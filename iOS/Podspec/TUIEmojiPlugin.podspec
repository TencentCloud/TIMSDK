Pod::Spec.new do |spec|
  spec.name         = 'TUIEmojiPlugin'
  spec.version      = '8.1.6103'
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
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.1.6103/ios/TUIEmojiPlugin.zip?time=4'}
  spec.default_subspec = 'CommonModel'

  spec.subspec 'CommonModel' do |ss|
    ss.source_files = '**/TUIEmojiPlugin/CommonModel/*.{h,m,mm}'
    ss.dependency 'TUICore'
    ss.dependency 'TIMCommon','~>8.1.6103'
    ss.dependency 'TUIChat','~>8.1.6103'
  end
  
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIEmojiPlugin/Resources/PrivacyInfo.xcprivacy'
  }
  
end

# pod trunk push TUIEmojiPlugin.podspec --use-libraries --allow-warnings
