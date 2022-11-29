package com.tencent.qcloud.tuikit.tuicontact.classicui.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.TUIUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.config.TUIContactConfig;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;

import java.util.ArrayList;
import java.util.List;

public class ContactAdapter extends RecyclerView.Adapter<ContactAdapter.ViewHolder> {

    protected List<ContactItemBean> mData;
    private ContactListView.OnSelectChangedListener mOnSelectChangedListener;
    private ContactListView.OnItemClickListener mOnClickListener;

    private int mPreSelectedPosition;
    private boolean isSingleSelectMode;
    private ContactPresenter presenter;
    private boolean isGroupList = false;
    private int dataSourceType = ContactListView.DataSource.UNKNOWN;
    private ArrayList<String> alreadySelectedList;

    public ContactAdapter(List<ContactItemBean> data) {
        this.mData = data;
    }

    public void setPresenter(ContactPresenter presenter) {
        this.presenter = presenter;
    }

    public void setIsGroupList(boolean groupList) {
        isGroupList = groupList;
    }

    public void setAlreadySelectedList(ArrayList<String> alreadySelectedList) {
        this.alreadySelectedList = alreadySelectedList;
    }

    @Override
    public ContactAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ContactAdapter.ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.contact_selecable_adapter_item, parent, false));
    }

    @Override
    public void onBindViewHolder(final ContactAdapter.ViewHolder holder, final int position) {
        final ContactItemBean contactBean = mData.get(position);
        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)holder.line.getLayoutParams();
        if (position < mData.size() - 1) {
            String tag1 = contactBean.getSuspensionTag();
            String tag2 = mData.get(position + 1).getSuspensionTag();

            if (TextUtils.equals(tag1, tag2)) {
                params.leftMargin = holder.tvName.getLeft();
            } else {
                params.leftMargin = 0;
            }
        } else {
            params.leftMargin = 0;
        }
        holder.line.setLayoutParams(params);
        if (!TextUtils.isEmpty(contactBean.getRemark())) {
            holder.tvName.setText(contactBean.getRemark());
        } else if (!TextUtils.isEmpty(contactBean.getNickName())) {
            holder.tvName.setText(contactBean.getNickName());
        } else {
            holder.tvName.setText(contactBean.getId());
        }
        if (mOnSelectChangedListener != null) {
            holder.ccSelect.setVisibility(View.VISIBLE);
            holder.ccSelect.setChecked(contactBean.isSelected());
        }

        holder.content.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!contactBean.isEnable()) {
                    return;
                }
                holder.ccSelect.setChecked(!holder.ccSelect.isChecked());
                if (mOnSelectChangedListener != null) {
                    mOnSelectChangedListener.onSelectChanged(getItem(position), holder.ccSelect.isChecked());
                }
                contactBean.setSelected(holder.ccSelect.isChecked());
                if (mOnClickListener != null) {
                    mOnClickListener.onItemClick(position, contactBean);
                }
                if (isSingleSelectMode && position != mPreSelectedPosition && contactBean.isSelected()) {
                    mData.get(mPreSelectedPosition).setSelected(false);
                    notifyItemChanged(mPreSelectedPosition);
                }
                mPreSelectedPosition = position;
            }
        });
        holder.unreadText.setVisibility(View.GONE);
        holder.userStatusView.setVisibility(View.GONE);
        if (TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.new_friend), contactBean.getId())) {
            holder.avatar.setImageResource(TUIThemeManager.getAttrResId(holder.itemView.getContext(), R.attr.contact_new_friend_icon));

            presenter.getFriendApplicationUnreadCount(new IUIKitCallback<Integer>() {
                @Override
                public void onSuccess(Integer data) {
                    if (data == 0) {
                        holder.unreadText.setVisibility(View.GONE);
                    } else {
                        holder.unreadText.setVisibility(View.VISIBLE);
                        holder.unreadText.setText("" + data);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastShortMessage("Error code = " + errCode + ", desc = " + errMsg);
                }
            });

        } else if (TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.group), contactBean.getId())) {
            holder.avatar.setImageResource(TUIThemeManager.getAttrResId(holder.itemView.getContext(), R.attr.contact_group_list_icon));
        } else if (TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.blacklist), contactBean.getId())) {
            holder.avatar.setImageResource(TUIThemeManager.getAttrResId(holder.itemView.getContext(), R.attr.contact_black_list_icon));
        } else {
            int radius = holder.itemView.getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
            if (isGroupList) {
                int defaultIconResId = TUIUtil.getDefaultGroupIconResIDByGroupType(holder.itemView.getContext(), contactBean.getGroupType());
                GlideEngine.loadUserIcon(holder.avatar, contactBean.getAvatarUrl(), defaultIconResId, radius);
            } else {
                GlideEngine.loadUserIcon(holder.avatar, contactBean.getAvatarUrl(), radius);
            }
            if (dataSourceType == ContactListView.DataSource.CONTACT_LIST && TUIContactConfig.getInstance().isShowUserStatus()) {
                holder.userStatusView.setVisibility(View.VISIBLE);
                if (contactBean.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE) {
                    holder.userStatusView.setBackgroundResource(TUIThemeManager.getAttrResId(TUIContactService.getAppContext(), com.tencent.qcloud.tuicore.R.attr.user_status_online));
                } else {
                    holder.userStatusView.setBackgroundResource(TUIThemeManager.getAttrResId(TUIContactService.getAppContext(), com.tencent.qcloud.tuicore.R.attr.user_status_offline));
                }
            } else {
                holder.userStatusView.setVisibility(View.GONE);
            }
        }
        setAlreadySelected(holder, contactBean);
    }

    private void setAlreadySelected(ContactAdapter.ViewHolder holder, ContactItemBean contactItemBean) {
        if (alreadySelectedList != null && alreadySelectedList.contains(contactItemBean.getId())) {
            holder.ccSelect.setChecked(true);
            holder.itemView.setEnabled(false);
            holder.ccSelect.setEnabled(false);
        } else {
            holder.itemView.setEnabled(true);
            holder.ccSelect.setEnabled(true);
            holder.ccSelect.setSelected(contactItemBean.isSelected());
        }
    }

    @Override
    public void onViewRecycled(ContactAdapter.ViewHolder holder) {
        if (holder != null) {
            GlideEngine.clear(holder.avatar);
            holder.avatar.setImageResource(0);

        }
        super.onViewRecycled(holder);
    }

    private ContactItemBean getItem(int position) {
        if (position < mData.size()) {
            return mData.get(position);
        }
        return null;
    }

    @Override
    public int getItemCount() {
        return mData != null ? mData.size() : 0;
    }

    public void setDataSource(List<ContactItemBean> datas) {
        this.mData = datas;
        notifyDataSetChanged();
    }

    public void setSingleSelectMode(boolean mode) {
        isSingleSelectMode = mode;
    }

    public void setOnSelectChangedListener(ContactListView.OnSelectChangedListener selectListener) {
        mOnSelectChangedListener = selectListener;
    }

    public void setOnItemClickListener(ContactListView.OnItemClickListener listener) {
        mOnClickListener = listener;
    }

    public void setDataSourceType(int dataSourceType) {
        this.dataSourceType = dataSourceType;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        TextView unreadText;
        ImageView avatar;
        CheckBox ccSelect;
        View content;
        View line;
        View userStatusView;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvCity);
            unreadText = itemView.findViewById(R.id.conversation_unread);
            unreadText.setVisibility(View.GONE);
            avatar = itemView.findViewById(R.id.ivAvatar);
            ccSelect = itemView.findViewById(R.id.contact_check_box);
            content = itemView.findViewById(R.id.selectable_contact_item);
            line = itemView.findViewById(R.id.view_line);
            userStatusView = itemView.findViewById(R.id.user_status);
        }
    }
}
