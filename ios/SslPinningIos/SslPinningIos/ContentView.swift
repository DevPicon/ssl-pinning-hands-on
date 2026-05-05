import SwiftUI
import Combine

struct ContentView: View {

    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Button("Call HTTPS Backend") {
                viewModel.callBackend()
            }
            .disabled(viewModel.isLoading)

            Text(viewModel.message)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
