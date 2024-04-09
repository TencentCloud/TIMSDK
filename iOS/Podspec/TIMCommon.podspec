Pod::Spec.new do |spec|
  spec.name         = 'TIMCommon'
  spec.version      = '7.9.5666'
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
  spec.summary      = 'TIMCommon'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.9.5666/ios/TIMCommon.zip?time=6'}

  spec.subspec 'CommonModel' do |commonModel|
        commonModel.source_files = '**/TIMCommon/CommonModel/*.{h,m,mm}'
        commonModel.dependency 'TXIMSDK_Plus_iOS'
        commonModel.dependency 'TUICore'
        commonModel.dependency 'ReactiveObjC'
        commonModel.dependency 'SDWebImage'
        commonModel.dependency 'Masonry'
  end
  
  spec.subspec 'BaseCellData' do |baseCellData|
       baseCellData.source_files = '**/TIMCommon/BaseCellData/*.{h,m,mm}'
       baseCellData.dependency "TIMCommon/CommonModel"
  end
  
  spec.subspec 'BaseCell' do |baseCell|
       baseCell.source_files = '**/TIMCommon/BaseCell/*.{h,m,mm}'
       baseCell.dependency "TIMCommon/BaseCellData"
  end
  
  spec.subspec 'UI_Classic' do |uiClassic|
       uiClassic.source_files = '**/TIMCommon/UI_Classic/*.{h,m,mm}'
       uiClassic.dependency "TIMCommon/BaseCell"
       uiClassic.resource = [
          '**/TIMCommon/Resources/*.bundle',
          '**/TIMCommon/Resources/PrivacyInfo.xcprivacy'
       ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
       uiMinimalist.source_files = '**/TIMCommon/UI_Minimalist/*.{h,m,mm}'
       uiMinimalist.dependency "TIMCommon/BaseCell"
       uiMinimalist.resource = [
        '**/TIMCommon/Resources/*.bundle',
        '**/TIMCommon/Resources/PrivacyInfo.xcprivacy'
       ]
  end
  
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'DEFINES_MODULE' => 'YES'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'DEFINES_MODULE' => 'YES'
  }
end

# pod trunk push TUICore.podspec --use-libraries --allow-warnings
