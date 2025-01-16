package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.presenter.GroupManagerPresenter;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class SetGroupManagerActivity extends BaseLightActivity {
    private TitleBarLayout titleBarLayout;
    private TextView managerCountLabel;

    private GroupManagerPresenter presenter;
    private GroupProfileBean profileBean;
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
        profileBean = (GroupProfileBean) getIntent().getSerializableExtra(TUIContactConstants.Group.GROUP_INFO);

        presenter = new GroupManagerPresenter();

        setClickListener();
        loadGroupManager();
        loadGroupOwner();
    }

    private void loadGroupManager() {
        presenter.loadGroupManager(profileBean.getGroupID(), new IUIKitCallback<List<GroupMemberInfo>>() {
            @Override
            public void onSuccess(List<GroupMemberInfo> data) {
                if (data != null) {
                    managerCountLabel.setText(String.format(Locale.US, getString(R.string.group_add_manager_count_label), data.size()));
                    managerAdapter.setGroupMemberInfoList(data);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    private void loadGroupOwner() {
        presenter.loadGroupOwner(profileBean.getGroupID(), new IUIKitCallback<GroupMemberInfo>() {
            @Override
            public void onSuccess(GroupMemberInfo data) {
                ownerID = data.getUserId();
                String faceUrl = data.getFaceUrl();
                String displayName = data.getDisplayName();
                GlideEngine.loadUserIcon(ownerFace, faceUrl);
                ownerName.setText(displayName);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
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
                intent.putExtra(TUIConstants.TUIContact.IS_SELECT_MODE, true);
                ArrayList<String> selectedList = new ArrayList<>();
                if (managerAdapter.getGroupMemberInfoList() != null) {
                    for (GroupMemberInfo memberInfo : managerAdapter.getGroupMemberInfoList()) {
                        selectedList.add(memberInfo.getUserId());
                    }
                    intent.putExtra(TUIConstants.TUIContact.SELECTED_LIST, selectedList);
                }
                ArrayList<String> excludeList = new ArrayList<>();
                excludeList.add(ownerID);
                intent.putExtra(TUIConstants.TUIContact.EXCLUDE_LIST, excludeList);
                intent.putExtra(TUIConstants.TUIContact.GROUP_ID, profileBean.getGroupID());
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
                        presenter.clearGroupManager(profileBean.getGroupID(), memberInfo.getUserId(), new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                loadGroupManager();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {}
                        });
                    }
                });
                int x = view.getWidth() / 2;
                int y = -view.getHeight() / 2;
                int popHeight = ScreenUtil.dip2px(45) * 3;
                if (y + popHeight + view.getY() + view.getHeight() > managerList.getBottom()) {
                    y = y - popHeight;
                }
                popupWindow.showAsDropDown(view, x, y, Gravity.CENTER);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && data != null) {
            List<String> selectedList = data.getStringArrayListExtra(TUIContactConstants.Selection.LIST);
            if (selectedList != null && !selectedList.isEmpty()) {
                for (String userId : selectedList) {
                    presenter.setGroupManager(profileBean.getGroupID(), userId, new IUIKitCallback<Void>() {
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
            holder.managerName.setText(groupMemberInfo.getDisplayName());
            GlideEngine.loadUserIcon(holder.faceIcon, groupMemberInfo.getFaceUrl());
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

    interface OnItemLongClickListener {
        void onClick(View view, GroupMemberInfo groupMemberInfo, int position);
    }
}