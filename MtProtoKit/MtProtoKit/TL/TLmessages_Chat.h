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

@class TLChat;

@interface TLmessages_Chat : NSObject <TLObject>

@property (nonatomic, retain) TLChat *chat;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLmessages_Chat$messages_chat : TLmessages_Chat


@end

