//
//  ReadableByteStreamReferingArray.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2019/03/02.
//

import CoreFoundation

/// Make `ReadableByteStream` refering array (`ArraySlice<UInt8>`)
///
/// - Parameter array: an array
/// - Returns: a readable byte stream
public func ReadableByteStreamRefering(_ array: ArraySlice<UInt8>) -> ReadableByteStream {
    return ByteStream(array)
}

fileprivate class ByteStream : ReadableByteStream {
    
    private let array: ArraySlice<UInt8>
    
    internal init(_ arraySlice: ArraySlice<UInt8>) {
        self.array = arraySlice
        currentIndex = array.startIndex
    }
    
    // MARK: ReadableByteStream
    
    public var available: Int {
        get {
            return array.endIndex - currentIndex
        }
    }
    
    public private(set) var currentIndex: Int
    
    public func read() throws -> UInt8 {
        guard available >= 1 else {
            throw BinaryConverterError.notAvailable
        }
        let value = array[currentIndex]
        currentIndex += 1
        return value
    }
    
    public func read(_ length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw BinaryConverterError.notAvailable
        }
        let value = [UInt8](array[currentIndex ..< currentIndex + length])
        currentIndex += length
        return value
    }
    
    public func moveIndex(to position: Int) {
        currentIndex = array.startIndex + position
    }
    
    public func moveIndex(amount: Int) {
        currentIndex += amount
    }
    
    public subscript(index: Int) -> UInt8 {
        return array[currentIndex + index]
    }
    
}
