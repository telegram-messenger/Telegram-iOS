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
@class TLEncryptedChat;

@interface TLRPCmessages_acceptEncryption : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic, retain) NSData *g_b;
@property (nonatomic) int64_t key_fingerprint;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_acceptEncryption$messages_acceptEncryption : TLRPCmessages_acceptEncryption


@end

