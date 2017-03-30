Pod::Spec.new do |s|
  s.name             = "Swell"
  s.summary          = "A logging utility for Swift and Objective C."
  s.version          = "0.5.4"
  s.homepage         = "https://github.com/hubertr/Swell"
  s.license          = 'Apache'
  s.author           = { "Hubert Rabago" => "undetected2@gmail.com" }
  s.source           = { :git => "https://github.com/weakfl/Swell.git", :commit => '80eb569f60454d01c207617a59abcb34343067da' }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Swell/**/*.{h,swift,plist}'
  s.frameworks       = 'UIKit'
end