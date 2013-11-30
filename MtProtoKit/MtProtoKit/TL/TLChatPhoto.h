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

@class TLFileLocation;

@interface TLChatPhoto : NSObject <TLObject>


@end

@interface TLChatPhoto$chatPhotoEmpty : TLChatPhoto


@end

@interface TLChatPhoto$chatPhoto : TLChatPhoto

@property (nonatomic, retain) TLFileLocation *photo_small;
@property (nonatomic, retain) TLFileLocation *photo_big;

@end

