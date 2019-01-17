package com.tencent.qcloud.uikit.operation.group;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.TypedValue;
import android.view.View;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.imsdk.TIMGroupAddOpt;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.common.utils.SoftKeyBoardUtil;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

/**
 * Created by valexhuang on 2018/9/4.
 */

public class GroupChatJoinActivity extends Activity {

    private SearchView mGroupSearch;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_chat_join_activity);
        mGroupSearch = findViewById(R.id.group_id_search);
        mGroupSearch.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }
        });

        int id = mGroupSearch.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        TextView textView = (TextView) mGroupSearch.findViewById(id);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
    }


    public void startSession(View view) {
        GroupChatManager.getInstance().applyJoinGroup(mGroupSearch.getQuery().toString(), "我就是测试一下", new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (data == TIMGroupAddOpt.TIM_GROUP_ADD_AUTH) {
                    UIUtils.toastLongMessage("申请入群成功，请等待管理员审批");
                } else {
                    UIUtils.toastLongMessage("加入群聊成功");
                }

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage(errCode + ":" + errMsg);
            }
        });
    }

    public void back(View view) {
        finish();
    }

    @Override
    public void finish() {
        super.finish();
        SoftKeyBoardUtil.hideKeyBoard(mGroupSearch.getWindowToken());
    }
}
