//
//  ReadableByteStreamReferingArray.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2019/03/02.
//

import CoreFoundation

extension Array : ReadableByteStreamReferable where Element == UInt8 {
    public func makeReadableByteStream() -> ReadableByteStream {
        // [UInt8] -> ArraySlice<UInt8>
        return ByteStream(self[0 ..< count])
    }
}

extension ArraySlice : ReadableByteStreamReferable where Element == UInt8 {
    public func makeReadableByteStream() -> ReadableByteStream {
        return ByteStream(self)
    }
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
            throw ReadableByteStreamError.notAvailable
        }
        let value = array[currentIndex]
        currentIndex += 1
        return value
    }
    
    public func read(_ length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw ReadableByteStreamError.notAvailable
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
