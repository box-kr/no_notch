import Foundation

/// 지원 언어
enum AppLanguage: String {
    case ko   // 한국어
    case ja   // 일본어
    case zh   // 중국어
    case en   // 영어 (기본)
}

/// 다국어 문자열 관리
enum L10n {

    // MARK: - 현재 언어 감지

    static let current: AppLanguage = {
        guard let preferred = Locale.preferredLanguages.first else { return .en }
        let code = String(preferred.prefix(2))
        return AppLanguage(rawValue: code) ?? .en
    }()

    // MARK: - 메뉴

    static var enableNotchBar: String {
        switch current {
        case .ko: return "노치 바 활성화"
        case .ja: return "ノッチバーを有効化"
        case .zh: return "启用刘海栏"
        case .en: return "Enable Notch Bar"
        }
    }

    static var disableNotchBar: String {
        switch current {
        case .ko: return "노치 바 비활성화"
        case .ja: return "ノッチバーを無効化"
        case .zh: return "禁用刘海栏"
        case .en: return "Disable Notch Bar"
        }
    }

    static var launchAtLogin: String {
        switch current {
        case .ko: return "로그인 시 자동 시작"
        case .ja: return "ログイン時に自動起動"
        case .zh: return "登录时自动启动"
        case .en: return "Launch at Login"
        }
    }

    static var buyMeACoffee: String {
        return "☕ Buy Me a Coffee"
    }

    static var quit: String {
        switch current {
        case .ko: return "종료"
        case .ja: return "終了"
        case .zh: return "退出"
        case .en: return "Quit"
        }
    }

    // MARK: - 툴팁

    static var tooltipEnabled: String {
        switch current {
        case .ko: return "NoNotch: 활성화 (클릭하여 비활성화)"
        case .ja: return "NoNotch: 有効 (クリックで無効化)"
        case .zh: return "NoNotch: 已启用 (点击禁用)"
        case .en: return "NoNotch: Enabled (click to disable)"
        }
    }

    static var tooltipDisabled: String {
        switch current {
        case .ko: return "NoNotch: 비활성화 (클릭하여 활성화)"
        case .ja: return "NoNotch: 無効 (クリックで有効化)"
        case .zh: return "NoNotch: 已禁用 (点击启用)"
        case .en: return "NoNotch: Disabled (click to enable)"
        }
    }

    // MARK: - 노치/디스플레이 정보

    static var noScreenInfo: String {
        switch current {
        case .ko: return "화면 정보 없음"
        case .ja: return "画面情報なし"
        case .zh: return "无屏幕信息"
        case .en: return "No screen info"
        }
    }

    static func notchDetected(height: Int) -> String {
        switch current {
        case .ko: return "노치 감지됨 (높이: \(height)pt)"
        case .ja: return "ノッチ検出 (高さ: \(height)pt)"
        case .zh: return "已检测到刘海 (高度: \(height)pt)"
        case .en: return "Notch detected (height: \(height)pt)"
        }
    }

    static var noNotchDetected: String {
        switch current {
        case .ko: return "노치가 감지되지 않음"
        case .ja: return "ノッチが検出されません"
        case .zh: return "未检测到刘海"
        case .en: return "No notch detected"
        }
    }

    static var noDisplayInfo: String {
        switch current {
        case .ko: return "디스플레이 정보 없음"
        case .ja: return "ディスプレイ情報なし"
        case .zh: return "无显示器信息"
        case .en: return "No display info"
        }
    }

    static var noCurrentModeInfo: String {
        switch current {
        case .ko: return "현재 모드 정보 없음"
        case .ja: return "現在のモード情報なし"
        case .zh: return "无当前模式信息"
        case .en: return "No current mode info"
        }
    }

    static func currentResolution(width: Int, height: Int) -> String {
        switch current {
        case .ko: return "현재: \(width)×\(height)"
        case .ja: return "現在: \(width)×\(height)"
        case .zh: return "当前: \(width)×\(height)"
        case .en: return "Current: \(width)×\(height)"
        }
    }

    static func changeResolution(width: Int, height: Int) -> String {
        return " → \(width)×\(height)"
    }

    static var noBelowNotchMode: String {
        switch current {
        case .ko: return " (노치 아래 모드 없음)"
        case .ja: return " (ノッチ下モードなし)"
        case .zh: return " (无刘海下方模式)"
        case .en: return " (no below-notch mode)"
        }
    }

    // MARK: - 로그인 매니저

    static var launchAtLoginError: String {
        switch current {
        case .ko: return "로그인 시 자동 시작 설정 오류"
        case .ja: return "ログイン時自動起動の設定エラー"
        case .zh: return "登录自动启动设置错误"
        case .en: return "Launch at login setting error"
        }
    }

    static var launchAtLoginNotSupported: String {
        switch current {
        case .ko: return "macOS 13 미만에서는 로그인 시 자동 시작이 수동 설정됩니다."
        case .ja: return "macOS 13未満ではログイン時自動起動は手動設定が必要です。"
        case .zh: return "macOS 13以下需手动设置登录自动启动。"
        case .en: return "Launch at login requires manual setup on macOS below 13."
        }
    }
}
