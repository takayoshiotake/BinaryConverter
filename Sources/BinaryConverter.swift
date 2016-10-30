//
//  BinaryConverter.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import Foundation

public enum BinaryConverterError: Error {
    case failedToRead
    case notSupported
}

public enum ByteOrder {
    case little
    case big
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
            throw BinaryConverterError.failedToRead
        }
        let value = buffer[currentIndex]
        currentIndex += 1
        return value
    }
    
    // mutating
    public func readBytes(length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw BinaryConverterError.failedToRead
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

public class BinaryConverter {
    public class func convert<T: BinaryCompatible>(array: Array<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try T.read(stream: BinaryStream(array: array, startIndex: 0), byteOrder: byteOrder)
    }
    
    public class func convert<T: BinaryCompatible>(arraySlice: ArraySlice<UInt8>, byteOrder: ByteOrder? = nil) throws -> T {
        return try T.read(stream: BinaryStream(arraySlice: arraySlice), byteOrder: byteOrder)
    }
    
    public class func convert<T: BinaryCompatible>(stream: BinaryStream, byteOrder: ByteOrder? = nil) throws -> T {
        return try T.read(stream: stream, byteOrder: byteOrder)
    }
    
    public class func convert<Key: Hashable>(stream: BinaryStream, layout: Array<(Key, BinaryCompatible.Type, ByteOrder?)>, defaultByteOrder: ByteOrder?) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            result[key] = try type.read(stream: stream, byteOrder: byteOrder ?? defaultByteOrder)
        }
        return result
    }
}
