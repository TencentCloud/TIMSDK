import {  Button } from "tea-component"
import React, { FC, useEffect, useRef } from "react"
import './recordPopup.scss'
import Recorder from 'js-audio-recorder'
const recorder = new Recorder({
    sampleBits: 16,                 // 采样位数，支持 8 或 16，默认是16
    sampleRate: 16000,              // 采样率，支持 11025、16000、22050、24000、44100、48000，根据浏览器默认值，我的chrome是48000
    numChannels: 1,                 // 声道，支持 1 或 2， 默认是1
    // compiling: false,(0.x版本中生效,1.x增加中)  // 是否边录边转换，默认是false
});
interface RecordPopupProps {
    onSend: Function
    onCancel: Function
}

export const RecordPopup: FC<RecordPopupProps> = ({ onSend, onCancel }): JSX.Element => {
    const refPopup = useRef(null)
    
    useEffect(() => {
        recorder.start().then(() => {
            // 开始录音
            console.log('开始录音')
        }, (error) => {
            // 出错了
            console.log(error);
        });
        document.addEventListener('click', handlePopupClick);
        return () => {
            document.removeEventListener('click', handlePopupClick);
        }
    }, []);

    const handlePopupClick = (e) => {
        if(!refPopup.current) return
        if (!refPopup.current.contains(e.target as Node) && refPopup.current !== e.target) {
            onCancel()
        } 
    }
    return (
        <div ref={refPopup} className="record-popup">
            <div className="record-popup__icon"></div>
            <div  className="record-popup__tips">正在录音</div>
            <Button type="primary" onClick={() => onSend("path")} className="record-popup__btn-send">发送</Button>
            <Button onClick={() => onCancel()} className="record-popup__btn-cancel">取消</Button>
        </div>
    )
}