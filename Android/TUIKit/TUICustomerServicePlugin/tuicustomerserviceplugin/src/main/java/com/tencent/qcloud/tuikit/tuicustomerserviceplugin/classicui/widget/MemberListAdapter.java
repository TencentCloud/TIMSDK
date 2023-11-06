package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.classicui.util.ContactStartChatUtils;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import java.util.List;

public class MemberListAdapter extends ArrayAdapter<V2TIMUserFullInfo> {
    private int mResourceID;
    private View mView;
    private ViewHolder mViewHolder;

    public MemberListAdapter(@NonNull Context context, int resource, @NonNull List<V2TIMUserFullInfo> objects) {
        super(context, resource, objects);
        mResourceID = resource;
    }

    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        V2TIMUserFullInfo userInfo = getItem(position);
        if (convertView != null) {
            mView = convertView;
            mViewHolder = (ViewHolder) mView.getTag();
        } else {
            mView = LayoutInflater.from(getContext()).inflate(mResourceID, null);
            mView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ContactStartChatUtils.startChatActivity(userInfo.getUserID(), ContactItemBean.TYPE_C2C, userInfo.getNickName(), "");
                }
            });
            mViewHolder = new ViewHolder();
            mViewHolder.avatar = mView.findViewById(R.id.customer_service_member_avatar);
            mViewHolder.name = mView.findViewById(R.id.customer_service_member_name);
            mView.setTag(mViewHolder);
        }

        Resources res = getContext().getResources();
        int radius = res.getDimensionPixelSize(com.tencent.qcloud.tuikit.tuicontact.R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(mViewHolder.avatar, userInfo.getFaceUrl(), radius);
        mViewHolder.name.setText(TextUtils.isEmpty(userInfo.getNickName()) ? userInfo.getUserID() : userInfo.getNickName());
        return mView;
    }

    public class ViewHolder {
        ImageView avatar;
        TextView name;
    }
}
