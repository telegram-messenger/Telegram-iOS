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

@class TLMessageMedia;
@class TLMessageAction;

@interface TLGeoChatMessage : NSObject <TLObject>

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t n_id;

@end

@interface TLGeoChatMessage$geoChatMessageEmpty : TLGeoChatMessage


@end

@interface TLGeoChatMessage$geoChatMessage : TLGeoChatMessage

@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;

@end

@interface TLGeoChatMessage$geoChatMessageService : TLGeoChatMessage

@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) TLMessageAction *action;

@end

