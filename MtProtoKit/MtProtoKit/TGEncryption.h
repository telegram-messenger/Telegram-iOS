/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

class MessageKeyData
{
public:
    NSData *aesKey;
    NSData *aesIv;
    
    MessageKeyData()
    {
        aesKey = nil;
        aesIv = nil;
    }
    
    MessageKeyData(const MessageKeyData &other)
    {
        aesKey = other.aesKey;
        aesIv = other.aesIv;
    }
    
    MessageKeyData & operator= (const MessageKeyData &other)
    {
        if (this != &other)
        {
            aesKey = other.aesKey;
            aesIv = other.aesIv;
        }
        
        return *this;
    }
    
    ~MessageKeyData()
    {
        aesKey = nil;
        aesIv = nil;
    }
};

struct TGServerSalt
{
    int validSince;
    int validUntil;
    int64_t value;
};
