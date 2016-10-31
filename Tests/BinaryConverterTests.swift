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
    public init(stream: BinaryStream, byteOrder: ByteOrder?) throws {
        let layout: [(String, BinaryCompatible.Type, ByteOrder?)] = [
            ("id", UInt8.self, nil),
            ("count", UInt16.self, nil)]
        let converted = try BinaryConverter.convert(stream: stream, layout: layout, defaultByteOrder: byteOrder)
        self = SimpleStructForTest(id: converted["id"] as! UInt8, count: converted["count"] as! UInt16)
    }
    
    // TODO: untested
    public func convertIntoBinary(byteOrder: ByteOrder?) -> [UInt8] {
        return []
    }
}

class BinaryConverterTests: XCTestCase {
    
    func testConvertingLittleEndianIntoValue() {
        let result = try! BinaryConverter.convert(array: [0x80, 0x00]) as Int16
        XCTAssert(result == 128)
    }
    
    func testConvertingBigEndianIntoValue() {
        let array = [0x80, 0x00] as [UInt8]
        let result = try! BinaryConverter.convert(arraySlice: array[0...1], byteOrder: .big) as Int16
        XCTAssert(result == -32768)
    }
    
    func testConvertingFixedArrayIntoValue() {
        // asciiz: [CChar](count: 8)
        let array = [0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
        var result = try! BinaryConverter.convert(array: array, count: 8, byteOrder: nil) as [CChar]
        
        XCTAssert(result.count == 8)
        let str = withUnsafePointer(to: &result[0]) {
            String(cString: $0)
        }
        XCTAssert(str == "ASCII")
    }
    
    func testConvertingIntoValues() {
        let values = try! BinaryConverter.convert(
            array: [0xff, 0x7f, 0x01, 0x02, 0x03, 0x04],
            layout: [("ui16", UInt16.self, .little), ("ui32", UInt32.self, nil)],
            defaultByteOrder: .big)
        
        XCTAssert(values["ui16"] is UInt16)
        XCTAssert(values["ui16"] as! UInt16 == 0x7fff)
        XCTAssert(values["ui32"] is UInt32)
        XCTAssert(values["ui32"] as! UInt32 == 0x01020304)
    }
    
    func testConvertingFixedArrayIntoValues() {
        // id: UInt8, asciiz: [CChar](count: 8)
        let array = [0x01, 0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
        let values = try! BinaryConverter.convert(array: array, layout: [("id", BinaryType(UInt8.self), nil), ("value", BinaryType(CChar.self, count: 8), nil)])
        
        XCTAssert(values["id"] is UInt8)
        XCTAssert(values["id"] as! UInt8 == 0x01)
        XCTAssert(values["value"] is [CChar])
        var value = values["value"] as! [CChar]
        XCTAssert(value.count == 8)
        let str = withUnsafePointer(to: &value[0]) {
            String(cString: $0)
        }
        XCTAssert(str == "ASCII")
    }
    
    func testConvertingCustomStructToValue() {
        let array = [0x10, 0x00, 0x08] as [UInt8]
        let stream = BinaryStream(arraySlice: array[0...2])
        let values = try! BinaryConverter.convert(stream: stream, byteOrder: .big) as SimpleStructForTest
        XCTAssert(values.id == 0x10)
        XCTAssert(values.count == 8)
    }
    
    
    func testConvertingValueIntoLittleEndian() {
        let value = 128 as Int16
        let result = BinaryConverter.convert(value: value, byteOrder: .little)
        XCTAssert(result == [0x80, 0x00])
    }
    
    func testConvertingValuesIntoBigEndian() {
        let values = [0x7fff, 0x0102] as [UInt16]
        let result = BinaryConverter.convert(values: values, byteOrder: .big)
        XCTAssert(result == [0x7f, 0xff, 0x01, 0x02])
    }
}
