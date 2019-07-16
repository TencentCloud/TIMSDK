package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.graphics.drawable.AnimationDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMSoundElem;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.AudioPlayer;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.io.File;

public class MessageAudioHolder extends MessageContentHolder {

    private static final int AUDIO_MIN_WIDTH = ScreenUtil.getPxByDp(60);
    private static final int AUDIO_MAX_WIDTH = ScreenUtil.getPxByDp(250);

    private TextView audioTimeText;
    private ImageView audioPlayImage;
    private LinearLayout audioContentView;

    public MessageAudioHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_audio;
    }

    @Override
    public void initVariableViews() {
        audioTimeText = rootView.findViewById(R.id.audio_time_tv);
        audioPlayImage = rootView.findViewById(R.id.audio_play_iv);
        audioContentView = rootView.findViewById(R.id.audio_content_ll);
    }

    @Override
    public void layoutVariableViews(final MessageInfo msg, final int position) {
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.CENTER_VERTICAL);
        if (msg.isSelf()) {
            params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            params.rightMargin = 25;
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
        } else {
            params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
            params.leftMargin = 25;
            // TODO 图标不对
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage, 0);
        }
        audioContentView.setLayoutParams(params);

        final TIMSoundElem soundElem = (TIMSoundElem) msg.getTIMMessage().getElement(0);
        int duration = (int) soundElem.getDuration();
        if (duration == 0) {
            duration = 1;
        }
        if (TextUtils.isEmpty(msg.getDataPath())) {
            getSound(msg, soundElem);
        }
        ViewGroup.LayoutParams audioParams = msgContentFrame.getLayoutParams();
        audioParams.width = AUDIO_MIN_WIDTH + ScreenUtil.getPxByDp(duration * 6);
        if (audioParams.width > AUDIO_MAX_WIDTH) {
            audioParams.width = AUDIO_MAX_WIDTH;
        }
        msgContentFrame.setLayoutParams(audioParams);
        audioTimeText.setText(duration + "''");
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (AudioPlayer.getInstance().isPlayingRecord()) {
                    AudioPlayer.getInstance().stopPlayRecord();
                    return;
                }
                if (TextUtils.isEmpty(msg.getDataPath())) {
                    ToastUtil.toastLongMessage("语音文件还未下载完成");
                    return;
                }
                audioPlayImage.setImageResource(R.drawable.play_voice_message);
                final AnimationDrawable animationDrawable = (AnimationDrawable) audioPlayImage.getDrawable();
                animationDrawable.start();
                AudioPlayer.getInstance().playRecord(msg.getDataPath(), new AudioPlayer.AudioPlayCallback() {
                    @Override
                    public void playComplete() {
                        audioPlayImage.post(new Runnable() {
                            @Override
                            public void run() {
                                animationDrawable.stop();
                                audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
                            }
                        });
                    }
                });
            }
        });
    }

    private void getSound(final MessageInfo msgInfo, TIMSoundElem soundElemEle) {
        final String path = TUIKitConstants.RECORD_DOWNLOAD_DIR + soundElemEle.getUuid();
        File file = new File(path);
        if (!file.exists()) {
            soundElemEle.getSoundToFile(path, new TIMCallBack() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e("getSoundToFile failed code = ", code + ", info = " + desc);
                }

                @Override
                public void onSuccess() {
                    msgInfo.setDataPath(path);
                }
            });
        } else {
            msgInfo.setDataPath(path);
        }
    }

}
