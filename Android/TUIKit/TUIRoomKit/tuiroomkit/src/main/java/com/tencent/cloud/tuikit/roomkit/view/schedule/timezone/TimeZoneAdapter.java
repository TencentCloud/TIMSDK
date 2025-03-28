package com.tencent.cloud.tuikit.roomkit.view.schedule.timezone;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TimeZone;

public class TimeZoneAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    public  int                 mSelectItemPosition;
    private Context             mContext;
    private LayoutInflater      mLayoutInflater;
    private List<TimeZoneItem>  mTimeZoneList = new ArrayList<>();
    private OnItemClickListener mOnItemClickListener;

    public TimeZoneAdapter(Context context, String currentId) {
        mContext = context;
        mLayoutInflater = LayoutInflater.from(context);
        initTimezoneList();
        mSelectItemPosition = getCurrentItemPosition(currentId);
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.mOnItemClickListener = onItemClickListener;
    }

    public interface OnItemClickListener {
        void onItemClick(String id);
    }

    public class TimeZoneItem {
        public String id;
        public String name;
        public String zone;
        public int    offset;
    }

    public void initTimezoneList() {
        String[] timeZoneIds = TimeZone.getAvailableIDs();
        Set<TimeZoneItem> timeZoneSet = new HashSet<>();
        Set<String> timeZoneNames = new HashSet<>();

        for (String id : timeZoneIds) {
            TimeZoneItem item = new TimeZoneItem();
            setTimeZoneItemData(id, item);
            if (!TextUtils.equals(item.zone, item.name) && !timeZoneNames.contains(item.name)) {
                timeZoneSet.add(item);
                timeZoneNames.add(item.name);
            }
        }

        mTimeZoneList = new ArrayList<>(timeZoneSet);
        sortTimeZoneList(mTimeZoneList);
    }

    public int getCurrentItemPosition(String timeZoneId) {
        TimeZoneItem currentItem = new TimeZoneItem();
        setTimeZoneItemData(timeZoneId, currentItem);
        for (TimeZoneItem item : mTimeZoneList) {
            if (TextUtils.equals(item.zone, currentItem.zone) && TextUtils.equals(item.name, currentItem.name)) {
                return mTimeZoneList.indexOf(item);
            }
        }
        return 0;
    }

    public void setTimeZoneItemData(String id, TimeZoneItem item) {
        TimeZone timeZone = TimeZone.getTimeZone(id);
        item.offset = timeZone.getRawOffset();
        item.id = id;
        item.name = timeZone.getDisplayName(Locale.getDefault());
        timeZone.setID("");
        item.zone = timeZone.getDisplayName(false, TimeZone.SHORT);
    }

    public void sortTimeZoneList(List<TimeZoneItem> list) {
        Collections.sort(list, new Comparator<TimeZoneItem>() {
            @Override
            public int compare(TimeZoneItem item1, TimeZoneItem item2) {
                return Integer.compare(item1.offset, item2.offset);
            }
        });
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = mLayoutInflater.inflate(R.layout.tuiroomkit_time_zone_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        TimeZoneItem item = mTimeZoneList.get(position);
        if (holder instanceof ViewHolder) {
            ((ViewHolder) holder).bind(item);
        }
    }

    @Override
    public int getItemCount() {
        return mTimeZoneList.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private       LinearLayout mLayoutTimeZone;
        private       TextView     mTvTimezone;
        private final int          mSelectItemColor;
        private final int          mUnselectItemColor;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            initView(itemView);
            mSelectItemColor = ContextCompat.getColor(mContext, R.color.tuiroomkit_color_button_schedule_conference);
            mUnselectItemColor = ContextCompat.getColor(mContext, R.color.tuiroomkit_color_schedule_conference_text);
        }

        private void initView(View itemView) {
            mLayoutTimeZone = itemView.findViewById(R.id.ll_time_zone_item);
            mTvTimezone = itemView.findViewById(R.id.tv_time_zone_content);
        }

        public void bind(TimeZoneItem item) {
            mTvTimezone.setText(getTimeZoneTextContent(item.id));
            if (mTimeZoneList.indexOf(item) == mSelectItemPosition) {
                mTvTimezone.setTextColor(mSelectItemColor);
            } else {
                mTvTimezone.setTextColor(mUnselectItemColor);
            }

            mLayoutTimeZone.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onItemClick(item.id);
                }
            });
        }

        public String getTimeZoneTextContent(String id) {
            TimeZoneItem item = new TimeZoneItem();
            setTimeZoneItemData(id, item);
            return "(" + item.zone + ")" + item.name;
        }
    }
}
