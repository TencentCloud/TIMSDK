package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class ScheduledConferenceListView extends FrameLayout {

    private final Context                    mContext;
    private       RecyclerView               mRvScheduledConferences;
    private       ScheduledConferenceAdapter mScheduledConferenceAdapter;

    private final ScheduledConferenceRecyclerStateHolder    mStateHolder = new ScheduledConferenceRecyclerStateHolder();
    private final LiveListObserver<ScheduledConferenceItem> mObserver    = new LiveListObserver<ScheduledConferenceItem>() {
        @Override
        public void onDataChanged(List<ScheduledConferenceItem> list) {
            mScheduledConferenceAdapter.setDataList(list);
            mRvScheduledConferences.setVisibility(mStateHolder.mScheduledConferenceData.isEmpty() ? INVISIBLE : VISIBLE);
        }

        @Override
        public void onItemChanged(int position, ScheduledConferenceItem item) {
            mScheduledConferenceAdapter.notifyItemChanged(position);
        }

        @Override
        public void onItemInserted(int position, ScheduledConferenceItem item) {
            mScheduledConferenceAdapter.notifyItemInserted(position);
            mRvScheduledConferences.setVisibility(mStateHolder.mScheduledConferenceData.isEmpty() ? INVISIBLE : VISIBLE);
        }

        @Override
        public void onItemRemoved(int position, ScheduledConferenceItem item) {
            mScheduledConferenceAdapter.notifyItemRemoved(position);
            mRvScheduledConferences.setVisibility(mStateHolder.mScheduledConferenceData.isEmpty() ? INVISIBLE : VISIBLE);
        }

        @Override
        public void onItemMoved(int fromPosition, int toPosition, ScheduledConferenceItem item) {
            mScheduledConferenceAdapter.notifyItemMoved(fromPosition, toPosition);
        }
    };

    public ScheduledConferenceListView(@NonNull Context context) {
        this(context, null);
    }

    public ScheduledConferenceListView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        initView(context);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observer(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void initView(Context context) {
        View parent = inflate(context, R.layout.tuiroomkit_view_scheduled_conference_list, this);
        mRvScheduledConferences = parent.findViewById(R.id.tuiroomkit_rv_scheduled_conference_list);
        mRvScheduledConferences.addItemDecoration(new ScheduledConferenceDecoration());
        mRvScheduledConferences.setLayoutManager(new LinearLayoutManager(mContext));
        mScheduledConferenceAdapter = new ScheduledConferenceAdapter(mContext);
        mRvScheduledConferences.setAdapter(mScheduledConferenceAdapter);
        mRvScheduledConferences.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);

                if (!recyclerView.canScrollVertically(1) && newState == RecyclerView.SCROLL_STATE_IDLE) {
                    ScheduleController.sharedInstance().fetchRequiredConferences(null);
                }
            }
        });
        setVerticalScrollBarEnabled(false);
    }
}
