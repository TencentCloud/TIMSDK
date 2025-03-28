package com.tencent.cloud.tuikit.roomkit.view.schedule.wheelpicker;

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
