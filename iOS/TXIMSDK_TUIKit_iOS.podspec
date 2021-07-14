Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_iOS'
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
  spec.summary      = 'TXIMSDK_TUIKit_iOS'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.dependency 'MMLayout','0.2.0'
  spec.dependency 'SDWebImage','5.9.0'
  spec.dependency 'ReactiveObjC','3.1.1'
  spec.dependency 'Toast','4.0.0'
  spec.dependency 'TXIMSDK_Plus_iOS','5.5.892'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/tuikit/5.5.892/TUIKit_iOS_5.5.892.zip'}
  spec.source_files = '**/TUIKit/Classes/**/*.{h,m,mm}'
  # spec.vendored_frameworks = ''
  spec.vendored_libraries = ['**/TUIKit/Classes/third/voiceConvert/opencore-amrnb/libopencore-amrnb.a', '**/TUIKit/Classes/third/voiceConvert/opencore-amrwb/libopencore-amrwb.a']
  spec.resource = ['**/TUIKit/Resources/TUIKitFace.bundle','**/TUIKit/Resources/TUIKitResource.bundle']
  spec.resource_bundles = {
    'TUIKitLocalizable' => ['**/TUIKit/Resources/Localizable/*']
  }
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TXIMSDK_TUIKit_iOS.podspec --use-libraries --allow-warnings
