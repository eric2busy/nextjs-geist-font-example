import SwiftUI
import AuthenticationServices

class SessionManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userPreferences: UserPreferences?
    
    private let supabase = SupabaseService.shared
    
    init() {
        // Check for existing session
        Task {
            await checkSession()
        }
    }
    
    func checkSession() async {
        // TODO: Implement session check with Supabase
        // For now, just set to false
        await MainActor.run {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func signInWithApple() async throws {
        let nonce = generateNonce()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await withCheckedThrowingContinuation { continuation in
            ASAuthorizationController(authorizationRequests: [request])
                .performRequests { controller, continuation in
                    continuation.resume(with: .success(controller))
                }
                .presentationAnchor = UIApplication.shared.windows.first!
        }
        
        guard let credential = result.credentials as? ASAuthorizationAppleIDCredential,
              let idToken = credential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }
        
        let user = try await supabase.signInWithApple(idToken: idTokenString, nonce: nonce)
        let preferences = try await supabase.fetchUserPreferences(userId: user.id)
        
        await MainActor.run {
            self.currentUser = user
            self.userPreferences = preferences
            self.isAuthenticated = true
        }
    }
    
    func signOut() async throws {
        try await supabase.signOut()
        
        await MainActor.run {
            self.currentUser = nil
            self.userPreferences = nil
            self.isAuthenticated = false
        }
    }
    
    func updatePreferences(_ preferences: UserPreferences) async throws {
        guard let userId = currentUser?.id else { return }
        try await supabase.updateUserPreferences(preferences, userId: userId)
        
        await MainActor.run {
            self.userPreferences = preferences
        }
    }
}

// MARK: - Helper Types

struct User: Codable {
    let id: String
    let email: String?
    let name: String?
}

enum AuthError: Error {
    case invalidCredential
    case signInFailed
    case sessionExpired
}

// MARK: - Helper Functions

private func generateNonce(length: Int = 32) -> String {
    let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

private func sha256(_ input: String) -> String {
    // TODO: Implement SHA256 hashing
    // For now, return the input as is
    return input
}

extension ASAuthorizationController {
    func performRequests(completion: @escaping (ASAuthorizationController, CheckedContinuation<ASAuthorizationAppleIDCredential, Error>) -> Void) -> ASAuthorizationController {
        var cont: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
        
        let delegate = AuthorizationDelegate { controller, credential in
            if let continuation = cont {
                completion(controller, continuation)
            }
        }
        
        self.delegate = delegate
        self.presentationContextProvider = delegate
        
        return self
    }
}

private class AuthorizationDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let completion: (ASAuthorizationController, ASAuthorizationAppleIDCredential) -> Void
    
    init(completion: @escaping (ASAuthorizationController, ASAuthorizationAppleIDCredential) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        completion(controller, credential)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
}
