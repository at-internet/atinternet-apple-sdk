/*
 This SDK is licensed under the MIT license (MIT)
 Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */





//
//  Crash.m
//  Tracker
//

#import "Crash.h"

#import <UIKit/UIKit.h>

#define CRASH_STATE_FILE @"%@/ATCrashState.txt"
#define CRASH_DATA_FILE @"%@/ATCrashData.txt"

@implementation Crash

/// Screen name to add to crash log
static NSString *lastScreen = nil;

/**
  Prepare a crash log
 
 :returns: a dictionnary ready to be added to xtcustom
 */
+ (NSDictionary *)compute {
    NSArray *content = [Crash crashFilesContent];
    if ([content count] == 2) {
        if ([content[0] isEqualToString:@"1"]) {
            [Crash writeToCrashFiles:@"0"];
            return [NSJSONSerialization JSONObjectWithData:[content[1] dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        } else {
            if (!content[0]) {
                [Crash writeToCrashFiles:@"0"];
            }
            return nil;
        }
    } else {
        return nil;
    }
}

/**
 Write to files crash informations
 
 :param: crash data to store
 */
+ (void)writeToCrashFiles:(NSString *)text {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileNameEvent = [NSString stringWithFormat:CRASH_STATE_FILE, documentsDirectory];
    [text writeToFile:fileNameEvent
           atomically:NO
             encoding:NSStringEncodingConversionAllowLossy
                error:nil];
    
    NSString *fileNameView = [NSString stringWithFormat:CRASH_DATA_FILE, documentsDirectory];
    NSString *crashInfo;
    
    if ([text isEqualToString:@"1"]) {
        NSString *view = [Crash lastScreen];
        NSDictionary *crashDico = [[NSDictionary alloc] initWithObjectsAndKeys:view, @"lastscreen", nil];
        NSDictionary *globalDico = [[NSDictionary alloc] initWithObjectsAndKeys:crashDico, @"crash", nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:globalDico
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        crashInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        crashInfo = @"";
    }
    
    [crashInfo writeToFile:fileNameView
           atomically:NO
             encoding:NSStringEncodingConversionAllowLossy
                error:nil];
}

/**
 Read files where crash informations are stored
 
 :returns: an array with the crash state [0] and the crash data [1]
 */
+ (NSArray *)crashFilesContent {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileNameEvent = [NSString stringWithFormat:CRASH_STATE_FILE, documentsDirectory];
    NSString *contentEvent = [[NSString alloc] initWithContentsOfFile:fileNameEvent
                                                    usedEncoding:nil
                                                           error:nil];
    
    NSString *fileNameView = [NSString stringWithFormat:CRASH_DATA_FILE, documentsDirectory];
    NSString *contentView = [[NSString alloc] initWithContentsOfFile:fileNameView
                                                    usedEncoding:nil
                                                           error:nil];
    
    NSArray *content = [[NSArray alloc] initWithObjects:contentEvent, contentView, nil];
    
    return content;
}

/**
 Get the most up-to-date tracked screen
 
 :returns: a screen name
 */
+ (NSString *)lastScreen {
    if (lastScreen == nil) {
        lastScreen = [NSString stringWithFormat:@""];
    }
    return lastScreen;
}

/**
 Set the most up-to-date tracked screen
 
 :params: a screen name
 */
+ (void)lastScreen:(NSString *)screenName {
    lastScreen = screenName;
}

/**
 Uncaught exception handler
 
 :param: raised exception
 */
void handleException(NSException *exception) {
    [Crash writeToCrashFiles:@"1"];
    exit(EXIT_FAILURE);
}

/**
 Unix signals handler
 
 :param raised signal
 */
void handleSignal(int signal) {
    [Crash writeToCrashFiles:@"1"];
    exit(signal);
}

/**
 Enable crash handler
 */
+ (void)handle {
    NSSetUncaughtExceptionHandler(&handleException);
    signal(SIGABRT, &handleSignal);
    signal(SIGBUS, &handleSignal);
    signal(SIGFPE, &handleSignal);
    signal(SIGILL, &handleSignal);
    signal(SIGPIPE, &handleSignal);
    signal(SIGSEGV, &handleSignal);
    signal(SIGTRAP, &handleSignal);
}

@end
