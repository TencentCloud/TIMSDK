package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.animation.Animator;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.MessageProperties;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {
    public static final int MSG_TYPE_HEADER_VIEW = -99;

    public ICommonMessageAdapter mAdapter;
    public MessageProperties properties = MessageProperties.getInstance();
    protected OnItemClickListener onItemClickListener;

    public FrameLayout msgContentFrame;
    public LinearLayout msgArea;
    public LinearLayout msgAreaAndReply;
    public ChatReactView reactView;
    public CheckBox mMutiSelectCheckBox;
    public View mContentLayout;

    private ValueAnimator highLightAnimator;
    public TextView chatTimeText;

    protected boolean floatMode = false;

    protected boolean isShowStart = true;

    public MessageBaseHolder(View itemView) {
        super(itemView);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        reactView = itemView.findViewById(R.id.reacts_view);
        msgArea = itemView.findViewById(R.id.msg_area);
        msgAreaAndReply = itemView.findViewById(R.id.msg_area_and_reply);
        mMutiSelectCheckBox = itemView.findViewById(R.id.select_checkbox);
        chatTimeText = itemView.findViewById(R.id.message_top_time_tv);
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
                    chatTimeText.setText(getTimeFormatText(new Date(msg.getMessageTime() * 1000)));
                } else {
                    chatTimeText.setVisibility(View.GONE);
                }
            }
        } else {
            chatTimeText.setVisibility(View.VISIBLE);
            chatTimeText.setText(getTimeFormatText(new Date(msg.getMessageTime() * 1000)));
        }
    }

    public static String getTimeFormatText(Date date) {
        if (date == null) {
            return "";
        }
        Context context = TUIConfig.getAppContext();
        Locale locale;
        if (context == null) {
            locale = Locale.getDefault();
        } else {
            locale = TUIThemeManager.getInstance().getLocale(context);
        }
        String timeText;
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_WEEK, 1);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_YEAR, 1);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        long dayStartTimeInMillis = calendar.getTimeInMillis();
        long yearStartTimeInMillis = calendar.getTimeInMillis();
        long weekStartTimeInMillis = calendar.getTimeInMillis();
        long outTimeMillis = date.getTime();
        if (outTimeMillis < yearStartTimeInMillis) {
            timeText = String.format(locale, "%1$tY/%1$tm/%1$td", date);
        } else if (outTimeMillis < weekStartTimeInMillis) {
            timeText = String.format(locale, "%1$tm/%1$td", date);
        } else if (outTimeMillis < dayStartTimeInMillis) {
            timeText = String.format(locale, "%tA", date);
        } else {
            timeText = context.getResources().getString(R.string.chat_time_today);
        }
        return timeText;
    }

    public void setFloatMode(boolean floatMode) {
        this.floatMode = floatMode;
    }

    public void stopHighLight() {
        if (highLightAnimator != null) {
            highLightAnimator.cancel();
        }
        clearHighLightBackground();
    }

    protected boolean isShowAvatar(TUIMessageBean messageBean) {
        return false;
    }
    
    public void startHighLight() {
        int highLightColorDark = itemView.getResources().getColor(R.color.chat_message_bubble_high_light_dark_color);
        int highLightColorLight = itemView.getResources().getColor(R.color.chat_message_bubble_high_light_light_color);

        if (highLightAnimator == null) {
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
                public void onAnimationStart(Animator animation) {}

                @Override
                public void onAnimationEnd(Animator animation) {
                    clearHighLightBackground();
                }

                @Override
                public void onAnimationCancel(Animator animation) {
                    clearHighLightBackground();
                }

                @Override
                public void onAnimationRepeat(Animator animation) {}
            });
            ArgbEvaluator argbEvaluator = new ArgbEvaluator();
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
