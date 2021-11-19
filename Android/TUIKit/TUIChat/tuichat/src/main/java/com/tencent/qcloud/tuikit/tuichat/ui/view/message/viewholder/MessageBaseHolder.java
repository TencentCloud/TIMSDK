package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageProperties;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemLongClickListener;

import java.util.Date;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {
    public static final int MSG_TYPE_HEADER_VIEW = -99;

    public ICommonMessageAdapter mAdapter;
    public MessageProperties properties = MessageProperties.getInstance();
    protected OnItemLongClickListener onItemLongClickListener;

    public TextView chatTimeText;
    public FrameLayout msgContentFrame;
    public CheckBox mMutiSelectCheckBox;
    public RelativeLayout rightGroupLayout;
    public RelativeLayout mContentLayout;


    public MessageBaseHolder(View itemView) {
        super(itemView);
        chatTimeText = itemView.findViewById(R.id.chat_time_tv);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        mMutiSelectCheckBox = itemView.findViewById(R.id.select_checkbox);
        rightGroupLayout = itemView.findViewById(R.id.right_group_layout);
        mContentLayout = itemView.findViewById(R.id.messsage_content_layout);
        initVariableLayout();
    }

    public abstract int getVariableLayout();

    private void setVariableLayout(int resId) {
        if (msgContentFrame.getChildCount() == 0) {
            View.inflate(itemView.getContext(), resId, msgContentFrame);
        }
    }

    private void initVariableLayout() {
        if (getVariableLayout() != 0) {
            setVariableLayout(getVariableLayout());
        }
    }

    public void setAdapter(ICommonMessageAdapter adapter) {
        mAdapter = adapter;
    }

    public void setOnItemClickListener(OnItemLongClickListener listener) {
        this.onItemLongClickListener = listener;
    }

    public OnItemLongClickListener getOnItemClickListener() {
        return this.onItemLongClickListener;
    }

    public void layoutViews(final TUIMessageBean msg, final int position) {

        //// 时间线设置
        if (properties.getChatTimeBubble() != null) {
            chatTimeText.setBackground(properties.getChatTimeBubble());
        }
        if (properties.getChatTimeFontColor() != 0) {
            chatTimeText.setTextColor(properties.getChatTimeFontColor());
        }
        if (properties.getChatTimeFontSize() != 0) {
            chatTimeText.setTextSize(properties.getChatTimeFontSize());
        }

        if (position > 1) {
            TUIMessageBean last = mAdapter.getItem(position - 1);
            if (last != null) {
                if (msg.getMessageTime() - last.getMessageTime() >= 5 * 60) {
                    chatTimeText.setVisibility(View.VISIBLE);
                    chatTimeText.setText(DateTimeUtil.getTimeFormatText(new Date(msg.getMessageTime() * 1000)));
                } else {
                    chatTimeText.setVisibility(View.GONE);
                }
            }
        } else {
            chatTimeText.setVisibility(View.VISIBLE);
            chatTimeText.setText(DateTimeUtil.getTimeFormatText(new Date(msg.getMessageTime() * 1000)));
        }
    }

}
