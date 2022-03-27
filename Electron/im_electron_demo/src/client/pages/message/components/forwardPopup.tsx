import { 
    Button, 
    Icon, 
    Input,
    Modal 
} from "tea-component"
import React, { 
    FC, 
    useEffect, 
    useRef, 
    useState 
} from "react"
import { Avatar } from "../../../components/avatar/avatar";
import { searchFriends, searchGroup } from "../../../api"
import { debounce } from 'lodash';
import './forwardPopup.scss'
import { useSelector } from 'react-redux';
interface ForwardPopupProps {
    onSuccess: Function 
    onClose: Function
}
const getId = (item) => {
    if(!item) return false
    return item.conv_id ? item.conv_id : (item.user_profile_identifier || item.friend_profile_identifier || item.group_detial_info_group_id || item.friendship_friend_info_get_result_identifier)
}
const getType = (item) => {
    if(!item) return false
    return item.conv_type ? item.conv_type : (item.user_profile_identifier || item.friend_profile_identifier || item.user_profile_identifier||item.friendship_friend_info_get_result_identifier) ? 1 : 2
}

export const ForwardPopup: FC<ForwardPopupProps> = ({ onSuccess, onClose }): JSX.Element => {
    const refPopup = useRef(null)
    const [visible, setVisible] = useState(true)
    const [userList, setUserList] = useState([])
    const [groupList, setGroupList] = useState([])
    const [selectedList, setSelectedList] = useState([])
    const [search, setSearch] = useState("")
    const { conversationList, currentSelectedConversation } = useSelector((state: State.RootState) => state.conversation);

    const defaultConversationList = useState(conversationList.filter(item => {
        const {conv_id,conv_type,conv_profile} = item
        return conv_id.includes(search) || conv_profile?.group_base_info_group_id?.includes(search) || conv_profile?.group_base_info_group_name?.includes(search) || conv_profile?.user_profile_identifier?.includes(search) || conv_profile?.user_profile_nick_name?.includes(search)
    } ))
        
    const getUserList = async () => {
        const userList = await searchFriends({ keyWords: search })
        setUserList(userList)
    }
    const getGroupList = async () => {
        const groupList = await searchGroup({ keyWords: search })
        setGroupList(groupList)
    }
    useEffect(() => {
        if(search.trim() !== "") {
            debounce(()=>{
                getUserList()
                getGroupList()
            },300)()
        }
    }, [search])
    const setValue = (value) => {
        setSearch(value);
    }
    useEffect(()=>{
        // 清空selectList
        setSelectedList([])
    },[search])
    const handleInoputOnchange = debounce(setValue, 300);
    useEffect(() => {
        document.addEventListener('click', handlePopupClick);
        return () => {
            document.removeEventListener('click', handlePopupClick);
        }
    }, []);
    const handlePopupClick = (e) => {
        if(!refPopup.current) return
        if (!refPopup.current.contains(e.target as Node) && refPopup.current !== e.target) {
            setVisible(false)
        } 
    }
    const handleItemClick = (conv_id, conv_type, item) => {
        console.log('item', item)
        console.log('conv_id', conv_id)
        if(selectedList.findIndex(v => getId(v) === conv_id) > -1) {
            const list = selectedList.filter(v => getId(v) !== conv_id)
            setSelectedList(list)
        } else {
            selectedList.push(item)
            setSelectedList(Array.from(selectedList))
        }
        console.log('selectedList',selectedList);
    }
    const handleItemClose = (e, conv_id, conv_type, item) => {
        e.stopPropagation();
        const list = selectedList.filter(v => getId(v) !== conv_id)
        setSelectedList(list)
    }
    return (
        <div ref={refPopup} >
            <Modal className="forward-popup" visible={visible} caption="转发" onClose={() => onClose()}>
                <Modal.Body>
                    {/* 转发box */}
                    <div className="forward-popup__search-list">
                        <div className="forward-popup__search-list__search">
                        <Icon className="forward-popup__search-list__icon" type="search" />
                        <Input className="forward-popup__search-list__input" type="search" placeholder="查找好友、群" onChange={handleInoputOnchange}/>
                        </div>
                        <div className="forward-popup__search-list__list customize-scroll-style">
                            {
                               (!search) &&  defaultConversationList[0].map((v,k) =>  <UserItem
                                        key={k}
                                        onItemClick={handleItemClick}
                                        onRemove={handleItemClose}
                                        seleted={selectedList.findIndex(item => getId(v) === getId(item)) > -1}
                                        item={v}
                                        hasSelectedIcon
                                    />)
                            }
                            { 
                              (search) &&  userList.map((v, k) =>
                                    <UserItem
                                        key={k}
                                        onItemClick={handleItemClick}
                                        onRemove={handleItemClose}
                                        seleted={selectedList.findIndex(item => getId(v) === getId(item)) > -1}
                                        item={v}
                                        hasSelectedIcon
                                    />
                                )
                            }
                            {
                             (search) &&   groupList.map((v, k) =>
                                    <UserItem
                                        key={k}
                                        onItemClick={handleItemClick}
                                        onRemove={handleItemClose}
                                        seleted={selectedList.findIndex(item => getId(v) === getId(item)) > -1}
                                        item={v}
                                        hasSelectedIcon
                                    />
                                )
                            }
                        </div>
                    </div>
                    <div className="forward-popup__seleted-list customize-scroll-style">
                        {
                            selectedList.map((v, k) =>
                                <UserItem
                                    key={k}
                                    onItemClick={Function}
                                    onRemove={handleItemClose}
                                    item={v}
                                    hasCloseIcon
                                />
                            )
                        }
                    </div>
                </Modal.Body>
                <Modal.Footer>
                <Button type="primary" disabled={selectedList.length === 0} onClick={(e) => onSuccess(selectedList)}>
                    转发
                </Button>
                <Button type="weak" onClick={() => onClose()}>
                    取消
                </Button>
                </Modal.Footer>
            </Modal>
        </div>
    )
}

interface UserItemProps {
    onItemClick: Function,
    onRemove: Function,
    item: any,
    seleted?: boolean,
    hasCloseIcon?: boolean,
    hasSelectedIcon?: boolean
}

export const UserItem: FC<UserItemProps> = ({ onItemClick, onRemove, seleted, item, hasCloseIcon, hasSelectedIcon }): JSX.Element => {
    const conv_type = getType(item)
    const conv_id = getId(item)
    let name
    let url
    if(item.conv_profile){
        const { user_profile_face_url,user_profile_identifier,user_profile_nick_name,group_base_info_face_url,group_detial_info_group_name,group_detial_info_owener_identifier } = item.conv_profile
        name = user_profile_identifier||user_profile_nick_name||group_detial_info_group_name||group_detial_info_owener_identifier
        url = user_profile_face_url || group_base_info_face_url || ""
    }else {
        if(item.friendship_friend_info_get_result_error_code === 0){
            // 搜出来的好友
            name = item.friendship_friend_info_get_result_field_info?.friend_profile_user_profile?.user_profile_nick_name|| item.friendship_friend_info_get_result_field_info?.friend_profile_user_profile?.user_profile_identifier
            url =  item.friendship_friend_info_get_result_field_info?.friend_profile_user_profile.user_profile_face_url
        }else{
            name = item.group_detial_info_group_name || item.friend_profile_user_profile?.user_profile_nick_name || item.user_profile_nick_name || item.conv_profile?.group_detial_info_group_name
            url = item.friend_profile_user_profile?.user_profile_face_url || "";
        }
        
    }
    
    const typeName = conv_type === 1 ? "[好友] " : "[群] "
    return (
        <div onClick={() => onItemClick(conv_id, conv_type, item)} className="user-item" >
            { hasSelectedIcon && (seleted ? 
                <Icon className="user-item__icon" type="success" /> : 
                <i className="user-item__icon-normal" ></i>)
            }
            <Avatar
                size="mini"
                key={ url }
                url={ url }
                nickName  = { name }
                userID = { conv_id }
            />
            <span className="user-item__name">{typeName}: { name }</span>
            { hasCloseIcon && <Icon type="dismiss"  onClick={(e) => onRemove(e, conv_id, conv_type, item)} /> }
        </div>
    )
}