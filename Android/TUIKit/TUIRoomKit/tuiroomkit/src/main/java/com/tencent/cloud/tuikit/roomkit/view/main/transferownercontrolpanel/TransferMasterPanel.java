package com.tencent.cloud.tuikit.roomkit.view.main.transferownercontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_OWNER_EXIT_ROOM_PANEL;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.trtc.tuikit.common.livedata.LiveListObserver;

public class TransferMasterPanel extends BaseBottomDialog implements View.OnClickListener {
    private static final float PORTRAIT_HEIGHT_OF_SCREEN = 0.9f;

    private Context                 mContext;
    private Button                  mButtonConfirmLeave;
    private Toolbar                 mToolBar;
    private EditText                mEditSearch;
    private RecyclerView            mRecyclerUserList;
    private TransferOwnerAdapter    mAdapter;
    private TransferMasterViewModel mViewModel;

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            if (mAdapter != null) {
                mAdapter.notifyDataSetChanged();
            }
        }
    };

    public TransferMasterPanel(Context context) {
        super(context);
        mContext = context;
        mViewModel = new TransferMasterViewModel(this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_OWNER_EXIT_ROOM_PANEL, null);
        mViewModel.destroy();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_assign_master;
    }

    @Override
    protected void initView() {
        mToolBar = findViewById(R.id.toolbar);
        mEditSearch = findViewById(R.id.et_search);
        mButtonConfirmLeave = findViewById(R.id.btn_specify_and_leave);
        mRecyclerUserList = findViewById(R.id.rv_user_list);

        mRecyclerUserList.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        mAdapter = new TransferOwnerAdapter(mContext);
        mAdapter.setDataList(ConferenceController.sharedInstance().getConferenceState().allUserList);
        mRecyclerUserList.setAdapter(mAdapter);
        mRecyclerUserList.setHasFixedSize(true);

        mToolBar.setOnClickListener(this);
        mButtonConfirmLeave.setOnClickListener(this);
        mEditSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String userName = mEditSearch.getText().toString();
                if (TextUtils.isEmpty(userName)) {
                    mAdapter.setDataList(ConferenceController.sharedInstance().getConferenceState().allUserList);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        mEditSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    String userName = mEditSearch.getText().toString();
                    mAdapter.setDataList(mViewModel.searchUserByKeyWords(userName));
                }
                return false;
            }
        });
        View view = findViewById(R.id.tuiroomkit_cl_transfer_master);
        setPortraitHeightPercentOfScreen(view, PORTRAIT_HEIGHT_OF_SCREEN);
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getUserState().allUsers.observe(mAllUserObserver);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getUserState().allUsers.removeObserver(mAllUserObserver);
    }

    public void onNotifyUserEnter(int position) {
        mAdapter.notifyItemInserted(position);
    }

    public void onNotifyUserExit(int position) {
        mAdapter.notifyItemRemoved(position);
    }

    public void onNotifyUserStateChanged(int position) {
        mAdapter.notifyItemChanged(position);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.toolbar) {
            dismiss();
        } else if (view.getId() == R.id.btn_specify_and_leave) {
            mViewModel.transferMasterAndExit(mAdapter.getSelectedUserId());
            dismiss();
        }
    }
}
