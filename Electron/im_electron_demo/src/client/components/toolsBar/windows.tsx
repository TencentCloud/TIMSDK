import React from "react"
import { Icon } from 'tea-component';

import './toolsbar.scss'
export const Windows = (props): JSX.Element=> {
    const {closeWin, maxSizeWin, minSizeWin } = props;
    return (
        <div className="windows">
            <Icon className="close-btn" type="close" onClick={ closeWin }/>
            <span className="max-size" onClick={ maxSizeWin }></span>
            <Icon className="min-size" type="minus" onClick={ minSizeWin } />
        </div>
    )
}