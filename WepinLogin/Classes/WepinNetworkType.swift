//
//  WepinNetworkType.swift
//  WepinLogin
//
//  Created by iotrust on 6/17/24.
//

import Foundation

struct WepinLoginRequest: Codable {
    let idToken: String
}

// LoginResponse 클래스
struct WepinLoginResponse: Codable {
    let loginStatus: String
    let pinRequired: Bool?
    let walletId: String?
    let token: WepinToken
    let userInfo: WepinAppUser
}

// Token 클래스
public struct WepinToken: Codable {
    public let refresh: String
    public let access: String
}

// AppUser 클래스
struct WepinAppUser: Codable {
    let userId: String
    let email: String
    let name: String
    let locale: String
    let currency: String
    let lastAccessDevice: String
    let lastSessionIP: String
    let userJoinStage: Int
    let profileImage: String
    let userState: Int
    let use2FA: Int

    func getUserJoinStageEnum() -> WepinUserJoinStage? {
        return WepinUserJoinStage(rawValue: userJoinStage)
    }

    func getUserStateEnum() -> WepinUserState? {
        return WepinUserState(rawValue: userState)
    }
}

// UserJoinStage 열거형
enum WepinUserJoinStage: Int, Codable {
    case emailRequire = 1
    case pinRequire = 2
    case complete = 3

    static func fromStage(_ stage: Int) -> WepinUserJoinStage? {
        return WepinUserJoinStage(rawValue: stage)
    }
}

// UserState 열거형
enum WepinUserState: Int, Codable {
    case active = 1
    case deleted = 2

    static func fromState(_ state: Int) -> WepinUserState? {
        return WepinUserState(rawValue: state)
    }
}

struct WepinGetAccessTokenResponse : Codable{
    let token: String
}

// OAuthTokenRequest 구조체
struct WepinOAuthTokenRequest: Codable {
    let code: String
    let clientId: String
    let redirectUri: String
    let state: String?
    let codeVerifier: String?
    
    init(code: String, clientId: String, redirectUri: String, state: String?=nil, codeVerifier: String?=nil) {
        self.code = code
        self.state = state
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.codeVerifier = codeVerifier
    }
}

// OAuthTokenResponse 구조체
struct WepinOAuthTokenResponse: Codable {
    let id_token: String?
    let access_token: String
    let token_type: String
    let expires_in: ExpiresIn?
    let refresh_token: String?
    let scope: String?
    
    enum ExpiresIn: Codable {
            case int(Int)
            case string(String)
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let value = try? container.decode(Int.self) {
                    self = .int(value)
                } else if let value = try? container.decode(String.self) {
                    self = .string(value)
                } else {
                    throw DecodingError.typeMismatch(ExpiresIn.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or String for expires_in"))
                }
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .int(let value):
                    try container.encode(value)
                case .string(let value):
                    try container.encode(value)
                }
            }
        }
//    // CodingKeys 열거형을 정의하여 Swift의 camelCase와 JSON의 snake_case를 매핑합니다.
//    private enum CodingKeys: String, CodingKey {
//        case id_token = "id_token"
//        case access_token = "access_token"
//        case token_type = "token_type"
//        case expires_in = "expires_in"
//        case refresh_token = "refresh_token"
//        case scope
//    }
}

// VerifyRequest 구조체
struct WepinVerifyRequest: Codable {
    let type: String
    let email: String
    let localeId: Int?
}

// VerifyResponse 구조체
struct WepinVerifyResponse: Codable {
    let result: Bool
    let oobReset: String?
    let oobVerify: String?
}

// PasswordStateResponse 구조체
struct WepinPasswordStateResponse: Codable {
    var isPasswordResetRequired: Bool
}

// PasswordStateRequest 구조체
struct WepinPasswordStateRequest: Codable {
    var isPasswordResetRequired: Bool
}

// CheckEmailExistResponse 구조체
struct WepinCheckEmailExistResponse: Codable {
    let isEmailExist: Bool
    let isEmailverified: Bool
    let providerIds: [String]
}

// LoginOauthAccessTokenRequest 구조체
public struct WepinLoginOauthAccessTokenRequest: Codable {
    let provider: String
    let accessToken: String
    let sign: String
    public init(provider: String, accessToken: String, sign: String) {
        self.provider = provider
        self.accessToken = accessToken
        self.sign = sign
    }
}

// LoginOauthIdTokenRequest 구조체
public struct WepinLoginOauthIdTokenRequest: Codable {
    var idToken: String
    var sign: String
    public init(idToken: String, sign: String) {
        self.idToken = idToken
        self.sign = sign
    }
}

// LoginOauthIdTokenResponse 구조체
struct WepinLoginOauthIdTokenResponse: Codable {
    let result: Bool
    let token: String?
    let signVerifyResult:Bool?
    let error: String?
}

//////////////////////////////////////////////
///
public enum WepinLoginProviders: String {
    case google = "google"
    case apple = "apple"
    case naver = "naver"
    case discord = "discord"
    case email = "email"
    case externalToken = "external_token"
    
    static func fromValue(_ value: String) -> WepinLoginProviders? {
        return WepinLoginProviders(rawValue: value)
    }
    
    // 주어진 값이 google, apple, naver, discord 중 하나인지 확인하는 함수
    static func isNotCommonProvider(_ value: String) -> Bool {
        guard let provider = fromValue(value) else { return true }
        return provider != .google && provider != .apple && provider != .naver && provider != .discord
    }
    
    static func isNotAccessTokenProvider(_ value: String) -> Bool {
        guard let provider = fromValue(value) else { return true }
        return provider != .naver && provider != .discord
    }
}

public struct WepinLoginOauth2Params {
    let provider: String
    let clientId: String
    public init(provider: String, clientId: String) {
        self.provider = provider
        self.clientId = clientId
    }
}

public struct WepinLoginOauthResult {
    public let provider: String
    public let token: String
    public let type: WepinOauthTokenType
}

public enum WepinOauthTokenType: String {
    case idToken = "id_token"
    case accessToken = "accessToken"
}

public struct WepinFBToken {
    let idToken: String
    let refreshToken: String
}

public struct WepinLoginResult {
    public let provider: WepinLoginProviders
    public let token: WepinFBToken
}

public struct WepinLoginWithEmailParams {
    let email: String
    let password: String
    let locale: String
    
    public init(email:String, password:String){
        self.email = email
        self.password = password
        self.locale = "en"
    }
    
    public init(email:String, password: String, locale: String?) {
        self.email = email
        self.password = password
        self.locale = locale ?? "en"
    }
}
struct WepinNetworEmptyType: Codable {
    
}

public struct WepinUserInfo {
    public let userId: String
    public let email: String
    public let provider: WepinLoginProviders
    public let use2FA: Bool
}

public struct WepinUserStatus {
    public let loginStatus: WepinLoginStatus
    public let pinRequired: Bool?
}

public enum WepinLoginStatus: String {
    case complete = "completed"
    case pinRequired = "pinRequired"
    case registerRequired = "registerRequired"
    
    static func fromValue(_ value: String) -> WepinLoginStatus? {
        return WepinLoginStatus.allCases.first { $0.rawValue == value }
    }
}

extension WepinLoginStatus: CaseIterable {}

public struct WepinUser {
    public let status: String
    public let userInfo: WepinUserInfo?
    public let walletId: String?
    public let userStatus: WepinUserStatus?
    public let token: WepinToken?
}
