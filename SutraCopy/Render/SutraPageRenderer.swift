import UIKit
import PencilKit

/// 把手寫筆跡排成直書經文頁面。
enum SutraPageRenderer {
    static let paper = UIColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1)
    static let ink = UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
    static let gridLine = UIColor(red: 0.72, green: 0.62, blue: 0.48, alpha: 0.7)
    static let titleInk = UIColor(red: 0.45, green: 0.18, blue: 0.12, alpha: 1)
    static let footerInk = UIColor(red: 0.45, green: 0.40, blue: 0.35, alpha: 1)

    static func renderAll(scripture: Scripture, session: CopySession) -> [UIImage] {
        let pages = PageLayout.pageCount(characterCount: scripture.count)
        return (0..<pages).map { renderPage($0, scripture: scripture, session: session) }
    }

    static func renderPage(_ page: Int, scripture: Scripture, session: CopySession) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: PageLayout.canvasSize, format: format)
        let total = scripture.count
        let pageCount = PageLayout.pageCount(characterCount: total)

        return renderer.image { ctx in
            let cg = ctx.cgContext
            paper.setFill()
            cg.fill(CGRect(origin: .zero, size: PageLayout.canvasSize))

            drawTitle(scripture.title, in: cg)
            drawGrid(page: page, total: total, in: cg)

            let start = page * PageLayout.charsPerPage
            let end = min(total, start + PageLayout.charsPerPage)
            for i in start..<end {
                let (_, rect) = PageLayout.cellFrame(forCharacterIndex: i)
                if let data = session.drawings[i], let drawing = try? PKDrawing(data: data),
                   !drawing.strokes.isEmpty {
                    drawHandwriting(drawing, in: rect, context: cg)
                } else {
                    drawTemplate(scripture.characters[i], in: rect, context: cg)
                }
            }

            drawFooter(page: page, pageCount: pageCount, date: session.completedAt ?? session.updatedAt, in: cg)
        }
    }

    // MARK: 元件

    private static func drawTitle(_ title: String, in cg: CGContext) {
        let frame = PageLayout.titleColumnFrame
        let font = ScriptureFont.uiFont(size: 56)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: titleInk]
        for (row, ch) in title.enumerated() where row < PageLayout.charsPerColumn {
            let cell = CGRect(x: frame.minX, y: frame.minY + CGFloat(row) * PageLayout.cell,
                              width: PageLayout.cell, height: PageLayout.cell)
            drawCentered(String(ch), attrs: attrs, in: cell)
        }
        // 經名行左側一條細線
        gridLine.setStroke()
        cg.setLineWidth(1.5)
        cg.move(to: CGPoint(x: frame.minX - 10, y: frame.minY))
        cg.addLine(to: CGPoint(x: frame.minX - 10, y: frame.maxY))
        cg.strokePath()
    }

    private static func drawGrid(page: Int, total: Int, in cg: CGContext) {
        gridLine.setStroke()
        cg.setLineWidth(1.5)
        let columns = PageLayout.columnCount(onPage: page, characterCount: total)
        for column in 0..<columns {
            let rows = PageLayout.rowCount(onPage: page, column: column, characterCount: total)
            let x = PageLayout.bodyRightEdge - CGFloat(column + 1) * PageLayout.cell
            for row in 0..<rows {
                let rect = CGRect(x: x, y: PageLayout.gridTop + CGFloat(row) * PageLayout.cell,
                                  width: PageLayout.cell, height: PageLayout.cell)
                cg.stroke(rect)
            }
        }
    }

    private static func drawHandwriting(_ drawing: PKDrawing, in cell: CGRect, context cg: CGContext) {
        let bounds = drawing.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        var image: UIImage!
        // 強制 light 外觀，避免 PencilKit 在深色模式下把黑墨反白。
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            image = drawing.image(from: bounds, scale: 2)
        }
        let maxSide = PageLayout.cell * 0.8
        let scale = min(maxSide / bounds.width, maxSide / bounds.height)
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        let origin = CGPoint(x: cell.midX - size.width / 2, y: cell.midY - size.height / 2)
        image.draw(in: CGRect(origin: origin, size: size))
    }

    private static func drawTemplate(_ ch: Character, in cell: CGRect, context cg: CGContext) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: ScriptureFont.uiFont(size: PageLayout.cell * 0.7),
            .foregroundColor: UIColor.gray.withAlphaComponent(0.25),
        ]
        drawCentered(String(ch), attrs: attrs, in: cell)
    }

    private static func drawFooter(page: Int, pageCount: Int, date: Date, in cg: CGContext) {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateFormat = "yyyy年M月d日"
        let text = pageCount > 1
            ? "第 \(page + 1) / \(pageCount) 頁　\(f.string(from: date))"
            : f.string(from: date)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: ScriptureFont.uiFont(size: 30),
            .foregroundColor: footerInk,
        ]
        let rect = CGRect(x: PageLayout.margin, y: PageLayout.gridBottom + 30,
                          width: PageLayout.canvasSize.width - PageLayout.margin * 2, height: 60)
        drawCentered(text, attrs: attrs, in: rect)
    }

    private static func drawCentered(_ text: String, attrs: [NSAttributedString.Key: Any], in rect: CGRect) {
        let s = NSAttributedString(string: text, attributes: attrs)
        let size = s.size()
        s.draw(at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2))
    }
}
