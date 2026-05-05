import Foundation
import Security

final class CertificatePinnedBackendClient: NSObject, BackendClient {

    let clientName = "URLSession Certificate Pinning"

    private lazy var session: URLSession = {
        URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: nil
        )
    }()

    func callHealth() async throws -> String {
        let url = URL(string: "https://localhost:8443/health")!
        let (data, _) = try await session.data(from: url)

        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension CertificatePinnedBackendClient: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let serverCertData = SecCertificateCopyData(serverCertificate) as Data

        guard let localCertUrl = Bundle.main.url(forResource: "server", withExtension: "cer"),
              let localCertData = try? Data(contentsOf: localCertUrl)
        else {
            return (.cancelAuthenticationChallenge, nil)
        }

        if serverCertData == localCertData {
            return (.useCredential, URLCredential(trust: serverTrust))
        } else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
}
