Pod::Spec.new do |spec|
  spec.name         = 'TUIEmojiPlugin'
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
  spec.summary      = 'TUIEmojiPlugin'
  spec.dependency 'TUICore'
  spec.dependency 'TIMCommon'
  spec.dependency 'TUIChat'
  spec.requires_arc = true
  
  spec.source = { :git => './'}
  spec.source_files = '**/*.{h,m,mm,c}'
  spec.resource = ['Resources/*.bundle']
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'Resources/PrivacyInfo.xcprivacy'
  }
end
