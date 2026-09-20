import SwiftUI

/// 排版結果預覽、存相簿、分享。
struct PreviewView: View {
    let scripture: Scripture
    let session: CopySession

    @State private var pages: [UIImage] = []
    @State private var current = 0
    @State private var showShare = false
    @State private var message: String?
    @State private var saving = false

    var body: some View {
        VStack(spacing: 16) {
            if pages.isEmpty {
                Spacer()
                ProgressView("排版中…")
                Spacer()
            } else {
                TabView(selection: $current) {
                    ForEach(pages.indices, id: \.self) { i in
                        Image(uiImage: pages[i])
                            .resizable()
                            .scaledToFit()
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: pages.count > 1 ? .always : .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                if pages.count > 1 {
                    Text("第 \(current + 1) / \(pages.count) 頁")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    Button {
                        Task { await save() }
                    } label: {
                        Label(saving ? "儲存中…" : "存到相簿", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(saving)

                    Button {
                        showShare = true
                    } label: {
                        Label("分享…", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .controlSize(.large)
                .tint(Color(uiColor: SutraPageRenderer.titleInk))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color(uiColor: SutraPageRenderer.paper).opacity(0.5).ignoresSafeArea())
        .navigationTitle(scripture.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await render() }
        .sheet(isPresented: $showShare) {
            if pages.indices.contains(current) {
                ShareSheet(items: [pages[current]])
                    .presentationDetents([.medium, .large])
            }
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("好", role: .cancel) {}
        }
    }

    private func render() async {
        let scripture = scripture
        let session = session
        let images = await Task.detached(priority: .userInitiated) {
            SutraPageRenderer.renderAll(scripture: scripture, session: session)
        }.value
        pages = images
    }

    private func save() async {
        saving = true
        defer { saving = false }
        do {
            try await ImageExporter.saveToPhotos(pages)
            message = pages.count > 1 ? "已將 \(pages.count) 頁存到相簿。" : "已存到相簿。"
        } catch {
            message = error.localizedDescription
        }
    }
}
