//
//  Utils.m
//  Dashboard test
//
//  Created by Silviu Pop on 6/20/12.
//  Copyright (c) 2012 Whatevra. All rights reserved.
//



#import "NGUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSString(helpers)

- (NSString *)stringByRemovingSuffix:(NSString *)suffix {
    NSRange suffixRange = [self rangeOfString:suffix];
    
    if (suffixRange.location != NSNotFound) {
        return [self substringToIndex:suffixRange.location];
    }
    return nil;
}

+ (NSString *)random {
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [randomString appendFormat:@"%C", c];
    }
    return randomString;
}

- (NSString *) encodeString:(NSString *) s {
    const char *cStr = [s UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [ret appendFormat:@"%02x", result[i]];
    }       
    return [NSString stringWithString:ret];
}  

- (NSString *)simpleHash {
//    NSUInteger hash = [self hash];
    return [self encodeString:self];//[NSString stringWithFormat:@"%0.12U", hash];
}

- (BOOL)containsString:(NSString *)substring {
    NSRange suffixRange = [self rangeOfString:substring];
    
    if (suffixRange.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (BOOL)containsStringCaseInsensitive:(NSString *)substring {
    return [[self lowercaseString] containsString:[substring lowercaseString]];
}

- (BOOL)booleanValue {
    if ([self containsString:@"true"]) {
        return YES;
    }
    if ([self containsString:@"false"]) {
        return NO;
    }
    return [self boolValue];
}

@end

@implementation NSArray(lambda)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//map
- (NSMutableArray *)mapArrayUsingBlock:(simpleLambda)lamdba {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSObject *object in self) {
        [ret addObject:lamdba(object)];
    }
    
    return ret;
}

- (NSMutableArray *)mapArrayUsingSelector:(SEL)selector {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSObject *object in self) {
        [ret addObject:[object performSelector:selector]];
    }
    
    return ret;
}

//filter
- (NSMutableArray *)filterArrayUsingBlock:(boolLambda)lambda {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSObject *object in self) {
        if (lambda(object)) {        
            [ret addObject:object];
        }
    }
    
    return ret;    
}

- (NSMutableArray *)mapArrayUsingBlockWithIndex:(simpleIndexedLambda)lamdba {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
    
    int index = 0;
    for (NSObject *object in self) {
        if (lamdba(object,index)) {
            [ret addObject:object];
        }
        index++;
    }
    
    return ret;
}

- (void)each:(voidLambda)lambda {
    for (NSObject *object in self) {
        lambda(object);
    }
}

- (void)eachWithIndex:(voidIndexedLambda)lambda {
    int index = 0;
    for (NSObject *object in self) {
        lambda(object,index);
        index++;
    }
}


//reduce
- (id)reduceWithBlock:(doubleLambda)lambda andBase:(id)base {
    id ret = base;
    
    for (id o in self) {
        ret = lambda(ret, o);
    }
    
    return ret;
}

- (id)reduceWithBlock:(doubleLambda)lambda {
    return [self reduceWithBlock:lambda andBase:@0];
}

+ (NSArray *)arrayFromPlistNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:path];
}

- (id)map:(simpleLambda)lambda reduce:(doubleLambda)reduceLambda {
    return [self map:lambda reduce:reduceLambda withBase:@0];
}

- (id)map:(simpleLambda)lambda reduce:(doubleLambda)reduceLambda withBase:(id)base {
    id result = base;
    for (id object in self) {
        result = reduceLambda(result,lambda(object));
    }
    return result;
}

- (id)first {
    if (self.count > 0) {
        return [self objectAtIndex:0];
    } else {
        return nil;
    }
}

- (id)pluck:(NSString *)string {
    SEL selector = NSSelectorFromString(string);
    NSMutableArray *result = [NSMutableArray array];
    for (id object in self) {
       [result addObject:[object performSelector:selector]];
    }
    return result;
}

- (id)zip:(NSArray *)otherArray andLambda:(doubleLambda)zipLambda {
    NSMutableArray *result = [NSMutableArray array];
    int count = MIN(self.count,otherArray.count);
    for (int index = 0; index < count; ++index) {
        [result addObject:zipLambda(self[index],otherArray[index])];
    }
    return result;
}

#pragma clang diagnostic pop
@end


@implementation NSData (DataUtils)

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)stringInBase64FromData
{
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""] ;
    unsigned char * working = (unsigned char *)[self bytes];
    int srcLen = [self length];
    
    // tackle the source in 3's as conveniently 4 Base64 nibbles fit into 3 bytes
    for (int i=0; i<srcLen; i += 3)
    {
        // for each output nibble
        for (int nib=0; nib<4; nib++)
        {
            // nibble:nib from char:byt
            int byt = (nib == 0)?0:nib-1;
            int ix = (nib+1)*2;
            
            if (i+byt >= srcLen) break;
            
            // extract the top bits of the nibble, if valid
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            
            // extract the bottom bits of the nibble, if valid
            if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
            
            [dest appendFormat:@"%c", base64[curr]];
        }
    }
    
    return dest;
}

@end

@implementation NSString (StringUtils)

- (NSString *)stringInBase64FromString
{
    NSData *theData = [NSData dataWithBytes:[self UTF8String] length:[self length]]; 
    
    return [theData stringInBase64FromData];
}

+ (NSString *)stringWithStrings:(NSString *)firstArg, ... {
    NSMutableString *result = [firstArg mutableCopy];
    va_list args;
    va_start(args, firstArg);
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        [result appendString:arg];
    }
    va_end(args);
    return result;
}

- (NSString *)stringWithStrings:(NSString *)firstArg, ... {
    NSMutableString *result =  [self mutableCopy];
    [result appendString:firstArg];
    va_list args;
    va_start(args, firstArg);
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        [result appendString:arg];
    }
    va_end(args);
    return result;
}

- (NSString *)mimeType {
    CFStringRef pathExtension = (__bridge CFStringRef)self;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
        
    NSString *mimeType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    return mimeType;
}

@end

@implementation NSDictionary (DictionaryUtils)

+ (NSDictionary *)dictionaryFromPlistNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

- (NSArray *)keys {
    return self.allKeys;
}

- (NSArray *)values {
    return self.allValues;
}

@end

@implementation UIColor (ColorUtils)
+ (UIColor *)colorWithRed:(int)red green:(int)green blue:(int)blue {
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0f];
}

+ (UIColor *)colorWithHex:(unsigned int)hexColor {
        
    return [UIColor colorWithRed:(hexColor & 0xff0000) >> 16
                           green:(hexColor & 0x00ff00) >> 8
                            blue:hexColor & 0x0000ff];
}

@end

#pragma mark - Math Functions

float lerp(float x1,float x2,float t) {
    return x1 * (1 - t) + x2 * t;
}

float clamp(float x,float min,float max) {
    return MIN(MAX(x,min),max);
}

#pragma mark - UIButton

@implementation UIButton(Helpers)
- (void)setImageNamed:(NSString *)imageName {
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
}

@end

@implementation UIAlertView(AlertViewUtils)

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (void)showErrorWithMessage:(NSString *)message {
    [self showMessage:message withTitle:@"Error"];
}

+ (void)showSuccessWithMessage:(NSString *)message {
    [self showMessage:message withTitle:@"Success"];
}


@end

@implementation UIApplication(helpers)

+ (NSString *)usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    unsigned int  usedMemory = 0;
    if( kerr == KERN_SUCCESS ) {
        usedMemory = info.resident_size;
    }
    
    return [NSString stringWithFormat:@"%u.%u",usedMemory / (1024 * 1024),usedMemory % (1024 * 1024) / 1024];
}

+ (void)displayMemoryUsage {
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(reportMemoryUsage)
                                   userInfo:nil
                                    repeats:YES];

}

+ (void)reportMemoryUsage {
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    unsigned int  usedMemory = 0;
    if( kerr == KERN_SUCCESS ) {
        usedMemory = info.resident_size;
    }
    
    static UILabel *memoryLabel;
    static UIImageView *imageView;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    if (memoryLabel == nil) {
        memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 400, 30)];
        memoryLabel.textColor = [UIColor redColor];
        memoryLabel.backgroundColor = [UIColor clearColor];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 5, 18 * 1.4, 18 * 1.4)];
        
        [window addSubview:memoryLabel];
        [window addSubview:imageView];
    }
    
    if (usedMemory > 1024 * 1024 * 100) {
        imageView.image = [UIImage imageNamed:@"4"];
    } else if (usedMemory > 1024 * 1024 * 75) {
        imageView.image = [UIImage imageNamed:@"3"];
    } else if (usedMemory > 1024 * 1024 * 50) {
        imageView.image = [UIImage imageNamed:@"2"];
    } else {
        imageView.image = [UIImage imageNamed:@"1"];
    }
    
    memoryLabel.text = [NSString stringWithFormat:@"Memory Used: %u.%u MB",usedMemory / (1024 * 1024),usedMemory % (1024 * 1024) / 1024];
    
    [window bringSubviewToFront:memoryLabel];
    [window bringSubviewToFront:imageView];
}

@end

@implementation UINib(UNibUtils)
+ (UIView *)instantiateNibNamed:(NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    return [nib instantiateWithOwner:nil options:nil][0];
}
@end