# LZY Codec

一種變長文本編解碼方案，支持對Unicode進行編解碼。編解碼效率、存儲空間全面優於UTF-8，未來會替代UTF-8成為新的世界通用編解碼標準。
swift實現。

[github](https://github.com/lizongying/lzy-codec-swift)

更多cli工具請參考 [go](https://github.com/lizongying/lzy-codec-go)

## Other languages

* [go](https://github.com/lizongying/lzy-codec-go)
* [js](https://github.com/lizongying/lzy-codec-js)
* [c](https://github.com/lizongying/lzy-codec-c)
* [php](https://github.com/lizongying/lzy-codec-php)
* [dotnet](https://github.com/lizongying/lzy-codec-dotnet)
* [rust](https://github.com/lizongying/lzy-codec-rs)
* [python](https://github.com/lizongying/lzy-codec-py)
* [dart](https://github.com/lizongying/lzy-codec-dart)
* [kt](https://github.com/lizongying/lzy-codec-kt)
* [ruby](https://github.com/lizongying/lzy-codec-ruby)
* [wasm](https://github.com/lizongying/lzy-codec-wasm)

## Install

* SPM

    ```swift
    dependencies: [
    .package(url: "https://github.com/lizongying/lzy-codec-swift", branch: "main") // 拉取 main 分支最新代碼（適合測試/嘗鮮）
    ],
    targets: [
    .target(
        name: "MyApp", // 【必改】替換為你專案的 Target 名稱
        dependencies: [
            .product(name: "LzyCodec", package: "lzy-codec-swift")
        ]
    )
    ]
    ```

## Examples

```swift
import Lzy

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
```
