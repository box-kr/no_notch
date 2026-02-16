import AppKit

// NSApplication 설정
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Dock 아이콘 숨기기 (LSUIElement 대체)
app.setActivationPolicy(.accessory)

// 실행
app.run()
