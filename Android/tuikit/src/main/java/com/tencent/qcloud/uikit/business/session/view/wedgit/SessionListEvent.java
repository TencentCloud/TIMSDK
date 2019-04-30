package com.tencent.qcloud.uikit.business.session.view.wedgit;

import android.view.View;

import com.tencent.qcloud.uikit.business.session.model.SessionInfo;


public interface SessionListEvent {

    /**
     * Session列表长按事件
     *
     * @param v        被点击的View
     * @param position 在sessionList中的位置
     * @param session  具体的SessionInfo对象
     */
    void onSessionLongClick(View v, int position, SessionInfo session);


    /**
     * Session列表左滑事件
     *
     * @param v        被点击的View
     * @param position 在sessionList中的位置
     * @param session  具体的SessionInfo对象
     */
    void onSessionLeftSlide(View v, int position, SessionInfo session);
}
