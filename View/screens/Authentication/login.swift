//
//  login.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-05.
//

import SwiftUI

struct Login: View {
    @Binding var isSignUp: Bool
    @State private var isPasswordVisible = false
//    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View{
        ZStack{
            LinearGradient(
                gradient: Gradient(colors:[
                    Color(red: 0.98, green: 1.0, blue: 0.99),
                    Color(red: 1.0, green: 1.0, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            .ignoresSafeArea()

            VStack{
                HStack{
                    ZStack{
                        Circle()
                            .fill(PetPawColors.primary.opacity(0.08))
                            .frame(width: 200, height: 200)
                            .offset(x: -80, y: -80)
                    }
                    Spacer()
                }

                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false){
                VStack(spacing: 20) {
                    VStack(spacing: 16){
                        ZStack{
                            Circle().fill(
                                LinearGradient(
                                    gradient: Gradient(colors:[
                                        PetPawColors.primary.opacity(0.12),
                                        PetPawColors.primary.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)

                            Circle()
                                .fill(PetPawColors.primaryBg)
                                .frame(width: 75, height: 75)

                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundColor(PetPawColors.primary)
                        }

                        VStack(spacing: 6){
                            Text("Welcome! 🐶")
                                .font(.system(size: 26, weight: .bold, design: .default))
                                .tracking(-0.4)
                                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.16))

                            Text("Your pets have missed you! Sign in to check up on them.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))
                        }
                    }

                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                    VStack(spacing: 14){
                        VStack(alignment: .leading, spacing: 8){
                            HStack(spacing: 8) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)

                                Text("Email Address")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                    .tracking(0.4)
                            }

                            TextField("you@example.com", text: $viewModel.loginEmail)
                                .font(.system(size: 15, weight: .regular))
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                .padding(.vertical, 13)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                                )
                         
                        }

                        VStack(alignment: .leading, spacing: 8){
                            HStack(spacing: 8){
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)

                                Text("Password")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                    .tracking(0.4)
                            }

                            HStack(spacing: 12){
                                if isPasswordVisible{
                                    TextField("Password", text: $viewModel.loginPassword)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.password)
                                } 
                                else{
                                    SecureField("Password", text: $viewModel.loginPassword)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.password)
                                }

                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(PetPawColors.primary.opacity(0.7))
                                        .contentTransition(.symbolEffect(.replace))
                                }
                            }
                            .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                            .padding(.vertical, 13)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        viewModel.loginPassword.isEmpty ? Color(red: 0.92, green: 0.93, blue: 0.95) : PetPawColors.primary,
                                        lineWidth: 2
                                    )
                            )
                        }

                        HStack{
                            Spacer()
                            NavigationLink(destination: Text("Forgot Password")){
                                Text("Forgot password?")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)
                            }
                        }
                        .padding(.top,4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                    Button(action: { viewModel.login() }) {
                        if viewModel.isLoginLoading {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Signing in...").font(.system(size: 15, weight: .semibold))
                            }
                        } 
                        else{
                            HStack(spacing: 8) {
                                Text("Sign In").font(.system(size: 15, weight: .semibold))
                                Image(systemName: "arrow.right").font(.system(size: 13, weight: .semibold))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors:[
                                PetPawColors.primary,
                                Color(red: 0.14, green: 0.42, blue: 0.30)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(13)
                    .shadow(color: PetPawColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    .disabled(viewModel.isLoginLoading || viewModel.loginEmail.isEmpty || viewModel.loginPassword.isEmpty)
                    .opacity((viewModel.isLoginLoading || viewModel.loginEmail.isEmpty || viewModel.loginPassword.isEmpty) ? 0.65 : 1.0)
                    .alert("Error", isPresented: $viewModel.showError){
                        Button("Ok") {viewModel.showError = false}
                    } message: {
                        Text(viewModel.errorMsg)
                    }
                    
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                    Button(action: { isSignUp = true }) {
                     HStack(spacing: 6){
                        Text("Don't have an account?")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))

                            HStack(spacing: 3) {
                                Text("Create one").font(.system(size: 13, weight: .bold))
                                Image(systemName: "arrow.right").font(.system(size: 11, weight: .semibold))
                            }
                        .foregroundColor(PetPawColors.primary)

                        Spacer()
                       
                    }
                    }
                    .frame(maxWidth: .infinity)
                    
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)
            }
        }
    }

}

#Preview {
   @State var isSignUp = false
    return Login(isSignUp: $isSignUp).environmentObject(AuthViewModel())
}
