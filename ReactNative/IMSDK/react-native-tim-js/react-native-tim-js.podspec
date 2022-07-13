require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-tim-js"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/XNeverGiveUp/react-native-tim-js.git", :tag => "#{s.version}" }

  s.dependency 'TXIMSDK_Plus_iOS', "6.3.2619"
  s.dependency 'HydraAsync'

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"
end
