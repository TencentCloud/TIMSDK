Pod::Spec.new do |spec|
  spec.name         = 'TUIVoiceToTextPlugin'
  spec.version      = '8.0.5895'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.0.5895/ios/TUIVoiceToTextPlugin.zip'}

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIVoiceToTextPlugin/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TUICore'
    commonModel.dependency 'TIMCommon', '~> 8.0.5895'
    commonModel.dependency 'TUIChat', '~> 8.0.5895'
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
    commonUI.resource = ['**/TUIVoiceToTextPlugin/Resources/*.bundle']
  end

  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIVoiceToTextPlugin/Resources/PrivacyInfo.xcprivacy'
  }
end

# pod trunk push TUIVoiceToTextPlugin.podspec --use-libraries --allow-warnings
