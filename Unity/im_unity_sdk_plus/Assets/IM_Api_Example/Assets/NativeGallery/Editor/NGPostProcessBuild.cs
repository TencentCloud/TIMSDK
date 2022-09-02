using System.IO;
using UnityEditor;
using UnityEngine;
#if UNITY_IOS
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
#endif

namespace NativeGalleryNamespace
{
	[System.Serializable]
	public class Settings
	{
		private const string SAVE_PATH = "ProjectSettings/NativeGallery.json";

		public bool AutomatedSetup = true;
#if !UNITY_2018_1_OR_NEWER
		public bool MinimumiOSTarget8OrAbove = false;
#endif
		public string PhotoLibraryUsageDescription = "The app requires access to Photos to interact with it.";
		public string PhotoLibraryAdditionsUsageDescription = "The app requires access to Photos to save media to it.";
		public bool DontAskLimitedPhotosPermissionAutomaticallyOnIos14 = true; // See: https://mackuba.eu/2020/07/07/photo-library-changes-ios-14/

		private static Settings m_instance = null;
		public static Settings Instance
		{
			get
			{
				if( m_instance == null )
				{
					try
					{
						if( File.Exists( SAVE_PATH ) )
							m_instance = JsonUtility.FromJson<Settings>( File.ReadAllText( SAVE_PATH ) );
						else
							m_instance = new Settings();
					}
					catch( System.Exception e )
					{
						Debug.LogException( e );
						m_instance = new Settings();
					}
				}

				return m_instance;
			}
		}

		public void Save()
		{
			File.WriteAllText( SAVE_PATH, JsonUtility.ToJson( this, true ) );
		}

#if UNITY_2018_3_OR_NEWER
		[SettingsProvider]
		public static SettingsProvider CreatePreferencesGUI()
		{
			return new SettingsProvider( "Project/yasirkula/Native Gallery", SettingsScope.Project )
			{
				guiHandler = ( searchContext ) => PreferencesGUI(),
				keywords = new System.Collections.Generic.HashSet<string>() { "Native", "Gallery", "Android", "iOS" }
			};
		}
#endif

#if !UNITY_2018_3_OR_NEWER
		[PreferenceItem( "Native Gallery" )]
#endif
		public static void PreferencesGUI()
		{
			EditorGUI.BeginChangeCheck();

			Instance.AutomatedSetup = EditorGUILayout.Toggle( "Automated Setup", Instance.AutomatedSetup );

			EditorGUI.BeginDisabledGroup( !Instance.AutomatedSetup );
#if !UNITY_2018_1_OR_NEWER
			Instance.MinimumiOSTarget8OrAbove = EditorGUILayout.Toggle( "Deployment Target Is 8.0 Or Above", Instance.MinimumiOSTarget8OrAbove );
#endif
			Instance.PhotoLibraryUsageDescription = EditorGUILayout.DelayedTextField( "Photo Library Usage Description", Instance.PhotoLibraryUsageDescription );
			Instance.PhotoLibraryAdditionsUsageDescription = EditorGUILayout.DelayedTextField( "Photo Library Additions Usage Description", Instance.PhotoLibraryAdditionsUsageDescription );
			Instance.DontAskLimitedPhotosPermissionAutomaticallyOnIos14 = EditorGUILayout.Toggle( new GUIContent( "Don't Ask Limited Photos Permission Automatically", "See: https://mackuba.eu/2020/07/07/photo-library-changes-ios-14/. It's recommended to keep this setting enabled" ), Instance.DontAskLimitedPhotosPermissionAutomaticallyOnIos14 );
			EditorGUI.EndDisabledGroup();

			if( EditorGUI.EndChangeCheck() )
				Instance.Save();
		}
	}

	public class NGPostProcessBuild
	{
#if UNITY_IOS
		[PostProcessBuild( 1 )]
		public static void OnPostprocessBuild( BuildTarget target, string buildPath )
		{
			if( !Settings.Instance.AutomatedSetup )
				return;

			if( target == BuildTarget.iOS )
			{
				string pbxProjectPath = PBXProject.GetPBXProjectPath( buildPath );
				string plistPath = Path.Combine( buildPath, "Info.plist" );

				PBXProject pbxProject = new PBXProject();
				pbxProject.ReadFromFile( pbxProjectPath );

#if UNITY_2019_3_OR_NEWER
				string targetGUID = pbxProject.GetUnityFrameworkTargetGuid();
#else
				string targetGUID = pbxProject.TargetGuidByName( PBXProject.GetUnityTargetName() );
#endif

				// Minimum supported iOS version on Unity 2018.1 and later is 8.0
#if !UNITY_2018_1_OR_NEWER
				if( !Settings.Instance.MinimumiOSTarget8OrAbove )
				{
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-weak_framework Photos" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-weak_framework PhotosUI" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework AssetsLibrary" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework MobileCoreServices" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework ImageIO" );
				}
				else
#endif
				{
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-weak_framework PhotosUI" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework Photos" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework MobileCoreServices" );
					pbxProject.AddBuildProperty( targetGUID, "OTHER_LDFLAGS", "-framework ImageIO" );
				}

				pbxProject.RemoveFrameworkFromProject( targetGUID, "Photos.framework" );

				File.WriteAllText( pbxProjectPath, pbxProject.WriteToString() );

				PlistDocument plist = new PlistDocument();
				plist.ReadFromString( File.ReadAllText( plistPath ) );

				PlistElementDict rootDict = plist.root;
				rootDict.SetString( "NSPhotoLibraryUsageDescription", Settings.Instance.PhotoLibraryUsageDescription );
				rootDict.SetString( "NSPhotoLibraryAddUsageDescription", Settings.Instance.PhotoLibraryAdditionsUsageDescription );
				if( Settings.Instance.DontAskLimitedPhotosPermissionAutomaticallyOnIos14 )
					rootDict.SetBoolean( "PHPhotoLibraryPreventAutomaticLimitedAccessAlert", true );

				File.WriteAllText( plistPath, plist.WriteToString() );
			}
		}
#endif
	}
}