//
//  ReadableByteStream.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2019/03/02.
//

import CoreFoundation

public enum ReadableByteStreamError: Error {
    case notAvailable
}

/// Data reading in byte units
public protocol ReadableByteStream {
    
    /// Available bytes count to read
    var available: Int { get }
    
    /// Current index points a next byte read
    var currentIndex: Int { get }
    
    /// Read a byte at `currentIndex`, and increment `currentIndex`
    ///
    /// - Returns: a byte read
    /// - Throws:
    ///   - ReadableByteStreamError.notAvailable: when `available == 0`
    func read() throws -> UInt8
    
    /// Read bytes from `currentIndex`
    ///
    /// - Throws:
    ///   - ReadableByteStreamError.notAvailable: when `available < ammount`
    func read(_ length: Int) throws -> [UInt8]
    
    /// Get a byte
    ///
    /// - Parameter index: points the position of the byte to be referred, is based on `currentIndex`
    subscript(index: Int) -> UInt8 { get }
    
    /// Move `currentIndex` to specified position
    ///
    /// - Parameter position: next position to read
    /// - Throws:
    ///   - BinaryConverterError.outOfRange:
    func moveIndex(to position: Int) throws
    
    /// Move `currentIndex` by specified amount
    ///
    /// - Parameter amount: bytes count
    /// - Throws:
    ///   - BinaryConverterError.outOfRange:
    func moveIndex(amount: Int) throws
}

public protocol ReadableByteStreamReferable {
    
    /// Make `ReadableByteStream` refering `self`
    ///
    /// - Returns: a readable byte stream
    func makeReadableByteStream() -> ReadableByteStream
}
