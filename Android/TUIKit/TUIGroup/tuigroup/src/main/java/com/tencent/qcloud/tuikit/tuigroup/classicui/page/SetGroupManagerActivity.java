package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

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
import android.widget.PopupWindow;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupManagerPresenter;

import java.util.ArrayList;
import java.util.List;

public class SetGroupManagerActivity extends BaseLightActivity {
    private TitleBarLayout titleBarLayout;
    private TextView managerCountLabel;

    private GroupManagerPresenter presenter;
    private GroupInfo groupInfo;
    private RecyclerView managerList;
    private ManagerAdapter managerAdapter;
    private ShadeImageView ownerFace;
    private TextView ownerName;
    private View setManagerView;
    private String ownerID;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_set_group_manager);
        titleBarLayout = findViewById(R.id.set_group_manager_title_bar);
        managerCountLabel = findViewById(R.id.set_group_manager_manager_label);
        managerList = findViewById(R.id.set_group_manager_manager_list);
        ownerFace = findViewById(R.id.set_group_manager_owner_face);
        ownerName = findViewById(R.id.set_group_manager_owner_name);
        setManagerView = findViewById(R.id.set_group_manager_add_manager);

        titleBarLayout.setTitle(getString(R.string.group_set_manager), ITitleBarLayout.Position.MIDDLE);
        managerList.setLayoutManager(new CustomLinearLayoutManager(this));
        managerAdapter = new ManagerAdapter();
        managerList.setAdapter(managerAdapter);
        groupInfo = (GroupInfo) getIntent().getSerializableExtra(TUIGroupConstants.Group.GROUP_INFO);

        presenter = new GroupManagerPresenter();

        setClickListener();
        loadGroupManager();
        loadGroupOwner();
    }

    private void loadGroupManager() {
        presenter.loadGroupManager(groupInfo.getId(), new IUIKitCallback<List<GroupMemberInfo>>() {
            @Override
            public void onSuccess(List<GroupMemberInfo> data) {
                if (data != null) {
                    managerCountLabel.setText(getString(R.string.group_add_manager_count_label, data.size()));
                    managerAdapter.setGroupMemberInfoList(data);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void loadGroupOwner() {
        presenter.loadGroupOwner(groupInfo.getId(), new IUIKitCallback<GroupMemberInfo>() {
            @Override
            public void onSuccess(GroupMemberInfo data) {
                ownerID = data.getAccount();
                String faceUrl = data.getIconUrl();
                String displayName = getDisplayName(data);
                GlideEngine.loadUserIcon(ownerFace, faceUrl);
                ownerName.setText(displayName);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void setClickListener() {
        titleBarLayout.getLeftIcon().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        setManagerView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(SetGroupManagerActivity.this, GroupMemberActivity.class);
                intent.putExtra(TUIConstants.TUIGroup.IS_SELECT_MODE, true);
                ArrayList<String> selectedList = new ArrayList<>();
                if (managerAdapter.getGroupMemberInfoList() != null) {
                    for (GroupMemberInfo memberInfo : managerAdapter.getGroupMemberInfoList()) {
                        selectedList.add(memberInfo.getAccount());
                    }
                    intent.putExtra(TUIConstants.TUIGroup.SELECTED_LIST, selectedList);
                }
                ArrayList<String> excludeList = new ArrayList<>();
                excludeList.add(ownerID);
                intent.putExtra(TUIConstants.TUIGroup.EXCLUDE_LIST, excludeList);
                intent.putExtra(TUIConstants.TUIGroup.GROUP_ID, groupInfo.getId());
                startActivityForResult(intent, 1);
            }
        });

        managerAdapter.setOnItemLongClickListener(new OnItemLongClickListener() {
            @Override
            public void onClick(View view, GroupMemberInfo memberInfo, int position) {
                Drawable drawable = view.getBackground();
                if (drawable != null) {
                    drawable.setColorFilter(0xd9d9d9, PorterDuff.Mode.SRC_IN);
                }
                View itemPop = LayoutInflater.from(SetGroupManagerActivity.this).inflate(R.layout.group_manager_pop_menu, null);
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
                popText.setText(R.string.group_remove_manager_label);
                popText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        popupWindow.dismiss();
                        presenter.clearGroupManager(groupInfo.getId(), memberInfo.getAccount(), new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                loadGroupManager();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {

                            }
                        });
                    }
                });
                int x = view.getWidth() / 2;
                int y = - view.getHeight() / 3;
                int popHeight = ScreenUtil.dip2px(45) * 3;
                if (y + popHeight + view.getY() + view.getHeight() > managerList.getBottom()) {
                    y = y - popHeight;
                }
                popupWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
            }
        });

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && data != null) {
            List<String> selectedList = data.getStringArrayListExtra(TUIGroupConstants.Selection.LIST);
            if (selectedList != null && !selectedList.isEmpty()) {
                for (String userId : selectedList) {
                    presenter.setGroupManager(groupInfo.getId(), userId, new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            loadGroupManager();
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

    class ManagerAdapter extends RecyclerView.Adapter<ManagerAdapter.ManagerViewHolder> {

        private List<GroupMemberInfo> groupMemberInfoList;

        private OnItemLongClickListener onItemLongClickListener;

        public void setOnItemLongClickListener(OnItemLongClickListener onItemLongClickListener) {
            this.onItemLongClickListener = onItemLongClickListener;
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
        public ManagerAdapter.ManagerViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_manager_item, parent, false);
            return new ManagerViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull ManagerViewHolder holder, int position) {
            GroupMemberInfo groupMemberInfo = groupMemberInfoList.get(position);
            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemLongClickListener != null) {
                        onItemLongClickListener.onClick(v, groupMemberInfo, position);
                    }
                    return true;
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

        class ManagerViewHolder extends RecyclerView.ViewHolder {
            ShadeImageView faceIcon;
            TextView managerName;
            public ManagerViewHolder(@NonNull View itemView) {
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
        void onClick(View view, GroupMemberInfo groupMemberInfo, int position);
    }
}