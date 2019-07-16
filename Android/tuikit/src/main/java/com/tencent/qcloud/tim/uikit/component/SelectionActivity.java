package com.tencent.qcloud.tim.uikit.component;

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

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;

public class SelectionActivity extends Activity {

    private static OnResultReturnListener sOnResultReturnListener;

    private RadioGroup radioGroup;
    private EditText input;
    private int mSelectionType;

    public static void startTextSelection(Context context, Bundle bundle, OnResultReturnListener listener){
        bundle.putInt(TUIKitConstants.Selection.TYPE, TUIKitConstants.Selection.TYPE_TEXT);
        startSelection( context, bundle, listener);
    }

    public static void startListSelection(Context context, Bundle bundle, OnResultReturnListener listener){
        bundle.putInt(TUIKitConstants.Selection.TYPE, TUIKitConstants.Selection.TYPE_LIST);
        startSelection( context, bundle, listener);
    }

    private static void startSelection(Context context, Bundle bundle, OnResultReturnListener listener){
        Intent intent = new Intent(context, SelectionActivity.class);
        intent.putExtra(TUIKitConstants.Selection.CONTENT, bundle);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        sOnResultReturnListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.selection_activity);
        final TitleBarLayout titleBar = findViewById(R.id.edit_title_bar);
        radioGroup = findViewById(R.id.content_list_rg);
        input = findViewById(R.id.edit_content_et);

        Bundle bundle = getIntent().getBundleExtra(TUIKitConstants.Selection.CONTENT);
        switch (bundle.getInt(TUIKitConstants.Selection.TYPE)) {
            case TUIKitConstants.Selection.TYPE_TEXT:
                radioGroup.setVisibility(View.GONE);
                String defaultString = bundle.getString(TUIKitConstants.Selection.INIT_CONTENT);
                int limit = bundle.getInt(TUIKitConstants.Selection.LIMIT);
                if (!TextUtils.isEmpty(defaultString)){
                    input.setText(defaultString);
                    input.setSelection(defaultString.length());
                }
                if (limit > 0){
                    input.setFilters( new InputFilter[] { new InputFilter.LengthFilter(limit) } );
                }
                break;
            case TUIKitConstants.Selection.TYPE_LIST:
                input.setVisibility(View.GONE);
                ArrayList<String> list = bundle.getStringArrayList(TUIKitConstants.Selection.LIST);
                if (list == null || list.size() == 0) {
                    return;
                }
                for (int i = 0; i < list.size(); i++) {
                    RadioButton radioButton = new RadioButton(this);
                    radioButton.setText(list.get(i));
                    radioButton.setId(i);
                    radioGroup.addView(radioButton, i, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                }
                int checked = bundle.getInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX);
                radioGroup.check(checked);
                radioGroup.invalidate();
                break;
            default:
                finish();
                return;
        }
        mSelectionType = bundle.getInt(TUIKitConstants.Selection.TYPE);

        final String title = bundle.getString(TUIKitConstants.Selection.TITLE);
        titleBar.setTitle(title, TitleBarLayout.POSITION.MIDDLE);
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
            case TUIKitConstants.Selection.TYPE_TEXT:
                if (TextUtils.isEmpty(input.getText().toString()) && title.equals(getResources().getString(R.string.modify_group_name))) {
                    ToastUtil.toastLongMessage("没有输入昵称，请重新填写");
                    return;
                }

                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(input.getText().toString());
                }
                break;
            case TUIKitConstants.Selection.TYPE_LIST:
                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(radioGroup.getCheckedRadioButtonId());
                }
                break;
        }
        finish();
    }

    @Override
    protected void onStop(){
        super.onStop();
        sOnResultReturnListener = null;
    }

    public interface OnResultReturnListener {
        void onReturn(Object res);
    }
}
