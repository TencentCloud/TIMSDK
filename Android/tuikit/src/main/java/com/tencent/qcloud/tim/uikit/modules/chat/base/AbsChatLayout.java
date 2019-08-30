package com.tencent.qcloud.tim.uikit.modules.chat.base;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.AudioPlayer;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatProvider;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.utils.NetWorkUtils;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;


public abstract class AbsChatLayout extends ChatLayoutUI implements IChatLayout {

    protected MessageListAdapter mAdapter;

    private AnimationDrawable mVolumeAnim;

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
                final TIMMessage timMsg = msg.getTIMMessage();
                if (timMsg.getElement(0) instanceof TIMTextElem) {
                    TIMTextElem textElem = (TIMTextElem) timMsg.getElement(0);
                    ClipData clip = ClipData.newPlainText("message", textElem.getText());
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
        });
        getMessageLayout().setLoadMoreMessageHandler(new MessageLayout.OnLoadMoreHandler() {
            @Override
            public void loadMore() {
                loadMessages();
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
                        if (touchChild == null)
                            getInputLayout().hideSoftInput();
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
            public void popupLayoutShow() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
            }

            @Override
            public void popupLayoutHide() {
            }

            @Override
            public void startRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        AudioPlayer.getInstance().stopPlayRecord();
                        mRecordingGroup.setVisibility(View.VISIBLE);
                        mRecordingIcon.setImageResource(R.drawable.recording_volume);
                        mVolumeAnim = (AnimationDrawable) mRecordingIcon.getDrawable();
                        mVolumeAnim.start();
                        mRecordingTips.setTextColor(Color.WHITE);
                        mRecordingTips.setText("手指上滑，取消发送");
                    }
                });
            }

            @Override
            public void stopRecording() {
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 500);
            }

            @Override
            public void tooShortRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_length_short);
                        mRecordingTips.setTextColor(Color.WHITE);
                        mRecordingTips.setText("说话时间太短");
                    }
                });
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 1000);
            }

            @Override
            public void cancelRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_cancel);
                        mRecordingTips.setText("松开手指，取消发送");
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
        if (getMessageLayout().getAdapter() == null) {
            mAdapter = new MessageListAdapter();
            getMessageLayout().setAdapter(mAdapter);
        }
        initListener();
    }

    @Override
    public void setParentLayout(Object parentContainer) {

    }

    public void scrollToEnd() {
        getMessageLayout().scrollToEnd();
    }

    public void setDataProvider(IChatProvider provider) {
        if (mAdapter != null) {
            mAdapter.setDataSource(provider);
        }
    }

    public abstract ChatManagerKit getChatManager();

    @Override
    public void loadMessages() {
        loadChatMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1) : null);
    }

    public void loadChatMessages(final MessageInfo lastMessage) {
        if (NetWorkUtils.sIMSDKConnected) {
            getChatManager().loadChatMessages(lastMessage, new IUIKitCallBack() {
                @Override
                public void onSuccess(Object data) {
                    if (lastMessage == null && data != null) {
                        setDataProvider((ChatProvider) data);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastLongMessage(errMsg);
                }
            });
        } else {
            getChatManager().loadLocalChatMessages(lastMessage, new IUIKitCallBack() {
                @Override
                public void onSuccess(Object data) {
                    if (lastMessage == null && data != null) {
                        setDataProvider((ChatProvider) data);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastLongMessage(errMsg);
                }
            });
        }
    }

    protected void deleteMessage(int position, MessageInfo msg) {
        getChatManager().deleteMessage(position, msg);
    }

    protected void revokeMessage(int position, MessageInfo msg) {
        getChatManager().revokeMessage(position, msg);
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
        AudioPlayer.getInstance().stopRecord();
        AudioPlayer.getInstance().stopPlayRecord();
        if (getChatManager() != null) {
            getChatManager().destroyChat();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        exitChat();
    }


}
