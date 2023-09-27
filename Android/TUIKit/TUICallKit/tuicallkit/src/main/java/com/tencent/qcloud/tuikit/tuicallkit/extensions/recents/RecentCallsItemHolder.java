package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class RecentCallsItemHolder extends RecyclerView.ViewHolder {
    protected RecordsIconView  mCallIconView;
    protected TextView         mTextUserTitle;
    protected ImageView        mImageMediaType;
    protected TextView         mTextCallStatus;
    protected TextView         mTextCallTime;
    protected ImageView        mImageDetails;
    protected RelativeLayout   mLayoutDelete;
    protected CheckBox         mCheckBoxSelectCall;
    protected ConstraintLayout mLayoutView;

    public RecentCallsItemHolder(@NonNull View itemView) {
        super(itemView);
        initView();
    }

    private void initView() {
        mLayoutDelete = itemView.findViewById(R.id.ll_call_delete);
        mCheckBoxSelectCall = itemView.findViewById(R.id.cb_call_select);

        mCallIconView = itemView.findViewById(R.id.call_icon);
        mTextUserTitle = itemView.findViewById(R.id.tv_call_user_id);
        mImageMediaType = itemView.findViewById(R.id.call_media_type);
        mTextCallStatus = itemView.findViewById(R.id.tv_call_status);
        mTextCallTime = itemView.findViewById(R.id.tv_call_time);
        mImageDetails = itemView.findViewById(R.id.img_call_details);

        mLayoutView = itemView.findViewById(R.id.cl_info_layout);
    }

    public void layoutViews(Context context, TUICallDefine.CallRecords records, int position) {
        if (records == null) {
            return;
        }

        int colorId = TUICallDefine.CallRecords.Result.Missed.equals(records.result)
                ? R.color.tuicallkit_record_text_red : R.color.tuicalling_color_black;
        mTextUserTitle.setTextColor(context.getResources().getColor(colorId));

        int imageId = TUICallDefine.MediaType.Video.equals(records.mediaType)
                ? R.drawable.tuicallkit_record_ic_video_call : R.drawable.tuicallkit_ic_audio_call;
        mImageMediaType.setImageDrawable(context.getResources().getDrawable(imageId));

        String resultMsg = context.getString(R.string.tuicallkit_record_result_unknown);
        if (TUICallDefine.CallRecords.Result.Missed.equals(records.result)) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_missed);
        } else if (TUICallDefine.CallRecords.Result.Incoming.equals(records.result)) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_incoming);
        } else if (TUICallDefine.CallRecords.Result.Outgoing.equals(records.result)) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_outgoing);
        }
        mTextCallStatus.setText(resultMsg);

        mTextCallTime.setText(DateTimeUtil.getTimeFormatText(new Date(records.beginTime)));

        List<String> list = new ArrayList<>();
        if (records.inviteList != null) {
            list.addAll(records.inviteList);
        }
        list.add(records.inviter.trim());
        list.remove(TUILogin.getLoginUser());
        mCallIconView.setTag(list);

        V2TIMManager.getInstance().getUsersInfo(list, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> userFullInfoList) {
                if (null == userFullInfoList || userFullInfoList.isEmpty()) {
                    return;
                }

                List<Object> avatarList = new ArrayList<>();
                List<String> newUserList = new ArrayList<>();
                List<String> nameList = new ArrayList<>();
                for (int i = 0; i < userFullInfoList.size(); i++) {
                    avatarList.add(userFullInfoList.get(i).getFaceUrl());
                    newUserList.add(userFullInfoList.get(i).getUserID());
                    String name = (TextUtils.isEmpty(userFullInfoList.get(i).getNickName())) ?
                            userFullInfoList.get(i).getUserID() : userFullInfoList.get(i).getNickName();
                    nameList.add(name);
                }
                if (!TextUtils.isEmpty(records.groupId)) {
                    avatarList.add(TUILogin.getFaceUrl());
                }

                List<String> oldUserList = new ArrayList<>((List<String>) mCallIconView.getTag());
                if (oldUserList.size() == newUserList.size() && oldUserList.containsAll(newUserList)) {
                    mCallIconView.setImageId(records.callId);
                    mCallIconView.displayImage(avatarList).load(records.callId);
                    mTextUserTitle.setText(String.valueOf(nameList).replaceAll(("[\\[\\]]"), ""));
                }
            }

            @Override
            public void onError(int errorCode, String errorMsg) {
                List<Object> list = new ArrayList<>();
                list.add(TUILogin.getFaceUrl());
                mCallIconView.displayImage(list).load(records.callId);
                mTextUserTitle.setText(TUILogin.getNickName());
            }
        });
    }
}

