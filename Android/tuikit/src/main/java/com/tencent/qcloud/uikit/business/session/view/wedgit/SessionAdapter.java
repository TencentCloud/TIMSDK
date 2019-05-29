
package com.tencent.qcloud.uikit.business.session.view.wedgit;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.session.ISessionAdapter;
import com.tencent.qcloud.uikit.api.session.ISessionProvider;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.model.SessionProvider;
import com.tencent.qcloud.uikit.business.session.view.SessionPanel;
import com.tencent.qcloud.uikit.common.BackgroundTasks;
import com.tencent.qcloud.uikit.common.utils.DateTimeUtil;
import com.tencent.qcloud.uikit.business.session.view.SessionIconView;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class SessionAdapter extends ISessionAdapter {

    private List<SessionInfo> mDataSource = new ArrayList<>();
    private SessionPanel mSessionPanel;

    public SessionAdapter(SessionPanel sessionPanel) {
        mSessionPanel = sessionPanel;
    }

    public void setDataProvider(ISessionProvider provider) {
        mDataSource = provider.getDataSource();
        if (provider instanceof SessionProvider) {
            provider.attachAdapter(this);
        }
        notifyDataSetChanged();
    }

    @Override
    public void notifyDataSetChanged() {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                SessionAdapter.super.notifyDataSetChanged();
            }
        });
    }

    @Override
    public int getCount() {
        return mDataSource.size();
    }

    @Override
    public SessionInfo getItem(int position) {
        return position >= 0 ? mDataSource.get(position) : null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {

        ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.session_adapter, parent, false);
            holder = new ViewHolder();
            holder.leftItemLayout = convertView.findViewById(R.id.item_left);
            holder.rightItemLayout = convertView.findViewById(R.id.item_right);
            holder.sessionIconView = convertView.findViewById(R.id.session_icon);
            holder.titleText = convertView.findViewById(R.id.session_title);
            holder.messageText = convertView.findViewById(R.id.session_last_msg);
            holder.timelineText = convertView.findViewById(R.id.session_time);
            holder.unreadText = convertView.findViewById(R.id.session_unRead);
            holder.deleteView = convertView.findViewById(R.id.item_right_txt);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        SessionInfo session = mDataSource.get(position);
        MessageInfo lastMsg = session.getLastMessage();
        if (session.isTop()) {
            holder.leftItemLayout.setBackgroundColor(convertView.getResources().getColor(R.color.top_session_color));
        } else {
            holder.leftItemLayout.setBackgroundColor(Color.WHITE);
        }
        if (mSessionPanel.getInfoView() != null) {
            holder.sessionIconView.invokeInformation(session, mSessionPanel.getInfoView());
        }

        holder.sessionIconView.setIconUrls(null);
        if (session.isGroup()) {
            holder.sessionIconView.setDefaultImageResId(R.drawable.default_group);
        } else {
            holder.sessionIconView.setDefaultImageResId(R.drawable.default_head);
        }

        holder.titleText.setText(session.getTitle());
        holder.messageText.setText("");
        holder.timelineText.setText("");
        if (lastMsg != null) {
            if (lastMsg.getStatus() == MessageInfo.MSG_STATUS_REVOKE) {
                if (lastMsg.isSelf())
                    holder.messageText.setText("您撤回了一条消息");
                else if (lastMsg.isGroup()) {
                    holder.messageText.setText(lastMsg.getFromUser() + "撤回了一条消息");
                } else {
                    holder.messageText.setText("对方撤回了一条消息");
                }

            } else {
                if (lastMsg.getExtra() != null)
                    holder.messageText.setText(lastMsg.getExtra().toString());
            }

            holder.timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(lastMsg.getMsgTime())));
        }


        if (session.getUnRead() > 0) {
            holder.unreadText.setVisibility(View.VISIBLE);
            holder.unreadText.setText("" + session.getUnRead());
        } else {
            holder.unreadText.setVisibility(View.GONE);
        }

        holder.rightItemLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
//                if (mListener != null) {
//                    mListener.onRightItemClick(v, position);
//                }
            }
        });
        return convertView;
    }

    static class ViewHolder {
        RelativeLayout leftItemLayout;
        RelativeLayout rightItemLayout;
        TextView titleText;
        TextView messageText;
        TextView timelineText;
        TextView unreadText;
        SessionIconView sessionIconView;
        TextView deleteView;
    }

    /**
     * 删除会话监听器
     */
    private onRightItemClickListener mListener = null;

    public void setOnRightItemClickListener(onRightItemClickListener listener) {
        mListener = listener;
    }

    public interface onRightItemClickListener {
        void onRightItemClick(View v, int position);
    }
}
