//
//  signup.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-05.
//

import SwiftUI

struct signup: View {
    @Binding var isSignUp: Bool
    @State private var scaleEffect: CGFloat = 1.0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var isFormValid: Bool {
        !authViewModel.signUpName.isEmpty && !authViewModel.signUpEmail.isEmpty &&
        authViewModel.isPasswordValid(authViewModel.signUpPassword) &&
        authViewModel.passwordsMatch(authViewModel.signUpPassword, confirmPassword: authViewModel.signUpConfirmPassword) &&
        authViewModel.acceptedTerms
    }
    
    
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
                        
                        Circle()
                            .fill(PetPawColors.primaryLight.opacity(0.05))
                            .frame(width: 300, height: 300)
                            .offset(x: -120, y: -100)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0){
                HStack{
                    Button(action:{isSignUp = false}){
                        HStack(spacing: 6) {
                            Image(systemName:"chevron.left").font(.system(size: 16, weight:.semibold))
                            Text("Back")
                        }
                        .foregroundColor(PetPawColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Create Account")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                        .tracking(0.3)
                }
                .padding(Spacing.lg)
                
                .padding(.horizontal, Spacing.lg)
                
                ScrollView(showsIndicators: false){
                    VStack(spacing: 24){
                        VStack(spacing: 16) {
                            ZStack{
                                Circle().fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            PetPawColors.primary.opacity(0.15),
                                            PetPawColors.primary.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: PetPawColors.primary.opacity(0.15), radius: 15, x: 0, y: 8)
                                
                                Circle()
                                    .fill(PetPawColors.primaryBg)
                                    .frame(width: 85, height: 85)
                                
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)
                            }
                            .scaleEffect(scaleEffect)
                            .onAppear{
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
                                    scaleEffect = 1.08
                                }
                            }
                            
                            VStack(spacing: 12){
                                Text("Create your account")
                                    .font(.system(size: 28, weight:.bold, design:.default))
                                    .tracking(-0.5)
                                    .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))
                                
                                Text("Start tracking your pet's health in minutes")
                                    .font(.system(size: 15, weight:.medium))
                                    .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 16){
                            VStack(spacing: 16){
                                HStack(spacing: 10){
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 18, weight:.semibold))
                                        .foregroundColor(PetPawColors.primary)
                                    
                                    Text("Account Details")
                                        .font(.system(size: 14, weight:.bold))
                                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.14))
                                    Spacer()
                                }
                                .padding(.bottom, 4)
                                
                                VStack(alignment: .leading, spacing: 8){
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(PetPawColors.primary.opacity(0.7))
                                        
                                        Text("Full Name")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                            .tracking(0.3)
                                    }
                                    
                                    TextField("Your name", text: $authViewModel.signUpName)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.name)
                                        .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius:12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12).stroke(
                                                authViewModel.signUpName.isEmpty ? Color(red: 0.92, green: 0.93, blue: 0.95) : PetPawColors.primary,
                                                lineWidth: 2
                                            )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8){
                                    HStack(spacing: 8){
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(PetPawColors.primary.opacity(0.7))
                                        
                                        Text("Email Address")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                            .tracking(0.3)
                                    }
                                    
                                    TextField("you@example.com", text: $authViewModel.signUpEmail)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12).stroke(
                                                authViewModel.signUpEmail.isEmpty ? Color(red: 0.92, green: 0.93, blue: 0.95) : PetPawColors.primary,
                                                lineWidth: 2
                                            )
                                        )
                                }
                            }
                            .padding(16)
                            
                            .background(
                                
                                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.9))
                            )
                            .shadow(color: PetPawColors.primary.opacity(0.08), radius: 12, x: 0, y: 4)
                            
                            // Security Card
                            VStack(spacing: 16){
                                // Card Header
                                HStack(spacing: 10){
                                    Image(systemName: "lock.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(red: 0.94, green: 0.28, blue: 0.28))
                                    
                                    Text("Security")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.14))
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 4)
                                
                                // Password Input
                                VStack(alignment: .leading, spacing: 8){
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(authViewModel.isPasswordValid(authViewModel.signUpPassword) && !authViewModel.signUpPassword.isEmpty ? PetPawColors.primary : Color(red: 0.94, green: 0.28, blue: 0.28).opacity(0.7))
                                        
                                        Text("Password")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                            .tracking(0.3)
                                    }
                                    
                                    SecureField("At least 6 characters", text: $authViewModel.signUpPassword)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.password)
                                        .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                    
                                    
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    authViewModel.signUpPassword.isEmpty ? Color(red: 0.92, green: 0.93, blue: 0.95) :
                                                        (authViewModel.isPasswordValid(authViewModel.signUpPassword) ? PetPawColors.primary : Color(red: 0.94, green: 0.28, blue: 0.28)),
                                                    lineWidth: 2
                                                )
                                        )
                                    
                                    if !authViewModel.signUpPassword.isEmpty{
                                        HStack(spacing: 8){
                                            Image(systemName: authViewModel.isPasswordValid(authViewModel.signUpPassword) ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(authViewModel.isPasswordValid(authViewModel.signUpPassword) ? PetPawColors.primary : Color(red: 0.94, green: 0.28, blue: 0.28))
                                            
                                            Text(authViewModel.isPasswordValid(authViewModel.signUpPassword) ? "Password is strong" : "Minimum 6 characters")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(authViewModel.isPasswordValid(authViewModel.signUpPassword) ? PetPawColors.primary : Color(red: 0.94, green: 0.28, blue: 0.28))
                                        }
                                        .padding(.horizontal, 4)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                    
                                }
                                
                                // Confirm Password Input
                                VStack(alignment: .leading, spacing: 8){
                                    HStack(spacing: 8){
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(authViewModel.signUpPassword == authViewModel.signUpConfirmPassword && !authViewModel.signUpConfirmPassword.isEmpty ? PetPawColors.primary : Color(red: 0.90, green: 0.92, blue: 0.94))
                                        
                                        Text("Confirm Password")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                            .tracking(0.3)
                                    }
                                    
                                    SecureField("Re-enter password", text: $authViewModel.signUpConfirmPassword)
                                        .font(.system(size: 15, weight: .regular))
                                        .textContentType(.password)
                                        .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    authViewModel.signUpConfirmPassword.isEmpty ? Color(red: 0.92, green: 0.93, blue: 0.95) :
                                                        (authViewModel.signUpPassword == authViewModel.signUpConfirmPassword ? PetPawColors.primary : Color(red: 0.94, green: 0.28, blue: 0.28)),
                                                    lineWidth: 2
                                                )
                                        )
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .shadow(color: Color(red: 0.94, green: 0.28, blue: 0.28).opacity(0.08), radius: 12, x: 0, y: 4)
                            
                            VStack(spacing: 12){
                                Button(action:{
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        authViewModel.acceptedTerms.toggle()
                                    }
                                }) { HStack(spacing: 12){
                                    Image(systemName: authViewModel.acceptedTerms ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(authViewModel.acceptedTerms ? PetPawColors.primary : Color(red: 0.90, green: 0.92, blue: 0.94))
                                        .scaleEffect(authViewModel.acceptedTerms ? 1.15 : 1.0)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("I agree to the Terms & Conditions")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color(red: 0.10, green: 0.13, blue: 0.16))
                                        
                                        Text("And our Privacy Policy")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))
                                    }
                                    
                                    Spacer()
                                }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(authViewModel.acceptedTerms ? PetPawColors.primary.opacity(0.08) : Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            authViewModel.acceptedTerms ? PetPawColors.primary.opacity(0.3) : Color(red: 0.92, green: 0.93, blue: 0.95),
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.7))
                            )
                            .shadow(color: PetPawColors.primary.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        .padding(.horizontal, 16)
                        
                        Button(action:{
                            authViewModel.signUp()
                        })
                        { if authViewModel.isSignUpLoading{
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.9)
                                Text("Creating your account...")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        } else {
                            HStack(spacing: 12){
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .semibold))
                                    .opacity(isFormValid ? 1.0 : 0)
                                
                                Text("Create Account")
                                    .font(.system(size: 15, weight: .bold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .offset(x: isFormValid ? 4 : 0)
                            }
                        }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
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
                        .cornerRadius(14)
                        .shadow(color: PetPawColors.primary.opacity(0.35),radius: 16,x: 0, y: 8)
                        .disabled(!isFormValid || authViewModel.isSignUpLoading)
                        .opacity(isFormValid && !authViewModel.isSignUpLoading ? 1.0 : 0.6)
                        .scaleEffect(isFormValid ? 1.0 : 0.97)
                        .alert("error", isPresented: $authViewModel.showError) {
                            Button("ok") {authViewModel.showError = false}
                        } message: {
                            Text(authViewModel.errorMsg)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        Button(action:{isSignUp = false}) {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2){
                                    Text("Already have an account?")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))
                                    
                                    Text("Sign In here")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(PetPawColors.primary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(PetPawColors.primary.opacity(0.06))
                                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(PetPawColors.primary.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                    .padding(.bottom, 32)
                }
                
            }
        }
    }
    
}

#Preview{
   @State var isSignUp = true
    return NavigationStack {
        signup(isSignUp: $isSignUp)
    }
}

