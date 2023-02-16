import React from 'react';
import { shell } from 'electron';
import { Button } from 'tea-component';
import { PURCHASE_LINK, CONTACT_LINK} from '../../constants';

import './connectUs.scss';

export const ConnectUs = (): JSX.Element => {
    const handlePurchaseClick = () => {
        shell.openExternal(PURCHASE_LINK);
    };

    const handleContactClick = () => {
        shell.openExternal(CONTACT_LINK);
    }

    return (
        <div className="connect">
            <header className="connect-header">
                <span className="connect-header--logo"></span>
                <span className="connect-header--text">联系我们</span>
            </header>
            <section className="connet-section">
                <div className="connect-section--title">
                    <span className="tencent-cloud-logo"></span>
                    <span className="tencent-cloud-name im">即时通信</span>
                </div>
                <div className="connect-desc">
                    <p>
                        企业数字化转型的通信助手
                    </p>
                    <p>
                        简单接入、稳定必达、覆盖全球的即时通信云服务
                    </p>
                </div>
                <div className="im-logo"></div>
                <div className="connect-us-button">
                    {/* <Button type="primary" onClick={handlePurchaseClick}  className="connect-us-button--purchase">立即选购</Button> */}
                    {/* <Button type="weak" onClick={handleContactClick} className="connect-us-button--contact">联系我们</Button> */}
                </div>
            </section>
        </div>
    )
}