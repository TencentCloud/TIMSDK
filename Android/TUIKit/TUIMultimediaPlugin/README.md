1 如果需要开通高级功能试用和了解更多信息，请访问官方文档：https://cloud.tencent.com/document/product/269/113290

2 如果不需要开通高级功能，您可以手动屏蔽对应功能
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
  
 3 如果您没有开通高级功能，或者高级功能失效，Release版本会自动为您屏蔽相应的功能
  
  
  
  

1 If you need to activate a trial of premium features or learn more, please visit the official documentation:
https://cloud.tencent.com/document/product/269/113290

2 If you do not need to activate advanced features, you can manually disable the corresponding functions.
You can directly disable advanced features in the configuration file: File location: assets/config/default_config.json.
The features that need to be disabled are:
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


3 If you have not activated advanced features, or if the advanced features have expired, 
the Release version will automatically disable the corresponding functions for you.

