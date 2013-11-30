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

@class TLInputEncryptedChat;

@interface TLRPCmessages_readEncryptedHistory : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) int32_t max_date;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory : TLRPCmessages_readEncryptedHistory


@end

