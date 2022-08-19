package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuikit.tuicommunity.R;

public class CommunityExperienceView extends FrameLayout {
    private TextView experienceName;
    private TextView experienceState;

    public CommunityExperienceView(Context context) {
        super(context);
        init(context, null);
    }

    public CommunityExperienceView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public CommunityExperienceView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public CommunityExperienceView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        View view = LayoutInflater.from(context).inflate(R.layout.community_experience_layout, this);
        experienceName = view.findViewById(R.id.experience_name);
        experienceState = view.findViewById(R.id.experience_state);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CommunityExperienceView);
        String contentText = typedArray.getString(R.styleable.CommunityExperienceView_content_text);
        experienceName.setText(contentText);
        typedArray.recycle();
    }

    public void setExperience(String experience) {
        experienceName.setText(experience);
    }

    public void setState(boolean isExperienced) {
        if (isExperienced) {
            experienceState.setText(R.string.community_completed);
            experienceState.setEnabled(false);
        }
    }
}
