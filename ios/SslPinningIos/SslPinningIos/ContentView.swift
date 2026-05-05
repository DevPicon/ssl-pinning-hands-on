import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel: MainViewModel

    init() {

        let usePublicKeyPinning = true

        let backendClient: BackendClient

        if usePublicKeyPinning {
            backendClient = PublicKeyPinnedBackendClient()
        } else {
            backendClient = CertificatePinnedBackendClient()
        }

        _viewModel = StateObject(
            wrappedValue: MainViewModel(
                backendClient: backendClient
            )
        )
    }

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
