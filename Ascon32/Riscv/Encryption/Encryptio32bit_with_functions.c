#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CRYPTO_KEYBYTES 16
#define CRYPTO_NSECBYTES 0
#define CRYPTO_NPUBBYTES 16
#define CRYPTO_ABYTES 16
#define CRYPTO_NOOVERLAP 1
#define RATE (64 / 8)
#define PA_ROUNDS 12
#define PB_ROUNDS 6

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef int i32;


/////////////////////////////////?????Global Variables?????????????????????????????
static const int R_O[5][2] = { {9, 14}, {19, 30}, {0, 3}, {5, 8}, {3, 20} };
static const int R_E[5][2] = { {10, 14}, {20, 31}, {1, 3}, {5, 9}, {4, 21} };

  u32 x0_o, x1_o, x2_o, x3_o, x4_o;
  u32 x0_e, x1_e, x2_e, x3_e, x4_e;
u32 t0_e, t1_e;
  u32 t0_o, t1_o;



u32 ROTR32(u32 x,char n) {
x=(((x)>>(n))|((x)<<(32-(n))));
return x;
}

u32 U32BIG(u32 x) {
   u32 y= x;
x=((ROTR32(x,  8) & (0xFF00FF00)) | ((ROTR32(y, 24) & (0x00FF00FF))));
return x;
   }
u8 EXT_BYTE32(u32 x,int n){
return (x)>>(8*(3-n));
}
u32 INS_BYTE32(u32 x,int n) {
x=x<<(8*(3-n));
return x;
}

u32 EXPAND_SHORT(u32 x){\
    x = x & 0x0000ffff;
    x = (x | (x << 8)) & 0x00ff00ff;
    x = (x | (x << 4)) & 0x0f0f0f0f;
    x = (x | (x << 2)) & 0x33333333;
    x = (x | (x << 1)) & 0x55555555;
    return x;
    }

  u32 EXPAND_U32(u16 var_o,u16 var_e) {\
   /*var 32-bit, and var_o/e 16-bit*/\
   u32 var;
   u32 t0_e = (var_e);\
   u32 t0_o = (var_o);\
   t0_e =EXPAND_SHORT(t0_e);\
   t0_o = EXPAND_SHORT(t0_o);\
   return var = t0_e | (t0_o << 1);\
   }
u32 COMPRESS_LONG(u32 x) {\
    x &= 0x55555555;
    x = (x | (x >> 1)) & 0x33333333;
    x = (x | (x >> 2)) & 0x0f0f0f0f;
    x = (x | (x >> 4)) & 0x00ff00ff;
    x = (x | (x >> 8)) & 0x0000ffff;
    return x;
    }

u32 COMPRESS_U32(u32 var,u32 *var_o,u32 *var_e){\
  /*var 32-bit, and var_o/e 16-bit*/\
   *var_e = var;\
  *var_o = *var_e >> 1;
    *var_e=COMPRESS_LONG(*var_e);\
  *var_o=COMPRESS_LONG(*var_o);\
  }

  u32 COMPRESS_BYTE_ARRAY( unsigned char *va ,u32 *var_or,u32 *var_er) {
   *var_er = U32BIG(((u32*)(va))[1]);
   *var_or = *var_er >> 1;\
   *var_er=COMPRESS_LONG(*var_er);\
   *var_or=COMPRESS_LONG(*var_or);\
 u32 t1_e,t1_o;
  t1_e= U32BIG(((u32*)(va))[0]);
 t1_o=t1_e>>1;
t1_e=COMPRESS_LONG(t1_e);\
   t1_o=COMPRESS_LONG(t1_o);\
   *var_er |= t1_e << 16;\
   *var_or |= t1_o << 16;\
}

  void ROUND_32(int C_e,int C_o) {\
    /* round constant */\
    x2_e ^= C_e;\
    x2_o ^= C_o;\
    /* s-box layer */\
    t0_e = x0_e ^ x4_e;       t1_e = x4_e ^ x3_e;    x2_e = x2_e ^ x1_e;\
    t0_o = x0_o ^ x4_o;       t1_o = x4_o ^ x3_o;    x2_o = x2_o ^ x1_o;\
    x0_e = x2_e & (~x1_e);    x0_e = t0_e ^ x0_e; \
    x0_o = x2_o & (~x1_o);    x0_o = t0_o ^ x0_o; \
    x4_e = x2_e & (~x1_e);    x4_e = x0_e ^ x4_e;\
    x4_o = x2_o & (~x1_o);    x4_o = x0_o ^ x4_o;\
    x4_e = x1_e & (~x4_e);    x4_e = x4_e ^ t1_e;\
    x4_o = x1_o & (~x4_o);    x4_o = x4_o ^ t1_o;\
    t0_e = x2_e & (~x1_e);    t0_e = t0_e ^ x0_e;\
    t0_o = x2_o & (~x1_o);    t0_o = t0_o ^ x0_o;\
    t0_e = t0_e & (~t1_e);    t0_e = t0_e ^ x3_e;\
    t0_o = t0_o & (~t1_o);    t0_o = t0_o ^ x3_o;\
    t1_e = x2_e & (~x1_e);    t1_e = t1_e ^ x0_e;\
    t1_o = x2_o & (~x1_o);    t1_o = t1_o ^ x0_o;\
    t1_e = x1_e & (~t1_e);    t1_e = t1_e ^ x4_e;\
    t1_o = x1_o & (~t1_o);    t1_o = t1_o ^ x4_o;\
    t1_e = t1_e & (~x3_e);    t1_e = t1_e ^ x2_e;\
    t1_o = t1_o & (~x3_o);    t1_o = t1_o ^ x2_o;\
    x2_e = x3_e & (~x2_e);    x1_e = x1_e ^ x2_e;\
    x2_o = x3_o & (~x2_o);    x1_o = x1_o ^ x2_o;\
    x1_e = x1_e ^ x0_e;    x0_e = x0_e ^ x4_e;    x3_e = t0_e ^ t1_e;    x2_e =~ t1_e;\
    x1_o = x1_o ^ x0_o;    x0_o = x0_o ^ x4_o;    x3_o = t0_o ^ t1_o;    x2_o =~ t1_o;\
    /* linear layer */\
    t0_e  = x0_e;    t0_o  = x0_o; \
    t1_e  = x1_e;    t1_o  = x1_o;\
    x0_e ^= ROTR32(t0_o, R_O[0][0]);\
    x0_o ^= ROTR32(t0_e, R_E[0][0]);\
    x1_e ^= ROTR32(t1_o, R_O[1][0]);\
    x1_o ^= ROTR32(t1_e, R_E[1][0]);\
    x0_e ^= ROTR32(t0_e, R_E[0][1]);\
    x0_o ^= ROTR32(t0_o, R_O[0][1]);\
    x1_e ^= ROTR32(t1_o, R_O[1][1]);\
    x1_o ^= ROTR32(t1_e, R_E[1][1]);\
    t0_e  = x2_e;    t0_o  = x2_o;\
    t1_e  = x3_e;    t1_o  = x3_o;\
    x2_e ^= ROTR32(t0_o, R_O[2][0]);\
    x2_o ^= ROTR32(t0_e, R_E[2][0]);\
    x3_e ^= ROTR32(t1_e, R_E[3][0]);\
    x3_o ^= ROTR32(t1_o, R_O[3][0]);\
    x2_e ^= ROTR32(t0_e, R_E[2][1]);\
    x2_o ^= ROTR32(t0_o, R_O[2][1]);\
    x3_e ^= ROTR32(t1_o, R_O[3][1]);\
    x3_o ^= ROTR32(t1_e, R_E[3][1]);\
    t0_e  = x4_e;\
    t0_o  = x4_o;\
    x4_e ^= ROTR32(t0_o, R_O[4][0]);\
    x4_o ^= ROTR32(t0_e, R_E[4][0]);\
    x4_e ^= ROTR32(t0_o, R_O[4][1]);\
    x4_o ^= ROTR32(t0_e, R_E[4][1]);\
  }
void P12_32 (){\
  ROUND_32(0xc,0xc);\
  ROUND_32(0x9,0xc);\
  ROUND_32(0xc,0x9);\
  ROUND_32(0x9,0x9);\
  ROUND_32(0x6,0xc);\
  ROUND_32(0x3,0xc);\
  ROUND_32(0x6,0x9);\
  ROUND_32(0x3,0x9);\
  ROUND_32(0xc,0x6);\
  ROUND_32(0x9,0x6);\
  ROUND_32(0xc,0x3);\
  ROUND_32(0x9,0x3);\
}

void P6_32 (){
  ROUND_32(0x6,0x9);
  ROUND_32(0x3,0x9);
  ROUND_32(0xc,0x6);
  ROUND_32(0x9,0x6);
  ROUND_32(0xc,0x3);
  ROUND_32(0x9,0x3);
}
int encryption(unsigned char *c, unsigned long long *clen,
   unsigned char *m, unsigned long long mlen,
 unsigned char *ad, unsigned long long adlen,
   unsigned char *nsec,
  unsigned char *npub,
  unsigned char *k);
int main()
{ unsigned char nsec[CRYPTO_NSECBYTES];
   unsigned char npub[CRYPTO_NPUBBYTES] = {0xab,0xcd,0xff,0x12,0x34,0x87,0x25,0x11,0x03,0x10,0x02,0x08,0x03,0x10,0x02,0x08};
  unsigned  char k[CRYPTO_KEYBYTES] = { 0xab,0xcd,0xef,0x12,0x34,0x87,0x25,0x11,0x03,0x10,0x02,0x08,0x03,0x10,0x02,0x08};

unsigned long long clen = CRYPTO_ABYTES;
  unsigned char ad[]="23115151";
  unsigned char m[]="Fantastic Three, 5od fekra we eshtry bokra";
 unsigned long long adlen = strlen(ad);
  unsigned long long mlen = strlen(m);
 unsigned char c[strlen(m) + CRYPTO_ABYTES];

encryption(c, &clen, m, mlen, ad, adlen, nsec, npub, k);



return 0 ;
}

int encryption(unsigned char *c, unsigned long long *clen,
   unsigned char *m, unsigned long long mlen,
 unsigned char *ad, unsigned long long adlen,
   unsigned char *nsec,
  unsigned char *npub,
  unsigned char *k){


 u32 K0_o;
  u32 K1_o;
  u32 N0_o;
  u32 N1_o;
   u32 K0_e;
  u32 K1_e;
  u32 N0_e;
  u32 N1_e;
u32 in_o, in_e;
u64 rlen;
int i;
COMPRESS_BYTE_ARRAY(k,&K0_o,&K0_e);
  COMPRESS_BYTE_ARRAY(k+8,&K1_o,&K1_e);
  COMPRESS_BYTE_ARRAY(npub,&N0_o,&N0_e);
  COMPRESS_BYTE_ARRAY(npub+8,&N1_o,&N1_e);

  t1_e = (u32)((CRYPTO_KEYBYTES * 8) << 24 | (RATE * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0);
  t1_o = t1_e >> 1;

  t1_e=COMPRESS_LONG(t1_e);
  t1_o=COMPRESS_LONG(t1_o);

  x0_e = t1_e << 16;
  x0_o = t1_o << 16;
  x1_o = K0_o;
  x1_e = K0_e;
  x2_e = K1_e;
  x2_o = K1_o;
  x3_e = N0_e;
  x3_o = N0_o;
  x4_e = N1_e;
  x4_o = N1_o;
  P12_32();
x3_e ^= K0_e;
  x3_o ^= K0_o;
  x4_e ^= K1_e;
  x4_o ^= K1_o;

if (adlen) {
//printf("%llu\n",adlen);   
 rlen = adlen;
    while (rlen >= RATE) {
   
      COMPRESS_BYTE_ARRAY(ad,&in_o,&in_e);
      x0_e ^= in_e;
      x0_o ^= in_o;
    
      P6_32();
      rlen -= RATE;
      ad += RATE;
    }
    t1_e = 0;
    t1_o = 0;
    for (i = 0; i < rlen; ++i, ++ad)
      if(i < 4)
        t1_o |= INS_BYTE32(*ad, i);
      else
        t1_e |= INS_BYTE32(*ad, (i - 4));

    if(rlen < 4)
      t1_o |= INS_BYTE32(0x80, rlen);
    else
      t1_e |= INS_BYTE32(0x80, (rlen - 4));
    COMPRESS_U32(t1_e,&in_o,&in_e);
    COMPRESS_U32(t1_o,&t0_o,&t0_e);
    in_o |= t0_o << 16;
    in_e |= t0_e << 16;


  x0_e ^= in_e;
    x0_o ^= in_o;
  P6_32();
  }
  x4_e ^= 1;

rlen = mlen;
  while (rlen >= RATE) {

    COMPRESS_BYTE_ARRAY(m,&in_o,&in_e);

    x0_e ^= in_e;
    x0_o ^= in_o;
    t1_e=EXPAND_U32(x0_o>>16,x0_e>>16);
    ((u32*)c)[0] = U32BIG(t1_e);
    t1_e=EXPAND_U32(x0_o,x0_e);
    ((u32*)c)[1] = U32BIG(t1_e);
P6_32();
    rlen -= RATE;
    m += RATE;
    c += RATE;

  }

  t1_o = t1_e = 0;
  for (i = 0; i < rlen; ++i, ++m)
    if(i < 4)
      t1_o |= INS_BYTE32(*m, i);
    else
      t1_e |= INS_BYTE32(*m, (i - 4));
  if(rlen < 4)
    t1_o |= INS_BYTE32(0x80, rlen);
  else
    t1_e |= INS_BYTE32(0x80, (rlen - 4));
 


 COMPRESS_U32(t1_e,&in_o,&in_e);
  COMPRESS_U32(t1_o,&t0_o,&t0_e);
  in_o |= t0_o << 16;
  in_e |= t0_e << 16;
  x0_e ^= in_e;
  x0_o ^= in_o;
  t1_e=EXPAND_U32(x0_o,x0_e);
  t1_o=EXPAND_U32(x0_o>>16,x0_e>>16);

  for (i = 0; i < rlen; ++i, ++c)
    if(i < 4){
      *c = EXT_BYTE32(t1_o, i);

}
    else{
      *c = EXT_BYTE32(t1_e, i - 4);

    }

    x1_e ^= K0_e;
  x1_o ^= K0_o;
  x2_e ^= K1_e;
  x2_o ^= K1_o;
  P12_32();
  x3_e ^= K0_e;
  x3_o ^= K0_o;
  x4_e ^= K1_e;
  x4_o ^= K1_o;

  // return tag
  t1_e=EXPAND_U32(x3_o>>16,x3_e>>16);
  ((u32*)c)[0] = U32BIG(t1_e);
  //printf("t=%x\n",t1_e);
  t1_e=EXPAND_U32(x3_o,x3_e);
  ((u32*)c)[1] = U32BIG(t1_e);
  //printf("t=%x\n",t1_e);
  t1_e=EXPAND_U32(x4_o>>16,x4_e>>16);
  ((u32*)c)[2] = U32BIG(t1_e);
  //printf("t=%x\n",t1_e);
  t1_e=EXPAND_U32(x4_o,x4_e);
  ((u32*)c)[3] = U32BIG(t1_e);
  //printf("t=%x\n",t1_e);
  *clen = mlen + CRYPTO_KEYBYTES;
return 0;
}


