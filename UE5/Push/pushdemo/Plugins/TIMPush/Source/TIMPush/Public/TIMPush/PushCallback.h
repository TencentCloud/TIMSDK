#ifndef PUSH_CALLBACK_H__
#define PUSH_CALLBACK_H__

#include "CoreMinimal.h"

#include <functional>

class PushBaseCallback {
public:
    PushBaseCallback() = default;
    virtual ~PushBaseCallback() = default;
    PushBaseCallback(const PushBaseCallback&) = delete;
    PushBaseCallback& operator=(const PushBaseCallback&) = delete;
    virtual bool IsValueCallback() const { return false; }
};

class PushCallback : public PushBaseCallback {
public:
    ~PushCallback() override {}

    virtual void OnSuccess() = 0;
    virtual void OnError(int error_code, const FString &error_message) = 0;
};

template <class T>
class PushValueCallback : public PushBaseCallback {
public:
    ~PushValueCallback() override {};

    virtual void OnSuccess(const T &value) = 0;
    virtual void OnError(int error_code, const FString &error_message) = 0;
    bool IsValueCallback() const override { return true; }
};

#endif // PUSH_CALLBACK_H__
