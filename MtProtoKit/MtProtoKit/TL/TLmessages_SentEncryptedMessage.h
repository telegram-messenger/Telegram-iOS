/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLEncryptedFile;

@interface TLmessages_SentEncryptedMessage : NSObject <TLObject>

@property (nonatomic) int32_t date;

@end

@interface TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage : TLmessages_SentEncryptedMessage


@end

@interface TLmessages_SentEncryptedMessage$messages_sentEncryptedFile : TLmessages_SentEncryptedMessage

@property (nonatomic, retain) TLEncryptedFile *file;

@end

