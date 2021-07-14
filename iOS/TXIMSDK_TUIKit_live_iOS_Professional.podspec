Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_live_iOS_Professional'
  spec.version      = '5.5.892'
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
  spec.summary      = 'TXIMSDK_TUIKit_live_iOS_Professional'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  
  spec.dependency 'TXIMSDK_TUIKit_iOS', '5.5.892'
  spec.dependency 'TXLiteAVSDK_Professional', '8.5.10022'
  spec.dependency 'Masonry', '1.1.0'
  spec.dependency 'MJExtension', '3.2.2'
  spec.dependency 'SSZipArchive', '2.2.3'
  spec.dependency 'lottie-ios', '2.5.3'

  spec.requires_arc = true

  spec.source = { :http => 'https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/tuikit/5.5.892/TUIKit_live_iOS_5.5.892.zip'}
  spec.source_files = '**/TUIKit_live/Classes/**/*.{h,m,mm}', '**/TUIKit_live/Classes/**/*.{h,c}'
  spec.resource = ['**/TUIKit_live/Resources/FilterResource.bundle', '**/TUIKit_live/Resources/*.xcassets',
    '**/TUIKit_live/Classes/Modules/BeautySettingPanel/Resources/*.{xcassets,mp4}', 
    '**/TUIKit_live/Classes/Modules/AudioSettingPanel/Resource/*.{xcassets,strings}', 
    '**/TUIKit_live/Classes/Modules/AudioSettingPanel/Resource/**/*.{xcassets,strings}']
  
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TXIMSDK_TUIKit_live_iOS_Professional.podspec --use-libraries --allow-warnings
