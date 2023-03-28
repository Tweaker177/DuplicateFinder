#import "DuplicateFinder.h"
#import <Foundation/Foundation.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
DuplicateFinder *dFinder = [[DuplicateFinder alloc] init];
NSString *outputFilePath = @"duplicateLog.txt";
[dFinder findDuplicatesWithOutputFile:outputFilePath];
}

return 0;
}