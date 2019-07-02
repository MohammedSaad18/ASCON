#include <stdio.h>
#include "api.h"
#include "crypto_aead.h"

typedef unsigned char u8; // 1 byte long
typedef unsigned long long u64; // 8 bytes long
typedef long long i64; // signed 8 bytes

#define LITTLE_ENDIAN
//#define BIG_ENDIAN

#define RATE (64 / 8) // 8 bytes for the rate // we can say that it's X0
#define PA_ROUNDS 12
#define PB_ROUNDS 6
// this exchanges the n MSB of X with the (64-n) LSB of X
#define ROTR(x,n) (((x)>>(n))|((x)<<(64-(n))))

// if BIG_ENDIN is defined  do that - and as we can see in the above lines (#define BIG_ENDIAN) is commented so it does not go in this condition
#ifdef BIG_ENDIAN
#define EXT_BYTE(x,n) ((u8)((u64)(x)>>(8*(n))))
#define INS_BYTE(x,n) ((u64)(x)<<(8*(n)))
#define U64BIG(x) (x) 
#endif

// if LITTLE_ENDIN is defined  do that 
#ifdef LITTLE_ENDIAN
#define EXT_BYTE(x,n) ((u8)((u64)(x)>>(8*(7-(n)))))
#define INS_BYTE(x,n) ((u64)(x)<<(8*(7-(n))))
// ULL means unsigned long long (8 bytes = 64 bits = 16 nibble -as it's written in hex) 
//this takes 64 bits number x, as it's saved in memory as litle indian, it changes it to big indian
#define U64BIG(x) \
    ((ROTR(x, 8) & (0xFF000000FF000000ULL)) | \
     (ROTR(x,24) & (0x00FF000000FF0000ULL)) | \
     (ROTR(x,40) & (0x0000FF000000FF00ULL)) | \
     (ROTR(x,56) & (0x000000FF000000FFULL)))
#endif

//this array shows the rotation values of the 'linear diffusion layer' 
//static inside a function means the variable will exist before and after the function has ended.
//static outside of a function means that the scope of the symbol marked static is limited to that.c file and cannot be seen outside of it.
//const:just tells the compiler to not let anybody modify it (like a variable put in a read only memory)
static const int R[5][2] = { {19, 28}, {39, 61}, {1, 6}, {10, 17}, {7, 41} };
//????
#define ROUND(C) ({\
    x2 ^= C;\  // Addition of Constants'pc'
    x0 ^= x4;\ //Substitution Layer'ps'
    x4 ^= x3;\
    x2 ^= x1;\
    t0 = x0;\
    t4 = x4;\
    t3 = x3;\
    t1 = x1;\
    t2 = x2;\
    x0 = t0 ^ ((~t1) & t2);\ // thers is something wrong in these steps !!!!!!
    x2 = t2 ^ ((~t3) & t4);\
    x4 = t4 ^ ((~t0) & t1);\
    x1 = t1 ^ ((~t2) & t3);\
    x3 = t3 ^ ((~t4) & t0);\
    x1 ^= x0;\
    t1  = x1;\
    x1 = ROTR(x1, R[1][0]);\ //Linear Diffusion Layer 'pl'
    x3 ^= x2;\
    t2  = x2;\
    x2 = ROTR(x2, R[2][0]);\
    t4  = x4;\
    t2 ^= x2;\
    x2 = ROTR(x2, R[2][1] - R[2][0]);\
    t3  = x3;\
    t1 ^= x1;\
    x3 = ROTR(x3, R[3][0]);\
    x0 ^= x4;\
    x4 = ROTR(x4, R[4][0]);\
    t3 ^= x3;\
    x2 ^= t2;\
    x1 = ROTR(x1, R[1][1] - R[1][0]);\
    t0  = x0;\
    x2 = ~x2;\
    x3 = ROTR(x3, R[3][1] - R[3][0]);\
    t4 ^= x4;\
    x4 = ROTR(x4, R[4][1] - R[4][0]);\
    x3 ^= t3;\
    x1 ^= t1;\
    x0 = ROTR(x0, R[0][0]);\
    x4 ^= t4;\
    t0 ^= x0;\
    x0 = ROTR(x0, R[0][1] - R[0][0]);\
    x0 ^= t0;\
  })
//in each rount of the permutation we add a constant value for X2 
#define P12 ({\
  ROUND(0xf0);\
  ROUND(0xe1);\
  ROUND(0xd2);\
  ROUND(0xc3);\
  ROUND(0xb4);\
  ROUND(0xa5);\
  ROUND(0x96);\
  ROUND(0x87);\
  ROUND(0x78);\
  ROUND(0x69);\
  ROUND(0x5a);\
  ROUND(0x4b);\
})

#define P6 ({\
  ROUND(0x96);\
  ROUND(0x87);\
  ROUND(0x78);\
  ROUND(0x69);\
  ROUND(0x5a);\
  ROUND(0x4b);\
})

int crypto_aead_encrypt(
    unsigned char *c, unsigned long long *clen,
    const unsigned char *m, unsigned long long mlen,
    const unsigned char *ad, unsigned long long adlen,
    const unsigned char *nsec,
    const unsigned char *npub,
    const unsigned char *k) {
// the key k1,k0 and the nonce N1,N0 are of length k=128 bits
  u64 K0 = U64BIG(((u64*)k)[0]); //((u64*)k) is one dimention array of two 64 bit save in the memory as little-endian
  u64 K1 = U64BIG(((u64*)k)[1]);//it's a pointer which points to 64 bit saved in the memoby by 8 bit boundarys 'can be pointed to it as char pointer (*k)'
  u64 N0 = U64BIG(((u64*)npub)[0]);
  u64 N1 = U64BIG(((u64*)npub)[1]);
  u64 x0, x1, x2, x3, x4;
  u64 t0, t1, t2, t3, t4;
  u64 rlen;
  int i;

  // initialization
  x0 = (u64)((CRYPTO_KEYBYTES * 8) << 24 | (RATE * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0) << 32;
  x1 = K0;
  x2 = K1;
  x3 = N0;
  x4 = N1;
  P12;
  // Sc=(x1||x2||x3||x4)^=(0's||K0||K1) ; k--> k0(64 bit) and k1(64 bit)
  // Sr=X0 (rate = 64 bit in this code)
  x3 ^= K0; 
  x4 ^= K1;

  // process associated data
  if (adlen) {
    rlen = adlen;
    while (rlen >= RATE) { // take blocks of 8 bytes of the associated data
      x0 ^= U64BIG(*(u64*)ad); // we take 8 bytes of associated data and we ^ it with each 8 bytes of x0 (we take data from memoory as little endian so we transform it to big endian)
      P6;
      rlen -= RATE;//substract 8 bytes if the associated data lenght to loop till we finish all th blocks of 8 bytes if ad
      ad += RATE; // to point to the next 8 bytes of the associated data
    }
	// we can end the loop and the remaining associated data lenght(rlen) can be = 7 , 6, 5, 4, 3, 2, 1,0 BYTES
	// so we pad the associated data by 1 || 0's till it complets 8 bits
	// if relen=0 it wont get into the for and will add a new 64 padded bits 0x80000000...
	// if relen = 1 byte so INS_BYTE returns : (*ad) value shifted 56 bits in x0 then we pad by 80 in the LSbyte and shift x0<<48bit 
	// if relen = 7 each time it takes 1 byte from the memory and shift it then concatinate it with the prevous byte till it gets 7 bytes and the 8th byte is 0x80 and we put it in the LSbyte
    for (i = 0; i < rlen; ++i, ++ad)
      x0 ^= INS_BYTE(*ad, i);
    x0 ^= INS_BYTE(0x80, rlen);//here it makes sense
    P6;
  }
  x4 ^= 1;

  // process plaintext
  rlen = mlen;
  while (rlen >= RATE) { // take blocks of 8 bytes of the plain text
    x0 ^= U64BIG(*(u64*)m);
    *(u64*)c = U64BIG(x0);// we save data back to memory as little endian so we take the cipher and U64BIG(U64BIG(bati5)) like changing it to little-endian
    P6;
    rlen -= RATE;
    m += RATE;
    c += RATE;
  }
  for (i = 0; i < rlen; ++i, ++m, ++c) {
    x0 ^= INS_BYTE(*m, i);
    *c = EXT_BYTE(x0, i); // batala3 byte byte 3ashan heya betetsave fel memory as bytes ,bas batala3 bel sha2loob 3ashan el memory little endian
  }
  x0 ^= INS_BYTE(0x80, rlen);

  // finalization
  // Sc=(x1||x2||x3||x4)^=(K0||K1||0's) ; k--> k0(64 bit) and k1(64 bit)
  // Sr=X0 (rate = 64 bit in this code)
  x1 ^= K0;
  x2 ^= K1;
  P12;
  x3 ^= K0; // here we only take the LSBs (128 bit), these are the tag but saved in the memory as little indian
  x4 ^= K1;

  // return tag
  ((u64*)c)[0] = U64BIG(x3); // to save it in the memory as little endian- it saves the tag after the cipher
  ((u64*)c)[1] = U64BIG(x4);
  *clen = mlen + CRYPTO_KEYBYTES;// cipher length = the plain text length + 64 bits wich we have added by padding 7ata lw el relen=0
  // this clen points to the end of the cipher data saved in the memory
  return 0;
}

int crypto_aead_decrypt(
    unsigned char *m, unsigned long long *mlen,
    unsigned char *nsec,
    const unsigned char *c, unsigned long long clen,
    const unsigned char *ad, unsigned long long adlen,
    const unsigned char *npub,
    const unsigned char *k) {

  *mlen = 0;
  if (clen < CRYPTO_KEYBYTES)// there is no cipher end the decyption process
    return -1;

  u64 K0 = U64BIG(((u64*)k)[0]);
  u64 K1 = U64BIG(((u64*)k)[1]);
  u64 N0 = U64BIG(((u64*)npub)[0]);
  u64 N1 = U64BIG(((u64*)npub)[1]);
  u64 x0, x1, x2, x3, x4;
  u64 t0, t1, t2, t3, t4;
  u64 rlen;
  int i;

  // initialization
  x0 = (u64)((CRYPTO_KEYBYTES * 8) << 24 | (RATE * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0) << 32;
  x1 = K0;
  x2 = K1;
  x3 = N0;
  x4 = N1;
  P12;
  x3 ^= K0;
  x4 ^= K1;

  // process associated data
  if (adlen) {
    rlen = adlen;
    while (rlen >= RATE) {
      x0 ^= U64BIG(*(u64*)ad);
      P6;
      rlen -= RATE;
      ad += RATE;
    }
    for (i = 0; i < rlen; ++i, ++ad)
      x0 ^= INS_BYTE(*ad, i);
    x0 ^= INS_BYTE(0x80, rlen);
    P6;
  }
  x4 ^= 1;

  // process plaintext
  rlen = clen - CRYPTO_KEYBYTES;// real lenght of the cipher
  while (rlen >= RATE) {
    *(u64*)m = U64BIG(x0) ^ *(u64*)c;// x0 xored with cipher and put it in the plain text place in the memory
    x0 = U64BIG(*((u64*)c));// note that the cipher is comming from memory as little endian 
    P6;
    rlen -= RATE;
    m += RATE;
    c += RATE;
  } // rlen can be = 7 6 5 4 3 2 1 0 bytes
  for (i = 0; i < rlen; ++i, ++m, ++c) {
    *m = EXT_BYTE(x0, i) ^ *c;// save the blocks of bytes of plain text in it's place pointed to in the memory
    x0 &= ~INS_BYTE(0xff, i);
    x0 |= INS_BYTE(*c, i);// the 8 bytes of the cipher blocks are inserted insted of  X0  /// the cipher blocks are now the Sr
  }
  x0 ^= INS_BYTE(0x80, rlen);//padding process of the cypher

  // finalization
  x1 ^= K0;
  x2 ^= K1;
  P12;
  x3 ^= K0;// my tag values
  x4 ^= K1;

  // return -1 if verification fails
  if (((u64*)c)[0] != U64BIG(x3) ||
      ((u64*)c)[1] != U64BIG(x4))
    return -1;

  // return plaintext
  *mlen = clen - CRYPTO_KEYBYTES;
  return 0;
}
