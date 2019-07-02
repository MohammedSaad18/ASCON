.data
        PlainText: .ascii "Fantastic Three, 5od fekra we eshtry bokra$"      
        .align 2
        npub: .word 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 # key is 128 bit saved in array of word boundaries 
        .align 2
         associated_data: .ascii "23115151$"
      .align 2  
        k: .word 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 #nouns length is 128 bit
     .align 2   
     cipherText : .space 

.macro U32BIG x

rem \x,zero,\x

.endm

.macro RotateRight x,n

sltiu \x,\x,\n

.endm

.macro NotAnd x,y,z

Div \x,\y,\z

.endm

.macro EXPAND_U32 x,y,z
slt \x,\y,\z
.endm

.macro COMPRESS_LONG x

slti \x,\x,0

.endm


.text
.align 2
.global main
.type main , @function
main:
la a0 ,PlainText
jal initialization
jal associated
jal PPTD
jal Finalization
addiw sp,sp,-40
sw s0,0(sp)
sw s1,4(sp)
sw s2,8(sp)
sw s3,12(sp)
sw s4,16(sp)
sw s5,20(sp)
sw s6,24(sp)
sw s7,28(sp)
sw s8,32(sp)
sw s9,36(sp)
  li a0, 0
        li a1, 0
        li a2, 0
        li a3, 0
        li a7, 93                   # _NR_sys_exit
        ecall                       # system call

strlen:
	######Saving Registers to The Stack###############
	addiw sp,sp,-16
	sw   t0,0(sp)
	sw   t1,4(sp)
	sw   t2,8(sp)
	sw   ra,12(sp)
	##################################################
	
	mv t0,a0 #getting the addwress of the Text
	mv t2,zero #initialize the Counter
	#For Loop#
agn:	lbu   t1,0(t0) #load the next character from the string
	addiw t1,t1,-36
        beqz t1,end    # check if it's the null character
	addiw t0,t0,1  #increment the charactter pointer
	addiw t2,t2,1  #increment the counter
	j agn	
end:	
	mv s11,t2    #Getting the return value
	#####re Registers from the Sack####################
	lw t0,0(sp)
	lw t1,4(sp)
	lw t2,8(sp)
	lw ra,12(sp)	
	addiw sp,sp,16
	###################################################
	jr ra #Return to the main Program
#########################################################################################
#############################
	ROUND32:
	addiw sp,sp,-24
	sw   t0,0(sp)
	sw   t1,4(sp)
	sw   t2,8(sp)
	sw   t3,12(sp)
	sw  t5,16(sp)
	sw   ra,20(sp)

	#Round Constant Layer#
	xor s4,s4,a0 #x2_e ^= C_e
	xor s5,s5,a1 #x2_o ^= C_o
	#####################################################################
	
	#S-Box layer#
	xor t0,s0,s8 # t0_e = x0_e ^ x4_e
	xor t2,s8,s6 # t1_e = x4_e ^ x3_e
	xor s4,s4,s2 # x2_e = x2_e ^ x1_e
	
	xor t1,s1,s9 # t0_o = x0_o ^ x4_o
	xor t3,s9,s7 # t1_o = x4_o ^ x3_o
	xor s5,s5,s3 # x2_o = x2_o ^ x1_o
	
	#not t5,s2
	#and s0,s4,t5 # x0_e = x2_e & (~x1_e)
	NotAnd s0,s2,s4
	xor s0,t0,s0 # x0_e = t0_e ^ x0_e
	
	#not t5,s3
	#and s1,s5,t5 # x0_o = x2_o & (~x1_o)
	NotAnd s1,s3,s5
	xor s1,t1,s1 # x0_o = t0_o ^ x0_o
	
	#not t5,s2
	#and s8,s4,t5 # x4_e = x2_e & (~x1_e)
	NotAnd s8,s2,s4
	xor s8,s0,s8 #  x4_e = x0_e ^ x4_e
	
	#not t5,s3
	#and s9,s5,t5 #  x4_o = x2_o & (~x1_o)
	NotAnd s9,s3,s5
	xor s9,s1,s9 #  x4_o = x0_o ^ x4_o
	
	#not t5,s8
	#and s8,s2,t5 # x4_e = x1_e & (~x4_e)
	NotAnd s8,s8,s2
	xor s8,s8,t2 # x4_e = x4_e ^ t1_e
	
	#not t5,s9
	#and s9,s3,t5 # x4_o = x1_o & (~x4_o)
	NotAnd s9,s9,s3
	xor s9,s9,t3 # x4_o = x4_o ^ t1_o
	
	#not t5,s2
	#and t0,s4,t5 # t0_e = x2_e & (~x1_e)
	NotAnd t0,s2,s4
	xor t0,t0,s0 # t0_e = t0_e ^ x0_e
	
	#not t5,s3
	#and t1,s5,t5 # t0_o = x2_o & (~x1_o)
	NotAnd t1,s3,s5
	xor t1,t1,s1 # t0_o = t0_o ^ x0_o
	
	#not t5,t2
	#and t0,t0,t5 #  t0_e = t0_e & (~t1_e)
	NotAnd t0,t2,t0
	xor t0,t0,s6 #  t0_e = t0_e ^ x3_e
	
	#not t5,t3
	#and t1,t1,t5 #  t0_o = t0_o & (~t1_o)
	NotAnd t1,t3,t1
	xor t1,t1,s7 #  t0_o = t0_o ^ x3_o
	
	#not t5,s2
	#and t2,s4,t5 # t1_e = x2_e & (~x1_e)
	NotAnd t2,s2,s4
	xor t2,t2,s0 # t1_e = t1_e ^ x0_e
	
	#not t5,s3
	#and t3,s5,t5 # t1_o = x2_o & (~x1_o)
	NotAnd t3,s3,s5
	xor t3,t3,s1 # t1_o = t1_o ^ x0_o
	
	#not t5,t2
	#and t2,s2,t5 # t1_e = x1_e & (~t1_e)
	NotAnd t2,t2,s2
	xor t2,t2,s8 # t1_e = t1_e ^ x4_e
	
	#not t5,t3
	#and t3,s3,t5 # t1_o = x1_o & (~t1_o)
	NotAnd t3,t3,s3
	xor t3,t3,s9 # t1_o = t1_o ^ x4_o
	
	#not t5,s6
	#and t2,t2,t5 #  t1_e = t1_e & (~x3_e)
	NotAnd t2,s6,t2
	xor t2,t2,s4 #  t1_e = t1_e ^ x2_e
	
	#not t5,s7
	#and t3,t3,t5 #  t1_o = t1_o & (~x3_o)
	NotAnd t3,s7,t3
	xor t3,t3,s5 #  t1_o = t1_o ^ x2_o
	
	#not t5,s4
	#and s4,s6,t5#  x2_e = x3_e & (~x2_e)
	NotAnd s4,s4,s6
	xor s2,s2,s4  #  x1_e = x1_e ^ x2_e
	
	#not t5,s5
	#and s5,s7,t5 # x2_o = x3_o & (~x2_o)
	NotAnd s5,s5,s7
	xor s3,s3,s5 #  x1_o = x1_o ^ x2_o
	
	xor s2,s2,s0 # x1_e = x1_e ^ x0_e
	xor s0,s0,s8 # x0_e = x0_e ^ x4_e
	xor s6,t0,t2 # x3_e = t0_e ^ t1_e
	not s4,t2     # x2_e =~ t1_e
	
	xor s3,s3,s1 # x1_o = x1_o ^ x0_o
	xor s1,s1,s9 # x0_o = x0_o ^ x4_
	xor s7,t1,t3 # x3_o = t0_o ^ t1_o
	not s5,t3
	##################################################################################################
	#Linear Layer#
	mv t0,s0 # t0_e  = x0_e
	mv t1,s1 # t0_o  = x0_o
	mv t2,s2 # t1_e  = x1_e
	mv t3,s3 # t1_o  = x1_o
	
	mv a0,t1
	RotateRight a0,9
	mv t5,a0
	#ror t5,t1,9
	xor s0,s0,t5 # x0_e ^= ROTR32(t0_o, R_O[0][0])
	
	mv a0,t0
	RotateRight a0,10
	mv t5,a0
	#ror t5,t0,10
	xor s1,s1,t5 # x0_o ^= ROTR32(t0_e, R_E[0][0])
	
	mv a0,t3
	RotateRight a0,19
	mv t5,a0
	#ror t5,t3,19
	xor s2,s2,t5 #  x1_e ^= ROTR32(t1_o, R_O[1][0])
	
	mv a0,t2
	RotateRight a0,20
	mv t5,a0	
	#ror t5,t2,20
	xor s3,s3,t5 # x1_o ^= ROTR32(t1_e, R_E[1][0])
	
	mv a0,t0
	RotateRight a0,14
	mv t5,a0	
	#ror t5,t0,14
	xor s0,s0,t5 # x0_e ^= ROTR32(t0_e, R_E[0][1])
	
	mv a0,t1
	RotateRight a0,14
	mv t5,a0	
	#ror t5,t1,14
	xor s1,s1,t5 # x0_o ^= ROTR32(t0_o, R_O[0][1])
	
	mv a0,t3
	RotateRight a0,30
	mv t5,a0	
	#ror t5,t3,30
	xor s2,s2,t5 # x1_e ^= ROTR32(t1_o, R_O[1][1])
	
	mv a0,t2
	RotateRight a0,31
	mv t5,a0	
	#ror t5,t2,31
	xor s3,s3,t5 # x1_o ^= ROTR32(t1_e, R_E[1][1])
	
	mv t0,s4 #  t0_e  = x2_e
	mv t1,s5 # t0_o  = x2_o
	mv t2,s6 # t1_e  = x3_e
	mv t3,s7 # t1_o  = x3_o

	mv a0,t1
	RotateRight a0,0
	mv t5,a0		
	#ror t5,t1,0
	xor s4,s4,t5 # x2_e ^= ROTR32(t0_o, R_O[2][0])
	
	mv a0,t0
	RotateRight a0,1
	mv t5,a0	
	#ror t5,t0,1
	xor s5,s5,t5 #  x2_o ^= ROTR32(t0_e, R_E[2][0])

	mv a0,t2
	RotateRight a0,5
	mv t5,a0		
	#ror t5,t2,5
	xor s6,s6,t5 # x3_e ^= ROTR32(t1_e, R_E[3][0])

	mv a0,t3
	RotateRight a0,5
	mv t5,a0		
	#ror t5,t3,5
	xor s7,s7,t5 # x3_o ^= ROTR32(t1_o, R_O[3][0])

	mv a0,t0
	RotateRight a0,3
	mv t5,a0		
	#ror t5,t0,3
	xor s4,s4,t5 # x2_e ^= ROTR32(t0_e, R_E[2][1])

	mv a0,t1
	RotateRight a0,3
	mv t5,a0		
	#ror t5,t1,3
	xor s5,s5,t5 # x2_o ^= ROTR32(t0_o, R_O[2][1])

	mv a0,t3
	RotateRight a0,8
	mv t5,a0		
	#ror t5,t3,8
	xor s6,s6,t5 # x3_e ^= ROTR32(t1_o, R_O[3][1])

	mv a0,t2
	RotateRight a0,9
	mv t5,a0		
	#ror t5,t2,9
	xor s7,s7,t5 # x3_o ^= ROTR32(t1_e, R_E[3][1])
	
	mv t0,s8 # t0_e  = x4_e
	mv t1,s9 # t0_o  = x4_o

	mv a0,t1
	RotateRight a0,3
	mv t5,a0		
	#ror t5,t1,3
	xor s8,s8,t5 # x4_e ^= ROTR32(t0_o, R_O[4][0])

	mv a0,t0
	RotateRight a0,4
	mv t5,a0		
	#ror t5,t0,4
	xor s9,s9,t5 # x4_o ^= ROTR32(t0_e, R_E[4][0])
	
	mv a0,t1
	RotateRight a0,20
	mv t5,a0	
	#ror t5,t1,20
	xor s8,s8,t5 # x4_e ^= ROTR32(t0_o, R_O[4][1])
	
	mv a0,t0
	RotateRight a0,21
	mv t5,a0	
	#ror t5,t0,21
	xor s9,s9,t5 # x4_o ^= ROTR32(t0_e, R_E[4][1])
	#################################################################################
	#Return#
	lw  t0,0(sp)
	lw  t1,4(sp)
	lw  t2,8(sp)
	lw  t3,12(sp)
	lw  t5,16(sp)
	lw  ra,20(sp)
	addw sp,sp,24
	jr ra
	
##################################################################################
#premutation 12 #
	P12_32: 
	addiw sp,sp,-12
	sw   a0,0(sp)
	sw   a1,4(sp)
	sw   ra,8(sp)
	
	li a0,0xc
	li a1,0xc
	jal ROUND32
	
	li a0,0x9
	li a1,0xc
	jal ROUND32
	
	li a0,0xc
	li a1,0x9
	jal ROUND32
	
	li a0,0x9
	li a1,0x9
	jal ROUND32
	
	li a0,0x6
	li a1,0xc
	jal ROUND32
	
	li a0,0x3
	li a1,0xc
	jal ROUND32
	
	li a0,0x6
	li a1,0x9
	jal ROUND32
	
	li a0,0x3
	li a1,0x9
	jal ROUND32
	
	li a0,0xc
	li a1,0x6
	jal ROUND32
	
	li a0,0x9
	li a1,0x6
	jal ROUND32
	
	li a0,0xc
	li a1,0x3
	jal ROUND32
	
	li a0,0x9
	li a1,0x3
	jal ROUND32
	
	lw   a0,0(sp)
	lw   a1,4(sp)
	lw   ra,8(sp)
	addiw sp,sp,12
	jr ra
	##################################################################################
	#premutation 16 #
	P6_32:
	
	addiw sp,sp,-12
	sw   a0,0(sp)
	sw   a1,4(sp)
	sw   ra,8(sp)
	
	li a0,0x6
	li a1,0x9
	jal ROUND32
	
	li a0,0x3
	li a1,0x9
	jal ROUND32
	
	li a0,0xc
	li a1,0x6
	jal ROUND32
	
	li a0,0x9
	li a1,0x6
	jal ROUND32
	
	li a0,0xc
	li a1,0x3
	jal ROUND32
	
	li a0,0x9
	li a1,0x3
	jal ROUND32
		
	
	lw   a0,0(sp)
	lw   a1,4(sp)
	lw   ra,8(sp)
	addiw sp,sp,12
	jr ra

  

#########################################################################################################    
   #EXT_BYTE32(x,n)=EXT_BYTE32(a0,a1)
   #this function shift right the register x by 8*(3-n) and cut the lowest byte
EXT_BYTE32: addiw sp,sp,-4
            sw   t0,0(sp)
            addiw t0,zero,3
            subw a1,t0,a1   #(3-(n)
            li a5,8
            mul a1,a1,a5     #8*(3-(n)
            srlw a0,a0,a1  #(x)>>(8*(3-(n))
            lw  t0,0(sp) 
	            addiw sp,sp,4	
           jalr zero ,ra
      #return value in a0
######################################################################################            
#INS_BYTE32(x,n)=INS_BYTE32(a0,a1)
#this function shift left register x by 8*(3-(n)) 
INS_BYTE32: 
	    addiw sp,sp,-4
            sw   t0,0(sp)
    	    addiw t0,zero,3   #(3-(n))
            subw a1,t0,a1
            li a5,8
            mul a1,a1,a5   #8*(3-(n))
            sllw a0,a0,a1  #(x)<<(8*(3-(n))
            lw  t0,0(sp) 
            addiw sp,sp,4          
            jalr zero ,ra
   # return in a0
###############################################################################################
#EXPAND_SHORT(x)=EXPAND_SHORT(a0)
# the function expands 16 bit register to 32 bit register 
EXPAND_SHORT : addiw sp,sp,-12              
               sw   t0,0(sp)
               sw   t1,4(sp)
               sw   t2,8(sp)    
               li t0,0xffff
               and a0,a0,t0  #x &= 0x0000ffff;
               addw t1,zero,a0 
               slliw t1,t1,8	#(x << 8)	
               or a0,a0,t1   #(x | (x << 8))
               li t2,0x00ff00ff   # 0x00ff00ff

               and a0,a0,t2 #x = (x | (x << 8)) & 0x00ff00ff;
               addw t1,zero,a0
               slliw t1,t1,4		
               or a0,a0,t1
               li t2,0x0f0f0f0f
    
               and a0,a0,t2  #x = (x | (x << 4)) & 0x0f0f0f0f;
               addw t1,zero,a0
               slliw t1,t1,2		
               or a0,a0,t1
               li t2,0x33333333
               and a0,a0,t2   # x = (x | (x << 2)) & 0x33333333;
               addw t1,zero,a0
               slliw t1,t1,1		
               or a0,a0,t1
               li t2,0x55555555
               and a0,a0,t2  #x = (x | (x << 1)) & 0x55555555;
               lw   t0,0(sp)
               lw   t1,4(sp)
               lw   t2,8(sp)
               addiw sp,sp,12  
               jalr zero ,ra
               #retrun value in a0


################################################################
# COMPRESS_U32(var,var_o,var_e)= COMPRESS_U32(a0,a1,a2)
#this function compresses 32 bit register and divides it into 2 16-bit registers (var_o and var_e)
COMPRESS_U32:addiw sp,sp,-4
	     sw   ra,0(sp)
	     srliw a1,a0,1   
           COMPRESS_LONG a0
            addw a2,zero,a0
            addw a0,zero,a1
           COMPRESS_LONG a0
            addw a1,zero,a0
            lw  ra,0(sp)
	    addw sp,sp,4
            jalr zero ,ra 
 
     # return two values var_0->a1 and var_e->a2
 ##################################################################
#COMPRESS_BYTE_ARRAY(a,var_o,var_e)=COMPRESS_BYTE_ARRAY(a0,a1,a3,a2)
#a3-> var_o and  a2->var_e  (a))[1]-> a1  (a)[0]->a0
#this function divides 64 bit block in a0,a1 into two 32 bit registers one is even (a2) and other is odd(a3)
COMPRESS_BYTE_ARRAY: addiw sp,sp,-20
                     sw   t0,0(sp)
                     sw   t1,4(sp)
                     sw   t2,8(sp)
                     sw   t3,12(sp)
                     sw   ra,16(sp)
	             addw t3,zero,a1
	             U32BIG a0   #t1_e = U32BIG(((u32*)(a))[0]);
	             addw a1,zero,t3 
	             srliw a3,a0,1   #t1_o = t1_e >> 1;
	             COMPRESS_LONG a0 #COMPRESS_LONG(t1_e)
	             slliw a2,a0,16    #t1_e << 16;
	             addw a0,zero,a3
                     COMPRESS_LONG a0 #COMPRESS_LONG(t1_o);
                     slliw a3,a0,16    #t1_o << 16
                     addw t0,zero,a2
                     addw t1,zero,a3
                     U32BIG a1	  #var_e = U32BIG(((u32*)(a))[1]);
                     addw a2,zero,t0
                     addw a3,zero,t1
	             srliw t2,a1,1  #var_o = var_e >> 1;
	             COMPRESS_LONG a1 #COMPRESS_LONG(var_e);
	             or a2,a2,a1 #var_e |= t1_e << 16;
	             addw a0,zero,t2
                     COMPRESS_LONG a0 #COMPRESS_LONG(var_o);
               	     or a3,a3,a0 #var_o |= t1_o << 16;
        	     lw t0,0(sp)
		     lw t1,4(sp)
		     lw t2,8(sp)
		     lw t3,12(sp)
		     lw   ra,16(sp)
		     addiw sp,sp,20           
	 	     jalr zero ,ra
	#return two values a3-> var_o and  a2->var_e
initialization:
	addiw sp,sp,-4
	sw ra , 0(sp)
	la a7,k	 # load the addwres of the 1st byte of the key in a7
	la t6,npub	 # load the addwres of the 1st byte of the nouns in a7
	
	# COMPRESS_BYTE_ARRAY(k,K0_o,K0_e) 
	lw a0,0(a7)
	lw a1,4(a7)	
	jal COMPRESS_BYTE_ARRAY
	addw t0,a2,0
	addw t1,a3,0
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw a0,8(a7)
	lw a1,12(a7)	
	jal COMPRESS_BYTE_ARRAY
	addw t2,a2,0
	addw t3,a3,0
	
	# COMPRESS_BYTE_ARRAY(npub,N0_o,N0_e)
	lw a0,0(t6)
	lw a1,4(t6)	
	jal COMPRESS_BYTE_ARRAY
	addiw s6,a2,0 # x3_e = N0_e;
	addiw s7,a3,0 # x3_o = N0_o;
	
	#  COMPRESS_BYTE_ARRAY(npub+8,N1_o,N1_e)
	lw a0,8(t6)
	lw a1,12(t6)	
	jal COMPRESS_BYTE_ARRAY
	addiw s8,a2,0# x4_e = N1_e;
	addiw s9,a3,0# x4_o = N1_o;
	

	li s0,0x80400c06#  t1_e = (u32)((CRYPTO_KEYBYTES * 8) << 24 | (8 * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0);
	srlw  s1,s0,1 #t1_o = t1_e >> 1
		
	#COMPRESS_LONG(t1_e) #t1_e = t2 and compress long takes and return a0 
	addiw a0,s0,0	
	COMPRESS_LONG a0
	addiw s0,a0,0
	
	# COMPRESS_LONG(t1_o)#t1_o = t3 and compress long takes and return a0 
	addiw a0,s1,0
	COMPRESS_LONG a0
	addiw s1,a0,0	
	
	slliw s0,s0,16	#x0_e = t1_e << 16
	slliw s1,s1,16	#x0_o = t1_o << 16
	addiw s2,t0,0	#x1_o = K0_o
	addiw s3,t1,0	#x1_e = K0_e
	addiw s4,t2,0	#x2_e = K1_e
	addiw s5,t3,0	#x2_o = K1_o
	jal P12_32
         	
        xor s6,s6,t0	#x3_e ^= K0_e
	xor s7,s7,t1	#x3_o ^= K0_o
	xor s8,s8,t2 #x4_e ^= K1_e
	xor s9,s9,t3	#x4_o ^= K1_o 
lw   ra,0(sp)
addiw sp,sp,4
 jalr zero ,ra	
####################################################################################################
associated:
addiw sp,sp,-4
sw ra , 0(sp)
la a7,associated_data #load the addwress of associated data (pointer ad in the c code)
addiw a0,a7,0 #put the addwress in a0 to make it as input for strlen function
jal strlen # reterns the length of the associated data in v1
beqz s11,end_ed #if (adlen) # if  s11= adlen=0 get out of the if and go to end label
addw s10,s11,0 #rlen(s10),#adlen=(s11)

while_loop:   
	  li a5 , 8
         bltu  s10,a5,cont0#  while (rlen >= 8) , 8= 8 bytes
		#load a0 and a1 with bytes of the associate datat array ????? ask hossam???????????????a[0]is the addwres of the first 2 bytes  a[1]the addwres of the second 2 bytes????
		lw a0,0(a7)
		lw a1,4(a7)	
		
		# COMPRESS_BYTE_ARRAY(ad,in_o,in_e);
		# (a))[1]-> a1 ### (a)[0]->a0 #### a3-> var_o ##### a2->var_e  
				
		jal COMPRESS_BYTE_ARRAY# takes the associated data itself (a0,a1)=(ad)and generates (a2,a3)=(in_o,in_e)
		xor s0,s0,a2 #x0_e ^= in_e
		xor s1,s1,a3 #x0_o ^= in_o
		
                jal P6_32
                  
		addiw s10,s10,-8 #rlen -= 8
		addiw a7,a7,8 #ad += 8	
j while_loop
	
cont0:	
	li t2,0# t1_e = 0;
	li t3,0#t1_o = 0;
	
	li t4,0 # $4 is i the counter of the for loop
	
for_loop:	
	bgeu t4,s10,exit_for #for (i = 0; i < rlen; ++i, ++ad) if[ i(t4)>=rlen(s10)] exit the loop
		lbu a0,0(a7)#load the word which ad points to in a0 as the first argument taken by INS_BYTE
		addw a1,t4,0  #load a1 with $v4(i)as the second argument for INS_BYTE32
		 li a5,4
                 bgeu t4,a5,else1 # if(i < 4)		
			jal INS_BYTE32 #INS_BYTE32(*ad, i) we shift bytes of associated data(*ad) i times,then we insert them in t1_0 and t1_e (s0 , s1)
			or t3,t3,a0# the reterned value (shifted ) from INS_BYTE a0 is ored with t1_0 (t1_o |= INS_BYTE32(*ad, i))		
			j cont1
		else1:	#t1_e |= INS_BYTE32(*ad, (i - 4))
			addiw a1,t4,-4
			jal INS_BYTE32
			or t2,t2,a0		
		cont1:
		addiw t4,t4,1# ++i
		addiw a7,a7,1# ++ad		
j for_loop

exit_for:	
		li a0,0x80 #load a0 with 0x80 as the first argument of INS_BYTE32
		addw a1,s10,0 #load a1 with s10(rlen)	as the second argument for INS_BYTE32
		li a5,4
                 bgeu s10,a5,else2 #if(rlen < 4)
               	jal INS_BYTE32
                	or t3,t3,a0#t1_o |= INS_BYTE32(0x80, rlen)
			j cont2		
		else2:#t1_e |= INS_BYTE32(0x80, (rlen - 4))
			addiw a1,s10,-4
                      jal INS_BYTE32
                      or t2,t2,a0
		cont2:	
		
		#COMPRESS_U32(var,var_o,var_e)
		#a0->var  a1->var_o  a2->var_e
		
		#COMPRESS_U32(t1_e,in_o,in_e)
		addw a0,t2,0 # a0(the argument taken by COMPRESS_U32)	= t2 (t1_e)	
              jal COMPRESS_U32
		#move COMPRESS_U32 output in registers so and s1 to reuse them 
		# t0 <------ $in_o
		# t1 <------ $in_e
                addw t0,a1,0 
		addw t1,a2,0
		
		
		#COMPRESS_U32(t1_o,t0_o,t0_e)
		addw a0,t3,0 # a0(the argument taken by COMPRESS_U32)	= t3 (t1_0)
               jal COMPRESS_U32
		#move COMPRESS_U32 output in registers s5 and s5 o reuse them 
		# t5 <------ s0_o
		# t3 <------ s0_e
		
                addw t5,a1,0  
		addw t3,a2,0
		
		#in_o |= t0_o << 16
		slliw t5,t5,16 
		or t0,t0,t5
		#in_e |= t0_e << 16
		slliw t3,t3,16
		or t1,t1,t3
		
		xor s0,s0,t1	#x0_e ^= in_e
		xor s1,s1,t0	#x0_o ^= in_o
		
jal P6_32
end_ed:
xori s8,s8,1 #x4_e ^= 1
lw   ra,0(sp)
addiw sp,sp,4
 jalr zero ,ra
########################end associated data	#####################


######################################Functions#########################################################
PPTD:    addiw sp,sp,-36             
          sw   t0,0(sp)
          sw   t1,4(sp)
          sw   t2,8(sp)
          sw   t3,12(sp)
          sw   t4,16(sp)
          sw   t5,20(sp)
          sw   t6,24(sp)
          sw   a7,28(sp)
          sw   ra,32(sp)
        	  
        la a0,PlainText #getting the addwress of the PlainText
	jal strlen     # getting string length and store it in v1
	addw s10 , zero,s11 # rlen=mlen
	li t5,8      # 8
	li a7,0      # counter for plaintext addwress 
	
        la t6,cipherText      # counter for ciphertext
        la a7 , PlainText
 loop1 : bltu s10,t5,next1 #while (rlen >= 8)
        lw a0,0(a7) # first 32-bit block of a (a[0])
        addiw a7,a7,4        #pointer ++
        lw a1,0(a7) # second 32-bit block of a (a[1])
        addiw a7,a7,4        #pointer++
       
       jal COMPRESS_BYTE_ARRAY #COMPRESS_BYTE_ARRAY(m,in_o,in_e);
      
       xor s0 , s0 ,a2  #x0_e ^= in_e;
        xor s1 , s1 ,a3 #x0_o ^= in_o;
        srliw a0,s0,16   #x0_e>>16
        srliw a1,s1,16  #x0_o>>16
     #EXPAND_U32(var,var_o,var_e)=EXPAND_U32(a0,a1,a0)
	EXPAND_U32 a0,a1,a0 	#EXPAND_U32(t1_e,x0_o>>16,x0_e>>16);
	U32BIG a0      #U32BIG(t1_e);
	
       sw a0,0(t6) #((u32*)c)[0] = U32BIG(t1_e);
	addiw t6,t6,4        # pointer++
	addw a0,zero,s0     
	addw a1,zero,s1     
	
       EXPAND_U32 a0,a1,a0    #EXPAND_U32(t1_e,x0_o,x0_e);
	U32BIG a0       #U32BIG(t1_e);
	
       sw a0,0(t6)  #((u32*)c)[1] = U32BIG(t1_e);
	addiw t6,t6,4   #pointer++
	jal P6_32	#Permutation_6
	subw s10,s10,t5 #rlen -= 8;
	
       j loop1
##############################################
next1: 
       li t0,0   # i ,s6->ciphertext , ,s7->plaintext
       li t3,0     #t1_o=0
       li t4,0     #t1_e=
       li t5,4     # 4
loop2 : bgeu t0,s10,next2  # for (i = 0; i < rlen; ++i, ++m) 
        li a5,4
        bgeu  t0 ,a5,else   #if(i < 4)
        lbu a0,0(a7) #*m
        addiw a7,a7,1 #pointer++
        addw a1,zero,t0 
        jal INS_BYTE32  #INS_BYTE32(*m, i)
        or t3,t3,a0  #t1_o |= INS_BYTE32(*m, i);
        j endloop
  else: lbu a0,0(a7) #*m
        addiw a7,a7,1   #pointer++
        subw a1,t0,t5  #(i - 4)
        jal INS_BYTE32 #INS_BYTE32(*m, (i - 4))
        or t4,t4,a0 #t1_e |= INS_BYTE32(*m, (i - 4));
  endloop:    addiw t0,t0,1 #i++
             j loop2        
################################################################33
        
next2: 
        li a5,4
        bgeu  s10 ,a5,else4  #if(rlen < 4)
        addiw a0,zero,0x80	#a0=0x80	
        addw a1,zero,s10 #rlen
        jal INS_BYTE32  #INS_BYTE32(0x80, rlen)
        or t3,t3,a0 #t1_o |= INS_BYTE32(0x80, rlen);
        j endloop1
  else4: addiw a0,zero,0x80   #a0=0x80
         subw a1,s10,t5 #rlen-4
        jal INS_BYTE32 #INS_BYTE32(0x80, rlen-4)
        or t4,t4,a0 #t1_e |= INS_BYTE32(0x80, (rlen - 4));
 endloop1: 
         addw a0,zero,t4 #t1_e
         jal COMPRESS_U32  #COMPRESS_U32(t1_e,in_o,in_e);
        # COMPRESS_U32(var,var_o,var_e)= COMPRESS_U32(a0,a1,a2)
          addw a0,zero,t3 #t1_o
         addw t4,zero,a2   
         addw t3,zero,a1 
         jal COMPRESS_U32 # COMPRESS_U32(t1_o,t0_o,t0_e);
         slliw a1,a1,16  #t0_o << 16;
          slliw a2,a2,16 #t0_e << 16;
         or t3,t3,a1 #in_o |= t0_o << 16;
         or t4,t4,a2 #n_e |= t0_e << 16;
         xor s0,s0,t4 #x0_e ^= in_e;
         xor s1,s1,t3 #x0_o ^= in_o;
          #a0->x0_e and a1->x0_o   a0->var
          addw a0,zero,s0
          addw a1,zero,s1
          EXPAND_U32 a0,a1,a0  #EXPAND_U32(t1_e,x0_o,x0_e);
          addw t4,zero,a0 #t1_e 
          addw a0,zero,s0
          addw a1,zero,s1
          srliw a0,a0,16
           srliw a1,a1,16
          EXPAND_U32 a0,a1,a0  #EXPAND_U32(t1_o,x0_o>>16,x0_e>>16);
          addw t3,zero,a0 #t1_o
###############################################################
       li t0,0   # i ,s6->ciphertext , ,s7->plaintext
       li t5,4     # 4
      
   loop3 : bgeu t0,s10,next3  #for (i = 0; i < rlen; ++i, ++c)
        li a5,4
        bgeu  t0 ,a5,else3 #if(i < 4)
        addw a0,zero,t3 #t1_o
        addw a1,zero,t0 #i
        jal EXT_BYTE32  #EXT_BYTE32(t1_o, i)
        sb a0,0(t6) #*c = EXT_BYTE32(t1_o, i);
        addiw t6,t6,1 #pointer++
        j endloop3
 else3 : addw a0,zero,t4  #t1_r
        subw a1,t0,t5     #i - 4
        jal EXT_BYTE32    #EXT_BYTE32(t1_e, i - 4);
        sb a0,0(t6) #*c = EXT_BYTE32(t1_e, i - 4);
        addiw t6,t6,1     #pointer++
  endloop3:   addiw t0,t0,1 #i++
             j loop3
 next3:  
         lw   t0,0(sp)
          lw   t1,4(sp)
          lw   t2,8(sp)
          lw   t3,12(sp)
          lw   t4,16(sp)
          lw   t5,20(sp)
          lw   t6,24(sp)
          lw   a7,28(sp)
          lw   ra,32(sp)
         addiw sp,sp,36      
         jalr zero ,ra  
   ##############################################################
#########################################################################################################    
Finalization:
	addiw sp,sp,-4
	sw   ra,0(sp)

	la a7,k	 # load the addwres of the 1st byte of the key in a7
	#la s6,npub	 # load the addwres of the 1st byte of the nouns in a7
	
	# COMPRESS_BYTE_ARRAY(k,K0_o,K0_e) 
	lw a0,0(a7)
	lw a1,4(a7)	
	jal COMPRESS_BYTE_ARRAY
	addw t0,a2,0
	addw t1,a3,0
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw a0,8(a7)
	lw a1,12(a7)	
	jal COMPRESS_BYTE_ARRAY
	addw t2,a2,0
	addw t3,a3,0
	
	#,addiwng Key bits to the internal state#
	xor s2,s2,t0
	xor s3,s3,t1
	xor s4,s4,t2
	xor s5,s5,t3

	##############################################
	# Permutation 12 #
	jal P12_32
	#Generating The Tag # Xoring the last k bits of the state with the Key
	xor s6,s6,t0
	xor s7,s7,t1
	xor s8,s8,t2
	xor s9,s9,t3
	#############################################

	# Returning The Tag #
	la a4,cipherText  # if the length of the plain text(or the cipher text )  we addw the some bytes to start saving the tag in a suitable place after the cipher
        li a1,4    # gp = s11 + [4 - (s11 mod 4 )] + a4 
        
       REMU a0,s11,a1 
        subw a1,a1,a0
        addw gp,s11,a1
        addw gp,gp,a4
	
	srliw a0,s6,16
	srliw a1,s7,16
	EXPAND_U32 a0,a1,a0  # return a0 as t1_e
	 U32BIG a0 # takes t1_e as a0
	sw  a0,0(gp)
	
	addw a0,zero,s6
	addw a1,zero,s7
	EXPAND_U32 a0,a1,a0  # return a0 as t1_e
	 U32BIG a0 # takes t1_e as a0
	sw  a0,4(gp)
	
	srliw a0,s8,16
	srliw a1,s9,16
	EXPAND_U32 a0,a1,a0  # return a0 as t1_e
	U32BIG a0 # takes t1_e as a0
	sw  a0,8(gp)	

	addw a0,zero,s8
	addw a1,zero,s9
	EXPAND_U32 a0,a1,a0  # return a0 as t1_e
	U32BIG a0 # takes t1_e as a0
	sw  a0,12(gp)		
	li a6,788
	lw ra,0(sp)
	addiw sp,sp,4
	jr ra
	
	

 .size main , .-main
.ident "GCC:(GNU) 5.2."
