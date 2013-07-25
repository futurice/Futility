//
//  UIApplication+FKFileSystemPaths.h
//
//  Created by Ali Rantakari / Futurice on 17.12.2012.
//
// Copyright © Futurice (http://www.futurice.com)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of Futurice nor the names of its contributors may be used to
//   endorse or promote products derived from this software without specific prior
//   written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

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
