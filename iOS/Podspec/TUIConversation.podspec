Pod::Spec.new do |spec|
  spec.name         = 'TUIConversation'
  spec.version      = '6.1.2155'
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
  spec.summary      = 'TUIConversation'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/6.1.2155/ios/TUIConversation.zip'}

  spec.subspec 'Cell' do |cell|
    cell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIConversation/Cell/CellData/*.{h,m,mm}'
      cellData.dependency 'TUICore','6.1.2155'
    end

    cell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIConversation/Cell/CellUI/*.{h,m,mm}'
      cellUI.dependency 'TUIConversation/Cell/CellData'
    end
  end

  spec.subspec 'DataProvider' do |dataProvider|
    dataProvider.source_files = '**/TUIConversation/DataProvider/*.{h,m,mm}'
    dataProvider.dependency 'TUIConversation/Cell'
  end

  spec.subspec 'UI' do |ui|
    ui.source_files = '**/TUIConversation/UI/*.{h,m,mm}'
    ui.dependency 'TUIConversation/DataProvider'
  end

  spec.subspec 'Service' do |service|
    service.source_files = '**/TUIConversation/Service/*.{h,m,mm}'
    service.dependency 'TUIConversation/UI'
  end
  
  spec.resource = [
      '**/TUIConversation/Resources/*.bundle'
  ]

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TUIConversation.podspec --use-libraries --allow-warnings
