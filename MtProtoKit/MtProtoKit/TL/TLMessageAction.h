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

@class TLPhoto;

@interface TLMessageAction : NSObject <TLObject>


@end

@interface TLMessageAction$messageActionEmpty : TLMessageAction


@end

@interface TLMessageAction$messageActionChatCreate : TLMessageAction

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLMessageAction$messageActionChatEditTitle : TLMessageAction

@property (nonatomic, retain) NSString *title;

@end

@interface TLMessageAction$messageActionChatEditPhoto : TLMessageAction

@property (nonatomic, retain) TLPhoto *photo;

@end

@interface TLMessageAction$messageActionChatDeletePhoto : TLMessageAction


@end

@interface TLMessageAction$messageActionChatAddUser : TLMessageAction

@property (nonatomic) int32_t user_id;

@end

@interface TLMessageAction$messageActionChatDeleteUser : TLMessageAction

@property (nonatomic) int32_t user_id;

@end

@interface TLMessageAction$messageActionSentRequest : TLMessageAction

@property (nonatomic) bool has_phone;

@end

@interface TLMessageAction$messageActionAcceptRequest : TLMessageAction


@end

@interface TLMessageAction$messageActionGeoChatCreate : TLMessageAction

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;

@end

@interface TLMessageAction$messageActionGeoChatCheckin : TLMessageAction


@end

