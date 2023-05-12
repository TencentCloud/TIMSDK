Pod::Spec.new do |spec|
  spec.name         = 'TUITranslation'
  spec.version      = '7.2.4146'
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
  spec.summary      = 'TUITranslation'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.2.4146/ios/TUITranslation.zip'}

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUITranslation/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TUICore','7.2.4146'
    commonModel.dependency 'TIMCommon','7.2.4146'
    commonModel.dependency 'TUIChat','7.2.4146'
  end

  spec.subspec 'UI' do |commonUI|
    commonUI.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUITranslation/UI/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUITranslation/CommonModel"
    end
    commonUI.subspec 'UI' do |subUI|
      subUI.source_files = '**/TUITranslation/UI/UI/*.{h,m,mm}'
      subUI.dependency "TUITranslation/UI/DataProvider"
    end
    commonUI.subspec 'Service' do |service|
      service.source_files = '**/TUITranslation/UI/Service/*.{h,m,mm}'
      service.dependency "TUITranslation/UI/UI"
    end
    commonUI.resource = [
      '**/TUITranslation/Resources/*.bundle'
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

# pod trunk push TUITranslation.podspec --use-libraries --allow-warnings