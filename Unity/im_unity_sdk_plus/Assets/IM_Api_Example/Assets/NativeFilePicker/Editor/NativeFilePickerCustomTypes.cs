using System.IO;
using UnityEditor;
using UnityEngine;

namespace NativeFilePickerNamespace
{
	[HelpURL( "https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_declare/understand_utis_declare.html" )]
	public class NativeFilePickerCustomTypes : ScriptableObject
	{
		[System.Serializable]
		public class TypeHolder
		{
			[Tooltip( "A unique identifier for the type (UTI) (e.g. com.mycompany.mydata)" )]
			public string identifier;
			[Tooltip( "Description of the type (e.g. Save data for My App)" )]
			public string description;
			[Tooltip( "If this type is owned by your app (i.e. exclusive to your app), set this value to true. If another app generates files of this type and your app is merely importing/modifying them, set this value to false." )]
			public bool isExported;
			[Tooltip( "Which official UTI(s) is this type part of (e.g. public.data for generic types or public.image for image types)\nFull list available at: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html" )]
			public string[] conformsTo;
			[Tooltip( "Extension(s) associated with this type (don't include the period; i.e. use myextension instead of .myextension)" )]
			public string[] extensions;
		}

		private const string INITIAL_SAVE_PATH = "Assets/Plugins/NativeFilePicker/NativeFilePickerCustomTypes.asset";

#pragma warning disable 0649
		[SerializeField]
		private TypeHolder[] customTypes;
#pragma warning restore 0649

		[MenuItem( "Window/NativeFilePicker Custom Types" )]
		private static void InspectCustomTypes()
		{
			Selection.activeObject = GetInstance( true );
		}

		private static NativeFilePickerCustomTypes GetInstance( bool createIfNotExists )
		{
			NativeFilePickerCustomTypes instance = null;
			string[] instances = AssetDatabase.FindAssets( "t:NativeFilePickerCustomTypes" );
			if( instances != null && instances.Length > 0 )
				instance = AssetDatabase.LoadAssetAtPath<NativeFilePickerCustomTypes>( AssetDatabase.GUIDToAssetPath( instances[0] ) );

			if( !instance && createIfNotExists )
			{
				Directory.CreateDirectory( Path.GetDirectoryName( INITIAL_SAVE_PATH ) );

				AssetDatabase.CreateAsset( CreateInstance<NativeFilePickerCustomTypes>(), INITIAL_SAVE_PATH );
				AssetDatabase.SaveAssets();
				instance = AssetDatabase.LoadAssetAtPath<NativeFilePickerCustomTypes>( INITIAL_SAVE_PATH );

				Debug.Log( "Created NativeFilePickerCustomTypes file at " + INITIAL_SAVE_PATH + ". You can move this file around freely.", instance );
			}

			return instance;
		}

		public static TypeHolder[] GetCustomTypes()
		{
			NativeFilePickerCustomTypes instance = GetInstance( false );
			return instance ? instance.customTypes : null;
		}
	}
}