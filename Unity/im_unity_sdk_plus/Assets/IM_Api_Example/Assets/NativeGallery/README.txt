= Native Gallery for Android & iOS =

Online documentation & example code available at: https://github.com/yasirkula/UnityNativeGallery
E-mail: yasirkula@gmail.com


1. ABOUT
This plugin helps you interact with Gallery/Photos on Android & iOS.


2. HOW TO
for Android: set "Write Permission" to "External (SDCard)" in Player Settings
for iOS: there are two ways to set up the plugin on iOS:

a. Automated Setup for iOS
- (optional) change the values of 'Photo Library Usage Description' and 'Photo Library Additions Usage Description' at 'Project Settings/yasirkula/Native Gallery'
- (Unity 2017.4 or earlier) if your minimum Deployment Target (iOS Version) is at least 8.0, set the value of 'Deployment Target Is 8.0 Or Above' to true at 'Project Settings/yasirkula/Native Gallery'

b. Manual Setup for iOS
- set the value of 'Automated Setup' to false at 'Project Settings/yasirkula/Native Gallery'
- build your project
- enter a Photo Library Usage Description to Info.plist in Xcode
- also enter a "Photo Library Additions Usage Description" to Info.plist in Xcode, if exists
- set Info.plist's "Prevent limited photos access alert" property's value to 1 in Xcode, if exists
- insert "-weak_framework PhotosUI -weak_framework Photos -framework AssetsLibrary -framework MobileCoreServices -framework ImageIO" to the "Other Linker Flags" of Unity-iPhone Target (and UnityFramework Target on Unity 2019.3 or newer) (if your Deployment Target is at least 8.0, it is sufficient to insert "-weak_framework PhotosUI -framework Photos -framework MobileCoreServices -framework ImageIO")
- lastly, remove Photos.framework and PhotosUI.framework from Link Binary With Libraries of Unity-iPhone Target (and UnityFramework Target on Unity 2019.3 or newer) in Build Phases, if exists

IMPORTANT: If you are targeting iOS 14 or later, you need to build your app with Xcode 12 or later to avoid any permission issues.


3. FAQ
- How can I fetch the path of the saved image or the original path of the picked image on iOS?
You can't. On iOS, these files are stored in an internal directory that we have no access to (I don't think there is even a way to fetch that internal path).

- Android build fails, it says "error: attribute android:requestLegacyExternalStorage not found" in Console
"android:requestLegacyExternalStorage" attribute in AndroidManifest.xml fixes a rare UnauthorizedAccessException on Android 10 but requires you to update your Android SDK to at least SDK 29. If this isn't possible for you, you should open NativeGallery.aar with WinRAR or 7-Zip and then remove the "<application ... />" tag from AndroidManifest.xml.

- Can't access the Gallery, it says "java.lang.ClassNotFoundException: com.yasirkula.unity.NativeGallery" in Logcat
If you are sure that your plugin is up-to-date, then enable "Custom Proguard File" option from Player Settings and add the following line to that file: -keep class com.yasirkula.unity.* { *; }

- Nothing happens when I try to access the Gallery on Android
Make sure that you've set the "Write Permission" to "External (SDCard)" in Player Settings.

- NativeGallery functions return Permission.Denied even though I've set "Write Permission" to "External (SDCard)"
Declare the WRITE_EXTERNAL_STORAGE permission manually in your Plugins/Android/AndroidManifest.xml file as follows: <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" tools:node="replace"/>
You'll need to add the following attribute to the '<manifest ...>' element: xmlns:tools="http://schemas.android.com/tools"

- Saving image/video doesn't work properly
Make sure that the "filename" parameter of the Save function includes the file's extension, as well


4. SCRIPTING API
Please see the online documentation for a more in-depth documentation of the Scripting API: https://github.com/yasirkula/UnityNativeGallery

enum NativeGallery.PermissionType { Read = 0, Write = 1 };
enum NativeGallery.Permission { Denied = 0, Granted = 1, ShouldAsk = 2 };
enum NativeGallery.ImageOrientation { Unknown = -1, Normal = 0, Rotate90 = 1, Rotate180 = 2, Rotate270 = 3, FlipHorizontal = 4, Transpose = 5, FlipVertical = 6, Transverse = 7 }; // EXIF orientation: http://sylvana.net/jpegcrop/exif_orientation.html (indices are reordered)
enum MediaType { Image = 1, Video = 2, Audio = 4 };

delegate void MediaSaveCallback( bool success, string path );
delegate void NativeGallery.MediaPickCallback( string path );
delegate void MediaPickMultipleCallback( string[] paths );

//// Saving Media To Gallery/Photos ////

// On Android, your images/videos are saved at DCIM/album/filename. On iOS 14+, the image/video will be saved to the default Photos album (i.e. album parameter will be ignored). On earlier iOS versions, the image/video will be saved to the target album.
// NOTE: Make sure that the filename parameter includes the file's extension, as well
// IMPORTANT: NativeGallery will never overwrite existing media on the Gallery. If there is a name conflict, NativeGallery will ensure a unique filename. So don't put '{0}' in filename anymore (for new users, putting {0} in filename was recommended in order to ensure unique filenames in earlier versions, this is no longer necessary).
// MediaSaveCallback takes "bool success" and "string path" parameters. If the image/video is saved successfully, success becomes true. On Android, path stores where the image/video was saved to (is null on iOS). If the raw filepath can't be determined, an abstract Storage Access Framework path will be returned (File.Exists returns false for that path)
NativeGallery.Permission NativeGallery.SaveImageToGallery( byte[] mediaBytes, string album, string filename, MediaSaveCallback callback = null );
NativeGallery.Permission NativeGallery.SaveImageToGallery( string existingMediaPath, string album, string filename, MediaSaveCallback callback = null );
NativeGallery.Permission NativeGallery.SaveImageToGallery( Texture2D image, string album, string filename, MediaSaveCallback callback = null );
NativeGallery.Permission NativeGallery.SaveVideoToGallery( byte[] mediaBytes, string album, string filename, MediaSaveCallback callback = null );
NativeGallery.Permission NativeGallery.SaveVideoToGallery( string existingMediaPath, string album, string filename, MediaSaveCallback callback = null );


//// Retrieving Media From Gallery/Photos ////

// This operation is asynchronous! After user selects an image/video or cancels the operation, the callback is called (on main thread)
// MediaPickCallback takes a string parameter which stores the path of the selected image/video, or null if nothing is selected
// MediaPickMultipleCallback takes a string[] parameter which stores the path(s) of the selected image(s)/video(s), or null if nothing is selected
// title: determines the title of the image picker dialog on Android. Has no effect on iOS
// mime: filters the available images/videos on Android. For example, to request a JPEG image from the user, mime can be set as "image/jpeg". Setting multiple mime types is not possible (in that case, you should leave mime as is). Has no effect on iOS
NativeGallery.Permission NativeGallery.GetImageFromGallery( MediaPickCallback callback, string title = "", string mime = "image/*" );
NativeGallery.Permission NativeGallery.GetVideoFromGallery( MediaPickCallback callback, string title = "", string mime = "video/*" );
NativeGallery.Permission NativeGallery.GetImagesFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "image/*" );
NativeGallery.Permission NativeGallery.GetVideosFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "video/*" );

// Picking audio files is supported on Android only
NativeGallery.Permission NativeGallery.GetAudioFromGallery( MediaPickCallback callback, string title = "", string mime = "audio/*" );
NativeGallery.Permission NativeGallery.GetAudiosFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "audio/*" );

// Allows you to pick images/videos/audios at the same time
// mediaTypes: bitwise OR'ed media types to pick from (e.g. to pick an image or video, use 'MediaType.Image | MediaType.Video')
NativeGallery.Permission NativeGallery.GetMixedMediaFromGallery( MediaPickCallback callback, MediaType mediaTypes, string title = "" );
NativeGallery.Permission NativeGallery.GetMixedMediasFromGallery( MediaPickMultipleCallback callback, MediaType mediaTypes, string title = "" );


// Returns true if selecting multiple images/videos from Gallery/Photos is possible on this device (only available on Android 18 and later and iOS 14 and later)
bool NativeGallery.CanSelectMultipleFilesFromGallery();

// Returns true if GetMixedMediaFromGallery/GetMixedMediasFromGallery functions are supported (available on Android 19 and later and all iOS versions)
bool NativeGallery.CanSelectMultipleMediaTypesFromGallery();

// Returns true if the user is currently picking media from Gallery/Photos. In that case, another GetImageFromGallery, GetVideoFromGallery or GetAudioFromGallery request will simply be ignored
bool NativeGallery.IsMediaPickerBusy();


//// Runtime Permissions ////

// Interacting with Gallery/Photos is only possible when permission state is Permission.Granted. Most of the functions request permission internally (and return the result) but you can also check/request the permissions manually
NativeGallery.Permission NativeGallery.CheckPermission( PermissionType permissionType );
NativeGallery.Permission NativeGallery.RequestPermission( PermissionType permissionType );

// If permission state is Permission.Denied, user must grant the necessary permission (Storage on Android and Photos on iOS) manually from the Settings. These functions help you open the Settings directly from within the app
void NativeGallery.OpenSettings();
bool NativeGallery.CanOpenSettings();


//// Utility Functions ////

// Creates a Texture2D from the specified image file in correct orientation and returns it. Returns null, if something goes wrong
// maxSize: determines the maximum size of the returned Texture2D in pixels. Larger textures will be down-scaled. If untouched, its value will be set to SystemInfo.maxTextureSize. It is recommended to set a proper maxSize for better performance
// markTextureNonReadable: marks the generated texture as non-readable for better memory usage. If you plan to modify the texture later (e.g. GetPixels/SetPixels), set its value to false
// generateMipmaps: determines whether texture should have mipmaps or not
// linearColorSpace: determines whether texture should be in linear color space or sRGB color space
Texture2D NativeGallery.LoadImageAtPath( string imagePath, int maxSize = -1, bool markTextureNonReadable = true, bool generateMipmaps = true, bool linearColorSpace = false );

// Creates a Texture2D thumbnail from a video file and returns it. Returns null, if something goes wrong
// maxSize: determines the maximum size of the returned Texture2D in pixels. Larger thumbnails will be down-scaled. If untouched, its value will be set to SystemInfo.maxTextureSize. It is recommended to set a proper maxSize for better performance
// captureTimeInSeconds: determines the frame of the video that the thumbnail is captured from. If untouched, OS will decide this value
// markTextureNonReadable: see LoadImageAtPath
Texture2D NativeGallery.GetVideoThumbnail( string videoPath, int maxSize = -1, double captureTimeInSeconds = -1.0, bool markTextureNonReadable = true );

// Returns an ImageProperties instance that holds the width, height and mime type information of an image file without creating a Texture2D object. Mime type will be null, if it can't be determined
NativeGallery.ImageProperties NativeGallery.GetImageProperties( string imagePath );

// Returns a VideoProperties instance that holds the width, height, duration (in milliseconds) and rotation information of a video file. To play a video in correct orientation, you should rotate it by rotation degrees clockwise. For a 90-degree or 270-degree rotated video, values of width and height should be swapped to get the display size of the video
NativeGallery.VideoProperties NativeGallery.GetVideoProperties( string videoPath );

// Returns the media type of the file at the specified path: Image, Video, Audio or neither of these (if media type can't be determined)
NativeGallery.MediaType NativeGallery.GetMediaTypeOfFile( string path );