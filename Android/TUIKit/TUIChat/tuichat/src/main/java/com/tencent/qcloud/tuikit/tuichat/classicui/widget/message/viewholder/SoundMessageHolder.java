package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.graphics.drawable.AnimationDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;

public class SoundMessageHolder extends MessageContentHolder {
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
        if (message.isSelf()) {
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            audioPlayImage.setRotation(180f);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage, 0);
            if (!message.hasPlayed()) {
                LinearLayout.LayoutParams unreadParams = (LinearLayout.LayoutParams) isReadText.getLayoutParams();
                unreadParams.gravity = Gravity.CENTER_VERTICAL;
                unreadParams.leftMargin = 10;
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
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(view, position, message);
                }
            }
        });

        if (message.isPlaying()) {
            audioPlayImage.setImageResource(R.drawable.play_voice_message);
            if (message.isSelf()) {
                audioPlayImage.setRotation(180f);
            }
            animationDrawable = (AnimationDrawable) audioPlayImage.getDrawable();
            animationDrawable.start();
            unreadAudioText.setVisibility(View.GONE);
        } else {
            if (animationDrawable != null) {
                animationDrawable.stop();
            }
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            if (message.isSelf()) {
                audioPlayImage.setRotation(180f);
            }
        }
    }
}
