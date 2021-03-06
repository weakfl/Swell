Pod::Spec.new do |s|
  s.name             = "Swell"
  s.summary          = "A logging utility for Swift and Objective C."
  s.version          = "0.6.0"
  s.homepage         = "https://github.com/weakfl/Swell"
  s.license          = 'Apache'
  s.authors          = { "Hubert Rabago" => "undetected2@gmail.com", "weakfl" => "" }
  s.source           = { :git => "https://github.com/weakfl/Swell.git", :tag => "v#{s.version}" }
  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  s.requires_arc     = true
  s.swift_version    = '5.0'
  s.source_files     = 'Swell/**/*.{h,swift}'
end
