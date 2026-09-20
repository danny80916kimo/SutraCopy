# easeSutra 舒經 — Speaker Script

Companion to `easeSutra-pitch.html`. Twelve slides, about seven to eight minutes at a relaxed pace.
Stage directions are in brackets. Advance the slide where marked with ▸.

---

## 1 · Cover

Hi everyone. This is easeSutra. In Chinese, 舒經 — "shu jing" — which loosely means "to ease the sutra," or to find ease through the sutra.

It's an iPhone app that does one very small thing: it lets you copy the Heart Sutra by hand, one character at a time, using nothing but your finger. When you finish the last of its two hundred and sixty characters, your own handwriting becomes a vertical scroll you can save or share.

That's the whole pitch. Let me tell you why it matters, and then I'll show it to you.

▸

## 2 · Origin

Copying sutras is one of the oldest quiet practices there is. For well over a thousand years, people have sat down with paper and brush and copied scripture, stroke by stroke. Not to produce a document. To slow down. To put the mind back where the hand is.

The problem is simple. Paper, brush and a scripture book are rarely within reach when you actually have ten quiet minutes. Your phone always is.

So the question was: can a phone hold that stillness, instead of breaking it?

▸

## 3 · Flow

The answer is three steps, and I want you to notice how little there is.

One: choose a sutra. Right now that's the Heart Sutra, two hundred and sixty characters, built in. If you've already started, you pick up exactly where you stopped.

Two: write one character per cell. A faint model character sits in the cell as a guide. You trace over it with your finger. The moment you write it, it's saved.

Three: it becomes a piece. Your handwriting is laid out as a traditional vertical scroll, right to left, and you can save it to Photos or share it anywhere.

Let me show you what that actually looks like.

▸

## 4 · Demo

[Let the video run. Speak over it lightly; don't compete with it.]

This is a real screen recording from the current build. No cuts, no speed-up. Twenty-eight seconds.

We start on a piece that's already finished, step back to the library, and open the Heart Sutra. This build is in a demo mode that stops after five characters, so you can see the whole loop.

Now the writing. 觀 — guan. 自 — zi. 菩 — pu. 薩 — sa. Each character gets its own cell. Notice the faint grey guide underneath, and the previous and next characters sitting to either side. Back and Clear are right there if a stroke goes wrong.

Tap Done, and the page renders. That's the same handwriting you just watched, laid out as a scroll, with the sutra's title down the right-hand column. Save to Photos. Share.

[When the video loops, move on.]

▸

## 5 · Writing

Three things about the writing experience that I think are the heart of it.

First, the guide. You don't need any calligraphy training. The grey character is only a guide. Every stroke you make is your own, and it stays your own on the final page.

Second, it saves instantly. Three characters on the commute, ten before bed. There's no "are you sure you want to leave" dialog, because there's nothing to lose. You come back and you're exactly where you stopped.

Third, you can step back. A bad stroke doesn't mean starting over. Go back one cell, rewrite that one character, and carry on.

▸

## 6 · Output

Here's the finished page.

It's laid out the way scripture has always been laid out: vertical columns, read right to left, twenty characters per column. The rightmost column carries the title, and then ten columns of text. The Heart Sutra's two hundred and sixty characters fit on exactly two pages.

Every character is centered and scaled. We take the real bounds of your strokes and fit them to eighty percent of the cell, so whether you write large or small, the page comes out even.

And the page is 1080 by 1920. That's a full-screen phone image, and it's also the exact ratio of an Instagram story. That's not a coincidence.

▸

## 7 · Share

Which brings us to sharing. When you finish, you have two buttons.

Save to Photos puts every page into your camera roll. Share opens the system share sheet, so Instagram, LINE, Messages, AirDrop, anything you have installed just works.

There's something meaningful about sharing this in particular. It's not a screenshot. It's twenty minutes of your own attention, made visible.

▸

## 8 · Tech

For the engineers in the room, a quick look under the hood. It's deliberately simple: five units, one job each.

SwiftUI, native iOS 17, iPhone first. Three screens with linear navigation and no settings to fiddle with.

PencilKit handles the handwriting. Strokes are captured and serialized by Apple's own engine, so it feels right with a finger, and it feels right with an Apple Pencil.

Storage is local JSON. Progress and strokes stay on the device. There's no account, and nothing is ever uploaded.

And the layout is a pure function. Strokes in, paged images out. The coordinate math is unit-testable, and adding a new sutra needs zero logic changes.

▸

## 9 · Research

Now, a question we had to answer before going further: can a phone actually read a handwritten prayer sheet?

This is our test page. A Taoist lamp-lighting prayer, about a hundred and twenty characters, written vertically in ballpoint pen. Exactly the kind of thing someone might want to copy.

We ran it through Apple Vision, on device. It reads about nine in ten characters, in two seconds, for free. Good enough to tell what the sheet is about.

But look at the misses. Every single error is a look-alike. It reads 大辛 where the sheet says 大帝, the name of a deity. It reads 笑厄, "laughing misfortune," where the sheet says 災厄, "disaster." The shape is right; the meaning is wrong. To fix these, you have to understand what the text is.

We also tried Apple's on-device language model to repair the draft. It fixed one to three of the eleven errors, and only for words we spelled out in the hint. It's too small for semantic repair.

▸

## 10 · Claude

So here is where we're going: bring your own scripture, and Claude reads it into the library.

Three steps. First, snap the sheet. A sutra page, a temple prayer, a mantra card. Vertical or horizontal, print or handwriting.

Second, Apple Vision produces a draft on the device. Fast and free. It gives Claude the layout and a rough transcript to start from.

Third, we call the Claude API. Claude Opus 5 sees the image and the draft, understands the liturgical context, and returns clean text. If it matches a known sutra in our library, we link it. If not, it's added as a new scripture you can copy.

Look at what that fixes. 大辛 becomes 大帝, because Claude knows it's a deity's name. 星店 becomes 星君, because the same title appears twice on the page. 笑厄 becomes 災厄, because "laughing misfortune" makes no sense. And 劉燈其間 becomes 點燈期間, echoing the title of the sheet. None of those are shape corrections. They're reading with understanding.

One boundary we're keeping: only the photo leaves the device, and only when you choose to import. Copying itself stays fully offline.

▸

## 11 · Next

Where this goes next. The philosophy is: get one sutra right, then take the next step.

More sutras is first. The Great Compassion Mantra, the Diamond Sutra. The data model is already there; it's only the text that's missing.

Second, straight to Instagram Stories. The output is already 9:16. What's left is wiring up the URL scheme.

Third, bring your own scripture. Photograph a sheet, Claude reads it in. And once you're copying, gentle stroke hints. A nudge, never a grade.

▸

## 12 · Closing

That's easeSutra. 舒經.

One character per cell. The mind returns to the present.

Thank you. I'm happy to take questions, or to hand you the phone.

---

## Timing guide

| Slide | Target |
|---|---|
| 1 Cover | 0:30 |
| 2 Origin | 0:40 |
| 3 Flow | 0:40 |
| 4 Demo | 0:45 (one loop of the video) |
| 5 Writing | 0:40 |
| 6 Output | 0:40 |
| 7 Share | 0:25 |
| 8 Tech | 0:45 |
| 9 Research | 0:50 |
| 10 Claude | 0:55 |
| 11 Next | 0:35 |
| 12 Closing | 0:15 |
| **Total** | **≈ 7:45** |

## Likely questions

- **Why the Heart Sutra first?** It's short, universally known, and 260 characters fits on two pages. It's the right size to finish in one sitting or a week of commutes.
- **Does it check whether I wrote the character correctly?** No, and that's on purpose. This is practice, not a test. Recognition may come later as a gentle hint, never a score.
- **Apple Pencil?** It works today through PencilKit. There's no Pencil-specific UI yet.
- **iPad?** It runs, but the layout is designed for iPhone. A dedicated iPad layout is not in this version.
- **Where's my data?** On your device, as JSON. Nothing leaves the phone unless you share it, or choose to import a photo for recognition.
- **Why Claude instead of a bigger OCR model?** The errors aren't visual, they're semantic. Fixing 笑厄 to 災厄 needs a model that knows what a prayer says. Claude Opus 5 reads the image and the context together; an OCR engine only sees shapes.
- **What does recognition cost?** One API call per imported sheet. It happens once, at import; copying never calls the network.

---

## One-minute version (≈ 150 words)

Use slides 1, 4 and 12 only. Start the video as you begin the second paragraph.

This is easeSutra, 舒經. It's an iPhone app for copying the Heart Sutra by hand, one character per cell, with nothing but your finger.

Copying sutras is a thousand-year-old way to slow down. But paper and brush are never around when you have ten quiet minutes. Your phone is.

[video] You open the sutra, trace a faint guide character, and every stroke is saved the moment you write it. Write three characters on the train, ten before bed, pick up where you left off. When the last of the 260 characters is done, your handwriting is laid out as a vertical scroll, right to left, ready to save or share as an Instagram story.

Native SwiftUI, PencilKit, everything stays on the device.

One character per cell. The mind returns to the present. That's easeSutra.

---

## 一分鐘版（中文，約 230 字）

只用第 1、4、12 頁。講到第二段時切到 Demo 頁讓影片開始播。

這是 easeSutra，舒經。一個 iPhone App，讓你用手指，一字一格，親手抄寫般若心經。

抄經是流傳千年的靜心方法。但真正有十分鐘空檔的時候，紙和筆從來不在手邊。手機一直都在。

［影片］打開經文，格子裡有淡淡的範字，跟著寫就好。每寫一字立刻存檔。通勤寫三個字，睡前寫十個字，回來從原處接續。寫完兩百六十字，你的字會自動排成由右到左的直書經文，可以存到相簿，也可以直接分享成 Instagram 限時動態。

原生 SwiftUI、PencilKit，所有資料都留在手機裡。

一字一格，把心放回當下。這就是舒經。
