%include "io64.inc"
%macro NOTAND 2
    adc %1,%2
%endmacro

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
cipherText dd 0x42570086,0x1c9b31ea,0xf94891a8,0x9be2de59,0x4bf027e8,0x66381daf,0xb4703bb7,0xc82b2463,0x00b224b2,0x3aeccc6a,0x0000ad41,0x220ea84d,0xc994db4d,0xa773b94a,0x4fe8669d

section .bss
m times 25 RESD 1


section .text
global CMAIN
CMAIN:
    mov rbp, rsp; for correct debugging
    ;write your code here
    
    call Initialization
    call associated
    call plain
    call Finalization
   
    xor rax, rax
    ret
    


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
;NOT rax
;AND rax,[t2]
NOTAND rax,[t2]
XOR rax,[t0]
MOV r8,rax
;    x1 = t1 ^ ((~t2) & t3);

MOV rax,[t2]
;NOT rax
;AND rax,[t3]
NOTAND rax,[t3]
XOR rax,[t1]
MOV r9,rax
;    x2 = t2 ^ ((~t3) & t4);

MOV rax,[t3]
;NOT rax
;AND rax,[t4]
NOTAND rax,[t4]
XOR rax,[t2]
MOV r10,rax
;    x3 = t3 ^ ((~t4) & t0);

MOV rax,[t4]
;NOT rax
;AND rax,[t0]
NOTAND rax,[t0]
XOR rax,[t3]
MOV r11,rax
;    x4 = t4 ^ ((~t0) & t1);
MOV rax,[t0]
;NOT rax
;AND rax,[t1]
NOTAND rax,[t1]
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
                BSWAP rbx
                MOV [k],rbx
                MOV r9,rbx
                MOV rbx,[k+8]
                BSWAP rbx
                MOV [k+8],rbx
                 MOV r10,rbx
                MOV rbx,[npub]
                BSWAP rbx
                MOV [npub],rbx
                 MOV r11,rbx
                MOV rbx,[npub+8]
                BSWAP rbx
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
           BSWAP rbx
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
 
    
;;;;;;;;;;;;;;;;;;;;;;;;; plain ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plain:
        mov cl,lenm
        mov rsi,cipherText
        mov rdi,m
   while_p1:
        CMP cl,8
        jl  end_p1
        
        mov rax,[rsi]
        mov rbx,r8
        BSWAP rbx
        
        xor rax,rbx
        mov [rdi],rax
        
        mov rbx,[rsi]
        BSWAP rbx
        mov r8,rbx
        
        call P6_64
        
        add cl,-8
        add rsi,8
        add rdi,8
        jmp while_p1
   end_p1:
   
   mov ch,0
   for_p2:
       cmp ch,cl
       jge end_p2
       
       mov al,[rsi]
       mov rbx,r8
       mov dl,ch
       call EXT_BYTE
       xor al,bl
       mov [rdi],al
       
       
       mov rbx,0xff
       mov dl,ch
       call INS_BYTE
       not rbx
       and r8,rbx
       
       
       mov bl,[rsi]
       and rbx,0x00000000000000ff
       mov dl,ch
       call INS_BYTE
       or r8,rbx
       
       add ch,1
       add rsi,1
       add rdi,1
   
       jmp for_p2
   end_p2:  
   
   mov rbx,0x80
   mov dl,cl
   call INS_BYTE
   xor r8,rbx    
ret

Finalization:

    mov edi ,k
    
    mov rbx,[edi]
    xor r9,rbx
    
    mov rbx,[edi+8]
    xor r10,rbx
    
    call P12_64
    
    mov rbx,[edi]
    xor r11,rbx
    
    mov rbx,[edi+8]
    xor r12,rbx

mov rbx,r11
BSWAP rbx

mov rax ,[rsi]
CMP rax,rbx
jz endd

mov rbx,r12
BSWAP rbx

mov rax,[rsi+8]
CMP rax,rbx
jz endd
mov rax,-1

endd:
ret   