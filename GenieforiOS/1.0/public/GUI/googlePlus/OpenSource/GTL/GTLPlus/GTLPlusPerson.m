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
//  GTLPlusPerson.m
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
//   GTLPlusPerson (0 custom class methods, 21 custom properties)
//   GTLPlusPersonEmailsItem (0 custom class methods, 3 custom properties)
//   GTLPlusPersonImage (0 custom class methods, 1 custom properties)
//   GTLPlusPersonName (0 custom class methods, 6 custom properties)
//   GTLPlusPersonOrganizationsItem (0 custom class methods, 9 custom properties)
//   GTLPlusPersonPlacesLivedItem (0 custom class methods, 2 custom properties)
//   GTLPlusPersonUrlsItem (0 custom class methods, 3 custom properties)

#import "GTLPlusPerson.h"

// ----------------------------------------------------------------------------
//
//   GTLPlusPerson
//

@implementation GTLPlusPerson
@dynamic aboutMe, birthday, currentLocation, displayName, emails, ETag, gender,
         hasApp, identifier, image, kind, languagesSpoken, name, nickname,
         objectType, organizations, placesLived, relationshipStatus, tagline,
         url, urls;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"etag", @"ETag",
      @"id", @"identifier",
      nil];
  return map;
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      [GTLPlusPersonEmailsItem class], @"emails",
      [NSString class], @"languagesSpoken",
      [GTLPlusPersonOrganizationsItem class], @"organizations",
      [GTLPlusPersonPlacesLivedItem class], @"placesLived",
      [GTLPlusPersonUrlsItem class], @"urls",
      nil];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"plus#person"];
}

@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonEmailsItem
//

@implementation GTLPlusPersonEmailsItem
@dynamic primary, type, value;
@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonImage
//

@implementation GTLPlusPersonImage
@dynamic url;
@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonName
//

@implementation GTLPlusPersonName
@dynamic familyName, formatted, givenName, honorificPrefix, honorificSuffix,
         middleName;
@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonOrganizationsItem
//

@implementation GTLPlusPersonOrganizationsItem
@dynamic department, descriptionProperty, endDate, location, name, primary,
         startDate, title, type;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"description"
                                forKey:@"descriptionProperty"];
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonPlacesLivedItem
//

@implementation GTLPlusPersonPlacesLivedItem
@dynamic primary, value;
@end


// ----------------------------------------------------------------------------
//
//   GTLPlusPersonUrlsItem
//

@implementation GTLPlusPersonUrlsItem
@dynamic primary, type, value;
@end
