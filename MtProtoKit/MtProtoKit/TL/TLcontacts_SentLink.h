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

@class TLmessages_Message;
@class TLcontacts_Link;

@interface TLcontacts_SentLink : NSObject <TLObject>

@property (nonatomic, retain) TLmessages_Message *message;
@property (nonatomic, retain) TLcontacts_Link *link;

@end

@interface TLcontacts_SentLink$contacts_sentLink : TLcontacts_SentLink


@end

