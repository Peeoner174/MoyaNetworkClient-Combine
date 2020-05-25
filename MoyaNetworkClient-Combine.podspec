Pod::Spec.new do |s|

    # 1
    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.name = "MoyaNetworkClient-Combine"
    s.summary = "Network client inspired by moya with combine realization"
    s.requires_arc = true
    
    # 2
    s.version = "1.0.0"
    
    # 3
    s.license = { :type => "MIT", :file => "LICENSE" }
    
    # 4 - Replace with your name and e-mail address
    s.author = { "Pavel Kochenda" => "peeoner174@gmail.com" }
    
    # 5 - Replace this URL with your own GitHub page's URL (from the address bar)
    s.homepage = "https://github.com/Peeoner174/MoyaNetworkClient-Combine"
    
    # 6 - Replace this URL with your own Git URL from "Quick Setup"
    s.source = { :git => "https://github.com/Peeoner174/MoyaNetworkClient-Combine.git",
    :tag => "#{s.version}" }
    
    # 7
    s.framework = "Combine"
    
    # 8
    s.source_files = "MoyaNetworkClient-Combine/**/*.{swift}"
    
    # 9
    s.resources = "MoyaNetworkClient-Combine/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
    
    # 10
    s.swift_version = "5.0"

end
