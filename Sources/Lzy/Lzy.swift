import Foundation

public struct Lzy {
    // 统一常量定义（与其他语言完全一致）
    private static let SURROGATE_MIN: UInt32 = 0xD800
    private static let SURROGATE_MAX: UInt32 = 0xDFFF
    private static let UNICODE_MAX: UInt32 = 0x10FFFF
    private static let ERROR_UNICODE = NSError(domain: "LzyCodecError", code: -1, userInfo: [NSLocalizedDescriptionKey: "invalid unicode"])
    
    private init() {}

    // MARK: - Unicode 有效性校验
    private static func validUnicode(_ r: UInt32) -> Bool {
        return (r >= 0 && r < SURROGATE_MIN) || (r > SURROGATE_MAX && r <= UNICODE_MAX)
    }

    // MARK: - 核心编码函数
    /// Unicode 码点序列 → LZY 字节序列（Data 对应其他语言的字节数组/bytes）
    public static func encode(_ inputRunes: [UInt32]) -> Data {
        var data = Data(capacity: inputRunes.count) // 预分配容量，优化性能
        for r in inputRunes {
            if r < 0x80 {
                // 单字节编码
                data.append(UInt8(r & 0xFF))
            } else if r < 0x4000 {
                // 双字节编码
                let byte1 = UInt8((r >> 7) & 0xFF)
                let byte2 = UInt8((0x80 | (r & 0x7F)) & 0xFF)
                data.append(byte1)
                data.append(byte2)
            } else {
                // 三字节编码
                let byte1 = UInt8((r >> 14) & 0xFF)
                let byte2 = UInt8((0x80 | ((r >> 7) & 0x7F)) & 0xFF)
                let byte3 = UInt8((0x80 | (r & 0x7F)) & 0xFF)
                data.append(byte1)
                data.append(byte2)
                data.append(byte3)
            }
        }
        return data
    }

    /// Swift 原生字符串 → LZY 字节序列
    public static func encodeFromString(_ inputStr: String) -> Data {
        var runes = [UInt32]()
        // 遍历字符串的 Unicode 码点（自动处理代理对，获取完整码点）
        for char in inputStr.unicodeScalars {
            runes.append(char.value)
        }
        return encode(runes)
    }

    /// UTF-8 字节序列（Data）→ LZY 字节序列
    public static func encodeFromBytes(_ inputBytes: Data) throws -> Data {
        // 解码 UTF-8 Data 为 Swift 字符串
        guard let inputStr = String(data: inputBytes, encoding: .utf8) else {
            throw ERROR_UNICODE
        }
        return encodeFromString(inputStr)
    }

    // MARK: - 核心解码函数
    /// LZY 字节序列 → Unicode 码点序列
    public static func decode(_ inputBytes: Data) throws -> [UInt32] {
        guard !inputBytes.isEmpty else {
            throw ERROR_UNICODE
        }
        
        // 寻找第一个最高位为 0 的字节（有效起始索引）
        var startIdx: Int?
        for (i, byte) in inputBytes.enumerated() {
            if (byte & 0x80) == 0 {
                startIdx = i
                break
            }
        }
        guard let validStartIdx = startIdx else {
            throw ERROR_UNICODE
        }
        
        var output = [UInt32]()
        var r: UInt32 = 0
        
        // 从有效起始索引开始遍历
        for i in validStartIdx ..< inputBytes.count {
            let byte = inputBytes[i]
            let b = UInt32(byte) & 0xFF // 转换为无符号值
            
            if (b >> 7) == 0 {
                // 遇到单字节标记，处理上一个累积的码点
                if i > validStartIdx {
                    guard validUnicode(r) else {
                        throw ERROR_UNICODE
                    }
                    output.append(r)
                }
                r = b
            } else {
                // 累积码点计算
                guard r <= (UNICODE_MAX >> 7) else {
                    throw ERROR_UNICODE
                }
                r = (r << 7) | (b & 0x7F)
            }
        }
        
        // 处理最后一个累积的码点
        guard validUnicode(r) else {
            throw ERROR_UNICODE
        }
        output.append(r)
        
        return output
    }

    /// LZY 字节序列 → Swift 原生字符串
    public static func decodeToString(_ inputBytes: Data) throws -> String {
        let runes = try decode(inputBytes)
        // 将 Unicode 码点序列转换为 Swift 字符串
        var string = String()
        for rune in runes {
            guard let scalar = UnicodeScalar(rune) else {
                throw ERROR_UNICODE
            }
            string.append(Character(scalar))
        }
        return string
    }

    /// LZY 字节序列 → UTF-8 字节序列（Data）
    public static func decodeToBytes(_ inputBytes: Data) throws -> Data {
        let outputStr = try decodeToString(inputBytes)
        guard let data = outputStr.data(using: .utf8) else {
            throw ERROR_UNICODE
        }
        return data
    }
}

