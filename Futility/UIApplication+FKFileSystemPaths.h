//
//  UIApplication+FKFileSystemPaths.h
//
//  Created by Ali Rantakari / Futurice on 17.12.2012.
/*
 The MIT License
 
 Copyright (c) 2012 Futurice
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

// See "File System Programming Guide" for more info
// http://developer.apple.com/library/ios/#documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html
// 
@interface UIApplication (FKFileSystemPaths)

/*
 This directory is the top-level directory for files that are not user data files.
 You typically put files in one of several standard subdirectories but you can also
 create custom subdirectories for files you want backed up but not exposed to the user.
 You should not use this directory for user data files.
 The contents of this directory (with the exception of the Caches subdirectory) are
 backed up by iTunes.
 */
+ (NSURL *) fk_libraryDirURL;

/*
 In iOS 5.0.1 and later, put support files your application downloads or generates
 and can recreate as needed in the <Application_Home>/Library/Application Support directory
 and apply the com.apple.MobileBackup extended attribute to them. This attribute prevents
 the files from being backed up to iTunes or iCloud. If you have a large number of
 support files, you may store them in a custom subdirectory and apply the extended
 attribute to just the directory.
 */
+ (NSURL *) fk_applicationSupportDirURL;

/*
 Put data cache files in the <Application_Home>/Library/Caches directory.
 Examples of files you should put in this directory include (but are not limited to)
 database cache files and downloadable content, such as that used by magazine, newspaper,
 and map apps. Your app should be able to gracefully handle situations where cached data
 is deleted by the system to free up disk space.
 */
+ (NSURL *) fk_cachesDirURL;

/*
 Use this directory to store critical user documents and app data files.
 Critical data is any data that cannot be recreated by your app, such as
 user-generated content. The contents of this directory can be made available
 to the user through file sharing. The contents of this directory are backed
 up by iTunes.
 */
+ (NSURL *) fk_documentsDirURL;

/*
 ...
 */
+ (NSURL *) fk_downloadsDirURL;

@end
