Pod::Spec.new do |s|
  s.name             = "Swell"
  s.summary          = "A logging utility for Swift and Objective C."
  s.version          = "0.5.0"
  s.homepage         = "https://github.com/hubertr/Swell"
  s.license          = 'Apache'
  s.author           = { "Hubert Rabago" => "undetected2@gmail.com" }
  s.source           = { :git => "https://github.com/weakfl/Swell.git", :commit => '5bd9de6b07a1990a94e54494e4da6c907383961a' }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Swell/**/*'
  s.frameworks       = 'UIKit'
end