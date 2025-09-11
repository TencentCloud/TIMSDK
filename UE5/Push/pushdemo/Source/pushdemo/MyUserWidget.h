// Fill out your copyright notice in the Description page of Project Settings.

#pragma once
#include "MyCallback.h"

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "MyUserWidget.generated.h"


/**
 * 
 */
UCLASS()
class PUSHDEMO_API UMyUserWidget : public UUserWidget
{
	GENERATED_BODY()
    
    UFUNCTION(BlueprintCallable)
    void CallRegisterPush();
    
    UFUNCTION(BlueprintCallable)
    void CallUnregisterPush();
    
    UFUNCTION(BlueprintCallable)
    void CallGetRegistrationID();
    
    UFUNCTION(BlueprintCallable)
    void CallSetRegistrationID();
    
    UFUNCTION(BlueprintCallable)
    void CallAddPushListener();
    
    UFUNCTION(BlueprintCallable)
    void CallRemovePushListener();
    
    UFUNCTION(BlueprintCallable)
    void CallForceUseFCMPushChannel();
    
    UFUNCTION(BlueprintCallable)
    void CallDisablePostNotificationInForeground();

    UFUNCTION(BlueprintCallable)
    void CallExperimentalAPI();
};
