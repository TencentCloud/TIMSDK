package com.tencent.cloud.tuikit.roomkit.view.join;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceSession;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.basic.SwitchSettingItem;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.ArrayList;

public class EnterConferenceView extends RelativeLayout {

    private Context                  mContext;
    private Toolbar                  mToolbar;
    private TextView                 mTextEnterRoom;
    private TextView                 mTextUserName;
    private EditText                 mTextRoomId;
    private LinearLayout             mSettingContainer;
    private EnterConferenceViewModel mViewModel;

    private final ConferenceDefine.ConferenceObserver mConferenceObserver = new ConferenceDefine.ConferenceObserver() {
        @Override
        public void onConferenceJoined(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {
            if (error != TUICommonDefine.Error.SUCCESS) {
                mTextEnterRoom.setClickable(true);
                return;
            }
            finishActivity();
        }
    };

    public EnterConferenceView(Context context) {
        super(context);
        View.inflate(context, R.layout.tuiroomkit_view_enter_room, this);
        mContext = context;
        mViewModel = new EnterConferenceViewModel(mContext);
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceSession.sharedInstance().addObserver(mConferenceObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceSession.sharedInstance().removeObserver(mConferenceObserver);
    }

    private void initView() {
        mToolbar = findViewById(R.id.toolbar);
        mTextRoomId = findViewById(R.id.et_room_id);
        mTextEnterRoom = findViewById(R.id.tv_enter);
        mSettingContainer = findViewById(R.id.ll_setting_container);
        mTextUserName = findViewById(R.id.tv_user_name);

        mTextEnterRoom.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                String roomId = mTextRoomId.getText().toString();
                if (TextUtils.isEmpty(roomId)) {
                    RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_empty));
                    return;
                }
                mViewModel.enterRoom(roomId);
            }
        });
        mToolbar.setNavigationOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                finishActivity();
            }
        });
        mTextRoomId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                mTextEnterRoom.setEnabled(!TextUtils.isEmpty(mTextRoomId.getText().toString()));
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ArrayList<SwitchSettingItem> settingItemList = mViewModel.createSwitchSettingItemList();
        int size = settingItemList.size();
        for (int i = 0; i < size; i++) {
            SwitchSettingItem item = settingItemList.get(i);
            if (i == size - 1) {
                item.hideBottomLine();
            }
            mSettingContainer.addView(item.getView());
        }

        mTextUserName.setText(TUILogin.getNickName());
    }

    private void finishActivity() {
        if (!(mContext instanceof Activity)) {
            return;
        }
        Activity activity = (Activity) mContext;
        activity.finish();
    }
}
