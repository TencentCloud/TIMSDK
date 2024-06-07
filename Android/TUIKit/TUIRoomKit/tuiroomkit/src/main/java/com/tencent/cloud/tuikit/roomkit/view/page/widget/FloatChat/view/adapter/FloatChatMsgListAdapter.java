package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.adapter;

import static android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IEmojiResource;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.store.FloatChatStore;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FloatChatMsgListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final Context             mContext;
    private final List<TUIFloatChat>  mMsgEntityList;
    private final OnItemClickListener mOnItemClickListener;
    private final LayoutInflater         mLayoutInflater;
    private final IEmojiResource             mEmojiResource;
    private       TUIFloatChatDisplayAdapter mCustomAdapter;

    public FloatChatMsgListAdapter(Context context, List<TUIFloatChat> msgEntityList,
                                   OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mMsgEntityList = msgEntityList;
        this.mOnItemClickListener = onItemClickListener;
        this.mEmojiResource = FloatChatStore.sharedInstance().mEmojiResource;
        this.mLayoutInflater = LayoutInflater.from(context);
    }

    public void setCustomAdapter(TUIFloatChatDisplayAdapter adapter) {
        mCustomAdapter = adapter;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (mCustomAdapter != null && viewType != 0) {
            RecyclerView.ViewHolder holder = mCustomAdapter.onCreateViewHolder(parent, viewType);
            if (holder != null) {
                return holder;
            }
        }
        View view = mLayoutInflater.inflate(R.layout.tuiroomkit_float_chat_item_msg, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        TUIFloatChat item = mMsgEntityList.get(position);
        if (holder instanceof ViewHolder) {
            ((ViewHolder) holder).bind(item, mOnItemClickListener);
        } else if (mCustomAdapter != null) {
            mCustomAdapter.onBindViewHolder(holder, item);
        }
    }

    @Override
    public int getItemCount() {
        return mMsgEntityList.size();
    }

    @Override
    public int getItemViewType(int position) {
        TUIFloatChat item = mMsgEntityList.get(position);
        int viewType = super.getItemViewType(position);
        if (mCustomAdapter != null) {
            viewType = mCustomAdapter.getItemViewType(position, item);
        }
        return viewType;
    }

    public interface OnItemClickListener {
        void onAgreeClick(int position);
    }


    public class ViewHolder extends RecyclerView.ViewHolder {
        private TextView mTvMsgContent;
        private TextView mBtnMsgAgree;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mTvMsgContent = itemView.findViewById(R.id.tv_msg_content);
            mBtnMsgAgree = itemView.findViewById(R.id.btn_msg_agree);
        }

        public void bind(final TUIFloatChat barrage, final OnItemClickListener listener) {
            String userName = TextUtils.isEmpty(barrage.user.userName) ? barrage.user.userId : barrage.user.userName;
            userName = TextUtils.isEmpty(userName) ? "" : userName;
            String result = userName + ": " + barrage.content;

            SpannableStringBuilder builder = new SpannableStringBuilder(result);
            int userNameColor = mContext.getResources().getColor(R.color.tuiroomkit_color_float_chat_user_name_color);
            ForegroundColorSpan foreSpan = new ForegroundColorSpan(userNameColor);
            builder.setSpan(foreSpan, 0, userName.length() + 1, SPAN_EXCLUSIVE_EXCLUSIVE);

            Paint.FontMetrics fontMetrics = mTvMsgContent.getPaint().getFontMetrics();
            int fontSize = (int) (Math.abs(fontMetrics.ascent) + Math.abs(fontMetrics.descent));
            Rect rect = new Rect(0, 0, fontSize, fontSize);
            processEmojiSpan(builder, mEmojiResource, rect);
            mTvMsgContent.setText(builder);

            mBtnMsgAgree.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onAgreeClick(getLayoutPosition());
                }
            });
        }

        private void processEmojiSpan(SpannableStringBuilder sb, IEmojiResource emojiResource, Rect rect) {
            if (sb == null || emojiResource == null) {
                return;
            }
            String text = sb.toString();
            Pattern pattern = Pattern.compile(emojiResource.getEncodePattern());
            List<String> matches = new ArrayList<>();
            Matcher matcher = pattern.matcher(sb);
            while (matcher.find()) {
                matches.add(matcher.group());
            }
            for (String item : matches) {
                int resId = emojiResource.getResId(item);
                if (resId == 0) {
                    continue;
                }
                int fromIndex = 0;
                while (fromIndex < text.length()) {
                    int index = text.indexOf(item, fromIndex);
                    if (index == -1) {
                        break;
                    }
                    fromIndex = index + item.length();
                    Drawable emojiDrawable = emojiResource.getDrawable(mContext, resId, rect);
                    if (emojiDrawable == null) {
                        continue;
                    }
                    ImageSpan imageSpan = new ImageSpan(emojiDrawable);
                    sb.setSpan(imageSpan, index, index + item.length(), SPAN_EXCLUSIVE_EXCLUSIVE);
                }
            }
        }
    }
}