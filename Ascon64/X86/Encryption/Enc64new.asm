%include "io64.inc"
section .data
t0 DQ 0x0 ;r13
t1 DQ 0x0 ;r14
t2 DQ 0x0 ;r15
t3 DQ 0x0
t4 DQ 0x0
PlainText db  "Fantastic Three, 5od fekra we eshtry bokra"      
lenm equ $ - PlainText  
npub dd 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 ; key is 128 bit saved in array of word boundaries 
associated_data db "23115151",
lenass equ $ - associated_data
k dd 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 ;nouns length is 128 bit 
cipherText db ""
section .text
global CMAIN

U64BIG:PUSH rax
       PUSH rcx
       MOV rax,rbx
       MOV rdx,rbx
       ROR rbx ,8
       MOV rcx,0xFF000000FF000000
       AND rbx,rcx
       ROR rdx ,24
       MOV rcx,0x00FF000000FF0000
       AND rdx,rcx
       OR rbx,rdx
       MOV rdx,rax
       ROR rdx ,40
       MOV rcx,0x0000FF000000FF00
       AND rdx,rcx
       OR rbx,rdx
       ROR rax ,56
       MOV rcx,0x000000FF000000FF
       AND rax,rcx
       OR rbx,rax
       POP rcx
       POP rax
       ret
;u8 EXT_BYTE(u64 x,int n) ((x)>>(8*(7-(n))));
EXT_BYTE:  PUSH cx
           NEG dl
           add dl,7
           SHL dl,3
           MOV cl,dl
           SHR rbx ,cl
           POP cx
           ret
;INS_BYTE(u64 x,int n) (x<<(8*(7-n)))
INS_BYTE: PUSH cx
          NEG dl
          add dl,7
          SHL dl,3
          MOV cl,dl
          SHL rbx ,cl
          POP cx
          ret
          
ROUND64:XOR r10,rbx
    ;x0 ^= x4;
    XOR r8,r12
    ;x4 ^= x3;
    XOR r12,r11
;    x2 ^= x1;
    XOR r10,r9
;    t0 = x0;
   MOV [t0],r8
;    t4 = x4;
   MOV [t1],r9
;    t3 = x3;
  MOV [t2],r10
;    t1 = x1;
  MOV [t3],r11
;    t2 = x2;
  MOV [t4],r12
;    x0 = t0 ^ ((~t1) & t2);
MOV rax,[t1]
NOT rax
AND rax,[t2]
XOR rax,[t0]
MOV r8,rax
;    x1 = t1 ^ ((~t2) & t3);

MOV rax,[t2]
NOT rax
AND rax,[t3]
XOR rax,[t1]
MOV r9,rax
;    x2 = t2 ^ ((~t3) & t4);

MOV rax,[t3]
NOT rax
AND rax,[t4]
XOR rax,[t2]
MOV r10,rax
;    x3 = t3 ^ ((~t4) & t0);

MOV rax,[t4]
NOT rax
AND rax,[t0]
XOR rax,[t3]
MOV r11,rax
;    x4 = t4 ^ ((~t0) & t1);
MOV rax,[t0]
NOT rax
AND rax,[t1]
XOR rax,[t4]
MOV r12,rax
;    x1 ^= x0;
XOR r9,r8
;    t1  = x1;
MOV [t1],r9

;x1 = ROTR(x1, R[1][0]);
;    x3 ^= x2;
;    t2  = x2;
ROR r9,39 
XOR r11,r10 
MOV [t2],r10 
;    x2 = ROTR(x2, R[2][0]);
;    t4  = x4;
;    t2 ^= x2;
ROR r10,1
XOR [t2],r10
MOV [t4],r12
;    x2 = ROTR(x2, R[2][1] - R[2][0]);
;    t3  = x3;
;    t1 ^= x1;
ROR r10,5 
XOR [t1],r9 
MOV [t3],r11
;    x3 = ROTR(x3, R[3][0]);
;    x0 ^= x4;
ROR r11,10
XOR r8,r12  
;    x4 = ROTR(x4, R[4][0]);
;    t3 ^= x3;
;    x2 ^= t2;
ROR r12,7
XOR [t3],r11
XOR r10,[t2]     
;    x1 = ROTR(x1, R[1][1] - R[1][0]);
;    t0  = x0;
;    x2 = ~x2;
ROR r9,22 
MOV [t0],r8
NOT r10    
;    x3 = ROTR(x3, R[3][1] - R[3][0]);
;    t4 ^= x4;
ROR r11,7
XOR [t4],r12
;    x4 = ROTR(x4, R[4][1] - R[4][0]);
;    x3 ^= t3;
;    x1 ^= t1;
ROR r12,34
XOR r11,[t3] 
XOR r9,[t1]   
;    x0 = ROTR(x0, R[0][0]);
;    x4 ^= t4;
;    t0 ^= x0;
ROR r8,19
XOR r12,[t4]
XOR [t0],r8
;    x0 = ROTR(x0, R[0][1] - R[0][0]);
;    x0 ^= t0;
ROR r8,9 
XOR r8,[t0]
ret
P12_64:
   PUSH rax
    mov rbx,0xf0
    call ROUND64

     mov rbx,0xe1
    call ROUND64

     mov rbx,0xd2
    call ROUND64

     mov rbx,0xc3
    call ROUND64

    mov rbx,0xb4
    call ROUND64

     mov rbx,0xa5
    call ROUND64

     mov rbx,0x96
    call ROUND64

     mov rbx,0x87
    call ROUND64

   mov rbx,0x78
    call ROUND64

     mov rbx,0x69
    call ROUND64

     mov rbx,0x5a
    call ROUND64

     mov rbx,0x4b
    call ROUND64
     POP rax
    ret
    P6_64:
    PUSh rax
     mov rbx,0x96
    call ROUND64

     mov rbx,0x87
    call ROUND64

   mov rbx,0x78
    call ROUND64

     mov rbx,0x69
    call ROUND64

     mov rbx,0x5a
    call ROUND64

     mov rbx,0x4b
    call ROUND64
    POP rax
    ret  
    Initialization: MOV rbx,[k]
                call U64BIG
                MOV [k],rbx
                MOV r9,rbx
                MOV rbx,[k+8]
                call U64BIG
                MOV [k+8],rbx
                 MOV r10,rbx
                MOV rbx,[npub]
                call U64BIG
                MOV [npub],rbx
                 MOV r11,rbx
                MOV rbx,[npub+8]
                call U64BIG
                MOV [npub+8],rbx
                 MOV r12,rbx
               MOV rbx ,0x80400c0600000000
               MOV r8,rbx
               call P12_64
               MOV rbx,[k]
               XOR r11,rbx
                MOV rbx,[k+8]
               XOR r12,rbx
               ret
associated:MOV rcx,lenass 
           MOV rsi ,associated_data
           CMP rcx ,0
           JE END
Loop1_ass:CMP rcx,8
           JL ass_next_step1
           MOV rbx,[rsi]
           ADD rsi,8
           call U64BIG
           XOR r8,rbx
           call P6_64
           ADD rcx,-8
           JMP Loop1_ass
ass_next_step1:MOV ch,0
 Loop2_ass   : CMP ch,cl
               JE  ass_next_step2
                MOV bl,[rsi] 
                MOV dl,ch
                call INS_BYTE
                XOR r8,rbx
                INC ch
                INC rsi 
                JMP Loop2_ass                     
ass_next_step2: MOV rbx,0x80
                MOV dl,cl
                call INS_BYTE
                XOR r8,rbx
                call P6_64
                MOV rbx,0x01               
                XOR r12,rbx
 END:ret           

PPTD:       MOV rsi , PlainText
            MOV rdi ,cipherText
            MOV ecx,lenm
LOOP1_pptd: CMP rcx,8
            JL pptd_next_step1
            MOV rbx,[rsi]
            ADD rsi,8
            call U64BIG
            XOR r8,rbx
           call U64BIG
           MOV [rdi],rbx
            ADD rdi,8
            call P6_64
            ADD rcx,-8
            JMP LOOP1_pptd

pptd_next_step1:MOV ch,0
 Loop2_pptd   : CMP ch,cl
               JE  pptd_next_step2
                MOV bl,[rsi] 
                MOV dl,ch
                call INS_BYTE
                XOR r8,rbx
                MOV dl,ch
                call EXT_BYTE
                MOV [rdi],bl
                INC rdi
                INC ch
                INC rsi 
                JMP Loop2_pptd 

pptd_next_step2: MOV rbx,0x80
                 MOV dl,cl   
                 call INS_BYTE
                XOR r8,rbx
                ret
finalization: 
              XOR r9,[k]
              XOR r10,[k+8]
              call P12_64
              XOR r11,[k]
              XOR r12,[k+8]
              MOV rbx,r11
              call U64BIG
              MOV [rdi],rbx
              ADD rdi,8
              MOV rbx,r12
              call U64BIG
              MOV [rdi],rbx
              ret
CMAIN:
    mov rbp, rsp; for correct debugging
    mov ebp, esp; for correct debugging
    mov rbp, rsp; for correct debugging
    ;write your code here
    mov  r8,0x80400c0600000000
    
    mov  r9,0xabcdef1234872511
    
    mov  r10,0x310020803100208
    
    mov  r11,0xabcdff1234872511
    
    mov  r12,0x310020803100208
       call Initialization
    call associated
     call PPTD
     call finalization
       xor rax, rax
       
       ret