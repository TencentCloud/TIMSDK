import './atPopup.scss'
import React, { 
    FC, 
    useEffect, 
    useRef, 
    useState 
} from "react"
import { Avatar } from "../../../components/avatar/avatar"
import { getSelectionCoords } from '../../../utils/getSelectionCoords';
import { List } from "tea-component"
import { getGroupMemberList } from "../../../api";

interface AtPopupProps {
    callback: Function,
    group_id: string,
    atUserNameInput: string;
}

export const AtPopup: FC<AtPopupProps> = ({ callback, group_id, atUserNameInput }): JSX.Element => {
    const [list, setList] = useState([])
    const [currentSelectMember, setCurrentSelectMember] = useState<{memberId?: string; memberName?: string}>({memberId: '__kImSDK_MesssageAtALL__', memberName: '所有人' })
    const [coords, setCoords] = useState({x: 0, y: 0})
    const [displayList, setDisplayList] = useState([]);
    const refPopup = useRef(null)
    const newCoords = getSelectionCoords(window)


    const addActiveClass = (id: string): string =>
    id === currentSelectMember.memberId ? "is-active" : "";
    
    
    const getData = async () => {
        const list = await getGroupMemberList({
            groupId: group_id,
            nextSeq: 0
        });
        const arr = list.group_get_memeber_info_list_result_info_array
        const atAllItem = {group_member_info_identifier:'__kImSDK_MesssageAtALL__', group_member_info_nick_name: '所有人'};
        setList([atAllItem,...arr])
        setDisplayList( [atAllItem,...arr]);
    }
    
    useEffect(() => {
        setCoords({x: newCoords.x - 325, y: 40})
        getData()
    }, [group_id])

    useEffect(() => {
        document.addEventListener('click', handlePopupClick);
        return () => {
            document.removeEventListener('click', handlePopupClick);
        }
    }, []);
    
    useEffect(() => {
        document.addEventListener('keyup', handleOnkeyPress);
        return () => {
            document.removeEventListener('keyup', handleOnkeyPress);
        }
    }, [currentSelectMember, displayList]);

    useEffect(() => {
        const newList = list.filter(v => v.group_member_info_nick_name?.includes(atUserNameInput) || v.group_member_info_identifier?.includes(atUserNameInput));
        setDisplayList(newList)
    }, [atUserNameInput, list]);

    const handlePopupClick = (e) => {
        if(!refPopup.current) return
        if (!refPopup.current.contains(e.target as Node) && refPopup.current !== e.target) {
            callback("")
        } 
    }


    const handleArrowUpOrDownSelectMember = (type: 'up'| 'down', e) => {
        const index = displayList.findIndex(v => v.group_member_info_identifier === currentSelectMember.memberId);
        let newIndex = 0;
        if(type === 'up') {
            newIndex = index - 1;
            newIndex = newIndex < 0 ? displayList.length - 1 : newIndex;
        } else {
            newIndex = index + 1;
            newIndex = newIndex >= displayList.length ? 0 : newIndex;
        }
        const currentElement = document.getElementById(`custom-${newIndex}`);
        currentElement.scrollIntoView({block: "end", inline: "nearest", behavior: 'smooth'});
        const newCurrentSelectMember = displayList[newIndex];
        setCurrentSelectMember({memberId: newCurrentSelectMember.group_member_info_identifier, memberName: newCurrentSelectMember.group_member_info_nick_name });
    }

    const handleOnkeyPress = (e) => {
        if (e.keyCode === 13 || e.charCode === 13) {
            e.stopPropagation();
            e.preventDefault();
            callback(currentSelectMember.memberId, currentSelectMember.memberName);
        }
        if (e.keyCode === 40 || e.charCode === 40) {// 下键
            e.stopPropagation();
            e.preventDefault();
            handleArrowUpOrDownSelectMember('down', e)
        } 
        if (e.keyCode === 38 || e.charCode === 38) { // 上键
            e.stopPropagation();
            e.preventDefault();
            handleArrowUpOrDownSelectMember('up', e)
        }
    }

    const handleOnMouseOver =(e) => {
        const currentElement = e.target || e.srcElement;
        const currentElementId = currentElement.id;
        if(currentElementId.includes('custom-')) {
            const index = Number(currentElementId.split('-')[1]);
            const item = displayList[index];
            setCurrentSelectMember({memberId: item.group_member_info_identifier, memberName: item.group_member_info_nick_name});
        }
    }

    return (
        <div className="at-popup-wrapper" style={{left: coords.x, top: coords.y}} onMouseOver={handleOnMouseOver}>
            <List ref={refPopup} className="at-popup" >
                {   
                    displayList.map((v, i) => 
                        // @ts-ignore
                        <List.Item  id={`custom-${i}`}  className={addActiveClass(v.group_member_info_identifier)} key={i} onClick={() => callback(v.group_member_info_identifier, v.group_member_info_nick_name)}>    
                            {v.group_member_info_identifier !== 'kMesssageAtALL' && <Avatar
                                size="mini"
                                url={ v.group_member_info_face_url }
                                userID = { v.group_member_info_identifier }
                            />}
                            { v.group_member_info_nick_name || v.group_member_info_identifier }
                        </List.Item>
                   )
                }
            </List>
        </div>
    )
}