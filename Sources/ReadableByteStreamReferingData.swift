//
//  ReadableByteStreamReferingData.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2019/03/02.
//

import CoreFoundation

/// Make `ReadableByteStream` refering `Data`
///
/// - Parameter data: data
/// - Returns: a readable byte stream
public func ReadableByteStreamRefering(_ data: Data) -> ReadableByteStream {
    return ByteStream(data)
}

fileprivate class ByteStream : ReadableByteStream {
    
    private let data: Data
    
    internal init(_ data: Data) {
        self.data = data
        currentIndex = 0
    }
    
    // MARK: ReadableByteStream
    
    public var available: Int {
        get {
            return data.count - currentIndex
        }
    }
    
    public private(set) var currentIndex: Int
    
    public func read() throws -> UInt8 {
        guard available >= 1 else {
            throw ReadableByteStreamError.notAvailable
        }
        let value = data[currentIndex]
        currentIndex += 1
        return value
    }
    
    public func read(_ length: Int) throws -> [UInt8] {
        guard available >= length else {
            throw ReadableByteStreamError.notAvailable
        }
        // TODO: Be more smartly
        var value = [UInt8].init(repeating: 0, count: length)
        for i in 0 ..< length {
            value[i] = data[currentIndex + i]
        }
        currentIndex += length
        return value
    }
    
    public func moveIndex(to position: Int) {
        currentIndex = position
    }
    
    public func moveIndex(amount: Int) {
        currentIndex += amount
    }
    
    public subscript(index: Int) -> UInt8 {
        return data[currentIndex + index]
    }
    
}
