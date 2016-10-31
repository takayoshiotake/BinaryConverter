//
//  BinaryConverter.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import Foundation

public let defaultByteOrder = ByteOrder.littleEndian

public enum BinaryConverterError: Error {
    case streamIsShort
    case notSupportedType
}

public enum ByteOrder {
    case littleEndian
    case bigEndian
}

public protocol BinaryCompatible {
    init(stream: BinaryStream, byteOrder: ByteOrder?) throws
    func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8]
}

public enum BinaryType {
    case type(type: BinaryCompatible.Type)
    case fixedCountArray(type: BinaryCompatible.Type, count: Int)
    
    init(_ type: BinaryCompatible.Type) {
        self = .type(type: type)
    }
    
    init(_ type: BinaryCompatible.Type, count: Int) {
        self = .fixedCountArray(type: type, count: count)
    }
}

public class BinaryStream {
    public let binary: ArraySlice<UInt8>
    public var currentIndex: Int
    
    public init(_ arraySlice: ArraySlice<UInt8>) {
        self.binary = arraySlice
        currentIndex = binary.startIndex
    }
    
    
    public var available: Int {
        get {
            return binary.endIndex - currentIndex
        }
    }
    
    // mutating
    public func read() throws -> UInt8 {
        guard available >= 1 else {
            throw BinaryConverterError.streamIsShort
        }
        let value = binary[currentIndex]
        currentIndex += 1
        return value
    }
    
    // mutating
    public func readBytes(length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw BinaryConverterError.streamIsShort
        }
        let value = [UInt8](binary[currentIndex..<currentIndex + length])
        currentIndex += length
        return value
    }
    
    // mutating
    public func moveIndex(to index: Int) {
        currentIndex = binary.startIndex + index
    }
    
    // mutating
    public func skipBytes(length: Int) {
        currentIndex += length
    }
    
    // nonmutating read
    public subscript(index: Int) -> UInt8 {
        return binary[currentIndex + index]
    }

    // nonmutating readBytes (1)
    public subscript(range: Range<Int>) -> ArraySlice<UInt8> {
        let currentBaseRange = currentIndex+range.lowerBound..<currentIndex+range.upperBound
        return binary[currentBaseRange]
    }

    // nonmutating readBytes (2)
    public subscript(range: ClosedRange<Int>) -> ArraySlice<UInt8> {
        let currentBaseRange = currentIndex+range.lowerBound...currentIndex+range.upperBound
        return binary[currentBaseRange]
    }
    
}

/// Converts the `[UInt8]` into `BinaryCompatible` value(s), by reading the `Array<UInt8>`, `ArraySlice<UInt8>` or `BinaryStream`.
/// And converts the `BinaryCompatible` value(s) into `[UInt8]`.
///
/// Converting example:
/// 
///     // Get a Int16 value from [UInt8]
///     BinaryConverter.convert(array: [0x80, 0x00], byteOrder: .little) as Int16 // returns 128
///
public class BinaryConverter {
    
    // MARK: - Converting `[UInt8]` into `BinaryCompatible` value(s)
    
    /// Converts the `[UInt8]` into `T`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary array: Array<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try convert(binary: BinaryStream(array[0..<array.count]), byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `T`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary arraySlice: ArraySlice<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try convert(binary: BinaryStream(arraySlice), byteOrder: byteOrder)
    }

    /// Converts the `[UInt8]` into `T`, by reading the `binary`.
    ///
    /// - parameter binary: this is containing the converting value
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the binary
    public class func convert<T: BinaryCompatible>(binary stream: BinaryStream, byteOrder: ByteOrder? = nil) throws -> T {
        return try T(stream: stream, byteOrder: byteOrder)
    }
    
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary array: Array<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(binary: BinaryStream(array[0..<array.count]), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary arraySlice: ArraySlice<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(binary: BinaryStream(arraySlice), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    ///
    /// - parameter stream: this is containing the converting values
    /// - parameter count: the count of the converting values
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the stream
    public class func convert<T: BinaryCompatible>(binary stream: BinaryStream, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        var value = [] as [T]
        for _ in 0..<count {
            value.append(try T(stream: stream, byteOrder: byteOrder))
        }
        return value
    }
    
    
    public class func convert<Key: Hashable>(binary array: Array<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: BinaryStream(array[0..<array.count]), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: BinaryStream(arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary stream: BinaryStream, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            result[key] = try type.init(stream: stream, byteOrder: byteOrder ?? defaultByteOrder)
        }
        return result
    }

    
    public class func convert<Key: Hashable>(binary array: Array<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: BinaryStream(array[0..<array.count]), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: BinaryStream(arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary stream: BinaryStream, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            switch type {
            case .type(let type):
                result[key] = try type.init(stream: stream, byteOrder: byteOrder ?? defaultByteOrder)
                break
            case .fixedCountArray(let type, let count):
                var array = [] as [Any]
                for _ in 0..<count {
                    array.append(try type.init(stream: stream, byteOrder: byteOrder ?? defaultByteOrder))
                }
                result[key] = array
                break
            }
        }
        return result
    }
    
    // MARK: - Converting `BinaryCompatible` value(s) into `[UInt8]`
    
    public class func convert(value: BinaryCompatible, byteOrder: ByteOrder? = nil) -> [UInt8] {
        return value.convertIntoBinary(byteOrder: byteOrder)
    }
    
    public class func convert<T: BinaryCompatible>(values: Array<T>, byteOrder: ByteOrder? = nil) -> [UInt8] {
        var binary: [UInt8] = []
        for value in values {
            binary.append(contentsOf: value.convertIntoBinary(byteOrder: byteOrder))
        }
        return binary
    }
    
    // FIXME: limit type of `mixedValues` to as like Array<Binarizable>, but `Array` can not inherit protocol with 'Element' constraints in Swift 3.0.x. And I want to remove the `throws`.
    public class func convert(mixedValues: Array<Any>, byteOrder: ByteOrder? = nil) throws -> [UInt8] {
        var binary: [UInt8] = []
        for unknownTypeValue in mixedValues {
            switch unknownTypeValue {
            case let value as BinaryCompatible:
                binary.append(contentsOf: convert(value: value, byteOrder: byteOrder))
            case let values as Array<BinaryCompatible>:
                #if false
                    // Error: in Swift 3.0.x
                    binary.append(contentsOf: convert(values: values, byteOrder: byteOrder))
                #else
                    for value in values {
                        binary.append(contentsOf: convert(value: value, byteOrder: byteOrder))
                    }
                #endif
            default:
                throw BinaryConverterError.notSupportedType
            }
        }
        return binary
    }
    
}

//
// I want to write as following, but it is ill-formed in Swift 3.0.x
//
//public protocol Binarizable {
//    func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8]
//}
//
//// Error: Extension of protocol 'BinaryCompatible' cannot have an inheritance clause
//extension BinaryCompatible: Binarizable {
//}
//
//// Error: Extension of type 'Array' with constraints cannot have an inheritance clause
//extension Array: Binarizable where Element: BinaryCompatible {
//    internal func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
//        var binary: [UInt8] = []
//        for value in self {
//            binary.append(contentsOf: value.convertIntoBinary(byteOrder: byteOrder))
//        }
//        return binary
//    }
//}

// This is nonsence...
//extension Array where Element: BinaryCompatible {
//    internal func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
//        var binary: [UInt8] = []
//        for value in self {
//            binary.append(contentsOf: value.convertIntoBinary(byteOrder: byteOrder))
//        }
//        return binary
//    }
//}
