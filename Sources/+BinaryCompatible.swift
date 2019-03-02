//
//  +BinaryCompatible.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/30.
//
//

import Foundation

extension UInt8: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        self = try stream.read()
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        return [self]
    }
}

extension UInt16: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        var buffer = try stream.read(2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder {
        case .littleEndian:
            self = UInt16(littleEndian: value)
        case .bigEndian:
            self = UInt16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        switch byteOrder {
        case .littleEndian:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff)
            ]
        case .bigEndian:
            return [
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension UInt32: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        var buffer = try stream.read(4)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder {
        case .littleEndian:
            self = UInt32(littleEndian: value)
        case .bigEndian:
            self = UInt32(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        switch byteOrder {
        case .littleEndian:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 24 & 0xff)
            ]
        case .bigEndian:
            return [
                UInt8(self >> 24 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension Int8: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        self = Int8(bitPattern: try stream.read())
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        return [UInt8(bitPattern: self)]
    }
}

extension Int16: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        var buffer = try stream.read(2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: Int16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder {
        case .littleEndian:
            self = Int16(littleEndian: value)
        case .bigEndian:
            self = Int16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        switch byteOrder {
        case .littleEndian:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff)
            ]
        case .bigEndian:
            return [
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension Int32: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        var buffer = try stream.read(4)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: Int32.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder {
        case .littleEndian:
            self = Int32(littleEndian: value)
        case .bigEndian:
            self = Int32(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        switch byteOrder {
        case .littleEndian:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 24 & 0xff)
            ]
        case .bigEndian:
            return [
                UInt8(self >> 24 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension Data: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws {
        self = Data(try stream.read(stream.available))
    }
    
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        var binary = [UInt8](repeating: 0, count: count)
        _ = binary.withUnsafeMutableBufferPointer {
            copyBytes(to: $0)
        }
        return binary
    }
}

extension Array: Binarizable where Element: Binarizable {
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        var binary: [UInt8] = []
        for value in self {
            binary.append(contentsOf: value.binarize(byteOrder: byteOrder))
        }
        return binary
    }
}

extension ArraySlice: Binarizable where Element: Binarizable {
    public func binarize(byteOrder: ByteOrder) -> [UInt8] {
        var binary: [UInt8] = []
        for value in self {
            binary.append(contentsOf: value.binarize(byteOrder: byteOrder))
        }
        return binary
    }
}
