# SutraCopy 抄經 iOS App 設計

日期：2026-09-20

## 目標

一個 iPhone app，讓使用者用手指逐字手寫抄錄內建經文。寫完後 app 把每個手寫字排成直書、由右到左的經文版面，輸出 1080×1920 圖片，可存到相簿或透過系統分享面板分享（含 Instagram）。

## 範圍

### 做

- 內建經文清單：般若波羅蜜多心經、大悲咒、往生咒、準提咒等短咒、金剛經。
- 一次一格的手寫抄寫，格內淡印範字（描紅式），手動按「下一字」前進。
- 每寫一字即存本機，可中斷續寫；完成的作品保留可重看、重新輸出。
- 直書版面渲染，長經文自動分頁，每頁 1080×1920。
- 存到相簿、系統分享面板。

### 不做（本版）

- 手寫辨識與對錯判斷。
- Instagram 限時動態 URL scheme 直跳（需 Facebook App ID，留待後續獨立任務）。
- 使用者自訂經文。
- iPad 專屬版面、Apple Pencil 專屬功能（Pencil 可用但不特別處理）。
- 標點符號：經文標點一律去除，每個字一格。
- 自訂筆刷、毛筆效果。

## 技術選擇

- SwiftUI，最低 iOS 17，iPhone 為主要目標。
- 手寫使用 PencilKit：`PKCanvasView` 收筆跡，`PKDrawing` 序列化保存。
- 本機儲存用檔案（JSON），不用 SwiftData / Core Data。
- 專案用 XcodeGen 從 `project.yml` 產生，Xcode 用 `/Applications/Xcode-27.1.0-Beta.app`。
- 專案位置 `~/Developer/SutraCopy`。

## 架構

五個獨立單元，每個只有一個職責：

| 單元 | 職責 | 依賴 |
|---|---|---|
| `ScriptureLibrary` | 內建經文靜態資料：經名、去標點後的字清單 | 無 |
| `SessionStore` | 抄寫進度讀寫：每字筆跡、下一字索引、完成狀態 | PencilKit（僅 `PKDrawing` 序列化） |
| `CopyingView` + `CharacterCanvas` | 一次一格手寫畫面 | PencilKit、SessionStore |
| `SutraPageRenderer` + `PageLayout` | 純函式：筆跡陣列 + 版面參數 → 分頁圖片 | PencilKit（`PKDrawing.image`）、Core Graphics |
| `ImageExporter` | 存相簿、開系統分享面板 | UIKit、Photos |

### 資料模型

```swift
struct Scripture: Identifiable {
    let id: String              // 例："heart-sutra"
    let title: String           // 例："般若波羅蜜多心經"
    let characters: [Character] // 去掉標點後的每個字
}

struct CopySession: Codable {
    let scriptureID: String
    var drawings: [Int: Data]   // 字索引 → PKDrawing.dataRepresentation()
    var nextIndex: Int          // 下一個要寫的字
    var createdAt: Date
    var updatedAt: Date
}
```

`isComplete` 由 `nextIndex >= scripture.characters.count` 推得，不另存欄位。

### 經文資料

每部經文一個純文字檔放在 `Library/Texts/<id>.txt`，原文含標點以便校對。`ScriptureLibrary` 載入時去除所有標點與空白（Unicode 類別 P、Z、控制字元），只留下字。經名與 id 對應表寫在 `ScriptureLibrary.swift`。

### 儲存

- 進行中：`Application Support/Sessions/<scriptureID>.json`。每部經文同時只有一個進行中的 session。
- 已完成：按最後一字的「下一字」時，檔案搬到 `Application Support/Completed/<scriptureID>-<yyyyMMdd-HHmmss>.json`。
- 每按一次「下一字」或「上一字」寫檔一次。心經整份約數百 KB，成本可忽略。

## 畫面與流程

三個畫面，線性導覽。

### 1. 經文清單 `LibraryView`

- 上方列出內建經文：經名、字數、進度（「已寫 87 / 260」或「尚未開始」）。
- 點選：有進行中 session 就從 `nextIndex` 接續，沒有就新建 session 從第 0 字開始。
- 下方「已完成作品」區列出 `Completed/` 裡的檔案，顯示經名與完成日期，點選直接進預覽。

### 2. 抄寫 `CopyingView`

- 主體是一個正方形大格子，寬度約螢幕寬 85%，米白底、細格線。
- 格內以淡灰色印出目前要寫的字，字型優先 `Kaiti TC`，其次 `Songti TC`，實作時比較後擇一。
- 格子上方：經名、進度「第 88 字 / 260」。格子左右兩側淡淡顯示前一字與下一字。
- 格子下方三個按鈕：
  - 清除：清空本格。
  - 上一字：把本格筆跡存回 session，`nextIndex - 1`，載入前一格已存的筆跡讓使用者修改。第 0 字時停用。
  - 下一字：本格筆跡存入 `drawings[nextIndex]`，`nextIndex + 1`，寫檔。本格筆跡為空時停用。
- 寫到最後一字按「下一字」：session 搬到 `Completed/`，自動導向預覽。
- 中途離開不需確認，因為每步都已存檔。

#### `CharacterCanvas`

包裝 `PKCanvasView` 的 `UIViewRepresentable`：

- 工具固定 `PKInkingTool(.pen, color: .black, width: 10，實作時可微調)`，不顯示工具列。
- `drawingPolicy = .anyInput`，關閉縮放與捲動。
- 對外介面：`@Binding var drawing: PKDrawing`，父視圖以此讀寫與清空。

### 3. 預覽與分享 `PreviewView`

- 進入時呼叫 `SutraPageRenderer` 產生所有分頁，橫向 `TabView(.page)` 翻頁。
- 底部兩個按鈕：
  - 分享…：系統分享面板，帶目前這一頁的圖片。
  - 存到相簿：把所有分頁依序存入相簿。
- 多頁經文渲染在背景執行緒逐頁進行，先顯示第一頁，其餘頁完成後補上。

## 版面規則 `PageLayout`

所有座標計算集中在 `PageLayout`，是純函式，可單獨測試。

- 畫布 1080×1920，米白紙色背景，四邊留白 90 px，可用區域 900×1740。
- 格子正方形 80 px，附細格線。
- 每直行 20 字（1600 px 高），直行由右到左排。
- 最右一行放經名，用範字同款字型印出，不是手寫。
- 經名行之後可用寬度約 820 px，放 10 行內文，每頁 200 字。
  - 心經 260 字 → 2 頁；大悲咒約 415 字 → 3 頁；金剛經約 5000 字 → 約 25 頁。
- 每頁左下留白區印小字「第 n / N 頁」與完成日期。
- 手寫字放法：取 `PKDrawing.bounds`（實際筆跡範圍），等比縮放到格子邊長的 80%，置中。

`PageLayout` 對外提供：

```swift
func pageCount(characterCount: Int) -> Int
func cellFrame(forCharacterIndex i: Int) -> (page: Int, rect: CGRect)
```

`SutraPageRenderer` 用 `UIGraphicsImageRenderer` 逐頁畫：背景、格線、經名、每字圖像、頁碼。

## 錯誤處理

- 寫檔失敗：保留記憶體中的 session 繼續寫，畫面頂端顯示一次提示，下一次寫檔再試。
- session 檔損毀讀不出：當作沒有進度，提示「先前進度無法讀取，重新開始」，壞檔改名為 `.corrupt` 保留不覆蓋。
- 存相簿：`Info.plist` 加 `NSPhotoLibraryAddUsageDescription`，只要求新增權限。被拒時提示到「設定」開啟。
- 渲染多頁：背景執行緒逐頁產生，避免主執行緒卡住。

## 測試

XCTest 單元測試，只測純邏輯：

- `ScriptureLibrary`：每部經文載入後無標點、無空白、字數符合預期。
- `SessionStore`：寫入再讀出一致；`nextIndex` 邊界（0 與最後一字）；損毀檔走重新開始路徑並保留 `.corrupt`。
- `PageLayout`：`pageCount(260) == 2`；`cellFrame` 第 0 字落在第 0 頁最右內文行頂端；第 200 字落在第 1 頁；所有 rect 都在畫布內。
- `SutraPageRenderer`：輸出尺寸 1080×1920，頁數與 `PageLayout` 一致。

畫面與手寫互動用模擬器手動驗證完整流程：選經文 → 寫數字 → 離開再回來進度保留 → 上一字修改 → 寫完進預覽 → 存相簿 → 分享面板可開。

## 專案結構

```
SutraCopy/
  project.yml
  docs/superpowers/specs/
  SutraCopy/
    App/          SutraCopyApp.swift
    Library/      Scripture.swift, ScriptureLibrary.swift, Texts/*.txt
    Session/      CopySession.swift, SessionStore.swift
    Copying/      CopyingView.swift, CharacterCanvas.swift
    Render/       PageLayout.swift, SutraPageRenderer.swift
    Share/        ImageExporter.swift
    Views/        LibraryView.swift, PreviewView.swift
    Resources/    Assets.xcassets
  SutraCopyTests/
```

## 後續可能擴充（不在本版）

- Instagram 限時動態直跳：新增 `InstagramSharer`、Facebook App ID、`LSApplicationQueriesSchemes`。
- 自訂經文輸入。
- 手寫辨識提示。
- 標點半格排版。
