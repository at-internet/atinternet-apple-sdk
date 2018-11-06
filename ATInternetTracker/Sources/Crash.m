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
#define CRASH_RECOVERY_FILE @"%@/ATCrashRecovery.txt"
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
    if ([content count] != 3) {
        return nil;
    }
    NSString *state = content[0];
    NSString *recovery = content[1];
    NSString *data = content[2];
    
    if ([state isEqualToString:@"1"]) {
        [Crash writeToCrashFiles:@"0" withRecovery:recovery];
        return [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    }
    if (!state) {
        [Crash writeToCrashFiles:@"0" withRecovery:recovery];
    }
    return nil;
}

+ (NSDictionary *)recover {
    NSArray *content = [Crash crashFilesContent];
    if ([content count] != 3) {
        return nil;
    }
    NSString *state = content[0];
    NSString *recovery = content[1];
    NSString *data = content[2];
    
    if ([recovery isEqualToString:@"0"]) {
        [Crash writeToCrashFiles:state withRecovery:@"1"];
        return [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                 error:nil];
    }
    if (!recovery) {
        [Crash writeToCrashFiles:state withRecovery:@"0"];
    }
    return nil;
}

/**
 Write to files crash informations
 
 :param: crash data to store
 */
+ (void)writeToCrashFiles:(NSString *)state withRecovery:(NSString *)recovery {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    [state writeToFile:[NSString stringWithFormat:CRASH_STATE_FILE, documentsDirectory]
           atomically:NO
             encoding:NSStringEncodingConversionAllowLossy
                error:nil];
    
    [recovery writeToFile:[NSString stringWithFormat:CRASH_RECOVERY_FILE, documentsDirectory]
            atomically:NO
              encoding:NSStringEncodingConversionAllowLossy
                 error:nil];
    
    if ([state isEqualToString:@"1"]) {
        NSString *view = [Crash lastScreen];
        NSDictionary *crashDico = [[NSDictionary alloc] initWithObjectsAndKeys:view, @"lastscreen", nil];
        NSDictionary *globalDico = [[NSDictionary alloc] initWithObjectsAndKeys:crashDico, @"crash", nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:globalDico
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        
        NSString *crashInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [crashInfo writeToFile:[NSString stringWithFormat:CRASH_DATA_FILE, documentsDirectory]
                    atomically:NO
                      encoding:NSStringEncodingConversionAllowLossy
                         error:nil];
    }
}

/**
 Read files where crash informations are stored
 
 :returns: an array with the crash state [0] and the crash data [1]
 */
+ (NSArray *)crashFilesContent {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *state = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:CRASH_STATE_FILE, documentsDirectory]
                                                    usedEncoding:nil
                                                           error:nil];
    
    NSString *recovery = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:CRASH_RECOVERY_FILE, documentsDirectory]
                                                 usedEncoding:nil
                                                        error:nil];
    
    NSString *data = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:CRASH_DATA_FILE, documentsDirectory]
                                                    usedEncoding:nil
                                                           error:nil];
    
    return [[NSArray alloc] initWithObjects:state, recovery, data, nil];
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
    [Crash writeToCrashFiles:@"1" withRecovery:@"0"];
    exit(EXIT_FAILURE);
}

/**
 Unix signals handler
 
 :param raised signal
 */
void handleSignal(int signal) {
    [Crash writeToCrashFiles:@"1" withRecovery:@"0"];
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
