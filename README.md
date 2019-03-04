# BinaryConverter

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/takayoshiotake/BinaryConverter.svg)](https://github.com/takayoshiotake/BinaryConverter/releases)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platforms](http://img.shields.io/badge/platforms-iOS%20|%20macOS-lightgrey.svg?style=flat)
![Swift 3.0.x](http://img.shields.io/badge/Swift-4.2.x-orange.svg?style=flat)

**BinaryConverter** is incomplete and in development.

**BinaryConverter** can convert binary and value. Supported binary types are `Array<UInt8>`, `ArraySlice<UInt8>` and `Data`. (e.g. converting `[UInt8]` into `Int16`)

In order to parse binary into value, the type of value must adopt `BinaryParsable` protocol.

```swift
public protocol BinaryParsable {
    init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws
}
```

And, in order to binarize value, the type of value must adopt `Binarizable` protocol.

```swift
public protocol Binarizable {
    func binarize(byteOrder: ByteOrder) -> [UInt8]
}
```

## Usage

### Examples

- Parsing a binary as `[UInt8]` into `Int16`

```
print(try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .littleEndian) as Int16) // 128
print(try! BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .bigEndian) as Int16) // -32768
```

- Parsing a 8 bytes binary into [CChar]

```
var asciiz8 = try! BinaryConverter.parse(binary: [0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00], count: 8) as [CChar]
let str = withUnsafePointer(to: &asciiz8[0]) { String(cString: $0) }
print(str) // "ASCII"
```

- Parsing a binary as `[UInt8]` with layout param

```
// id: UInt8, asciiz: [CChar](count: 8)
let array = [0x01, 0x41, 0x53, 0x43, 0x49, 0x49, 0x00, 0x00, 0x00] as [UInt8]
let values = try! BinaryConverter.parse(binary: array, layout: [("id", BinaryElement(UInt8.self)), ("asciiz", BinaryElement(CChar.self, count: 8))])
print(values) // ["id": 1, "asciiz": [65, 83, 67, 73, 73, 0, 0, 0]]
```

- Binarizing `Int16` into `[UInt8]`

```swift
print(BinaryConverter.binarize(128 as Int16, byteOrder: .littleEndian)) // [128, 0]
```

- Binarizing `[Int16]` into `[UInt8]`

```swift
print(BinaryConverter.binarize([0x7fff, 0x0102] as [Int16], byteOrder: .bigEndian)) // [127, 255, 1, 2]
```
- Binarizing values into `[UInt8]`

```swift
let result = BinaryConverter.binarize([-32768 as Int16, 0x01020304 as UInt32, "ASCII".cString(using: .ascii)!], byteOrder: .bigEndian)
print(result) // [128, 0, 1, 2, 3, 4, 65, 83, 67, 73, 73, 0]
```

See *BinaryConverterTests.swift* for more details.

## Adopting State of `BinaryParsable` and `Binarizable` Protocol

I am adopting `BinaryCompatible` protocol to following types:

- UInt8
- UInt16
- UInt32
- Int8
- Int16
- Int32
- CChar
- Data
- Array&lt;Binarizable&gt;
- ArraySlice&lt;Binarizable&gt;
