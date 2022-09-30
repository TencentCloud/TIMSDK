Pod::Spec.new do |spec|
  spec.name         = 'TUIContact'
  spec.version      = '6.7.3184'
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
  spec.summary      = 'TUIContact'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/6.7.3184/ios/TUIContact.zip'}
  
  spec.subspec 'Header' do |header|
      header.source_files = '**/TUIContact/Header/*.{h,m,mm}'
  end
  
  spec.subspec 'Cell' do |cell|
    cell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIContact/Cell/CellData/*.{h,m,mm}'
      cellData.dependency 'TUICore','6.7.3184'
    end

    cell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIContact/Cell/CellUI/*.{h,m,mm}'
      cellUI.dependency 'TUIContact/Cell/CellData'
    end
  end

  spec.subspec 'DataProvider' do |dataProvider|
    dataProvider.source_files = '**/TUIContact/DataProvider/*.{h,m,mm}'
    dataProvider.dependency 'TUIContact/Cell'
  end

  spec.subspec 'UI' do |ui|
    ui.source_files = '**/TUIContact/UI/*.{h,m,mm}'
    ui.dependency 'TUIContact/DataProvider'
  end

  spec.subspec 'Service' do |service|
    service.source_files = '**/TUIContact/Service/*.{h,m,mm}'
    service.dependency 'TUIContact/UI'
  end
  
  spec.resource = [
      '**/TUIContact/Resources/*.bundle'
  ]

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TUIContact.podspec --use-libraries --allow-warnings
