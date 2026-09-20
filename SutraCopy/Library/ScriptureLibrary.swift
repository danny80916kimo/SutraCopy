import Foundation

/// 內建經文庫。目前只有心經。
enum ScriptureLibrary {
    static let all: [Scripture] = [
        load(id: "heart-sutra", title: "般若波羅蜜多心經"),
    ]

    static func scripture(id: String) -> Scripture? {
        all.first { $0.id == id }
    }

    /// 去掉標點、空白、控制字元，只留下字。
    static func strip(_ text: String) -> [Character] {
        text.filter { $0.isLetter }
    }

    private static func load(id: String, title: String) -> Scripture {
        guard let url = Bundle.main.url(forResource: id, withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            assertionFailure("找不到經文檔 \(id).txt")
            return Scripture(id: id, title: title, characters: [])
        }
        return Scripture(id: id, title: title, characters: strip(text))
    }
}
