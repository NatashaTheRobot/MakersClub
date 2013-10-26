//
//  GithubLoginViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "GithubLoginViewController.h"
#import <AFNetworking.h>

@interface GithubLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSURLConnection *tokenRequestConnection;

@end

@implementation GithubLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.data = [NSMutableData data];
    
    self.webView.delegate = self;
    [self.webView loadRequest:[self githubURLRequest]];
    
}

#pragma mark - Web View Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    NSString *codeString = [NSString stringWithFormat:@"%@?code=", GITHUB_CALLBACK_URL];
    if([responseURL hasPrefix:codeString])
    {
//        NSString *code = [responseURL substringFromIndex:codeString.length];
//        
//        NSDictionary *parameters =  @{@"code" : code,
//                                      @"client_id" : GITHUB_CLIENT_ID,
//                                      @"redirect_uri" : GITHUB_CALLBACK_URL,
//                                      @"client_secret" : GITHUB_CLIENT_SECRET};
//        
//        // Request the token
//        AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
//        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
//        requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset]];
//        [requestManager POST:@"https://github.com/login/oauth/access_token"
//                  parameters:parameters
//                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                     
//                         
//                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                      
//                  }];
        
        
        NSInteger strLen = [codeString length];
        NSString *code = [responseURL substringFromIndex:strLen];
        
        //Request the token.
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
        
        NSDictionary *paramDict = @{@"code" : code,
                                    @"client_id" : GITHUB_CLIENT_ID,
                                    @"redirect_uri" : GITHUB_CALLBACK_URL,
                                    @"client_secret" : GITHUB_CLIENT_SECRET};

        NSMutableArray *parts = [NSMutableArray array];
        for (NSString *key in paramDict)
        {
            id value = [paramDict objectForKey: key];
            NSString *part = [NSString stringWithFormat: @"%@=%@", [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                              [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            [parts addObject: part];
        }
        NSString *paramString = [parts componentsJoinedByString: @"&"];
        
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        [request setHTTPMethod:@"POST"];
        [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.tokenRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [self.tokenRequestConnection start];
        
        return NO;
    }
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
    if(jsonData && [NSJSONSerialization isValidJSONObject:jsonData])
    {
        
        NSString *accesstoken = [jsonData objectForKey:@"access_token"];
        if(accesstoken)
        {
            [self didAuth:accesstoken];
            return;
        }
    }
    
    [self didAuth:nil];
}

-(void) didAuth:(NSString*)token
{
    if(!token)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to request token."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //As a test, we'll request the authenticated user data.
    NSString *gistCreateURLString = [NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:gistCreateURLString]];
    
    NSOperationQueue *theQ = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:theQ
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *err;
                               id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                               if(!err && !error && val && [NSJSONSerialization isValidJSONObject:val])
                               {
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       NSString *username = [val objectForKey:@"name"];
                                       
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User request complete" message:[NSString stringWithFormat:@"User info retrieved for: %@", username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView show];
                                   });
                               }
                           }];
    
}

#pragma mark - Private Methods

- (NSURLRequest *)githubURLRequest
{
    NSString *scope = @"user:email";
    
    NSString *requestURL = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@", GITHUB_CLIENT_ID, GITHUB_CALLBACK_URL, scope];
    
    return [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
}

@end
