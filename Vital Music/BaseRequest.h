//
//  Created by Silviu Pop on 3/12/13.
//  Copyright (c) 2013 Whatevra. All rights reserved.
//

#define SERVER_BASE_URL @"http://vital-music.herokuapp.com/"

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPClient.h>
#import <MBProgressHUD.h>
#import <Foundation/NSJSONSerialization.h>

typedef enum {
    kRequestMethodGET,
    kRequestMethodPOST,
    kRequestMethodPUT,
    kRequestMethodDELETE
} RequestMethod;

@class BaseRequest;

typedef void(^RequestSuccessBlock)(id request, id response);
typedef void(^RequestErrorBlock)(id request, NSError *error);
typedef void(^RequestExceptionBlock)(id request, NSException *exceptionBlock);
@protocol RequestDelegate;

@interface BaseRequest : NSObject

@property (nonatomic, weak) id<RequestDelegate> delegate;
@property BOOL showsProgressIndicator;
@property BOOL hasCustomDisplayErrorMessage;

@property (nonatomic, copy) RequestSuccessBlock success;
@property (nonatomic, copy) RequestErrorBlock error;
@property (nonatomic, copy) RequestExceptionBlock exceptionBlock;
@property (nonatomic, strong) AFHTTPClient *httpClient;

+ (instancetype)request;

- (NSString *)serverBase;
- (NSString *)requestURL;
- (NSDictionary *)params;
- (RequestMethod)requestMethod;
- (id)successData:(id)data;

- (void)runRequest;
- (void)sendRequest:(id)failureBlock successBlock:(id)successBlock path:(NSString *)path;

- (void)setSuccess:(RequestSuccessBlock)success;
- (void)setError:(RequestErrorBlock)error;
- (void)setExceptionBlock:(RequestExceptionBlock)exceptionBlock;
- (void)handleException:(NSException *)exception;
- (BOOL)shouldReturnFromNetworkError:(NSError *)error;
- (void)handleError:(NSError *)error;

@end

@protocol RequestDelegate <NSObject>

- (void)request:(BaseRequest *)request didFinishWithResponse:(id)response;
- (void)request:(BaseRequest *)request didFinishWithError:(NSError *)error;

@optional
- (void)request:(BaseRequest *)request didThrowException:(NSException *)exception;

@end
