Pod::Spec.new do |s|
  s.name             = "Swell"
  s.summary          = "A logging utility for Swift and Objective C."
  s.version          = "0.5.7"
  s.homepage         = "https://github.com/weakfl/Swell"
  s.license          = 'Apache'
  s.authors          = { "Hubert Rabago" => "undetected2@gmail.com", "weakfl" => "" }
  s.source           = { :git => "https://github.com/weakfl/Swell.git", :commit => 'dd114be825d319d0b8c8b8c31a7fb45dfb337bb3' }
  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc     = true
  s.swift_version    = '4.0'
  s.source_files     = 'Swell/**/*.{h,swift,plist}'
end