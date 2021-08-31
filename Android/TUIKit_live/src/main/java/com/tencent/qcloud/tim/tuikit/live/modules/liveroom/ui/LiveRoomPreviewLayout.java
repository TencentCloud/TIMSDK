package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RadioButton;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.trtc.TRTCCloudDef;

import static android.content.Context.INPUT_METHOD_SERVICE;

/**
 * 预览页的Layout
 */
public class LiveRoomPreviewLayout extends ConstraintLayout {
    private EditText mEditLiveRoomName;
    private RadioButton mRbLiveRoomQualityNormal;
    private RadioButton mRbLiveRoomQualityMusic;
    private PreviewCallback mPreviewCallback;
    private ImageButton mButtonBeauty;
    private Button mButtonStartRoom;

    public LiveRoomPreviewLayout(Context context) {
        this(context, null);
        initView(context);
    }

    public LiveRoomPreviewLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    public LiveRoomPreviewLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        inflate(context, R.layout.live_layout_live_room_preview, this);
        mEditLiveRoomName = findViewById(R.id.et_live_room_name);
        mRbLiveRoomQualityNormal = findViewById(R.id.rb_live_room_quality_normal);
        mRbLiveRoomQualityMusic = findViewById(R.id.rb_live_room_quality_music);
        mButtonBeauty = findViewById(R.id.btn_beauty);
        mButtonBeauty.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPreviewCallback != null) {
                    mPreviewCallback.onBeautyPanel();
                }
            }
        });
        mButtonStartRoom = findViewById(R.id.btn_start_room);
        mButtonStartRoom.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                String roomName = mEditLiveRoomName.getText().toString().trim();
                if (TextUtils.isEmpty(roomName)) {
                    Toast.makeText(TUIKitLive.getAppContext(), R.string.live_room_name_empty, Toast.LENGTH_SHORT).show();
                    return;
                }
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(mEditLiveRoomName.getWindowToken(), 0);
                int audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
                if (mRbLiveRoomQualityNormal.isChecked()) {
                    audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
                } else if (mRbLiveRoomQualityMusic.isChecked()) {
                    audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
                }
                if (mPreviewCallback != null) {
                    mPreviewCallback.onStartLive(roomName, audioQuality);
                }
            }
        });
        findViewById(R.id.btn_switch_cam).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPreviewCallback != null) {
                    mPreviewCallback.onSwitchCamera();
                }
            }
        });
        findViewById(R.id.btn_close_before_live).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPreviewCallback != null) {
                    mPreviewCallback.onClose();
                }
            }
        });
    }

    public void setPreviewCallback(PreviewCallback previewCallback) {
        mPreviewCallback = previewCallback;
    }

    public void setBottomViewVisibility(int visibility) {
        mButtonBeauty.setVisibility(visibility);
        mButtonStartRoom.setVisibility(visibility);
    }

    public interface PreviewCallback {
        void onClose();

        void onBeautyPanel();

        void onSwitchCamera();

        void onStartLive(String roomName, int audioQualityType);
    }
}
