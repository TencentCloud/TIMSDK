Pod::Spec.new do |spec|
  spec.name         = 'TUIVoiceToTextPlugin'
  spec.version      = '7.9.5666'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIVoiceToTextPlugin'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.9.5666/ios/TUIVoiceToTextPlugin.zip'}

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIVoiceToTextPlugin/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TUICore'
    commonModel.dependency 'TIMCommon', '~> 7.9.5666'
    commonModel.dependency 'TUIChat', '~> 7.9.5666'
  end

  spec.subspec 'UI' do |commonUI|
    commonUI.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIVoiceToTextPlugin/UI/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIVoiceToTextPlugin/CommonModel"
    end
    commonUI.subspec 'UI' do |subUI|
      subUI.source_files = '**/TUIVoiceToTextPlugin/UI/UI/*.{h,m,mm}'
      subUI.dependency "TUIVoiceToTextPlugin/UI/DataProvider"
    end
    commonUI.subspec 'Service' do |service|
      service.source_files = '**/TUIVoiceToTextPlugin/UI/Service/*.{h,m,mm}'
      service.dependency "TUIVoiceToTextPlugin/UI/UI"
    end
    commonUI.resource = [
      '**/TUIVoiceToTextPlugin/Resources/*.bundle',
      '**/TUIVoiceToTextPlugin/Resources/PrivacyInfo.xcprivacy'
    ]
  end

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  spec.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
end

# pod trunk push TUIVoiceToTextPlugin.podspec --use-libraries --allow-warnings