package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.CompoundButton;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupManagerPresenter;
import java.util.ArrayList;
import java.util.List;

public class ManageGroupActivity extends BaseLightActivity {
    private TitleBarLayout titleBarLayout;
    private LineControllerView setManagerView;
    private LineControllerView muteAllView;
    private View addMuteMemberView;
    private RecyclerView mutedList;
    private MutedMemberAdapter mutedMemberAdapter;

    private GroupManagerPresenter presenter;
    private GroupInfo groupInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_manager);
        presenter = new GroupManagerPresenter();
        titleBarLayout = findViewById(R.id.group_manage_title_bar);
        setManagerView = findViewById(R.id.group_manage_set_manager);
        muteAllView = findViewById(R.id.group_manage_mute_all);
        addMuteMemberView = findViewById(R.id.group_manage_add_mute_member);
        mutedList = findViewById(R.id.group_manage_muted_member_list);
        mutedList.setLayoutManager(new CustomLinearLayoutManager(this));
        mutedMemberAdapter = new MutedMemberAdapter();
        mutedList.setAdapter(mutedMemberAdapter);

        groupInfo = (GroupInfo) getIntent().getSerializableExtra(TUIGroupConstants.Group.GROUP_INFO);

        muteAllView.setChecked(groupInfo.isAllMuted());
        if (groupInfo.isAllMuted()) {
            addMuteMemberView.setVisibility(View.GONE);
            mutedList.setVisibility(View.GONE);
        }

        titleBarLayout.setTitle(getString(R.string.group_manager), ITitleBarLayout.Position.MIDDLE);
        setClickListener();
        loadMutedMember();
    }

    private void setClickListener() {
        titleBarLayout.getLeftIcon().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        muteAllView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                presenter.muteAll(groupInfo.getId(), isChecked, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        if (isChecked) {
                            addMuteMemberView.setVisibility(View.GONE);
                            mutedList.setVisibility(View.GONE);
                        } else {
                            addMuteMemberView.setVisibility(View.VISIBLE);
                            mutedList.setVisibility(View.VISIBLE);
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(errCode + ", " + errMsg);
                    }
                });
            }
        });

        setManagerView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (TextUtils.equals(groupInfo.getGroupType(), GroupInfo.GROUP_TYPE_AVCHATROOM)
                    || TextUtils.equals(groupInfo.getGroupType(), GroupInfo.GROUP_TYPE_WORK)) {
                    ToastUtil.toastShortMessage(getString(R.string.group_not_support_set_manager));
                    return;
                }
                Intent intent = new Intent(ManageGroupActivity.this, SetGroupManagerActivity.class);
                intent.putExtra(TUIGroupConstants.Group.GROUP_INFO, groupInfo);
                startActivity(intent);
            }
        });

        addMuteMemberView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (TextUtils.equals(groupInfo.getGroupType(), GroupInfo.GROUP_TYPE_AVCHATROOM)
                    || TextUtils.equals(groupInfo.getGroupType(), GroupInfo.GROUP_TYPE_WORK)) {
                    ToastUtil.toastShortMessage(getString(R.string.group_not_support_mute_member));
                    return;
                }

                Intent intent = new Intent(ManageGroupActivity.this, GroupMemberActivity.class);
                intent.putExtra(TUIConstants.TUIGroup.IS_SELECT_MODE, true);
                intent.putExtra(TUIConstants.TUIGroup.FILTER, GroupInfo.GROUP_MEMBER_FILTER_COMMON);
                if (mutedMemberAdapter.getGroupMemberInfoList() != null) {
                    ArrayList<String> selectedList = new ArrayList<>();
                    for (GroupMemberInfo memberInfo : mutedMemberAdapter.getGroupMemberInfoList()) {
                        selectedList.add(memberInfo.getAccount());
                    }
                    intent.putExtra(TUIConstants.TUIGroup.SELECTED_LIST, selectedList);
                }
                intent.putExtra(TUIConstants.TUIGroup.GROUP_ID, groupInfo.getId());
                startActivityForResult(intent, 1);
            }
        });

        mutedMemberAdapter.setOnItemLongClickListener(new SetGroupManagerActivity.OnItemLongClickListener() {
            @Override
            public void onClick(View view, GroupMemberInfo memberInfo, int position) {
                Drawable drawable = view.getBackground();
                if (drawable != null) {
                    drawable.setColorFilter(0xd9d9d9, PorterDuff.Mode.SRC_IN);
                }
                View itemPop = LayoutInflater.from(ManageGroupActivity.this).inflate(R.layout.group_manager_pop_menu, null);
                PopupWindow popupWindow = new PopupWindow(itemPop, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
                popupWindow.setBackgroundDrawable(new ColorDrawable());
                popupWindow.setOutsideTouchable(true);
                popupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
                    @Override
                    public void onDismiss() {
                        if (drawable != null) {
                            drawable.clearColorFilter();
                        }
                    }
                });
                TextView popText = itemPop.findViewById(R.id.pop_text);
                popText.setText(R.string.group_cancel_mute_label);
                popText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        popupWindow.dismiss();
                        presenter.cancelMuteGroupMember(groupInfo.getId(), memberInfo.getAccount(), new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                mutedMemberAdapter.onItemRemoved(memberInfo);
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastShortMessage(errCode + ", " + errMsg);
                            }
                        });
                    }
                });
                int x = view.getWidth() / 2;
                int y = -view.getHeight() / 3;
                int popHeight = ScreenUtil.dip2px(45) * 3;
                if (y + popHeight + view.getY() + view.getHeight() > mutedList.getBottom()) {
                    y = y - popHeight;
                }
                popupWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
            }
        });
    }

    private void loadMutedMember() {
        presenter.loadMutedMembers(groupInfo.getId(), new IUIKitCallback<List<GroupMemberInfo>>() {
            @Override
            public void onSuccess(List<GroupMemberInfo> data) {
                mutedMemberAdapter.setGroupMemberInfoList(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(errCode + ", " + errMsg);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && data != null) {
            List<String> selectedList = data.getStringArrayListExtra(TUIGroupConstants.Selection.LIST);
            if (selectedList != null && !selectedList.isEmpty()) {
                for (String userId : selectedList) {
                    presenter.muteGroupMember(groupInfo.getId(), userId, new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            loadMutedMember();
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage(errCode + ", " + errMsg);
                        }
                    });
                }
            }
        }
    }

    class MutedMemberAdapter extends RecyclerView.Adapter<MutedMemberAdapter.MutedMemberViewHolder> {
        private List<GroupMemberInfo> groupMemberInfoList;

        private SetGroupManagerActivity.OnItemLongClickListener onItemLongClickListener;

        public void setOnItemLongClickListener(SetGroupManagerActivity.OnItemLongClickListener onItemLongClickListener) {
            this.onItemLongClickListener = onItemLongClickListener;
        }

        public void onItemRemoved(GroupMemberInfo memberInfo) {
            int index = groupMemberInfoList.indexOf(memberInfo);
            groupMemberInfoList.remove(memberInfo);
            notifyItemRemoved(index);
        }

        public void setGroupMemberInfoList(List<GroupMemberInfo> groupMemberInfoList) {
            this.groupMemberInfoList = groupMemberInfoList;
            notifyDataSetChanged();
        }

        public List<GroupMemberInfo> getGroupMemberInfoList() {
            return groupMemberInfoList;
        }

        @NonNull
        @Override
        public MutedMemberViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_manager_item, parent, false);
            return new MutedMemberViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull MutedMemberViewHolder holder, int position) {
            GroupMemberInfo groupMemberInfo = groupMemberInfoList.get(position);
            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemLongClickListener != null) {
                        onItemLongClickListener.onClick(v, groupMemberInfo, position);
                    }
                    return false;
                }
            });
            String displayName = getDisplayName(groupMemberInfo);
            holder.managerName.setText(displayName);
            GlideEngine.loadUserIcon(holder.faceIcon, groupMemberInfo.getIconUrl());
        }

        @Override
        public int getItemCount() {
            if (groupMemberInfoList == null || groupMemberInfoList.isEmpty()) {
                return 0;
            }
            return groupMemberInfoList.size();
        }

        class MutedMemberViewHolder extends RecyclerView.ViewHolder {
            ShadeImageView faceIcon;
            TextView managerName;

            public MutedMemberViewHolder(@NonNull View itemView) {
                super(itemView);
                faceIcon = itemView.findViewById(R.id.group_manager_face);
                managerName = itemView.findViewById(R.id.group_manage_name);
            }
        }
    }

    private String getDisplayName(GroupMemberInfo groupMemberInfo) {
        String displayName = groupMemberInfo.getNameCard();
        if (TextUtils.isEmpty(displayName)) {
            displayName = groupMemberInfo.getNickName();
        }
        if (TextUtils.isEmpty(displayName)) {
            displayName = groupMemberInfo.getAccount();
        }
        return displayName;
    }

    interface OnItemLongClickListener {
        void onClick(View view, GroupMemberInfo groupMemberInfo);
    }
}