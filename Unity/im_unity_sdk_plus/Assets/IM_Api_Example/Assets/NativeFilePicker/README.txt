= Native File Picker for Android & iOS =

Online documentation & example code available at: https://github.com/yasirkula/UnityNativeFilePicker
E-mail: yasirkula@gmail.com


1. ABOUT
This plugin helps you import/export files from/to various document providers on Android & iOS. On iOS, it uses UIDocumentPickerViewController which has the following requirements:

- iOS 8 or later
- an Apple Developer Program account (signing the app with a free account won't work)

NOTE: Custom file extensions are supported on iOS only.


2. HOW TO
for Android: if your app will be exporting files, set "Write Permission" to "External (SDCard)" in Player Settings
for iOS: there are two ways to set up the plugin on iOS:

a. Automated Setup for iOS
- set the values of 'Auto Setup Frameworks' and 'Auto Setup iCloud' to true at 'Project Settings/yasirkula/Native File Picker'. By default, automated setup for iCloud is disabled. That's because this plugin uses the iCloud capability and if another plugin uses other capabilities, these plugins may conflict with each other. Set 'Auto Setup iCloud' to true at your own risk
- if your app uses custom file extensions that are unique to your app (e.g. .mydata), add them to the "Window-NativeFilePicker Custom Types" asset (it has explanatory tooltips). This step works even if the values of 'Auto Setup Frameworks' and 'Auto Setup iCloud' are set to false (this step is not needed for extensions available in this list: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)

b. Manual Setup for iOS
- set the values of 'Auto Setup Frameworks' and 'Auto Setup iCloud' to false at 'Project Settings/yasirkula/Native File Picker'
- after building the Unity project, open the Xcode project
- add MobileCoreServices.framework to Link Binary With Libraries list in Build Phases
- enable iCloud in Capabilities and make sure that at least one of its Services is active
- if your app uses custom file extensions that are unique to your app (e.g. .mydata), add them to the Exported UTIs or Imported UTIs lists in Info (about custom UTIs: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_declare/understand_utis_declare.html) (this step is not needed for extensions available in this list: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)


3. FAQ
- How can I fetch the path of the saved file or the original path of the picked file?
You can't. The abstraction layers used on each platform deliberately don't return raw file paths.

- Can't import/export files, it says "java.lang.ClassNotFoundException: com.yasirkula.unity.NativeFilePicker" in Logcat
If you are sure that your plugin is up-to-date, then enable "Custom Proguard File" option from Player Settings and add the following line to that file: -keep class com.yasirkula.unity.* { *; }

- Nothing happens when I try to import/export files on Android
Make sure that you've set the "Write Permission" to "External (SDCard)" in Player Settings.

- NativeFilePicker functions return Permission.Denied even though I've set "Write Permission" to "External (SDCard)"
Declare the WRITE_EXTERNAL_STORAGE permission manually in your Plugins/Android/AndroidManifest.xml file as follows: <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" tools:node="replace"/>
You'll need to add the following attribute to the '<manifest ...>' element: xmlns:tools="http://schemas.android.com/tools"


4. SCRIPTING API
Please see the online documentation for a more in-depth documentation of the Scripting API: https://github.com/yasirkula/UnityNativeFilePicker

enum NativeFilePicker.Permission { Denied = 0, Granted = 1, ShouldAsk = 2 };

delegate void FilePickedCallback( string path );
delegate void MultipleFilesPickedCallback( string[] paths );
delegate void FilesExportedCallback( bool success );

//// Importing Files ////

// This operation is asynchronous! After user picks a file or cancels the operation, the callback is called (on main thread)
// FilePickedCallback takes a string parameter which stores the path of the picked file, or null if nothing is picked
// MultipleFilesPickedCallback takes a string[] parameter which stores the path(s) of the picked file(s), or null if nothing is picked
// allowedFileTypes determines which file types are accepted. On Android, this is the MIMEs and on iOS, this is the UTIs. For example:
//   PNG files: "image/png" on Android and "public.png" on iOS
//   Image files (png, jpeg, tiff, etc.): "image/*" on Android and "public.image" on iOS
//   PDF files: "application/pdf" on Android and "com.adobe.pdf" on iOS
//   On Android, see the following list for all available MIMEs (other MIMEs may not be supported on all devices): http://androidxref.com/4.4.4_r1/xref/frameworks/base/media/java/android/media/MediaFile.java#174
//   On iOS, see the following list for all available UTIs: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
//   Also see the NativeFilePicker.ConvertExtensionToFileType function
NativeFilePicker.Permission NativeFilePicker.PickFile( FilePickedCallback callback, string[] allowedFileTypes );

// Call this function only if CanPickMultipleFiles() returns true
NativeFilePicker.Permission NativeFilePicker.PickMultipleFiles( MultipleFilesPickedCallback callback, string[] allowedFileTypes );

// NOTE: on iOS, imported files will automatically be deleted by the OS after the application is closed. If you need the files to persist, move them to Application.persistentDataPath


//// Exporting Files ////

// This operation is asynchronous! After user exports the file(s) or cancels the operation, the callback is called (on main thread)
// FilesExportedCallback takes a bool parameter which stores whether user has exported the files or cancelled the operation
// Call this function only if CanExportFiles() returns true
NativeFilePicker.Permission NativeFilePicker.ExportFile( string filePath, FilesExportedCallback callback = null );

// Call this function only if CanExportMultipleFiles() returns true
NativeFilePicker.Permission NativeFilePicker.ExportMultipleFiles( string[] filePaths, FilesExportedCallback callback = null );


//// Runtime Permissions ////

// Importing/exporting files is only possible when permission state is Permission.Granted. Most of the functions request permission internally (and return the result) but you can also check/request the permissions manually
// On iOS, no permissions are needed and thus, these functions will always return Permission.Granted
NativeFilePicker.Permission NativeFilePicker.CheckPermission();
NativeFilePicker.Permission NativeFilePicker.RequestPermission();

// If permission state is Permission.Denied, user must grant the necessary Storage permission manually from the Settings. This function helps you open the Settings directly from within the app
void NativeFilePicker.OpenSettings();


//// Other Functions ////

// Returns true if importing multiple files is supported (Android 18+ and iOS 11+)
bool NativeFilePicker.CanPickMultipleFiles();

// Returns true if exporting a single file is supported (Android 19+ and iOS 8+)
bool NativeFilePicker.CanExportFiles();

// Returns true if exporting multiple files is supported (Android 21+ and iOS 11+)
bool NativeFilePicker.CanExportMultipleFiles();

// Returns true if the user is currently importing/exporting files. In that case, another PickFile, PickMultipleFiles, ExportFile or ExportMultipleFiles request will simply be ignored
bool NativeFilePicker.IsFilePickerBusy();

// Converts a file extension to its corresponding MIME on Android and UTI on iOS (don't include the period in extension, i.e. use "png" instead of ".png")
string NativeFilePicker.ConvertExtensionToFileType( string extension );