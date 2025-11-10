//
//  ViewController.swift
//  WepinLogin
//
//  Created by JisunHong1 on 03/17/2025.
//  Copyright (c) 2025 JisunHong1. All rights reserved.
//

import UIKit
import WepinLogin

class ViewController: UIViewController {
    
    var wepinLogin: WepinLogin?
    
    var appId: String = "WEPIN_APP_ID"
    var appKey: String = "WEPIN_APP_KEY"
    
    let providerInfos: [LoginProviderInfo] = [
        LoginProviderInfo(provider: "google", clientId: "GOOGLE_CLIENT_ID"),
        LoginProviderInfo(provider: "apple", clientId: "APPLE_CLIENT_ID"),
        LoginProviderInfo(provider: "discord", clientId: "DISCORD_CLIENT_ID"),
        LoginProviderInfo(provider: "naver", clientId: "NAVER_CLIENT_ID"),
        LoginProviderInfo(provider: "facebook", clientId: "FACEBOOK_CLIENT_ID"),
        LoginProviderInfo(provider: "line", clientId: "LINE_CLIENT_ID")
    ]
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    var settingsContainerView: UIView!
    var statusLabel: UILabel!
    var appIdTextField: UITextField!
    var appKeyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        
        setupUI()
        
        let params = WepinLoginParams(appId: appId, appKey: appKey)
        wepinLogin = WepinLogin(params)
    }
    
    func setupUI() {
        // 상단 영역: 버튼 및 설정 패널이 포함된 스크롤 가능한 컨테이너 (화면의 50% 차지)
        let topContainer = UIView()
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topContainer)
        
        // 하단 영역: 상태 레이블이 위치할 컨테이너
        let bottomContainer = UIView()
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomContainer)
        
        NSLayoutConstraint.activate([
            // 상단 영역: safeArea의 top부터 view의 50% 높이까지
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            // 하단 영역: 상단 컨테이너 바로 아래부터 safeArea의 bottom까지
            bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 상단 영역에 기존 UI 구성 요소 추가
        let topStack = UIStackView()
        topStack.axis = .vertical
        topStack.spacing = 8
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(topStack)
        
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 8),
            topStack.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            topStack.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor)
        ])
        
        
        // 타이틀 레이블
        let titleLabel = UILabel()
        titleLabel.text = "Wepin Widget Test"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        topStack.addArrangedSubview(titleLabel)
        
        let emailNoticeLabel = UILabel()
        emailNoticeLabel.text = "This app collects your email address from LINE login for authentication and account linking purposes only."
        emailNoticeLabel.font = UIFont.systemFont(ofSize: 14)
        emailNoticeLabel.textColor = .darkGray
        emailNoticeLabel.numberOfLines = 0
        emailNoticeLabel.textAlignment = .center
        topStack.addArrangedSubview(emailNoticeLabel)
        
        // 상단 컨테이너 내부에 스크롤뷰 추가
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        topStack.addArrangedSubview(scrollView)
        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: topContainer.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor)
//        ])
        
        // 스크롤뷰 내에 버튼 및 설정 패널을 담을 스택뷰 추가
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 16
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            buttonStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        settingsContainerView = UIView()
        settingsContainerView.backgroundColor = .white
        settingsContainerView.layer.cornerRadius = 8
        settingsContainerView.layer.shadowColor = UIColor.black.cgColor
        settingsContainerView.layer.shadowOpacity = 0.2
        settingsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        settingsContainerView.isHidden = true
        settingsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let settingsStack = UIStackView()
        settingsStack.axis = .vertical
        settingsStack.spacing = 8
        settingsStack.translatesAutoresizingMaskIntoConstraints = false
        settingsContainerView.addSubview(settingsStack)
        NSLayoutConstraint.activate([
            settingsStack.topAnchor.constraint(equalTo: settingsContainerView.topAnchor, constant: 16),
            settingsStack.leadingAnchor.constraint(equalTo: settingsContainerView.leadingAnchor, constant: 16),
            settingsStack.trailingAnchor.constraint(equalTo: settingsContainerView.trailingAnchor, constant: -16),
            settingsStack.bottomAnchor.constraint(equalTo: settingsContainerView.bottomAnchor, constant: -16)
        ])
        
        let settingsTitle = UILabel()
        settingsTitle.text = "Settings"
        settingsTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        settingsStack.addArrangedSubview(settingsTitle)
        
        let appIdLabel = UILabel()
        appIdLabel.text = "App ID"
        settingsStack.addArrangedSubview(appIdLabel)
        
        appIdTextField = UITextField()
        appIdTextField.borderStyle = .roundedRect
        appIdTextField.text = appId
        settingsStack.addArrangedSubview(appIdTextField)
        
        let appKeyLabel = UILabel()
        appKeyLabel.text = "App Key"
        settingsStack.addArrangedSubview(appKeyLabel)
        
        appKeyTextField = UITextField()
        appKeyTextField.borderStyle = .roundedRect
        appKeyTextField.text = appKey
        settingsStack.addArrangedSubview(appKeyTextField)
        
        let applyChangesButton = UIButton(type: .system)
        applyChangesButton.setTitle("Apply Changes", for: .normal)
        applyChangesButton.addTarget(self, action: #selector(applySettings), for: .touchUpInside)
        settingsStack.addArrangedSubview(applyChangesButton)
        
        buttonStackView.addArrangedSubview(settingsContainerView)
        
        // 기능 버튼들을 추가 (추가할 버튼은 기존 addFunctionButton 함수로 동일한 효과를 줌)
        func addFunctionButton(title: String, action: Selector) {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.layer.cornerRadius = 8
            button.backgroundColor = .systemBlue
            button.tintColor = .white
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        addFunctionButton(title: "Initialize", action: #selector(initializeTapped))
        addFunctionButton(title: "Check Initialization Status", action: #selector(checkInitStatusTapped))
        addFunctionButton(title: "Email Signup", action: #selector(signUpWithEmailTapped))
        addFunctionButton(title: "Email Login", action: #selector(loginWithEmailTapped))
        addFunctionButton(title: "loginWithOauthProvider(google)", action: #selector(loginWithGoogleTapped))
        addFunctionButton(title: "loginWithOauthProvider(apple)", action: #selector(loginWithAppleTapped))
        addFunctionButton(title: "loginWithOauthProvider(discord)", action: #selector(loginWithDiscordTapped))
        addFunctionButton(title: "loginWithOauthProvider(naver)", action: #selector(loginWithNaverTapped))
        addFunctionButton(title: "loginWithOauthProvider(facebook)", action: #selector(loginWithFacebookTapped))
        addFunctionButton(title: "loginWithOauthProvider(line)", action: #selector(loginWithLineTapped))
        addFunctionButton(title: "loginWithOauthProvider(kakao)", action: #selector(loginWithKakaoTapped))
        addFunctionButton(title: "loginWithAccessToken(invalid provider)", action: #selector(invalidLoginWithAccessTokenTapped))
        addFunctionButton(title: "Get Refresh Firebase Token", action: #selector(getRefreshFirebaseTokenTapped))
        addFunctionButton(title: "Get Current Wepin User", action: #selector(getCurrentWepinUserTapped))
        addFunctionButton(title: "Get Sign For Login (Deprecated)", action: #selector(getSignForLoginTapped))
        addFunctionButton(title: "Logout", action: #selector(logoutTapped))
        addFunctionButton(title: "Finalize", action: #selector(finalizeTapped))
        
        // ✅ ScrollView 추가 (하단)
        let textWrapperScrollView = UIScrollView()
        textWrapperScrollView.translatesAutoresizingMaskIntoConstraints = false
        textWrapperScrollView.layer.borderColor = UIColor.lightGray.cgColor
        textWrapperScrollView.layer.borderWidth = 1
        textWrapperScrollView.layer.cornerRadius = 8
        textWrapperScrollView.clipsToBounds = true
        bottomContainer.addSubview(textWrapperScrollView)

        // ✅ Label 추가
        statusLabel = UILabel()
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.textColor = .black
        statusLabel.text = "Status: Not Initialized"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        textWrapperScrollView.addSubview(statusLabel)

        // ✅ AutoLayout 설정
        NSLayoutConstraint.activate([
            // ScrollView Constraints
            textWrapperScrollView.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            textWrapperScrollView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            textWrapperScrollView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            textWrapperScrollView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -8),
            
            // Label Constraints (ScrollView Content)
            statusLabel.topAnchor.constraint(equalTo: textWrapperScrollView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: textWrapperScrollView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: textWrapperScrollView.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: textWrapperScrollView.bottomAnchor),
            statusLabel.widthAnchor.constraint(equalTo: textWrapperScrollView.widthAnchor)
        ])
    }
    
    @objc func applySettings() {
        // 텍스트필드의 값으로 설정값 갱신
        appId = appIdTextField.text ?? appId
        appKey = appKeyTextField.text ?? appKey
        let params = WepinLoginParams(appId: appId, appKey: appKey)
            wepinLogin =  WepinLogin(params)
            updateStatus("Settings Applied")
    }
    
    @objc func initializeTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepinLogin is nil. Apply settings first.")
                return
            }
//            let attributes = WepinWidgetAttribute(defaultLanguage: selectedLanguage, defaultCurrency: "USD")
            do {
                let result = try await login.initialize() ?? false
                updateStatus(result ? "Initialized" : "Initialization Failed")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func invalidLoginWithAccessTokenTapped() {
        Task {
            var result = await loginWithOauthProvider(provider: "discord", notLoginWepin: true)
            self.loginWithIdToken(idToken: result?.token ?? "")
        }
    }
    
    @objc func checkInitStatusTapped() {
        // SDK 내 isInitialized 여부에 따라 상태 확인
        if let login = wepinLogin, login.isInitialized() {
            updateStatus("WepinLogin is Initialized")
        } else {
            updateStatus("Not Initialized")
        }
    }
    
    @objc func signUpWithEmailTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepnLogin is nil")
                return
            }
            do {
                let params = WepinLoginWithEmailParams(email: "EMAIL", password: "PASSWORD", locale: "ko")
                let result = try await login.signUpWithEmailAndPassword(params: params)
                updateStatus("signupWithEmail: \(result)")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func loginWithEmailTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepnLogin is nil")
                return
            }
            do {
                let params = WepinLoginWithEmailParams(email: "EMAIL", password: "PASSWORD")
                let result = try await login.loginWithEmailAndPassword(params: params)
                updateStatus("loginWithEmail: \(result)")
                wepinLogin(loginResult: result)
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func loginWithGoogleTapped() {
        Task {
            await loginWithOauthProvider(provider: "google")
        }
    }
    
    @objc func loginWithAppleTapped() {
        Task {
            await loginWithOauthProvider(provider: "apple")
        }
    }
    
    @objc func loginWithDiscordTapped() {
        Task {
            await loginWithOauthProvider(provider: "discord")
        }
    }
    
    @objc func loginWithNaverTapped() {
        Task {
            await loginWithOauthProvider(provider: "naver")
        }
    }
    
    @objc func loginWithFacebookTapped() {
        Task {
            await loginWithOauthProvider(provider: "facebook")
        }
    }
    
    @objc func loginWithLineTapped() {
        Task {
            await loginWithOauthProvider(provider: "line")
        }
    }
    
    @objc func loginWithKakaoTapped() {
        Task {
            await loginWithOauthProvider(provider: "kakao")
        }
    }
    
    @objc func getRefreshFirebaseTokenTapped() {
        guard let login = wepinLogin else {
            updateStatus("wepinLogin is nil")
            return
        }
        
        Task {
            do {
                let result = try await login.getRefreshFirebaseToken()
                updateStatus("getRefreshFirebaseToken: \(result)")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func getSignForLoginTapped() {
        guard let login = wepinLogin else {
            updateStatus("wepinLogin is nil")
            return
        }
        do {
            try login.getSignForLogin(privateKey: "", message: "")
        } catch {
            updateStatus("Error: \(error.localizedDescription)")
        }
    }
    
    @objc func getCurrentWepinUserTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepnLogin is nil")
                return
            }
            do {
                let result = try await login.getCurrentWepinUser()
                updateStatus("getCurrentWepinUser: \(result)")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func logoutTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepinLogin is nil")
                return
            }
            do {
                let result = try await login.logoutWepin()
                updateStatus("\(result)")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }

    private func loginWithOauthProvider(provider: String, notLoginWepin: Bool = false) async -> WepinLoginOauthResult? {
//        Task {
            guard let login = wepinLogin else {
                updateStatus("wepinLogin is nil")
                return nil
            }
            guard let params = providerInfos[provider] else {
                updateStatus("provider info is not exist")
                return nil
            }
            do {
                let result = try await login.loginWithOauthProvider(params: params, viewController: self)
                updateStatus("loginWithOauthProvider: \(result)")
                
                if notLoginWepin {
                    return result
                }
                
                switch(result.type) {
                case WepinOauthTokenType.idToken:
                    self.loginWithIdToken(idToken: result.token)
                case WepinOauthTokenType.accessToken:
                    self.loginWithAccessToken(provider: provider, accessToken: result.token)
                }
                return nil
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
                return nil
            }
//        }
    }
    
    private func loginWithIdToken(idToken: String) {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepinLogin is nil")
                return
            }
            let params = WepinLoginOauthIdTokenRequest(idToken: idToken)
            do {
                let result = try await login.loginWithIdToken(params: params)
                updateStatus("loginWithIdToken: \(result)")
                self.wepinLogin(loginResult: result)
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func loginWithAccessToken(provider: String, accessToken: String) {
        Task {
            guard let login = wepinLogin else {
                updateStatus("wepinLogin is nil")
                return
            }
            let params = WepinLoginOauthAccessTokenRequest(provider: provider, accessToken: accessToken)
            do {
                let result = try await login.loginWithAccessToken(params: params)
                updateStatus("loginWithAccessToken: \(result)")
                self.wepinLogin(loginResult: result)
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func wepinLogin(loginResult: WepinLoginResult) {
        Task {
            guard wepinLogin != nil else {
                updateStatus("wepinLogin is nil")
                return
            }
            do {
                let result = try await wepinLogin?.loginWepin(params: loginResult)
                updateStatus("wepinLogin: \(String(describing: result))")
            } catch {
                updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func finalizeTapped() {
        Task {
            guard let login = wepinLogin else {
                updateStatus("WepinWidget is nil.")
                return
            }
            login.finalize()
            updateStatus("Finalized")

        }
    }
    
    func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

