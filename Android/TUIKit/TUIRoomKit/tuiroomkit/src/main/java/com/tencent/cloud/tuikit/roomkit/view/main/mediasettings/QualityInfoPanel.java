package com.tencent.cloud.tuikit.roomkit.view.main.mediasettings;

import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;

import android.content.Context;
import android.content.res.Configuration;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.tencent.trtc.TRTCStatistics;

import java.util.Map;

public class QualityInfoPanel extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder,
        ConferenceEventCenter.RoomEngineEventResponder {
    private static final String NETWORK_DELAY_UNITS       = "ms";
    private static final String PACKET_LOOS_RATE_UNITS    = "%";
    private static final String BITRATE_UNITS             = "kbps";
    private static final String VIDEO_FRAME_UNITS         = "FPS";
    private static final String VIDEO_RESOLUTION_UNITS    = "X";
    private static final String STATISTICS_ORIGINAL_VALUE = "0";

    private TextView mTextNetworkDelay;
    private TextView mTextPacketLossRateUpload;
    private TextView mTextPacketLossRateDownload;
    private TextView mTextAudioBitrateUpload;
    private TextView mTextAudioBitrateDownload;
    private TextView mTextVideoResolutionUpload;
    private TextView mTextVideoResolutionDownload;
    private TextView mTextVideoFrameDownload;
    private TextView mTextVideoFrameUpload;
    private TextView mTextVideoBitrateUpload;
    private TextView mTextVideoBitrateDownload;


    private void setQualityInfo(TRTCStatistics statistics) {
        mTextNetworkDelay.setText(String.valueOf(statistics.rtt) + NETWORK_DELAY_UNITS);
        mTextPacketLossRateUpload.setText(String.valueOf(statistics.upLoss) + PACKET_LOOS_RATE_UNITS);
        mTextPacketLossRateDownload.setText(String.valueOf(statistics.downLoss) + PACKET_LOOS_RATE_UNITS);

        // audio and video upload (only count big stream for audio bitrate 、 video bitrate 、 resolution and frame rate.)
        for (TRTCStatistics.TRTCLocalStatistics local : statistics.localArray) {
            if (local.streamType == TRTC_VIDEO_STREAM_TYPE_BIG) {
                mTextAudioBitrateUpload.setText(String.valueOf(local.audioBitrate) + BITRATE_UNITS);
                mTextVideoBitrateUpload.setText(String.valueOf(local.videoBitrate) + BITRATE_UNITS);
                mTextVideoFrameUpload.setText(String.valueOf(local.frameRate) + VIDEO_FRAME_UNITS);
                mTextVideoResolutionUpload.setText(String.valueOf(local.width) + VIDEO_RESOLUTION_UNITS + String.valueOf(local.height));
            }
        }

        // audio and video download.
        int audioBitrateDownload = 0;
        int videoBitrateDownload = 0;
        int videoFrameDownload = 0;
        int videoResolutionWidthDownload = 0;
        int videoResolutionHeightDownload = 0;
        for (TRTCStatistics.TRTCRemoteStatistics remote : statistics.remoteArray) {
            if (remote.frameRate > videoFrameDownload) {
                videoFrameDownload = remote.frameRate;
            }
            if ((remote.width * remote.height) > (videoResolutionWidthDownload * videoResolutionHeightDownload)) {
                videoResolutionWidthDownload = remote.width;
                videoResolutionHeightDownload = remote.height;
            }
            audioBitrateDownload += remote.audioBitrate;
            videoBitrateDownload += remote.videoBitrate;
        }
        mTextVideoFrameDownload.setText(String.valueOf(videoFrameDownload) + VIDEO_FRAME_UNITS);
        mTextVideoResolutionDownload.setText(String.valueOf(videoResolutionWidthDownload)
                + VIDEO_RESOLUTION_UNITS
                + String.valueOf(videoResolutionHeightDownload));
        mTextAudioBitrateDownload.setText(String.valueOf(audioBitrateDownload) + BITRATE_UNITS);
        mTextVideoBitrateDownload.setText(String.valueOf(videoBitrateDownload) + BITRATE_UNITS);
    }

    public QualityInfoPanel(@NonNull Context context) {
        super(context);
        ConferenceEventCenter.getInstance().subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
        ConferenceEventCenter.getInstance().subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ON_STATISTICS, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ON_STATISTICS, this);
    }


    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key) && params != null) {
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            changeConfiguration(configuration);
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomEngineEvent.ON_STATISTICS.equals(event) && params != null) {
            TRTCStatistics statistics = (TRTCStatistics) params.get(ConferenceEventConstant.KEY_ON_STATISTICS);
            if (statistics != null) {
                setQualityInfo(statistics);
            }
        }
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_quality_info_panel;
    }

    @Override
    protected void initView() {
        mTextNetworkDelay = findViewById(R.id.tuiroomkit_network_delay);
        mTextPacketLossRateUpload = findViewById(R.id.tuiroomkit_packet_loss_rate_upload);
        mTextPacketLossRateDownload = findViewById(R.id.tuiroomkit_packet_loss_rate_download);
        mTextNetworkDelay.setText(STATISTICS_ORIGINAL_VALUE + NETWORK_DELAY_UNITS);
        mTextPacketLossRateUpload.setText(STATISTICS_ORIGINAL_VALUE + PACKET_LOOS_RATE_UNITS);
        mTextPacketLossRateDownload.setText(STATISTICS_ORIGINAL_VALUE + PACKET_LOOS_RATE_UNITS);

        mTextAudioBitrateUpload = findViewById(R.id.tuiroomkit_audio_bitrate_upload);
        mTextAudioBitrateDownload = findViewById(R.id.tuiroomkit_audio_bitrate_download);
        mTextAudioBitrateUpload.setText(STATISTICS_ORIGINAL_VALUE + BITRATE_UNITS);
        mTextAudioBitrateDownload.setText(STATISTICS_ORIGINAL_VALUE + BITRATE_UNITS);

        mTextVideoResolutionUpload = findViewById(R.id.tuiroomkit_video_resolution_upload);
        mTextVideoResolutionDownload = findViewById(R.id.tuiroomkit_video_resolution_download);
        mTextVideoFrameDownload = findViewById(R.id.tuiroomkit_video_frame_download);
        mTextVideoFrameUpload = findViewById(R.id.tuiroomkit_video_frame_upload);
        mTextVideoBitrateUpload = findViewById(R.id.tuiroomkit_video_bitrate_upload);
        mTextVideoBitrateDownload = findViewById(R.id.tuiroomkit_video_bitrate_download);
        mTextVideoResolutionUpload.setText(STATISTICS_ORIGINAL_VALUE + VIDEO_RESOLUTION_UNITS + STATISTICS_ORIGINAL_VALUE);
        mTextVideoResolutionDownload.setText(STATISTICS_ORIGINAL_VALUE + VIDEO_RESOLUTION_UNITS + STATISTICS_ORIGINAL_VALUE);
        mTextVideoFrameDownload.setText(STATISTICS_ORIGINAL_VALUE + VIDEO_FRAME_UNITS);
        mTextVideoFrameUpload.setText(STATISTICS_ORIGINAL_VALUE + VIDEO_FRAME_UNITS);
        mTextVideoBitrateUpload.setText(STATISTICS_ORIGINAL_VALUE + BITRATE_UNITS);
        mTextVideoBitrateDownload.setText(STATISTICS_ORIGINAL_VALUE + BITRATE_UNITS);
    }

}
