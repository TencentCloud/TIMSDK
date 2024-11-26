English | [简体中文](./版本历史.md)

# TIMSDK

## 8.3.6498 @2024.11.26 - Enhanced Version
### SDK

- Support for Lite Signaling SDK
- Support for configuring AnyCast routing address
- Optimization of long connection IP address routing strategy
- Online push supports custom ringtones
- Support for OPPO push message classification
- HarmonyOS platform SDK adaptation API 12
- Support for HarmonyOS SDK connecting to private servers
- Support for HarmonyOS TS API and C API mixed compilation
- Conversation marking supports filtering duplicate requests
- Optimization and upgrade of single chat unread message and unread count protocol
- Completion of the recall information of the last message in the conversation
- Fix occasional issue of message body size exceeding limit in merged forwarding - messages
- Fix occasional issue of incorrect account type during random login of IM and Push
- Fix parsing error of message response data format in HarmonyOS SDK
- Fix occasional failure issue of editing merged forwarding messages

### TUIKit & Demo
- TUIKit document message supports automatic URL resolution
- TUIKit's self-developed album browser
- TUIKit supports video editor
- TUIKit supports Traditional Chinese

## 8.2.6325 @2024.09.27 - Enhanced Version
### SDK

- IMSDK now supports crash reporting and monitoring.
- IMSDK supports HarmonyOS C API version.
- IMSDK supports Sony PS platform.
- IMSDK supports pure push notifications.
- Login now allows for custom fields to be carried.
- Optimized the logic for server timestamp correction.
- Upgraded the backend notification protocol for fan following.
- Updated versions of libcurl and libopenssl.
- Upgraded the long connection routing address selection.
- Enhanced the authentication logic for downloading rich media files via COS.
- Removed the HttpDNS routing method for long connections.
- Optimized the loading process of QUIC and encryption plugins on the Android platform.
- Fixed an issue with the Linux SDK exporting some internal symbols.
- Resolved a rare issue where merged forwarded messages downloaded via the Flutter SDK lacked a message ID.
- Fixed an error in parsing custom signaling fields in the Harmony SDK.
- Corrected an issue with parsing session tag fields in the Harmony SDK.
- Addressed occasional disarray in session sorting fields within the Harmony SDK.

### TUIKit & Demo
- TUIKit offers enriched API for interface customization.
- Group voting and group serial message support is now top-positionable.
- Messages flagged by security measures are not allowed to be forwarded or quoted.
- Audio and video calls now support enabling virtual backgrounds.
- Fixed an issue where clicking on a message in TUIChat did not automatically hide the keyboard.


## 8.1.6122 @2024.08.30 - Enhanced Version
### SDK
- Support offline push for HarmonyOS platform
- Android platform IM SDK adapted to 16K Page Size
- Optimize server time correction logic
- Optimize HTTP addresses for anycast routing on the international site
- Optimize default value for QUIC channel ping timeout
- Fix the issue where Mac end group notifications do not distinguish between actively joining a group and being passively invited
- Fix the issue with incorrect account type during Push login

## 8.1.6116 @2024.08.14 - Enhanced Version
### SDK
- Signaling now supports disabling callbacks before and after message sending.
- Fixed an issue where after deleting a pinned conversation, new messages could not retrieve the conversation.
- Fixed an occasional issue where after deleting a conversation and receiving a conversation deletion callback, there would still be occasional conversation update callbacks.
- Fixed occasional crash issues.

### TUIKit & Demo
- Updated customer service plugin agreement
- Fixed a crash issue on the iOS side of the group note plugin

## 8.1.6103 @2024.07.26 - Enhanced Version
### SDK
- Long connection supports HTTP protocol, enhancing network penetration capabilities.
- Topic message reception options now support setting whether to follow the community.
- Topics add a new message reception option to only receive @ messages.
- Read receipts for private chat messages now include the read time.
- Support disabling cloud callbacks before and after message sending.
- Fixed an issue where the conversation list did not update in real-time when group - avatars or names were changed.
- Fixed an issue where pulling the grouped conversation list was abnormal when logging in without a network connection.
- Optimized Android HTTPS security issues.
- Optimized rich media file download authentication.
- Enhanced database performance for Android.

### TUIKit & Demo
- TPush standalone push product launched with a smaller package size.
- Push adds a login-free push feature.
- Push introduces a new intelligent detection strategy for available channels.
- Push adds a push registration timeout protection mechanism.
- TUIChat optimizes the UI display of pinned messages and security prompts.
- TUIChat international version UI supports "User is typing" status.
- Optimized the UI experience for message sending and receiving, reducing lag issues.


## 8.0.5895 @2024.06.07 - Enhanced Version
### SDK
- Added support for offline push settings with a large icon on the right side.
- Pinned messages now support returning information about the operator.
- Added support for returning group pinned messages that were deleted by oneself.
- Added support for preserving conversation grouping information when deleting conversations.
- Added system notifications for when conversation grouping information is eliminated by the backend.
- Local message search now supports searching all single or group chat messages.
- Completed system notifications for friend group changes.
- The entry tips message and callback in a regular group can distinguish between active joining and being invited into the group.
- Improved database query throughput and speed.
- Optimized read receipt performance by merging duplicate requests.
- Optimized the time range for group signaling synchronization after login.
- Fixed an issue with pulling messages after inserting local messages in a topic.

### TUIKit & Demo
- TUIKit now supports message pinning.
- TUIKit supports asynchronous striking of file messages.
- TUIKit allows for entering the main interface to view local data without logging in after a network disconnection.
- TUIKit no longer exposes the original message content when referencing and replying to a retracted message.
- TUIKit replaces libopencore with AAC+M4A.
- TUIChat Android supports saving images without extensions to the gallery.

## 7.9.5680 @2024.04.19 - Enhanced Version
### SDK
- Fix the issue of the pinned message list returning in the wrong order
- Fix the issue of incorrect parsing of the Tips type of pinned messages
- Fix the issue of log writing failure on some Android phones
- Fix the occasional incomplete retrieval of group roaming messages from old to new
- Fix the occasional inability to retrieve local messages when pulling historical messages from topics
- Fix the issue where sessions deleted from the conversation group are reactivated after logging in again

## 7.9.5666 @2024.04.07 - Enhanced Version
### SDK

- New visionOS SDK, compatible with Apple Vision Pro
- Group conversation supports message pinning
- Add the function of receiving group @ reminder offline notifications during Do Not Disturb mode
- Support setting friend remarks in the "Accept Friend Request" interface
- Add handling of invitations to join groups
- Upgrade vivo push package version in TIMPush
- Fix OV device crash issue in TIMPush
- Add OfflinePushExtInfo support for push through feature in TIMPush
- Fix the issue of not receiving the notification of being kicked out due to network disconnection
- Fix the issue of occasionally not receiving group messages when joining a live group immediately in the login callback
- Fix the issue of still receiving session change callbacks after receiving the delete session callback
- Fix the issue of occasional reset of local data in messages
- Fix the issue of frequent triggering of onRecvMessageModified callback when fetching historical messages
- Fix the issue of no return value and no support for optional values in some Swift interfaces
- Fix the multi-endpoint login exception caused by iCloud sync between different types of devices with the same AppleID
- Fix related issues of communities and topics
- Fix the issue of failing to fetch historical messages on HarmonyOS platform
- Upgrade libcurl in Windows platform to 8.4.0
- Fix the issue of duplicate summary in merged forwarded messages in C++ interface
- Fix the issue of unable to download large images in C++ interface
- Fix the issue of incorrect group type in C++ interface
- Fix the issue of unable to set message custom data in C++ interface
- Fix the forwarding message failure in C++ interface

### TUIKit & Demo

- iOS components provide PrivacyInfo.xcprivacy privacy list file
- TUIChatBot plugin supports markdown text display
- TUIChat chat page header supports displaying call status

## 7.8.5505 @2024.03.01 - Enhanced Version
### SDK
- Add PrivacyInfo.xcprivacy privacy file for iOS & Mac SDK
- Fix the issue that C++ SDK cannot set localCustomData
- Fix the issue of Swift SDK location message data type error
- Fix the occasional issue of triggering "message update" callback when pulling historical messages
- Fix the topic at message exception issue
- Fix the issue of fetching exceptions in group and topic lists
- Fix other stability issues

## 7.8.5483 @2024.02.01 - Enhanced Version（The version for Android is 7.8.5484）
### SDK
- Support HarmonyOS platform
- Support Loongson architecture
- Release TIMPush-UniApp
- FCM push supports pass-through messages
- Add permission group function for community topics
- Add stranger attention/fan function
- Support configuring cloud message audit policy
- Support deleting accounts
- Topic information supports obtaining the readSequence field
- Fix the problem that after deleting a local inserted group message, the new message received does not update the unread count
- Fix the problem that the SDK does not callback occasionally after the user subscribes to multiple official accounts at the same time
- Fix the inconsistency of msgID before and after sending official account messages
- Fix the problem that the callback does not occur occasionally after subscribing to conversation group unread counts
- Fix the problem of abnormal creation time of topics
- Fix the problem that when pulling topic information before and after joining the community, the unread count does not change.
- Fix the problem of incorrect notification message type for topic information updates
- Fix the problem that withdrawn status messages can be searched under certain conditions
- Fix the issue of onApplicationProcessed callback being called multiple times

### TUIKit & Demo
- Add the TUIEmojiPlugin plugin to support emoticon response functions
- TUIChat supports adding and displaying gif dynamic emoticons
- Upgrade the built-in small emoji pack in TUIChat to the new version of yellow face emojis
- Fix the problem of TUIChat on iOS black screen when clicking image messages

## 7.7.5294 @2023.12.27 - Enhanced Version
### SDK
- Optimize Room control logic
- Solve the problem that the SDK cannot receive notifications of conversation deletion from the group when the local conversation does not exist
- Solve the problem that a conversation's last message can still be searched when it is in a withdrawn state
- Solve the problem that message senders cannot receive message change callbacks after live group messages are modified by third-party callbacks
- Fix occasional stability problems in the log module
- Optimize community topic unread count logic
- 
## 7.7.5282 @2023.12.18 - Enhanced Version
### SDK
- Added V2TIMCommunityManager and V2TIMCommunityListener to integrate community topic interfaces
- The SDK supports Quic and advanced encryption plugins
- Optimized conversation filtering logic
- Topic information added createTime field
- Live group supports setting administrators and pulling administrator list
- Local content moderation regular expressions default ignore English case
- Fixed occasional jni issues
- Fixed occasional weak network message send callback error
- Fixed occasional group tips message intValue change issue
- Fixed Android SDK search English question mark failure problem

### TUIKit & Demo
- Added ChatBot plugin for intelligent chat, supporting FAQ question-and-answer format and streaming text message display
- TUIKit adapted to Gradle 8.0
- Simplified TUIKit component initialization steps and increased component dependency configuration
- TUIChat supports half screen horizontal display in RoomKit
- TUIChat supports adding message click and long press event listeners
- Optimized TIMPush plugin
- Optimized customer service plugin experience
- Improved voice message click effect

## 7.6.5011 @2023.11.03 - Enhanced Version 
### SDK
- Add official account feature
- Online status supports returning terminal type
- Save security strike status locally after sending text and image messages are hit by security
- C interface layer's session information supplements session avatar and group specific type
- Optimize message sending failure status and resend logic
- Optimize the message response fetching logic when there is no network connection.
- Fix the occasional network connection failure when switching sdkappid across sites
- Fix the issue of being able to search in the cloud after being kicked offline

### TUIKit & Demo
- Added push plugin, console supports viewing statistical indicator data, supports troubleshooting tools
- Added open-source customer service plugin TUICustomerServicePlugin
- TUIChat adds 60-second countdown for sending voice messages
- TUIChat uses the new recall interface, supports displaying the recall operator
- Optimize the display of images/videos/audios hit by security

## 7.5.4864 @2023.10.13 - Enhanced Version
### SDK
- Fixed occasional issue of no callback when retrieving historical messages.
- Fixed occasional issue of local message loss.
- Fixed occasional incorrect message response status.
- Optimized automatic login logic after SDK is kicked out.

## 7.5.4852 @2023.09.27 - Enhanced Version
### SDK
- Optimized retrieval of roaming messages
- Community supports marking group members
- Optimized C API header files
- Added interface to ban the entire group chat
- Added flag field for message response to indicate whether it is a self-response
- Fixed occasional exception in local storage of message reaction
- Fixed issue where the revoke-information of lastMessage in the conversation is empty when a message is revoked
- Fixed issue where the message sender's remarks are empty when receiving friend messages
- Fixed issue where clearing only group chat unread messages also clears unread messages in one-on-one chats
- Fixed issue where onRecvNewMessage callback is not triggered for group messages received during network disconnection
- Fixed occasional crash issue in server search
- Fixed issue where unread count of topic information is not updated after reconnection and retrieval
- Fixed issue where conversation's LastMessage is not updated after custom data is set for the last message of the conversation
- Fixed crash issue when clearing unread notifications on Windows platform using Swift interface with Int.max as input

### TUIKit & Demo
- TUIKit supports RTL language
- TUIChat's voice playback supports manual switching between earpiece and speaker
- Added voice recognition plugin TUIVoiceToText
- Optimized file download
- Replaced the latest cleanConversationUnreadMessageCount interface with read report.

## 7.4.4661 @2023.09.08 - Enhanced Version
### SDK
- Fix the exception caused by clearing unread messages with one click.
- Fix the occasional exception that occurs when searching for cloud messages.

## 7.4.4655 @2023.09.01 - Enhanced Version
### SDK
- Optimize server anti-isolation logic in the network module.
- Optimize HTTP routing logic in the network module.
- Optimize logic for fetching historical messages.
- Improve system logs for conversation groups.
- Fix the issue of occasional inaccuracy in the unread message count for group conversations.
- Fix the issue of occasional inaccuracy in the unread message count for topics in the community.
- Fix the occasional issue of not receiving notifications for conversation group creation.

## 7.4.4643 @2023.08.11 - Enhanced Version
### SDK

- Support subscribing and unsubscribing users
- Support emoji replies
- Support voice-to-text capability
- Support revoking messages in AVChatRoom
- Support setting global message reception options
- Single forwarded message supports automatic renewal of rich media resources
- Voice and video messages support security strike notifications
- Message revoke supports "revoke reason" + "revoker"
- Fixed the issue of inaccurate read status for the last message in a one-on-one chat session
- Fixed the issue of friend remark information not being cleared in time after deleting a friend
- Optimized handling of SQLite file corruption

### TUIKit & Demo

- Support storing conversation group information in the cloud
- iOS optimized video sending process
- Android fixed the issue of continuous voice messages failing to autoplay
- Android fixed the issue of incorrect time display in the call record list
- Android fixed the issue of overlapping items in the Chat Lite message list

## 7.3.4358 @2023.06.21 - Enhanced Edition
### SDK
- Support server message search
- Support filtering conversation list and conversation total unread count by whether it contains unread messages
- Support filtering conversation list and conversation total unread count by whether it contains @ messages
- Adding online identification to group members obtained througn getMemberList API
- Total number of online group members can be obtained for all type of groups
- Optimize the reconnection speed when switching from the background to the foreground
- Optimize the slow problem of pulling local messages in weak network
- Fix the problem of missing the application list after marking the group application as read
- Fix the problem that the conversation cannot be retrieved after sending the first message to a non-friend account
- Fix the problem that the conversation personal information is the previous account information when switching accounts to log in
- Fix the problem that the local field disappears occasionally when pulling historical messages
- Fix the problem that signaling notifications are not throw out occasionally on iOS platform
- Fix the problem that the conversation unread count callback does not take effect after clearing all unread messages
- Fix the problem that detail information are not filled in conversation object when receiving conversation update notification after deleting or renaming the conversation group
- Fix the problem that conversation mark and conversation group change notification are discarded for conversations which do not exist locally
- Fix the problem of symbol conflict between SDK and user code

### TUIKit & Demo
- Support multiple conversation groups and conversation marks
- Add quick meeting function
- Adding the feature of playing the next voice message automatically
- Picture and video viewing supports zooming in and out and adaptive horizontal and vertical screens
- Picture and video upload and download support displaying progress
- Picture and video messages support multi-select sending
- The group information page supports modifying the invitation option
- iOS supports adding suffix names when sending pictures

## 7.2.4146 @2023.05.12 - Enhanced Edition
### SDK
- Fixed the issue that the conversation list failed to be returned before the login is successful.
- Fixed the issue that the unread count of group conversations could not be cleared occasionally.
- Fixed the issue that the last message of the group conversation was not updated occasionally when synchronizing the conversation list.
- Fixed the issue that one end could not synchronize to the other end when it included unread group messages.
- Fixed the issue that sending unread group messages to conference groups will fail.
- Fixed the issue of occasional failure to obtain the total number of unread conversations based on filter conditions.
- Fixed the issue that the local field of the message is occasionally lost when pulling historical messages.
- Fixed the issue that the package MAC rename SDK prompts that the signature fails.

### TUIKit & Demo
- Fixed overseas version TUIKit related experience problems

## 7.2.4123 @2023.04.25 - Enhanced Edition
### SDK

- Supported clearing messages for topics.
- Added the notification for conversation deletion.
- Improved the synchronization speed of conversation lists after login.
- Supported blocking members kicked out of the group from joining again for non-audio-video groups and community groups.
- Supported checking western European languages by words in local content moderation.
- Supported configuring approval options for joining a community group via application or invitation.
- Android offline push supported second-level message category for vivo phones
- Supported configuring the number of long polling tasks on console for audio-video groups.
- Prohibited reverting timestamp for one-to-one message read reporting.
- The sequence of the read reported group message cannot exceed the sequence of the last group message.
- Android offline push is now adapted to Android 12 for Huawei, Mi and FCM channels.
- Fixed the issue that the group name card fields are missing for group messages sent by yourself.
- Fixed the occasional error that message modification callback is not triggered after a message is modified successfully.
- Fixed the issue that repeated callback for onMemberKicked after a member is kicked out of a group.
- Fixed the parsing error for multi-element message in Swift SDK.
- Fixed the issue that there is no callback for pulling group messages under certain conditions.
- Fixed the occasional issue that message unread count is not updated in time after a message is recalled.
- Fixed the occasional OpenSSL crash issue for Android and C/C++.

### TUIKit and demo

- Added call records page.
- Supported specifying target language for message translation.
- Supported customizing time limit for message recall in TUIChat
- Fixed the no response issue when users press Enter to send messages with some third-party input methods

## 7.1.3925 @2023.03.07 - Enhanced Edition

### SDK

- Supported pulling historical group messages by sequence list
- Supported setting whether to clear historical messages when you delete a conversation
- Added an API for deleting conversations in batches
- Supported modifying the approval method of group member invitations
- Supported group counters for community groups
- Added a parameter for setting a message object to bypass the content moderation
- Supported reporting one-to-one message read by timestamp
- Supported reporting group message read by sequence
- Supported getting timestamp of the read message in one-to-one chats
- Supported getting sequence of the read message in group chats
- Fixed the issue that intercepted messages due to local moderation were not saved in the local message database.
- Fixed the issue that unread message count displayed when offline group members logged in again even though the messages had been excluded from the unread count.
- Fixed the occasional issue of inaccurate `isRead` status of messages when users sent and received messages again after a one-to-one chat is deleted.
- Fixed the occasional inconsistency of unread one-to-one message count in multi-device login scenarios.
- Fixed the occasional crashes when file uploading failed.
- Changed enumerated values of `V2TIMGroupApplicationGetType` to those of `V2TIMGroupApplicationType`
- Changed the attribute name `getType` of `V2TIMGroupApplication` to `applicationType`


### TUIKit and demo

- Supported group polling and one-by-one notes
- Improved the minimalist theme
- Optimized the signaling display logic

## 7.0.3754 @2023.01.06 - Enhanced Edition

### SDK

- Supported mentioning (@) group members in all types of messages.
- Supported getting the total message unread count by conversation filter.
- Supported the meta counter for common groups and audio-video groups.
- Supported text message translation.
- Supported custom attributes for community groups.
- Supported setting the Huawei category and Mi channel ID for offline push.
- Optimized the QUIC network reconnection logic.
- Added the base IP logic for COS rich media file download.
- Supported emoji characters in the file paths of rich media messages sent in Windows.
- Supported emoji characters in the C++ SDK log and initialization paths in Windows.
- Fixed the failure in setting custom conversation marks in the v7a architecture.
- Fixed the errors in setting the height of thumbnails or large images.

### TUIKit and demo

- Supported gain control and AI-based noise reduction for TUIChat voice message recording.
- Added the message translation capability in TUIChat. 
- Supported custom ringtones for Android FCM push.
- Optimized the TUIChat performance in loading historical messages in iOS.

## 6.9.3557 @2022.11.29 - Enhanced Edition

### SDK

- Fix an occasional crash of getting V2TIMOfflinePushInfo content from the message on the Android platform
- Fix an occasional crash of the enhanced-pro version on the Android platform
- Optimize the json data content returned by the C interface TIMConvGetConvList

### TUIKit and demo

- Released a new simplified version of the theme, which is more consistent with the style of international apps


## 6.8.3374 @2022.11.14 - Enhanced Edition

### SDK

- Supported local text moderation on clients.
- Released the Swift SDK.
- Supported the group attribute feature for non-audio-video groups.
- Optimized the logic for updating the number of members in a non-audio-video groups when someone entered the group.
- Optimized the COS upload process.
- Optimized the issue of unread message count after operations such as message recall in a community group.
- Fixed the failure to deliver a notification when a custom friend field is set independently.
- Fixed the double callbacks for group listening.
- Fixed the issue where the topic profile under a community group would not be updated timely when a user left the group and then joined the group again.
- Fixed the issue that sender’s profile photo is empty in the callback for inserting a local message successfully.
- Fixed the occasional error when setting message extension after repeated login.
- Fixed the failure to update the message read receipt status in the conversation update callback after all messages in the conversation are marked as read.
- Fixed the occasional emptiness of `send_user_id` in a message when a user sends a message immediately after login callback.
- C++ API: Added an API to check whether a message is read.
- C++ API: Fixed the failure to update the cursor in the result of the paged pulling of the conversation list.

### TUIKit and demo

- Fixed the issue where a search webpage window popped out when a user long pressed a text message on iOS 16.
- TUIChat-iOS: Supported sending GIF images.
- TUIChat-iOS: Fixed image sending status exceptions.
- TUIChat-iOS: Supported the deletion of time when deleting a message.
- Fixed system exceptions caused by iOS TUIOfflinePush.
- Fixed the issue where Android TUIOfflinePush push parameter settings did not take effect.


## 6.7.3184 @2022.09.29 - Enhanced Edition

### SDK

- Supported the messaging extension.
- Supported the signaling editing.
- Supported VoIP for iOS offline push.
- Supported Android offline push in HONOR phones.
- Added the backup domain name in the access layer.
- Fixed the issue where login and logout callbacks cannot be executed in a special network environment.
- Fixed the issue where keeping the group profile empty did not trigger the notification callback.
- Fixed the issue where Mute Notifications for group conversations were not updated after the user leaved a group and joined it again.
- Fixed the crash triggered by sending message read receipts.
- Fixed the issue for C-based APIs where read receipts for one-to-one messages cannot be sent with the SDK.
- For the issue for PC where `TIMGroupModifyGroupInfo` cannot modify combined group attributes.

### TUIKit and demo

- Optimized the group chat creation process.
- Supported setting the background image for the chat area.
- Optimized the theme logic.
- Supported inviting new group members during a group call.
- Supported animoji for Android.
- Fixed the occasional messaging missing in the message list for Android.
- Fixed the occasional error of message sending state in the message list for Android.
- Fixed the issue for Android where the offline push component tried to get the phone model for several times.
- Removed the global style modification for `UIAlertController` from iOS TUICore.
- Added redirecting to the gallery during the shooting for iOS.
- Fixed the issue for iOS where clicking the button triggered a crash after the chat history was cleared.

## 6.6.3002 @2022.08.18 - Enhanced Edition

### SDK

- Supported labeling a member of an audio-video group.
- Supported removing a member from an audio-video group.
- Fixed the occasional crash of the topic update callback for Android.
- Fixed incorrect enumerated values in notifications of group joining option changes.
- Fixed the issue where no callback for `onTopicInfoChanged` was received after custom topic fields were set.
- Optimized the issue for Android where the network IP was requested repeatedly.

### TUIKit and demo

- Supported marking conversations as unread/read, hiding conversations, and folding group conversations.
- Replaced TUICalling with TUICallKit.
- TUICallKit supported displaying the audio or video call in a floating window.
- Supported enabling or disabling group grid profile photos as needed.
- TUIChat supported customizing background images.
- Optimized the TUIOfflinePush component for Android to support calling back the app when users click received messages in the notification bar and to support packaging into native plugins for uni-app.
- The TUIKit  for Android supported a three-tier community mode: community - group - topic.
- Supported showing emoji in the input box for iOS.
- Supported showing default profile photos by group type.
- Supported showing security tips all the time in the Demo.
- Fixed the compatibility and compliance issues arising from using the WebView in the TUICore theme component.
- Fixed the issue where repeated messages displayed occasionally when users clicked messages pushed offline to enter the chat interface.

## 6.5.2816 @2022.07.29 - Enhanced Version

### SDK

- Optimizing the route selection strategy for the Indian station
- Optimize rich media message upload/download progress callback
- Optimized the compliance problem of Android terminal obtaining device process information
- Fix the problem of continuous creation of topics crash
- Fix the problem of occasional crash in Windows package
- Fix Android v7a architecture pull down black friends, add black friends again crash problem

## 6.5.2803 @ 2022.07.15 - Enhanced Edition

### SDK

- Added the support for marking conversations.
- Added the support for grouping conversations.
- Added the support for customizing chat fields.
- Added the advanced API for pulling conversation list.
- Supported receiving broadcast messages of audio-video groups.
- Supported sending notifications of changes to group joining options.
- Added the support for syncing the changes to group message receiving options across terminals.
- Optimized the routing logic for persistent connections and added the support for rotation policy.
- Scheduled to support for Tencent Cloud Japan.
- Upgraded the authorization ID for HTTPDNS routing requests.
- Added the support for HTTPDNS routing at Tencent Cloud International.
- Optimized the start sequence of long polling requests in audio-video groups.
- Fixed the issue where `lastMessage` is missing in topic profile under certain conditions.
- Optimized the logic of pinning a chat to the top.
- Optimized the statistics collection logic of end-to-end message time.
- Fixed the issue where duplicate messages occasionally appeared in historical messages due to the resending of failed messages.
- Fixed the issue where garbled characters were displayed when emojis were sent on earlier mobile phones.
- Fixed the issue where the `faceURL` was empty in the message returned by `onRecvMessageModified`.
- Fixed the issue where the group invitation signaling sent when the invitee was offline couldn't be received after login.


### TUIKit and demo

- Supported displaying the "Typing..." status in one-to-one chat.
- Supported displaying the online status of friends in chats and contacts.
- No longer displayed the "Recall" option 2 minutes after a message was sent.
- Made custom messages intercompatible across terminals.
- Fixed the issue where chats were not rearranged in certain scenarios on Android.
- Removed the TPNS channel from the offline push component.

## 6.3.2619 @2022.06.29 - Enhanced Version

### SDK

- Fixed the occasional crash when getting the topic list
- Fixed the abnormal problem of getting the conversation list after deleting a topic

## 6.3.2609 @2022.06.16 - Enhanced Version

### SDK

- Added the online status and custom status.
- Supported pulling the member list (up to 1,000 persons) of an audio-video group.
- Supported @all messages for a topic.
- Added the friend adding time in the profile of a friend.
- Fixed the issue where cross-platform SQL execution errors occurred.
- Added community topic APIs for the cross-platform SDK.
- Fixed the issue where the unread count was occasionally incorrect when messages of a specified topic was pulled after login.
- Fixed the issue where the call result of the API for getting the list of groups a user has joined was occasionally null when the network was unavailable.
- Fixed the issue where the call result of the API for getting the group owner userID of a group a user has joined was occasionally null.
- Fixed the issue where the role in the member profile obtained by the new group owner was not upgraded after a group was transferred.
- Fixed the issue where search result error occurred when several senders were provided as parameters for the message search API.
- Fixed the issue where the name and profile photo of a sender were inconsistent after message search.
- Fixed the issue where modifying `cloudCustomData` as null did not apply.
- Fixed the issue for iOS where the returned value of `elemType` was `0` after `cloudCustomData` of audio messages was modified.
- Fixed the issue for iOS where the read receipts of one-to-one messages were occasionally not called back.
- Optimized .so loading for Android

### TUIKit and demo

- Supported stickers in chat messages.
- Supported quoting a chat message.
- Supported replying to a chat message.
- Supported read receipts for one-to-one messages.
- Unified the time display format of conversation lists.
- Supported version upgrade check for the demo app.
- Upgraded the brand logo for the demo app.

## 6.2.2363 @2022.04.29 - Enhanced Version

### SDK

- Added the community topic feature.
- Added the message edit API.
- Added support for one-to-one message read receipts.
- Optimized the network quality of the International Site.
- Fixed the issue where a read message was displayed as unread after the app was uninstalled and reinstalled.
- Fixed the issue where when the profile of a non-friend user was obtained, the values of custom fields cannot be updated after they were changed to null.
- Fixed the issue where the `lastMsg` of a one-to-one conversation was inconsistent with the `lastMsg` in the message history when both sides sent a message simultaneously.
- Fixed the issue where after the group owner of a public group approved a group joining request, the callback received by the applicant was incorrect.
- Fixed the issue where the `nameCard` of a message sent by a user was null when the user checked this message.
- Fixed the issue in some cases where the conversation list was not sorted after messages were sent.

### TUIKit and demo

- Added the offline push component and simplified the integration process.
- Supported read receipts for group messages.
- Supported the dark theme for iOS.
- Fixed the issue for Android where the app crashed when an excessively large image was sent and previewed.
- Fixed the issue for Android where after a video message was sent, the duration displayed in the message was inconsistent with the actual duration of the video.
- Fixed the issue for Android where a user cannot continue to handle friend requests after the user handled a friend request.

## 6.1.2166 @2022.04.02 - Enhanced Version

### SDK

- Fixed the issue where no data was returned when two or more userIDs were entered for `senderUserIDList` to search for local messages.
- Fixed the issue where the SDK for Android called back only one message when a user recalled multiple messages with the RESTful API.
- Fixed occasional crashes in quickly clearing unread messages for Windows.

### TUIKit and demo

- Released the International Edition demo.
- Switched offline push back to vendor channels.
- Switched the login with mobile number to the aPaaS service.
- Fixed the failure of audio/video call sync across multiple clients.

## 6.1.2155 @2022.3.18 - Enhanced Version

### SDK

- Added support for read receipts for group messages.
- Added support for setting offline push alert sound for Android.
- Added the API for setting network proxy for mobile SDKs.
- Supplemented offline push APIs for the C/C++ platform.
- Added support for automatically synchronizing signaling messages in a group after login.
- Fixed the issue where a user cannot get complete custom fields after receiving a notification on custom field changes.
- Fixed the notification muting status return error that occasionally occurred when the conversation list was pulled under a weak network.
- Optimized the log printing logic.
- Optimized error descriptions.

### TUIKit

- Upgraded the personal information protection law for TUIKit demo to meet compliance requirements.
- Fixed the issue where a user cannot initiate an audio/video call by tapping the banner notification after receiving an offline push notification.
- Fixed the issue where a user cannot initiate an audio/video call by directly opening the app after switching the app to background and receiving an offline push notification.

## 5.8.1696 @2021.12.10 - Enhanced Version

  ### SDK

  - Fixed the failure to quickly clearing the unread message count of conversations including disbanded or left group conversations.

  ### TUIKit

  - Added the message reply feature.
  - Changed the default skin and optimized the UI logic.
  - iOS: fixed the occasional failure to load resource files.

  ## 5.8.1672 @2021.11.30 - Enhanced Version

  ### SDK

  - Optimized the device information getting logic to meet compliance requirements.
  - Fixed the crashes in quickly clearing the unread message count under certain conditions.

  ## 5.8.1668 @2021.11.19 - Enhanced Version

  ### SDK

  - Added the feature of quickly clearing the total unread message count of all conversations.
  - Added support for the community group (Community) feature. A community group supports up to 100,000 members. Users must activate the Flagship Edition package before they can use the feature.
  - Added the feature of automatically excluding conversions whose message receiving option is "Receive but not notify" or "Not receive" when getting the total unread message count of all conversations.
  - Added support for Chinese SM algorithms for encrypted tunnels of persistent connections.
  - Fixed the issue where, when historical messages were pulled, the end tag was incorrectly determined occasionally.
  - Fixed the issue where, when the SDK was upgraded from the Basic Edition to Enhanced Edition in overriding mode, audio-video groups that users previously joined had unread message count.
  - Fixed the failure to setting auto read reporting for accounts in special formats.
  - Fixed the occasional error of connecting to incorrect servers during frequent network reconnections in private environments.
  - Fixed the issue where, in multi-client sync scenario, when a user received a group message sent by the user, the SDK automatically clears the unread message count of the group conversation.
  - Fixed the issue where there is occasionally no callback when users log in again after going offline and being kicked off.
  - Cross-platform SDK for C: added support for supplementing offline push fields when receiving a new message.

  ### TUIKit

  - Optimized the notification muting logic.
  - Optimized the logic for displaying a red dot for unread messages in the conversation list.
  - Added support for allowing users to trigger group @ messages by tapping and holding the group profile photo.
  - Added support for allowing users to tap a button to stop voice message playback.
  - Added the feature of quickly clearing the total unread message count of all conversations.
  - Added support for the community group feature.

  ## 5.7.1435 @2021.09.30 - Enhanced Version

  ### SDK

  - Fixed the issue where local data was not updated in time after group profile custom fields were modified.
  - Fixed the issue of synchronizing a large number of conversations to be pinned on top.
  - Fixed the issue where Android device timeout signaling did not contain the custom data entered during invitation.
  - Fixed the issue where empty profiles overwrote local profiles due to network request failures during non-friend profile pulling.
  - Fixed the issue where historical group messages could be pulled after a user left the group and then joined the group again.
  - Fixed the issue where the callback function `onFriendListDeleted` was called twice after a friend was deleted.
  - Fixed the issue where the friend remarks of the last message of a conversation were empty.
  - Fixed the issue where, after the IM SDK was initialized, there was no callback for a `getConversationList` API call by a user who has not logged in.
  - Fixed the issue where, if failed messages were sent in a group conversation after the network was disconnected, there was no unread message count displayed when the first message was received in the conversation after the network connection was restored.
  - Fixed the issue where the unread message count could not be obtained in the first conversation with a stranger.
  - Fixed the issue where the Mute Notifications option for group messages was not updated in certain conditions.
  - Fixed the issue where incomplete content was called back after group attribute update.
  - Added the listener addition and deletion APIs for SDKs, groups, relationships, and conversations.
  - iOS: fixed the issue where audio-video group (AVChatRoom) creation failed when the group joining mode was not set.

  ## 5.1.66 @2021.09.22 - Basic Version

  ### Android

  - Removed the feature of getting Wi-Fi information.

  ## 5.6.1202 @2021.09.10 - Enhanced Version

  ### SDK

  - Fixed the issue where, after a user left a group and then joined the same group again, the system included the messages that were not received during this period into the unread message count of the conversation.
  - Fixed the failure to delete group messages that failed to be sent by muted users.
  - Fixed the issue where, when historical messages were pulled, the nicknames and profile photos of message senders were occasionally restored to previous ones.
  - Added support for setting whether to support unread message count in meeting groups.
  - Added support for the international websites of Singapore, South Korea, and Germany, supporting acceleration domain names.
  - Fixed the issue where received image messages occasionally had incorrect image formats.
  - Fixed the issue where, when video messages were sent in Windows, thumbnail sending occasionally failed.
  - Optimized the report of the success rate of receiving common group messages.
  - Fixed the issue where, after group members are muted in an audio-video group, the muting period obtained through getting the group member profile is 0.

  ## 5.6.1200 @2021.08.31 - Enhanced Version

  ### SDK

  #### Common changes

  - Improved the login speed.
  - Added support for the international websites of Singapore, South Korea, and Germany.
  - Added support for commercial HTTP DNS.
  - Optimized the group attribute logic to solve the concurrency problem when group attributes are modified on multiple devices at the same time.
  - Improved the message database query speed.
  - Improved the network connection policy.
  - Optimized the search of image, video, and voice messages.
  - Reduced the time for getting the conversation list (`getConversationList`).
  - Optimized the third-party callback logic for server-side status change: when login on a device causes logout on another device, the server-side logout callback is no longer triggered.
  - Removed the feature of read reporting for audio-video groups.
  - Unified login error codes.
  - Changed the friend search callback parameter `V2TIMFriendInfo` to `V2TIMFriendInfoResult` so that the friend relationship can be determined based on `relationType`.
  - Added the API for getting offline push configuration for the message object.
  - Fixed the occasional database crash during the update of user profiles.
  - Fixed the database query and operation failures before SDK initialization is completed.
  - Fixed the issue where read receipts became invalid after an app is uninstalled and then reinstalled.
  - Fixed the issue where `onFriendListAdded` was occasionally called twice.
  - Fixed the failure to delete messages that are inserted locally.
  - Fixed the issue where group profile custom fields were not saved when group notifications are saved to the database.
  - iOS: removed the `Tag_Profile_Custom_` prefix when getting custom user fields and removed the `Tag_SNS_Custom_` prefix when getting custom friend fields.
  - Android: removed the carrier name and Wi-Fi information getting features and AndroidX dependency.
  - Android: fixed crashes caused by non-UTF-8 encoding.

  ### TUIKit and demo

  - Added the pulling-by-page logic for group member list related pages.
  - Android: optimized the issue where the entire conversation list was loaded each time a message was deleted or recalled.
  - Android: optimized the issue where the group profile photo was loaded each time when the conversation list was loaded.
  - iOS: fixed the issue where the displayed number of records was incorrect when a user clears the original keyword and enters a new one to search for messages.
  - iOS: fixed the issue where searched custom messages were not displayed on the chat screen.

  ## 5.5.897 @2021.07.29 - Enhanced Version

  ### SDK

  - Fixed occasional crashes when data was reported.

  ### Android

  Removed the calling of `getSimOperatorName()` for getting the carrier name.

  ## 5.1.65 @2021.07.29 - Basic Version

  ### Android

  Removed the calling of `getSimOperatorName()` for getting the carrier name.

  ## 5.5.892 @2021.07.14 - Enhanced Version

  ### SDK

  - Added support for message search by multiple keywords combined with AND or OR.
  - Added support for message search by a specified message sender account.
  - Added support for historical message pulling by a specified time range.
  - Added support for historical group message pulling by a specified sequence.
  - Added notifications for message modifications by a third-party callback.
  - Added the API for getting the maximum number of group members that can be added to a group.
  - Added the `orderKey` field for sorting conversation objects to facilitate sorting conversations without the last message at the app layer.
  - Optimized the audio-video group message receiving latency by making the backend complete account conversation in advance.
  - Upgraded the network connection scheduling protocol to reduce the network connection time outside the Chinese mainland.
  - Optimized the conversation list pulling logic.
  - Optimized the group member pulling logic and enabled local cache.
  - Fixed the issue where log callback was not triggered when the log level was lower than Debug.
  - Fixed the issue where group member profiles obtained did not include friend remarks.
  - Fixed the issue where the obtained list of groups the user has joined contained groups to be approved by the group owner.
  - Fixed the stability issue reported online.

  ## 5.4.666 @2021.06.03 - Enhanced Version

  ### SDK

  - Changed the name of Lite Edition SDK to Enhanced Edition SDK.
  - Added support for message, group, and friend search.
  - Added a parameter to specify whether to update the last message of the conversation during message sending.
  - Added support for clearing the roaming messages of a conversation while retaining the conversation.
  - Added support for concurrent multi-device login on the same platform.
  - Reduced the time for network connection and login.
  - Optimized the data reporting feature.
  - Optimized the offline push logic to support disabling offline push globally.
  - Optimized the offline push logic to allow setting the message classification field `classification` for vivo phone offline push.
  - Fixed the occasional incorrectness of the unread message count of one-to-one conversations.
  - Optimized the historical message pulling speed.
  - Added support for adding emojis and locations to multi-element messages.
  - Fixed the issue where, if an offline user changed the user's nickname in a group, the user's nickname in the corresponding conversation was not updated in a timely manner when the user logged in the next time.
  - Fixed the issue where the 20005 error code was occasionally reported when read messages of one-to-one conversations were reported.

  ## 5.3.435 @2021.05.20 - Lite Edition

  ### SDK

  - Added the API for deleting conversation roaming messages.
  - Fixed the issue where some Android phones could not receive network status change notifications over persistent connections.
  - Optimized the logic for pulling user profiles to avoid requesting the backend every time when strangers request for user profiles.
  - Fixed the issue where group profiles and historical messages could not be obtained when the groups were deleted but conversations were retained.
  - Fixed the issue where conversations were out of order when you got them via the API for getting a conversation list.
  - Fixed the issue where group conversations in Mute Notifications mode were filtered out when getting the total message unread count.
  - Fixed the occasional crashes caused by iOS HTTP requests.

  ## 5.1.62 @2021.05.20 - Basic Version

  ### SDK

  - Fixed known issues.

  ## 5.3.425 @2021.04.19 - Lite Edition

  ### SDK

  - Added support for pinning a conversion on top.
  - Added support for setting the Mute Notifications option for one-to-one messages.
  - Added support for sending messages that are excluded from the unread count.
  - Added support for getting local conversation and message data when there is no network connection or your login fails.
  - Added XCFramework (supporting Mac Catalyst) to the SDK for iOS.
  - Added the API for getting the conversation unread count.
  - Added the `birthday` field to personal profiles.
  - Fixed the issue where, when group @ messages were recalled, the conversations of the @ target users still contained the group @ notification.
  - Fixed the issue where, for some Android phones, the network would be disconnected and connected again after a successful initial network connection during persistent connections.
  - Fixed the issue where users could not set custom fields when creating a group in the SDK for iOS.
  - Fixed the issue where users with special accounts could not search for local messages via `findMessage`.

  ## 5.1.60 @2021.04.06 - Standard Edition

  **iOS**

  - Fixed the issue where the SDK may be rejected by the App Store for using IDFA related keywords.

  ## 5.2.212 @2021.04.06 - Lite Edition

  **iOS**

  - Fixed the issue where the SDK may be rejected by the App Store for using IDFA related keywords.

  ## 5.2.210 @2021.03.12 - Lite Edition

  ### SDK

  **Common changes**

  - Added support for forwarding multiple messages as a combined single message.
  - Optimized the logic of persistent connections, improving the quality of connections outside the Chinese mainland.
  - Specified login error codes in a detailed way to distinguish whether the network is normal during login.
  - Optimized the logic of COS upload, providing better experience of sending rich media messages.
  - Added the advanced API for getting historical messages.
  - Added the API for getting conversations in batches.
  - Added the API for checking friend relationships in batches.
  - Fixed the issue where two messages were generated in the local database after a message that failed to be sent was sent again.
  - Fixed the issue where the muting time called back was incorrect when the group member profile was changed.
  - Fixed the issue where the width of the image called back was incorrect when an image message was received.
  - Fixed the issue where the console still printed logs after `logLevel` was set to `None`.
  - Fixed the issue where the `add_source` field of adding friends was incorrect.
  - Fixed the issue where sometimes the sending progress called back was negative when a video file greater than 24 MB was sent.

  ## 5.1.56 @2021.03.03 - Standard Edition

  ### SDK

  **Common changes**

  - Optimized the logic of persistent connection, improving the quality of connections outside the Chinese mainland.
  - Optimized data reporting and specified error codes related to network timeout in a detailed way.
  - Fixed known stability issues.

  **iOS**

  - Fixed occasional failures of extracting logs in the iOS SDK.

  **Android**

  - Replaced the log component of the Android SDK to improve stability.

  **Windows**

  - Fixed the issue where the client thread might block the SDK logic thread when a new message callback was triggered in the Windows SDK.

  ## 5.1.138 @2021.02.05 - Lite Edition

  ### SDK

  **Common changes**

  - Optimized logging.
  - Optimized the policy of persistent connection, improving the quality of connections outside the Chinese mainland.
  - Fixed the issue where sometimes the last message was incorrect when multiple one-to-one messages were sent or received in the same second.
  - Fixed the issue where sometimes there was no callback for querying the conversation list.
  - Fixed the issue where sometimes the sequence number of a one-to-one message was incorrect.

  **Android**

  - Fixed the issue where sometimes a negative upload progress was displayed when a video greater than 24 MB was sent.
  - Fixed occasional crashes when messages were sent.

  ## 5.1.50 @2021.02.05 - Standard Edition

  ### SDK

  - V2 APIs added the `random` field for message objects.
  - Added support for recalling the `lastMsg` message in a conversation.
  - Fixed occasional exceptions in the status of the last message obtained via the `getMessage` API.
  - Fixed the issue where messages were delayed when user profiles were frequently pulled after messages were received.
  - Fixed the issue where deleting the account might cause the failure to pull the group member list.
  - Fixed the issue where the message might not be found when `findMessage` was called after `insertLocalMessage`.
  - Fixed the issue where a conversation update callback was triggered when a conversation was deleted.
  - Fixed the issue of the Android SDK where the nicknames of historical group messages were not timely updated.
  - Improved the database stability of the iOS SDK.

  ### TUIKit and demo

  - Fixed the issue of the Android TUIKit where a black screen was displayed when you tried to view the original images that were not downloaded.
  - Fixed the internationalization issue of the iOS version.
  - Fixed the issue of the iOS version where images were overwritten when multiple images were sent at a time.
  - Fixed the issue of the iOS 14 operating system where there was no response when you clicked the "add" or "delete" button on the group details page.
  - Fixed the issue of the iOS 14 operating system where the tab bar disappeared after you left a group conversation and went back to the message list.

  ## 5.1.21 @2021.01.15 - Standard Edition

  ### SDK

  **Android**

  - Fixed the issue where custom messages with the extended field `extension` failed to be sent on the Android platform.

  ### TUIKit and demo

  **iOS/Android**

  - Improved internationalization support by eliminating the issue where there were Chinese characters in the English version.

  ## 5.1.137 @2021.01.29 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed the issue where there was no callback for the login API occasionally when a user logged in to the same account repeatedly on multiple iOS devices or Android devices.

  **Android**

  - Fixed crashes that occurred occasionally when a low-end Android device tried to obtain the log path.

  ## 5.1.136 @2021.01.27 - Lite Edition

  ### SDK

  **Common changes**

  - V2 APIs added an API for log callbacks.
  - Fixed the issue where the UserID of the @ target user in the group @ message was empty.
  - Fixed the issue where audio-video group messages occasionally could not be received.
  - Fixed the occasional issue of incorrect login status in the case of frequent network reconnection.
  - Fixed the issue where users occasionally failed to log in again after going offline and being kicked off.
  - Fixed occasional crashes in DNS resolution.

  ## 5.1.132 @2021.01.22 - Lite Edition

  ### SDK

  **Common changes**

  - Added support for overload protection in the network module.
  - Fixed the issue where some sessions occasionally were lost when the standard edition was upgraded to the Lite Edition.
  - Fixed the issue where the `onUserSigExpired` callback could not be received after the login information expired.
  - Fixed the issue where a member received the `onMemberKicked` callback after being kicked out of a group and joining the group again.

  ## 5.1.131 @2021.01.19 - Lite Edition

  ### SDK

  **Common changes**

  - Added the API for forwarding a single message.
  - Optimized the logic of receiving audio-video group messages. When an audio-video group receives a message, the sender’s nickname and profile photo are no longer queried.
  - Fixed the issue where there was no conversation update notification when the last message in a conversation was deleted.
  - Fixed the issue where the unread messages count in one-to-one conversations occasionally was cleared when the one-to-one messages were synchronized after login.
  - Fixed the issue where the last message in a conversation was not updated when the conversation list was synchronized after a user went offline and then online.

  **Android**

  - Fixed the issue where the settings of the custom message field `description` and personal profile fields `level` and `role` did not take effect.
  - Fixed occasional crashes during deinitialization.

  ## 5.1.129 @2021.01.13 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed the issue where a conversation update callback was triggered when a user tried to get the conversation list and there was no conversation update.
  - Fixed the issue where the last message in a conversation was not cleared when a user tried to delete all the messages in the conversation.

  **iOS**

  - Fixed the issue where the returned information was not `nil` when a non-signaling message was passed in using the `getSignallingInfo` method.

  **Android**

  - Fixed occasional crashes caused by JNI local reference table exceeding the limit.

  ## 5.1.20 @2021.01.08 - Standard Edition

  ### SDK

  **Common changes**

  - V2 custom messages added the `desc` and `ext` fields.
  - V2 user profile APIs added the `role` and `level` fields.
  - Optimized V2 APIs. Whether your login is successful or not, you can get the data of the local conversation list and local historical messages.
  - V2 added the `getHistoryMessageList` API to support getting cloud or local messages and getting messages sent before or after a specific time.
  - Optimized the issue in getting the profile photos of one-to-one messages.
  - Optimized the security and renewal of rich media message file upload.
  - Fixed the issue where the local paths of sent rich media messages were empty.
  - Fixed the issue where when a local message was inserted into a group, the previous message was displayed as the `lastMessage` of the conversation after you logged out and logged back in.
  - Fixed the Elem out-of-order issue.
  - Fixed the issue where the @ prompt still existed in the message list after the group @ message was recalled.
  - Fixed the issue where system messages were pulled when you pulled the offline historical group messages after going online.
  - Fixed the issue where two offline push notifications were received when only one signaling invitation for a voice call was sent.
  - Fixed the issue where the settings of local "custom message data" became invalid when there were too many messages.
  - Fixed the issue where the unread number did not decrease after an unread group message was recalled.
  - Fixed other stability issues.

  **iOS and Mac**

  - Fixed receiver crashes that occurred when `array json` was passed for custom messages.
  - Fixed crashes after calling `deleteConversation` and passing the wrong conversation ID.
  - Fixed the issue where the last draft in the draft box could not be deleted.

  ### TUIKit and demo

  - Fixed the issue where the information of the conversation pinned to the top was not deleted after you deleted the friend or left the group on the iOS platform.
  - Fixed the issue where after a user was set as the administrator, the console still showed that the user did not have the administrator permissions on the iOS platform.
  - Fixed crashes that occurred when the thumbnail was empty on the iOS platform.
  - Fixes the issue where there was an exception in the height of a recalled long-text message on the iOS platform.
  - Fixed the issue where group muting tips were not displayed on the iOS platform.
  - Optimized the time display of the conversation UI on the iOS platform.
  - Fixed crashes that occurred when a user clicked **Back** after the creation of a live room entered the countdown process on the Android platform.
  - Fixed the issue where the call interface did not disappear when a member refused to answer the call in a group chat on the Android platform.
  - Fixed the issue where the small window was not closed when a viewer in the live room was kicked offline in the small window mode on the Android platform.
  - Fixed occasional crashes that occurred when someone joined a group on Android devices.

  ## 5.1.125 @2021.01.08 - Lite Edition

  ### SDK

  **Common changes**

  - V2 APIs added the `random` field for message objects.
  - V2 APIs added the `description` and `extension` fields for custom messages.
  - V2 APIs added the `role` and `level` fields for user profile objects.
  - Fixed the database compatibility issue in the upgrade from versions below 4.8.1 to the Lite Edition.
  - Fixed the issue where users occasionally received the callbacks of messages sent by themselves.
  - Fixed the issue where there was no callback when you tried to get the list of groups that you joined when you hadn’t joined any group.
  - Fixed the issue where there was no conversation update callback when setting group message receiving options.
  - Fixed the issue where occasionally there was no end callback for conversion synchronization.
  - Fixed occasional crashes during conversion synchronization.

  ## 5.1.123 @2020.12.31 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed the issue where the Android edition could not receive custom group system messages sent via the RESTful API.
  - Optimized the method of generating the value of the `random` field for a message.
  - Optimized log printing to facilitate troubleshooting.
  - Fixed occasional crashes in the network module.

  ## 5.1.122 @2020.12.25 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed the issue where there might be no callback when setting conversation drafts.
  - Fixed the issue where the message sender information was not completed when searching for messages via `findMessage`.
  - Fixed the issue where it might fail to search for messages via `findMessage` after inserting local messages.
  - Fixed the issue where conversation objects were not updated when setting group message receiving options.
  - Fixed the issue where conversation change notifications were not sent when personal or group nicknames or profile photos were changed.
  - Fixed the issue where the last message in a conversation was not updated when inserting local messages.
  - Enabled on-cloud control over personal profile update cycle.

  **iOS**

  - Fixed occasional crashes caused by improper dictionary or array operations.

  **Android**

  - Fixed occasional crashes when deleting messages.

  ## 5.1.121 @2020.12.18 - Lite Edition

  ### SDK

  **Common changes**

  - Optimized the group profile pull logic. For audio-video groups, users’ own group member information does not need to be pulled.
  - Improved log printing and added the device type field.
  - Fixed the issue where, when a message recall notification was received in a one-to-one conversation, the status of the last message in the conversation was not updated.
  - Fixed the issue of excessive message delay during long polling in an audio-video group.
  - Fixed the issue where, when a user logged in to the same account repeatedly and then joined the same audio-video group, the message long polling module did not update the message pull key.

  **iOS**

  - Fixed the issue where, when a JSON array was passed in for custom message fields on iOS, the signaling module on the receiving end crashed during parsing.

  **Android**

  - Fixed occasional crashes when setting conversation drafts.

  ## 5.1.118 @2020.12.11 - Lite Edition

  ### SDK

  **Common changes**

  - Optimized the message deduplication logic and fixed the issue where repeated callbacks were triggered for the same message.
  - Added an API for local insertion of one-to-one messages.
  - Fixed the issue where the unread group message count did not decrease when unread group messages were deleted or recalled.
  - Fixed the issue where messages that failed to be sent could not be deleted.
  - Fixed the issue where the deletion failure callback was triggered when a user attempted to delete a conversation in a group that the user had left or a group that had been deleted.
  - Fixed the issue where the setting failure callback was triggered when a user attempted to enable group message read reports for a group that the user had left or a group that had been deleted.

  **iOS**

  - Fixed the issue where setting the signature in personal profiles failed.

  **Android**

  - Fixed the issue where adding a friend to a blocklist occasionally led to crashes.
  - Fixed the issue where no message ID was returned when a message was sent.

  ## 5.1.10 @2020.12.04 - Standard Edition

  ### SDK

  **Common changes**

  - V2 APIs added support for custom group fields and multi-element messages.
  - V2 APIs added an API for the local insertion of one-to-one messages.
  - Mitigated the issue of message loss for ordinary groups and audio-video groups.
  - Fixed the issue where messages that failed to be sent could not be deleted.
  - Fixed the one-to-one conversation issue where, if the first message was sent online, the read receipt was not received.
  - Fixed the issue where, after a recalled message was returned through the API for pulling historical messages, the message status was incorrect.
  - Fixed the failure to return information of all friend lists when `null` was entered as the friend list name for the API for obtaining friend list information on iOS.
  - Fixed known stability issues.

  ## 5.1.115 @2020.12.04 - Lite Edition

  ### SDK

  **Common changes**

  - Optimized synchronization between the signaling timeout threshold and server time.
  - Fixed occasional failures in establishing connections on a weak network.

  **iOS**

  - Completed API header files.

  **Android**

  - Fixed crashes by replacing Gson with JSON.

  ## 5.1.111 @2020.12.01 - Lite Edition

  ### SDK

  **Common changes**

  - Improved log printing.
  - Fixed known stability issues.

  ## 5.1.2 @2020.11.11 - Standard Edition

  ### SDK

  **iOS and Mac**

  - iOS allows iPhones and iPads to be online at the same time.
  - Mac supports the ARM64 architecture.

  **Android**

  - Fixed a stability issue in the Android edition.
  - Substituted the standard TRTC dependency package.

  ## 5.1.110 @2020.11.26 - Lite Edition

  ### SDK

  **Common changes**

  - Added all V2 APIs.
  - Added the conversation feature.
  - Added the relationship chain feature.
  - Added the group @ feature.
  - iOS allows iPhones and iPads to be online at the same time.
  - Added support for multi-element message sending.
  - Supplemented custom fields in group profiles.
  - Fixed known stability issues.

  ## 5.1.1 @2020.11.05 - Standard Edition

  ### SDK

  **iOS/Android**

  - Added an API to obtain the number of online users in an audio-video group (AVChatRoom).
  - Added an API to query messages based on the unique ID.
  - Added an API to obtain the server calibration timestamp.
  - Optimized the login speed.
  - Optimized the group profile pull logic.
  - Fixed the issue where pulling local messages failed after users left a group.
  - Fixed the issue where, after a successfully sent message was modified by a third-party callback, the message on the sender end was not promptly updated.
  - Fixed the issue where, after configuration via the console, conversations of meeting groups still did not support unread counts.
  - Fixed the issue where users in an audio-video group (AVChatRoom) occasionally failed to receive messages.
  - Fixed some other occasional stability issues.

  ### TUIKit and demo

  **iOS/Android**

  - Group members can input `@All`.
  - TUIKit components added international support.
  - Added support for selecting videos when sending image messages through the Android edition.
  - Optimized the timeout logic for voice and video call requests.
  - Updated Android offline push to be dependent on the TPNS package.
  - Group live streaming added an opening animation.
  - Group live streaming added support for a small livestreaming window.

  ## 5.0.108 @2020.11.02 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed a stability issue in the iOS edition.
  - Fixed the occasional message callback failures in the Android edition.

  ## 5.0.10 @2020.10.15 - Standard Edition

  ### SDK

  **iOS/Android**

  - Optimized signaling APIs to support the setting of `onlineUserOnly` for online messages and `offlinePushInfo` for offline push messages.
  - Optimized the async callback for the API for obtaining a single conversation.
  - Added an API for obtaining group types for conversations to facilitate display filtering of the conversation list.

  ### TUIKit and demo

  **iOS/Android**

  - Added [group livestreaming](https://intl.cloud.tencent.com/document/product/1047/37310) features, such as co-anchoring, gifts, beauty filter, and voice changing.
  - Added [live rooms](https://intl.cloud.tencent.com/document/product/1047/38519) that support co-anchoring, PK, likes, gifts, beauty filter, on-screen comments, following friends, and other features.
  - Optimized the recognition of audio and video signaling.

  ## 5.0.106 @2020.09.21 - Lite Edition

  ### SDK

  **Common changes**

  - Fixed known stability issues.

  ## 5.0.6 @2020.09.18 - Standard Edition

  ### SDK

  **Common changes**

  - Added the group @ feature.
  - Added the `deleteMessages` API for iOS and Android, which will simultaneously delete local and roaming messages.
  - When deleting a conversation, the `deleteConversation` API also deletes local and roaming messages.
  - API2.0 added APIs for setting and obtaining custom fields for user profiles, friend profiles, and group member profiles.
  - Optimized image upload compatibility issues.
  - Fixed the issue where after the group message receiving option was modified and then immediately obtained, the option remained unchanged.
  - Fixed the issue where after a local C2C conversation was deleted, C2C system notifications updated the conversation but the message `elem` was empty.
  - Fixed the issue where image upload failed when the userID contained Chinese characters.
  - Fixed the issue where after an account with special characters successfully set the user nickname and entered the group to send a message, the nickname was still blank in the new message callback received by other group members.
  - Fixed known crashes.

  **iOS**

  - Fixed the crash issue that occurred when message listening was removed.
  - Fixed the issue where deleting a conversation peer account led to exceptions in obtaining the conversation.
  - Mitigated the issue of initialization lag.

  **Android**

  - Optimized the processing for signaling sending timeout failure.
  - Fixed the issue of invalid custom data for the signaling cancellation API.
  - Fixed the issue where attempts to delete all attributes failed when `null` was passed in for the `keys` of the group attribute deletion API.
  - Fixed the issue where signaling group calls could still be accepted or rejected after being accepted or rejected.
  - Fixed the multi-element resolution issue for API 2.0.

  **Windows**

  - Fixed the known issue of memory leak.
  - Optimized log upload.
  - Fixed the issue where a user who simultaneously logged in to the same account from multiple PCs of the same model was not forced offline.
  - Fixed the issue where received messages were out of order on a PC.

  ### TUIKit and demo

  **iOS**

  - Added the group @ feature.
  - Added new emoji packs.
  - Updated the SDWebImage dependent library.
  - Optimized UI display for applications to join a group.
  - Optimized the text display of voice and video calls.

  **Android**

  - Added the group @ feature.
  - Fixed the issue where the contacts displayed during group creation might be inconsistent with those actually selected.
  - Fixed the issue where the display of custom messages might be out of order.
  - Fixed occasional crashes of AVCallManager and TRTCAVCallImpl.
  - Added new emoji packs.

  ## 5.0.102 @2020.09.04 - Lite Edition

  ### SDK

  **Common changes**

  - Released the Android & iOS Lite-Edition SDK.
  - Compared with the standard edition SDK, the Lite Edition SDK removed the friend and conversation capabilities and optimized some service logic to ensure higher execution efficiency and a smaller installation package size.

  ## 4.9.1 @2020.07.24 - Standard Edition

  ### SDK

  **Common changes**

  - Optimized login outside the Chinese mainland.
  - Fixed file upload failures in some regions outside the Chinese mainland.
  - Fixed file upload failures for accounts containing the @ symbol.
  - Fixed occasional errors with unread count of one-to-one messages.
  - Fixed occasional exceptions in conversation `showName` display.
  - Added an API for obtaining the download URL of file messages.

  **iOS**

  - Fixed the issue where there was no callback when users attempted to obtain one-to-one messages while network connection was not available.

  **Android**

  - Fixed occasional crashes of signaling parsing APIs.
  - Fixed occasional crashes when obtaining offline push information.
  - Fixed the issue of no callback when API 2.0 `getFriendApplicationList` carried no data, and fixed the issue of no callback when non-members were specified for `getGroupMembersInfo`.

  **Windows**

  - Added detailed group information when users obtain the list of groups joined.
  - Fixed the failure to send small files.
  - Fixed error 6002 reported by logs.

  ### TUIKit and demo

  **iOS**

  - Added push of offline voice and video calls and enabled redirection to the call answering interface.
  - Fixed failure to delete or recall custom messages.
  - Optimized the interface.
  - Migrated the voice and video code from Swift to Objective-C to substantially reduce third-party dependent libraries.
  - Added support for TUIKit pod integration of two types of voice and video dependent libraries: LiteAV_TRTC and LiteAV_Professional.

  **Android**

  - Optimized the offline push of the demo and upgraded the push SDK version for each vendor.
  - Added push of offline voice and video calls and enabled redirection to the call answering interface.

  ## 4.8.50 @2020.06.22 - Standard Edition

  ### SDK

  **Common changes**

  - Fixed the API 2.0 issue where the `onMemberEnter` callback was not triggered when someone entered an audio-video group (AVChatRoom).
  - Added the `groupID` parameter to the `onGroupInfoChanged` and `onMemberInfoChanged` callbacks of API 2.0.
  - Fixed the issue where there was no conversation update callback after a one-to-one message was sent successfully.
  - Fixed the issue where a user failed to receive messages after switching accounts and joining the same audio-video group (AVChatRoom).
  - Fixed the occasional issue of incorrect callback sequence during unread message synchronization after login.
  - Adding signaling APIs.
  - Added the custom group attribute API for audio-video groups (AVChatRoom).
  - Fixed known crashes.

  **Android**

  Changed the default log storage location to `/sdcard/Android/data/package name/files/log/tencent/imsdk` to be compatible with Android Q versions.

  **Windows**

  Fixed group member role issues during group creation.

  ### TUIKit and demo

  **iOS**

  - TUIKit replaced API 2.0.
  - Integrated TRTC to realize the voice and video call feature.
  - Added the deep-color mode.

  **Android**

  - TUIKit replaced API 2.0.
  - Integrated TRTC to realize the voice and video call feature.
  - Supports AndroidX.

  ## 4.8.10 @2020.05.15

  ### SDK

  **Common changes**

  - iOS and Android support IPv6.
  - Audio-video groups (AVChatRoom) support dynamic updates of the group member list.
  - Fixed xlog crashes.

  **iOS and Mac**

  - Fixed the failure of iOS to send big files.
  - Fixed the exceptions that occurred when `getFriendRemark` was triggered to fetch the sender’s friend remark in a V2TIMMessage message.

  **Android**

  - IM SDK supports AndroidX.
  - Fixed the crashes of Android devices caused by network permission issues.

  ## 4.8.1 @2020.04.30

  ### SDK

  **Common changes**

  - Launched brand-new API 2.0 for iOS & Android.
  - Fixed conversation errors when users logged in to different accounts in certain scenarios.

  ## 4.7.10 @2020.04.23

  ### SDK

  **Common changes**

  - Fixed login timeout in some network environments.
  - Fixed inaccurate unread counts in some scenarios.

  ## 4.7.2 @2020.04.03

  ### SDK

  **Common changes**

  Fixed a data error.

  ## 4.7.1 @2020.03.23

  ### SDK

  **Common changes**

  - Optimized the local log size.
  - Optimized the login time.
  - Fixed the multi-terminal unread count synchronization issue.
  - Added the `getFriendList` API.
  - The iOS and Android SDKs enable you to set the message title and content to display on the offline push notifications bar of iOS and Android devices, respectively.

  ## 4.6.102 @2020.02.28

  ### SDK

  **Common changes**

  - Fixed slow message pulling in some scenarios.
  - Fixed the compatibility issue with sending 3.x version audio messages to later versions.
  - Fixed the issue where the identifiers of some conversions in the obtained conversion list were null.
  - Fixed known crashes.
  - Fixed SOCKS5 proxy users' password verification issue.
  - Optimized the pending group processing logic.
  - Improved the file upload limit to 100 MB.
  - Optimized COS upload.
  - Fixed the issue where an exception was returned for obtaining the friend list if there was no friend.

  ## 4.6.56 @2020.01.08

  ### SDK

  **Common changes**

  - Mitigated the issue where memory grew when user profiles were frequently pulled.
  - Improved compatibility with special characters in user profiles.
  - Fixed known crashes.
  - Fixed occasional login failures when accounts are switched frequently.
  - Fixed reconnection in the pressure test.

  ## 4.6.51 @2019.12.23

  ### SDK

  **Common changes**

  - Improved network connection quality to quickly detect network quality changes.
  - Optimized audio-video group message handling.

  **iOS and Mac**

  - Changed all IMSDK listeners from strong references to weak references of external objects.
  - Added the `getSenderNickname` API for messages.

  **Android**

  - Fixed the issue where offline users are kicked off.
  - Fixed exceptional upload progress callback on devices running earlier Android versions.
  - Fixed memory leak during login.
  - Added the `getSenderNickname` API for messages.

  **Windows**

  - Fixed the issue where messages failed to be sent to newly added friends.
  - Improved modification and query of custom fields for group information and group member information.
  - Improved callbacks for all APIs to ensure that callbacks will be called and that objects are transferred to JSON strings only when callbacks succeed and empty strings are returned when callbacks fail.

  ### TUIKit and demo

  **Android**

  - Profile photos displayed in conversation lists can be set with rounded corners.
  - Fixed the issue where account switching is exceptional when a conversation is pinned to the top.

  ## 4.6.1 @2019.11.13

  ### SDK

  **Common changes**

  - Roaming messages can be recalled.
  - Fixed the unread count error when a user was invited to join a group in silent mode through a RESTful API.
  - Fixed occasional message sending exceptions due to poor network connection.
  - Fixed incorrect logic for role filter conditions when group members are obtained.
  - Fixed the issue where the SDK failed to get the group name the first time users sent a message in a group created by a RESTful API.
  - Fixed the issue where `getUsersProfile` failed to get user information after caching was disabled.
  - Fixed the issue where voice message files without a suffix could not be downloaded after they were received.

  **iOS and Mac**

  - Added OPPOChannelID settings to fix the issue where OPPO mobile phones running Android 8.0 or later failed to receive iOS push messages.
  - Optimized annotations to `getGrouplist` return objects.

  **Android**

  - Offline pushed channelID on OPPO mobile phones running Android 8.0 or later can be configured in the console.
  - The ext, sound, and desc fields of `TIMCustomElem` have been deprecated.

  **Windows**

  - Fixed the exceptional type field of group system messages.
  - Fixed inconsistent group type and header file in the returned group information.
  - Fixed the issue where specifying custom group fields failed during group creation.
  - Added sender profile and offline push configuration to messages.

  ### TUIKit and demo

  **iOS**

  - Added the video call feature.
  - Added 3x3 grid display of group profile photos.
  - Optimized the conversation list, contacts, and chat UIs.

  **Android**

  - Added a method to set whether to display read receipts.
  - Added 3x3 grid display of group profile photos.
  - Optimized the conversation list, contacts, and chat UIs.
  - Fixed compatibility issues with the input method, UI, and file selection for some mobile phones.
  - Fixed messy display of custom messages.
  - Fixed slow contact loading in the stress test.
  - Fixed the conflicts with other library resources.
  - Fixed ineffective cache directory settings.

  ## 4.5.111 @2019.10.16

  ### SDK

  **Common changes**

  - Fixed the paging issue of the API used to get the list of group members of a specified type.
  - Added file format extension to the URL generated upon sending a file message.
  - Added the notification callback after custom group fields are modified.
  - Local user and group information can be obtained before login by calling the `initStorage` method.
  - Fixed the memory leak issue.
  - Fixed the issue with incorrect message status codes after sent messages are recalled.
  - Fixed the issue with incorrect `getMessage` callback error codes.
  - Fixed incorrect one-to-one chat unread count after an app is killed and restarted.

  **iOS and Mac**

  Fixed occasional login failures for sleeping Mac devices.

  **Android**

  - Fixed stability issues in some scenarios.
  - Fixed the issue where OPPO mobile phones running Android 8.0 or later could not receive offline push notifications.
  - Optimized the return types of the `getElementCount` API.

  **Windows**

  - Improved the network reconnection speed for cross platform libraries.
  - Fixed the Windows public group management setting failure.
  - Added JVM configuration to cross-platform libraries to facilitate passing jvm from an Android environment.

  ### TUIKit and demo

  **iOS**

  - Added support for sending and receiving voice messages to and from web applications.
  - Fixed the issue where TUIKit resource files could not be found when swift loading.
  - Fixed the issue where a friend's alias could not be seen on the chat interface after it was modified.
  - Fixed the issue where the conversation list did not refresh promptly after a conversation was pinned to the top.

  **Android**

  - Added support for sending and receiving voice messages to and from web applications.
  - Added support for setting the input box style.
  - Displayed a red dot on unread voice messages.
  - Fixed the issue where video messages could not be played on x86 devices.
  - Fixed conflicts between FileProvider and the integration side.
  - Fixed the issue where audio permissions could not be identified on some mobile phone models.
  - Fixed the issue where the profile photo cannot be loaded in specific conditions.
  - Fixed occasional incomplete display of bubbles.

  ## 4.5.55 @2019.10.10

  ### SDK

  **Common changes**

  - Fixed crashes when networks are switched multiple times.
  - Improved network connection quality.
  - Optimized annotations of some APIs.

  **Android**

  Optimized HTTP request restrictions on Android 9.0 or later.

  **iOS and Mac**

  Optimized pod integration.

  ## 4.5.45 @2019.09.18

  ### SDK

  **Common changes**

  - Improved network connection quality.
  - Fixed the exceptional unread count when new messages are received after a group chat is deleted.
  - Fixed the issue where deleted conversations could still be obtained from the conversation update callback.
  - Optimized the logic for pulling custom group/group member fields.

  **Android**

  Deprecated the `setOfflinePushListener` API and `TIMOfflinePushNotification` class in `TIMManager`.

  ### TUIKit and demo

  **iOS**

  - Fixed the NSSting + Common.h class conflict issue.
  - Fixed the incomplete group tip display issue.

  **Android**

  - Added read receipts.
  - Compatible with typing display in earlier versions.
  - Fixed the issue where resent messages failed to immediately appear at the bottom of the chat window.
  - Fixed the issue where profile photos in a group chat failed to be displayed under specific conditions.
  - Fixed the issue where multi-element group messages could not be displayed.
  - Fixed crashes caused by specific messages.
  - Fixed the group admin permission error.
  - Fixed the issue where files sent by web applications could not be received.

  ## 4.5.15 @2019.08.30

  ### SDK

  **Common changes**

  - Improved the speed of sending file messages for users outside the Chinese mainland.
  - Fixed the issue where the message status fetched by `getLastMessage` was incorrect after a message was recalled. Fixed the issue where the callback is called multiple times after message listening was recalled.
  - Fixed the issue where the backend failed to obtain the muting time after a member is muted, left the group, and joined the group again.
  - Fixed the issue where the message time was ineffective during `savemsg` after the message time was proactively modified.
  - Fixed the issue where no callback occurred occasionally upon login.
  - Fixed the issue where `rand` and `timestamp` of a recalled group message were empty.
  - Fixed the issue where UserSig in a callback expired when the user was logged out. Fixed the issue where reconnection continued when the user was logged out.

  **Android**

  - Added support for FCM push notifications on Android devices in the backend.
  - Fixed the issue where an error was reported when null was passed for getting a specified friend list.
  - Fixed checkEquals crashes in specified scenarios.

  **Windows**

  - Added the `unique_id` field to `MessageLocator`.
  - Added support for 64-bit Windows.
  - Added user profile APIs and relationship chain APIs to the cross-platform library.

  ### TUIKit and demo

  **iOS**

  - Added support for sending custom messages.
  - Added read receipts for one-to-one messages.
  - Added a red dot to unplayed audio messages.

  **Android**

  - Fixed the demo memory leak issue in some scenarios.
  - Fixed crashes in some scenarios.
  - Fixed the incorrect custom message color issue.
  - Fixed the incorrect or incomplete bubble display issue.
  - Fixed the issue where conversation lists failed to display profile photos.
  - Fixed the issue where the title bar color could not be changed by ConversationLayout.
  - Added support for 64-bit ijkplayer.
  - Added support for multi-element messages.

  ## 4.4.900 @2019.08.07

  ### SDK

  **Common changes**

  - Fixed stability issues in some scenarios.
  - Optimized the unread message count.
  - Improved the latest conversation list loading speed after login.
  - Added the log cleaning feature.
  - Fixed message loss when synchronizing a large number of unread one-to-one messages.
  - After a user leaves an audio-video group, system messages about members leaving the group will not be pushed to the user's device.
  - Fixed the issue where group system messages occasionally failed to be delivered to users.
  - Added the frequency limit logic to `onRefresh/onRefreshConversations`.
  - Optimized exceptional `saveMessage` ordering.

  **iOS and Mac**

  - Changed the `getGroupInfo` callback parameter to `TIMGroupInfoResult` to fetch the error codes corresponding to each group.
  - Optimized the display style of push notifications for 4.x versions to keep consistency with 2.x and 3.x versions.
  - Fixed the issue where login accounts that contain Chinese characters failed to send images, files, and videos.

  **Android**

  - Fixed the issue where mobile phones running the 4.2.2 system version failed to load so.
  - Fixed the issue where `getGroupInfo` returns an incorrect amount of data.
  - Changed the `getGroupInfo` callback parameter to `TIMGroupDetailInfoResult` to fetch the error codes corresponding to each group.
  - Used the `com.tencent.imsdk.TIMGroupReceiveMessageOpt` class in a unified manner.

  **Windows**

  Fixed the issue where the Windows configuration file path is garbled.

  ### TUIKit and demo

  **iOS**

  - Modified the iOS demo UI, including the default profile photo and four feature icons (camera, video, album, and file) on the input interface.
  - Added the profile card to "Me" and put personal information in the profile card.
  - Added the feature to view the large image by tapping the profile photo.
  - Modified the style of the small gray bar in group chats in the demo so that the member nickname becomes blue and tapping the nickname will redirect the member to the member's profile page.
  - Optimized the logic for displaying nicknames in groups in the demo.
  - Optimized the logic for displaying profile photos on the chat interface.
  - Added tap feedback to all interfaces, allowing users to set and customize feedback in TUIKit.

  **Android**

  - Added `MotionEvent.ACTION_CANCEL` event handling for audio messages in chats.
  - Added profile photo display in the conversation list, chat interface, detailed profile, and contacts.
  - Added profile photo change in user profiles.
  - Added Intent redirection to offline push functions.
  - Added random profile photos for one-to-one chats and group chats.
  - Added prompts for granting and revoking the group admin role for a group member.
  - Added prompts for muting and unmuting group members.
  - Fixed the issue where the text "You've recalled a message" was not displayed in tips after a message was recalled.
  - Fixed the issue where the content of a recalled message was always displayed as the last message in the conversation list.
  - Fixed the white screen issue on the chat interface after offline messages were received on Meizu mobile phones.
  - Fixed the issue where the chat conversation pinned to the top did not update to the last message when new messages came in.
  - Fixed Toast notifications when the username or password is empty.
  - Fixed the issue where GroupTips messages transferred from the group owner were displayed abnormally in TUIKit.
  - Fixed the Didn't find class "android.support.v4.content.FileProvider" error reported on some mobile phones.
  - Optimized the logic for pinning a chat to the top to arrange chats in chronological order starting from the most recent.
  - Fixed the issue where the soft keyboard and other layouts appeared in chats at the same time.
  - Fixed the issue where the Group Chats, Blocklist, and New Contacts items were not displayed on the Contacts interface when a user is newly registered with no contacts.
  - Fixed the issue where the video sound continued to play after a user taps the Back button on a mobile phone.
  - Fixed the issue where the playing voice message did not stop and its sound was also recorded during voice message recording.
  - Fixed the issue where videos sent by iOS devices failed to playback on some mobile phones.

  ## 4.4.716 @2019.07.16

  **iOS and Mac**

  - Organized and merged APIs.
  - Added APIs to get the download URLs of file, video, and voice messages.
  - Added the `disableStorage` API to disable all local storage.
  - Fixed the issue where the conversation on the sender's device could still get lastMsg after an online message was sent.
  - Removed the return value of `getSenderProfile`, and used callback instead.
  - Changed the group function `modifyReciveMessageOpt` to `modifyReceiveMessageOpt`.
  - Fixed the issue where video screenshots sent from a device running iOS 2.X or 3.X to a device running iOS 4.X could not be obtained.
  - Fixed occasional crashes when data was reported upon exit.
  - Optimized the login module (repeated login/frequent login/frequent account switching/automatic connection/offline user being kicked off).
  - Fixed the issue where the unread count could not be cleared after a member left a group or a group was deleted.
  - Fixed the issue where group deletion notifications could not be received occasionally.
  - Fixed the issue where longer time was required to deliver messages when the app went to the foreground after staying in the background for a long time.
  - Optimized the one-to-one chat unread count.
  - Changed the input parameter `TIMLoginParam` of `autoLogin` to `userID`.
  - Changed the input parameter `TIMLoginParam` of `initStorage` to `userID`.
  - Removed multi-account login APIs: `newManager`, `getManager`, and `deleteManager`.
  - Fixed occasional respondsToLocator crashes.
  - Fixed occasional crashes caused by TIMGroupInfo > lastMsg calling related functions.
  - TUIKit
    - Optimized the recent contact list update algorithm to reduce the refresh frequency.
    - Fixed blocklist memory leak.
    - Added message bubble and profile photo click event callbacks.
    - Fixed the issue where the latest profile photo was not displayed in recent contacts or the chat window.
    - Optimized document annotations.

  **Android**

  - Organized and merged APIs.
    - Added all APIs in `TIMManagerExt` to `TIMManager`.
    - Added all APIs in `TIMConversationExt` to `TIMConversation`.
    - Added all APIs in `TIMGroupManagerExt` to `TIMGroupManager`.
    - Added all APIs in `TIMMessageExt` to `TIMMessage`.
    - Added all APIs in `TIMUserConfigMsgExt` to `TIMUserConfig`.
    - Retained APIs in `TIMManagerExt`, `TIMMessageExt`, `TIMConversationExt`, `TIMGroupManagerExt`, and `TIMUserConfigMsgExt` classes provisionally for compatibility purposes, which will be deprecated in the future.
  - Added options to add friends in one-way or two-way manner.
  - Added the `disableStorage` API to disable all local storage.
  - Added APIs to get the download URLs of file, video, and voice messages.
  - Fixed the issue where `queryUserProfile` was null on some Android mobile phones.
  - Fixed the issue where the conversation on the sender's device could still get lastMsg after an online message was sent.
  - Removed the return value of `getSenderProfile`, and used callback instead.
  - Fixed occasional crashes when data was reported upon exit.
  - Optimized the login module (repeated login/frequent login/frequent account switching/automatic connection/offline user being kicked off).
  - Fixed the issue where the unread count could not be cleared after a member left a group or a group was deleted.
  - Fixed the issue where group deletion notifications could not be received occasionally.
  - Fixed the issue where longer time was required to deliver messages when the app went to the foreground after staying in the background for a long time.
  - Optimized the one-to-one chat unread count.
  - TUIKit
    - Short video messages in chats can be played in landscape or portrait orientation.
    - Added support for Javadoc documentation.
    - Fixed the issue where downloading a video that was being sent failed.
    - Fixed the issue where the `onSuccess` callback of the `GroupChatManagerKit.getInstance().sendMessage` method could be triggered twice.
    - Fixed the issue with short audio messages on the chat interface. Audio messages should be at least 1 second long. For messages shorter than 1 second, "Message too short" is displayed.
    - Fixed the issue where a user could be invited to join a private group repeatedly.
    - Fixed the issue where remarks could not be empty.
    - Fixed the issue where the time displayed on the chat interface was incorrect when the system time of the device was incorrect.
    - Fixed the issue where voice messages sent locally could not be downloaded on another mobile phone from roaming messages.
    - Fixed the issue where the group owner failed to set the group name to null but a message stating that the setting was successful was displayed.

  **Windows**

  - Fixed the issues where various platforms sent Chinese characters when image, file, audio, and video messages contained Chinese paths.
  - Fixed the issue where `TIMMsgReportReaded` was invalid.
  - Fixed the issue where the received message and recalled message have different rand and seq.
  - Fixed occasional crashes when data was reported upon exit.
  - Optimized the login module (repeated login/frequent login/frequent account switching/automatic connection/offline user being kicked off).
  - Fixed the issue where the unread count could not be cleared after a member left a group or a group was deleted.
  - Fixed the issue where group deletion notifications could not be received occasionally.
  - Fixed the issue where longer time was required to deliver messages when the app went to the foreground after staying in the background for a long time.

  ## Patch 4.4.631 @2019.07.03

  **Android**

  Fixed offline push issues and crashes.

  ## 4.4.627 @2019.06.27

  **iOS and Mac**

  - Fixed the message sending timeout issue when no network connection was available.
  - Fixed the issue where the message ID value was changed after the message was sent.
  - Fixed the disordered message issue.
  - Fixed the issue where messages were lost when chat room historical messages were pulled.
  - Fixed the issue with incorrect system message types.
  - Fixed the issue where the obtained original image size of an image message was 0.
  - Fixed the issue where mobile phones failed to send messages after the system time was changed.
  - Fixed the issue where reporting conversation read and getting the unread count failed in some cases.
  - Fixed the issue where online messages that had been sent could be obtained through getLastMessage of the conversation.
  - Fixed the issue where getting lastMsg status through the conversation was exceptional after the last message was recalled.
  - Fixed the issue where recalled message content still existed in the conversation list of the peer.
  - Fixed the issue where the sending status of image/voice/file messages was exceptional after network reconnection.
  - Fixed the issue where login accounts that contained special characters could not send audio and images.
  - Fixed the issue where the V4 version could not get the width and height of thumbnails sent by the V2 version.
  - Fixed the issue where recent conversations failed to be pulled after `saveMessage` was created for a conversation.
  - Fixed the issue where `getMessage` failed to get the `MemberChangeList` content of group tips.
  - Fixed the issue when `getLoginStatus` failed to get the login status.
  - Fixed the issue where applicants became group members after their requests to join the group were rejected.
  - Fixed the issue where a log file existed under the root directory of the drive letter after a log path was set.
  - Mac: fixed the issue where the callback failed to be received in case of force offline.
  - TUIKit
    - Optimized the group management page logic.
    - Fixed the iOS 13 compatibility issue.
    - Fixed known issues.

  **Android**

  - Fixed the message sending timeout issue when no network connection was available.
  - Fixed the issue where the message ID value was changed after the message was sent.
  - Fixed the disordered message issue.
  - Fixed the issue where messages were lost when chat room historical messages were pulled.
  - Fixed the issue with incorrect system message types.
  - Fixed the issue with exceptional progress value when files were downloaded.
  - Fixed the issue where mobile phones failed to send messages after the system time was changed.
  - Fixed the issue where the sending status of image/voice/file messages was exceptional after network reconnection.
  - Fixed exceptional message sorting after a group was deleted or a user was muted.
  - Fixed the issue where reporting conversation read and getting the unread count failed in some cases.
  - Fixed the issue where recalled message content still existed in the conversation list of the peer.
  - Fixed the issue where the status fetched by `getLastMessage` of the conversation was exceptional after the last message was recalled.
  - Fixed the issue where sent online messages could be obtained through `getLastMessage` of the conversation.
  - Fixed the issue where the obtained original image size of an image message was 0.
  - Fixed the issue where the V4 version could not get the width and height of thumbnails sent by the V2 version.
  - Fixed the issue where `getLoginUser()` could still get login users after they were forced offline.
  - Fixed the issue where `getSenderProfile` returned blank information.
  - Fixed the issue where `getOpUser` of `TIMGroupSystemElem` was empty.
  - Fixed the issue where `getMessage` failed to get the `MemberChangeList` content of group tips.
  - Fixed the issue where recent conversations failed to be pulled after `saveMessage` was created for a conversation.
  - Fixed the issue where a log file existed under the root directory of the drive letter after a log path was set.
  - Fixed known TUIKit issues.

  **Windows**

  - Fixed the message sending timeout issue when no network connection was available.
  - Fixed the issue where the message ID value was changed after the message was sent.
  - Fixed the disordered message issue.
  - Fixed the issue where messages were lost when chat room historical messages were pulled.
  - Fixed the issue with incorrect system message types.
  - Fixed the issue where the iOS IM SDK module of the cross-platform library did not include the ARMv7-A architecture.
  - Fixed the issue where empty messages were not supported by the `TIMMsgReportReaded` API of the cross-platform library.
  - Fixed the issue where multiple IM instances could run on one cross-platform library device with the same account and would be kicked off.
  - Added the JSON key for getting the unique ID of messages to cross-platform library messages.
  - Fixed the issue where a log file existed under the root directory of the drive letter after a log path was set.
  - Fixed the issue where `getMessage` failed to get the `MemberChangeList` content of group tips.
  - Fixed the issue where getting lastMsg status through the conversation was exceptional after the last message was recalled.
  - Fixed the issue where reporting conversation read and getting the unread count failed in some cases.

  ## 4.4.479 @2019.06.12

  **iOS**

  - Fixed the issue with message loss when offline messages were pulled.
  - Fixed the login failure caused by changing SDKAppID.
  - Fixed the issue where voice messages failed to play.
  - Fixed crashes caused by recalling group messages.
  - Fixed the 6002 error when getting friend lists and creating groups.
  - Improved the message sending efficiency.
  - Optimized the cache to mitigate UI lag.
  - TUIKit
    - New UI design
    - New architecture design
    - Improved features such as contacts, group management, and relationship chain.
    - Fixed bugs.

  **Android**

  - Fixed the issue with message loss when offline messages were pulled.
  - Fixed the login failure caused by changing SDKAppID.
  - Fixed the issue where voice messages failed to play.
  - Fixed crashes caused by recalling group messages.
  - Fixed the 6002 error when getting friend lists and creating groups.
  - Fixed Android device crashes caused by creating groups with too many members.
  - Improved the message sending efficiency.
  - Optimized the cache to mitigate UI lag.
  - TUIKit
    - New UI design
    - New architecture design
    - Improved features such as contacts, group management, and relationship chain.
    - Fixed bugs.

  **Windows**

  - Fixed the issue with message loss when offline messages were pulled.
  - Fixed the login failure caused by changing SDKAppID.
  - Fixed the issue where voice messages failed to play.
  - Fixed crashes caused by recalling group messages.
  - Fixed the 6002 error when getting friend lists and creating groups.
  - Optimized the cache to mitigate UI lag.
  - Improved the message sending efficiency.

  ## 4.3.145 @2019.05.31

  **iOS**

  - Fixed the issue where the same message was received after switching to another account.
  - Fixed crashes caused by getting one-to-one roaming messages after the ticket expired.
  - Fixed the issue where new chat room members could not see the chat history.
  - Fixed FindMsg crashes.
  - Optimized group message synchronization.
  - Fixed occasional getReciveMessageOpt errors.

  **Android**

  - Fixed the issue where the same message was received after switching to another account.
  - Fixed crashes caused by getting one-to-one roaming messages after the ticket expired.
  - Fixed the issue where new chat room members could not see the chat history.
  - Fixed the issue where the same message listener was added repeatedly.
  - Fixed FindMsg crashes.
  - Optimized group message synchronization.

  **Windows**

  - Fixed the issue where the same message was received after switching to another account.
  - Fixed crashes caused by getting one-to-one roaming messages after the ticket expired.
  - Fixed the issue where new chat room members could not see the chat history.
  - Optimized group message synchronization.

  ## 4.3.135 @2019.05.24

  **iOS**

  - Added the `checkFriends` API to verify friends.
  - Added the `queryGroupInfo` API to get local data.
  - Deprecated `getGroupPublicInfo` and replaced it with `getGroupInfo`.
  - Fixed the issue where deleted messages could be seen in the message list.
  - Fixed the issue where local messages could not be obtained before login.
  - Fixed the pulling quantity and sorting issues of recent contacts.
  - Fixed group message synchronization after network reconnection.
  - Fixed the issue where identifying duplicates failed when a large number of messages were received in a short time.
  - Fixed the issue where the same message might be received again after the app restarted.
  - Fixed occasional errors in initialization and message synchronization.
  - Fixed occasional errors caused when `lastMsg` of a conversation was deleted.
  - Fixed the issue where `onRefreshConversation` was called back twice with identical data.
  - Fixed the issue where users could not obtain the chat history of a chat room before the time they joined the chat room.
  - Fixed the issue where `copyFrom` of `TIMMessage` failed to work.
  - Fixed the issue where `TIMGroupEventListener` failed to receive callbacks.
  - Fixed crashes reported online.
  - Optimized connection requests during reconnection.
  - Optimized the quality of first connections to different networks and access points outside the Chinese mainland.
  - Improved the network reconnection speed when iOS devices switch to Wi-Fi networks.

  **Android**

  - Added the `checkFriends` API to verify friends.
  - Added the `queryGroupInfo` API to get local data.
  - Deprecated the `getGroupDetailInfo` and `getGroupPublicInfo` APIs and replaced them with the `getGroupInfo` API.
  - Fixed the issue where deleted messages could be seen in the message list.
  - Fixed `modifyGroupOwner` and `getGroupMembersByFilter` callback issues.
  - Fixed the issue where local messages could not be obtained before login.
  - Fixed the pulling quantity and sorting issues of recent contacts.
  - Fixed group message synchronization after network reconnection.
  - Fixed the issue where identifying duplicates failed when a large number of messages were received in a short time.
  - Fixed the issue where the same message might be received again after the app restarted.
  - Fixed occasional errors in initialization and message synchronization.
  - Fixed occasional errors caused when `lastMsg` of a conversation was deleted.
  - Fixed the issue where `onRefreshConversation` was called back twice with identical data.
  - Fixed the issue where users could not obtain the chat history of a chat room before the time they joined the chat room.
  - Fixed crashes reported online.
  - Optimized connection requests during reconnection.
  - Optimized the quality of first connections to different networks and access points outside the Chinese mainland.

  **Windows**

  - Added support for custom field data reporting.
  - Added messages that disappear after being viewed.
  - Added use cases for recalling messages.
  - Fixed occasional failures in setting upload files.
  - Fixed the issue where deleted messages could be seen in the message list.
  - Fixed the pulling quantity and sorting issues of recent contacts.
  - Fixed group message synchronization after network reconnection.
  - Fixed the issue where identifying duplicates failed when a large number of messages were received in a short time.
  - Fixed the issue where the same message might be received again after the app restarted.
  - Fixed occasional errors caused when `lastMsg` of a conversation was deleted.
  - Fixed occasional errors in initialization and message synchronization.
  - The JSON string of a delivered message is returned in the callback indicating successful delivery.
  - Replaced `TIMSetRecvNewMsgCallback` with `TIMAddRecvNewMsgCallback` and `TIMRemoveRecvNewMsgCallback`.
  - Added SOCKS5 proxy configuration.
  - Optimized connection requests during reconnection.
  - Optimized the quality of first connections to different networks and access points outside the Chinese mainland.

  ## 4.3.118 @2019.05.10

  **iOS**

  - Added `querySelfProfile` and `queryUserProfile` to the `TIMFriendshipManager` class (reading local data).
  - Fixed the issue where `getLoginUser` returned a login user exception.
  - Fixed the issue where online reported user profiles failed to be obtained.
  - Fixed the issue where some local fields became invalid after the app restarted.
  - Fixed occasional errors when calling read reports after messages were deleted.
  - Fixed the online reported IM group issue.
  - Fixed the issue with conversation unread counts.
  - Fixed the issue with online messages.
  - Fixed the issue where messages failed to be re-sent occasionally.
  - Fixed the issue where local ticket expiration caused repeated reconnection.
  - Fixed crashes reported online.
  - Optimized the server connection strategy.
  - Optimized the network reconnection strategy.
  - Optimized the server overload strategy.
  - Optimized heartbeat to reduce unnecessary outbound packets.
  - Added support for importing through CocoaPods for TUIKit.
  - Added the Contacts interface for TUIKit.
  - Added the Adding Friends interface for TUIKit.
  - Added the Blocklist interface for TUIKit.
  - Added the Search Friend interface for TUIKit.
  - Added the New Friends interface for TUIKit.
  - Added the Remarks, Blocklist, and Delete Friend features to the friend's profile page for TUIKit.
  - Added support for modification of nicknames, personal signature, date of birth, gender, and location on the user profile page for TUIKit.
  - Improve the group pinning feature for TUIKit.

  **Android**

  - Added `querySelfProfile` and `queryUserProfile` to the `TIMFriendshipManager` class (reading local data).
  - Added the `addTime` field when getting a friend's profile.
  - Added support for the x86 and x86_64 architecture.
  - Fixed the issue where `getLoginUser` returned a login user exception.
  - Fixed the issue where online reported user profiles failed to be obtained.
  - Fixed the issue where some local fields became invalid after the app restarted.
  - Fixed occasional errors when calling read reports after messages were deleted.
  - Fixed the online reported IM group issue.
  - Fixed the issue with conversation unread counts.
  - Fixed the issue with online messages.
  - Fixed the issue where messages failed to be re-sent occasionally.
  - Fixed the issue where local ticket expiration caused repeated reconnection.
  - Fixed crashes reported online.
  - Optimized the server connection strategy.
  - Optimized the network reconnection strategy.
  - Optimized the server overload strategy.
  - Optimized heartbeat to reduce unnecessary outbound packets.
  - Added the "pin chat to top" feature to TUIKit.
  - TUIKit: nickname and personal signature can be changed, and the nickname is displayed on the profile page.
  - TUIKit: fixed the issue where emojis sent by iOS devices failed to be displayed on Android devices.
  - TUIKit: fixed the unread message red dot issue.
  - TUIKit: fixed the issue where a message appeared stating that UIs were abnormal after the plus sign was tapped on Meitu M8 mobile phones.
  - TUIKit: fixed the issue where profile photos were scaled down after being set and did not fill the entire UI.
  - TUIKit: fixed the login and auto login logic.
  - TUIKit: fixed the ANR issue when the input content exceeds the maximum limit.
  - TUIKit: fixed the issue where no response was received when images were selected from the photo album and the **OK** button on the preview screen was tapped.
  - TUIKit: fixed the issue where the message deleting and recalling buttons were not displayed after image messages were tapped and held on the chat interface.
  - TUIKit: optimized and fixed crashes reported online.

  **Windows**

  - Fixed the issue where `getLoginUser` returned a login user exception.
  - Fixed the issue where online reported user profiles failed to be obtained.
  - Fixed the issue where some local fields became invalid after the app restarted.
  - Fixed occasional errors when calling read reports after messages were deleted.
  - Fixed the online reported IM group issue.
  - Fixed the issue with conversation unread counts.
  - Fixed the issue with online messages.
  - Fixed the issue where messages failed to be re-sent occasionally.
  - Fixed the issue where local ticket expiration caused repeated reconnection.
  - Fixed crashes reported online.
  - Optimized the server connection strategy.
  - Optimized the network reconnection strategy.
  - Optimized the server overload strategy.
  - Optimized heartbeat to reduce unnecessary outbound packets.

  ## 4.3.81 @2019.04.24

  **iOS**

  - Fixed crashes caused by adding message elements to drafts.
  - Fixed the issue where some accounts failed to pull conversation lists after an app was removed and reinstalled.
  - Fixed the issue where login failed when usersig expired in login state and the app was not restarted.
  - Fixed the issue where messages could not be sent and the usersig expiration callback was not received when usersig expired in login state.
  - Fixed the issue with getting group member counts.
  - Fixed the request timeout issue (error code 6012).

  **Android**

  - Added:
  - Supplemented relationship chain features such as blocklist, friend list, and friend request handling of earlier version SDKs.
  - Fixed:
  - Fixed the issue where an error was reported when the main process of the app was killed.
  - Fixed the issue with getting group member counts.
  - Fixed issues with setting and getting custom group fields and custom group member fields.
  - Fixed the issue where no `onError` callback was sent after getting group profile timed out.
  - Fixed the issue where some accounts failed to pull conversation lists after an app was removed and reinstalled.
  - Fixed the issue where login failed when usersig expired in login state and the app was not restarted.
  - Fixed the issue where messages could not be sent and the usersig expiration callback was not received when usersig expired in login state.
  - Fixed disordered messages.
  - Fixed the request timeout issue (error code 6012).
  - Updated relationship chain error codes.
  - TUIKit: fixed a critical bug with the `DateUtils` class (GitHub issue #75).
  - TUIKit: fixed a crash (GitHub issue #86).
  - TUIKit: fixed issues with using SDK without permissions.
  - TUIKit: fixed crashes after deleting conversation, deleting message, and long-pressing.
  - TUIKit: fixed the issue where `popupwindow` would not disappear.
  - TUIKit: fixed the issue with repeated messages.
  - TUIKit: fixed the issue with intercepting empty messages containing whitespace.
  - TUIKit: fixed the issue where unread counts did not update after conversations were deleted.
  - TUIKit: fixed the issue with the maximum number of characters in a message.
  - TUIKit: improved experience and fixed several Array Index Out of Bounds exceptions.

  **Windows**

  - Fixed some crashes.
  - Fixed the request timeout issue (error code 6012).
  - Fixed the issue where some accounts failed to pull conversation lists after an app was removed and reinstalled.
  - Fixed the issue where login failed when usersig expired in login state and the app was not restarted.
  - Fixed the issue where messages could not be sent and the usersig expiration callback was not received when usersig expired in login state.

  ## 4.2.52 @2019.04.17

  **iOS**

  - Added:
  - Supplemented relationship chain features such as blocklist, friend list, and friend request handling of earlier version SDKs.
  - Fixed:
  - Optimized API annotations.
  - Fixed the issue with ineffective group custom fields and group member custom fields.
  - Fixed the issue where `TIMMessage` failed to get user profiles through `senderProfile`.
  - Fixed the issue with read receipt callback and status.
  - Fixed the issue where the last message did not call back when unread messages were synchronized.
  - Fixed the issue where group messages occasionally could not be received.
  - Fixed the issue where login response packets could not be decrypted.
  - Added support for IP connection and login information reporting.
  - Fixed the message seq error.

  **Android**

  - Added:
  - Supplemented relationship chain features such as blocklist, friend list, and friend request handling of earlier version SDKs.
  - Fixed:
  - Fixed jni leak on Android.
  - Fixed incorrect group member roles.
  - Fixed recalling group message crashes after a member left the group and joined the group again.
  - Fixed the issue where emojis were not displayed in the TUIKit demo.
  - Fixed the issue where the second page would often contain repeated messages when group chat messages were received.
  - Fixed some crashes in the TUIKit demo.
  - Fixed the issue where `TIMMessage` failed to get user profiles through `senderProfile`.
  - Fixed the issue with read receipt callback and status.
  - Fixed the issue where the last message did not call back when unread messages were synchronized.
  - Fixed the issue where group messages occasionally could not be received.
  - Fixed the issue where login response packets could not be decrypted.
  - Added support for IP connection and login information reporting.
  - Fixed the message seq error.

  **Windows**

  - Added:
  - Supplemented relationship chain features such as blocklist, friend list, and friend request handling of earlier version SDKs.
  - Fixed:
  - Fixed the issue where `TIMMessage` failed to get user profiles through `senderProfile`.
  - Fixed the issue with read receipt callback and status.
  - Fixed the issue where the last message did not call back when unread messages were synchronized.
  - Fixed the issue where group messages occasionally could not be received.
  - Fixed the issue where login response packets could not be decrypted.
  - Added support for IP connection and login information reporting.
  - Fixed the message seq error.

  ## 4.2.28 @2019.04.08

  **iOS**

  - Optimized issues related to unread counts.
  - Optimized message read status.
  - Fixed disordered one-to-one messages sent by RESTful APIs.
  - Fixed occasional repeated roaming messages fetched.
  - Optimized the `uniqueId` empty implementation issue.

  **Android**

  - Added:
    Added the logic for adding, deleting, and querying friends.
  - Fixed:
  - Optimized issues related to unread counts.
  - Optimized message read status.
  - Fixed disordered one-to-one messages sent by RESTful APIs.
  - Fixed occasional repeated roaming messages fetched.
  - Optimized the `uniqueId` empty implementation issue.

  **Windows**

  - Optimized issues related to unread counts.
  - Optimized message read status.
  - Mitigated disordered one-to-one messages sent by RESTful APIs.
  - Fixed occasional repeated roaming messages fetched.

  ## 4.2.10 @2019.03.29

  **iOS**

  - New features
    Added the logic for adding, deleting, and querying friends.
  - Fixed:
    - Mitigated the timeout issue.
    - Optimized the auto login logic.
    - Fixed crashes.
    - Fixed occasional network connection exceptions.

  **Android**

  - Mitigated the timeout issue.
  - Optimized the auto login logic.
  - Mitigated the JNI leak issue.
  - Fixed crashes.
  - Fixed occasional network connection exceptions.

  **Windows**

  - Mitigated the timeout issue.
  - Fixed crashes.
  - Fixed occasional network connection exceptions.

  ## 4.2.9 @2019.03.27

  **iOS and Mac**

  - Fixed crashes in the IPv6 environment.
  - Fixed the issue where setting profiles to int failed.

  **Android**
  Fixed the issue where setting profiles to int failed.

  ## 4.2.1 @2019.03.15

  **iOS**

  - Fixed the issue where clients did not receive relevant instructions after a group was deleted in the backend.
  - Fixed the issue where calling `deleteConversationAndMessage()` failed.
  - Fixed the issue where no messages were received after network reconnection (On the conversion interface, messages can be proactively pulled after network reconnection.)

  **Android**

  - Fixed incorrect group pending and processed requests returned.
  - Fixed client crashes when the client went to the backend.
  - Fixed the issue where no messages were received after network reconnection.
  - Fixed occasional message sorting errors.
  - Fixed the issue where messages occasionally failed to be sent.

  **Web**
  Web IM can play .amr recordings.

  **Windows**

  - Added the /source-charset:.65001 compilation option.
  - Fixed crashes when the file system directly ran IMAPP.exe.
  - Fixed various compilation errors and crashes.
  - Removed X64 compilation (not supported at present).

  ## 4.0.13 @2019.03.13

  **Android**
  Fixed crashes caused by login after 3.x is upgraded to 4.x.

  **iOS**

  - pod can directly integrate the TUIKit.framework.
  - Fixed crashes caused by login after 3.x is upgraded to 4.x.

  **Windows**

  - Added the IM demo with the duilib library as a UI component.
  - Added usage instructions and integration guide.

  ## IM SDK 4.0.12 2019-3-11

  **iOS**

  - TUIKit.framework supports bitcode 2.
  - Fixed ineffective group muting.
  - Fixed the feature for modifying a user's role in a group.

  **Android**

  - Fixed ineffective group muting.
  - Fixed the feature for modifying a user's role in a group.
  - Fixed the issue with modifying group message receiving options.
  - Fixed the issue with ineffective offline push toggle.

  ## IM SDK 4.0.10 2019-3-7

  Fixed the message receiving error when an audio-video group had more than 100 members.

  ## IM SDK 4.0.8 2019-3-6

  Optimized the audio playback logic for TUIKit.

  ## IM SDK 4.0.7 2019-3-1

  - Fixed the compatibility issue with audio, file, and video messages between earlier and later versions.
  - Fixed "-5 tls exchange failed" where login was successful after uninstalling and then reinstalling the app.

  ## IM SDK 4.0.4 2019-2-28

  - Fixed the issue where an incorrect error code was returned when a user logged in after userSig expired. The correct error code is 6206.
  - Optimized the force offline logic.

  ## IM SDK 4.0.3 2019-2-25

  Fixed the issue with third-party offline push.

  ## IM SDK 4.0.2 2019-2-20

  Fixed the issue where bitcode packaging activation failed.

  ## IM SDK 4.0.1 2019-2-20

  Fixed the issue where -5 is returned after login.

  ## iOS--IM SDK 4.0.0.1 2019-1-21

  Added TUIKIt.

  ## IM SDK 3.3.2 2018-7-5

  - Automatic read reporting is disabled by default.
  - Custom information types of profile relationship chains support integer.
  - Fixed the issue where the group member count obtained from local storage was incorrect.
  - Fixed the issue where the nickname carried in one-to-one chat messages was not updated in real time.

  ## IM SDK 2.7.2 2018-7-5

  - Automatic read reporting is disabled by default.
  - Custom information types of profile relationship chains support integer.
  - Added the message recalling feature.
  - Fixed the issue where the nickname carried in one-to-one chat messages was not updated in real time.

  ## Windows--IM SDK 2.5.8 2018-7-5

  - Fixed login failures in some cases.
  - Custom information types of profile relationship chains support integer.

  ## IM SDK 3.3.0 2018-4-4

  **iOS**
  Added the level and role fields to `TIMUserProfile`.

  **Android**

  - Added support for offline push on Meizu mobile phones.
  - Added standard level and role attributes to user profiles.
  - Fixed the issue where UGC short video failed to be sent when a user logged in after logging out.

  ## IM SDK 2.7.0 2018-4-4

  **iOS**

  - Added custom data parameters to the API for inviting users to join a group.

  **Android**

  - Added support for offline push on Meizu mobile phones.
  - Added support for custom data for the API for inviting users to join a group.

  ## Windows--IM SDK 2.5.7 2018-3-13

  - Modified the login module to improve communication security.
  - Improved the message delivery capability with poor network connection.
  - Fixed occasional crashes when logs were printed.

  ## iOS--IM SDK 2.6.0 2018-3-13

  - Provided an API for deleting roaming messages.
  - Provided an API for serializing and deserializing message objects.
  - Fixed some known issues.

  ## iOS--IM SDK 3.2.0 2018-3-13

  - Fixed the issue where an error was reported when `getUserProfile` contained custom friend fields.
  - Optimized the group unread count update strategy.
  - Optimized the logic and strategy for local message storage.
  - Fixed some crashes.

  ## Android--IM SDK 3.2.0 2018-3-13

  - Fixed the issue where UGC short videos failed to be sent.
  - Fixed the issue with no callbacks for sent messages when the network connection is interrupted.
  - Fixed the issue where muting all did not take effect.
  - Optimized the logic and strategy for local message storage.
  - Fixed some crashes.

  ## Android--IM SDK 2.6.0 2018-3-13

  - Provided an API for deleting roaming messages.
  - Provided an API for serializing and deserializing message objects.
  - Fixed some known issues.

  ## IM SDK 3.1.2 2017-12-12

  - Mitigated the network timeout issue on Android devices.
  - Fixed the audio download error on Android devices.
  - Fixed various crashes on Android devices.

  ## IM SDK 2.5.7 2017-11-08

  - Fixed SDK crashes when app processes were killed.
  - Fixed the issue where offline messages were repeatedly pushed.
  - Fixed the issue where internal accounts may be empty when `initStorage` and `login` are called at the same time.
  - Optimized the network detection strategy.
  - Fixed the error in getting friend lists.
  - Fixed some crashes.

  ## IM SDK 3.1.1 2017-8-16

  - Optimized the regular log clearing mechanism.
  - Fixed the issue where iOS QALSDK crashed upon initialization.
  - Added the feature for muting all group members.
  - iOS: fixed the multi-user login failure.
  - Android: fixed crashes caused by getting group lists before login.

  ## IM SDK 2.5.6 2017-7-14

  - Fixed crashes during login and logout.
  - Fixed crashes during push and recording.

  ## IM SDK 3.1.0 2017-7-3

  - Added IMUGCExt.framework and TXRTMPSDK.framework to provide short video recording and upload.
  - Added the Recall Message feature.

  ## IM SDK 2.5.5 2017-6-6

  - Optimized the logic for internal response packets to reduce time consumption.
  - Improved the log time granularity to millisecond.
  - Fixed some crashes and message synchronization issues.

  ## IM SDKV3 3.0.2 2017-5-22

  - Fixed the issue where users cannot receive group messages in an audio-video group.
  - Adjusted APIs.
    i. Deprecated `TIMFileElem` and the `setData` API in `TIMSoundElem`.
    ii. Corrected spelling of the `getConversionList` API in `TIMManagerExt` to `getConversationList`.

  ## IM SDKV3 3.0.1 2017-5-15

  Fixed the issue where some .so libraries were incompatible with devices running systems earlier than Android 5.0.

  ## IM SDKV3 3.0 2017-5-8

  - Regrouped IM SDK and IMCore into IM SDK, IMMessageExt, IMGroupExt, and IMFriendExt.
  - Optimized the IM SDK initialization method to initSdk: and setUserConfig.
  - Names of IM SDK APIs and protocol callback methods start with lowercase letters.
  - IM SDK features: basic login, receiving and sending messages, profile, and group features
  - IMMessageExt features: full message features, including message pulling, local storage, and unread count
  - IMGroupExt features: full group features, including group type management and group member management
  - IMFriendExt features: full relationship chain features, including friend list and blocklist

  ## IM SDK 2.5.4 2017-4-28

  - Fixed the timer mechanism bug in the IM SDK.

  ## IM SDK 2.5.3 2017-4-17

  **iOS**

  - `sendOnlineMessage` supports group messages, which will not be saved to local storage, stored offline, or included in the unread count.
  - Added the `findMessages` method to get local messages by message ID.
  - `TIMIOSOfflinePushConfig` provides the option for setting APNs push muting.
  - Fixed the issue of excessive memory consumption when messages were received at high frequency.

  **Android**

  - Added the API for searching for messages. (For more information, see `findMessages` under `TIMConversation`.)
  - `sendOnlineMessage` supports group messages, which will not be saved to local storage, stored offline, or included in the unread count.
  - Added the configuration item that allows a device to receive APNs push notifications without playing a sound or vibration. (For more information, see TIMMessageOfflinePushSettings.IOSSettings.NO_SOUND_NO_VIBRATION.)
  - Optimized networking to improve SDK robustness in poor network connection.

  **Windows**

  - Fixed issues that may cause crashes.

  **API changes:**

  - Changed how `TIMMessageOfflinePushSettings.AndroidSettings` and `TIMMessageOfflinePushSettings.IOSSettings` are constructed.
    For more information, see [Offline Push](https://intl.cloud.tencent.com/document/product/1047/34336)

  ## IM Android SDK 2.5.2 2017-3-1

  - Fixed the issue where the return of outgoing packets occasionally timed out (return code 6205).

  ## IM SDK 2.5.1 2017-2-16

  - Limited the maximum size of log files to 50 MB.
  - Fixed the bug where the online state was returned after a user logged out and the app went to the backend.
  - iOS: updated the audio and file downloading strategy and supported HTTP and HTTPS download.
  - Fixed the status mismatch bug after messages failed to be sent when the user was not logged in.

  ## IM Web SDK 1.7 2016-12-20

  - Added support for multi-instance force offline.
  - Added support for simultaneous online of multiple instances.
  - Added support for synchronization of read group messages.
  - Added support for synchronization of read one-to-one messages.
  - Optimized the demo directory structure and code.
  - Added the recent contacts list.

  ## IM SDK 2.5 2016-12-16

  - Optimized the `TIMOfflinePushInfo` object structure.
  - Fixed audio and file download failures in iOS 9.1.
  - Optimized network operations.
  - Fixed some bugs.

  ## IM SDK 2.4.1 2016-11-24

  - Fixed the bug where `TIMGroupAssistant` exceptionally pulls the group profile after entering an audio-video group.
  - Fixed the bug where disabling console print failed.
  - Fixed the issue where various listeners became invalid when logout is called before login after initialization.

  ## IM SDK 2.4 2016-11-09

  - Full compatible with the ATS mode.
  - Message forwarding feature: the `copyFrom` API forwards image and file messages by copying images and files without downloading them.
  - The number of members in an audio-video group is dynamically updated. `TIMGroupEventListener` returns the current number of group members.
  - Message filtering can be customized for audio-video groups.
  - `TIMOfflinePushInfo` attributes support push notification settings of Mi and Huawei mobile phones.
  - Optimized the process of pulling group roaming messages.
  - Optimized the processes of uploading and downloading audio, files, and short videos.
  - Throwing `onNewMessage` when pulling the recent contacts list can be disallowed.

  ## IM SDK 2.3 2016-9-13

  - Added support for push notifications to multiple apps with one appid.
  - Added `setOfflinePushToken` with callback to the Android version.
  - Optimized the message deletion logic to automatically filter messages in the DELETED state when messages were pulled.
  - iOS: moved database files from subdirectory Library/Caches/ to subdirectory Document/ to prevent them being cleared by the system.
  - Multiple TIMMessageListeners can be added and deleted in iOS versions.
  - Resident threads in iOS versions are named in a unified manner.
  - The API for getting conversation lists automatically filters conversations with the message count set to 0.

  ## IM Web SDK 1.6 2016-8-15

  - Web broadcast message requirements
  - Added friend system notifications.
  - Added profile system notifications.

  ## IM SDK 2.2 2016-8-10

  - Added support for conversation drafts.
  - Conversations can be marked whether to store messages to ensure more flexible message handling.
  - Roaming messages can be traversed from old to new, which applies to scenarios where message recording is needed.
  - Added ext and sounds of push notifications to messages, allowing setting push information for some messages.
  - Added `stopQALService` to the Android SDK, which turns off QALService when exiting the app.
  - Added support for network status monitoring and added error codes for network errors.

  ## IM SDK 2.1 2016-7-15

  - Added support for notification push to Mi and Huawei mobile phones.
  - Added support for the read receipts feature, which is optional depending on product needs.
  - Added support for typing reminder, which is optional depending on product needs.
  - Added standard fields such as the gender, date of birth, address, and language to profile relationship chains.
  - Notifications for joining and quitting a group contain the group member count.
  - Fixed some SDK and demo bugs.

  ## IM Web SDK 1.5 2016-7-13

  - Merged broadcasting chat room SDK capabilities.
  - Fixed issues with uploading images in Internet Explorer 8 and 9.
  - Added a group member count field to tips for joining and leaving groups.
  - Fixed some SDK and demo bugs.

  ## IM SDK 2.0 2016-6-16

  - The unread count can be synchronized between multiple online devices.
  - Historical messages can be imported when an app is migrated to ensure smooth migration.
  - Added the message notification status to group message attributes.
  - Added support for flexible settings for message priorities.
  - Push notifications can be filtered by attribute and tag.

  ## IM Web SDK 1.4 2016-6-7

  - Friends' message history can be pulled.
  - Red packets and like messages can be sent.
  - The API for creating groups supports custom group IDs and broadcasting chat rooms.
  - Optimized SDK APIs and merged the login and initialization APIs.
  - Optimized the demo directory structure and code.

  ## IM SDK 1.9.3 2016-5-31

  - Fixed resource destruction deadlocks when the winsdk process exited.

  ## IM SDK 1.9.2 2016-5-27

  - Added the ticket expiration callback.
  - Added support for IPv6 (iOS).

  ## IM SDK 1.9 2016-5-4

  - Added support for groups with more than 10,000 members (no limit on the number of members, which is suitable for broadcasting scenarios).
  - Reconstructed the IM demo for better experience and ease-of-use.
  - Messages can be sent based on their priorities.
  - Added storage and cache for group profiles and relationship chains.
  - Added APIs to synchronize group profiles and relationship chains and change callbacks.
  - Added support for getting friend profiles, including remarks and lists.
  - Added support for setting default group profile and relationship chain fields to be pulled.
  - Added support for disabling pulling recent contacts.
  - Added synchronizing the last message to the conversation list.
  - You can specify the group members whose group information, such as group name cards, is to be pulled.
  - Added support for passing in file paths for voice and file messages (messages can be resent).
  - Adapted to Android 6.0 dynamic permission management.

  ## IM SDK 1.8.1 2016-4-13

  - Android: optimized the auto-start process. (To modify configuration, see ReadMe.txt.)
  - Added the API for sending online messages in one-to-one chats. (The messages will be received only when the receiver is online and will not be stored when the receiver is offline.)
  - Added the API for batch sending messages.
  - Optimized Android performance.

  ## IM SDK 1.8 2016-3-23

  - Android offline push
  - Added the API to verify friend relationships.
  - Added the relationship chain custom field API.
  - Messages can be customized for local storage (for example, audio can be identified as read or unread).
  - Added the API to compress images, meeting the need for image compression in detached communication scenarios.
  - Customized messages' sound fields to specify APNs sounds.
  - Optimized callback APIs for online status change.

  ## IM SDK 1.7 2016-1-25

  - Added support for limiting the message sending frequency in groups.
  - Added support for group ownership transfer.
  - Group message notification intensity can be customized.
  - CS channels are established to remove the need for a persistent connection between the app and backend to reduce battery consumption.
  - Added configuration items, including message and recent contacts roaming switch, storage duration, and multi-device online switch to improve operational efficiency.
  - Downstream messages carry group member nicknames and contact cards to improve user experience and ease-of-use.
  - Simplified the SDK to reduce the installation package size.

  ## IM SDK 1.6 2015-12-25

  - Short video messages are supported to meet growing needs for video messages and social communication.
  - Added support for rule-based sorting of group members.
  - Added support for relationship chain friend lists.
  - Added support for filtering of sensitive words in group names, announcements, and introductions.
  - Added support for group member contact cards to help users identify group members.
  - Added support for the message notifications switch, allowing users to turn on or off message notifications for one-to-one chats and group chats.

  ## IM SDK 1.5 2015-11-16

  - Added support for asynchronous download of message records.
  - Group messages can be deleted at the server side.
  - Users can be searched by nickname.
  - Groups can be searched by group name.
  - Event callbacks can be configured in the console.
  - User credentials of admin accounts can be downloaded.
  - Optimized some demo and technical logic.

  ## IM SDK 1.4 2015-10-16

  - Multi-device login is supported.
  - Messages from blocklisted users cannot be received.
  - Deleted friend recommendations.
  - APNs pushes nicknames.
  - Added support for filtering sensitive words in group names.
  - Added support for filtering sensitive words in group announcements.
  - Demo supports the guest mode and third-party account login.

  ## IM SDK 1.3 2015-09-10

  - Users can log in as guests without usernames and passwords.
  - Message roaming is supported. (Messages are stored for seven days by default.)
  - Recent contacts roaming and deletion are supported.
  - Real-time message synchronization through callbacks is supported.
  - Friend recommendation is supported after the recommendation logic has been defined.
  - Sending original images or thumbnails is supported for better user experience.
  - Added support for push notifications (available only to online Android users).
  - Added support for smooth migration.
  - Added support for deleting local messages to protect users' privacy.

  ## IM SDK 1.2 2015-08-18

  - One-to-one chats on the web platform are supported.
  - The maximum number of group members is increased to 10,000.
  - Added support for filtering ads and sensitive words in messages.
  - Added an API that provides message IDs to precisely locate messages.
  - Added remarks to user profiles.
  - Added support for viewing local messages when offline.

  ## IM SDK 1.1 2015-07-13

  - Windows C++ platform is supported.
  - Public groups and chat rooms are supported.
  - Added support for adding group introductions and announcements and added muting, message block, and group role setting.
  - Added APIs for user profile and relationship chain operations, such as setting nicknames, adding friends, and setting a blocklist.
  - Added support for file messages.
  - Optimized image messages: image quality includes the original image, thumbnail, and large image. Changed upload and download APIs. Image URLs can be passed.
  - Added log levels to the log callback API.
  - Added the logic to execute forced logout on one device in the event of repeated logins.
  - Added automatic crash reporting.
  - Added support for self-owned account and third-party account integration in hosting mode.
  - Added SMS authentication for user registration and login.
  - Added support for ticket verification using public keys and private keys generated by Tencent.
  - Added user and group management.

  ## IM SDK 1.0 2015-05-11

  - Added support for Android/iOS platforms.
  - Added support for integrating Tencent account and third-party account logins.
  - Added support for one-to-one chats and group chats (discussion groups).
  - Added support for text, emoji, image, audio, location, and custom messages.
  - APNs push notifications (token reporting, foreground and background switching event reporting)
  - Messages can be stored locally.
