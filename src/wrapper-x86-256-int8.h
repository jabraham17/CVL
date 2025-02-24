#ifndef WRAPPER_X86_256_INT8_H_
#define WRAPPER_X86_256_INT8_H_

#include <x86intrin.h>

static inline __m128i swapPairs_256epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i swapLowHigh_256epi8(__m128i x) {
  return x; // TODO
}

static inline __m128i reverse_256epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateLeft_256epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateRight_256epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i blendLowHigh_256epi8(__m128i x, __m128i y) {
  return x; // TODO
}

#endif
