package com.tencent.cloud.tuikit.roomkit.view.main.speechtotext;

import android.content.Context;
import android.content.res.Configuration;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.state.ASRState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class SpeechToTextRecyclerView extends RecyclerView {
    private final SpeechToTextViewAdapter mTextAdapter = new SpeechToTextViewAdapter(getContext());
    private final LinearLayoutManager     mLayoutManager;

    private final LiveListObserver<ASRState.SpeechToText> mTextObserver = new LiveListObserver<ASRState.SpeechToText>() {
        @Override
        public void onDataChanged(List<ASRState.SpeechToText> list) {
            mTextAdapter.setDataList(list);
            scrollToPosition(list.size() - 1);
        }

        @Override
        public void onItemChanged(int position, ASRState.SpeechToText item) {
            mTextAdapter.notifyItemChanged(position);
        }

        @Override
        public void onItemInserted(int position, ASRState.SpeechToText item) {
            mTextAdapter.notifyItemInserted(position);
            scrollToLatestIfNeeded();
        }
    };

    public SpeechToTextRecyclerView(@NonNull Context context) {
        this(context, null);
    }

    public SpeechToTextRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setAdapter(mTextAdapter);
        mLayoutManager = new LinearLayoutManager(context);
        setLayoutManager(mLayoutManager);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getASRState().speechToTexts.observe(mTextObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getASRState().speechToTexts.removeObserver(mTextObserver);
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        scrollToLatestIfNeeded();
    }

    private void scrollToLatestIfNeeded() {
        int lastVisibleItemPosition = mLayoutManager.findLastVisibleItemPosition();
        int lastItemPosition = mTextAdapter.getItemCount() - 1;
        if (lastVisibleItemPosition >= lastItemPosition - 1) {
            scrollToPosition(lastItemPosition);
        }
    }
}
