Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Mac'
  spec.version      = '4.6.58'
  spec.platform     = :osx  
  spec.osx.deployment_target = '10.10'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXIMSDK_Mac'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/4.6.58/TIM_SDK_Mac_latest_framework.zip'}
  spec.preserve_paths = '**/ImSDKForMac.framework'
  spec.source_files = '**/ImSDKForMac.framework/Versions/A/Headers/*.h'
  spec.public_header_files = '**/ImSDKForMac.framework/Versions/A/Headers/*.h'
  spec.vendored_frameworks = '**/ImSDKForMac.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Mac/ImSDKForMac.framework/Versions/A/Headers/'}
end

# export EXPANDED_CODE_SIGN_IDENTITY=""
# export EXPANDED_CODE_SIGN_IDENTITY_NAME=""
# export EXPANDED_PROVISIONING_PROFILE=""