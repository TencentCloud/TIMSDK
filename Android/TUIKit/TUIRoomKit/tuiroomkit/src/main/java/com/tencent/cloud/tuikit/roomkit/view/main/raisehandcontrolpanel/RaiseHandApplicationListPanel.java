package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_APPLY_LIST;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

public class RaiseHandApplicationListPanel extends BaseBottomDialog implements View.OnClickListener {
    private static final float PORTRAIT_HEIGHT_OF_SCREEN = 0.9f;

    private Context                           mContext;
    private TextView                          mTextAgreeAll;
    private TextView                          mTextRejectAll;
    private ConstraintLayout                  mClNoApplications;
    private RecyclerView                      mRecyclerApplyList;
    private RaiseHandApplicationListAdapter   mAdapter;
    private RaiseHandApplicationListViewModel mViewModel;

    private RaiseHandApplicationPanelStateHolder       mStateHolder   = new RaiseHandApplicationPanelStateHolder();
    private Observer<RaiseHandApplicationPanelUiState> mPanelObserver = this::updatePanel;

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            updateRequestUserName(item);
        }
    };

    public RaiseHandApplicationListPanel(Context context) {
        super(context);
        mContext = context;
        mViewModel = new RaiseHandApplicationListViewModel(context, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_APPLY_LIST, null);
        mViewModel.destroy();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_raise_hand_applies;
    }

    @Override
    protected void initView() {
        mTextRejectAll = findViewById(R.id.tuiroomkit_tv_reject_all);
        mTextRejectAll.setOnClickListener(this::onClick);
        mTextAgreeAll = findViewById(R.id.tuiroomkit_tv_agree_all);
        mTextAgreeAll.setOnClickListener(this::onClick);
        mClNoApplications = findViewById(R.id.tuiroomkit_cl_no_seat_requests);

        mRecyclerApplyList = findViewById(R.id.tuiroomkit_rv_seat_apply_list);
        mRecyclerApplyList.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        mAdapter = new RaiseHandApplicationListAdapter(mContext);
        mAdapter.setDataList(mViewModel.getApplyList());
        mRecyclerApplyList.setAdapter(mAdapter);
        mRecyclerApplyList.setHasFixedSize(true);

        View view = findViewById(R.id.tuiroomkit_cl_raise_hand_panel);
        setPortraitHeightPercentOfScreen(view, PORTRAIT_HEIGHT_OF_SCREEN);
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observe(mPanelObserver);
        ConferenceController.sharedInstance().getUserState().allUsers.observe(mAllUserObserver);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mPanelObserver);
        ConferenceController.sharedInstance().getUserState().allUsers.removeObserver(mAllUserObserver);
    }

    public void notifyItemInserted(int position) {
        mAdapter.notifyItemInserted(position);
    }

    public void notifyItemRemoved(int position) {
        mAdapter.notifyItemRemoved(position);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.tuiroomkit_tv_reject_all) {
            mViewModel.rejectAllUserOnStage();
        } else if (v.getId() == R.id.tuiroomkit_tv_agree_all) {
            mViewModel.agreeAllUserOnStage();
        }
    }

    private void updatePanel(RaiseHandApplicationPanelUiState uiState) {
        mClNoApplications.setVisibility(uiState.isApplicationEmpty ? View.VISIBLE : View.INVISIBLE);
        mTextRejectAll.setEnabled(!uiState.isApplicationEmpty);
        mTextAgreeAll.setEnabled(!uiState.isApplicationEmpty);
        mTextAgreeAll.setAlpha(uiState.isApplicationEmpty ? 0.5f : 1.0f);
    }

    private void updateRequestUserName(UserState.UserInfo userInfo) {
        if (mAdapter == null) {
            return;
        }
        mAdapter.updateRequestUserNameCard(userInfo.userId, userInfo.userName);
    }
}

