#ifndef PUSH_MESSAGE_H__
#define PUSH_MESSAGE_H__

#include "CoreMinimal.h"

class PushMessage {
public:
    PushMessage() = default;
    PushMessage(const FString& inTitle, const FString& inDesc, const FString& inExt, const FString& inMessageID)
        : title_(inTitle),
          desc_(inDesc),
          ext_(inExt),
          messageID_(inMessageID) {}
    ~PushMessage() {}

    void SetTitle(const FString& inTitle) { title_ = inTitle; }
    FString GetTitle() const { return title_; }
    
    void SetDesc(const FString& inDesc) { desc_ = inDesc; }
    FString GetDesc() const { return desc_; }
    
    void SetExt(const FString& inExt) { ext_ = inExt; }
    FString GetExt() const { return ext_; }
    
    void SetMessageID(const FString& inMessageID) { messageID_ = inMessageID; }
    FString GetMessageID() const { return messageID_; }
    
private:
    FString title_;
    FString desc_;
    FString ext_;
    FString messageID_;
};

#endif // PUSH_MESSAGE_H__
