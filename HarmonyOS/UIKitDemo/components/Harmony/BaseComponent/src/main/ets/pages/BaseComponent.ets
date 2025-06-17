export default class BaseComponent {
  static imageRadius(): Resource {
    return $r("app.float.common_image_border_radius");
  }

  static titleFontColor(): Resource {
    return $r("app.color.common_title_text_font_color");
  }

  static contentFontColor(): Resource {
    return $r("app.color.common_content_text_font_color");
  }

  static paddingStartEnd(): Resource {
    return $r("app.float.common_item_common_padding_start_end");
  }

  static lightPrimaryColor(): Resource {
    return $r("app.color.common_light_primary_color");
  }

  static backIcon(): Resource {
    return $r("app.media.common_back_icon");
  }

  static forwardIcon(): Resource {
    return $r("app.media.common_forward_icon");
  }

  static defaultUserIcon() {
    return $r("app.media.core_default_user_icon");
  }

  static defaultReplaceImage() {
    return $r("app.media.common_image_replace_icon");
  }
}