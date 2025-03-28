package com.tencent.cloud.tuikit.roomkit.view.main.aisssistant;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.main.speechtotext.SpeechToTextActivity;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Map;

public class AIAssistantDialog extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {

    private       RelativeLayout mLayoutAILiveSubtitle;
    private       RelativeLayout mLayoutAILiveRecord;
    private       TextView       mTvSubtitleName;
    private final Context        mContext;

    private final Observer<Boolean> mSubtitleObserver = this::updateSubtitleView;

    public AIAssistantDialog(@NonNull Context context) {
        super(context);
        mContext = context;
        ConferenceEventCenter.getInstance().subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
        ConferenceController.sharedInstance().getViewState().isSpeechToTextSubTitleShowing.removeObserver(mSubtitleObserver);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_ai_assistant;
    }

    @Override
    protected void initView() {
        mLayoutAILiveSubtitle = findViewById(R.id.tuiroomkit_rl_ai_live_subtitle);
        mLayoutAILiveSubtitle.setOnClickListener(view -> {
            boolean isShowSubtitle = ConferenceController.sharedInstance().getViewState().isSpeechToTextSubTitleShowing.get();
            ConferenceController.sharedInstance().getViewState().isSpeechToTextSubTitleShowing.set(!isShowSubtitle);
            dismiss();
        });

        mLayoutAILiveRecord = findViewById(R.id.tuiroomkit_rl_ai_live_recording);
        mLayoutAILiveRecord.setOnClickListener(view -> {
            Intent intent = new Intent(mContext, SpeechToTextActivity.class);
            mContext.startActivity(intent);
            dismiss();
        });

        mTvSubtitleName = findViewById(R.id.tuiroomkit_iv_ai_live_subtitle_name);
        ConferenceController.sharedInstance().getViewState().isSpeechToTextSubTitleShowing.observe(mSubtitleObserver);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (TextUtils.equals(key, CONFIGURATION_CHANGE)) {
            if (params == null || !isShowing()) {
                return;
            }
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            changeConfiguration(configuration);
        }
    }

    private void updateSubtitleView(boolean isShowSubtitle) {
        mTvSubtitleName.setText(isShowSubtitle ? R.string.tuiroomkit_ai_close_live_subtitle : R.string.tuiroomkit_ai_open_live_subtitle);
    }
}
