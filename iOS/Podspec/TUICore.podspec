Pod::Spec.new do |spec|
  spec.name         = 'TUICore'
  spec.version      = '6.7.3187'
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
  spec.summary      = 'TUICore'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/6.7.3184/ios/TUICore.zip'}
  
  spec.default_subspec = 'ImSDK_Plus'

  spec.dependency 'ReactiveObjC'
  spec.dependency 'SDWebImage'
  
  spec.subspec 'ImSDK_Plus' do |ss|
      ss.dependency 'TXIMSDK_Plus_iOS','6.7.3184'
      ss.dependency 'TUICore/Base'
  end
  
  spec.subspec 'ImSDK_Scenario' do |ss|
      ss.dependency 'TXIMSDK_Customer_iOS','6.7.3186'
      ss.dependency 'TUICore/Base'
  end
  
  spec.subspec 'Base' do |ss|
      ss.source_files = '**/TUICore/*.{h,m,mm,c}'
      ss.resource = [
          '**/TUICore/Resources/*.bundle'
      ]
  end

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) ENABLE_SCENARIO_SDK'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) ENABLE_SCENARIO_SDK'
  }
end

# pod trunk push TUICore.podspec --use-libraries --allow-warnings
