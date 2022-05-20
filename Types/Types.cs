using com.tencent.imsdk.unity.enums;
using System.Collections.Generic;
using System;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace com.tencent.imsdk.unity.types
{



    [JsonObject(MemberSerialization.OptOut)]
    public class SdkConfig : ExtraData
    {
        /// <value>只写，SDK配置本地路径</value>
        public string sdk_config_config_file_path = System.IO.Directory.GetCurrentDirectory() + "/.TIM-Config";
        /// <value>只写，SDK日志本地路径</value>
        public string sdk_config_log_file_path = System.IO.Directory.GetCurrentDirectory() + "/.TIM-Log";
        /// <value> uint64, 只写(选填), 配置Android平台的Java虚拟机指针</value>
        public ulong? sdk_config_java_vm;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class ConvParam : ExtraData
    {
        /// <value>只写, 会话类型</value>
        public TIMConvType get_conversation_list_param_conv_type ;
        /// <value>只写, 会话ID</value>
        public string get_conversation_list_param_conv_id ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class UserProfileCustemStringInfo : ExtraData
    {
        /// <value>只写, 用户自定义资料字段的key值（包含前缀Tag_Profile_Custom_）</value>
        public string user_profile_custom_string_info_key ;
        /// <value>只写, 该字段对应的字符串值</value>
        public string user_profile_custom_string_info_value ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class UserProfile : ExtraData
    {
        /// <value>只读, 用户ID</value>
        public string user_profile_identifier ;
        /// <value>只读, 用户的昵称</value>
        public string user_profile_nick_name ;
        /// <value>只读, 性别</value>
        public TIMGenderType user_profile_gender ;
        /// <value>只读, 用户头像URL</value>
        public string user_profile_face_url ;
        /// <value>只读, 用户个人签名</value>

        public string user_profile_self_signature ;
        /// <value>只读, 用户加好友的选项</value>
        public TIMProfileAddPermission user_profile_add_permission ;
        /// <value>只读, 用户位置信息</value>

        public string user_profile_location ;
        /// <value>只读, 语言</value>

        public uint user_profile_language ;
        /// <value>只读, 生日</value>

        public uint user_profile_birthday ;
        /// <value>只读, 等级</value>

        public uint user_profile_level ;
        /// <value>只读, 角色</value>
        public uint user_profile_role ;
        /// <value>只读, 请参考[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)</value>

        public List<UserProfileCustemStringInfo> user_profile_custom_string_array ;
    }




    [JsonObject(MemberSerialization.OptOut)]
    public class Message : ExtraData
    {
        /// <value>读写(必填), 消息内元素列表</value>
        public List<Elem> message_elem_array ;
        /// <value>读写(选填),       消息所属会话ID</value>
        public string message_conv_id ;
        /// <value>读写(选填), 消息所属会话类型</value>
        public TIMConvType? message_conv_type ;
        /// <value>读写(选填),       消息的发送者</value>
        public string message_sender ;
        /// <value>读写(选填), 消息优先级</value>
        public TIMMsgPriority? message_priority ;
        /// <value>读写(选填),       客户端时间</value>
        public ulong? message_client_time ;
        /// <value>读写(选填),       服务端时间</value>
        public ulong? message_server_time ;
        /// <value>读写(选填),       消息是否来自自己</value>
        public bool? message_is_from_self ;
        /// <value>读写(选填), 发送消息的平台</value>
        public TIMPlatform? message_platform ;
        /// <value>读写(选填),       消息是否已读</value>
        public bool? message_is_read ;
        /// <value>读写(选填),       消息是否是在线消息，false表示普通消息,true表示阅后即焚消息，默认为false</value>
        public bool? message_is_online_msg ;
        /// <value>只读,            消息是否被会话对方已读</value>
        public bool? message_is_peer_read ;
        /// <value>读写(选填),    消息是否需要已读回执（6.1 以上版本有效，需要您购买旗舰版套餐），群消息在使用该功能之前，需要先到 IM 控制台设置已读回执支持的群类型</value>
        public bool? message_need_read_receipt ;
        /// <value>只读,         是否已经发送了已读回执（只有Group 消息有效）</value>
        public bool? message_has_sent_receipt ;
        /// <value>只读,         注意：这个字段是内部字段，不推荐使用，推荐调用 TIMMsgGetMessageReadReceipts 获取群消息已读回执</value>
        public int? message_group_receipt_read_count ;
        /// <value>只读,         注意：这个字段是内部字段，不推荐使用，推荐调用 TIMMsgGetMessageReadReceipts 获取群消息已读回执</value>
        public int? message_group_receipt_unread_count ;
        /// <value>只读，注意：这个字段是内部字段，不推荐使用</value>
        public ulong? message_version;
        /// <value>读写(选填), 消息当前状态</value>
        public TIMMsgStatus? message_status ;
        /// <value>只读,       消息的唯一标识，推荐使用 kTIMMsgMsgId</value>
        public ulong message_unique_id ;

        /// <value>只读,       消息的唯一标识</value>
        public string message_msg_id ;
        /// <value> 只读,       消息的随机码</value>
        public ulong message_rand ;
        /// <value>只读,       消息序列</value>
        public ulong message_seq ;
        /// <value>读写(选填), 自定义整数值字段（本地保存，不会发送到对端，程序卸载重装后失效）</value>
        public int? message_custom_int ;
        /// <value>读写(选填), 自定义数据字段（本地保存，不会发送到对端，程序卸载重装后失效）</value>
        public string message_custom_str ;
        /// <value>读写(选填), 消息自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）</value>
        public string message_cloud_custom_str ;
        /// <value>读写(选填),  消息是否不计入未读计数：默认为 NO，表明需要计入未读计数，设置为 YES，表明不需要计入未读计数</value>
        public bool? message_is_excluded_from_unread_count ;

        /// <value>读写(选填),  是否是转发消息</value>
        public bool? message_is_forward_message ;

        /// <value>读写(选填), 群消息中被 @ 的用户 UserID 列表（即该消息都 @ 了哪些人），如果需要 @ALL ，请传入 kImSDK_MesssageAtALL 字段</value>
        public List<string> message_group_at_user_array ;
        /// <value>读写(选填), 消息的发送者的用户资料</value>
        public UserProfile message_sender_profile ;
        /// <value>读写(选填), 消息发送者在群里面的信息，只有在群会话有效。目前仅能获取字段 kTIMGroupMemberInfoIdentifier、kTIMGroupMemberInfoNameCard 其他的字段建议通过 TIMGroupGetMemberInfoList 接口获取</value>
        public GroupMemberInfo message_sender_group_member_info ;
        /// <value>只写(选填), 指定群消息接收成员（定向消息）；不支持群 @ 消息设置，不支持社群（Community）和直播群（AVChatRoom）消息设置；该字段设置后，消息会不计入会话未读数。</value>
        public List<string> message_target_group_member_array ;
        /// <value>读写(选填), 消息的离线推送设置</value>
        public OfflinePushConfig message_offlie_push_config ;
        /// <value>读写 是否作为会话的 lasgMessage，true - 不作为，false - 作为</value>
        public bool message_excluded_from_last_message ;

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class OfflinePushConfig : ExtraData
    {
        /// <value>读写, 当前消息在对方收到离线推送时候展示内容</value>
        public string offline_push_config_desc ; // 文本消息
        /// <value>读写, 当前消息离线推送时的扩展字段</value>
        public string offline_push_config_ext ; // 文本消息
        /// <value>读写, 当前消息是否允许推送，默认允许推送 kTIMOfflinePushFlag_Default</value>
        public TIMOfflinePushFlag offline_push_config_flag ; // 文本消息
        /// <value>读写, iOS离线推送配置</value>
        public IOSOfflinePushConfig offline_push_config_ios_config ; // 文本消息
        /// <value>读写, Android离线推送配置</value>
        public AndroidOfflinePushConfig offline_push_config_android_config ; // 文本消息
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class IOSOfflinePushConfig : ExtraData
    {
        /// <value>读写, 通知标题</value>
        public string ios_offline_push_config_title ; // 文本消息
        /// <value>读写, 当前消息在iOS设备上的离线推送提示声音URL。当设置为push.no_sound时表示无提示音无振动</value>
        public string ios_offline_push_config_sound ; // 文本消息
        /// <value>读写, 是否忽略badge计数。若为true，在iOS接收端，这条消息不会使App的应用图标未读计数增加</value>
        public bool ios_offline_push_config_ignore_badge ; // 文本消息
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class AndroidOfflinePushConfig : ExtraData
    {


        /// <value>读写, 通知标题</value>
        public string android_offline_push_config_title ; // 文本消息
        /// <value>读写, 当前消息在Android设备上的离线推送提示声音URL</value>
        public string android_offline_push_config_sound ; // 文本消息
        /// <value>读写, 当前消息的通知模式</value>
        public TIMAndroidOfflinePushNotifyMode android_offline_push_config_notify_mode ; // 文本消息
        /// 读写，离线推送设置 VIVO 手机 （仅对 Android 生效），VIVO 手机离线推送消息分类，0：运营消息，1：系统消息。默认取值为 1 。
        public int android_offline_push_config_vivo_classification = 1;
        /// <value>读写, OPPO的ChannelID</value>
        public string android_offline_push_config_oppo_channel_id ; // 文本消息

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class Elem : ExtraData
    {
        /// <value>读写(必填), 元素类型</value>
        public TIMElemType elem_type ;
        /// <value>读写(必填), 文本内容</value>
        public string text_elem_content ; // 文本消息
        /// <value>读写(必填), 表情索引</value>
        public string face_elem_buf ; // 表情消息
        /// <value>读写(选填), 其他额外数据,可由用户自定义填写。若要传输二进制，麻烦先转码成字符串。JSON只支持字符串</value>
        public int face_elem_index ; // 表情消息
        /// <value>读写(选填), 位置描述</value>
        public string location_elem_desc ; // 位置消息
        /// <value>读写(必填), 经度</value>
        public double location_elem_longitude ; // 位置消息
        /// <value>读写(必填), 纬度</value>
        public double location_elem_latitude ; // 位置消息
        /// <value>读写(必填), 发送图片的路径</value>

        public string image_elem_orig_path ; // 图片消息
        /// <value>读写(必填), 发送图片的质量级别</value>
        public TIMImageLevel image_elem_level ; // 图片消息
        /// <value>读写,       发送图片格式:，0xff:未知格式, 1：JPG, 2:GIF, 3:PNG, 4:BMP</value>
        public int image_elem_format ; // 图片消息
        /// <value>只读,       原图 ID</value>
        public string image_elem_orig_id ; // 图片消息
        /// <value>只读,       原图的图片高度</value>
        public int image_elem_orig_pic_height ; // 图片消息
        /// <value>只读,       原图的图片宽度</value>
        public int image_elem_orig_pic_width ; // 图片消息
        /// <value>只读,       原图的图片大小</value>
        public int image_elem_orig_pic_size ; // 图片消息



        /// <value>只读,       缩略图 ID</value>
        public string image_elem_thumb_id ; // 图片消息
        /// <value>只读,       缩略图的图片高度</value>
        public int image_elem_thumb_pic_height ; // 图片消息
        /// <value>只读,       缩略图的图片宽度</value>
        public int image_elem_thumb_pic_width ; // 图片消息
        /// <value>只读,       缩略图的图片大小</value>
        public int image_elem_thumb_pic_size ; // 图片消息
        /// <value>只读,       大图片uuid</value>
        public string image_elem_large_id ; // 图片消息
        /// <value>只读,       大图片的图片高度</value>
        public int image_elem_large_pic_height ; // 图片消息
        /// <value>只读,       大图片的图片宽度</value>
        public int image_elem_large_pic_width ; // 图片消息
        /// <value>只读,       大图片的图片大小</value>
        public int image_elem_large_pic_size ; // 图片消息
        /// <value>只读,       原图URL</value>
        public string image_elem_orig_url ; // 图片消息
        /// <value>只读,       缩略图URL</value>
        public string image_elem_thumb_url ; // 图片消息
        /// <value>只读,       大图片URL</value>
        public string image_elem_large_url ; // 图片消息
        /// <value>只读,       任务ID，废弃</value>
        public int image_elem_task_id ; // 图片消息


        /// <value>读写(必填), 语音文件路径,需要开发者自己先保存语言然后指定路径</value>
        public string sound_elem_file_path ; // 声音消息
        /// <value>读写(必填), 语言数据文件大小，以秒为单位</value>

        public int sound_elem_file_size ; // 声音消息
        /// <value>读写(必填), 语音时长</value>


        public int sound_elem_file_time ; // 声音消息
        /// <value>只读,       语音 ID</value>

        public string sound_elem_file_id ; // 声音消息
        /// <value>只读,       下载时用到的businessID</value>

        public int sound_elem_business_id ; // 声音消息
        /// <value>只读,       是否需要申请下载地址(0:需要申请，1:到cos申请，2:不需要申请,直接拿url下载)</value>
        public int sound_elem_download_flag ; // 声音消息
        /// <value>只读,  下载的URL</value>
        public string sound_elem_url ; // 声音消息
        /// <value>只读,  任务ID，废弃</value>
        public int sound_elem_task_id ; // 声音消息
        /// <value>读写, 数据,支持二进制数据</value>




        public string custom_elem_data ; // 自定义消息
        /// <value>读写, 自定义描述</value>
        public string custom_elem_desc ; // 自定义消息
        /// <value>读写, 后台推送对应的ext字段</value>
        public string custom_elem_ext ; // 自定义消息
        /// <value>读写, 自定义声音</value>
        public string custom_elem_sound ; // 自定义消息
        /// <value>读写(必填), 文件所在路径（包含文件名）</value>



        public string file_elem_file_path ; // 文件消息
        /// <value>读写(必填), 文件名，显示的名称。不设置该参数时，kTIMFileElemFileName默认为kTIMFileElemFilePath指定的文件路径中的文件名</value>
        public string file_elem_file_name ; // 文件消息
        /// <value>读写(必填), 文件大小</value>
        public int file_elem_file_size ; // 文件消息
        /// <value>只读, 文件 ID</value>
        public string file_elem_file_id ; // 文件消息
        /// <value>只读, 下载时用到的businessID</value>
        public int file_elem_business_id ; // 文件消息
        /// <value>只读, 文件下载flag</value>
        public int file_elem_download_flag ; // 文件消息
        /// <value>只读, 文件下载的URL</value>
        public string file_elem_url ; // 文件消息
        /// <value>只读, 任务ID，废弃</value>
        public int file_elem_task_id ; // 文件消息


        /// <value>读写(必填), 视频文件类型，发送消息时进行设置</value>
        public string video_elem_video_type ; // 视频消息
        /// <value>读写(必填), 视频文件大小</value>
        public uint video_elem_video_size ; // 视频消息
        /// <value>读写(必填), 视频时长，发送消息时进行设置</value>
        public uint video_elem_video_duration ; // 视频消息
        /// <value>读写(必填), 适配文件路径</value>
        public string video_elem_video_path ; // 视频消息
        /// <value>只读, 视频 ID</value>
        public string video_elem_video_id ; // 视频消息
        /// <value>只读, 下载时用到的businessID</value>
        public int video_elem_business_id ; // 视频消息
        /// <value>只读, 视频文件下载flag</value>
        public int video_elem_video_download_flag ; // 视频消息
        /// <value>只读, 视频文件下载的URL </value>
        public string video_elem_video_url ; // 视频消息
        /// <value>读写(必填), 截图文件类型，发送消息时进行设置</value>

        public string video_elem_image_type ; // 视频消息
        /// <value>读写(必填), 截图文件大小</value>
        public uint video_elem_image_size ; // 视频消息
        /// <value>读写(必填), 截图高度，发送消息时进行设置</value>
        public uint video_elem_image_width ; // 视频消息
        /// <value>读写(必填), 截图宽度，发送消息时进行设置</value>
        public uint video_elem_image_height ; // 视频消息
        /// <value>读写(必填), 保存截图的路径</value>
        public string video_elem_image_path ; // 视频消息
        /// <value>只读, 截图 ID</value>
        public string video_elem_image_id ; // 视频消息
        /// <value>只读, 截图文件下载flag </value>
        public int video_elem_image_download_flag ; // 视频消息
        /// <value>只读, 截图文件下载的URL </value>
        public string video_elem_image_url ; // 视频消息
        /// <value>只读, 任务ID，废弃</value>
        public uint video_elem_task_id ; // 视频消息






        /// <value>读写(必填), 合并消息 title</value>
        public string merge_elem_title ; // 合并消息
        /// <value>读写(必填), 合并消息摘要列表</value>
        public List<string> merge_elem_abstract_array ; // 合并消息
        /// <value>读写(必填), 消息列表（最大支持 300 条，消息对象必须是 kTIMMsg_SendSucc 状态，消息类型不能为 GroupTipsElem 或 GroupReportElem）</value>
        public List<Message> merge_elem_message_array ; // 合并消息
        /// <value>读写(必填), 合并消息兼容文本，低版本 SDK 如果不支持合并消息，默认会收到一条文本消息，文本消息的内容为 compatibleText，该参数不能为空。</value>
        public string merge_elem_compatible_text ; // 合并消息
        /// <value>只读, 合并消息里面又包含合并消息我们称之为合并嵌套，合并嵌套层数不能超过 100 层，如果超过限制，layersOverLimit 会返回 YES，kTIMMergerElemTitle 和 kTIMMergerElemAbstractArray 为空，DownloadMergerMessage 会返回 ERR_MERGER_MSG_LAYERS_OVER_LIMIT 错误码。</value>
        public bool merge_elem_layer_over_limit ; // 合并消息
        /// <value>只读, native 端消息列表下载 key</value>
        public string merge_elem_relay_pb_key ; // 合并消息
        /// <value>只读, web 端消息列表下载 key</value>

        public string merge_elem_relay_json_key ; // 合并消息

        /// <value>只读, 转发消息的 buffer</value>
        public string merge_elem_relay_buffer ; // 合并消息



        /// <value>只读, 群消息类型</value>
        public TIMGroupTipType group_tips_elem_tip_type ; // 群组系统消息元素
        /// <value>只读, 操作者ID</value>
        public string group_tips_elem_op_user ; // 群组系统消息元素
        /// <value>只读, 群组名称</value>
        public string group_tips_elem_group_name ; // 群组系统消息元素
        /// <value>只读, 群组ID</value>

        public string group_tips_elem_group_id ; // 群组系统消息元素
        /// <value>只读, 群消息时间，废弃</value>
        public uint group_tips_elem_time ; // 群组系统消息元素
        /// <value>只读, 被操作的帐号列表</value>
        public List<string> group_tips_elem_user_array ; // 群组系统消息元素
        /// <value>只读, 群资料变更信息列表,仅当 tips_type 值为 kTIMGroupTip_GroupInfoChange 时有效</value>
        public List<GroupTipGroupChangeInfo> group_tips_elem_group_change_info_array ; // 群组系统消息元素
        /// <value>只读, 群成员变更信息列表,仅当 tips_type 值为 kTIMGroupTip_MemberInfoChange 时有效</value>
        public List<GroupTipMemberChangeInfo> group_tips_elem_member_change_info_array ; // 群组系统消息元素
        /// <value>只读, 操作者个人资料</value>

        public UserProfile group_tips_elem_op_user_info ; // 群组系统消息元素
        /// <value>只读, 群成员信息</value>
        public GroupMemberInfo group_tips_elem_op_group_memberinfo ; // 群组系统消息元素
        /// <value>只读, 被操作者列表资料</value>
        public List<UserProfile> group_tips_elem_changed_user_info_array ; // 群组系统消息元素
        /// <value>只读, 群成员信息列表</value>
        public List<GroupMemberInfo> group_tips_elem_changed_group_memberinfo_array ; // 群组系统消息元素
        /// <value>只读, 当前群成员数,只有当事件消息类型为 kTIMGroupTip_Invite 、 kTIMGroupTip_Quit 、 kTIMGroupTip_Kick 时有效</value>
        public uint group_tips_elem_member_num ; // 群组系统消息元素
        /// <value>只读, 操作方平台信息</value>

        public string group_tips_elem_platform ; // 群组系统消息元素

        /// <value>只读, 类型</value>
        public TIMGroupReportType group_report_elem_report_type ; // 群组系统通知元素(针对个人)
        /// <value>只读, 群组ID</value>
        public string group_report_elem_group_id ; // 群组系统通知元素(针对个人)
        /// <value>只读, 群组名称</value>
        public string group_report_elem_group_name ; // 群组系统通知元素(针对个人)
        /// <value>只读, 操作者ID</value>
        public string group_report_elem_op_user ; // 群组系统通知元素(针对个人)
        /// <value>只读, 操作理由</value>
        public string group_report_elem_msg ; // 群组系统通知元素(针对个人)
        /// <value>只读, 操作者填的自定义数据</value>
        public string group_report_elem_user_data ; // 群组系统通知元素(针对个人)
        /// <value>只读, 操作者个人资料</value>
        public UserProfile group_report_elem_op_user_info ; // 群组系统通知元素(针对个人)
        /// <value>只读,操作者群内资料</value>
        public GroupMemberInfo group_report_elem_op_group_memberinfo ; // 群组系统通知元素(针对个人)
        /// <value>只读, 操作方平台信息</value>
        public string group_report_elem_platform ;

        /// <value>只读, 资料变更类型</value>
        public TIMProfileChangeType profile_change_elem_change_type ; // GroupMemberInfo
        /// <value>只读, 资料变更用户的UserID</value>
        public string profile_change_elem_from_identifer ; // GroupMemberInfo
        /// <value>只读, 具体的变更信息，只有当 change_type 为 kTIMProfileChange_Profile 时有效</value>
        public UserProfileItem profile_change_elem_user_profile_item ; // GroupMemberInfo
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class UserProfileItem : ExtraData
    {
        /// <value>只写, 修改用户昵称</value>
        public string user_profile_item_nick_name ; // UserProfileItem
        /// <value>只写, 修改用户性别</value>
        public TIMGenderType user_profile_item_gender ; // UserProfileItem
        /// <value>只写, 修改用户头像</value>
        public string user_profile_item_face_url ; // UserProfileItem
        /// <value>只写, 修改用户签名</value>
        public string user_profile_item_self_signature ; // UserProfileItem
        /// <value>只写, 修改用户加好友的选项</value>
        public TIMProfileAddPermission user_profile_item_add_permission ; // UserProfileItem
        /// <value>只写, 修改位置</value>
        public string user_profile_item_location ; // UserProfileItem
        /// <value>只写, 修改语言</value>
        public uint user_profile_item_language ; // UserProfileItem
        /// <value>只写, 修改生日</value>
        public uint user_profile_item_birthday ; // UserProfileItem
        /// <value>只写, 修改等级</value>
        public uint user_profile_item_level ; // UserProfileItem
        /// <value>只写, 修改角色</value>
        public uint user_profile_item_role ; // UserProfileItem
        /// <value>只写, 修改[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)</value>
        public List<UserProfileCustemStringInfo> user_profile_item_custom_string_array ; // UserProfileItem

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupMemberInfo : ExtraData
    {
        /// <value>读写(必填), 群组成员ID</value>
        public string group_member_info_identifier ; // GroupMemberInfo
        /// <value>只读, 群组 ID</value>
        public string group_member_info_group_id ; // GroupMemberInfo
        /// <value>只读, 群组成员加入时间</value>
        public uint group_member_info_join_time ; // GroupMemberInfo
        /// <value>读写(选填), 群组成员角色</value>

        public TIMGroupMemberRole group_member_info_member_role ; // GroupMemberInfo
        /// <value>只读, 成员接收消息的选项</value>
        public TIMReceiveMessageOpt group_member_info_msg_flag ; // GroupMemberInfo
        /// <value>只读, 消息序列号</value>
        public uint group_member_info_msg_seq ; // GroupMemberInfo
        /// <value>只读, 成员禁言时间</value>
        public uint group_member_info_shutup_time ; // GroupMemberInfo
        /// <value>只读, 成员群名片</value>
        public string group_member_info_name_card ; // GroupMemberInfo
        /// <value>只读, 好友昵称</value>

        public string group_member_info_nick_name ; // GroupMemberInfo
        /// <value>只读，好友备注</value>
        public string group_member_info_remark;    // string, 只读, 好友备注
        /// <value>只读, 好友头像</value>
        public string group_member_info_face_url ; // GroupMemberInfo
        /// <value>只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<GroupMemberInfoCustemString> group_member_info_custom_info ; // GroupMemberInfo

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupTipGroupChangeInfo : ExtraData
    {
        /// <value>只读, 群消息修改群信息标志</value>
        public TIMGroupTipGroupChangeFlag group_tips_group_change_info_flag ;
        /// <value>只读, 自定义信息对应的 key 值，只有 info_flag 为 kTIMGroupTipChangeFlag_Custom 时有效</value>
        public string group_tips_group_change_info_key ;
        /// <value>只读, 修改的后值,不同的 info_flag 字段,具有不同的含义</value>
        public string group_tips_group_change_info_value ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupMemberInfoCustemString : ExtraData
    {
        /// <value>只写, 自定义字段的key</value>
        public string group_member_info_custom_string_info_key ; // GroupMemberInfoCustemString
        /// <value>只写, 自定义字段的value</value>
        public string group_member_info_custom_string_info_value ; // GroupMemberInfoCustemString


    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupTipMemberChangeInfo : ExtraData
    {
        /// <value>只读, 群组成员ID</value>
        public string group_tips_member_change_info_identifier ;
        /// <value>只读, 禁言时间</value>
        public uint group_tips_member_change_info_shutupTime ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class DraftParam : ExtraData
    {

        /// <value>只读, 草稿最新编辑时间</value>
        public ulong draft_edit_time ;
        /// <value>只读, 用户自定义数据</value>
        public string draft_user_define ;
        /// <value>只读, 草稿内的消息</value>

        public Message draft_msg ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class MsgLocator : ExtraData
    {

        /// <value>读写,      要查找的消息所属的会话ID</value>
        public string message_locator_conv_id ;
        /// <value>读写,      要查找的消息所属的会话类型</value>
        public TIMConvType message_locator_conv_type ;
        /// <value>读写(必填), 要查找的消息是否是被撤回。true表示被撤回的，false表示未撤回的。默认为false</value>
        public bool message_locator_is_revoked ;
        /// <value>读写(必填), 要查找的消息的时间戳</value>
        public ulong message_locator_time ;
        /// <value>读写(必填), 要查找的消息的序列号</value>
        public ulong message_locator_seq ;
        /// <value>读写(必填), 要查找的消息的发送者是否是自己。true表示发送者是自己，false表示发送者不是自己。默认为false</value>
        public bool message_locator_is_self ;
        /// <value>读写(必填), 要查找的消息随机码</value>
        public ulong message_locator_rand ;
        /// <value>读写(必填), 要查找的消息的唯一标识</value>
        public ulong message_locator_unique_id ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class MsgGetMsgListParam : ExtraData
    {

        /// <value>只写(选填), 指定的消息，不允许为null</value>
        public Message msg_getmsglist_param_last_msg ;
        /// <value>只写(选填), 从指定消息往后的消息数</value>
        public uint? msg_getmsglist_param_count;
        /// <value>只写(选填), 是否漫游消息</value>
        public bool? msg_getmsglist_param_is_remble;
        /// <value>只写(选填), 是否向前排序</value>
        public bool? msg_getmsglist_param_is_forward;
        /// <value>只写(选填), 指定的消息的 seq</value>
        public ulong? msg_getmsglist_param_last_msg_seq;
        /// <value>只写(选填), 开始时间；UTC 时间戳， 单位：秒</value>
        public ulong? msg_getmsglist_param_time_begin;
        /// <value>只写(选填), 持续时间；单位：秒</value>
        public ulong? msg_getmsglist_param_time_period;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class MsgDeleteParam : ExtraData
    {


        /// <value>只写(选填), 要删除的消息</value>
        public Message msg_delete_param_msg ;
        /// <value>只写(选填), 是否删除本地/漫游所有消息。true删除漫游消息，false删除本地消息，默认值false</value>
        public bool? msg_delete_param_is_remble ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class DownloadElemParam : ExtraData
    {

        /// <value>只写, 从消息元素里面取出来,元素的下载类型</value>
        public uint msg_download_elem_param_flag ;
        /// <value>只写, 从消息元素里面取出来,元素的类型</value>
        public TIMDownloadType msg_download_elem_param_type ;
        /// <value>只写, 从消息元素里面取出来,元素的ID</value>
        public string msg_download_elem_param_id ;
        /// <value>只写, 从消息元素里面取出来,元素的BusinessID</value>
        public uint msg_download_elem_param_business_id ;
        /// <value>只写, 从消息元素里面取出来,元素URL</value>
        public string msg_download_elem_param_url ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class MsgBatchSendParam : ExtraData
    {

        /// <value>只写(必填), 接收群发消息的用户 ID 列表</value>
        public List<string> msg_batch_send_param_identifier_array ;
        /// <value>只写(必填), 群发的消息</value>
        public Message msg_batch_send_param_msg ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class MessageSearchParam : ExtraData
    {

        /// <value>只写(必填)，搜索关键字列表，最多支持5个。</value>
        public List<string> msg_search_param_keyword_array ;
        /// <value>只写(选填), 指定搜索的消息类型集合，传入空数组，表示搜索支持的全部类型消息（FaceElem 和 GroupTipsElem 暂不支持）取值详见 TIMElemType。</value>
        public List<TIMElemType> msg_search_param_message_type_array ;
        /// <value>只写(选填)，会话 ID</value>
        public string msg_search_param_conv_id ;
        /// <value>只写(选填), 会话类型，如果设置 kTIMConv_Invalid，代表搜索全部会话。否则，代表搜索指定会话。</value>
        public TIMConvType? msg_search_param_conv_type ;
        /// <value>只写(选填), 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒</value>
        public ulong? msg_search_param_search_time_position ;
        /// <value>只写(选填), 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天。</value>
        public ulong? msg_search_param_search_time_period ;

        /// <value>
        /// 只写(选填), 分页的页号：用于分页展示查找结果，从零开始起步。首次调用：通过参数 pageSize = 10, pageIndex = 0 调用 searchLocalMessage，从结果回调中的 totalCount 可以获知总共有多少条结果。
        /// </value>
        public uint? msg_search_param_page_index ;
        /// <value>只写(选填), 每页结果数量：用于分页展示查找结果，如不希望分页可将其设置成 0，但如果结果太多，可能会带来性能问题。</value>
        public uint? msg_search_param_page_size ;
        /// <value>关键字进行 Or 或者 And 进行搜索</value>
        public TIMKeywordListMatchType msg_search_param_keyword_list_match_type ;
        /// <value>按照发送者的 userid 进行搜索</value>
        public List<string> msg_search_param_send_indentifier_array ;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class CreateGroupParam : ExtraData
    {

        /// <value>只写(必填), 群组名称</value>
        public string create_group_param_group_name ;
        /// <value>只写(选填), 群组ID,不填时创建成功回调会返回一个后台分配的群ID，如果创建社群（Community）需要自定义群组 ID ，那必须以 "@TGS#_" 作为前缀。</value>
        public string create_group_param_group_id ;
        /// <value>只写(选填), 群组类型,默认为Public</value>
        public TIMGroupType? create_group_param_group_type ;
        /// <value>只写(选填), 群组初始成员数组</value>
        public List<GroupMemberInfo> create_group_param_group_member_array ;
        /// <value>只写(选填), 群组公告</value>
        public string create_group_param_notification ;
        /// <value>只写(选填), 群组简介</value>
        public string create_group_param_introduction ;
        /// <value>只写(选填), 群组头像URL</value>
        public string create_group_param_face_url ;
        /// <value>只写(选填), 加群选项，默认为Any</value>
        public TIMGroupAddOption? create_group_param_add_option ;
        /// <value>只写(选填), 群组最大成员数</value>
        public uint? create_group_param_max_member_num ;
        /// <value>只读(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<GroupInfoCustemString> create_group_param_custom_info ;

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupInfoCustemString : ExtraData
    {

        /// <value>只写, 自定义字段的key</value>
        public string group_info_custom_string_info_key ;
        /// <value>只写, 自定义字段的value</value>
        public string group_info_custom_string_info_value ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupInviteMemberParam : ExtraData
    {

        /// <value>只写(必填), 群组ID</value>
        public string group_invite_member_param_group_id ;
        /// <value>只写(必填), 被邀请加入群组用户ID数组</value>
        public List<string> group_invite_member_param_identifier_array ;
        /// <value>只写(选填), 用于自定义数据</value>
        public string group_invite_member_param_user_data ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupDeleteMemberParam : ExtraData
    {

        /// <value>只写(必填), 群组ID</value>
        public string group_delete_member_param_group_id ;
        /// <value>只写(必填), 被删除群组成员数组</value>
        public List<string> group_delete_member_param_identifier_array ;
        /// <value>只写(选填), 用于自定义数据</value>
        public string group_delete_member_param_user_data ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupModifyInfoParam : ExtraData
    {


        /// <value>只写(必填), 群组ID</value>
        public string group_modify_info_param_group_id ;
        /// <value>只写(必填), 修改标识,可设置多个值按位或</value>
        public TIMGroupModifyInfoFlag group_modify_info_param_modify_flag ;
        /// <value>只写(选填), 修改群组名称,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_Name 时必填,其他情况不用填</value>
        public string group_modify_info_param_group_name ;
        /// <value>只写(选填), 修改群公告,        当 modify_flag 包含 kTIMGroupModifyInfoFlag_Notification 时必填,其他情况不用填</value>
        public string group_modify_info_param_notification ;
        /// <value>只写(选填), 修改群简介,        当 modify_flag 包含 kTIMGroupModifyInfoFlag_Introduction 时必填,其他情况不用填</value>
        public string group_modify_info_param_introduction ;
        /// <value>只写(选填), 修改群头像URL,     当 modify_flag 包含 kTIMGroupModifyInfoFlag_FaceUrl 时必填,其他情况不用填</value>
        public string group_modify_info_param_face_url ;
        /// <value>只写(选填), 修改加群方式,       当 modify_flag 包含 kTIMGroupModifyInfoFlag_AddOption 时必填,其他情况不用填</value>
        public TIMGroupAddOption? group_modify_info_param_add_option ;
        /// <value>只写(选填), 修改群最大成员数,    当 modify_flag 包含 kTIMGroupModifyInfoFlag_MaxMmeberNum 时必填,其他情况不用填</value>
        public uint? group_modify_info_param_max_member_num ;
        /// <value>只写(选填), 修改群是否可见,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_Visible 时必填,其他情况不用填</value>
        public uint? group_modify_info_param_visible ;
        /// <value>只写(选填), 修改群是否允许被搜索, 当 modify_flag 包含 kTIMGroupModifyInfoFlag_Searchable 时必填,其他情况不用填</value>
        public uint? group_modify_info_param_searchable ;
        /// <value>只写(选填), 修改群是否全体禁言,  当 modify_flag 包含 kTIMGroupModifyInfoFlag_ShutupAll 时必填,其他情况不用填</value>
        public bool? group_modify_info_param_is_shutup_all ;
        /// <value>只写(选填), 修改群主所有者,     当 modify_flag 包含 kTIMGroupModifyInfoFlag_Owner 时必填,其他情况不用填。此时 modify_flag 不能包含其他值，当修改群主时，同时修改其他信息已无意义</value>
        public string group_modify_info_param_owner ;
        /// <value>只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<GroupInfoCustemString> group_modify_info_param_custom_info ;

    }

    [JsonObject(MemberSerialization.OptOut)]
    public class OfflinePushToken : ExtraData
    {
        /// <value>只写（选填）, 注册应用到厂商平台或者 TPNS 时获取的 token。使用注意事项：当接入推送 TPNS 通道，需要设置 isTPNSToken 为 true，上报注册 TPNS 获取的 token；当接入推送为厂商通道，需要设置 isTPNSToken 为 false，上报注册厂商获取的 token。</value>
        public string offline_push_token_token ;
        /// <value>只写（选填），IM 控制台证书 ID，接入 TPNS 时不需要填写</value>
        public int? offline_push_token_business_id ;
        /// <value>只写（选填），是否接入配置 TPNS, token 是否是从 TPNS 获取</value>
        public bool? offline_push_token_is_tpns_token ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupGetMemberInfoListParam : ExtraData
    {


        /// <value>只写(必填), 群组ID</value>
        public string group_get_members_info_list_param_group_id ;
        /// <value>只写(选填), 群成员ID列表</value>
        public List<string> group_get_members_info_list_param_identifier_array ;
        /// <value>只写(选填), 获取群成员信息的选项</value>
        public GroupMemberGetInfoOption group_get_members_info_list_param_option ;
        /// <value>只写(选填), 分页拉取标志,第一次拉取填0,回调成功如果不为零,需要分页,调用接口传入再次拉取,直至为0</value>
        public ulong? group_get_members_info_list_param_next_seq ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupMemberGetInfoOption : ExtraData
    {

        /// <value>读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)</value>
        public TIMGroupMemberInfoFlag group_member_get_info_option_info_flag ;
        /// <value>读写(选填), 根据成员角色过滤，默认值为kTIMGroupMemberRoleFlag_All，获取所有角色</value>
        public TIMGroupMemberRoleFlag group_member_get_info_option_role_flag ;
        /// <value>只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<string> group_member_get_info_option_custom_array ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupModifyMemberInfoParam : ExtraData
    {

        /// <value>只写(必填), 群组ID</value>
        public string group_modify_member_info_group_id ;
        /// <value>只写(必填), 被设置信息的成员ID</value>
        public string group_modify_member_info_identifier ;
        /// <value>只写(必填), 修改类型,可设置多个值按位或</value>
        public TIMGroupMemberModifyInfoFlag group_modify_member_info_modify_flag ;
        /// <value>只写(选填), 修改消息接收选项,                  当 modify_flag 包含 kTIMGroupMemberModifyFlag_MsgFlag 时必填,其他情况不用填</value>
        public TIMReceiveMessageOpt? group_modify_member_info_msg_flag ;
        /// <value>只写(选填), 修改成员角色, 当 modify_flag 包含 kTIMGroupMemberModifyFlag_MemberRole 时必填,其他情况不用填</value>
        public TIMGroupMemberRole? group_modify_member_info_member_role ;
        /// <value>只写(选填), 修改禁言时间,                      当 modify_flag 包含 kTIMGroupMemberModifyFlag_ShutupTime 时必填,其他情况不用填</value>
        public uint? group_modify_member_info_shutup_time ;
        /// <value>只写(选填), 修改群名片,                        当 modify_flag 包含 kTIMGroupMemberModifyFlag_NameCard 时必填,其他情况不用填</value>
        public uint? group_modify_member_info_name_card ;
        /// <value>只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<GroupMemberInfoCustemString> group_modify_member_info_custom_info ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupPendencyOption : ExtraData
    {

        /// <value>只写(必填), 设置拉取时间戳,第一次请求填0,后边根据server返回的[GroupPendencyResult]()键kTIMGroupPendencyResultNextStartTime指定的时间戳进行填写</value>
        public ulong group_pendency_option_start_time ;
        /// <value>只写(选填), 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志</value>
        public uint? group_pendency_option_max_limited ;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupHandlePendencyParam : ExtraData
    {

        /// <value>只写(选填), true表示接受，false表示拒绝。默认为false</value>
        public bool? group_handle_pendency_param_is_accept ;
        /// <value>只写(选填), 同意或拒绝信息,默认为空字符串</value>
        public string group_handle_pendency_param_handle_msg ;
        /// <value>只写(必填), 未决信息详情</value>
        public GroupPendency group_handle_pendency_param_pendency ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupPendency : ExtraData
    {

        /// <value>读写, 群组ID</value>
        public string group_pendency_group_id ;
        /// <value>读写, 请求者的ID,例如：请求加群:请求者,邀请加群:邀请人</value>
        public string group_pendency_form_identifier ;
        /// <value>读写, 判决者的 ID，处理此条“加群的未决请求”的管理员ID</value>
        public string group_pendency_to_identifier ;
        /// <value>只读, 未决信息添加时间</value>
        public ulong group_pendency_add_time ;
        /// <value>只读, 未决请求类型</value>
        public TIMGroupPendencyType group_pendency_pendency_type ;
        /// <value>只读, 群未决处理状态</value>
        public TIMGroupPendencyHandle group_pendency_handled ;
        /// <value>只读, 群未决处理操作类型</value>
        public TIMGroupPendencyHandleResult group_pendency_handle_result ;
        /// <value>只读, 申请或邀请附加信息</value>
        public string group_pendency_apply_invite_msg ;
        /// <value>只读, 申请或邀请者自定义字段</value>
        public string group_pendency_form_user_defined_data ;
        /// <value>只读, 审批信息：同意或拒绝信息</value>
        public string group_pendency_approval_msg ;
        /// <value>只读, 审批者自定义字段</value>
        public string group_pendency_to_user_defined_data ;
        /// <value>只读, 签名信息，客户不用关心</value>
        public string group_pendency_key ;
        /// <value>只读, 签名信息，客户不用关心</value>
        public string group_pendency_authentication ;
        /// <value>只读, 自己的ID</value>
        public string group_pendency_self_identifier ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupSearchParam : ExtraData
    {

        /// <value>搜索关键字列表，最多支持5个 </value>
        public List<string> group_search_params_keyword_list ;
        /// <value>搜索域列表表</value>
        public List<TIMGroupSearchFieldKey> group_search_params_field_list ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupMemberSearchParam : ExtraData
    {

        /// <value>指定群 ID 列表，若为不填则搜索全部群中的群成员</value>
        public List<string> group_search_member_params_groupid_list ;
        /// <value>搜索关键字列表，最多支持5个</value>
        public List<string> group_search_member_params_keyword_list ;
        /// <value>搜索域列表</value>
        public List<TIMGroupMemberSearchFieldKey> group_search_member_params_field_list ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupAttributes : ExtraData
    {

        /// <value>群属性 map 的 key</value>
        public string group_atrribute_key ;
        /// <value>群属性 map 的 value</value>
        public string group_atrribute_value ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendShipGetProfileListParam : ExtraData
    {

        /// <value>只写, 想要获取目标用户资料的UserID列表</value>
        public List<string> friendship_getprofilelist_param_identifier_array ;
        /// <value>只写, 是否强制更新。false表示优先从本地缓存获取，获取不到则去网络上拉取。true表示直接去网络上拉取资料。默认为false</value>
        public bool friendship_getprofilelist_param_force_update ;

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipAddFriendParam : ExtraData
    {

        /// <value>只写, 请求加好友对应的UserID</value>
        public string friendship_add_friend_param_identifier ;
        /// <value>只写, 请求添加好友的好友类型</value>
        public TIMFriendType friendship_add_friend_param_friend_type ;
        /// <value>只写, 预备注</value>
        public string friendship_add_friend_param_remark ;
        /// <value>只写, 预分组名</value>
        public string friendship_add_friend_param_group_name ;
        /// <value>只写, 加好友来源描述</value>
        public string friendship_add_friend_param_add_source ;
        /// <value>只写, 加好友附言</value>
        public string friendship_add_friend_param_add_wording ;

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendRespone : ExtraData
    {

        /// <value>只写(必填), 响应好友添加的UserID</value>
        public string friend_respone_identifier ;
        /// <value>只写(必填), 响应好友添加的动作</value>
        public TIMFriendResponseAction friend_respone_action ;
        /// <value>只写(选填), 好友备注</value>
        public string friend_respone_remark ;
        /// <value>只写(选填), 好友分组列表</value>
        public string friend_respone_group_name ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipModifyFriendProfileParam : ExtraData
    {

        /// <value>只写, 被修改的好友的UserID</value>
        public string friendship_modify_friend_profile_param_identifier ;
        /// <value>只写, 修改的好友资料各个选项</value>
        public FriendProfileItem friendship_modify_friend_profile_param_item ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendProfileItem : ExtraData
    {

        /// <value>只写, 修改好友备注</value>
        public string friend_profile_item_remark ;
        /// <value>只写, 修改好友分组名称列表</value>
        public List<string> friend_profile_item_group_name_array ;
        /// <value>只写, 修改[自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)</value>
        public List<FriendProfileCustemStringInfo> friend_profile_item_custom_string_array ;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendProfileCustemStringInfo : ExtraData
    {

        /// <value>只写, 好友自定义资料字段key</value>
        public string friend_profile_custom_string_info_key ;
        /// <value>只写, 好友自定义资料字段value</value>
        public string friend_profile_custom_string_info_value ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipDeleteFriendParam : ExtraData
    {

        /// <value>只写, 删除好友，指定删除的好友类型</value>
        public TIMFriendType friendship_delete_friend_param_friend_type ;
        /// <value>只写(选填), 删除好友UserID列表</value>
        public List<string> friendship_delete_friend_param_identifier_array ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipCheckFriendTypeParam : ExtraData
    {


        /// <value>只写, 要检测的好友类型</value>
        public TIMFriendType friendship_check_friendtype_param_check_type ;
        /// <value>只写, 要检测的好友UserID列表</value>
        public List<string> friendship_check_friendtype_param_identifier_array ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendGroupInfo : ExtraData
    {

        /// <value>只写, 创建分组的名称列表</value>
        public List<string> friendship_create_friend_group_param_name_array ;
        /// <value>只写, 要放到创建的分组的好友UserID列表</value>
        public List<string> friendship_create_friend_group_param_identifier_array ;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipModifyFriendGroupParam : ExtraData
    {

        /// <value>只写, 要修改的分组名称</value>
        public string friendship_modify_friend_group_param_name ;
        /// <value>只写(选填), 修改后的分组名称</value>
        public string friendship_modify_friend_group_param_new_name ;
        /// <value>只写(选填), 要从当前分组删除的好友UserID列表</value>
        public List<string> friendship_modify_friend_group_param_delete_identifier_array ;
        /// <value>只写(选填), 当前分组要新增的好友UserID列表</value>
        public List<string> friendship_modify_friend_group_param_add_identifier_array ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipGetPendencyListParam : ExtraData
    {

        /// <value>只写, 添加好友的未决请求类型</value>
        public TIMFriendPendencyType friendship_get_pendency_list_param_type ;
        /// <value>只写, 分页获取未决请求的起始 seq，返回的结果包含最大 seq，作为获取下一页的起始 seq</value>
        public ulong friendship_get_pendency_list_param_start_seq ;
        /// <value>只写, 获取未决信息的开始时间戳</value>
        public ulong friendship_get_pendency_list_param_start_time ;
        /// <value>只写, 获取未决信息列表，每页的数量</value>
        public int friendship_get_pendency_list_param_limited_size ;

    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipDeletePendencyParam : ExtraData
    {

        /// <value>只读, 添加好友的未决请求类型</value>
        public TIMFriendPendencyType friendship_delete_pendency_param_type ;
        /// <value>只读, 删除好友未决请求的UserID列表</value>
        public List<string> friendship_delete_pendency_param_identifier_array ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendSearchParam : ExtraData
    {

        /// <value>只写, 搜索的关键字列表，关键字列表最多支持 5 个</value>
        public List<string> friendship_search_param_keyword_list ;
        /// <value>只写 [TIMFriendshipSearchFieldKey]() 好友搜索类型</value>
        public List<TIMFriendshipSearchFieldKey> friendship_search_param_search_field_list ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class MessageReceipt : ExtraData
    {

        /// <value>只读, 会话ID</value>
        public string msg_receipt_conv_id ;
        /// <value>只读, 会话类型</value>
        public TIMConvType msg_receipt_conv_type ;
        /// <value>只读, 时间戳</value>
        public ulong msg_receipt_time_stamp ;
        //string, 只读, 群消息 ID
        public string msg_receipt_msg_id;
        //bool, C2C 对端消息是否已读
        public bool msg_receipt_is_peer_read;
        //uint64, 只读, 群消息已读人数
        public int msg_receipt_read_count;
        //uint64, 只读, 群消息未读人数
        public int msg_receipt_unread_count;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupTipsElem : ExtraData
    {
        /// <value>读写(必填), 元素类型</value>
        // public TIMElemType elem_type ;
        /// <value>只读, 群消息类型</value>
        public TIMGroupTipType group_tips_elem_tip_type ; // 群组系统消息元素
        /// <value>只读, 操作者ID</value>
        public string group_tips_elem_op_user ; // 群组系统消息元素
        /// <value>只读, 群组名称</value>
        public string group_tips_elem_group_name ; // 群组系统消息元素
        /// <value>只读, 群组ID</value>

        public string group_tips_elem_group_id ; // 群组系统消息元素
        /// <value>只读, 群消息时间，废弃</value>
        public uint group_tips_elem_time ; // 群组系统消息元素
        /// <value>只读, 被操作的帐号列表</value>
        public List<string> group_tips_elem_user_array ; // 群组系统消息元素
        /// <value>只读, 群资料变更信息列表,仅当 tips_type 值为 kTIMGroupTip_GroupInfoChange 时有效</value>
        public List<GroupTipGroupChangeInfo> group_tips_elem_group_change_info_array ; // 群组系统消息元素
        /// <value>只读, 群成员变更信息列表,仅当 tips_type 值为 kTIMGroupTip_MemberInfoChange 时有效</value>
        public List<GroupTipMemberChangeInfo> group_tips_elem_member_change_info_array ; // 群组系统消息元素
        /// <value>只读, 操作者个人资料</value>

        public UserProfile group_tips_elem_op_user_info ; // 群组系统消息元素
        /// <value>只读, 群成员信息</value>
        public GroupMemberInfo group_tips_elem_op_group_memberinfo ; // 群组系统消息元素
        /// <value>只读, 被操作者列表资料</value>
        public List<UserProfile> group_tips_elem_changed_user_info_array ; // 群组系统消息元素
        /// <value>只读, 群成员信息列表</value>
        public List<GroupMemberInfo> group_tips_elem_changed_group_memberinfo_array ; // 群组系统消息元素
        /// <value>只读, 当前群成员数,只有当事件消息类型为 kTIMGroupTip_Invite 、 kTIMGroupTip_Quit 、 kTIMGroupTip_Kick 时有效</value>
        public uint group_tips_elem_member_num ; // 群组系统消息元素
        /// <value>只读, 操作方平台信息</value>

        public string group_tips_elem_platform ; // 群组系统消息元素
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class ConvInfo : ExtraData
    {

        /// <value>只读, 会话ID</value>
        public string conv_id ; // 群组系统消息元素
        /// <value>只读, 会话类型</value>
        public TIMConvType conv_type ; // 群组系统消息元素
        /// <value>只读, 会话所有者，废弃</value>
        public string conv_owner ; // 群组系统消息元素
        /// <value>只读, 会话未读计数</value>
        public ulong conv_unread_num ; // 群组系统消息元素
        /// <value>只读, 会话的激活时间</value>
        public ulong conv_active_time ; // 群组系统消息元素
        /// <value>只读, 会话是否有最后一条消息</value>
        public bool conv_is_has_lastmsg ; // 群组系统消息元素
        /// <value>只读, 会话最后一条消息</value>
        public Message conv_last_msg ; // 群组系统消息元素
        /// <value>只读, 会话是否有草稿</value>
        public bool conv_is_has_draft ; // 群组系统消息元素
        /// <value>只读(选填), 会话草稿</value>
        public Draft conv_draft ; // 群组系统消息元素
        /// <value>只读(选填), 消息接收选项</value>
        public TIMReceiveMessageOpt conv_recv_opt ; // 群组系统消息元素
        /// <value>只读(选填),  群会话 @ 信息列表，用于展示 “有人@我” 或 “@所有人” 这两种提醒状态</value>
        public List<GroupAtInfo> conv_group_at_info_array ; // 群组系统消息元素
        /// <value>只读,是否置顶</value>
        public bool conv_is_pinned ; // 群组系统消息元素
        /// <value>只读, 获取会话展示名称，其展示优先级如下：1、群组，群名称 C2C; 2、对方好友备注->对方昵称->对方的 userID</value>
        public string conv_show_name ; // 群组系统消息元素


    }


    [JsonObject(MemberSerialization.OptOut)]
    public class Draft : ExtraData
    {

        /// <value>只读, 草稿内的消息</value>
        public Message draft_msg ; // 群组系统消息元素
        /// <value>只读, 用户自定义数据</value>
        public string draft_user_define ; // 群组系统消息元素
        /// <value>只读, 草稿最新编辑时间</value>
        public uint draft_edit_time ; // 群组系统消息元素

    }



    [JsonObject(MemberSerialization.OptOut)]
    public class GroupAtInfo : ExtraData
    {

        /// <value>只读, @ 消息序列号，即带有 “@我” 或者 “@所有人” 标记的消息的序列号</value>
        public ulong conv_group_at_info_seq ; // 群组系统消息元素
        /// <value>只读, @ 提醒类型，分成 “@我” 、“@所有人” 以及 “@我并@所有人” 三类</value>
        public TIMGroupAtType conv_group_at_info_at_type ; // 群组系统消息元素
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class FriendAddPendency : ExtraData
    {


        /// <value>只读, 添加好友请求方的UserID</value>
        public string friend_add_pendency_identifier ;
        /// <value>只读, 添加好友请求方的昵称</value>
        public string friend_add_pendency_nick_name ;
        /// <value>只读, 添加好友请求方的来源</value>
        public string friend_add_pendency_add_source ;
        /// <value>只读, 添加好友请求方的附言</value>
        public string friend_add_pendency_add_wording ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class FriendProfile : ExtraData
    {

        /// <value>只读, 好友UserID</value>
        public string friend_profile_identifier ;
        /// <value>只读, 好友分组名称列表</value>
        public List<string> friend_profile_group_name_array ;
        /// <value>只读, 好友备注，最大96字节，获取自己资料时，该字段为空</value>
        public string friend_profile_remark ;
        /// <value>只读, 好友申请时的添加理由</value>
        public string friend_profile_add_wording ;
        /// <value>只读, 好友申请时的添加来源</value>
        public string friend_profile_add_source ;
        /// <value>只读, 好友添加时间</value>
        public long friend_profile_add_time ;
        /// <value>只读, 好友的个人资料</value>
        public UserProfile friend_profile_user_profile ;
        /// <value>只读, [自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)</value>
        public List<FriendProfileCustemStringInfo> friend_profile_custom_string_array ;


    }



    [JsonObject(MemberSerialization.OptOut)]
    public class SetConfig : ExtraData
    {


        /// <value>只写(选填), 输出到日志文件的日志级别</value>
        public TIMLogLevel? set_config_log_level ;
        /// <value>只写(选填), 日志回调的日志级别 </value>
        public TIMLogLevel? set_config_callback_log_level ;
        /// <value>只写(选填), 是否输出到控制台，默认为 true</value>
        public bool? set_config_is_log_output_console ;
        /// <value>只写(选填), 用户配置</value>
        public UserConfig set_config_user_config ;
        /// <value>只写(选填), 自定义数据，如果需要，初始化前设置</value>
        public string set_config_user_define_data ;
        /// <value>只写(选填), 设置HTTP代理，如果需要，在发送图片、文件、语音、视频前设置</value>
        public HttpProxyInfo set_config_http_proxy_info ;
        /// <value>只写(选填), 设置SOCKS5代理，如果需要，初始化前设置</value>
        public Socks5ProxyInfo set_config_socks5_proxy_info ;
        /// <value>只写(选填), 如果为true，SDK内部会在选择最优IP时只使用LocalDNS</value>
        public bool? set_config_is_only_local_dns_source ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class HttpProxyInfo : ExtraData
    {
        /// <value>只写(必填), 代理的IP</value>
        public string http_proxy_info_ip ;
        /// <value>只写(必填), 代理的端口</value>
        public int http_proxy_info_port ;
        /// <value>只写(选填), 认证的用户名</value>
        public string http_proxy_info_username ;
        /// <value>只写(选填), 认证的密码</value>
        public string http_proxy_info_password ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class Socks5ProxyInfo : ExtraData
    {

        /// <value>只写(必填), socks5代理的IP</value>
        public string socks5_proxy_info_ip ;
        /// <value>只写(必填), socks5代理的端口</value>
        public int socks5_proxy_info_port ;
        /// <value>只写(选填), 认证的用户名</value>
        public string socks5_proxy_info_username ;
        /// <value>只写(选填), 认证的密码</value>
        public string socks5_proxy_info_password ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class UserConfig : ExtraData
    {


        /// <value>只写(选填), true表示要收已读回执事件</value>
        public bool user_config_is_read_receipt ;
        /// <value>只写(选填), true表示服务端要删掉已读状态</value>
        public bool user_config_is_sync_report ;
        /// <value>只写(选填), true表示群tips不计入群消息已读计数</value>
        public bool user_config_is_ingore_grouptips_unread ;
        /// <value>只写(选填), 是否禁用本地数据库，true表示禁用，false表示不禁用。默认是false</value>
        public bool user_config_is_is_disable_storage ;
        /// <value>只写(选填),获取群组信息默认选项</value>
        public GroupGetInfoOption user_config_group_getinfo_option ;
        /// <value>只写(选填),获取群组成员信息默认选项</value>
        public GroupMemberGetInfoOption user_config_group_member_getinfo_option ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class GroupGetInfoOption : ExtraData
    {

        /// <value>读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)</value>
        public TIMGroupGetInfoFlag group_get_info_option_info_flag ;
        /// <value>只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)</value>
        public List<string> group_get_info_option_custom_array ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class SSODataParam : ExtraData
    {

        /// <value>sso请求的命令字</value>
        public string sso_data_param_cmd ;
        /// <value>sso请求的内容，内容是二进制，需要外部传入base64编码后的字符串，sdk内部回解码成原二进制</value>
        public string sso_data_param_body ;
        /// <value>sso请求的超时时间，默认是15秒</value>
        public ulong sso_data_param_timeout ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class ServerAddress : ExtraData
    {

        /// <value>只写(必填), 服务器 IP</value>
        public string server_address_ip ;
        /// <value>只写(必填), 服务器端口</value>
        public int server_address_port ;
        /// <value>只写(选填), 是否 IPv6 地址，默认为 false</value>
        public bool server_address_is_ipv6 ;
    }


    [JsonObject(MemberSerialization.OptOut)]
    public class CustomServerInfo : ExtraData
    {

        /// <value>只写(必填), 长连接服务器地址列表</value>
        public List<ServerAddress> longconnection_address_array ;
        /// <value>只写(选填), 短连接服务器地址列表</value>
        public List<ServerAddress> shortconnection_address_array ;
        /// <value>只写(必填), 服务器公钥</value>
        public string server_public_key ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class SM4GCMCallbackParam : ExtraData
    {

        /// <value>只写(必填), SM4 GCM 加密回调函数地址</value>
        public ulong sm4_gcm_callback_param_encrypt ;
        /// <value>只写(必填), SM4 GCM 解密回调函数地址</value>
        public ulong sm4_gcm_callback_param_decrypt ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class CosSaveRegionForConversationParam : ExtraData
    {

        /// <value>只写(必填), 会话 ID</value>
        public string cos_save_region_for_conversation_param_conversation_id ;
        /// <value>只写(必填), 存储区域</value>
        public string cos_save_region_for_conversation_param_cos_save_region ;
    }



    [JsonObject(MemberSerialization.OptOut)]
    public class ExperimentalAPIReqeustParam : ExtraData
    {

        /// <value>只写(必填), 内部接口的操作类型</value>
        public string request_internal_operation ; // TIMInternalOperation
        /// <value>只写(选填), sso发包请求, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSSOData 时需要设置</value>
        public SSODataParam request_sso_data_param ;
        /// <value>只写(选填), 请求需要转换成tinyid的userid列表, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationUserId2TinyId 时需要设置</value>
        public List<string> request_userid_tinyid_param ;
        /// <value>只写(选填), 请求需要转换成userid的tinyid列表, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationTinyId2UserId 时需要设置</value>
        public List<ulong> request_tinyid_userid_param ;
        /// <value>只写(选填), true 表示设置当前环境为测试环境，false表示设置当前环境是正式环境，默认是正式环境, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetEnv 时需要设置</value>
        public bool? request_set_env_param ;
        /// <value>只写(选填), 设置登录、发消息的重试次数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetMaxRetryCount 时需要设置</value>
        public int? request_set_max_retry_count_param ;
        /// <value>只写(选填), 自定义服务器信息, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetCustomServerInfo 时需要设置</value>
        public CustomServerInfo request_set_custom_server_info_param ;
        /// <value>只写(选填), 国密 SM4 GCM 回调函数地址的参数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetSM4GCMCallback 时需要设置</value>
        public SM4GCMCallbackParam request_set_sm4_gcm_callback_param ;
        /// <value>只写(选填), 初始化 Database 的用户 ID, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationInitLocalStorage 时需要设置</value>
        public string request_init_local_storage_user_id_param ;
        /// <value>只写(选填), 设置 cos 存储区域的参数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetCosSaveRegionForConversation 时需要设置</value>
        public CosSaveRegionForConversationParam request_set_cos_save_region_for_conversation_param ;
        /// <value>只写(选填), 设置 UI 平台，当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetUIPlatform 时需要设置</value>
        public string request_set_ui_platform_param ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GetTotalUnreadNumberResult : ExtraData
    {
        // int, 只读，会话未读数
        public int conv_get_total_unread_message_count_result_unread_count ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GetC2CRecvMsgOptResult : ExtraData
    {
        // string, 只读，用户ID
        public string msg_recv_msg_opt_result_identifier ;
        // uint [TIMReceiveMessageOpt](), 只读，消息接收选项
        public TIMReceiveMessageOpt msg_recv_msg_opt_result_opt ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class CreateGroupResult : ExtraData
    {
        // string, 只读, 创建的群ID
        public string create_group_result_groupid ;
    }
    [JsonObject(MemberSerialization.OptOut)]
    public class GroupInviteMemberResult : ExtraData
    {
        // string, 只读, 被邀请加入群组的用户ID
        public string group_invite_member_result_identifier ;
        // uint [HandleGroupMemberResult](), 只读, 邀请结果
        public HandleGroupMemberResult group_invite_member_result_result ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupDeleteMemberResult : ExtraData
    {
        // string, 只读, 删除的成员ID
        public string group_delete_member_result_identifier ;
        // uint [HandleGroupMemberResult](), 只读, 删除结果
        public HandleGroupMemberResult group_delete_member_result_result ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupBaseInfo : ExtraData
    {
        // string, 只读, 群组ID
        public string group_base_info_group_id ;
        // string, 只读, 群组名称
        public string group_base_info_group_name ;
        // uint [TIMGroupType](), 只读, 群组类型
        public TIMGroupType group_base_info_group_type ;
        // string, 只读, 群组头像URL
        public string group_base_info_face_url ;
        // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
        public uint group_base_info_info_seq ;
        // uint,   只读, 群最新消息的Seq。群组内每一条消息都有一条唯一的消息Seq，且该Seq是按照发消息顺序而连续的。从1开始，群内每增加一条消息，LastestSeq就会增加1
        public uint group_base_info_lastest_seq ;
        // uint,   只读, 用户所在群已读的消息Seq
        public uint group_base_info_readed_seq ;
        // uint,   只读, 消息接收选项
        public uint group_base_info_msg_flag ;
        // bool,   只读, 当前群组是否设置了全员禁言
        public bool group_base_info_is_shutup_all ;
        // object [GroupSelfInfo](), 只读, 用户所在群的个人信息
        public GroupSelfInfo group_base_info_self_info ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupSelfInfo : ExtraData
    {
        // uint, 只读, 加入群组时间
        public uint group_self_info_join_time ;
        // uint, 只读, 用户在群组中的角色
        public uint group_self_info_role ;
        // uint, 只读, 消息未读计数
        public uint group_self_info_unread_num ;
        // uint [TIMReceiveMessageOpt](), 只读, 消息接收选项
        public TIMReceiveMessageOpt group_self_info_msg_flag ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GetGroupInfoResult : ExtraData
    {
        // int [错误码](https://cloud.tencent.com/document/product/269/1671),   只读, 获取群组详细信息的结果
        public int get_groups_info_result_code ;
        // string, 只读, 获取群组详细失败的描述信息
        public string get_groups_info_result_desc ;
        // object [GroupDetailInfo](), 只读, 群组详细信息
        public GroupDetailInfo get_groups_info_result_info ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupDetailInfo : ExtraData
    {
        // string, 只读, 群组ID
        public string group_detial_info_group_id ;
        // uint [TIMGroupType](), 只读, 群组类型
        public TIMGroupType group_detial_info_group_type ;
        // string, 只读, 群组名称
        public string group_detial_info_group_name ;
        // string, 只读, 群组公告
        public string group_detial_info_notification ;
        // string, 只读, 群组简介
        public string group_detial_info_introduction ;
        // string, 只读, 群组头像URL
        public string group_detial_info_face_url ;
        // uint,   只读, 群组创建时间
        public uint group_detial_info_create_time ;
        // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
        public uint group_detial_info_info_seq ;
        // uint,   只读, 群组信息最后修改时间
        public uint group_detial_info_last_info_time ;
        // uint,   只读, 群最新消息的Seq
        public uint group_detial_info_next_msg_seq ;
        // uint,   只读, 最新群组消息时间
        public uint group_detial_info_last_msg_time ;
        // uint,   只读, 群组当前成员数量
        public uint group_detial_info_member_num ;
        // uint,   只读, 群组最大成员数量
        public uint group_detial_info_max_member_num ;
        // uint [TIMGroupAddOption](), 只读, 群组加群选项
        public TIMGroupAddOption group_detial_info_add_option ;
        // uint,   只读, 群组在线成员数量
        public uint group_detial_info_online_member_num ;
        // uint,   只读, 群组成员是否对外可见
        public uint group_detial_info_visible ;
        // uint,   只读, 群组是否能被搜索
        public uint group_detial_info_searchable ;
        // bool,   只读, 群组是否被设置了全员禁言
        public bool group_detial_info_is_shutup_all ;
        // string, 只读, 群组所有者ID
        public string group_detial_info_owener_identifier ;
        // array [GroupInfoCustemString](), 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
        public List<GroupInfoCustemString> group_detial_info_custom_info ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupPendencyResult : ExtraData
    {
        // uint64, 只读, 下一次拉取的起始时戳,server返回0表示没有更多的数据,否则在下次获取数据时以这个时间戳作为开始时间戳
        public ulong group_pendency_result_next_start_time ;
        // uint64, 只读, 已读上报的时间戳
        public ulong group_pendency_result_read_time_seq ;
        // uint,   只读, 未决请求的未读数
        public uint group_pendency_result_unread_num ;
        // array [GroupPendency](), 只读, 群未决信息列表
        public List<GroupPendency> group_pendency_result_pendency_array ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupGetOnlineMemberCountResult : ExtraData
    {
        // int, 只读, 指定群的在线人数
        public int group_get_online_member_count_result ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class FriendResult : ExtraData
    {
        // string, 只读, 关系链操作的用户ID
        public string friend_result_identifier ;
        // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 关系链操作的结果
        public int friend_result_code ;
        // string, 只读, 关系链操作失败的详细描述
        public string friend_result_desc ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class FriendshipCheckFriendTypeResult : ExtraData
    {
        // string, 只读, 被检测的好友UserID
        public string friendship_check_friendtype_result_identifier ;
        // uint [TIMFriendCheckRelation](), 只读, 检测成功时返回的二者之间的关系
        public TIMFriendCheckRelation friendship_check_friendtype_result_relation ;
        // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 检测的结果
        public int friendship_check_friendtype_result_code ;
        // string, 只读, 检测好友失败的描述信息
        public string friendship_check_friendtype_result_desc ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class PendencyPage : ExtraData
    {
        // uint64, 只读, 未决请求信息页的起始时间
        public ulong pendency_page_start_time ;
        // uint64, 只读, 未决请求信息页的未读数量
        public int pendency_page_unread_num ;
        // uint64, 只读, 未决请求信息页的当前Seq
        public ulong pendency_page_current_seq ;
        // array [FriendAddPendencyInfo](), 只读, 未决请求信息页的未决信息列表
        public List<FriendAddPendencyInfo> pendency_page_pendency_info_array ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class FriendAddPendencyInfo : ExtraData
    {
        // uint [TIMFriendPendencyType](), 只读, 好友添加请求未决类型
        public TIMFriendPendencyType friend_add_pendency_info_type ;
        // string, 只读, 好友添加请求未决的UserID
        public string friend_add_pendency_info_idenitifer ;
        // string, 只读, 好友添加请求未决的昵称
        public string friend_add_pendency_info_nick_name ;
        // uint64, 只读, 发起好友申请的时间
        public ulong friend_add_pendency_info_add_time ;
        // string, 只读, 好友添加请求未决的添加来源
        public string friend_add_pendency_info_add_source ;
        // string, 只读, 好友添加请求未决的添加附言
        public string friend_add_pendency_info_add_wording ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class FriendInfoGetResult : ExtraData
    {
        // string, 只读, 好友 user_id
        public string friendship_friend_info_get_result_identifier ;
        // uint [TIMFriendshipRelationType], 只读， 好友关系
        public TIMFriendshipRelationType friendship_friend_info_get_result_relation_type ;
        // uint， 只读，错误码
        public uint friendship_friend_info_get_result_error_code ;
        // string, 只读， 错误描述
        public string friendship_friend_info_get_result_error_message ;
        // [FriendProfile], 只读, 好友资料
        public FriendProfile friendship_friend_info_get_result_field_info ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class MessageSearchResult : ExtraData
    {
        // uint, 只读, 如果您本次搜索【指定会话】，那么返回满足搜索条件的消息总数量；如果您本次搜索【全部会话】，那么返回满足搜索条件的消息所在的所有会话总数量。
        public uint msg_search_result_total_count ;
        // array [TIMMessageSearchResultItem](), 只读, 如果您本次搜索【指定会话】，那么返回结果列表只包含该会话结果；如果您本次搜索【全部会话】，那么对满足搜索条件的消息根据会话 ID 分组，分页返回分组结果；
        public List<MessageSearchResultItem> msg_search_result_item_array ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class MessageSearchResultItem : ExtraData
    {
        // string, 只读，会话 ID
        public string msg_search_result_item_conv_id ;
        // uint [TIMConvType](), 只读, 会话类型
        public TIMConvType msg_search_result_item_conv_type ;
        // uint, 只读, 当前会话一共搜索到了多少条符合要求的消息
        public uint msg_search_result_item_total_message_count ;
        // array [Message](), 只读, 满足搜索条件的消息列表
        public List<Message> msg_search_result_item_message_array ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class MsgBatchSendResult : ExtraData
    {
        // string, 只读, 接收群发消息的用户 ID
        public string msg_batch_send_result_identifier ;
        // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 消息发送结果
        public int msg_batch_send_result_code ;
        // string, 只读, 消息发送的描述
        public string msg_batch_send_result_desc ;
        // object [Message](), 只读, 发送的消息
        public Message msg_batch_send_result_msg ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class MsgDownloadElemResult : ExtraData
    {
        // uint, 只读, 当前已下载的大小
        public uint msg_download_elem_result_current_size ;
        // uint, 只读, 需要下载的文件总大小
        public uint msg_download_elem_result_total_size ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class ReponseInfo : ExtraData
    {
        // string [TIMInternalOperation](), 只读(必填), 响应的内部操作
        public string response_internal_operation ;
        // object [SSODataRes](), 只读(选填), sso发包请求的响应, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationSSOData 时有值
        public SSODataRes response_sso_data_res ;
        // array [UserInfo](), 只读(选填), 响应的tinyid列表, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationUserId2TinyId 时有值
        public List<UserInfo> response_userid_tinyid_res ;
        // array [UserInfo](), 只读(选填), 响应的tinyid列表, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationTinyId2UserId 时有值
        public List<UserInfo> response_tinyid_userid_res ;
        // bool, 只读(选填), true 表示当前环境为测试环境，false表示当前环境是正式环境, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationSetEnv 时有值
        public bool response_set_env_res ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class UserInfo : ExtraData
    {
        public string user_info_userid ;
        public uint user_info_tinyid ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class SSODataRes : ExtraData
    {
        // string, 只读(必填), sso返回数据对应请求的命令字
        public string sso_data_res_cmd ;
        // string, 只读(必填), sso返回的内容，内容是二进制，sdk内部使用base64编码了，外部使用前需要base64解码
        public string sso_data_res_body ;
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class GroupGetMemberInfoListResult : ExtraData
    {
        // uint64, 只读, 下一次拉取的标志,server返回0表示没有更多的数据,否则在下次获取数据时填入这个标志
        public ulong group_get_memeber_info_list_result_next_seq ;
        // array [GroupMemberInfo](), 只读, 成员信息列表
        public List<GroupMemberInfo> group_get_memeber_info_list_result_info_array ;
    }

    // 用于处理Deserialize时多余的参数
    // Handle Unknown Fields when Deserialize
    public class ExtraData {
        // public IDictionary<string, JToken> extra_data;

        [JsonExtensionData]
        private IDictionary<string, JToken> _additionalData;

        // [OnDeserialized]
        // private void OnDeserialized(StreamingContext context)
        // {
            // extra_data = _additionalData;
        // }
    }
}