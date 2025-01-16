Pod::Spec.new do |spec|
  spec.name         = 'TUIMultimediaCore_iOS'
  spec.version      = '8.4.6667'
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
  spec.summary      = 'TUIMultimediaCore_iOS'
  spec.dependency 'TUICore'
  spec.dependency 'TIMCommon'
  spec.dependency 'TUIChat'
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.qcloud.com/download/tuiplugin/8.4.6667/ios/TUIMultimediaCore_8.4.6667.xcframework.zip'}
  spec.vendored_frameworks = 'TUIMultimediaCore.xcframework'
  spec.resource_bundle = {
        "#{spec.module_name}_Privacy" => '**/TUIMultimediaCore.xcframework/ios-arm64/TUIMultimediaCore.framework/PrivacyInfo.xcprivacy'
  }

  spec.public_header_files = '**/TUIMultimediaCore.xcframework/ios-arm64/TUIMultimediaCore.framework/Headers/*.h'
  spec.source_files = '**/TUIMultimediaCore.xcframework/ios-arm64/TUIMultimediaCore.framework/Headers/*.h'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '**/TUIMultimediaCore.xcframework/ios-arm64/TUIMultimediaCore.framework/Headers/*.h'}
  
end
