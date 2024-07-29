package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.res.ResourcesCompat;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

public class SoundMessageHolder extends MessageContentHolder {
    private static final int SOUND_VIEW_MAX_WIDTH = 220;

    private TextView audioTimeText;
    private ImageView audioPlayImage;
    private LinearLayout audioContentView;
    private AnimationDrawable animationDrawable;

    public SoundMessageHolder(View itemView) {
        super(itemView);
        audioTimeText = itemView.findViewById(R.id.audio_time_tv);
        audioPlayImage = itemView.findViewById(R.id.audio_play_iv);
        audioContentView = itemView.findViewById(R.id.audio_content_ll);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_audio;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        SoundMessageBean message = (SoundMessageBean) msg;
        if (hasRiskContent) {
            setRiskContent(itemView.getResources().getString(R.string.chat_risk_sound_message_alert));
        }
        if (message.isSelf()) {
            Drawable playingDrawable = ResourcesCompat.getDrawable(itemView.getResources(), R.drawable.chat_voice_msg_playing_3, null);
            playingDrawable.setAutoMirrored(true);
            audioPlayImage.setImageDrawable(playingDrawable);
            audioPlayImage.setRotation(180f);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            Drawable playingDrawable = ResourcesCompat.getDrawable(itemView.getResources(), R.drawable.chat_voice_msg_playing_3, null);
            playingDrawable.setAutoMirrored(true);
            audioPlayImage.setImageDrawable(playingDrawable);
            audioPlayImage.setRotation(0f);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage, 0);
            if (!message.hasPlayed()) {
                LinearLayout.LayoutParams unreadParams = (LinearLayout.LayoutParams) isReadText.getLayoutParams();
                unreadParams.gravity = Gravity.CENTER_VERTICAL;
                unreadParams.setMarginStart(10);
                unreadAudioText.setVisibility(View.VISIBLE);
                unreadAudioText.setLayoutParams(unreadParams);
            } else {
                unreadAudioText.setVisibility(View.GONE);
            }
        }

        int duration = (int) message.getDuration();
        if (duration == 0) {
            duration = 1;
        }

        if (isReplyDetailMode || isForwardMode || !msg.isSelf()) {
            int otherTextColorResId = TUIThemeManager.getAttrResId(audioTimeText.getContext(), R.attr.chat_other_msg_text_color);
            int otherTextColor = audioTimeText.getResources().getColor(otherTextColorResId);
            audioTimeText.setTextColor(otherTextColor);
        } else {
            int selfTextColorResId = TUIThemeManager.getAttrResId(audioTimeText.getContext(), R.attr.chat_self_msg_text_color);
            int selfTextColor = audioTimeText.getResources().getColor(selfTextColorResId);
            audioTimeText.setTextColor(selfTextColor);
        }

        audioTimeText.setText(duration + "''");
        if (!hasRiskContent) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(view, message);
                    }
                }
            });
        } else {
            unreadAudioText.setVisibility(View.GONE);
            msgContentFrame.setOnClickListener(null);
        }

        if (message.isPlaying()) {
            audioPlayImage.setImageResource(R.drawable.play_voice_message);
            if (message.isSelf()) {
                audioPlayImage.setRotation(180f);
            }
            animationDrawable = (AnimationDrawable) audioPlayImage.getDrawable();
            animationDrawable.setAutoMirrored(true);
            animationDrawable.start();
            unreadAudioText.setVisibility(View.GONE);
        } else {
            if (animationDrawable != null) {
                animationDrawable.stop();
            }
            Drawable playingDrawable = ResourcesCompat.getDrawable(itemView.getResources(), R.drawable.chat_voice_msg_playing_3, null);
            playingDrawable.setAutoMirrored(true);
            audioPlayImage.setImageDrawable(playingDrawable);
            if (message.isSelf()) {
                audioPlayImage.setRotation(180f);
            }
        }
        setSoundViewWidth(duration);
    }

    @Override
    protected void setGravity(boolean isStart) {
        int gravity = isStart ? Gravity.START : Gravity.END;
        super.setGravity(isStart);
        ViewGroup.LayoutParams layoutParams = audioContentView.getLayoutParams();
        if (layoutParams instanceof FrameLayout.LayoutParams) {
            ((FrameLayout.LayoutParams) layoutParams).gravity = gravity;
        } else if (layoutParams instanceof LinearLayout.LayoutParams) {
            ((LinearLayout.LayoutParams) layoutParams).gravity = gravity;
        }
        audioContentView.setLayoutParams(layoutParams);
    }

    private void setSoundViewWidth(int duration) {
        if (msgContentFrame == null) {
            return;
        }

        ViewGroup.LayoutParams params = msgContentFrame.getLayoutParams();
        if (params != null) {
            params.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            msgContentFrame.setLayoutParams(params);
            msgContentFrame.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            int minWidth = msgContentFrame.getMeasuredWidth();
            int maxWidth = ScreenUtil.dip2px(SOUND_VIEW_MAX_WIDTH);
            int audioMaxTime = TUIChatConfigs.getGeneralConfig().getAudioRecordMaxTime();
            params.width = minWidth + ((maxWidth - minWidth) / audioMaxTime) * duration;
            msgContentFrame.setLayoutParams(params);
        }
    }
}
