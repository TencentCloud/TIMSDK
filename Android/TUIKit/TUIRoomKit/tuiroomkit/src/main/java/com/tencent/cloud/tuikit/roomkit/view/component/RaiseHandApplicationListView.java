package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RaiseHandApplicationListViewModel;

public class RaiseHandApplicationListView extends BaseBottomDialog implements
        View.OnClickListener {
    private Context                           mContext;
    private TextView                          mTextAgreeAll;
    private TextView                          mTextInviteMember;
    private EditText                          mEditSearch;
    private RecyclerView                      mRecyclerApplyList;
    private RaiseHandApplicationListAdapter   mAdapter;
    private RaiseHandApplicationListViewModel mViewModel;

    public RaiseHandApplicationListView(Context context) {
        super(context);
        mContext = context;
        mAdapter = new RaiseHandApplicationListAdapter(mContext);
        mViewModel = new RaiseHandApplicationListViewModel(mContext, this);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_raise_hand_applies;
    }

    @Override
    protected void intiView() {
        mTextAgreeAll = findViewById(R.id.tv_agree_all);
        mTextInviteMember = findViewById(R.id.tv_invite_member_to_stage);
        mRecyclerApplyList = findViewById(R.id.rv_apply_list);

        mEditSearch = findViewById(R.id.et_search);

        findViewById(R.id.toolbar).setOnClickListener(this);
        mTextInviteMember.setOnClickListener(this);
        mTextAgreeAll.setOnClickListener(this);

        mEditSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                String userName = mEditSearch.getText().toString();
                if (TextUtils.isEmpty(userName)) {
                    mAdapter.setDataList(mViewModel.getApplyList());
                }
                mAdapter.notifyDataSetChanged();
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

        mRecyclerApplyList.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));

        mRecyclerApplyList.setAdapter(mAdapter);
        mRecyclerApplyList.setHasFixedSize(true);

    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        updateHeightToMatchParent();
    }

    public void addItem(UserModel userModel) {
        if (mAdapter != null) {
            mAdapter.addItem(userModel);
        }
    }

    public void removeItem(UserModel userModel) {
        if (mAdapter != null) {
            mAdapter.removeItem(userModel);
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.toolbar) {
            dismiss();
        } else if (v.getId() == R.id.tv_agree_all) {
            mViewModel.agreeAllUserOnStage();
        } else if (v.getId() == R.id.tv_invite_member_to_stage) {
            dismiss();
            mViewModel.inviteMemberOnstage();
        }
    }

    public void destroy() {
        if (mViewModel != null) {
            mViewModel.destroy();
        }
    }
}

