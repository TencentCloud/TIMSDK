package com.tencent.qcloud.tim.uikit.modules.contact;

import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.R;

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
        if (contactBean.isGroup()) {
            holder.avatar.setImageResource(R.drawable.conversation_group);
        } else if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.new_friend), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_new_friend);
        } else if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.group), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_common_list);
        } else if (TextUtils.equals(TUIKit.getAppContext().getResources().getString(R.string.blacklist), contactBean.getId())) {
            holder.avatar.setImageResource(R.drawable.group_black_list);
        } else {
            holder.avatar.setImageResource(R.drawable.ic_personal_member);
        }

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
        ImageView avatar;
        CheckBox ccSelect;
        View content;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvCity);
            avatar = itemView.findViewById(R.id.ivAvatar);
            ccSelect = itemView.findViewById(R.id.contact_check_box);
            content = itemView.findViewById(R.id.selectable_contact_item);
        }
    }
}
