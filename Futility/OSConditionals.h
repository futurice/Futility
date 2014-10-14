//
// OSConditionals.h
// 
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

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
// This value is from the iOS 8.0 release:
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.100
#endif

#define PRE_IOS_3  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_3_0)
#define PRE_IOS_4  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_4_0)
#define PRE_IOS_5  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_5_0)
#define PRE_IOS_6  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_6_0)
#define PRE_IOS_7  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0)
#define PRE_IOS_8  (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
