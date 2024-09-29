package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

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
import com.tencent.qcloud.tuikit.timcommon.component.highlight.HighlightPresenter;
import com.tencent.qcloud.tuikit.timcommon.config.minimalistui.TUIConfigMinimalist;
import com.tencent.qcloud.tuikit.timcommon.interfaces.HighlightListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {
    public ICommonMessageAdapter mAdapter;
    protected OnItemClickListener onItemClickListener;

    public FrameLayout msgContentFrame;
    public LinearLayout msgArea;
    public LinearLayout msgAreaAndReply;
    public FrameLayout reactionArea;
    public CheckBox mMutiSelectCheckBox;
    public View mContentLayout;

    public TextView chatTimeText;

    protected boolean floatMode = false;

    protected boolean isLayoutOnStart = true;
    private HighlightListener highlightListener;
    protected TUIMessageBean currentMessageBean;

    public MessageBaseHolder(View itemView) {
        super(itemView);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        reactionArea = itemView.findViewById(R.id.message_reaction_area);
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
        currentMessageBean = msg;
        registerHighlightListener(msg.getId());

        setChatTimeStyle();

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

    private void setChatTimeStyle() {
        Drawable chatTimeBubble = TUIConfigMinimalist.getChatTimeBubble();
        if (chatTimeBubble != null) {
            chatTimeText.setBackground(chatTimeBubble);
        }
        int chatTimeFontColor = TUIConfigMinimalist.getChatTimeFontColor();
        if (chatTimeFontColor != TUIConfigMinimalist.UNDEFINED) {
            chatTimeText.setTextColor(chatTimeFontColor);
        }
        int chatTimeFontSize = TUIConfigMinimalist.getChatTimeFontSize();
        if (chatTimeFontSize != TUIConfigMinimalist.UNDEFINED) {
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
        Calendar dayCalendar = Calendar.getInstance();
        dayCalendar.set(Calendar.HOUR_OF_DAY, 0);
        dayCalendar.set(Calendar.MINUTE, 0);
        dayCalendar.set(Calendar.SECOND, 0);
        dayCalendar.set(Calendar.MILLISECOND, 0);
        Calendar weekCalendar = Calendar.getInstance();
        weekCalendar.setFirstDayOfWeek(Calendar.SUNDAY);
        weekCalendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
        weekCalendar.set(Calendar.HOUR_OF_DAY, 0);
        weekCalendar.set(Calendar.MINUTE, 0);
        weekCalendar.set(Calendar.SECOND, 0);
        weekCalendar.set(Calendar.MILLISECOND, 0);
        Calendar yearCalendar = Calendar.getInstance();
        yearCalendar.set(Calendar.DAY_OF_YEAR, 1);
        yearCalendar.set(Calendar.HOUR_OF_DAY, 0);
        yearCalendar.set(Calendar.MINUTE, 0);
        yearCalendar.set(Calendar.SECOND, 0);
        yearCalendar.set(Calendar.MILLISECOND, 0);
        long dayStartTimeInMillis = dayCalendar.getTimeInMillis();
        long weekStartTimeInMillis = weekCalendar.getTimeInMillis();
        long yearStartTimeInMillis = yearCalendar.getTimeInMillis();
        long outTimeMillis = date.getTime();
        if (outTimeMillis < yearStartTimeInMillis) {
            timeText = String.format(Locale.US, "%1$tY/%1$tm/%1$td", date);
        } else if (outTimeMillis < weekStartTimeInMillis) {
            timeText = String.format(Locale.US, "%1$tm/%1$td", date);
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

    protected boolean isShowAvatar(TUIMessageBean messageBean) {
        return false;
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
