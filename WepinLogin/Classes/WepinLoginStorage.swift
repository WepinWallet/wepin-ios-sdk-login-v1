//
//  WepinLoginStorage.swift
//  Pods
//
//  Created by iotrust on 3/19/25.
//
import WepinCommon
import WepinCore

func setWepinUser(request: WepinLoginResult, response: LoginResponse) {
    WepinCore.shared.storage.deleteAllStorage()
    WepinCore.shared.storage.setStorage(key: "firebase:wepin", data: StorageDataType.FirebaseWepin(idToken: request.token.idToken, refreshToken: request.token.refreshToken, provider: request.provider.rawValue))
    WepinCore.shared.storage.setStorage(key: "wepin:connectUser", data: StorageDataType.WepinToken(accessToken: response.token.access, refreshToken: response.token.refresh))
    WepinCore.shared.storage.setStorage(key: "user_id", data: response.userInfo.userId)
    WepinCore.shared.storage.setStorage(key: "user_status", data: StorageDataType.UserStatus(loginStatus: response.loginStatus, pinRequired: (response.loginStatus == "registerRequired" ? response.pinRequired : false)))
    
    if (response.loginStatus != "pinRequired" && response.walletId != nil) {
        WepinCore.shared.storage.setStorage(key: "wallet_id", data: response.walletId)
        WepinCore.shared.storage.setStorage(key: "user_info",
                                       data: StorageDataType.UserInfo(
                                        status: "success",
                                        userInfo: StorageDataType.UserInfoDetails(
                                            userId: response.userInfo.userId,
                                            email: response.userInfo.email,
                                            provider: request.provider.rawValue,
                                            use2FA: (response.userInfo.use2FA >= 2)
                                        ),
                                        walletId: response.walletId)
        )
    } else {
        let userInfo = StorageDataType.UserInfo(status: "success",
                                                userInfo: StorageDataType.UserInfoDetails(
                                                    userId: response.userInfo.userId,
                                                    email: response.userInfo.email,
                                                    provider: request.provider.rawValue,
                                                    use2FA: (response.userInfo.use2FA >= 2)
                                                ))
        WepinCore.shared.storage.setStorage(key: "user_info", data: userInfo)
    }
    WepinCore.shared.storage.setStorage(key: "oauth_provider_pending", data: request.provider.rawValue)
}

func setFirebaseUser(loginResult: WepinLoginResult) {
    WepinCore.shared.storage.deleteAllStorage()
    WepinCore.shared.storage.setStorage(key: "firebase:wepin",
                                   data: StorageDataType.FirebaseWepin(
                                    idToken: loginResult.token.idToken,
                                    refreshToken: loginResult.token.refreshToken,
                                    provider: loginResult.provider.rawValue)
    )
}

func getWepinUser() -> WepinUser? {
    if let userInfo = WepinCore.shared.storage.getStorage(key: "user_info", type: StorageDataType.UserInfo.self),
       let wepinToken = WepinCore.shared.storage.getStorage(key: "wepin:connectUser", type: StorageDataType.WepinToken.self),
       let userStatus = WepinCore.shared.storage.getStorage(key: "user_status", type: StorageDataType.UserStatus.self) {
        let walletId = WepinCore.shared.storage.getStorage(key: "wallet_id")
        
        if walletId == nil {
            return WepinUser(
                status: "success",
                userInfo: WepinUser.UserInfo(
                    userId: userInfo.userInfo.userId,
                    email: userInfo.userInfo.email,
                    provider: userInfo.userInfo.provider,
                    use2FA: userInfo.userInfo.use2FA
                ),
                walletId: nil,
                userStatus: WepinUser.WepinUserStatus(
                    loginStatus: userStatus.loginStatus,
                    pinRequired: userStatus.pinRequired
                ),
                token: WepinUser.WepinToken(
                    access: wepinToken.accessToken, refresh: wepinToken.refreshToken
                ))
        }
        return WepinUser(status: "success",
                         userInfo: WepinUser.UserInfo(
                            userId: userInfo.userInfo.userId,
                            email: userInfo.userInfo.email,
                            provider: userInfo.userInfo.provider,
                            use2FA: userInfo.userInfo.use2FA
                         ),
                         walletId: walletId as? String,
                         userStatus: WepinUser.WepinUserStatus(
                            loginStatus: userStatus.loginStatus,
                            pinRequired: userStatus.pinRequired
                         ),
                         token: WepinUser.WepinToken(
                            access: wepinToken.accessToken,
                            refresh: wepinToken.refreshToken
                         )
        )
    }
    return nil
}
