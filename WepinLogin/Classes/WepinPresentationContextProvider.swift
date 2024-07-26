//
//  WepinPresentationContextProvider.swift
//  WepinLogin
//
//  Created by iotrust on 6/17/24.
//

import AuthenticationServices

class WepinPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    private weak var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window ?? ASPresentationAnchor()
    }
}
