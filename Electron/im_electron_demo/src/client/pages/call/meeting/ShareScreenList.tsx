import React, { createElement, useEffect, useState } from 'react';
import { Button } from 'tea-component';
import {
    TRTCScreenCaptureSourceType,
} from "trtc-electron-sdk/liteav/trtc_define";

import trtcInstance from '../../../utils/trtcInstance';
import { LoadingContainer } from "../../../components/loadingContainer";
import useDynamicRef from "../../../utils/react-use/useDynamicRef"

export const ShareScreenList = ({startShare}) => {
    const [ isLoading, setLoading ] = useState(true);
    const [ screenList, setScreenList ] = useState([]);
    const [ setRef, getRef ] = useDynamicRef<HTMLCanvasElement>();
    const [ shareScreen, setShareScreen ] = useState({
        sourceId: ''
    });

    useEffect(() => {
        setLoading(true);
        setTimeout(() => {
            const shareScreenList = trtcInstance.getScreenCaptureSources(300, 200, 30, 30);
            const screenTypeList = shareScreenList.filter(screen => (
                screen.type === TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeScreen
            ));
            const windowTypeList = shareScreenList.filter(screen => (
                screen.type === TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeWindow
            ));
            setScreenList(screenTypeList);
            setLoading(false);
        }, 300);
    }, []);

    useEffect(() => {
        setTimeout(() => {
            screenList.forEach(item => {
                const { sourceId, thumbBGRA: { width, height, buffer} } = item;
                const currentCanvas = getRef(sourceId);
                const canvasDom = currentCanvas.current;
                const ctx = canvasDom.getContext('2d');

                const img = new ImageData(
                    new Uint8ClampedArray(buffer),
                    width,
                    height
                )
                if (ctx !== null) {
                    ctx.putImageData(img, 0, 0);
                }
            })
        }, 300);
    }, [screenList]);

    const selectShareItem = (item) => setShareScreen(item);

    const handleStartShare = () => startShare(shareScreen);

    return <div className="share-screen">
        {
            isLoading && <LoadingContainer loading={true} style={{height:'100%'}}>{}</LoadingContainer>
        }
        <div className="share-item__content">
            {
                screenList.length > 0 && screenList.map(item => {
                    const { width, height} = item.thumbBGRA;
                    return <div className={`share-screen-item ${shareScreen.sourceId === item.sourceId ? 'active' : ''}`} key={item.sourceId} onClick={() => selectShareItem(item)}>
                        <canvas ref={setRef(item.sourceId)} width={width} height={height} />
                        <span>{item.sourceName}</span>
                    </div>
                })
            }
        </div>
        <Button type="primary" disabled={shareScreen.sourceId === ''} onClick={handleStartShare}>确认共享</Button>
    </div>
};