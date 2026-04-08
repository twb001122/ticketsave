public enum SettingsDestination: String, CaseIterable, Identifiable, Sendable {
    case entityManagement
    case localBackup

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .entityManagement:
            "实体管理"
        case .localBackup:
            "本地备份"
        }
    }

    public var subtitle: String {
        switch self {
        case .entityManagement:
            "维护演员、俱乐部厂牌和场地实体"
        case .localBackup:
            "导出 zip 备份，或从本地 zip 恢复档案"
        }
    }

    public var systemImage: String {
        switch self {
        case .entityManagement:
            "person.2.crop.square.stack.fill"
        case .localBackup:
            "externaldrive.badge.icloud"
        }
    }
}
