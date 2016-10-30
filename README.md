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
    static func read(stream: BinaryStream, byteOrder: ByteOrder?) throws -> Self
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
- Int16

I will support other types gradually.
