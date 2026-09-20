import UIKit
import SwiftUI
import Photos

enum ImageExporter {
    enum ExportError: LocalizedError {
        case denied
        var errorDescription: String? {
            switch self {
            case .denied: return "沒有相簿存取權限，請到「設定」開啟。"
            }
        }
    }

    static func saveToPhotos(_ images: [UIImage]) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw ExportError.denied }
        try await PHPhotoLibrary.shared().performChanges {
            for image in images {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

/// 系統分享面板。
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
