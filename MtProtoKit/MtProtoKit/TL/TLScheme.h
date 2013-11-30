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


@interface TLScheme : NSObject <TLObject>


@end

@interface TLScheme$scheme : TLScheme

@property (nonatomic, retain) NSString *scheme_raw;
@property (nonatomic, retain) NSArray *types;
@property (nonatomic, retain) NSArray *methods;
@property (nonatomic) int32_t version;

@end

@interface TLScheme$schemeNotModified : TLScheme


@end

