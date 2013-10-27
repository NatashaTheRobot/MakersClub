//
//  GithubAuthWebView.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "GithubAuthWebView.h"
#import "NSDictionary+MCExtensions.h"

@interface GithubAuthWebView () <UIWebViewDelegate>

@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSURLConnection *tokenRequestConnection;

@end

@implementation GithubAuthWebView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.data = [NSMutableData data];
        self.scalesPageToFit = YES;
        self.delegate = self;
        [self loadRequest:[self githubLoginPageURLRequest]];
    }
    return self;
}

#pragma mark - Web View Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    NSString *codeString = [NSString stringWithFormat:@"%@?code=", GITHUB_CALLBACK_URL];
    if([responseURL hasPrefix:codeString])
    {
        NSString *code = [responseURL substringFromIndex:codeString.length];
        
        self.tokenRequestConnection = [[NSURLConnection alloc] initWithRequest:[self tokenURLRequestWithCode:code] delegate:self];
        
        [self.tokenRequestConnection start];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - NSURLConnection delegates

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.data.length = 0;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
    if(jsonData && [NSJSONSerialization isValidJSONObject:jsonData])
    {
        NSString *accessToken = [jsonData objectForKey:@"access_token"];
        if(accessToken)
        {
            [self didAuthWithToken:accessToken];
            return;
        }
    }
    
    [self didAuthWithToken:nil];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

#pragma mark - Private Methods

- (NSURLRequest *)githubLoginPageURLRequest
{
    NSString *scope = @"user:email";
    
    NSString *requestURL = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@", GITHUB_CLIENT_ID, GITHUB_CALLBACK_URL, scope];
    
    return [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
}

- (NSURLRequest *)tokenURLRequestWithCode:(NSString *)code
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    
    NSDictionary *paramDict = @{@"code" : code,
                                @"client_id" : GITHUB_CLIENT_ID,
                                @"redirect_uri" : GITHUB_CALLBACK_URL,
                                @"client_secret" : GITHUB_CLIENT_SECRET};
    
    NSString *paramString = [paramDict urlEncodedString];
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (void)didAuthWithToken:(NSString*)token
{
    if(!token)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to request token."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:sNotificationGithubTokenRetrieved object:token];
}

@end
