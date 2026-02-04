import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding(.top, 50)
                
                Text("SugarGuard AI")
                    .font(.largeTitle)
                    .bold()
                
                Text("您的智能健康管家")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 账号密码登录区域
                VStack(spacing: 15) {
                    TextField("邮箱", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        // 模拟登录成功
                        isPresented = false
                    }) {
                        Text(isSignUp ? "注册" : "登录")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(isSignUp ? "已有账号？去登录" : "没有账号？去注册") {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                // 第三方登录
                VStack(spacing: 15) {
                    // Apple 登录
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                print("Apple Login Successful: \(authResults)")
                                isPresented = false
                            case .failure(let error):
                                print("Apple Login Failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black) // 自动适配深色模式
                    .frame(height: 50)
                    .padding(.horizontal)
                    
                    // 微信登录 (模拟 UI)
                    Button(action: {
                        // 需接入微信 SDK
                    }) {
                        HStack {
                            Image(systemName: "message.fill") // 暂用系统图标代替微信
                            Text("微信登录")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("暂不登录，以游客身份使用") {
                    isPresented = false
                }
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    LoginView(isPresented: .constant(true))
}
