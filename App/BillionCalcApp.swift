import SwiftUI
import BillionCalcCore

@main
struct BillionCalcApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .tint(AppTheme.accent)
                .preferredColorScheme(viewModel.colorScheme.swiftUI)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.onboardingCompleted {
                MainView()
            } else {
                OnboardingView()
            }
        }
    }
}
