package com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MEETING_INFO;

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
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RoomInfoViewModel;

public class RoomInfoDialog extends BaseBottomDialog {
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

    public RoomInfoDialog(@NonNull Context context) {
        super(context);
        mViewModel = new RoomInfoViewModel(getContext(), this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_MEETING_INFO, null);
        mViewModel.destroy();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_meeting_info;
    }

    @Override
    protected void initView() {
        mTextName = findViewById(R.id.tv_info_name);
        mTextMaster = findViewById(R.id.tv_master);
        mTextRoomId = findViewById(R.id.tv_room_id);
        mTextRoomType = findViewById(R.id.tv_type);
        mRootCopyRoomLink = findViewById(R.id.tuiroomkit_root_room_link_layout);
        mTextRoomLink = findViewById(R.id.tv_room_link);
        mButtonCopyRoomId = findViewById(R.id.btn_copy_room_id);
        mButtonCopyRoomLink = findViewById(R.id.btn_copy_room_link);
        mButtonQRCode = findViewById(R.id.btn_qr_code);

        TUIRoomDefine.RoomInfo roomInfo = ConferenceController.sharedInstance().getConferenceState().roomInfo;
        mTextName.setText(roomInfo.name);
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

    public void setMasterName(String name) {
        mTextMaster.setText(name);
    }
}
