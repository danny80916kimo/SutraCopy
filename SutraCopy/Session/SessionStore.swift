import Foundation

/// 抄寫進度的讀寫。進行中的 session 放 Sessions/，完成的搬到 Completed/。
@MainActor
final class SessionStore: ObservableObject {
    struct CompletedWork: Identifiable, Hashable {
        let id: String          // 檔名
        let session: CopySession
        static func == (a: CompletedWork, b: CompletedWork) -> Bool { a.id == b.id }
        func hash(into h: inout Hasher) { h.combine(id) }
    }

    @Published private(set) var inProgress: [String: CopySession] = [:]
    @Published private(set) var completed: [CompletedWork] = []
    @Published var lastError: String?

    private let sessionsDir: URL
    private let completedDir: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SutraCopy", isDirectory: true)
        sessionsDir = base.appendingPathComponent("Sessions", isDirectory: true)
        completedDir = base.appendingPathComponent("Completed", isDirectory: true)
        for dir in [sessionsDir, completedDir] {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        reload()
    }

    // MARK: 讀取

    func reload() {
        inProgress = [:]
        for url in jsonFiles(in: sessionsDir) {
            if let s = read(url) { inProgress[s.scriptureID] = s }
        }
        completed = jsonFiles(in: completedDir)
            .compactMap { url in read(url).map { CompletedWork(id: url.lastPathComponent, session: $0) } }
            .sorted { ($0.session.completedAt ?? .distantPast) > ($1.session.completedAt ?? .distantPast) }
    }

    func session(for scripture: Scripture) -> CopySession {
        inProgress[scripture.id] ?? CopySession.new(for: scripture)
    }

    func completedWork(id: String) -> CompletedWork? {
        completed.first { $0.id == id }
    }

    // MARK: 寫入

    func save(_ session: CopySession) {
        var s = session
        s.updatedAt = Date()
        inProgress[s.scriptureID] = s
        write(s, to: sessionsDir.appendingPathComponent("\(s.scriptureID).json"))
    }

    @discardableResult
    func complete(_ session: CopySession) -> CompletedWork {
        var s = session
        s.completedAt = Date()
        s.updatedAt = s.completedAt!
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmmss"
        let name = "\(s.scriptureID)-\(f.string(from: s.completedAt!)).json"
        write(s, to: completedDir.appendingPathComponent(name))
        try? FileManager.default.removeItem(at: sessionsDir.appendingPathComponent("\(s.scriptureID).json"))
        inProgress[s.scriptureID] = nil
        let work = CompletedWork(id: name, session: s)
        completed.insert(work, at: 0)
        return work
    }

    func resetProgress(scriptureID: String) {
        try? FileManager.default.removeItem(at: sessionsDir.appendingPathComponent("\(scriptureID).json"))
        inProgress[scriptureID] = nil
    }

    func deleteCompleted(_ work: CompletedWork) {
        try? FileManager.default.removeItem(at: completedDir.appendingPathComponent(work.id))
        completed.removeAll { $0.id == work.id }
    }

    // MARK: 檔案

    private func jsonFiles(in dir: URL) -> [URL] {
        ((try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? [])
            .filter { $0.pathExtension == "json" }
    }

    private func read(_ url: URL) -> CopySession? {
        do {
            return try decoder.decode(CopySession.self, from: Data(contentsOf: url))
        } catch {
            // 損毀的檔案改名保留，不覆蓋。
            let corrupt = url.appendingPathExtension("corrupt")
            try? FileManager.default.moveItem(at: url, to: corrupt)
            lastError = "先前進度無法讀取，已重新開始。"
            return nil
        }
    }

    private func write(_ session: CopySession, to url: URL) {
        do {
            try encoder.encode(session).write(to: url, options: .atomic)
        } catch {
            lastError = "進度儲存失敗：\(error.localizedDescription)"
        }
    }
}
