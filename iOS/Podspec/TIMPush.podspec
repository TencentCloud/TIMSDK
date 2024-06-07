Pod::Spec.new do |spec|
  spec.name         = 'TIMPush'
  spec.version      = '8.0.5895'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2023 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TIMPush'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.qcloud.com/download/tuiplugin/8.0.5895/ios/TIMPush_8.0.5895.xcframework.zip'}
  
  spec.vendored_frameworks = 'TIMPush.xcframework'
  spec.resource_bundle = {
        "#{spec.module_name}_Privacy" => '**/TIMPush.xcframework/ios-arm64/TIMPush.framework/PrivacyInfo.xcprivacy'
  }

  spec.public_header_files = '**/TIMPush.xcframework/ios-arm64/TIMPush.framework/Headers/*.h'
  spec.source_files = '**/TIMPush.xcframework/ios-arm64/TIMPush.framework/Headers/*.h'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '**/TIMPush.xcframework/ios-arm64/TIMPush.framework/Headers/*.h'}

end
