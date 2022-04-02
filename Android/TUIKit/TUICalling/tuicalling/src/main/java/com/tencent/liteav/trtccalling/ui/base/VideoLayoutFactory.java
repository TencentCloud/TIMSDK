package com.tencent.liteav.trtccalling.ui.base;

import android.content.Context;
import android.view.View;

import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;

import java.util.Iterator;
import java.util.LinkedList;

public class VideoLayoutFactory {
    private final Context                      mContext;
    public        LinkedList<TRTCLayoutEntity> mLayoutEntityList;

    public VideoLayoutFactory(Context context) {
        mContext = context;
        mLayoutEntityList = new LinkedList<>();
    }

    /**
     * 根据 userId 找到已经分配的 View
     *
     * @param userId
     * @return
     */
    public TRTCVideoLayout findUserLayout(String userId) {
        if (userId == null) return null;
        for (TRTCLayoutEntity layoutEntity : mLayoutEntityList) {
            if (layoutEntity.userId.equals(userId)) {
                return layoutEntity.layout;
            }
        }
        return null;
    }

    /**
     * 根据 userId 分配对应的 view
     *
     * @param userId
     * @return
     */
    public TRTCVideoLayout allocUserLayout(String userId, TRTCVideoLayout layout) {
        if (userId == null) return null;
        TRTCLayoutEntity layoutEntity = new TRTCLayoutEntity();
        layoutEntity.userId = userId;
        layoutEntity.layout = layout;
        layoutEntity.layout.setVisibility(View.VISIBLE);
        mLayoutEntityList.add(layoutEntity);
        return layoutEntity.layout;
    }

    /**
     * 根据 userId 和 视频类型，回收对应的 view
     *
     * @param userId
     */
    public void recyclerCloudViewView(String userId) {
        if (userId == null) return;
        Iterator iterator = mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            TRTCLayoutEntity item = (TRTCLayoutEntity) iterator.next();
            if (item.userId.equals(userId)) {
                iterator.remove();
                break;
            }
        }
    }
}
