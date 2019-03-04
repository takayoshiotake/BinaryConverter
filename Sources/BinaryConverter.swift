//
//  BinaryConverter.swift
//  BinaryConverter
//
//  Created by OTAKE Takayoshi on 2016/10/29.
//
//

import CoreFoundation

public enum ByteOrder {
    case littleEndian
    case bigEndian
    
    public static var hostEndian: ByteOrder {
        get {
            return CFByteOrderGetCurrent() == Int(CFByteOrderBigEndian.rawValue) ? .bigEndian : .littleEndian
        }
    }
}

public protocol Binarizable {
    func binarize(byteOrder: ByteOrder) -> [UInt8]
}

public protocol BinaryParsable {
    init(parsing stream: ReadableByteStream, byteOrder: ByteOrder) throws
}

public enum BinaryType {
    case type(type: BinaryParsable.Type)
    case fixedCountArray(type: BinaryParsable.Type, count: Int)
    
    public init(_ type: BinaryParsable.Type) {
        self = .type(type: type)
    }
    
    public init(_ type: BinaryParsable.Type, count: Int) {
        self = .fixedCountArray(type: type, count: count)
    }
}

/// Converts binary and value(s)
///
/// Data type can convert from binary are required adopting `BinaryParsable` protocol. If you want to adopt it for your data type, +BinaryCompatible.swift will be helpful you as example code.
///
/// Similarly, for converting value(s) to binary, it's type is required adopting `Binarizable`.
///
/// Summary of the above:
/// - BinaryParsable -> value(s)
/// - Binarizable -> binary
///
/// ---
/// In default, we support `[UInt8]`, `ArraySlice<UInt8>` and `Data` as the binary. If you want to use other one, you need to a new class that adopts ReadableByteStream. ReadableByteStreamRefering*.swift will be helpful for you.
///
/// ---
/// A simple example of converting:
/// 
///     // Get a Int16 value from [UInt8]
///     BinaryConverter.parse(binary: [0x80, 0x00], byteOrder: .little) as Int16 // returns 128
///
/// More example codes are in my tests code: BinaryConverterTests.swift.
public class BinaryConverter {
    
    // MARK: - Parsing binary
    
    /// Parses the binary into `T`
    /// - Tag: BinaryConverter.parseBinaryIntoT
    ///
    /// - Note: Depending on the data type of `refarable`, there is a possibility of referring without holding `refarable` during parsing, so you should keep it on memory.
    ///
    /// - Parameters:
    ///   - stream: will be read
    ///   - byteOrder: default is ByteOrder.hostEndian
    /// - Returns: a value parsed
    /// - Throws: <#throws value description#>
    public class func parse<T: BinaryParsable>(binary stream: ReadableByteStream, byteOrder: ByteOrder = ByteOrder.hostEndian) throws -> T {
        return try T(parsing: stream, byteOrder: byteOrder)
    }
    
    /// See also [class func parse<T: BinaryParsable>(binary stream: ReadableByteStream, byteOrder: ByteOrder) throws -> T](x-source-tag://BinaryConverter.parseBinaryIntoT)
    public class func parse<T: BinaryParsable>(binary referable: ReadableByteStreamReferable, byteOrder: ByteOrder = ByteOrder.hostEndian) throws -> T {
        return try parse(binary: referable.makeReadableByteStream(), byteOrder: byteOrder)
    }
    
    /// Parses the binary into value(s) as `[T]`
    /// - Tag: BinaryConverter.parseBinaryIntoTArray
    ///
    /// - Parameters:
    ///   - stream: will be read
    ///   - count: of values to read
    ///   - byteOrder: default is ByteOrder.hostEndian
    /// - Returns: a value(s) parsed
    /// - Throws: <#throws value description#>
    public class func parse<T: BinaryParsable>(binary stream: ReadableByteStream, count: Int, byteOrder: ByteOrder = ByteOrder.hostEndian) throws -> [T] {
        var value = [] as [T]
        for _ in 0..<count {
            value.append(try T(parsing: stream, byteOrder: byteOrder))
        }
        return value
    }
    
    /// See also [class func parse<T: BinaryParsable>(binary stream: ReadableByteStream, count: Int, byteOrder: ByteOrder) throws -> [T]) throws -> T](x-source-tag://BinaryConverter.parseBinaryIntoTArray)
    public class func parse<T: BinaryParsable>(binary referable: ReadableByteStreamReferable, count: Int, byteOrder: ByteOrder = ByteOrder.hostEndian) throws -> [T] {
        return try parse(binary: referable.makeReadableByteStream(), count: count, byteOrder: byteOrder)
    }
    
    
    public class func parse<Key: Hashable>(binary stream: ReadableByteStream, layout: Array<(Key, BinaryParsable.Type, ByteOrder?)>, defaultByteOrder: ByteOrder = ByteOrder.hostEndian) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            result[key] = try type.init(parsing: stream, byteOrder: byteOrder ?? defaultByteOrder)
        }
        return result
    }
    
    public class func parse<Key: Hashable>(binary referable: ReadableByteStreamReferable, layout: Array<(Key, BinaryParsable.Type, ByteOrder?)>, defaultByteOrder: ByteOrder = ByteOrder.hostEndian) throws -> Dictionary<Key, Any> {
        return try parse(binary: referable.makeReadableByteStream(), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    
    public class func parse<Key: Hashable>(binary stream: ReadableByteStream, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder = ByteOrder.hostEndian) throws -> Dictionary<Key, Any> {
        var result: [Key : Any] = [:]
        for (key, type, byteOrder) in layout {
            switch type {
            case .type(let type):
                result[key] = try type.init(parsing: stream, byteOrder: byteOrder ?? defaultByteOrder)
                break
            case .fixedCountArray(let type, let count):
                var array = [] as [Any]
                for _ in 0..<count {
                    array.append(try type.init(parsing: stream, byteOrder: byteOrder ?? defaultByteOrder))
                }
                result[key] = array
                break
            }
        }
        return result
    }
    
    public class func parse<Key: Hashable>(binary refarable: ReadableByteStreamReferable, layout: Array<(Key, BinaryType, ByteOrder?)>, defaultByteOrder: ByteOrder = ByteOrder.hostEndian) throws -> Dictionary<Key, Any> {
        return try parse(binary: refarable.makeReadableByteStream(), layout: layout, defaultByteOrder: defaultByteOrder)
    }
    
    // MARK: - Binarizing
    
    public class func binarize(_ value: Binarizable, byteOrder: ByteOrder = ByteOrder.hostEndian) -> [UInt8] {
        return value.binarize(byteOrder: byteOrder)
    }
    
    public class func binarize(_ values: [Binarizable], byteOrder: ByteOrder = ByteOrder.hostEndian) -> [UInt8] {
        var binary: [UInt8] = []
        for value in values {
            binary.append(contentsOf: value.binarize(byteOrder: byteOrder))
        }
        return binary
    }
    
    public class func binarize(_ values: ArraySlice<Binarizable>, byteOrder: ByteOrder = ByteOrder.hostEndian) -> [UInt8] {
        var binary: [UInt8] = []
        for value in values {
            binary.append(contentsOf: value.binarize(byteOrder: byteOrder))
        }
        return binary
    }
    
}
