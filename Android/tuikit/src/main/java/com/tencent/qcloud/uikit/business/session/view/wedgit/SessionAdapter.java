
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
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.business.session.view.SessionIconView;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class SessionAdapter extends ISessionAdapter {

    private List<SessionInfo> dataSource = new ArrayList<>();

    private int mRightWidth = UIUtils.getPxByDp(60);

    private SessionPanel mSessionPanel;

    public SessionAdapter(SessionPanel sessionPanel) {
        mSessionPanel = sessionPanel;
    }

    public void setDataProvider(ISessionProvider provider) {
        dataSource = provider.getDataSource();
        if (provider instanceof SessionProvider) {
            ((SessionProvider) provider).attachAdapter(this);
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
        return dataSource.size();
    }

    @Override
    public SessionInfo getItem(int position) {
        return dataSource.get(position);
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
            holder.item_left = (RelativeLayout) convertView.findViewById(R.id.item_left);
            holder.item_right = (RelativeLayout) convertView.findViewById(R.id.item_right);
            holder.iv_icon = (SessionIconView) convertView.findViewById(R.id.session_icon);
            holder.tv_title = (TextView) convertView.findViewById(R.id.session_title);
            holder.tv_msg = (TextView) convertView.findViewById(R.id.session_last_msg);
            holder.tv_time = (TextView) convertView.findViewById(R.id.session_time);
            holder.tv_unRead = (TextView) convertView.findViewById(R.id.session_unRead);
            holder.item_right_txt = (TextView) convertView.findViewById(R.id.item_right_txt);
            convertView.setTag(holder);
        } else {// 有直接获得ViewHolder
            holder = (ViewHolder) convertView.getTag();
        }

        SessionInfo session = dataSource.get(position);
        com.tencent.qcloud.uikit.business.chat.model.MessageInfo lastMsg = session.getLastMessage();
        if (session.isTop()) {
            holder.item_left.setBackgroundColor(convertView.getResources().getColor(R.color.top_session_color));
        } else {
            holder.item_left.setBackgroundColor(Color.WHITE);
        }
        if (mSessionPanel.getInfoView() != null) {
            holder.iv_icon.invokeInformation(session, mSessionPanel.getInfoView());
        }

      /*  if (session.isGroup()) {
            ArrayList<String> imageUrls = new ArrayList<>();
            imageUrls.add("http://pic.qiantucdn.com/58pic/22/06/55/57b2d98e109c6_1024.jpg");
            imageUrls.add("http://www.zhlzw.com/UploadFiles/Article_UploadFiles/201204/20120412123914329.jpg");
            holder.iv_icon.setIconUrls(imageUrls);
        } else {

        }
*/
        holder.iv_icon.setIconUrls(null);
        if (session.isGroup()) {
            holder.iv_icon.setDefaultImageResId(R.drawable.default_group);
        } else {
            holder.iv_icon.setDefaultImageResId(R.drawable.default_head);
        }

        holder.tv_title.setText(session.getTitle());
        holder.tv_msg.setText("");
        holder.tv_time.setText("");
        if (lastMsg != null) {
            if (lastMsg.getStatus() == MessageInfo.MSG_STATUS_REVOKE) {
                if (lastMsg.isSelf())
                    holder.tv_msg.setText("您撤回了一条消息");
                else if (lastMsg.isGroup()) {
                    holder.tv_msg.setText(lastMsg.getFromUser() + "撤回了一条消息");
                } else {
                    holder.tv_msg.setText("对方撤回了一条消息");
                }

            } else {
                if (lastMsg.getExtra() != null)
                    holder.tv_msg.setText(lastMsg.getExtra().toString());
            }

            holder.tv_time.setText(DateTimeUtil.getTimeFormatText(new Date(lastMsg.getMsgTime())));
        }


        if (session.getUnRead() > 0) {
            holder.tv_unRead.setVisibility(View.VISIBLE);
            holder.tv_unRead.setText("" + session.getUnRead());
        } else {
            holder.tv_unRead.setVisibility(View.GONE);
        }

        holder.item_right.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mListener != null) {
                    mListener.onRightItemClick(v, position);
                }
            }
        });
        return convertView;
    }

    static class ViewHolder {
        RelativeLayout item_left;
        RelativeLayout item_right;
        TextView tv_title;
        TextView tv_msg;
        TextView tv_time;
        TextView tv_unRead;
        SessionIconView iv_icon;
        TextView item_right_txt;
    }

    /**
     * 单击事件监听器
     */
    private onRightItemClickListener mListener = null;

    public void setOnRightItemClickListener(onRightItemClickListener listener) {
        mListener = listener;
    }

    public interface onRightItemClickListener {
        void onRightItemClick(View v, int position);
    }
}
