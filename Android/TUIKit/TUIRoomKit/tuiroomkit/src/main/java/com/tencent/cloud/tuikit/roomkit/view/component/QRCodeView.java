package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.QRCodeViewModel;

public class QRCodeView extends BaseBottomDialog implements View.OnClickListener {
    private static final int QRCODE_WIDTH  = 480;
    private static final int QRCODE_HEIGHT = 480;

    private String          mRoomURL;
    private Bitmap          mBitmap;
    private Toolbar         mToolbar;
    private Button          mButtonSave;
    private TextView        mTextRoomName;
    private TextView        mTextRoomId;
    private ImageView       mImageQRCode;
    private ImageButton     mButtonCopyRoomId;
    private RoomInfo        mRoomInfo;
    private QRCodeViewModel mViewModel;

    public QRCodeView(Context context, String url) {
        super(context);
        mRoomURL = url;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_qr_code;
    }

    @Override
    protected void intiView() {
        mViewModel = new QRCodeViewModel(getContext());
        mRoomInfo = mViewModel.getRoomInfo();
        mToolbar = findViewById(R.id.toolbar_qr_code_view);
        mButtonSave = findViewById(R.id.btn_save);
        mTextRoomName = findViewById(R.id.tv_room_name);
        mTextRoomId = findViewById(R.id.tv_room_id);
        mImageQRCode = findViewById(R.id.img_qr_code);
        mButtonCopyRoomId = findViewById(R.id.btn_copy_room_id);

        mToolbar.setOnClickListener(this);
        mButtonSave.setOnClickListener(this);
        mButtonCopyRoomId.setOnClickListener(this);

        mTextRoomName.setText(mRoomInfo.name);
        mTextRoomId.setText(mRoomInfo.roomId);

        mBitmap = CommonUtils.createQRCodeBitmap(mRoomURL, QRCODE_WIDTH, QRCODE_HEIGHT);
        mImageQRCode.setImageBitmap(mBitmap);
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        updateHeightToMatchParent();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.toolbar_qr_code_view) {
            dismiss();
        } else if (v.getId() == R.id.btn_save) {
            mViewModel.saveQRCodeToAlbum(mBitmap);
        } else if (v.getId() == R.id.btn_copy_room_id) {
            mViewModel.copyContentToClipboard(mTextRoomId.getText().toString(),
                    getContext().getString(R.string.tuiroomkit_copy_room_id_success));
        }
    }
}
