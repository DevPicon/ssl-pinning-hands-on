import Foundation

protocol BackendClient {
    var clientName: String { get }

    func callHealth() async throws -> String
}
