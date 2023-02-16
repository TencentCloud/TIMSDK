import React from 'react';
import { Slider } from 'tea-component';

export const CommonSetting = () => {
    const marks = [{ value: 10 }, { value: 12 }, { value: 14 }];

    return (
        <div className="common-setting">
            <Slider
          min={10}
          max={14}
          step={2}
          marks={marks}
          markValueOnly
          defaultValue={12}
          onChange={value => console.log(value)}
        />
        </div>
    )
}