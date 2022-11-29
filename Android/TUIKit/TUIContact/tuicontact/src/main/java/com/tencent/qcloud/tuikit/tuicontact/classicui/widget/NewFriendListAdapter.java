package com.tencent.qcloud.tuikit.tuicontact.classicui.widget;

import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.presenter.NewFriendPresenter;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;

import java.util.List;

public class NewFriendListAdapter extends ArrayAdapter<FriendApplicationBean> {

    private static final String TAG = NewFriendListAdapter.class.getSimpleName();

    private int mResourceId;
    private View mView;
    private ViewHolder mViewHolder;

    private NewFriendPresenter presenter;
    /**
     * Constructor
     *
     * @param context  The current context.
     * @param resource The resource ID for a layout ic_chat_input_file containing a TextView to use when
     *                 instantiating views.
     * @param objects  The objects to represent in the ListView.
     */
    public NewFriendListAdapter(Context context, int resource, List<FriendApplicationBean> objects) {
        super(context, resource, objects);
        mResourceId = resource;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final FriendApplicationBean data = getItem(position);
        if (convertView != null) {
            mView = convertView;
            mViewHolder = (ViewHolder) mView.getTag();
        } else {
            mView = LayoutInflater.from(getContext()).inflate(mResourceId, null);
            mView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable(TUIContactConstants.ProfileType.CONTENT, data);
                    TUICore.startActivity("FriendProfileActivity", bundle);
                }
            });
            mViewHolder = new ViewHolder();
            mViewHolder.avatar = mView.findViewById(R.id.avatar);
            mViewHolder.name = mView.findViewById(R.id.name);
            mViewHolder.des = mView.findViewById(R.id.description);
            mViewHolder.agree = mView.findViewById(R.id.agree);
            mViewHolder.reject = mView.findViewById(R.id.reject);
            mViewHolder.result = mView.findViewById(R.id.result_tv);
            mView.setTag(mViewHolder);
        }
        Resources res = getContext().getResources();
        int radius = mView.getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(mViewHolder.avatar, data.getFaceUrl(), radius);
        mViewHolder.name.setText(TextUtils.isEmpty(data.getNickName()) ? data.getUserId() : data.getNickName());
        mViewHolder.des.setText(data.getAddWording());
        switch (data.getAddType()) {
            case FriendApplicationBean.FRIEND_APPLICATION_COME_IN:
                mViewHolder.agree.setText(res.getString(R.string.request_agree));
                mViewHolder.agree.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        doResponse(data, true);
                    }
                });
                mViewHolder.reject.setText(res.getString(R.string.refuse));
                mViewHolder.reject.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        doResponse(data, false);
                    }
                });
                if (data.isAccept()) {
                    mViewHolder.agree.setVisibility(View.GONE);
                    mViewHolder.reject.setVisibility(View.GONE);
                    mViewHolder.result.setVisibility(View.VISIBLE);
                }
                break;
            case FriendApplicationBean.FRIEND_APPLICATION_BOTH:
                mViewHolder.agree.setText(res.getString(R.string.request_accepted));
                break;
        }
        return mView;
    }

    private void doResponse(FriendApplicationBean bean, boolean isAccept) {
        if (presenter != null) {
            if (isAccept) {
                presenter.acceptFriendApplication(bean, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        bean.setAccept(true);
                        refreshList();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage("Error code = " + errCode + ", desc = " + errMsg);
                    }
                });
            } else {
                presenter.refuseFriendApplication(bean, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage("Error code = " + errCode + ", desc = " + errMsg);
                    }
                });
            }
        }
    }

    private void refreshList() {
        notifyDataSetChanged();
    }

    public void setPresenter(NewFriendPresenter presenter) {
        this.presenter = presenter;
    }

    public class ViewHolder {
        ImageView avatar;
        TextView name;
        TextView des;
        TextView agree;
        TextView reject;
        TextView result;
    }

}
