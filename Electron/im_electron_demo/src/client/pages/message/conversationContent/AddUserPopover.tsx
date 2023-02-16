import { Input, Popover } from "tea-component";
import React, { useState } from "react";
import "../scss/add-user-popover.scss";
import { inviteMemberGroup } from "../../../api";

export const AddUserPopover = (props: {groupId: string}): JSX.Element => {
  const {groupId} = props;
  const [visible, setVisible] = useState(false);

  const [value, setValue] = useState("");

  const handleAdd = async () => {
    try{
      if(value.length){
        await inviteMemberGroup({groupId, UID: value})
        setValue('');
        setVisible(false);
      }
    }catch(e){
      console.log(e.message);
    }
   
  }

  return (
    <Popover
      visible={visible}
      onVisibleChange={(visible) => setVisible(visible)}
      placement="bottom-start"
      trigger="click"
      overlay={
        <div className="overlay-content">
          <Input
            className="overlay-content--input"
            placeholder="输入UID后，回车添加成员"
            value={value}
            onChange={(value) => setValue(value)}
            onKeyDown={(e) => {
             if(e.which === 13) {
               handleAdd();
             }
            }}
          />
        </div>
      }
    >
      <span className={`add-icon ${visible ? "is-active" : ""}`} />
    </Popover>
  );
};
