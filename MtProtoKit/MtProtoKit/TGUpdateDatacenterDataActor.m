#import "TGUpdateDatacenterDataActor.h"

#import "TGSession.h"

#import "tl/TLMetaScheme.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatacenterContext.h"

@interface TGUpdateDatacenterDataActor ()

@property (nonatomic) int datacenterId;

@end

@implementation TGUpdateDatacenterDataActor

@synthesize datacenterId = _datacenterId;

+ (NSString *)genericPath
{
    return @"/tg/network/updateDatacenterData/@";
}

- (void)execute:(NSDictionary *)options
{
    _datacenterId = [[options objectForKey:@"datacenterId"] intValue];
    
    TLRPChelp_getConfig$help_getConfig *getConfig = [[TLRPChelp_getConfig$help_getConfig alloc] init];
    
    self.cancelToken = [[TGSession instance] performRpc:getConfig completionBlock:^(TLConfig *config, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            NSMutableArray *datacenters = [[NSMutableArray alloc] init];
            for (TLDcOption *datacenterDesc in config.dc_options)
            {
                if (datacenterDesc.n_id == _datacenterId || _datacenterId == TG_ALL_DATACENTERS)
                {
                    TGDatacenterContext *datacenter = [[TGDatacenterContext alloc] init];
                    datacenter.datacenterId = datacenterDesc.n_id;
                    
                    int64_t authSessionId = [[TGSession instance] generateSessionId];
                    int64_t authUploadSessionId = [[TGSession instance] generateSessionId];
                    int64_t authDownloadSessionId = [[TGSession instance] generateSessionId];
                    
                    datacenter.authSessionId = authSessionId;
                    datacenter.authDownloadSessionId = authDownloadSessionId;
                    datacenter.authUploadSessionId = authUploadSessionId;
                    
                    NSMutableArray *addressSet = [[NSMutableArray alloc] init];
                    [addressSet addObject:[[NSDictionary alloc] initWithObjectsAndKeys:datacenterDesc.ip_address, @"address", [[NSNumber alloc] initWithInt:datacenterDesc.port], @"port", nil]];
                    datacenter.addressSet = addressSet;
                    
                    [datacenters addObject:datacenter];
                }
            }
            
            [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:datacenters, @"datacenters", nil]]];
        }
        else
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassEnableUnauthorized];
}

- (void)cancel
{
    [super cancel];
}

@end
