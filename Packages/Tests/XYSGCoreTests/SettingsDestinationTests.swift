import Testing
@testable import XYSGCore

struct SettingsDestinationTests {
    @Test
    func exposesEntityManagementAndLocalBackup() {
        #expect(SettingsDestination.allCases.count == 2)
        #expect(SettingsDestination.allCases == [.entityManagement, .localBackup])
    }

    @Test
    func providesStableTitlesAndSymbols() {
        #expect(SettingsDestination.entityManagement.title == "实体管理")
        #expect(SettingsDestination.entityManagement.systemImage == "person.2.crop.square.stack.fill")
        #expect(SettingsDestination.localBackup.title == "本地备份")
        #expect(SettingsDestination.localBackup.systemImage == "externaldrive.badge.icloud")
    }
}
