package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

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
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupManagerPresenter;

public class GroupNoticeActivity extends BaseLightActivity {
    private static OnGroupNoticeChangedListener changedListener;

    private EditText editText;

    private GroupInfo groupInfo;

    private TitleBarLayout titleBarLayout;

    private boolean isEditModel = false;

    private GroupManagerPresenter presenter;

    public static void setOnGroupNoticeChangedListener(OnGroupNoticeChangedListener listener) {
        GroupNoticeActivity.changedListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_notice);
        editText = findViewById(R.id.group_notice_text);
        titleBarLayout = findViewById(R.id.group_notice_title_bar);
        groupInfo = (GroupInfo) getIntent().getSerializableExtra(TUIGroupConstants.Group.GROUP_INFO);
        presenter = new GroupManagerPresenter();
        if (!TextUtils.isEmpty(groupInfo.getNotice())) {
            editText.setText(groupInfo.getNotice());
        }
        titleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        titleBarLayout.setTitle(getString(R.string.group_notice), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);

        if (groupInfo.isCanManagerGroup()) {
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
                    editText.setFocusableInTouchMode(true);
                    showSoftInput();
                    editText.setSelection(editText.getText().toString().length());
                    isEditModel = true;
                } else {
                    titleBarLayout.setTitle(getString(R.string.group_edit), ITitleBarLayout.Position.RIGHT);
                    editText.setInputType(EditorInfo.TYPE_NULL);
                    editText.setClickable(false);
                    editText.setFocusable(false);
                    editText.setFocusableInTouchMode(false);
                    hideSoftInput();
                    setGroupNotice(editText.getText().toString());
                    isEditModel = false;
                }
            }
        });
    }

    private void setGroupNotice(String groupNotice) {
        if (TextUtils.equals(groupNotice, groupInfo.getNotice())) {
            return;
        }
        presenter.modifyGroupNotification(groupInfo.getId(), groupNotice, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                groupInfo.setNotice(groupNotice);
                if (changedListener != null) {
                    changedListener.onChanged(groupNotice);
                }
                ToastUtil.toastShortMessage(getResources().getString(R.string.modify_group_notice_success));
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("modifyGroupNotice error , errCode " + errCode + " errMsg " + errMsg);
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

    // 兼容有导航键的情况
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

    public interface OnGroupNoticeChangedListener {
        void onChanged(String notice);
    }
}