package com.tencent.cloud.tuikit.roomkit.view.create;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;

public class CreateConferenceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_create_room);
        CreateConferenceView createRoomView = new CreateConferenceView(this);
        ViewGroup root = findViewById(R.id.ll_root_create_room);
        root.addView(createRoomView);
        createRoomView.setFinishCallback(new TUICallback() {
            @Override
            public void onSuccess() {
                finish();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {

            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
