#ifndef __CBARCODE_FORMAT_H__
#define __CBARCODE_FORMAT_H__

/*
 *  CBarcodeFormat.h
 *  zxing
 *
 *  Copyright 2011 ZXing authors All rights reserved.
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

// This must remain parallel to zxing::BarcodeFormat.
typedef enum BarcodeFormat {
        BarcodeFormat_None = 0,
        BarcodeFormat_QR_CODE,
        BarcodeFormat_DATA_MATRIX,
        BarcodeFormat_UPC_E,
        BarcodeFormat_UPC_A,
        BarcodeFormat_EAN_8,
        BarcodeFormat_EAN_13,
        BarcodeFormat_CODE_128,
        BarcodeFormat_CODE_39,
        BarcodeFormat_ITF
} BarcodeFormat;

#endif // __CBARCODE_FORMAT_H__
