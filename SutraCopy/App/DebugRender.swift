#if DEBUG
import UIKit
import PencilKit

/// 啟動參數 `-renderDemo`：用假筆跡渲染心經第一頁到 Documents/demo-page-1.png，供開發時檢查排版。
enum DebugRender {
    static func runIfRequested() {
        guard CommandLine.arguments.contains("-renderDemo"),
              let scripture = ScriptureLibrary.all.first else { return }
        var session = CopySession.new(for: scripture)
        for i in 0..<5 { session.drawings[i] = fakeDrawing(seed: i).dataRepresentation() }
        session.nextIndex = 5
        session.completedAt = Date()
        let images = SutraPageRenderer.renderAll(scripture: scripture, session: session)
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for (i, img) in images.enumerated() {
            let url = docs.appendingPathComponent("demo-page-\(i + 1).png")
            try? img.pngData()?.write(to: url)
            print("DEMO_RENDER \(url.path)")
        }
    }

    /// 在 300×300 的畫布裡畫幾筆，模擬手寫。
    private static func fakeDrawing(seed: Int) -> PKDrawing {
        let ink = PKInk(.pen, color: .black)
        func stroke(_ pts: [CGPoint]) -> PKStroke {
            let points = pts.enumerated().map { (i, p) in
                PKStrokePoint(location: p, timeOffset: TimeInterval(i) * 0.05, size: CGSize(width: 10, height: 10),
                              opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
            }
            return PKStroke(ink: ink, path: PKStrokePath(controlPoints: points, creationDate: Date()))
        }
        let o = CGFloat(seed) * 8
        return PKDrawing(strokes: [
            stroke([CGPoint(x: 60 + o, y: 80), CGPoint(x: 240 - o, y: 90)]),
            stroke([CGPoint(x: 150, y: 60), CGPoint(x: 140 + o, y: 250)]),
            stroke([CGPoint(x: 80, y: 200 + o), CGPoint(x: 230, y: 190)]),
        ])
    }
}
#endif
