using System;
using System.Globalization;
using System.IO;
using UnityEngine;
using Object = UnityEngine.Object;
#if UNITY_ANDROID || UNITY_IOS
using NativeGalleryNamespace;
#endif

public static class NativeGallery
{
	public struct ImageProperties
	{
		public readonly int width;
		public readonly int height;
		public readonly string mimeType;
		public readonly ImageOrientation orientation;

		public ImageProperties( int width, int height, string mimeType, ImageOrientation orientation )
		{
			this.width = width;
			this.height = height;
			this.mimeType = mimeType;
			this.orientation = orientation;
		}
	}

	public struct VideoProperties
	{
		public readonly int width;
		public readonly int height;
		public readonly long duration;
		public readonly float rotation;

		public VideoProperties( int width, int height, long duration, float rotation )
		{
			this.width = width;
			this.height = height;
			this.duration = duration;
			this.rotation = rotation;
		}
	}

	public enum PermissionType { Read = 0, Write = 1 };
	public enum Permission { Denied = 0, Granted = 1, ShouldAsk = 2 };

	[Flags]
	public enum MediaType { Image = 1, Video = 2, Audio = 4 };

	// EXIF orientation: http://sylvana.net/jpegcrop/exif_orientation.html (indices are reordered)
	public enum ImageOrientation { Unknown = -1, Normal = 0, Rotate90 = 1, Rotate180 = 2, Rotate270 = 3, FlipHorizontal = 4, Transpose = 5, FlipVertical = 6, Transverse = 7 };

	public delegate void MediaSaveCallback( bool success, string path );
	public delegate void MediaPickCallback( string path );
	public delegate void MediaPickMultipleCallback( string[] paths );

	#region Platform Specific Elements
#if !UNITY_EDITOR && UNITY_ANDROID
	private static AndroidJavaClass m_ajc = null;
	private static AndroidJavaClass AJC
	{
		get
		{
			if( m_ajc == null )
				m_ajc = new AndroidJavaClass( "com.yasirkula.unity.NativeGallery" );

			return m_ajc;
		}
	}

	private static AndroidJavaObject m_context = null;
	private static AndroidJavaObject Context
	{
		get
		{
			if( m_context == null )
			{
				using( AndroidJavaObject unityClass = new AndroidJavaClass( "com.unity3d.player.UnityPlayer" ) )
				{
					m_context = unityClass.GetStatic<AndroidJavaObject>( "currentActivity" );
				}
			}

			return m_context;
		}
	}
#elif !UNITY_EDITOR && UNITY_IOS
	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern int _NativeGallery_CheckPermission( int readPermission, int permissionFreeMode );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern int _NativeGallery_RequestPermission( int readPermission, int permissionFreeMode );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern void _NativeGallery_ShowLimitedLibraryPicker();

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern int _NativeGallery_CanOpenSettings();

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern void _NativeGallery_OpenSettings();

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern int _NativeGallery_CanPickMultipleMedia();

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern int _NativeGallery_GetMediaTypeFromExtension( string extension );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern void _NativeGallery_ImageWriteToAlbum( string path, string album, int permissionFreeMode );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern void _NativeGallery_VideoWriteToAlbum( string path, string album, int permissionFreeMode );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern void _NativeGallery_PickMedia( string mediaSavePath, int mediaType, int permissionFreeMode, int selectionLimit );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern string _NativeGallery_GetImageProperties( string path );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern string _NativeGallery_GetVideoProperties( string path );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern string _NativeGallery_GetVideoThumbnail( string path, string thumbnailSavePath, int maxSize, double captureTimeInSeconds );

	[System.Runtime.InteropServices.DllImport( "__Internal" )]
	private static extern string _NativeGallery_LoadImageAtPath( string path, string temporaryFilePath, int maxSize );
#endif

#if !UNITY_EDITOR && ( UNITY_ANDROID || UNITY_IOS )
	private static string m_temporaryImagePath = null;
	private static string TemporaryImagePath
	{
		get
		{
			if( m_temporaryImagePath == null )
			{
				m_temporaryImagePath = Path.Combine( Application.temporaryCachePath, "tmpImg" );
				Directory.CreateDirectory( Application.temporaryCachePath );
			}

			return m_temporaryImagePath;
		}
	}

	private static string m_selectedMediaPath = null;
	private static string SelectedMediaPath
	{
		get
		{
			if( m_selectedMediaPath == null )
			{
				m_selectedMediaPath = Path.Combine( Application.temporaryCachePath, "pickedMedia" );
				Directory.CreateDirectory( Application.temporaryCachePath );
			}

			return m_selectedMediaPath;
		}
	}
#endif
	#endregion

	#region Runtime Permissions
	// PermissionFreeMode was initially planned to be a toggleable setting on iOS but it has its own issues when set to false, so its value is forced to true.
	// These issues are:
	// - Presented permission dialog will have a "Select Photos" option on iOS 14+ but clicking it will freeze and eventually crash the app (I'm guessing that
	//   this is caused by how permissions are handled synchronously in NativeGallery)
	// - While saving images/videos to Photos, iOS 14+ users would see the "Select Photos" option (which is irrelevant in this context, hence confusing) and
	//   the user must grant full Photos access in order to save the image/video to a custom album
	// The only downside of having PermissionFreeMode = true is that, on iOS 14+, images/videos will be saved to the default Photos album rather than the
	// provided custom album
	private const bool PermissionFreeMode = true;

	public static Permission CheckPermission( PermissionType permissionType )
	{
#if !UNITY_EDITOR && UNITY_ANDROID
		Permission result = (Permission) AJC.CallStatic<int>( "CheckPermission", Context, permissionType == PermissionType.Read );
		if( result == Permission.Denied && (Permission) PlayerPrefs.GetInt( "NativeGalleryPermission", (int) Permission.ShouldAsk ) == Permission.ShouldAsk )
			result = Permission.ShouldAsk;

		return result;
#elif !UNITY_EDITOR && UNITY_IOS
		// result == 3: LimitedAccess permission on iOS, no need to handle it when PermissionFreeMode is set to true
		int result = _NativeGallery_CheckPermission( permissionType == PermissionType.Read ? 1 : 0, PermissionFreeMode ? 1 : 0 );
		return result == 3 ? Permission.Granted : (Permission) result;
#else
		return Permission.Granted;
#endif
	}

	public static Permission RequestPermission( PermissionType permissionType )
	{
#if !UNITY_EDITOR && UNITY_ANDROID
		object threadLock = new object();
		lock( threadLock )
		{
			NGPermissionCallbackAndroid nativeCallback = new NGPermissionCallbackAndroid( threadLock );

			AJC.CallStatic( "RequestPermission", Context, nativeCallback, permissionType == PermissionType.Read, PlayerPrefs.GetInt( "NativeGalleryPermission", (int) Permission.ShouldAsk ) );

			if( nativeCallback.Result == -1 )
				System.Threading.Monitor.Wait( threadLock );

			if( (Permission) nativeCallback.Result != Permission.ShouldAsk && PlayerPrefs.GetInt( "NativeGalleryPermission", -1 ) != nativeCallback.Result )
			{
				PlayerPrefs.SetInt( "NativeGalleryPermission", nativeCallback.Result );
				PlayerPrefs.Save();
			}

			return (Permission) nativeCallback.Result;
		}
#elif !UNITY_EDITOR && UNITY_IOS
		// result == 3: LimitedAccess permission on iOS, no need to handle it when PermissionFreeMode is set to true
		int result = _NativeGallery_RequestPermission( permissionType == PermissionType.Read ? 1 : 0, PermissionFreeMode ? 1 : 0 );
		return result == 3 ? Permission.Granted : (Permission) result;
#else
		return Permission.Granted;
#endif
	}

	// This function isn't needed when PermissionFreeMode is set to true
	private static void TryExtendLimitedAccessPermission()
	{
		if( IsMediaPickerBusy() )
			return;

#if !UNITY_EDITOR && UNITY_IOS
		_NativeGallery_ShowLimitedLibraryPicker();
#endif
	}

	public static bool CanOpenSettings()
	{
#if !UNITY_EDITOR && UNITY_IOS
		return _NativeGallery_CanOpenSettings() == 1;
#else
		return true;
#endif
	}

	public static void OpenSettings()
	{
#if !UNITY_EDITOR && UNITY_ANDROID
		AJC.CallStatic( "OpenSettings", Context );
#elif !UNITY_EDITOR && UNITY_IOS
		_NativeGallery_OpenSettings();
#endif
	}
	#endregion

	#region Save Functions
	public static Permission SaveImageToGallery( byte[] mediaBytes, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( mediaBytes, album, filename, MediaType.Image, callback );
	}

	public static Permission SaveImageToGallery( string existingMediaPath, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( existingMediaPath, album, filename, MediaType.Image, callback );
	}

	public static Permission SaveImageToGallery( Texture2D image, string album, string filename, MediaSaveCallback callback = null )
	{
		if( image == null )
			throw new ArgumentException( "Parameter 'image' is null!" );

		if( filename.EndsWith( ".jpeg", StringComparison.OrdinalIgnoreCase ) || filename.EndsWith( ".jpg", StringComparison.OrdinalIgnoreCase ) )
			return SaveToGallery( GetTextureBytes( image, true ), album, filename, MediaType.Image, callback );
		else if( filename.EndsWith( ".png", StringComparison.OrdinalIgnoreCase ) )
			return SaveToGallery( GetTextureBytes( image, false ), album, filename, MediaType.Image, callback );
		else
			return SaveToGallery( GetTextureBytes( image, false ), album, filename + ".png", MediaType.Image, callback );
	}

	public static Permission SaveVideoToGallery( byte[] mediaBytes, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( mediaBytes, album, filename, MediaType.Video, callback );
	}

	public static Permission SaveVideoToGallery( string existingMediaPath, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( existingMediaPath, album, filename, MediaType.Video, callback );
	}

	private static Permission SaveAudioToGallery( byte[] mediaBytes, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( mediaBytes, album, filename, MediaType.Audio, callback );
	}

	private static Permission SaveAudioToGallery( string existingMediaPath, string album, string filename, MediaSaveCallback callback = null )
	{
		return SaveToGallery( existingMediaPath, album, filename, MediaType.Audio, callback );
	}
	#endregion

	#region Load Functions
	public static bool CanSelectMultipleFilesFromGallery()
	{
#if !UNITY_EDITOR && UNITY_ANDROID
		return AJC.CallStatic<bool>( "CanSelectMultipleMedia" );
#elif !UNITY_EDITOR && UNITY_IOS
		return _NativeGallery_CanPickMultipleMedia() == 1;
#else
		return false;
#endif
	}

	public static bool CanSelectMultipleMediaTypesFromGallery()
	{
#if UNITY_EDITOR
		return true;
#elif UNITY_ANDROID
		return AJC.CallStatic<bool>( "CanSelectMultipleMediaTypes" );
#elif UNITY_IOS
		return true;
#else
		return false;
#endif
	}

	public static Permission GetImageFromGallery( MediaPickCallback callback, string title = "", string mime = "image/*" )
	{
		return GetMediaFromGallery( callback, MediaType.Image, mime, title );
	}

	public static Permission GetVideoFromGallery( MediaPickCallback callback, string title = "", string mime = "video/*" )
	{
		return GetMediaFromGallery( callback, MediaType.Video, mime, title );
	}

	public static Permission GetAudioFromGallery( MediaPickCallback callback, string title = "", string mime = "audio/*" )
	{
		return GetMediaFromGallery( callback, MediaType.Audio, mime, title );
	}

	public static Permission GetMixedMediaFromGallery( MediaPickCallback callback, MediaType mediaTypes, string title = "" )
	{
		return GetMediaFromGallery( callback, mediaTypes, "*/*", title );
	}

	public static Permission GetImagesFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "image/*" )
	{
		return GetMultipleMediaFromGallery( callback, MediaType.Image, mime, title );
	}

	public static Permission GetVideosFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "video/*" )
	{
		return GetMultipleMediaFromGallery( callback, MediaType.Video, mime, title );
	}

	public static Permission GetAudiosFromGallery( MediaPickMultipleCallback callback, string title = "", string mime = "audio/*" )
	{
		return GetMultipleMediaFromGallery( callback, MediaType.Audio, mime, title );
	}

	public static Permission GetMixedMediasFromGallery( MediaPickMultipleCallback callback, MediaType mediaTypes, string title = "" )
	{
		return GetMultipleMediaFromGallery( callback, mediaTypes, "*/*", title );
	}

	public static bool IsMediaPickerBusy()
	{
#if !UNITY_EDITOR && UNITY_IOS
		return NGMediaReceiveCallbackiOS.IsBusy;
#else
		return false;
#endif
	}

	public static MediaType GetMediaTypeOfFile( string path )
	{
		if( string.IsNullOrEmpty( path ) )
			return (MediaType) 0;

		string extension = Path.GetExtension( path );
		if( string.IsNullOrEmpty( extension ) )
			return (MediaType) 0;

		if( extension[0] == '.' )
		{
			if( extension.Length == 1 )
				return (MediaType) 0;

			extension = extension.Substring( 1 );
		}

#if UNITY_EDITOR
		extension = extension.ToLowerInvariant();
		if( extension == "png" || extension == "jpg" || extension == "jpeg" || extension == "gif" || extension == "bmp" || extension == "tiff" )
			return MediaType.Image;
		else if( extension == "mp4" || extension == "mov" || extension == "wav" || extension == "avi" )
			return MediaType.Video;
		else if( extension == "mp3" || extension == "aac" || extension == "flac" )
			return MediaType.Audio;

		return (MediaType) 0;
#elif UNITY_ANDROID
		string mime = AJC.CallStatic<string>( "GetMimeTypeFromExtension", extension.ToLowerInvariant() );
		if( string.IsNullOrEmpty( mime ) )
			return (MediaType) 0;
		else if( mime.StartsWith( "image/" ) )
			return MediaType.Image;
		else if( mime.StartsWith( "video/" ) )
			return MediaType.Video;
		else if( mime.StartsWith( "audio/" ) )
			return MediaType.Audio;
		else
			return (MediaType) 0;
#elif UNITY_IOS
		return (MediaType) _NativeGallery_GetMediaTypeFromExtension( extension.ToLowerInvariant() );
#else
		return (MediaType) 0;
#endif
	}
	#endregion

	#region Internal Functions
	private static Permission SaveToGallery( byte[] mediaBytes, string album, string filename, MediaType mediaType, MediaSaveCallback callback )
	{
		Permission result = RequestPermission( PermissionType.Write );
		if( result == Permission.Granted )
		{
			if( mediaBytes == null || mediaBytes.Length == 0 )
				throw new ArgumentException( "Parameter 'mediaBytes' is null or empty!" );

			if( album == null || album.Length == 0 )
				throw new ArgumentException( "Parameter 'album' is null or empty!" );

			if( filename == null || filename.Length == 0 )
				throw new ArgumentException( "Parameter 'filename' is null or empty!" );

			if( string.IsNullOrEmpty( Path.GetExtension( filename ) ) )
				Debug.LogWarning( "'filename' doesn't have an extension, this might result in unexpected behaviour!" );

			string path = GetTemporarySavePath( filename );
#if UNITY_EDITOR
			Debug.Log( "SaveToGallery called successfully in the Editor" );
#else
			File.WriteAllBytes( path, mediaBytes );
#endif

			SaveToGalleryInternal( path, album, mediaType, callback );
		}

		return result;
	}

	private static Permission SaveToGallery( string existingMediaPath, string album, string filename, MediaType mediaType, MediaSaveCallback callback )
	{
		Permission result = RequestPermission( PermissionType.Write );
		if( result == Permission.Granted )
		{
			if( !File.Exists( existingMediaPath ) )
				throw new FileNotFoundException( "File not found at " + existingMediaPath );

			if( album == null || album.Length == 0 )
				throw new ArgumentException( "Parameter 'album' is null or empty!" );

			if( filename == null || filename.Length == 0 )
				throw new ArgumentException( "Parameter 'filename' is null or empty!" );

			if( string.IsNullOrEmpty( Path.GetExtension( filename ) ) )
			{
				string originalExtension = Path.GetExtension( existingMediaPath );
				if( string.IsNullOrEmpty( originalExtension ) )
					Debug.LogWarning( "'filename' doesn't have an extension, this might result in unexpected behaviour!" );
				else
					filename += originalExtension;
			}

			string path = GetTemporarySavePath( filename );
#if UNITY_EDITOR
			Debug.Log( "SaveToGallery called successfully in the Editor" );
#else
			File.Copy( existingMediaPath, path, true );
#endif

			SaveToGalleryInternal( path, album, mediaType, callback );
		}

		return result;
	}

	private static void SaveToGalleryInternal( string path, string album, MediaType mediaType, MediaSaveCallback callback )
	{
#if !UNITY_EDITOR && UNITY_ANDROID
		string savePath = AJC.CallStatic<string>( "SaveMedia", Context, (int) mediaType, path, album );

		File.Delete( path );

		if( callback != null )
			callback( !string.IsNullOrEmpty( savePath ), savePath );
#elif !UNITY_EDITOR && UNITY_IOS
		if( mediaType == MediaType.Audio )
		{
			Debug.LogError( "Saving audio files is not supported on iOS" );

			if( callback != null )
				callback( false, null );

			return;
		}

		Debug.Log( "Saving to Pictures: " + Path.GetFileName( path ) );

		NGMediaSaveCallbackiOS.Initialize( callback );
		if( mediaType == MediaType.Image )
			_NativeGallery_ImageWriteToAlbum( path, album, PermissionFreeMode ? 1 : 0 );
		else if( mediaType == MediaType.Video )
			_NativeGallery_VideoWriteToAlbum( path, album, PermissionFreeMode ? 1 : 0 );
#else
		if( callback != null )
			callback( true, null );
#endif
	}

	private static string GetTemporarySavePath( string filename )
	{
		string saveDir = Path.Combine( Application.persistentDataPath, "NGallery" );
		Directory.CreateDirectory( saveDir );

#if !UNITY_EDITOR && UNITY_IOS
		// Ensure a unique temporary filename on iOS:
		// iOS internally copies images/videos to Photos directory of the system,
		// but the process is async. The redundant file is deleted by objective-c code
		// automatically after the media is saved but while it is being saved, the file
		// should NOT be overwritten. Therefore, always ensure a unique filename on iOS
		string path = Path.Combine( saveDir, filename );
		if( File.Exists( path ) )
		{
			int fileIndex = 0;
			string filenameWithoutExtension = Path.GetFileNameWithoutExtension( filename );
			string extension = Path.GetExtension( filename );

			do
			{
				path = Path.Combine( saveDir, string.Concat( filenameWithoutExtension, ++fileIndex, extension ) );
			} while( File.Exists( path ) );
		}

		return path;
#else
		return Path.Combine( saveDir, filename );
#endif
	}

	private static Permission GetMediaFromGallery( MediaPickCallback callback, MediaType mediaType, string mime, string title )
	{
		Permission result = RequestPermission( PermissionType.Read );
		if( result == Permission.Granted && !IsMediaPickerBusy() )
		{
#if UNITY_EDITOR
			System.Collections.Generic.List<string> editorFilters = new System.Collections.Generic.List<string>( 4 );

			if( ( mediaType & MediaType.Image ) == MediaType.Image )
			{
				editorFilters.Add( "Image files" );
				editorFilters.Add( "png,jpg,jpeg" );
			}

			if( ( mediaType & MediaType.Video ) == MediaType.Video )
			{
				editorFilters.Add( "Video files" );
				editorFilters.Add( "mp4,mov,wav,avi" );
			}

			if( ( mediaType & MediaType.Audio ) == MediaType.Audio )
			{
				editorFilters.Add( "Audio files" );
				editorFilters.Add( "mp3,aac,flac" );
			}

			editorFilters.Add( "All files" );
			editorFilters.Add( "*" );

			string pickedFile = UnityEditor.EditorUtility.OpenFilePanelWithFilters( "Select file", "", editorFilters.ToArray() );

			if( callback != null )
				callback( pickedFile != "" ? pickedFile : null );
#elif UNITY_ANDROID
			AJC.CallStatic( "PickMedia", Context, new NGMediaReceiveCallbackAndroid( callback, null ), (int) mediaType, false, SelectedMediaPath, mime, title );
#elif UNITY_IOS
			if( mediaType == MediaType.Audio )
			{
				Debug.LogError( "Picking audio files is not supported on iOS" );

				if( callback != null ) // Selecting audio files is not supported on iOS
					callback( null );
			}
			else
			{
				NGMediaReceiveCallbackiOS.Initialize( callback, null );
				_NativeGallery_PickMedia( SelectedMediaPath, (int) ( mediaType & ~MediaType.Audio ), PermissionFreeMode ? 1 : 0, 1 );
			}
#else
			if( callback != null )
				callback( null );
#endif
		}

		return result;
	}

	private static Permission GetMultipleMediaFromGallery( MediaPickMultipleCallback callback, MediaType mediaType, string mime, string title )
	{
		Permission result = RequestPermission( PermissionType.Read );
		if( result == Permission.Granted && !IsMediaPickerBusy() )
		{
			if( CanSelectMultipleFilesFromGallery() )
			{
#if !UNITY_EDITOR && UNITY_ANDROID
				AJC.CallStatic( "PickMedia", Context, new NGMediaReceiveCallbackAndroid( null, callback ), (int) mediaType, true, SelectedMediaPath, mime, title );
#elif !UNITY_EDITOR && UNITY_IOS
				if( mediaType == MediaType.Audio )
				{
					Debug.LogError( "Picking audio files is not supported on iOS" );

					if( callback != null ) // Selecting audio files is not supported on iOS
						callback( null );
				}
				else
				{
					NGMediaReceiveCallbackiOS.Initialize( null, callback );
					_NativeGallery_PickMedia( SelectedMediaPath, (int) ( mediaType & ~MediaType.Audio ), PermissionFreeMode ? 1 : 0, 0 );
				}
#else
				if( callback != null )
					callback( null );
#endif
			}
			else if( callback != null )
				callback( null );
		}

		return result;
	}

	private static byte[] GetTextureBytes( Texture2D texture, bool isJpeg )
	{
		try
		{
			return isJpeg ? texture.EncodeToJPG( 100 ) : texture.EncodeToPNG();
		}
		catch( UnityException )
		{
			return GetTextureBytesFromCopy( texture, isJpeg );
		}
		catch( ArgumentException )
		{
			return GetTextureBytesFromCopy( texture, isJpeg );
		}

#pragma warning disable 0162
		return null;
#pragma warning restore 0162
	}

	private static byte[] GetTextureBytesFromCopy( Texture2D texture, bool isJpeg )
	{
		// Texture is marked as non-readable, create a readable copy and save it instead
		Debug.LogWarning( "Saving non-readable textures is slower than saving readable textures" );

		Texture2D sourceTexReadable = null;
		RenderTexture rt = RenderTexture.GetTemporary( texture.width, texture.height );
		RenderTexture activeRT = RenderTexture.active;

		try
		{
			Graphics.Blit( texture, rt );
			RenderTexture.active = rt;

			sourceTexReadable = new Texture2D( texture.width, texture.height, isJpeg ? TextureFormat.RGB24 : TextureFormat.RGBA32, false );
			sourceTexReadable.ReadPixels( new Rect( 0, 0, texture.width, texture.height ), 0, 0, false );
			sourceTexReadable.Apply( false, false );
		}
		catch( Exception e )
		{
			Debug.LogException( e );

			Object.DestroyImmediate( sourceTexReadable );
			return null;
		}
		finally
		{
			RenderTexture.active = activeRT;
			RenderTexture.ReleaseTemporary( rt );
		}

		try
		{
			return isJpeg ? sourceTexReadable.EncodeToJPG( 100 ) : sourceTexReadable.EncodeToPNG();
		}
		catch( Exception e )
		{
			Debug.LogException( e );
			return null;
		}
		finally
		{
			Object.DestroyImmediate( sourceTexReadable );
		}
	}
	#endregion

	#region Utility Functions
	public static Texture2D LoadImageAtPath( string imagePath, int maxSize = -1, bool markTextureNonReadable = true,
		bool generateMipmaps = true, bool linearColorSpace = false )
	{
		if( string.IsNullOrEmpty( imagePath ) )
			throw new ArgumentException( "Parameter 'imagePath' is null or empty!" );

		if( !File.Exists( imagePath ) )
			throw new FileNotFoundException( "File not found at " + imagePath );

		if( maxSize <= 0 )
			maxSize = SystemInfo.maxTextureSize;

#if !UNITY_EDITOR && UNITY_ANDROID
		string loadPath = AJC.CallStatic<string>( "LoadImageAtPath", Context, imagePath, TemporaryImagePath, maxSize );
#elif !UNITY_EDITOR && UNITY_IOS
		string loadPath = _NativeGallery_LoadImageAtPath( imagePath, TemporaryImagePath, maxSize );
#else
		string loadPath = imagePath;
#endif

		string extension = Path.GetExtension( imagePath ).ToLowerInvariant();
		TextureFormat format = ( extension == ".jpg" || extension == ".jpeg" ) ? TextureFormat.RGB24 : TextureFormat.RGBA32;

		Texture2D result = new Texture2D( 2, 2, format, generateMipmaps, linearColorSpace );

		try
		{
			if( !result.LoadImage( File.ReadAllBytes( loadPath ), markTextureNonReadable ) )
			{
				Object.DestroyImmediate( result );
				return null;
			}
		}
		catch( Exception e )
		{
			Debug.LogException( e );

			Object.DestroyImmediate( result );
			return null;
		}
		finally
		{
			if( loadPath != imagePath )
			{
				try
				{
					File.Delete( loadPath );
				}
				catch { }
			}
		}

		return result;
	}

	public static Texture2D GetVideoThumbnail( string videoPath, int maxSize = -1, double captureTimeInSeconds = -1.0, bool markTextureNonReadable = true )
	{
		if( maxSize <= 0 )
			maxSize = SystemInfo.maxTextureSize;

#if !UNITY_EDITOR && UNITY_ANDROID
		string thumbnailPath = AJC.CallStatic<string>( "GetVideoThumbnail", Context, videoPath, TemporaryImagePath + ".png", false, maxSize, captureTimeInSeconds );
#elif !UNITY_EDITOR && UNITY_IOS
		string thumbnailPath = _NativeGallery_GetVideoThumbnail( videoPath, TemporaryImagePath + ".png", maxSize, captureTimeInSeconds );
#else
		string thumbnailPath = null;
#endif

		if( !string.IsNullOrEmpty( thumbnailPath ) )
			return LoadImageAtPath( thumbnailPath, maxSize, markTextureNonReadable );
		else
			return null;
	}

	public static ImageProperties GetImageProperties( string imagePath )
	{
		if( !File.Exists( imagePath ) )
			throw new FileNotFoundException( "File not found at " + imagePath );

#if !UNITY_EDITOR && UNITY_ANDROID
		string value = AJC.CallStatic<string>( "GetImageProperties", Context, imagePath );
#elif !UNITY_EDITOR && UNITY_IOS
		string value = _NativeGallery_GetImageProperties( imagePath );
#else
		string value = null;
#endif

		int width = 0, height = 0;
		string mimeType = null;
		ImageOrientation orientation = ImageOrientation.Unknown;
		if( !string.IsNullOrEmpty( value ) )
		{
			string[] properties = value.Split( '>' );
			if( properties != null && properties.Length >= 4 )
			{
				if( !int.TryParse( properties[0].Trim(), out width ) )
					width = 0;
				if( !int.TryParse( properties[1].Trim(), out height ) )
					height = 0;

				mimeType = properties[2].Trim();
				if( mimeType.Length == 0 )
				{
					string extension = Path.GetExtension( imagePath ).ToLowerInvariant();
					if( extension == ".png" )
						mimeType = "image/png";
					else if( extension == ".jpg" || extension == ".jpeg" )
						mimeType = "image/jpeg";
					else if( extension == ".gif" )
						mimeType = "image/gif";
					else if( extension == ".bmp" )
						mimeType = "image/bmp";
					else
						mimeType = null;
				}

				int orientationInt;
				if( int.TryParse( properties[3].Trim(), out orientationInt ) )
					orientation = (ImageOrientation) orientationInt;
			}
		}

		return new ImageProperties( width, height, mimeType, orientation );
	}

	public static VideoProperties GetVideoProperties( string videoPath )
	{
		if( !File.Exists( videoPath ) )
			throw new FileNotFoundException( "File not found at " + videoPath );

#if !UNITY_EDITOR && UNITY_ANDROID
		string value = AJC.CallStatic<string>( "GetVideoProperties", Context, videoPath );
#elif !UNITY_EDITOR && UNITY_IOS
		string value = _NativeGallery_GetVideoProperties( videoPath );
#else
		string value = null;
#endif

		int width = 0, height = 0;
		long duration = 0L;
		float rotation = 0f;
		if( !string.IsNullOrEmpty( value ) )
		{
			string[] properties = value.Split( '>' );
			if( properties != null && properties.Length >= 4 )
			{
				if( !int.TryParse( properties[0].Trim(), out width ) )
					width = 0;
				if( !int.TryParse( properties[1].Trim(), out height ) )
					height = 0;
				if( !long.TryParse( properties[2].Trim(), out duration ) )
					duration = 0L;
				if( !float.TryParse( properties[3].Trim().Replace( ',', '.' ), NumberStyles.Float, CultureInfo.InvariantCulture, out rotation ) )
					rotation = 0f;
			}
		}

		if( rotation == -90f )
			rotation = 270f;

		return new VideoProperties( width, height, duration, rotation );
	}
	#endregion
}