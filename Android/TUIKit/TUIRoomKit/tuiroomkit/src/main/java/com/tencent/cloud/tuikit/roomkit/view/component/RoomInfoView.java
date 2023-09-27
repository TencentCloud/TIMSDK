package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RoomInfoViewModel;

public class RoomInfoView extends BaseBottomDialog {
    private TextView          mTextName;
    private TextView          mTextMaster;
    private TextView          mTextRoomId;
    private TextView          mTextRoomType;
    private TextView          mTextRoomLink;
    private LinearLayout      mButtonCopyRoomId;
    private LinearLayout      mButtonCopyRoomLink;
    private RelativeLayout    mRootCopyRoomLink;
    private ImageButton       mButtonQRCode;
    private RoomInfoViewModel mViewModel;

    public RoomInfoView(@NonNull Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_meeting_info;
    }

    @Override
    protected void initView() {
        mViewModel = new RoomInfoViewModel(getContext(), this);
        mTextName = findViewById(R.id.tv_info_name);
        mTextMaster = findViewById(R.id.tv_master);
        mTextRoomId = findViewById(R.id.tv_room_id);
        mTextRoomType = findViewById(R.id.tv_type);
        mRootCopyRoomLink = findViewById(R.id.tuiroomkit_root_room_link_layout);
        mTextRoomLink = findViewById(R.id.tv_room_link);
        mButtonCopyRoomId = findViewById(R.id.btn_copy_room_id);
        mButtonCopyRoomLink = findViewById(R.id.btn_copy_room_link);
        mButtonQRCode = findViewById(R.id.btn_qr_code);

        TUIRoomDefine.RoomInfo roomInfo = RoomEngineManager.sharedInstance().getRoomStore().roomInfo;
        mTextName.setText(TextUtils.isEmpty(roomInfo.name) ? roomInfo.roomId :
                roomInfo.name + getContext().getString(R.string.tuiroomkit_meeting_title));
        mViewModel.setMasterName();
        mTextRoomType.setText(mViewModel.getRoomType());
        mTextRoomId.setText(roomInfo.roomId);
        mTextRoomLink.setText(mViewModel.getRoomURL());
        mRootCopyRoomLink.setVisibility(mViewModel.needShowRoomLink() ? View.VISIBLE : View.GONE);

        mButtonCopyRoomId.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.copyContentToClipboard(mTextRoomId.getText().toString(),
                        getContext().getString(R.string.tuiroomkit_copy_room_id_success));
            }
        });

        mButtonQRCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.showQRCodeView();
                dismiss();
            }
        });

        mButtonCopyRoomLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.copyContentToClipboard(mTextRoomLink.getText().toString(),
                        getContext().getString(R.string.tuiroomkit_copy_room_line_success));
            }
        });
    }

    @Override
    public void onDetachedFromWindow() {
        mViewModel.destroy();
        super.onDetachedFromWindow();
    }

    public void setMasterName(String name) {
        mTextMaster.setText(name);
    }
}
