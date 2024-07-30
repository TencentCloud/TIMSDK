package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.WheelPicker;
import java.util.List;

public interface IWheelPicker {
    void setVisibleItemCount(int count);

    void setOnItemSelectedListener(WheelPicker.OnItemSelectedListener listener);

    int getSelectedItemPosition();

    void setSelectedItemPosition(int position);

    int getCurrentItemPosition();

    void setData(List data);

    void setOnWheelChangeListener(WheelPicker.OnWheelChangeListener listener);

}
