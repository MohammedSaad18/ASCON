.data
        .align 3
        PlainText: .ascii "Fantastic Three, 5od fekra we eshtry bokra$"      
        .align 3
        npub: .word 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 # key is 128 bit saved in array of word boundaries 
        .align 3
         associated_data: .ascii "23115151$"
      .align 3  
        k: .word 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 #nouns length is 128 bit
     .align 3   
     cipherText : .space 

.text
.align 3
.global main
.type main , @function
main:
la a0 ,PlainText

jal initialization
jal associated
jal PPTD
jal Finalization
li a0, 0
        li a1, 0
        li a2, 0
        li a3, 0
        li a7, 93                   # _NR_sys_exit
        ecall  




strlen:
	######Saving Registers to The Stack###############
	addi sp,sp,-32
	sd   t0,0(sp)
	sd   t1,8(sp)
	sd   t2,16(sp)
	sd   ra,24(sp)
	##################################################
	
	mv t0,a0 #getting the address of the Text
	mv t2,zero #initialize the Counter
	#For Loop#
agn:	lbu   t1,0(t0) #load the next character from the string
	addi t1,t1,-36
        beqz t1,end    # check if it's the null character
	addi t0,t0,1  #increment the charactter pointer
	addi t2,t2,1  #increment the counter
	j agn	
end:	
	mv s11,t2    #Getting the return value
	#####re Registers from the Sack####################
	ld t0,0(sp)
	ld t1,8(sp)
	ld t2,16(sp)
	ld ra,24(sp)	
	addi sp,sp,32
	###################################################
	jr ra #Return to the main Program

#define ROTR(x,n) (((x)>>(n))|((x)<<(64-(n))))
#########################################################################################################   
      #RotateRight(x,n)=RotateRight(a0,a1)
      #this function rotates the register x by n number 
RotateRight:  addi sp,sp,-16
              sd   t0,0(sp)
              sd   t1,8(sp)
              
              add t0,zero,a0
              srl a0,a0,a1  #(x)>>(n)
              addi t1 ,zero,64
              sub t1,t1,a1 
              sll t0,t0,t1  # (x)<<64-(n)
              or a0,a0,t0    #(((x)>>(n))|((x)<<(64-(n))))
              ld   t0,0(sp)
              ld   t1,8(sp)
              addi sp,sp,16
              jalr zero ,ra
           #return value in a0
######################################################################
######################################################################
#define EXT_BYTE64(x,n) ((u8)((u64)(x)>>(8*(7-(n)))))
   #EXT_BYTE6432(x,n)=EXT_BYTE6432(a0,a1)
   #this function shift right the register x by 8*(3-n) and cut the lowest byte
EXT_BYTE64: addi sp,sp,-8
            sd   t0,0(sp)
            addi t0,zero,7
            sub a1,t0,a1   #(7-(n)
            li a5,8
            mul a1,a1,a5     #8*(7-(n)
            srl a0,a0,a1  #(x)>>(8*(7-(n))
            
            ld  t0,0(sp) 
            addi sp,sp,8	
           jalr zero ,ra
      #return value in a0
######################################################################################     
#define INS_BYTE64(x,n) ((u64)(x)<<(8*(7-(n))))       
#INS_BYTE6432(x,n)=INS_BYTE6432(a0,a1)
#this function shift left register x by 8*(3-(n)) 
INS_BYTE64: 
	    addi sp,sp,-8
            sd   t0,0(sp)
       	    addi t0,zero,7   #(7-(n))
            sub a1,t0,a1
            li a5,8
            mul a1,a1,a5   #8*(7-(n))
            sll a0,a0,a1  #(x)<<(8*(7-(n))
            ld  t0,0(sp) 
            addi sp,sp,8          
            jalr zero ,ra
   # return in a0
###############################################################################################
###############################################################################################
#define U64BIG(x) \
#   ((ROTR(x, 8) & (0xFF000000FF000000ULL)) | \
#   (ROTR(x,24) & (0x00FF000000FF0000ULL)) | \
#   (ROTR(x,40) & (0x0000FF000000FF00ULL)) | \
#  (ROTR(x,56) & (0x000000FF000000FFULL)))
#endif
#u32BIG(a0)

#u64BIG(a0)
#this function converts register x to big endian 
 U64BIG :      addi sp,sp,-32              
               sd   t0,0(sp)
               sd   t1,8(sp)
               sd   t2,16(sp)
	       sd   ra,24(sp)    
	       addi a1,zero,8
	       add t2,zero,a0 #store  value of x in t2
	       jal RotateRight  #ROTR64(x,  8) 
	       li t0,0xFF000000FF000000  #(0xFF000000FF000000ULL))
                
               and a0,a0,t0 #((ROTR(x, 8) & (0xFF000000FF000000ULL))
	      ##############################################################  
              addi a1,zero,24
	        add t1,zero,a0 # store value of ((ROTR(x, 8) & (0xFF000000FF000000ULL)) in  
               add a0,zero,t2 
	       jal RotateRight  #ROTR32(x, 24)
	        li t0,0x00FF000000FF0000  #(0xFF000000FF000000ULL))
               
               and a0,a0,t0  #(ROTR(x,24) & (0x00FF000000FF0000ULL))
               or t1,a0,t1   
               #############################################################
                addi a1,zero,40
               add a0,zero,t2 
	       jal RotateRight  #ROTR32(x, 40)
	        li t0,0x0000FF000000FF00  #(0xFF000000FF000000ULL))
                and a0,a0,t0  #(ROTR(x,40) & (0x0000FF000000FF00ULL))
               or t1,a0,t1  
               ######################################################################### 
               addi a1,zero,56  
               add a0,zero,t2 
	       jal RotateRight  #ROTR32(x, 24)
	        li t0,0x000000FF000000FF  #(0xFF000000FF000000ULL))
                 
               and a0,a0,t0  #  (ROTR(x,56) & (0x000000FF000000FFULL)))
               or a0,a0,t1   #return
               ld   t0,0(sp)
               ld   t1,8(sp)
               ld   t2,16(sp)
               ld  ra,24(sp)
		addi sp,sp,32
		jr ra
#############################################

#############################
	ROUND64:# takes only a0
	#s0=x0
	#s1=x1
	#s2=x2
	#s3=x3
	#s4=x4
	
	#t0=t0
	#t1=t1
	#t2=t2
	#t3=t3
	#t4=t4
	addi sp,sp,-56
	sd  t0,0(sp)
	sd  t1,8(sp)
	sd  t2,16(sp)
	sd  t3,24(sp)
	sd  t4,32(sp)
        sd t5,40(sp)
	sd  ra,48(sp)

	#Round Constant Layer#
	xor s2,s2,a0 #x2 ^= C;

	
	#S-Box layer#
xor s0,s0,s4#x0 ^= x4
xor s4,s4,s3 #    x4 ^= x3 
xor s2,s2,s1 #     x2 ^= x1
    #t0 = x0;\
    #t4 = x4;\
    #t3 = x3;\
    #t1 = x1;\
    #t2 = x2;\
    addi t0,s0,0
    addi t1,s1,0
    addi t2,s2,0
    addi t3,s3,0
    addi t4,s4,0
    not t5,s1
    #x0 = t0 ^ ((~t1) & t2)
    not t5,t1
    and t5,t5,t2
    xor s0,t0,t5     
    #x2 = t2 ^ ((~t3) & t4);\
    not t5,t3
    and t5,t5,t4
    xor s2,t2,t5 
    #x4 = t4 ^ ((~t0) & t1);\
    not t5,t0
    and t5,t5,t1
    xor s4,t4,t5 
    #x1 = t1 ^ ((~t2) & t3);\
    not t5,t2
    and t5,t5,t3
    xor s1,t1,t5 
    #x3 = t3 ^ ((~t4) & t0);\
    not t5,t4
    and t5,t5,t0
    xor s3,t3,t5 
    # x1 ^= x0;\
    #t1  = x1;\
    #x1 = ROTR(x1, R[1][0]);\ 
    xor t1,s1,s0
    addi a0,t1,0
    addi a1,zero,39
    jal RotateRight 
    addi s1,a0,0   
    # x3 ^= x2;\
    #t2  = x2;\
    #x2 = ROTR(x2, R[2][0]);\
    xor s3,s3,s2
    addi t2,s2,0
    addi a0,t2,0
    addi a1,zero,1
    jal RotateRight 
    addi s2,a0,0   
    #t4  = x4;\
    #t2 ^= x2;\
    #x2 = ROTR(x2, R[2][1] - R[2][0]);\
    addi t4,s4,0
    xor t2,t2,s2
    addi a0,s2,0
    addi a1,zero,5
    jal RotateRight 
    addi s2,a0,0
    #t3  = x3;\
    #t1 ^= x1;\
    #x3 = ROTR(x3, R[3][0]);\ 
    addi t3,s3,0
    xor t1,t1,s1
    addi a0,s3,0
    addi a1,zero,10
    jal RotateRight 
    addi s3,a0,0
    #x0 ^= x4;\
    #x4 = ROTR(x4, R[4][0]);\
   xor s0,s0,s4
   addi a0,s4,0
   addi a1,zero,7
   jal RotateRight
   addi s4,a0,0
   # t3 ^= x3;\
   # x2 ^= t2;\
   # x1 = ROTR(x1, R[1][1] - R[1][0]);\
   xor t3,t3,s3
   xor s2,s2,t2
   addi a0,s1,0
   addi a1,zero,22
   jal RotateRight
   addi s1,a0,0
   #t0  = x0;\
   #x2 = ~x2;\
   #x3 = ROTR(x3, R[3][1] - R[3][0]);\
   addi t0,s0,0
   not s2,s2
   addi a0,s3,0
   addi a1,zero,7
   jal RotateRight
   addi s3,a0,0
   #t4 ^= x4;\
   #x4 = ROTR(x4, R[4][1] - R[4][0]);\
   xor t4,t4,s4
   addi a0,s4,0
   addi a1,zero,34
   jal RotateRight
   addi s4,a0,0
  # x3 ^= t3;\
  # x1 ^= t1;\
  # x0 = ROTR(x0, R[0][0]);\
   xor s3,s3,t3
    xor s1,s1,t1
    addi a0,s0,0
   addi a1,zero,19
   jal RotateRight
   addi s0,a0,0
  # x4 ^= t4;\
  #  t0 ^= x0;\
  #  x0 = ROTR(x0, R[0][1] - R[0][0]);\
  #  x0 ^= t0;\
   xor s4,s4,t4
    xor t0,s0,t0
    addi a0,s0,0
   addi a1,zero,9
   jal RotateRight
   addi s0,a0,0
   xor s0,s0,t0
	
#Return#
	ld  t0,0(sp)
	ld  t1,8(sp)
	ld  t2,16(sp)
	ld  t3,24(sp)
	ld  t4,32(sp)
        ld t5,40(sp)
	ld  ra,48(sp)
	addi sp,sp,56
	jr ra
	
##################################################################################
  
  #premutation 12 #
	P12_64: 
	addi sp,sp,-16
	sd   a0,0(sp)
	sd   ra,8(sp)
	
	li a0,0xf0
	jal ROUND64
	
	li a0,0xe1
	jal ROUND64
	
	li a0,0xd2
	jal ROUND64
	
	li a0,0xc3
	jal ROUND64
	
	li a0,0xb4
	jal ROUND64
	
	li a0,0xa5
	jal ROUND64
	
	li a0,0x96
	jal ROUND64
	
	li a0,0x87
	jal ROUND64
	
	li a0,0x78
	jal ROUND64
	
	li a0,0x69
	jal ROUND64
	
	li a0,0x5a
	jal ROUND64
	
	li a0,0x4b
	jal ROUND64
	
	
	ld   a0,0(sp)
	ld   ra,8(sp)
	addi sp,sp,16
	jr ra
	
	##################################################################################
	#premutation 16 #
	P6_64:
	
	addi sp,sp,-16
	sd   a0,0(sp)
	sd   ra,8(sp)
  
  	li a0,0x96
	jal ROUND64
	
	li a0,0x87
	jal ROUND64
	
	li a0,0x78
	jal ROUND64
	
	li a0,0x69
	jal ROUND64
	
	li a0,0x5a
	jal ROUND64
	
	li a0,0x4b
	jal ROUND64
	
  
        ld   a0,0(sp)
	ld   ra,8(sp)
	addi sp,sp,16
	jr ra
	
	
	##################################################################################
	
##############################initialiazion########################################
initialization:
        addi sp,sp,-32
	sd  t6,0(sp)
	sd  a7,8(sp)
	sd  t5,16(sp)
	sd  ra,24(sp)
###################################################################################
	la a7,k
	la t6,npub
	li s0,0x80400c0600000000
	ld a0,0(a7) #x1 = K0;
        jal U64BIG
	add s1,a0,0
	addi s5,s1,0
       ld a0,8(a7) #x1 = K0;
        jal U64BIG
	add s2,a0,0
        addi s6,s2,0
	ld a0,0(t6) #x1 = K0;
	jal U64BIG
	add s3,a0,0
	ld a0,8(t6) #x1 = K0;
	jal U64BIG
	add s4,a0,0
	#ld s1,0(a7) #x1 = K0;
	#ld s2,8(a7) 
	#ld s3,0(t6) #x3 = N0;
	#ld s4,8(t6)
	jal P12_64
	xor s3,s3,s5 #x3 ^= K0;
	xor s4,s4,s6 #x4 ^= K1;
###################################################################################
	ld  t6,0(sp)
	ld  a7,8(sp)
	ld  t5,16(sp)
	ld  ra,24(sp)
	addi sp,sp,32
	jr ra
##########################################################
associated:
        addi sp,sp,-72
	sd  t0,0(sp)
	sd  t1,8(sp)
	sd  t2,16(sp)
	sd  t3,24(sp)
	sd  t4,32(sp)
	sd  t5,40(sp)	
	sd  t6,48(sp)
	sd  a7,56(sp)
	sd  ra,64(sp)
####################################################################	
	la a7,associated_data
	addi a0,a7,0
	jal strlen
	beqz s11,end_ad	
	####################################################
	add s10,s11,0
while_loop:
	li a5,8
	blt  s10,a5,cont0#  while (rlen >= RATE) , RATE= 8 bytes
	
		ld a0,0(a7)
		jal U64BIG
		xor s0,s0,a0
		jal P6_64
		
		addi a7,a7,8  
		addi s10,s10,-8 #rlen -= a5
	
	j while_loop
cont0:	
	li t4,0 #counter
for_loop:
	bge t4,s10,exit_for  #for (i = 0; i < rlen; ++i, ++ad)
		
		lbu a0,0(a7)
		add a1,t4,0
		jal INS_BYTE64
		xor s0,s0,a0 #x0 ^= INS_BYTE64(*ad, i);
	addi t4,t4,1
	addi a7,a7,1
			
	
	j for_loop

exit_for:
	
	li a0,0x80
	add a1,s10,0
	jal INS_BYTE64
	xor s0,s0,a0
	jal P6_64
end_ad:	
xori s4,s4,1
#########################################
	ld  t0,0(sp)
	ld  t1,8(sp)
	ld  t2,16(sp)
	ld  t3,24(sp)
	ld  t4,32(sp)
	ld  t5,40(sp)	
	ld  t6,48(sp)
	ld  a7,56(sp)
	ld  ra,64(sp)
	addi sp,sp,72
	jr ra

PPTD:    addi sp,sp,-72             
          sd   t0,0(sp)
          sd   t1,8(sp)
          sd   t2,16(sp)
          sd   t3,24(sp)
          sd   t4,32(sp)
          sd   t5,40(sp)
          sd   t6,48(sp)
          sd   a7,56(sp)
          sd   ra,64(sp)
      
        la a0 , PlainText    
	jal strlen     # getting string length and store it in v1
	addi s10,s11,0 # rlen=mlen
	li t5,8      # 8
	li a7,0      # counter for plaintext address 
        la t6,cipherText      # counter for ciphertext
      la a7 , PlainText

loop1 : bltu s10,t5,next1 #while (rlen >= 8)
       ld a0,0(a7) # first 64-bit block of a (a[0])
      addi a7,a7,8        #pointer ++ 
      jal U64BIG
       xor s0,s0,a0 #U64BIG(x0) ^ *(u64*)c;
       add a0,s0,0
        jal U64BIG
        sd  a0,0(t6)    
        addi t6,t6,8
         jal P6_64	
        addi s10,s10,-8 #rlen -= 8;
        j loop1
         
##############################################
next1: 
       li t0,0   # i ,s6->ciphertext , ,s7->plaintext
loop2 : bgeu t0,s10,next2  # for (i = 0; i < rlen; ++i, ++m) 
        lbu a0,0(a7) #*m
        addi a7,a7,1 #pointer++
        add a1,zero,t0 
        jal INS_BYTE64  #INS_BYTE64(*m, i)
        xor s0,s0,a0  #x0 ^= INS_BYTE(*m, i);
        add a0,zero,s0 
        add a1,zero,t0 
        jal EXT_BYTE64
        sb a0,0(t6)
        addi t6,t6,1 #pointer++ 
      addi t0,t0,1 #i++
             j loop2        
################################################################33
        
next2:   li a0,0x80
	add a1,s10,0
	jal INS_BYTE64
	xor s0,s0,a0
           ld   t0,0(sp)
          ld   t1,8(sp)
          ld   t2,16(sp)
          ld   t3,24(sp)
          ld   t4,32(sp)
          ld   t5,40(sp)
          ld   t6,48(sp)
          ld   a7,56(sp)
          ld   ra,64(sp)
         addi sp,sp,72      
         jalr zero ,ra  
   ##############################################################
Finalization:
	addi sp,sp,-8
	sd   ra,0(sp)

	la a7,k
	ld a0,0(a7)
        jal U64BIG
        addi t0,a0,0
	ld a0,8(a7)
	jal U64BIG
        addi t1,a0,0
        
	xor s1,s1,t0
	xor s2,s2,t1
	
	jal P12_64
	
	xor s3,s3,t0
	xor s4,s4,t1
        
        la a4,cipherText  
        li a1,8    # gp = a4+s11 + [8 - (s11 mod 8 )] 
        
       REMU a0,s11,a1  # s11 mod 8
        sub a1,a1,a0   #[8 - (s11 mod 8 )]
        add gp,s11,a1 #s11 + [8 - (s11 mod 8 )] 
	add gp,gp,a4
       add a0,s3,0
        jal U64BIG
        sd  a0,0(gp)
        add a0,s4,0
	jal U64BIG
        sd  a0,8(gp)  
	
       ld ra,0(sp)
	addi sp,sp,8
	jr ra
