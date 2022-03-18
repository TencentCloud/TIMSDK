Pod::Spec.new do |spec|
  spec.name         = 'TUIChat'
  spec.version      = '6.1.2155'
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
  spec.summary      = 'TUIChat'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.requires_arc = true

  spec.source = { :http => 'https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/tuikit/6.1.2155/ios/TUIChat.zip'}
  spec.dependency 'TUICore','6.1.2155'
  spec.source_files = '**/TUIChat/**/*.{h,m,mm}'
  spec.resource = [
      '**/TUIChat/Resources/*.bundle'
  ]

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TUIChat.podspec --use-libraries --allow-warnings
