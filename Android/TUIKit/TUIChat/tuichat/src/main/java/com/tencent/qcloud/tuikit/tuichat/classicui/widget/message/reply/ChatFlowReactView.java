package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReactUserBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

public class ChatFlowReactView extends RecyclerView {
    private ChatFlowReactLayoutManager layoutManager;
    private ChatFlowReactAdapter adapter;
    private int themeColorId;
    public ChatFlowReactView(@NonNull Context context) {
        super(context);
        initView();
    }

    public ChatFlowReactView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public ChatFlowReactView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {

        DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
        float spacingVertical = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 7.68f, displayMetrics);
        float spacingHorizontal = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5.76f, displayMetrics);

        layoutManager = new ChatFlowReactLayoutManager(spacingHorizontal, spacingVertical);
        setLayoutManager(layoutManager);
        adapter = new ChatFlowReactAdapter();
        setAdapter(adapter);
    }

    public void setThemeColorId(int themeColorId) {
        this.themeColorId = themeColorId;
        adapter.setThemeColorId(themeColorId);
    }

    public void setReactOnClickListener(ReactOnClickListener reactOnClickListener) {
        if (adapter != null) {
            adapter.setReactOnClickListener(reactOnClickListener);
        }
    }

    public void setData(MessageReactBean reactBean) {
        if (adapter != null) {
            adapter.setData(reactBean);
            adapter.notifyDataSetChanged();
        }
    }

    static class ChatFlowReactAdapter extends Adapter<ChatFlowReactViewHolder> {
        private MessageReactBean data;
        private ReactOnClickListener reactOnClickListener;
        private int themeColorId;
        public void setReactOnClickListener(ReactOnClickListener reactOnClickListener) {
            this.reactOnClickListener = reactOnClickListener;
        }

        public void setThemeColorId(int themeColorId) {
            this.themeColorId = themeColorId;
        }

        public void setData(MessageReactBean data) {
            this.data = data;
        }

        @NonNull
        @Override
        public ChatFlowReactViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_flow_react_item_layout, parent, false);
            return new ChatFlowReactViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ChatFlowReactViewHolder holder, int position) {
            Map.Entry<String, Set<String>> entry = new ArrayList<>(data.getReacts().entrySet()).get(position);
            String emojiId = entry.getKey();
            Set<String> userIds = entry.getValue();

            Bitmap bitmap = FaceManager.getEmoji(emojiId);
            holder.faceImageView.setImageBitmap(bitmap);

            holder.faceImageView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (reactOnClickListener != null) {
                        reactOnClickListener.onClick(emojiId);
                    }
                }
            });
            if (themeColorId != 0) {
                holder.userTextView.setTextColor(holder.userTextView.getResources().getColor(themeColorId));
                holder.userTextView.setTextColor(holder.userTextView.getResources().getColor(themeColorId));
            } else {
                holder.userTextView.setTextColor(holder.userTextView.getResources().getColor(
                        TUIThemeManager.getAttrResId(holder.userTextView.getContext(), R.attr.chat_react_text_color)));
                holder.userTextView.setTextColor(holder.userTextView.getResources().getColor(
                        TUIThemeManager.getAttrResId(holder.userTextView.getContext(), R.attr.chat_react_text_color)));
            }
            holder.userTextView.setText(formatDisplayUserName(userIds));
        }

        private String getUserDisplayName(String id) {
            if (data.getReactUserBeanMap() == null) {
                return id;
            } else {
                ReactUserBean reactUserBean = data.getReactUserBeanMap().get(id);
                if (reactUserBean == null) {
                    return id;
                } else {
                    return reactUserBean.getDisplayString();
                }
            }
        }

        @Override
        public int getItemCount() {
            if (data != null) {
                return data.getReactSize();
            }
            return 0;
        }
        
        private String formatDisplayUserName(Set<String> userIds) {
            StringBuilder stringBuilder = new StringBuilder();
            int index = 0;
            for (String userId : userIds) {
                stringBuilder.append(getUserDisplayName(userId));
                index++;
                if (index != userIds.size()) {
                    stringBuilder.append("、");
                }
            }
            return stringBuilder.toString();
        }
    }

    public interface ReactOnClickListener {
        void onClick(String emojiId);
    }

    static class ChatFlowReactViewHolder extends ViewHolder {
        public TextView userTextView;
        public ImageView faceImageView;
        public ChatFlowReactViewHolder(@NonNull View itemView) {
            super(itemView);
            userTextView = itemView.findViewById(R.id.users_tv);
            faceImageView = itemView.findViewById(R.id.face_iv);
        }
    }


    // ChatReactView is just a simple flowLayout
    static class ChatFlowReactLayoutManager extends LayoutManager {
        private int verticalSpacing = 0;
        private int horizontalSpacing = 0;

        public ChatFlowReactLayoutManager() {}

        public ChatFlowReactLayoutManager(float horizontalSpacing, float verticalSpacing) {
            this.verticalSpacing = Math.round(verticalSpacing);
            this.horizontalSpacing = Math.round(horizontalSpacing);
        }

        @Override
        public LayoutParams generateDefaultLayoutParams() {
            return new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }

        @Override
        public void onLayoutChildren(Recycler recycler, State state) {
            detachAndScrapAttachedViews(recycler);
            int itemCount = getItemCount();
            if (itemCount == 0) {
                return;
            }

            int offsetTop;
            int offsetBottom;
            int offsetLeft;
            int offsetRight = getPaddingStart();

            boolean isLineFirstItem = true;
            boolean isFirstLine = true;

            int currentMaxBottom = 0;
            int nextMaxBottom = 0;
            for (int i = 0; i < itemCount; i++) {
                View childView = recycler.getViewForPosition(i);
                addView(childView);
                measureChildWithMargins(childView, 0, 0);
                int childMeasuredWidth = getDecoratedMeasuredWidth(childView);
                int childMeasuredHeight = getDecoratedMeasuredHeight(childView);

                if (i != 0 && offsetRight + horizontalSpacing + childMeasuredWidth >
                        getWidth() - getPaddingStart() - getPaddingEnd()) {
                    // switch a new line
                    isLineFirstItem = true;
                    isFirstLine = false;
                    currentMaxBottom = nextMaxBottom;
                }

                if (isLineFirstItem) {
                    offsetLeft = getPaddingStart();
                } else {
                    offsetLeft = offsetRight + horizontalSpacing;
                }

                if (isFirstLine) {
                    offsetTop = getPaddingTop();
                } else {
                    offsetTop = currentMaxBottom + verticalSpacing;
                }

                offsetRight = offsetLeft + childMeasuredWidth;
                offsetBottom = offsetTop + childMeasuredHeight;
                nextMaxBottom = Math.max(nextMaxBottom, offsetBottom);

                layoutDecoratedWithMargins(childView, offsetLeft, offsetTop, offsetRight, offsetBottom);

                isLineFirstItem = false;
            }
        }

        @Override
        public boolean isAutoMeasureEnabled() {
            return true;
        }
    }
}
