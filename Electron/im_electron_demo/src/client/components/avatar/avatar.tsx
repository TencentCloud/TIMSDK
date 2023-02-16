import React, { FC, useEffect, useState } from "react"
import { RouteComponentProps } from "react-router-dom"
import './avatar.scss'


type AvatarSizeEnum = "default" | "large" | "small" | "mini"

interface AvatarProps  {
    size?: AvatarSizeEnum,
    url?: string,
    extralClass?: string,
    nickName?: string,
    userID?: string,
    groupID?: string,
}

export const Avatar:FC<AvatarProps> = ( { size='default',url:avatar,extralClass = '',nickName:nick,userID:uid,groupID:gid } ): JSX.Element => {
    const [nickName,setNickName] = useState(nick)
    const [url,setUrl] = useState(avatar)
    const [userID,setUserID] = useState(uid)
    const [groupID,setGroupID] = useState(gid)
    const displayInfo = (info:string)=>{
        if(!info){
            return "unknown"
        }
        return info.slice(0, 2).toUpperCase()
    }
    const urlComp:JSX.Element =  <div className={`avatar ${size} ${extralClass}`} style={{
        backgroundImage:`url(${url})`,
    }}>
        
    </div>;
    const nickComp:JSX.Element = <div className={`avatar ${size} ${extralClass}`} >
        {
            displayInfo(nickName)
        }
    </div>;
    const userIDComp:JSX.Element = <div className={`avatar ${size} ${extralClass}`} >
        {
            displayInfo(userID)
        }
    </div>;
    const groupIDComp:JSX.Element = <div className={`avatar ${size} ${extralClass}`} >
        {
            displayInfo(groupID)
        }
    </div>;
    const defaltComp:JSX.Element = <div className={`avatar ${size} ${extralClass}`}>
        未知
    </div>;
    useEffect(()=>{
        setNickName(nick)
        setUrl(avatar)
        setUserID(uid)
        setGroupID(gid)
    },[avatar,nick,uid,gid])
    return (
        <>
        {
            url ? urlComp : nickName ? nickComp : userID ? userIDComp : groupID ? groupIDComp : defaltComp
        }
        </>
    )
}