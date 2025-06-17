import { ThemeManager } from 'basecomponent';
import { MessageInputState, MessageType, MessageInfo, MessageBody, Util } from 'chatengine';
import { MessageInputMoreDialog, MenuItem } from './pages/MessageInputMoreDialog';
import { EmojiPicker, EmojiItem } from 'emojipicker';
import { VoiceRecordingView, AudioRecorderManager } from 'audiorecorder';
import picker from '@ohos.file.picker';
import fileio from '@ohos.fileio';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import mediaLibrary from '@ohos.multimedia.media';
import { util } from '@kit.ArkTS';
import { common as commonKit } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { dataSharePredicates } from '@kit.ArkData';
import image from '@ohos.multimedia.image';
import { EmojiDataManager } from 'emojipicker';

/**
 * 消息输入栏组件
 */
@Component
export struct MessageInputBar {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 会话ID，用于创建 MessageInputState
  conversationID: string = '';
  // 消息发送回调，用于外部获取发送结果
  onSendMessage?: (text: string) => void;
  // 对话框控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: MessageInputMoreDialog({
      menuItems: [
        {
          id: 'image',
          text: $r('app.string.menu_image'),
          icon: $r('app.media.camera_action_icon'),
          action: () => {
            console.info('[MessageInputBar] 选择图片');
            this.selectImage();
          }
        },
        {
          id: 'photo',
          text: $r('app.string.menu_photo'),
          icon: $r('app.media.camera_action_icon'),
          action: () => {
            console.info('[MessageInputBar] 选择拍照');
            this.takePhoto();
          }
        },
        {
          id: 'video',
          text: $r('app.string.menu_video'),
          icon: $r('app.media.document_icon'),
          action: () => {
            console.info('[MessageInputBar] 选择录像');
            this.recordVideo();
          }
        },
        {
          id: 'file',
          text: $r('app.string.menu_file'),
          icon: $r('app.media.document_icon'),
          action: () => {
            console.info('[MessageInputBar] 选择文件');
            this.selectFile();
          }
        },
        {
          id: 'custom',
          text: $r('app.string.menu_custom'),
          icon: $r('app.media.custom_icon'),
          action: () => {
            console.info('[MessageInputBar] 选择自定义');
          }
        }
      ],
      onCancel: () => {
        console.info('[MessageInputBar] 对话框取消');
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -16 },
    customStyle: true,
    autoCancel: true
  });
  // 富文本编辑器控制器
  private richEditorController: RichEditorController = new RichEditorController();
  // 消息输入状态 (必须提供 conversationID)
  @State private inputState: MessageInputState | null = null;
  // 表情选择器显示状态
  @State private showEmojiPicker: boolean = false;
  // 上下文
  private context = getContext(this) as common.UIAbilityContext;
  // 输入框焦点状态
  @State private inputFocused: boolean = false;
  // 隐藏键盘用的辅助组件
  private hiddenButtonId: string = 'hiddenFocusButton';
  // 语音录制状态
  @State private isVoiceRecording: boolean = false;
  // 语音录制时长
  @State private recordingDuration: number = 0;
  // 语音录制管理器
  private audioRecorderManager: AudioRecorderManager = new AudioRecorderManager();

  aboutToAppear() {
    if (this.conversationID) {
      this.inputState = new MessageInputState(this.conversationID);
    } else {
      console.error('[MessageInputBar] No conversationID provided, input state will not be created');
    }

    this.audioRecorderManager.setContext(this.context)
    // 初始化语音录制管理器回调
    this.audioRecorderManager.setCallbacks({
      onDurationUpdate: (duration: number) => {
        this.recordingDuration = duration;
      },
      onRecordingStart: () => {
        this.isVoiceRecording = true;
      },
      onRecordingStop: (filePath: string, duration: number) => {
        this.isVoiceRecording = false;
        this.sendVoiceMessage(duration, filePath);
      },
      onRecordingCancel: () => {
        this.isVoiceRecording = false;
        this.recordingDuration = 0;
      }
    });
  }

  build() {
    Column() {
      // 消息输入栏
      if (this.isVoiceRecording) {
        // 语音录制模式 - 占据整个宽度
        Row() {
          VoiceRecordingView({
            recordingDuration: this.recordingDuration,
            onCancel: () => {
              this.audioRecorderManager.cancelRecording();
            },
            onSend: () => {
              this.audioRecorderManager.stopRecording();
            }
          })
            .layoutWeight(1)
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        // 正常输入模式
        Row() {
          // 添加按钮 (含有 + 号的按钮)
          Button() {
            Image($r('app.media.plus_icon'))
              .width(20)
              .height(20)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.themeManager.getCurrentTheme().bgColorOperate)
          .borderRadius(18)
          .onClick(() => {
            console.info('[MessageInputBar] 点击添加按钮');
            this.showEmojiPicker = false; // 关闭表情选择器
            this.hideKeyboard(); // 隐藏键盘
            this.dialogController.open();
          })

          // 输入框部分 (包含输入框和表情按钮)
          Stack() {
            // 底层：正常的输入框
            Row() {
              // 富文本输入框
              RichEditor({
                controller: this.richEditorController
              })
                .backgroundColor(this.themeManager.currentTheme.bgColorInput)
                .borderRadius(0)
                .layoutWeight(1)
                .constraintSize({
                  minHeight: 36,
                  maxHeight: 120
                })
                .padding({
                  left: 0,
                  right: 8,
                  top: 8,
                  bottom: 8
                })
                .focusable(true)
                .defaultFocus(this.inputFocused && !this.showEmojiPicker)
                .enterKeyType(EnterKeyType.Send)
                .placeholder($r('app.string.input_message_placeholder'), {
                  fontColor: this.themeManager.currentTheme.textColorTertiary,
                  font: {
                    size: 14,
                    weight: FontWeight.Normal,
                    family: "HarmonyOS Sans",
                    style: FontStyle.Normal
                  }
                })
                .onReady(() => {
                  console.info('[MessageInputBar] RichEditor 准备就绪');
                })
                .onFocus(() => {
                  console.info('[MessageInputBar] RichEditor 获得焦点');
                  this.inputFocused = true;
                  // 当输入框获得焦点时，关闭表情面板
                  if (this.showEmojiPicker) {
                    this.showEmojiPicker = false;
                  }
                })
                .onBlur(() => {
                  console.info('[MessageInputBar] RichEditor 失去焦点');
                  this.inputFocused = false;
                })
                .onClick(() => {
                  console.info('[MessageInputBar] 点击输入框');
                  // 点击输入框时，关闭表情面板，聚焦输入框
                  if (this.showEmojiPicker) {
                    this.showEmojiPicker = false;
                  }
                  // 设置焦点状态，触发重新渲染
                  this.inputFocused = true;
                })
                .onSubmit(() => {
                  console.info('[MessageInputBar] 用户点击发送按钮');
                  // 当用户点击键盘上的发送按钮时，发送消息
                  this.sendTextMessage();
                })
                .onIMEInputComplete((value: RichEditorTextSpanResult) => {
                  // 当用户输入文字时，设置文字颜色
                  if (value.value && value.value.length > 0) {
                    // 获取当前输入的文字范围
                    const selection = this.richEditorController.getSelection();
                    const start = selection.selection[0];
                    const end = selection.selection[1];

                    // 更新文字样式，设置颜色
                    this.richEditorController.updateSpanStyle({
                      start: start - value.value.length,
                      end: start,
                      textStyle: {
                        fontColor: this.themeManager.currentTheme.textColorPrimary
                      }
                    });
                  }
                })

              // 表情按钮
              Image(this.showEmojiPicker ? $r('app.media.keyboard_icon') : $r('app.media.emoji_icon'))
                .width(19)
                .height(19)
                .onClick(() => {
                  console.info('[MessageInputBar] 点击表情按钮');

                  if (this.showEmojiPicker) {
                    // 当前显示表情面板，点击后关闭表情面板，显示键盘
                    this.showEmojiPicker = false;
                    // 设置输入框焦点状态
                    this.inputFocused = true;
                    // 主动聚焦到 RichEditor
                    this.richEditorController.getCaretOffset();
                  } else {
                    // 当前显示键盘或无焦点，点击后关闭键盘，显示表情面板
                    this.hideKeyboard();
                    this.showEmojiPicker = true;
                  }
                })
            }
            .width('100%')
            .constraintSize({
              minHeight: 36,
              maxHeight: 120
            })
            .backgroundColor(this.themeManager.currentTheme.bgColorInput)
            .borderRadius(18)
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          .width('60%')
          .constraintSize({
            minHeight: 36,
            maxHeight: 120
          })
          .backgroundColor(this.themeManager.currentTheme.bgColorInput)
          .borderRadius(18)
          .padding({ left: 16, right: 16 })

          // 语音按钮
          Button() {
            Image($r('app.media.microphone_icon'))
              .width(24)
              .height(24)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.isVoiceRecording ? '#4A90E2' : this.themeManager.currentTheme.bgColorOperate)
          .borderRadius(18)
          .onClick(() => {
            console.info('[MessageInputBar] 点击语音按钮');
            this.showEmojiPicker = false; // 关闭表情选择器
            this.hideKeyboard(); // 隐藏键盘

            if (this.isVoiceRecording) {
              // 如果正在录制，点击完成录制
              this.audioRecorderManager.stopRecording();
            } else {
              // 如果未录制，点击开始录制
              this.audioRecorderManager.startRecording();
            }
          })

          // 相机按钮
          Button() {
            Image($r('app.media.camera_icon'))
              .width(24)
              .height(24)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
          .borderRadius(18)
          .onClick(() => {
            console.info('[MessageInputBar] 点击相机按钮');
            this.showEmojiPicker = false; // 关闭表情选择器
            this.hideKeyboard(); // 隐藏键盘
            this.takePhoto();
          })
        }
        .width('100%')
        .constraintSize({
          minHeight: 50,
          maxHeight: 120
        })
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }

      // 隐藏的按钮，用于转移焦点以隐藏键盘
      Button()
        .width(0)
        .height(0)
        .opacity(0)
        .focusable(true)
        .id(this.hiddenButtonId)

      // 表情选择器 - 紧贴在输入栏下方
      if (this.showEmojiPicker) {
        EmojiPicker({
          onEmojiSelected: (emoji: EmojiItem) => {
            this.handleEmojiSelected(emoji);
          },
          onClose: () => {
            this.showEmojiPicker = false;
          },
          onDelete: () => {
            this.handleDeleteLastCharacter();
          },
          onSend: () => {
            this.sendTextMessage();
            // this.showEmojiPicker = false;
          }
        })
          .transition({
            type: TransitionType.Insert,
            opacity: 1,
            translate: { y: 0 }
          })
          .transition({
            type: TransitionType.Delete,
            opacity: 0,
            translate: { y: 280 }
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 发送文本消息
   */
  private async sendTextMessage() {
    const messageText = await this.getMessageText();
    if (!messageText.trim() || !this.inputState) {
      return;
    }

    console.info(`[MessageInputBar] 发送文本消息: ${messageText}`);

    // 立即清空输入框，提供更好的用户体验
    this.clearEditor();

    try {
      // 构建消息体
      const messageBody = new MessageBody();
      messageBody.text = messageText.trim();

      // 构建消息信息
      const message = new MessageInfo();
      message.messageType = MessageType.Text;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.dateTime = new Date();
      message.ID = '';

      // 使用 MessageInputState 发送消息
      this.inputState.sendMessage(message)
        .then(() => {
          console.info(`[MessageInputBar] 消息发送成功`);
          // 调用父组件回调
          if (this.onSendMessage) {
            this.onSendMessage(messageText.trim());
          }
        })
        .catch((error: Object) => {
          console.error(`[MessageInputBar] 消息发送失败: ${JSON.stringify(error)}`);
          // 如果发送失败，可以考虑恢复输入框内容
          // 这里暂时不恢复，保持清空状态
        });
    } catch (error) {
      console.error(`[MessageInputBar] 创建消息失败: ${error}`);
    }
  }

  /**
   * 选择图片
   */
  private async selectImage() {
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        const imagePath = PhotoSelectResult.photoUris[0];
        const extension = imagePath.split(".").pop()
        if (extension === 'jpg' || extension === 'png' || extension === 'gif') {
          this.handleSelectedMedia(imagePath, MessageType.Image);
        } else if (extension === 'mp4' || extension === 'avi') {
          this.handleSelectedMedia(imagePath, MessageType.Video);
        } else {
          console.log('未知类型');
        }
        console.info(`[MessageInputBar] 已选择图片: ${imagePath}`);
      }).catch((err: BusinessError) => {
        console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      console.error(`[MessageInputBar] 选择图片失败: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 拍照
   */
  private async takePhoto() {
    try {
      // 创建相机选择器配置
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 启动相机进行拍照或录像
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        this.context as commonKit.Context,
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      );

      console.info(`[MessageInputBar] 相机选择器结果: ${JSON.stringify(pickerResult)}`);

      // 处理拍摄的照片
      if (pickerResult && pickerResult.resultUri && pickerResult.resultUri.length > 0) {
        const videoPath = pickerResult.resultUri;
        console.info(`[MessageInputBar] 照片拍摄完成: ${videoPath}`);
        this.handleSelectedMedia(videoPath, MessageType.Image);
      } else {
        console.info('[MessageInputBar] 未完成照片拍摄');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[MessageInputBar] 启动相机拍照失败: 错误码: ${err.code}`);
    }
  }

  /**
   * 录像
   */
  private async recordVideo() {
    try {
      // 创建相机选择器配置
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 启动相机进行拍照或录像
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        this.context as commonKit.Context,
        [cameraPicker.PickerMediaType.VIDEO],
        pickerProfile
      );

      console.info(`[MessageInputBar] 相机选择器结果: ${JSON.stringify(pickerResult)}`);

      // 处理录制的视频
      if (pickerResult && pickerResult.resultUri && pickerResult.resultUri.length > 0) {
        const videoPath = pickerResult.resultUri;
        console.info(`[MessageInputBar] 视频录制完成: ${videoPath}`);
        this.handleSelectedMedia(videoPath, MessageType.Video);
      } else {
        console.info('[MessageInputBar] 未完成视频录制');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[MessageInputBar] 启动相机录像失败: 错误码: ${err.code}`);
    }
  }

  /**
   * 选择文件
   */
  private selectFile() {
    try {
      // 创建文件选择器
      const documentPicker = new picker.DocumentViewPicker();

      // 配置文件选择器
      const documentSelectOptions: picker.DocumentSelectOptions = {
        maxSelectNumber: 1,
      };

      // 显示文件选择器
      documentPicker.select(documentSelectOptions)
        .then((documentSelectResult) => {
          if (documentSelectResult && documentSelectResult.length > 0) {
            const filePath = documentSelectResult[0];
            console.info(`[MessageInputBar] 已选择文件: ${filePath}`);
            this.handleSelectedFile(filePath);
          } else {
            console.info('[MessageInputBar] 未选择任何文件');
          }
        })
        .catch((err: Object) => {
          console.error(`[MessageInputBar] 选择文件失败: ${JSON.stringify(err)}`);
        });
    } catch (error) {
      console.error(`[MessageInputBar] 创建文件选择器失败: ${error}`);
    }
  }

  /**
   * 处理选择的媒体文件（图片或视频）
   */
  private async handleSelectedMedia(mediaPath: string, messageType: MessageType) {
    if (!this.inputState) {
      console.error('[MessageInputBar] 消息输入状态未初始化');
      return;
    }
    const user_file_uri = mediaPath;
    const app_file_path = Util.getMediaHomePath(messageType) + user_file_uri.split("/").pop();
    let user_file = await fs.open(user_file_uri, fs.OpenMode.READ_ONLY);
    let app_file = await fs.open(app_file_path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    await fs.copyFile(user_file.fd, app_file.fd, 0);
    await fs.close(user_file);
    await fs.close(app_file);

    try {
      // 创建消息体
      const messageBody = new MessageBody();

      if (messageType === MessageType.Image) {
        // 对于图片类型
        messageBody.originalImagePath = app_file_path;
        messageBody.originalImageWidth = 0; // 将在后续处理中获取实际宽度
        messageBody.originalImageHeight = 0; // 将在后续处理中获取实际高度
      } else if (messageType === MessageType.Video) {
        // 对于视频类型
        messageBody.videoPath = app_file_path;

        // 获取视频封面图
        // 获取视频文件名（不含扩展名）
        const videoFileName = app_file_path.split("/").pop()?.split(".")[0] || "video_cover";
        // 生成封面图路径
        const thumbnail_file_path = Util.getMediaHomePath(MessageType.Image) + videoFileName + "_cover.jpg";

        let predicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo("uri", user_file_uri);
        let fetchResult = await photoAccessHelper.getPhotoAccessHelper(getContext()).getAssets({
          fetchColumns: [photoAccessHelper.PhotoKeys.DURATION],
          predicates: predicates,
        });
        const asset = await fetchResult.getFirstObject();
        const thumbnail = await asset.getThumbnail();

        const imagePackerApi = image.createImagePacker();
        const thumbnail_file = await fs.open(thumbnail_file_path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
        await imagePackerApi.packToFile(thumbnail, thumbnail_file.fd, {
          format: "image/jpeg",
          quality: 100,
        });

        messageBody.videoSnapshotPath = thumbnail_file_path;
        messageBody.videoDuration = 1;
      }

      // 创建消息
      const message = new MessageInfo();
      message.messageType = messageType;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.dateTime = new Date();
      message.ID = '';

      // 发送消息
      if (this.inputState) {
        this.inputState.sendMessage(message)
          .then(() => {
            console.info(`[MessageInputBar] ${messageType === MessageType.Image ? '图片' : '视频'}消息发送成功`);
          })
          .catch((error: Object) => {
            console.error(`[MessageInputBar] ${messageType === MessageType.Image ? '图片' :
              '视频'}消息发送失败: ${JSON.stringify(error)}`);
          });
      }
    } catch (error) {
      console.error(`[MessageInputBar] 处理媒体文件失败: ${error}`);
    }
  }

  /**
   * 处理选择的文件
   */
  private async handleSelectedFile(filePath: string) {
    if (!this.inputState) {
      console.error('[MessageInputBar] 消息输入状态未初始化');
      return;
    }

    const user_file_uri = filePath;
    const app_file_path = Util.getMediaHomePath(MessageType.File) + user_file_uri.split("/").pop();
    let user_file = await fs.open(user_file_uri, fs.OpenMode.READ_ONLY);
    let app_file = await fs.open(app_file_path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    await fs.copyFile(user_file.fd, app_file.fd, 0);
    await fs.close(user_file);
    await fs.close(app_file);
    try {
      // 获取文件信息
      fs.stat(app_file_path).then((stat) => {
        // 创建消息体
        const messageBody = new MessageBody();
        messageBody.filePath = app_file_path;
        messageBody.fileName = app_file_path.substring(app_file_path.lastIndexOf('/') + 1);
        messageBody.fileSize = stat.size;

        // 创建消息
        const message = new MessageInfo();
        message.messageType = MessageType.File;
        message.messageBody = messageBody;
        message.isSelf = true;
        message.dateTime = new Date();
        message.ID = '';

        // 发送消息
        if (this.inputState) {
          this.inputState.sendMessage(message)
            .then(() => {
              console.info('[MessageInputBar] 文件消息发送成功');
            })
            .catch((error: Object) => {
              console.error(`[MessageInputBar] 文件消息发送失败: ${JSON.stringify(error)}`);
            });
        }
      }).catch((err: Object) => {
        console.error(`[MessageInputBar] 获取文件信息失败: ${JSON.stringify(err)}`);
      });
    } catch (error) {
      console.error(`[MessageInputBar] 处理文件失败: ${error}`);
    }
  }

  /**
   * 处理表情选择
   */
  private handleEmojiSelected(emoji: EmojiItem) {
    console.info(`[MessageInputBar] 选择表情: ${emoji.name}`);

    // 在富文本编辑器中插入表情图片
    this.insertEmojiToEditor(emoji);

    // 选择表情后保持表情面板显示，确保键盘不弹出
    this.inputFocused = false;
  }

  /**
   * 处理删除最后一个字符
   */
  private handleDeleteLastCharacter() {
    console.info('[MessageInputBar] 开始删除最后一个字符');

    try {
      // 获取当前所有 spans 来计算总长度
      const spans = this.richEditorController.getSpans({
        start: 0,
        end: -1
      });

      if (!spans || spans.length === 0) {
        console.info('[MessageInputBar] 编辑器为空，无需删除');
        return;
      }

      // 计算总长度
      let totalLength = 0;
      spans.forEach((span) => {
        const textSpan = span as RichEditorTextSpanResult;
        if (textSpan.value !== undefined && textSpan.value !== null) {
          // 文本 span，累加文本长度
          totalLength += textSpan.value.length;
        } else {
          // 图片 span（表情），算作 1 个字符
          totalLength += 1;
        }
      });

      console.info(`[MessageInputBar] 当前总长度: ${totalLength}`);

      if (totalLength > 0) {
        // 删除最后一个字符：从 totalLength-1 到 totalLength
        this.richEditorController.deleteSpans({
          start: totalLength - 1,
          end: totalLength
        });
        console.info(`[MessageInputBar] 成功删除位置 ${totalLength - 1} 到 ${totalLength} 的内容`);
      } else {
        console.info('[MessageInputBar] 内容长度为0，无需删除');
      }

    } catch (error) {
      console.error(`[MessageInputBar] 删除字符失败: ${error}`);
    }
  }

  /**
   * 获取消息文本（用于发送）
   */
  private async getMessageText(): Promise<string> {
    console.info(`[MessageInputBar] 开始实时获取消息文本`);

    try {
      // 从 RichEditor 获取所有 spans
      const spans = await this.richEditorController.getSpans({
        start: 0,
        end: -1
      });

      console.info(`[MessageInputBar] 获取到 ${spans.length} 个 spans`);

      let messageText = '';
      spans.forEach((span, index) => {
        console.info(`[MessageInputBar] 处理 span ${index}`);

        // 检查是否为文本 span
        const textSpan = span as RichEditorTextSpanResult;
        if (textSpan.value !== undefined && textSpan.value !== null) {
          console.info(`[MessageInputBar] 识别为文本 span: "${textSpan.value}"`);
          messageText += textSpan.value;
          return;
        }

        // 检查是否为图片 span（表情）
        const imageSpan = span as RichEditorImageSpanResult;
        if (imageSpan.valueResourceStr !== undefined || imageSpan.valuePixelMap !== undefined) {
          console.info(`[MessageInputBar] 识别为图片 span，开始查找表情名称`);

          // 获取图片资源
          let imageResource: string | Resource | undefined = imageSpan.valueResourceStr;

          if (imageResource) {
            // 将资源转换为字符串格式进行匹配
            let resourceStr = '';
            if (typeof imageResource === 'string') {
              resourceStr = imageResource;
            } else {
              // Resource 类型，转换为 JSON 字符串
              resourceStr = JSON.stringify(imageResource);
            }

            console.info(`[MessageInputBar] 图片资源字符串: ${resourceStr}`);

            // 使用全局 EmojiDataManager 查找表情名称
            const emojiName = EmojiDataManager.getEmojiNameByResourceString(resourceStr);

            if (emojiName) {
              console.info(`[MessageInputBar] 通过全局映射找到表情名称: ${emojiName}`);
              messageText += emojiName;
            } else {
              console.warn(`[MessageInputBar] 未找到对应的表情名称，资源: ${resourceStr}`);
            }
          } else {
            console.warn(`[MessageInputBar] 图片 span 中未找到资源属性`);
          }
        } else {
          console.warn(`[MessageInputBar] 未知类型的 span: ${JSON.stringify(span)}`);
        }
      });

      console.info(`[MessageInputBar] 最终获取到的消息文本: "${messageText}"`);
      return messageText;

    } catch (error) {
      console.error(`[MessageInputBar] 获取富文本内容失败: ${error}`);
      return '';
    }
  }

  /**
   * 插入表情到富文本编辑器
   */
  private insertEmojiToEditor(emoji: EmojiItem) {
    try {
      console.info(`[MessageInputBar] 开始插入表情: ${emoji.name}`);

      // 获取表情图片资源
      const emojiResource = EmojiDataManager.getEmojiImageResource(emoji.imageFile);
      console.info(`[MessageInputBar] 表情资源对象: ${JSON.stringify(emojiResource)}`);

      // 获取当前光标位置
      const selection = this.richEditorController.getSelection();
      const cursorPosition = selection.selection[1]; // 获取光标结束位置

      console.info(`[MessageInputBar] 当前光标位置: ${cursorPosition}`);

      // 在光标位置插入表情图片
      this.richEditorController.addImageSpan(emojiResource, {
        imageStyle: {
          size: [20, 20],
          verticalAlign: ImageSpanAlignment.CENTER,
          objectFit: ImageFit.Contain
        },
        offset: cursorPosition
      });

      console.info(`[MessageInputBar] 成功在位置 ${cursorPosition} 插入表情: ${emoji.name}`);

    } catch (error) {
      console.error(`[MessageInputBar] 插入表情失败: ${error}`);
    }
  }

  /**
   * 清空富文本编辑器
   */
  private clearEditor() {
    try {
      console.info('[MessageInputBar] 开始清空编辑器');
      // 删除所有 spans
      this.richEditorController.deleteSpans();
    } catch (error) {
      console.error(`[MessageInputBar] 清空编辑器失败: ${error.message}`);
    }
  }

  /**
   * 隐藏键盘
   */
  private hideKeyboard() {
    console.info('[MessageInputBar] 开始隐藏键盘');
    this.inputFocused = false;

    // 通过让隐藏的按钮获取焦点来移除 RichEditor 的焦点
    try {
      // 使用 focusControl 来转移焦点
      focusControl.requestFocus(this.hiddenButtonId);
      console.info('[MessageInputBar] 成功转移焦点到隐藏按钮');
    } catch (error) {
      console.warn('[MessageInputBar] 转移焦点失败:', error);
    }

    // 延时确保焦点转移生效
    setTimeout(() => {
      console.info('[MessageInputBar] 键盘隐藏处理完成');
    }, 100);
  }

  /**
   * 发送语音消息
   */
  private async sendVoiceMessage(duration: number, voiceFilePath?: string) {
    if (!this.inputState) {
      console.error('[MessageInputBar] 消息输入状态未初始化');
      return;
    }

    try {
      // 使用传入的语音文件路径，如果没有则使用空字符串
      const filePath = voiceFilePath || '';

      if (!filePath) {
        console.error('[MessageInputBar] 语音文件路径为空');
        return;
      }

      // 创建消息体
      const messageBody = new MessageBody();
      messageBody.soundPath = filePath;
      messageBody.soundDuration = duration;

      // 创建消息
      const message = new MessageInfo();
      message.messageType = MessageType.Sound;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.dateTime = new Date();
      message.ID = '';

      // 发送消息
      this.inputState.sendMessage(message)
        .then(() => {
          console.info('[MessageInputBar] 语音消息发送成功');
          // 调用父组件回调
          if (this.onSendMessage) {
            this.onSendMessage(`[语音消息 ${duration}秒]`);
          }
        })
        .catch((error: Object) => {
          console.error(`[MessageInputBar] 语音消息发送失败: ${JSON.stringify(error)}`);
        });

    } catch (error) {
      console.error(`[MessageInputBar] 创建语音消息失败: ${error}`);
    }
  }
}
