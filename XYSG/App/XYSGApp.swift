import SwiftData
import SwiftUI
import XYSGCore

@main
struct XYSGApp: App {
    private let bootstrap = AppBootstrap.make()

    var body: some Scene {
        WindowGroup {
            RootTabView(recoveryMessage: bootstrap.recoveryMessage)
        }
        .modelContainer(bootstrap.container)
    }
}

private struct AppBootstrap {
    let container: ModelContainer
    let recoveryMessage: String?

    static func make() -> AppBootstrap {
        let schema = Schema([
            ShowRecord.self,
            Performer.self,
            ProductionBrand.self,
            Venue.self,
        ])

        let fileManager = FileManager.default
        let applicationSupportURL = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.temporaryDirectory
        let dataDirectory = applicationSupportURL.appendingPathComponent("XYSG", isDirectory: true)
        try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
        let storeURL = dataDirectory.appendingPathComponent("default.store")
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        do {
            return AppBootstrap(
                container: try ModelContainer(for: schema, configurations: [configuration]),
                recoveryMessage: nil
            )
        } catch {
            let nsError = error as NSError
            print("Initial SwiftData load failed: \(nsError), userInfo: \(nsError.userInfo)")

            let directoryRecovery = try? PersistentStoreRecovery().relocateDirectory(
                at: dataDirectory
            )

            do {
                let refreshedConfiguration = ModelConfiguration(
                    schema: schema,
                    url: dataDirectory.appendingPathComponent("default.store"),
                    cloudKitDatabase: .none
                )
                let recoveryMessage = directoryRecovery.map { recovery in
                    """
                    检测到旧版本本地数据库无法自动迁移，app 已把旧数据库目录移到 \(recovery.recoveryDirectoryURL.lastPathComponent) 并重新创建空数据库。\
                    如果你之前导出过 zip 备份，现在可以去 Settings > 本地备份 里执行“导入 zip 备份”。
                    """
                }
                return AppBootstrap(
                    container: try ModelContainer(for: schema, configurations: [refreshedConfiguration]),
                    recoveryMessage: recoveryMessage
                )
            } catch {
                fatalError("Failed to create model container after recovery attempt: \(error)")
            }
        }
    }
}
