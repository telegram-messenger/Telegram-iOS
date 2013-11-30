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


@interface TLWallPaper : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) int32_t color;

@end

@interface TLWallPaper$wallPaper : TLWallPaper

@property (nonatomic, retain) NSArray *sizes;

@end

@interface TLWallPaper$wallPaperSolid : TLWallPaper

@property (nonatomic) int32_t bg_color;

@end

