Pod::Spec.new do |spec|
  spec.name         = 'TIMPush'
  spec.version      = '7.7.5282'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2023 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TIMPush'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/7.7.5282/ios/TIMPush_7.7.5282.framework.zip'}

  #spec.dependency 'TXIMSDK_Plus_iOS'
  #spec.library = 'c++', 'resolv', 'sqlite3'
  spec.preserve_paths = 'TIMPush.framework'
  spec.public_header_files = 'Framework/TIMPush.framework/Headers/*.h'
  spec.source_files = '**/TIMPush.framework/Headers/*.h'
  spec.vendored_frameworks = '**/TIMPush.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TIMPush/Framework/TIMPush.framework/Headers/'}
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
end
