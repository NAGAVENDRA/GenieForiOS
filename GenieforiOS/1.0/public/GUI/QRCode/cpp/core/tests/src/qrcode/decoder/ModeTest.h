#ifndef __MODE_TEST_H__
#define __MODE_TEST_H__

/*
 *  ModeTest.h
 *  zxing
 *
 *  Copyright 2010 ZXing authors All rights reserved.
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

#include <cppunit/TestFixture.h>
#include <cppunit/extensions/HelperMacros.h>
#include <zxing/qrcode/decoder/Mode.h>

namespace zxing {
namespace qrcode {

class ModeTest : public CPPUNIT_NS::TestFixture {
  CPPUNIT_TEST_SUITE(ModeTest);
  CPPUNIT_TEST(testForBits);
  CPPUNIT_TEST(testCharacterCount);
  CPPUNIT_TEST_SUITE_END();

public:

protected:
  void testForBits();
  void testCharacterCount();

private:
};
}
}

#endif // __MODE_TEST_H__
