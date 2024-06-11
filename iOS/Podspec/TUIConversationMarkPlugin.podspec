Pod::Spec.new do |spec|
    spec.name         = 'TUIConversationMarkPlugin'
    spec.version      = '8.0.5895'
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
    spec.summary      = 'TUIConversationMarkPlugin'
    
    spec.requires_arc = true
  
    spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuiplugin/8.0.5895/ios/TUIConversationMarkPlugin_8.0.5895.xcframework.zip'}

    spec.vendored_frameworks = 'TUIConversationMarkPlugin.xcframework'
    spec.resource_bundle = {
      "#{spec.module_name}_Privacy" => '**/TUIConversationMarkPlugin.xcframework/ios-arm64/TUIConversationMarkPlugin.framework/PrivacyInfo.xcprivacy'
    }

end

# pod trunk push TUIConversationMarkPlugin.podspec --use-libraries --allow-warnings
