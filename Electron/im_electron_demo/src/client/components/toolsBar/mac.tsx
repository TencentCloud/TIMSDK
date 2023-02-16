import React from 'react';

import "./macBars.scss";

export const Mac = (props) => {
    const {closeWin, minSizeWin, maxSizeWin } = props;
    return <div className="mac-bars">
        <div className='bars close' onClick={ closeWin }></div>
        <div className='bars min' onClick={ minSizeWin }></div>
        <div className='bars max' onClick={ maxSizeWin }></div>
    </div>
}