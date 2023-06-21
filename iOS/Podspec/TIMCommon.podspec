Pod::Spec.new do |spec|
  spec.name         = 'TIMCommon'
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
  spec.summary      = 'TUICore'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.3.4358/ios/TIMCommon.zip?time=2'}

  spec.subspec 'CommonModel' do |commonModel|
        commonModel.source_files = '**/TIMCommon/CommonModel/*.{h,m,mm}'
        commonModel.dependency 'TXIMSDK_Plus_iOS','7.3.4358'
        commonModel.dependency 'TUICore','7.3.4358'
        #commonModel.dependency 'TUICore', :path => 'TUICore'
        commonModel.dependency 'ReactiveObjC'
        commonModel.dependency 'SDWebImage'
  end
  
  spec.subspec 'BaseCell' do |baseCell|
        baseCell.subspec 'CellData' do |cellData|
            cellData.source_files = '**/TIMCommon/BaseCell/CellData/*.{h,m,mm}'
            cellData.dependency "TIMCommon/CommonModel"
        end
        baseCell.subspec 'CellUI' do |cellUI|
            cellUI.source_files = '**/TIMCommon/BaseCell/CellUI/*.{h,m,mm}'
            cellUI.dependency "TIMCommon/BaseCell/CellData"
        end
  end
  
  spec.subspec 'UI_Classic' do |uiClassic|
      uiClassic.subspec 'Cell' do |cell|
         cell.subspec 'CellData' do |cellData|
           cellData.source_files = '**/TIMCommon/UI_Classic/Cell/CellData/*.{h,m,mm}'
           cellData.dependency "TIMCommon/BaseCell"
         end
         cell.subspec 'CellUI' do |cellUI|
            cellUI.source_files = '**/TIMCommon/UI_Classic/Cell/CellUI/*.{h,m,mm}'
            cellUI.dependency "TIMCommon/UI_Classic/Cell/CellData"
         end
      end
     uiClassic.resource = [
         '**/TIMCommon/Resources/*.bundle'
      ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
      cell.subspec 'CellData' do |cellData|
         cellData.source_files = '**/TIMCommon/UI_Minimalist/Cell/CellData/*.{h,m,mm}'
         cellData.dependency "TIMCommon/BaseCell"
      end
      cell.subspec 'CellUI' do |cellUI|
         cellUI.source_files = '**/TIMCommon/UI_Minimalist/Cell/CellUI/*.{h,m,mm}'
         cellUI.dependency "TIMCommon/UI_Minimalist/Cell/CellData"
      end
    end
    uiMinimalist.resource = [
      '**/TIMCommon/Resources/*.bundle'
    ]
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

# pod trunk push TUICore.podspec --use-libraries --allow-warnings
