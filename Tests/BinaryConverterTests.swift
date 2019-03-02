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

extension SimpleStructForTest: Binarizable, BinaryPersable {
    public init(parsing stream: ReadableByteStream, byteOrder: ByteOrder?) throws {
        let layout: [(String, BinaryPersable.Type, ByteOrder?)] = [
            ("id", UInt8.self, nil),
            ("count", UInt16.self, nil)]
        let converted = try BinaryConverter.parse(binary: stream, layout: layout, defaultByteOrder: byteOrder)
        self = SimpleStructForTest(id: converted["id"] as! UInt8, count: converted["count"] as! UInt16)
    }
    
    public func binarize(byteOrder: ByteOrder?) -> [UInt8] {
        return try! BinaryConverter.binarize(mixedValues: [id, count], byteOrder: byteOrder)
    }
}

class BinaryConverterTests: XCTestCase {
    
    func testByteOrderOfHost() {
        print("Info: ByteOrder.hostEndian=\(ByteOrder.hostEndian)")
    }
    
    func testConvertingLittleEndianIntoValue() {
        let result = try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .littleEndian) as Int16
        XCTAssert(result == 128)
    }
    
    func testConvertingBigEndianIntoValue() {
        let result = try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .bigEndian) as Int16
        XCTAssert(result == -32768)
    }
    
    func testConvertingBinaryIntoData() {
        let binary = [0x01, 0x02, 0x03, 0x04, 0xAA, 0x55, 0xFF, 0x00] as [UInt8]
        let result = try! BinaryConverter.parse(binary: binary) as Data
        XCTAssert(binary == BinaryConverter.binarize(value: result))
    }
    
    func testConvertingFixedArrayIntoValue() {
        let asciiz8 = [0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
        XCTAssert(asciiz8.count == 8)
        var result = try! BinaryConverter.parse(binary: asciiz8, count: asciiz8.count, byteOrder: nil) as [CChar]
        XCTAssert(result.count == 8)
        let str = withUnsafePointer(to: &result[0]) {
            String(cString: $0)
        }
        XCTAssert(str == "ASCII")
    }
    
    func testConvertingBinaryIntoValues1() {
        // ui16=.little, ui32=.big
        let values = try! BinaryConverter.parse(
            binary: [0xff, 0x7f, 0x01, 0x02, 0x03, 0x04],
            layout: [("ui16", UInt16.self, .littleEndian), ("ui32", UInt32.self, nil)],
            defaultByteOrder: .bigEndian)
        XCTAssert(values["ui16"] is UInt16)
        XCTAssert(values["ui16"] as! UInt16 == 0x7fff)
        XCTAssert(values["ui32"] is UInt32)
        XCTAssert(values["ui32"] as! UInt32 == 0x01020304)
    }
    
    func testConvertingBinaryIntoValues2() {
        // id: UInt8, asciiz: [CChar](count: 8)
        let data = Data.init(bytes: [0x01, 0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00])
        let values = try! BinaryConverter.parse(binary: data, layout: [("id", BinaryType(UInt8.self), nil), ("asciiz", BinaryType(CChar.self, count: 8), nil)])
        XCTAssert(values["id"] is UInt8)
        XCTAssert(values["id"] as! UInt8 == 0x01)
        XCTAssert(values["asciiz"] is [CChar])
        var value = values["asciiz"] as! [CChar]
        XCTAssert(value.count == 8)
        let str = withUnsafePointer(to: &value[0]) {
            String(cString: $0)
        }
        XCTAssert(str == "ASCII")
    }
    
    func testConvertingCustomStructIntoValue() {
        let array = [0x10, 0x00, 0x08] as [UInt8]
        let values = try! BinaryConverter.parse(binary: array, byteOrder: .bigEndian) as SimpleStructForTest
        XCTAssert(values.id == 0x10)
        XCTAssert(values.count == 8)
    }
    
    
    func testConvertingValueIntoLittleEndian() {
        let value = 128 as Int16
        let result = BinaryConverter.binarize(value: value, byteOrder: .littleEndian)
        XCTAssert(result == [0x80, 0x00])
    }
    
    func testConvertingValuesIntoBigEndian() {
        let values = [0x7fff, 0x0102] as [UInt16]
        let result = BinaryConverter.binarize(values: values, byteOrder: .bigEndian)
        XCTAssert(result == [0x7f, 0xff, 0x01, 0x02])
    }
    
    func testConvertingValuesIntoBinary() {
        var asciiz8 = [CChar](repeating: 0, count: 8)
        let asciiz = "ASCII".cString(using: .ascii)!
        asciiz8.replaceSubrange(0..<asciiz.count, with: asciiz)
        
        let values = [
            128 as Int16,
            0x01020304 as UInt32,
            asciiz8
        ] as [Any]
        let result = try! BinaryConverter.binarize(mixedValues: values, byteOrder: .bigEndian)
        XCTAssert(result == [
            0x00, 0x80,
            0x01, 0x02, 0x03, 0x04,
            0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00
        ])
    }
    
    func testConvertingCustomStructIntoBinary() {
        let value = SimpleStructForTest(id: 0x10, count: 8)
        let binary = BinaryConverter.binarize(value: value, byteOrder: .bigEndian)
        XCTAssert(binary == [0x10, 0x00, 0x08])
    }
    
    
    func testExample() {
        print(try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .littleEndian) as Int16) // 128
        print(try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .bigEndian) as Int16) // -32768
        
        var asciiz8 = try! BinaryConverter.parse(binary: [0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00], count: 8) as [CChar]
        let str = withUnsafePointer(to: &asciiz8[0]) { String(cString: $0) }
        print(str) // "ASCII"
        
        // id: UInt8, asciiz: [CChar](count: 8)
        let array = [0x01, 0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
        let values = try! BinaryConverter.parse(binary: array, layout: [("id", BinaryType(UInt8.self), nil), ("asciiz", BinaryType(CChar.self, count: 8), nil)]) // ["id": 1, "asciiz": [65, 83, 67, 73, 73, 0, 0, 0]]
        print(values)
        
        
        print(BinaryConverter.binarize(value: 128 as Int16, byteOrder: .littleEndian))
        print(BinaryConverter.binarize(values: [0x7fff, 0x0102] as [Int16], byteOrder: .bigEndian))
        
        let result = try! BinaryConverter.binarize(mixedValues: [-32768 as Int16, 0x01020304 as UInt32, "ASCII".cString(using: .ascii)!], byteOrder: .bigEndian)
        print(result) // [128, 0, 1, 2, 3, 4, 65, 83, 67, 73, 73, 0]
    }
}
