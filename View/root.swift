//
//  root.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-05.
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
            AuthenticationFlow()
    }
}

struct AuthenticationFlow: View {
    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            if isSignUp {
                signup(isSignUp: $isSignUp)
            } else {
                Login(isSignUp: $isSignUp)
                    .onAppear {
                        isSignUp = false
                    }
            }
        }
    }
}

#Preview {
    RootView()
}
