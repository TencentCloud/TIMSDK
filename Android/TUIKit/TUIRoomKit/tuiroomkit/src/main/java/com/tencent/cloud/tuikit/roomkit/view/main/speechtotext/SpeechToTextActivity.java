package com.tencent.cloud.tuikit.roomkit.view.main.speechtotext;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;

public class SpeechToTextActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_speech_to_text);
        findViewById(R.id.tuiroomkit_speech_to_text_back).setOnClickListener(v -> finish());
    }
}
