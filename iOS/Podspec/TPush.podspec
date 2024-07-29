Pod::Spec.new do |spec|
  spec.name         = 'TPush'
  spec.version      = '8.1.6103'
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
  spec.summary      = 'TPush'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.qcloud.com/download/tuiplugin/8.1.6103/ios/TPush_8.1.6103.xcframework.zip'}
  
  spec.vendored_frameworks = 'TPush.xcframework'
  spec.resource_bundle = {
        "#{spec.module_name}_Privacy" => '**/TPush.xcframework/ios-arm64/TPush.framework/PrivacyInfo.xcprivacy'
  }

  spec.public_header_files = '**/TPush.xcframework/ios-arm64/TPush.framework/Headers/*.h'
  spec.source_files = '**/TPush.xcframework/ios-arm64/TPush.framework/Headers/*.h'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '**/TPush.xcframework/ios-arm64/TPush.framework/Headers/*.h'}

end
