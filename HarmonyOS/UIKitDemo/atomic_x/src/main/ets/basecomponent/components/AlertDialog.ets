import { ThemeState } from '../theme/ThemeState'
import { BusinessError } from '@kit.BasicServicesKit'
import { ComponentContent, promptAction } from '@kit.ArkUI'
import { UIContext } from '@ohos.arkui.UIContext'
interface SingleButtonAlertDialogParams {
  message?: string
  confirmText?: string
  onDismiss?: () => void
  onConfirm?: () => void
}
interface DoubleButtonAlertDialogParams {
  title?: string
  message?: string
  cancelText?: string
  confirmText?: string
  onDismiss?: () => void
  onCancel?: () => void
  onConfirm?: () => void
}
@Component
struct SingleButtonAlertDialog {
  @Prop message?: string
  @Prop confirmText: string = '我知道了'
  onDismiss?: () => void
  onConfirm?: () => void
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()

  build() {
    Column() {
      
      Column() {
        if (this.message && this.message.length > 0) {
          Text(this.message)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('100%')
        }
      }
      .width('100%')
      .constraintSize({
        minHeight: 88,
        maxHeight: 424
      })
      .padding({
        left: 24,
        right: 24,
        top: 32,
        bottom: 20
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      
      Column() {
        // Divider
        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor(this.themeState.colors.strokeColorModule)

        
        Text(this.confirmText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.colors.textColorLink)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .height(56)
          .padding({
            top: 16,
            bottom: 16,
            left: 20,
            right: 20
          })
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm()
            }
            if (this.onDismiss) {
              this.onDismiss()
            }
            AlertDialog.closeDialog()
          })
      }
      .width('100%')
    }
    .width(327)
    .constraintSize({
      minHeight: 134,
      maxHeight: 480
    })
    .backgroundColor(this.themeState.colors.bgColorDialog)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Center)
  }
}
@Component
struct DoubleButtonAlertDialog {
  @Prop title?: string
  @Prop message?: string
  @Prop cancelText: string = '取消'
  @Prop confirmText: string = '确定'
  onDismiss?: () => void
  onCancel?: () => void
  onConfirm?: () => void
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance()

  build() {
    Column() {
      
      Column() {
        if (this.title && this.title.length > 0) {
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
            .lineHeight(26)
            .width('100%')

          if (this.message && this.message.length > 0) {
            Row().height(12) // Spacer
          }
        }

        if (this.message && this.message.length > 0) {
          Text(this.message)
            .fontSize(16)
            .fontWeight(FontWeight.Normal)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('100%')
        }
      }
      .width('100%')
      .constraintSize({
        minHeight: 134,
        maxHeight: 424
      })
      .padding({
        left: 24,
        right: 24,
        top: 32,
        bottom: 20
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      
      Column() {
        // Divider
        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor(this.themeState.colors.strokeColorModule)

        
        Row() {
          
          Text(this.cancelText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('50%')
            .height(56)
            .padding({
              top: 16,
              bottom: 16,
              left: 20,
              right: 20
            })
            .onClick(() => {
              if (this.onCancel) {
                this.onCancel()
              }
              if (this.onDismiss) {
                this.onDismiss()
              }
              AlertDialog.closeDialog()
            })

          
          Row()
            .width(0.5)
            .height(56)
            .backgroundColor(this.themeState.colors.strokeColorModule)

          
          Text(this.confirmText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.colors.textColorLink)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('50%')
            .height(56)
            .padding({
              top: 16,
              bottom: 16,
              left: 20,
              right: 20
            })
            .onClick(() => {
              if (this.onConfirm) {
                this.onConfirm()
              }
              if (this.onDismiss) {
                this.onDismiss()
              }
              AlertDialog.closeDialog()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(56)
    }
    .width(327)
    .constraintSize({
      minHeight: 190,
      maxHeight: 480
    })
    .backgroundColor(this.themeState.colors.bgColorDialog)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Center)
  }
}
@Component
struct SingleButtonAlertDialogComponent {
  @Prop message?: string
  @Prop confirmText: string = '我知道了'
  onDismiss?: () => void
  onConfirm?: () => void

  build() {
    SingleButtonAlertDialog({
      message: this.message,
      confirmText: this.confirmText,
      onDismiss: this.onDismiss,
      onConfirm: this.onConfirm
    })
  }
}

@Component
struct DoubleButtonAlertDialogComponent {
  @Prop title?: string
  @Prop message?: string
  @Prop cancelText: string = '取消'
  @Prop confirmText: string = '确定'
  onDismiss?: () => void
  onCancel?: () => void
  onConfirm?: () => void

  build() {
    DoubleButtonAlertDialog({
      title: this.title,
      message: this.message,
      cancelText: this.cancelText,
      confirmText: this.confirmText,
      onDismiss: this.onDismiss,
      onCancel: this.onCancel,
      onConfirm: this.onConfirm
    })
  }
}
@Builder
function SingleButtonAlertDialogBuilder(params: SingleButtonAlertDialogParams) {
  SingleButtonAlertDialogComponent({
    message: params.message,
    confirmText: params.confirmText ?? '我知道了',
    onDismiss: params.onDismiss,
    onConfirm: params.onConfirm
  })
}

@Builder
function DoubleButtonAlertDialogBuilder(params: DoubleButtonAlertDialogParams) {
  DoubleButtonAlertDialogComponent({
    title: params.title,
    message: params.message,
    cancelText: params.cancelText ?? '取消',
    confirmText: params.confirmText ?? '确定',
    onDismiss: params.onDismiss,
    onCancel: params.onCancel,
    onConfirm: params.onConfirm
  })
}
export class AlertDialog {
  private static currentContentNode: ComponentContent<SingleButtonAlertDialogParams | DoubleButtonAlertDialogParams> | null =
    null
  private static ctx: UIContext

  
  static show(
    message?: string,
    confirmText?: string,
    onDismiss?: () => void,
    onConfirm?: () => void,
    context?: UIContext
  ): void
  
  static show(
    title?: string,
    message?: string,
    cancelText?: string,
    confirmText?: string,
    onDismiss?: () => void,
    onCancel?: () => void,
    onConfirm?: () => void,
    context?: UIContext
  ): void
  static show(
    param1?: string,
    param2?: string,
    param3?: string | (() => void),
    param4?: string | (() => void),
    param5?: (() => void) | UIContext,
    param6?: (() => void) | UIContext,
    param7?: (() => void),
    param8?: UIContext
  ) {
    
    if (arguments.length <= 5) {
      
      const message = param1
      const confirmText = param2
      const onDismiss = typeof param3 === 'function' ? param3 : undefined
      const onConfirm = typeof param4 === 'function' ? param4 : (typeof param3 === 'function' ? param3 : undefined)
      const context = (param5 && typeof param5 !== 'function') ? param5 as UIContext : undefined

      AlertDialog.showSingleButton(message, confirmText, onDismiss, onConfirm, context)
    } else {
      
      const title = param1
      const message = param2
      const cancelText = typeof param3 === 'string' ? param3 : undefined
      const confirmText = typeof param4 === 'string' ? param4 : undefined
      const onDismiss = typeof param5 === 'function' ? param5 : undefined
      const onCancel = typeof param6 === 'function' ? param6 : undefined
      const onConfirm = typeof param7 === 'function' ? param7 : undefined
      const context = param8 as UIContext

      AlertDialog.showDoubleButton(title, message, cancelText, confirmText, onDismiss, onCancel, onConfirm, context)
    }
  }

  
  private static showSingleButton(
    message?: string,
    confirmText?: string,
    onDismiss?: () => void,
    onConfirm?: () => void,
    context?: UIContext
  ) {
    if (context) {
      AlertDialog.ctx = context
    }

    
    if (AlertDialog.currentContentNode) {
      AlertDialog.closeDialog()
    }

    const params: SingleButtonAlertDialogParams = {
      message: message,
      confirmText: confirmText ?? '我知道了',
      onDismiss: onDismiss,
      onConfirm: onConfirm ?? onDismiss
    }

    AlertDialog.currentContentNode = new ComponentContent(
      AlertDialog.ctx,
      wrapBuilder(SingleButtonAlertDialogBuilder),
      params
    )

    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      autoCancel: false,
      maskColor: 'rgba(0, 0, 0, 0.6)'
    }

    AlertDialog.ctx.getPromptAction()
      .openCustomDialog(AlertDialog.currentContentNode, options)
      .then(() => {
        console.info('SingleButtonAlertDialog openCustomDialog complete.')
      })
      .catch((error: BusinessError) => {
        let message = (error as BusinessError).message
        let code = (error as BusinessError).code
        console.error(`SingleButtonAlertDialog openCustomDialog error code is ${code}, message is ${message}`)
      })
  }

  
  private static showDoubleButton(
    title?: string,
    message?: string,
    cancelText?: string,
    confirmText?: string,
    onDismiss?: () => void,
    onCancel?: () => void,
    onConfirm?: () => void,
    context?: UIContext
  ) {
    if (context) {
      AlertDialog.ctx = context
    }

    
    if (AlertDialog.currentContentNode) {
      AlertDialog.closeDialog()
    }

    const params: DoubleButtonAlertDialogParams = {
      title: title,
      message: message,
      cancelText: cancelText ?? '取消',
      confirmText: confirmText ?? '确定',
      onDismiss: onDismiss,
      onCancel: onCancel,
      onConfirm: onConfirm
    }

    AlertDialog.currentContentNode = new ComponentContent(
      AlertDialog.ctx,
      wrapBuilder(DoubleButtonAlertDialogBuilder),
      params
    )

    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      autoCancel: false,
      maskColor: 'rgba(0, 0, 0, 0.6)'
    }

    AlertDialog.ctx.getPromptAction()
      .openCustomDialog(AlertDialog.currentContentNode, options)
      .then(() => {
        console.info('DoubleButtonAlertDialog openCustomDialog complete.')
      })
      .catch((error: BusinessError) => {
        let message = (error as BusinessError).message
        let code = (error as BusinessError).code
        console.error(`DoubleButtonAlertDialog openCustomDialog error code is ${code}, message is ${message}`)
      })
  }

  
  static closeDialog() {
    if (AlertDialog.currentContentNode && AlertDialog.ctx) {
      AlertDialog.ctx.getPromptAction()
        .closeCustomDialog(AlertDialog.currentContentNode)
        .then(() => {
          console.info('AlertDialog closeCustomDialog complete.')
          AlertDialog.currentContentNode = null
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message
          let code = (error as BusinessError).code
          console.error(`AlertDialog closeCustomDialog error code is ${code}, message is ${message}`)
        })
    }
  }
}
export default AlertDialog 