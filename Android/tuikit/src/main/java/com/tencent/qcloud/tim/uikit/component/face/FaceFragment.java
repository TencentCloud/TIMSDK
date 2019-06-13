package com.tencent.qcloud.tim.uikit.component.face;

import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.SoftKeyBoardUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class FaceFragment extends BaseInputFragment implements View.OnClickListener {

    public static FaceFragment Instance() {
        FaceFragment instance = new FaceFragment();
        Bundle bundle = new Bundle();
        instance.setArguments(bundle);
        return instance;
    }

    ViewPager faceViewPager;
    EmojiIndicatorView faceIndicator;
    FaceGroupIcon faceFirstSetTv;
    FaceGroupIcon mCurrentSelected;
    LinearLayout faceGroup;
    private int mCurrentGroupIndex = 0;

    ArrayList<View> ViewPagerItems = new ArrayList<>();
    ArrayList<Emoji> emojiList;
    ArrayList<Emoji> recentlyEmojiList;
    ArrayList<FaceGroup> customFaces;
    private int columns = 7;
    private int rows = 3;
    private int vMargin = 0;
    private OnEmojiClickListener listener;
    private RecentEmojiManager recentManager;

    public void setListener(OnEmojiClickListener listener) {
        this.listener = listener;
    }

    @Override
    public void onAttach(Activity activity) {
        if (activity instanceof OnEmojiClickListener) {
            this.listener = (OnEmojiClickListener) activity;
        }
        recentManager = RecentEmojiManager.make(activity);
        super.onAttach(activity);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        emojiList = FaceManager.getEmojiList();
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
        ViewGroup.LayoutParams params = view.getLayoutParams();
        params.height = SoftKeyBoardUtil.getSoftKeyBoardHeight();
        view.setLayoutParams(params);
        faceViewPager = view.findViewById(R.id.face_viewPager);
        faceIndicator = view.findViewById(R.id.face_indicator);
        faceFirstSetTv = view.findViewById(R.id.face_first_set);
        faceGroup = view.findViewById(R.id.face_view_group);
        initViews();
        return view;
    }

    private void initViews() {
        initViewPager(emojiList, 7, 3);
        mCurrentSelected = faceFirstSetTv;
        faceFirstSetTv.setSelected(true);
        faceFirstSetTv.setOnClickListener(this);
        customFaces = FaceManager.getCustomFaceList();

        int width = ScreenUtil.getPxByDp(70);
        for (int i = 0; i < customFaces.size(); i++) {
            final FaceGroup group = customFaces.get(i);
            FaceGroupIcon faceBtn = new FaceGroupIcon(getActivity());
            faceBtn.setFaceTabIcon(group.getGroupIcon());

            faceBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mCurrentSelected != v) {
                        mCurrentGroupIndex = group.getGroupId();
                        ArrayList<Emoji> faces = group.getFaces();
                        mCurrentSelected.setSelected(false);
                        initViewPager(faces, group.getPageColumnCount(), group.getPageRowCount());
                        mCurrentSelected = (FaceGroupIcon) v;
                        mCurrentSelected.setSelected(true);
                    }

                }
            });
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(width, LinearLayout.LayoutParams.MATCH_PARENT);
            faceGroup.addView(faceBtn, params);

        }


    }

    private void initViewPager(ArrayList<Emoji> list, int columns, int rows) {
        this.columns = columns;
        this.rows = rows;
        if (list.size() > 0) {
            vMargin = (SoftKeyBoardUtil.getSoftKeyBoardHeight() - (ScreenUtil.getPxByDp(40 + 20) + list.get(0).getHeight() * rows)) / 4;
        }

        intiIndicator(list);
        ViewPagerItems.clear();
        int pageCont = getPagerCount(list);
        for (int i = 0; i < pageCont; i++) {
            ViewPagerItems.add(getViewPagerItem(i, list));
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

    private void intiIndicator(ArrayList<Emoji> list) {
        faceIndicator.init(getPagerCount(list));
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.face_first_set) {
           /* if (faceIndicator.getVisibility() == View.GONE) {
                faceIndicator.setVisibility(View.VISIBLE);
            }*/
            if (mCurrentSelected != v) {
                mCurrentGroupIndex = 0;
                mCurrentSelected.setSelected(false);
                mCurrentSelected = (FaceGroupIcon) v;
                initViewPager(emojiList, 7, 3);
                mCurrentSelected.setSelected(true);

            }

        }
    }

    /**
     * 根据表情数量以及GridView设置的行数和列数计算Pager数量
     *
     * @return
     */
    private int getPagerCount(ArrayList<Emoji> list) {
        int count = list.size();
        int dit = 1;
        if (mCurrentGroupIndex > 0)
            dit = 0;
        return count % (columns * rows - dit) == 0 ? count / (columns * rows - dit)
                : count / (columns * rows - dit) + 1;
    }

    private View getViewPagerItem(int position, ArrayList<Emoji> list) {
        LayoutInflater inflater = (LayoutInflater) getActivity().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = inflater.inflate(R.layout.layout_face_grid, null);//表情布局
        GridView gridview = layout.findViewById(R.id.chart_face_gv);
        /**
         * 注：因为每一页末尾都有一个删除图标，所以每一页的实际表情columns *　rows　－　1; 空出最后一个位置给删除图标
         * */
        final List<Emoji> subList = new ArrayList<>();
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
        // 单击表情执行的操作
        gridview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (mCurrentGroupIndex > 0) {
                    listener.onCustomFaceClick(mCurrentGroupIndex, subList.get(position));
                } else {
                    if (position == columns * rows - 1) {
                        if (listener != null) {
                            listener.onEmojiDelete();
                        }
                        return;
                    }
                    if (listener != null) {
                        listener.onEmojiClick(subList.get(position));
                    }
                }


                //insertToRecentList(subList.get(position));
            }
        });

        return gridview;
    }

    private void insertToRecentList(Emoji emoji) {
        if (emoji != null) {
            if (recentlyEmojiList.contains(emoji)) {
                //如果已经有该表情，就把该表情放到第一个位置
                int index = recentlyEmojiList.indexOf(emoji);
                Emoji emoji0 = recentlyEmojiList.get(0);
                recentlyEmojiList.set(index, emoji0);
                recentlyEmojiList.set(0, emoji);
                return;
            }
            if (recentlyEmojiList.size() == (rows * columns - 1)) {
                //去掉最后一个
                recentlyEmojiList.remove(rows * columns - 2);
            }
            recentlyEmojiList.add(0, emoji);
        }
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


    class FaceGVAdapter extends BaseAdapter {
        private List<Emoji> list;
        private Context mContext;

        public FaceGVAdapter(List<Emoji> list, Context mContext) {
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
            Emoji emoji = list.get(position);
            if (convertView == null) {
                holder = new ViewHolder();
                convertView = LayoutInflater.from(mContext).inflate(R.layout.item_face, null);
                holder.iv = convertView.findViewById(R.id.face_image);
                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) holder.iv.getLayoutParams();
                if (emoji != null) {
                    params.width = emoji.getWidth();
                    params.height = emoji.getHeight();
                }
                if (position / columns == 0) {
                    params.setMargins(0, vMargin, 0, 0);
                } else if (rows == 2) {
                    params.setMargins(0, vMargin, 0, 0);
                } else {
                    if (position / columns < rows - 1) {
                        params.setMargins(0, vMargin, 0, vMargin);
                    } else {
                        params.setMargins(0, 0, 0, vMargin);
                    }
                }

                holder.iv.setLayoutParams(params);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            if (emoji != null) {
                holder.iv.setImageBitmap(emoji.getIcon());
            }
            return convertView;
        }

        class ViewHolder {
            ImageView iv;
        }
    }

    class FaceVPAdapter extends PagerAdapter {
        // 界面列表
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

        // 初始化arg1位置的界面
        @Override
        public Object instantiateItem(View arg0, int arg1) {
            ((ViewPager) arg0).addView(views.get(arg1));
            return views.get(arg1);
        }

        // 判断是否由对象生成界
        @Override
        public boolean isViewFromObject(View arg0, Object arg1) {
            return (arg0 == arg1);
        }
    }

    public interface OnEmojiClickListener {
        void onEmojiDelete();

        void onEmojiClick(Emoji emoji);

        void onCustomFaceClick(int groupIndex, Emoji emoji);
    }
}
