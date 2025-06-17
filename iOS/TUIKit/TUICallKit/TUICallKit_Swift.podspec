Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit_Swift'
  spec.version      = '1.0.0'
  spec.platform     = :ios
  spec.ios.deployment_target = '13.0'
  spec.license      = { :type => 'Proprietary',
    :text => <<-LICENSE
    copyright 2017 tencent Ltd. All rights reserved.
    LICENSE
  }
  spec.homepage     = 'https://cloud.tencent.com/document/product/647'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICallKit'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  
  spec.dependency 'TUICore'
  spec.dependency 'RTCCommon'

  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :path => './' }
  spec.swift_version = '5.0'
  
  spec.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
  spec.library = 'c++', 'resolv', 'sqlite3'
  
  spec.default_subspec = 'Professional'
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'RTCRoomEngine/TRTC'
    trtc.source_files = 'TUICallKit_Swift/**/*.{h,m,mm,swift}'
    trtc.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit_Swift/Resources/**/*.strings', 'TUICallKit_Swift/Resources/AudioFile', 'TUICallKit_Swift/Resources/*.xcassets']
    }
    trtc.resource = ['TUICallKit_Swift/Resources/*.bundle']
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'RTCRoomEngine/Professional'
    professional.source_files = 'TUICallKit_Swift/**/*.{h,m,mm,swift}'
    professional.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit_Swift/Resources/**/*.strings', 'TUICallKit_Swift/Resources/AudioFile', 'TUICallKit_Swift/Resources/*.xcassets']
    }
    professional.resource = ['TUICallKit_Swift/Resources/*.bundle']
  end
  
  spec.resource_bundles = {
    'TUICallKit_Swift_Privacy' => ['TUICallKit_Swift/Sources/PrivacyInfo.xcprivacy']
  }
  
end

