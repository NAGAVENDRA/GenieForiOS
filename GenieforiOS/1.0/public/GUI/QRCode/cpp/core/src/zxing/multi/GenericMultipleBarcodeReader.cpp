/*
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

#include <zxing/multi/GenericMultipleBarcodeReader.h>
#include <zxing/ReaderException.h>
#include <zxing/ResultPoint.h>

namespace zxing {
namespace multi {
GenericMultipleBarcodeReader::GenericMultipleBarcodeReader(Reader& delegate) : 
  delegate_(delegate)
{
}

GenericMultipleBarcodeReader::~GenericMultipleBarcodeReader(){}

std::vector<Ref<Result> > GenericMultipleBarcodeReader::decodeMultiple(
  Ref<BinaryBitmap> image, DecodeHints hints)
{
  std::vector<Ref<Result> > results;
  doDecodeMultiple(image, hints, results, 0, 0);
  if (results.empty()){
    throw ReaderException("No code detected");
  }
  return results;
}

void GenericMultipleBarcodeReader::doDecodeMultiple(Ref<BinaryBitmap> image, 
  DecodeHints hints, std::vector<Ref<Result> >& results, int xOffset, int yOffset)
{
  Ref<Result> result;
  try {
    result = delegate_.decode(image, hints);
  } catch (ReaderException re) {
    return;
  }
  bool alreadyFound = false;
  for (unsigned int i = 0; i < results.size(); i++) {
    Ref<Result> existingResult = results[i];
    if (existingResult->getText()->getText() == result->getText()->getText()) {
      alreadyFound = true;
      break;
    }
  }
  if (alreadyFound) {
    return;
  }
  
  results.push_back(translateResultPoints(result, xOffset, yOffset));
  const std::vector<Ref<ResultPoint> > resultPoints = result->getResultPoints();
  if (resultPoints.empty()) {
    return;
  }

  int width = image->getWidth();
  int height = image->getHeight();
  float minX = width;
  float minY = height;
  float maxX = 0.0f;
  float maxY = 0.0f;
  for (unsigned int i = 0; i < resultPoints.size(); i++) {
    Ref<ResultPoint> point = resultPoints[i];
    float x = point->getX();
    float y = point->getY();
    if (x < minX) {
      minX = x;
    }
    if (y < minY) {
      minY = y;
    }
    if (x > maxX) {
      maxX = x;
    }
    if (y > maxY) {
      maxY = y;
    }
  }

  // Decode left of barcode
  if (minX > MIN_DIMENSION_TO_RECUR) {
    doDecodeMultiple(image->crop(0, 0, (int) minX, height), 
                     hints, results, xOffset, yOffset);
  }
  // Decode above barcode
  if (minY > MIN_DIMENSION_TO_RECUR) {
    doDecodeMultiple(image->crop(0, 0, width, (int) minY), 
                     hints, results, xOffset, yOffset);
  }
  // Decode right of barcode
  if (maxX < width - MIN_DIMENSION_TO_RECUR) {
    doDecodeMultiple(image->crop((int) maxX, 0, width - (int) maxX, height), 
                     hints, results, xOffset + (int) maxX, yOffset);
  }
  // Decode below barcode
  if (maxY < height - MIN_DIMENSION_TO_RECUR) {
    doDecodeMultiple(image->crop(0, (int) maxY, width, height - (int) maxY), 
                     hints, results, xOffset, yOffset + (int) maxY);
  }
}

Ref<Result> GenericMultipleBarcodeReader::translateResultPoints(Ref<Result> result, int xOffset, int yOffset){
  const std::vector<Ref<ResultPoint> > oldResultPoints = result->getResultPoints();
  if (oldResultPoints.empty()) {
    return result;
  }
  std::vector<Ref<ResultPoint> > newResultPoints;
  for (unsigned int i = 0; i < oldResultPoints.size(); i++) {
    Ref<ResultPoint> oldPoint = oldResultPoints[i];
    newResultPoints.push_back(Ref<ResultPoint>(new ResultPoint(oldPoint->getX() + xOffset, oldPoint->getY() + yOffset)));
  }
  return Ref<Result>(new Result(result->getText(), result->getRawBytes(), newResultPoints, result->getBarcodeFormat()));
}

} // End zxing::multi namespace
} // End zxing namespace
