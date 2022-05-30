## 3.5.0
* New interface
* callExperimentalAPI
* clearC2CHistoryMessage
* clearGroupHistoryMessage
* searchLocalMessages
* findMessages
* searchGroups
* searchGroupMembers
* getSignalingInfo
* addInvitedSignaling
* searchFriends

## 3.5.1
* Array out-of-bounds compatible logic

## 3.5.2
* add web support

## 3.5.3
* Added onTotalUnreadMessageCountChanged event
* Added orderkey field to V2TimConversation for session sorting

## 3.5.4
* Added downloadMergeMesasge interface

## 3.5.5
* Architecture adjustment

## 3.5.6
* Fix checkFriend failure problem
* Fix the problem that getC2CHistoryMessageList cannot get follow-up messages

## 3.6.0
* Each module supports multiple registration of listener and multiple callbacks
* Added api markAllMessageAsRead to set all sessions read
* Added combined message parsing
* Upgrade the native version to 5.8.1668

## 3.6.1
* Fix file progress event missing

## 3.6.2
* Fixed removing advanced message not passing uuid

## 3.6.3
* addFriend interface optimization: addType changed from int to FriendTypeEnum
* acceptFriendApplication interface optimization: acceptType changed from int to FriendResponseTypeEnum
* checkFriend interface optimization: checkType changed from int to FriendTypeEnum
* createGroup interface optimization: addOpt changed from int to GroupAddOptTypeEnum
* deleteFromFriendList interface optimization: deleteType changed from int to FriendTypeEnum
* getGroupMemberList interface optimization: filter changed from int to GroupMemberFilterTypeEnum
* getHistoryMessageList interface optimization: type changed from int to HistoryMsgGetTypeEnum
* getHistoryMessageListWithoutFormat interface optimization: type changed from int to HistoryMsgGetTypeEnum
* getGroupMemberList interface optimization: type changed from int to GroupMemberFilterTypeEnum
* getGroupMemberList interface optimization: filter changed from int to GroupMemberFilterTypeEnum
* initSDK interface optimization: loglevel changed from int to LogLevelEnum
* refuseFriendApplication interface optimization: change acceptType from int to FriendApplicationTypeEnum
* sendCustomMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendFaceMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendFileMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendForwardMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendImageMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendLocationMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendMergerMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendSoundMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendTextAtMessage interface optimization: priority changed from int to MessagePriorityEnum
* sendTextMessage interface optimization: priority changed from int to MessagePriorityEnum
* setGroupMemberRole interface optimization: role changed from int to GroupMemberRoleTypeEnum
* Event callback registration return modified to be asynchronous


## 3.6.4
* Fix Android asynchronous registration event no return bug
* Fix the error of removing the basic listener event
* The message progress event adds the uuid of the message being sent

## 3.6.5
* fix java syntax error

## 3.6.6
* Add message reply interface
* Fix the problem of error reporting in release mode on the web side

## 3.6.7
* The ios compilation environment has been upgraded from 8.0 to 9.0

## 3.6.8
* Reply message interface optimization

## 3.6.9
* Reply message parameter optimization

## 3.7.0
* Optimize cloudCustomData unpacking

## 3.7.1
* The message sending progress event returns the id of the created message
* Optimize the callback part, prompting the business side to call back errors that are caught in the SDK and need to be modified by the business side

## 3.7.5
* Upgrade the underlying library to 6.0.1975
* Offline push configuration supports TPNS TOKEN

## 3.7.7
* Fix swift code warning
* Rewrite swift strong unpacking code
* Add the id field to the message instance returned by the sendMessage interface

## 3.7.8
* Fix the exception caused by strong unpacking

## 3.8.0
* Upgrade the underlying interface dependencies

## 3.8.2
* Update group member parameter constraints

## 3.8.3
* Switch the token encoding according to the environment

## 3.8.4
* update interface

## 3.8.5
* Added remove session listener interface
* Add the interface for removing the friend relationship link

## 3.8.6
* Solve the problem that the package cannot be get

## 3.8.7
* Modify add friends enumeration

## 3.8.8
* Monitor registration problem fix

## 3.8.9
* Monitor registration problem fix


## 3.9.0
* Modify grouplistener

## 3.9.1
* Upgrade the underlying library version to 6.1.2155

## 3.9.2
* Upgrade the ios library version to 6.1.2155.1

## 3.9.3
* Upgrade the underlying SDK version to 6.2.x
* Fix the problem that the group ban group tips boolValue is lost
* Fixed the problem that the nameCard field was not parsed for session instances
* Added group read receipt related interface
* flutter for web perfect

## 4.0.0
* Upgrade the underlying SDK version to 6.2.x
* fix offlinePush info bug


## 4.0.1
* Added topic related interface
* Added message editing interface

## 4.0.2
* Local video url bug fix