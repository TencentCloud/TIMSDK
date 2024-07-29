Pod::Spec.new do |spec|
  spec.name         = 'TUIContact'
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
  spec.summary      = 'TUIContact'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.1.6103/ios/TUIContact.zip?time=2'}

  spec.default_subspec = 'ALL'
  
  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIContact/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency 'TXIMSDK_Plus_iOS_XCFramework'
      cellData.dependency 'TUICore'
      cellData.dependency 'TIMCommon','~> 8.1.6103'
      cellData.dependency 'ReactiveObjC'
      cellData.dependency 'Masonry'
    end
    baseCell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIContact/BaseCell/CellUI/*.{h,m,mm}'
      cellUI.dependency "TUIContact/BaseCell/CellData"
    end
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
    baseDataProvider.source_files = '**/TUIContact/BaseDataProvider/*.{h,m,mm}'
    baseDataProvider.dependency "TUIContact/BaseCell"
  end
  
  spec.subspec 'CommonUI' do |commonUI|
     commonUI.source_files = '**/TUIContact/CommonUI/*.{h,m,mm}'
     commonUI.dependency "TUIContact/BaseDataProvider"
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'UI' do |ui|
      ui.source_files = '**/TUIContact/UI_Classic/UI/*.{h,m,mm}'
      ui.dependency "TUIContact/CommonUI"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUIContact/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUIContact/UI_Classic/UI"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUIContact/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUIContact/UI_Classic/Service"
    end
    uiClassic.resource = ['**/TUIContact/Resources/*.bundle']
  end
  
  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
        cell.subspec 'CellData' do |cellData|
        cellData.source_files = '**/TUIContact/UI_Minimalist/Cell/CellData/*.{h,m,mm}'
        cellData.dependency "TUIContact/CommonUI"
        end
        cell.subspec 'CellUI' do |cellUI|
        cellUI.source_files = '**/TUIContact/UI_Minimalist/Cell/CellUI/*.{h,m,mm}'
        cellUI.dependency "TUIContact/UI_Minimalist/Cell/CellData"
        end
    end
    uiMinimalist.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIContact/UI_Minimalist/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIContact/UI_Minimalist/Cell"
    end
    uiMinimalist.subspec 'UI' do |ui|
      ui.source_files = '**/TUIContact/UI_Minimalist/UI/*.{h,m,mm}'
      ui.dependency "TUIContact/UI_Minimalist/DataProvider"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUIContact/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUIContact/UI_Minimalist/UI"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUIContact/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUIContact/UI_Minimalist/Service"
    end
    uiMinimalist.resource = ['**/TUIContact/Resources/*.bundle']
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIContact/UI_Classic"
    all.dependency "TUIContact/UI_Minimalist"
  end

  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIContact/Resources/PrivacyInfo.xcprivacy'
  }
  
end

# pod trunk push TUIContact.podspec --use-libraries --allow-warnings
