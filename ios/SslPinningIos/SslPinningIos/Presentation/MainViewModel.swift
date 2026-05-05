import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {

    @Published var message: String = "Press the button to call the backend"
    @Published var isLoading: Bool = false

    private let backendClient: BackendClient

    init(
        backendClient: BackendClient
    ) {
        self.backendClient = backendClient
    }

    func callBackend() {
        Task {
            isLoading = true
            message = "Loading..."

            do {
                let response = try await backendClient.callHealth()
                message = """
                Client: \(backendClient.clientName)
                Response: \(response)
                """
            } catch {
                message = """
                Client: \(backendClient.clientName)
                Error: \(error.localizedDescription)
                """
            }

            isLoading = false
        }
    }
}
