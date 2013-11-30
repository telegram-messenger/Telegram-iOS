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


@interface TLChatParticipants : NSObject <TLObject>

@property (nonatomic) int32_t chat_id;

@end

@interface TLChatParticipants$chatParticipantsForbidden : TLChatParticipants


@end

@interface TLChatParticipants$chatParticipants : TLChatParticipants

@property (nonatomic) int32_t admin_id;
@property (nonatomic, retain) NSArray *participants;
@property (nonatomic) int32_t version;

@end

