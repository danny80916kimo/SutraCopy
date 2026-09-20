import UIKit
import SwiftUI

/// 範字與經名用的字型：優先楷體、宋體，沒有就退回系統襯線體。
enum ScriptureFont {
    private static let candidates = ["Kaiti TC", "STKaiti", "Kaiti SC", "Songti TC", "STSong", "Songti SC"]

    static let familyName: String? = {
        let installed = Set(UIFont.familyNames)
        return candidates.first { installed.contains($0) }
    }()

    static func uiFont(size: CGFloat) -> UIFont {
        if let family = familyName, let f = UIFont(name: family, size: size) { return f }
        let desc = UIFont.systemFont(ofSize: size).fontDescriptor.withDesign(.serif)
            ?? UIFont.systemFont(ofSize: size).fontDescriptor
        return UIFont(descriptor: desc, size: size)
    }

    static func font(size: CGFloat) -> Font {
        if let family = familyName { return .custom(family, size: size) }
        return .system(size: size, design: .serif)
    }
}
