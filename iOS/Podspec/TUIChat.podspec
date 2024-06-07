Pod::Spec.new do |spec|
  spec.name         = 'TUIChat'
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
  spec.summary      = 'TUIChat'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/8.0.5895/ios/TUIChat.zip?time=11'}

  spec.default_subspec = 'ALL'

  spec.subspec 'CommonModel' do |commonModel|
    commonModel.source_files = '**/TUIChat/CommonModel/*.{h,m,mm}'
    commonModel.dependency 'TXIMSDK_Plus_iOS_XCFramework'
    commonModel.dependency 'TUICore'
    commonModel.dependency 'TIMCommon','~> 8.0.5895'
    commonModel.dependency 'ReactiveObjC'
    commonModel.dependency 'SDWebImage'
    commonModel.dependency 'Masonry'
  end

  spec.subspec 'BaseCellData' do |baseCellData|
       baseCellData.subspec 'Base' do |base|
            base.source_files = '**/TUIChat/BaseCellData/Base/*.{h,m,mm}'
            base.dependency "TUIChat/CommonModel"
       end
      baseCellData.subspec 'Chat' do |chat|
            chat.source_files = '**/TUIChat/BaseCellData/Chat/*.{h,m,mm}'
            chat.dependency "TUIChat/BaseCellData/Base"
      end
      baseCellData.subspec 'Custom' do |custom|
            custom.source_files = '**/TUIChat/BaseCellData/Custom/*.{h,m,mm}'
            custom.dependency "TUIChat/BaseCellData/Chat"
      end
      baseCellData.subspec 'Reply' do |reply|
            reply.source_files = '**/TUIChat/BaseCellData/Reply/*.{h,m,mm}'
            reply.dependency "TUIChat/BaseCellData/Custom"
      end
  end
  
  spec.subspec 'BaseCell' do |baseCell|
      baseCell.source_files = '**/TUIChat/BaseCell/*.{h,m,mm}'
      baseCell.dependency "TUIChat/BaseCellData"
  end

  spec.subspec 'BaseDataProvider' do |baseDataProvider|
      baseDataProvider.subspec 'Base' do |base|
            base.source_files = '**/TUIChat/BaseDataProvider/Base/*.{h,m,mm}'
            base.dependency "TUIChat/BaseCellData"
      end
      baseDataProvider.subspec 'Impl' do |impl|
            impl.source_files = '**/TUIChat/BaseDataProvider/Impl/*.{h,m,mm}'
            impl.dependency "TUIChat/BaseCellData"
            impl.dependency "TUIChat/BaseDataProvider/Base"
      end
  end

  spec.subspec 'CommonUI' do |commonUI|
    commonUI.subspec 'Camera' do |camera|
      camera.source_files = '**/TUIChat/CommonUI/Camera/*.{h,m,mm}'
      camera.dependency "TUIChat/BaseDataProvider"
      camera.dependency "TUIChat/BaseCell"
    end
    commonUI.subspec 'Pendency' do |pendency|
      pendency.source_files = '**/TUIChat/CommonUI/Pendency/*.{h,m,mm}'
      pendency.dependency "TUIChat/BaseDataProvider"
      pendency.dependency "TUIChat/BaseCell"
    end
    commonUI.subspec 'Pop' do |pop|
      pop.source_files = '**/TUIChat/CommonUI/Pop/*.{h,m,mm}'
      pop.dependency "TUIChat/BaseDataProvider"
      pop.dependency "TUIChat/BaseCell"
    end
  end

  spec.subspec 'UI_Classic' do |uiClassic|
    uiClassic.subspec 'Cell' do |cell|
        cell.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Classic/Cell/Base/*.{h,m,mm}'
          base.dependency "TUIChat/CommonUI"
        end
        cell.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Classic/Cell/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Classic/Cell/Base"
        end
        cell.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Classic/Cell/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Classic/Cell/Chat"
        end
        cell.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Classic/Cell/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Classic/Cell/Custom"
        end
    end
    uiClassic.subspec 'Input' do |input|
      input.source_files = '**/TUIChat/UI_Classic/Input/*.{h,m,mm}'
      input.dependency "TUIChat/UI_Classic/Cell"
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
    uiClassic.resource = ['**/TUIChat/Resources/*.bundle']
  end

  spec.subspec 'UI_Minimalist' do |uiMinimalist|
    uiMinimalist.subspec 'Cell' do |cell|
        cell.subspec 'Base' do |base|
          base.source_files = '**/TUIChat/UI_Minimalist/Cell/Base/*.{h,m,mm}'
          base.dependency "TUIChat/CommonUI"
        end
        cell.subspec 'Chat' do |chat|
          chat.source_files = '**/TUIChat/UI_Minimalist/Cell/Chat/*.{h,m,mm}'
          chat.dependency "TUIChat/UI_Minimalist/Cell/Base"
        end
        cell.subspec 'Custom' do |custom|
          custom.source_files = '**/TUIChat/UI_Minimalist/Cell/Custom/*.{h,m,mm}'
          custom.dependency "TUIChat/UI_Minimalist/Cell/Chat"
        end
        cell.subspec 'Reply' do |reply|
          reply.source_files = '**/TUIChat/UI_Minimalist/Cell/Reply/*.{h,m,mm}'
          reply.dependency "TUIChat/UI_Minimalist/Cell/Custom"
        end
    end
    uiMinimalist.subspec 'Input' do |input|
      input.source_files = '**/TUIChat/UI_Minimalist/Input/*.{h,m,mm}'
      input.dependency "TUIChat/UI_Minimalist/Cell"
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
    uiMinimalist.resource = ['**/TUIChat/Resources/*.bundle']
  end

  spec.subspec 'ALL' do |all|
    all.dependency "TUIChat/UI_Classic"
    all.dependency "TUIChat/UI_Minimalist"
  end

  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/TUIChat/Resources/PrivacyInfo.xcprivacy'
  }
end

# pod trunk push TUIChat.podspec --use-libraries --allow-warnings
