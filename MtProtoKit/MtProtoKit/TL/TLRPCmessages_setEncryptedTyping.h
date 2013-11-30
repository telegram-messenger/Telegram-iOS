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

@interface TLRPCmessages_setEncryptedTyping : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) bool typing;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping : TLRPCmessages_setEncryptedTyping


@end

