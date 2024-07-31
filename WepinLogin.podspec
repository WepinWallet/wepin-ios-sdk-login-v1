#
# Be sure to run `pod lib lint WepinLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WepinLogin'
  s.version          = '0.0.3'
  s.summary          = 'Wepin iOS SDK Login Library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/WepinWallet/wepin-ios-sdk-login-v1'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wepin.dev' => 'wepin.dev@iotrust.kr' }
  s.source           = { :git => 'https://github.com/WepinWallet/wepin-ios-sdk-login-v1.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'WepinLogin/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WepinLogin' => ['WepinLogin/Assets/*.png']
  # }

  s.swift_version = '5.0'
  s.dependency 'secp256k1.swift' , '~> 0.1.0'
  s.dependency 'AppAuth' , '~> 1.7.5'
  s.dependency 'BCrypt' , '~> 1.0.0'
end
