
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Smart_iOS_Bitcode'
  spec.version      = '5.2.212'
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
  spec.summary      = 'TXIMSDK_Smart_iOS_Bitcode'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/restructure/ios/5.2.212/ImSDK_Smart_Bitcode.framework.zip'}
  spec.preserve_paths = '**/ImSDK_Smart.framework'
  spec.source_files = '**/ImSDK_Smart.framework/Headers/*.h'
  spec.public_header_files = '**/ImSDK_Smart.framework/Headers/*.h'
  spec.vendored_frameworks = '**/ImSDK_Smart.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Smart_iOS_Bitcode/ImSDK_Smart.framework/Headers/'}
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
