//
//  WepinLoginParams.swift
//  WepinLogin
//
//  Created by iotrust on 6/13/24.
//

import Foundation

public struct WepinLoginParams: Codable {
    public init(appId: String, appKey: String){
        self.appId = appId
        self.appKey = appKey
        self.baseUrl = WepinLoginParams.getBaseUrl(appKey: appKey) ?? ""
    }
    public var appId: String
    public var appKey: String
    public var baseUrl: String
    
    private static func getBaseUrl(appKey: String) -> String? {
        var urlString:String? = nil
        
        if (appKey.hasPrefix("ak_live_")) {
            urlString = "https://sdk.wepin.io/v1/"
        }else if(appKey.hasPrefix("ak_test_")) {
            urlString = "https://stage-sdk.wepin.io/v1/"
        }else if(appKey.hasPrefix("ak_dev_")) {
            urlString = "https://dev-sdk.wepin.io/v1/"
        }
        
        return urlString
    }
}


