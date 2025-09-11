// Copyright 1998-2017 Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Modules/ModuleManager.h"
#include "PushManager.h"
#include "PushListener.h"
#include "PushMessage.h"
#include "PushCallback.h"

class TIMPush : public IModuleInterface
{
public:

	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;
    
private:
	/** Handle to the test dll we will load */
	//void*	ExampleLibraryHandle;
};
