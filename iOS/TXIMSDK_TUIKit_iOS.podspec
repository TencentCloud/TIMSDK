Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_iOS'
  spec.version      = '5.0.7'
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
  spec.summary      = 'TXIMSDK_TUIKit_iOS'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.dependency 'MMLayout','0.2.0'
  spec.dependency 'SDWebImage','5.9.0'
  spec.dependency 'ReactiveObjC','3.1.1'
  spec.dependency 'Toast','4.0.0'
  spec.dependency 'TXLiteAVSDK_TRTC','7.4.9203'
  spec.dependency 'TXIMSDK_iOS','5.0.6'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/5.0.7/TIM_SDK_TUIKIT_iOS_latest_framework.zip'}
  spec.source_files = '**/TUIKit/Classes/**/*.{h,m,mm}'
  # spec.vendored_frameworks = ''
  spec.vendored_libraries = ['**/TUIKit/Classes/third/voiceConvert/opencore-amrnb/libopencore-amrnb.a', '**/TUIKit/Classes/third/voiceConvert/opencore-amrwb/libopencore-amrwb.a']
  spec.resource = ['**/TUIKit/Resources/TUIKitFace.bundle','**/TUIKit/Resources/TUIKitResource.bundle']

end

# pod trunk push TXIMSDK_TUIKit_iOS.podspec --use-libraries --allow-warnings