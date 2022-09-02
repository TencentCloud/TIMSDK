#if UNITY_EDITOR || UNITY_ANDROID
using UnityEngine;

namespace NativeFilePickerNamespace
{
	public class FPResultCallbackAndroid : AndroidJavaProxy
	{
		private readonly NativeFilePicker.FilePickedCallback pickCallback;
		private readonly NativeFilePicker.MultipleFilesPickedCallback pickCallbackMultiple;
		private readonly NativeFilePicker.FilesExportedCallback exportCallback;

		private readonly FPCallbackHelper callbackHelper;

		public FPResultCallbackAndroid( NativeFilePicker.FilePickedCallback pickCallback, NativeFilePicker.MultipleFilesPickedCallback pickCallbackMultiple, NativeFilePicker.FilesExportedCallback exportCallback ) : base( "com.yasirkula.unity.NativeFilePickerResultReceiver" )
		{
			this.pickCallback = pickCallback;
			this.pickCallbackMultiple = pickCallbackMultiple;
			this.exportCallback = exportCallback;

			callbackHelper = new GameObject( "FPCallbackHelper" ).AddComponent<FPCallbackHelper>();
		}

		public void OnFilePicked( string path )
		{
			callbackHelper.CallOnMainThread( () => FilePickCallback( path ) );
		}

		public void OnMultipleFilesPicked( string paths )
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

			callbackHelper.CallOnMainThread( () => FilePickMultipleCallback( result ) );
		}

		public void OnFilesExported( bool result )
		{
			callbackHelper.CallOnMainThread( () => FileExportCallback( result ) );
		}

		private void FilePickCallback( string path )
		{
			if( string.IsNullOrEmpty( path ) )
				path = null;

			try
			{
				if( pickCallback != null )
					pickCallback( path );
			}
			finally
			{
				Object.Destroy( callbackHelper.gameObject );
			}
		}

		private void FilePickMultipleCallback( string[] paths )
		{
			if( paths != null && paths.Length == 0 )
				paths = null;

			try
			{
				if( pickCallbackMultiple != null )
					pickCallbackMultiple( paths );
			}
			finally
			{
				Object.Destroy( callbackHelper.gameObject );
			}
		}

		private void FileExportCallback( bool result )
		{
			try
			{
				if( exportCallback != null )
					exportCallback( result );
			}
			finally
			{
				Object.Destroy( callbackHelper.gameObject );
			}
		}
	}
}
#endif