package com.tencent.qcloud.tuikit.tuigroup.component;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.tuigroup.R;
import java.util.ArrayList;
import java.util.List;

public class BottomSelectSheet {
    private List<String> selectList = new ArrayList<>();
    private Dialog dialog;
    private ArrayAdapter<String> listAdapter;
    private BottomSelectSheetOnClickListener onClickListener;

    public BottomSelectSheet(Context context) {
        View view = View.inflate(context, R.layout.bottom_select_sheet, null);
        dialog = new Dialog(context, R.style.BottomSelectSheet);
        dialog.setContentView(view);
        dialog.setCancelable(true);
        dialog.setCanceledOnTouchOutside(true);
        Window window = dialog.getWindow();
        window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        WindowManager m = window.getWindowManager();
        Display d = m.getDefaultDisplay();
        WindowManager.LayoutParams p = window.getAttributes();
        p.width = d.getWidth();
        p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        window.setAttributes(p);
        window.setGravity(Gravity.BOTTOM);
        window.setWindowAnimations(R.style.BottomSelectSheet_Anim); // 添加动画

        final ListView listView = view.findViewById(R.id.item_list);
        listAdapter = new ArrayAdapter<>(context, R.layout.bottom_sheet_item, R.id.sheet_item, selectList);
        listView.setAdapter(listAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                dismiss();
                if (onClickListener != null) {
                    onClickListener.onSheetClick(position);
                }
            }
        });

        TextView cancelButton = view.findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
    }

    public void dismiss() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    public void show() {
        if (dialog != null && !dialog.isShowing()) {
            listAdapter.notifyDataSetChanged();
            dialog.show();
        }
    }

    public void setSelectList(List<String> selectList) {
        this.selectList.clear();
        this.selectList.addAll(selectList);
    }

    public void setOnClickListener(BottomSelectSheetOnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    public interface BottomSelectSheetOnClickListener {
        void onSheetClick(int index);
    }
}
