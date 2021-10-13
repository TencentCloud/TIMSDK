package com.tencent.qcloud.tuikit.tuicontact.ui.view;

import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.component.CircleImageView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.NewFriendPresenter;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;

import java.util.List;

/**
 * 好友关系链管理消息adapter
 */
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
            mViewHolder.avatar = (CircleImageView) mView.findViewById(R.id.avatar);
            mViewHolder.name = mView.findViewById(R.id.name);
            mViewHolder.des = mView.findViewById(R.id.description);
            mViewHolder.agree = mView.findViewById(R.id.agree);
            mView.setTag(mViewHolder);
        }
        Resources res = getContext().getResources();
        mViewHolder.avatar.setImageResource(R.drawable.ic_personal_member);
        mViewHolder.name.setText(TextUtils.isEmpty(data.getNickName()) ? data.getUserId() : data.getNickName());
        mViewHolder.des.setText(data.getAddWording());
        switch (data.getAddType()) {
            case FriendApplicationBean.FRIEND_APPLICATION_COME_IN:
                mViewHolder.agree.setText(res.getString(R.string.request_agree));
                mViewHolder.agree.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        final TextView vv = (TextView) v;
                        doResponse(vv, data);
                    }
                });
                break;
            case FriendApplicationBean.FRIEND_APPLICATION_SEND_OUT:
                mViewHolder.agree.setText(res.getString(R.string.request_waiting));
                break;
            case FriendApplicationBean.FRIEND_APPLICATION_BOTH:
                mViewHolder.agree.setText(res.getString(R.string.request_accepted));
                break;
        }
        return mView;
    }

    private void doResponse(final TextView view, FriendApplicationBean data) {
        if (presenter != null) {
            presenter.acceptFriendApplication(data, new IUIKitCallback<Void>(){
                @Override
                public void onSuccess(Void data) {
                    if (view != null) {
                        view.setText(TUIContactService.getAppContext().getResources().getString(R.string.request_accepted));
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastShortMessage("Error code = " + errCode + ", desc = " + errMsg);
                }
            });
        }

    }

    public void setPresenter(NewFriendPresenter presenter) {
        this.presenter = presenter;
    }

    public class ViewHolder {
        ImageView avatar;
        TextView name;
        TextView des;
        Button agree;
    }

}
