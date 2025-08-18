import { ThemeState } from '../theme/ThemeState'
import Prompt from '@system.prompt'
import { BusinessError } from '@kit.BasicServicesKit'
import { ComponentContent, promptAction } from '@kit.ArkUI'
import { UIContext } from '@ohos.arkui.UIContext'
import { Util } from 'chatengine'

export enum ToastType {
  Text = 'Text',
  Info = 'Info',
  Help = 'Help',
  Loading = 'Loading',
  Success = 'Success',
  Warning = 'Warning',
  Error = 'Error'
}

@Component
struct ToastIcon {
  @Prop type: ToastType
  @Prop iconSize: number = 16
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()
  @State private isAnimating: boolean = false

  aboutToAppear() {
    if (this.type === ToastType.Loading) {
      this.isAnimating = true
    }
  }

  aboutToDisappear() {
    this.isAnimating = false
  }

  build() {
    if (this.type === ToastType.Loading) {

      LoadingProgress()
        .width(this.iconSize)
        .height(this.iconSize)
        .color('#1C66E5')
    } else if (this.type !== ToastType.Text) {

      Image(this.getIconResource())
        .width(this.iconSize)
        .height(this.iconSize)
    }
  }

  private getIconResource(): Resource {
    switch (this.type) {
      case ToastType.Info:
        return $rawfile('basecomponent/info_circle_filled.svg')
      case ToastType.Help:
        return $rawfile('basecomponent/help_circle_filled.svg')
      case ToastType.Success:
        return $rawfile('basecomponent/check_circle_filled.svg')
      case ToastType.Warning:
        return $rawfile('basecomponent/warning_circle_filled.svg')
      case ToastType.Error:
        return $rawfile('basecomponent/error_circle_filled.svg')
      default:
        return $rawfile('basecomponent/check_circle_filled.svg')
    }
  }
}

@Component
struct ToastContent {
  @Prop message: string | Resource
  @Prop type: ToastType
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()

  build() {
    Row({ space: 4 }) {
      if (this.type !== ToastType.Text) {
        ToastIcon({
          type: this.type,
          iconSize: 16
        })
      }
      Text(this.message)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.colors.textColorPrimary)
        .lineHeight(14 * 1.57)
        .textAlign(TextAlign.Start)
    }
    .height(40)
    .padding({
      left: 16,
      right: 16,
      top: 9,
      bottom: 9
    })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(6)
    .shadow({
      radius: 8,
      color: this.themeState.colors.shadowColor,
      offsetX: 0,
      offsetY: 2
    })
    .constraintSize({
      maxWidth: 340
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}

interface ToastParams {
  message: string | Resource
  type: ToastType
}

// Toast Dialog Builder
@CustomDialog
struct ToastDialogBuilder {
  @Prop message: string
  @Prop type: ToastType
  controller: CustomDialogController

  build() {
    Column() {
      ToastContent({
        message: this.message,
        type: this.type
      })
    }
    .backgroundColor(Color.Transparent)
  }
}

@Builder
function ToastBuilder(params: ToastParams) {
  ToastContent({
    message: params.message,
    type: params.type
  })
}

export class Toast {
  private static ctx: UIContext
  private static currentContentNode: ComponentContent<ToastParams> | null = null
  private static currentTimer: number | null = null

  static longToast(text: string | Resource, bottom?: string | number) {
    const message =
      typeof text === 'string' ? text : getContext().getApplicationContext().resourceManager.getStringSync(text);
    Prompt.showToast({
      message: message,
      duration: 3000,
      bottom: bottom
    });
  }

  static shortToast(text: string | Resource, bottom?: string | number) {

    const message =
      typeof text === 'string' ? text : getContext().getApplicationContext().resourceManager.getStringSync(text);
    Prompt.showToast({
      message: message,
      duration: 1000,
      bottom: bottom
    });
  }

  static show(text: string | Resource, type: ToastType, context: UIContext, duration: number = 3000) {
    Toast.ctx = context


    if (Toast.currentTimer) {
      clearTimeout(Toast.currentTimer)
      Toast.currentTimer = null
    }

    Toast.closeDialogSync().then(() => {

      const params: ToastParams = {
        message: text,
        type: type
      }


      Toast.currentContentNode = new ComponentContent(Toast.ctx, wrapBuilder(ToastBuilder), params)

      const options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        autoCancel: false,
        maskColor: Color.Transparent,
        isModal: false
      }

      Toast.ctx.getPromptAction()
        .openCustomDialog(Toast.currentContentNode, options)
        .then(() => {
          console.info('Toast openCustomDialog complete.')

          if (duration > 0) {
            Toast.currentTimer = setTimeout(() => {
              Toast.closeDialog()
            }, duration)
          }
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message
          let code = (error as BusinessError).code
          console.error(`Toast openCustomDialog error code is ${code}, message is ${message}`)
        })
    })
  }

  static closeDialog() {

    if (Toast.currentTimer) {
      clearTimeout(Toast.currentTimer)
      Toast.currentTimer = null
    }

    if (Toast.currentContentNode && Toast.ctx) {
      Toast.ctx.getPromptAction()
        .closeCustomDialog(Toast.currentContentNode)
        .then(() => {
          console.info('Toast closeCustomDialog complete.')
          Toast.currentContentNode = null
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message
          let code = (error as BusinessError).code
          console.error(`Toast closeCustomDialog error code is ${code}, message is ${message}`)
        })
    }
  }

  static info(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Info, context, duration)
  }

  static help(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Help, context, duration)
  }

  static success(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Success, context, duration)
  }

  static warning(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Warning, context, duration)
  }

  static error(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Error, context, duration)
  }

  static loading(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Loading, context, duration)
  }

  static simple(message: string | Resource, context: UIContext, duration?: number) {
    Toast.show(message, ToastType.Info, context, duration)
  }

  private static closeDialogSync(): Promise<void> {
    return new Promise((resolve) => {

      if (Toast.currentTimer) {
        clearTimeout(Toast.currentTimer)
        Toast.currentTimer = null
      }

      if (Toast.currentContentNode && Toast.ctx) {
        Toast.ctx.getPromptAction()
          .closeCustomDialog(Toast.currentContentNode)
          .then(() => {
            console.info('Toast closeCustomDialog complete.')
            Toast.currentContentNode = null
            resolve()
          })
          .catch((error: BusinessError) => {
            let message = (error as BusinessError).message
            let code = (error as BusinessError).code
            console.error(`Toast closeCustomDialog error code is ${code}, message is ${message}`)
            Toast.currentContentNode = null
            resolve()
          })
      } else {
        resolve()
      }
    })
  }
}

export default Toast