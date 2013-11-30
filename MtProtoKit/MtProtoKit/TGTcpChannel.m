#import "TGTcpChannel.h"

#import <libkern/OSAtomic.h>

static volatile int32_t nextChannelToken = 1;
int TGGenerateChannelToken()
{
    int result = OSAtomicIncrement32(&nextChannelToken);
    return result;
}