package com.tencent.qcloud.uikit.business.contact.view.adapter;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.view.ContactList;

import java.util.List;

/**
 * Created by valexhuang on 2018/7/3.
 */


public class ContactAdapter extends RecyclerView.Adapter<ContactAdapter.ViewHolder> {
    protected List<ContactInfoBean> mDatas;
    protected LayoutInflater mInflater;
    private ContactList.ContactSelectChangedListener mSelectChangeListener;

    public ContactAdapter(List<ContactInfoBean> mDatas) {
        this.mDatas = mDatas;
        mInflater = LayoutInflater.from(TUIKit.getAppContext());

    }

    public List<ContactInfoBean> getDatas() {
        return mDatas;
    }

    public ContactAdapter setDatas(List<ContactInfoBean> datas) {
        mDatas = datas;
        return this;
    }

    @Override
    public ContactAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ContactAdapter.ViewHolder(mInflater.inflate(R.layout.contact_selecable_adapter_item, parent, false));
    }

    @Override
    public void onBindViewHolder(final ContactAdapter.ViewHolder holder, final int position) {
        final ContactInfoBean contactBean = mDatas.get(position);
        holder.tvName.setText(contactBean.getIdentifier());
        if (mSelectChangeListener != null) {
            holder.ccSelect.setVisibility(View.VISIBLE);
            holder.ccSelect.setChecked(contactBean.isSelected());
            holder.ccSelect.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    mSelectChangeListener.onSelectChanged(getItem(position), isChecked);
                }
            });
        }

        holder.content.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                holder.ccSelect.setChecked(!holder.ccSelect.isChecked());
            }
        });
        holder.avatar.setImageResource(R.drawable.friend);
    }

    private ContactInfoBean getItem(int position) {
        return mDatas.get(position);
    }


    @Override
    public int getItemCount() {
        return mDatas != null ? mDatas.size() : 0;
    }

    public void setDataSource(List<ContactInfoBean> datas) {
        this.mDatas = datas;
        notifyDataSetChanged();
    }


    public void setContactSelectListener(ContactList.ContactSelectChangedListener selectListener) {
        mSelectChangeListener = selectListener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        ImageView avatar;
        CheckBox ccSelect;
        View content;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = (TextView) itemView.findViewById(R.id.tvCity);
            avatar = (ImageView) itemView.findViewById(R.id.ivAvatar);
            ccSelect = itemView.findViewById(R.id.contact_check_box);
            content = itemView.findViewById(R.id.selectable_contact_item);
        }
    }
}
