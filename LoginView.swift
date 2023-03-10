//
//  LoginView.swift
//  ReaderThon
//
//  Created by Lingeswaran Kandasamy on 3/8/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    
    // MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    // MARK: User Defaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        VStack {
            Image("SampleLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .padding(.top, 20)
            
            VStack(spacing: 20) {
                TextField("UserName", text: $emailID)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)
            Button("Reset password?", action:{})
                .font(.callout)
                .fontWeight(.medium)
                .tint(.black)
                .hAlign(.trailing)
        
            
            Button(action: {
                // Perform login action
            }) {
                Text("Login")
                    .padding(10)
                    .font(.headline)
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .padding(.top, 10)
            
            Spacer()
            // MARK: Register Button
            HStack{
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(20)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID , password: password)
                print("User logged in successfully.")
                try await fetchUser()
            } catch {
                print("Login failed with error: \(error.localizedDescription)")
                await setError(error)
            }
        }
        
        func resetPassword(){
            Task{
                do{
                    // With the help of Swift Concurrency Auth can be done with Single Line
                    try await Auth.auth().sendPasswordReset(withEmail: emailID)
                    print("Link Sent")
                }catch{
                    await setError(error)
                }
            }
        }
        
        // MARK: Displaying Errors VIA Alert
        @Sendable func setError(_ error: Error)async{
            // MARK: UI Must be Updated on Main Thread
            await MainActor.run(body: {
                errorMessage = error.localizedDescription
                showError.toggle()
                isLoading = false
            })
        }
    }
    
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        // MARK: UI Updating Must be Run On Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            userUID = userID
            userNameStored = user.userEmail
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}






extension View{
    // Closing All Active Keyboards
    func closeKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: Disabling with Opacity
    func disableWithOpacity(_ condition: Bool)->some View{
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxWidth: .infinity,alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxHeight: .infinity,alignment: alignment)
    }
    
    // MARK: Custom Border View With Padding
    func border(_ width: CGFloat,_ color: Color)->some View{
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    // MARK: Custom Fill View With Padding
    func fillView(_ color: Color)->some View{
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
    
}
