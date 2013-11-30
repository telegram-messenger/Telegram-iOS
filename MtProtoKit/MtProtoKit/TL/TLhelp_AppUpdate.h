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


@interface TLhelp_AppUpdate : NSObject <TLObject>


@end

@interface TLhelp_AppUpdate$help_appUpdate : TLhelp_AppUpdate

@property (nonatomic) int32_t n_id;
@property (nonatomic) bool critical;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *text;

@end

@interface TLhelp_AppUpdate$help_noAppUpdate : TLhelp_AppUpdate


@end

