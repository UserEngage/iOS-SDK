# local testing podspec

Pod::Spec.new do |spec|
    version                     = '0.2.0'
    swift_version               = '5.1.2'

    spec.name                   = "UserSDK"
    spec.version                = "#{version}"
    spec.summary                = "SDK for user.com"
    spec.homepage               = "http://user.com"
    spec.license                = { :type => "MIT", :file => "LICENSE" }
    spec.author                 = { "Andrzej Puczyk" => "a.puczyk@futuremind.com" }
    spec.platform               = :ios, "11.0"
    spec.swift_version          = "#{swift_version}"

    spec.module_name            = "UserSDK"
    spec.source                 = { :git => "git@github.com:UserEngage/iOS-SDK.git", :tag => "#{version}" }
    spec.vendored_frameworks    = 'UserSDK.framework'
    spec.static_framework       = true

    spec.frameworks             = 'Foundation', 'UIKit', 'CoreTelephony', 'AdSupport', 'SystemConfiguration', 'UserNotifications'
    spec.dependency 'Firebase/Core'
    spec.dependency 'Firebase/Messaging'

    spec.user_target_xcconfig   = { "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES" => "YES" }
end
