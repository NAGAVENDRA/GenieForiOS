/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLPlusMoment.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Google+ API (plus/v1moments)
// Description:
//   The Google+ API enables developers to build on top of the Google+ platform.
// Documentation:
//   http://developers.google.com/+/api/
// Classes:
//   GTLPlusMoment (0 custom class methods, 6 custom properties)
//   GTLPlusMomentVerb (0 custom class methods, 1 custom properties)

#import "GTLPlusMoment.h"

#import "GTLPlusItemScope.h"

// ----------------------------------------------------------------------------
//
//   GTLPlusMoment
//

@implementation GTLPlusMoment
@dynamic kind, result, startDate, target, type, verb;

+ (void)load {
  [self registerObjectClassForKind:@"plus#moment"];
}

@end


// ----------------------------------------------------------------------------
//
//   GTLPlusMomentVerb
//

@implementation GTLPlusMomentVerb
@dynamic url;
@end
