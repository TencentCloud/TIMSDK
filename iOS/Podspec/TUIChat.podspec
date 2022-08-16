Pod::Spec.new do |spec|
  spec.name         = 'TUIChat'
  spec.version      = '6.5.2816'
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

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/tuikit/6.5.2816/ios/TUIChat.zip'}
  spec.dependency 'TUICore','6.5.2816'

  spec.subspec 'Header' do |header|
      header.source_files = '**/TUIChat/Header/*.{h,m,mm}'
  end
  
  spec.subspec 'Common' do |common|
    common.source_files = '**/TUIChat/Common/*.{h,m,mm}'
  end

  spec.subspec 'VoiceConvert' do |voiceConvert|
    voiceConvert.vendored_libraries = '**/TUIChat/VoiceConvert/*.a'
    voiceConvert.source_files = '**/TUIChat/VoiceConvert/*.{h,m,mm}'
  end

  spec.subspec 'Cell' do |cell|
    cell.subspec 'CellData' do |cellData|
      cellData.subspec 'Base' do |base|
        base.source_files = '**/TUIChat/Cell/CellData/Base/*.{h,m,mm}'
        base.dependency 'TUIChat/VoiceConvert'
        base.dependency 'TUIChat/Common'
      end
      cellData.subspec 'Chat' do |chat|
        chat.source_files = '**/TUIChat/Cell/CellData/Chat/*.{h,m,mm}'
        chat.dependency 'TUIChat/Cell/CellData/Base'
      end
      cellData.subspec 'Custom' do |custom|
        custom.source_files = '**/TUIChat/Cell/CellData/Custom/*.{h,m,mm}'
        custom.dependency 'TUIChat/Cell/CellData/Chat'
      end
      cellData.subspec 'Reply' do |reply|
        reply.source_files = '**/TUIChat/Cell/CellData/Reply/*.{h,m,mm}'
        reply.dependency 'TUIChat/Cell/CellData/Chat'
      end
    end

    cell.subspec 'CellUI' do |cellUI|
      cellUI.subspec 'Base' do |base|
        base.source_files = '**/TUIChat/Cell/CellUI/Base/*.{h,m,mm}'
        base.dependency 'TUIChat/Cell/CellData'
      end
      cellUI.subspec 'Chat' do |chat|
        chat.source_files = '**/TUIChat/Cell/CellUI/Chat/*.{h,m,mm}'
        chat.dependency 'TUIChat/Cell/CellUI/Base'
      end
      cellUI.subspec 'Custom' do |custom|
        custom.source_files = '**/TUIChat/Cell/CellUI/Custom/*.{h,m,mm}'
        custom.dependency 'TUIChat/Cell/CellUI/Chat'
      end
      cellUI.subspec 'Reply' do |reply|
        reply.source_files = '**/TUIChat/Cell/CellUI/Reply/*.{h,m,mm}'
        reply.dependency 'TUIChat/Cell/CellUI/Chat'
      end
    end
  end

  spec.subspec 'DataProvider' do |dataProvider|
    dataProvider.source_files = '**/TUIChat/DataProvider/*.{h,m,mm}'
    dataProvider.dependency 'TUIChat/Cell'
  end

  spec.subspec 'UI' do |ui|
    ui.subspec 'Base' do |base|
      base.subspec 'Camera' do |camera|
        camera.source_files = '**/TUIChat/UI/Base/Camera/*.{h,m,mm}'
        camera.dependency 'TUIChat/DataProvider'
      end
      base.subspec 'Media' do |media|
        media.source_files = '**/TUIChat/UI/Base/Media/*.{h,m,mm}'
        media.dependency 'TUIChat/UI/Base/Camera'
      end
      base.subspec 'Pop' do |pop|
        pop.source_files = '**/TUIChat/UI/Base/Pop/*.{h,m,mm}'
        pop.dependency 'TUIChat/DataProvider'
      end
    end
    ui.subspec 'Forward' do |forward|
      forward.source_files = '**/TUIChat/UI/Forward/*.{h,m,mm}'
      forward.dependency 'TUIChat/UI/Base'
      forward.dependency 'TUIChat/UI/Input'
    end
    ui.subspec 'Input' do |input|
      input.source_files = '**/TUIChat/UI/Input/*.{h,m,mm}'
      input.dependency 'TUIChat/UI/Base'
    end
    ui.subspec 'Pendency' do |pendency|
      pendency.source_files = '**/TUIChat/UI/Pendency/*.{h,m,mm}'
      pendency.dependency 'TUIChat/UI/Base'
    end
    ui.subspec 'Chat' do |chat|
      chat.source_files = '**/TUIChat/UI/Chat/*.{h,m,mm}'
      chat.dependency 'TUIChat/UI/Forward'
      chat.dependency 'TUIChat/UI/Input'
      chat.dependency 'TUIChat/UI/Pendency'
    end
  end

  spec.subspec 'Service' do |service|
    service.source_files = '**/TUIChat/Service/*.{h,m,mm}'
    service.dependency 'TUIChat/UI'
  end
  
  spec.resource = [
  '**/TUIChat/Resources/*.bundle'
  ]

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

# pod trunk push TUIChat.podspec --use-libraries --allow-warnings
