import { Switch } from "tea-component";
import React, { useEffect, useState } from "react";
import { TIMMsgSetGroupReceiveMessageOpt } from "../../../api";
import "./group-flag-message.scss";



export const GroupFlagMessage = (props: {
  flagMsg: number;
  userId: string;
  groupId: string;
  onRefresh: () => Promise<any>;
}): JSX.Element => {
  const { flagMsg, userId, groupId, onRefresh } = props;
  const [ revMessageOpt,setRevMessageOpt ] = useState(flagMsg)
  const handleChange = async (value: number) => {
    try {
      const { data :{ code}} =  await TIMMsgSetGroupReceiveMessageOpt(groupId,Number(value));
      if(code === 0){
        await onRefresh();
      }
    } catch (e) {
      console.log(e);
    }
  };
  useEffect(()=>{
    if(flagMsg!==revMessageOpt){
      handleChange(revMessageOpt)
    }
  },[revMessageOpt])
  return (
    <div className="group-flag-message">
      <div className="group-flag-message--title">
        <span className="group-flag-message--title__text">消息免打扰</span><Switch value={revMessageOpt!==0} onChange={(value)=>{setRevMessageOpt(value?1:0)}} />
      </div>
      {/* <Select
        size="full"
        type="simulate"
        appearance="button"
        className="group-flag-message--select"
        value={"" + flagMsg}
        onChange={(value) => handleChange(value)}
        options={flagMsgOptions}
      /> */}
    </div>
  );
};
