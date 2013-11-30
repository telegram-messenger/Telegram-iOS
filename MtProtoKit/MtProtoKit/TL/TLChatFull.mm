#import "TLChatFull.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChatParticipants.h"
#import "TLPhoto.h"
#import "TLPeerNotifySettings.h"

@implementation TLChatFull

@synthesize n_id = _n_id;
@synthesize participants = _participants;
@synthesize chat_photo = _chat_photo;
@synthesize notify_settings = _notify_settings;

- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLChatFull$chatFull : TLChatFull


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x630e61be;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2be8331c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChatFull$chatFull *object = [[TLChatFull$chatFull alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.participants = metaObject->getObject(0xe0e25c28);
    object.chat_photo = metaObject->getObject(0x824caff);
    object.notify_settings = metaObject->getObject(0xfa59265);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.participants;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe0e25c28, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.chat_photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x824caff, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xfa59265, value));
    }
}


@end

