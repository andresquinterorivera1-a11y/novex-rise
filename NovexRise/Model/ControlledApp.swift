import Foundation

/// Apps que NOVEX RISE puede controlar en la versión gratuita (sin Screen Time API).
/// Cada una se conecta con una automatización de la app Atajos.
enum ControlledApp: String, CaseIterable, Codable, Identifiable, Hashable {
    case instagram, tiktok, youtube, facebook, x, snapchat, whatsapp, reddit, threads, pinterest, twitch, netflix

    var id: String { rawValue }

    var name: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .facebook: return "Facebook"
        case .x: return "X"
        case .snapchat: return "Snapchat"
        case .whatsapp: return "WhatsApp"
        case .reddit: return "Reddit"
        case .threads: return "Threads"
        case .pinterest: return "Pinterest"
        case .twitch: return "Twitch"
        case .netflix: return "Netflix"
        }
    }

    /// Íconos genéricos en blanco y negro (SF Symbols), sin logos de marcas.
    var symbol: String {
        switch self {
        case .instagram: return "camera"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle"
        case .facebook: return "person.2"
        case .x: return "text.bubble"
        case .snapchat: return "camera.viewfinder"
        case .whatsapp: return "message"
        case .reddit: return "bubble.left.and.bubble.right"
        case .threads: return "at"
        case .pinterest: return "pin"
        case .twitch: return "gamecontroller"
        case .netflix: return "film"
        }
    }

    /// Direcciones que se prueban, en orden, para abrir la app cuando el usuario decide entrar.
    var launchURLs: [URL] {
        (schemes + [website]).compactMap(URL.init(string:))
    }

    private var schemes: [String] {
        switch self {
        case .instagram: return ["instagram://app"]
        case .tiktok: return ["tiktok://", "snssdk1233://"]
        case .youtube: return ["youtube://"]
        case .facebook: return ["fb://"]
        case .x: return ["twitter://", "x://"]
        case .snapchat: return ["snapchat://"]
        case .whatsapp: return ["whatsapp://"]
        case .reddit: return ["reddit://"]
        case .threads: return ["barcelona://"]
        case .pinterest: return ["pinterest://"]
        case .twitch: return ["twitch://"]
        case .netflix: return ["nflx://"]
        }
    }

    private var website: String {
        switch self {
        case .instagram: return "https://www.instagram.com"
        case .tiktok: return "https://www.tiktok.com"
        case .youtube: return "https://m.youtube.com"
        case .facebook: return "https://m.facebook.com"
        case .x: return "https://x.com"
        case .snapchat: return "https://www.snapchat.com"
        case .whatsapp: return "https://www.whatsapp.com"
        case .reddit: return "https://www.reddit.com"
        case .threads: return "https://www.threads.net"
        case .pinterest: return "https://www.pinterest.com"
        case .twitch: return "https://www.twitch.tv"
        case .netflix: return "https://www.netflix.com"
        }
    }
}
