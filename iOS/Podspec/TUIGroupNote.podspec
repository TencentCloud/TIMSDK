
Pod::Spec.new do |spec|
    spec.name         = 'TUIGroupNote'
    spec.version      = '7.1.3925'
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
    spec.summary      = 'TUIGroupNote'
    
    spec.requires_arc = true
  
    spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/7.1.3925/ios/TUIGroupNote.framework.zip'}
    spec.preserve_paths = 'TUIGroupNote.framework'
    spec.vendored_frameworks = 'TUIGroupNote.framework'
    spec.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
    spec.user_target_xcconfig = { 
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    } 
  end