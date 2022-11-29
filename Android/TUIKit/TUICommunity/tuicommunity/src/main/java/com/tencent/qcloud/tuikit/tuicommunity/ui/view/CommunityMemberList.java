package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityMemberActivity;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityMemberList;

import java.util.ArrayList;
import java.util.List;

public class CommunityMemberList extends LinearLayout implements ICommunityMemberList {

    private TitleBarLayout titleBar;
    private GroupMemberAdapter adapter;
    private CommunityBean communityBean;
    private RecyclerView recyclerView;
    private boolean isSelectMode;
    private String title;
    private List<CommunityMemberBean> communityMemberBeans;

    private CommunityPresenter presenter;
    private long nextSeq = 0;

    private ICommunityMemberActivity communityMemberActivity;

    private MemberListListener memberListListener;
    public CommunityMemberList(Context context) {
        super(context);
        init();
    }

    public CommunityMemberList(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CommunityMemberList(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.community_member_layout, this);
        titleBar = findViewById(R.id.group_member_title_bar);
        titleBar.setTitle(getContext().getString(R.string.community_invite), ITitleBarLayout.Position.RIGHT);
        titleBar.getRightIcon().setVisibility(GONE);
        titleBar.setOnRightClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                startInviteGroup();
            }
        });
        adapter = new GroupMemberAdapter();
        recyclerView = findViewById(R.id.group_all_members);
        recyclerView.setLayoutManager(new CustomLinearLayoutManager(getContext()));
        recyclerView.setAdapter(adapter);
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    // 判断滚动到底部
                    LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
                    if (layoutManager == null) {
                        return;
                    }
                    int lastPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                    if (adapter != null && nextSeq != 0) {
                        if (lastPosition == adapter.getItemCount() - 1) {
                            if (communityBean != null) {
                                presenter.loadCommunityMembers(communityBean.getGroupId(), nextSeq);
                            }
                        }
                    }
                }
            }
        });
    }

    public void loadMemberList() {
        presenter.loadCommunityMembers(communityBean.getGroupId(), 0);
    }

    public void setCommunityBean(CommunityBean communityBean) {
        this.communityBean = communityBean;
    }

    public List<CommunityMemberBean> getCommunityMemberBeans() {
        return communityMemberBeans;
    }

    public TitleBarLayout getTitleBar() {
        return titleBar;
    }

    public void setSelectMode(boolean selectMode) {
        isSelectMode = selectMode;
        if (isSelectMode) {
            titleBar.setTitle(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
            titleBar.getRightGroup().setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (memberListListener != null) {
                        memberListListener.setSelectedMember(adapter.getSelectedMember());
                    }
                }
            });
        }

        adapter.setSelectMode(isSelectMode);
    }

    public void setTitle(String title) {
        this.title = title;
        titleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
    }

    public void onGroupInfoChanged(CommunityBean communityBean) {
        this.communityBean = communityBean;
        presenter.setCurrentCommunityBean(communityBean);
        adapter.setCommunityBean(communityBean);
    }

    private void startInviteGroup() {
        if (communityBean == null) {
            return;
        }
        if (communityMemberActivity != null) {
            communityMemberActivity.onAddCommunityMember();
        }
    }

    public void setCommunityMemberListener(ICommunityMemberActivity listener) {
        this.communityMemberActivity = listener;
    }

    public void setPresenter(CommunityPresenter presenter) {
        this.presenter = presenter;
        adapter.setPresenter(presenter);
    }

    @Override
    public void onMemberListChanged(List<CommunityMemberBean> memberBeanList, long nextSeq) {
        this.communityMemberBeans = memberBeanList;
        this.nextSeq = nextSeq;
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    public void setGroupMemberListener(MemberListListener listener) {
        this.memberListListener = listener;
    }

    public interface MemberListListener {
        void setSelectedMember(ArrayList<String> members);
    }

    public class GroupMemberAdapter extends RecyclerView.Adapter<GroupMemberAdapter.GroupMemberViewHolder> {

        private CommunityPresenter presenter;
        private boolean isSelectMode;

        private ArrayList<String> selectedMember = new ArrayList<>();

        public void setSelectMode(boolean selectMode) {
            isSelectMode = selectMode;
        }

        public ArrayList<String> getSelectedMember() {
            return selectedMember;
        }

        public void setPresenter(CommunityPresenter presenter) {
            this.presenter = presenter;
        }

        @NonNull
        @Override
        public GroupMemberViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_member_list_item, parent, false);
            return new GroupMemberViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull GroupMemberViewHolder holder, int position) {
            final CommunityMemberBean memberBean = communityMemberBeans.get(position);
            GlideEngine.loadImage(holder.memberIcon, memberBean.getAvatar());
            holder.memberName.setText(memberBean.getDisplayName());
            if (isSelectMode) {
                holder.checkBox.setVisibility(View.VISIBLE);
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        holder.checkBox.setChecked(!holder.checkBox.isChecked());
                        if (holder.checkBox.isChecked()) {
                            selectedMember.add(memberBean.getAccount());
                        } else {
                            selectedMember.remove(memberBean.getAccount());
                        }
                    }
                });
            } else {
                holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        if (!communityBean.isOwner()) {
                            return true;
                        }
                        Drawable drawable = view.getBackground();
                        if (drawable != null) {
                            drawable.setColorFilter(0xd9d9d9, PorterDuff.Mode.SRC_IN);
                        }
                        View itemPop = LayoutInflater.from(getContext()).inflate(R.layout.community_member_list_delete_popup_layout, null);
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
                        popText.setText(R.string.community_remove_member);
                        popText.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                List<String> dels = new ArrayList<>();
                                dels.add(memberBean.getAccount());
                                if (presenter == null) {
                                    return;
                                }
                                presenter.removeGroupMembers(communityBean.getGroupId(), dels, new IUIKitCallback<List<String>>() {
                                    @Override
                                    public void onSuccess(List<String> data) {
                                        communityMemberBeans.remove(memberBean);
                                        notifyDataSetChanged();
                                    }

                                    @Override
                                    public void onError(String module, int errCode, String errMsg) {
                                        ToastUtil.toastLongMessage(getResources().getString(R.string.community_remove_fail_tip) + ":errCode=" + errCode);
                                    }
                                });
                                popupWindow.dismiss();
                            }
                        });
                        int x = view.getWidth() / 2;
                        int y = - view.getHeight() / 3;
                        int popHeight = ScreenUtil.dip2px(45) * 3;
                        if (y + popHeight + view.getY() + view.getHeight() > CommunityMemberList.this.getBottom()) {
                            y = y - popHeight;
                        }
                        popupWindow.showAsDropDown(view, x, y);
                        return true;
                    }
                });

                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Bundle bundle = new Bundle();
                        bundle.putString(TUIConstants.TUIChat.CHAT_ID, memberBean.getAccount());
                        TUICore.startActivity("FriendProfileActivity", bundle);
                    }
                });
            }
        }

        @Override
        public int getItemCount() {
            if (communityMemberBeans == null) {
                return 0;
            }
            return communityMemberBeans.size();
        }

        public void setCommunityBean(CommunityBean communityBean) {
            if (communityBean != null) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        notifyDataSetChanged();
                    }
                });
            }
        }

        protected class GroupMemberViewHolder extends RecyclerView.ViewHolder {
            private final ImageView memberIcon;
            private final TextView memberName;
            private final CheckBox checkBox;

            public GroupMemberViewHolder(@NonNull View itemView) {
                super(itemView);
                checkBox = itemView.findViewById(R.id.group_member_check_box);
                memberIcon = itemView.findViewById(R.id.group_member_icon);
                memberName = itemView.findViewById(R.id.group_member_name);
            }
        }
    }

}
