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


@interface TLmessages_Dialogs : NSObject <TLObject>

@property (nonatomic, retain) NSArray *dialogs;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLmessages_Dialogs$messages_dialogs : TLmessages_Dialogs


@end

@interface TLmessages_Dialogs$messages_dialogsSlice : TLmessages_Dialogs

@property (nonatomic) int32_t count;

@end

