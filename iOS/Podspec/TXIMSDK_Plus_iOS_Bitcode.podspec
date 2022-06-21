
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Plus_iOS_Bitcode'
  spec.version      = '6.3.2609'
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
  spec.summary      = 'TXIMSDK_Plus_iOS_Bitcode'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/plus/6.3.2609/ImSDK_Plus_6.3.2609_Bitcode.framework.zip'}
  spec.preserve_paths = '**/ImSDK_Plus.framework'
  spec.source_files = '**/ImSDK_Plus.framework/Headers/*.h'
  spec.public_header_files = '**/ImSDK_Plus.framework/Headers/*.h'
  spec.vendored_frameworks = '**/ImSDK_Plus.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Plus_iOS_Bitcode/ImSDK_Plus.framework/Headers/'}
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
