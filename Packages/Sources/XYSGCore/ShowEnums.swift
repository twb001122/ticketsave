import Foundation

public enum ShowFormatAccentToken: String, Codable, Sendable, Hashable {
    case sun
    case berry
    case mint
    case sky
    case fog
}

public enum ShowFormat: String, Codable, CaseIterable, Sendable, Hashable {
    case standup
    case manzai
    case improv
    case sketch
    case other

    public var displayName: String {
        switch self {
        case .standup:
            "单口"
        case .manzai:
            "漫才"
        case .improv:
            "即兴"
        case .sketch:
            "新喜剧"
        case .other:
            "其他"
        }
    }

    public var accentToken: ShowFormatAccentToken {
        switch self {
        case .standup:
            .sun
        case .manzai:
            .berry
        case .improv:
            .mint
        case .sketch:
            .sky
        case .other:
            .fog
        }
    }
}

public enum ShowRole: String, Codable, CaseIterable, Sendable, Hashable {
    case host
    case performer
    case headliner
    case other

    public var displayName: String {
        switch self {
        case .host:
            "主持"
        case .performer:
            "演员"
        case .headliner:
            "主咖"
        case .other:
            "其他"
        }
    }
}

public enum ShowType: String, Codable, CaseIterable, Sendable, Hashable {
    case openMic
    case commercial
    case showcase
    case special
    case other

    public var displayName: String {
        switch self {
        case .openMic:
            "开放麦"
        case .commercial:
            "商演"
        case .showcase:
            "主打秀"
        case .special:
            "专场"
        case .other:
            "其他"
        }
    }
}

public enum ShowStatus: String, Codable, CaseIterable, Sendable, Hashable {
    case published
    case draft
}
