import Foundation

/// 一部經文：經名與去掉標點後的每一個字。
struct Scripture: Identifiable, Hashable {
    let id: String
    let title: String
    let characters: [Character]

    var count: Int { characters.count }
}
