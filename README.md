# BinaryConverter

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/takayoshiotake/BinaryConverter.svg)](https://github.com/takayoshiotake/BinaryConverter/releases)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platforms](http://img.shields.io/badge/platforms-iOS%20|%20macOS-lightgrey.svg?style=flat)
![Swift 3.0.x](http://img.shields.io/badge/Swift-3.0.x-orange.svg?style=flat)

**BinaryConverter** is incomplete and in development.

**BinaryConverter** can convert `Array<UInt8>` (`ArraySlice<UInt8>`) and value. (e.g. converting `[UInt8]` into `Int16`)
Type of the value must adopt `BinaryCompatible` protocol.

```swift
public protocol BinaryCompatible {
    init(stream: BinaryStream, byteOrder: ByteOrder?) throws
    func convertIntoBinary(byteOrder: ByteOrder?) throws -> [UInt8]
}
```

## Usage

### Examples

- Converting `[UInt8]` into `Int16`

```
BinaryConverter.convert(array: [0x80, 0x00], byteOrder: .little) as Int16 // 128
BinaryConverter.convert(array: [0x80, 0x00], byteOrder: .big) as Int16 // -32768
```

- Converting 8 bytes byte array into [CChar]

```
BinaryConverter.convert(array: [0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00], count: 8) as [CChar]
let str = withUnsafePointer(to: &result[0]) { String(cString: $0) } // "ASCII"
```

- Converting `[UInt8]` with layout information

```
// id: UInt8, asciiz: [CChar](count: 8)
let array = [0x01, 0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
let values = try! BinaryConverter.convert(array: array, layout: [("id", BinaryType(UInt8.self), nil), ("value", BinaryType(CChar.self, count: 8), nil)]) // ["id": 1, "value": [65, 83, 67, 73, 73, 0, 0, 0]]
```

- Converting `Int16` into `[UInt8]`

```swift
// implementing...
```

See *BinaryConverterTests.swift* for more details.

## Adopting State of `BinaryCompatible ` Protocol

I am adopting `BinaryCompatible` protocol to following types:

- UInt8
- UInt16
- UInt32
- Int8
- Int16
- Int32
- CChar

I will support other types gradually.
