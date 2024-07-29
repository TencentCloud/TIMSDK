Pod::Spec.new do |spec|
  spec.name         = 'TUITranslationPlugin'
  spec.version      = '8.1.6103'
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
  spec.summary      = 'TUITranslationPlugin'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.1.6103/ios/TUITranslationPlugin.zip'}

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUITranslationPlugin/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TUICore'
    commonModel.dependency 'TIMCommon', '~> 8.1.6103'
    commonModel.dependency 'TUIChat', '~> 8.1.6103'
  end

  spec.subspec 'UI' do |commonUI|
    commonUI.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUITranslationPlugin/UI/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUITranslationPlugin/CommonModel"
    end
    commonUI.subspec 'UI' do |subUI|
      subUI.source_files = '**/TUITranslationPlugin/UI/UI/*.{h,m,mm}'
      subUI.dependency "TUITranslationPlugin/UI/DataProvider"
    end
    commonUI.subspec 'Service' do |service|
      service.source_files = '**/TUITranslationPlugin/UI/Service/*.{h,m,mm}'
      service.dependency "TUITranslationPlugin/UI/UI"
    end
    commonUI.resource = ['**/TUITranslationPlugin/Resources/*.bundle']
  end

  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUITranslationPlugin/Resources/PrivacyInfo.xcprivacy'
  }
end

# pod trunk push TUITranslationPlugin.podspec --use-libraries --allow-warnings
