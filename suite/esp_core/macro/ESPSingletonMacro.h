//
//  ESPSingletonMacro.h
//  IOT_Espressif_IOS_New
//
//  Created by 白 桦 on 9/29/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#ifndef IOT_Espressif_IOS_New_ESPSingletonMacro_h
#define IOT_Espressif_IOS_New_ESPSingletonMacro_h

#define DEFINE_SINGLETON_FOR_HEADER(className,prefixName)\
\
+ (prefixName##className *)shared##className;

// ARC
#if __has_feature(objc_arc)
    #define DEFINE_SINGLETON_FOR_CLASS(className,prefixName)\
    \
    + (prefixName##className *) shared##className\
    {\
        static prefixName##className *instance = nil;\
        static dispatch_once_t predicate;\
        dispatch_once(&predicate, ^{\
            instance = [[prefixName##className alloc]init];\
        });\
        return instance;\
    }\
    \
    + (id) allocWithZone:(struct _NSZone *)zone\
    {\
        static id _id = nil;\
        static dispatch_once_t predicate;\
        dispatch_once(&predicate, ^{\
            _id = [super allocWithZone:zone];\
        });\
        return _id;\
    }\

// non-ARC
#else
    #define DEFINE_SINGLETON_FOR_CLASS(className,prefixName)\
    \
    + (prefixName##className *) shared##className\
    {\
        static prefixName##className *instance = nil;\
        @synchronized(self)\
        {\
            if(instance == nil)\
            {\
                instance= [[super allocWithZone:NULL] init];\
            }\
        }\
        return instance;\
    }\
    \
    + (id) allocWithZone:(struct _NSZone *)zone\
    {\
        return [[self sharedManager] retain];\
    }\
    \
    - (id) copyWithZone:(NSZone *)zone\
    {\
        return self;\
    }\
    \
    - (id) retain\
    {\
        return self;\
    }\
    \
    - (unsigned)retainCount\
    {\
        return UINT_MAX;\
    }\
    \
    - (oneway void)release\
    {\
    \
    }\
    \
    - (id)autorelease\
    {\
        return self;\
    }\

#endif

#endif