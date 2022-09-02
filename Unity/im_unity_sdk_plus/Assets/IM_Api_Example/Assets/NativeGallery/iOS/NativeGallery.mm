#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
#import <AssetsLibrary/AssetsLibrary.h>
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
#import <PhotosUI/PhotosUI.h>
#endif

#ifdef UNITY_4_0 || UNITY_5_0
#import "iPhone_View.h"
#else
extern UIViewController* UnityGetGLViewController();
#endif

#define CHECK_IOS_VERSION( version )  ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)

@interface UNativeGallery:NSObject
+ (int)checkPermission:(BOOL)readPermission permissionFreeMode:(BOOL)permissionFreeMode;
+ (int)requestPermission:(BOOL)readPermission permissionFreeMode:(BOOL)permissionFreeMode;
+ (void)showLimitedLibraryPicker;
+ (int)canOpenSettings;
+ (void)openSettings;
+ (int)canPickMultipleMedia;
+ (void)saveMedia:(NSString *)path albumName:(NSString *)album isImg:(BOOL)isImg permissionFreeMode:(BOOL)permissionFreeMode;
+ (void)pickMedia:(int)mediaType savePath:(NSString *)mediaSavePath permissionFreeMode:(BOOL)permissionFreeMode selectionLimit:(int)selectionLimit;
+ (int)isMediaPickerBusy;
+ (int)getMediaTypeFromExtension:(NSString *)extension;
+ (char *)getImageProperties:(NSString *)path;
+ (char *)getVideoProperties:(NSString *)path;
+ (char *)getVideoThumbnail:(NSString *)path savePath:(NSString *)savePath maximumSize:(int)maximumSize captureTime:(double)captureTime;
+ (char *)loadImageAtPath:(NSString *)path tempFilePath:(NSString *)tempFilePath maximumSize:(int)maximumSize;
@end

@implementation UNativeGallery

static NSString *pickedMediaSavePath;
static UIPopoverController *popup;
static UIImagePickerController *imagePicker;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
static PHPickerViewController *imagePickerNew;
#endif
static int imagePickerState = 0; // 0 -> none, 1 -> showing (always in this state on iPad), 2 -> finished
static BOOL simpleMediaPickMode;
static BOOL pickingMultipleFiles = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (int)checkPermission:(BOOL)readPermission permissionFreeMode:(BOOL)permissionFreeMode
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	if( CHECK_IOS_VERSION( @"8.0" ) )
	{
#endif
		// version >= iOS 8: check permission using Photos framework

		// On iOS 11 and later, permission isn't mandatory to fetch media from Photos
		if( readPermission && permissionFreeMode && CHECK_IOS_VERSION( @"11.0" ) )
			return 1;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
		// Photos permissions has changed on iOS 14
		if( CHECK_IOS_VERSION( @"14.0" ) )
		{
			// Request ReadWrite permission in 2 cases:
			// 1) When attempting to pick media from Photos with PHPhotoLibrary (readPermission=true and permissionFreeMode=false)
			// 2) When attempting to write media to a specific album in Photos using PHPhotoLibrary (readPermission=false and permissionFreeMode=false)
			PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:( ( readPermission || !permissionFreeMode ) ? PHAccessLevelReadWrite : PHAccessLevelAddOnly )];
			if( status == PHAuthorizationStatusAuthorized )
				return 1;
			else if( status == PHAuthorizationStatusRestricted )
				return 3;
			else if( status == PHAuthorizationStatusNotDetermined )
				return 2;
			else
				return 0;
		}
		else
#endif
		{
			PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
			if( status == PHAuthorizationStatusAuthorized )
				return 1;
			else if( status == PHAuthorizationStatusNotDetermined )
				return 2;
			else
				return 0;
		}
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	}
	else
	{
		// version < iOS 8: check permission using AssetsLibrary framework (Photos framework not available)
		ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
		if( status == ALAuthorizationStatusAuthorized )
			return 1;
		else if( status == ALAuthorizationStatusNotDetermined )
			return 2;
		else
			return 0;
	}
#endif
}
#pragma clang diagnostic pop

+ (int)requestPermission:(BOOL)readPermission permissionFreeMode:(BOOL)permissionFreeMode
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	if( CHECK_IOS_VERSION( @"8.0" ) )
	{
#endif
		// version >= iOS 8: request permission using Photos framework
		
		// On iOS 11 and later, permission isn't mandatory to fetch media from Photos
		if( readPermission && permissionFreeMode && CHECK_IOS_VERSION( @"11.0" ) )
			return 1;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
		if( CHECK_IOS_VERSION( @"14.0" ) )
		{
			// Photos permissions has changed on iOS 14. There are 2 permission dialogs now:
			// - AddOnly permission dialog: has 2 options: "Allow" and "Don't Allow". This dialog grants permission for save operations only. Unfortunately,
			//   saving media to a custom album isn't possible with this dialog, media can only be saved to the default Photos album
			// - ReadWrite permission dialog: has 3 options: "Allow Access to All Photos" (i.e. full permission), "Select Photos" (i.e. limited access) and
			//   "Don't Allow". To be able to save media to a custom album, user must grant Full Photos permission. Thus, even when readPermission is false,
			//   this dialog will be used if PermissionFreeMode is set to false. So, PermissionFreeMode determines whether or not saving to a custom album is
			//   be supported
			return [self requestPermissionNewest:( readPermission || !permissionFreeMode )];
		}
		else
#endif
			return [self requestPermissionNew];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	}
	else
	{
		// version < iOS 8: request permission using AssetsLibrary framework (Photos framework not available)
		return [self requestPermissionOld];
	}
#endif
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
// Credit: https://stackoverflow.com/a/26933380/2373034
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (int)requestPermissionOld
{
	ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
	
	if( status == ALAuthorizationStatusAuthorized )
		return 1;
	else if( status == ALAuthorizationStatusNotDetermined )
	{
		__block BOOL authorized = NO;
		ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
		
		dispatch_semaphore_t sema = dispatch_semaphore_create( 0 );
		[lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^( ALAssetsGroup *group, BOOL *stop )
		{
			*stop = YES;
			authorized = YES;
			dispatch_semaphore_signal( sema );
		}
		failureBlock:^( NSError *error )
		{
			dispatch_semaphore_signal( sema );
		}];
		dispatch_semaphore_wait( sema, DISPATCH_TIME_FOREVER );
		
		return authorized ? 1 : 0;
	}

	return 0;
}
#pragma clang diagnostic pop
#endif

// Credit: https://stackoverflow.com/a/32989022/2373034
+ (int)requestPermissionNew
{
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
	
	if( status == PHAuthorizationStatusAuthorized )
		return 1;
	else if( status == PHAuthorizationStatusNotDetermined )
	{
		__block BOOL authorized = NO;
		
		dispatch_semaphore_t sema = dispatch_semaphore_create( 0 );
		[PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status )
		{
			authorized = ( status == PHAuthorizationStatusAuthorized );
			dispatch_semaphore_signal( sema );
		}];
		dispatch_semaphore_wait( sema, DISPATCH_TIME_FOREVER );
		
		return authorized ? 1 : 0;
	}
	
	return 0;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
+ (int)requestPermissionNewest:(BOOL)readPermission
{
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:( readPermission ? PHAccessLevelReadWrite : PHAccessLevelAddOnly )];
	
	if( status == PHAuthorizationStatusAuthorized )
		return 1;
	else if( status == PHAuthorizationStatusRestricted )
		return 3;
	else if( status == PHAuthorizationStatusNotDetermined )
	{
		__block int authorized = 0;
		
		dispatch_semaphore_t sema = dispatch_semaphore_create( 0 );
		[PHPhotoLibrary requestAuthorizationForAccessLevel:( readPermission ? PHAccessLevelReadWrite : PHAccessLevelAddOnly ) handler:^( PHAuthorizationStatus status )
		{
			if( status == PHAuthorizationStatusAuthorized )
				authorized = 1;
			else if( status == PHAuthorizationStatusRestricted )
				authorized = 3;

			dispatch_semaphore_signal( sema );
		}];
		dispatch_semaphore_wait( sema, DISPATCH_TIME_FOREVER );
		
		return authorized;
	}
	
	return 0;
}
#endif

// When Photos permission is set to restricted, allows user to change the permission or change the list of restricted images
// It doesn't support a deterministic callback; for example there is a photoLibraryDidChange event but it won't be invoked if
// user doesn't change the list of restricted images
+ (void)showLimitedLibraryPicker
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
	if( status == PHAuthorizationStatusNotDetermined )
		[self requestPermissionNewest:YES];
	else if( status == PHAuthorizationStatusRestricted )
		[[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:UnityGetGLViewController()];
#endif
}

// Credit: https://stackoverflow.com/a/25453667/2373034
+ (int)canOpenSettings
{
	return ( &UIApplicationOpenSettingsURLString != NULL ) ? 1 : 0;
}

// Credit: https://stackoverflow.com/a/25453667/2373034
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)openSettings
{
	if( &UIApplicationOpenSettingsURLString != NULL )
	{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
		if( CHECK_IOS_VERSION( @"10.0" ) )
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
		else
#endif
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}
}
#pragma clang diagnostic pop

+ (int)canPickMultipleMedia
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
	if( CHECK_IOS_VERSION( @"14.0" ) )
		return 1;
	else
#endif
		return 0;
}

+ (void)saveMedia:(NSString *)path albumName:(NSString *)album isImg:(BOOL)isImg permissionFreeMode:(BOOL)permissionFreeMode
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	if( CHECK_IOS_VERSION( @"8.0" ) )
	{
#endif
		// version >= iOS 8: save to specified album using Photos framework
		// On iOS 14+, permission workflow has changed significantly with the addition of PHAuthorizationStatusRestricted permission. On those versions,
		// user must grant Full Photos permission to be able to save to a custom album. Hence, there are 2 workflows:
		// - If PermissionFreeMode is enabled, save the media directly to the default album (i.e. ignore 'album' parameter). This will present a simple
		//   permission dialog stating "The app requires access to Photos to save media to it." and the "Selected Photos" permission won't be listed in the options
		// - Otherwise, the more complex "The app requires access to Photos to interact with it." permission dialog will be shown and if the user grants
		//   Full Photos permission, only then the image will be saved to the specified album. If user selects "Selected Photos" permission, default album will be
		//   used as fallback
		[self saveMediaNew:path albumName:album isImage:isImg saveToDefaultAlbum:( permissionFreeMode && CHECK_IOS_VERSION( @"14.0" ) )];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	}
	else
	{
		// version < iOS 8: save using AssetsLibrary framework (Photos framework not available)
		[self saveMediaOld:path albumName:album isImage:isImg];
	}
#endif
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
// Credit: https://stackoverflow.com/a/22056664/2373034
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)saveMediaOld:(NSString *)path albumName:(NSString *)album isImage:(BOOL)isImage
{
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	if( !isImage && ![library videoAtPathIsCompatibleWithSavedPhotosAlbum:[NSURL fileURLWithPath:path]])
	{
		NSLog( @"Error saving video: Video format is not compatible with Photos" );
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
		return;
	}
	
	void (^saveBlock)(ALAssetsGroup *assetCollection) = ^void( ALAssetsGroup *assetCollection )
	{
		void (^saveResultBlock)(NSURL *assetURL, NSError *error) = ^void( NSURL *assetURL, NSError *error )
		{
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			
			if( error.code == 0 )
			{
				[library assetForURL:assetURL resultBlock:^( ALAsset *asset )
				{
					[assetCollection addAsset:asset];
					UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveCompleted", "" );
				}
				failureBlock:^( NSError* error )
				{
					NSLog( @"Error moving asset to album: %@", error );
					UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
				}];
			}
			else
			{
				NSLog( @"Error creating asset: %@", error );
				UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
			}
		};
		
		if( !isImage )
			[library writeImageDataToSavedPhotosAlbum:[NSData dataWithContentsOfFile:path] metadata:nil completionBlock:saveResultBlock];
		else
			[library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:saveResultBlock];
	};
	
	__block BOOL albumFound = NO;
	[library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^( ALAssetsGroup *group, BOOL *stop )
	{
		if( [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:album] )
		{
			*stop = YES;
			albumFound = YES;
			saveBlock( group );
		}
		else if( group == nil && albumFound==NO )
		{
			// Album doesn't exist
			[library addAssetsGroupAlbumWithName:album resultBlock:^( ALAssetsGroup *group )
			{
				saveBlock( group );
			}
			failureBlock:^( NSError *error )
			{
				NSLog( @"Error creating album: %@", error );
				[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
				UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
			}];
		}
	}
	failureBlock:^( NSError* error )
	{
		NSLog( @"Error listing albums: %@", error );
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
	}];
}
#pragma clang diagnostic pop
#endif

// Credit: https://stackoverflow.com/a/39909129/2373034
+ (void)saveMediaNew:(NSString *)path albumName:(NSString *)album isImage:(BOOL)isImage saveToDefaultAlbum:(BOOL)saveToDefaultAlbum
{
	void (^saveToPhotosAlbum)() = ^void()
	{
		if( isImage )
		{
			// Try preserving image metadata (essential for animated gif images)
			[[PHPhotoLibrary sharedPhotoLibrary] performChanges:
			^{
				[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:path]];
			}
			completionHandler:^( BOOL success, NSError *error )
			{
				if( success )
				{
					[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
					UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveCompleted", "" );
				}
				else
				{
					NSLog( @"Error creating asset in default Photos album: %@", error );
					
					UIImage *image = [UIImage imageWithContentsOfFile:path];
					if( image != nil )
						UIImageWriteToSavedPhotosAlbum( image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge_retained void *) path );
					else
					{
						NSLog( @"Couldn't create UIImage from file at path: %@", path );
						[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
						UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
					}
				}
			}];
		}
		else
		{
			if( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum( path ) )
				UISaveVideoAtPathToSavedPhotosAlbum( path, self, @selector(video:didFinishSavingWithError:contextInfo:), (__bridge_retained void *) path );
			else
			{
				NSLog( @"Video at path isn't compatible with saved photos album: %@", path );
				[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
				UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
			}
		}
	};

	void (^saveBlock)(PHAssetCollection *assetCollection) = ^void( PHAssetCollection *assetCollection )
	{
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:
		^{
			PHAssetChangeRequest *assetChangeRequest;
			if( isImage )
				assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:path]];
			else
				assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]];
			
			PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
			[assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
			
		}
		completionHandler:^( BOOL success, NSError *error )
		{
			if( success )
			{
				[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
				UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveCompleted", "" );
			}
			else
			{
				NSLog( @"Error creating asset: %@", error );
				saveToPhotosAlbum();
			}
		}];
	};

	if( saveToDefaultAlbum )
		saveToPhotosAlbum();
	else
	{
		PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
		fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", album];
		PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
		if( fetchResult.count > 0 )
			saveBlock( fetchResult.firstObject);
		else
		{
			__block PHObjectPlaceholder *albumPlaceholder;
			[[PHPhotoLibrary sharedPhotoLibrary] performChanges:
			^{
				PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
				albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
			}
			completionHandler:^( BOOL success, NSError *error )
			{
				if( success )
				{
					PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
					if( fetchResult.count > 0 )
						saveBlock( fetchResult.firstObject);
					else
					{
						NSLog( @"Error creating album: Album placeholder not found" );
						saveToPhotosAlbum();
					}
				}
				else
				{
					NSLog( @"Error creating album: %@", error );
					saveToPhotosAlbum();
				}
			}];
		}
	}
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSString* path = (__bridge_transfer NSString *)(contextInfo);
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];

	if( error == nil )
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveCompleted", "" );
	else
	{
		NSLog( @"Error saving image with UIImageWriteToSavedPhotosAlbum: %@", error );
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
	}
}

+ (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSString* path = (__bridge_transfer NSString *)(contextInfo);
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];

	if( error == nil )
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveCompleted", "" );
	else
	{
		NSLog( @"Error saving video with UISaveVideoAtPathToSavedPhotosAlbum: %@", error );
		UnitySendMessage( "NGMediaSaveCallbackiOS", "OnMediaSaveFailed", "" );
	}
}

// Credit: https://stackoverflow.com/a/10531752/2373034
+ (void)pickMedia:(int)mediaType savePath:(NSString *)mediaSavePath permissionFreeMode:(BOOL)permissionFreeMode selectionLimit:(int)selectionLimit
{
	pickedMediaSavePath = mediaSavePath;
	imagePickerState = 1;
	simpleMediaPickMode = permissionFreeMode && CHECK_IOS_VERSION( @"11.0" );
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
	if( CHECK_IOS_VERSION( @"14.0" ) )
	{
		// PHPickerViewController is used on iOS 14
		PHPickerConfiguration *config = simpleMediaPickMode ? [[PHPickerConfiguration alloc] init] : [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
		config.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeCurrent;
		config.selectionLimit = selectionLimit;
		pickingMultipleFiles = selectionLimit != 1;
		
		// mediaType is a bitmask:
		// 1: image
		// 2: video
		// 4: audio (not supported)
		if( mediaType == 1 )
			config.filter = [PHPickerFilter anyFilterMatchingSubfilters:[NSArray arrayWithObjects:[PHPickerFilter imagesFilter], [PHPickerFilter livePhotosFilter], nil]];
		else if( mediaType == 2 )
			config.filter = [PHPickerFilter videosFilter];
		else
			config.filter = [PHPickerFilter anyFilterMatchingSubfilters:[NSArray arrayWithObjects:[PHPickerFilter imagesFilter], [PHPickerFilter livePhotosFilter], [PHPickerFilter videosFilter], nil]];
		
		imagePickerNew = [[PHPickerViewController alloc] initWithConfiguration:config];
		imagePickerNew.delegate = (id) self;
		[UnityGetGLViewController() presentViewController:imagePickerNew animated:YES completion:^{ imagePickerState = 0; }];
	}
	else
#endif
	{
		// UIImagePickerController is used on previous versions
		imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = (id) self;
		imagePicker.allowsEditing = NO;
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		
		// mediaType is a bitmask:
		// 1: image
		// 2: video
		// 4: audio (not supported)
		if( mediaType == 1 )
		{
			if( CHECK_IOS_VERSION( @"9.1" ) )
				imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeLivePhoto, nil];
			else
				imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
		}
		else if( mediaType == 2 )
			imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo, nil];
		else
		{
			if( CHECK_IOS_VERSION( @"9.1" ) )
				imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeLivePhoto, (NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo, nil];
			else
				imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo, nil];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
		if( mediaType != 1 )
		{
			// Don't compress picked videos if possible
			if( CHECK_IOS_VERSION( @"11.0" ) )
				imagePicker.videoExportPreset = AVAssetExportPresetPassthrough;
		}
#endif
		
		UIViewController *rootViewController = UnityGetGLViewController();
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) // iPhone
			[rootViewController presentViewController:imagePicker animated:YES completion:^{ imagePickerState = 0; }];
		else
		{
			// iPad
			popup = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
			popup.delegate = (id) self;
			[popup presentPopoverFromRect:CGRectMake( rootViewController.view.frame.size.width / 2, rootViewController.view.frame.size.height / 2, 1, 1 ) inView:rootViewController.view permittedArrowDirections:0 animated:YES];
		}
	}
}

+ (int)isMediaPickerBusy
{
	if( imagePickerState == 2 )
		return 1;
	
	if( imagePicker != nil )
	{
		if( imagePickerState == 1 || [imagePicker presentingViewController] == UnityGetGLViewController() )
			return 1;
		else
		{
			imagePicker = nil;
			return 0;
		}
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
	else if( CHECK_IOS_VERSION( @"14.0" ) && imagePickerNew != nil )
	{
		if( imagePickerState == 1 || [imagePickerNew presentingViewController] == UnityGetGLViewController() )
			return 1;
		else
		{
			imagePickerNew = nil;
			return 0;
		}
	}
#endif
	else
		return 0;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString *resultPath = nil;
	
	if( [info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage] )
	{
		NSLog( @"Picked an image" );
		
		// On iOS 8.0 or later, try to obtain the raw data of the image (which allows picking gifs properly or preserving metadata)
		if( CHECK_IOS_VERSION( @"8.0" ) )
		{
			PHAsset *asset = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
			if( CHECK_IOS_VERSION( @"11.0" ) )
			{
				// Try fetching the source image via UIImagePickerControllerImageURL
				NSURL *mediaUrl = info[UIImagePickerControllerImageURL];
				if( mediaUrl != nil )
				{
					NSString *imagePath = [mediaUrl path];
					if( imagePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imagePath] )
					{
						NSError *error;
						NSString *newPath = [pickedMediaSavePath stringByAppendingPathExtension:[imagePath pathExtension]];
						
						if( ![[NSFileManager defaultManager] fileExistsAtPath:newPath] || [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error] )
						{
							if( [[NSFileManager defaultManager] copyItemAtPath:imagePath toPath:newPath error:&error] )
							{
								resultPath = newPath;
								NSLog( @"Copied source image from UIImagePickerControllerImageURL" );
							}
							else
								NSLog( @"Error copying image: %@", error );
						}
						else
							NSLog( @"Error deleting existing image: %@", error );
					}
				}
				
				if( resultPath == nil )
					asset = info[UIImagePickerControllerPHAsset];
			}
#endif
			
			if( resultPath == nil && !simpleMediaPickMode )
			{
				if( asset == nil )
				{
					NSURL *mediaUrl = info[UIImagePickerControllerReferenceURL] ?: info[UIImagePickerControllerMediaURL];
					if( mediaUrl != nil )
						asset = [[PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:mediaUrl] options:nil] firstObject];
				}
				
				resultPath = [self trySavePHAsset:asset atIndex:1];
			}
		}
		
		if( resultPath == nil )
		{
			// Save image as PNG
			UIImage *image = info[UIImagePickerControllerOriginalImage];
			if( image != nil )
			{
				resultPath = [pickedMediaSavePath stringByAppendingPathExtension:@"png"];
				if( ![self saveImageAsPNG:image toPath:resultPath] )
				{
					NSLog( @"Error creating PNG image" );
					resultPath = nil;
				}
			}
			else
				NSLog( @"Error fetching original image from picker" );
		}
	}
	else if( CHECK_IOS_VERSION( @"9.1" ) && [info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeLivePhoto] )
	{
		NSLog( @"Picked a live photo" );
		
		// Save live photo as PNG
		UIImage *image = info[UIImagePickerControllerOriginalImage];
		if( image != nil )
		{
			resultPath = [pickedMediaSavePath stringByAppendingPathExtension:@"png"];
			if( ![self saveImageAsPNG:image toPath:resultPath] )
			{
				NSLog( @"Error creating PNG image" );
				resultPath = nil;
			}
		}
		else
			NSLog( @"Error fetching live photo's still image from picker" );
	}
	else
	{
		NSLog( @"Picked a video" );
		
		NSURL *mediaUrl = info[UIImagePickerControllerMediaURL] ?: info[UIImagePickerControllerReferenceURL];
		if( mediaUrl != nil )
		{
			resultPath = [mediaUrl path];
			
			// On iOS 13, picked file becomes unreachable as soon as the UIImagePickerController disappears,
			// in that case, copy the video to a temporary location
			if( CHECK_IOS_VERSION( @"13.0" ) )
			{
				NSError *error;
				NSString *newPath = [pickedMediaSavePath stringByAppendingPathExtension:[resultPath pathExtension]];
				
				if( ![[NSFileManager defaultManager] fileExistsAtPath:newPath] || [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error] )
				{
					if( [[NSFileManager defaultManager] copyItemAtPath:resultPath toPath:newPath error:&error] )
						resultPath = newPath;
					else
					{
						NSLog( @"Error copying video: %@", error );
						resultPath = nil;
					}
				}
				else
				{
					NSLog( @"Error deleting existing video: %@", error );
					resultPath = nil;
				}
			}
		}
	}
	
	popup = nil;
	imagePicker = nil;
	imagePickerState = 2;
	UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMediaReceived", [self getCString:resultPath] );
	
	[picker dismissViewControllerAnimated:NO completion:nil];
}
#pragma clang diagnostic pop

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
// Credit: https://ikyle.me/blog/2020/phpickerviewcontroller
+(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
{
	imagePickerNew = nil;
	imagePickerState = 2;
	
	[picker dismissViewControllerAnimated:NO completion:nil];
	
	if( results != nil && [results count] > 0 )
	{
		NSMutableArray<NSString *> *resultPaths = [NSMutableArray arrayWithCapacity:[results count]];
		NSLock *arrayLock = [[NSLock alloc] init];
		dispatch_group_t group = dispatch_group_create();
		
		for( int i = 0; i < [results count]; i++ )
		{
			PHPickerResult *result = results[i];
			NSItemProvider *itemProvider = result.itemProvider;
			NSString *assetIdentifier = result.assetIdentifier;
			__block NSString *resultPath = nil;
			
			int j = i + 1;
			
			//NSLog( @"result: %@", result );
			//NSLog( @"%@", result.assetIdentifier);
			//NSLog( @"%@", result.itemProvider);

			if( [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage] )
			{
				NSLog( @"Picked an image" );
				
				if( !simpleMediaPickMode && assetIdentifier != nil )
				{
					PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:assetIdentifier] options:nil] firstObject];
					resultPath = [self trySavePHAsset:asset atIndex:j];
				}
				
				if( resultPath != nil )
				{
					[arrayLock lock];
					[resultPaths addObject:resultPath];
					[arrayLock unlock];
				}
				else
				{
					dispatch_group_enter( group );
					
					[itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeImage completionHandler:^( NSURL *url, NSError *error )
					{
						if( url != nil )
						{
							// Copy the image to a temporary location because the returned image will be deleted by the OS after this callback is completed
							resultPath = [url path];
							NSString *newPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j] stringByAppendingPathExtension:[resultPath pathExtension]];
							
							if( ![[NSFileManager defaultManager] fileExistsAtPath:newPath] || [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error] )
							{
								if( [[NSFileManager defaultManager] copyItemAtPath:resultPath toPath:newPath error:&error])
									resultPath = newPath;
								else
								{
									NSLog( @"Error copying image: %@", error );
									resultPath = nil;
								}
							}
							else
							{
								NSLog( @"Error deleting existing image: %@", error );
								resultPath = nil;
							}
						}
						else
							NSLog( @"Error getting the picked image's path: %@", error );
						
						if( resultPath != nil )
						{
							[arrayLock lock];
							[resultPaths addObject:resultPath];
							[arrayLock unlock];
						}
						else
						{
							if( [itemProvider canLoadObjectOfClass:[UIImage class]] )
							{
								dispatch_group_enter( group );
								
								[itemProvider loadObjectOfClass:[UIImage class] completionHandler:^( __kindof id<NSItemProviderReading> object, NSError *error )
								{
									if( object != nil && [object isKindOfClass:[UIImage class]] )
									{
										resultPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j] stringByAppendingPathExtension:@"png"];
										if( ![self saveImageAsPNG:(UIImage *)object toPath:resultPath] )
										{
											NSLog( @"Error creating PNG image" );
											resultPath = nil;
										}
									}
									else
										NSLog( @"Error generating UIImage from picked image: %@", error );
									
									[arrayLock lock];
									[resultPaths addObject:( resultPath != nil ? resultPath : @"" )];
									[arrayLock unlock];
									
									dispatch_group_leave( group );
								}];
							}
							else
							{
								NSLog( @"Can't generate UIImage from picked image" );
								
								[arrayLock lock];
								[resultPaths addObject:@""];
								[arrayLock unlock];
							}
						}
						
						dispatch_group_leave( group );
					}];
				}
			}
			else if( CHECK_IOS_VERSION( @"9.1" ) && [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeLivePhoto] )
			{
				NSLog( @"Picked a live photo" );
				
				if( [itemProvider canLoadObjectOfClass:[UIImage class]] )
				{
					dispatch_group_enter( group );
					
					[itemProvider loadObjectOfClass:[UIImage class] completionHandler:^( __kindof id<NSItemProviderReading> object, NSError *error )
					{
						if( object != nil && [object isKindOfClass:[UIImage class]] )
						{
							resultPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j] stringByAppendingPathExtension:@"png"];
							if( ![self saveImageAsPNG:(UIImage *)object toPath:resultPath] )
							{
								NSLog( @"Error creating PNG image" );
								resultPath = nil;
							}
						}
						else
							NSLog( @"Error generating UIImage from picked live photo: %@", error );
						
						[arrayLock lock];
						[resultPaths addObject:( resultPath != nil ? resultPath : @"" )];
						[arrayLock unlock];
						
						dispatch_group_leave( group );
					}];
				}
				else if( [itemProvider canLoadObjectOfClass:[PHLivePhoto class]] )
				{
					dispatch_group_enter( group );
					
					[itemProvider loadObjectOfClass:[PHLivePhoto class] completionHandler:^( __kindof id<NSItemProviderReading> object, NSError *error )
					{
						if( object != nil && [object isKindOfClass:[PHLivePhoto class]] )
						{
							// Extract image data from live photo
							// Credit: https://stackoverflow.com/a/41341675/2373034
							NSArray<PHAssetResource*>* livePhotoResources = [PHAssetResource assetResourcesForLivePhoto:(PHLivePhoto *)object];
							
							PHAssetResource *livePhotoImage = nil;
							for( int k = 0; k < [livePhotoResources count]; k++ )
							{
								if( livePhotoResources[k].type == PHAssetResourceTypePhoto )
								{
									livePhotoImage = livePhotoResources[k];
									break;
								}
							}
							
							if( livePhotoImage == nil )
							{
								NSLog( @"Error extracting image data from live photo" );
							
								[arrayLock lock];
								[resultPaths addObject:@""];
								[arrayLock unlock];
							}
							else
							{
								dispatch_group_enter( group );
								
								NSString *originalFilename = livePhotoImage.originalFilename;
								if( originalFilename == nil || [originalFilename length] == 0 )
									resultPath = [NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j];
								else
									resultPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j] stringByAppendingPathExtension:[originalFilename pathExtension]];
								
								[[PHAssetResourceManager defaultManager] writeDataForAssetResource:livePhotoImage toFile:[NSURL fileURLWithPath:resultPath] options:nil completionHandler:^( NSError * _Nullable error2 )
								{
									if( error2 != nil )
									{
										NSLog( @"Error saving image data from live photo: %@", error2 );
										resultPath = nil;
									}
									
									[arrayLock lock];
									[resultPaths addObject:( resultPath != nil ? resultPath : @"" )];
									[arrayLock unlock];
									
									dispatch_group_leave( group );
								}];
							}
						}
						else
						{
							NSLog( @"Error generating PHLivePhoto from picked live photo: %@", error );
						
							[arrayLock lock];
							[resultPaths addObject:@""];
							[arrayLock unlock];
						}
						
						dispatch_group_leave( group );
					}];
				}
				else
				{
					NSLog( @"Can't convert picked live photo to still image" );
					
					[arrayLock lock];
					[resultPaths addObject:@""];
					[arrayLock unlock];
				}
			}
			else if( [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie] || [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVideo] )
			{
				NSLog( @"Picked a video" );
				
				// Get the video file's path
				dispatch_group_enter( group );
				
				[itemProvider loadFileRepresentationForTypeIdentifier:([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie] ? (NSString *)kUTTypeMovie : (NSString *)kUTTypeVideo) completionHandler:^( NSURL *url, NSError *error )
				{
					if( url != nil )
					{
						// Copy the video to a temporary location because the returned video will be deleted by the OS after this callback is completed
						resultPath = [url path];
						NSString *newPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, j] stringByAppendingPathExtension:[resultPath pathExtension]];
						
						if( ![[NSFileManager defaultManager] fileExistsAtPath:newPath] || [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error] )
						{
							if( [[NSFileManager defaultManager] copyItemAtPath:resultPath toPath:newPath error:&error])
								resultPath = newPath;
							else
							{
								NSLog( @"Error copying video: %@", error );
								resultPath = nil;
							}
						}
						else
						{
							NSLog( @"Error deleting existing video: %@", error );
							resultPath = nil;
						}
					}
					else
						NSLog( @"Error getting the picked video's path: %@", error );
					
					[arrayLock lock];
					[resultPaths addObject:( resultPath != nil ? resultPath : @"" )];
					[arrayLock unlock];
					
					dispatch_group_leave( group );
				}];
			}
			else
			{
				// Unknown media type picked?
				NSLog( @"Couldn't determine type of picked media: %@", itemProvider );
				
				[arrayLock lock];
				[resultPaths addObject:@""];
				[arrayLock unlock];
			}
		}
		
		dispatch_group_notify( group, dispatch_get_main_queue(),
		^{
			if( !pickingMultipleFiles )
				UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMediaReceived", [self getCString:resultPaths[0]] );
			else
				UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMultipleMediaReceived", [self getCString:[resultPaths componentsJoinedByString:@">"]] );
		});
	}
	else
	{
		NSLog( @"No media picked" );
		
		if( !pickingMultipleFiles )
			UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMediaReceived", "" );
		else
			UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMultipleMediaReceived", "" );
	}
}
#endif

+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	NSLog( @"UIImagePickerController cancelled" );

	popup = nil;
	imagePicker = nil;
	UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMediaReceived", "" );
	
	[picker dismissViewControllerAnimated:NO completion:nil];
}

+ (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	NSLog( @"UIPopoverController dismissed" );

	popup = nil;
	imagePicker = nil;
	UnitySendMessage( "NGMediaReceiveCallbackiOS", "OnMediaReceived", "" );
}

+ (NSString *)trySavePHAsset:(PHAsset *)asset atIndex:(int)filenameIndex
{
	if( asset == nil )
		return nil;
	
	__block NSString *resultPath = nil;
	
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.synchronous = YES;
	options.version = PHImageRequestOptionsVersionCurrent;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
	if( CHECK_IOS_VERSION( @"13.0" ) )
	{
		[[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:options resultHandler:^( NSData *imageData, NSString *dataUTI, CGImagePropertyOrientation orientation, NSDictionary *imageInfo )
		{
			if( imageData != nil )
				resultPath = [self trySaveSourceImage:imageData withInfo:imageInfo atIndex:filenameIndex];
			else
				NSLog( @"Couldn't fetch raw image data" );
		}];
	}
	else 
#endif
	{
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^( NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *imageInfo )
		{
			if( imageData != nil )
				resultPath = [self trySaveSourceImage:imageData withInfo:imageInfo atIndex:filenameIndex];
			else
				NSLog( @"Couldn't fetch raw image data" );
		}];
	}
	
	return resultPath;
}

+ (NSString *)trySaveSourceImage:(NSData *)imageData withInfo:(NSDictionary *)info atIndex:(int)filenameIndex
{
	NSString *filePath = info[@"PHImageFileURLKey"];
	if( filePath != nil ) // filePath can actually be an NSURL, convert it to NSString
		filePath = [NSString stringWithFormat:@"%@", filePath];
	
	if( filePath == nil || [filePath length] == 0 )
	{
		filePath = info[@"PHImageFileUTIKey"];
		if( filePath != nil )
			filePath = [NSString stringWithFormat:@"%@", filePath];
	}
	
	NSString *resultPath;
	if( filePath == nil || [filePath length] == 0 )
		resultPath = [NSString stringWithFormat:@"%@%d", pickedMediaSavePath, filenameIndex];
	else
		resultPath = [[NSString stringWithFormat:@"%@%d", pickedMediaSavePath, filenameIndex] stringByAppendingPathExtension:[filePath pathExtension]];
	
	NSError *error;
	if( ![[NSFileManager defaultManager] fileExistsAtPath:resultPath] || [[NSFileManager defaultManager] removeItemAtPath:resultPath error:&error] )
	{
		if( ![imageData writeToFile:resultPath atomically:YES] )
		{
			NSLog( @"Error copying source image to file" );
			resultPath = nil;
		}
	}
	else
	{
		NSLog( @"Error deleting existing image: %@", error );
		resultPath = nil;
	}
	
	return resultPath;
}

// Credit: https://lists.apple.com/archives/cocoa-dev/2012/Jan/msg00052.html
+ (int)getMediaTypeFromExtension:(NSString *)extension
{
	CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, NULL );
	
	// mediaType is a bitmask:
	// 1: image
	// 2: video
	// 4: audio (not supported)
	int result = 0;
	if( UTTypeConformsTo( fileUTI, kUTTypeImage ) )
		result = 1;
	else if( CHECK_IOS_VERSION( @"9.1" ) && UTTypeConformsTo( fileUTI, kUTTypeLivePhoto ) )
		result = 1;
	else if( UTTypeConformsTo( fileUTI, kUTTypeMovie ) || UTTypeConformsTo( fileUTI, kUTTypeVideo ) )
		result = 2;
	else if( UTTypeConformsTo( fileUTI, kUTTypeAudio ) )
		result = 4;
	
	CFRelease( fileUTI );
	
	return result;
}

// Credit: https://stackoverflow.com/a/4170099/2373034
+ (NSArray *)getImageMetadata:(NSString *)path
{
	int width = 0;
	int height = 0;
	int orientation = -1;
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL( (__bridge CFURLRef) [NSURL fileURLWithPath:path], nil );
	if( imageSource != nil )
	{
		NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(__bridge NSString *)kCGImageSourceShouldCache];
		CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex( imageSource, 0, (__bridge CFDictionaryRef) options );
		CFRelease( imageSource );
		
		CGFloat widthF = 0.0f, heightF = 0.0f;
		if( imageProperties != nil )
		{
			if( CFDictionaryContainsKey( imageProperties, kCGImagePropertyPixelWidth ) )
				CFNumberGetValue( (CFNumberRef) CFDictionaryGetValue( imageProperties, kCGImagePropertyPixelWidth ), kCFNumberCGFloatType, &widthF );
			
			if( CFDictionaryContainsKey( imageProperties, kCGImagePropertyPixelHeight ) )
				CFNumberGetValue( (CFNumberRef) CFDictionaryGetValue( imageProperties, kCGImagePropertyPixelHeight ), kCFNumberCGFloatType, &heightF );
			
			if( CFDictionaryContainsKey( imageProperties, kCGImagePropertyOrientation ) )
			{
				CFNumberGetValue( (CFNumberRef) CFDictionaryGetValue( imageProperties, kCGImagePropertyOrientation ), kCFNumberIntType, &orientation );
				
				if( orientation > 4 )
				{
					// Landscape image
					CGFloat temp = widthF;
					widthF = heightF;
					heightF = temp;
				}
			}
			
			CFRelease( imageProperties );
		}
		
		width = (int) roundf( widthF );
		height = (int) roundf( heightF );
	}
	
	return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:width], [NSNumber numberWithInt:height], [NSNumber numberWithInt:orientation], nil];
}

+ (char *)getImageProperties:(NSString *)path
{
	NSArray *metadata = [self getImageMetadata:path];
	
	int orientationUnity;
	int orientation = [metadata[2] intValue];
	
	// To understand the magic numbers, see ImageOrientation enum in NativeGallery.cs
	// and http://sylvana.net/jpegcrop/exif_orientation.html
	if( orientation == 1 )
		orientationUnity = 0;
	else if( orientation == 2 )
		orientationUnity = 4;
	else if( orientation == 3 )
		orientationUnity = 2;
	else if( orientation == 4 )
		orientationUnity = 6;
	else if( orientation == 5 )
		orientationUnity = 5;
	else if( orientation == 6 )
		orientationUnity = 1;
	else if( orientation == 7 )
		orientationUnity = 7;
	else if( orientation == 8 )
		orientationUnity = 3;
	else
		orientationUnity = -1;
	
	return [self getCString:[NSString stringWithFormat:@"%d>%d> >%d", [metadata[0] intValue], [metadata[1] intValue], orientationUnity]];
}

+ (char *)getVideoProperties:(NSString *)path
{
	CGSize size = CGSizeZero;
	float rotation = 0;
	long long duration = 0;
	
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
	if( asset != nil )
	{
		duration = (long long) round( CMTimeGetSeconds( [asset duration] ) * 1000 );
		CGAffineTransform transform = [asset preferredTransform];
		NSArray<AVAssetTrack *>* videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
		if( videoTracks != nil && [videoTracks count] > 0 )
		{
			size = [[videoTracks objectAtIndex:0] naturalSize];
			transform = [[videoTracks objectAtIndex:0] preferredTransform];
		}
		
		rotation = atan2( transform.b, transform.a ) * ( 180.0 / M_PI );
	}
	
	return [self getCString:[NSString stringWithFormat:@"%d>%d>%lld>%f", (int) roundf( size.width ), (int) roundf( size.height ), duration, rotation]];
}

+ (char *)getVideoThumbnail:(NSString *)path savePath:(NSString *)savePath maximumSize:(int)maximumSize captureTime:(double)captureTime
{
	AVAssetImageGenerator *thumbnailGenerator = [[AVAssetImageGenerator alloc] initWithAsset:[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil]];
	thumbnailGenerator.appliesPreferredTrackTransform = YES;
	thumbnailGenerator.maximumSize = CGSizeMake( (CGFloat) maximumSize, (CGFloat) maximumSize );
	thumbnailGenerator.requestedTimeToleranceBefore = kCMTimeZero;
	thumbnailGenerator.requestedTimeToleranceAfter = kCMTimeZero;
	
	if( captureTime < 0.0 )
		captureTime = 0.0;
	else
	{
		AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
		if( asset != nil )
		{
			double videoDuration = CMTimeGetSeconds( [asset duration] );
			if( videoDuration > 0.0 && captureTime >= videoDuration - 0.1 )
			{
				if( captureTime > videoDuration )
					captureTime = videoDuration;
				
				thumbnailGenerator.requestedTimeToleranceBefore = CMTimeMakeWithSeconds( 1.0, 600 );
			}
		}
	}
	
	NSError *error = nil;
	CGImageRef image = [thumbnailGenerator copyCGImageAtTime:CMTimeMakeWithSeconds( captureTime, 600 ) actualTime:nil error:&error];
	if( image == nil )
	{
		if( error != nil )
			NSLog( @"Error generating video thumbnail: %@", error );
		else
			NSLog( @"Error generating video thumbnail..." );
		
		return [self getCString:@""];
	}
	
	UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease( image );
	
	if( ![UIImagePNGRepresentation( thumbnail ) writeToFile:savePath atomically:YES] )
	{
		NSLog( @"Error saving thumbnail image" );
		return [self getCString:@""];
	}
	
	return [self getCString:savePath];
}

+ (BOOL)saveImageAsPNG:(UIImage *)image toPath:(NSString *)resultPath
{
	return [UIImagePNGRepresentation( [self scaleImage:image maxSize:16384] ) writeToFile:resultPath atomically:YES];
}

+ (UIImage *)scaleImage:(UIImage *)image maxSize:(int)maxSize
{
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	
	UIImageOrientation orientation = image.imageOrientation;
	if( width <= maxSize && height <= maxSize && orientation != UIImageOrientationDown &&
		orientation != UIImageOrientationLeft && orientation != UIImageOrientationRight &&
		orientation != UIImageOrientationLeftMirrored && orientation != UIImageOrientationRightMirrored &&
		orientation != UIImageOrientationUpMirrored && orientation != UIImageOrientationDownMirrored )
		return image;
	
	CGFloat scaleX = 1.0f;
	CGFloat scaleY = 1.0f;
	if( width > maxSize )
		scaleX = maxSize / width;
	if( height > maxSize )
		scaleY = maxSize / height;
	
	// Credit: https://github.com/mbcharbonneau/UIImage-Categories/blob/master/UIImage%2BAlpha.m
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo( image.CGImage );
	BOOL hasAlpha = alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast;
	
	CGFloat scaleRatio = scaleX < scaleY ? scaleX : scaleY;
	CGRect imageRect = CGRectMake( 0, 0, width * scaleRatio, height * scaleRatio );
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
	// Resize image with UIGraphicsImageRenderer (Apple's recommended API) if possible
	if( CHECK_IOS_VERSION( @"10.0" ) )
	{
		UIGraphicsImageRendererFormat *format = [image imageRendererFormat];
		format.opaque = !hasAlpha;
		format.scale = image.scale;
	   
		UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageRect.size format:format];
		image = [renderer imageWithActions:^( UIGraphicsImageRendererContext* _Nonnull myContext )
		{
			[image drawInRect:imageRect];
		}];
	}
	else
	#endif
	{
		UIGraphicsBeginImageContextWithOptions( imageRect.size, !hasAlpha, image.scale );
		[image drawInRect:imageRect];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	return image;
}

+ (char *)loadImageAtPath:(NSString *)path tempFilePath:(NSString *)tempFilePath maximumSize:(int)maximumSize
{
	// Check if the image can be loaded by Unity without requiring a conversion to PNG
	// Credit: https://stackoverflow.com/a/12048937/2373034
	NSString *extension = [path pathExtension];
	BOOL conversionNeeded = [extension caseInsensitiveCompare:@"jpg"] != NSOrderedSame && [extension caseInsensitiveCompare:@"jpeg"] != NSOrderedSame && [extension caseInsensitiveCompare:@"png"] != NSOrderedSame;

	if( !conversionNeeded )
	{
		// Check if the image needs to be processed at all
		NSArray *metadata = [self getImageMetadata:path];
		int orientationInt = [metadata[2] intValue];  // 1: correct orientation, [1,8]: valid orientation range
		if( orientationInt == 1 && [metadata[0] intValue] <= maximumSize && [metadata[1] intValue] <= maximumSize )
			return [self getCString:path];
	}
	
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	if( image == nil )
		return [self getCString:path];
	
	UIImage *scaledImage = [self scaleImage:image maxSize:maximumSize];
	if( conversionNeeded || scaledImage != image )
	{
		if( ![UIImagePNGRepresentation( scaledImage ) writeToFile:tempFilePath atomically:YES] )
		{
			NSLog( @"Error creating scaled image" );
			return [self getCString:path];
		}
		
		return [self getCString:tempFilePath];
	}
	else
		return [self getCString:path];
}

// Credit: https://stackoverflow.com/a/37052118/2373034
+ (char *)getCString:(NSString *)source
{
	if( source == nil )
		source = @"";
	
	const char *sourceUTF8 = [source UTF8String];
	char *result = (char*) malloc( strlen( sourceUTF8 ) + 1 );
	strcpy( result, sourceUTF8 );
	
	return result;
}

@end

extern "C" int _NativeGallery_CheckPermission( int readPermission, int permissionFreeMode )
{
	return [UNativeGallery checkPermission:( readPermission == 1 ) permissionFreeMode:( permissionFreeMode == 1 )];
}

extern "C" int _NativeGallery_RequestPermission( int readPermission, int permissionFreeMode )
{
	return [UNativeGallery requestPermission:( readPermission == 1 ) permissionFreeMode:( permissionFreeMode == 1 )];
}

extern "C" void _NativeGallery_ShowLimitedLibraryPicker()
{
	return [UNativeGallery showLimitedLibraryPicker];
}

extern "C" int _NativeGallery_CanOpenSettings()
{
	return [UNativeGallery canOpenSettings];
}

extern "C" void _NativeGallery_OpenSettings()
{
	[UNativeGallery openSettings];
}

extern "C" int _NativeGallery_CanPickMultipleMedia()
{
	return [UNativeGallery canPickMultipleMedia];
}

extern "C" void _NativeGallery_ImageWriteToAlbum( const char* path, const char* album, int permissionFreeMode )
{
	[UNativeGallery saveMedia:[NSString stringWithUTF8String:path] albumName:[NSString stringWithUTF8String:album] isImg:YES permissionFreeMode:( permissionFreeMode == 1 )];
}

extern "C" void _NativeGallery_VideoWriteToAlbum( const char* path, const char* album, int permissionFreeMode )
{
	[UNativeGallery saveMedia:[NSString stringWithUTF8String:path] albumName:[NSString stringWithUTF8String:album] isImg:NO permissionFreeMode:( permissionFreeMode == 1 )];
}

extern "C" void _NativeGallery_PickMedia( const char* mediaSavePath, int mediaType, int permissionFreeMode, int selectionLimit )
{
	[UNativeGallery pickMedia:mediaType savePath:[NSString stringWithUTF8String:mediaSavePath] permissionFreeMode:( permissionFreeMode == 1 ) selectionLimit:selectionLimit];
}

extern "C" int _NativeGallery_IsMediaPickerBusy()
{
	return [UNativeGallery isMediaPickerBusy];
}

extern "C" int _NativeGallery_GetMediaTypeFromExtension( const char* extension )
{
	return [UNativeGallery getMediaTypeFromExtension:[NSString stringWithUTF8String:extension]];
}

extern "C" char* _NativeGallery_GetImageProperties( const char* path )
{
	return [UNativeGallery getImageProperties:[NSString stringWithUTF8String:path]];
}

extern "C" char* _NativeGallery_GetVideoProperties( const char* path )
{
	return [UNativeGallery getVideoProperties:[NSString stringWithUTF8String:path]];
}

extern "C" char* _NativeGallery_GetVideoThumbnail( const char* path, const char* thumbnailSavePath, int maxSize, double captureTimeInSeconds )
{
	return [UNativeGallery getVideoThumbnail:[NSString stringWithUTF8String:path] savePath:[NSString stringWithUTF8String:thumbnailSavePath] maximumSize:maxSize captureTime:captureTimeInSeconds];
}

extern "C" char* _NativeGallery_LoadImageAtPath( const char* path, const char* temporaryFilePath, int maxSize )
{
	return [UNativeGallery loadImageAtPath:[NSString stringWithUTF8String:path] tempFilePath:[NSString stringWithUTF8String:temporaryFilePath] maximumSize:maxSize];
}