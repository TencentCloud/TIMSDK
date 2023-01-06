Pod::Spec.new do |spec|
  spec.name         = 'TUIChat'
  spec.version      = '7.0.3754'
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
  spec.summary      = 'TUIChat'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/7.0.3754/ios/TUIChat.zip?time=2'}

  spec.default_subspec = 'ALL'

  spec.subspec 'VoiceConvert' do |voiceConvert|
    voiceConvert.vendored_libraries = '**/TUIChat/VoiceConvert/*.a'
    voiceConvert.source_files = '**/TUIChat/VoiceConvert/*.{h,m,mm}'
  end

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIChat/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TUICore','7.0.3754'
    commonModel.dependency "TUIChat/VoiceConvert"
  end

  spec.subspec 'BaseCell' do |baseCell|
    baseCell.subspec 'CellData' do |cellData|
      cellData.source_files = '**/TUIChat/BaseCell/CellData/*.{h,m,mm}'
      cellData.dependency "TUIChat/CommonModel"
    end
    baseCell.subspec 'CellUI' do |cellUI|
      cellUI.source_files = '**/TUIChat/BaseCell/CellUI/*.{h,m,mm}'
      cellUI.dependency "TUIChat/BaseCell/CellData"
    end
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
    baseDataProvider.source_files = '**/TUIChat/BaseDataProvider/*.{h,m,mm}'
    baseDataProvider.dependency "TUIChat/BaseCell"
  end

  spec.subspec 'CommonUI' do |commonUI|
    commonUI.subspec 'Camera' do |camera|
      camera.source_files = '**/TUIChat/CommonUI/Camera/*.{h,m,mm}'
      camera.dependency "TUIChat/BaseDataProvider"
    end
    commonUI.subspec 'Pendency' do |pendency|
      pendency.source_files = '**/TUIChat/CommonUI/Pendency/*.{h,m,mm}'
      pendency.dependency "TUIChat/BaseDataProvider"
    end
    commonUI.subspec 'Pop' do |pop|
      pop.source_files = '**/TUIChat/CommonUI/Pop/*.{h,m,mm}'
      pop.dependency "TUIChat/BaseDataProvider"
    end
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'Cell' do |cell|
      cell.subspec 'CellData' do |cellData|
        cellData.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Classic/Cell/CellData/Base/*.{h,m,mm}'
          base.dependency "TUIChat/CommonUI"
        end
        cellData.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Classic/Cell/CellData/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Classic/Cell/CellData/Base"
        end
        cellData.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Classic/Cell/CellData/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Classic/Cell/CellData/Chat"
        end
        cellData.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Classic/Cell/CellData/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Classic/Cell/CellData/Custom"
        end
      end
      cell.subspec 'CellUI' do |cellUI|
        cellUI.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Classic/Cell/CellUI/Base/*.{h,m,mm}'
          base.dependency "TUIChat/UI_Classic/Cell/CellData"
        end
        cellUI.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Classic/Cell/CellUI/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Classic/Cell/CellUI/Base"
        end
        cellUI.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Classic/Cell/CellUI/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Classic/Cell/CellUI/Chat"
        end
        cellUI.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Classic/Cell/CellUI/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Classic/Cell/CellUI/Custom"
        end
      end
    end
    uiClassic.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIChat/UI_Classic/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIChat/UI_Classic/Cell"
    end
    uiClassic.subspec 'Input' do |input|
      input.source_files = '**/TUIChat/UI_Classic/Input/*.{h,m,mm}'
      input.dependency "TUIChat/UI_Classic/DataProvider"
    end
    uiClassic.subspec 'Chat' do |chat|
      chat.source_files = '**/TUIChat/UI_Classic/Chat/*.{h,m,mm}'
      chat.dependency "TUIChat/UI_Classic/Input"
    end
    uiClassic.subspec 'Service' do |service|
      service.source_files = '**/TUIChat/UI_Classic/Service/*.{h,m,mm}'
      service.dependency "TUIChat/UI_Classic/Chat"
    end
    uiClassic.subspec 'Header' do |header|
      header.source_files = '**/TUIChat/UI_Classic/Header/*.{h,m,mm}'
      header.dependency "TUIChat/UI_Classic/Service"
    end
    uiClassic.resource = [
      '**/TUIChat/Resources/*.bundle'
    ]
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
      cell.subspec 'CellData' do |cellData|
        cellData.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Minimalist/Cell/CellData/Base/*.{h,m,mm}'
          base.dependency "TUIChat/CommonUI"
        end
        cellData.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Minimalist/Cell/CellData/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Minimalist/Cell/CellData/Base"
        end
        cellData.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Minimalist/Cell/CellData/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Minimalist/Cell/CellData/Chat"
        end
        cellData.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Minimalist/Cell/CellData/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Minimalist/Cell/CellData/Custom"
        end
      end
      cell.subspec 'CellUI' do |cellUI|
        cellUI.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Minimalist/Cell/CellUI/Base/*.{h,m,mm}'
          base.dependency "TUIChat/UI_Minimalist/Cell/CellData"
        end
        cellUI.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Minimalist/Cell/CellUI/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Minimalist/Cell/CellUI/Base"
        end
        cellUI.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Minimalist/Cell/CellUI/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Minimalist/Cell/CellUI/Chat"
        end
        cellUI.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Minimalist/Cell/CellUI/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Minimalist/Cell/CellUI/Custom"
        end
      end
    end
    uiMinimalist.subspec 'DataProvider' do |dataProvider|
      dataProvider.source_files = '**/TUIChat/UI_Minimalist/DataProvider/*.{h,m,mm}'
      dataProvider.dependency "TUIChat/UI_Minimalist/Cell"
    end
    uiMinimalist.subspec 'Input' do |input|
      input.source_files = '**/TUIChat/UI_Minimalist/Input/*.{h,m,mm}'
      input.dependency "TUIChat/UI_Minimalist/DataProvider"
    end
    uiMinimalist.subspec 'Chat' do |chat|
      chat.source_files = '**/TUIChat/UI_Minimalist/Chat/*.{h,m,mm}'
      chat.dependency "TUIChat/UI_Minimalist/Input"
    end
    uiMinimalist.subspec 'Service' do |service|
      service.source_files = '**/TUIChat/UI_Minimalist/Service/*.{h,m,mm}'
      service.dependency "TUIChat/UI_Minimalist/Chat"
    end
    uiMinimalist.subspec 'Header' do |header|
      header.source_files = '**/TUIChat/UI_Minimalist/Header/*.{h,m,mm}'
      header.dependency "TUIChat/UI_Minimalist/Service"
    end
    uiMinimalist.resource = [
      '**/TUIChat/Resources/*.bundle'
    ]
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIChat/UI_Classic"
    all.dependency "TUIChat/UI_Minimalist"
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

# pod trunk push TUIChat.podspec --use-libraries --allow-warnings
