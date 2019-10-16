package com.tencent.qcloud.tim.demo.contact;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.friendship.TIMFriendPendencyItem;
import com.tencent.imsdk.friendship.TIMFriendResponse;
import com.tencent.imsdk.friendship.TIMFriendResult;
import com.tencent.imsdk.friendship.TIMPendencyType;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.component.CircleImageView;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.List;

/**
 * 好友关系链管理消息adapter
 */
public class NewFriendListAdapter extends ArrayAdapter<TIMFriendPendencyItem> {

    private static final String TAG = NewFriendListAdapter.class.getSimpleName();

    private int mResourceId;
    private View mView;
    private ViewHolder mViewHolder;


    /**
     * Constructor
     *
     * @param context  The current context.
     * @param resource The resource ID for a layout ic_chat_input_file containing a TextView to use when
     *                 instantiating views.
     * @param objects  The objects to represent in the ListView.
     */
    public NewFriendListAdapter(Context context, int resource, List<TIMFriendPendencyItem> objects) {
        super(context, resource, objects);
        mResourceId = resource;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final TIMFriendPendencyItem data = getItem(position);
        if (convertView != null) {
            mView = convertView;
            mViewHolder = (ViewHolder) mView.getTag();
        } else {
            mView = LayoutInflater.from(getContext()).inflate(mResourceId, null);
            mView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(DemoApplication.instance(), FriendProfileActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.ProfileType.CONTENT, data);
                    DemoApplication.instance().startActivity(intent);
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
        mViewHolder.name.setText(TextUtils.isEmpty(data.getNickname()) ? data.getIdentifier() : data.getNickname());
        mViewHolder.des.setText(data.getAddWording());
        switch (data.getType()) {
            case TIMPendencyType.TIM_PENDENCY_COME_IN:
                mViewHolder.agree.setText(res.getString(R.string.request_agree));
                mViewHolder.agree.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        final TextView vv = (TextView) v;
                        doResponse(vv, data);
                    }
                });
                break;
            case TIMPendencyType.TIM_PENDENCY_SEND_OUT:
                mViewHolder.agree.setText(res.getString(R.string.request_waiting));
                break;
            case TIMPendencyType.TIM_PENDENCY_BOTH:
                mViewHolder.agree.setText(res.getString(R.string.request_accepted));
                break;
        }
        return mView;
    }

    private void doResponse(final TextView view, TIMFriendPendencyItem data) {
        TIMFriendResponse response = new TIMFriendResponse();
        response.setIdentifier(data.getIdentifier());
        response.setResponseType(TIMFriendResponse.TIM_FRIEND_RESPONSE_AGREE_AND_ADD);
        TIMFriendshipManager.getInstance().doResponse(response, new TIMValueCallBack<TIMFriendResult>() {
            @Override
            public void onError(int i, String s) {
                DemoLog.e(TAG, "deleteFriends err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess(TIMFriendResult timUserProfiles) {
                DemoLog.i(TAG, "deleteFriends success");
                view.setText(getContext().getResources().getString(R.string.request_accepted));
            }
        });
    }

    public class ViewHolder {
        ImageView avatar;
        TextView name;
        TextView des;
        Button agree;
    }

}
