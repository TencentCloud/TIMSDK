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

        TextMessageBean textMessageBean = new TextMessageBean();
        textMessageBean.setCommonAttribute(v2TIMMessage);
        textMessageBean.onProcessMessage(v2TIMMessage);
        return textMessageBean;
    }

    public static TextAtMessageBean buildTextAtMessage(List<String> atUserList, String message) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextAtMessage(message, atUserList);
        TextAtMessageBean textAtMessageBean = new TextAtMessageBean();
        textAtMessageBean.setCommonAttribute(v2TIMMessage);
        textAtMessageBean.onProcessMessage(v2TIMMessage);
        return textAtMessageBean;
    }

    /**
     * Create a message with a custom emoji
     *
     * @param groupId  The expression group id where the custom expression is located
     * @param faceName name
     * @return
     */
    public static TUIMessageBean buildFaceMessage(int groupId, String faceName) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createFaceMessage(groupId, faceName.getBytes());

        FaceMessageBean message = new FaceMessageBean();
        message.setCommonAttribute(v2TIMMessage);
        message.onProcessMessage(v2TIMMessage);
        return message;
    }

    /**
     *
     * Create a image message
     *
     * @param imagePath  path
     * @return
     */
    public static TUIMessageBean buildImageMessage(final String imagePath) {
        String path = ImageUtil.getImagePathAfterRotate(imagePath);
        if (TextUtils.isEmpty(path)) {
            return null;
        }
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createImageMessage(path);

        final ImageMessageBean messageBean = new ImageMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);

        int[] size = ImageUtil.getImageSize(path);
        messageBean.setImgWidth(size[0]);
        messageBean.setImgHeight(size[1]);
        return messageBean;
    }

    /**
     *
     * create a video message
     *
     * @param imgPath   
     * @param videoPath 
     * @param width     
     * @param height    
     * @param duration  
     * @return
     */
    public static TUIMessageBean buildVideoMessage(String imgPath, String videoPath, int width, int height, long duration) {
        if (TextUtils.isEmpty(imgPath) || TextUtils.isEmpty(videoPath)) {
            return null;
        }
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createVideoMessage(videoPath, "mp4", Math.round(duration * 1.0f / 1000), imgPath);

        VideoMessageBean messageBean = new VideoMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);

        messageBean.setImgWidth(width);
        messageBean.setImgHeight(height);
        return messageBean;
    }

    /**
     *
     * create a audio message
     *
     * @param recordPath 
     * @param duration   
     * @return
     */
    public static TUIMessageBean buildAudioMessage(String recordPath, int duration) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createSoundMessage(recordPath, Math.round(duration * 1.0f / 1000));

        SoundMessageBean messageBean = new SoundMessageBean();
        messageBean.setCommonAttribute(v2TIMMessage);
        messageBean.onProcessMessage(v2TIMMessage);
        return messageBean;
    }

    /**
     *
     * create a text message
     *
     * @param fileUri 
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

            FileMessageBean messageBean = new FileMessageBean();
            messageBean.setCommonAttribute(v2TIMMessage);
            messageBean.onProcessMessage(v2TIMMessage);

            return messageBean;
        }
        return null;
    }

    /**
     *
     * create a forward message
     *
     * @param v2TIMMessage 
     * @return
     */
    public static TUIMessageBean buildForwardMessage(V2TIMMessage v2TIMMessage) {
        V2TIMMessage forwardMessage = V2TIMManager.getMessageManager().createForwardMessage(v2TIMMessage);
        forwardMessage.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isMsgNeedReadReceipt());

        return buildMessage(forwardMessage);
    }

    /**
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
        mergeMsg.setNeedReadReceipt(TUIChatConfigs.getConfigs().getGeneralConfig().isMsgNeedReadReceipt());

        MergeMessageBean messageBean = new MergeMessageBean();
        messageBean.setCommonAttribute(mergeMsg);
        messageBean.onProcessMessage(mergeMsg);
        return messageBean;
    }

    /**
     * create a custom message
     *
     * @param data        ，
     * @param description ，
     * @param extension   
     * @return
     */
    public static TUIMessageBean buildCustomMessage(String data, String description, byte[] extension) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createCustomMessage(data.getBytes(), description, extension);
        v2TIMMessage.setSupportMessageExtension(true);

        TUIMessageBean message = ChatMessageParser.parseMessage(v2TIMMessage);
        if (message != null && message.getExtra() == null) {
            message.setExtra(TUIChatService.getAppContext().getString(R.string.custom_msg));
        }
        return message;
    }

    /**
     * create a custom message for group
     *
     * @param customMessage 
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

        return buildReplyMessage(v2TIMMessage, previewBean);
    }

    public static TUIMessageBean buildReplyMessage(String content, ReplyPreviewBean previewBean) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextMessage(content);

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