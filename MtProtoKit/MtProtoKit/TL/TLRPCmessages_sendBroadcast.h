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

@class TLInputMedia;
@class TLmessages_StatedMessages;

@interface TLRPCmessages_sendBroadcast : TLMetaRpc

@property (nonatomic, retain) NSArray *contacts;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLInputMedia *media;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendBroadcast$messages_sendBroadcast : TLRPCmessages_sendBroadcast


@end

