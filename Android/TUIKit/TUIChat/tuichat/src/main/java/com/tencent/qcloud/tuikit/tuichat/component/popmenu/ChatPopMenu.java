package com.tencent.qcloud.tuikit.tuichat.component.popmenu;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.MessageRecyclerView;

import java.util.ArrayList;
import java.util.List;

/**
 * 聊天界面长按弹窗
 */
public class ChatPopMenu {
    // 列数
    private static final int COLUMN_NUM = 4;
    // 阴影宽度
    private static final int SHADOW_WIDTH = 10;
    // 弹窗显示高度偏移（稍偏上显示）
    private static final int Y_OFFSET = 8;

    private final PopupWindow popupWindow;
    private final Context context;
    private RecyclerView recyclerView;
    private View popupView;
    private final MenuAdapter adapter;
    private final List<ChatPopMenuAction> chatPopMenuActionList = new ArrayList<>();
    private ChatPopMenu chatPopMenu;
    private MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener;

    public ChatPopMenu(Context context) {
        chatPopMenu = this;
        this.context = context;
        popupView = LayoutInflater.from(context).inflate(R.layout.chat_pop_menu_layout, null);
        recyclerView = popupView.findViewById(R.id.chat_pop_menu_content_view);
        GridLayoutManager gridLayoutManager = new GridLayoutManager(context, COLUMN_NUM);
        recyclerView.setLayoutManager(gridLayoutManager);
        adapter = new MenuAdapter();
        recyclerView.setAdapter(adapter);

        int spaceWidth = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_width);
        int spaceHeight = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_height);
        Drawable divider = context.getResources().getDrawable(R.drawable.chat_pop_menu_divider);
        recyclerView.addItemDecoration(new GridDecoration(divider, COLUMN_NUM, spaceWidth, spaceHeight));
        popupWindow = new PopupWindow(popupView, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, false);
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(true);
    }

    public void show(View anchorView, int minY) {
        if (chatPopMenuActionList.size() == 0) {
            return;
        }
        float anchorWidth = anchorView.getWidth();
        float anchorHeight = anchorView.getHeight();
        int[] location = new int[2];
        anchorView.getLocationOnScreen(location);
        // 小三角高度
        int indicatorHeight = context.getResources().getDimensionPixelOffset(R.dimen.chat_pop_menu_indicator_height);
        int rowCount = (int) Math.ceil(chatPopMenuActionList.size() * 1.0f / COLUMN_NUM);
        if (popupWindow != null) {
            int itemSpaceWidth = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_width);
            int itemSpaceHeight = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_height);

            int itemWidth = ScreenUtil.dip2px(36.72f);
            int itemHeight = ScreenUtil.dip2px(36.72f);;

            int paddingLeftRight = ScreenUtil.dip2px(18.0f);
            int paddingTopBottom = ScreenUtil.dip2px(18.0f);

            int columnNum = Math.min(chatPopMenuActionList.size(), COLUMN_NUM);

            int popWidth = itemWidth * columnNum + paddingLeftRight * 2 + (columnNum - 1) * itemSpaceWidth - SHADOW_WIDTH;
            int popHeight = itemHeight * rowCount + paddingTopBottom * 2 + (rowCount - 1) * itemSpaceHeight - SHADOW_WIDTH;

            float indicatorX = anchorWidth / 2;
            int screenWidth = ScreenUtil.getScreenWidth(context);
            int x = location[0];
            int y = location[1] - popHeight - indicatorHeight - Y_OFFSET;
            // 如果是在右边，小箭头 x 坐标和 弹窗 x 位置都要变化
            if (location[0] * 2 + anchorWidth > screenWidth) {
                indicatorX = popWidth - anchorWidth / 2;
                x = (int) (location[0] + anchorWidth - popWidth);
            }
            // 如果高度小于给定最小高度，太偏上了，会遮盖标题栏，要显示在下面
            boolean isTop = y <= minY;
            if (isTop) {
                y = (int) (location[1] + anchorHeight) + Y_OFFSET;
                popHeight = popHeight - indicatorHeight;
            }

            if (indicatorX <= 0 || indicatorX > popWidth || popWidth < anchorWidth) {
                indicatorX = popWidth * 1.0f / 2;
            }

            Drawable drawable = getBackgroundDrawable(popWidth, popHeight, indicatorX, indicatorHeight, isTop,16);
            popupView.setBackground(drawable);
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
        adapter.notifyDataSetChanged();
    }

    public void setEmptySpaceClickListener(MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    private ChatPopMenuAction getChatPopMenuAction(int position) {
        return chatPopMenuActionList.get(position);
    }


    /**
     * 绘制带小三角的弹窗背景
     */
    public Drawable getBackgroundDrawable(final float widthPixel, final float heightPixel, float indicatorX, float indicatorHeight, boolean isTop, float radius) {
        int borderWidth = SHADOW_WIDTH;

        Path path = new Path();
        Drawable drawable = new Drawable() {
            @Override
            public void draw(@NonNull Canvas canvas) {
                Paint paint = new Paint();
                paint.setColor(Color.WHITE);
                paint.setStyle(Paint.Style.FILL);

                paint.setShadowLayer(borderWidth, 0,0,0xFFAAAAAA);

                // 小三角箭头在上面
                if (isTop) {
                    path.addRoundRect(new RectF(borderWidth, indicatorHeight + borderWidth, widthPixel - borderWidth, heightPixel + indicatorHeight - borderWidth), radius, radius, Path.Direction.CW);
                    path.moveTo(indicatorX - indicatorHeight, indicatorHeight + borderWidth);
                    path.lineTo(indicatorX, borderWidth);
                    path.lineTo(indicatorX + indicatorHeight, indicatorHeight + borderWidth);
                } else {
                    path.addRoundRect(new RectF(borderWidth, borderWidth, widthPixel - borderWidth, heightPixel - borderWidth), radius, radius, Path.Direction.CW);
                    path.moveTo(indicatorX - indicatorHeight, heightPixel - borderWidth);
                    path.lineTo(indicatorX, heightPixel + indicatorHeight - borderWidth);
                    path.lineTo(indicatorX + indicatorHeight, heightPixel - borderWidth);
                }
                path.close();
                canvas.drawPath(path, paint);
            }

            @Override
            public void setAlpha(int alpha) {

            }

            @Override
            public void setColorFilter(@Nullable ColorFilter colorFilter) {

            }

            @Override
            public int getOpacity() {
                return PixelFormat.TRANSLUCENT;
            }
        };
        return drawable;
    }

    class MenuAdapter extends RecyclerView.Adapter<MenuAdapter.MenuItemViewHolder> {
        @NonNull
        @Override
        public MenuAdapter.MenuItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(context).inflate(R.layout.chat_pop_menu_item_layout, null);
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
                    chatPopMenuAction.actionClickListener.onClick();
                    chatPopMenu.hide();

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

    /**
     * 添加间距和分割线
     */
    static class GridDecoration extends RecyclerView.ItemDecoration {

        private final int columnNum; // 总列数
        private final int leftRightSpace; // 左右间隔
        private final int topBottomSpace; // 上下间隔
        private final Drawable divider;// 分割线

        public GridDecoration(Drawable divider, int columnNum, int leftRightSpace, int topBottomSpace) {
            this.divider = divider;
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace - (column + 1) * leftRightSpace / columnNum;

            // 多行时添加顶部间距
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }

        @Override
        public void onDraw(@NonNull Canvas canvas, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            canvas.save();
            final int childCount = parent.getChildCount();
            int rowNum = (int) Math.ceil(childCount * 1.0f / columnNum);
            final int divideLine = rowNum - 1;
            for (int i = 0; i < divideLine; i++) {
                View startChild = parent.getChildAt(i * columnNum);
                View endChild = parent.getChildAt(i * columnNum + (columnNum - 1));
                final int bottom = startChild.getBottom();
                final int top = bottom - divider.getIntrinsicHeight();
                divider.setBounds(startChild.getLeft(), top + topBottomSpace / 2, endChild.getRight(), bottom + topBottomSpace / 2);
                divider.draw(canvas);
            }
            canvas.restore();
        }
    }

    public static class ChatPopMenuAction {
        private String actionName;
        private int actionIcon;
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
