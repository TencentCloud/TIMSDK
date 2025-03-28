package com.tencent.cloud.tuikit.roomkit.view.schedule.timezone;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;

public class TimeZoneActivity extends AppCompatActivity implements View.OnClickListener {
    private static final String          TIME_ZONE_ID = "TIME_ZONE_ID";
    private              RecyclerView    mRvTimeZone;
    private              ImageView       mCloseTimeZone;
    private              TimeZoneAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_view_time_zone);
        initView();
    }

    private void initView() {
        String timeZoneId = getIntent().getStringExtra(TIME_ZONE_ID);
        mRvTimeZone = findViewById(R.id.rv_time_zone_list);
        mRvTimeZone.setLayoutManager(new LinearLayoutManager(this));
        mAdapter = new TimeZoneAdapter(this, timeZoneId);
        mAdapter.setOnItemClickListener(new TimeZoneAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(String id) {
                Intent dataIntent = new Intent();
                dataIntent.putExtra(TIME_ZONE_ID, id);
                setResult(Activity.RESULT_OK, dataIntent);
                finish();
            }
        });
        mRvTimeZone.setAdapter(mAdapter);
        mRvTimeZone.scrollToPosition(mAdapter.mSelectItemPosition);
        mCloseTimeZone = findViewById(R.id.img_time_zone_arrows_return);
        mCloseTimeZone.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.img_time_zone_arrows_return) {
            setResult(Activity.RESULT_CANCELED);
            finish();
        }
    }

}
