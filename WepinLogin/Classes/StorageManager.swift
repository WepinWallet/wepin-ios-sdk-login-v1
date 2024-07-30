//
//  StorageManager.swift
//  WepinLogin
//
//  Created by iotrust on 6/13/24.
//

import Foundation
import Security

class StorageManager {
    private var appId: String = ""
    private let servicePrefix: String = "wepin" + (Bundle.main.bundleIdentifier ?? "") //"wepin_encrypted_preferences"
    private let keychainAccessGroup: String? = nil
    
    static let shared = StorageManager()
    
    func initManager(appId: String) {
        self.appId = appId
    }
    
    private func convertToData<T: Codable>(value: T) -> Data? {
        // String 타입인 경우
        if let stringValue = value as? String {
            return stringValue.data(using: .utf8)
        }
        
        // Data 타입인 경우
        if let dataValue = value as? Data {
            return dataValue
        }
        
        // Dictionary 타입인 경우 (JSON으로 변환)
        if let jsonValue = value as? [String: Any] {
            return try? JSONSerialization.data(withJSONObject: jsonValue, options: [])
        }
        
        // Int 타입인 경우 (바이트 배열로 변환)
        if let intValue = value as? Int {
            var intData = intValue
            return Data(bytes: &intData, count: MemoryLayout.size(ofValue: intData))
        }
        
        // Codable 타입인 경우 (JSON으로 변환)
        do {
           return try JSONEncoder().encode(value)
        } catch {
            return nil
        }
        
        // 변환할 수 없는 경우 nil 반환
//        return nil
    }

    func formData(data: Data) -> Any? {
        
        // Data를 JSON으로 변환 시도
        if let jsonValue = try? JSONSerialization.jsonObject(with: data, options: []),
           let dictionaryValue = jsonValue as? [String: Any] {
            return dictionaryValue
        }
        
        // Data를 Int로 변환 시도
        if data.count == MemoryLayout<Int>.size {
            var intValue: Int = 0
            _ = withUnsafeMutableBytes(of: &intValue) { data.copyBytes(to: $0) }
            return intValue
        }
        
        // Data를 String으로 변환 시도
        if let stringValue = String(data: data, encoding: .utf8) {
            return stringValue
        }
        
        // 변환할 수 없는 경우 nil 반환
        return nil
    }
    func setStorage<T: Codable&Any>(key: String, data: T) {
        
        
        let keychainData = convertToData(value: data) //.encodeToJSON(data)//.encodeToJSON(data)
//        if data is Int {
//            keychainData = data
//        }else {
//            guard let chainData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
//               print("Error encoding data")
//               return
//           }
//            keychainData = chainData
//        }
//        guard let keychainData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
//           print("Error encoding data")
//           return
//       }


        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicePrefix + appId,
            kSecAttrAccount as String: key,
            kSecValueData as String: keychainData!
        ]

        SecItemDelete(query as CFDictionary) // 기존 항목 삭제

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
//            print("Error saving data to keychain: \(status)")
        }
    }

    func getStorage<T: Decodable>(key: String, type: T.Type) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicePrefix + appId,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
//            print("Error fetching data from keychain: \(status)")
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }
    func getStorage(key: String) -> Any? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicePrefix + appId,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
//            print("Error retrieving data from keychain: \(status)")
            return nil
        }

        return formData(data: data)
//        return try? JSONSerialization.jsonObject(with: data, options: [])
    }

    func deleteStorage(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicePrefix + appId,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
//            print("Error deleting data from keychain: \(status)")
        }
    }

    func getAllStorage() -> [String: Any] {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: servicePrefix + appId,
                kSecReturnAttributes as String: kCFBooleanTrue!,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitAll
            ]

            var items: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &items)
            guard status == errSecSuccess, let itemArray = items as? [[String: Any]] else {
//                print("Error retrieving all data from keychain: \(status)")
                return [:]
            }

            var result: [String: Any] = [:]

            for item in itemArray {
                if let key = item[kSecAttrAccount as String] as? String,
                   let data = item[kSecValueData as String] as? Data {
                   let value = formData(data: data)
//                   let value = try? JSONSerialization.jsonObject(with: data, options: []) {
                    result[key] = value
                }
            }

            return result
        }
//    func getAllStorage() -> [String: Any]? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service + appId,
//            kSecReturnAttributes as String: kCFBooleanTrue!,
//            kSecReturnData as String: kCFBooleanTrue!,
//            kSecMatchLimit as String: kSecMatchLimitAll
//        ]
//        
//        var items: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &items)
//        guard status == errSecSuccess, let array = items as? [[String: Any]] else {
//            print("Error fetching all data from keychain: \(status)")
//            return nil
//        }
//        
//        var result = [String: Any]()
//        for item in array {
//            if let key = item[kSecAttrAccount as String] as? String,
//               let data = item[kSecValueData as String] as? Data {
//                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
//                   result[key] = jsonObject
//                } else if let string = try? JSONDecoder().decode(String.self, from: data) {//String(data: data, encoding: .utf8) {
//                   result[key] = string
//               } else {
//                   // 데이터가 JSON도 아니고 문자열도 아닌 경우 처리
//                   print("Data is neither JSON nor a valid UTF-8 string.")
//               }
//            }
//        }
//        
//        return result
//    }
     
//    func setAllStorage(jsonstring: String) {
//        let jsonData = jsonstring.data(using: .utf8)!
//        if let dictionary = decodeJSONToDictionary(jsonData: jsonData) {
//            setAllStorage(data: dictionary)
//        }
//    }
//
//    func setAllStorage(data: [String: Codable]) {
//        for (key, value) in data {
//            setStorage(key: key, data: value)
//        }
//    }
    
    func deleteAllStorageWithCurrentAppId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicePrefix + appId,
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
//            print("Error deleting all data from keychain: \(status)")
        }
    }
    
    func deleteAllIfAppIdDataNotExists(){
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status == errSecSuccess, let itemArray = items as? [[String: Any]] else {
            return
        }

        var appIdDataExists = false
        for item in itemArray {
           if let service = item[kSecAttrService as String] as? String,
              service.hasPrefix(servicePrefix + appId) {
               appIdDataExists = true
               break
//               SecItemDelete(item as CFDictionary)
           }
        }
        if !appIdDataExists {
            // appID 관련 데이터가 존재하지 않으면 모든 데이터를 삭제
            let deleteAllQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
            ]
            SecItemDelete(deleteAllQuery as CFDictionary)
        }

    }
    func deleteAllStorage() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status == errSecSuccess, let itemArray = items as? [[String: Any]] else {
            return
        }

        let deleteAllQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
        ]
        SecItemDelete(deleteAllQuery as CFDictionary)
        
//        for item in itemArray {
//            if let service = item[kSecAttrService as String] as? String,
//               service.hasPrefix("wepin" + (Bundle.main.bundleIdentifier ?? "")) {
//                SecItemDelete(item as CFDictionary)
//            }
//        }
    }
    
    func getWepinUser() -> WepinUser? {
        if let userInfo = StorageManager.shared.getStorage(key: "user_info", type: StorageDataType.UserInfo.self),
           let userSatus = StorageManager.shared.getStorage(key: "user_status", type: StorageDataType.UserStatus.self),
           let token = StorageManager.shared.getStorage(key: "wepin:connectUser", type: StorageDataType.WepinToken.self) {
            let walletId = StorageManager.shared.getStorage(key: "wallet_id")
            if walletId == nil {
                return WepinUser(
                    status: "successs",
                    userInfo: WepinUserInfo(
                        userId: (userInfo.userInfo.userId),
                        email: (userInfo.userInfo.email),
                        provider: WepinLoginProviders.fromValue((userInfo.userInfo.provider))!,
                        use2FA: (userInfo.userInfo.use2FA)
                    ),
                    walletId: nil,
                    userStatus: WepinUserStatus(loginStatus: WepinLoginStatus.fromValue(userSatus.loginStatus)!, pinRequired: userSatus.pinRequired),
                    token: WepinToken(refresh: (token.refreshToken), access: (token.accessToken))
                )
            }
            return WepinUser(
                status: "successs",
                userInfo: WepinUserInfo(
                    userId: (userInfo.userInfo.userId),
                    email: (userInfo.userInfo.email),
                    provider: WepinLoginProviders.fromValue((userInfo.userInfo.provider))!,
                    use2FA: (userInfo.userInfo.use2FA)
                ),
                walletId: walletId as? String,
                userStatus: WepinUserStatus(loginStatus: WepinLoginStatus.fromValue(userSatus.loginStatus)!, pinRequired: userSatus.pinRequired),
                token: WepinToken(refresh: (token.refreshToken), access: (token.accessToken))
            )
        }
        return nil
    }
    
    func setWepinUser(request: WepinLoginResult, response: WepinLoginResponse) {
        deleteAllStorage()

        setStorage(key: "firebase:wepin", data: StorageDataType.FirebaseWepin(
            idToken: request.token.idToken,
            refreshToken: request.token.refreshToken,
            provider: request.provider.rawValue
        ))
        
        let wepinToken = StorageDataType.WepinToken(
            accessToken: response.token.access,
            refreshToken: response.token.refresh
        )
        setStorage(key: "wepin:connectUser", data: wepinToken)
        
        setStorage(key: "user_id", data: response.userInfo.userId)
        
        setStorage(key: "user_status", data: StorageDataType.UserStatus(
            loginStatus: response.loginStatus,
            pinRequired: (response.loginStatus == "registerRequired") ? response.pinRequired! : false
        ))
        
        if response.loginStatus != "pinRequired", let walletId = response.walletId {
            setStorage(key: "wallet_id", data: walletId)
            setStorage(key: "user_info", data: StorageDataType.UserInfo(
                status: "success",
                userInfo: StorageDataType.UserInfoDetails(
                    userId: response.userInfo.userId,
                    email: response.userInfo.email,
                    provider: request.provider.rawValue,
                    use2FA: (response.userInfo.use2FA >= 2)
                ),
                walletId: walletId
            ))
        } else {
            let userInfo = StorageDataType.UserInfo(
                status: "success",
                userInfo: StorageDataType.UserInfoDetails(
                    userId: response.userInfo.userId,
                    email: response.userInfo.email,
                    provider: request.provider.rawValue,
                    use2FA: (response.userInfo.use2FA >= 2)
                ),
                walletId: nil
            )
            setStorage(key: "user_info", data: userInfo)
        }
        
        setStorage(key: "oauth_provider_pending", data: request.provider.rawValue)
    }
}

struct StorageDataType {
    struct FirebaseWepin : Codable{
        let idToken: String
        let refreshToken: String
        let provider: String
    }

    struct WepinToken : Codable{
        let accessToken: String
        let refreshToken: String
    }

    struct UserStatus : Codable{
        let loginStatus: String
        let pinRequired: Bool
    }

    struct UserInfo : Codable{
        let status: String
        let userInfo: UserInfoDetails
        let walletId: String?
    }
    
    struct UserInfoDetails : Codable {
        let userId: String
        let email: String
        let provider: String
        let use2FA: Bool
    }
}
