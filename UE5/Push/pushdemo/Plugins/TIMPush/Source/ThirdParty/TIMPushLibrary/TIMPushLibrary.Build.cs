// Fill out your copyright notice in the Description page of Project Settings.

using System.IO;
using UnrealBuildTool;

public class TIMPushLibrary : ModuleRules
{
#if WITH_FORWARDED_MODULE_RULES_CTOR
public TIMPushLibrary(ReadOnlyTargetRules Target) : base(Target)
#else
public TIMPushLibrary(TargetInfo Target)
#endif
	{
		Type = ModuleType.External;
	}
}
