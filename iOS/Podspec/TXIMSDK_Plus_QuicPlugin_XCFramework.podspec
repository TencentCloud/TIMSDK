
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Plus_QuicPlugin_XCFramework'
  spec.version      = '8.6.7020'
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
  spec.summary      = 'TXIMSDK_Plus_QuicPlugin_XCFramework'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.qcloud.com/download/plus/8.6.7020/TIMQuicPlugin_8.6.7020.xcframework.zip'}
  spec.vendored_frameworks = '**/TIMQuicPlugin.xcframework'
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

end
