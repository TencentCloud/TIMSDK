Pod::Spec.new do |spec|
  spec.name         = 'TUICalling'
  spec.version      = '9.4.0'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/647'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICalling'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }

  spec.dependency 'Masonry'
  spec.dependency 'TUICore'
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :git => 'https://github.com/tencentyun/TUICalling.git', :tag => "v9.4" }
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.swift_version = '5.0'
  spec.default_subspec = 'TRTC'

  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    # framework_path="../../SDK/TXLiteAVSDK_TRTC.framework"
    # trtc.pod_target_xcconfig={
    #     'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    # }
    trtc.source_files = 'iOS/Source/localized/**/*.{h,m,mm}', 'iOS/Source/Model/**/*.{h,m,mm}', 'iOS/Source/Service/**/*.{h,m,mm}', 'iOS/Source/UI/**/*.{h,m,mm}', 'iOS/Source/TUICallingKit_TRTC/*.{h,m,mm}'
    trtc.ios.framework = ['AVFoundation', 'Accelerate']
    trtc.library = 'c++', 'resolv'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['iOS/Resources/Localized/**/*.strings', 'iOS/Resources/AudioFile', 'iOS/Resources/*.xcassets']
    }
  end
 
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    # framework_path="../../SDK/TXLiteAVSDK_Professional.framework"
    # professional.pod_target_xcconfig={
    #     'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    # }
    # professional.xcconfig = { 'HEADER_SEARCH_PATHS' => '${SRCROOT}/../SDK/TXLiteAVSDK_Professional.framework/Headers/'}
    professional.source_files = 'iOS/Source/localized/**/*.{h,m,mm}', 'iOS/Source/Model/**/*.{h,m,mm}', 'iOS/Source/Service/**/*.{h,m,mm}', 'iOS/Source/UI/**/*.{h,m,mm}', 'iOS/Source/TUICallingKit_Professional/*.{h,m,mm}'
    professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    professional.library = 'c++', 'resolv', 'sqlite3'
    professional.resource_bundles = {
      'TUICallingKitBundle' => ['iOS/Resources/Localized/**/*.strings', 'iOS/Resources/AudioFile', 'iOS/Resources/*.xcassets']
    }
  end
  
end
