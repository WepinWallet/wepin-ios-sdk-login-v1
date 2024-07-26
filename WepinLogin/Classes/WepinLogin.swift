//
//  WepinLogin.swift
//  Wepin Login Library
//
//  Created by iotrust on 2024/06/12.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import AppAuth
import AuthenticationServices

public typealias CompletionHandler = (_ result:Bool?, _ error:WepinLoginError?) -> Void


public enum WepinLoginError:Error {
    case invalidParameters
    case notInitialized
    case invalidAppKey
    case invalidLoginProvider
    case invalidToken
    case invalidLoginSession
    case userCancelled
    case unkonwError(message: String)
    case notConnectedInternet
    case failedLogin
    case alreadyLogout
    case alreadyInitialized
    case invalidEmailDomain
    case failedSendEmail
    case requiredEmailVerified
    case incorrectEmailForm
    case incorrectPasswordForm
    case notInitializedNetwork
    case requiredSignupEmail
    case failedEmailVerified
    case failedPasswordStateSetting
    case failedPasswordSetting
    case existedEmail
}

public class WepinLogin {
    private var initParams: WepinLoginParams
    var initialized: Bool = false
    var domain: String? = nil
    var wepinNetwork: WepinNework? = nil
    var firebaseNetwork: FirebaseNetwork? = nil
    
    let networkMonitor = NetworkMonitor.shared
    
//    static let defaultInstance = WepinLogin()
    
    var safariVC: SFSafariViewController? = nil
    public static var WepinAuthorizationFlow: OIDExternalUserAgentSession?
    ///
    /// public APIs ====================================================================
    ///
    
//    public static func instance() -> WepinLogin {
//        return defaultInstance
//    }
    
    public init(_ params: WepinLoginParams) {
        initParams = params
        StorageManager.shared.initManager(appId: initParams.appId)
        wepinNetwork = WepinNework(appKey: initParams.appKey, sdkVersion: PodVersion, baseUrl: initParams.baseUrl)
    }
    
    public func initialize() async throws -> Bool?{
        if initialized {
            throw WepinLoginError.alreadyInitialized
        }
        do {
            let appInfo = try await wepinNetwork?.getAppInfo()
            let fireconfig = try await wepinNetwork?.getFirebaseConfig()
            firebaseNetwork = FirebaseNetwork(key: fireconfig!)
            StorageManager.shared.deleteAllIfAppIdDataNotExists()
            await checkLoginSession()
            
            initialized = true
            return initialized
        } catch {
            throw error
        }
    }
    
    private func checkLoginSession() async {
        let userId = StorageManager.shared.getStorage(key: "user_id")
        let token = StorageManager.shared.getStorage(key: "wepin:connectUser", type: StorageDataType.WepinToken.self)
        if(token != nil && userId != nil){
            wepinNetwork?.setAuthToken(accessToken: (token?.accessToken)!, refreshToken: (token?.refreshToken)!)
            do{
                let accessToken = try await wepinNetwork?.getAccessToken(userId: userId as! String)
                let wepinToken = StorageDataType.WepinToken(
                    accessToken: accessToken!,
                    refreshToken: (token?.refreshToken)!
                )
                StorageManager.shared.setStorage(key: "wepin:connectUser", data: wepinToken)
                wepinNetwork?.setAuthToken(accessToken: accessToken!, refreshToken: (token?.refreshToken)!)
                return
            }catch{
            }
        }
        wepinNetwork?.clearAuthToken()
        StorageManager.shared.deleteAllStorage()
    }
    
    public func isInitialized() -> Bool{
        return initialized
    }
    
    public func finalize() {
        StorageManager.shared.deleteAllStorage()
        wepinNetwork?.clearAuthHeader()
        initialized = false
    }
    
    private func prevCheck() throws {
        if !initialized {
            throw WepinLoginError.notInitialized
        }
        if !networkMonitor.isConnected {
            throw WepinLoginError.notConnectedInternet
        }
    }
    
    @MainActor
    public func loginWithOauthProvider(params: WepinLoginOauth2Params, viewController: UIViewController) async throws -> WepinLoginOauthResult {
        try prevCheck()
        
        if WepinLoginProviders.isNotCommonProvider(params.provider){
            throw WepinLoginError.invalidLoginProvider
        }
        
        let authorizationEndpoint = AppAuthConst.getAuthorizationEndpoint(provider: params.provider)!
        let tokenEndpoint = AppAuthConst.getTokenEndpoint(provider: params.provider)!
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                    tokenEndpoint: tokenEndpoint)
    
        
        let scheme = "wepin.\(initParams.appId):/oauth2redirect"
        let redirectUrl = "\(initParams.baseUrl)user/oauth/callback?uri=\(customURLEncode(scheme))"
        let scope = params.provider  == "discord" ? ["identify", OIDScopeEmail] : [OIDScopeEmail]
        var additParms = ["prompt": "select_account"]
        if params.provider == "apple" {
            additParms["response_mode"]  = "form_post"
        }
        
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: params.clientId,
            clientSecret: nil,
            scopes: scope,
            redirectURL: URL(string: redirectUrl)!,
            responseType: OIDResponseTypeCode,
            additionalParameters: additParms
        )
        return try await withCheckedThrowingContinuation { continuation in
            let presentationContextProvider = WepinPresentationContextProvider(window: viewController.view.window)
            let authSession = ASWebAuthenticationSession(url: request.externalUserAgentRequestURL(),
                                                         callbackURLScheme:  "wepin.\(initParams.appId)") { callbackURL, error in
                
                if let callbackURL = callbackURL {
                    // Handle the callback URL and process the authentication response
                    let authResponse = OIDAuthorizationResponse(request: request, parameters: OIDURLQueryComponent(url: callbackURL)!.dictionaryValue)
                    let authState = OIDAuthState(authorizationResponse: authResponse)
                    
                    if(params.provider == "discord") {
                        // Exchange authorization code for access token
                        if let authorizationCode = authState.lastAuthorizationResponse.authorizationCode, let codeVerifier = authState.lastAuthorizationResponse.request.codeVerifier {
                            let tokenRequest = OIDTokenRequest(
                                configuration: configuration,
                                grantType: OIDGrantTypeAuthorizationCode,
                                authorizationCode: authorizationCode,
                                redirectURL: request.redirectURL,
                                clientID: params.clientId,
                                clientSecret: nil,
                                scope: request.scope,
                                refreshToken: nil,
                                codeVerifier: codeVerifier,
                                additionalParameters: nil)
                            
                            OIDAuthorizationService.perform(tokenRequest) { tokenResponse, error in
                                if let tokenResponse = tokenResponse {
                                    let token = WepinLoginOauthResult(provider: params.provider, token: tokenResponse.accessToken!, type: WepinOauthTokenType.accessToken)
                                    continuation.resume(returning: token)
                                } else if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(throwing: NSError(domain: "Unknown error", code: -1, userInfo: nil))
                                }
                            }
                        } else {
                            continuation.resume(throwing: WepinLoginError.unkonwError(message: "Missing authorization code or code verifier"))
                        }
                    } else {
                            if let authorizationCode = authState.lastAuthorizationResponse.authorizationCode, let codeVerifier = authState.lastAuthorizationResponse.request.codeVerifier, let state = authState.lastAuthorizationResponse.state{
                                let requestParams = WepinOAuthTokenRequest(code: authorizationCode, clientId: params.clientId, redirectUri: redirectUrl, state: state, codeVerifier: codeVerifier)
                                Task {
                                    do {
                                        let res = try await self.wepinNetwork?.oauthTokenRequest(provider: params.provider, params: requestParams)
                                        if(res?.access_token == nil && res?.id_token == nil){
                                            continuation.resume(throwing: WepinLoginError.invalidToken)
                                            return
                                        }
                                        var resToken: WepinLoginOauthResult
                                        if params.provider == "google" || params.provider == "apple"{
                                            resToken = WepinLoginOauthResult(provider: params.provider, token: res?.id_token ?? "", type: WepinOauthTokenType.idToken)
                                        }else {
                                            resToken = WepinLoginOauthResult(provider: params.provider, token: res?.access_token ?? "", type: WepinOauthTokenType.accessToken)
                                        }
                                        continuation.resume(returning: resToken)
                                    } catch (let wepinError) {
                                        continuation.resume(throwing: wepinError)
                                    }
                                }
                            }else{
                                continuation.resume(throwing: WepinLoginError.invalidToken)
                            }
                        
                        
                    }
                    
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WepinLoginError.unkonwError(message: "Unknown error"))
                }
                // 인증 흐름이 완료된 후 nil로 설정
                WepinLogin.WepinAuthorizationFlow = nil
            }
                
            authSession.presentationContextProvider = presentationContextProvider
            authSession.start()
        }
    }
    
    public func signUpWithEmailAndPassword(params: WepinLoginWithEmailParams) async throws -> WepinLoginResult {
        try prevCheck()
        if !validateEmail(params.email) {
            throw WepinLoginError.incorrectEmailForm
        }
        if !validatePassword(params.password) {
            throw WepinLoginError.incorrectPasswordForm
        }
        do {
            let checkEmailResponse = try await wepinNetwork?.checkEmailExist(email: params.email)
            if (checkEmailResponse?.isEmailExist == true && checkEmailResponse?.isEmailverified == true && ((checkEmailResponse?.providerIds.contains("password")) != nil)) {
                throw WepinLoginError.existedEmail
            } else {
                //_wepinLoginMangager.loginHelper?.verifySignUpFirebase(params)
                let verifyResponse = try await wepinNetwork?.verify(params: WepinVerifyRequest(type: "create", email: params.email, localeId: params.locale == "ko" ? 1 : 2))
                if verifyResponse?.result != nil {
                    if verifyResponse?.oobReset != nil && verifyResponse?.oobVerify != nil {
                        //signup firebase
                        let resetPWres = try await firebaseNetwork?.resetPassword(resetPasswordRequest: WepinFBResetPasswordRequest(oobCode: verifyResponse!.oobReset!, newPassword: params.password ))
                        if resetPWres == nil || resetPWres?.email.lowercased() != params.email.lowercased() {
                            throw WepinLoginError.failedPasswordSetting
                        }
                        let verifyEmailRes = try await firebaseNetwork?.verifyEmail(verifyEmailRequest: WepinFBVerifyEmailRequest(oobCode: verifyResponse!.oobVerify!))
                        if verifyEmailRes == nil || verifyEmailRes?.email.lowercased() != params.email.lowercased() {
                            throw WepinLoginError.failedEmailVerified
                        }
                        return try await loginWithEmailAndResetPasswordState(params: params)
                    }else {
                        throw WepinLoginError.requiredEmailVerified
                    }
                }
                throw WepinLoginError.failedEmailVerified
            }
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    public func loginWithEmailAndPassword(params: WepinLoginWithEmailParams) async throws -> WepinLoginResult {
        try prevCheck()
        if !validateEmail(params.email) {
            throw WepinLoginError.incorrectEmailForm
        }
        if !validatePassword(params.password) {
            throw WepinLoginError.incorrectPasswordForm
        }
        do {
            let checkEmailResponse = try await wepinNetwork?.checkEmailExist(email: params.email)
            if (checkEmailResponse?.isEmailExist == true && checkEmailResponse?.isEmailverified == true && ((checkEmailResponse?.providerIds.contains("password")) != nil)) {
                return try await loginWithEmailAndResetPasswordState(params: params)
            } else {
                throw WepinLoginError.requiredSignupEmail
            }
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    private func loginWithEmailAndResetPasswordState(params: WepinLoginWithEmailParams) async throws -> WepinLoginResult {
        var isChangeRequired = false
        do {
            let res = try await wepinNetwork?.getUserPasswordState(email: params.email)
            isChangeRequired = res?.isPasswordResetRequired ?? false
        } catch {
            switch error {
                case let networkError as NetworkError:
                    switch networkError {
                    case .faiedResponse(let message):
                        if !isFirstEmailUser(errorString: message) {
                            throw error
                        }else {
                            // 처음 가입한 이메일 유저인 경우는 무조건 패스워드 변경해줘야 함
                            isChangeRequired = true
                        }
                    default: throw error
                        
                    }
                default:
                    throw error
                }
        }
        
        do {
            let encryptPW = hashPassword(params.password)
            let fistPW = isChangeRequired ? params.password : encryptPW
            let signInRes = try await firebaseNetwork?.signInWithEmailPassword(signInRequest: WepinFBEmailAndPasswordRequest(email: params.email, password: fistPW))
            if(signInRes?.idToken == nil || signInRes?.refreshToken == nil){
                throw WepinLoginError.failedLogin
            }
            if(isChangeRequired){
                //changepassword
                let loginRes = try await wepinNetwork?.login(idToken: signInRes!.idToken)
                if(loginRes == nil || loginRes?.userInfo.userId == nil){
                    throw WepinLoginError.failedLogin
                }
                wepinNetwork?.setAuthHeader(token: (loginRes?.token.access)!)
                let updatePwRes = try await firebaseNetwork?.updatePassword(idToken: signInRes!.idToken, password: encryptPW)
                if updatePwRes == nil || updatePwRes?.idToken == nil || updatePwRes?.refreshToken == nil {
                    throw WepinLoginError.failedPasswordSetting
                }
                let updataPWStateRes = try await wepinNetwork?.updateUserPasswordState(userId: loginRes!.userInfo.userId, passwordStateRequest: WepinPasswordStateRequest(isPasswordResetRequired: false))
                if updataPWStateRes?.isPasswordResetRequired != false {
                    throw WepinLoginError.failedPasswordStateSetting
                }
                wepinNetwork?.clearAuthHeader()
                
                let wepinToken = StorageDataType.FirebaseWepin(idToken: (updatePwRes?.idToken)!, refreshToken: (updatePwRes?.refreshToken)!, provider: WepinLoginProviders.email.rawValue)
                    
                StorageManager.shared.setStorage(key: "firebase:wepin", data: wepinToken)
                
                return WepinLoginResult(provider: WepinLoginProviders.email, token: WepinFBToken(idToken: updatePwRes!.idToken, refreshToken: updatePwRes!.refreshToken))
            } else {
                return WepinLoginResult(provider: WepinLoginProviders.email, token: WepinFBToken(idToken: signInRes!.idToken, refreshToken: signInRes!.refreshToken))
            }
        }catch let error {
            throw error
        }
    }
    
    public func loginWithIdToken(params: WepinLoginOauthIdTokenRequest) async throws  -> WepinLoginResult{
        try prevCheck()

        do {
            let res = try await wepinNetwork?.loginOAuthIdToken(params: params)
            if res?.token == nil {
                throw WepinLoginError.invalidToken
            }
            let fbRes = try await firebaseNetwork?.signInWithCustomToken(customToken: (res?.token)!)
            if (fbRes == nil) || fbRes?.idToken == nil || ((fbRes?.refreshToken) == nil) {
                throw WepinLoginError.failedLogin
            }
            let fbToken = WepinFBToken(idToken: (fbRes?.idToken)!, refreshToken: (fbRes?.refreshToken)!)
            let wepinToken = StorageDataType.FirebaseWepin(idToken: (fbRes?.idToken)!, refreshToken: (fbRes?.refreshToken)!, provider: WepinLoginProviders.externalToken.rawValue)
                
            StorageManager.shared.setStorage(key: "firebase:wepin", data: wepinToken)
            return WepinLoginResult(provider: WepinLoginProviders.externalToken, token: fbToken)
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    public func loginWithAccessToken(params: WepinLoginOauthAccessTokenRequest) async throws -> WepinLoginResult{
        try prevCheck()
        if WepinLoginProviders.isNotAccessTokenProvider(params.provider){
            throw WepinLoginError.invalidLoginProvider
        }
        do {
            let res = try await wepinNetwork?.loginOAuthAccessToken(params: params)
            if res?.token == nil {
                throw WepinLoginError.invalidToken
            }
            let fbRes = try await firebaseNetwork?.signInWithCustomToken(customToken: (res?.token)!)
            if (fbRes == nil) || fbRes?.idToken == nil || ((fbRes?.refreshToken) == nil) {
                throw WepinLoginError.failedLogin
            }
            let fbToken = WepinFBToken(idToken: (fbRes?.idToken)!, refreshToken: (fbRes?.refreshToken)!)
            let loginResult = WepinLoginResult(provider: WepinLoginProviders.externalToken, token: fbToken)
            let wepinToken = StorageDataType.FirebaseWepin(idToken: (fbRes?.idToken)!, refreshToken: (fbRes?.refreshToken)!, provider: WepinLoginProviders.externalToken.rawValue)
                
            StorageManager.shared.setStorage(key: "firebase:wepin", data: wepinToken)
            return loginResult
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    public func getRefreshFirebaseToken() async throws -> WepinLoginResult {
        try prevCheck()
        do {
            let firebaseToken = StorageManager.shared.getStorage(key: "firebase:wepin", type: StorageDataType.FirebaseWepin.self)
            if (firebaseToken == nil || firebaseToken?.refreshToken == nil){
                throw WepinLoginError.invalidLoginSession
            }
            let refreshToken = firebaseToken?.refreshToken
            let provider = firebaseToken?.provider
            let res = try await firebaseNetwork?.getRefreshIdToken(getRefreshIdTokenRequest: WepinFBGetRefreshIdTokenRequest(refreshToken: refreshToken!))
            let newToken = StorageDataType.FirebaseWepin(idToken: (res?.idToken)!, refreshToken: (res?.refreshToken)!, provider: provider!)
            StorageManager.shared.setStorage(key: "firebase:wepin", data: newToken)
            let fbToken = WepinFBToken(idToken: (res?.idToken)!, refreshToken: (res?.refreshToken)!)
            return WepinLoginResult(provider: WepinLoginProviders.fromValue(provider!)!, token: fbToken)
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    public func loginWepin(params: WepinLoginResult) async throws -> WepinUser {
        try prevCheck()
        
        if ((params.token.idToken.isEmpty) || (params.token.refreshToken.isEmpty)) {
            throw WepinLoginError.invalidParameters
        }
        do {
            let res = try await wepinNetwork?.login(idToken: params.token.idToken)
            if(res == nil || res?.userInfo == nil || res?.token == nil){
                throw WepinLoginError.failedLogin
            }
            StorageManager.shared.setWepinUser(request: params, response: res!)
//            wepinNetwork?.setAuthHeader(token: (res?.token.access)!)
            return StorageManager.shared.getWepinUser()!
        } catch {
            throw error
        }
    }
    
    public func getCurrentWepinUser() async throws -> WepinUser {
        try prevCheck()
        do {
            await checkLoginSession()
            let data =  StorageManager.shared.getWepinUser()
            if data != nil {
                return data!
            }
            throw WepinLoginError.invalidLoginSession
        } catch (let wepinError) {
            throw wepinError
        }
    }
    
    public func logoutWepin() async throws -> Bool {
        try prevCheck()
        let userId = StorageManager.shared.getStorage(key: "user_id")

        if userId == nil {
            throw WepinLoginError.alreadyLogout
        }
        do {
            let res = try await wepinNetwork?.logout(userId: userId as! String)
            if(res == nil || !res!){
                throw WepinLoginError.alreadyLogout
            }
            StorageManager.shared.deleteAllStorage()
//            wepinNetwork?.clearAuthHeader()
            return true
        } catch {
            throw error
        }
    }
    
    public func getSignForLogin(privateKey: String, message: String) -> String?{
        let res = signMessage(message: message, hexPrivateKey: privateKey)
        return res
    }
}
