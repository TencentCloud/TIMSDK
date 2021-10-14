Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_iOS'
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
  spec.summary      = 'TXIMSDK_TUIKit_iOS'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.dependency 'TUIChat','5.7.1435'
  spec.dependency 'TUIContact','5.7.1435'
  spec.dependency 'TUIConversation','5.7.1435'
  spec.dependency 'TUIGroup','5.7.1435'
  spec.dependency 'TUISearch','5.7.1435'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.qcloud.com/download/tuikit/5.7.1435/TUIKit_iOS.zip'}
  spec.source_files = '**/TUIKit/*.{h,m,mm}'
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TXIMSDK_TUIKit_iOS.podspec --use-libraries --allow-warnings
