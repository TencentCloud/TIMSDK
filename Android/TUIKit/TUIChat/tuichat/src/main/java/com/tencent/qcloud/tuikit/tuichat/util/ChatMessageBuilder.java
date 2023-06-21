package com.tencent.qcloud.tuikit.tuichat.util;

import android.net.Uri;
import android.text.TextUtils;
import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextAtMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatMessageBuilder {
    public static final String TAG = ChatMessageBuilder.class.getSimpleName();

    public static TextMessageBean buildTextMessage(String message) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextMessage(message);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        TextMessageBean textMessageBean = new TextMessageBean();
        textMessageBean.setCommonAttribute(v2TIMMessage);
        textMessageBean.onProcessMessage(v2TIMMessage);
        return textMessageBean;
    }

    public static TextAtMessageBean buildTextAtMessage(List<String> atUserList, String message) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextAtMessage(message, atUserList);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());
        TextAtMessageBean textAtMessageBean = new TextAtMessageBean();
        textAtMessageBean.setCommonAttribute(v2TIMMessage);
        textAtMessageBean.onProcessMessage(v2TIMMessage);
        return textAtMessageBean;
    }

    /**
     * 创建一条自定义表情的消息
     *
     * @param groupId  自定义表情所在的表情组id
     * @param faceName 表情的名称
     * @return
     *
     * Create a message with a custom emoji
     *
     * @param groupId  The expression group id where the custom expression is located
     * @param faceName name
     * @return
     */
    public static TUIMessageBean buildFaceMessage(int groupId, String faceName) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createFaceMessage(groupId, faceName.getBytes());
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        FaceMessageBean message = new FaceMessageBean();
        message.setCommonAttribute(v2TIMMessage);
        message.onProcessMessage(v2TIMMessage);
        return message;
    }

    /**
     * 创建一条图片消息
     *
     * Create a image message
     *
     * @param imagePath 图片 path
     * @return
     */
    public static TUIMessageBean buildImageMessage(final String imagePath) {
        String path = ImageUtil.getImagePathAfterRotate(imagePath);
        if (TextUtils.isEmpty(path)) {
            return null;
        }
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createImageMessage(path);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        final ImageMessageBean messageBean = new ImageMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);

        int[] size = ImageUtil.getImageSize(path);
        messageBean.setDataPath(path);
        messageBean.setImgWidth(size[0]);
        messageBean.setImgHeight(size[1]);
        return messageBean;
    }

    /**
     * 创建一条视频消息
     *
     * create a video message
     *
     * @param imgPath   视频缩略图路径
     * @param videoPath 视频路径
     * @param width     视频的宽
     * @param height    视频的高
     * @param duration  视频的时长
     * @return
     */
    public static TUIMessageBean buildVideoMessage(String imgPath, String videoPath, int width, int height, long duration) {
        if (TextUtils.isEmpty(imgPath) || TextUtils.isEmpty(videoPath)) {
            return null;
        }
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createVideoMessage(videoPath, "mp4", Math.round(duration * 1.0f / 1000), imgPath);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        VideoMessageBean messageBean = new VideoMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);

        messageBean.setImgWidth(width);
        messageBean.setImgHeight(height);
        messageBean.setSnapshotPath(imgPath);
        messageBean.setVideoPath(videoPath);
        return messageBean;
    }

    /**
     * 创建一条音频消息
     *
     * create a audio message
     *
     * @param recordPath 音频路径
     * @param duration   音频的时长
     * @return
     */
    public static TUIMessageBean buildAudioMessage(String recordPath, int duration) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createSoundMessage(recordPath, Math.round(duration * 1.0f / 1000));
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        SoundMessageBean messageBean = new SoundMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);

        messageBean.setDataPath(recordPath);
        return messageBean;
    }

    /**
     * 创建一条文件消息
     *
     * create a text message
     *
     * @param fileUri 文件路径
     * @return
     */
    public static TUIMessageBean buildFileMessage(Uri fileUri) {
        String filePath = FileUtil.getPathFromUri(fileUri);
        if (TextUtils.isEmpty(filePath)) {
            return null;
        }
        File file = new File(filePath);
        if (file.exists()) {
            V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createFileMessage(filePath, file.getName());
            v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

            FileMessageBean messageBean = new FileMessageBean();
            messageBean.setCommonAttribute(v2TIMMessage);
            messageBean.onProcessMessage(v2TIMMessage);

            messageBean.setDataPath(filePath);
            return messageBean;
        }
        return null;
    }

    /**
     * 创建一条 onebyone 转发消息
     *
     * create a forward message
     *
     * @param v2TIMMessage 要转发的消息
     * @return
     */
    public static TUIMessageBean buildForwardMessage(V2TIMMessage v2TIMMessage) {
        V2TIMMessage forwardMessage = V2TIMManager.getMessageManager().createForwardMessage(v2TIMMessage);
        forwardMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        return buildMessage(forwardMessage);
    }

    /**
     * 创建一条 merge 转发消息
     *
     * create a merge message
     *
     * @return
     */
    public static TUIMessageBean buildMergeMessage(List<TUIMessageBean> messageInfoList, String title, List<String> abstractList, String compatibleText) {
        if (messageInfoList == null || messageInfoList.isEmpty()) {
            return null;
        }
        List<V2TIMMessage> msgList = new ArrayList<>();
        for (int i = 0; i < messageInfoList.size(); i++) {
            msgList.add(messageInfoList.get(i).getV2TIMMessage());
        }
        V2TIMMessage mergeMsg = V2TIMManager.getMessageManager().createMergerMessage(msgList, title, abstractList, compatibleText);
        mergeMsg.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        MergeMessageBean messageBean = new MergeMessageBean();
        messageBean.setCommonAttribute(mergeMsg);
        messageBean.onProcessMessage(mergeMsg);
        return messageBean;
    }

    /**
     * 创建一条自定义消息
     *
     * create a custom message
     *
     * @param data        自定义消息内容，可以是任何内容
     * @param description 自定义消息描述内容，可以被搜索到
     * @param extension   扩展内容
     * @return
     */
    public static TUIMessageBean buildCustomMessage(String data, String description, byte[] extension) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createCustomMessage(data.getBytes(), description, extension);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());
        v2TIMMessage.setSupportMessageExtension(true);

        TUIMessageBean message = ChatMessageParser.parseMessage(v2TIMMessage);
        if (message.getExtra() == null) {
            message.setExtra(TUIChatService.getAppContext().getString(R.string.custom_msg));
        }
        return message;
    }

    /**
     * 创建一条群消息自定义内容
     *
     * create a custom message for group
     *
     * @param customMessage 消息内容
     * @return
     */
    public static V2TIMMessage buildGroupCustomMessage(String customMessage) {
        return V2TIMManager.getMessageManager().createCustomMessage(customMessage.getBytes());
    }

    public static TUIMessageBean buildMessage(V2TIMMessage message) {
        return ChatMessageParser.parseMessage(message);
    }

    public static TUIMessageBean buildAtReplyMessage(String content, List<String> atList, ReplyPreviewBean previewBean) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextAtMessage(content, atList);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        return buildReplyMessage(v2TIMMessage, previewBean);
    }

    public static TUIMessageBean buildReplyMessage(String content, ReplyPreviewBean previewBean) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextMessage(content);
        v2TIMMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());

        return buildReplyMessage(v2TIMMessage, previewBean);
    }

    private static TUIMessageBean buildReplyMessage(V2TIMMessage v2TIMMessage, ReplyPreviewBean previewBean) {
        Map<String, ReplyPreviewBean> cloudData = new HashMap<>();
        Gson gson = new Gson();
        cloudData.put(TIMCommonConstants.MESSAGE_REPLY_KEY, previewBean);
        v2TIMMessage.setCloudCustomData(gson.toJson(cloudData));

        QuoteMessageBean replyMessageBean;
        if (TextUtils.isEmpty(previewBean.getMessageRootID())) {
            replyMessageBean = new QuoteMessageBean(previewBean);
        } else {
            replyMessageBean = new ReplyMessageBean(previewBean);
        }
        replyMessageBean.setCommonAttribute(v2TIMMessage);
        replyMessageBean.onProcessMessage(v2TIMMessage);
        return replyMessageBean;
    }

    public static ReplyPreviewBean buildReplyPreviewBean(TUIMessageBean messageBean) {
        String sender = messageBean.getNickName();
        if (TextUtils.isEmpty(sender)) {
            sender = messageBean.getSender();
        }

        ReplyPreviewBean previewBean = new ReplyPreviewBean();
        if (messageBean instanceof ReplyMessageBean) {
            String msgRootId = ((ReplyMessageBean) messageBean).getMsgRootId();
            previewBean.setMessageRootID(msgRootId);
        } else {
            previewBean.setMessageRootID(messageBean.getId());
        }
        String messageAbstract = ChatMessageParser.getReplyMessageAbstract(messageBean);
        previewBean.setOriginalMessageBean(messageBean);
        previewBean.setMessageID(messageBean.getId());
        previewBean.setMessageAbstract(messageAbstract);
        previewBean.setMessageSender(sender);
        previewBean.setMessageTime(messageBean.getMessageTime());
        previewBean.setMessageSequence(messageBean.getMsgSeq());
        previewBean.setMessageType(messageBean.getMsgType());

        return previewBean;
    }
}