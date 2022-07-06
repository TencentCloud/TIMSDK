<template>
	<view class="manage" ref="dialog">
		<view class="manage-header">
			<view class="manage-header-left">
				<view>
					<h1>{{ TabName }}</h1>
				</view>
			</view>
			<!-- <i class="icon icon-close" @click="toggleShow"></i> -->
		</view>
		<view class="main" v-if="!currentTab">
			<ManageName class="space-top" :isAuth="isAuth" :data="conversation.groupProfile" @update="updateProfile" />
			<view class="userInfo space-top">
				<view class="userInfo-header" @click="setTab('member')">
					<view>{{ 群成员 }}</view>
					<view style="display: flex;">
						<view>{{ conversation.groupProfile.memberCount }}人</view>
						<image class="image-right" src="/pages/TUIKit/assets/icon/right-arrow.svg"></image>
					</view>
				</view>
				<view style="display: flex;">
					<view v-for="(item, index) in userInfo?.list?.slice(0, showUserNum)" :key="index">
						<view style="padding: 10px;">
							<image class="avatar" :src="
                  item?.avatar ||
                  'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'
                " onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"></image>
						</view>
						<view class="text-ellipsis">{{ item?.nick || item?.userID }}</view>
					</view>
					<view style="padding: 10px;" v-if="isShowAddMember">
						<view class="avatar" @click="handleOperateMember('add')">+</view>
					</view>
					<view style="padding: 10px;" v-if="conversation.groupProfile.selfInfo.role === 'Owner'">
						<view class="avatar" @click="handleOperateMember('remove')">-</view>
					</view>
				</view>
			</view>
			<view class="content space-top" @click="editLableName = ''">
				<!-- 	<view class="item-li" @click.stop="setTab('notification')">
					<view>
						<view> 群公告</view>
						<view class="notification">{{ conversation.groupProfile.notification }}</view>
					</view>
					<image class="image-right" src="/pages/TUIKit/assets/icon/right-arrow.svg"></image>
				</view> -->
				<view class="item-li" v-if="isAdmin" @click.stop="setTab('admin')">
					<view>群管理</view>
					<image class="image-right" src="/pages/TUIKit/assets/icon/right-arrow.svg"></image>
				</view>
				<view class="item-li">
					<view>群ID</view>
					<view>{{ conversation.groupProfile.groupID }}</view>
				</view>
				<view class="item-li">
					<view>群头像</view>
					<image class="avatar" :src="
              conversation?.groupProfile?.avatar ||
              'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'
            " onerror="this.src='https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg'">
					</image>
				</view>
				<view class="item-li">
					<view>群类型</view>
					<view>{{
                typeName[conversation.groupProfile.type]
            }}</view>
				</view>
				<view class="item-li">
					<view>加群方式</view>
					<view>{{
                typeName[conversation.groupProfile.joinOption]
            }}</view>
				</view>
			</view>
			<view class="footer space-top">
				<view class="group-btn" v-if="
            conversation.groupProfile.selfInfo.role === 'Owner' &&
            userInfo?.list.length > 1
          ">
					转让群组
				</view>
				<view class="group-btn" v-if="!!isDismissGroupAuth" @click.stop="dismiss(conversation.groupProfile)">
					解散群聊
				</view>
				<view class="group-btn" v-else @click.stop="quit(conversation.groupProfile)">
					退出群组
				</view>
			</view>
		</view>
		<ManageMember v-else-if="currentTab === 'member'" :self="conversation.groupProfile.selfInfo"
			:list="userInfo.list" :total="conversation.groupProfile.memberCount"
			:isShowDel="conversation.groupProfile.selfInfo.role === 'Owner'" @more="getMember('more')" @del="submit" />
		<ManageNotification v-else-if="currentTab === 'notification'" :isAuth="isAuth" :data="conversation.groupProfile"
			@update="updateProfile" />
		<main class="admin" v-else-if="currentTab === 'admin'">
			<view class="admin-list" v-if="isAdmin">
				<label>群管理员</label>
				<view>
					<view v-for="(item, index) in member.admin" :key="index">
						<view>
							<img class="avatar" :src="
                  item?.avatar ||
                  'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'
                " onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'" />
						</view>
						<view>{{ item?.nick || item?.userID }}</view>
					</view>
				</view>
			</view>
		</main>
	</view>
</template>

<script lang="ts">
	import {
		defineComponent,
		watchEffect,
		reactive,
		toRefs,
		computed,
		watch,
		ref,
	} from "vue";
	import ManageName from "./manage-name.vue";
	import ManageNotification from "./manage-notification.vue";
	import ManageMember from "./manage-member.vue";
	import TUIMessage from "./message/index.vue";
	import Vuex from "vuex";
	import {
		onBackPress
	} from '@dcloudio/uni-app';

	const TUIGroupManage = defineComponent({
		components: {
			ManageName,
			ManageNotification,
			ManageMember,
			TUIMessage,
		},
		props: {
			userInfo: {
				type: Object,
				default: () => ({
					isGroup: false,
					list: [],
				}),
			},
			conversation: {
				type: Object,
				default: () => ({}),
			},
		},
		setup(props: any, ctx: any) {
			const types: any = uni.$TUIKit.TIM.TYPES;
			const TUIGroupServer: any = uni.$TUIKit.TUIGroupServer;
			const data: any = reactive({
				conversation: {},
				userInfo: {
					isGroup: false,
					list: [],
				},
				isShowMuteTimeInput: false,
				editLableName: "",
				currentTab: "",
				transferType: "",
				isSearch: true,
				isRadio: false,
				transferList: [],
				selectedList: [],
				isMuteTime: false,
				show: false,
				typeName: {
					[types.GRP_WORK]: "好友工作群",
					[types.GRP_PUBLIC]: "陌生人社交群",
					[types.GRP_MEETING]: "临时会议群",
					[types.GRP_AVCHATROOM]: "直播群",
					[types.JOIN_OPTIONS_FREE_ACCESS]: "自由加入",
					[types.JOIN_OPTIONS_NEED_PERMISSION]: "需要验证",
					[types.JOIN_OPTIONS_DISABLE_APPLY]: "禁止加群",
				},
				delDialogShow: false,
				userList: [],
				transferTitle: "",
				member: {
					admin: [],
					member: [],
					muteMember: [],
				},
			});

			const dialog: any = ref();

			watchEffect(() => {
				data.conversation = props.conversation;
				data.userInfo = props.userInfo;
				// 	data.show = props.show;
			});

			// 获取vuex 的 store
			const VuexStore = (Vuex as any).useStore();

			const TabName = computed(() => {
				let name = "";
				switch (data.currentTab) {
					case "notification":
						name = "群公告";
						break;
					case "member":
						name = "群成员";
						break;
					default:
						name = "群管理";
						break;
				}
				return name;
			});

			// 监听用户列表变化
			watch(
				() => data.userInfo.list,
				(newValue: any, oldValue: any) => {
					data.member = {
						admin: [], // 群管理员列表
						member: [], // 群成员列表
						muteMember: [], // 已被禁言用户
					};
					newValue.map((item: any) => {
						switch (item?.role) {
							case types.GRP_MBR_ROLE_ADMIN:
								data.member.admin.push(item);
								break;
							case types.GRP_MBR_ROLE_MEMBER:
								data.member.member.push(item);
								break;
							default:
								break;
						}
						return item;
					});
					const time: number = new Date().getTime();
					data.member.muteMember = newValue.filter(
						(item: any) => item?.muteUntil * 1000 - time > 0
					);
				}, {
					deep: true
				}
			);

			// 是否有删除群的权限
			const isDismissGroupAuth = computed(() => {
				const {
					conversation
				} = data;
				const userRole = conversation?.groupProfile?.selfInfo.role;
				const groupType = conversation?.groupProfile?.type;

				const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
				const isWork = groupType === types.GRP_WORK;

				return isOwner && !isWork;
			});

			// 是否显示可以添加群成员
			const isShowAddMember = computed(() => {
				const {
					conversation
				} = data;
				const groupType = conversation?.groupProfile?.type;
				const isWork = groupType === types.GRP_WORK;

				if (isWork) {
					return true;
				}
				return false;
			});

			// 群成员列表外部显示数量
			const showUserNum = computed(() => {
				let num = 3;
				if (!isShowAddMember.value) {
					num += 1;
				}
				if ((data.conversation as any).groupProfile.selfInfo.role !== "Owner") {
					num += 1;
				}
				return num;
			});

			// 是否为管理员或群主
			const isAuth = computed(() => {
				const {
					conversation
				} = data;
				const userRole = conversation?.groupProfile?.selfInfo.role;

				const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
				const isAdmin = userRole === types.GRP_MBR_ROLE_ADMIN;
				return isOwner || isAdmin;
			});

			// 是否可以设置管理
			const isAdmin = computed(() => {
				const {
					conversation
				} = data;
				const groupType = conversation?.groupProfile?.type;
				const userRole = conversation?.groupProfile?.selfInfo.role;

				const isOwner = userRole === types.GRP_MBR_ROLE_OWNER;
				const isWork = groupType === types.GRP_WORK;
				const isAVChatRoom = groupType === types.GRP_AVCHATROOM;

				if (!isWork && !isAVChatRoom && isOwner) {
					return true;
				}
				return false;
			});

			// 获取群用户列表
			const getMember = (type ? : string) => {
				const {
					conversation
				} = data;
				const options: any = {
					groupID: conversation?.groupProfile?.groupID,
					count: 100,
					offset: type && type === "more" ? data.userInfo.list.length : 0,
				};
				TUIGroupServer.getGroupMemberList(options).then((res: any) => {
					if (type && type === "more") {
						data.userInfo.list = [...data.userInfo.list, ...res.data.memberList];
					} else {
						data.userInfo.list = res.data.memberList;
					}
				});
			};

			// 退出群
			const quit = async (group: any) => {
				await TUIGroupServer.quitGroup(group.groupID);
				TUIGroupServer.store.conversation = {};
				uni.switchTab({
					url: '/pages/TUIKit/TUIPages/TUIConversation/index'
				});
			};

			// 解散群
			const dismiss = async (group: any) => {
				await TUIGroupServer.dismissGroup(group.groupID);
				TUIGroupServer.store.conversation = {};
				uni.switchTab({
					url: '/pages/TUIKit/TUIPages/TUIConversation/index'
				});
			};


			// 打开编辑栏
			const edit = (labelName: string) => {
				data.editLableName = labelName;
			};

			// 更新群资料
			const updateProfile = async (params: any) => {
				const {
					key,
					value
				} = params;
				const options: any = {
					groupID: data.conversation.groupProfile.groupID,
					[key]: value,
				};
				const res = await TUIGroupServer.updateGroupProfile(options);
				const {
					conversation
				} = TUIGroupServer.store;
				conversation.groupProfile = res.data.group;
				TUIGroupServer.store.conversation = {};
				TUIGroupServer.store.conversation = conversation;
				data.editLableName = "";
			};

			// 设置当前tab
			const setTab = (tabName: string) => {
				data.currentTab = tabName;
				data.editLableName = "";
				if (data.currentTab === "member") {
					data.transferType = "remove";
				}
				if (!data.currentTab) {
					data.transferType = "";
				}
			};

			const submit = (userList: any) => {
				if (data.transferType === "remove") {
					data.userList = userList;
					data.delDialogShow = !data.delDialogShow;
				} else {
					handleManage(userList, data.transferType);
				}
			};

			const handleManage = (userList: any, type: any) => {
				const userIDList: any = [];
				userList.map((item: any) => {
					userIDList.push(item.userID);
					return item;
				});
			};

			// 获取要展示的用户列表
			getMember();
			// 跳转到群成员列表页面
			onBackPress((event: any) => {
				if (event.from === 'backbutton' && data.currentTab) {
					setTab('');
					return true;
				}
				return false;
			});
			// 群管理：添加、删除成员
			const handleOperateMember = (type) => {
				if (type) {
					uni.navigateTo({
						url: `../TUIGroupManage/memberOperate?type=${type}&groupID=${data.conversation.groupProfile.groupID}`
					});
				}
			};

			return {
				...toRefs(data),
				isDismissGroupAuth,
				isShowAddMember,
				isAdmin,
				isAuth,
				quit,
				dismiss,
				edit,
				updateProfile,
				setTab,
				TabName,
				getMember,
				submit,
				handleManage,
				showUserNum,
				dialog,
				handleOperateMember,
			};
		},
	});
	export default TUIGroupManage;
</script>

<style lang="scss" scoped>
	.manage {
		display: flex;
		flex-direction: column;
		background: #ffffff;
		box-sizing: border-box;
		// width: 360px;
		overflow-y: auto;
		box-shadow: 0 1px 10px 0 rgba(2, 16, 43, 0.15);
		border-radius: 8px 0 0 8px;
		// position: absolute;
		right: 0;
		height: calc(100% - 40px);
		z-index: 2;
		top: 40px;

		.text-ellipsis {
			text-align: center;
			max-width: 36px;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}

		.notification {
			opacity: 0.6;
			width: 246px;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}

		.item-li {
			padding: 14px 0;
			display: flex;
			justify-content: space-between;
			align-items: center;
			font-size: 14px
		}

		.footer {
			padding: 0 20px;
			.group-btn {
				cursor: pointer;
				width: 100%;
				font-weight: 400;
				font-size: 14px;
				color: #dc2113;
				padding: 14px 0;
				text-align: center;
				border-bottom: 1px solid #e8e8e9;

				&:last-child {
					border: none;
				}
			}
		}

		&-header {
			padding: 20px;
			display: flex;
			justify-content: space-between;
			align-items: center;
			border-bottom: 1px solid #e8e8e9;

			h1 {
				font-family: PingFangSC-Medium;
				font-weight: 500;
				font-size: 16px;
				color: #000000;
			}

			&-left {
				display: flex;

				.icon {
					margin-right: 14px;
				}

				main {
					display: flex;
					flex-direction: column;
				}
			}
		}

		.main {
			.userInfo {
				padding: 0 20px;
				display: flex;
				flex-direction: column;
				font-size: 14px;

				&-header {
					display: flex;
					justify-content: space-between;
					align-items: center;
					padding: 14px 0;
				}

				&:last-child {
					padding-right: 0;
				}

				.more {
					padding-top: 10px;
				}

				.userInfo-mask {
					position: absolute;
					z-index: 5;
					background: #ffffff;
					padding: 20px;
					box-shadow: 0 11px 20px 0 rgb(0 0 0 / 30%);
					left: 100%;
				}
			}
		}
	

	.content {
		padding: 0 20px;
	}
	.admin {
		padding: 20px 0;

		&-content {
			padding: 20px 20px 12px;
			display: flex;
			align-items: center;
		}

		&-list {
			padding: 0 20px;

			label {
				display: inline-block;
				font-weight: 400;
				font-size: 14px;
				color: #000000;
				padding-bottom: 8px;
			}
		}

		.last {
			padding-top: 13px;
			position: relative;

			&::before {
				position: absolute;
				content: "";
				width: calc(100% - 40px);
				height: 1px;
				background: #e8e8e9;
				top: 0;
				left: 0;
				right: 0;
				margin: 0 auto;
			}
		}
	}
	

	.image-right {
		width: 18px;
		height: 20px;
	}

	

	.avatar {
		width: 36px;
		height: 36px;
		background: #f4f5f9;
		border-radius: 4px;
		font-size: 12px;
		color: #000000;
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.space-top {
		border-top: 10px solid #f4f5f9;
	}

	// .btn {
	// 	background: #3370ff;
	// 	border: 0 solid #2f80ed;
	// 	padding: 4px 28px;
	// 	font-weight: 400;
	// 	font-size: 12px;
	// 	color: #ffffff;
	// 	line-height: 24px;
	// 	border-radius: 4px;

	// 	&-cancel {
	// 		background: #ffffff;
	// 		border: 1px solid #dddddd;
	// 		color: #828282;
	// 	}
	// }

	.slider {
		&-box {
			display: flex;
			align-items: center;
			width: 34px;
			height: 20px;
			border-radius: 10px;
			background: #e1e1e3;
		}

		&-block {
			display: inline-block;
			width: 16px;
			height: 16px;
			border-radius: 8px;
			margin: 0 2px;
			background: #ffffff;
			border: 0 solid rgba(0, 0, 0, 0.85);
			box-shadow: 0 2px 4px 0 #d1d1d1;
		}
	}

	.space-between {
		justify-content: space-between;
	}
}
</style>
