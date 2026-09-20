import SwiftUI
import PencilKit

/// 一次一格的手寫抄寫畫面。
struct CopyingView: View {
    let scripture: Scripture
    let onComplete: (SessionStore.CompletedWork) -> Void

    @EnvironmentObject private var store: SessionStore
    @StateObject private var canvas = CanvasController()
    @State private var session: CopySession

    init(scripture: Scripture, initialSession: CopySession,
         onComplete: @escaping (SessionStore.CompletedWork) -> Void) {
        self.scripture = scripture
        self.onComplete = onComplete
        _session = State(initialValue: initialSession)
    }

    private var index: Int { min(session.nextIndex, scripture.count - 1) }
    private var current: Character { scripture.characters[index] }
    private var previous: Character? { index > 0 ? scripture.characters[index - 1] : nil }
    private var following: Character? { index + 1 < scripture.count ? scripture.characters[index + 1] : nil }
    private var isLast: Bool { index == scripture.count - 1 }

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width * 0.85, 360)
            VStack(spacing: 24) {
                header
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: 12) {
                    sideChar(following)     // 直書由右到左：下一字在左
                    cell(size: cellSize)
                    sideChar(previous)
                }
                Spacer(minLength: 0)
                controls
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(uiColor: SutraPageRenderer.paper).ignoresSafeArea())
        .navigationTitle(scripture.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadDrawing(for: index) }
        .overlay(alignment: .top) {
            if let err = store.lastError {
                Text(err)
                    .font(.footnote)
                    .padding(8)
                    .background(.red.opacity(0.85), in: Capsule())
                    .foregroundStyle(.white)
                    .onTapGesture { store.lastError = nil }
                    .padding(.top, 4)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("第 \(index + 1) 字 / \(scripture.count)")
                .font(.headline)
                .foregroundStyle(Color(uiColor: SutraPageRenderer.titleInk))
            ProgressView(value: Double(index), total: Double(scripture.count))
                .tint(Color(uiColor: SutraPageRenderer.titleInk))
                .frame(maxWidth: 240)
        }
    }

    private func cell(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(uiColor: SutraPageRenderer.paper))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(uiColor: SutraPageRenderer.gridLine), lineWidth: 2)
            // 米字格輔助線
            Path { p in
                p.move(to: CGPoint(x: size / 2, y: 0)); p.addLine(to: CGPoint(x: size / 2, y: size))
                p.move(to: CGPoint(x: 0, y: size / 2)); p.addLine(to: CGPoint(x: size, y: size / 2))
                p.move(to: .zero); p.addLine(to: CGPoint(x: size, y: size))
                p.move(to: CGPoint(x: size, y: 0)); p.addLine(to: CGPoint(x: 0, y: size))
            }
            .stroke(Color(uiColor: SutraPageRenderer.gridLine).opacity(0.35),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            Text(String(current))
                .font(ScriptureFont.font(size: size * 0.78))
                .foregroundStyle(.gray.opacity(0.28))
            CharacterCanvas(controller: canvas)
        }
        .frame(width: size, height: size)
    }

    private func sideChar(_ ch: Character?) -> some View {
        Text(ch.map(String.init) ?? " ")
            .font(ScriptureFont.font(size: 28))
            .foregroundStyle(.gray.opacity(0.45))
            .frame(width: 32)
    }

    private var controls: some View {
        HStack(spacing: 16) {
            Button {
                canvas.clear()
            } label: {
                Label("清除", systemImage: "eraser")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(canvas.isEmpty)

            Button {
                goBack()
            } label: {
                Label("上一字", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(index == 0)

            Button {
                goNext()
            } label: {
                Label(isLast ? "完成" : "下一字", systemImage: isLast ? "checkmark" : "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(canvas.isEmpty)
        }
        .tint(Color(uiColor: SutraPageRenderer.titleInk))
        .controlSize(.large)
    }

    // MARK: 動作

    private func loadDrawing(for i: Int) {
        if let data = session.drawings[i], let d = try? PKDrawing(data: data) {
            canvas.drawing = d
        } else {
            canvas.clear()
        }
    }

    private func storeCurrent() {
        if canvas.isEmpty {
            session.drawings[index] = nil
        } else {
            session.drawings[index] = canvas.drawing.dataRepresentation()
        }
    }

    private func goNext() {
        storeCurrent()
        if isLast {
            session.nextIndex = scripture.count
            let work = store.complete(session)
            onComplete(work)
        } else {
            session.nextIndex = index + 1
            store.save(session)
            loadDrawing(for: session.nextIndex)
        }
    }

    private func goBack() {
        guard index > 0 else { return }
        storeCurrent()
        session.nextIndex = index - 1
        store.save(session)
        loadDrawing(for: session.nextIndex)
    }
}
