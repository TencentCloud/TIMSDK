
Pod::Spec.new do |spec|
  spec.name         = 'TXPushSDK_IOS_XCFramework'
  spec.version      = '8.3.6498'
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXPushSDK_IOS_XCFramework'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/plus/8.3.6498/PushSDK_8.3.6498.xcframework.zip'}
  spec.vendored_frameworks = '**/PushSDK.xcframework'
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/PushSDK.xcframework/ios-arm64_armv7/PushSDK.framework/PrivacyInfo.xcprivacy'
  }
end
