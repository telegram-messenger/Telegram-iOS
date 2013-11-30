#import "TLUserFull.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUser.h"
#import "TLcontacts_Link.h"
#import "TLPhoto.h"
#import "TLPeerNotifySettings.h"

@implementation TLUserFull

@synthesize user = _user;
@synthesize link = _link;
@synthesize profile_photo = _profile_photo;
@synthesize notify_settings = _notify_settings;
@synthesize blocked = _blocked;
@synthesize real_first_name = _real_first_name;
@synthesize real_last_name = _real_last_name;

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

@implementation TLUserFull$userFull : TLUserFull


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x771095da;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6d7a1c3a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUserFull$userFull *object = [[TLUserFull$userFull alloc] init];
    object.user = metaObject->getObject(0x2275eda7);
    object.link = metaObject->getObject(0xc58224f9);
    object.profile_photo = metaObject->getObject(0xbc78165);
    object.notify_settings = metaObject->getObject(0xfa59265);
    object.blocked = metaObject->getBool(0xb651736f);
    object.real_first_name = metaObject->getString(0x9f3a640a);
    object.real_last_name = metaObject->getString(0x176cbb2b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x2275eda7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.link;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc58224f9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.profile_photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xbc78165, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xfa59265, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.blocked;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb651736f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.real_first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x9f3a640a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.real_last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x176cbb2b, value));
    }
}


@end

