package com.tencent.cloud.tuikit.roomkit.view.join;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;

public class EnterConferenceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_enter_room);
        EnterConferenceView enterRoomView = new EnterConferenceView(this);
        ViewGroup root = findViewById(R.id.ll_root_enter_room);
        root.addView(enterRoomView);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
