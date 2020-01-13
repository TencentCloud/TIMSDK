
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_iOS'
  spec.version      = '4.6.58'
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
  spec.summary      = 'TXIMSDK_iOS'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/4.6.58/TIM_SDK_iOS_latest_framework.zip'}
  spec.preserve_paths = '**/ImSDK.framework'
  spec.source_files = '**/ImSDK.framework/Headers/*.h'
  spec.public_header_files = '**/ImSDK.framework/Headers/*.h'
  spec.vendored_frameworks = '**/ImSDK.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_iOS/ImSDK.framework/Headers/'}
end