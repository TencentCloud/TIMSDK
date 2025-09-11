// Copyright 1998-2017 Epic Games, Inc. All Rights Reserved.

#include "TIMPush.h"

#define LOCTEXT_NAMESPACE "FTIMPush"

void TIMPush::StartupModule() {
	// This code will execute after your module is loaded into memory; the exact timing is specified in the .uplugin file per-module

    UE_LOG(LogInit, Warning, TEXT("StartupModule()"));
}

void TIMPush::ShutdownModule() {
	// This function may be called during shutdown to clean up your module.  For modules that support dynamic reloading,
	// we call this function before unloading the module.
    UE_LOG(LogInit, Warning, TEXT("ShutdownModule()"));
}

#undef LOCTEXT_NAMESPACE
	
IMPLEMENT_MODULE(TIMPush, TIMPush)
