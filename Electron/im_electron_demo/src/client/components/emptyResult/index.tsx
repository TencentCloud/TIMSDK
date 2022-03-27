import React, { ReactChild, Fragment } from 'react';

import noResultImg from '../../assets/icon/no-result.png';
import './index.scss';

type Props = {
    isEmpty: boolean,
    children?: ReactChild[] | ReactChild ,
    contentText?: string
}

export const EmptyResult = (props: Props) : JSX.Element => {
    const { isEmpty, children, contentText = '' } = props;
    if(!isEmpty) {
        return <Fragment>
            {children}
        </Fragment>
    }

    return (
        <div className="empty-result">
            <img className="empty-result__img" src={noResultImg}/>
            <span className="empty-result__text">{contentText}</span>
        </div>
    )
}