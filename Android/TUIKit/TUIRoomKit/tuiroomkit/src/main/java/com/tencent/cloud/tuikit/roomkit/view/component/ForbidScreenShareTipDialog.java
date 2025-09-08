package com.tencent.cloud.tuikit.roomkit.view.component;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.tencent.cloud.tuikit.roomkit.R;

public class ForbidScreenShareTipDialog extends Dialog {
    private Context mContext;

    public ForbidScreenShareTipDialog(Context context) {
        super(context, R.style.TUIRoomDialogTheme);
        mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_dialog_forbid_screen_share_tip);
        initView();
    }

    private void initView() {
        TextView mTextMessage = findViewById(R.id.dialog_message);
        Button mButtonPositive = findViewById(R.id.button_positive);
        Button mButtonNegative = findViewById(R.id.button_negative);

        mTextMessage.setText(mContext.getString(R.string.tuiroomkit_unable_to_shared_screen));
        mButtonPositive.setText(mContext.getString(R.string.tuiroomkit_contact_us));
        mButtonNegative.setText(mContext.getString(R.string.tuiroomkit_cancel));


        mButtonPositive.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    Intent browserIntent = new Intent(Intent.ACTION_VIEW,
                            Uri.parse("https://im.cloud.tencent.com/s/cWSPGIIM62CC/cFUPGIIM62CF"));
                    mContext.startActivity(browserIntent);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dismiss();
            }
        });

        mButtonNegative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
    }
} 