import Prompt from '@system.prompt'

export default class Toast {
  static shortToast(text: string, bottom?: string | number) {
    Prompt.showToast({
      message: text,
      bottom: bottom
    });
  }

  static longToast(text: string, bottom?: string | number) {
    Prompt.showToast({
      message: text,
      duration: 3000,
      bottom: bottom
    });
  }
}