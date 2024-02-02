package com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget;

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
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.R;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.common.widget.ChatReactDialogFragment;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.ReactPreviewView;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionPreviewPresenter;

import java.util.ArrayList;
import java.util.List;

public class ChatFlowReactView extends RecyclerView implements ReactPreviewView {
    private ChatFlowReactLayoutManager layoutManager;
    private ChatFlowReactAdapter adapter;
    private int themeColorId;
    private TUIMessageBean messageBean;
    private MessageReactionPreviewPresenter presenter;

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
        presenter = new MessageReactionPreviewPresenter();
        presenter.setReactPreviewView(this);
        DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
        float spacingVertical = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 7.68f, displayMetrics);
        float spacingHorizontal = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5.76f, displayMetrics);

        layoutManager = new ChatFlowReactLayoutManager(spacingHorizontal, spacingVertical);
        setLayoutManager(layoutManager);
        adapter = new ChatFlowReactAdapter();
        setAdapter(adapter);
        setOnReactionClickedListener(new OnReactionClickedListener() {
            @Override
            public void onClick(String reactionID) {
                ChatReactDialogFragment fragment = new ChatReactDialogFragment();
                fragment.setMessageBean(messageBean);
                fragment.setCurrentReactionID(reactionID);
                Context context = getContext();
                FragmentManager fragmentManager = null;
                if (context instanceof AppCompatActivity) {
                    fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
                }
                if (fragmentManager != null) {
                    fragment.show(fragmentManager, "ReactionDetailDialog");
                }
            }
        });
    }

    public void setThemeColorId(int themeColorId) {
        this.themeColorId = themeColorId;
        adapter.setThemeColorId(themeColorId);
    }

    public void setOnReactionClickedListener(OnReactionClickedListener onReactionClickedListener) {
        if (adapter != null) {
            adapter.setOnReactionClickedListener(onReactionClickedListener);
        }
    }

    public void setData(MessageReactionBean messageReactionBean) {
        setVisibility(VISIBLE);
        if (adapter != null) {
            adapter.setData(messageReactionBean);
            adapter.notifyDataSetChanged();
        }
    }

    @Override
    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    @Override
    public TUIMessageBean getMessageBean() {
        return messageBean;
    }

    public MessageReactionPreviewPresenter getPresenter() {
        return presenter;
    }

    static class ChatFlowReactAdapter extends Adapter<ChatFlowReactViewHolder> {
        private MessageReactionBean data;
        private OnReactionClickedListener onReactionClickedListener;
        private int themeColorId;

        public void setOnReactionClickedListener(OnReactionClickedListener onReactionClickedListener) {
            this.onReactionClickedListener = onReactionClickedListener;
        }

        public void setThemeColorId(int themeColorId) {
            this.themeColorId = themeColorId;
        }

        public void setData(MessageReactionBean data) {
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
            ReactionBean reactionBean = new ArrayList<>(data.getMessageReactionBeanMap().values()).get(position);
            String emojiId = reactionBean.getReactionID();
            Bitmap bitmap = FaceManager.getEmoji(emojiId);
            holder.faceImageView.setImageBitmap(bitmap);
            List<UserBean> userIds = reactionBean.getPartialUserList();
            holder.userTextView.setText(formatDisplayUserName(userIds));
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onReactionClickedListener != null) {
                        onReactionClickedListener.onClick(emojiId);
                    }
                }
            });
            if (themeColorId != 0) {
                holder.userTextView.setTextColor(holder.userTextView.getResources().getColor(themeColorId));
            } else {
                holder.userTextView.setTextColor(
                    holder.userTextView.getResources().getColor(TUIThemeManager.getAttrResId(holder.userTextView.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.chat_react_text_color)));
            }
        }

        @Override
        public int getItemCount() {
            if (data != null) {
                return data.getReactionCount();
            }
            return 0;
        }

        private String formatDisplayUserName(List<UserBean> userBeans) {
            StringBuilder stringBuilder = new StringBuilder();
            int index = 0;
            for (UserBean userBean : userBeans) {
                stringBuilder.append(userBean.getDisplayString());
                index++;
                if (index != userBeans.size()) {
                    stringBuilder.append("、");
                }
            }
            return stringBuilder.toString();
        }
    }

    public interface OnReactionClickedListener {
        void onClick(String reactionID);
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

            boolean isRTL = getLayoutDirection() == LAYOUT_DIRECTION_RTL;
            int offsetTop;
            int offsetBottom;
            int offsetLeft = getPaddingEnd();
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

                if (isRTL) {
                    if (i != 0 && offsetLeft - horizontalSpacing - childMeasuredWidth < getPaddingEnd()) {
                        // switch a new line
                        isLineFirstItem = true;
                        isFirstLine = false;
                        currentMaxBottom = nextMaxBottom;
                    }
                } else {
                    if (i != 0 && offsetRight + horizontalSpacing + childMeasuredWidth > getWidth() - getPaddingStart() - getPaddingEnd()) {
                        // switch a new line
                        isLineFirstItem = true;
                        isFirstLine = false;
                        currentMaxBottom = nextMaxBottom;
                    }
                }

                if (isLineFirstItem) {
                    if (isRTL) {
                        offsetLeft = getWidth() - childMeasuredWidth - getPaddingStart();
                    } else {
                        offsetLeft = getPaddingStart();
                    }
                } else {
                    if (isRTL) {
                        offsetLeft = offsetLeft - horizontalSpacing - childMeasuredWidth;

                    } else {
                        offsetLeft = offsetRight + horizontalSpacing;
                    }
                }

                if (isFirstLine) {
                    offsetTop = getPaddingTop();
                } else {
                    offsetTop = currentMaxBottom + verticalSpacing;
                }
                int childMeasuredHeight = getDecoratedMeasuredHeight(childView);

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
