Pod::Spec.new do |spec|
  spec.name         = 'TUISearch'
  spec.version      = '5.9.1886'
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
  spec.summary      = 'TUISearch'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/tuikit/5.9.1886/ios/TUISearch.zip'}

  spec.subspec 'Cell' do |cell|
    cell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUISearch/Cell/CellData/*.{h,m,mm}'
      cellData.dependency 'TUICore','5.9.1886'
    end

    cell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUISearch/Cell/CellUI/*.{h,m,mm}'
      cellUI.dependency 'TUISearch/Cell/CellData'
    end
  end

  spec.subspec 'DataProvider' do |dataProvider|
    dataProvider.source_files = '**/TUISearch/DataProvider/*.{h,m,mm}'
    dataProvider.dependency 'TUISearch/Cell'
  end

  spec.subspec 'UI' do |ui|
    ui.source_files = '**/TUISearch/UI/*.{h,m,mm}'
    ui.dependency 'TUISearch/DataProvider'
  end

  spec.subspec 'Service' do |service|
    service.source_files = '**/TUISearch/Service/*.{h,m,mm}'
    service.dependency 'TUISearch/UI'
  end
  
  spec.resource = [
      '**/TUISearch/Resources/*.bundle'
  ]

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TUISearch.podspec --use-libraries --allow-warnings
