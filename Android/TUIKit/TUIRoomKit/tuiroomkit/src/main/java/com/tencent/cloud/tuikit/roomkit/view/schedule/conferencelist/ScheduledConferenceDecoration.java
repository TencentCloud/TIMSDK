package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist;

import android.graphics.Canvas;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;

public class ScheduledConferenceDecoration extends RecyclerView.ItemDecoration {

    @Override
    public void onDrawOver(@NonNull Canvas c, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.onDrawOver(c, parent, state);
        if (parent.getAdapter() instanceof ScheduledConferenceAdapter) {
            ScheduledConferenceAdapter adapter = (ScheduledConferenceAdapter) parent.getAdapter();
            int firstPosition = ((LinearLayoutManager) parent.getLayoutManager()).findFirstVisibleItemPosition();

            String itemHeader = adapter.getRoomInfoDateString(firstPosition);
            View headerView = LayoutInflater.from(parent.getContext()).inflate(R.layout.tuiroomkit_scheduled_room_date, parent, false);
            TextView headerTextView = headerView.findViewById(R.id.scheduled_room_date);
            headerTextView.setText(itemHeader);

            int widthSpec = View.MeasureSpec.makeMeasureSpec(parent.getWidth(), View.MeasureSpec.EXACTLY);
            int heightSpec = View.MeasureSpec.makeMeasureSpec(parent.getHeight(), View.MeasureSpec.UNSPECIFIED);
            int childWidth = ViewGroup.getChildMeasureSpec(widthSpec,
                    parent.getPaddingLeft() + parent.getPaddingRight(),
                    headerView.getLayoutParams().width);
            int childHeight = ViewGroup.getChildMeasureSpec(heightSpec,
                    parent.getPaddingTop() + parent.getPaddingBottom(),
                    headerView.getLayoutParams().height);
            headerView.measure(childWidth, childHeight);
            headerView.layout(0, 0, headerView.getMeasuredWidth(), headerView.getMeasuredHeight());
            headerView.draw(c);
        }
    }

}