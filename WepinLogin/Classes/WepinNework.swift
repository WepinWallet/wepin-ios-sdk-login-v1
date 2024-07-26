//
//  WepinNework.swift
//  WepinLogin
//
//  Created by iotrust on 6/12/24.
//

import Foundation

class WepinNework : NetworkManager {
    private var accessToken: String? = nil
    private var refreshToken: String? = nil
    
    init(appKey:String, sdkVersion:String, baseUrl: String) {
        super.init(baseURL: baseUrl)
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "X-API-KEY": appKey,
            "X-API-DOMAIN" : Bundle.main.bundleIdentifier ?? "",
            "X-SDK-VERSION": sdkVersion,
            "X-SDK-TYPE": "ios-login"
        ]
        setCommonHeader(header: headers)
    }
    
    func setAuthToken(accessToken:String, refreshToken:String){
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        setAuthHeader(token: accessToken)
    }
    
    func clearAuthToken(){
        self.accessToken = nil
        self.refreshToken = nil
        clearAuthHeader()
    }
    
    public func getAppInfo() async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            getRequest(endpoint: "app/info") { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getFirebaseConfig() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            getStringRequest(endpoint: "user/firebase-config") { result in
                switch result {
                case .success(let stringResponse):
                    if let decodedData = Data(base64Encoded: stringResponse) {
                        let decodedString = String(data: decodedData, encoding: .utf8)
//                        do {
                        let data = decodedString?.data(using: .utf8)
                        if data == nil {
                            continuation.resume(throwing: WepinNetworkError.parsingFailed)
                            return
                        }
//                                fatalError("Failed to convert JSON string to Data")
//                                continuation.resume(throwing: WepinNetworkError.parsingFailed)
                            
//                            let json = try? JSONSerialization.jsonObject(with: data, options: [])
                            
                        if let apiKey = (try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any])?["apiKey"] as? String {
                            continuation.resume(returning: apiKey)
                        } else {
                            continuation.resume(throwing: WepinNetworkError.parsingFailed)
                        }
//                        } catch let jsonparsError {
//                            continuation.resume(throwing: jsonparsError)
//                        }
                    }else{
                        continuation.resume(throwing: NetworkError.noData)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func login(idToken:String) async throws -> WepinLoginResponse {
        let params = WepinLoginRequest(idToken: idToken)
        let jsonRequestBody = try? JSONEncoder().encode(params)
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/login", responseType: WepinLoginResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    self.setAuthToken(accessToken: jsonResponse.token.access, refreshToken: jsonResponse.token.refresh)
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func logout(userId: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/\(userId)/logout", responseType: WepinNetworEmptyType.self, parameters: nil, completion: { result in
                switch result {
                case .success(_):
                    self.clearAuthToken()
                    continuation.resume(returning: true)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func getAccessToken(userId:String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            getRequest(endpoint: "user/access-token?userId=\(userId)&refresh_token=\(self.refreshToken!)", responseType: WepinGetAccessTokenResponse.self) { result in
                switch result {
                case .success(let jsonResponse):
                    self.setAuthToken(accessToken: jsonResponse.token, refreshToken: self.refreshToken!)
                    continuation.resume(returning: jsonResponse.token)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func loginOAuthIdToken(params:WepinLoginOauthIdTokenRequest) async throws -> WepinLoginOauthIdTokenResponse {
        let jsonRequestBody = try? JSONEncoder().encode(params)
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/oauth/login/id-token", responseType: WepinLoginOauthIdTokenResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    let result = jsonResponse.result
                    if(result) {
                        continuation.resume(returning: jsonResponse)
                    }else{
                        continuation.resume(throwing: WepinNetworkError.resultFailed)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func loginOAuthAccessToken(params: WepinLoginOauthAccessTokenRequest) async throws -> WepinLoginOauthIdTokenResponse {
        let jsonRequestBody = try? JSONEncoder().encode(params)
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/oauth/login/access-token", responseType: WepinLoginOauthIdTokenResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    let result = jsonResponse.result
                    if(result) {
                        continuation.resume(returning: jsonResponse)
                    }else{
                        continuation.resume(throwing: WepinNetworkError.resultFailed)
                    }
                        
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func checkEmailExist(email: String) async throws -> WepinCheckEmailExistResponse {
        return try await withCheckedThrowingContinuation { continuation in
            getRequest(endpoint: "user/check-user?email=\(email)", responseType: WepinCheckEmailExistResponse.self, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func getUserPasswordState(email: String) async throws -> WepinPasswordStateResponse {
        return try await withCheckedThrowingContinuation { continuation in
            getRequest(endpoint: "user/password-state?email=\(email)", responseType: WepinPasswordStateResponse.self, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func updateUserPasswordState(userId: String, passwordStateRequest: WepinPasswordStateRequest) async throws -> WepinPasswordStateResponse {
        let jsonRequestBody = try? JSONEncoder().encode(passwordStateRequest)
        return try await withCheckedThrowingContinuation { continuation in
            patchRequest(endpoint: "user/\(userId)/password-state", responseType: WepinPasswordStateResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func verify(params: WepinVerifyRequest) async throws -> WepinVerifyResponse {
        let jsonRequestBody = try? JSONEncoder().encode(params)
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/verify", responseType: WepinVerifyResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    public func oauthTokenRequest(provider:String, params: WepinOAuthTokenRequest) async throws -> WepinOAuthTokenResponse {
        let jsonRequestBody = try? JSONEncoder().encode(params)
        return try await withCheckedThrowingContinuation { continuation in
            postRequest(endpoint: "user/oauth/token/\(provider)", responseType: WepinOAuthTokenResponse.self, parameters: jsonRequestBody, completion: { result in
                switch result {
                case .success(let jsonResponse):
                    continuation.resume(returning: jsonResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
}

enum WepinNetworkError: Error {
    case resultFailed
    case parsingFailed
}
