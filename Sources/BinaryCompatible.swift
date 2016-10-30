//
//  BinaryCompatible.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/30.
//
//

import Foundation

public protocol BinaryCompatible {
    static func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> Self
    func convertIntoBinary(byteOrder: ByteOrder?) throws -> [UInt8]
}

// MARK: - Preset extensions

extension UInt8: BinaryCompatible {
    static public func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> UInt8 {
        return try stream.read()
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        return [self]
    }
}

extension UInt16: BinaryCompatible {
    static public func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> UInt16 {
        var buffer = try stream.readBytes(length: 2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return UInt16(littleEndian: value)
        case .big:
            return UInt16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff)
            ]
        case .big:
            return [
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension UInt32: BinaryCompatible {
    static public func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> UInt32 {
        var buffer = try stream.readBytes(length: 4)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return UInt32(littleEndian: value)
        case .big:
            return UInt32(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 24 & 0xff)
            ]
        case .big:
            return [
                UInt8(self >> 24 & 0xff),
                UInt8(self >> 16 & 0xff),
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}

extension Int16: BinaryCompatible {
    static public func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> Int16 {
        var buffer = try stream.readBytes(length: 2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: Int16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return Int16(littleEndian: value)
        case .big:
            return Int16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
        case .little:
            return [
                UInt8(self >> 0 & 0xff),
                UInt8(self >> 8 & 0xff)
            ]
        case .big:
            return [
                UInt8(self >> 8 & 0xff),
                UInt8(self >> 0 & 0xff)
            ]
        }
    }
}
