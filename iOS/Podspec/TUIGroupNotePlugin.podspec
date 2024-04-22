Pod::Spec.new do |spec|
  spec.name         = 'TUIGroupNotePlugin'
  spec.version      = '7.9.5666'
  spec.platform     = :ios 
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
      }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIGroupNotePlugin'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/7.9.5666/ios/TUIGroupNotePlugin_7.9.5666.framework.zip'}
  spec.preserve_paths = 'TUIGroupNotePlugin.framework'
  spec.vendored_frameworks = 'TUIGroupNotePlugin.framework'
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  } 
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIGroupNotePlugin.framework/PrivacyInfo.xcprivacy'
  }
end

# pod trunk push TUIGroupNotePlugin.podspec --use-libraries --allow-warnings