import Foundation

/// 一次抄寫的進度：每個字的筆跡與寫到第幾字。
struct CopySession: Codable {
    let scriptureID: String
    /// 字的索引 → PKDrawing.dataRepresentation()
    var drawings: [Int: Data]
    /// 下一個要寫的字
    var nextIndex: Int
    let createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    static func new(for scripture: Scripture) -> CopySession {
        let now = Date()
        return CopySession(scriptureID: scripture.id, drawings: [:], nextIndex: 0,
                           createdAt: now, updatedAt: now, completedAt: nil)
    }
}
