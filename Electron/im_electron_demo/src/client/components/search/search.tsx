import React, { Fragment } from "react"
import { Icon } from "tea-component";
import { useDialogRef } from "../../utils/react-use/useDialog";
import { SearchBox } from "../searchBox/SearchBox"
import { SearchMessageModal } from "../searchMessage";

import "./index.scss";

import { CreateGroupDialog } from "../../pages/relationship/group/components/CreateGroupDialog";
import { useSelector } from "react-redux";

export const SearchMessageAndFriends = (): JSX.Element => {
    const dialogRef = useDialogRef();
    const handleSearchBoxClick = () => dialogRef.current.open();
    const createGroupDialogRef = useDialogRef();
    const { userId } = useSelector((state: State.RootState) => state.userInfo);

    return (
        <Fragment>
            <div className="search-wrap" ><div onClick={handleSearchBoxClick}><SearchBox /></div><Icon onClick={(e) => createGroupDialogRef.current.open({ userId })} type="plus" className="add-c-icon" /></div>
            <SearchMessageModal dialogRef={dialogRef} />
            <CreateGroupDialog
                dialogRef={createGroupDialogRef}
                onSuccess={async () => {
                }}
            />
        </Fragment>
    )
}