import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showMainPage = false
    @State private var currentNonce: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Satellite map focused on DC area
                Image("satellite_map")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .ignoresSafeArea(.all)
                
                // Dark overlay for better text readability
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    Spacer()
                    
                    // AtlasIQ Logo/Title
                    Text("AtlasIQ")
                        .font(.system(size: 64, weight: .light, design: .default))
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98)) // Bone white
                        .shadow(color: Color.blue.opacity(1.0), radius: 8, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.9), radius: 16, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.7), radius: 24, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.5), radius: 32, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.3), radius: 40, x: 0, y: 0)
                    
                    // Tagline
                    Text("Clarity Out Of Complexity")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98)) // Bone white
                        .shadow(color: Color.blue.opacity(0.9), radius: 6, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.7), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.5), radius: 18, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.3), radius: 24, x: 0, y: 0)
                    
                    Spacer()
                    
                    // Sign in with Apple Button
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    guard let nonce = currentNonce else {
                                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                    }
                                    guard let appleIDToken = appleIDCredential.identityToken else {
                                        print("Unable to fetch identity token")
                                        return
                                    }
                                    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                        return
                                    }
                                    // Initialize a Firebase credential.
                                    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                              idToken: idTokenString,
                                                                              rawNonce: nonce)
                                    // Sign in with Firebase.
                                    Auth.auth().signIn(with: credential) { (authResult, error) in
                                        if let error = error {
                                            print("Error signing in: \(error.localizedDescription)")
                                            return
                                        }
                                        // User is signed in to Firebase with Apple.
                                        showMainPage = true
                                    }
                                default:
                                    break
                                }
                            case .failure(let error):
                                print("Sign in with Apple failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(8)
                    .padding(.horizontal, 100)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            TextField("Enter username", text: $username)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            SecureField("Enter password", text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                        }
                        
                        // Login Button
                        Button(action: {
                            // For now, just navigate to main page
                            // Later we'll add actual authentication logic
                            showMainPage = true
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("Sign In")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                        .background(Color.white.opacity(0.05))
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.4),
                                                    Color.clear,
                                                    Color.black.opacity(0.3)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 100)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showMainPage) {
            MainPageView()
        }
    }
    
    // MARK: - Sign in with Apple helpers
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    LoginView()
}
