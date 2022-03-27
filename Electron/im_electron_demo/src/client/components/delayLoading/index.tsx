import React, { useState, useRef, useEffect, Fragment, ReactChild } from 'react';

type Props = {
    isLoading: boolean;
    children: ReactChild[] | ReactChild,
    delay?: number,
    minDuration?: number,
    fallback: ReactChild[] | ReactChild;
}

export const DelayLoading = (props: Props) : JSX.Element => {
    const { isLoading, delay = 400, minDuration = 700, children, fallback } = props;
    const [visible, setVisible] = useState<boolean>(false);
    const startTime = useRef<number>(0);

    useEffect(() => {
        const remaining = minDuration - (Date.now() - startTime.current);
        const timeout = isLoading ? delay : remaining >= 0 ? remaining : 0;

        const timer = setTimeout(() => {
            if(isLoading) {
                startTime.current = Date.now();
            } else {
                startTime.current = 0;
            }
            setVisible(isLoading);
        }, timeout)

        return () => {
            clearTimeout(timer)
        }
    }, [isLoading]);

    if(visible) {
        return <Fragment>
            {fallback}
        </Fragment> 
    }

    if(!isLoading && startTime.current == 0) {
        return <Fragment>
            { children === undefined ? null : children }
        </Fragment> 
    }

    return null;
}