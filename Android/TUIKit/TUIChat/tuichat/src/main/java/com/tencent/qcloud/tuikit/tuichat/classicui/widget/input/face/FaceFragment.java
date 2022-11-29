package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.face;

import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.EmojiIndicatorView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.BaseInputFragment;
import com.tencent.qcloud.tuikit.tuichat.component.face.ChatFace;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFace;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceGroup;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.component.face.RecentEmojiManager;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FaceFragment extends BaseInputFragment {

    ViewPager faceViewPager;
    EmojiIndicatorView faceIndicator;
    FaceGroupIcon mCurrentSelected;
    LinearLayout faceGroup;
    ArrayList<View> ViewPagerItems = new ArrayList<>();
    ArrayList<Emoji> recentlyEmojiList;
    List<FaceGroup> faceGroups;
    private int mCurrentGroupIndex = 0;
    private OnEmojiClickListener listener;
    private RecentEmojiManager recentManager;

    private boolean showCustomFace = true;

    public void setListener(OnEmojiClickListener listener) {
        this.listener = listener;
    }

    public void setShowCustomFace(boolean showCustomFace) {
        this.showCustomFace = showCustomFace;
    }

    @Override
    public void onAttach(Activity activity) {
        if (activity instanceof OnEmojiClickListener) {
            this.listener = (OnEmojiClickListener) activity;
        }
        recentManager = RecentEmojiManager.getInstance();
        super.onAttach(activity);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        try {
            if (recentManager.getCollection(RecentEmojiManager.PREFERENCE_NAME) != null) {
                recentlyEmojiList = (ArrayList<Emoji>) recentManager.getCollection(RecentEmojiManager.PREFERENCE_NAME);
            } else {
                recentlyEmojiList = new ArrayList<>();
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_face, container, false);
        faceViewPager = view.findViewById(R.id.face_viewPager);
        faceIndicator = view.findViewById(R.id.face_indicator);
        faceGroup = view.findViewById(R.id.face_view_group);
        initViews();
        return view;
    }

    private void initViews() {
        faceGroups = FaceManager.getFaceGroupList();

        for (int i = 0; i < faceGroups.size(); i++) {
            final FaceGroup group = faceGroups.get(i);
            if (group.getGroupID() != FaceManager.EMOJI_GROUP_ID && !showCustomFace) {
                continue;
            }
            FaceGroupIcon faceBtn = new FaceGroupIcon(getActivity());
            faceBtn.setFaceTabIcon(group.getFaceGroupIconUrl());
            if (i == 0) {
                mCurrentSelected = faceBtn;
                mCurrentGroupIndex = group.getGroupID();
                ArrayList<ChatFace> faces = group.getFaces();
                initViewPager(faces, group.getPageColumnCount(), group.getPageRowCount());
                mCurrentSelected.setSelected(true);
            }
            faceBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mCurrentSelected != v) {
                        mCurrentGroupIndex = group.getGroupID();
                        ArrayList<ChatFace> faces = group.getFaces();
                        mCurrentSelected.setSelected(false);
                        initViewPager(faces, group.getPageColumnCount(), group.getPageRowCount());
                        mCurrentSelected = (FaceGroupIcon) v;
                        mCurrentSelected.setSelected(true);
                    }
                }
            });
            faceGroup.addView(faceBtn);
        }
    }

    private void initViewPager(ArrayList<? extends ChatFace> list, int columns, int rows) {
        intiIndicator(list, columns, rows);
        ViewPagerItems.clear();
        int pageCont = getPagerCount(list, columns, rows);
        for (int i = 0; i < pageCont; i++) {
            ViewPagerItems.add(getViewPagerItem(i, list, columns, rows));
        }
        FaceVPAdapter mVpAdapter = new FaceVPAdapter(ViewPagerItems);
        faceViewPager.setAdapter(mVpAdapter);
        faceViewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            int oldPosition = 0;

            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                faceIndicator.playBy(oldPosition, position);
                oldPosition = position;
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    private void intiIndicator(ArrayList<? extends ChatFace> list, int columns, int rows) {
        faceIndicator.init(getPagerCount(list, columns, rows));
    }

    /**
     * 根据表情数量以及GridView设置的行数和列数计算Pager数量
     * 
     * Calculate the number of Pagers based on the number of expressions and the number of rows and columns set by the GridView
     *
     * @return
     */
    private int getPagerCount(ArrayList<? extends ChatFace> list, int columns, int rows) {
        int count = list.size();
        int dit = 1;
        if (mCurrentGroupIndex > 0)
            dit = 0;
        return count % (columns * rows - dit) == 0 ? count / (columns * rows - dit)
                : count / (columns * rows - dit) + 1;
    }

    private View getViewPagerItem(int position, ArrayList<? extends ChatFace> list, int columns, int rows) {
        LayoutInflater inflater = (LayoutInflater) getActivity().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = inflater.inflate(R.layout.layout_face_grid, null);
        GridView gridview = layout.findViewById(R.id.chart_face_gv);
        gridview.setNumColumns(columns);
        /**
         * 注：因为每一页末尾都有一个删除图标，所以每一页的实际表情columns *　rows　－　1; 空出最后一个位置给删除图标
         * 
         * Because there is a delete icon at the end of each page, the actual emoji of each page columns *　rows　－　1, Empty the last position for the delete icon
         * */
        final List<ChatFace> subList = new ArrayList<>();
        int dit = 1;
        if (mCurrentGroupIndex > 0)
            dit = 0;
        subList.addAll(list.subList(position * (columns * rows - dit),
                (columns * rows - dit) * (position + 1) > list
                        .size() ? list.size() : (columns
                        * rows - dit)
                        * (position + 1)));
        /**
         * 末尾添加删除图标
         * 
         * Add delete icon at the end
         * */
        if (mCurrentGroupIndex == 0 && subList.size() < (columns * rows - dit)) {
            for (int i = subList.size(); i < (columns * rows - dit); i++) {
                subList.add(null);
            }
        }
        if (mCurrentGroupIndex == 0) {
            Emoji deleteEmoji = new Emoji();
            deleteEmoji.setIcon(BitmapFactory.decodeResource(getResources(), R.drawable.face_delete));
            subList.add(deleteEmoji);
        }

        FaceGVAdapter mGvAdapter = new FaceGVAdapter(subList, getActivity());
        gridview.setAdapter(mGvAdapter);
        gridview.setNumColumns(columns);

        gridview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (mCurrentGroupIndex > 0) {
                    listener.onCustomFaceClick(mCurrentGroupIndex, (CustomFace) subList.get(position));
                } else {
                    if (position == columns * rows - 1) {
                        if (listener != null) {
                            listener.onEmojiDelete();
                        }
                        return;
                    }
                    if (listener != null) {
                        listener.onEmojiClick((Emoji) subList.get(position));
                    }
                }
            }
        });

        return gridview;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        try {
            recentManager.putCollection(RecentEmojiManager.PREFERENCE_NAME, recentlyEmojiList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public interface OnEmojiClickListener {
        void onEmojiDelete();

        void onEmojiClick(Emoji emoji);

        void onCustomFaceClick(int groupIndex, CustomFace customFace);
    }

    static class FaceGVAdapter extends BaseAdapter {
        private final List<ChatFace> list;
        private final Context mContext;

        public FaceGVAdapter(List<ChatFace> list, Context mContext) {
            super();
            this.list = list;
            this.mContext = mContext;
        }

        @Override
        public int getCount() {
            // TODO Auto-generated method stub
            return list.size();
        }

        @Override
        public Object getItem(int position) {
            // TODO Auto-generated method stub
            return list.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            ViewHolder holder;
            ChatFace chatFace = list.get(position);
            if (convertView == null) {
                holder = new ViewHolder();
                convertView = LayoutInflater.from(mContext).inflate(R.layout.item_face, null);
                holder.iv = convertView.findViewById(R.id.face_image);
                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) holder.iv.getLayoutParams();
                if (chatFace != null && chatFace.getHeight() != 0 && chatFace.getWidth() != 0) {
                    params.width = chatFace.getWidth();
                    params.height = chatFace.getHeight();
                }
                holder.iv.setLayoutParams(params);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            if (chatFace != null) {
                FaceManager.loadFace(chatFace, holder.iv);
            }
            return convertView;
        }

        class ViewHolder {
            ImageView iv;
        }
    }

    class FaceVPAdapter extends PagerAdapter {
        private List<View> views;

        public FaceVPAdapter(List<View> views) {
            this.views = views;
        }

        @Override
        public void destroyItem(View arg0, int arg1, Object arg2) {
            ((ViewPager) arg0).removeView((View) (arg2));
        }

        @Override
        public int getCount() {
            return views.size();
        }

        @Override
        public Object instantiateItem(View arg0, int arg1) {
            ((ViewPager) arg0).addView(views.get(arg1));
            return views.get(arg1);
        }

        @Override
        public boolean isViewFromObject(View arg0, Object arg1) {
            return (arg0 == arg1);
        }
    }
}
