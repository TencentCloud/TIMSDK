package com.tencent.qcloud.uikit.business.session.presenter;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.model.SessionManager;
import com.tencent.qcloud.uikit.business.session.model.SessionProvider;
import com.tencent.qcloud.uikit.business.session.view.SessionPanel;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

public class SessionPresenter implements SessionManager.SessionStartChat {

    private SessionPanel mSessionPanel;
    private SessionManager mManager;


    public SessionPresenter(SessionPanel sessionPanel) {
        this.mSessionPanel = sessionPanel;
        mManager = SessionManager.getInstance();
        mManager.addStartChat(this);
    }

    /**
     * 加载会话数据
     */
    public void loadSessionData() {
        mManager.loadSession(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                mSessionPanel.getSessionAdapter().setDataProvider((SessionProvider) data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage("加载消息失败");
            }
        });
    }

    /**
     * 置顶会话
     *
     * @param index       所在会话列表的索引
     * @param sessionInfo 会话数据对象
     */
    public void setSessionTop(int index, SessionInfo sessionInfo) {
        mManager.setSessionTop(index, sessionInfo);
    }

    /**
     * 删除会话
     *
     * @param index       所在会话列表的索引
     * @param sessionInfo 会话数据对象
     */
    public void deleteSession(int index, SessionInfo sessionInfo) {
        mManager.deleteSession(index, sessionInfo);
    }

    @Override
    public void startChat(SessionInfo sessionInfo) {
        mSessionPanel.startChat(sessionInfo);
    }
}
