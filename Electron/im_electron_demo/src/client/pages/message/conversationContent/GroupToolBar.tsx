import React from "react";
import {useSelector } from "react-redux";

import "../scss/group-tool-bar.scss";


const tools = [
  // {
  //   id: "query-message",
  //   title: "聊天记录",
  // },
  {
    id: "announcement",
    title: "群公告",
  },
  {
    id: "setting",
    title: "设置",
  },
];

export const GroupToolBar = (props: {
  onActive: (id: string) => void;
  onClose: () => void;
  onShow: () => void;
}): JSX.Element => {
  const { onActive, onClose, onShow} = props;

  const { toolsTab } = useSelector(
    (state: State.RootState) => state.groupDrawer
  );


  const addActiveClass = (id: string): string =>
    toolsTab === id ? "is-active" : "";

  return (
    <>
      <div className="tool-bar" id="toolBar">
        {tools.map(({ id, title }) => (
          <div
            key={id}
            className="tool-bar--item"
            onClick={() => {
              if (toolsTab !== id) {
                onActive(id);
                onShow();
              } else {
                onActive("");
                onClose();
              }
            }}
          >
            <span
              className={`tool-bar--item__icon ${id} ${addActiveClass(id)}`}
            ></span>
          </div>
        ))}
      </div>
    </>
  );
};
