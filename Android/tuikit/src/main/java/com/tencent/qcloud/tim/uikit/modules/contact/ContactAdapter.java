package com.tencent.qcloud.tim.uikit.modules.contact;

import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.friendship.TIMFriendPendencyRequest;
import com.tencent.imsdk.friendship.TIMFriendPendencyResponse;
import com.tencent.imsdk.friendship.TIMPendencyType;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.List;


public class ContactAdapter extends RecyclerView.Adapter<ContactAdapter.ViewHolder> {

    protected List<ContactItemBean> mData;
    protected LayoutInflater mInflater;
    private ContactListView.OnSelectChangedListener mOnSelectChangedListener;
    private ContactListView.OnItemClickListener mOnClickListener;

    private int mPreSelectedPosition;
    private boolean isSingleSelectMode;

    public ContactAdapter(List<ContactItemBean> data) {
        this.mData = data;
        mInflater = LayoutInflater.from(TUIKit.getAppContext());
    }

    @Override
    public ContactAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ContactAdapter.ViewHolder(mInflater.inflate(R.layout.contact_selecable_adapter_item, parent, false));
    }

    @Override
    public void onBindViewHolder(final ContactAdapter.ViewHolder holder, final int position) {
        final ContactItemBean contactBean = mData.get(position);
        if (!TextUtils.isEmpty(contactBean.getRemark())) {
            holder.tvName.setText(contactBean.getRemark());
        } else if (!TextUtils.isEmpty(contactBean.getNickname())) {
            holder.tvName.setText(contactBean.getNickname());
        } else {
            holder.tvName.setText(contactBean.getId());
        }
        if (mOnSelectChangedListener != null) {
            holder.ccSelect.setVisibility(View.VISIBLE);
            holder.ccSelect.setChecked(contactBean.isSelected());
            holder.ccSelect.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    mOnSelectChangedListener.onSelectChanged(getItem(position), isChecked);
                }
            });
        }

        holder.content.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!contactBean.isEnable()) {
                    return;
                }
                holder.ccSelect.setChecked(!holder.ccSelect.isChecked());
                contactBean.setSelected(holder.ccSelect.isChecked());
                if (mOnClickListener != null) {
                    mOnClickListener.onItemClick(position, contactBean);
                }
                if (isSingleSelectMode && position != mPreSelectedPosition && contactBean.isSelected()) {
                    //单选模式的prePos处理
                    mData.get(mPreSelectedPosition).setSelected(false);
                    notifyItemChanged(mPreSelectedPosition);
                }
                mPreSelectedPosition = position;
            }
        });
        holder.unreadText.setVisibility(View.GONE);
        if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.new_friend), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_new_friend);
            final TIMFriendPendencyRequest timFriendPendencyRequest = new TIMFriendPendencyRequest();
            timFriendPendencyRequest.setTimPendencyGetType(TIMPendencyType.TIM_PENDENCY_COME_IN);
            TIMFriendshipManager.getInstance().getPendencyList(timFriendPendencyRequest, new TIMValueCallBack<TIMFriendPendencyResponse>() {
                @Override
                public void onError(int i, String s) {
                    ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
                }

                @Override
                public void onSuccess(TIMFriendPendencyResponse timFriendPendencyResponse) {
                    if (timFriendPendencyResponse.getItems() != null) {
                        int pendingRequest = timFriendPendencyResponse.getItems().size();
                        if (pendingRequest == 0) {
                            holder.unreadText.setVisibility(View.GONE);
                        } else {
                            holder.unreadText.setVisibility(View.VISIBLE);
                            holder.unreadText.setText("" + pendingRequest);
                        }
                    }
                }
            });
        } else if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.group), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_common_list);
        } else if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.blacklist), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_black_list);
        } else {
            if (TextUtils.isEmpty(contactBean.getAvatarurl())) {
                if (contactBean.isGroup()) {
                    holder.avatar.setImageResource(R.drawable.conversation_group);
                } else {
                    holder.avatar.setImageResource(R.drawable.ic_personal_member);
                }
            } else {
                GlideEngine.loadImage(holder.avatar, Uri.parse(contactBean.getAvatarurl()));
            }
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

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        TextView unreadText;
        ImageView avatar;
        CheckBox ccSelect;
        View content;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvCity);
            unreadText = itemView.findViewById(R.id.conversation_unread);
            unreadText.setVisibility(View.GONE);
            avatar = itemView.findViewById(R.id.ivAvatar);
            ccSelect = itemView.findViewById(R.id.contact_check_box);
            content = itemView.findViewById(R.id.selectable_contact_item);
        }
    }
}
