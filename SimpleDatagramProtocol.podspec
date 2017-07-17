Pod::Spec.new do |s|
  s.name         = "SimpleDatagramProtocol"
  s.version      = "0.1"
  s.summary      = ""
  s.description  = "Reference Swift implementation for the Simple Datagram Protocol"
  DESC
  s.homepage     = "https://github.com/snipsco/SDP-swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Sasha Lopoukhine" => "sasha.lopoukhine@snips.ai" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/snipsco/SDP-swift.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
