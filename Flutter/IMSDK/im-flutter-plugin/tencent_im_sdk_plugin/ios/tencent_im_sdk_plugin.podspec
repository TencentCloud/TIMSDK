#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hello.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tencent_im_sdk_plugin'
  s.version          = '4.0.3'
  s.summary          = 'Tencent IM SDK For Flutter'
  s.description      = <<-DESC
Tencent IM SDK For Flutter
                       DESC
  s.homepage         = 'https://cloud.tencent.com/document/product/269'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'tencent' => 'xingchenhe@tencent.com' }
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
  s.dependency 'TXIMSDK_Plus_iOS', "6.5.2816"
  # s.dependency 'TXIMSDK_Smart_iOS'
  # s.dependency 'BrightFutures'
  s.dependency 'HydraAsync'
  s.static_framework = true
end
