package com.tencent.qcloud.uikit.operation.c2c;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.TypedValue;
import android.view.View;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatInfo;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.model.SessionManager;
import com.tencent.qcloud.uikit.business.session.view.SessionPanel;
import com.tencent.qcloud.uikit.common.utils.SoftKeyBoardUtil;
import com.tencent.qcloud.uikit.operation.message.UIKitRequest;
import com.tencent.qcloud.uikit.operation.message.UIKitRequestDispatcher;

/**
 * Created by valexhuang on 2018/9/4.
 */

public class C2CChatStartActivity extends Activity {

    private SearchView mUserSearch;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.session_c2c_search_activity);
        mUserSearch = findViewById(R.id.c2c_user_search);
        mUserSearch.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }
        });

        int id = mUserSearch.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        TextView textView = (TextView) mUserSearch.findViewById(id);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
    }


    public void startSession(View view) {
        C2CChatInfo chatInfo = new C2CChatInfo();
        chatInfo.setPeer(mUserSearch.getQuery().toString());
        chatInfo.setChatName(mUserSearch.getQuery().toString());
        C2CChatManager.getInstance().addChatInfo(chatInfo);

        SessionInfo sessionInfo = new SessionInfo();
        sessionInfo.setPeer(chatInfo.getPeer());
        sessionInfo.setTitle(chatInfo.getPeer());
        //SessionManager.getInstance().addSession(sessionInfo);
        UIKitRequest request = new UIKitRequest();
        request.setModel(UIKitRequestDispatcher.MODEL_SESSION);
        request.setAction(UIKitRequestDispatcher.SESSION_ACTION_START_CHAT);
        request.setRequest(sessionInfo);
        UIKitRequestDispatcher.getInstance().dispatchRequest(request);
        finish();
    }


    @Override
    public void finish() {
        super.finish();
        SoftKeyBoardUtil.hideKeyBoard(mUserSearch.getWindowToken());
    }

    public void back(View view) {
        finish();
    }
}
