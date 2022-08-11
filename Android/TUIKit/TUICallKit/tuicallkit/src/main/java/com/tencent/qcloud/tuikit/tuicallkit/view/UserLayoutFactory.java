package com.tencent.qcloud.tuikit.tuicallkit.view;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;

import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;

import java.util.LinkedList;

public class UserLayoutFactory {
    private Context                      mContext;
    public  LinkedList<UserLayoutEntity> mLayoutEntityList = new LinkedList<>();

    public UserLayoutFactory(Context context) {
        mContext = context;
    }

    public UserLayout allocUserLayout(CallingUserModel model) {
        if (null == model || TextUtils.isEmpty(model.userId)) {
            return null;
        }
        UserLayout userLayout = findUserLayout(model.userId);
        if (null != userLayout) {
            return userLayout;
        }
        UserLayoutEntity layoutEntity = new UserLayoutEntity();
        layoutEntity.userId = model.userId;
        layoutEntity.userModel = model;
        layoutEntity.layout = new UserLayout(mContext);
        layoutEntity.layout.setVisibility(View.VISIBLE);
        mLayoutEntityList.add(layoutEntity);
        return layoutEntity.layout;
    }

    public UserLayout findUserLayout(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        for (UserLayoutEntity layoutEntity : mLayoutEntityList) {
            if (userId.equals(layoutEntity.userId)) {
                return layoutEntity.layout;
            }
        }
        return null;
    }
}
