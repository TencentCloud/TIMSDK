Pod::Spec.new do |spec|
  spec.name         = 'TUIConversation'
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
  spec.summary      = 'TUIConversation'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true
  
  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.0.5895/ios/TUIConversation.zip?time=3'}

  spec.default_subspec = 'ALL'

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIConversation/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TXIMSDK_Plus_iOS_XCFramework'
    commonModel.dependency 'TUICore'
    commonModel.dependency 'TIMCommon','~> 8.0.5895'
    commonModel.dependency 'ReactiveObjC'
    commonModel.dependency 'Masonry'
  end

  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIConversation/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency "TUIConversation/CommonModel"
    end
    baseCell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIConversation/BaseCell/CellUI/*.{h,m,mm}'
      cellUI.dependency "TUIConversation/BaseCell/CellData"
    end
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
    baseDataProvider.source_files = '**/TUIConversation/BaseDataProvider/*.{h,m,mm}'
    baseDataProvider.dependency "TUIConversation/BaseCell"
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIConversation/UI_Classic/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIConversation/BaseDataProvider"
    end
    uiClassic.subspec 'UI' do |ui|
      ui.source_files = '**/TUIConversation/UI_Classic/UI/*.{h,m,mm}'
      ui.dependency "TUIConversation/UI_Classic/DataProvider"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUIConversation/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUIConversation/UI_Classic/UI"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUIConversation/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUIConversation/UI_Classic/Service"
    end
    uiClassic.resource = ['**/TUIConversation/Resources/*.bundle']
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
      cell.subspec 'CellData' do |cellData|
        cellData.source_files = '**/TUIConversation/UI_Minimalist/Cell/CellData/*.{h,m,mm}'
        cellData.dependency "TUIConversation/BaseDataProvider"
      end
      cell.subspec 'CellUI' do |cellUI|
        cellUI.source_files = '**/TUIConversation/UI_Minimalist/Cell/CellUI/*.{h,m,mm}'
        cellUI.dependency "TUIConversation/UI_Minimalist/Cell/CellData"
      end
    end
    uiMinimalist.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIConversation/UI_Minimalist/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIConversation/UI_Minimalist/Cell"
    end
    uiMinimalist.subspec 'UI' do |ui|
      ui.source_files = '**/TUIConversation/UI_Minimalist/UI/*.{h,m,mm}'
      ui.dependency "TUIConversation/UI_Minimalist/DataProvider"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUIConversation/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUIConversation/UI_Minimalist/UI"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUIConversation/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUIConversation/UI_Minimalist/Service"
    end
    uiMinimalist.resource = ['**/TUIConversation/Resources/*.bundle']
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIConversation/UI_Classic"
    all.dependency "TUIConversation/UI_Minimalist"
  end

  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIConversation/Resources/PrivacyInfo.xcprivacy'
  }
  
end

# pod trunk push TUIConversation.podspec --use-libraries --allow-warnings
