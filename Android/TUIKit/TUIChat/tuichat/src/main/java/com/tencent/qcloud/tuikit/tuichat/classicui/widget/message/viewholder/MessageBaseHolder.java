package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.animation.Animator;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.MessageProperties;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.ChatFlowReactView;

import java.util.Date;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {
    public static final int MSG_TYPE_HEADER_VIEW = -99;

    public ICommonMessageAdapter mAdapter;
    public MessageProperties properties = MessageProperties.getInstance();
    protected OnItemClickListener onItemClickListener;

    public TextView chatTimeText;
    public FrameLayout msgContentFrame;
    public LinearLayout msgReplyDetailLayout;
    public LinearLayout msgArea;
    public LinearLayout msgAreaAndReply;
    public ChatFlowReactView reactView;
    public CheckBox mMutiSelectCheckBox;
    public RelativeLayout rightGroupLayout;
    public RelativeLayout mContentLayout;

    private ValueAnimator highLightAnimator;
    public MessageBaseHolder(View itemView) {
        super(itemView);
        chatTimeText = itemView.findViewById(R.id.message_top_time_tv);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        msgReplyDetailLayout = itemView.findViewById(R.id.msg_reply_detail_fl);
        reactView = itemView.findViewById(R.id.reacts_view);
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

    public void layoutViews(final TUIMessageBean msg, final int position) {
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

    public void stopHighLight() {
        if (highLightAnimator != null) {
            highLightAnimator.cancel();
        }
        clearHighLightBackground();
    }

    public void startHighLight() {
        int highLightColorDark = itemView.getResources().getColor(R.color.chat_message_bubble_high_light_dark_color);
        int highLightColorLight = itemView.getResources().getColor(R.color.chat_message_bubble_high_light_light_color);

        if (highLightAnimator == null) {
            ArgbEvaluator argbEvaluator = new ArgbEvaluator();
            highLightAnimator = new ValueAnimator();
            highLightAnimator.setIntValues(highLightColorDark, highLightColorLight);
            highLightAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    Integer color = (Integer) animation.getAnimatedValue();
                    setHighLightBackground(color);
                }
            });
            highLightAnimator.addListener(new Animator.AnimatorListener() {
                @Override
                public void onAnimationStart(Animator animation) {

                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    clearHighLightBackground();
                }

                @Override
                public void onAnimationCancel(Animator animation) {
                    clearHighLightBackground();
                }

                @Override
                public void onAnimationRepeat(Animator animation) {

                }
            });
            highLightAnimator.setEvaluator(argbEvaluator);
            highLightAnimator.setRepeatCount(3);
            highLightAnimator.setDuration(250);
            highLightAnimator.setRepeatMode(ValueAnimator.REVERSE);
        }
        highLightAnimator.start();
    }

    public void setHighLightBackground(int color) {
        Drawable drawable = msgArea.getBackground();
        if (drawable != null) {
            drawable.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
    }

    public void clearHighLightBackground() {
        Drawable drawable = msgArea.getBackground();
        if (drawable != null) {
            drawable.setColorFilter(null);
        }
    }

}
