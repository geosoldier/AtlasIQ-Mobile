import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showMainPage = false
    
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
}

#Preview {
    LoginView()
}
