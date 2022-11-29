Pod::Spec.new do |spec|
  spec.name         = 'TUIContact'
  spec.version      = '6.9.3557'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/6.9.3557/ios/TUIContact.zip'}

  spec.default_subspec = 'ALL'
  
  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIContact/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency 'TUICore','6.9.3557'
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

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'UI' do |ui|
      ui.source_files = '**/TUIContact/UI_Classic/UI/*.{h,m,mm}'
      ui.dependency "TUIContact/BaseDataProvider"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUIContact/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUIContact/UI_Classic/UI"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUIContact/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUIContact/UI_Classic/Service"
    end
    uiClassic.resource = [
      '**/TUIContact/Resources/*.bundle'
    ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'UI' do |ui|
      ui.source_files = '**/TUIContact/UI_Minimalist/UI/*.{h,m,mm}'
      ui.dependency "TUIContact/BaseDataProvider"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUIContact/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUIContact/UI_Minimalist/UI"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUIContact/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUIContact/UI_Minimalist/Service"
    end
    uiMinimalist.resource = [
      '**/TUIContact/Resources/*.bundle'
    ]
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIContact/UI_Classic"
    all.dependency "TUIContact/UI_Minimalist"
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

# pod trunk push TUIContact.podspec --use-libraries --allow-warnings
