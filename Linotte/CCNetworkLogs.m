//
//  CCNetworkLogs.m
//  Linotte
//
//  Created by stant on 18/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNetworkLogs.h"

#import <Reachability/Reachability.h>
#import <AFNetworking/AFNetworking.h>

#import "CCAppDelegate.h"

#if defined(DEBUG)
#define kCCNetworkLogsUploadServerUrl @"http://192.168.1.23:4242"
#else
#define kCCNetworkLogsUploadServerUrl @"https://logs.getlinotte.com"
#endif

#define kCCNetworkLogsDirectory @"linotte_logs"
#define kCCNetworkLogsFileName @"network_logs.log"
#define kCCNetworkLogsFileNameToSend @"network_logs_to_send_%@.log"
#define kCCMaxLogsFileSize 1024 * 100
#define kCCMaxLogsFileToSend 10

#define kCCLogFilePurgeInterval 10

@implementation CCNetworkLogs
{
    NSString *_logDirectory;
    NSString *_logFilePath;
    NSFileHandle *_logFile;
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_fileNameDateFormatter;
    
    NSTimer *_timer;
    
    Reachability *_reachability;
    AFHTTPSessionManager *_manager;
    
    BOOL _isSending;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        _isSending = NO;
        
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kCCNetworkLogsUploadServerUrl]];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _logDirectory = [NSString stringWithFormat:@"%@/%@", [appDelegate applicationLibraryDirectory].path, kCCNetworkLogsDirectory];
        _logFilePath = [NSString stringWithFormat:@"%@/%@", _logDirectory, kCCNetworkLogsFileName];
        
        [self openLogFile];
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss'.'SSS"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        _fileNameDateFormatter = [NSDateFormatter new];
        [_fileNameDateFormatter setLocale:[NSLocale currentLocale]];
        [_fileNameDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'HH'-'mm'-'ss'-'SSS"];
        [_fileNameDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        __weak id weakself = self;
        _reachability = [Reachability reachabilityWithHostname:@"google.com"];
        _reachability.reachableBlock = ^(Reachability * reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself startTimer];
            });
        };
        _reachability.unreachableBlock = ^(Reachability * reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself stopTimer];
            });
        };

        [_reachability startNotifier];
    }
    return self;
}

#pragma mark - NSTimer methods

- (void)startTimer
{
    if (_timer)
        return;
    _timer = [NSTimer timerWithTimeInterval:kCCLogFilePurgeInterval target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)timerTick:(NSTimer *)timer
{
    if (_isSending)
        return;
    [self sendFilesToSend];
}

#pragma mark - log file management methods

- (void)openLogFile
{
    if (_logFile != nil)
        return;
    
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:_logDirectory withIntermediateDirectories:YES attributes:nil error:&error];

        if (error)
            NSLog(@"%@", error);
    }
    
    {
        NSError *error = nil;
        NSArray *toSendFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_logDirectory error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        if ([toSendFiles count] > kCCMaxLogsFileToSend) {
            NSLog(@"Cannot open new log file, already too many.");
            return;
        }
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:_logFilePath] == NO)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createFileAtPath:_logFilePath contents:nil attributes:nil];

        if (error)
            NSLog(@"%@", error);
    }

    _logFile = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
    [_logFile seekToEndOfFile];
    
    if ([self currentLogFileSize] == 0)
        [self log:@"log file creation"];
    
    [self setSkipICloudBackupFlag:_logFilePath];
}

- (void)setSkipICloudBackupFlag:(NSString *)filePath
{
    NSError *error = nil;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    BOOL success = [fileUrl setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"%@", error);
    }
}

- (void)moveLogFileToSendFile
{
    [_logFile closeFile];
    _logFile = nil;
    
    NSError *error;
    NSString *dateString = [_fileNameDateFormatter stringFromDate:[NSDate date]];
    NSString *logFileToSendName = [NSString stringWithFormat:kCCNetworkLogsFileNameToSend, dateString];
    NSString *logFileToSendPath = [NSString stringWithFormat:@"%@/%@", _logDirectory, logFileToSendName];
    [[NSFileManager defaultManager] moveItemAtPath:_logFilePath toPath:logFileToSendPath error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
    } else {
        [self setSkipICloudBackupFlag:logFileToSendPath];
    }
    
    [self openLogFile];
}

- (void)sendFilesToSend
{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:_logDirectory error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    NSString *toSendFileName = nil;
    
    for (NSString *file in files) {
        if ([file rangeOfString:@"network_logs_to_send_"].location == 0) {
            toSendFileName = file;
            break;
        }
    }
    
    if (toSendFileName == nil)
        return;
    
    NSString *toSendFilePath = [NSString stringWithFormat:@"%@/%@", _logDirectory, toSendFileName];
    NSData *toSendFileContent = [NSData dataWithContentsOfFile:toSendFilePath];
    
    _isSending = YES;
    [_manager POST:kCCNetworkLogsUploadServerUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:toSendFileContent name:@"logFile" fileName:toSendFileName mimeType:@"text/plain"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error = nil;
        [fileManager removeItemAtPath:toSendFilePath error:&error];
        
        if (error != nil) {
            NSLog(@"%@", error);
        }
        
        NSLog(@"Successfully sent: %@", toSendFileName);
        
        if (_logFile == nil)
            [self openLogFile];
        
        _isSending = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        
        NSLog(@"Failed sending: %@", toSendFileName);
        
        _isSending = NO;
    }];
}

- (NSUInteger)currentLogFileSize
{
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_logFilePath error:&error];
    
    if (error == nil) {
        NSNumber *size = attributes[NSFileSize];
        return [size unsignedIntegerValue];
    }
    NSLog(@"%@", error);
    return 0;
}

#pragma mark - log methods

- (void)log:(NSString *)logString
{
    NSLog(@"%@", logString);
    
    if (_logFile == nil)
        return;
    
    NSString *dateString = [_dateFormatter stringFromDate:[NSDate date]];
    NSString *logStringWithCR = [NSString stringWithFormat:@"%@: %@\n", dateString, logString];
    [_logFile writeData:[NSData dataWithBytes:[logStringWithCR UTF8String] length:[logStringWithCR length]]];
    
    [self checkFileLength];
}

- (void)checkFileLength
{
    NSUInteger fileLength = [self currentLogFileSize];
    if (fileLength > kCCMaxLogsFileSize) {
        [self moveLogFileToSendFile];
    }
}

+ (void)log:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    [[self sharedInstance] log:logString];
    
    va_end(args);
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
