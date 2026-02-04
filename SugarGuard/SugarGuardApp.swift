import SwiftUI

@main
struct SugarGuardApp: App {
    @StateObject private var dataManager = DataManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    if !hasCompletedOnboarding {
                        showingOnboarding = true
                    }
                }
                .sheet(isPresented: $showingOnboarding) {
                    OnboardingView(isPresented: $showingOnboarding)
                        .environmentObject(dataManager) // 关键修复：显式传递环境对象给 sheet
                        .onDisappear {
                            hasCompletedOnboarding = true
                        }
                }
        }
    }
}
