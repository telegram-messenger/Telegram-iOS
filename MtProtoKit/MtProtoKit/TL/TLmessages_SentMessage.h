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


@interface TLmessages_SentMessage : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t seq;

@end

@interface TLmessages_SentMessage$messages_sentMessage : TLmessages_SentMessage


@end

@interface TLmessages_SentMessage$messages_sentMessageLink : TLmessages_SentMessage

@property (nonatomic, retain) NSArray *links;

@end

