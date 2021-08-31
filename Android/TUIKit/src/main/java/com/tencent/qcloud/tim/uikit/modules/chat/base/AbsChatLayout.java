package com.tencent.qcloud.tim.uikit.modules.chat.base;

import android.app.Activity;
import android.app.Dialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.AudioPlayer;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatProvider;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.forward.ForwardSelectActivity;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;


public abstract class AbsChatLayout extends ChatLayoutUI implements IChatLayout {
    private static final String TAG = AbsChatLayout.class.getSimpleName();
    // 逐条转发消息数量限制
    private static final int FORWARD_MSG_NUM_LIMIT = 30;

    protected MessageListAdapter mAdapter;
    private onForwardSelectActivityListener mForwardSelectActivityListener;

    private V2TIMMessage mConversationLastMessage;

    private AnimationDrawable mVolumeAnim;
    private Runnable mTypingRunnable = null;
    private ChatProvider.TypingListener mTypingListener = new ChatProvider.TypingListener() {
        @Override
        public void onTyping() {
            final String oldTitle = getTitleBar().getMiddleTitle().getText().toString();
            getTitleBar().getMiddleTitle().setText(R.string.typing);
            if (mTypingRunnable == null) {
                mTypingRunnable = new Runnable() {
                    @Override
                    public void run() {
                        getTitleBar().getMiddleTitle().setText(oldTitle);
                    }
                };
            }
            getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
            getTitleBar().getMiddleTitle().postDelayed(mTypingRunnable, 3000);
        }
    };

    public AbsChatLayout(Context context) {
        super(context);
    }

    public AbsChatLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public AbsChatLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    private void initListener() {
        getMessageLayout().setPopActionClickListener(new MessageLayout.OnPopActionClickListener() {
            @Override
            public void onCopyClick(int position, MessageInfo msg) {
                ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                if (clipboard == null || msg == null) {
                    return;
                }
                if (msg.getMsgType() == MessageInfo.MSG_TYPE_TEXT) {
                    V2TIMTextElem textElem = msg.getTimMessage().getTextElem();
                    String copyContent;
                    if (textElem == null) {
                        copyContent = (String) msg.getExtra();
                    } else {
                        copyContent = textElem.getText();
                    }
                    ClipData clip = ClipData.newPlainText("message", copyContent);
                    clipboard.setPrimaryClip(clip);
                }
            }

            @Override
            public void onSendMessageClick(MessageInfo msg, boolean retry) {
                sendMessage(msg, retry);
            }

            @Override
            public void onDeleteMessageClick(int position, MessageInfo msg) {
                deleteMessage(position, msg);
            }

            @Override
            public void onRevokeMessageClick(int position, MessageInfo msg) {
                revokeMessage(position, msg);
            }

            @Override
            public void onMultiSelectMessageClick(int position, MessageInfo msg) {
                multiSelectMessage(position, msg);
            }

            @Override
            public void onForwardMessageClick(int position, MessageInfo msg){
                forwardMessage(position, msg);
            }
        });
        getMessageLayout().setLoadMoreMessageHandler(new MessageLayout.OnLoadMoreHandler() {
            @Override
            public void loadMore(int type) {
                loadMessages(type);
            }

            @Override
            public boolean isListEnd(int postion) {
                if (mAdapter == null || mConversationLastMessage == null || mAdapter.getItem(postion) == null) {
                    return true;
                }
                if (postion < 0 || postion >= mAdapter.getItemCount()) {
                    return true;
                }

                if (mAdapter.getItem(postion).getTimMessage().getSeq() < mConversationLastMessage.getSeq()) {
                    return false;
                }
                return true;
            }
        });
        getMessageLayout().setEmptySpaceClickListener(new MessageLayout.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                getInputLayout().hideSoftInput();
            }
        });

        /**
         * 设置消息列表空白处点击处理
         */
        getMessageLayout().addOnItemTouchListener(new RecyclerView.OnItemTouchListener() {
            @Override
            public boolean onInterceptTouchEvent(RecyclerView rv, MotionEvent e) {
                if (e.getAction() == MotionEvent.ACTION_UP) {
                    View child = rv.findChildViewUnder(e.getX(), e.getY());
                    if (child == null) {
                        getInputLayout().hideSoftInput();
                    } else if (child instanceof ViewGroup) {
                        ViewGroup group = (ViewGroup) child;
                        final int count = group.getChildCount();
                        float x = e.getRawX();
                        float y = e.getRawY();
                        View touchChild = null;
                        for (int i = count - 1; i >= 0; i--) {
                            final View innerChild = group.getChildAt(i);
                            int position[] = new int[2];
                            innerChild.getLocationOnScreen(position);
                            if (x >= position[0]
                                    && x <= position[0] + innerChild.getMeasuredWidth()
                                    && y >= position[1]
                                    && y <= position[1] + innerChild.getMeasuredHeight()) {
                                touchChild = innerChild;
                                break;
                            }
                        }
                        if (touchChild == null) {
                            getInputLayout().hideSoftInput();
                        }
                    }
                }
                return false;
            }

            @Override
            public void onTouchEvent(RecyclerView rv, MotionEvent e) {

            }

            @Override
            public void onRequestDisallowInterceptTouchEvent(boolean disallowIntercept) {

            }
        });

        getInputLayout().setChatInputHandler(new InputLayout.ChatInputHandler() {
            @Override
            public void onInputAreaClick() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
            }

            @Override
            public void onRecordStatusChanged(int status) {
                switch (status) {
                    case RECORD_START:
                        startRecording();
                        break;
                    case RECORD_STOP:
                        stopRecording();
                        break;
                    case RECORD_CANCEL:
                        cancelRecording();
                        break;
                    case RECORD_TOO_SHORT:
                    case RECORD_FAILED:
                        stopAbnormally(status);
                        break;
                    default:
                        break;
                }
            }

            private void startRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        AudioPlayer.getInstance().stopPlay();
                        mRecordingGroup.setVisibility(View.VISIBLE);
                        mRecordingIcon.setImageResource(R.drawable.recording_volume);
                        mVolumeAnim = (AnimationDrawable) mRecordingIcon.getDrawable();
                        mVolumeAnim.start();
                        mRecordingTips.setTextColor(Color.WHITE);
                        mRecordingTips.setText(TUIKit.getAppContext().getString(R.string.down_cancle_send));
                    }
                });
            }

            private void stopRecording() {
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 500);
            }

            private void stopAbnormally(final int status) {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_length_short);
                        mRecordingTips.setTextColor(Color.WHITE);
                        if (status == RECORD_TOO_SHORT) {
                            mRecordingTips.setText(TUIKit.getAppContext().getString(R.string.say_time_short));
                        } else {
                            mRecordingTips.setText(TUIKit.getAppContext().getString(R.string.record_fail));
                        }
                    }
                });
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 1000);
            }

            private void cancelRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_cancel);
                        mRecordingTips.setText(TUIKit.getAppContext().getString(R.string.up_cancle_send));
                    }
                });
            }
        });
    }

    @Override
    public void initDefault() {
        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
        getInputLayout().setMessageHandler(new InputLayout.MessageHandler() {
            @Override
            public void sendMessage(MessageInfo msg) {
                AbsChatLayout.this.sendMessage(msg, false);
            }
        });
        getInputLayout().clearCustomActionList();
        if (getMessageLayout().getAdapter() == null) {
            mAdapter = new MessageListAdapter();
            getMessageLayout().setAdapter(mAdapter);
        }
        initListener();
        resetForwardState("");
    }

    @Override
    public void setParentLayout(Object parentContainer) {

    }

    public void scrollToEnd() {
        getMessageLayout().scrollToEnd();
    }

    public void setDataProvider(IChatProvider provider) {
        if (provider != null) {
            ((ChatProvider) provider).setTypingListener(mTypingListener);
        }
        if (mAdapter != null) {
            mAdapter.setDataSource(provider);
            getChatManager().setLastMessageInfo(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1) : null);
        }
    }

    public abstract ChatManagerKit getChatManager();

    @Override
    public void loadMessages(int type) {
        if (type == TUIKitConstants.GET_MESSAGE_FORWARD) {
            loadChatMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1).getTimMessage() : null, type);
        } else if (type == TUIKitConstants.GET_MESSAGE_BACKWARD){
            loadChatMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(mAdapter.getItemCount() -1).getTimMessage() : null, type);
        }
    }

    public void loadChatMessages(final V2TIMMessage lastMessage, final int getMessageType) {
        getChatManager().loadChatMessages(getMessageType, lastMessage, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (getMessageType == TUIKitConstants.GET_MESSAGE_TWO_WAY || (lastMessage == null && data != null)) {
                    setDataProvider((ChatProvider) data);
                }

                if (getMessageType == TUIKitConstants.GET_MESSAGE_TWO_WAY) {
                    if (mAdapter != null) {
                       mAdapter.notifyDataSourceChanged(MessageLayout.DATA_CHANGE_SCROLL_TO_POSITION, mAdapter.getLastMessagePosition(lastMessage));
                    }
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
                if (lastMessage == null) {
                    setDataProvider(null);
                }
            }
        });
    }

    public void getConversationLastMessage(String id) {
        V2TIMManager.getConversationManager().getConversation(id, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "getConversationLastMessage error:" + code + ", desc:" + desc);
            }

            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                if (v2TIMConversation == null){
                    Log.d(TAG,"getConversationLastMessage failed");
                    mConversationLastMessage = null;
                    return;
                }
                mConversationLastMessage = v2TIMConversation.getLastMessage();
            }
        });
    }

    protected void deleteMessage(int position, MessageInfo msg) {
        getChatManager().deleteMessage(position, msg);
    }

    protected void deleteMessages(final List<Integer> positions) {
        getChatManager().deleteMessages(positions);
    }

    protected void deleteMessageInfos(final List<MessageInfo> msgIds) {
        getChatManager().deleteMessageInfos(msgIds);
    }

    protected boolean checkFailedMessage(final List<Integer> positions) {
        return getChatManager().checkFailedMessages(positions);
    }

    protected boolean checkFailedMessageInfos(final List<MessageInfo> msgIds){
        return getChatManager().checkFailedMessageInfos(msgIds);
    }

    protected void revokeMessage(int position, MessageInfo msg) {
        getChatManager().revokeMessage(position, msg);
    }

    protected void multiSelectMessage(int position, MessageInfo msg) {
        if(mAdapter != null){
            mAdapter.setShowMutiSelectCheckBox(true);
            mAdapter.setItemChecked(msg.getId(), true);
            mAdapter.notifyDataSetChanged();

            setTitleBarWhenMultiSelectMessage();
        }
    }

    protected void forwardMessage(int position, MessageInfo msg) {
        if (mAdapter != null) {
            mAdapter.setItemChecked(msg.getId(), true);
            mAdapter.notifyDataSetChanged();
            showForwardDialog(false);
        }
    }

    private void resetTitleBar(String leftTitle){
        getTitleBar().getRightGroup().setVisibility(VISIBLE);

        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().getLeftIcon().setVisibility(VISIBLE);
        if (!TextUtils.isEmpty(leftTitle)) {
            getTitleBar().setTitle(leftTitle, TitleBarLayout.POSITION.LEFT);
        } else {
            getTitleBar().setTitle("", TitleBarLayout.POSITION.LEFT);
        }
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });

        getForwardLayout().setVisibility(GONE);
    }

    private void resetForwardState(String leftTitle){
        //取消多选界面
        if(mAdapter != null){
            mAdapter.setShowMutiSelectCheckBox(false);
            mAdapter.notifyDataSetChanged();
        }

        //重置titlebar
        resetTitleBar(leftTitle);
    }

    private void setTitleBarWhenMultiSelectMessage(){
        getTitleBar().getRightGroup().setVisibility(GONE);

        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().getLeftIcon().setVisibility(GONE);
        final CharSequence leftTitle = getTitleBar().getLeftTitle().getText();
        getTitleBar().setTitle(getContext().getString(R.string.cancel), TitleBarLayout.POSITION.LEFT);
        //点击取消
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                resetForwardState(leftTitle.toString());
            }
        });

        getForwardLayout().setVisibility(VISIBLE);
        //点击转发
        getForwardButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                showForwardDialog(true);
            }
        });

        //点击删除
        getDeleteButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                List<MessageInfo> msgIds = new ArrayList<MessageInfo>();
                msgIds =  mAdapter.getSelectedItem();

                if(msgIds == null || msgIds.isEmpty()){
                    ToastUtil.toastShortMessage("please select message!");
                    return;
                }

                //deleteMessages(msgIds);
                deleteMessageInfos(msgIds);

                resetForwardState(leftTitle.toString());
            }
        });
    }

    private String SwitchToForwardBundle(List<V2TIMMessage> msgList){
        if (msgList == null || msgList.size() == 0) {
            return "";
        }

        String bundle = "";
        for(int i = 0; i < msgList.size(); i++){
            bundle += msgList.get(i).getMsgID();
            bundle += ",";
        }
        //TUIKitLog.i(TAG, "bundle = " + bundle);
        return bundle;
    }

    private List<MessageInfo> SwitchToV2TIMMessage(List<Integer> positions){
        if (positions == null || positions.size() == 0) {
            return null;
        }

        List<MessageInfo> msgList = getChatManager().getSelectPositionMessage(positions);

        return msgList;
    }

    private void showForwardDialog(boolean isMultiSelect) {
        if (mAdapter == null){
            return;
        }

        final List<MessageInfo> messageInfoList = mAdapter.getSelectedItem();
        if(messageInfoList == null || messageInfoList.isEmpty()){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_tip));
            return;
        }

        if(checkFailedMessageInfos(messageInfoList)){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_failed_tip));
            return;
        }

        if (!isMultiSelect) {
            mAdapter.setShowMutiSelectCheckBox(false);//发送完清理选中
        }

        final Dialog bottomDialog = new Dialog(getContext(), R.style.BottomDialog);
        View contentView = LayoutInflater.from(getContext()).inflate(R.layout.forward_dialog_layout, null);
        bottomDialog.setContentView(contentView);
        ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) contentView.getLayoutParams();
        params.width = getResources().getDisplayMetrics().widthPixels - 8;
        contentView.setLayoutParams(params);
        bottomDialog.getWindow().setGravity(Gravity.BOTTOM);
        bottomDialog.getWindow().setWindowAnimations(R.style.BottomDialog_Animation);
        bottomDialog.show();

        contentView.findViewById(R.id.forward_one_by_one).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (messageInfoList.size() > FORWARD_MSG_NUM_LIMIT) {
                    showForwardLimitDialog(bottomDialog, messageInfoList);
                } else {
                    bottomDialog.dismiss();
                    startSelectForwardActivity(ForwardSelectActivity.FORWARD_MODE_ONE_BY_ONE, messageInfoList);
                    resetForwardState("");
                    ;//发送完清理选中
                }
            }
        });
        contentView.findViewById(R.id.forward_merge).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                bottomDialog.dismiss();

                startSelectForwardActivity(ForwardSelectActivity.FORWARD_MODE_MERGE, messageInfoList);
                resetForwardState("");;//发送完清理选中
            }
        });
        contentView.findViewById(R.id.cancel_action).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                bottomDialog.dismiss();
            }
        });
    }

    private void showForwardLimitDialog(final Dialog bottomDialog, final List<MessageInfo> messageInfoList) {
        TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.forward_oneByOne_limit_number_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(R.string.forward_mode_merge), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        bottomDialog.dismiss();
                        startSelectForwardActivity(ForwardSelectActivity.FORWARD_MODE_MERGE, messageInfoList);
                        resetForwardState("");;//发送完清理选中
                    }
                })
                .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                    }
                });
         tipsDialog.show();
    }

    private void startSelectForwardActivity(int mode, List<MessageInfo> msgIds){
        if (mForwardSelectActivityListener != null) {
            mForwardSelectActivityListener.onStartForwardSelectActivity(mode, msgIds);
        }
    }

    public void setForwardSelectActivityListener(onForwardSelectActivityListener listener) {
        this.mForwardSelectActivityListener = listener;
    }

    @Override
    public void sendMessage(MessageInfo msg, boolean retry) {
        getChatManager().sendMessage(msg, retry, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    @Override
    public void exitChat() {
        getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
        AudioPlayer.getInstance().stopRecord();
        AudioPlayer.getInstance().stopPlay();
        ChatManagerKit.markMessageAsRead(mChatInfo);
        if (getChatManager() != null) {
            // 两者不相等说明 ChatManagerKit 中的 ChatInfo 已经在外部被修改，不能销毁不属于自己的 ChatInfo
            if (getChatInfo() != getChatManager().getCurrentChatInfo()) {
                return;
            }
            getChatManager().destroyChat();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        exitChat();
    }

    public interface onForwardSelectActivityListener {
        public void onStartForwardSelectActivity(int mode, List<MessageInfo> msgIds);
    }

}
