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

@class TLcontacts_MyLink;
@class TLcontacts_ForeignLink;
@class TLUser;

@interface TLcontacts_Link : NSObject <TLObject>

@property (nonatomic, retain) TLcontacts_MyLink *my_link;
@property (nonatomic, retain) TLcontacts_ForeignLink *foreign_link;
@property (nonatomic, retain) TLUser *user;

@end

@interface TLcontacts_Link$contacts_link : TLcontacts_Link


@end

