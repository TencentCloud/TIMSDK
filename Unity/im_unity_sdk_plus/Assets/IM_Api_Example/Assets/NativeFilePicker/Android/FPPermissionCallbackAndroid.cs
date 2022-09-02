#if UNITY_EDITOR || UNITY_ANDROID
using System.Threading;
using UnityEngine;

namespace NativeFilePickerNamespace
{
	public class FPPermissionCallbackAndroid : AndroidJavaProxy
	{
		private object threadLock;
		public int Result { get; private set; }

		public FPPermissionCallbackAndroid( object threadLock ) : base( "com.yasirkula.unity.NativeFilePickerPermissionReceiver" )
		{
			Result = -1;
			this.threadLock = threadLock;
		}

		public void OnPermissionResult( int result )
		{
			Result = result;

			lock( threadLock )
			{
				Monitor.Pulse( threadLock );
			}
		}
	}
}
#endif