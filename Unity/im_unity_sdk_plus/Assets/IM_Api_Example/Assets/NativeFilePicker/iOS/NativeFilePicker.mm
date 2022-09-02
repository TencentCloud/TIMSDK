#import <MobileCoreServices/MobileCoreServices.h>

#ifdef UNITY_4_0 || UNITY_5_0
#import "iPhone_View.h"
#else
extern UIViewController* UnityGetGLViewController();
#endif

@interface UNativeFilePicker:NSObject
+ (void)pickFiles:(BOOL)allowMultipleSelection withUTIs:(NSArray<NSString *> *)allowedUTIs;
+ (void)exportFiles:(NSArray<NSURL *> *)paths;
+ (int)canPickMultipleFiles;
+ (int)isFilePickerBusy;
+ (char *)convertExtensionToUTI:(NSString *)extension;
@end

@implementation UNativeFilePicker

static UIDocumentPickerViewController *filePicker;
static BOOL pickingMultipleFiles;
static int filePickerState = 0; // 0 -> none, 1 -> showing, 2 -> finished

+ (void)pickFiles:(BOOL)allowMultipleSelection withUTIs:(NSArray<NSString *> *)allowedUTIs
{
	filePicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:allowedUTIs inMode:UIDocumentPickerModeImport];
	filePicker.delegate = (id) self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
	if( [[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending )
		filePicker.allowsMultipleSelection = allowMultipleSelection;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
	// Show file extensions if possible
	if( [[[UIDevice currentDevice] systemVersion] compare:@"13.0" options:NSNumericSearch] != NSOrderedAscending )
		filePicker.shouldShowFileExtensions = YES;
#endif
	
	pickingMultipleFiles = allowMultipleSelection;
	filePickerState = 1;
	
	[UnityGetGLViewController() presentViewController:filePicker animated:NO completion:^{ filePickerState = 0; }];
}

+ (void)exportFiles:(NSArray<NSURL *> *)paths
{
	if( paths != nil && [paths count] > 0 )
	{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
		if ([paths count] > 1 && [[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending)
			filePicker = [[UIDocumentPickerViewController alloc] initWithURLs:paths inMode:UIDocumentPickerModeExportToService];
		else
#endif
			filePicker = [[UIDocumentPickerViewController alloc] initWithURL:paths[0] inMode:UIDocumentPickerModeExportToService];
		
		filePicker.delegate = (id) self;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
		// Show file extensions if possible
		if( [[[UIDevice currentDevice] systemVersion] compare:@"13.0" options:NSNumericSearch] != NSOrderedAscending )
			filePicker.shouldShowFileExtensions = YES;
#endif
		
		filePickerState = 1;
		[UnityGetGLViewController() presentViewController:filePicker animated:NO completion:^{ filePickerState = 0; }];
	}
}

+ (int)canPickMultipleFiles
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
	if( [[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending )
		return 1;
#endif
	
	return 0;
}

+ (int)isFilePickerBusy
{
	if( filePickerState == 2 )
		return 1;
	
	if( filePicker != nil )
	{
		if( filePickerState == 1 || [filePicker presentingViewController] == UnityGetGLViewController() )
			return 1;
		else
		{
			filePicker = nil;
			return 0;
		}
	}
	else
		return 0;
}

// Credit: https://lists.apple.com/archives/cocoa-dev/2012/Jan/msg00052.html
+ (char *)convertExtensionToUTI:(NSString *)extension
{
	CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, NULL );
	char *result = [self getCString:(__bridge NSString *) fileUTI];
	CFRelease( fileUTI );
	
	return result;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
	[self documentPickerCompleted:controller documents:@[url]];
}
#pragma clang diagnostic pop

+ (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
	[self documentPickerCompleted:controller documents:urls];
}

+ (void)documentPickerCompleted:(UIDocumentPickerViewController *)controller documents:(NSArray<NSURL *> *)urls
{
	filePicker = nil;
	filePickerState = 2;
	
	if( controller.documentPickerMode == UIDocumentPickerModeImport )
	{
		if( !pickingMultipleFiles || [urls count] <= 1 )
		{
			const char* filePath;
			if( [urls count] == 0 )
				filePath = "";
			else
				filePath = [self getCString:[urls[0] path]];
			
			if( pickingMultipleFiles )
				UnitySendMessage( "FPResultCallbackiOS", "OnMultipleFilesPicked", filePath );
			else
				UnitySendMessage( "FPResultCallbackiOS", "OnFilePicked", filePath );
		}
		else
		{
			NSMutableArray<NSString *> *filePaths = [NSMutableArray arrayWithCapacity:[urls count]];
			for( int i = 0; i < [urls count]; i++ )
				[filePaths addObject:[urls[i] path]];
			
			UnitySendMessage( "FPResultCallbackiOS", "OnMultipleFilesPicked", [self getCString:[filePaths componentsJoinedByString:@">"]] );
		}
	}
	else if( controller.documentPickerMode == UIDocumentPickerModeExportToService )
	{
		if( [urls count] > 0 )
			UnitySendMessage( "FPResultCallbackiOS", "OnFilesExported", "1" );
		else
			UnitySendMessage( "FPResultCallbackiOS", "OnFilesExported", "0" );
	}
	
	[controller dismissViewControllerAnimated:NO completion:nil];
}

+ (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
	filePicker = nil;
	UnitySendMessage( "FPResultCallbackiOS", "OnOperationCancelled", "" );
	
	[controller dismissViewControllerAnimated:NO completion:nil];
}

// Credit: https://stackoverflow.com/a/37052118/2373034
+ (char *)getCString:(NSString *)source
{
	if( source == nil )
		source = @"";
	
	const char *sourceUTF8 = [source UTF8String];
	char *result = (char*) malloc( strlen( sourceUTF8 ) + 1 );
	strcpy(result, sourceUTF8);
	
	return result;
}

@end

extern "C" void _NativeFilePicker_PickFile( const char* UTIs[], int UTIsCount )
{
	NSMutableArray<NSString *> *allowedUTIs = [NSMutableArray arrayWithCapacity:UTIsCount];
	for( int i = 0; i < UTIsCount; i++ )
		[allowedUTIs addObject:[NSString stringWithUTF8String:UTIs[i]]];
	
	[UNativeFilePicker pickFiles:NO withUTIs:allowedUTIs];
}

extern "C" void _NativeFilePicker_PickMultipleFiles( const char* UTIs[], int UTIsCount )
{
	NSMutableArray<NSString *> *allowedUTIs = [NSMutableArray arrayWithCapacity:UTIsCount];
	for( int i = 0; i < UTIsCount; i++ )
		[allowedUTIs addObject:[NSString stringWithUTF8String:UTIs[i]]];
	
	[UNativeFilePicker pickFiles:YES withUTIs:allowedUTIs];
}

extern "C" void _NativeFilePicker_ExportFiles( const char* files[], int filesCount )
{
	NSMutableArray<NSURL *> *paths = [NSMutableArray arrayWithCapacity:filesCount];
	for( int i = 0; i < filesCount; i++ )
	{
		NSString *filePath = [NSString stringWithUTF8String:files[i]];
		[paths addObject:[NSURL fileURLWithPath:filePath]];
	}
	
	[UNativeFilePicker exportFiles:paths];
}

extern "C" int _NativeFilePicker_CanPickMultipleFiles()
{
	return [UNativeFilePicker canPickMultipleFiles];
}

extern "C" int _NativeFilePicker_IsFilePickerBusy()
{
	return [UNativeFilePicker isFilePickerBusy];
}

extern "C" char* _NativeFilePicker_ConvertExtensionToUTI( const char* extension )
{
	return [UNativeFilePicker convertExtensionToUTI:[NSString stringWithUTF8String:extension]];
}