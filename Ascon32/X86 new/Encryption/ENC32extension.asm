%include "io.inc"

%macro EXPAND_U32 2
    BTS %2,%1
%endmacro

%macro NOTAND 2
    adc %1,%2
%endmacro

%macro COMPRESS_LONG 1
 RCR %1,1
%endmacro

section .data
x0o dd 0x00
x0e dd 0x0
x1o dd 0x0
x1e dd 0x0
x2o dd 0x0
x2e dd 0x0
x3o dd 0x0
x3e dd 0x0
x4o dd 0x0
x4e dd 0x0
t0o dd 0x0
t0e dd 0x0
t1o dd 0x0
t1e dd 0x0
k0o dd 0x0
k0e dd 0x0
k1o dd 0x0
k1e dd 0x0
n0o dd 0x0
n0e dd 0x0
n1o dd 0x0
n1e dd 0x0

PlainText db  "Fantastic Three, 5od fekra we eshtry bokra"      
len equ $ - PlainText 

npub dd 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 ; key is 128 bit saved in array of word boundaries 

associated_data db "23115151"
adlen equ $ - associated_data

k dd 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 ;nouns length is 128 bit 
cipherText dw ""
section .text
global CMAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;define U32BIG(x)=U32BIG(ebx) input->ebx , output->ebx
U32BIG:PUSH eax
       MOV eax,ebx
       ROR ebx ,8
       AND ebx,0xFF00FF00
       ROR eax ,24
       AND eax,0x00FF00FF
       OR ebx,eax
       POP eax
       ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;EXPAND_SHORT(x)  input->bx , output->ebx
 
EXPAND_SHORT:PUSH ecx
             AND ebx ,0x0000FFFF
             MOV ecx ,ebx
             SHL ebx,8
             OR ebx,ecx
             AND ebx,0x00FF00FF
             MOV ecx ,ebx
             SHL ebx,4
             OR ebx,ecx
             AND ebx,0x0F0F0F0F
             MOV ecx ,ebx
             SHL ebx,2
             OR ebx,ecx
             AND ebx,0x33333333
             MOV ecx ,ebx
             SHL ebx,1
             OR ebx,ecx
             AND ebx,0x55555555
             POP ecx
             ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COMPRESS_U32(var,var_o,var_e) var_o ->dx var_e->bx
COMPRESS_U32:PUSH ecx
             MOV ecx,ebx
             SHR ebx,1
             COMPRESS_LONG  ebx 
             MOV edx,ebx
             MOV ebx,ecx
             COMPRESS_LONG  ebx 
             POP ecx 
             ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COMPRESS_BYTE_ARRAY(a,var_o,var_e) a->ESI var_o->edx var_e->ebx           
COMPRESS_BYTE_ARRAY:PUSH ecx
                   MOV ebx ,[esi]
                   BSWAP ebx
                   MOV ecx,ebx
                   SHR ebx,1
                   COMPRESS_LONG  ebx   ;t1_o
                   MOV edx,ebx
                   SHL edx,16  ;t1_o<<16
                   MOV ebx,ecx
                   COMPRESS_LONG  ebx  ;t1_e
                   MOV eax,ebx
                   SHL eax,16  ;t1_e<<16
                   MOV ebx ,[esi+4]
                   BSWAP ebx
                   MOV ecx,ebx
                   SHR ebx,1
                   COMPRESS_LONG  ebx   ;var_o
                   OR edx,ebx
                   MOV ebx,ecx
                   COMPRESS_LONG  ebx  ;var_e
                   OR ebx,eax
                   POP ecx
                   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;EXT_BYTE32(x,n) ((u8)((u32)(x)>>(8*(3-(n)))))   x->ebx dl->n
EXT_BYTE32: PUSH cx
           NEG dl
           add dl,3
           SHL dl,3
           MOV cl,dl
           SHR ebx ,cl
           POP cx
           ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INS_BYTE32(x,n) ((u32)(x)<<(8*(3-(n)))   x->ebx dl->n
INS_BYTE32: PUSH cx
            NEG dl
            add dl,3
            SHL dl,3
            MOV cl,dl
           SHL ebx ,cl
           POP cx
            ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Take array address and return length in ecx
;STRLEN:PUSH ax
;       MOV ecx , -1
;STRLEN_LOOP:INC ecx
;            MOV al ,[esi+ecx]  
;              CMP al , 0
;             JNE  STRLEN_LOOP
;        POP ax
;        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROUND32:
    ;round Constatn
    xor [x2e],ebx
    xor [x2o],edx
    ;S-box layer
    
    mov eax,[x0e]
    xor eax,[x4e]
    mov [t0e],eax ;t0_e = x0_e ^ x4_e;
    
    mov eax,[x4e]
    xor eax,[x3e]
    mov [t1e],eax ;t1_e = x4_e ^ x3_e;
    
    mov eax,[x2e]
    xor eax,[x1e]
    mov [x2e],eax ;x2_e = x2_e ^ x1_e;
    
    mov eax,[x0o]
    xor eax,[x4o]
    mov [t0o],eax ;t0_o = x0_o ^ x4_o
    
    mov eax,[x4o]
    xor eax,[x3o]
    mov [t1o],eax ;t1_o = x4_o ^ x3_o
    
    mov eax,[x2o]
    xor eax,[x1o]
    mov [x2o],eax ;x2_o = x2_o ^ x1_o;
    
    mov eax,[x1e]
    not eax
    and eax,[x2e]
    mov [x0e],eax ;x0_e = x2_e & (~x1_e)
    
    mov eax,[t0e]
    xor eax,[x0e]
    mov [x0e],eax ;x0_e = t0_e ^ x0_e
    
    mov eax,[x1o]
    not eax
    and eax,[x2o]
    mov [x0o],eax ;x0_o = x2_o & (~x1_o)
    
    mov eax,[t0o]
    xor eax,[x0o]
    mov [x0o],eax ;x0_o = t0_o ^ x0_o;
    
    mov eax,[x1e]
    not eax
    and eax,[x2e]
    mov [x4e],eax ;x4_e = x2_e & (~x1_e)
  
    mov eax,[x0e]
    xor eax,[x4e]
    mov [x4e],eax ;x4_e = x0_e ^ x4_e;
    
    mov eax,[x1o]
    not eax
    and eax,[x2o]
    mov [x4o],eax ;x4_o = x2_o & (~x1_o)
    
    mov eax,[x0o]
    xor eax,[x4o]
    mov [x4o],eax ;x4_o = x0_o ^ x4_o
    
    mov eax,[x4e]
    ;not eax
    ;and eax,[x1e]
    NOTAND eax,[x1e]
    mov [x4e],eax ;x4_e = x1_e & (~x4_e)
    
    mov eax,[x4e]
    xor eax,[t1e]
    mov [x4e],eax ;x4_e = x4_e ^ t1_e;
    
    mov eax,[x4o]
    ;not eax
    ;and eax,[x1o]
    NOTAND eax,[x1o]
    mov [x4o],eax ;x4_o = x1_o & (~x4_o)
    
    mov eax,[x4o]
    xor eax,[t1o]
    mov [x4o],eax ;x4_o = x4_o ^ t1_o
    
    mov eax,[x1e]
    ;not eax
    ;and eax,[x2e]
    NOTAND eax,[x2e]
    mov [t0e],eax ;t0_e = x2_e & (~x1_e)
    
    mov eax,[t0e]
    xor eax,[x0e]
    mov [t0e],eax ;t0_e = t0_e ^ x0_e;
    
    mov eax,[x1o]
    ;not eax
    ;and eax,[x2o]
    NOTAND eax,[x2o]
    mov [t0o],eax ;t0_o = x2_o & (~x1_o)
    
    mov eax,[t0o]
    xor eax,[x0o]
    mov [t0o],eax ;t0_o = t0_o ^ x0_o;
    
    mov eax,[t1e]
    ;not eax
    ;and eax,[t0e]
    NOTAND eax,[t0e]
    mov [t0e],eax ;t0_e = t0_e & (~t1_e)
    
    mov eax,[t0e]
    xor eax,[x3e]
    mov [t0e],eax ;t0_e = t0_e ^ x3_e
    
    mov eax,[t1o]
    ;not eax
    ;and eax,[t0o]
    NOTAND eax,[t0o]
    mov [t0o],eax ;t0_o = t0_o & (~t1_o)
    
    mov eax,[t0o]
    xor eax,[x3o]
    mov [t0o],eax ;t0_o = t0_o ^ x3_o;
    
    mov eax,[x1e]
    ;not eax
    ;and eax,[x2e]
    NOTAND eax,[x2e]
    mov [t1e],eax ;t1_e = x2_e & (~x1_e)
    
    mov eax,[t1e]
    xor eax,[x0e]
    mov [t1e],eax ;t1_e = t1_e ^ x0_e;
    
    mov eax,[x1o]
    ;not eax
    ;and eax,[x2o]
    NOTAND eax,[x2o]
    mov [t1o],eax ;t1_o = x2_o & (~x1_o)
    
    mov eax,[t1o]
    xor eax,[x0o]
    mov [t1o],eax ;t1_o = t1_o ^ x0_o;
    
    mov eax,[t1e]
    ;not eax
    ;and eax,[x1e]
    NOTAND eax,[x1e]
    mov [t1e],eax ;t1_e = x1_e & (~t1_e);
    
    mov eax,[t1e]
    xor eax,[x4e]
    mov [t1e],eax ;t1_e = t1_e ^ x4_e;
    
    mov eax,[t1o]
    ;not eax
    ;and eax,[x1o]
    NOTAND eax,[x1o]
    mov [t1o],eax ;t1_o = x1_o & (~t1_o)
    
    mov eax,[t1o]
    xor eax,[x4o]
    mov [t1o],eax ;t1_o = t1_o ^ x4_o;
    
    mov eax,[x3e]
    ;not eax
    ;and eax,[t1e]
    NOTAND eax,[t1e]
    mov [t1e],eax ;t1_e = t1_e & (~x3_e)
    
    mov eax,[t1e]
    xor eax,[x2e]
    mov [t1e],eax ;t1_e = t1_e ^ x2_e;
    
    mov eax,[x3o]
    ;not eax
    ;and eax,[t1o]
    NOTAND eax,[t1o]
    mov [t1o],eax ;t1_o = t1_o & (~x3_o)
    
    mov eax,[t1o]
    xor eax,[x2o]
    mov [t1o],eax ;t1_o = t1_o ^ x2_o;
    
    mov eax,[x2e]
   ; not eax
   ; and eax,[x3e]
   NOTAND eax,[x3e]
    mov [x2e],eax ;x2_e = x3_e & (~x2_e);
    
    mov eax,[x1e]
    xor eax,[x2e]
    mov [x1e],eax ;x1_e = x1_e ^ x2_e;
    
    mov eax,[x2o]
    ;not eax
    ;and eax,[x3o]
    NOTAND eax,[x3o]
    mov [x2o],eax ;x2_o = x3_o & (~x2_o);
        
    mov eax,[x1o]
    xor eax,[x2o]
    mov [x1o],eax ;x1_o = x1_o ^ x2_o;
    
    mov eax,[x1e]
    xor eax,[x0e]
    mov [x1e],eax ;x1_e = x1_e ^ x0_e;
    
    mov eax,[x0e]
    xor eax,[x4e]
    mov [x0e],eax ;x0_e = x0_e ^ x4_e;
    
    mov eax,[t0e]
    xor eax,[t1e]
    mov [x3e],eax ;x3_e = t0_e ^ t1_e
    
    mov eax,[t1e]
    not eax
    mov [x2e],eax ; x2_e =~ t1_e;
    
    mov eax,[x1o]
    xor eax,[x0o]
    mov [x1o],eax ;x1_o = x1_o ^ x0_o
    
    mov eax,[x0o]
    xor eax,[x4o]
    mov [x0o],eax ;x0_o = x0_o ^ x4_o;
    
    mov eax,[t0o]
    xor eax,[t1o]
    mov [x3o],eax ;x3_o = t0_o ^ t1_o
    
    mov eax,[t1o]
    not eax
    mov [x2o],eax ; x2_o =~ t1_o;
    
    ;--------------- Linear -------------;
    
    mov eax,[x0e]
    mov [t0e],eax ;t0_e  = x0_e
    
    mov eax,[x0o]
    mov [t0o],eax ;t0_o  = x0_o;
    
    mov eax,[x1e]
    mov [t1e],eax ;t1_e  = x1_e
    
    mov eax,[x1o]
    mov [t1o],eax ;t1_o  = x1_o;
    
    mov eax ,[t0o]
    ror eax ,9
    xor eax,[x0e]
    mov [x0e],eax ;x0_e ^= ROTR32(t0_o, R_O[0][0]);
    
    mov eax,[t0e]
    ror eax,10
    xor eax,[x0o]
    mov [x0o],eax ;x0_o ^= ROTR32(t0_e, R_E[0][0]);
    
    mov eax,[t1o]
    ror eax,19
    xor eax,[x1e]
    mov [x1e],eax ;x1_e ^= ROTR32(t1_o, R_O[1][0]);
    
    mov eax,[t1e]
    ror eax,20
    xor eax,[x1o]
    mov [x1o],eax ;x1_o ^= ROTR32(t1_e, R_E[1][0]);
    
    mov eax,[t0e]
    ror eax,14
    xor eax,[x0e]
    mov [x0e],eax ;x0_e ^= ROTR32(t0_e, R_E[0][1]);
    
    mov eax,[t0o]
    ror eax,14
    xor eax,[x0o]
    mov [x0o],eax ;x0_o ^= ROTR32(t0_o, R_O[0][1]);
    
    mov eax,[t1o]
    ror eax,30
    xor eax,[x1e]
    mov [x1e],eax ;x1_e ^= ROTR32(t1_o, R_O[1][1]);
    
    mov eax,[t1e]
    ror eax,31
    xor eax,[x1o]
    mov [x1o],eax ;x1_o ^= ROTR32(t1_e, R_E[1][1]);
    
    mov eax,[x2e]
    mov [t0e],eax ;t0_e  = x2_e;
    
    mov eax,[x2o]
    mov [t0o],eax ;t0_o  = x2_o;
    
    mov eax,[x3e]
    mov [t1e],eax ;t1_e  = x3_e
    
    mov eax,[x3o]
    mov [t1o],eax ;t1_o  = x3_o;
    
    mov eax,[t0o]
    ror eax,0
    xor eax,[x2e]
    mov [x2e],eax ;x2_e ^= ROTR32(t0_o, R_O[2][0]);
    
    mov eax,[t0e]
    ror eax, 1
    xor eax,[x2o]
    mov [x2o],eax ;x2_o ^= ROTR32(t0_e, R_E[2][0]);
    
    mov eax,[t1e]
    ror eax,5
    xor eax,[x3e]
    mov [x3e],eax ;x3_e ^= ROTR32(t1_e, R_E[3][0]);
    
    mov eax,[t1o]
    ror eax,5
    xor eax,[x3o]
    mov [x3o],eax ;x3_o ^= ROTR32(t1_o, R_O[3][0]);
    
    mov eax,[t0e]
    ror eax,3
    xor eax,[x2e]
    mov [x2e],eax ;x2_e ^= ROTR32(t0_e, R_E[2][1]);
    
    mov eax,[t0o]
    ror eax,3
    xor eax,[x2o]
    mov [x2o],eax ;x2_o ^= ROTR32(t0_o, R_O[2][1]);
    
    mov eax,[t1o]
    ror eax,8
    xor eax,[x3e]
    mov [x3e],eax ;x3_e ^= ROTR32(t1_o, R_O[3][1]);
    
    mov eax,[t1e]
    ror eax,9
    xor eax,[x3o]
    mov [x3o],eax ;x3_o ^= ROTR32(t1_e, R_E[3][1]);
    
    mov eax,[x4e]
    mov [t0e],eax ;t0_e  = x4_e;
    
    mov eax,[x4o]
    mov [t0o],eax ;t0_o  = x4_o;
    
    mov eax,[t0o]
    ror eax,3
    xor eax,[x4e]
    mov [x4e],eax ;x4_e ^= ROTR32(t0_o, R_O[4][0]);
    
    mov eax,[t0e]
    ror eax,4
    xor eax,[x4o]
    mov [x4o],eax ;x4_o ^= ROTR32(t0_e, R_E[4][0]);
    mov eax,[t0o]
    ror eax,20
    xor eax,[x4e]
    mov [x4e],eax ;x4_e ^= ROTR32(t0_o, R_O[4][1]);
    mov eax,[t0e]
    ror eax,21
    xor eax,[x4o]
    mov [x4o],eax ;x4_o ^= ROTR32(t0_e, R_E[4][1]);
    
    
    
    ret
    
    
P12_32:
   PUSH eax
    mov ebx,0xc
    mov edx,0xc
    call ROUND32

    mov ebx,0x9
    mov edx,0xc
    call ROUND32

    mov ebx,0xc
    mov edx,0x9
    call ROUND32

    mov ebx,0x9
    mov edx,0x9
    call ROUND32

    mov ebx,0x6
    mov edx,0xc
    call ROUND32

    mov ebx,0x3
    mov edx,0xc
    call ROUND32

    mov ebx,0x6
    mov edx,0x9
    call ROUND32

    mov ebx,0x3
    mov edx,0x9
    call ROUND32

    mov ebx,0xc
    mov edx,0x6
    call ROUND32

    mov ebx,0x9
    mov edx,0x6
    call ROUND32

    mov ebx,0xc
    mov edx,0x3
    call ROUND32

    mov ebx,0x9
    mov edx,0x3
    call ROUND32
     POP eax
    ret
    
P6_32:
    PUSh eax
    mov ebx,0x6
    mov edx,0x9
    call ROUND32

    mov ebx,0x3
    mov edx,0x9
    call ROUND32

    mov ebx,0xc
    mov edx,0x6
    call ROUND32

    mov ebx,0x9
    mov edx,0x6
    call ROUND32

    mov ebx,0xc
    mov edx,0x3
    call ROUND32

    mov ebx,0x9
    mov edx,0x3
    call ROUND32
    POP eax
    ret    
    
;;;;;;;;;;;;;;;;;;;;;;initilization;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
init: 
      MOV esi,k    
      call COMPRESS_BYTE_ARRAY
      mov dword [k0o],edx
      mov dword [k0e],ebx
      mov dword [x1o],edx
      mov dword [x1e],ebx
      
      MOV esi,k + 8
      call COMPRESS_BYTE_ARRAY
      mov dword [k1o],edx
      mov dword [k1e],ebx
      mov dword [x2o],edx
      mov dword [x2e],ebx
      
      MOV esi,npub    
      call COMPRESS_BYTE_ARRAY
      mov dword [n0o],edx
      mov dword [n0e],ebx
      mov dword [x3o],edx
      mov dword [x3e],ebx
      
      MOV esi,npub + 8
      call COMPRESS_BYTE_ARRAY
      mov dword [n1o],edx
      mov dword [n1e],ebx
      mov dword [x4o],edx
      mov dword [x4e],ebx
      
      MOV dword [t1e],0x80400c06
      MOV dword [t1o],0x40200603
      
      MOV ebx,[t1e]
      COMPRESS_LONG  ebx 
      SHL ebx,16
      MOV dword [x0e],ebx
      
      MOV ebx,[t1o]
      COMPRESS_LONG  ebx 
      SHL ebx,16
      MOV dword [x0o],ebx
      
      call P12_32
      
      MOv ebx, [k0e]
      XOR [x3e], ebx
      
      
      MOv ebx, [k0o]
      XOR [x3o], ebx
      
      MOv ebx, [k1e]
      XOR [x4e], ebx
      
      MOv ebx, [k1o]
      XOR [x4o], ebx
ret      
;;;;;;;;;;;;;;;;;;;;;;associated data;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
associated:
  
    MOV ecx, adlen; ecx= rlen=adlen
    CMP ecx,0
    jz a_exit 
         MOV esi,associated_data
         while_a0:   
         CMP ecx,8; while (rlen >= RATE) 
         jl while_a1
                          
                call COMPRESS_BYTE_ARRAY;cOMPRESS_BYTE_ARRAY(ad,in_o,in_e); a->ESI var_o->edx var_e->ebx 
                XOR [x0e],ebx;x0_e ^= in_e;
                XOR [x0o],edx;x0_o ^= in_o;
                call P6_32
                add ecx,-8;rlen -= RATE
                add esi,8;ad += RATE
                
         jmp while_a0
         while_a1:
                   
         MOV dword[t1e],0x00000000
         MOV dword[t1o],0x00000000
         
         ; for (i = 0; i < rlen; ++i, ++ad)
         MOV edx,0x00000000 ;i = 0
        
          for_a0:
          CMP edx,ecx  ;i < rlen   
          JGE for_a1
          
             MOV ebx,[esi];use ebx as input for INS_BYTE32
             CMP edx,4 ;if(i < 4) 
             JGE else_a1   
                          ;t1_o |= INS_BYTE32(*ad, i)                          
                          call INS_BYTE32
                          OR [t1o],ebx      
             else_a1:
                         ;t1_e |= INS_BYTE32(*ad, (i - 4))
                         push edx
                         add edx,-4;(i - 4)
                         call INS_BYTE32
                         pop edx
                         OR [t1e],ebx    
         add esi,1 ;++ad  
         add edx,1 ;++i   
         JMP  for_a0
         for_a1:
         
         
         CMP ecx,4 ;if(rlen < 4) 
         JGE else_a2
            ;t1_o |= INS_BYTE32(0x80, rlen);
            MOV ebx,0x80
            MOV edx,ecx
            call INS_BYTE32
            OR [t1o],ebx
            jmp end_if
         else_a2:  
            ;t1_e |= INS_BYTE32(0x80, (rlen - 4))
            MOV ebx,0x80
            MOV edx,ecx
            add edx, -4
            call INS_BYTE32
            OR [t1e],ebx
            end_if:
               
             MOV ebx,[t1o]     
            call COMPRESS_U32 ;COMPRESS_U32(t1_o,&t0_o,&t0_e); var_o ->dx var_e->bx
             SHL edx,16 ;t0_o << 16;
             MOV [t0o],edx
             
             SHL ebx,16 ;t0_e << 16
             MOV [t0e],ebx
             
             MOV ebx,[t1e]     
             call COMPRESS_U32 ;COMPRESS_U32(t1_e,&in_o,&in_e) var_o ->dx var_e->bx
             OR edx ,[t0o]
             OR ebx ,[t0e]
             XOR [x0e],ebx;x0_e ^= in_e
             XOR [x0o],edx;x0_o ^= in_o
             call P6_32
    a_exit: 
    MOV eax,1
    XOR [x4e],eax
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PPTD: MOV esi , PlainText
      MOV edi ,cipherText
      MOV ecx,len
FIRST_LOOP:CMP ecx ,8
      JL NEXT_STEP1
      call COMPRESS_BYTE_ARRAY ;COMPRESS_BYTE_ARRAY(a,var_o,var_e) a->ESI var_o->edx var_e->ebx
      ADD esi,8 ;m += RATE;
      XOR [x0e],ebx
      XOR [x0o],edx
      MOV ebx,[x0e]
      MOV edx,[x0o]
      PUSH bx
      PUSH dx
      SHR ebx,16
      SHR edx,16
      EXPAND_U32 ebx,edx ;EXPAND_U32(var,var_o,var_e)-> var_o=dx , var_e=bx , var=ebx
      BSWAP ebx
      MOV [edi],ebx      
      POP dx
      POP bx
    EXPAND_U32 ebx,edx ;EXPAND_U32(var,var_o,var_e)-> var_o=dx , var_e=bx , var=ebx
      BSWAP ebx
      MOV [edi+4],ebx
      call P6_32
      ADD ecx,-8
      ADD edi,8 ;c += RATE;
      JMP FIRST_LOOP
NEXT_STEP1:
          MOV dword [t1o],0
          MOV dword [t1e],0
          MOV ch ,0          
FOR_LOOP: CMP ch ,cl
          JE NEXT_STEP2
          CMP ch ,4
          JGE else1
          MOV dl,ch
          MOV bl ,[esi]
          call INS_BYTE32  ;INS_BYTE32(x,n) ((u32)(x)<<(8*(n)))   x->ebx dl->n
          OR [t1o],ebx
          ADD esi,1
          ADD ch,1
          JMP FOR_LOOP
else1:   MOV dl,ch
          MOV bl ,[esi]
          call INS_BYTE32  ;INS_BYTE32(x,n) ((u32)(x)<<(8*(n)))   x->ebx dl->edx
          OR [t1e],ebx
          ADD esi,1
           ADD ch,1
          JMP FOR_LOOP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEXT_STEP2:MOV dl,cl
          MOV ebx ,0x80
          CMP cl ,4
          JGE else2
          call INS_BYTE32  ;INS_BYTE32(x,n) ((u32)(x)<<(8*(n)))   x->ebx dl->edx
          OR [t1o],ebx
          JMP NEXT_STEP3
else2:   ADD dl,-4
         call INS_BYTE32  ;INS_BYTE32(x,n) ((u32)(x)<<(8*(n)))   x->ebx dl->edx
             OR [t1e],ebx
NEXT_STEP3: MOV ebx,[t1o]     
            call COMPRESS_U32 ;COMPRESS_U32(var,var_o,var_e) var_o ->dx var_e->bx
             SHL edx,16
             MOV [t0o],edx
             SHL ebx,16
             MOV [t0e],ebx
             MOV ebx,[t1e]     
             call COMPRESS_U32 ;COMPRESS_U32(var,var_o,var_e) var_o ->dx var_e->bx
             OR edx ,[t0o]
             OR ebx ,[t0e]
             XOR [x0e],ebx
             XOR [x0o],edx
             MOV bx ,[x0e]
             MOV dx ,[x0o]
             EXPAND_U32 ebx,edx    ;EXPAND_U32(var,var_o,var_e)-> var_o=dx , var_e=bx , var=ebx
             MOV [t1e],ebx
              MOV bx ,[x0e+2]
             MOV dx ,[x0o+2]
             EXPAND_U32 ebx,edx     ;EXPAND_U32(var,var_o,var_e)-> var_o=dx , var_e=bx , var=ebx
            MOV [t1o],ebx
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MOV ch ,0          
FOR_LOOP2: CMP ch ,cl
          JE FINAL_STEP
          CMP ch ,4
          JGE else3
          MOV dl,ch
          MOV ebx ,[t1o]
          call EXT_BYTE32  
          MOV [edi],bl
          ADD edi,1
          ADD ch,1
          JMP FOR_LOOP2
else3:   MOV dl,ch
         ADD dl,-1
          MOV ebx ,[t1e]
          call EXT_BYTE32  
          MOV [edi],bl
          ADD edi,1
          ADD ch,1
          JMP FOR_LOOP 
     
FINAL_STEP: ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Finalization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Final:

    mov eax,[x1e]
    xor eax,[k0e]
    mov [x1e],eax
    
    mov eax,[x1o]
    xor eax,[k0o]
    mov[x1o],eax
    
    mov eax,[x2e]
    xor eax,[k1e]
    mov[x2e],eax
    
    mov eax,[x2o]
    xor eax,[k1o]
    mov[x2o],eax
    
    call P12_32
    
    mov eax,[x3e]
    xor eax,[k0e]
    mov[x3e],eax
    
    mov eax,[x3o]
    xor eax,[k0o]
    mov[x3o],eax
    
    mov eax,[x4e]
    xor eax,[k1e]
    mov [x4e],eax
    
    mov eax,[x4o]
    xor eax,[k1o]
    mov[x4o],eax
    
  ;;;;;;;;;;;;;;;;;;;; return tag ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mov esi , cipherText
  add esi ,len
  
  mov ebx,[x3e]
  shr ebx,16
  
  mov edx,[x3o]
  shr edx,16
  
  EXPAND_U32 ebx,edx
  BSWAP ebx
  
  mov [esi],ebx
  
  mov ebx,[x3e]
  mov edx,[x3o]
  EXPAND_U32 ebx,edx
  BSWAP ebx
  
  mov [esi+4],ebx
  
  mov ebx,[x4e]
  shr ebx,16
  mov edx,[x4o]
  shr ebx,16
  EXPAND_U32 ebx,edx
  BSWAP ebx
  mov [esi+8],ebx
  
  mov ebx,[x4e]
  mov edx,[x4o]
  EXPAND_U32 ebx,edx
  BSWAP ebx
  mov[esi+12],ebx
    
    

ret

CMAIN:
    mov ebp, esp; for correct debugging
    call init
    call associated
    call PPTD
    call Final
    mov ebx,[x0e]
    mov ebx,[x0o]
    mov ebx,[x1e]
    mov ebx,[x1o]
    mov ebx,[x2e]
    mov ebx,[x2o]
    mov ebx,[x3e]
    mov ebx,[x3o]    
    mov ebx,[x4e]
    mov ebx,[x4o]
    xor eax, eax
    ret
