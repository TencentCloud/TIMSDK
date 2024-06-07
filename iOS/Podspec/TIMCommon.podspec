Pod::Spec.new do |spec|
  spec.name         = 'TIMCommon'
  spec.version      = '8.0.5895'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.0.5895/ios/TIMCommon.zip?time=6'}

  spec.subspec 'CommonModel' do |commonModel|
        commonModel.source_files = '**/TIMCommon/CommonModel/*.{h,m,mm}'
        commonModel.dependency 'TXIMSDK_Plus_iOS_XCFramework'
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
       uiClassic.resource = ['**/TIMCommon/Resources/*.bundle']
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
       uiMinimalist.source_files = '**/TIMCommon/UI_Minimalist/*.{h,m,mm}'
       uiMinimalist.dependency "TIMCommon/BaseCell"
       uiMinimalist.resource = ['**/TIMCommon/Resources/*.bundle']
  end
  
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  spec.user_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TIMCommon/Resources/PrivacyInfo.xcprivacy'
  }
end

# pod trunk push TUICore.podspec --use-libraries --allow-warnings
