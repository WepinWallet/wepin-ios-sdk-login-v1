//
//  WepinNetworkType.swift
//  WepinLogin
//
//  Created by iotrust on 6/14/24.
//

import Foundation

struct WepinFBSignInResponse: Codable {
    let localId: String
    let email: String
    let displayName: String
    let idToken: String
    let registered: Bool
    let refreshToken: String
    let expiresIn: String
}

struct WepinFBEmailAndPasswordRequest: Codable {
    let email: String
    let password: String
    let returnSecureToken: Bool
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.returnSecureToken = true
    }
}

struct WepinFBSignInWithCustomTokenSuccess : Codable {
    let idToken:String
    let refreshToken:String
}

// UpdatePasswordSuccess 구조체
struct WepinFBUpdatePasswordSuccess: Codable {
    let kind: String?
    let localId: String
    let email: String
    let displayName: String?
    let passwordHash: String
    let providerUserInfo: [WepinFBProviderUserInfo]
    let idToken: String
    let refreshToken: String
    let expiresIn: String
    let emailVerified: Bool?
}

// VerifyEmailResponse 구조체
struct WepinFBVerifyEmailResponse: Codable {
    let localId: String
    let email: String
    let passwordHash: String
    let providerUserInfo: [WepinFBProviderUserInfo]
}

// VerifyEmailRequest 구조체
struct WepinFBVerifyEmailRequest: Codable {
    var oobCode: String
}

// ResetPasswordRequest 클래스
class WepinFBResetPasswordRequest: Codable {
    var oobCode: String
    var newPassword: String
    
    init(oobCode: String, newPassword: String) {
        self.oobCode = oobCode
        self.newPassword = newPassword
    }
}

// ResetPasswordResponse 구조체
struct WepinFBResetPasswordResponse: Codable {
    var email: String
    var requestType: String
}

// GetRefreshIdTokenRequest 구조체
struct WepinFBGetRefreshIdTokenRequest: Codable {
    var refreshToken: String
    var grantType: String = "refresh_token"
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case grantType = "grant_type"
    }
}

// GetRefreshIdTokenSuccess 구조체
struct WepinFBGetRefreshIdTokenSuccess: Codable {
    var expiresIn: String
    var tokenType: String
    var refreshToken: String
    var idToken: String
    var userId: String
    var projectId: String
    
    enum CodingKeys: String, CodingKey {
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case userId = "user_id"
        case projectId = "project_id"
    }
}

// GetCurrentUserRequest 구조체
struct WepinFBGetCurrentUserRequest: Codable {
    var idToken: String
}

// GetCurrentUserSuccess 구조체
struct WepinFBGetCurrentUserResponse: Codable {
    let users: [WepinFBUserInfo]
}

// UserInfo 구조체
struct WepinFBUserInfo: Codable {
    let localId: String
    let email: String
    let emailVerified: Bool
    let displayName: String
    let providerUserInfo: [WepinFBProviderUserInfo]
    let photoUrl: String
    let passwordHash: String
    let passwordUpdatedAt: String?
    let validSince: String
    let disabled: Bool
    let lastLoginAt: String
    let createdAt: String
    let customAuth: Bool
}

// ProviderUserInfo 구조체 (이 구조체는 Kotlin 코드에 정의되어 있지 않으므로, 임의로 정의합니다)
struct WepinFBProviderUserInfo: Codable {
    let providerId: String
    let displayName: String?
    let photoUrl: String?
    let federatedId: String?
    let email: String?
    let rawId: String?
    let screenName: String?
}
