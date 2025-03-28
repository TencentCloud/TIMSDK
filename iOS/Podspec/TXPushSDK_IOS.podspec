
Pod::Spec.new do |spec|
  spec.name         = 'TXPushSDK_IOS'
  spec.version      = '8.5.6864'
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
  spec.summary      = 'TXPushSDK_IOS'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/plus/8.5.6864/PushSDK_8.5.6864.framework.zip'}
  spec.vendored_frameworks = '**/PushSDK.framework'
  spec.preserve_paths = '**/PushSDK.framework'
  spec.source_files = '**/PushSDK.framework/Headers/*.h', '**/PushSDK.framework/cpluscplus/include/*.h'
  spec.public_header_files = '**/PushSDK.framework/Headers/*.h', '**/PushSDK.framework/cpluscplus/include/*.h'
  spec.vendored_frameworks = '**/PushSDK.framework'
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/PushSDK.framework/PrivacyInfo.xcprivacy'
  }
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXPushSDK_iOS/PushSDK.framework/Headers/, ${PODS_ROOT}/TXPushSDK_iOS/PushSDK.framework/cpluscplus/include/'}
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

end
