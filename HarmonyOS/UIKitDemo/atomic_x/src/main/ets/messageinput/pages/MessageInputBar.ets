import { ThemeState } from '../../basecomponent/Index';
import { MessageBody, MessageInfo, MessageInputStore, MessageType, Util } from 'chatengine';
import { MessageInputMoreDialog } from './MessageInputMoreDialog';
import { EmojiDataManager, EmojiItem, EmojiPicker } from '../../emojipicker/Index';
import { AudioRecorderManager, AudioRecorderView } from '../../audiorecorder/Index';
import { FilePicker } from '../../filepicker/Index';
import { VideoRecorder } from '../../videorecorder/Index';
import { ImagePicker, MediaSelectResult } from '../../imagepicker/Index';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { common as commonKit } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { dataSharePredicates } from '@kit.ArkData';
import image from '@ohos.multimedia.image';

@Component
export struct MessageInputBar {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  conversationID: string = '';
  onSendMessage?: (text: string) => void;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: MessageInputMoreDialog({
      menuItems: [
        {
          id: 'image',
          text: $r('app.string.menu_image'),
          icon: $rawfile('messageinput/camera_action_icon.svg'),
          action: () => {
            this.selectImage();
          }
        },
        {
          id: 'photo',
          text: $r('app.string.menu_photo'),
          icon: $rawfile('messageinput/camera_action_icon.svg'),
          action: () => {
            this.takePhoto();
          }
        },
        {
          id: 'video',
          text: $r('app.string.menu_video'),
          icon: $rawfile('messageinput/document_icon.svg'),
          action: () => {
            this.recordVideo();
          }
        },
        {
          id: 'file',
          text: $r('app.string.menu_file'),
          icon: $rawfile('messageinput/document_icon.svg'),
          action: () => {
            this.selectFile();
          }
        },
        {
          id: 'custom',
          text: $r('app.string.menu_custom'),
          icon: $rawfile('messageinput/custom_icon.svg'),
          action: () => {

          }
        }
      ],
      onCancel: () => {

      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -16 },
    customStyle: true,
    autoCancel: true
  });
  private richEditorController: RichEditorController = new RichEditorController();
  @State private inputState: MessageInputStore | null = null;
  @State private showEmojiPicker: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  @State private inputFocused: boolean = false;
  private hiddenButtonId: string = 'hiddenFocusButton';
  @State private isVoiceRecording: boolean = false;
  @State private recordingDuration: number = 0;
  private audioRecorderManager: AudioRecorderManager = new AudioRecorderManager();

  aboutToAppear() {
    if (this.conversationID) {
      this.inputState = MessageInputStore.createInstance(this.conversationID);
    } else {
      console.error('[MessageInputBar] No conversationID provided, input state will not be created');
    }

    this.audioRecorderManager.setContext(this.context)

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

      if (this.isVoiceRecording) {

        Row() {
          AudioRecorderView({
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
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {

        Row() {

          Button() {
            Image($rawfile('messageinput/plus_icon.svg'))
              .width(20)
              .height(20)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.themeState.getCurrentTheme().bgColorOperate)
          .borderRadius(18)
          .onClick(() => {

            this.showEmojiPicker = false;
            this.hideKeyboard();
            this.dialogController.open();
          })


          Stack() {

            Row() {

              RichEditor({
                controller: this.richEditorController
              })
                .backgroundColor(this.themeState.colors.bgColorInput)
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
                  fontColor: this.themeState.colors.textColorTertiary,
                  font: {
                    size: 14,
                    weight: FontWeight.Normal,
                    family: "HarmonyOS Sans",
                    style: FontStyle.Normal
                  }
                })
                .onReady(() => {

                })
                .onFocus(() => {

                  this.inputFocused = true;

                  if (this.showEmojiPicker) {
                    this.showEmojiPicker = false;
                  }
                })
                .onBlur(() => {

                  this.inputFocused = false;
                })
                .onClick(() => {


                  if (this.showEmojiPicker) {
                    this.showEmojiPicker = false;
                  }

                  this.inputFocused = true;
                })
                .onSubmit(() => {


                  this.sendTextMessage();
                })
                .onIMEInputComplete((value: RichEditorTextSpanResult) => {

                  if (value.value && value.value.length > 0) {

                    const selection = this.richEditorController.getSelection();
                    const start = selection.selection[0];
                    const end = selection.selection[1];


                    this.richEditorController.updateSpanStyle({
                      start: start - value.value.length,
                      end: start,
                      textStyle: {
                        fontColor: this.themeState.colors.textColorPrimary
                      }
                    });
                  }
                })


              Image(this.showEmojiPicker ? $rawfile('messageinput/keyboard_icon.svg') :
              $rawfile('messageinput/emoji_icon.svg'))
                .width(19)
                .height(19)
                .onClick(() => {


                  if (this.showEmojiPicker) {

                    this.showEmojiPicker = false;

                    this.inputFocused = true;

                    this.richEditorController.getCaretOffset();
                  } else {

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
            .backgroundColor(this.themeState.colors.bgColorInput)
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
          .backgroundColor(this.themeState.colors.bgColorInput)
          .borderRadius(18)
          .padding({ left: 16, right: 16 })


          Button() {
            Image($rawfile('messageinput/microphone_icon.svg'))
              .width(24)
              .height(24)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.isVoiceRecording ? '#4A90E2' : this.themeState.colors.bgColorOperate)
          .borderRadius(18)
          .onClick(() => {

            this.showEmojiPicker = false;
            this.hideKeyboard();

            if (this.isVoiceRecording) {

              this.audioRecorderManager.stopRecording();
            } else {

              this.audioRecorderManager.startRecording();
            }
          })


          Button() {
            Image($rawfile('messageinput/camera_icon.svg'))
              .width(24)
              .height(24)
          }
          .width(36)
          .height(36)
          .backgroundColor(this.themeState.colors.bgColorOperate)
          .borderRadius(18)
          .onClick(() => {

            this.showEmojiPicker = false;
            this.hideKeyboard();
            this.takePhoto();
          })
        }
        .width('100%')
        .constraintSize({
          minHeight: 50,
          maxHeight: 120
        })
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }


      Button()
        .width(0)
        .height(0)
        .opacity(0)
        .focusable(true)
        .id(this.hiddenButtonId)


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

  private async sendTextMessage() {
    const messageText = await this.getMessageText();
    if (!messageText.trim() || !this.inputState) {
      return;
    }


    this.clearEditor();

    try {
      const messageBody = new MessageBody();
      messageBody.text = messageText.trim();

      const message = new MessageInfo();
      message.messageType = MessageType.Text;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.timestamp = new Date().getTime();
      message.ID = '';

      this.inputState.sendMessage(message)
        .then(() => {
          if (this.onSendMessage) {
            this.onSendMessage(messageText.trim());
          }
        })
        .catch((error: Object) => {
        });
    } catch (error) {
    }
  }

  private async selectImage(): Promise<void> {
    try {
      const result: MediaSelectResult = await ImagePicker.selectImage();
      if (result.path) {

        if (result.type === 'image') {
          this.handleSelectedMedia(result.path, MessageType.Image);
        } else if (result.type === 'video') {
          this.handleSelectedMedia(result.path, MessageType.Video);
        }
      } else {
      }
    } catch (error) {
    }
  }

  private async takePhoto() {
    try {

      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        this.context as commonKit.Context,
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      );

      if (pickerResult && pickerResult.resultUri && pickerResult.resultUri.length > 0) {
        const videoPath = pickerResult.resultUri;

        this.handleSelectedMedia(videoPath, MessageType.Image);
      } else {

      }
    } catch (error) {
      const err = error as BusinessError;
    }
  }

  private async recordVideo(): Promise<void> {
    try {
      const videoPath: string = await VideoRecorder.recordVideo(this.context);
      if (videoPath) {

        this.handleSelectedMedia(videoPath, MessageType.Video);
      } else {

      }
    } catch (error) {

    }
  }

  private async handleSelectedMedia(mediaPath: string, messageType: MessageType) {
    if (!this.inputState) {

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

      const messageBody = new MessageBody();

      if (messageType === MessageType.Image) {

        messageBody.originalImagePath = app_file_path;
        messageBody.originalImageWidth = 0;
        messageBody.originalImageHeight = 0;
      } else if (messageType === MessageType.Video) {

        messageBody.videoPath = app_file_path;


        const videoFileName = app_file_path.split("/").pop()?.split(".")[0] || "video_cover";

        const thumbnail_file_path = Util.getMediaHomePath(MessageType.Image) + videoFileName + "_cover.jpg";

        let predicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo("uri", user_file_uri);
        let fetchResult = await photoAccessHelper.getPhotoAccessHelper(getContext()).getAssets({
          fetchColumns: [photoAccessHelper.PhotoKeys.DURATION],
          predicates: predicates,
        });
        const asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
        const thumbnail: image.PixelMap = await asset.getThumbnail();

        const imagePackerApi = image.createImagePacker();
        const thumbnail_file = await fs.open(thumbnail_file_path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
        await imagePackerApi.packToFile(thumbnail, thumbnail_file.fd, {
          format: "image/jpeg",
          quality: 100,
        });

        messageBody.videoSnapshotPath = thumbnail_file_path;
        messageBody.videoDuration = 1;
      }


      const message = new MessageInfo();
      message.messageType = messageType;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.timestamp = new Date().getTime();
      message.ID = '';

      // Send message
      if (this.inputState) {
        this.inputState.sendMessage(message)
          .then(() => {

          })
          .catch((error: Object) => {
            console.error(`[MessageInputBar] ${messageType === MessageType.Image ? 'image' :
              'video'}Message sendfailed ${JSON.stringify(error)}`);
          });
      }
    } catch (error) {

    }
  }

  private handleEmojiSelected(emoji: EmojiItem) {
    this.insertEmojiToEditor(emoji);
    this.inputFocused = false;
  }

  private handleDeleteLastCharacter() {
    try {
      const spans = this.richEditorController.getSpans({
        start: 0,
        end: -1
      });

      if (!spans || spans.length === 0) {
        return;
      }
      let totalLength = 0;
      spans.forEach((span) => {
        const textSpan = span as RichEditorTextSpanResult;
        if (textSpan.value !== undefined && textSpan.value !== null) {
          totalLength += textSpan.value.length;
        } else {
          totalLength += 1;
        }
      });
      if (totalLength > 0) {
        this.richEditorController.deleteSpans({
          start: totalLength - 1,
          end: totalLength
        });
      } else {
      }

    } catch (error) {
    }
  }

  private async getMessageText(): Promise<string> {
    try {
      const spans = await this.richEditorController.getSpans({
        start: 0,
        end: -1
      });

      let messageText = '';
      spans.forEach((span, index) => {
        const textSpan = span as RichEditorTextSpanResult;
        if (textSpan.value !== undefined && textSpan.value !== null) {
          messageText += textSpan.value;
          return;
        }
        const imageSpan = span as RichEditorImageSpanResult;
        if (imageSpan.valueResourceStr !== undefined || imageSpan.valuePixelMap !== undefined) {
          let imageResource: string | Resource | undefined = imageSpan.valueResourceStr;
          if (imageResource) {
            let resourceStr = '';
            if (typeof imageResource === 'string') {
              resourceStr = imageResource;
            } else {

              resourceStr = JSON.stringify(imageResource);
            }


            const emojiName = EmojiDataManager.getEmojiNameByResourceString(resourceStr);

            if (emojiName) {

              messageText += emojiName;
            } else {
              console.warn(`[MessageInputBar] No corresponding emoticon name found，Resource: ${resourceStr}`);
            }
          } else {
            console.warn(`[MessageInputBar] Resource attribute not found in image span`);
          }
        } else {
          console.warn(`[MessageInputBar] span of unknown type: ${JSON.stringify(span)}`);
        }
      });


      return messageText;

    } catch (error) {

      return '';
    }
  }

  private insertEmojiToEditor(emoji: EmojiItem) {
    try {
      const emojiResource = EmojiDataManager.getEmojiImageResource(emoji.imageFile);
      const selection = this.richEditorController.getSelection();
      const cursorPosition = selection.selection[1];
      this.richEditorController.addImageSpan(emojiResource, {
        imageStyle: {
          size: [20, 20],
          verticalAlign: ImageSpanAlignment.CENTER,
          objectFit: ImageFit.Contain
        },
        offset: cursorPosition
      });
    } catch (error) {
    }
  }

  private clearEditor() {
    try {
      this.richEditorController.deleteSpans();
    } catch (error) {
    }
  }

  private hideKeyboard() {
    this.inputFocused = false;
    try {
      focusControl.requestFocus(this.hiddenButtonId);
    } catch (error) {
      console.warn('[MessageInputBar] 转移焦点失败:', error);
    }
  }

  private async sendVoiceMessage(duration: number, voiceFilePath?: string) {
    if (!this.inputState) {
      return;
    }
    try {
      const filePath = voiceFilePath || '';
      if (!filePath) {
        return;
      }
      const messageBody = new MessageBody();
      messageBody.soundPath = filePath;
      messageBody.soundDuration = duration;
      const message = new MessageInfo();
      message.messageType = MessageType.Sound;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.timestamp = new Date().getTime();
      message.ID = '';

      // Send message
      this.inputState.sendMessage(message)
        .then(() => {
          if (this.onSendMessage) {
            this.onSendMessage(`[Voice Message ${duration} sec]`);
          }
        })
        .catch((error: Object) => {
        });

    } catch (error) {
    }
  }

  private async selectFile() {
    try {
      const selectedFiles = await FilePicker.selectFile();
      if (selectedFiles.length > 0) {
        const filePath = selectedFiles[0];
        this.handleSelectedFile(filePath);
      } else {
      }
    } catch (error) {
    }
  }

  private async handleSelectedFile(filePath: string) {
    if (!this.inputState) {
      return;
    }

    const user_file_uri = filePath;
    const app_file_path = Util.getMediaHomePath(MessageType.File) + user_file_uri.split("/").pop();

    try {

      let user_file = await fs.open(user_file_uri, fs.OpenMode.READ_ONLY);
      let app_file = await fs.open(app_file_path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      await fs.copyFile(user_file.fd, app_file.fd, 0);
      await fs.close(user_file);
      await fs.close(app_file);


      const stat = await fs.stat(app_file_path);


      const messageBody = new MessageBody();
      messageBody.filePath = app_file_path;
      messageBody.fileName = app_file_path.substring(app_file_path.lastIndexOf('/') + 1);
      messageBody.fileSize = stat.size;


      const message = new MessageInfo();
      message.messageType = MessageType.File;
      message.messageBody = messageBody;
      message.isSelf = true;
      message.timestamp = new Date().getTime();
      message.ID = '';

      // Send message
      await this.inputState.sendMessage(message);

    } catch (error) {

    }
  }
}
