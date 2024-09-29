package com.tencent.qcloud.tuikit.timcommon.classicui.widget.message;

import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.highlight.HighlightPresenter;
import com.tencent.qcloud.tuikit.timcommon.config.classicui.TUIConfigClassic;
import com.tencent.qcloud.tuikit.timcommon.interfaces.HighlightListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import java.util.Date;

public abstract class MessageBaseHolder<T extends TUIMessageBean> extends RecyclerView.ViewHolder {
    public ICommonMessageAdapter mAdapter;
    protected OnItemClickListener onItemClickListener;

    public TextView chatTimeText;
    public FrameLayout msgContentFrame;
    public LinearLayout msgReplyDetailLayout;
    public LinearLayout msgArea;
    public LinearLayout msgAreaAndReply;
    public FrameLayout reactionArea;
    public CheckBox mMutiSelectCheckBox;
    public RelativeLayout rightGroupLayout;
    public RelativeLayout mContentLayout;
    private HighlightListener highlightListener;
    protected T currentMessageBean;

    public MessageBaseHolder(View itemView) {
        super(itemView);
        chatTimeText = itemView.findViewById(R.id.message_top_time_tv);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        msgReplyDetailLayout = itemView.findViewById(R.id.msg_reply_detail_fl);
        reactionArea = itemView.findViewById(R.id.message_reaction_area);
        msgArea = itemView.findViewById(R.id.msg_area);
        msgAreaAndReply = itemView.findViewById(R.id.msg_area_and_reply);
        mMutiSelectCheckBox = itemView.findViewById(R.id.select_checkbox);
        rightGroupLayout = itemView.findViewById(R.id.right_group_layout);
        mContentLayout = itemView.findViewById(R.id.message_content_layout);
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

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    public OnItemClickListener getOnItemClickListener() {
        return this.onItemClickListener;
    }

    public void layoutViews(final T msg, final int position) {
        currentMessageBean = msg;
        registerHighlightListener(msg.getId());
        setChatTimeStyle();

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

    private void setChatTimeStyle() {
        Drawable chatTimeBubble = TUIConfigClassic.getChatTimeBubble();
        if (chatTimeBubble != null) {
            chatTimeText.setBackground(chatTimeBubble);
        }
        int chatTimeFontColor = TUIConfigClassic.getChatTimeFontColor();
        if (chatTimeFontColor != TUIConfigClassic.UNDEFINED) {
            chatTimeText.setTextColor(chatTimeFontColor);
        }
        int chatTimeFontSize = TUIConfigClassic.getChatTimeFontSize();
        if (chatTimeFontSize != TUIConfigClassic.UNDEFINED) {
            chatTimeText.setTextSize(chatTimeFontSize);
        }
    }

    private void registerHighlightListener(String msgID) {
        if (highlightListener == null) {
            highlightListener = new HighlightListener() {
                @Override
                public void onHighlightStart() {}

                @Override
                public void onHighlightEnd() {
                    clearHighLightBackground();
                }

                @Override
                public void onHighlightUpdate(int color) {
                    setHighLightBackground(color);
                }
            };
        }
        HighlightPresenter.registerHighlightListener(msgID, highlightListener);
    }

    public void onRecycled() {
        if (currentMessageBean != null) {
            HighlightPresenter.unregisterHighlightListener(currentMessageBean.getId());
        }
    }

    public void setMessageBubbleZeroPadding() {
        if (msgArea == null) {
            return;
        }
        msgArea.setPaddingRelative(0, 0, 0, 0);
    }

    public void setMessageBubbleBackground(int resID) {
        if (msgArea == null) {
            return;
        }
        msgArea.setBackgroundResource(resID);
    }

    public void setMessageBubbleBackground(Drawable drawable) {
        if (msgArea == null) {
            return;
        }
        msgArea.setBackground(drawable);
    }

    public Drawable getMessageBubbleBackground() {
        if (msgArea == null) {
            return null;
        }
        return msgArea.getBackground();
    }

    public void setHighLightBackground(int color) {
        Drawable drawable = getMessageBubbleBackground();
        if (drawable != null) {
            drawable.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
    }

    public void clearHighLightBackground() {
        Drawable drawable = getMessageBubbleBackground();
        if (drawable != null) {
            drawable.setColorFilter(null);
        }
    }
}
