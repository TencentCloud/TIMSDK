Pod::Spec.new do |spec|
  spec.name         = 'TUISearch'
  spec.version      = '7.2.4146'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.2.4146/ios/TUISearch.zip?time=2'}

  spec.default_subspec = 'ALL'

  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUISearch/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency 'TXIMSDK_Plus_iOS','7.2.4146'
      cellData.dependency 'TUICore','7.2.4146'
      cellData.dependency 'TIMCommon','7.2.4146'
    end
    baseCell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUISearch/BaseCell/CellUI/*.{h,m,mm}'
      cellUI.dependency "TUISearch/BaseCell/CellData"
    end
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
    baseDataProvider.source_files = '**/TUISearch/BaseDataProvider/*.{h,m,mm}'
    baseDataProvider.dependency "TUISearch/BaseCell"
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'UI' do |ui|
      ui.source_files = '**/TUISearch/UI_Classic/UI/*.{h,m,mm}'
      ui.dependency "TUISearch/BaseDataProvider"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUISearch/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUISearch/UI_Classic/UI"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUISearch/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUISearch/UI_Classic/Service"
    end
    uiClassic.resource = [
      '**/TUISearch/Resources/*.bundle'
    ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
        cell.subspec 'CellUI' do |cellUI|
        cellUI.source_files = '**/TUISearch/UI_Minimalist/Cell/CellUI/*.{h,m,mm}'
        cellUI.dependency "TUISearch/BaseDataProvider"
        end
    end
    uiMinimalist.subspec 'UI' do |ui|
      ui.source_files = '**/TUISearch/UI_Minimalist/UI/*.{h,m,mm}'
      ui.dependency "TUISearch/UI_Minimalist/Cell"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUISearch/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUISearch/UI_Minimalist/UI"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUISearch/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUISearch/UI_Minimalist/Service"
    end
    uiMinimalist.resource = [
      '**/TUISearch/Resources/*.bundle'
    ]
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUISearch/UI_Classic"
    all.dependency "TUISearch/UI_Minimalist"
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

# pod trunk push TUISearch.podspec --use-libraries --allow-warnings
