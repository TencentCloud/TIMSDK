import { MessageInfo, MessageStatus, MessageBody, MessageListStore, MessageResourceType } from 'chatengine';
import { ThemeState, TimeUtil } from '../../basecomponent/Index';
import { promptAction } from '@kit.ArkUI';
import { filePreview } from '@kit.PreviewKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri } from '@kit.CoreFileKit';

@Component
export struct FileMessageViewContent {
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @ObjectLink messageListStore: MessageListStore;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Column() {
      Row() {
        Image($rawfile('messagelist/icon_message_file.svg'))
          .width(22)
          .height(22)
          .margin({ right: 10 })
        Column() {
          Text(this.messageBody?.fileName || $r('app.string.messagelist_unknown_file'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('80%')

        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding(10)
      .backgroundColor(this.themeState.colors.bgColorOperate)
      .borderRadius(8)
      .margin({ left: 5, right: 5, top: 8 })
      .width('90%')
      .onClick(() => {
        this.handleFileClick();
      })

      // Time and status - inline with text
      Row() {
        // Left side - File size
        Text(this.formatFileSize(this.messageBody?.fileSize))
          .fontSize(12)
          .fontColor(this.message?.isSelf ? this.themeState.colors.textColorAntiSecondary :
          this.themeState.colors.textColorPrimary)
          .margin({ left: 1, top: 4 })
        // Right side - Status and time
        Row() {
          if (this.message?.status === MessageStatus.sending) {
            LoadingProgress()
              .width(12)
              .height(12)
              .margin({ right: 4 })
          }
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 10,
        bottom: 8,
        left: 16,
        right: 16
      })
    }
  }

  private handleFileClick() {
    if (!this.message || !this.message.msgID) {
      return;
    }

    if (!this.messageBody?.fileName) {
      return;
    }

    if (this.messageBody?.filePath && this.messageBody.filePath.length > 0) {
      this.openFile(this.messageBody.filePath);
      return;
    }

    this.downloadAndOpenFile();
  }

  private downloadAndOpenFile() {
    if (!this.message) {
      return;
    }

    console.info('[FileMessageView] start download filed:', this.messageBody?.fileName);

    this.showDownloadToast($r('app.string.messagelist_downloading'));

    this.messageListStore.downloadMessageResource(this.message, MessageResourceType.file)
      .then(() => {
        this.showDownloadToast($r('app.string.messagelist_file_download_success'));
        if (this.messageBody?.filePath) {
          this.openFile(this.messageBody.filePath);
        } else {
          this.showDownloadToast($r('app.string.messagelist_file_download_failed'));
        }
      })
      .catch((error: object) => {

      });
  }

  private openFile(filePath: string) {
    try {
      const cleanPath = filePath.startsWith('file://') ? filePath.substring(7) : filePath;
      const fileName = this.messageBody?.fileName || '';
      const fileExtension = this.getFileExtension(fileName).toLowerCase();

      this.openWithSystemApp(cleanPath);

    } catch (error) {

    }
  }

  private openWithSystemApp(filePath: string) {
    try {
      let uiContext = this.getUIContext().getHostContext() as Context;
      let uri = fileUri.getUriFromPath(filePath);

      filePreview.canPreview(uiContext, uri).then((result) => {
        console.info(`Succeeded in obtaining the result of whether it can be previewed. result = ${result}`);
        let uiContext = this.getUIContext().getHostContext() as Context;
        let displayInfo: filePreview.DisplayInfo = {
          x: 100,
          y: 100,
          width: 800,
          height: 800
        };
        let fileInfo: filePreview.PreviewInfo = {
          title: this.messageBody?.fileName,
          uri: uri,
          mimeType: this.getMimeType(filePath)
        };
        filePreview.openPreview(uiContext, fileInfo, displayInfo).then(() => {
          console.info('Succeeded in opening preview');
        }).catch((err: BusinessError) => {
          console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(`Failed to obtain the result of whether it can be previewed, err.code = ${err.code}, err.message = ${err.message}`);
      });


    } catch (error) {
      console.error('[FileMessageView] error:', error);
    }
  }

  private getMimeType(fileName: string): string {
    const extension = this.getFileExtension(fileName).toLowerCase();

    const mimeTypes: Record<string, string> = {
      // image
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'webp': 'image/webp',
      'svg': 'image/svg+xml',

      // video
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'wmv': 'video/x-ms-wmv',
      'flv': 'video/x-flv',
      'mkv': 'video/x-matroska',
      '3gp': 'video/3gpp',
      'webm': 'video/webm',

      // voice
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'aac': 'audio/aac',
      'flac': 'audio/flac',
      'ogg': 'audio/ogg',
      'm4a': 'audio/mp4',
      'wma': 'audio/x-ms-wma',

      // file
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',

      // zip
      'zip': 'application/zip',
      'rar': 'application/x-rar-compressed',
      '7z': 'application/x-7z-compressed',

      // other
      'json': 'application/json',
      'xml': 'application/xml',
      'html': 'text/html',
      'css': 'text/css',
      'js': 'application/javascript'
    };

    return mimeTypes[extension] || 'application/octet-stream';
  }

  private getFileExtension(fileName: string): string {
    const lastDotIndex = fileName.lastIndexOf('.');
    return lastDotIndex !== -1 ? fileName.substring(lastDotIndex + 1) : '';
  }

  private showDownloadToast(message: string | Resource) {
    console.info('[FileMessageView] Toast:', message);
    try {
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      console.error('[FileMessageView] Download error:', error);
    }
  }

  private formatFileSize(bytes?: number): string | Resource {
    if (!bytes) {
      return $r('app.string.messagelist_unknown_size');
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return `${size.toFixed(1)} ${units[unitIndex]}`;
  }
}

@Builder
export function FileMessageView(messageData: MessageInfo, messageListStore: MessageListStore) {
  if (messageData && messageData.messageBody && MessageListStore) {
    FileMessageViewContent({
      message: messageData,
      messageBody: messageData.messageBody,
      messageListStore: messageListStore
    })
  }
}