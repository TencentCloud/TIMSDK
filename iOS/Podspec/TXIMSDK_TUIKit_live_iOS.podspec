Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_live_iOS'
  spec.version      = '5.7.1435'
  spec.platform     = :ios 
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXIMSDK_TUIKit_live_iOS'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.requires_arc = true
  spec.static_framework = true
  
  spec.dependency 'TXIMSDK_TUIKit_iOS', '5.7.1435'
  spec.dependency 'Masonry', '1.1.0'
  spec.dependency 'MJExtension', '3.2.2'
  spec.dependency 'SSZipArchive', '2.2.3'
  spec.dependency 'lottie-ios', '2.5.3'
  spec.source = { :http => 'https://im.sdk.qcloud.com/download/tuikit/5.7.1435/TUIKit_live_iOS.zip'}

  spec.default_subspec = 'TRTC'
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC', '9.2.10637'
    trtc.source_files = '**/TUIKit_live/Classes/**/*.{h,c,m,mm}'
    trtc.resource = ['**/TUIKit_live/Resources/FilterResource.bundle', '**/TUIKit_live/Resources/*.xcassets',
    '**/TUIKit_live/Classes/Common/UI/BeautySettingPanel/Resources/*.{xcassets,mp4}', 
    '**/TUIKit_live/Classes/Common/UI/AudioSettingPanel/Resource/*.{xcassets,strings}', 
    '**/TUIKit_live/Classes/Common/UI/AudioSettingPanel/Resource/**/*.{xcassets,strings}']
  end

  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional', '9.2.10637'
    professional.source_files = '**/TUIKit_live/Classes/**/*.{h,c,m,mm}'
    professional.resource = ['**/TUIKit_live/Resources/FilterResource.bundle', '**/TUIKit_live/Resources/*.xcassets',
    '**/TUIKit_live/Classes/Common/UI/BeautySettingPanel/Resources/*.{xcassets,mp4}', 
    '**/TUIKit_live/Classes/Common/UI/AudioSettingPanel/Resource/*.{xcassets,strings}', 
    '**/TUIKit_live/Classes/Common/UI/AudioSettingPanel/Resource/**/*.{xcassets,strings}']
  end
  
  
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TXIMSDK_TUIKit_live_iOS.podspec --use-libraries --allow-warnings
