//
//  WepinLoginProvider.swift
//  WepinLogin
//
//  Created by iotrust on 6/12/24.
//

import Foundation

public enum WebPinLoginProvider: String, Codable {
    case GOOGLE = "google"
    case DISCORD = "discord"
    case APPLE = "apple"
    case NAVER = "naver"
    case EMAIL = "email"
    case EXTERNAL_TOKEN = "external_token"
}

let emailRegExp = try! NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", options: .caseInsensitive)
let passwordRegExp = try! NSRegularExpression(pattern: "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,128}$", options: [])
let pinRegExp = try! NSRegularExpression(pattern: "^\\d{6,8}$", options: [])

func validateEmail(_ email: String?) -> Bool{
    guard let email = email, emailRegExp.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil else {
        return false
    }
    return true
}

func validatePassword(_ password: String?) -> Bool {
    guard let password = password, passwordRegExp.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.count)) != nil else {
        return false
    }
    return true
}
