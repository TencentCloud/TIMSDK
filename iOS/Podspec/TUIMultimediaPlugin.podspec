Pod::Spec.new do |spec|
  spec.name         = 'TUIMultimediaPlugin'
  spec.version      = '8.4.6667'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2024 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIMultimediaPlugin'
  spec.dependency 'TUICore'
  spec.dependency 'TIMCommon'
  spec.dependency 'TUIChat'
  spec.dependency 'TXLiteAVSDK_Professional'
  spec.dependency 'TUIMultimediaCore_iOS'
  
  spec.static_framework = true
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.4.6667/ios/TUIMultimediaPlugin.zip'}
  spec.source_files = 'TUIMultimediaPlugin/**/*.{h,m,mm,c}'
  spec.resource = ['TUIMultimediaPlugin/Resources/*.bundle']
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'TUIMultimediaPlugin/Resources/PrivacyInfo.xcprivacy'
  }
#   pod lib lint TUIMultimediaPlugin.podspec --use-libraries --allow-warnings --skip-import-validation --verbose

end
