package com.tencent.qcloud.tuikit.tuichat.config.classicui;

import static com.tencent.qcloud.tuikit.timcommon.util.TUIUtil.newDrawable;

import android.graphics.drawable.Drawable;
import android.view.View;

import androidx.annotation.IntDef;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreItem;
import com.tencent.qcloud.tuikit.tuichat.config.ShortcutMenuConfig;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.ChatEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIChatConfigClassic {
    private TUIChatConfigClassic() {}

    private static final class TUIChatConfigClassicHolder {
        private static final TUIChatConfigClassic INSTANCE = new TUIChatConfigClassic();
    }

    private static TUIChatConfigClassic getInstance() {
        return TUIChatConfigClassicHolder.INSTANCE;
    }

    public static final int UNDEFINED = -1;

    public static final int REPLY = 1;
    public static final int QUOTE = 2;
    public static final int EMOJI_REACTION = 3;
    public static final int PIN = 4;
    public static final int RECALL = 5;
    public static final int TRANSLATE = 6;
    public static final int CONVERT = 7;
    public static final int FORWARD = 8;
    public static final int SELECT = 9;
    public static final int COPY = 10;
    public static final int DELETE = 11;
    public static final int SPEAKER_MODE_SWITCH = 12;

    @IntDef({REPLY, QUOTE, EMOJI_REACTION, PIN, RECALL, TRANSLATE, CONVERT, FORWARD, SELECT, COPY, DELETE, SPEAKER_MODE_SWITCH})
    public @interface LongPressPopMenuItem {}

    public static final int CUSTOM = 1;
    public static final int RECORD_VIDEO = 2;
    public static final int TAKE_PHOTO = 3;
    public static final int ALBUM = 4;
    public static final int FILE = 5;
    public static final int AUDIO_CALL = 6;
    public static final int VIDEO_CALL = 7;
    public static final int ROOM_KIT = 8;
    public static final int POLL = 9;
    public static final int GROUP_NOTE = 10;

    @IntDef({CUSTOM, RECORD_VIDEO, TAKE_PHOTO, ALBUM, FILE, AUDIO_CALL, VIDEO_CALL, ROOM_KIT, POLL, GROUP_NOTE})
    public @interface InputMoreMenuItem {}

    private boolean enableTypingIndicator = true;
    private Drawable background;
    private boolean useSystemCamera;
    private int timeIntervalForAllowedMessageRecall = 120;
    private int sendTextMessageColor = UNDEFINED;
    private int sendTextMessageFontSize = UNDEFINED;
    private int receiveTextMessageColor = UNDEFINED;
    private int receiveTextMessageFontSize = UNDEFINED;
    // message style
    private Drawable systemMessageBackground;
    private int systemMessageTextColor = UNDEFINED;
    private int systemMessageFontSize = UNDEFINED;

    // input bar
    private boolean showInputBar = true;
    private boolean hideCustom = false;
    private boolean hideRecordVideo = false;
    private boolean hideTakePhoto = false;
    private boolean hideAlbum = false;
    private boolean hideFile = false;
    private boolean hideAudioCall = false;
    private boolean hideVideoCall = false;
    private boolean hideRoomKit = false;
    private boolean hidePoll = false;
    private boolean hideGroupNote = false;
    private TUIChatConfigClassic.ChatInputMoreDataSource chatInputMoreDataSource;

    // long press menu
    private boolean enableReply = true;
    private boolean enableQuote = true;
    private boolean enableEmojiReaction = true;
    private boolean enablePin = true;
    private boolean enableRecall = true;
    private boolean enableTranslate = true;
    private boolean enableConvert = true;
    private boolean enableForward = true;
    private boolean enableSelect = true;
    private boolean enableCopy = true;
    private boolean enableDelete = true;
    private boolean enableSpeakerModeSwitch = true;

    /**
     * Hide the items in the pop-up menu when user presses the message.
     * @param items The items to be hidden.
     */
    public static void hideItemsWhenLongPressMessage(@LongPressPopMenuItem int... items) {
        for (int i : items) {
            switch (i) {
                case REPLY: {
                    getInstance().enableReply = false;
                    break;
                }
                case QUOTE: {
                    getInstance().enableQuote = false;
                    break;
                }
                case EMOJI_REACTION: {
                    getInstance().enableEmojiReaction = false;
                    break;
                }
                case PIN: {
                    getInstance().enablePin = false;
                    break;
                }
                case RECALL: {
                    getInstance().enableRecall = false;
                    break;
                }
                case TRANSLATE: {
                    getInstance().enableTranslate = false;
                    break;
                }
                case CONVERT: {
                    getInstance().enableConvert = false;
                    break;
                }
                case FORWARD: {
                    getInstance().enableForward = false;
                    break;
                }
                case SELECT: {
                    getInstance().enableSelect = false;
                    break;
                }
                case COPY: {
                    getInstance().enableCopy = false;
                    break;
                }
                case DELETE: {
                    getInstance().enableDelete = false;
                    break;
                }
                case SPEAKER_MODE_SWITCH: {
                    getInstance().enableSpeakerModeSwitch = false;
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    /**
     * Get whether to enable the reply button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableReply() {
        return getInstance().enableReply;
    }

    /**
     * Get whether to enable the quote button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableQuote() {
        return getInstance().enableQuote;
    }

    /**
     * Get whether to enable the emoji reaction button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableEmojiReaction() {
        return getInstance().enableEmojiReaction;
    }

    /**
     * Get whether to enable the pin button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnablePin() {
        return getInstance().enablePin;
    }

    /**
     * Get whether to enable the recall button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableRecall() {
        return getInstance().enableRecall;
    }

    /**
     * Get whether to enable the translate button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableTranslate() {
        return getInstance().enableTranslate;
    }

    /**
     * Get whether to enable the voice to text button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableConvert() {
        return getInstance().enableConvert;
    }

    /**
     * Get whether to enable the forward button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableForward() {
        return getInstance().enableForward;
    }

    /**
     * Get whether to enable the select button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableSelect() {
        return getInstance().enableSelect;
    }

    /**
     * Get whether to enable the copy button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableCopy() {
        return getInstance().enableCopy;
    }

    /**
     * Get whether to enable the delete button on the pop menu.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableDelete() {
        return getInstance().enableDelete;
    }

    /**
     * Get whether to enable the speaker mode switch button.
     * @return true if enabled, false otherwise.
     */
    public static boolean isEnableSpeakerModeSwitch() {
        return getInstance().enableSpeakerModeSwitch;
    }

    /**
     * Set event listeners for Chat from external sources, to listen for various events in Chat and respond accordingly, such as
     * listening for avatar click events, long-press message events, etc.
     */
    public static void setChatEventListener(ChatEventListener chatEventListener) {
        TUIChatConfigs.getChatEventConfig().setChatEventListener(chatEventListener);
    }

    /**
     *  Enable the display "Alice is typing..." on one-to-one chat interface.
     *  The default value is true.
     *  This configuration takes effect in all one-to-one chat message list interfaces.
     */
    public static void setEnableTypingIndicator(boolean enableTypingIndicator) {
        getInstance().enableTypingIndicator = enableTypingIndicator;
    }

    /**
     * Get whether to enable the display "Alice is typing..." on one-to-one chat interface.
     * @return
     */
    public static boolean isEnableTypingIndicator() {
        return getInstance().enableTypingIndicator;
    }

    /**
     * Set the background of the Chat interface.
     * @param background
     */
    public static void setBackground(Drawable background) {
        getInstance().background = background;
    }


    /**
     * Get the background of the Chat interface.
     * @return
     */
    public static Drawable getBackground() {
        return newDrawable(getInstance().background);
    }

    /**
     * Set the top view of the Chat interface.
     * @param customTopView
     */
    public static void setCustomTopView(View customTopView) {
        TUIChatConfigs.getNoticeLayoutConfig().setCustomNoticeLayout(customTopView);
    }

    /**
     * Set whether to use the system camera. The default is false.
     * @param useSystemCamera
     */
    public static void setUseSystemCamera(boolean useSystemCamera) {
        getInstance().useSystemCamera = useSystemCamera;
    }

    /**
     * Get whether to use the system camera.
     * @return true if use system camera, false otherwise.
     */
    public static boolean isUseSystemCamera() {
        return getInstance().useSystemCamera;
    }

    /**
     * Set whether to play the sound message via the speaker by default. The default is true.
     * @param playingSoundMessageViaSpeakerByDefault
     */
    public static void setPlayingSoundMessageViaSpeakerByDefault(boolean playingSoundMessageViaSpeakerByDefault) {
        TUIChatConfigs.getGeneralConfig().setEnableSoundMessageSpeakerMode(playingSoundMessageViaSpeakerByDefault);
    }

    /**
     * Set whether to exclude the message from the unread count. The default is false.
     * @param excludedFromUnreadCount
     */
    public static void setExcludedFromUnreadCount(boolean excludedFromUnreadCount) {
        TUIChatConfigs.getGeneralConfig().setExcludedFromUnreadCount(excludedFromUnreadCount);
    }

    /**
     * Set whether to exclude the message from the last message. The default is false.
     * @param excludedFromLastMessage
     */
    public static void setExcludedFromLastMessage(boolean excludedFromLastMessage) {
        TUIChatConfigs.getGeneralConfig().setExcludedFromLastMessage(excludedFromLastMessage);
    }

    /**
     * Set the maximum duration of the audio recording. The default is 60 seconds.
     * @param maxAudioRecordDuration
     */
    public static void setMaxAudioRecordDuration(int maxAudioRecordDuration) {
        TUIChatConfigs.getGeneralConfig().setAudioRecordMaxTime(maxAudioRecordDuration);
    }

    /**
     * Set the maximum duration of the video recording. The default is 15 seconds.
     * @param maxVideoRecordDuration
     */
    public static void setMaxVideoRecordDuration(int maxVideoRecordDuration) {
        TUIChatConfigs.getGeneralConfig().setVideoRecordMaxTime(maxVideoRecordDuration);
    }

    /**
     * Set whether to enable the message read receipt. The default is false.
     * @param messageReadReceiptNeeded
     */
    public static void setMessageReadReceiptNeeded(boolean messageReadReceiptNeeded) {
        TUIChatConfigs.getGeneralConfig().setMsgNeedReadReceipt(messageReadReceiptNeeded);
    }

    /**
     * Set the time interval for the allowed message recall. The default is 120 seconds.
     * @param timeIntervalForAllowedMessageRecall
     */
    public static void setTimeIntervalForAllowedMessageRecall(int timeIntervalForAllowedMessageRecall) {
        getInstance().timeIntervalForAllowedMessageRecall = timeIntervalForAllowedMessageRecall;
    }

    /**
     * Get the time interval for the allowed message recall.
     * @return time interval for the allowed message recall
     */
    public static int getTimeIntervalForAllowedMessageRecall() {
        return getInstance().timeIntervalForAllowedMessageRecall;
    }

    /**
     * Set whether to enable the float window for the call. The default is false.
     * @param enableFloatWindowForCall
     */
    public static void setEnableFloatWindowForCall(boolean enableFloatWindowForCall) {
        TUIChatConfigs.getGeneralConfig().setEnableFloatWindowForCall(enableFloatWindowForCall);
    }

    /**
     * Set whether to enable the multi-device for the call. The default is false.
     * @param enableMultiDeviceForCall
     */
    public static void setEnableMultiDeviceForCall(boolean enableMultiDeviceForCall) {
        TUIChatConfigs.getGeneralConfig().setEnableMultiDeviceForCall(enableMultiDeviceForCall);
    }

    /**
     * Set whether to enable the incoming banner. The default is false.
     * @param enableIncomingBanner
     */
    public static void setEnableIncomingBanner(boolean enableIncomingBanner) {
        TUIChatConfigs.getGeneralConfig().setEnableIncomingBanner(enableIncomingBanner);
    }

    /**
     * Set whether to enable the virtual background for the call. The default is false.
     * @param enableVirtualBackgroundForCall
     */
    public static void setEnableVirtualBackgroundForCall(boolean enableVirtualBackgroundForCall) {
        TUIChatConfigs.getGeneralConfig().setEnableVirtualBackgroundForCall(enableVirtualBackgroundForCall);
    }

    /**
     * Set whether to use the Android private ring. The default is false.
     * @param enableAndroidCustomRing
     */
    public static void setEnableAndroidCustomRing(boolean enableAndroidCustomRing) {
        TUIChatConfigs.getGeneralConfig().setEnableAndroidPrivateRing(enableAndroidCustomRing);
    }

    /**
     * Register custom message
     * @param businessID Custom message businessID (note that it must be unique)
     * @param messageBeanClass Custom message MessageBean type
     * @param messageViewHolderClass Custom message MessageViewHolder type
     * @param isUseEmptyViewGroup Set whether to use an empty layout. By default, an empty layout is not used. If set to use an empty layout, the custom message
     *     will not display user avatars, message bubbles, and other content.
     */
    public static void registerCustomMessage(String businessID, Class<? extends TUIMessageBean> messageBeanClass,
        Class<? extends RecyclerView.ViewHolder> messageViewHolderClass, boolean isUseEmptyViewGroup) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID, businessID);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, messageBeanClass);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, messageViewHolderClass);
        param.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.IS_NEED_EMPTY_VIEW_GROUP, isUseEmptyViewGroup);
        String serviceName = TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME;
        TUICore.callService(serviceName, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, param);
    }

    /**
     * Add sticker group.
     * @param groupID the face group ID
     * @param faceGroup the face group
     */
    public static void addStickerGroup(int groupID, FaceGroup<? extends ChatFace> faceGroup) {
        FaceManager.addFaceGroup(groupID, faceGroup);
    }

    public interface ChatInputMoreDataSource {
        /**
         *  Implement this method to add new items to the more menu of the specified model.
         * @param chatInfo the chat model
         * @return the items to be added
         */
        default List<InputMoreItem> inputBarShouldAddNewItemToMoreMenuOfInfo(ChatInfo chatInfo) {
            return new ArrayList<>();
        }

        /**
         *  Implement this method to hide items in more menu of the specified model.
         *  @param chatInfo the chat model
         *  @return the items to be hidden
         */
        default @InputMoreMenuItem List<Integer> inputBarShouldHideItemsInMoreMenuOfInfo(ChatInfo chatInfo) {
            return new ArrayList<>();
        }
    }

    /**
     * Get whether to show the input bar.
     * @return whether to show the input bar
     */
    public static boolean isShowInputBar() {
        return getInstance().showInputBar;
    }

    /**
     * Set whether to show the input bar. The default value is true.
     * @param showInputBar whether to show the input bar
     */
    public static void setShowInputBar(boolean showInputBar) {
        getInstance().showInputBar = showInputBar;
    }

    /**
     * Set the data source of the more menu in the input bar.
     * @param chatInputMoreDataSource the input more data source
     * @see ChatInputMoreDataSource
     */
    public static void setChatInputMoreDataSource(ChatInputMoreDataSource chatInputMoreDataSource) {
        getInstance().chatInputMoreDataSource = chatInputMoreDataSource;
    }

    /**
     * Get the data source of the more menu in the input bar.
     * @return the input more data source
     * @see ChatInputMoreDataSource
     */
    public static ChatInputMoreDataSource getChatInputMoreDataSource() {
        return getInstance().chatInputMoreDataSource;
    }

    /**
     * Hide items in more menu
     * @param items the items to be hidden
     */
    public static void hideItemsInMoreMenu(@InputMoreMenuItem int... items) {
        for (int item : items) {
            switch (item) {
                case CUSTOM: {
                    getInstance().hideCustom = true;
                    break;
                }
                case RECORD_VIDEO: {
                    getInstance().hideRecordVideo = true;
                    break;
                }
                case TAKE_PHOTO: {
                    getInstance().hideTakePhoto = true;
                    break;
                }
                case ALBUM: {
                    getInstance().hideAlbum = true;
                    break;
                }
                case FILE: {
                    getInstance().hideFile = true;
                    break;
                }
                case AUDIO_CALL: {
                    getInstance().hideAudioCall = true;
                    break;
                }
                case VIDEO_CALL: {
                    getInstance().hideVideoCall = true;
                    break;
                }
                case ROOM_KIT: {
                    getInstance().hideRoomKit = true;
                    break;
                }
                case GROUP_NOTE: {
                    getInstance().hideGroupNote = true;
                    break;
                }
                case POLL: {
                    getInstance().hidePoll = true;
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    /**
     * Get whether to show the custom button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarCustom() {
        return !getInstance().hideCustom;
    }

    /**
     * Get whether to show the record video button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarRecordVideo() {
        return !getInstance().hideRecordVideo;
    }

    /**
     * Get whether to show the take photo button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarTakePhoto() {
        return !getInstance().hideTakePhoto;
    }

    /**
     * Get whether to show the album button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarAlbum() {
        return !getInstance().hideAlbum;
    }

    /**
     * Get whether to show the file button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarFile() {
        return !getInstance().hideFile;
    }

    /**
     * Get whether to show the audio call button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarAudioCall() {
        return !getInstance().hideAudioCall;
    }

    /**
     * Get whether to show the video call button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarVideoCall() {
        return !getInstance().hideVideoCall;
    }

    /**
     * Get whether to show the room button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarRoomKit() {
        return !getInstance().hideRoomKit;
    }

    /**
     * Get whether to show the group note button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarGroupNote() {
        return !getInstance().hideGroupNote;
    }

    /**
     * Get whether to show the poll button in the input bar
     * @return true: show; false: hide
     */
    public static boolean isShowInputBarPoll() {
        return !getInstance().hidePoll;
    }

    /**
     * Set the text color of the sent text message
     * @param color text color
     */
    public static void setSendTextMessageColor(int color) {
        getInstance().sendTextMessageColor = color;
    }

    /**
     * Get the text color of the sent text message
     * @return text color
     */
    public static int getSendTextMessageColor() {
        return getInstance().sendTextMessageColor;
    }

    /**
     * Set the font size of the sent text message
     * @param size font size
     */
    public static void setSendTextMessageFontSize(int size) {
        getInstance().sendTextMessageFontSize = size;
    }

    /**
     * Get the font size of the sent text message
     * @return font size
     */
    public static int getSendTextMessageFontSize() {
        return getInstance().sendTextMessageFontSize;
    }

    /**
     * Set the text color of the received text message
     * @param color text color
     */
    public static void setReceiveTextMessageColor(int color) {
        getInstance().receiveTextMessageColor = color;
    }

    /**
     * Get the text color of the received text message
     * @return text color
     */
    public static int getReceiveTextMessageColor() {
        return getInstance().receiveTextMessageColor;
    }

    /**
     * Set the font size of the received text message
     * @param size
     */
    public static void setReceiveTextMessageFontSize(int size) {
        getInstance().receiveTextMessageFontSize = size;
    }

    /**
     * Get the font size of the received text message
     * @return font size
     */
    public static int getReceiveTextMessageFontSize() {
        return getInstance().receiveTextMessageFontSize;
    }

    /**
     * Set the background of the system message
     * @param drawable the background of the system message
     */
    public static void setSystemMessageBackground(Drawable drawable) {
        getInstance().systemMessageBackground = drawable;
    }

    /**
     * Get the background of the system message
     * @return the background
     */
    public static Drawable getSystemMessageBackground() {
        return newDrawable(getInstance().systemMessageBackground);
    }

    /**
     * Set the text color of the system message
     * @param color the text color of the system message
     */
    public static void setSystemMessageTextColor(int color) {
        getInstance().systemMessageTextColor = color;
    }

    /**
     * Get the text color of the system message
     * @return text color
     */
    public static int getSystemMessageTextColor() {
        return getInstance().systemMessageTextColor;
    }

    /**
     * Set the font size of the system message
     * @param size the font size of the system message
     */
    public static void setSystemMessageFontSize(int size) {
        getInstance().systemMessageFontSize = size;
    }

    /**
     * Get the font size of the system message
     * @return font size
     */
    public static int getSystemMessageFontSize() {
        return getInstance().systemMessageFontSize;
    }

    /**
     * Set the data source of the chat shortcut menu
     * @param shortcutViewDataSource
     * @see ShortcutMenuConfig.ChatShortcutViewDataSource
     */
    public static void setChatShortcutViewDataSource(ShortcutMenuConfig.ChatShortcutViewDataSource shortcutViewDataSource) {
        ShortcutMenuConfig.setShortcutViewDataSource(shortcutViewDataSource);
    }
}
