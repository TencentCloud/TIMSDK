package com.tencent.qcloud.tuikit.tuicontact.ui.pages;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputFilter;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;

import java.util.ArrayList;

public class SelectionActivity extends Activity {

    private static OnResultReturnListener sOnResultReturnListener;

    private RadioGroup radioGroup;
    private EditText input;
    private int mSelectionType;

    public static void startTextSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        bundle.putInt(TUIContactConstants.Selection.TYPE, TUIContactConstants.Selection.TYPE_TEXT);
        startSelection(context, bundle, listener);
    }

    public static void startListSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        bundle.putInt(TUIContactConstants.Selection.TYPE, TUIContactConstants.Selection.TYPE_LIST);
        startSelection(context, bundle, listener);
    }

    private static void startSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        Intent intent = new Intent(context, SelectionActivity.class);
        intent.putExtra(TUIContactConstants.Selection.CONTENT, bundle);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        sOnResultReturnListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_selection_activity);
        final TitleBarLayout titleBar = findViewById(R.id.edit_title_bar);
        radioGroup = findViewById(R.id.content_list_rg);
        input = findViewById(R.id.edit_content_et);

        Bundle bundle = getIntent().getBundleExtra(TUIContactConstants.Selection.CONTENT);
        switch (bundle.getInt(TUIContactConstants.Selection.TYPE)) {
            case TUIContactConstants.Selection.TYPE_TEXT:
                radioGroup.setVisibility(View.GONE);
                String defaultString = bundle.getString(TUIContactConstants.Selection.INIT_CONTENT);
                int limit = bundle.getInt(TUIContactConstants.Selection.LIMIT);
                if (!TextUtils.isEmpty(defaultString)) {
                    input.setText(defaultString);
                    input.setSelection(defaultString.length());
                }
                if (limit > 0) {
                    input.setFilters(new InputFilter[]{new InputFilter.LengthFilter(limit)});
                }
                break;
            case TUIContactConstants.Selection.TYPE_LIST:
                input.setVisibility(View.GONE);
                ArrayList<String> list = bundle.getStringArrayList(TUIContactConstants.Selection.LIST);
                if (list == null || list.size() == 0) {
                    return;
                }
                for (int i = 0; i < list.size(); i++) {
                    RadioButton radioButton = new RadioButton(this);
                    radioButton.setText(list.get(i));
                    radioButton.setId(i);
                    radioGroup.addView(radioButton, i, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                }
                int checked = bundle.getInt(TUIContactConstants.Selection.DEFAULT_SELECT_ITEM_INDEX);
                radioGroup.check(checked);
                radioGroup.invalidate();
                break;
            default:
                finish();
                return;
        }
        mSelectionType = bundle.getInt(TUIContactConstants.Selection.TYPE);

        final String title = bundle.getString(TUIContactConstants.Selection.TITLE);
        titleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
        titleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        titleBar.getRightIcon().setVisibility(View.GONE);
        titleBar.getRightTitle().setText(getResources().getString(R.string.sure));
        titleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                echoClick(title);
            }
        });
    }

    private void echoClick(String title) {
        switch (mSelectionType) {
            case TUIContactConstants.Selection.TYPE_TEXT:
                if (TextUtils.isEmpty(input.getText().toString()) && title.equals(getResources().getString(R.string.modify_group_name))) {
                    ToastUtil.toastLongMessage(getString(R.string.input_tip));
                    return;
                }

                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(input.getText().toString());
                }
                break;
            case TUIContactConstants.Selection.TYPE_LIST:
                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(radioGroup.getCheckedRadioButtonId());
                }
                break;
        }
        finish();
    }

    @Override
    protected void onStop() {
        super.onStop();
        sOnResultReturnListener = null;
    }

    public interface OnResultReturnListener {
        void onReturn(Object res);
    }
}
