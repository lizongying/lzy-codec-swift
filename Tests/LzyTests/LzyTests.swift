import XCTest
import Foundation
@testable import Lzy // 替换为你的 Framework 名称

class LzyTests: XCTestCase {
    // MARK: - 常量定义（测试用例）
    private let testSingleChar = "A" // 单字节 Unicode（0x41）
    private let testDoubleChar = "中" // 双字节 Unicode（0x4E2D）
    private let testTripleChar = "𝄞" // 三字节 Unicode（0x1D11E）
    private let testMultiStr = "LZY中𝄞123" // 混合字符
    private let invalidUTF8Data = Data([0xFF, 0xFE, 0xFD]) // 无效 UTF-8 字节
    private let invalidLZYData = Data([0x80, 0x81, 0x82]) // 无起始单字节的 LZY 数据
    
    // MARK: - 正向测试：正常编解码往返
    func testEncodeDecodeSingleChar() throws {
        // 测试单字符编解码往返
        let encodedData = Lzy.encodeFromString(testSingleChar)
        let decodedStr = try Lzy.decodeToString(encodedData)
        XCTAssertEqual(decodedStr, testSingleChar, "单字符编解码失败")
    }
    
    func testEncodeDecodeDoubleChar() throws {
        // 测试双字节字符编解码往返
        let encodedData = Lzy.encodeFromString(testDoubleChar)
        let decodedStr = try Lzy.decodeToString(encodedData)
        XCTAssertEqual(decodedStr, testDoubleChar, "双字节字符编解码失败")
    }
    
    func testEncodeDecodeTripleChar() throws {
        // 测试三字节字符编解码往返
        let encodedData = Lzy.encodeFromString(testTripleChar)
        let decodedStr = try Lzy.decodeToString(encodedData)
        XCTAssertEqual(decodedStr, testTripleChar, "三字节字符编解码失败")
    }
    
    func testEncodeDecodeMultiStr() throws {
        // 测试混合字符串编解码往返
        let encodedData = Lzy.encodeFromString(testMultiStr)
        let decodedStr = try Lzy.decodeToString(encodedData)
        XCTAssertEqual(decodedStr, testMultiStr, "混合字符串编解码失败")
    }
    
    func testEncodeFromBytesAndDecodeToBytes() throws {
        // 测试 Data 入参的编解码往返（UTF-8 → LZY → UTF-8）
        guard let originalData = testMultiStr.data(using: .utf8) else {
            XCTFail("原始字符串转 UTF-8 Data 失败")
            return
        }
        let encodedData = try Lzy.encodeFromBytes(originalData)
        let decodedData = try Lzy.decodeToBytes(encodedData)
        XCTAssertEqual(decodedData, originalData, "Data 编解码往返失败")
    }
    
    // MARK: - 边界值测试：Unicode 极值
    func testEncodeDecodeUnicodeBoundary() throws {
        // 测试 Unicode 最小值（0x0000）
        let minUnicodeStr = String(UnicodeScalar(0x0000)!)
        let minEncoded = Lzy.encodeFromString(minUnicodeStr)
        let minDecoded = try Lzy.decodeToString(minEncoded)
        XCTAssertEqual(minDecoded, minUnicodeStr, "Unicode 最小值编解码失败")
        
        // 测试 Unicode 最大值（0x10FFFF）
        guard let maxScalar = UnicodeScalar(0x10FFFF) else {
            XCTFail("Unicode 最大值无效")
            return
        }
        let maxUnicodeStr = String(maxScalar)
        let maxEncoded = Lzy.encodeFromString(maxUnicodeStr)
        let maxDecoded = try Lzy.decodeToString(maxEncoded)
        XCTAssertEqual(maxDecoded, maxUnicodeStr, "Unicode 最大值编解码失败")
    }
    
    // MARK: - 异常场景测试
    func testEncodeFromInvalidUTF8Bytes() {
        // 测试无效 UTF-8 字节编码 → 应抛出错误
        XCTAssertThrowsError(try Lzy.encodeFromBytes(invalidUTF8Data)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "LzyCodecError")
            XCTAssertEqual(nsError.code, -1)
        }
    }
    
    func testDecodeInvalidLZYData() {
        // 测试无有效起始字节的 LZY 数据 → 应抛出错误
        XCTAssertThrowsError(try Lzy.decode(invalidLZYData)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "LzyCodecError")
            XCTAssertEqual(nsError.code, -1)
        }
    }
    
    func testDecodeEmptyData() {
        // 测试空数据解码 → 应抛出错误
        let emptyData = Data()
        XCTAssertThrowsError(try Lzy.decode(emptyData)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "LzyCodecError")
            XCTAssertEqual(nsError.code, -1)
        }
    }
    
    func testDecodeInvalidUnicode() throws {
        // 测试代理区 Unicode（0xD800）→ 应抛出错误
        let surrogateRune: [UInt32] = [0xD800]
        let encodedData = Lzy.encode(surrogateRune)
        XCTAssertThrowsError(try Lzy.decodeToString(encodedData)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "LzyCodecError")
            XCTAssertEqual(nsError.code, -1)
        }
    }
}
