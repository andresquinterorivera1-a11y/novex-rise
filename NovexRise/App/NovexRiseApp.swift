import SwiftUI
import UIKit

@main
struct NovexRiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = NovexStore.shared
    @StateObject private var router = AppRouter.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(router)
                .environment(\.locale, Locale(identifier: "es"))
                .preferredColorScheme(.dark)
                .tint(.white)
                .onOpenURL { url in
                    router.handle(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    store.refreshSession()
                }
        }
    }
}
