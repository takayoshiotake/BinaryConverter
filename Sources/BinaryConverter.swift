//
//  BinaryConverter.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import Foundation

public enum BinaryConverterError: Error {
    case streamIsShort
}

public enum ByteOrder {
    case little
    case big
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

public let defaultByteOrder = ByteOrder.little

public class BinaryStream {
    public let buffer: ArraySlice<UInt8>
    public var currentIndex: Int
    
    public init(arraySlice: ArraySlice<UInt8>) {
        buffer = arraySlice
        currentIndex = buffer.startIndex
    }
    
    public init(array: Array<UInt8>, startIndex: Int) {
        assert(startIndex >= 0)
        assert(startIndex < array.count)
        buffer = array[startIndex..<array.count]
        currentIndex = buffer.startIndex
    }
    
    
    public var available: Int {
        get {
            return buffer.endIndex - currentIndex
        }
    }
    
    // mutating
    public func read() throws -> UInt8 {
        guard available >= 1 else {
            throw BinaryConverterError.streamIsShort
        }
        let value = buffer[currentIndex]
        currentIndex += 1
        return value
    }
    
    // mutating
    public func readBytes(length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw BinaryConverterError.streamIsShort
        }
        let value = [UInt8](buffer[currentIndex..<currentIndex + length])
        currentIndex += length
        return value
    }
    
    // mutating
    public func moveIndex(to index: Int) {
        currentIndex = buffer.startIndex + index
    }
    
    // mutating
    public func skipBytes(length: Int) {
        currentIndex += length
    }
    
    // nonmutating read
    public subscript(index: Int) -> UInt8 {
        return buffer[currentIndex + index]
    }

    // nonmutating readBytes (1)
    public subscript(range: Range<Int>) -> ArraySlice<UInt8> {
        let currentBaseRange = currentIndex+range.lowerBound..<currentIndex+range.upperBound
        return buffer[currentBaseRange]
    }

    // nonmutating readBytes (2)
    public subscript(range: ClosedRange<Int>) -> ArraySlice<UInt8> {
        let currentBaseRange = currentIndex+range.lowerBound...currentIndex+range.upperBound
        return buffer[currentBaseRange]
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
    
    /// Converts the `[UInt8]` into `T`, by reading the `array`.
    ///
    /// - parameter array: this is containing the converting value
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the array
    public class func convert<T: BinaryCompatible>(array: Array<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try convert(stream: BinaryStream(array: array, startIndex: 0), byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `T`, by reading the `arraySlice`.
    ///
    /// - parameter arraySlice: this is containing the converting value
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the arraySlice
    public class func convert<T: BinaryCompatible>(arraySlice: ArraySlice<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try convert(stream: BinaryStream(arraySlice: arraySlice), byteOrder: byteOrder)
    }

    /// Converts the `[UInt8]` into `T`, by reading the `stream`.
    ///
    /// - parameter stream: this is containing the converting value
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the stream
    public class func convert<T: BinaryCompatible>(stream: BinaryStream, byteOrder: ByteOrder? = nil) throws -> T {
        return try T(stream: stream, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `array`.
    ///
    /// - parameter array: this is containing the converting values
    /// - parameter count: the count of the converting values
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the array
    public class func convert<T: BinaryCompatible>(array: Array<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(stream: BinaryStream(array: array, startIndex: 0), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `arraySlice`.
    ///
    /// - parameter arraySlice: this is containing the converting values
    /// - parameter count: the count of the converting values
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the arraySlice
    public class func convert<T: BinaryCompatible>(arraySlice: ArraySlice<UInt8>, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        return try convert(stream: BinaryStream(arraySlice: arraySlice), count: count, byteOrder: byteOrder)
    }
    
    /// Converts the `[UInt8]` into `[T]`, by reading the `stream`.
    ///
    /// - parameter stream: this is containing the converting values
    /// - parameter count: the count of the converting values
    /// - parameter byteOrder: the byte order of the converting value; default is `nil` (optional)
    /// - returns: the value converted
    /// - throws: BinaryConverterError.streamIsShort: Could not read the value from the stream
    public class func convert<T: BinaryCompatible>(stream: BinaryStream, count: Int, byteOrder: ByteOrder? = nil) throws -> [T] {
        var value = [] as [T]
        for _ in 0..<count {
            value.append(try T(stream: stream, byteOrder: byteOrder))
        }
        return value
    }
    
    
    public class func convert<Key: Hashable>(array: Array<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(stream: BinaryStream(array: array, startIndex: 0), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(stream: BinaryStream(arraySlice: arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(stream: BinaryStream, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            result[key] = try type.init(stream: stream, byteOrder: byteOrder ?? defaultByteOrder)
        }
        return result
    }

    
    public class func convert<Key: Hashable>(array: Array<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(stream: BinaryStream(array: array, startIndex: 0), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(arraySlice: ArraySlice<UInt8>, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
        return try convert(stream: BinaryStream(arraySlice: arraySlice), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    public class func convert<Key: Hashable>(stream: BinaryStream, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder? = nil) throws -> Dictionary<Key, Any> {
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
    
    public class func convert(values: [BinaryCompatible], byteOrder: ByteOrder? = nil) -> [UInt8] {
        var binary: [UInt8] = []
        for value in values {
            binary.append(contentsOf: value.convertIntoBinary(byteOrder: byteOrder))
        }
        return binary
    }
    
}
