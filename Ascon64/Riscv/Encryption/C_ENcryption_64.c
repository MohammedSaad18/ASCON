#include <stdio.h>
#include <string.h>

typedef unsigned char u8;
typedef unsigned long long u64;
typedef long long i64;

#define RATE (64 / 8)
#define PA_ROUNDS 12
#define PB_ROUNDS 6
#define CRYPTO_KEYBYTES 16
#define CRYPTO_NSECBYTES 0
#define CRYPTO_NPUBBYTES 16
#define CRYPTO_ABYTES 16
#define CRYPTO_NOOVERLAP 1

#define print \
 ({printf("x0=%llx\n",x0);\
printf("x1=%llx\n",x1);\
printf("x2=%llx\n",x2);\
printf("x3=%llx\n",x3);\
printf("x4=%llx\n",x4);\
printf("///////////////////////////\n");\
  })


  u64 x0, x1, x2, x3, x4;
  u64 t0, t1, t2, t3, t4;

u64 ROTR(u64 x,char n) {
return (((x)>>(n))|((x)<<(64-(n))));
}
u8 EXT_BYTE(u64 x,int n){
return ((x)>>(8*(7-(n))));
}
u64 INS_BYTE(u64 x,int n) {
return (x<<(8*(7-n)));
}

u64 U64BIG(u64 x) {

    u64 y= x;
    u64 z= x;
    u64 k= x;
    x= ((ROTR(x, 8) & (0xFF000000FF000000ULL)) |(ROTR(y,24) & (0x00FF000000FF0000ULL)) |(ROTR(z,40) & (0x0000FF000000FF00ULL)) | (ROTR(k,56) & (0x000000FF000000FFULL)));

return x;
   }

static const int R[5][2] = { {19, 28}, {39, 61}, {1, 6}, {10, 17}, {7, 41} };

void ROUND(int C) {
    x2 ^= C;
    x0 ^= x4;
    x4 ^= x3;
    x2 ^= x1;
    t0 = x0;
    t4 = x4;
    t3 = x3;
    t1 = x1;
    t2 = x2;
    x0 = t0 ^ ((~t1) & t2);
    x2 = t2 ^ ((~t3) & t4);
    x4 = t4 ^ ((~t0) & t1);
    x1 = t1 ^ ((~t2) & t3);
    x3 = t3 ^ ((~t4) & t0);
    x1 ^= x0;
    t1  = x1;
   
    x1 = ROTR(x1, R[1][0]);
    x3 ^= x2;
    t2  = x2;
    
    x2 = ROTR(x2, R[2][0]);
    t4  = x4;
    t2 ^= x2;
   
    x2 = ROTR(x2, R[2][1] - R[2][0]);
    t3  = x3;
    t1 ^= x1;
   
    x3 = ROTR(x3, R[3][0]);
    x0 ^= x4;
    
    x4 = ROTR(x4, R[4][0]);
    t3 ^= x3;
    x2 ^= t2;
    
    x1 = ROTR(x1, R[1][1] - R[1][0]);
    t0  = x0;
    x2 = ~x2;
   
    x3 = ROTR(x3, R[3][1] - R[3][0]);
    t4 ^= x4;
    
    x4 = ROTR(x4, R[4][1] - R[4][0]);
    x3 ^= t3;
    x1 ^= t1;
   
    x0 = ROTR(x0, R[0][0]);
    x4 ^= t4;
    t0 ^= x0;
    
    x0 = ROTR(x0, R[0][1] - R[0][0]);
    x0 ^= t0;
  }

void P12 (){
  ROUND(0xf0);
  ROUND(0xe1);
  ROUND(0xd2);
  ROUND(0xc3);
  ROUND(0xb4);
  ROUND(0xa5);
  ROUND(0x96);
  ROUND(0x87);
  ROUND(0x78);
  ROUND(0x69);
  ROUND(0x5a);
  ROUND(0x4b);
}

void P6 (){
  ROUND(0x96);
  ROUND(0x87);
  ROUND(0x78);
  ROUND(0x69);
  ROUND(0x5a);
  ROUND(0x4b);
}

int crypto_aead_encrypt(
    unsigned char *c, unsigned long long *clen,
    const unsigned char *m, unsigned long long mlen,
    const unsigned char *ad, unsigned long long adlen,
    const unsigned char *nsec,
    const unsigned char *npub,
    const unsigned char *k) {
 
  u64 K0 = U64BIG(((u64*)k)[0]);
  u64 K1 = U64BIG(((u64*)k)[1]);
  u64 N0 = U64BIG(((u64*)npub)[0]);
  u64 N1 = U64BIG(((u64*)npub)[1]);

  u64 rlen;
  int i;

  // initialization
  x0 = (u64)((CRYPTO_KEYBYTES * 8) << 24 | (RATE * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0) << 32;  
x1 = K0;
  x2 = K1;
  x3 = N0;
  x4 = N1;
  P12();
  x3 ^= K0;
  x4 ^= K1;
  
  // process associated data
  if (adlen) {
    rlen = adlen;
    while (rlen >= RATE) {
      x0 ^= U64BIG(*(u64*)ad);
      P6();
      rlen -= RATE;
      ad += RATE;
    }
    for (i = 0; i < rlen; ++i, ++ad)
      x0 ^= INS_BYTE(*ad, i);
    x0 ^= INS_BYTE(0x80, rlen);
    P6();
  }
  x4 ^= 1;

  // process plaintext
  rlen = mlen;
  while (rlen >= RATE) {
    x0 ^= U64BIG(*(u64*)m);
    *(u64*)c = U64BIG(x0);
printf("%llx\n",*(u64*)c );
    P6();
    rlen -= RATE;
    m += RATE;
    c += RATE;
  }
  for (i = 0; i < rlen; ++i, ++m, ++c) {
    x0 ^= INS_BYTE(*m, i);
    *c = EXT_BYTE(x0, i);
    printf("%x\n",*c );
  }
  x0 ^= INS_BYTE(0x80, rlen);

  // finalization
  x1 ^= K0;
  x2 ^= K1;
  P12();
  x3 ^= K0;
  x4 ^= K1;

  // return tag
  ((u64*)c)[0] = U64BIG(x3);
  printf("%x\n",*c );
  ((u64*)c)[1] = U64BIG(x4);
printf("%llx\n",((u64*)c)[1]);
  *clen = mlen + CRYPTO_KEYBYTES;


  return 0;
}





int main() {
  unsigned long long clen = CRYPTO_ABYTES;
  const char a[] = "23115151";
  const char m[] = "Fantastic Three, 5od fekra we eshtry bokra";
  unsigned long long alen = strlen(a);
  unsigned long long mlen = strlen(m);
  unsigned char c[strlen(m) + CRYPTO_ABYTES];
  unsigned char nsec[CRYPTO_NSECBYTES];
  unsigned char npub[CRYPTO_NPUBBYTES] = {0xab,0xcd,0xff,0x12,0x34,0x87,0x25,0x11,0x03,0x10,0x02,0x08,0x03,0x10,0x02,0x08};
  unsigned char k[CRYPTO_KEYBYTES ] = { 0xab,0xcd,0xef,0x12,0x34,0x87,0x25,0x11,0x03,0x10,0x02,0x08,0x03,0x10,0x02,0x08};
  crypto_aead_encrypt(c, &clen, m, mlen, a, alen, nsec, npub, k);


   
  

  return 0;
}

