package com.tencent.qcloud.tim.uikit.modules.forward.message;

import android.graphics.drawable.AnimationDrawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.AudioPlayer;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.io.File;

public class ForwardMessageAudioHolder extends ForwardMessageBaseHolder {

    private static final int AUDIO_MIN_WIDTH = ScreenUtil.getPxByDp(60);
    private static final int AUDIO_MAX_WIDTH = ScreenUtil.getPxByDp(250);

    private static final int UNREAD = 0;
    private static final int READ = 1;

    private TextView audioTimeText;
    private ImageView audioPlayImage;
    private LinearLayout audioContentView;

    public ForwardMessageAudioHolder(View itemView) {
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
            params.rightMargin = 24;
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            audioPlayImage.setRotation(180f);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
            params.leftMargin = 24;
            // TODO 图标不对
            audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
            audioContentView.removeView(audioPlayImage);
            audioContentView.addView(audioPlayImage, 0);
            if (msg.getCustomInt() == UNREAD) {
                LinearLayout.LayoutParams unreadParams = (LinearLayout.LayoutParams) isReadText.getLayoutParams();
                unreadParams.gravity = Gravity.CENTER_VERTICAL;
                unreadParams.leftMargin = 10;
                unreadAudioText.setVisibility(View.VISIBLE);
                unreadAudioText.setLayoutParams(unreadParams);
            } else {
                unreadAudioText.setVisibility(View.GONE);
            }
        }
        audioContentView.setLayoutParams(params);

        V2TIMMessage timMessage = msg.getTimMessage();
        if (timMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
            return;
        }
        final V2TIMSoundElem soundElem = timMessage.getSoundElem();
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
                if (AudioPlayer.getInstance().isPlaying()) {
                    AudioPlayer.getInstance().stopPlay();
                    return;
                }
                if (TextUtils.isEmpty(msg.getDataPath())) {
                    ToastUtil.toastLongMessage("语音文件还未下载完成");
                    return;
                }
                audioPlayImage.setImageResource(R.drawable.play_voice_message);
                if (msg.isSelf()) {
                    audioPlayImage.setRotation(180f);
                }
                final AnimationDrawable animationDrawable = (AnimationDrawable) audioPlayImage.getDrawable();
                animationDrawable.start();
                msg.setCustomInt(READ);
                unreadAudioText.setVisibility(View.GONE);
                AudioPlayer.getInstance().startPlay(msg.getDataPath(), new AudioPlayer.Callback() {
                    @Override
                    public void onCompletion(Boolean success) {
                        audioPlayImage.post(new Runnable() {
                            @Override
                            public void run() {
                                animationDrawable.stop();
                                audioPlayImage.setImageResource(R.drawable.voice_msg_playing_3);
                                if (msg.isSelf()) {
                                    audioPlayImage.setRotation(180f);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    private void getSound(final MessageInfo msgInfo, V2TIMSoundElem soundElemEle) {
        final String path = TUIKitConstants.RECORD_DOWNLOAD_DIR + soundElemEle.getUUID();
        File file = new File(path);
        if (!file.exists()) {
            soundElemEle.downloadSound(path, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    TUIKitLog.i("downloadSound progress current:", progressInfo.getCurrentSize() + ", total:" + progressInfo.getTotalSize());
                }

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
