import SwiftUI

enum Route: Hashable {
    case copying(scriptureID: String)
    case preview(completedID: String)
}

/// 首頁：經文清單與已完成作品。
struct LibraryView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("經文") {
                    ForEach(ScriptureLibrary.all) { scripture in
                        NavigationLink(value: Route.copying(scriptureID: scripture.id)) {
                            scriptureRow(scripture)
                        }
                        .swipeActions {
                            if store.inProgress[scripture.id] != nil {
                                Button("重新開始", role: .destructive) {
                                    store.resetProgress(scriptureID: scripture.id)
                                }
                            }
                        }
                    }
                }

                if !store.completed.isEmpty {
                    Section("已完成") {
                        ForEach(store.completed) { work in
                            NavigationLink(value: Route.preview(completedID: work.id)) {
                                completedRow(work)
                            }
                        }
                        .onDelete { offsets in
                            offsets.map { store.completed[$0] }.forEach(store.deleteCompleted)
                        }
                    }
                }
            }
            .navigationTitle("抄經")
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
        }
        .tint(Color(uiColor: SutraPageRenderer.titleInk))
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .copying(let id):
            if let scripture = ScriptureLibrary.scripture(id: id) {
                CopyingView(scripture: scripture, initialSession: store.session(for: scripture)) { work in
                    path = [.preview(completedID: work.id)]
                }
            }
        case .preview(let id):
            if let work = store.completedWork(id: id),
               let scripture = ScriptureLibrary.scripture(id: work.session.scriptureID) {
                PreviewView(scripture: scripture, session: work.session)
            } else {
                Text("找不到這份作品")
            }
        }
    }

    private func scriptureRow(_ scripture: Scripture) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(scripture.title).font(ScriptureFont.font(size: 22))
            if let s = store.inProgress[scripture.id] {
                Text("已寫 \(s.nextIndex) / \(scripture.count) 字")
                    .font(.footnote).foregroundStyle(.secondary)
            } else {
                Text("\(scripture.count) 字 · 尚未開始")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func completedRow(_ work: SessionStore.CompletedWork) -> some View {
        let title = ScriptureLibrary.scripture(id: work.session.scriptureID)?.title ?? work.session.scriptureID
        return VStack(alignment: .leading, spacing: 4) {
            Text(title).font(ScriptureFont.font(size: 20))
            if let date = work.session.completedAt {
                Text(date, format: .dateTime.year().month().day().hour().minute())
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
