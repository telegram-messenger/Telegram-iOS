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

@class TLUser;
@class TLcontacts_Link;
@class TLPhoto;
@class TLPeerNotifySettings;

@interface TLUserFull : NSObject <TLObject>

@property (nonatomic, retain) TLUser *user;
@property (nonatomic, retain) TLcontacts_Link *link;
@property (nonatomic, retain) TLPhoto *profile_photo;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;
@property (nonatomic) bool blocked;
@property (nonatomic, retain) NSString *real_first_name;
@property (nonatomic, retain) NSString *real_last_name;

@end

@interface TLUserFull$userFull : TLUserFull


@end

