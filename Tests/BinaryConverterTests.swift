//
//  BinaryConverterTests.swift
//  BinaryConverterTests
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import XCTest
@testable import BinaryConverter

struct SimpleStructForTest {
    let id: UInt8
    let count: UInt16
}

extension SimpleStructForTest: BinaryCompatible {
    static public func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> SimpleStructForTest {
        let layout: [(String, BinaryCompatible.Type, ByteOrder?)] = [
            ("id", UInt8.self, nil),
            ("count", UInt16.self, nil)]
        let converted = try BinaryConverter.convert(stream: stream, layout: layout, defaultByteOrder: byteOrder)
        return SimpleStructForTest(id: converted["id"] as! UInt8, count: converted["count"] as! UInt16)
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) throws -> [UInt8] {
        throw BinaryConverterError.notSupported
    }
}

class BinaryConverterTests: XCTestCase {
    
    func testConvertingLittleEndianToValue() {
        let result = try? BinaryConverter.convert(array: [0x80, 0x00]) as Int16
        XCTAssertNotNil(result)
        if let result = result {
            XCTAssert(result == 128)
        }
    }
    
    func testConvertingBigEndianToValue() {
        let array = [0x80, 0x00] as [UInt8]
        let result = try? BinaryConverter.convert(arraySlice: array[0...1], byteOrder: .big) as Int16
        XCTAssertNotNil(result)
        if let result = result {
            XCTAssert(result == -32768)
        }
    }
    
    func testConvertingToValues() {
        let array = [0xff, 0x7f, 0x01, 0x02, 0x03, 0x04] as [UInt8]
        let stream = BinaryStream(array: array, startIndex: 0)
        let layout: [(String, BinaryCompatible.Type, ByteOrder?)] = [("ui16", UInt16.self, .little), ("ui32", UInt32.self, .big)]
        let result = try? BinaryConverter.convert(stream: stream, layout: layout, defaultByteOrder: nil)
        XCTAssertNotNil(result)
        
        if let result = result {
            XCTAssert(result["ui16"] is UInt16)
            XCTAssert(result["ui16"] as! UInt16 == 0x7fff)
            XCTAssert(result["ui32"] is UInt32)
            XCTAssert(result["ui32"] as! UInt32 == 0x01020304)
        }
    }
    
    func testConvertingCustomStructToValue() {
        let array = [0x10, 0x00, 0x08] as [UInt8]
        let stream = BinaryStream(arraySlice: array[0...2])
        let result = try? BinaryConverter.convert(stream: stream, byteOrder: .big) as SimpleStructForTest
        XCTAssertNotNil(result)
        if let result = result {
            XCTAssert(result.id == 0x10)
            XCTAssert(result.count == 8)
        }
    }
    
}
