//
// OSConditionals.h
// 
/*
The MIT License

Copyright (c) 2011-2012 Ali Rantakari

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

// See: http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html

#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 661.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
// This value is from the iOS 6 DP4:
#define kCFCoreFoundationVersionNumber_iOS_6_0 790.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
// This value is from the iOS 7 DP1:
#define kCFCoreFoundationVersionNumber_iOS_7_0 838.00
#endif

#define PRE_IOS_3  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_3_0)
#define PRE_IOS_4  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_4_0)
#define PRE_IOS_5  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_5_0)
#define PRE_IOS_6  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_6_0)
#define PRE_IOS_7  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0)
