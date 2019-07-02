.data
	PlainText: .ascii "Fantastic Three, 5od fekra we eshtry bokra$"      
        npub: .word 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 # key is 128 bit saved in array of word boundaries
	.align 2
       associated_data: .ascii "23115151$"
       k: .word 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 #nouns length is 128 bit
	.align 2

        cipherText : .word 0x42570086,0x1c9b31ea,0xf94891a8,0x9be2de59,0x4bf027e8,0x66381daf,0xb4703bb7,0xc82b2463,0x00b224b2,0x3aeccc6a,0x0000ad41
	m:         .word  25



.text
.align 2
.global main
.type main , @function

	main:

	la a0 ,PlainText
	jal initialization
	li a6 , 888
	jal associated
	li a6 , 799
	jal Plain
	li a6 , 444
	jal FD
	li a6 , 555
	




strlen:
	######Saving Registers to The Stack###############
	addi sp,sp,-16
	sw   t0,0(sp)
	sw   t1,4(sp)
	sw   t2,8(sp)
	sw   ra,12(sp)
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
	lw t0,0(sp)
	lw t1,4(sp)
	lw t2,8(sp)
	lw ra,12(sp)	
	addi sp,sp,16
	###################################################
	jr ra #Return to the main Program
#########################################################################################
#############################
	ROUND32:
	addi sp,sp,-24
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
	
	not t5,s2
	and s0,s4,t5 # x0_e = x2_e & (~x1_e)
	xor s0,t0,s0 # x0_e = t0_e ^ x0_e
	
	not t5,s3
	and s1,s5,t5 # x0_o = x2_o & (~x1_o)
	xor s1,t1,s1 # x0_o = t0_o ^ x0_o
	
	not t5,s2
	and s8,s4,t5 # x4_e = x2_e & (~x1_e)
	xor s8,s0,s8 #  x4_e = x0_e ^ x4_e
	
	not t5,s3
	and s9,s5,t5 #  x4_o = x2_o & (~x1_o)
	xor s9,s1,s9 #  x4_o = x0_o ^ x4_o
	
	not t5,s8
	and s8,s2,t5 # x4_e = x1_e & (~x4_e)
	xor s8,s8,t2 # x4_e = x4_e ^ t1_e
	
	not t5,s9
	and s9,s3,t5 # x4_o = x1_o & (~x4_o)
	xor s9,s9,t3 # x4_o = x4_o ^ t1_o
	
	not t5,s2
	and t0,s4,t5 # t0_e = x2_e & (~x1_e)
	xor t0,t0,s0 # t0_e = t0_e ^ x0_e
	
	not t5,s3
	and t1,s5,t5 # t0_o = x2_o & (~x1_o)
	xor t1,t1,s1 # t0_o = t0_o ^ x0_o
	
	not t5,t2
	and t0,t0,t5 #  t0_e = t0_e & (~t1_e)
	xor t0,t0,s6 #  t0_e = t0_e ^ x3_e
	
	not t5,t3
	and t1,t1,t5 #  t0_o = t0_o & (~t1_o)
	xor t1,t1,s7 #  t0_o = t0_o ^ x3_o
	
	not t5,s2
	and t2,s4,t5 # t1_e = x2_e & (~x1_e)
	xor t2,t2,s0 # t1_e = t1_e ^ x0_e
	
	not t5,s3
	and t3,s5,t5 # t1_o = x2_o & (~x1_o)
	xor t3,t3,s1 # t1_o = t1_o ^ x0_o
	
	not t5,t2
	and t2,s2,t5 # t1_e = x1_e & (~t1_e)
	xor t2,t2,s8 # t1_e = t1_e ^ x4_e
	
	not t5,t3
	and t3,s3,t5 # t1_o = x1_o & (~t1_o)
	xor t3,t3,s9 # t1_o = t1_o ^ x4_o
	
	not t5,s6
	and t2,t2,t5 #  t1_e = t1_e & (~x3_e)
	xor t2,t2,s4 #  t1_e = t1_e ^ x2_e
	
	not t5,s7
	and t3,t3,t5 #  t1_o = t1_o & (~x3_o)
	xor t3,t3,s5 #  t1_o = t1_o ^ x2_o
	
	not t5,s4
	and s4,s6,t5#  x2_e = x3_e & (~x2_e)
	xor s2,s2,s4  #  x1_e = x1_e ^ x2_e
	
	not t5,s5
	and s5,s7,t5 # x2_o = x3_o & (~x2_o)
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
	li   a1,9
	jal RotateRight
	mv t5,a0
	#ror t5,t1,9
	xor s0,s0,t5 # x0_e ^= ROTR32(t0_o, R_O[0][0])
	
	mv a0,t0
	li   a1,10
	jal RotateRight
	mv t5,a0
	#ror t5,t0,10
	xor s1,s1,t5 # x0_o ^= ROTR32(t0_e, R_E[0][0])
	
	mv a0,t3
	li   a1,19
	jal RotateRight
	mv t5,a0
	#ror t5,t3,19
	xor s2,s2,t5 #  x1_e ^= ROTR32(t1_o, R_O[1][0])
	
	mv a0,t2
	li   a1,20
	jal RotateRight
	mv t5,a0	
	#ror t5,t2,20
	xor s3,s3,t5 # x1_o ^= ROTR32(t1_e, R_E[1][0])
	
	mv a0,t0
	li   a1,14
	jal RotateRight
	mv t5,a0	
	#ror t5,t0,14
	xor s0,s0,t5 # x0_e ^= ROTR32(t0_e, R_E[0][1])
	
	mv a0,t1
	li   a1,14
	jal RotateRight
	mv t5,a0	
	#ror t5,t1,14
	xor s1,s1,t5 # x0_o ^= ROTR32(t0_o, R_O[0][1])
	
	mv a0,t3
	li   a1,30
	jal RotateRight
	mv t5,a0	
	#ror t5,t3,30
	xor s2,s2,t5 # x1_e ^= ROTR32(t1_o, R_O[1][1])
	
	mv a0,t2
	li   a1,31
	jal RotateRight
	mv t5,a0	
	#ror t5,t2,31
	xor s3,s3,t5 # x1_o ^= ROTR32(t1_e, R_E[1][1])
	
	mv t0,s4 #  t0_e  = x2_e
	mv t1,s5 # t0_o  = x2_o
	mv t2,s6 # t1_e  = x3_e
	mv t3,s7 # t1_o  = x3_o

	mv a0,t1
	li   a1,0
	jal RotateRight
	mv t5,a0		
	#ror t5,t1,0
	xor s4,s4,t5 # x2_e ^= ROTR32(t0_o, R_O[2][0])
	
	mv a0,t0
	li   a1,1
	jal RotateRight
	mv t5,a0	
	#ror t5,t0,1
	xor s5,s5,t5 #  x2_o ^= ROTR32(t0_e, R_E[2][0])

	mv a0,t2
	li   a1,5
	jal RotateRight
	mv t5,a0		
	#ror t5,t2,5
	xor s6,s6,t5 # x3_e ^= ROTR32(t1_e, R_E[3][0])

	mv a0,t3
	li   a1,5
	jal RotateRight
	mv t5,a0		
	#ror t5,t3,5
	xor s7,s7,t5 # x3_o ^= ROTR32(t1_o, R_O[3][0])

	mv a0,t0
	li   a1,3
	jal RotateRight
	mv t5,a0		
	#ror t5,t0,3
	xor s4,s4,t5 # x2_e ^= ROTR32(t0_e, R_E[2][1])

	mv a0,t1
	li   a1,3
	jal RotateRight
	mv t5,a0		
	#ror t5,t1,3
	xor s5,s5,t5 # x2_o ^= ROTR32(t0_o, R_O[2][1])

	mv a0,t3
	li   a1,8
	jal RotateRight
	mv t5,a0		
	#ror t5,t3,8
	xor s6,s6,t5 # x3_e ^= ROTR32(t1_o, R_O[3][1])

	mv a0,t2
	li   a1,9
	jal RotateRight
	mv t5,a0		
	#ror t5,t2,9
	xor s7,s7,t5 # x3_o ^= ROTR32(t1_e, R_E[3][1])
	
	mv t0,s8 # t0_e  = x4_e
	mv t1,s9 # t0_o  = x4_o

	mv a0,t1
	li   a1,3
	jal RotateRight
	mv t5,a0		
	#ror t5,t1,3
	xor s8,s8,t5 # x4_e ^= ROTR32(t0_o, R_O[4][0])

	mv a0,t0
	li   a1,4
	jal RotateRight
	mv t5,a0		
	#ror t5,t0,4
	xor s9,s9,t5 # x4_o ^= ROTR32(t0_e, R_E[4][0])
	
	mv a0,t1
	li   a1,20
	jal RotateRight
	mv t5,a0	
	#ror t5,t1,20
	xor s8,s8,t5 # x4_e ^= ROTR32(t0_o, R_O[4][1])
	
	mv a0,t0
	li   a1,21
	jal RotateRight
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
	add sp,sp,24
	jr ra
	
##################################################################################
#premutation 12 #
	P12_32: 
	addi sp,sp,-12
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
	addi sp,sp,12
	jr ra
	##################################################################################
	#premutation 16 #
	P6_32:
	
	addi sp,sp,-12
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
	addi sp,sp,12
	jr ra

  

#########################################################################################################    
      #RotateRight(x,n)=RotateRight(a0,a1)
      #this function rotates the register x by n number 
RotateRight:  addi sp,sp,-8
              sw   t0,0(sp)
              sw   t1,4(sp)
              add t0,zero,a0
              srl a0,a0,a1  #(x)>>(n)
              addi t1 ,zero,32
              sub t1,t1,a1 
              sll t0,t0,t1  # (x)<<32-(n)
              or a0,a0,t0    #(((x)>>(n))|((x)<<(32-(n))))
              lw   t0,0(sp)
              lw   t1,4(sp)
              addi sp,sp,8
              jalr zero ,ra
           #return value in a0
######################################################################
   #EXT_BYTE32(x,n)=EXT_BYTE32(a0,a1)
   #this function shift right the register x by 8*(3-n) and cut the lowest byte
EXT_BYTE32: addi sp,sp,-4
            sw   t0,0(sp)
            addi t0,zero,3
            sub a1,t0,a1   #(3-(n)
            li a5,8
            mul a1,a1,a5     #8*(3-(n)
            srl a0,a0,a1  #(x)>>(8*(3-(n))
            lw  t0,0(sp) 
	            addi sp,sp,4	
           jalr zero ,ra
      #return value in a0
######################################################################################            
#INS_BYTE32(x,n)=INS_BYTE32(a0,a1)
#this function shift left register x by 8*(3-(n)) 
INS_BYTE32: 
	    addi sp,sp,-4
            sw   t0,0(sp)
    	    addi t0,zero,3   #(3-(n))
            sub a1,t0,a1
            li a5,8
            mul a1,a1,a5   #8*(3-(n))
            sll a0,a0,a1  #(x)<<(8*(3-(n))
            lw  t0,0(sp) 
            addi sp,sp,4          
            jalr zero ,ra
   # return in a0
###############################################################################################
#u32BIG(a0)
#this function converts register x to big endian 
 U32BIG :      addi sp,sp,-16              
               sw   t0,0(sp)
               sw   t1,4(sp)
               sw   t2,8(sp)
	       sw   ra,12(sp)    
	       addi a1,zero,8
	       add t2,zero,a0 #store  value of x in t2
	       jal RotateRight  #ROTR32(x,  8) 
	        li t0,0xff00ff00  #0xFF00FF00
               and a0,a0,t0 #(ROTR32(x,  8) & (0xFF00FF00)
	        addi a1,zero,24
	        add t1,zero,a0 # store value of (ROTR32(x,  8) & (0xFF00FF00) in t3
	        add a0,zero,t2 
	       jal RotateRight  #ROTR32(x, 24)
	        li t0,0x00ff00ff #0x00FF00FF
               and a0,a0,t0  #(ROTR32(x, 24) & (0x00FF00FF))
               or a0,a0,t1   #((ROTR32(x,  8) & (0xFF00FF00))|((ROTR32(x, 24) & (0x00FF00FF))))
               lw   t0,0(sp)
               lw   t1,4(sp)
               lw   t2,8(sp)
               lw  ra,12(sp)
	       addi sp,sp,16
               jalr zero ,ra
       #return value in a0
#############################################
#EXPAND_SHORT(x)=EXPAND_SHORT(a0)
# the function expands 16 bit register to 32 bit register 
EXPAND_SHORT : addi sp,sp,-12              
               sw   t0,0(sp)
               sw   t1,4(sp)
               sw   t2,8(sp)    
               li t0,0xffff
               and a0,a0,t0  #x &= 0x0000ffff;
               add t1,zero,a0 
               slli t1,t1,8	#(x << 8)	
               or a0,a0,t1   #(x | (x << 8))
               li t2,0x00ff00ff   # 0x00ff00ff

               and a0,a0,t2 #x = (x | (x << 8)) & 0x00ff00ff;
               add t1,zero,a0
               slli t1,t1,4		
               or a0,a0,t1
               li t2,0x0f0f0f0f
    
               and a0,a0,t2  #x = (x | (x << 4)) & 0x0f0f0f0f;
               add t1,zero,a0
               slli t1,t1,2		
               or a0,a0,t1
               li t2,0x33333333
               and a0,a0,t2   # x = (x | (x << 2)) & 0x33333333;
               add t1,zero,a0
               slli t1,t1,1		
               or a0,a0,t1
               li t2,0x55555555
               and a0,a0,t2  #x = (x | (x << 1)) & 0x55555555;
               lw   t0,0(sp)
               lw   t1,4(sp)
               lw   t2,8(sp)
               addi sp,sp,12  
               jalr zero ,ra
               #retrun value in a0
###########################################
#EXPAND_U32(var,var_o,var_e)=EXPAND_U32(a0,a1,a0)
#a0->var_e and a1->var_o   a0->var
#this function makes 32 bit register var from its even numbers var_e and odd numbers var_o
EXPAND_U32:  addi sp,sp,-8
             sw   t2,0(sp)
	     sw   ra,4(sp)
            jal EXPAND_SHORT #t0_e = (var_e); and EXPAND_SHORT(t0_e);
            add t2,zero,a0 # store t0_e in t2
            add a0,zero,a1 
            jal EXPAND_SHORT # EXPAND_SHORT(t0_o);
            sll a0,a0,1  #(t0_o << 1)
            or a0,a0,t2 #var = t0_e | (t0_o << 1);
            lw  t2,0(sp)
            lw  ra,4(sp)
            add sp,sp,8
           jalr zero ,ra
# return value in $ a0
############################################
 #COMPRESS_LONG(x)=COMPRESS_LONG(a0)
 #this function compresses 32 bit register to 16 bit you can use it to make var_e and var_o
 COMPRESS_LONG:addi sp,sp,-12              
               sw   t0,0(sp)
               sw   t1,4(sp)
               sw   t2,8(sp) 
               li t0,0x55555555
               and a0,a0,t0 #x &= 0x55555555;
               add t1,zero,a0
               srli t1,t1,1	#(x >> 1)	
               or a0,a0,t1   #(x | (x >> 1))
               li t0,0x33333333
               and a0,a0,t0   #x = (x | (x >> 1)) & 0x33333333;
               add t1,zero,a0
               srli t1,t1,2		
               or a0,a0,t1  
               li t2,0x0f0f0f0f
               and a0,a0,t2 #x = (x | (x >> 2)) & 0x0f0f0f0f;
               add t1,zero,a0
               srli t1,t1,4		
               or a0,a0,t1
               li t2,0x00ff00ff
               and a0,a0,t2    #x = (x | (x >> 4)) & 0x00ff00ff;
               add t1,zero,a0
               srli t1,t1,8		
               or a0,a0,t1
               li t2,0x000ffff
               and a0,a0,t2 #x = (x | (x >> 8)) & 0x0000ffff;
               lw   t0,0(sp)
               lw   t1,4(sp)
               lw   t2,8(sp)
	       addi sp,sp,12
               jalr zero ,ra
     #return value in a0    
################################################################
# COMPRESS_U32(var,var_o,var_e)= COMPRESS_U32(a0,a1,a2)
#this function compresses 32 bit register and divides it into 2 16-bit registers (var_o and var_e)
COMPRESS_U32:addi sp,sp,-4
	     sw   ra,0(sp)
	     srli a1,a0,1   
           jal 	COMPRESS_LONG
            add a2,zero,a0
            add a0,zero,a1
           jal COMPRESS_LONG
            add a1,zero,a0
            lw  ra,0(sp)
	    add sp,sp,4
            jalr zero ,ra 
 
     # return two values var_0->a1 and var_e->a2
 ##################################################################
#COMPRESS_BYTE_ARRAY(a,var_o,var_e)=COMPRESS_BYTE_ARRAY(a0,a1,a3,a2)
#a3-> var_o and  a2->var_e  (a))[1]-> a1  (a)[0]->a0
#this function divides 64 bit block in a0,a1 into two 32 bit registers one is even (a2) and other is odd(a3)
COMPRESS_BYTE_ARRAY: addi sp,sp,-20
                     sw   t0,0(sp)
                     sw   t1,4(sp)
                     sw   t2,8(sp)
                     sw   t3,12(sp)
                     sw   ra,16(sp)
	             add t3,zero,a1
	             jal U32BIG    #t1_e = U32BIG(((u32*)(a))[0]);
	             add a1,zero,t3 
	             srli a3,a0,1   #t1_o = t1_e >> 1;
	             jal COMPRESS_LONG #COMPRESS_LONG(t1_e)
	             slli a2,a0,16    #t1_e << 16;
	             add a0,zero,a3
                     jal COMPRESS_LONG #COMPRESS_LONG(t1_o);
                     slli a3,a0,16    #t1_o << 16
                     add a0,zero,a1
                     add t0,zero,a2
                     add t1,zero,a3
                     jal U32BIG	  #var_e = U32BIG(((u32*)(a))[1]);
                     add a2,zero,t0
                     add a3,zero,t1
	             srli t2,a0,1  #var_o = var_e >> 1;
	             jal COMPRESS_LONG #COMPRESS_LONG(var_e);
	             or a2,a2,a0 #var_e |= t1_e << 16;
	             add a0,zero,t2
                     jal COMPRESS_LONG #COMPRESS_LONG(var_o);
               	     or a3,a3,a0 #var_o |= t1_o << 16;
        	     lw t0,0(sp)
		     lw t1,4(sp)
		     lw t2,8(sp)
		     lw t3,12(sp)
		     lw   ra,16(sp)
		     addi sp,sp,20           
	 	     jalr zero ,ra
	#return two values a3-> var_o and  a2->var_e
initialization:
	addi sp,sp,-4
	sw ra , 0(sp)
	
	addi sp,sp,-4
	sw ra , 0(sp)
	la a7,k	 # load the addres of the 1st byte of the key in a7
	la t6,npub	 # load the addres of the 1st byte of the nouns in a7
	
	# COMPRESS_BYTE_ARRAY(k,K0_o,K0_e) 
	lw a0,0(a7)
	lw a1,4(a7)	
	jal COMPRESS_BYTE_ARRAY
	add t0,a2,0
	add t1,a3,0
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw a0,8(a7)
	lw a1,12(a7)	
	jal COMPRESS_BYTE_ARRAY
	add t2,a2,0
	add t3,a3,0
	
	# COMPRESS_BYTE_ARRAY(npub,N0_o,N0_e)
	lw a0,0(t6)
	lw a1,4(t6)	
	jal COMPRESS_BYTE_ARRAY
	addi s6,a2,0 # x3_e = N0_e;
	addi s7,a3,0 # x3_o = N0_o;
	
	#  COMPRESS_BYTE_ARRAY(npub+8,N1_o,N1_e)
	lw a0,8(t6)
	lw a1,12(t6)	
	jal COMPRESS_BYTE_ARRAY
	addi s8,a2,0# x4_e = N1_e;
	addi s9,a3,0# x4_o = N1_o;
	

	li s0,0x80400c06#  t1_e = (u32)((CRYPTO_KEYBYTES * 8) << 24 | (8 * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0);
	srl  s1,s0,1 #t1_o = t1_e >> 1
		
	#COMPRESS_LONG(t1_e) #t1_e = t2 and compress long takes and return a0 
	addi a0,s0,0	
	jal COMPRESS_LONG
	addi s0,a0,0
	
	# COMPRESS_LONG(t1_o)#t1_o = t3 and compress long takes and return a0 
	addi a0,s1,0
	jal COMPRESS_LONG
	addi s1,a0,0	
	
	slli s0,s0,16	#x0_e = t1_e << 16
	slli s1,s1,16	#x0_o = t1_o << 16
	addi s2,t0,0	#x1_o = K0_o
	addi s3,t1,0	#x1_e = K0_e
	addi s4,t2,0	#x2_e = K1_e
	addi s5,t3,0	#x2_o = K1_o
	jal P12_32	
        xor s6,s6,t0	#x3_e ^= K0_e
	xor s7,s7,t1	#x3_o ^= K0_o
	xor s8,s8,t2 #x4_e ^= K1_e
	xor s9,s9,t3	#x4_o ^= K1_o 
lw   ra,0(sp)
addi sp,sp,4
 jalr zero ,ra	
####################################################################################################
########################process associated data	#####################

associated:
addi sp,sp,-4
sw ra , 0(sp)
li a6,222
la a7,associated_data #load the address of associated data (pointer ad in the c code)
addi a0,a7,0 #put the address in a0 to make it as input for strlen function
jal strlen # reterns the length of the associated data in v1
beqz s11,end_ed #if (adlen) # if  s11= adlen=0 get out of the if and go to end label
add s10,s11,0 #rlen(s10),#adlen=(s11)

while_loop: 
        li a5,8  
	blt  s10,a5,cont0#  while (rlen >= 8) , 8= 8 bytes
		#load a0 and a1 with bytes of the associate datat array ????? ask hossam???????????????a[0]is the addres of the first 2 bytes  a[1]the addres of the second 2 bytes????
		lw a0,0(a7)
		lw a1,4(a7)	
		
		# COMPRESS_BYTE_ARRAY(ad,in_o,in_e);
		# (a))[1]-> a1 ### (a)[0]->a0 #### a3-> var_o ##### a2->var_e  
				
		jal COMPRESS_BYTE_ARRAY# takes the associated data itself (a0,a1)=(ad)and generates (a2,a3)=(in_o,in_e)
		xor s0,s0,a2 #x0_e ^= in_e
		xor s1,s1,a3 #x0_o ^= in_o
		jal P6_32
		addi s10,s10,-8 #rlen -= 8
		addi a7,a7,8 #ad += 8	
j while_loop
li a6 , 789	
cont0:	
	li t2,0# t1_e = 0;
	li t3,0#t1_o = 0;
	
	li t4,0 # $4 is i the counter of the for loop
	
for_loop:	
	bge t4,s10,exit_for #for (i = 0; i < rlen; ++i, ++ad) if[ i(t4)>=rlen(s10)] exit the loop
		lbu a0,0(a7)#load the word which ad points to in a0 as the first argument taken by INS_BYTE
		add a1,t4,0  #load a1 with $v4(i)as the second argument for INS_BYTE32
	li a5,4	
         bge t4,a5,else1 # if(i < 4)		
			jal INS_BYTE32 #INS_BYTE32(*ad, i) we shift bytes of associated data(*ad) i times,then we insert them in t1_0 and t1_e (s0 , s1)
			or t3,t3,a0# the reterned value (shifted ) from INS_BYTE a0 is ored with t1_0 (t1_o |= INS_BYTE32(*ad, i))		
			j cont1
		else1:	#t1_e |= INS_BYTE32(*ad, (i - 4))
			addi a1,t4,-4
			jal INS_BYTE32
			or t2,t2,a0		
		cont1:
		addi t4,t4,1# ++i
		addi a7,a7,1# ++ad		
j for_loop
li a6 , 789
exit_for:	
		li a0,0x80 #load a0 with 0x80 as the first argument of INS_BYTE32
		add a1,s10,0 #load a1 with s10(rlen)	as the second argument for INS_BYTE32
		li a5,4
               bge s10,a5,else2 #if(rlen < 4)
			jal INS_BYTE32
			or t3,t3,a0#t1_o |= INS_BYTE32(0x80, rlen)
			j cont2		
		else2:#t1_e |= INS_BYTE32(0x80, (rlen - 4))
			addi a1,s10,-4
			jal INS_BYTE32
			or t2,t2,a0
		cont2:	
		
		#COMPRESS_U32(var,var_o,var_e)
		#a0->var  a1->var_o  a2->var_e
		
		#COMPRESS_U32(t1_e,in_o,in_e)
		add a0,t2,0 # a0(the argument taken by COMPRESS_U32)	= t2 (t1_e)	
		jal COMPRESS_U32
		#move COMPRESS_U32 output in registers so and s1 to reuse them 
		# t0 <------ $in_o
		# t1 <------ $in_e
		add t0,a1,0 
		add t1,a2,0
		
		
		#COMPRESS_U32(t1_o,t0_o,t0_e)
		add a0,t3,0 # a0(the argument taken by COMPRESS_U32)	= t3 (t1_0)	
		jal COMPRESS_U32
		#move COMPRESS_U32 output in registers s5 and s5 o reuse them 
		# t5 <------ s0_o
		# t3 <------ s0_e
		add t5,a1,0  
		add t3,a2,0
		
		#in_o |= t0_o << 16
		slli t5,t5,16 
		or t0,t0,t5
		#in_e |= t0_e << 16
		slli t3,t3,16
		or t1,t1,t3
		
		xor s0,s0,t1	#x0_e ^= in_e
		xor s1,s1,t0	#x0_o ^= in_o
		jal P6_32
li a6 , 789
end_ed:
xori s8,s8,1 #x4_e ^= 1
li a6 , 789
lw   ra,0(sp)
addi sp,sp,4
 jalr zero ,ra
########################end associated data	#####################

########################end associated data	#####################

########################################################################## plain ########################################
Plain:          addi sp,sp,-32
		sw   t1,0(sp)
		sw   t2,4(sp)
		sw   t3,8(sp)
		sw   t4,12(sp)
		sw   t5,16(sp)
		sw   t6,20(sp)
		sw   a7,24(sp)
		sw   ra,28(sp)
		la a0,PlainText
		jal strlen
		############just for test###################
		#li t2,0x296f047b
		#li t3,0xc2992e3e
		#li s0,0xa3e3a193
		#li s1,0x75f08ec8
		#li s2,0xb570519b
		#li s3,0x7673a5ef
		#li s4,0xb488f198
		#li s5,0x3d7520e1
		#li s6,0xcee6e576
		#li s7,0x91950cd
		#li s8,0x6fd487fd
		#li s9,0x1beb7ce6#	
		#li t2,0x969e3617
		#li t3,0x2380a7c7
		#li s0,0x9333b3b9
		#li s1,0x18c95201
		#li s2,0x3a0e61f0
		#li s3,0x7eba294d
		#li s4,0xe20d165b
		#li s5,0x71515cc8
		#li s6,0xed094700
		#li s7,0x1157ede2
		#li s8,0xabc42fbd
		#li s9,0xe5cdade2	
		
		#############################################
	
		#################################
		#la   a4,a6
		#la   $k1,m
		#li  gp,0x00
		add a7,zero,s11 # getting the value of rlen
		la a6,cipherText
		la s10,m
	while_p1:
		li a5,8
		blt a7,a5,Exit_p1
		
		add a0,zero,s0
		add a1,zero,s1
		jal EXPAND_U32
		add t2,zero,a0 # EXPAND_U32(t1_e,x0_o,x0_e);
		
		srl a0,s0,16
		srl a1,s1,16
		jal EXPAND_U32
		add t3,zero,a0 # EXPAND_U32(t1_o,x0_o>>16,x0_e>>16);
		
		add a0,t3,zero
		jal U32BIG # U32BIG(t1_o) 
		lw  t5,0(a6) # getting 32 bit of the cipher text which is pointed to right now
		xor t4,t5,a0
		sw  t4,0(s10) # storing the computed plain text in the memory
		
		#addi gp,gp,4 #increment the pointer to the plain and cipher text
		addi  a6,a6,4
		addi  s10,s10,4		
		
		add a0,t2,zero
		jal U32BIG
		lw  t6,0(a6)
		xor t4,t6,a0
		sw  t4,0(s10)
		
		add a0,t5,zero
		add a1,t6,zero
		jal COMPRESS_BYTE_ARRAY
		add s0,a2,zero
		add s1,a3,zero
		
		jal P6_32								
										
		
	
		addi a7,a7,-8 # rlen -= RATE
		#addi  gp,gp,4 # m += RATE , c += RATE
		addi  a6,a6,4
		addi  s10,s10,4		
		j     while_p1		
	Exit_p1:							
																	
		######################################### End of While #######################
	
		add a0,zero,s0
		add a1,zero,s1
		jal EXPAND_U32
		add t2,zero,a0 # EXPAND_U32(t1_e,x0_o,x0_e);
		
		srl a0,s0,16
		srl a1,s1,16
		jal EXPAND_U32
		add t3,zero,a0 # EXPAND_U32(t1_o,x0_o>>16,x0_e>>16);
		
		############################### FOR LOOP #####################################
		
		li a4,0 # initializing the counter i=0
		li a5,4
	for_p2:	
		bgeu a4,a7,Exit_p2
				################### IF STATEMENT ####################
				bgeu a4,a5,DoElse_p2 # ELSE ( if (i < 4) )
				
				add a0,t3,zero
				add a1,a4,zero
				jal EXT_BYTE32 #retutn the Extracted byte from t1_o in a0
				lbu  t5,0(a6) #get 8 bits of the cipher and store them in s5
				xor t6,a0,t5
				sb  t6,0(s10) # *m = EXT_BYTE32(t1_o, i) ^ *c
				
				addi a0,zero,0xff
				add   a1,zero,a4
				jal   INS_BYTE32 #INS_BYTE32(0xff, i); 
				not   a0,a0 #~INS_BYTE32(0xff, i);
				and   t3,t3,a0 # t1_o &= ~INS_BYTE32(0xff, i);
				
				
				add   a0,zero,t5
				add   a1,zero,a4
				jal   INS_BYTE32
				or    t3,t3,a0
				
				
				
				j SkipElse_p2
			DoElse_p2:
				add a0,t2,zero
				addi a1,a4,-4
				jal EXT_BYTE32 #retutn the Extracted byte from t1_o in a0
				lb  t5,0(a6) #get 32 bits of the cipher and store them in s5
				xor t6,a0,t5
				sb  t6,0(s10) # *m = EXT_BYTE32(t1_o, i) ^ *c
				
				addi a0,zero,0xff
				addi  a1,a4,-4
				jal   INS_BYTE32 #INS_BYTE32(0xff, i); 
				not   a0,a0 #~INS_BYTE32(0xff, i);
				and   t3,t3,a0 # t1_o &= ~INS_BYTE32(0xff, i);
				
				
				add   a0,zero,t5
				addi  a1,a4,-4
				jal   INS_BYTE32
				or    t3,t3,a0				
			
			SkipElse_p2:
			################################### END of IF STATEEMENT ##########
					
		addi a4,a4,1 #i++
		#addi gp,gp,1 # m++ c++
		addi  a6,a6,1
		addi  s10,s10,1
		j for_p2
							
	Exit_p2:
	############################################# IF ################################
		li a5,4
		bgeu a7,a5,DoElse_p3
		
		addi a0,zero,0x80
		add  a1,zero,a7
		jal  INS_BYTE32
		xor t3,t3,a0
		
		j SkipElse_p3
	DoElse_p3:
		addi a0,zero,0x80
		addi  a1,a7,-4
		jal  INS_BYTE32
		xor t2,t2,a0
	SkipElse_p3:			
	#################################################################################
		
		add a0,t2,zero
		jal COMPRESS_U32
		add s1,a1,zero
		add s0,a2,zero
		
		add a0,t3,zero
		jal COMPRESS_U32
		add t1,a1,zero
		add t0,a2,zero
		
		sll t5,t1,16
		or  s1,s1,t5
		
		sll t5,t0,16
		or  s0,s0,t5
	###########################################################################					
		
		
		
		lw   t1,0(sp)
		lw   t2,4(sp)
		lw   t3,8(sp)
		lw   t4,12(sp)
		lw   t5,16(sp)
		lw   t6,20(sp)
		lw   a7,24(sp)
		lw   ra,28(sp)
		addi sp,sp,32
		jr ra
##########################################################################
#Finalization
FD: addi sp,sp,-4
	sw ra , 0(sp)
	la a7,k
    # COMPRESS_BYTE_ARRAY(k,K0_o,K0_e)  #COMPRESS_BYTE_ARRAY(a,var_o,var_e)=COMPRESS_BYTE_ARRAY(a0,a1,a3,a2)
	lw a0,0(a7)
	lw a1,4(a7)	
	jal COMPRESS_BYTE_ARRAY
	add t0,a2,0 #k0_e
	add t1,a3,0 #K0_o
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw a0,8(a7)
	lw a1,12(a7)	
	jal COMPRESS_BYTE_ARRAY
	add t2,a2,0 #K1_e
	add t3,a3,0 #K1_o
        xor s2,s2,t0 #x1_e ^= K0_e;
	xor s3,s3,t1 #x1_o ^= K0_o;
	xor s4,s4,t2 #x2_e ^= K1_e;
	xor s5,s5,t3 #x2_o ^= K1_o;
	jal P12_32    #P12_32;
	xor s6,s6,t0 #x3_e ^= K0_e;
	xor s7,s7,t1 #x3_o ^= K0_o;
	xor s8,s8,t2 #x4_e ^= K1_e;
	xor s9,s9,t3 #x4_o ^= K1_o;
	#EXPAND_U32(var,var_o,var_e)=EXPAND_U32(a0,a1,a0)
        #a0->var_e and a1->var_o   a0->var
	li t4,0 #ret_value
	add a0,zero,s6
	add a1,zero,s7
	jal EXPAND_U32   #  EXPAND_U32(t1_e, x3_o, x3_e);
	add t6,zero,a0 #t1_e
	srl a0,s6,16
	srl a1,s7,16
	jal EXPAND_U32  #EXPAND_U32(t1_o, x3_o >> 16, x3_e >> 16);
	add t5,zero,a0 #t1_o
	#############Verify######################
	la a6,cipherText  # if the length of the plain text(or the cipher text )  we add the some bytes to start saving the tag in a suitable place after the cipher
       # li a1,4    # $gp = s11 + [4 - (s11 mod 4 )] + $k0 
        #div  s11, a1
       # mfhi a0
       # subu a1,a1,a0
        #addu $gp,s11,a1
        add gp,s11,a6
        lw t1,0(gp) #((u32*) c)[0]
        add a0,zero,t5 
        jal U32BIG
        bne a0,t1 ,noteq1 #if (((u32*) c)[0] != U32BIG(t1_o))
        addi t4,t4,1#ret_val++
noteq1:  lw t0,4(gp) #((u32*) c)[1]
        add a0,zero,t6 
        jal U32BIG
        bne a0,t0 ,noteq2 #if (((u32*) c)[1] != U32BIG(t1_e))
        addi t4,t4,1  #ret_val++
 noteq2: add a0,zero,s8
	add a1,zero,s9
	jal EXPAND_U32   #  EXPAND_U32(t1_e, x3_o, x3_e);
	add t6,zero,a0 #t1_e
	srl a0,s8,16
	srl a1,s9,16
	jal EXPAND_U32  #EXPAND_U32(t1_o, x3_o >> 16, x3_e >> 16);
	add t5,zero,a0 #t1_o    
        lw t1,8(gp) #((u32*) c)[2]
        add a0,zero,t5 
        jal U32BIG
        bne a0,t1 ,noteq3 #if (((u32*) c)[2] != U32BIG(t1_o))
        addi t4,t4,1    #ret_val++
 noteq3:  lw t0,4(gp) #((u32*) c)[3]
        add a0,zero,t6 
        jal U32BIG
        bne a0,t0 ,noteq4   #if (((u32*) c)[3] != U32BIG(t1_e))
        addi t4,t4,1 #ret_val++
 noteq4: addi t0,zero,4
        bne t0,t4, ret_1
       addi a0,zero,0   #return 0 if the two tags are equal
       j ENDFD
ret_1:addi a0,zero,-1      #return -1 if the two tags aren't equal
 #return value in a0       
ENDFD:        
        lw ra,0(sp)
	addi sp,sp,4
	jr ra									
##########################################################################		
 .size main , .-main
.ident "GCC:(GNU) 5.2."
