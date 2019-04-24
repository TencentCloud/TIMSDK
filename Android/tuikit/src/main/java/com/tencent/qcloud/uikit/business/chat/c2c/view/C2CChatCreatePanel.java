package com.tencent.qcloud.uikit.business.chat.c2c.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatInfo;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.model.SessionManager;

public class C2CChatCreatePanel extends LinearLayout {

    private SearchView mUserSearch;

    public C2CChatCreatePanel(Context context) {
        super(context);
    }

    public C2CChatCreatePanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public C2CChatCreatePanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    private void init() {

        inflate(getContext(), R.layout.c2c_chat_create_panel, this);
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
        findViewById(R.id.c2c_chat_start).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                startSession(view);
            }
        });

    }


    public void startSession(View view) {
        C2CChatInfo chatInfo = new C2CChatInfo();
        chatInfo.setPeer(mUserSearch.getQuery().toString());
        chatInfo.setChatName(mUserSearch.getQuery().toString());
        C2CChatManager.getInstance().addChatInfo(chatInfo);

        SessionInfo sessionInfo = new SessionInfo();
        sessionInfo.setPeer(chatInfo.getPeer());
        sessionInfo.setTitle(chatInfo.getPeer());
        SessionManager.getInstance().addSession(sessionInfo);

        //TUIKit.getBaseConfigs().chatProcessor.startC2CChat(getContext(), chatInfo.getPeer());
    }

}
