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

@class TLMessage;

@interface TLmessages_StatedMessage : NSObject <TLObject>

@property (nonatomic, retain) TLMessage *message;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t seq;

@end

@interface TLmessages_StatedMessage$messages_statedMessage : TLmessages_StatedMessage


@end

@interface TLmessages_StatedMessage$messages_statedMessageLink : TLmessages_StatedMessage

@property (nonatomic, retain) NSArray *links;

@end

