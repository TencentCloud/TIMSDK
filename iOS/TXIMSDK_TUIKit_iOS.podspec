Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_iOS'
  spec.version      = '4.4.479'
  spec.platform     = :ios 
  spec.ios.deployment_target = '8.0'
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

  spec.dependency 'MMLayout'
  spec.dependency 'SDWebImage'
  spec.dependency 'TXIMSDK_iOS'
  spec.dependency 'ReactiveObjC'
  spec.dependency 'Toast'
  
  spec.requires_arc = true

  spec.source = { :git => 'https://github.com/tencentyun/TIMSDK.git', :tag => spec.version}
  spec.source_files = 'iOS/TUIKit/Classes/**/*.{h,m,mm}'
  # spec.vendored_frameworks = ''
  spec.vendored_libraries = ['iOS/TUIKit/Classes/third/voiceConvert/opencore-amrnb/libopencore-amrnb.a', 'iOS/TUIKit/Classes/third/voiceConvert/opencore-amrwb/libopencore-amrwb.a']
  spec.resource = ['iOS/TUIKit/Resources/TUIKitFace.bundle','iOS/TUIKit/Resources/TUIKitResource.bundle']
end

# pod trunk push TXIMSDK_TUIKit_iOS.podspec --use-libraries --allow-warnings