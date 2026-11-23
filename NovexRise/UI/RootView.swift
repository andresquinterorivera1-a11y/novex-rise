import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            if store.state.onboardingDone {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .fullScreenCover(item: $router.pause) { request in
            PauseFlowView(request: request)
                .id(request.id)
                .environmentObject(store)
                .environmentObject(router)
                .preferredColorScheme(.dark)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Inicio", systemImage: "arrow.up.right") }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.black, for: .tabBar)

            NavigationStack { StatsView() }
                .tabItem { Label("Estadísticas", systemImage: "chart.bar") }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.black, for: .tabBar)

            NavigationStack { SettingsView() }
                .tabItem { Label("Ajustes", systemImage: "slider.horizontal.3") }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.black, for: .tabBar)
        }
        .tint(.white)
    }
}
