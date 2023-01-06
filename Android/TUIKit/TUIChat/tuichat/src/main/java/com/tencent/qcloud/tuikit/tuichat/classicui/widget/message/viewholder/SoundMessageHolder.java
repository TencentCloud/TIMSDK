package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.graphics.drawable.AnimationDrawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.File;

public class SoundMessageHolder extends MessageContentHolder {

    private static final int UNREAD = 0;
    private static final int READ = 1;

    private TextView audioTimeText;
    private ImageView audioPlayImage;
    private LinearLayout audioContentView;

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
            if (message.getCustomInt() == UNREAD) {
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
                if (AudioPlayer.getInstance().isPlaying()) {
                    AudioPlayer.getInstance().stopPlay();
                    if (TextUtils.equals(AudioPlayer.getInstance().getPath(), message.getDataPath())) {
                        return;
                    }
                }
                if (TextUtils.isEmpty(message.getDataPath())) {
                    ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.voice_play_tip));
                    getSound(message);
                    return;
                }
                audioPlayImage.setImageResource(R.drawable.play_voice_message);
                if (message.isSelf()) {
                    audioPlayImage.setRotation(180f);
                }
                final AnimationDrawable animationDrawable = (AnimationDrawable) audioPlayImage.getDrawable();
                animationDrawable.start();
                message.setCustomInt(READ);
                unreadAudioText.setVisibility(View.GONE);
                AudioPlayer.getInstance().startPlay(message.getDataPath(), new AudioPlayer.Callback() {
                    @Override
                    public void onCompletion(Boolean success) {
                        audioPlayImage.post(new Runnable() {
                            @Override
                            public void run() {
                                animationDrawable.stop();
                                audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
                                if (message.isSelf()) {
                                    audioPlayImage.setRotation(180f);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    private void getSound(final SoundMessageBean messageBean) {
        final String path = TUIConfig.getRecordDownloadDir() + messageBean.getUUID();
        File file = new File(path);
        if (!file.exists()) {
            messageBean.downloadSound(path, new SoundMessageBean.SoundDownloadCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.i("downloadSound progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e("getSoundToFile failed code = ", code + ", info = " + desc);
                    ToastUtil.toastLongMessage("getSoundToFile failed code = " + code + ", info = " + desc);
                }

                @Override
                public void onSuccess() {
                    messageBean.setDataPath(path);
                }
            });
        } else {
            messageBean.setDataPath(path);
        }
    }

}
