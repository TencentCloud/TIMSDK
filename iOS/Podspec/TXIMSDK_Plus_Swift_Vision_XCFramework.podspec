
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Plus_Swift_Vision_XCFramework'
  spec.version      = '8.4.6667'
  spec.ios.deployment_target = '12.0'
  spec.visionos.deployment_target = "1.0"
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXIMSDK_Plus_Swift_Vision_XCFramework'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/plus/8.4.6667/ImSDKForVision_Plus_8.4.6667.xcframework.zip?rand=1'}
  spec.vendored_frameworks = '**/ImSDKForVision_Plus.xcframework'
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/ImSDKForVision_Plus.xcframework/xros-arm64/ImSDKForVision_Plus.framework/PrivacyInfo.xcprivacy'
  }
end
