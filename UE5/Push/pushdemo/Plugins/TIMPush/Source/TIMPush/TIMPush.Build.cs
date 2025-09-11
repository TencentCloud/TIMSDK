// Copyright 1998-2017 Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.IO;

public class TIMPush : ModuleRules
{
#if WITH_FORWARDED_MODULE_RULES_CTOR
public TIMPush(ReadOnlyTargetRules Target) : base(Target)
#else
public TIMPush(TargetInfo Target)
#endif
	{
	    string PluginPath = ModuleDirectory;
		System.Console.WriteLine("-------------- PluginPath = " + PluginPath);
        string TIMPushThirdPartyDir = Path.GetFullPath(Path.Combine(ModuleDirectory, "../ThirdParty/TIMPushLibrary"));
		System.Console.WriteLine("-------------- TIMPushThirdPartyDir = " + TIMPushThirdPartyDir);
        System.Console.WriteLine("-------------- TIMPushBuildTarget = " + Target.Platform);
		
		PublicIncludePaths.AddRange(
			new string[] {
				Path.Combine(PluginPath, "Public"),
				Path.Combine(PluginPath, "Public/TIMPush"),
				// ... add public include paths required here ...
			}
			);
		
		PrivateIncludePaths.AddRange(
			new string[] {
				Path.Combine(PluginPath, "Private"),
				Path.Combine(PluginPath, "Private/TIMPush/Impl"),
				Path.Combine(PluginPath, "Private/TIMPush/Convert"),
				// ... add other private include paths required here ...
			}
			);
			
		
		PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
				"Projects",
				"TIMPushLibrary"
				// ... add other public dependencies that you statically link with here ...
			}
			);
			
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				// ... add private dependencies that you statically link with here ...	
			}
			);	


		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);

		if (Target.Platform == UnrealTargetPlatform.Android)
        {
            PrivateDependencyModuleNames.AddRange(new string[] { 
				"Core",
                "CoreUObject",
                "Engine",
                "Launch"
			});

            string PluginPathAPL = Utils.MakePathRelativeTo(ModuleDirectory, Target.RelativeEnginePath);
			AdditionalPropertiesForReceipt.Add("AndroidPlugin", Path.Combine(PluginPathAPL, "TIMPush_APL.xml"));
        }
		else if (Target.Platform == UnrealTargetPlatform.IOS)
        {
            PublicAdditionalFrameworks.Add(new Framework("TPush", Path.Combine(TIMPushThirdPartyDir, "iOS", "TPush.embeddedframework.zip"), null, true));
            PublicAdditionalFrameworks.Add(new Framework("PushSDK", Path.Combine(TIMPushThirdPartyDir, "iOS", "PushSDK.embeddedframework.zip"), null, true));
        }
    }
}

