package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist;

import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS;

import android.content.Context;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainActivity;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class ScheduledConferenceAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private final static String                        FORMAT_TIME = "%02d:%02d";
    private final        Context                       mContext;
    private final        LayoutInflater                mLayoutInflater;
    private              List<ScheduledConferenceItem> mScheduledRoomDataList;

    public ScheduledConferenceAdapter(Context context) {
        this.mContext = context;
        this.mLayoutInflater = LayoutInflater.from(context);

    }

    public void setDataList(List<ScheduledConferenceItem> list) {
        mScheduledRoomDataList = list;
        notifyDataSetChanged();
    }

    public String getRoomInfoDateString(int position) {
        for (int i = position; i >= 0; i--) {
            ScheduledConferenceItem item = mScheduledRoomDataList.get(i);
            if (item.getType() == ScheduledConferenceItem.TYPE_CONFERENCE_HEADER) {
                return (String) item.getData();
            }
        }
        return "";
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == ScheduledConferenceItem.TYPE_CONFERENCE_HEADER) {
            View headerView = mLayoutInflater.inflate(R.layout.tuiroomkit_scheduled_room_date, parent, false);
            return new ViewHolderRoomHeader(headerView);
        }
        View contentView = mLayoutInflater.inflate(R.layout.tuiroomkit_scheduled_room_info, parent, false);
        return new ViewHolderRoomInfo(contentView);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ScheduledConferenceItem item = mScheduledRoomDataList.get(position);
        RecyclerView.LayoutParams layoutParams = (RecyclerView.LayoutParams) holder.itemView.getLayoutParams();
        layoutParams.bottomMargin = (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_conference_item_margin_bottom);
        holder.itemView.setLayoutParams(layoutParams);
        if (holder instanceof ViewHolderRoomHeader) {
            ((ViewHolderRoomHeader) holder).bind((String) item.getData());
        } else {
            ((ViewHolderRoomInfo) holder).bind((ScheduledConferenceItemInfo) item.getData());
        }
    }

    @Override
    public int getItemViewType(int position) {
        return mScheduledRoomDataList.get(position).getType();
    }

    @Override
    public int getItemCount() {
        if (mScheduledRoomDataList != null) {
            return mScheduledRoomDataList.size();
        }
        return 0;
    }

    public class ViewHolderRoomHeader extends RecyclerView.ViewHolder {
        public TextView mTvScheduledRoomDate;

        public ViewHolderRoomHeader(@NonNull View itemView) {
            super(itemView);
            mTvScheduledRoomDate = itemView.findViewById(R.id.scheduled_room_date);
        }

        public void bind(final String item) {
            mTvScheduledRoomDate.setText(item);
        }
    }

    public class ViewHolderRoomInfo extends RecyclerView.ViewHolder {
        private TextView         mTvRoomOwner;
        private TextView         mTvRoomId;
        private TextView         mTvRoomTime;
        private TextView         mTvRoomStatus;
        private View             mStatusDivideLine;
        private LinearLayout     mLlEnterRoom;
        private ConstraintLayout mLayoutRoomInfo;
        private String           mRoomId;

        public ViewHolderRoomInfo(@NonNull View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mLayoutRoomInfo = itemView.findViewById(R.id.cl_scheduled_conference_item);
            mTvRoomTime = itemView.findViewById(R.id.tv_scheduled_room_time);
            mTvRoomOwner = itemView.findViewById(R.id.tv_scheduled_conference_name);
            mTvRoomId = itemView.findViewById(R.id.tv_scheduled_room_id);
            mTvRoomStatus = itemView.findViewById(R.id.tv_scheduled_room_status);
            mLlEnterRoom = itemView.findViewById(R.id.ll_enter_scheduled_room);
            mStatusDivideLine = itemView.findViewById(R.id.divide_status_line);
            mLlEnterRoom.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ConferenceDefine.JoinConferenceParams params = new ConferenceDefine.JoinConferenceParams(mRoomId);
                    params.isOpenMicrophone = true;
                    params.isOpenCamera = false;
                    params.isOpenSpeaker = true;
                    Intent intent = new Intent(mContext, ConferenceMainActivity.class);
                    intent.putExtra(KEY_JOIN_CONFERENCE_PARAMS, params);
                    mContext.startActivity(intent);
                }
            });
            mLayoutRoomInfo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle param = new Bundle();
                    param.putString(ConferenceConstant.KEY_CONFERENCE_ID, mRoomId);
                    TUICore.startActivity("ScheduledConferenceDetailActivity", param);
                }
            });
        }

        public void bind(final ScheduledConferenceItemInfo item) {
            mTvRoomOwner.setText(item.conferenceName);
            String roomTime = transTimestampToString(item.scheduleStartTime) + " - " + transTimestampToString(item.scheduledEndTime);
            mTvRoomTime.setText(roomTime);
            mTvRoomId.setText(addSpacesEveryThreeChars(item.id));
            if (TextUtils.isEmpty(item.status)) {
                mStatusDivideLine.setVisibility(View.GONE);
            } else {
                mStatusDivideLine.setVisibility(View.VISIBLE);
            }
            mTvRoomStatus.setText(item.status);
            mRoomId = item.id;
        }

        private String transTimestampToString(long timestamp) {
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(timestamp);
            int hour = calendar.get(Calendar.HOUR_OF_DAY);
            int minute = calendar.get(Calendar.MINUTE);
            return String.format(Locale.getDefault(), FORMAT_TIME, hour, minute);
        }

        private String addSpacesEveryThreeChars(String roomId) {
            if (TextUtils.isEmpty(roomId)) {
                return "";
            }
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0; i < roomId.length(); i++) {
                stringBuilder.append(roomId.charAt(i));
                if ((i + 1) % 3 == 0 && i != roomId.length() - 1) {
                    stringBuilder.append(' ');
                }
            }
            return stringBuilder.toString();
        }
    }
}
