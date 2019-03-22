Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_TUIKit_iOS'
  spec.version      = '4.2.2'
  spec.platform     = :ios 
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXIMSDK_TUIKit_iOS'
  
  spec.requires_arc = true

  spec.source = { :git => 'https://github.com/tencentyun/TIMSDK.git', :tag => spec.version}
  spec.preserve_paths = 'iOS/TUIKit.framework'
  spec.source_files = 'iOS/TUIKit.framework/Headers/*.h'
  spec.public_header_files = 'iOS/TUIKit.framework/Headers/*.h'
  spec.vendored_frameworks = 'iOS/TUIKit.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_TUIKit_iOS/iOS/TUIKit.framework/Headers/'}
  spec.resource = ['iOS/TUIKit.framework/TUIKitFace.bundle','iOS/TUIKit.framework/TUIKitResource.bundle','iOS/TUIKit.framework/emoji.plist']
end