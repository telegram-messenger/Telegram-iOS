#import "TGTcpWorker.h"

#import "TGTimer.h"

#import "ActionStage.h"
#import "TGSession.h"

#ifdef DEBUG
static int downloadWorkerCount = 0;
static int uploadWorkerCount = 0;
#endif

@interface TGTcpWorker () <TGTransportHandler>

@property (nonatomic, strong) TGTimer *timeoutTimer;

@end

@implementation TGTcpWorker

@synthesize workerHandler = _workerHandler;

@synthesize transport = _transport;

@synthesize requestClasses = _requestClasses;
@synthesize datacenter = _datacenter;

@synthesize isBusy = _isBusy;
@synthesize currentRequestTokens = _currentRequestTokens;
@synthesize mergingEnabled = _mergingEnabled;

@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithRequestClasses:(int)requestClasses datacenter:(TGDatacenterContext *)datacenter
{
    self = [super init];
    if (self != nil)
    {
        _requestClasses = requestClasses;
        _datacenter = datacenter;
        
        _currentRequestTokens = [[NSMutableSet alloc] init];
        
#ifdef DEBUG
        if (_requestClasses & TGRequestClassUploadMedia)
        {
            uploadWorkerCount++;
            TGLog(@"## %d upload workers (++)", uploadWorkerCount, requestClasses);
        }
        else if (_requestClasses & TGRequestClassDownloadMedia)
        {
            downloadWorkerCount++;
            TGLog(@"## %d download workers (++)", downloadWorkerCount, requestClasses);
        }
#endif
        
        _transport = [[TGTcpTransport alloc] init];
        [_transport setDatacenter:_datacenter];
        [_transport setTransportTimeout:8];
        [_transport setTransportHandler:self];
    }
    return self;
}

- (void)dealloc
{
    if (_requestClasses & TGRequestClassUploadMedia)
    {
#ifdef DEBUG
        uploadWorkerCount--;
        TGLog(@"## %d upload workers (--)", uploadWorkerCount);
#endif
    }
    else if (_requestClasses & TGRequestClassDownloadMedia)
    {
#ifdef DEBUG
        downloadWorkerCount--;
        TGLog(@"## %d download workers (--)", downloadWorkerCount);
#endif
    }
    
    [_transport setTransportHandler:nil];
    [_transport suspendTransport];
}

#pragma mark -

- (void)sendData:(NSData *)data
{
    [_transport sendData:data reportAck:false startResponseTimeout:false];
}

- (void)setIsBusy:(bool)isBusy
{
    if (isBusy != _isBusy)
    {
        _isBusy = isBusy;
        
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        
        if (!isBusy)
        {
            _timeoutTimer = [[TGTimer alloc] initWithTimeout:20.0 repeat:false completion:^
            {
                id<TGTcpWorkerHandler> workerHandler = _workerHandler;
                
                [workerHandler freeWorkerTimedOut:self];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            [_timeoutTimer start];
        }
    }
}

- (void)addRequestToken:(int)token
{
    [_currentRequestTokens addObject:[[NSNumber alloc] initWithInt:token]];
}

- (void)removeRequestToken:(int)token
{
    [_currentRequestTokens removeObject:[[NSNumber alloc] initWithInt:token]];
}

- (void)prepareForRemoval
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

#pragma mark -

- (void)transport:(id<TGTransport>)transport receivedData:(NSData *)data
{
    id<TGTcpWorkerHandler> workerHandler = _workerHandler;
    
    [workerHandler transport:transport receivedData:data];
}

- (int64_t)transport:(id<TGTransport>)transport needsToDecodeMessageIdFromPartialData:(NSData *)data
{
    id<TGTcpWorkerHandler> workerHandler = _workerHandler;
    
    return [workerHandler transport:transport needsToDecodeMessageIdFromPartialData:data];
}

- (void)transport:(id<TGTransport>)transport updatedRequestProgress:(int64_t)requestMessageId length:(int)length progress:(float)progress
{
    id<TGTcpWorkerHandler> workerHandler = _workerHandler;
    
    [workerHandler transport:transport updatedRequestProgress:requestMessageId length:length progress:progress];
}

- (void)transportHasConnectedChannels:(id<TGTransport>)__unused transport
{
    
}

- (void)transportHasDisconnectedAllChannels:(id<TGTransport>)__unused transport
{
    id<TGTcpWorkerHandler> workerHandler = _workerHandler;
    
    if (_isBusy)
        [workerHandler workerFailed:self];
    else
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        
        [workerHandler freeWorkerTimedOut:self];
    }
}

- (void)transportReceivedQuickAck:(int)__unused quickAckId
{
}

@end
