#import "TGFutureSaltsRequestActor.h"

#import "ActionStage.h"

#import "TGSession.h"
#import "TGDatacenterContext.h"

#import "TL/TLMetaScheme.h"
#import "TLFutureSalts.h"

@implementation TGFutureSaltsRequestActor

+ (NSString *)genericPath
{
    return @"/tg/network/requestFutureSalts/@";
}

- (void)execute:(NSDictionary *)__unused options
{
    int position = @"/tg/network/requestFutureSalts/(".length;
    int datacenterId = [[self.path substringWithRange:NSMakeRange(position, self.path.length - 1 - position)] intValue];
    
    if ([[TGSession instance] datacenterWithId:datacenterId] == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    else
    {
        TLRPCget_future_salts$get_future_salts *getFutureSalts = [[TLRPCget_future_salts$get_future_salts alloc] init];
        getFutureSalts.num = 64;
        
        [[TGSession instance] performRpc:getFutureSalts completionBlock:^(TLFutureSalts *futureSalts, __unused int64_t responseTime, TLError *error)
        {
            if (error == nil)
            {
                int currentTime = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + [TGSession instance].timeDifference;
                
                [[[TGSession instance] datacenterWithId:datacenterId] mergeServerSalts:currentTime salts:futureSalts.salts];
                
                [[TGSession instance] storeSession];
            }
            else
            {
                [ActionStageInstance() actionFailed:self.path reason:-1];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator datacenterId:datacenterId];
    }
}

@end
