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

@class TLDecryptedMessageMedia;
@class TLDecryptedMessageAction;

@interface TLDecryptedMessage : NSObject <TLObject>

@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSData *random_bytes;

@end

@interface TLDecryptedMessage$decryptedMessage : TLDecryptedMessage

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLDecryptedMessageMedia *media;

@end

@interface TLDecryptedMessage$decryptedMessageService : TLDecryptedMessage

@property (nonatomic, retain) TLDecryptedMessageAction *action;

@end

