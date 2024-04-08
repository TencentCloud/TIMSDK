package com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.EmojiIndicatorView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.interfaces.OnEmptySpaceClickListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatPopMenu {
    // action column num
    private static final int ACTION_COLUMN_NUM = 5;

    // shadow width
    private static final int SHADOW_WIDTH = 10;
    // rect radius
    private static final int RECT_RADIUS = 16;

    private final PopupWindow popupWindow;
    private final Context context;
    private final RecyclerView actionRecyclerView;
    private final GridLayoutManager actionGridLayoutManager;

    private final View popupView;
    private final MenuAdapter menuAdapter;
    private final List<ChatPopMenuAction> chatPopMenuActionList = new ArrayList<>();

    private final ChatPopMenu chatPopMenu;
    private OnEmptySpaceClickListener mEmptySpaceClickListener;

    private FrameLayout reactFrameLayout;
    private View anchorView;
    private int minY;
    private final int indicatorHeight;
    private int paddingTopOffset;
    private int paddingBottomOffset;
    private TUIMessageBean messageBean;

    private boolean isShowFaces = false;

    public ChatPopMenu(Context context) {
        chatPopMenu = this;
        this.context = context;
        popupView = LayoutInflater.from(context).inflate(R.layout.chat_pop_menu_layout, null);
        reactFrameLayout = popupView.findViewById(R.id.react_frame);
        indicatorHeight = context.getResources().getDimensionPixelOffset(R.dimen.chat_pop_menu_indicator_height);

        // add space to show shadow
        popupView.setPaddingRelative(popupView.getPaddingLeft() + SHADOW_WIDTH, popupView.getPaddingTop() + SHADOW_WIDTH,
            popupView.getPaddingRight() + SHADOW_WIDTH, popupView.getPaddingBottom() + SHADOW_WIDTH);
        // actions
        actionRecyclerView = popupView.findViewById(R.id.chat_pop_menu_content_view);
        actionGridLayoutManager = new GridLayoutManager(context, ACTION_COLUMN_NUM);
        actionRecyclerView.setLayoutManager(actionGridLayoutManager);
        menuAdapter = new MenuAdapter();
        actionRecyclerView.setAdapter(menuAdapter);

        popupWindow = new PopupWindow(popupView, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, false);
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setAnimationStyle(R.style.ChatPopMenuAnimation);
        popupWindow.setOutsideTouchable(true);
    }

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public TUIMessageBean getMessageBean() {
        return messageBean;
    }

    public void setOnDismissListener(PopupWindow.OnDismissListener listener) {
        if (popupWindow != null) {
            popupWindow.setOnDismissListener(listener);
        }
    }

    public FrameLayout getReactFrameLayout() {
        return reactFrameLayout;
    }

    public void setShowFaces(boolean showFaces) {
        isShowFaces = showFaces;
    }

    public boolean isShowFaces() {
        return isShowFaces;
    }

    public boolean hasMenuAction() {
        return chatPopMenuActionList.size() > 0;
    }

    public void setActionListVisibility(int visibility) {
        actionRecyclerView.setVisibility(visibility);
    }

    public void show(View anchorView, int minY) {
        this.anchorView = anchorView;
        this.minY = minY;

        // raise reaction area
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.CHAT_POP_MENU, this);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.EXTENSION_ID, null, param);

        popupView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        popupView.setBackground(new PopIndicatorDrawable(anchorView, indicatorHeight, RECT_RADIUS));
        showAtLocation();
    }

    public void showAtLocation() {
        // reset padding
        popupView.setPaddingRelative(popupView.getPaddingLeft(), popupView.getPaddingTop() - paddingTopOffset, popupView.getPaddingRight(),
            popupView.getPaddingBottom() - paddingBottomOffset);
        paddingTopOffset = 0;
        paddingBottomOffset = 0;

        int measureSpec = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        popupView.measure(measureSpec, measureSpec);
        int popWidth = popupView.getMeasuredWidth();
        int popHeight = popupView.getMeasuredHeight();

        float anchorWidth = anchorView.getWidth();
        float anchorHeight = anchorView.getHeight();

        int[] location = new int[2];
        anchorView.getLocationOnScreen(location);
        int screenWidth = ScreenUtil.getScreenWidth(context);
        int x = location[0] - indicatorHeight;
        int y = location[1] - popHeight - indicatorHeight;
        // if popup show on the right
        if (location[0] * 2 + anchorWidth > screenWidth) {
            x = (int) (location[0] + anchorWidth - popWidth) + indicatorHeight;
        }
        // if it's too high, should show on the anchor's bottom
        boolean isTop = y <= minY;

        if (isTop) {
            y = (int) (location[1] + anchorHeight + indicatorHeight);
            // add paddingTop to show indicator
            paddingTopOffset = indicatorHeight;
            popupView.setPaddingRelative(
                popupView.getPaddingLeft(), popupView.getPaddingTop() + paddingTopOffset, popupView.getPaddingRight(), popupView.getPaddingBottom());
        } else {
            // add paddingBottom to show indicator
            paddingBottomOffset = indicatorHeight;
            popupView.setPaddingRelative(
                popupView.getPaddingLeft(), popupView.getPaddingTop(), popupView.getPaddingRight(), popupView.getPaddingBottom() + paddingBottomOffset);
            y = y - indicatorHeight;
        }
        if (popupWindow.isShowing()) {
            popupWindow.update(x, y, -1, -1, true);
        } else {
            popupWindow.showAtLocation(anchorView, Gravity.NO_GRAVITY, x, y);
        }
    }

    public void hide() {
        if (popupWindow != null && popupWindow.isShowing()) {
            popupWindow.dismiss();
        }
    }

    public void setChatPopMenuActionList(List<ChatPopMenuAction> actionList) {
        chatPopMenuActionList.clear();
        chatPopMenuActionList.addAll(actionList);
        if (!isShowFaces && !chatPopMenuActionList.isEmpty() && chatPopMenuActionList.size() < ACTION_COLUMN_NUM) {
            actionGridLayoutManager.setSpanCount(chatPopMenuActionList.size());
        }
        menuAdapter.notifyDataSetChanged();
    }

    public void setEmptySpaceClickListener(OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    private ChatPopMenuAction getChatPopMenuAction(int position) {
        return chatPopMenuActionList.get(position);
    }

    class PopIndicatorDrawable extends Drawable {
        private final Paint paint = new Paint();
        private final Path path = new Path();
        private final View anchorView;
        private final int indicatorHeight;
        private final float radius;

        public PopIndicatorDrawable(View anchorView, int indicatorHeight, float radius) {
            this.radius = radius;
            this.anchorView = anchorView;
            this.indicatorHeight = indicatorHeight;
            paint.setColor(Color.WHITE);
            paint.setStyle(Paint.Style.FILL);
            paint.setShadowLayer(SHADOW_WIDTH, 0, 0, 0xFFAAAAAA);
        }

        @Override
        public void draw(@NonNull Canvas canvas) {
            Rect bounds = getBounds();
            float widthPixel = bounds.width();
            float heightPixel = bounds.height();
            float anchorWidth = anchorView.getWidth();
            int[] anchorLocation = new int[2];
            anchorView.getLocationOnScreen(anchorLocation);
            int anchorX = anchorLocation[0];
            int anchorY = anchorLocation[1];

            int[] popLocation = new int[2];
            popupView.getLocationOnScreen(popLocation);
            int popX = popLocation[0];
            int popY = popLocation[1];

            int indicatorX = (int) (anchorX + anchorWidth / 2 - popX);
            boolean isTop = anchorY < popY;

            path.reset();
            // indicator on the top
            if (isTop) {
                float top = indicatorHeight + SHADOW_WIDTH;
                path.addRoundRect(new RectF(SHADOW_WIDTH, top, widthPixel - SHADOW_WIDTH, heightPixel - SHADOW_WIDTH), radius, radius, Path.Direction.CW);
                path.moveTo(indicatorX - indicatorHeight, top);
                path.lineTo(indicatorX, top - indicatorHeight);
                path.lineTo(indicatorX + indicatorHeight, top);
            } else {
                float bottom = heightPixel - SHADOW_WIDTH - indicatorHeight;
                path.addRoundRect(new RectF(SHADOW_WIDTH, SHADOW_WIDTH, widthPixel - SHADOW_WIDTH, bottom), radius, radius, Path.Direction.CW);
                path.moveTo(indicatorX - indicatorHeight, bottom);
                path.lineTo(indicatorX, bottom + indicatorHeight);
                path.lineTo(indicatorX + indicatorHeight, bottom);
            }
            path.close();
            canvas.drawPath(path, paint);
        }

        @Override
        public void setAlpha(int alpha) {}

        @Override
        public void setColorFilter(@Nullable ColorFilter colorFilter) {}

        @Override
        public int getOpacity() {
            return PixelFormat.TRANSLUCENT;
        }
    }

    class MenuAdapter extends RecyclerView.Adapter<MenuAdapter.MenuItemViewHolder> {
        @NonNull
        @Override
        public MenuAdapter.MenuItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(context).inflate(R.layout.chat_pop_menu_item_layout, parent, false);
            return new MenuItemViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull MenuAdapter.MenuItemViewHolder holder, int position) {
            ChatPopMenuAction chatPopMenuAction = getChatPopMenuAction(position);
            holder.title.setText(chatPopMenuAction.actionName);
            Drawable drawable = ResourcesCompat.getDrawable(context.getResources(), chatPopMenuAction.actionIcon, null);
            holder.icon.setImageDrawable(drawable);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    chatPopMenu.hide();
                    chatPopMenuAction.actionClickListener.onClick();

                    if (mEmptySpaceClickListener != null) {
                        mEmptySpaceClickListener.onClick();
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return chatPopMenuActionList.size();
        }

        class MenuItemViewHolder extends RecyclerView.ViewHolder {
            public TextView title;
            public ImageView icon;

            public MenuItemViewHolder(@NonNull View itemView) {
                super(itemView);
                title = itemView.findViewById(R.id.menu_title);
                icon = itemView.findViewById(R.id.menu_icon);
            }
        }
    }

    public static class ChatPopMenuAction {
        private String actionName;
        private int actionIcon;

        private int priority;
        private OnClickListener actionClickListener;

        public void setActionName(String actionName) {
            this.actionName = actionName;
        }

        public String getActionName() {
            return actionName;
        }

        public void setActionIcon(int actionIcon) {
            this.actionIcon = actionIcon;
        }

        public int getActionIcon() {
            return actionIcon;
        }

        public int getPriority() {
            return priority;
        }

        public void setPriority(int priority) {
            this.priority = priority;
        }

        public void setActionClickListener(OnClickListener actionClickListener) {
            this.actionClickListener = actionClickListener;
        }

        public OnClickListener getActionClickListener() {
            return actionClickListener;
        }

        @FunctionalInterface
        public interface OnClickListener {
            void onClick();
        }
    }
}
