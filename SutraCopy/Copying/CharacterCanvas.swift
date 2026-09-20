import SwiftUI
import PencilKit

/// 持有一個 PKCanvasView，父視圖透過它讀寫筆跡、清除、觀察是否為空。
final class CanvasController: NSObject, ObservableObject, PKCanvasViewDelegate {
    let canvasView = PKCanvasView()
    @Published private(set) var isEmpty = true

    override init() {
        super.init()
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.isScrollEnabled = false
        canvasView.minimumZoomScale = 1
        canvasView.maximumZoomScale = 1
        canvasView.overrideUserInterfaceStyle = .light
    }

    var drawing: PKDrawing {
        get { canvasView.drawing }
        set {
            canvasView.drawing = newValue
            isEmpty = newValue.strokes.isEmpty
        }
    }

    func clear() { drawing = PKDrawing() }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        isEmpty = canvasView.drawing.strokes.isEmpty
    }
}

struct CharacterCanvas: UIViewRepresentable {
    let controller: CanvasController

    func makeUIView(context: Context) -> PKCanvasView { controller.canvasView }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
