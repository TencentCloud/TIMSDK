package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupProfilePresenter;

public class GroupNoticeMinimalistActivity extends BaseMinimalistLightActivity {

    private EditText editText;

    private GroupProfileBean profileBean;

    private TitleBarLayout titleBarLayout;

    private boolean isEditModel = false;

    private GroupProfilePresenter presenter = new GroupProfilePresenter();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_minimalist_notice);
        editText = findViewById(R.id.group_notice_text);
        titleBarLayout = findViewById(R.id.group_notice_title_bar);
        profileBean = (GroupProfileBean) getIntent().getSerializableExtra(TUIChatConstants.Group.GROUP_INFO);
        if (!TextUtils.isEmpty(profileBean.getNotification())) {
            editText.setText(profileBean.getNotification());
        }
        editText.setEnabled(false);
        titleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        titleBarLayout.setTitle(getString(R.string.group_notice), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);

        if (profileBean.canManage()) {
            titleBarLayout.setTitle(getString(R.string.group_edit), ITitleBarLayout.Position.RIGHT);
        }
        titleBarLayout.getRightGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isEditModel) {
                    titleBarLayout.setTitle(getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
                    editText.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                    editText.setClickable(true);
                    editText.setFocusable(true);
                    editText.setEnabled(true);
                    editText.setFocusableInTouchMode(true);
                    showSoftInput();
                    editText.setSelection(editText.getText().toString().length());
                    isEditModel = true;
                } else {
                    titleBarLayout.setTitle(getString(R.string.group_edit), ITitleBarLayout.Position.RIGHT);
                    editText.setInputType(EditorInfo.TYPE_NULL);
                    editText.setClickable(false);
                    editText.setFocusable(false);
                    editText.setEnabled(false);
                    editText.setFocusableInTouchMode(false);
                    hideSoftInput();
                    setGroupNotice(editText.getText().toString());
                    isEditModel = false;
                }
            }
        });
    }

    private void setGroupNotice(String groupNotice) {
        if (TextUtils.equals(groupNotice, profileBean.getNotification())) {
            return;
        }
        presenter.modifyGroupNotification(profileBean.getGroupID(), groupNotice, new TUICallback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int errorCode, String errorMessage) {

            }
        });

    }

    private void showSoftInput() {
        editText.requestFocus();
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (!isSoftInputShown()) {
            imm.toggleSoftInput(0, 0);
        }
    }

    public void hideSoftInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
        editText.clearFocus();
    }

    private boolean isSoftInputShown() {
        View decorView = getWindow().getDecorView();
        int screenHeight = decorView.getHeight();
        Rect rect = new Rect();
        decorView.getWindowVisibleDisplayFrame(rect);
        return screenHeight - rect.bottom - getNavigateBarHeight() >= 0;
    }

    
    private int getNavigateBarHeight() {
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager windowManager = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        windowManager.getDefaultDisplay().getMetrics(metrics);
        int usableHeight = metrics.heightPixels;
        windowManager.getDefaultDisplay().getRealMetrics(metrics);
        int realHeight = metrics.heightPixels;
        if (realHeight > usableHeight) {
            return realHeight - usableHeight;
        } else {
            return 0;
        }
    }

}