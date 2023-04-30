//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
//Shouldnt need to reimport since the header imports them
#import "DuplicateFinder.h"
#define homePath @"/private/var/mobile/"
//only scan starting at /var/mobile/ skipping higher level system files and components
//The only thing this typically misses is duplicate theme images, which often have different bundleID's and in theory are both valid paths.
//This also misses some duplicate string files / localizations, but it's a good idea not to erase or move them unless you know exactly what you're doing


@implementation DuplicateFinder

- (void)findDuplicatesWithOutputFile:(NSString *)outputFilePath {
    NSMutableDictionary *filePathsToDuplicates = [NSMutableDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:homePath]
                                           includingPropertiesForKeys:@[NSURLFileSizeKey, NSURLIsDirectoryKey]
                                                              options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants
                                                         errorHandler:nil];
    for (NSURL *url in enumerator) {
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue]) {
            continue;
        }
        NSString *filePath = [url path];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
        if ([fileSize unsignedLongLongValue] == 0) {
            continue;
        }
        NSMutableArray *duplicates = [filePathsToDuplicates objectForKey:fileSize];
        if (duplicates == nil) {
            duplicates = [NSMutableArray array];
            [filePathsToDuplicates setObject:duplicates forKey:fileSize];
        }
        BOOL safeToDelete = [self isSafeToDeleteFilePath:filePath];
        Duplicate *duplicate = [[Duplicate alloc] init];
        duplicate.filePath = filePath;
        duplicate.memoryUsage = [fileSize unsignedLongLongValue];
        duplicate.isSafeToDelete = safeToDelete;
        [duplicates addObject:duplicate];
    }
    NSError *error;
    NSFileHandle *outputFile = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:outputFilePath]
                                                                 error:&error];
    if (error) {
        NSLog(@"Failed to open output file: %@", error);
        return;
    }
    for (NSNumber *fileSize in filePathsToDuplicates) {
        NSArray *duplicates = [filePathsToDuplicates objectForKey:fileSize];
        if ([duplicates count] > 1) {
            for (Duplicate *duplicate in duplicates) {
               BOOL safeToDelete = [self  isSafeToDeleteFilePath: duplicate.filePath]; 
              duplicate.isSafeToDelete = safeToDelete;
                NSString *outputLine = [NSString stringWithFormat:@"%@\t%llu\t%@\n", duplicate.filePath, duplicate.memoryUsage, [[NSNumber numberWithBool:duplicate.isSafeToDelete] stringValue]];
                [outputFile writeData:[outputLine dataUsingEncoding:NSUTF8StringEncoding]];
                NSLog(@"%@", outputLine);
            }
        }
    }
    [outputFile closeFile];
NSLog(@"Duplicates have been outputted if any existed to file path: %@", outputFilePath);
}

- (BOOL)isSafeToDeleteFilePath:(NSString *)filePath {
    // Determine whether it is safe to delete the file at this path
    // For example, check whether the file is in use by another program,  check last modified, last opened dates
    //Right now there is no real check, only references to here, which returns NO every time.
    //if you add a delete function make sure you determine the files are safe to delete.
   
    return NO;
}

@end
