package com.tencent.liteav.audiosettingkit;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.ArrayList;
import java.util.List;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;


public class AudioEffectPanel extends BottomSheetDialog {

    private static final String TAG = AudioEffectPanel.class.getSimpleName();

    private static final int AUDIO_REVERB_TYPE_0 = 0;
    private static final int AUDIO_REVERB_TYPE_1 = 1;
    private static final int AUDIO_REVERB_TYPE_2 = 2;
    private static final int AUDIO_REVERB_TYPE_3 = 3;
    private static final int AUDIO_REVERB_TYPE_4 = 4;
    private static final int AUDIO_REVERB_TYPE_5 = 5;
    private static final int AUDIO_REVERB_TYPE_6 = 6;
    private static final int AUDIO_REVERB_TYPE_7 = 7;
    private static final int AUDIO_VOICECHANGER_TYPE_0 = 0;
    private static final int AUDIO_VOICECHANGER_TYPE_1 = 1;
    private static final int AUDIO_VOICECHANGER_TYPE_2 = 2;
    private static final int AUDIO_VOICECHANGER_TYPE_3 = 3;
    private static final int AUDIO_VOICECHANGER_TYPE_4 = 4;
    private static final int AUDIO_VOICECHANGER_TYPE_5 = 5;
    private static final int AUDIO_VOICECHANGER_TYPE_6 = 6;
    private static final int AUDIO_VOICECHANGER_TYPE_7 = 7;
    private static final int AUDIO_VOICECHANGER_TYPE_8 = 8;
    private static final int AUDIO_VOICECHANGER_TYPE_9 = 9;
    private static final int AUDIO_VOICECHANGER_TYPE_10 = 10;
    private static final int AUDIO_VOICECHANGER_TYPE_11 = 11;

    private Context                mContext;
    private Button                 mBtnSelectedSong;
    private RecyclerView           mRVAuidoChangeType;
    private RecyclerView           mRVAudioReverbType;
    private RecyclerView           mRVAudioBGM;
    private SeekBar                mSbMicVolume;
    private SeekBar                mSbBGMVolume;
    private SeekBar                mSbPitchLevel;
    private RecyclerViewAdapter    mChangerRVAdapter;
    private RecyclerViewAdapter    mReverbRVAdapter;
    private BGMRecyclerViewAdapter mBGMRVAdapter;
    private List<ItemEntity>       mChangerItemEntityList;
    private List<ItemEntity>       mReverbItemEntityList;
    private ImageView              mIVBGMBack;
    private LinearLayout mMainAudioEffectPanel;
    private LinearLayout mBGMPanel;
    private List<BGMItemEntity> mBGMItemEntityList;
    private Button   mTvClosePanel;
    private TextView mTvBGMVolume;
    private TextView mTvPitchLevel;
    private TextView mTvMicVolume;
    private TextView mTvActor;
    private TextView mTvStartTime;
    private TextView mTvTotalTime;
    private TextView mTvBGM;
    private LinearLayout mLayoutSelectBGM;
    private LinearLayout mMainPanel;
    private ImageButton mImgbtnBGMPlay;
    private TXAudioEffectManager mAudioEffectManager;
    private BGMListener mBGMPlayListenr;
    private static final String ONLINE_BGM_FIRST = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic1.mp3";
    private static final String ONLINE_BGM_SECOND = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic2.mp3";
    private static final String ONLINE_BGM_THIRD = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic3.mp3";

    private int     mBGMId     = -1;
    private float   mPitch     = 0;
    private boolean mIsPlaying = false;
    private boolean mIsPause   = false;
    private boolean mIsPlayEnd = false;

    private int     mBGMVolume = 100;

    private int mVoiceChangerPosition = 0;
    private int mVoiceReverbPosition = 0;

    public AudioEffectPanel(@NonNull Context context) {
        super(context);
        setContentView(R.layout.audio_effect_panel);
        mContext = context;
        initView();
    }


    private void initView() {

        mMainPanel = (LinearLayout) findViewById(R.id.ll_panel);
        mTvClosePanel = (Button) findViewById(R.id.tv_close_panel);
        mTvBGMVolume =  (TextView) findViewById(R.id.tv_bgm_volume);
        mTvMicVolume = (TextView) findViewById(R.id.tv_mic_volume);
        mTvPitchLevel = (TextView) findViewById(R.id.tv_pitch_level);
        mTvActor = (TextView) findViewById(R.id.tv_actor);
        mTvStartTime = (TextView) findViewById(R.id.tv_bgm_start_time);
        mTvTotalTime = (TextView) findViewById(R.id.tv_bgm_end_time);
        mImgbtnBGMPlay = (ImageButton) findViewById(R.id.ib_audio_bgm_play);
        mTvBGM = (TextView) findViewById(R.id.tv_bgm);
        mLayoutSelectBGM = (LinearLayout) findViewById(R.id.ll_select_bgm);
        mLayoutSelectBGM.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(VISIBLE);
            }
        });

        mTvClosePanel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                if (mAudioEffectPanelHideListener != null) {
                    mAudioEffectPanelHideListener.onClosePanel();
                }
            }
        });

        mBtnSelectedSong = (Button) findViewById(R.id.audio_btn_select_song);
        mBtnSelectedSong.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(VISIBLE);
            }
        });
        mSbMicVolume = (SeekBar) findViewById(R.id.sb_mic_volume);
        mSbMicVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvMicVolume.setText(progress + "");
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceCaptureVolume(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        mSbBGMVolume = (SeekBar) findViewById(R.id.sb_bgm_volume);
        mSbBGMVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvBGMVolume.setText(progress + "");
                mBGMVolume = progress;
                if (mAudioEffectManager != null && mBGMId != -1) {
                    mAudioEffectManager.setMusicPlayoutVolume(mBGMId, progress);
                    mAudioEffectManager.setMusicPublishVolume(mBGMId, progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        mSbPitchLevel = (SeekBar) findViewById(R.id.sb_pitch_level);
        mSbPitchLevel.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                float pitch = ((progress - 50) / (float) 50);
                mTvPitchLevel.setText(pitch + "");
                mPitch = pitch;
                if (mAudioEffectManager != null && mBGMId != -1) {
                    Log.d(TAG, "setMusicPitch: mBGMId -> " + mBGMId + ", pitch -> " + pitch);
                    mAudioEffectManager.setMusicPitch(mBGMId, pitch);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        mIVBGMBack = (ImageView) findViewById(R.id.iv_bgm_back);
        mIVBGMBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(VISIBLE);
                mBGMPanel.setVisibility(GONE);
            }
        });

        mMainAudioEffectPanel = (LinearLayout) findViewById(R.id.audio_main_ll);
        mBGMPanel = (LinearLayout) findViewById(R.id.audio_main_bgm);

        mRVAudioReverbType = (RecyclerView) findViewById(R.id.audio_reverb_type_rv);
        mRVAuidoChangeType = (RecyclerView) findViewById(R.id.audio_change_type_rv);
        mRVAudioBGM = (RecyclerView) findViewById(R.id.audio_bgm_rv);

        mChangerItemEntityList = createAudioChangeItems();
        mReverbItemEntityList = createReverbItems();
        mBGMItemEntityList = createBGMItems();
        // 选变声
        mChangerRVAdapter = new RecyclerViewAdapter(mContext, mChangerItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                int type = mChangerItemEntityList.get(position).mType;
                Log.d(TAG, "select changer type " + type);
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceChangerType(translateChangerType(type));
                }
                mChangerItemEntityList.get(position).mIsSelected = true;
                mChangerItemEntityList.get(mVoiceChangerPosition).mIsSelected = false;
                mVoiceChangerPosition = position;
                mChangerRVAdapter.notifyDataSetChanged();
            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRVAuidoChangeType.setLayoutManager(layoutManager);
        mRVAuidoChangeType.setAdapter(mChangerRVAdapter);
        // 选混响
        mReverbRVAdapter = new RecyclerViewAdapter(mContext, mReverbItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                int type = mReverbItemEntityList.get(position).mType;
                Log.d(TAG, "select reverb type " + type);
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceReverbType(translateReverbType(type));
                }
                mReverbItemEntityList.get(position).mIsSelected = true;
                mReverbItemEntityList.get(mVoiceReverbPosition).mIsSelected = false;
                mVoiceReverbPosition = position;
                mReverbRVAdapter.notifyDataSetChanged();
            }
        });

        LinearLayoutManager reverbLayoutManager = new LinearLayoutManager(mContext);
        reverbLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRVAudioReverbType.setLayoutManager(reverbLayoutManager);
        mRVAudioReverbType.setAdapter(mReverbRVAdapter);

        // 选BGM
        mBGMRVAdapter = new BGMRecyclerViewAdapter(mContext, mBGMItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {

            }
        });
        mRVAudioBGM.setLayoutManager(new LinearLayoutManager(mContext));
        mRVAudioBGM.setAdapter(mBGMRVAdapter);
    }

    private TXAudioEffectManager.TXVoiceChangerType translateChangerType(int type) {
        TXAudioEffectManager.TXVoiceChangerType changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
        switch (type) {
            case AUDIO_VOICECHANGER_TYPE_0:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
            case AUDIO_VOICECHANGER_TYPE_1:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
                break;
            case AUDIO_VOICECHANGER_TYPE_2:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
                break;
            case AUDIO_VOICECHANGER_TYPE_3:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
                break;
            case AUDIO_VOICECHANGER_TYPE_4:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
                break;
            case AUDIO_VOICECHANGER_TYPE_5:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
                break;
            case AUDIO_VOICECHANGER_TYPE_6:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
                break;
            case AUDIO_VOICECHANGER_TYPE_7:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
                break;
            case AUDIO_VOICECHANGER_TYPE_8:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
                break;
            case AUDIO_VOICECHANGER_TYPE_9:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
                break;
            case AUDIO_VOICECHANGER_TYPE_10:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
                break;
            case AUDIO_VOICECHANGER_TYPE_11:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
                break;
        }
        return changerType;
    }

    private TXAudioEffectManager.TXVoiceReverbType translateReverbType(int type) {
        TXAudioEffectManager.TXVoiceReverbType reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
        switch (type) {
            case AUDIO_REVERB_TYPE_0:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
            case AUDIO_REVERB_TYPE_1:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
                break;
            case AUDIO_REVERB_TYPE_2:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
                break;
            case AUDIO_REVERB_TYPE_3:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
                break;
            case AUDIO_REVERB_TYPE_4:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
                break;
            case AUDIO_REVERB_TYPE_5:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
                break;
            case AUDIO_REVERB_TYPE_6:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
                break;
            case AUDIO_REVERB_TYPE_7:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_7;
                break;
        }
        return reverbType;
    }


    public void unInit() {
        if (mAudioEffectManager != null) {
            mAudioEffectManager.stopPlayMusic(mBGMId);
            mAudioEffectManager = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
        }
        mIsPlaying = false;
        mIsPause = false;
        mIsPlayEnd = false;
        mBGMPlayListenr = null;
    }

    public void stopPlay() {
        if (mAudioEffectManager != null) {
            mAudioEffectManager.stopPlayMusic(mBGMId);
        }
    }

    private List<ItemEntity> createAudioChangeItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_original), R.drawable.live_ic_none_normal, AUDIO_VOICECHANGER_TYPE_0));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_child), R.drawable.audio_effect_setting_changetype_child, AUDIO_VOICECHANGER_TYPE_1));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_luoli), R.drawable.audio_effect_setting_changetype_luoli, AUDIO_VOICECHANGER_TYPE_2));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_dashu), R.drawable.audio_effect_setting_changetype_dashu, AUDIO_VOICECHANGER_TYPE_3));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_metal), R.drawable.audio_effect_setting_changetype_metal, AUDIO_VOICECHANGER_TYPE_4));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_sick), R.drawable.audio_effect_setting_changetype_sick, AUDIO_VOICECHANGER_TYPE_5));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_foreign), R.drawable.audio_effect_setting_changetype_foreign, AUDIO_VOICECHANGER_TYPE_6));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_kunsou), R.drawable.audio_effect_setting_changetype_kunsou, AUDIO_VOICECHANGER_TYPE_7));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_feizai), R.drawable.audio_effect_setting_changetype_feizai, AUDIO_VOICECHANGER_TYPE_8));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_dianliu), R.drawable.audio_effect_setting_changetype_dianliu, AUDIO_VOICECHANGER_TYPE_9));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_machine), R.drawable.audio_effect_setting_changetype_machine, AUDIO_VOICECHANGER_TYPE_10));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_kongling), R.drawable.audio_effect_setting_changetype_kongling, AUDIO_VOICECHANGER_TYPE_11));
        return list;
    }

    private List<ItemEntity> createReverbItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_origin), R.drawable.live_ic_none_normal, AUDIO_REVERB_TYPE_0));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_ktv), R.drawable.audio_effect_setting_reverbtype_ktv, AUDIO_REVERB_TYPE_1));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_room), R.drawable.audio_effect_setting_reverbtype_room, AUDIO_REVERB_TYPE_2));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_meeting), R.drawable.audio_effect_setting_reverbtype_meeting, AUDIO_REVERB_TYPE_3));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_lowdeep), R.drawable.audio_effect_setting_reverbtype_lowdeep, AUDIO_REVERB_TYPE_4));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_hongliang), R.drawable.audio_effect_setting_reverbtype_hongliang, AUDIO_REVERB_TYPE_5));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_heavymetal), R.drawable.audio_effect_setting_reverbtype_heavymetal, AUDIO_REVERB_TYPE_6));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_cixing), R.drawable.audio_effect_setting_reverbtype_cixing, AUDIO_REVERB_TYPE_7));
        return list;
    }

    public class ItemEntity {
        public String mTitle;
        public int    mIconId;
        public int    mType;
        public boolean mIsSelected = false;

        public ItemEntity(String title, int iconId, int type) {
            mTitle = title;
            mIconId = iconId;
            mType = type;
        }
    }

    public class RecyclerViewAdapter extends
            RecyclerView.Adapter<RecyclerViewAdapter.ViewHolder> {

        private Context              context;
        private List<ItemEntity> list;
        private OnItemClickListener onItemClickListener;

        public RecyclerViewAdapter(Context context, List<ItemEntity> list,
                                   OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private CircleImageView mItemImg;
            private TextView mTitleTv;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final ItemEntity model, final int position,
                             final OnItemClickListener listener) {
                mItemImg.setImageResource(model.mIconId);
                mTitleTv.setText(model.mTitle);
                if (model.mIsSelected) {
                    mItemImg.setBorderWidth(4);
                    mItemImg.setBorderColor(mContext.getResources().getColor(R.color.live_primary));
                    mTitleTv.setTextColor(mContext.getResources().getColor(R.color.live_dark_black));
                } else {
                    mItemImg.setBorderWidth(0);
                    mItemImg.setBorderColor(mContext.getResources().getColor(android.R.color.transparent));
                    mTitleTv.setTextColor(mContext.getResources().getColor(R.color.live_light_black));
                }
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(position);
                    }
                });
            }

            private void initView(final View itemView) {
                mItemImg = (CircleImageView) itemView.findViewById(R.id.img_item);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.audio_main_entry_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(view);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, final int position) {
            ItemEntity item = list.get(position);
            holder.bind(item, position, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

    }

    private List<BGMItemEntity> createBGMItems() {
        List<BGMItemEntity> list = new ArrayList<>();
        list.add(new BGMItemEntity("环绕声测试1", ONLINE_BGM_FIRST, "佚名"));
        list.add(new BGMItemEntity("环绕声测试2", ONLINE_BGM_SECOND, "佚名"));
        list.add(new BGMItemEntity("环绕声测试3", ONLINE_BGM_THIRD, "佚名"));
        return list;
    }

    public class BGMItemEntity {
        public String mTitle;
        public String mActor;
        public String mPath;

        public BGMItemEntity(String title, String path, String actor) {
            mTitle = title;
            mPath = path;
            mActor = actor;
        }
    }

    public class BGMRecyclerViewAdapter extends
            RecyclerView.Adapter<BGMRecyclerViewAdapter.ViewHolder> {

        private Context mContext;
        private List<BGMItemEntity> list;
        private OnItemClickListener onItemClickListener;

        public BGMRecyclerViewAdapter(Context context, List<BGMItemEntity> list,
                                        OnItemClickListener onItemClickListener) {
            this.mContext = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private Button   mItemImg;
            private TextView mTitleTv;
            private TextView mTextActor;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final BGMItemEntity model, final int positon,
                             final OnItemClickListener listener) {
                mTitleTv.setText(model.mTitle);
                mTextActor.setText(model.mActor);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        handleBGM(positon, model);
                    }
                });
                mItemImg.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        handleBGM(positon, model);
                    }
                });
            }

            private void initView(final View itemView) {
                mItemImg = (Button) itemView.findViewById(R.id.iv_bgm_play);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_bgm_title);
                mTextActor = (TextView) itemView.findViewById(R.id.tv_bgm_actor);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.audio_bgm_entry_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(view);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            BGMItemEntity item = list.get(position);
            holder.bind(item, position, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    private class BGMListener implements TXAudioEffectManager.TXMusicPlayObserver {

        @Override
        public void onStart(int i, int i1) {

        }

        @Override
        public void onPlayProgress(int id, final long curPtsMS, long durationMS) {
//            Log.d(TAG, "onPlayProgress id " + id + ", curPtsMS = " + curPtsMS + ", durationMS " + durationMS);
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mTvStartTime.setText(formattedTime(curPtsMS /1000) + "");
                }
            });
        }

        @Override
        public void onComplete(int id, int i1) {
            Log.d(TAG, "onMusicPlayFinish id " + id);
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    // 播放完成更新状态
                    mImgbtnBGMPlay.setVisibility(VISIBLE);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_play);
                    mIsPlayEnd = true;
                }
            });
        }
    }

    public void showAudioPanel() {
        mBGMPanel.setVisibility(GONE);
        mMainAudioEffectPanel.setVisibility(VISIBLE);
    }

    public void hideAudioPanel() {
        mBGMPanel.setVisibility(GONE);
        mMainAudioEffectPanel.setVisibility(GONE);
    }

    public void setAudioEffectManager(TXAudioEffectManager audioEffectManager) {
        mAudioEffectManager = audioEffectManager;
    }

    public void reset() {
        mAudioEffectManager.stopPlayMusic(mBGMId);
        mBGMId = -1;
        mIsPlaying = false;
        mIsPause = false;
        mIsPlayEnd = false;

        mSbMicVolume.setProgress(100);
        mTvMicVolume.setText("100");

        mBGMVolume = 100;
        mSbBGMVolume.setProgress(mBGMVolume);
        mTvBGMVolume.setText(mBGMVolume + "");

        mPitch = 0;
        mSbPitchLevel.setProgress(50);
        mTvPitchLevel.setText("50");

        mBtnSelectedSong.setVisibility(VISIBLE);
        mTvBGM.setVisibility(VISIBLE);
        mTvActor.setVisibility(GONE);
        mTvActor.setText("");
        mTvStartTime.setVisibility(GONE);
        mTvTotalTime.setVisibility(GONE);
        mImgbtnBGMPlay.setVisibility(GONE);

        mChangerItemEntityList.get(mVoiceChangerPosition).mIsSelected = false;
        mChangerRVAdapter.notifyDataSetChanged();
        mVoiceChangerPosition = 0;

        mReverbItemEntityList.get(mVoiceReverbPosition).mIsSelected = false;
        mReverbRVAdapter.notifyDataSetChanged();
        mVoiceReverbPosition = 0;

        if (mAudioEffectManager != null) {
            Log.d(TAG, "select changer type1 " + translateChangerType(mVoiceChangerPosition));
            mAudioEffectManager.setVoiceChangerType(translateChangerType(mVoiceChangerPosition));
            mAudioEffectManager.setVoiceReverbType(translateReverbType(mVoiceReverbPosition));
        }
    }

    public void pauseBGM() {
        if (!mIsPlaying) {
            return;
        }
        mAudioEffectManager.pausePlayMusic(mBGMId);
        mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_play);
        mIsPlaying = false;
    }

    public void resumeBGM() {
        Log.i(TAG, "resumeBGM: mIsPlayEnd -> " + mIsPlayEnd + ", mIsPlaying -> " + mIsPlaying);
        if (!mIsPlayEnd && !mIsPlaying && !mIsPause) {
            mAudioEffectManager.resumePlayMusic(mBGMId);
            mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
            mIsPlaying = true;
        }
    }

    private void handleBGM(int position, final BGMItemEntity model) {
        Log.d(TAG, "handleBGM position " + position + ", mAudioEffectManager " + mAudioEffectManager);
        if (mAudioEffectManager == null) {
            return;
        }
        if (mBGMId != -1) { // 已开始播放音乐，需要先停止上一次正在播放的音乐
            mAudioEffectManager.stopPlayMusic(mBGMId);
        }
        mBGMId = position;
        // 开始播放音乐时，无论是否首次均需重新设置变调和音量，因为音乐id发生了变化
        mAudioEffectManager.setMusicPitch(position, mPitch);
        mAudioEffectManager.setMusicPlayoutVolume(position, mBGMVolume);
        mAudioEffectManager.setMusicPublishVolume(position, mBGMVolume);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mBGMPanel.setVisibility(GONE);
                mMainAudioEffectPanel.setVisibility(VISIBLE);
                mTvBGM.setVisibility(GONE);
                mBtnSelectedSong.setVisibility(GONE);

                mTvActor.setVisibility(VISIBLE);
                mTvActor.setText(model.mTitle);
                mTvStartTime.setVisibility(VISIBLE);
                mTvTotalTime.setVisibility(VISIBLE);
                mTvTotalTime.setText("/" + formattedTime(mAudioEffectManager.getMusicDurationInMS(model.mPath)/1000) + "");
                mImgbtnBGMPlay.setVisibility(VISIBLE);
                mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
            }
        });
        final TXAudioEffectManager.AudioMusicParam audioMusicParam = new TXAudioEffectManager.AudioMusicParam(position, model.mPath);
        audioMusicParam.publish = true; //上行
        mAudioEffectManager.startPlayMusic(audioMusicParam);
        mBGMPlayListenr = new BGMListener();
        mAudioEffectManager.setMusicObserver(mBGMId, mBGMPlayListenr);
        mIsPlaying = true;
        mIsPause = false;

        mImgbtnBGMPlay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsPlayEnd) {
                    mAudioEffectManager.startPlayMusic(audioMusicParam);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
                    mIsPlayEnd = false;
                    mIsPlaying = true;
                    mIsPause = false;
                } else if (mIsPlaying) {
                    mAudioEffectManager.pausePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_play);
                    mIsPlaying = false;
                    mIsPause = true;
                } else {
                    mAudioEffectManager.resumePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
                    mIsPlaying = true;
                    mIsPause = false;
                }
            }
        });
    }

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private OnAudioEffectPanelHideListener mAudioEffectPanelHideListener;

    public void setOnAudioEffectPanelHideListener(OnAudioEffectPanelHideListener listener) {
        mAudioEffectPanelHideListener = listener;
    }

    public interface OnAudioEffectPanelHideListener {
        void onClosePanel();
    }

    public void setPanelBackgroundColor(int color) {
        mMainPanel.setBackgroundColor(color);
    }

    public void setPanelBackgroundResource(int resId) {
        mMainPanel.setBackgroundResource(resId);
    }

    public void setPanelBackgroundDrawable(Drawable drawable) {
        mMainPanel.setBackground(drawable);
    }

    public void initPanelDefaultBackground() {
        mMainPanel.setBackground(mContext.getResources().getDrawable(R.drawable.audio_effect_setting_bg_gradient));
    }

    private String formattedTime(long second) {
        String hs, ms, ss, formatTime;

        long h, m, s;
        h = second / 3600;
        m = (second % 3600) / 60;
        s = (second % 3600) % 60;
        if (h < 10) {
            hs = "0" + h;
        } else {
            hs = "" + h;
        }

        if (m < 10) {
            ms = "0" + m;
        } else {
            ms = "" + m;
        }

        if (s < 10) {
            ss = "0" + s;
        } else {
            ss = "" + s;
        }
        if (h > 0) {
            formatTime = hs + ":" + ms + ":" + ss;
        } else {
            formatTime = ms + ":" + ss;
        }
        return formatTime;
    }
}
