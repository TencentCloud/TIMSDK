export class BaseComponent {
  // static backIcon(): Resource {
  //   return $rawfile("basecomponent/common_back_icon.svg");
  // }

  // static forwardIcon(): Resource {
  //   return $rawfile("basecomponent/common_forward_icon.svg");
  // }

  static defaultUserIcon() {
    return $rawfile("basecomponent/core_default_user_icon.png");
  }

  static defaultReplaceImage() {
    return $rawfile("basecomponent/common_image_replace_icon.png");
  }
}