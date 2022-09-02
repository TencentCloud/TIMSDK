#if UNITY_EDITOR || UNITY_IOS
using UnityEngine;

namespace NativeGalleryNamespace
{
	public class NGMediaReceiveCallbackiOS : MonoBehaviour
	{
		private static NGMediaReceiveCallbackiOS instance;

		private NativeGallery.MediaPickCallback callback;
		private NativeGallery.MediaPickMultipleCallback callbackMultiple;

		private float nextBusyCheckTime;

		public static bool IsBusy { get; private set; }

		[System.Runtime.InteropServices.DllImport( "__Internal" )]
		private static extern int _NativeGallery_IsMediaPickerBusy();

		public static void Initialize( NativeGallery.MediaPickCallback callback, NativeGallery.MediaPickMultipleCallback callbackMultiple )
		{
			if( IsBusy )
				return;

			if( instance == null )
			{
				instance = new GameObject( "NGMediaReceiveCallbackiOS" ).AddComponent<NGMediaReceiveCallbackiOS>();
				DontDestroyOnLoad( instance.gameObject );
			}

			instance.callback = callback;
			instance.callbackMultiple = callbackMultiple;

			instance.nextBusyCheckTime = Time.realtimeSinceStartup + 1f;
			IsBusy = true;
		}

		private void Update()
		{
			if( IsBusy )
			{
				if( Time.realtimeSinceStartup >= nextBusyCheckTime )
				{
					nextBusyCheckTime = Time.realtimeSinceStartup + 1f;

					if( _NativeGallery_IsMediaPickerBusy() == 0 )
					{
						IsBusy = false;

						NativeGallery.MediaPickCallback _callback = callback;
						callback = null;

						NativeGallery.MediaPickMultipleCallback _callbackMultiple = callbackMultiple;
						callbackMultiple = null;

						if( _callback != null )
							_callback( null );

						if( _callbackMultiple != null )
							_callbackMultiple( null );
					}
				}
			}
		}

		public void OnMediaReceived( string path )
		{
			IsBusy = false;

			if( string.IsNullOrEmpty( path ) )
				path = null;

			NativeGallery.MediaPickCallback _callback = callback;
			callback = null;

			if( _callback != null )
				_callback( path );
		}

		public void OnMultipleMediaReceived( string paths )
		{
			IsBusy = false;

			string[] _paths = SplitPaths( paths );
			if( _paths != null && _paths.Length == 0 )
				_paths = null;

			NativeGallery.MediaPickMultipleCallback _callbackMultiple = callbackMultiple;
			callbackMultiple = null;

			if( _callbackMultiple != null )
				_callbackMultiple( _paths );
		}

		private string[] SplitPaths( string paths )
		{
			string[] result = null;
			if( !string.IsNullOrEmpty( paths ) )
			{
				string[] pathsSplit = paths.Split( '>' );

				int validPathCount = 0;
				for( int i = 0; i < pathsSplit.Length; i++ )
				{
					if( !string.IsNullOrEmpty( pathsSplit[i] ) )
						validPathCount++;
				}

				if( validPathCount == 0 )
					pathsSplit = new string[0];
				else if( validPathCount != pathsSplit.Length )
				{
					string[] validPaths = new string[validPathCount];
					for( int i = 0, j = 0; i < pathsSplit.Length; i++ )
					{
						if( !string.IsNullOrEmpty( pathsSplit[i] ) )
							validPaths[j++] = pathsSplit[i];
					}

					pathsSplit = validPaths;
				}

				result = pathsSplit;
			}

			return result;
		}
	}
}
#endif