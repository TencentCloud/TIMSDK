#
# Be sure to run `pod lib lint TUIVideoSeat.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name                  = 'TUIVideoSeat'
  spec.version               = '1.3.2'
  spec.platform              = :ios
  spec.ios.deployment_target = '11.0'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage              = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url     = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors               = 'tencent video cloud'
  spec.summary               = 'A short description of TUIVideoSeat.'
  
  spec.static_framework = true
  spec.xcconfig      = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  spec.swift_version = '5.0'
  
  spec.source                = { :path => './' }
  
  spec.dependency 'SnapKit'
  spec.dependency 'TUICore'
  
  spec.default_subspec = 'TRTC'
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TUIRoomEngine/Professional','1.3.3'
    professional.source_files = 'Source/*.swift','Source/Localized/*.swift','Source/View/View/*.swift','Source/View/ViewModel/*.swift','Source/Model/*.swift','Source/Common/*.*'
    professional.resource_bundles = {
      'TUIVideoSeatKitBundle' => ['Resources/*.xcassets', 'Resources/Localized/**/*.strings']
    }
    professional.pod_target_xcconfig = {'OTHER_SWIFT_FLAGS' => '-D TXLiteAVSDK_Professional', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 TXLiteAVSDK_Professional=1'}
  end
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TUIRoomEngine/TRTC','1.3.3'
    trtc.source_files = 'Source/*.swift','Source/Localized/*.swift','Source/View/View/*.swift','Source/View/ViewModel/*.swift','Source/Model/*.swift','Source/Common/*.*'
    trtc.resource_bundles = {
      'TUIVideoSeatKitBundle' => ['Resources/*.xcassets', 'Resources/Localized/**/*.strings']
    }
    trtc.pod_target_xcconfig = {'OTHER_SWIFT_FLAGS' => '-D TXLiteAVSDK_TRTC', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 TXLiteAVSDK_TRTC=1'}
  end
  
end
