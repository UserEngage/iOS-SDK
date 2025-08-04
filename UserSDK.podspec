# local testing podspec

Pod::Spec.new do |spec|
    version                     = '0.7.3'
    swift_version               = '5.10'

    spec.name                   = "UserSDK"
    spec.version                = "#{version}"
    spec.summary                = "SDK for user.com"
    spec.homepage               = "http://user.com"
    spec.license                = { :type => "MIT", :file => "LICENSE" }
    spec.authors                = { "User" => "http://user.com" }
    
    spec.platform               = :ios, "13.0"
    spec.swift_version          = "#{swift_version}"

    spec.module_name            = "UserSDK"
    spec.source                 = { :git => "git@github.com:UserEngage/iOS-SDK.git", :tag => "#{version}" }
    spec.vendored_frameworks    = 'UserSDK.xcframework'
    spec.static_framework       = true
    spec.frameworks             = 'Foundation', 'UIKit', 'CoreTelephony', 'AdSupport', 'SystemConfiguration', 'UserNotifications'
    
    spec.dependency 'FirebaseCore'
    spec.dependency 'FirebaseMessaging'
    spec.dependency 'Gifu', '3.3.1'

    spec.user_target_xcconfig   = { "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES" => "YES" }
end
