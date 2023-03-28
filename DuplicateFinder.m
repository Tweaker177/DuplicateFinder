//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
//Shouldnt need to reimport since the header imports them
#import "DuplicateFinder.h"


@implementation DuplicateFinder

- (void)findDuplicatesWithOutputFile:(NSString *)outputFilePath {
    NSMutableDictionary *filePathsToDuplicates = [NSMutableDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:@"/"]
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
    // For example, you can check whether the file is in use by another program
    //Right now there is no real check, only references to here, which returns YES every time.
    //if you add a delete function make sure you determine the files are safe to delete.
    //considering most are system files when ya start at root, it should probably be NO by default
    return YES;
}

@end
