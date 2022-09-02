#if UNITY_EDITOR || UNITY_IOS
using UnityEngine;

namespace NativeGalleryNamespace
{
	public class NGMediaSaveCallbackiOS : MonoBehaviour
	{
		private static NGMediaSaveCallbackiOS instance;
		private NativeGallery.MediaSaveCallback callback;

		public static void Initialize( NativeGallery.MediaSaveCallback callback )
		{
			if( instance == null )
			{
				instance = new GameObject( "NGMediaSaveCallbackiOS" ).AddComponent<NGMediaSaveCallbackiOS>();
				DontDestroyOnLoad( instance.gameObject );
			}
			else if( instance.callback != null )
				instance.callback( false, null );

			instance.callback = callback;
		}

		public void OnMediaSaveCompleted( string message )
		{
			NativeGallery.MediaSaveCallback _callback = callback;
			callback = null;

			if( _callback != null )
				_callback( true, null );
		}

		public void OnMediaSaveFailed( string error )
		{
			NativeGallery.MediaSaveCallback _callback = callback;
			callback = null;

			if( _callback != null )
				_callback( false, null );
		}
	}
}
#endif