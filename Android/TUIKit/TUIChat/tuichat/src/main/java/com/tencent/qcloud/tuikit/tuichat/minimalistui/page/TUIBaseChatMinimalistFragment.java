package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.JCameraView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.DataStoreUtil;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class TUIBaseChatMinimalistFragment extends BaseFragment {
    private static final String TAG = TUIBaseChatMinimalistFragment.class.getSimpleName();


    public static final int REQUEST_CODE_PHOTO = 1012;

    public static TUIBaseChatMinimalistFragment fragment;

    protected View baseView;

    protected ChatView chatView;

    private List<TUIMessageBean> mForwardSelectMsgInfos = null;
    private int mForwardMode;
    private boolean mOnlyForTranslation;

    private MessageRecyclerView messageRecyclerView;
    private int messageViewBackgroundHeight;
    protected String mChatBackgroundUrl;
    protected String mChatBackgroundThumbnailUrl;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        fragment = this;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = inflater.inflate(R.layout.chat_minimalist_fragment, container, false);
//        // TODO 通过api设置ChatLayout各种属性的样例
//        // Example of setting various properties of ChatLayout through api
//        ChatLayoutSetting helper = new ChatLayoutSetting(getActivity());
//        helper.setGroupId(mChatInfo.getId());
//        helper.customizeChatLayout(mChatLayout);
        return baseView;
    }

    protected void initView() {
        chatView = baseView.findViewById(R.id.chat_layout);
        chatView.initDefault();

        chatView.setOnBackClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(chatView.getWindowToken(), 0);
                getActivity().finish();
            }
        });

        chatView.setForwardSelectActivityListener(new ChatView.ForwardSelectActivityListener(){
            @Override
            public void onStartForwardSelectActivity(int mode, List<TUIMessageBean> msgIds, boolean onlyForTranslation) {
                mForwardMode = mode;
                mForwardSelectMsgInfos = msgIds;
                mOnlyForTranslation = onlyForTranslation;
                Bundle bundle = new Bundle();
                bundle.putInt(TUIChatConstants.FORWARD_MODE, mode);
                TUICore.startActivity(TUIBaseChatMinimalistFragment.this, "TUIForwardSelectMinimalistActivity", bundle, TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE);

            }
        });

        chatView.getMessageLayout().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, TUIMessageBean message) {
                chatView.getMessageLayout().showItemPopMenu(message, view);
            }

            @Override
            public void onUserIconClick(View view, int position, TUIMessageBean message) {
                if (null == message) {
                    return;
                }

                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, message.getSender());
                TUICore.startActivity("FriendProfileMinimalistActivity", bundle);

            }

            @Override
            public void onUserIconLongClick(View view, int position, TUIMessageBean message) {

            }

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                int messageType = messageInfo.getMsgType();
                if (messageType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT){
                    chatView.getInputLayout().appendText(messageInfo.getV2TIMMessage().getTextElem().getText());
                } else {
                    TUIChatLog.e(TAG, "error type: " + messageType);
                }
            }

            @Override
            public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                CallingMessageBean callingMessageBean = (CallingMessageBean) messageInfo;
                String callTypeString = "";
                int callType = callingMessageBean.getCallType();
                if (callType == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                    callTypeString = TUIConstants.TUICalling.TYPE_VIDEO;
                } else if (callType == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                    callTypeString = TUIConstants.TUICalling.TYPE_AUDIO;
                }
                Map<String, Object> map = new HashMap<>();
                map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[]{messageInfo.getUserId()});
                map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, callTypeString);
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(messageInfo, view);
            }

            @Override
            public void onTranslationLongClick(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().showTranslationItemPopMenu(position - 1, messageInfo, view);
            }
        });

        chatView.getInputLayout().setOnInputViewListener(new InputView.OnInputViewListener() {
            @Override
            public void onStartGroupMemberSelectActivity() {
                Bundle param = new Bundle();
                param.putString(TUIChatConstants.GROUP_ID, getChatInfo().getId());
                TUICore.startActivity(TUIBaseChatMinimalistFragment.this, "StartGroupMemberSelectActivity", param, 1);
            }

            @Override
            public void onClickCapture() {
                startCapture();
            }

            @Override
            public void onUpdateChatBackground() {
                setChatViewBackground(mChatBackgroundUrl);
            }
        });

        messageRecyclerView = chatView.getMessageLayout();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == 3) {
            ArrayList<String> result_ids = data.getStringArrayListExtra(TUIChatConstants.Selection.USER_ID_SELECT);
            ArrayList<String> result_names = data.getStringArrayListExtra(TUIChatConstants.Selection.USER_NAMECARD_SELECT);
            chatView.getInputLayout().updateInputText(result_names, result_ids);
        } else if (requestCode == TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE && resultCode == TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE) {
            if (data != null) {
                if (mForwardSelectMsgInfos == null || mForwardSelectMsgInfos.isEmpty()) {
                    return;
                }

                HashMap<String, Boolean> chatMap = (HashMap<String, Boolean>) data.getSerializableExtra(TUIChatConstants.FORWARD_SELECT_CONVERSATION_KEY);
                if (chatMap == null || chatMap.isEmpty()) {
                    return;
                }

                for (Map.Entry<String, Boolean> entry : chatMap.entrySet()) {
                    boolean isGroup = entry.getValue();
                    String id = entry.getKey();
                    String title = "";
                    ChatInfo chatInfo = getChatInfo();
                    if (chatInfo == null) {
                        return;
                    }
                    if (TUIChatUtils.isGroupChat(chatInfo.getType())) {
                        title = getString(R.string.forward_chats);
                    } else {
                        String senderName;
                        String userNickName = TUIConfig.getSelfNickName();
                        if (!TextUtils.isEmpty(userNickName)) {
                            senderName = userNickName;
                        } else {
                            senderName = TUILogin.getLoginUser();
                        }
                        String chatName;
                        if (!TextUtils.isEmpty(getChatInfo().getChatName())) {
                            chatName = getChatInfo().getChatName();
                        } else {
                            chatName = getChatInfo().getId();
                        }
                        title = senderName + getString(R.string.and_text) + chatName + getString(R.string.forward_chats_c2c);                    }

                    boolean selfConversation = false;
                    if (id != null && id.equals(chatInfo.getId())) {
                        selfConversation = true;
                    }

                    ChatPresenter chatPresenter = getPresenter();
                    chatPresenter.forwardMessage(mForwardSelectMsgInfos, isGroup, id, title, mForwardMode, selfConversation, false, new IUIKitCallback() {
                        @Override
                        public void onSuccess(Object data) {
                            TUIChatLog.v(TAG, "sendMessage onSuccess:");
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                            ToastUtil.toastLongMessage(getString(R.string.send_failed) + ", " + errMsg);
                        }
                    });
                }
            }
        } else if (requestCode == REQUEST_CODE_PHOTO) {
            if (resultCode != -1) {
                return;
            }
            onCaptureResult(data);
        }
    }

    public ChatInfo getChatInfo() {
        return null;
    }
    
    @Override
    public void onResume() {
        super.onResume();
        if (getPresenter() != null) {
            getPresenter().setChatFragmentShow(true);
        }
        initChatViewBackground();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (chatView != null) {
            if (chatView.getInputLayout() != null) {
                chatView.getInputLayout().setDraft();
            }

            if (getPresenter() != null) {
                getPresenter().setChatFragmentShow(false);
            }
        }
        AudioPlayer.getInstance().stopPlay();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (chatView != null) {
            chatView.exitChat();
        }
    }

    public ChatPresenter getPresenter() {
        return null;
    }

    protected void initChatViewBackground() {
        if (getChatInfo() == null) {
            TUIChatLog.e(TAG, "initChatViewBackground getChatInfo is null");
            return;
        }
        DataStoreUtil.getInstance().getValueAsync(getChatInfo().getId(), new DataStoreUtil.GetResult<String>() {
            @Override
            public void onSuccess(String result) {
                setChatViewBackground(result);
            }

            @Override
            public void onFail() {
                TUIChatLog.e(TAG, "initChatViewBackground onFail");
            }
        }, String.class);
    }

    protected void setChatViewBackground(String uri){
        TUIChatLog.d(TAG, "setChatViewBackground uri = " + uri);
        if (TextUtils.isEmpty(uri)) {
            return;
        }

        if (chatView == null) {
            TUIChatLog.e(TAG, "setChatViewBackground chatview is null");
            return;
        }

        if (messageRecyclerView == null) {
            TUIChatLog.e(TAG, "setChatViewBackground messageRecyclerView is null");
            return;
        }

        String[] list = uri.split(",");
        if (list.length > 0) {
            mChatBackgroundThumbnailUrl = list[0];
        }

        if (list.length > 1) {
            mChatBackgroundUrl = list[1];
        }

        if (TextUtils.equals(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundUrl)) {
            mChatBackgroundThumbnailUrl = TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL;
            messageRecyclerView.setBackgroundResource(R.color.chat_background_color);
            return;
        }

        messageRecyclerView.post(new Runnable() {
            @Override
            public void run() {
                int imageWidth = messageRecyclerView.getWidth();
                int imageHeight = messageRecyclerView.getHeight();
                if (imageHeight > messageViewBackgroundHeight) {
                    messageViewBackgroundHeight = imageHeight;
                }
                TUIChatLog.d(TAG, "messageRecyclerView  width = " + imageWidth + ", height = " + messageViewBackgroundHeight);
                if (imageWidth == 0 || messageViewBackgroundHeight == 0) {
                    return;
                }
                Glide.with(getContext()).asBitmap().load(mChatBackgroundUrl).into(new CustomTarget<Bitmap>(imageWidth, messageViewBackgroundHeight) {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        TUIChatLog.d(TAG, "messageRecyclerView onGlobalLayout url = " + mChatBackgroundUrl);
                        Bitmap srcBitmap = zoomImg(resource, imageWidth, messageViewBackgroundHeight);
                        messageRecyclerView.setBackground(new BitmapDrawable(getResources(), resource) {
                            @Override
                            public void draw(@NonNull Canvas canvas) {
                                // TUIChatLog.d(TAG, "draw canvas =" + canvas.getClipBounds());
                                canvas.drawBitmap(srcBitmap, canvas.getClipBounds(), canvas.getClipBounds(), null);
                            }
                        });
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {

                    }
                });
            }
        });
    }

    private Bitmap zoomImg(Bitmap bm, int targetWidth, int targetHeight) {
        int srcWidth = bm.getWidth();
        int srcHeight = bm.getHeight();
        float widthScale = targetWidth * 1.0f / srcWidth;
        float heightScale = targetHeight * 1.0f / srcHeight;
        Matrix matrix = new Matrix();
        matrix.postScale(widthScale, heightScale, 0, 0);
        Bitmap bmpRet = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(bmpRet);
        Paint paint = new Paint();
        canvas.drawBitmap(bm, matrix, paint);
        return bmpRet;
    }


    protected void startCapture() {
        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                Intent captureIntent = new Intent(getContext(), CameraActivity.class);
                captureIntent.putExtra(TUIChatConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_CAPTURE);
                CameraActivity.mCallBack = new IUIKitCallback() {
                    @Override
                    public void onSuccess(Object data) {
                        Uri contentUri = Uri.fromFile(new File(data.toString()));
                        TUIMessageBean msg = ChatMessageBuilder.buildImageMessage(contentUri);
                        chatView.sendMessage(msg, false);
                        chatView.getInputLayout().hideSoftInput();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                };

                startActivityForResult(captureIntent, REQUEST_CODE_PHOTO);
            }

            @Override
            public void onDenied() {
                TUIChatLog.i(TAG, "startCapture checkPermission failed");
            }
        });
    }

    private void onCaptureResult(Intent intent) {
        TUIChatLog.i(TAG, "onSuccess: " + intent);
        Uri data = intent.getData();
        if (data == null){
            TUIChatLog.e(TAG, "data is null");
            return;
        }

        String uri = data.toString();
        if (TextUtils.isEmpty(uri)){
            TUIChatLog.e(TAG, "uri is empty");
            return;
        }

        String fileName = FileUtil.getFileName(TUIChatService.getAppContext(), (Uri) data);
        String fileExtension = FileUtil.getFileExtensionFromUrl(fileName);
        String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
        if (TextUtils.isEmpty(mimeType)) {
            TUIChatLog.e(TAG, "mimeType is empty.");
            return;
        }
        if (mimeType.contains("video")){
            String videoPath = FileUtil.getPathFromUri((Uri) data);
            TUIMessageBean msg = chatView.getInputLayout().buildVideoMessage(videoPath);
            if (msg == null){
                ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                TUIChatLog.e(TAG, "start send video error data: " + data);
            } else {
                chatView.sendMessage(msg, false);
                chatView.getInputLayout().hideSoftInput();
            }
        } else if (mimeType.contains("image")){
            TUIMessageBean info = ChatMessageBuilder.buildImageMessage((Uri) data);
            if (info == null) {
                TUIChatLog.e(TAG, "start send image error data: " + data);
                ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                return;
            }
            chatView.sendMessage(info, false);
            chatView.getInputLayout().hideSoftInput();
        } else {
            TUIChatLog.e(TAG, "Send photo or video failed , invalid mimeType : " + mimeType);
        }
    }
}
