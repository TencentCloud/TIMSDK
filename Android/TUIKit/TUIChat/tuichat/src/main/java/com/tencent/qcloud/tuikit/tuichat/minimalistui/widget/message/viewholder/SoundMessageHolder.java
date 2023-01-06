package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.File;
import java.util.Timer;
import java.util.TimerTask;

public class SoundMessageHolder extends MessageContentHolder {

    private static final int UNREAD = 0;
    private static final int READ = 1;

    private TextView audioTimeText;
    private ImageView audioPlayImage;
    private Timer mTimer;
    private int times = 0;

    public SoundMessageHolder(View itemView) {
        super(itemView);
        audioTimeText = itemView.findViewById(R.id.audio_time_tv);
        audioPlayImage = itemView.findViewById(R.id.audio_play_iv);
        timeInLineTextLayout = itemView.findViewById(R.id.time_in_line_text);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_message_adapter_content_audio;
    }


    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        SoundMessageBean message = (SoundMessageBean) msg;

        int duration = (int) message.getDuration();
        if (duration == 0) {
            duration = 1;
        }

        String timeString = DateTimeUtil.formatSecondsTo00(duration);
        int finalDuration = duration;
        resetTimerStatus(timeString);
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (AudioPlayer.getInstance().isPlaying()) {
                    AudioPlayer.getInstance().stopPlay();
                    resetTimerStatus(timeString);
                    if (TextUtils.equals(AudioPlayer.getInstance().getPath(), message.getDataPath())) {
                        return;
                    }
                }
                if (TextUtils.isEmpty(message.getDataPath())) {
                    ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.voice_play_tip));
                    getSound(message);
                    return;
                }

                if (finalDuration > 1) {
                    if (mTimer == null) {
                        mTimer = new Timer();
                    }
                    mTimer.schedule(new TimerTask() {
                        @Override
                        public void run() {
                            BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (times < finalDuration) {
                                        times++;
                                        String s = DateTimeUtil.formatSecondsTo00(times);
                                        audioTimeText.setText(s);
                                    } else {
                                        audioTimeText.setText(timeString);
                                    }
                                }
                            });
                        }
                    }, 0, 1000);
                }

                audioPlayImage.setImageResource(R.drawable.chat_audio_stop_btn_ic);
                message.setCustomInt(READ);
                AudioPlayer.getInstance().startPlay(message.getDataPath(), new AudioPlayer.Callback() {
                    @Override
                    public void onCompletion(Boolean success) {
                        audioPlayImage.post(new Runnable() {
                            @Override
                            public void run() {
                                audioPlayImage.setImageResource(R.drawable.chat_audio_play_btn_ic);
                            }
                        });
                        resetTimerStatus(timeString);
                    }
                });
            }
        });
    }

    private void resetTimerStatus(String timeString) {
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
        audioTimeText.setText(timeString);
        times = 0;
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
