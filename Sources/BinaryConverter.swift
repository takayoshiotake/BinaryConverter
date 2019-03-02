//
//  BinaryConverter.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import CoreFoundation

public enum BinaryConverterError: Error {
    case notSupportedType
}

public enum ByteOrder {
    case littleEndian
    case bigEndian
    
    static var hostEndian: ByteOrder {
        get {
            return CFByteOrderGetCurrent() == Int(CFByteOrderBigEndian.rawValue) ? .bigEndian : .littleEndian
        }
    }
}

public protocol Binarizable {
    func binarize(byteOrder: ByteOrder?) -> [UInt8]
}

public protocol BinaryCompatible : Binarizable {
    init(stream: ReadableByteStream, byteOrder: ByteOrder?) throws
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
        return try convert(binary: ReadableByteStreamRefering(array[0..<array.count]), byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `T`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary arraySlice: ArraySlice<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try convert(binary: ReadableByteStreamRefering(arraySlice), byteOrder: byteOrder)
    }

    /// Converts the `[UInt8]` into `T`, by reading the `binary`.
    ///
    /// - parameter binary: this is containing the converting value
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the binary
    public class func convert<T: BinaryCompatible>(binary stream: ReadableByteStream, byteOrder: ByteOrder? = nil) throws -> T {
        return try T(stream: stream, byteOrder: byteOrder)
    }
    
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary array: Array<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(binary: ReadableByteStreamRefering(array[0..<array.count]), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    public class func convert<T: BinaryCompatible>(binary arraySlice: ArraySlice<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(binary: ReadableByteStreamRefering(arraySlice), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `binary`.
    ///
    /// - parameter stream: this is containing the converting values
    /// - parameter count: the count of the converting values
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the stream
    public class func convert<T: BinaryCompatible>(binary stream: ReadableByteStream, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        var value = [] as [T]
        for _ in 0..<count {
            value.append(try T(stream: stream, byteOrder: byteOrder))
        }
        return value
    }
    
    
    public class func convert<Key: Hashable>(binary array: Array<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: ReadableByteStreamRefering(array[0..<array.count]), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: ReadableByteStreamRefering(arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary stream: ReadableByteStream, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            result[key] = try type.init(stream: stream, byteOrder: byteOrder ?? defaultByteOrder)
        }
        return result
    }

    
    public class func convert<Key: Hashable>(binary array: Array<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: ReadableByteStreamRefering(array[0..<array.count]), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(binary: ReadableByteStreamRefering(arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(binary stream: ReadableByteStream, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
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
        return value.binarize(byteOrder: byteOrder)
    }
    
    public class func convert<T: BinaryCompatible>(values: Array<T>, byteOrder: ByteOrder? = nil) -> [UInt8] {
        var binary: [UInt8] = []
        for value in values {
            binary.append(contentsOf: value.binarize(byteOrder: byteOrder))
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
                    array.append(contentsOf: convert(values: values, byteOrder: byteOrder))
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
