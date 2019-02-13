Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_iOS'
  spec.version      = '4.0.1'
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

  spec.source = { :git => 'https://github.com/tencentyun/TIMSDK.git', :tag => spec.version}
  spec.preserve_paths = 'iOS/ImSDK.framework'
  spec.source_files = 'iOS/ImSDK.framework/Headers/*.h'
  spec.public_header_files = 'iOS/ImSDK.framework/Headers/*.h'
  spec.vendored_frameworks = 'iOS/ImSDK.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_iOS/iOS/ImSDK.framework/Headers/'}
end