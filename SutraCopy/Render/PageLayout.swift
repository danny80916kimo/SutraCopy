import CoreGraphics

/// 1080×1920 直書版面的座標計算。純函式，不畫圖。
enum PageLayout {
    static let canvasSize = CGSize(width: 1080, height: 1920)
    static let margin: CGFloat = 90
    static let cell: CGFloat = 80
    static let charsPerColumn = 20
    static let columnsPerPage = 10
    static let charsPerPage = charsPerColumn * columnsPerPage   // 200

    /// 格線頂端。可用高度 1740，格子 1600，上方留 40，下方留 140 給頁碼。
    static let gridTop: CGFloat = margin + 40                     // 130
    static let gridBottom: CGFloat = gridTop + cell * CGFloat(charsPerColumn) // 1730

    /// 最右一行放經名。
    static let titleColumnFrame = CGRect(x: canvasSize.width - margin - cell, y: gridTop,
                                         width: cell, height: cell * CGFloat(charsPerColumn))
    private static let titleGap: CGFloat = 20
    /// 內文第一行（最右）的右緣。
    static let bodyRightEdge: CGFloat = titleColumnFrame.minX - titleGap  // 890

    static func pageCount(characterCount: Int) -> Int {
        max(1, (characterCount + charsPerPage - 1) / charsPerPage)
    }

    static func cellFrame(forCharacterIndex i: Int) -> (page: Int, rect: CGRect) {
        let page = i / charsPerPage
        let k = i % charsPerPage
        let column = k / charsPerColumn
        let row = k % charsPerColumn
        let x = bodyRightEdge - CGFloat(column + 1) * cell
        let y = gridTop + CGFloat(row) * cell
        return (page, CGRect(x: x, y: y, width: cell, height: cell))
    }

    /// 這一頁用到幾行內文。
    static func columnCount(onPage page: Int, characterCount: Int) -> Int {
        let start = page * charsPerPage
        let remaining = max(0, characterCount - start)
        return min(columnsPerPage, (remaining + charsPerColumn - 1) / charsPerColumn)
    }

    /// 這一頁某一行有幾個字（最後一行可能不滿）。
    static func rowCount(onPage page: Int, column: Int, characterCount: Int) -> Int {
        let start = page * charsPerPage + column * charsPerColumn
        return max(0, min(charsPerColumn, characterCount - start))
    }
}
