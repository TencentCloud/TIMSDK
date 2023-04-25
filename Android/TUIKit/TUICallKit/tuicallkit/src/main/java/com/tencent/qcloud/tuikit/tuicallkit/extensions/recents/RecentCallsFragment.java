package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.tabs.TabLayout;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces.ICallRecordItemListener;
import com.tencent.qcloud.tuikit.tuicallkit.view.common.SlideRecyclerView;

import java.util.ArrayList;
import java.util.List;

public class RecentCallsFragment extends Fragment {
    public static final String TYPE_ALL  = "AllCall";
    public static final String TYPE_MISS = "MissedCall";

    private View              mRootView;
    private Button            mButtonEdit;
    private Button            mButtonStartCall;
    private Button            mButtonEditDone;
    private Button            mButtonClear;
    private TabLayout         mLayoutTab;
    private SlideRecyclerView mRecyclerRecent;
    private BottomSheetDialog mBottomSheetDialog;
    private ConstraintLayout  mLayoutTitle;

    private String                 mType          = RecentCallsFragment.TYPE_ALL;
    private RecentCallsViewModel   mViewModel;
    private RecentCallsListAdapter mListAdapter;
    private String                 mChatViewStyle = RecentCalls.UI_STYLE_MINIMALIST;

    public RecentCallsFragment() {
    }

    public RecentCallsFragment(String style) {
        mChatViewStyle = style;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.tuicallkit_record_fragment_main, container, false);
        initView();
        initData();
        initListener();
        return mRootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mViewModel != null) {
            mViewModel.queryRecentCalls(getFilter());
        }
    }

    private void initView() {
        mButtonEdit = mRootView.findViewById(R.id.btn_call_edit);
        mButtonStartCall = mRootView.findViewById(R.id.btn_start_call);
        mButtonEditDone = mRootView.findViewById(R.id.btn_edit_done);
        mButtonClear = mRootView.findViewById(R.id.btn_clear);
        mLayoutTab = mRootView.findViewById(R.id.tab_layout);
        mRecyclerRecent = mRootView.findViewById(R.id.recycle_view_list);
        mLayoutTitle = mRootView.findViewById(R.id.cl_record_title);
        if (TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE_MINIMALIST.equals(mChatViewStyle)) {
            mLayoutTitle.setBackgroundColor(getResources().getColor(R.color.tuicalling_color_white));
        }
    }

    private void initData() {
        mListAdapter = new RecentCallsListAdapter();
        mListAdapter.setHasStableIds(true);
        mRecyclerRecent.setLayoutManager(new LinearLayoutManager(getContext()));
        mRecyclerRecent.setAdapter(mListAdapter);
        setAdapterListener();

        mViewModel = new ViewModelProvider(requireActivity()).get(RecentCallsViewModel.class);

        mViewModel.getCallHistoryList().observe(requireActivity(), recordList -> {
            if (mListAdapter != null && TYPE_ALL.equals(mType)) {
                mListAdapter.onDataSourceChanged(recordList);
            }
        });
        mViewModel.getCallMissedList().observe(requireActivity(), recordList -> {
            if (mListAdapter != null && TYPE_MISS.equals(mType)) {
                mListAdapter.onDataSourceChanged(recordList);
            }
        });

        if (mViewModel != null) {
            mViewModel.queryRecentCalls(getFilter());
        }
    }

    private TUICallDefine.RecentCallsFilter getFilter() {
        TUICallDefine.RecentCallsFilter filter = new TUICallDefine.RecentCallsFilter();
        if (RecentCallsFragment.TYPE_MISS.equals(mType)) {
            filter.result = TUICallDefine.CallRecords.Result.Missed;
        }
        return filter;
    }

    private void initListener() {
        mButtonEdit.setOnClickListener(v -> {
            startMultiSelect();
            updateTabViews(true);
        });
        mButtonStartCall.setOnClickListener(v -> {
            TUICore.startActivity("StartC2CChatMinimalistActivity", null);
        });

        mButtonEditDone.setOnClickListener(v -> {
            stopMultiSelect();
            updateTabViews(false);
        });
        mButtonClear.setOnClickListener(v -> {
            showDeleteHistoryDialog();
        });
        mLayoutTab.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                mType = (tab.getPosition() == 1) ? TYPE_MISS : TYPE_ALL;
                updateTabViews(false);
                stopMultiSelect();
                refreshData();
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {
            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {
            }
        });
    }

    private void refreshData() {
        if (mViewModel != null) {
            mViewModel.queryRecentCalls(getFilter());
        }
    }

    private void updateTabViews(boolean isEditable) {
        if (isEditable) {
            mButtonEdit.setVisibility(View.GONE);
            mButtonStartCall.setVisibility(View.GONE);
            mButtonEditDone.setVisibility(View.VISIBLE);
            mButtonClear.setVisibility(View.VISIBLE);
        } else {
            mButtonEdit.setVisibility(View.VISIBLE);
            mButtonStartCall.setVisibility(View.GONE);
            mButtonEditDone.setVisibility(View.GONE);
            mButtonClear.setVisibility(View.GONE);
        }
    }

    private void setAdapterListener() {
        mListAdapter.setOnCallRecordItemListener(new ICallRecordItemListener() {
            @Override
            public void onItemClick(View view, int viewType, TUICallDefine.CallRecords callRecords) {
                if (callRecords == null) {
                    return;
                }
                if (mListAdapter.isMultiSelectMode()) {
                    return;
                }
                if (callRecords.scene.equals(TUICallDefine.Scene.GROUP_CALL)) {
                    startGroupInfoActivity(callRecords);
                    Toast.makeText(getContext(), R.string.tuicallkit_group_recall_unsupport, Toast.LENGTH_SHORT).show();
                    return;
                }
                if (TUICallDefine.Role.Caller.equals(callRecords.role)) {
                    TUICallKit.createInstance(getContext()).call(callRecords.inviteList.get(0), callRecords.mediaType);
                } else {
                    TUICallKit.createInstance(getContext()).call(callRecords.inviter, callRecords.mediaType);
                }
            }

            @Override
            public void onItemDeleteClick(View view, int viewType, TUICallDefine.CallRecords callRecords) {
                if (callRecords == null) {
                    return;
                }
                List<TUICallDefine.CallRecords> list = new ArrayList<>();
                list.add(callRecords);
                deleteRecordCalls(list);
            }

            @Override
            public void onDetailViewClick(View view, TUICallDefine.CallRecords records) {
                if (records == null) {
                    return;
                }
                if (TUICallDefine.Scene.SINGLE_CALL.equals(records.scene)) {
                    startFriendProfileActivity(records);
                } else if (TUICallDefine.Scene.GROUP_CALL.equals(records.scene)) {
                    startGroupInfoActivity(records);
                }
            }
        });
    }

    private void startFriendProfileActivity(TUICallDefine.CallRecords records) {
        Bundle bundle = new Bundle();
        if (TUICallDefine.Role.Caller.equals(records.role)) {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, records.inviteList.get(0));
        } else {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, records.inviter);
        }
        String activityName = "FriendProfileActivity";
        if (TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE_MINIMALIST.equals(mChatViewStyle)) {
            activityName = "FriendProfileMinimalistActivity";
        }
        TUICore.startActivity(activityName, bundle);
    }

    private void startGroupInfoActivity(TUICallDefine.CallRecords records) {
        Bundle bundle = new Bundle();
        bundle.putString("group_id", records.groupId);
        String activityName = "GroupInfoActivity";
        if (TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE_MINIMALIST.equals(mChatViewStyle)) {
            activityName = "GroupInfoMinimalistActivity";
        }
        TUICore.startActivity(getContext(), activityName, bundle);
    }

    private void startMultiSelect() {
        RecentCallsListAdapter adapter = (RecentCallsListAdapter) mRecyclerRecent.getAdapter();
        if (adapter != null) {
            adapter.setShowMultiSelectCheckBox(true);
            adapter.notifyDataSetChanged();
        }
        mRecyclerRecent.disableRecyclerViewSlide(true);
        mRecyclerRecent.closeMenu();
    }

    private void stopMultiSelect() {
        RecentCallsListAdapter adapter = (RecentCallsListAdapter) mRecyclerRecent.getAdapter();
        if (adapter != null) {
            adapter.setShowMultiSelectCheckBox(false);
            adapter.notifyDataSetChanged();
        }
        mRecyclerRecent.disableRecyclerViewSlide(false);
        mRecyclerRecent.closeMenu();
    }

    private void deleteRecordCalls(List<TUICallDefine.CallRecords> selectItem) {
        if (mViewModel != null) {
            mViewModel.deleteRecordCalls(selectItem);
        }
        stopMultiSelect();
    }

    private void clearRecentCalls() {
        List<TUICallDefine.CallRecords> selectedItems = new ArrayList<>();
        if (mListAdapter != null) {
            selectedItems = mListAdapter.getSelectedItem();
        }
        if (selectedItems == null) {
            return;
        }
        List<TUICallDefine.CallRecords> recordList = new ArrayList<>();
        for (TUICallDefine.CallRecords records : selectedItems) {
            if (records != null && !TextUtils.isEmpty(records.callId)) {
                recordList.add(records);
            }
        }
        if (mViewModel != null) {
            mViewModel.deleteRecordCalls(recordList);
        }
    }

    private void showDeleteHistoryDialog() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(getContext(), R.style.TUICallBottomSelectSheet);
        }
        mBottomSheetDialog.setContentView(R.layout.tuicallkit_record_dialog);
        mBottomSheetDialog.setCanceledOnTouchOutside(false);
        TextView textPositive = mBottomSheetDialog.findViewById(R.id.tv_clear_call_history);
        TextView textCancel = mBottomSheetDialog.findViewById(R.id.tv_clear_cancel);
        textPositive.setOnClickListener(v -> {
            clearRecentCalls();
            mBottomSheetDialog.dismiss();
            stopMultiSelect();
        });
        textCancel.setOnClickListener(v -> {
            mBottomSheetDialog.dismiss();
        });
        mBottomSheetDialog.show();
    }
}
