#import "TGTcpTransport.h"

#import "TGTcpChannel.h"
#import "TGGCDTcpChannel.h"
#import "TGSimpleTcpChannel.h"

#pragma mark -

@interface TGTcpTransport () <TGTcpChannelListener>

@property (nonatomic, strong) NSString *hostAddress;
@property (nonatomic) int hostPort;

@property (nonatomic) int timeout;

@property (nonatomic, strong) id<TGTcpChannel> currentChannel;
@property (nonatomic) int nextChannelId;

@end

@implementation TGTcpTransport

@synthesize hostAddress = _hostAddress;
@synthesize hostPort = _hostPort;

@synthesize transportHandler = _transportHandler;
@synthesize transportRequestClass = _transportRequestClass;

@synthesize timeout = _timeout;

@synthesize datacenter = _datacenter;

@synthesize currentChannel = _currentChannel;
@synthesize nextChannelId = _nextChannelId;

- (id)init
{
    self = [super init];
    if (self != nil)
    {   
        _timeout = -1;
    }
    return self;
}

- (void)dealloc
{
    [_currentChannel setListener:nil];
    
    [self suspendTransport];
}

- (void)setDatacenter:(TGDatacenterContext *)datacenter
{
    if (_datacenter != datacenter)
    {
        _datacenter = datacenter;
        
        NSDictionary *addressDesc = [[datacenter addressSet] objectAtIndex:0];
        
        _hostAddress = [addressDesc objectForKey:@"address"];
        _hostPort = [[addressDesc objectForKey:@"port"] intValue];
        
        if (_currentChannel != nil)
        {
            [_currentChannel setHostAddress:_hostAddress];
            [_currentChannel setHostPort:_hostPort];
        }
        
        [self forceTransportReconnection];
    }
}

- (void)setTransportTimeout:(NSTimeInterval)timeout
{
    _timeout = (int)timeout;
    
    [_currentChannel setTimeout:(int)timeout];
}

- (void)suspendTransport
{
    [_currentChannel setListener:nil];
    [_currentChannel disconnect];
    _currentChannel = nil;
}

- (void)forceTransportReconnection
{
    if (_currentChannel != nil)
    {
        [self suspendTransport];
        [self resumeTransport];
    }
}

- (void)updateConnectedChannels
{
    id<TGTransportHandler> transportHandler = _transportHandler;
    
    if (_currentChannel != nil && [_currentChannel isConnected])
        [transportHandler transportHasConnectedChannels:self];
    else
        [transportHandler transportHasDisconnectedAllChannels:self];
}

- (void)channelClosed:(id<TGTcpChannel>)channel
{
    [channel setListener:nil];
    
    TGLog(@"===== Channel #%d closed", [channel channelId]);
    
    [self updateConnectedChannels];
}

- (void)channelConnected:(id<TGTcpChannel>)__unused channel
{
    [self updateConnectedChannels];
}

- (void)channelDisconnected:(id<TGTcpChannel>)__unused channel
{
    [self updateConnectedChannels];
}

- (void)resumeTransport
{
    if (_currentChannel == nil)
        [self createChannel];
    else
        [_currentChannel connect];
}

- (void)clearFailCountAndConnect
{
    if (_currentChannel != nil)
        [_currentChannel clearFailCountAndConnect];
}

- (id<TGTcpChannel>)createChannel
{
    id<TGTcpChannel> channel = [[TGGCDTcpChannel alloc] init];
    //id<TGTcpChannel> channel = [[TGSimpleTcpChannel alloc] init];
    
    [channel setHostAddress:_hostAddress];
    [channel setHostPort:_hostPort];
    [channel setTimeout:_timeout];
    [channel setChannelId:_nextChannelId++];
    [channel setListener:self];
    _currentChannel = channel;
    
    TGLog(@"===== Spawn channel #%d", channel.channelId);
    
    [channel connect];
    
    return channel;
}

- (void)dataReceivedFromChannel:(NSData *)data
{
    id<TGTransportHandler> transportHandler = _transportHandler;
    
    [transportHandler transport:self receivedData:data];
}

- (int64_t)decodeMessageIdFromPartialData:(NSData *)data
{
    id<TGTransportHandler> transportHandler = _transportHandler;
    
    return [transportHandler transport:self needsToDecodeMessageIdFromPartialData:data];
}

- (void)requestProgressUpdated:(int64_t)requestMessageId length:(int)length progress:(float)progress
{
    id<TGTransportHandler> transportHandler = _transportHandler;
    
    [transportHandler transport:self updatedRequestProgress:requestMessageId length:length progress:progress];
}

- (void)quiackAckReceived:(int)quickAck
{
    id<TGTransportHandler> transportHandler = _transportHandler;
    
    [transportHandler transportReceivedQuickAck:quickAck];
}

- (void)sendData:(NSData *)data reportAck:(bool)reportAck startResponseTimeout:(bool)startResponseTimeout
{
    [self.currentChannel sendData:data reportAck:reportAck startResponseTimeout:startResponseTimeout];
}

- (id<TGTcpChannel>)currentChannel
{
    if (_currentChannel != nil)
        return _currentChannel;
    
    [self createChannel];
    return _currentChannel;
}

- (int)connectedChannelToken
{
    if (_currentChannel != nil && _currentChannel.isConnected)
        return [_currentChannel channelToken];
    
    return 0;
}

- (void)sendPingData:(NSData *)pingData
{
    if (_currentChannel != nil)
        [_currentChannel sendData:pingData reportAck:false startResponseTimeout:true];
}

@end
