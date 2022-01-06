# im_flutter_plugin_platform_interface
A common platform interface for the `tencent_im_sdk_plugin` plugin.

This interface allows platform-specific implementations of the `tencent_im_sdk_plugin` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Usage

To implement a new platform-specific implementation of `tencent_im_sdk_plugin`, extend `ImFlutterPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `ImFlutterPlatform` by calling `ImFlutterPlatform.instance = MyPlatformTencentIMSDKPlugin()`.

