#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hello.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tencent_im_sdk_plugin'
  s.version          = '1.0.5'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  # 资源导入
  s.vendored_frameworks = '**/*.framework'

  # SDK 依赖
  s.dependency 'TXIMSDK_Plus_iOS', "6.0.1975"
  # s.dependency 'TXIMSDK_Smart_iOS'
  # s.dependency 'BrightFutures'
  s.dependency 'HydraAsync'
  s.static_framework = true
end
