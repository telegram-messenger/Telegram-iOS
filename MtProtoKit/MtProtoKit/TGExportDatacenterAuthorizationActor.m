#import "TGExportDatacenterAuthorizationActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGSession.h"

#import "TGDatacenterContext.h"

#import "TL/TLMetaScheme.h"

@interface TGExportDatacenterAuthorizationActor ()

@property (nonatomic) int retryCount;

@property (nonatomic, strong) TGDatacenterContext *datacenter;
@property (nonatomic, strong) TLauth_ExportedAuthorization *exportedAuthorization;

@end

@implementation TGExportDatacenterAuthorizationActor

@synthesize retryCount = _retryCount;

@synthesize datacenter = _datacenter;
@synthesize exportedAuthorization = _exportedAuthorization;

+ (NSString *)genericPath
{
    return @"/tg/network/exportDatacenterAuthorization/@";
}

- (void)execute:(NSDictionary *)options
{
    _datacenter = [options objectForKey:@"datacenter"];
    if (_datacenter == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    [self beginExport];
}

- (void)beginExport
{
    TLRPCauth_exportAuthorization$auth_exportAuthorization *exportAuthorization = [[TLRPCauth_exportAuthorization$auth_exportAuthorization alloc] init];
    exportAuthorization.dc_id = _datacenter.datacenterId;
    
    self.cancelToken = [[TGSession instance] performRpc:exportAuthorization completionBlock:^(TLauth_ExportedAuthorization *result, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            _exportedAuthorization = result;
            
            [self beginImport];
        }
        else
        {
            _retryCount++;
            if (_retryCount >= 3)
            {
                [ActionStageInstance() actionFailed:self.path reason:-1];
            }
            else
            {
                TGDispatchAfter(_retryCount * 1.5, [ActionStageInstance() globalStageDispatchQueue], ^
                {
                    [self beginExport];
                });
            }
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (void)beginImport
{
    TLRPCauth_importAuthorization$auth_importAuthorization *importAuthorization = [[TLRPCauth_importAuthorization$auth_importAuthorization alloc] init];
    importAuthorization.bytes = _exportedAuthorization.bytes;
    importAuthorization.n_id = _exportedAuthorization.n_id;
    
    self.cancelToken = [[TGSession instance] performRpc:importAuthorization completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
            [resultDict setObject:[[NSNumber alloc] initWithInt:_datacenter.datacenterId] forKey:@"datacenterId"];
            [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:resultDict]];
        }
        else
        {
            _exportedAuthorization = nil;
            
            _retryCount++;
            if (_retryCount >= 3)
                [ActionStageInstance() actionFailed:self.path reason:-1];
            else
            {
                TGDispatchAfter(_retryCount * 1.5, [ActionStageInstance() globalStageDispatchQueue], ^
                {
                    [self beginExport];
                });
            }
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassEnableUnauthorized datacenterId:_datacenter.datacenterId];
}

@end
