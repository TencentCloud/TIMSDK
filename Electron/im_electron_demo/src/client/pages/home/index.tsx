import React, { useEffect } from 'react';
import { Link, Switch, Route, useLocation } from 'react-router-dom';

import { Message } from '../message/index';
import { RelationShip } from '../relationship/relationship';
import { Setting } from '../settings/Setting';
import { Meeting } from '../meeting/Meeting' 

import './home.scss';
import { UnreadCount } from './unreadCount';
import { Profile } from './profile';
import { useDispatch, useSelector } from 'react-redux';
import { changeFunctionTab } from '../../store/actions/ui';
import { Myloader } from '../../components/skeleton';
import ErrorBoundary from "../../components/ErrorBoundary";
import withMemo from '../../utils/componentWithMemo';

const navList = [
    {
        id: 'message',
        title: '消息',
        address: '/home/message',
    },
    {
        id: 'contacts',
        title: '通讯录',
        address: '/home/connection',

    },
    {
        id: 'meeting',
        title: '会议',
        address: '/home/meeting',
    }
]

const Home = (): JSX.Element => {
    const function_tab = useSelector((state: State.RootState) => state.ui.function_tab);
    const { userId } = useSelector((state: State.RootState) => state.userInfo);
    const location =  useLocation();
    const path = location?.pathname;

    const currentId = {
        '/home/message': 'message',
        '/home/connection': 'contacts',
        '/home/setting': 'settings',
    }[path] || 'message';

    const dispatch = useDispatch();
    
    const addActiveClass = (id: string) : string => function_tab === id ? 'is-active' : '';

    const handleLinkClick = (id: string) => dispatch(changeFunctionTab(id));

    useEffect(() => {
        dispatch(changeFunctionTab(currentId))
    }, [])
    console.log("userId:",userId)
    return <div className="home">
        
        <div className="nav">
            {/* 头像以及个人信心 */}
            <Profile />
            {/* 菜单 */}
            {
                navList.map(({id, address}) => {
                    return (
                        <div className='nav--item' key={id}>
                            {/* 会话未读的小红点 */}
                            {
                                id === 'message' ? <UnreadCount /> : null
                            }
                            <Link to={address} className={`nav--link ${id} ${addActiveClass(id)}`} onClick={() => handleLinkClick(id)} />
                        </div>
                    )
                })
            }
            {/* 设置 */}
            <div className='nav--item'>
                <Link to="/home/setting" className={`nav--link settings ${addActiveClass('settings')}`} onClick={() => handleLinkClick('settings')}/>
            </div>
        </div>
        {
            userId ? <div className="content">
            <Switch>
                <Route path="/home/message" component={Message}></Route>
                <Route path="/home/connection" component={RelationShip}></Route>
                <Route path="/home/setting" component={Setting}></Route>
                <Route path="/home/meeting" component={Meeting}></Route>
            </Switch>
        </div> : <Myloader/>
        }
    </div>
}

const MemoHome = withMemo(Home);

const HomeWithErrorBoundary = () => {
    return <ErrorBoundary>
        <MemoHome />
    </ErrorBoundary>
}

export default HomeWithErrorBoundary;