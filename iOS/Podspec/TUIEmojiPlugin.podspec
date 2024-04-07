Pod::Spec.new do |spec|
  spec.name         = 'TUIEmojiPlugin'
  spec.version      = '7.9.5666'
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
  spec.summary      = 'TUIEmojiPlugin'
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.9.5666/ios/TUIEmojiPlugin.zip?time=4'}
  spec.default_subspec = 'CommonModel'

  spec.subspec 'CommonModel' do |ss|
    ss.source_files = '**/TUIEmojiPlugin/CommonModel/*.{h,m,mm}'
    ss.dependency 'TUICore'
    ss.dependency 'TIMCommon','~>7.9.5666'
    ss.dependency 'TUIChat','~>7.9.5666'
  end

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
   spec.resource = [
    'Resources/*.bundle','Resources/PrivacyInfo.xcprivacy'
  ]
end

# pod trunk push TUIEmojiPlugin.podspec --use-libraries --allow-warnings
