import React, { useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { downloadFilesByUrl, showDialog } from "../../../utils/tools";
import { cancelSendMsg } from "../../../api";
import { shell } from 'electron'
import { Icon, message as teaMessage } from "tea-component";
import { checkPathInLS, setPathToLS } from "../../../utils/messageUtils";
import path from 'path';

import withMemo from "../../../utils/componentWithMemo";

const FileElem = (props: any): JSX.Element => {
    const { message, element, index } = props
    const { message_conv_id, message_conv_type, message_status, message_msg_id, message_is_from_self } = message
    const { file_elem_file_name, file_elem_file_size,  file_elem_file_path, file_elem_url } = element
    const { uploadProgressList } = useSelector((state: State.RootState) => state.historyMessage);
    const progressKey = `${message_msg_id}_${index}`
    const uploadProgress = uploadProgressList.get(progressKey);
    let   backgroundStyle = ""
    let   percentage = 0
   
    if(message_status === 1 && uploadProgress) {
        const { cur_size, total_size } = uploadProgress
        percentage = Math.floor((cur_size / total_size) * 100)
        backgroundStyle = message_status === 1 ? `linear-gradient(to right, #D4FFEB ${percentage}%, white 0%, white 100%)` : ""
    }

    const getFilePath = () => {
        const match = file_elem_url.match(/\/([\w|\.]+$)/)
        if(message_is_from_self) 
            return path.resolve(file_elem_file_path)
        else 
            return path.resolve(process.cwd() + '/download/' + (match ? match[1] : ""))
    }
    
    const calcuSize = () => {
        return (file_elem_file_size / (1024 * 1024)).toFixed(2)
    }
    const showFile = () => {
        showDialog()
    }
    const displayName = () => {
        return file_elem_file_name || "null"
    }
    const getFileTypeName = () => {
        const match = file_elem_file_name.match(/\.(\w+)$/)
        return match ? match[1] : "unknow"
    }
    const handleOpen = () => {
        const p = getFilePath()
        try {
            shell.openPath(p).catch(err=>{
                shell.showItemInFolder(p)
            })
        }catch {
            
        }
    }
    const handleCancel = async () => {
        const {data: {json_params, code}} = await cancelSendMsg({
            conv_id: message_conv_id,
            conv_type: message_conv_type,
            message_id: message_msg_id,
            user_data: "test"
        });

        if (code === 0) {
            // dispatch(updateMessages({
            //     convId,
            //     message: JSON.parse(json_params)
            // }))
        }
    }
    const getHandleElement = () => {
        if(message_status === 1) return <Icon type="dismiss" className="message-view__item--file___close" onClick={handleCancel} />
        if(message_status === 2) {
            if(message_is_from_self) {
                return <div className="message-view__item--file___open" onClick={handleOpen}></div>
            } else {
                if(!checkPathInLS(getFilePath())) return <div className="message-view__item--file___download" onClick={savePic}></div>
                else return <div className="message-view__item--file___open" onClick={handleOpen}></div>
            }
        }
    }
    const getDetailText = () => {
        if(message_status === 1) return <div className="message-view__item--file___content____size">{calcuSize()}MB 加速上传中 {percentage}%</div>
        if(message_status === 2) return <div className="message-view__item--file___content____size">{calcuSize()}MB</div>
    }
    const downloadPic = (url) => {
        const basePath = process.cwd() + '/download/'
        try {
            downloadFilesByUrl(url)
            setPathToLS(getFilePath())
        } catch(e){
            teaMessage.error({
                content: e
            })
        }
    }
    const savePic = () => {
        file_elem_url && downloadPic(file_elem_url)
    }
    const item = () => {
        return (
            <div className="message-view__item--file" style={{background: backgroundStyle}} onDoubleClick={showFile}>
                <div className="message-view__item--file___ext">{getFileTypeName()}</div>
                <div className="message-view__item--file___content">
                    <div className="message-view__item--file___content____name">{displayName()}</div>
                    { getDetailText() }
                </div>
                <div className="message-view__item--file___handle">
                    { getHandleElement() }
                </div>
            </div>
        )
    };
    return item();
}

export default withMemo(FileElem);