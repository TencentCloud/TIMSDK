# im_api_example
This project is used to build an API demo for Flutter, including how to use APIs, so as to facilitate use and test.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to Use
- Configure the environment as instructed in the Flutter's [installation documentation](https://flutter.dev/docs/get-started/install).
- Run the project. For how to run a Flutter project, see [documentation](https://flutter.dev/docs/get-started/codelab).
- Configure `sdkappid` and `secret` before calling APIs. Please go to the [IM console](https://cloud.tencent.com/product/im) to sign up and create an app.
- In the basic module, initialize and log in to the SDK (initSDK).

## FAQs
- **How to set custom fields**

To meet the needs of users in different cases, IM provides `custom user field`, `custom friend field`, `custom group field`, and `custom group member field`. Please configure a custom field name in the console first, and then call the API (`setSelfInfo`, `setGourpInfo`, `setGroupMemberInfo`, or `setFriendInfo`) to set the field value.

When you create a custom field for self or a custom field for friend, the console will automatically add the prefix `Tag_Profile_Custom_` or `Tag_SNS_Custom_`. Therefore, you have no need to provide the prefix when calling the API to set the field value. For example, the custom field for friend is `Tag_SNS_Custom_test` in the console, so you just need to set the custom name as `test` to call the API.

