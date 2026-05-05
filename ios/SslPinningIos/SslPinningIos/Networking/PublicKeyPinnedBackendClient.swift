import Foundation
import Security
import CryptoKit

final class PublicKeyPinnedBackendClient: NSObject, BackendClient {

    let clientName = "URLSession Public Key Pinning"

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

extension PublicKeyPinnedBackendClient: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
              let serverPublicKey = SecCertificateCopyKey(serverCertificate),
              let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data?
        else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let serverPublicKeyHash = SHA256.hash(data: serverPublicKeyData)
        let serverPublicKeyHashBase64 = Data(serverPublicKeyHash).base64EncodedString()

        guard let localCertUrl = Bundle.main.url(forResource: "server", withExtension: "cer"),
              let localCertData = try? Data(contentsOf: localCertUrl),
              let localCertificate = SecCertificateCreateWithData(nil, localCertData as CFData),
              let localPublicKey = SecCertificateCopyKey(localCertificate),
              let localPublicKeyData = SecKeyCopyExternalRepresentation(localPublicKey, nil) as Data?
        else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let localPublicKeyHash = SHA256.hash(data: localPublicKeyData)
        let localPublicKeyHashBase64 = Data(localPublicKeyHash).base64EncodedString()

        print("Server public key hash: \(serverPublicKeyHashBase64)")
        print("Local public key hash: \(localPublicKeyHashBase64)")

        if serverPublicKeyHashBase64 == localPublicKeyHashBase64 {
            return (.useCredential, URLCredential(trust: serverTrust))
        } else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
}
