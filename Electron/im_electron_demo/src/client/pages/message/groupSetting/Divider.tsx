import React from "react";
import "./divider.scss";

export const Divider = (props: { style?: React.CSSProperties }): JSX.Element => {
  return <div className="divider" style={props.style}></div>;
};
