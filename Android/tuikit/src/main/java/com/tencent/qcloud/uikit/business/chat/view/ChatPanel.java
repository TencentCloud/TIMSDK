package com.tencent.qcloud.uikit.business.chat.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.chat.IChatAdapter;
import com.tencent.qcloud.uikit.api.chat.IChatPanel;
import com.tencent.qcloud.uikit.api.chat.IChatProvider;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAdapter;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatAdapter;
import com.tencent.qcloud.uikit.business.chat.view.widget.MessageOperaUnit;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatListEvent;
import com.tencent.qcloud.uikit.common.component.audio.UIKitAudioArmMachine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;
import com.tencent.qcloud.uikit.common.utils.ScreenUtil;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/18.
 */

public abstract class ChatPanel extends LinearLayout implements IChatPanel {
    /**
     * 标题栏
     */
    public PageTitleBar mTitleBar;
    /**
     * 聊天列表
     */
    public ChatListView mChatList;
    /**
     * 聊天列表适配器
     */
    public IChatAdapter mAdapter;
    /**
     * 聊天面板底部输入组件
     */
    public ChatBottomInputGroup mInputGroup;


    /**
     * 消息长按弹框列表
     */
    public ListView mItemPopMenuList;

    /**
     * 聊天界面顶部提示栏（通知类型的消息，如加群申请）
     */
    public View mTipsGroup;
    public TextView mTipsContent, mTipsHandel;

    private AnimationDrawable mVolumeAnim;

    private PopupWindow mPopWindow;
    private PopMenuAdapter mItemMenuAdapter;
    private View mRecordingGroup;
    private ImageView mRecordingIcon;
    private TextView mRecordingTips;
    private ChatListEvent mEvent;


    private List<PopMenuAction> mMessagePopActions = new ArrayList<>();

    public ChatPanel(Context context) {
        super(context);
        init();
    }

    public ChatPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ChatPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    /**
     * 初始化
     */
    private void init() {
        inflate(getContext(), R.layout.chat_panel, this);
        mTitleBar = findViewById(R.id.chat_page_title);

        mChatList = findViewById(R.id.chat_list);
        mChatList.setMLoadMoreHandler(new ChatListView.OnLoadMoreHandler() {
            @Override
            public void loadMore() {
                loadMessages();
            }
        });
        mChatList.setEmptySpaceClickListener(new ChatListView.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                mInputGroup.hideSoftInput();
            }
        });

        /**
         * 设置消息列表空白处点击处理
         */
        mChatList.addOnItemTouchListener(new RecyclerView.OnItemTouchListener() {
            @Override
            public boolean onInterceptTouchEvent(RecyclerView rv, MotionEvent e) {
                if (e.getAction() == MotionEvent.ACTION_UP) {
                    View child = rv.findChildViewUnder(e.getX(), e.getY());
                    if (child == null) {
                        mInputGroup.hideSoftInput();
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
                            mInputGroup.hideSoftInput();
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

        mInputGroup = findViewById(R.id.chat_bottom_box);
        mInputGroup.setInputHandler(new ChatBottomInputGroup.ChatInputHandler()

        {
            @Override
            public void popupAreaShow() {
                scrollToEnd();
            }

            @Override
            public void popupAreaHide() {
            }

            @Override
            public void startRecording() {
                mRecordingIcon.setImageResource(R.drawable.recording_volume);
                mVolumeAnim = (AnimationDrawable) mRecordingIcon.getDrawable();
                mRecordingGroup.setVisibility(View.VISIBLE);
                mVolumeAnim.start();
                mRecordingTips.setTextColor(Color.WHITE);
                mRecordingTips.setText("上滑取消录音");
            }

            @Override
            public void stopRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                });

            }

            @Override
            public void tooShortRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingIcon.setImageResource(R.drawable.exclama);
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
                mRecordingIcon.setImageResource(R.drawable.recording_cancel);
                mRecordingTips.setTextColor(Color.RED);
                mRecordingTips.setText("松开手指，取消发送");
            }
        });

        mRecordingGroup =

                findViewById(R.id.voice_recording_view);

        mRecordingIcon =

                findViewById(R.id.recording_icon);

        mRecordingTips =

                findViewById(R.id.recording_tips);

        mChatList.setAdapter(mAdapter);


        mTipsGroup =

                findViewById(R.id.chat_tips_group);

        mTipsContent =

                findViewById(R.id.chat_tips_content);

        mTipsHandel =

                findViewById(R.id.chat_tips_handle);


    }


    public abstract void sendMessage(MessageInfo messageInfo);

    public abstract void loadMessages();

    public void setChatAdapter(IChatAdapter adapter) {
        mAdapter = adapter;
        mChatList.setAdapter(mAdapter);
        if (mEvent != null && mAdapter instanceof ChatAdapter)
            ((ChatAdapter) mAdapter).setChatListEvent(mEvent);
    }

    public void scrollToEnd() {
        mChatList.scrollToEnd();
    }


    public void setChatListEvent(ChatListEvent event) {
        this.mEvent = event;
        if (mAdapter != null && mAdapter instanceof ChatAdapter)
            ((ChatAdapter) mAdapter).setChatListEvent(event);
    }


    public void setDataProvider(IChatProvider provider) {
        if (mAdapter != null)
            mAdapter.setDataSource(provider);
    }


    public void setMoreOperaUnits(List<MessageOperaUnit> units, boolean isAdd) {
        mInputGroup.setMoreOperaUnits(units, isAdd);
    }


    public void setMessagePopActions(List<PopMenuAction> actions, boolean isAdd) {
        if (isAdd)
            mMessagePopActions.addAll(actions);
        else
            mMessagePopActions = actions;
    }


    public void refreshData() {
        mAdapter.notifyDataSetChanged(ChatListView.DATA_CHANGE_TYPE_REFRESH, 0);
    }


    void showItemPopMenu(final int index, final MessageInfo messageInfo, View view) {
        initPopActions(messageInfo);
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        int locationX = location[0];
        int locationY = location[1];
        int parentViewHeight = view.getMeasuredHeight();
        if (mMessagePopActions == null || mMessagePopActions.size() == 0)
            return;
        View itemPop = inflate(getContext(), R.layout.pop_menu_layout, null);
        mItemPopMenuList = itemPop.findViewById(R.id.pop_menu_list);
        mItemPopMenuList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = mMessagePopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(index, messageInfo);
                }
                mPopWindow.dismiss();
            }
        });
        int viewHeight = UIUtils.getPxByDp(40) * mMessagePopActions.size();
        mItemMenuAdapter = new PopMenuAdapter();
        mItemPopMenuList.setAdapter(mItemMenuAdapter);
        mItemMenuAdapter.setDataSource(mMessagePopActions);
        locationY = locationY - viewHeight;
        if (locationY < 50)
            locationY = locationY + viewHeight + parentViewHeight;
        mPopWindow = PopWindowUtil.popupWindow(itemPop, this, (int) locationX, (int) locationY);
    }

    protected void initPopActions(MessageInfo msg) {

    }

    @Override
    public void initDefault() {
        mInputGroup.setMsgHandler(new ChatBottomInputGroup.MessageHandler() {
            @Override
            public void sendMessage(MessageInfo msg) {
                ChatPanel.this.sendMessage(msg);
            }
        });
    }

    public void initDefaultEvent() {
        setChatListEvent(new ChatListEvent() {

            @Override
            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {
                //因为adapter中第一条为加载条目，位置需减1
                showItemPopMenu(position - 1, mAdapter.getItem(position), view);
            }

            @Override
            public void onUserIconClick(View view, int position, MessageInfo messageInfo) {
                UIUtils.toastLongMessage("头像点击");
            }
        });
        mTitleBar.setLeftClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
    }

    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }

}
