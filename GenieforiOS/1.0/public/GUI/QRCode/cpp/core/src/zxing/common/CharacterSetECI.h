// -*- mode:c++; tab-width:2; indent-tabs-mode:nil; c-basic-offset:2 -*-

#ifndef __CHARACTERSET_ECI__
#define __CHARACTERSET_ECI__

/*
 * Copyright 2008-2011 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <map>
#include <zxing/common/ECI.h>
#include <zxing/DecodeHints.h>

namespace zxing {
  namespace common {
    class CharacterSetECI;
  }
}

class zxing::common::CharacterSetECI : public ECI {
private:
  static std::map<int, CharacterSetECI*> VALUE_TO_ECI;
  static std::map<std::string, CharacterSetECI*> NAME_TO_ECI;
  static const bool inited;
  static bool init_tables();

  char const* const encodingName;

  CharacterSetECI(int value, char const* encodingName);

  static void addCharacterSet(int value, char const* encodingName);
  static void addCharacterSet(int value, char const* const* encodingNames);

public:
  char const* getEncodingName();

  static CharacterSetECI* getCharacterSetECIByValue(int value);
  static CharacterSetECI* getCharacterSetECIByName(std::string const& name);
};

#endif
