Pod::Spec.new do |spec|
  spec.name         = 'TUIGroup'
  spec.version      = '7.3.4358'
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
  spec.summary      = 'TUIGroup'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.3.4358/ios/TUIGroup.zip?time=2'}

  spec.default_subspec = 'ALL'

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIGroup/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TXIMSDK_Plus_iOS','7.3.4358'
    commonModel.dependency 'TUICore','7.3.4358'
    commonModel.dependency 'TIMCommon','7.3.4358'
    commonModel.dependency 'ReactiveObjC'
  end

  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIGroup/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency "TUIGroup/CommonModel"
    end
    baseCell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIGroup/BaseCell/CellUI/*.{h,m,mm}'
      cellUI.dependency "TUIGroup/BaseCell/CellData"
    end
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
    baseDataProvider.source_files = '**/TUIGroup/BaseDataProvider/*.{h,m,mm}'
    baseDataProvider.dependency "TUIGroup/BaseCell"
  end

  spec.subspec 'CommonUI' do |commonUI|
    commonUI.source_files = '**/TUIGroup/CommonUI/*.{h,m,mm}'
    commonUI.dependency "TUIGroup/BaseDataProvider"
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'UI' do |ui|
      ui.source_files = '**/TUIGroup/UI_Classic/UI/*.{h,m,mm}'
      ui.dependency "TUIGroup/CommonUI"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUIGroup/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUIGroup/UI_Classic/UI"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUIGroup/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUIGroup/UI_Classic/Service"
    end
    uiClassic.resource = [
      '**/TUIGroup/Resources/*.bundle'
    ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
        cell.subspec 'CellData' do |cellData|
        cellData.source_files = '**/TUIGroup/UI_Minimalist/Cell/CellData/*.{h,m,mm}'
        cellData.dependency "TUIGroup/CommonUI"
        end
        cell.subspec 'CellUI' do |cellUI|
        cellUI.source_files = '**/TUIGroup/UI_Minimalist/Cell/CellUI/*.{h,m,mm}'
        cellUI.dependency "TUIGroup/UI_Minimalist/Cell/CellData"
        end
    end
    uiMinimalist.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIGroup/UI_Minimalist/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIGroup/UI_Minimalist/Cell"
    end
    uiMinimalist.subspec 'UI' do |ui|
      ui.source_files = '**/TUIGroup/UI_Minimalist/UI/*.{h,m,mm}'
      ui.dependency "TUIGroup/UI_Minimalist/DataProvider"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUIGroup/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUIGroup/UI_Minimalist/UI"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUIGroup/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUIGroup/UI_Minimalist/Service"
    end
    uiMinimalist.resource = [
      '**/TUIGroup/Resources/*.bundle'
    ]
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIGroup/UI_Classic"
    all.dependency "TUIGroup/UI_Minimalist"
  end

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  spec.user_target_xcconfig = {
   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
   'GENERATE_INFOPLIST_FILE' => 'YES'
  }
end

# pod trunk push TUIGroup.podspec --use-libraries --allow-warnings
