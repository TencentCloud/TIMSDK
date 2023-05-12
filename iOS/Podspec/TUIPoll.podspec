
Pod::Spec.new do |spec|
    spec.name         = 'TUIPoll'
    spec.version      = '7.2.4146'
    spec.platform     = :ios 
    spec.ios.deployment_target = '9.0'
    spec.license      = { :type => 'Proprietary',
        :text => <<-LICENSE
          copyright 2017 tencent Ltd. All rights reserved.
          LICENSE
         }
    spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
    spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
    spec.authors      = 'tencent video cloud'
    spec.summary      = 'TUIPoll'
    
    spec.requires_arc = true
  
    spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/7.2.4146/ios/TUIPoll.framework.zip'}
    spec.preserve_paths = 'TUIPoll.framework'
    spec.vendored_frameworks = 'TUIPoll.framework'
    spec.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
    spec.user_target_xcconfig = { 
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    } 
  end
