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

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.EmojiIndicatorView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.component.face.RecentEmojiManager;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ChatPopMenu {
    // action column num
    private static final int ACTION_COLUMN_NUM = 5;
    // emoji column num
    private static final int EMOJI_COLUMN_NUM = 8;
    private static final int EMOJI_ROW_NUM = 3;
    private static final int RECENT_EMOJI_NUM = 6;
    private static final String RECENT_EMOJI_KEY = "recentEmoji";
    // shadow width
    private static final int SHADOW_WIDTH = 10;
    // rect radius
    private static final int RECT_RADIUS = 16;

    private final PopupWindow popupWindow;
    private final Context context;
    private final RecyclerView actionRecyclerView;
    private final GridLayoutManager actionGridLayoutManager;
    private final RecyclerView facePageRecyclerView;
    private final LinearLayout facePageLinearLayout;
    private final EmojiIndicatorView facePageIndicator;
    private RecyclerView recentFaceView;
    private View divideLine;
    private FacePageAdapter facePageAdapter;
    private final View popupView;
    private final MenuAdapter menuAdapter;
    private final List<ChatPopMenuAction> chatPopMenuActionList = new ArrayList<>();
    private final List<Emoji> emojiList = new ArrayList<>();
    private final List<String> recentEmojiList = new ArrayList<>();
    private final ChatPopMenu chatPopMenu;
    private MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener;
    private EmojiOnClickListener emojiOnClickListener;
    private boolean isShowMoreFace = false;

    private View anchorView;
    private int minY;
    private final int indicatorHeight;
    private int paddingTopOffset;
    private int paddingBottomOffset;
    private int oldFacePageIndex = 0;

    private boolean isShowFaces = false;
    public ChatPopMenu(Context context) {
        chatPopMenu = this;
        this.context = context;
        initEmojiList();
        popupView = LayoutInflater.from(context).inflate(R.layout.chat_pop_menu_layout, null);
        indicatorHeight = context.getResources().getDimensionPixelOffset(R.dimen.chat_pop_menu_indicator_height);

        // add space to show shadow
        popupView.setPadding(popupView.getPaddingLeft() + SHADOW_WIDTH, popupView.getPaddingTop() + SHADOW_WIDTH,
                popupView.getPaddingRight() + SHADOW_WIDTH, popupView.getPaddingBottom() + SHADOW_WIDTH);
        // actions
        actionRecyclerView = popupView.findViewById(R.id.chat_pop_menu_content_view);
        actionGridLayoutManager = new GridLayoutManager(context, ACTION_COLUMN_NUM);
        actionRecyclerView.setLayoutManager(actionGridLayoutManager);
        int spaceWidth = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_width);
        int spaceHeight = context.getResources().getDimensionPixelSize(R.dimen.chat_pop_menu_item_space_height);
        actionRecyclerView.addItemDecoration(new GridDecoration(null, ACTION_COLUMN_NUM, spaceWidth, spaceHeight));
        menuAdapter = new MenuAdapter();
        actionRecyclerView.setAdapter(menuAdapter);

        divideLine = popupView.findViewById(R.id.divide_line);
        // recent faces
        recentFaceView = popupView.findViewById(R.id.recent_faces);
        recentFaceView.setItemAnimator(null);
        LinearLayoutManager recentLayoutManager = new LinearLayoutManager(context, RecyclerView.HORIZONTAL, false);
        int recentSpacing = ScreenUtil.dip2px(13.44f);
        recentFaceView.addItemDecoration(new GridDecoration(null, RECENT_EMOJI_NUM + 1, recentSpacing, 0));
        recentFaceView.setLayoutManager(recentLayoutManager);
        RecentFaceAdapter recentFaceAdapter = new RecentFaceAdapter();
        recentFaceView.setAdapter(recentFaceAdapter);
        // grid faces
        facePageLinearLayout = popupView.findViewById(R.id.face_grid_ll);
        facePageRecyclerView = popupView.findViewById(R.id.face_grid);
        facePageIndicator = popupView.findViewById(R.id.face_indicator);
        facePageLinearLayout.setVisibility(View.GONE);
        LinearLayoutManager faceLayoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false);
        PagerSnapHelper snapHelper = new PagerSnapHelper();
        snapHelper.attachToRecyclerView(facePageRecyclerView);
        facePageRecyclerView.setLayoutManager(faceLayoutManager);
        facePageAdapter = new FacePageAdapter();
        facePageRecyclerView.setAdapter(facePageAdapter);
        setFacePageIndicator(faceLayoutManager);

        popupWindow = new PopupWindow(popupView, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, false);
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setAnimationStyle(R.style.ChatPopMenuAnimation);
        popupWindow.setOutsideTouchable(true);
    }

    private void setFacePageIndicator(LinearLayoutManager faceLayoutManager) {
        facePageIndicator.init(facePageAdapter.getItemCount());
        facePageRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                int currentFacePageIndex;
                if (dx >= 0) {
                    currentFacePageIndex = faceLayoutManager.findLastVisibleItemPosition();
                } else {
                    currentFacePageIndex = faceLayoutManager.findFirstVisibleItemPosition();
                }
                // the page is not be selected
                if (currentFacePageIndex == RecyclerView.NO_POSITION || oldFacePageIndex == currentFacePageIndex) {
                    return;
                }
                facePageIndicator.playBy(oldFacePageIndex, currentFacePageIndex);
                oldFacePageIndex = currentFacePageIndex;
            }
        });
    }

    public void setOnDismissListener(PopupWindow.OnDismissListener listener) {
        if (popupWindow != null) {
            popupWindow.setOnDismissListener(listener);
        }
    }

    private void initEmojiList() {
        emojiList.addAll(FaceManager.getEmojiList());
        initDefaultEmoji();
    }

    private void initDefaultEmoji() {
        List<String> emojis = null;
        try {
            emojis = (List<String>) RecentEmojiManager.getInstance().getCollection(RECENT_EMOJI_KEY);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        if (emojis == null) {
            List<Emoji> subList = emojiList.subList(0, RECENT_EMOJI_NUM);
            List<String> emojiKeys = new ArrayList<>();
            for (Emoji emoji : subList) {
                emojiKeys.add(emoji.getFaceKey());
            }
            emojis = new ArrayList<>(emojiKeys);
            try {
                RecentEmojiManager.getInstance().putCollection(RECENT_EMOJI_KEY, emojis);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        recentEmojiList.addAll(emojis);
    }

    private void updateRecentEmoji(Emoji emoji) {
        recentEmojiList.remove(emoji.getFaceKey());
        recentEmojiList.add(0, emoji.getFaceKey());
        try {
            RecentEmojiManager.getInstance().putCollection(RECENT_EMOJI_KEY, recentEmojiList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void setShowFaces(boolean showFaces) {
        isShowFaces = showFaces;
    }

    public void show(View anchorView, int minY) {
        this.anchorView = anchorView;
        this.minY = minY;
        if (!isShowFaces) {
            recentFaceView.setVisibility(View.GONE);
            divideLine.setVisibility(View.GONE);
        } else {
            recentFaceView.setVisibility(View.VISIBLE);
            if (chatPopMenuActionList.isEmpty()) {
                divideLine.setVisibility(View.GONE);
                actionRecyclerView.setVisibility(View.GONE);
            } else {
                divideLine.setVisibility(View.VISIBLE);
                actionRecyclerView.setVisibility(View.VISIBLE);
            }
        }
        popupView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        popupView.setBackground(new PopIndicatorDrawable(anchorView, indicatorHeight, RECT_RADIUS));
        showAtLocation();
    }

    private void showAtLocation() {
        // reset padding
        popupView.setPadding(popupView.getPaddingLeft(), popupView.getPaddingTop() - paddingTopOffset,
                popupView.getPaddingRight(), popupView.getPaddingBottom() - paddingBottomOffset);
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
            popupView.setPadding(popupView.getPaddingLeft(), popupView.getPaddingTop() + paddingTopOffset,
                    popupView.getPaddingRight(), popupView.getPaddingBottom());
        } else {
            // add paddingBottom to show indicator
            paddingBottomOffset = indicatorHeight;
            popupView.setPadding(popupView.getPaddingLeft(), popupView.getPaddingTop(),
                    popupView.getPaddingRight(), popupView.getPaddingBottom() + paddingBottomOffset);
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
        if (!chatPopMenuActionList.isEmpty() && chatPopMenuActionList.size() < ACTION_COLUMN_NUM) {
            actionGridLayoutManager.setSpanCount(chatPopMenuActionList.size());
        }
        menuAdapter.notifyDataSetChanged();
    }

    public void setEmptySpaceClickListener(MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    private ChatPopMenuAction getChatPopMenuAction(int position) {
        return chatPopMenuActionList.get(position);
    }

    public void setEmojiOnClickListener(EmojiOnClickListener emojiOnClickListener) {
        this.emojiOnClickListener = emojiOnClickListener;
    }

    private void refreshLayout() {
        if (isShowMoreFace) {
            facePageLinearLayout.setVisibility(View.VISIBLE);
            actionRecyclerView.setVisibility(View.GONE);
            divideLine.setVisibility(View.VISIBLE);
        } else {
            facePageLinearLayout.setVisibility(View.GONE);
            if (chatPopMenuActionList.isEmpty()) {
                divideLine.setVisibility(View.GONE);
                actionRecyclerView.setVisibility(View.GONE);
            } else {
                divideLine.setVisibility(View.VISIBLE);
                actionRecyclerView.setVisibility(View.VISIBLE);
            }
        }
        showAtLocation();
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
            paint.setShadowLayer(SHADOW_WIDTH, 0,0,0xFFAAAAAA);
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
                path.addRoundRect(new RectF(SHADOW_WIDTH, top, widthPixel -  SHADOW_WIDTH,
                        heightPixel - SHADOW_WIDTH), radius, radius, Path.Direction.CW);
                path.moveTo(indicatorX - indicatorHeight, top);
                path.lineTo(indicatorX, top - indicatorHeight);
                path.lineTo(indicatorX + indicatorHeight, top);
            } else {
                float bottom = heightPixel - SHADOW_WIDTH - indicatorHeight;
                path.addRoundRect(new RectF(SHADOW_WIDTH, SHADOW_WIDTH, widthPixel - SHADOW_WIDTH,
                        bottom), radius, radius, Path.Direction.CW);
                path.moveTo(indicatorX - indicatorHeight, bottom);
                path.lineTo(indicatorX, bottom + indicatorHeight);
                path.lineTo(indicatorX + indicatorHeight, bottom);
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
    }

    class RecentFaceAdapter extends RecyclerView.Adapter<RecentFaceAdapter.RecentFaceViewHolder> {

        @NonNull
        @Override
        public RecentFaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_menu_recent_face_item_layout, parent, false);
            return new RecentFaceViewHolder(faceView);
        }

        @Override
        public void onBindViewHolder(@NonNull RecentFaceViewHolder holder, int position) {
            Emoji emoji;
            if (position == RECENT_EMOJI_NUM) {
                emoji = new Emoji();
                Bitmap bitMap;
                if (!isShowMoreFace) {
                    bitMap = BitmapFactory.decodeResource(context.getResources(), R.drawable.chat_menu_face_show_more);
                } else {
                    bitMap = BitmapFactory.decodeResource(context.getResources(), R.drawable.chat_menu_face_hide_more);
                }
                emoji.setIcon(bitMap);
            } else {
                emoji = getEmoji(recentEmojiList.get(position));
            }
            if (emoji == null) {
                return;
            }
            holder.faceIv.setImageBitmap(emoji.getIcon());
            if (emojiOnClickListener != null) {
                holder.faceIv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (position == RECENT_EMOJI_NUM) {
                            isShowMoreFace = !isShowMoreFace;
                            refreshLayout();
                            notifyItemChanged(position);
                        } else {
                            emojiOnClickListener.onClick(emoji);
                            updateRecentEmoji(emoji);
                            hide();
                        }
                    }
                });
            }
        }

        private Emoji getEmoji(String emojiKey) {
            for (Emoji emoji : emojiList) {
                if (TextUtils.equals(emoji.getFaceKey(), emojiKey)) {
                    return emoji;
                }
            }
            return null;
        }

        @Override
        public int getItemCount() {
            return RECENT_EMOJI_NUM + 1;
        }

        class RecentFaceViewHolder extends RecyclerView.ViewHolder {
            ImageView faceIv;
            public RecentFaceViewHolder(@NonNull View itemView) {
                super(itemView);
                faceIv = itemView.findViewById(R.id.face_iv);
            }
        }
    }

    class FacePageAdapter extends RecyclerView.Adapter<FacePageAdapter.FacePageViewHolder> {

        @NonNull
        @Override
        public FacePageAdapter.FacePageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            RecyclerView faceGridView = new RecyclerView(parent.getContext());
            faceGridView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            faceGridView.setLayoutManager(new GridLayoutManager(parent.getContext(), EMOJI_COLUMN_NUM));
            int faceVerticalSpacing = ScreenUtil.dip2px(16.32f);
            int faceHorizontalSpacing = ScreenUtil.dip2px(9.12f);
            faceGridView.addItemDecoration(new FaceGridDecoration(EMOJI_COLUMN_NUM, faceHorizontalSpacing, faceVerticalSpacing));
            return new FacePageViewHolder(faceGridView);
        }

        @Override
        public void onBindViewHolder(@NonNull FacePageAdapter.FacePageViewHolder holder, int position) {
            FaceGridAdapter faceGridAdapter = new FaceGridAdapter();
            holder.recyclerView.setAdapter(faceGridAdapter);
            int startIndex = position * EMOJI_ROW_NUM * EMOJI_COLUMN_NUM;
            int endIndex = (position + 1) * EMOJI_COLUMN_NUM * EMOJI_ROW_NUM;
            if (endIndex > emojiList.size()) {
                endIndex = emojiList.size();
            }
            List<Emoji> data = emojiList.subList(startIndex, endIndex);
            faceGridAdapter.setData(data);
        }

        @Override
        public int getItemCount() {
            return (int) Math.ceil(emojiList.size() * 1.0f / (EMOJI_COLUMN_NUM * EMOJI_ROW_NUM));
        }

        class FacePageViewHolder extends RecyclerView.ViewHolder {
            public RecyclerView recyclerView;
            public FacePageViewHolder(@NonNull View itemView) {
                super(itemView);
                recyclerView = (RecyclerView) itemView;
            }
        }
    }

    class FaceGridAdapter extends RecyclerView.Adapter<FaceViewHolder> {
        private List<Emoji> data;

        public void setData(List<Emoji> data) {
            this.data = data;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public FaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_menu_face_item_layout, parent, false);
            return new FaceViewHolder(faceView);
        }

        @Override
        public void onBindViewHolder(@NonNull FaceViewHolder holder, int position) {
            Emoji emoji = data.get(position);
            holder.faceIv.setBackground(new BitmapDrawable(holder.itemView.getResources(), emoji.getIcon()));
            if (emojiOnClickListener != null) {
                holder.faceIv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        emojiOnClickListener.onClick(emoji);
                        updateRecentEmoji(emoji);
                        hide();
                    }
                });
            }
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }
    }

    static class FaceViewHolder extends RecyclerView.ViewHolder {
        ImageView faceIv;
        public FaceViewHolder(@NonNull View itemView) {
            super(itemView);
            faceIv = itemView.findViewById(R.id.face_iv);
        }
    }

    static class FaceGridDecoration extends RecyclerView.ItemDecoration {

        private final int columnNum;
        private final int leftRightSpace; // horizontal spacing
        private final int topBottomSpace; // vertical spacing

        public FaceGridDecoration(int columnNum, int leftRightSpace, int topBottomSpace) {
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            // grid has multi rows, add top spacing
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
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

    static class GridDecoration extends RecyclerView.ItemDecoration {

        private final int columnNum;
        private final int leftRightSpace;
        private final int topBottomSpace;
        private final Drawable divider;

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
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }

        @Override
        public void onDraw(@NonNull Canvas canvas, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            if (divider == null) {
                return;
            }
            canvas.save();
            final int childCount = parent.getChildCount();
            int rowNum = (int) Math.ceil(childCount * 1.0f / columnNum);
            final int divideLine = rowNum - 1;
            for (int i = 0; i < divideLine; i++) {
                View startChild = parent.getChildAt(i * columnNum);
                View endChild = parent.getChildAt((i + 1) * columnNum - 1);
                final int bottom = startChild.getBottom();
                final int top = bottom - divider.getIntrinsicHeight();
                divider.setBounds(startChild.getLeft(), top + topBottomSpace / 2, endChild.getRight(), bottom + topBottomSpace / 2);
                divider.draw(canvas);
            }
            canvas.restore();
        }
    }

    public interface EmojiOnClickListener {
        void onClick(Emoji emoji);
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
