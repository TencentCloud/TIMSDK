import { ChatEngine, MessageInfo, MessageType, ErrorResult } from 'chatengine';
import { TextUtils, ThemeManager } from 'basecomponent';
import router from '@ohos.router';
import { MessageList } from 'messagelist';
import { MessageInputBar } from 'messageinput';

/**
 * 消息页面组件
 */
@Entry
@Component
export struct MessagePage {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 会话ID
  @State conversationID: string = '';
  // 会话标题
  @State title: string = '聊天';
  // 会话状态
  @State status: string = 'online';
  // 会话头像URL
  @State avatarUrl: string = '';

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams();
    if (params) {
      const paramsObj = params as Record<string, string>;
      this.conversationID = paramsObj.conversationID || '';
      this.title = paramsObj.title || '聊天';
      this.status = paramsObj.status || 'online';
      this.avatarUrl = paramsObj.avatarUrl || '';
      console.info(`MessagePage: 接收到会话ID: ${this.conversationID}, 标题: ${this.title}`);
    } else {
      console.error('MessagePage: 没有收到有效的会话ID');
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Column() {
        // 主标题栏
        Row() {
          // 返回按钮和头像部分
          Row({ space: 8 }) {
            // 返回按钮
            Image($r('app.media.back_icon'))
              .width(24)
              .height(24)
              .fillColor(this.themeManager.currentTheme.textColorSecondary)
              .onClick(() => {
                router.back();
              })

            // 头像
            Stack() {

              Image(this.avatarUrl || $r('app.media.avatar_bg'))
                .width(36)
                .height(36)
                .borderRadius(18)

              if (this.avatarUrl && this.avatarUrl.trim().length > 0 && TextUtils.isValidUrl(this.avatarUrl)) {
                // 有头像URL时显示图片
                Image(this.avatarUrl)
                  .width(36)
                  .height(36)
                  .borderRadius(18)
              } else {
                // 没有头像URL时显示首字母
                Circle()
                  .width(36)
                  .height(36)
                  .fill(this.themeManager.currentTheme.textColorLink)

                Text(TextUtils.getAvatarLetter(this.title))
                  .fontSize(18)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
              }

            }
            .width(36)
            .height(36)
            .borderRadius(18)

            // 名称和状态
            Column() {
              Text(this.title)
                .fontSize(14)
                .fontColor(this.themeManager.currentTheme.textColorPrimary)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Start)

              Text(this.status)
                .fontSize(12)
                .fontColor(this.themeManager.currentTheme.textColorTertiary)
                .fontWeight(FontWeight.Regular)
                .textAlign(TextAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(VerticalAlign.Center)

          // 视频通话和语音通话按钮
          Row({ space: 16 }) {
            // 视频通话按钮
            Image($r('app.media.video_icon'))
              .width(24)
              .height(24)
              .onClick(() => {
                console.info('视频通话');
              })

            // 语音通话按钮
            Image($r('app.media.call_icon'))
              .width(24)
              .height(24)
              .onClick(() => {
                console.info('语音通话');
              })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height(56)
        .padding({ left: 10, right: 10 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        // 分割线
        Divider()
          .width('100%')
          .height(1)
          .color('#E6E9F0')
      }
      .width('100%')
      .backgroundColor(this.themeManager.currentTheme.bgColorOperate)

      // 消息列表区域 - 使用 MessageList 组件
      MessageList({
        conversationID: this.conversationID
      })
        .width('100%')
        .layoutWeight(1)

      // 底部输入框 - 使用 MessageInputBar 组件
      MessageInputBar({
        conversationID: this.conversationID,
        onSendMessage: (text: string) => {
          // 这里不需要额外的处理，MessageInputBar会直接发送消息
          // MessageList会通过事件监听接收到消息状态变化
          console.info(`MessagePage: 用户发送消息: ${text}`);
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
