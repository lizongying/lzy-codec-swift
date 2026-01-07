import Lzy // ① 导入你的库（和 Package.swift 里 products.name 一致）

// 测试用例（包含中文、Emoji，验证跨语言兼容性）
let testStr = "Hello 世界！😀"
print("原始字符串：\(testStr)")

// 1. 字符串 → LZY 字节序列
let lzyData = Lzy.encodeFromString(testStr)
print("LZY 编码 Data：\(lzyData)")

// 2. LZY 字节序列 → 字符串
do {
    let decodedStr = try Lzy.decodeToString(lzyData)
    print("解码后字符串：\(decodedStr)")
    print("字符串一致性校验：\(testStr == decodedStr)") // true
} catch {
    print("解码失败：\(error.localizedDescription)")
}

// 3. UTF-8 Data → LZY Data → UTF-8 Data
do {
    let utf8Data = testStr.data(using: .utf8)!
    let lzyData2 = try Lzy.encodeFromBytes(utf8Data)
    let decodedUtf8Data = try Lzy.decodeToBytes(lzyData2)
    print("UTF-8 Data 一致性校验：\(utf8Data == decodedUtf8Data)") // true
} catch {
    print("字节流转换失败：\(error.localizedDescription)")
}
