package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.inputmore;

import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;

import java.util.ArrayList;
import java.util.List;

public class InputMoreDialogFragment extends DialogFragment {
    public static final int REQUEST_CODE_FILE = 1011;
    public static final int REQUEST_CODE_PHOTO = 1012;
    private IUIKitCallback mCallback;
    private InputView.OnMoreActionsClickLisener mMoreActionsListener;
    private Dialog moreDialog;
    private List<InputMoreActionUnit> mInputMoreList = new ArrayList<>();
    private RecyclerView mInputActionView;
    private SelectAdapter mAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.minimalist_input_more, container, false);
        mInputActionView = view.findViewById(R.id.input_extra_area);
        TextView cancelView = view.findViewById(R.id.cancel_button);
        moreDialog = getDialog();

        mAdapter = new SelectAdapter();
        mInputActionView.setAdapter(mAdapter);
        mInputActionView.setLayoutManager(new CustomLinearLayoutManager(getContext()));

        cancelView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (moreDialog != null) {
                    moreDialog.dismiss();
                }
            }
        });

        if (moreDialog != null) {
            Window win = moreDialog.getWindow();
            WindowManager.LayoutParams lp = win.getAttributes();
            lp.width = lp.width - ScreenUtil.getPxByDp(16f);
            lp.y = ScreenUtil.getPxByDp(34f);
            moreDialog.getWindow().setBackgroundDrawable(new ColorDrawable());
            win.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
            win.setAttributes(lp);
            moreDialog.setOnKeyListener(new DialogInterface.OnKeyListener() {
                @Override
                public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                    if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
                        moreDialog.dismiss();
                    }
                    return false;
                }
            });
        }
        return view;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public void setMoreActionsListener(InputView.OnMoreActionsClickLisener mMoreActionsListener) {
        this.mMoreActionsListener = mMoreActionsListener;
    }

    public void setActions(List<InputMoreActionUnit> actions) {
        this.mInputMoreList = actions;
    }

    public void setCallback(IUIKitCallback callback) {
        mCallback = callback;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FILE
                || requestCode == REQUEST_CODE_PHOTO) {
            if (resultCode != -1) {
                if (moreDialog != null) {
                    moreDialog.dismiss();
                }
                return;
            }
            Uri uri = data.getData();
            if (mCallback != null) {
                mCallback.onSuccess(uri);
            }

            if (moreDialog != null) {
                moreDialog.dismiss();
            }
        }
    }

    class SelectAdapter extends RecyclerView.Adapter<SelectAdapter.SelectViewHolder> {

        @NonNull
        @Override
        public SelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.minimalist_input_more_item,parent, false);
            return new SelectAdapter.SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull SelectAdapter.SelectViewHolder holder, int position) {
            InputMoreActionUnit actionUnit = mInputMoreList.get(position);
            if (actionUnit.getTitleId() > 0) {
                holder.itemText.setText(getContext().getString(actionUnit.getTitleId()));
            }
            if (actionUnit.getIconResId() > 0) {
                holder.itemImage.setImageResource(actionUnit.getIconResId());
            }
            holder.itemLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    actionUnit.getOnClickListener().onClick();
                    if (actionUnit.getActionType() == 0) {
                        if (moreDialog != null) {
                            moreDialog.dismiss();
                        }
                    }
                }
            });
            if (position == mInputMoreList.size() - 1) {
                holder.itemLine.setVisibility(View.GONE);
            }
        }

        @Override
        public int getItemCount() {
            return mInputMoreList.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder {
            RelativeLayout itemLayout;
            TextView itemText;
            ImageView itemImage;
            TextView itemLine;
            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                itemLayout = itemView.findViewById(R.id.item_layout);
                itemText = itemView.findViewById(R.id.item_text);
                itemImage = itemView.findViewById(R.id.item_icon);
                itemLine = itemView.findViewById(R.id.divide_line);
            }
        }
    }
}
