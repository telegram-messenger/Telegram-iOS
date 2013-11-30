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


@interface TLError : NSObject <TLObject>

@property (nonatomic) int32_t code;

@end

@interface TLError$error : TLError

@property (nonatomic, retain) NSString *text;

@end

@interface TLError$richError : TLError

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *debug;
@property (nonatomic, retain) NSString *request_params;

@end

