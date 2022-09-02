#if UNITY_EDITOR || UNITY_ANDROID
using UnityEngine;

namespace NativeFilePickerNamespace
{
	public class FPCallbackHelper : MonoBehaviour
	{
		private System.Action mainThreadAction = null;

		private void Awake()
		{
			DontDestroyOnLoad( gameObject );
		}

		private void Update()
		{
			if( mainThreadAction != null )
			{
				System.Action temp = mainThreadAction;
				mainThreadAction = null;
				temp();
			}
		}

		public void CallOnMainThread( System.Action function )
		{
			mainThreadAction = function;
		}
	}
}
#endif