import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("概览", systemImage: "heart.text.square")
                }
                .tag(0)
            
            SmartLogView()
                .tabItem {
                    Label("记录", systemImage: "plus.circle")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "list.bullet")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
