//
//  ViewController.swift
//  WepinLogin
//
//  Created by iotrust on 06/12/2024.
//  Copyright (c) 2024 iotrust. All rights reserved.
//

import UIKit
import WepinLogin
//import AuthenticationServices

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labalResult: UILabel!
    @IBOutlet weak var tvResult: UITextView!
    
    let appKey: String = "Wepin-App-Key"
    let appId: String = "Wepin-App-ID"
    let privateKey: String = "Wepin-OAuth-Verification-Key"
    
    let googleClientId: String = "Google-Client-ID"
    let appleClientId: String = "Apple-Client-ID"
    let discordClientId: String = "Discord-Client-ID"
    let naverClientId: String = "Naver-Client-ID"
    
    var wepin: WepinLogin? = nil
    private var wepinLoginRes: WepinLoginResult? = nil
    let testList = ["initialize", 
                    "isInitialized", 
                    "getSignForLogin",
                    "loginWithOauth(Apple)",
                    "loginWithOauth(Google)",
                    "loginWithOauth(Discord)",
                    "loginWithOauth(Naver)",
                    "loginWithIdToken",
                    "loginWithAccessToken",
                    "signUpWithEmail",
                    "loginWithEmail",
                    "getRefreshFirebaseToken",
                    "loginWepin",
                    "getCurrentWepinUser",
                    "logoutWepin",
                    "finalize"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView의 frame 설정
//        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: labalResult.frame.minY - 10)

//        tableView.translatesAutoresizingMaskIntoConstraints = false
        // 라벨과의 제약조건 설정
//        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
//        tableView.bottomAnchor.constraint(equalTo: labalResult.topAnchor, constant: -30).isActive = true
//        tableView.heightAnchor.constraint(equalToConstant: labalResult.frame.minY - 30).isActive = true
        
        //        tableView.delegate = self
                tableView.dataSource = self
        
        let iniParam = WepinLoginParams(appId: appId, appKey: appKey)
        wepin = WepinLogin(iniParam)
    }

    func testMethod(at indexPath: IndexPath){
        self.tvResult.text = String("processing...")
        switch testList[indexPath.row] {
        case "initialize":
            do {
                print("initialize")
                Task {
                    do{
                        let res = try await wepin!.initialize()
                        self.tvResult.text = String("Successed: " + String(res!))
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "isInitialized":
            do {
                print("isInitialized")
                let result = wepin!.isInitialized()
        //        saveJsonData()
                self.tvResult.text = String("result - \(result)")
            }
        case "getSignForLogin":
            do {
                print("getSingForLogin")
                let res = wepin!.getSignForLogin(privateKey: privateKey, message: "")
                if (res != nil) {
                    self.tvResult.text = String("Successed: " + res!)
                }else {
                    self.tvResult.text = String("Fail")
                }
            }
        case "loginWithOauth(Apple)":
            do {
                print("loginWithOauth(Apple)")
                Task {
                    do {
                        let oauthParams = WepinLoginOauth2Params(provider: "apple", clientId: self.appleClientId)
                        let res = try await wepin!.loginWithOauthProvider(params: oauthParams, viewController: self)
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: res.token)
                        let params = WepinLoginOauthIdTokenRequest(idToken: res.token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithIdToken(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithOauth(Google)":
            do {
                print("loginWithOauth(Google)")
                Task {
                    do {
                        let oauthParams = WepinLoginOauth2Params(provider: "google", clientId: self.googleClientId)
                        let res = try await wepin!.loginWithOauthProvider(params: oauthParams, viewController: self)
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: res.token)
                        let params = WepinLoginOauthIdTokenRequest(idToken: res.token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithIdToken(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithOauth(Discord)":
            do {
                print("loginWithOauth(Discord)")
                Task {
                    do {
                        let oauthParams = WepinLoginOauth2Params(provider: "discord", clientId: self.discordClientId)
                        let res = try await wepin!.loginWithOauthProvider(params: oauthParams, viewController: self)
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: res.token)
                        let params = WepinLoginOauthAccessTokenRequest(provider: "discord", accessToken: res.token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithAccessToken(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithOauth(Naver)":
            do {
                print("loginWithOauth(Naver)")
                Task {
                    do {
                        let oauthParams = WepinLoginOauth2Params(provider: "naver", clientId: self.naverClientId)
                        let res = try await wepin!.loginWithOauthProvider(params: oauthParams, viewController: self)
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: res.token)
                        let params = WepinLoginOauthAccessTokenRequest(provider: "naver", accessToken: res.token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithAccessToken(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithIdToken":
            do {
                print("loginWithIdToken")
                Task {
                    do {
                        let token = "ID-TOKEN"
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: token)
                        let params = WepinLoginOauthIdTokenRequest(idToken: token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithIdToken(params: params)
                        
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithAccessToken":
            do {
                print("loginWithAccessToken")
                Task {
                    do {
                        let token = "ACCESS-TOKEN"
                        let sign = wepin!.getSignForLogin(privateKey: privateKey, message: token)
                        let params = WepinLoginOauthAccessTokenRequest(provider: "discord", accessToken: token, sign: sign!)
                        wepinLoginRes = try await wepin!.loginWithAccessToken(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "signUpWithEmail":
            do {
                print("signUpWithEmail")
                Task {
                    do {
                        let email = "EMAIL-ADDRESS"
                        let password = "PASSWORD"
                        let params = WepinLoginWithEmailParams(email: email, password: password)
                        wepinLoginRes = try await wepin!.signUpWithEmailAndPassword(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWithEmail":
            do {
                print("loginWithEmail")
                Task {
                    do {
                        let email = "EMAIL-ADDRESS"
                        let password = "PASSWORD"
                        let params = WepinLoginWithEmailParams(email: email, password: password)
                        wepinLoginRes = try await wepin!.loginWithEmailAndPassword(params: params)
                        self.tvResult.text = String("Successed: \(wepinLoginRes)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "getRefreshFirebaseToken":
            do{
                print("getRefreshFirebaseToken")
                Task {
                    do {
                        let res = try await wepin!.getRefreshFirebaseToken()
                        wepinLoginRes = res
                        self.tvResult.text = String("Successed: \(res)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "loginWepin":
            do{
                print("loginWepin")
                Task {
                    do {
                        if(wepinLoginRes == nil) {
                            self.tvResult.text = String("Faild: Before performing the 'loginWepin' method, the 'loginWithToken', 'loginWithAccessToken', 'loginWithOauth', and 'loginWithEmailAndPassword' methods must be performed first.")
                            return
                        }
                        let res = try await wepin!.loginWepin(params: wepinLoginRes!)
                        wepinLoginRes = nil
                        self.tvResult.text = String("Successed: \(res)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "getCurrentWepinUser":
            do{
                print("getCurrentWepinUser")
                Task {
                    do {
                        let res = try await wepin!.getCurrentWepinUser()
                        self.tvResult.text = String("Successed: \(res)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "logoutWepin":
            do{
                print("logoutWepin")
                
//                wepin?.logoutWepin()
                Task {
                    do {
                        let res = try await wepin!.logoutWepin()
                        self.tvResult.text = String("Successed: \(res)")
                    } catch (let error){
                        self.tvResult.text = String("Faild: \(error)")
                    }
                }
            }
        case "finalize":
            do {
                print("finalize")
                wepin!.finalize()
                self.tvResult.text = String("Successed")
            }
        default:
            print("default")
        }
    }
    
}

// AppAuth url scheme을 가져오기 위해 설정 필요!!
//extension ViewController: ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Cell at \(indexPath.row) selected")
        testMethod(at: indexPath)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return testList.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath) as! TestListCellTableViewCell
        cell.listLabel.text = testList[indexPath.row]
        
        return cell

    }

}
