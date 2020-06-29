Pod::Spec.new do |s|
    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.name = "MoyaNetworkClient-Combine"
    s.summary = "Network client inspired by moya with combine realization"
    s.requires_arc = true
    s.version = "1.0.0"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "Pavel Kochenda" => "peeoner174@gmail.com" }
    s.homepage = "https://github.com/Peeoner174/MoyaNetworkClient-Combine"
    s.source = { :git => "https://github.com/Peeoner174/MoyaNetworkClient-Combine.git",
    :tag => "#{s.version}" }
    s.framework = "Combine"
    s.source_files = "MoyaNetworkClient-Combine/**/*.{swift}"
    s.resources = "MoyaNetworkClient-Combine/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
    s.swift_version = "5.0"
end
