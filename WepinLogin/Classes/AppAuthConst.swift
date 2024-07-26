//
//  AppAuthConst.swift
//  WepinLogin
//
//  Created by iotrust on 6/17/24.
//

import Foundation

class AppAuthConst {
    static func getAuthorizationEndpoint(provider: String) -> URL? {
        switch provider {
        case "google":
            return URL(string: "https://accounts.google.com/o/oauth2/v2/auth")
        case "apple":
            return URL(string: "https://appleid.apple.com/auth/authorize")
        case "discord":
            return URL(string: "https://discord.com/api/oauth2/authorize")
        case "naver":
            return URL(string: "https://nid.naver.com/oauth2.0/authorize")
        default:
            return nil
        }
    }

    static func getTokenEndpoint(provider: String) -> URL? {
        switch provider {
        case "google":
            return URL(string: "https://oauth2.googleapis.com/token")
        case "apple":
            return URL(string: "https://appleid.apple.com/auth/token")
        case "discord":
            return URL(string: "https://discord.com/api/oauth2/token")
        case "naver":
            return URL(string: "https://nid.naver.com/oauth2.0/token")
        default:
            return nil
        }
    }
}

