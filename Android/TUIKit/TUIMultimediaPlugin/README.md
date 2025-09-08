1 如果需要开通高级功能试用和了解更多信息，请访问官方文档：https://cloud.tencent.com/document/product/269/113290
2 如果不需要开通高级功能，需要先屏蔽部份功能才能正常使用，否则即使去掉弹窗，功能也会出现异常。
  可以在配置文件中直接屏蔽高级功能:配置文件位置：assets/config/default_config.json,
  需要屏蔽的功能有：
  {
  	"support_record_beauty": "false",
  	"support_record_scroll_filter": "false",
  	"support_video_edit_graffiti": "false",
  	"support_video_edit_paster": "false",
  	"support_video_edit_subtitle": "false",
  	"support_video_edit_bgm": "false",
  	"support_picture_edit_graffiti": "false",
  	"support_picture_edit_mosaic": "false",
  	"support_picture_edit_paster": "false",
  	"support_picture_edit_subtitle": "false",
  	"support_picture_edit_crop": "false",
  	"support_album_picker_edit": "false",
  	"support_album_picker_transcode_select": "false"
  }
  要屏蔽某个功能将对应的配置选设置为"false",打开设置为"true"即可。
  
  
  
  

1 If you need to activate a trial of premium features or learn more, please visit the official documentation:
https://cloud.tencent.com/document/product/269/113290

2 If you choose not to activate premium features, you must disable certain functionalities for normal operation. Otherwise, features may malfunction even after dismissing pop-up notifications.
Configuration file adjustments are required: assets/config/default_config.json
Set the following features to "false":
{
  "support_record_beauty": "false",
  "support_record_scroll_filter": "false",
  "support_video_edit_graffiti": "false",
  "support_video_edit_paster": "false",
  "support_video_edit_subtitle": "false",
  "support_video_edit_bgm": "false",
  "support_picture_edit_graffiti": "false",
  "support_picture_edit_mosaic": "false",
  "support_picture_edit_paster": "false",
  "support_picture_edit_subtitle": "false",
  "support_picture_edit_crop": "false",
  "support_album_picker_edit": "false",
  "support_album_picker_transcode_select": "false"
}
Toggle features by setting values to "true" (enable) or "false" (disable)
