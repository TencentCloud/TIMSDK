Pod::Spec.new do |spec|
  spec.name         = 'TUICore'
  spec.version      = '8.1.6103'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.source = { :git => './'}
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICore'
  spec.dependency 'SDWebImage'
  
  spec.requires_arc = true
  spec.default_subspec = 'ImSDK_Plus'
  
  spec.subspec 'ImSDK_Plus' do |plus|
      plus.dependency 'TXIMSDK_Plus_iOS'
      plus.dependency 'TUICore/Base'
  end
  
  spec.subspec 'Base' do |base|
      base.source_files = '*.{h,m,mm,c}'
      base.resource = ['Resources/*.bundle']
  end
  
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'Resources/PrivacyInfo.xcprivacy'
  }
  
end
