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

@class TLInputUser;
@class TLEncryptedChat;

@interface TLRPCmessages_requestEncryption : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t random_id;
@property (nonatomic, retain) NSData *g_a;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_requestEncryption$messages_requestEncryption : TLRPCmessages_requestEncryption


@end

