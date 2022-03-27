import React, { FC, useState } from 'react';
import { RouteComponentProps } from "react-router-dom";

import { AccountSetting } from './AccountSetting';
import { CommonSetting } from './CommonSetting';
import { FileManager } from './FileManager';
import { ConnectUs } from './ConnectUs';

import './setting.scss';
import { SearchBox } from '../../components/searchBox/SearchBox';
import { Icon } from 'tea-component';


type Props = RouteComponentProps

const settingsConfig = [
    {
        id: 'accountSetting',
        name: '账号设置',
    },
    // {
    //     id: 'commonSetting',
    //     name: '通用设置',
    // },
    // {
    //     id: 'fileManager',
    //     name: '文件管理',
    // },
    {
        id: 'connectUs',
        name: '联系我们',
    }
]

export const Setting: FC<Props> = () => {
    const [activedId,  setActiveId] = useState('accountSetting');

    const DisplayComponent = {
        accountSetting: AccountSetting,
        commonSetting: CommonSetting,
        fileManager: FileManager,
        connectUs: ConnectUs
    }[activedId]

    const handleNavClick = (id: string): void => setActiveId(id);

    const addActiveClass = (id: string): string => id === activedId ? 'is-active' : '';

    return (
        <div className="settings">
            <div className="settings-nav">
                <div className="settings-search">
                    <SearchBox />
                </div>
                {
                    settingsConfig.map(({id, name}) => {
                        return (
                            <li className={`settings-nav--item ${addActiveClass(id)}`} key={id} onClick={() => handleNavClick(id)}>
                                <span className={`settings-nav--item__icon ${id}`} />
                                <span className="settings-nav--item__name">{name}</span>
                            </li>
                        )
                    })
                }
            </div>
            <div className="settings-content">
                <DisplayComponent />         
            </div>
        </div>
    )
}