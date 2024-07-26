//
//  FirebaseNetwork.swift
//  WepinLogin
//
//  Created by iotrust on 6/12/24.
//

import Foundation

class FirebaseNetwork : NetworkManager {
    private var key: String = ""
    init(key:String) {
        super.init(baseURL: "https://identitytoolkit.googleapis.com/v1/")
        self.key = key
    }
    
    
    public func signInWithCustomToken(customToken:String) async throws -> WepinFBSignInWithCustomTokenSuccess {
        let url = "accounts:signInWithCustomToken?key=\(key)"
        let postParameters: [String : Any] = [
            "token": customToken,
            "returnSecureToken": true
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: postParameters, options: [])
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBSignInWithCustomTokenSuccess.self, parameters: jsonData) { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signInWithEmailPassword(signInRequest: WepinFBEmailAndPasswordRequest) async throws -> WepinFBSignInResponse {
        let url = "accounts:signInWithPassword?key=\(key)"
        let jsonRequestBody = try? JSONEncoder().encode(signInRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBSignInResponse.self, parameters: jsonRequestBody) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getCurrentUser(getCurrentUserRequest: WepinFBGetCurrentUserRequest) async throws -> WepinFBGetCurrentUserResponse {
        let url = "accounts:lookup?key=\(key)"
        let jsonRequestBody = try? JSONEncoder().encode(getCurrentUserRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBGetCurrentUserResponse.self, parameters: jsonRequestBody) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func getRefreshIdToken(getRefreshIdTokenRequest: WepinFBGetRefreshIdTokenRequest) async throws -> WepinFBGetRefreshIdTokenSuccess {
        let url = "token?key=\(key)"
        let jsonRequestBody = try? JSONEncoder().encode(getRefreshIdTokenRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBGetRefreshIdTokenSuccess.self, parameters: jsonRequestBody) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func resetPassword(resetPasswordRequest: WepinFBResetPasswordRequest) async throws -> WepinFBResetPasswordResponse {
        let url = "accounts:resetPassword?key=\(key)"
        let jsonRequestBody = try? JSONEncoder().encode(resetPasswordRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBResetPasswordResponse.self, parameters: jsonRequestBody) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func verifyEmail(verifyEmailRequest: WepinFBVerifyEmailRequest) async throws -> WepinFBVerifyEmailResponse {
        let url = "accounts:update?key=\(key)"
        let jsonRequestBody = try? JSONEncoder().encode(verifyEmailRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBVerifyEmailResponse.self, parameters: jsonRequestBody) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func updatePassword(idToken:String, password:String) async throws -> WepinFBUpdatePasswordSuccess {
        let url = "accounts:update?key=\(key)"
        
        let postParameters: [String : Any] = [
            "idToken": idToken,
            "password": password,
            "returnSecureToken": true
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postParameters, options: [])
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: url, responseType: WepinFBUpdatePasswordSuccess.self, parameters: jsonData) { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
