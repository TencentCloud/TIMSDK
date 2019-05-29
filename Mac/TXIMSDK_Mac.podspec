Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Mac'
  spec.version      = '4.3.135'
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

  spec.source = { :git => 'https://github.com/tencentyun/TIMSDK.git', :tag => spec.version}
  spec.preserve_paths = 'Mac/ImSDKForMac.framework'
  spec.source_files = 'Mac/ImSDKForMac.framework/Versions/A/Headers/*.h'
  spec.public_header_files = 'Mac/ImSDKForMac.framework/Versions/A/Headers/*.h'
  spec.vendored_frameworks = 'Mac/ImSDKForMac.framework'
   spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Mac/Mac/ImSDKForMac.framework/Versions/A/Headers/'}
end