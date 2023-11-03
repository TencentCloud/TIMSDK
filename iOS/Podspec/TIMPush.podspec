Pod::Spec.new do |spec|
  spec.name         = 'TIMPush'
  spec.version      = '7.6.5011'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/7.6.5011/ios/TIMPush_7.6.5011.framework.zip'}

  #spec.dependency 'TXIMSDK_Plus_iOS'
  #spec.library = 'c++', 'resolv', 'sqlite3'
  
  spec.preserve_paths = 'TIMPush.framework'
  spec.vendored_frameworks = 'TIMPush.framework'
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
end
