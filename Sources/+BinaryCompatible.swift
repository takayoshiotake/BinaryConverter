//
//  +BinaryCompatible.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/30.
//
//

import Foundation

extension UInt8: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        self = try stream.read()
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        return [self]
    }
}

extension UInt16: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        var buffer = try stream.readBytes(length: 2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .littleEndian:
            self = UInt16(littleEndian: value)
        case .bigEndian:
            self = UInt16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
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

extension UInt32: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        var buffer = try stream.readBytes(length: 4)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .littleEndian:
            self = UInt32(littleEndian: value)
        case .bigEndian:
            self = UInt32(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
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

extension Int8: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        self = Int8(bitPattern: try stream.read())
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        return [UInt8(bitPattern: self)]
    }
}

extension Int16: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        var buffer = try stream.readBytes(length: 2)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: Int16.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .littleEndian:
            self = Int16(littleEndian: value)
        case .bigEndian:
            self = Int16(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
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

extension Int32: BinaryCompatible {
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        var buffer = try stream.readBytes(length: 4)
        let value = withUnsafePointer(to: &buffer[0]) {
            $0.withMemoryRebound(to: Int32.self, capacity: 1) {
                $0[0]
            }
        }
        switch byteOrder ?? defaultByteOrder {
        case .littleEndian:
            self = Int32(littleEndian: value)
        case .bigEndian:
            self = Int32(bigEndian: value)
        }
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        switch byteOrder ?? defaultByteOrder {
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

