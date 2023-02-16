let tim = null;

const createGroup = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const fakeParams = {
            groupName: "test-avchatRoom",
            groupType: 4,
            groupMemberArray: [{
                identifer: "6666",
                // customInfo: [
                //     { key: "test1", value: "111" },
                //     { key: "test2", value: "222" }
                // ],
                nameCard: "member1"
            }],
            notification: "Pls add name card",
            introduction: "use for dev test",
            face_url: "test face_url",
            // customInfo: [
            //     { key: "gourp_custom1", value: "111" },
            //     { key: "group_custom2", value: "222" }
            // ]
        };
        const res = await groupManager.TIMGroupCreate({
            params: fakeParams,
            data: "{a:1, b:2}"
        });
        console.log("==========res===========", res);
        return JSON.parse(res.json_param).create_group_result_groupid;
    } catch (e) {
        console.log("=========error===", e)
    }
};

const joinGroup = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupJoin({
            groupId: '@TGS#10W2JTHHF',
            helloMsg: "Hello",
            data: "{a:1, b:2}"
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const deleteGroup = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupDelete({
            groupId: '@TGS#2DPBSMHHG',
            data: "{a:1, b:2}"
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const quitGroup = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupQuit({
            groupId: '@TGS#2CTYSMHHB',
            data: "{a:1, b:2}"
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const getJoinedGroup = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetJoinedGroupList();
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const getGroupInfoList = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetGroupInfoList({
            groupIds: ["@TGS#aRTKB2HHF"],
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const modifyGroupInfo = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupModifyGroupInfo({
            params: {
                groupId: "@TGS#2S7FBTHHV",
                groupName: "modified group name",
                modifyFlag: 2,
                notification: "modified notifaction"
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const getGroupMemberInfo = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetMemberInfoList({
            params: {
                groupId: "@TGS#2S7FBTHHV",
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const modifyGroupMemberInfo = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupModifyMemberInfo({
            params: {
                groupId: "@TGS#13SCIVHHW",
                identifier: '77778',
                modifyFlag: 8,
                nameCard: 'Modified Name card'
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const inviteMember = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupInviteMember({
            params: {
                groupId: "@TGS#1G5XAVHHZ",
                identifierArray: ['6666'],
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const TIMGroupGetPendencyList = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetPendencyList({
            params: {
                startTime: 0,
                maxLimited: 0,
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}


const TIMGroupReportPendencyReaded = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupReportPendencyReaded({
            timeStamp: 0,
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const TIMGroupGetOnlineMemberCount = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetOnlineMemberCount({
            groupId: '@TGS#2SLAJTHHO',
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const TIMGroupSearchGroups = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupSearchGroups({
            searchParams: {
                keywordList: ['test'],
                fieldList: [2]
            },
            data: 'test data'
        });
        console.log("==========res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const TIMGroupSearchGroupMembers = async () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupSearchGroupMembers({
            searchParams: {
                groupidList: ['@TGS#2SLAJTHHO'],
                keywordList: ['9999'],
                fieldList: [1]
            },
            data: 'test data'
        });
        console.log("========== init attribute res===========", res);
    } catch (e) {
        console.log("=========search error===", e)
    }
}

const TIMGroupInitGroupAttributes = async groupId => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupInitGroupAttributes({
            groupId,
            attributes: [{
                key: 'attribute1',
                value: 'hello'
            }],
            data: 'test data'
        });
        console.log("==========init attribute res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const TIMGroupGetGroupAttributes = async groupId => {
    const groupManager = tim.getGroupManager();
    try {
        const res = await groupManager.TIMGroupGetGroupAttributes({
            groupId,
            attributesKey: ["attribute1"],
            data: 'test data'
        });
        console.log("==========get attribute res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const groupAttributeChangeCallback = () => {
    const groupManager = tim.getGroupManager();
    try {
        const res = groupManager.TIMSetGroupAttributeChangedCallback({
            callback: (data) => {
                console.log("====================callback response", data);
            },
            data: 'test data'
        });
        console.log("==========get attribute res===========", res);
    } catch (e) {
        console.log("=========error===", e)
    }
}

const testGroupManager = async data => {
    console.log("============= test group ==========")
    tim = data;
    const groupId =  await createGroup();
    groupAttributeChangeCallback();
    // await joinGroup();
    // deleteGroup(); // success
    // quitGroup();
    // getJoinedGroup(); // success
    // await modifyGroupInfo(); // success
    // await inviteMember(); //success
    // await modifyGroupMemberInfo(); //success
    // getGroupMemberInfo(); // success
    // await getGroupInfoList(); // success
    // await TIMGroupGetPendencyList(); // success
    // await TIMGroupReportPendencyReaded(); //success
    // await TIMGroupGetOnlineMemberCount(); //success
    // await TIMGroupSearchGroups(); //successs
    // await TIMGroupSearchGroupMembers(); // success
    console.log("groupId", groupId);
    await TIMGroupInitGroupAttributes(groupId); // success
    await TIMGroupGetGroupAttributes(groupId); // success
}

module.exports = {
    testGroupManager
}