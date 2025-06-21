import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 40) {
            Text("Welcome to Trajectory")
                .font(.largeTitle)
                .bold()

            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        Task {
                            do {
                                try await sessionManager.signInWithApple()
                            } catch {
                                print("Sign in failed: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 50)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
