import React from 'react';
import './index.scss';
import { LoadingTip } from 'tea-component';

interface Props extends React.HTMLAttributes<HTMLElement> {
  loading?: boolean;
  style?: React.CSSProperties;
  children:
    | React.ReactNode
    | React.ReactFragment
    | React.ReactPortal
    | boolean
    | null
    | undefined;
}

export const LoadingContainer = (props: Props): JSX.Element => {
  const { loading, style = {} } = props;
  const _loading = !!loading;

  return (
    <div
      className={`loading-container ${ _loading ? 'is-loading' : ''}`}
      style={style}
    >
      <div className="loading-container--modal">
        <LoadingTip className="loading-container--modal__tip"></LoadingTip>
      </div>
      {props.children}
    </div>
  );
};
