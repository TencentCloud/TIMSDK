package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.View;
import android.widget.Button;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

import java.util.HashMap;
import java.util.Map;

public class RoomTypeSelectView extends BottomSheetDialog implements View.OnClickListener {
    private boolean    mIsFreeSpeech;
    private Button     mButtonConfirm;
    private Button     mButtonCancel;
    private RadioGroup mGroupRoomType;

    public RoomTypeSelectView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_room_type_select);
        initView();
    }

    private void initView() {
        mButtonCancel = findViewById(R.id.btn_cancel);
        mButtonConfirm = findViewById(R.id.btn_confirm);
        mGroupRoomType = findViewById(R.id.rg_room_type);

        mButtonCancel.setOnClickListener(this);
        mButtonConfirm.setOnClickListener(this);

        mGroupRoomType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                mIsFreeSpeech = checkedId == R.id.rb_free_speech;
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_cancel) {
            dismiss();
        } else if (v.getId() == R.id.btn_confirm) {
            Map<String, Object> params = new HashMap<>();
            params.put(RoomEventConstant.KEY_IS_FREE_SPEECH,
                    mIsFreeSpeech ? TUIRoomDefine.SpeechMode.FREE_TO_SPEAK
                            : TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT);
            RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.ROOM_TYPE_CHANGE, params);
            dismiss();
        }
    }

}
