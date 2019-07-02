.data
	PlainText: .asciiz "Fantastic Three, 5od fekra we eshtry bokra"
	m:         .word  25
        #cipherText : .byte 0x23,0x48,0x96,0x64,0xa9,0xc4,0x84,0xe1
        #cipherText : .byte 0x23,0x48,0x96,0x64,0xa9,0xc4,0x84,0xe1,0xfb,0x45,0x38,0x02,0x42,0x27,0x73,0x98,0x29,0xa0,0x68
        cipherText : .word 0x42570086,0x1c9b31ea,0xf94891a8,0x9be2de59,0x4bf027e8,0x66381daf,0xb4703bb7,0xc82b2463,0x00b224b2,0x3aeccc6a,0x0000ad41
        associated_data: .asciiz "23115151"
        npub: .word 0x12ffcdab, 0x11258734, 0x08021003, 0x08021003 # key is 128 bit saved in array of word boundaries 
        k: .word 0x12efcdab, 0x11258734, 0x08021003, 0x08021003 #nouns length is 128 bit
        .eqv RATE 8
0x42570086,0x1c9b31ea,0xf94891a8,0x9be2de59,0x4bf027e8,0x66381daf,0xb4703bb7,0xc82b2463,0x00b224b2,0x3aeccc6a,0x0000ad41
.text
	main:
	jal initialization
	jal associated
	jal Plain
	jal FD
	
	
	
	End_Program:
	li $v0,10
	syscall
	
########################### FUNCTIONS ###############################################
strlen:
	######Saving Registers to The Stack###############
	addi $sp,$sp,-16
	sw   $s0,0($sp)
	sw   $s1,4($sp)
	sw   $s2,8($sp)
	sw   $ra,12($sp)
	##################################################
	
	move $s0,$a0 #getting the address of the Text
	move $s2,$zero #initialize the Counter
	#For Loop#
agn:	lb   $s1,0($s0) #load the next character from the string
	beqz $s1,end    # check if it's the null character
	addi $s0,$s0,1  #increment the charactter pointer
	addi $s2,$s2,1  #increment the counter
	j agn	
end:	
	move $v1,$s2    #Getting the return value
	#####re Registers from the Sack####################
	lw $s0,0($sp)
	lw $s1,4($sp)
	lw $s2,8($sp)
	lw $ra,12($sp)	
	addi $sp,$sp,16
	###################################################
	jr $ra #Return to the main Program
		
	#############################
	ROUND32:
	addi $sp,$sp,-24
	sw   $s0,0($sp)
	sw   $s1,4($sp)
	sw   $s2,8($sp)
	sw   $s3,12($sp)
	sw  $s5,16($sp)
	sw   $ra,20($sp)

	#Round Constant Layer#
	xor $t4,$t4,$a0 #x2_e ^= C_e
	xor $t5,$t5,$a1 #x2_o ^= C_o
	#####################################################################
	
	#S-Box layer#
	xor $s0,$t0,$t8 # t0_e = x0_e ^ x4_e
	xor $s2,$t8,$t6 # t1_e = x4_e ^ x3_e
	xor $t4,$t4,$t2 # x2_e = x2_e ^ x1_e
	
	xor $s1,$t1,$t9 # t0_o = x0_o ^ x4_o
	xor $s3,$t9,$t7 # t1_o = x4_o ^ x3_o
	xor $t5,$t5,$t3 # x2_o = x2_o ^ x1_o
	
	not $s5,$t2
	and $t0,$t4,$s5 # x0_e = x2_e & (~x1_e)
	xor $t0,$s0,$t0 # x0_e = t0_e ^ x0_e
	
	not $s5,$t3
	and $t1,$t5,$s5 # x0_o = x2_o & (~x1_o)
	xor $t1,$s1,$t1 # x0_o = t0_o ^ x0_o
	
	not $s5,$t2
	and $t8,$t4,$s5 # x4_e = x2_e & (~x1_e)
	xor $t8,$t0,$t8 #  x4_e = x0_e ^ x4_e
	
	not $s5,$t3
	and $t9,$t5,$s5 #  x4_o = x2_o & (~x1_o)
	xor $t9,$t1,$t9 #  x4_o = x0_o ^ x4_o
	
	not $s5,$t8
	and $t8,$t2,$s5 # x4_e = x1_e & (~x4_e)
	xor $t8,$t8,$s2 # x4_e = x4_e ^ t1_e
	
	not $s5,$t9
	and $t9,$t3,$s5 # x4_o = x1_o & (~x4_o)
	xor $t9,$t9,$s3 # x4_o = x4_o ^ t1_o
	
	not $s5,$t2
	and $s0,$t4,$s5 # t0_e = x2_e & (~x1_e)
	xor $s0,$s0,$t0 # t0_e = t0_e ^ x0_e
	
	not $s5,$t3
	and $s1,$t5,$s5 # t0_o = x2_o & (~x1_o)
	xor $s1,$s1,$t1 # t0_o = t0_o ^ x0_o
	
	not $s5,$s2
	and $s0,$s0,$s5 #  t0_e = t0_e & (~t1_e)
	xor $s0,$s0,$t6 #  t0_e = t0_e ^ x3_e
	
	not $s5,$s3
	and $s1,$s1,$s5 #  t0_o = t0_o & (~t1_o)
	xor $s1,$s1,$t7 #  t0_o = t0_o ^ x3_o
	
	not $s5,$t2
	and $s2,$t4,$s5 # t1_e = x2_e & (~x1_e)
	xor $s2,$s2,$t0 # t1_e = t1_e ^ x0_e
	
	not $s5,$t3
	and $s3,$t5,$s5 # t1_o = x2_o & (~x1_o)
	xor $s3,$s3,$t1 # t1_o = t1_o ^ x0_o
	
	not $s5,$s2
	and $s2,$t2,$s5 # t1_e = x1_e & (~t1_e)
	xor $s2,$s2,$t8 # t1_e = t1_e ^ x4_e
	
	not $s5,$s3
	and $s3,$t3,$s5 # t1_o = x1_o & (~t1_o)
	xor $s3,$s3,$t9 # t1_o = t1_o ^ x4_o
	
	not $s5,$t6
	and $s2,$s2,$s5 #  t1_e = t1_e & (~x3_e)
	xor $s2,$s2,$t4 #  t1_e = t1_e ^ x2_e
	
	not $s5,$t7
	and $s3,$s3,$s5 #  t1_o = t1_o & (~x3_o)
	xor $s3,$s3,$t5 #  t1_o = t1_o ^ x2_o
	
	not $s5,$t4
	and $t4,$t6,$s5#  x2_e = x3_e & (~x2_e)
	xor $t2,$t2,$t4  #  x1_e = x1_e ^ x2_e
	
	not $s5,$t5
	and $t5,$t7,$s5 # x2_o = x3_o & (~x2_o)
	xor $t3,$t3,$t5 #  x1_o = x1_o ^ x2_o
	
	xor $t2,$t2,$t0 # x1_e = x1_e ^ x0_e
	xor $t0,$t0,$t8 # x0_e = x0_e ^ x4_e
	xor $t6,$s0,$s2 # x3_e = t0_e ^ t1_e
	not $t4,$s2     # x2_e =~ t1_e
	
	xor $t3,$t3,$t1 # x1_o = x1_o ^ x0_o
	xor $t1,$t1,$t9 # x0_o = x0_o ^ x4_
	xor $t7,$s1,$s3 # x3_o = t0_o ^ t1_o
	not $t5,$s3
	##################################################################################################
	#Linear Layer#
	move $s0,$t0 # t0_e  = x0_e
	move $s1,$t1 # t0_o  = x0_o
	move $s2,$t2 # t1_e  = x1_e
	move $s3,$t3 # t1_o  = x1_o
	
	ror $s5,$s1,9
	xor $t0,$t0,$s5 # x0_e ^= ROTR32(t0_o, R_O[0][0])
	
	ror $s5,$s0,10
	xor $t1,$t1,$s5 # x0_o ^= ROTR32(t0_e, R_E[0][0])
	
	ror $s5,$s3,19
	xor $t2,$t2,$s5 #  x1_e ^= ROTR32(t1_o, R_O[1][0])
	
	ror $s5,$s2,20
	xor $t3,$t3,$s5 # x1_o ^= ROTR32(t1_e, R_E[1][0])
	
	ror $s5,$s0,14
	xor $t0,$t0,$s5 # x0_e ^= ROTR32(t0_e, R_E[0][1])
	
	ror $s5,$s1,14
	xor $t1,$t1,$s5 # x0_o ^= ROTR32(t0_o, R_O[0][1])
	
	ror $s5,$s3,30
	xor $t2,$t2,$s5 # x1_e ^= ROTR32(t1_o, R_O[1][1])
	
	ror $s5,$s2,31
	xor $t3,$t3,$s5 # x1_o ^= ROTR32(t1_e, R_E[1][1])
	
	move $s0,$t4 #  t0_e  = x2_e
	move $s1,$t5 # t0_o  = x2_o
	move $s2,$t6 # t1_e  = x3_e
	move $s3,$t7 # t1_o  = x3_o
	
	ror $s5,$s1,0
	xor $t4,$t4,$s5 # x2_e ^= ROTR32(t0_o, R_O[2][0])
	
	ror $s5,$s0,1
	xor $t5,$t5,$s5 #  x2_o ^= ROTR32(t0_e, R_E[2][0])
	
	ror $s5,$s2,5
	xor $t6,$t6,$s5 # x3_e ^= ROTR32(t1_e, R_E[3][0])
	
	ror $s5,$s3,5
	xor $t7,$t7,$s5 # x3_o ^= ROTR32(t1_o, R_O[3][0])
	
	ror $s5,$s0,3
	xor $t4,$t4,$s5 # x2_e ^= ROTR32(t0_e, R_E[2][1])
	
	ror $s5,$s1,3
	xor $t5,$t5,$s5 # x2_o ^= ROTR32(t0_o, R_O[2][1])
	
	ror $s5,$s3,8
	xor $t6,$t6,$s5 # x3_e ^= ROTR32(t1_o, R_O[3][1])
	
	ror $s5,$s2,9
	xor $t7,$t7,$s5 # x3_o ^= ROTR32(t1_e, R_E[3][1])
	
	move $s0,$t8 # t0_e  = x4_e
	move $s1,$t9 # t0_o  = x4_o
	
	ror $s5,$s1,3
	xor $t8,$t8,$s5 # x4_e ^= ROTR32(t0_o, R_O[4][0])
	
	ror $s5,$s0,4
	xor $t9,$t9,$s5 # x4_o ^= ROTR32(t0_e, R_E[4][0])
	
	ror $s5,$s1,20
	xor $t8,$t8,$s5 # x4_e ^= ROTR32(t0_o, R_O[4][1])
	
	ror $s5,$s0,21
	xor $t9,$t9,$s5 # x4_o ^= ROTR32(t0_e, R_E[4][1])
	#################################################################################
	#Return#
	lw  $s0,0($sp)
	lw  $s1,4($sp)
	lw  $s2,8($sp)
	lw  $s3,12($sp)
	lw  $s5,16($sp)
	lw  $ra,20($sp)
	add $sp,$sp,24
	jr $ra
	
	##################################################################################
	#premutation 12 #
	P12_32: 
	addi $sp,$sp,-12
	sw   $a0,0($sp)
	sw   $a1,4($sp)
	sw   $ra,8($sp)
	
	li $a0,0xc
	li $a1,0xc
	jal ROUND32
	
	li $a0,0x9
	li $a1,0xc
	jal ROUND32
	
	li $a0,0xc
	li $a1,0x9
	jal ROUND32
	
	li $a0,0x9
	li $a1,0x9
	jal ROUND32
	
	li $a0,0x6
	li $a1,0xc
	jal ROUND32
	
	li $a0,0x3
	li $a1,0xc
	jal ROUND32
	
	li $a0,0x6
	li $a1,0x9
	jal ROUND32
	
	li $a0,0x3
	li $a1,0x9
	jal ROUND32
	
	li $a0,0xc
	li $a1,0x6
	jal ROUND32
	
	li $a0,0x9
	li $a1,0x6
	jal ROUND32
	
	li $a0,0xc
	li $a1,0x3
	jal ROUND32
	
	li $a0,0x9
	li $a1,0x3
	jal ROUND32
	
	lw   $a0,0($sp)
	lw   $a1,4($sp)
	lw   $ra,8($sp)
	addi $sp,$sp,12
	jr $ra
	##################################################################################
	#premutation 16 #
	P6_32:
	
	addi $sp,$sp,-12
	sw   $a0,0($sp)
	sw   $a1,4($sp)
	sw   $ra,8($sp)
	
	li $a0,0x6
	li $a1,0x9
	jal ROUND32
	
	li $a0,0x3
	li $a1,0x9
	jal ROUND32
	
	li $a0,0xc
	li $a1,0x6
	jal ROUND32
	
	li $a0,0x9
	li $a1,0x6
	jal ROUND32
	
	li $a0,0xc
	li $a1,0x3
	jal ROUND32
	
	li $a0,0x9
	li $a1,0x3
	jal ROUND32
		
	
	lw   $a0,0($sp)
	lw   $a1,4($sp)
	lw   $ra,8($sp)
	addi $sp,$sp,12
	jr $ra

  
#########################################################################################################    
      #RotateRight(x,n)=RotateRight($a0,$a1)
      #this function rotates the register x by n number 
RotateRight:  addi $sp,$sp,-8
              sw   $s0,0($sp)
              sw   $s1,4($sp)
              add $s0,$zero,$a0
              srlv $a0,$a0,$a1  #(x)>>(n)
              addi $s1 ,$zero,32
              sub $s1,$s1,$a1 
              sllv $s0,$s0,$s1  # (x)<<32-(n)
              or $a0,$a0,$s0    #(((x)>>(n))|((x)<<(32-(n))))
              lw   $s0,0($sp)
              lw   $s1,4($sp)
              addi $sp,$sp,8
              jalr $zero ,$ra
           #return value in $a0
######################################################################
   #EXT_BYTE32(x,n)=EXT_BYTE32($a0,$a1)
   #this function shift right the register x by 8*(3-n) and cut the lowest byte
EXT_BYTE32: addi $sp,$sp,-4
            sw   $s0,0($sp)
            addi $s0,$zero,3
            sub $a1,$s0,$a1   #(3-(n)
            mul $a1,$a1,8     #8*(3-(n)
            srlv $a0,$a0,$a1  #(x)>>(8*(3-(n))
            lw  $s0,0($sp) 
            addi $sp,$sp,4	
           jalr $zero ,$ra
      #return value in $a0
######################################################################################            
#INS_BYTE32(x,n)=INS_BYTE32($a0,$a1)
#this function shift left register x by 8*(3-(n)) 
INS_BYTE32: addi $s0,$zero,3   #(3-(n))
            sub $a1,$s0,$a1
            mul $a1,$a1,8   #8*(3-(n))
            sllv $a0,$a0,$a1  #(x)<<(8*(3-(n))          
            jalr $zero ,$ra
   # return in $a0
###############################################################################################
#u32BIG(a0)
#this function converts register x to big endian 
 U32BIG :      addi $sp,$sp,-16              
               sw   $s0,0($sp)
               sw   $s1,4($sp)
               sw   $s2,8($sp)
	       sw   $ra,12($sp)    
	       addi $a1,$zero,8
	       add $s2,$zero,$a0 #store  value of x in $s2
	       jal RotateRight  #ROTR32(x,  8) 
	        lui $s0,0xff00
               addi $s0,$s0,0xff00  #0xFF00FF00
               and $a0,$a0,$s0 #(ROTR32(x,  8) & (0xFF00FF00)
	        addi $a1,$zero,24
	        add $s1,$zero,$a0 # store value of (ROTR32(x,  8) & (0xFF00FF00) in $s3
	        add $a0,$zero,$s2 
	       jal RotateRight  #ROTR32(x, 24)
	        lui $s0,0x00ff
               addi $s0,$s0,0x00ff #0x00FF00FF
               and $a0,$a0,$s0  #(ROTR32(x, 24) & (0x00FF00FF))
               or $a0,$a0,$s1   #((ROTR32(x,  8) & (0xFF00FF00))|((ROTR32(x, 24) & (0x00FF00FF))))
               lw   $s0,0($sp)
               lw   $s1,4($sp)
               lw   $s2,8($sp)
               lw  $ra,12($sp)
	       addi $sp,$sp,16
               jalr $zero ,$ra
       #return value in $a0
#############################################
#EXPAND_SHORT(x)=EXPAND_SHORT($a0)
# the function expands 16 bit register to 32 bit register 
EXPAND_SHORT : addi $sp,$sp,-12              
               sw   $s0,0($sp)
               sw   $s1,4($sp)
               sw   $s2,8($sp)    
               addi $s0,$zero,0xffff
               and $a0,$a0,$s0  #x &= 0x0000ffff;
               add $s1,$zero,$a0 
               sll $s1,$s1,8	#(x << 8)	
               or $a0,$a0,$s1   #(x | (x << 8))
               lui $s2,0x00ff   # 0x00ff00ff
               addi $s2,$s2,0x00ff
               and $a0,$a0,$s2 #x = (x | (x << 8)) & 0x00ff00ff;
               add $s1,$zero,$a0
               sll $s1,$s1,4		
               or $a0,$a0,$s1
               lui $s2,0x0f0f
               addi $s2,$s2,0x0f0f
               and $a0,$a0,$s2  #x = (x | (x << 4)) & 0x0f0f0f0f;
               add $s1,$zero,$a0
               sll $s1,$s1,2		
               or $a0,$a0,$s1
               lui $s2,0x3333
               addi $s2,$s2,0x3333
               and $a0,$a0,$s2   # x = (x | (x << 2)) & 0x33333333;
               add $s1,$zero,$a0
               sll $s1,$s1,1		
               or $a0,$a0,$s1
               lui $s2,0x5555
               addi $s2,$s2,0x5555
               and $a0,$a0,$s2  #x = (x | (x << 1)) & 0x55555555;
               lw   $s0,0($sp)
               lw   $s1,4($sp)
               lw   $s2,8($sp)
               addi $sp,$sp,12  
               jalr $zero ,$ra
               #retrun value in $a0
###########################################
#EXPAND_U32(var,var_o,var_e)=EXPAND_U32($a0,$a1,$a0)
#a0->var_e and a1->var_o   a0->var
#this function makes 32 bit register var from its even numbers var_e and odd numbers var_o
EXPAND_U32:  addi $sp,$sp,-8
             sw   $s2,0($sp)
	     sw   $ra,4($sp)
            jal EXPAND_SHORT #t0_e = (var_e); and EXPAND_SHORT(t0_e);
            add $s2,$zero,$a0 # store t0_e in $s2
            add $a0,$zero,$a1 
            jal EXPAND_SHORT # EXPAND_SHORT(t0_o);
            sll $a0,$a0,1  #(t0_o << 1)
            or $a0,$a0,$s2 #var = t0_e | (t0_o << 1);
            lw  $s2,0($sp)
            lw  $ra,4($sp)
            add $sp,$sp,8
           jalr $zero ,$ra
# return value in $ a0
############################################
 #COMPRESS_LONG(x)=COMPRESS_LONG($a0)
 #this function compresses 32 bit register to 16 bit you can use it to make var_e and var_o
 COMPRESS_LONG:addi $sp,$sp,-12              
               sw   $s0,0($sp)
               sw   $s1,4($sp)
               sw   $s2,8($sp) 
               lui $s0,0x5555
              addi $s0,$s0,0x5555
               and $a0,$a0,$s0 #x &= 0x55555555;
               add $s1,$zero,$a0
               srl $s1,$s1,1	#(x >> 1)	
               or $a0,$a0,$s1   #(x | (x >> 1))
               lui $s0,0x3333
               addi $s0,$s0,0x3333
               and $a0,$a0,$s0   #x = (x | (x >> 1)) & 0x33333333;
               add $s1,$zero,$a0
               srl $s1,$s1,2		
               or $a0,$a0,$s1  
               lui $s2,0x0f0f
               addi $s2,$s2,0x0f0f
               and $a0,$a0,$s2 #x = (x | (x >> 2)) & 0x0f0f0f0f;
               add $s1,$zero,$a0
               srl $s1,$s1,4		
               or $a0,$a0,$s1
               lui $s2,0x00ff
               addi $s2,$s2,0x00ff
               and $a0,$a0,$s2    #x = (x | (x >> 4)) & 0x00ff00ff;
               add $s1,$zero,$a0
               srl $s1,$s1,8		
               or $a0,$a0,$s1
               lui $s2,0x000
               addi $s2,$s2,0xffff
               and $a0,$a0,$s2 #x = (x | (x >> 8)) & 0x0000ffff;
               lw   $s0,0($sp)
               lw   $s1,4($sp)
               lw   $s2,8($sp)
	       addi $sp,$sp,12
               jalr $zero ,$ra
     #return value in $a0    
################################################################
# COMPRESS_U32(var,var_o,var_e)= COMPRESS_U32($a0,$a1,$a2)
#this function compresses 32 bit register and divides it into 2 16-bit registers (var_o and var_e)
COMPRESS_U32:addi $sp,$sp,-4
	     sw   $ra,0($sp)
	     srl $a1,$a0,1   
           jal 	COMPRESS_LONG
            add $a2,$zero,$a0
            add $a0,$zero,$a1
           jal COMPRESS_LONG
            add $a1,$zero,$a0
            lw  $ra,0($sp)
	    add $sp,$sp,4
            jalr $zero ,$ra 
 
     # return two values var_0->$a1 and var_e->$a2
 ##################################################################
#COMPRESS_BYTE_ARRAY(a,var_o,var_e)=COMPRESS_BYTE_ARRAY(a0,a1,$a3,$a2)
#a3-> var_o and  a2->var_e  (a))[1]-> a1  (a)[0]->a0
#this function divides 64 bit block in a0,a1 into two 32 bit registers one is even ($a2) and other is odd($a3)
COMPRESS_BYTE_ARRAY: addi $sp,$sp,-20
                     sw   $s0,0($sp)
                     sw   $s1,4($sp)
                     sw   $s2,8($sp)
                     sw   $s3,12($sp)
                     sw   $ra,16($sp)
	             add $s3,$zero,$a1
	             jal U32BIG    #t1_e = U32BIG(((u32*)(a))[0]);
	             add $a1,$zero,$s3 
	             srl $a3,$a0,1   #t1_o = t1_e >> 1;
	             jal COMPRESS_LONG #COMPRESS_LONG(t1_e)
	             sll $a2,$a0,16    #t1_e << 16;
	             add $a0,$zero,$a3
                     jal COMPRESS_LONG #COMPRESS_LONG(t1_o);
                     sll $a3,$a0,16    #t1_o << 16
                     add $a0,$zero,$a1
                     add $s0,$zero,$a2
                     add $s1,$zero,$a3
                     jal U32BIG	  #var_e = U32BIG(((u32*)(a))[1]);
                     add $a2,$zero,$s0
                     add $a3,$zero,$s1
	             srl $s2,$a0,1  #var_o = var_e >> 1;
	             jal COMPRESS_LONG #COMPRESS_LONG(var_e);
	             or $a2,$a2,$a0 #var_e |= t1_e << 16;
	             add $a0,$zero,$s2
                     jal COMPRESS_LONG #COMPRESS_LONG(var_o);
               	     or $a3,$a3,$a0 #var_o |= t1_o << 16;
        	     lw $s0,0($sp)
		     lw $s1,4($sp)
		     lw $s2,8($sp)
		     lw $s3,12($sp)
		     lw   $ra,16($sp)
		     addi $sp,$sp,20           
	 	     jalr $zero ,$ra
	#return two values a3-> var_o and  a2->var_e

####################################################################################################################################
initialization:
	addi $sp,$sp,-4
	sw $ra , 0($sp)
	
	addi $sp,$sp,-4
	sw $ra , 0($sp)
	la $s7,k	 # load the addres of the 1st byte of the key in $s7
	la $s6,npub	 # load the addres of the 1st byte of the nouns in $s7
	
	# COMPRESS_BYTE_ARRAY(k,K0_o,K0_e) 
	lw $a0,0($s7)
	lw $a1,4($s7)	
	jal COMPRESS_BYTE_ARRAY
	add $s0,$a2,0
	add $s1,$a3,0
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw $a0,8($s7)
	lw $a1,12($s7)	
	jal COMPRESS_BYTE_ARRAY
	add $s2,$a2,0
	add $s3,$a3,0
	
	# COMPRESS_BYTE_ARRAY(npub,N0_o,N0_e)
	lw $a0,0($s6)
	lw $a1,4($s6)	
	jal COMPRESS_BYTE_ARRAY
	addi $t6,$a2,0 # x3_e = N0_e;
	addi $t7,$a3,0 # x3_o = N0_o;
	
	#  COMPRESS_BYTE_ARRAY(npub+8,N1_o,N1_e)
	lw $a0,8($s6)
	lw $a1,12($s6)	
	jal COMPRESS_BYTE_ARRAY
	addi $t8,$a2,0# x4_e = N1_e;
	addi $t9,$a3,0# x4_o = N1_o;
	

	li $t0,0x80400c06#  t1_e = (u32)((CRYPTO_KEYBYTES * 8) << 24 | (RATE * 8) << 16 | PA_ROUNDS << 8 | PB_ROUNDS << 0);
	srl  $t1,$t0,1 #t1_o = t1_e >> 1
		
	#COMPRESS_LONG(t1_e) #t1_e = $s2 and compress long takes and return a0 
	addi $a0,$t0,0	
	jal COMPRESS_LONG
	addi $t0,$a0,0
	
	# COMPRESS_LONG(t1_o)#t1_o = $s3 and compress long takes and return a0 
	addi $a0,$t1,0
	jal COMPRESS_LONG
	addi $t1,$a0,0	
	
	sll $t0,$t0,16	#x0_e = t1_e << 16
	sll $t1,$t1,16	#x0_o = t1_o << 16
	addi $t2,$s0,0	#x1_o = K0_o
	addi $t3,$s1,0	#x1_e = K0_e
	addi $t4,$s2,0	#x2_e = K1_e
	addi $t5,$s3,0	#x2_o = K1_o
	
	jal P12_32	#P12_32
	
	xor $t6,$t6,$s0	#x3_e ^= K0_e
	xor $t7,$t7,$s1	#x3_o ^= K0_o
	xor $t8,$t8,$s2 #x4_e ^= K1_e
	xor $t9,$t9,$s3	#x4_o ^= K1_o

lw   $ra,0($sp)
addi $sp,$sp,4
 jalr $zero ,$ra	
########################end initialization	#####################
########################process associated data	#####################
########################process associated data	#####################

associated:
addi $sp,$sp,-4
sw $ra , 0($sp)
la $s7,associated_data #load the address of associated data (pointer ad in the c code)
addi $a0,$s7,0 #put the address in a0 to make it as input for strlen function
jal strlen # reterns the length of the associated data in v1
beqz $v1,end_ed #if (adlen) # if  $v1= adlen=0 get out of the if and go to end label
add $v0,$v1,0 #rlen($v0),#adlen=($v1)

while_loop:   
	blt  $v0,RATE,cont0#  while (rlen >= RATE) , RATE= 8 bytes
		#load $a0 and $a1 with bytes of the associate datat array ????? ask hossam???????????????a[0]is the addres of the first 2 bytes  a[1]the addres of the second 2 bytes????
		lw $a0,0($s7)
		lw $a1,4($s7)	
		
		# COMPRESS_BYTE_ARRAY(ad,in_o,in_e);
		# (a))[1]-> a1 ### (a)[0]->a0 #### a3-> var_o ##### a2->var_e  
				
		jal COMPRESS_BYTE_ARRAY# takes the associated data itself ($a0,$a1)=(ad)and generates ($a2,$a3)=(in_o,in_e)
		xor $t0,$t0,$a2 #x0_e ^= in_e
		xor $t1,$t1,$a3 #x0_o ^= in_o
		jal P6_32
		subiu $v0,$v0,RATE #rlen -= RATE
		addiu $s7,$s7,RATE #ad += RATE	
j while_loop
	
cont0:	
	li $s2,0# t1_e = 0;
	li $s3,0#t1_o = 0;
	
	li $s4,0 # $4 is i the counter of the for loop
	
for_loop:	
	bge $s4,$v0,exit_for #for (i = 0; i < rlen; ++i, ++ad) if[ i($s4)>=rlen($v0)] exit the loop
		lbu $a0,0($s7)#load the word which ad points to in $a0 as the first argument taken by INS_BYTE
		add $a1,$s4,0  #load $a1 with $v4(i)as the second argument for INS_BYTE32
		bge $s4,4,else1 # if(i < 4)		
			jal INS_BYTE32 #INS_BYTE32(*ad, i) we shift bytes of associated data(*ad) i times,then we insert them in t1_0 and t1_e (s0 , s1)
			or $s3,$s3,$a0# the reterned value (shifted ) from INS_BYTE $a0 is ored with t1_0 (t1_o |= INS_BYTE32(*ad, i))		
			j cont1
		else1:	#t1_e |= INS_BYTE32(*ad, (i - 4))
			subu $a1,$s4,4
			jal INS_BYTE32
			or $s2,$s2,$a0		
		cont1:
		addiu $s4,$s4,1# ++i
		addiu $s7,$s7,1# ++ad		
j for_loop

exit_for:	
		li $a0,0x80 #load $a0 with 0x80 as the first argument of INS_BYTE32
		add $a1,$v0,0 #load $a1 with $v0(rlen)	as the second argument for INS_BYTE32
		bge $v0,4,else2 #if(rlen < 4)
			jal INS_BYTE32
			or $s3,$s3,$a0#t1_o |= INS_BYTE32(0x80, rlen)
			j cont2		
		else2:#t1_e |= INS_BYTE32(0x80, (rlen - 4))
			sub $a1,$v0,4
			jal INS_BYTE32
			or $s2,$s2,$a0
		cont2:	
		
		#COMPRESS_U32(var,var_o,var_e)
		#a0->var  a1->var_o  a2->var_e
		
		#COMPRESS_U32(t1_e,in_o,in_e)
		add $a0,$s2,0 # $a0(the argument taken by COMPRESS_U32)	= $s2 (t1_e)	
		jal COMPRESS_U32
		#move COMPRESS_U32 output in registers so and s1 to reuse them 
		# $s0 <------ $in_o
		# $s1 <------ $in_e
		add $s0,$a1,0 
		add $s1,$a2,0
		
		
		#COMPRESS_U32(t1_o,t0_o,t0_e)
		add $a0,$s3,0 # $a0(the argument taken by COMPRESS_U32)	= $s3 (t1_0)	
		jal COMPRESS_U32
		#move COMPRESS_U32 output in registers s5 and s5 o reuse them 
		# $s5 <------ $t0_o
		# $s3 <------ $t0_e
		add $s5,$a1,0  
		add $s3,$a2,0
		
		#in_o |= t0_o << 16
		sll $s5,$s5,16 
		or $s0,,$s0,$s5
		#in_e |= t0_e << 16
		sll $s3,$s3,16
		or $s1,$s1,$s3
		
		xor $t0,$t0,$s1	#x0_e ^= in_e
		xor $t1,$t1,$s0	#x0_o ^= in_o
		jal P6_32
end_ed:
xori $t8,1 #x4_e ^= 1
lw   $ra,0($sp)
addi $sp,$sp,4
 jalr $zero ,$ra
########################end associated data	#####################

Plain:          addi $sp,$sp,-32
		sw   $s1,0($sp)
		sw   $s2,4($sp)
		sw   $s3,8($sp)
		sw   $s4,12($sp)
		sw   $s5,16($sp)
		sw   $s6,20($sp)
		sw   $s7,24($sp)
		sw   $ra,28($sp)
		la $a0,PlainText
		jal strlen
		############just for test###################
		#li $s2,0x296f047b
		#li $s3,0xc2992e3e
		#li $t0,0xa3e3a193
		#li $t1,0x75f08ec8
		#li $t2,0xb570519b
		#li $t3,0x7673a5ef
		#li $t4,0xb488f198
		#li $t5,0x3d7520e1
		#li $t6,0xcee6e576
		#li $t7,0x91950cd
		#li $t8,0x6fd487fd
		#li $t9,0x1beb7ce6#	
		#li $s2,0x969e3617
		#li $s3,0x2380a7c7
		#li $t0,0x9333b3b9
		#li $t1,0x18c95201
		#li $t2,0x3a0e61f0
		#li $t3,0x7eba294d
		#li $t4,0xe20d165b
		#li $t5,0x71515cc8
		#li $t6,0xed094700
		#li $t7,0x1157ede2
		#li $t8,0xabc42fbd
		#li $t9,0xe5cdade2	
		
		#############################################
	
		#################################
		#la   $k0,cipherText
		#la   $k1,m
		li  $gp,0x00
		add $s7,$zero,$v1 # getting the value of rlen
	while_p1:
		blt $s7,RATE,Exit_p1
		
		add $a0,$zero,$t0
		add $a1,$zero,$t1
		jal EXPAND_U32
		add $s2,$zero,$a0 # EXPAND_U32(t1_e,x0_o,x0_e);
		
		srl $a0,$t0,16
		srl $a1,$t1,16
		jal EXPAND_U32
		add $s3,$zero,$a0 # EXPAND_U32(t1_o,x0_o>>16,x0_e>>16);
		
		add $a0,$s3,$zero
		jal U32BIG # U32BIG(t1_o) 
		lw  $s5,cipherText($gp) # getting 32 bit of the cipher text which is pointed to right now
		xor $s4,$s5,$a0
		sw  $s4,m($gp) # storing the computed plain text in the memory
		
		addi $gp,$gp,4 #increment the pointer to the plain and cipher text
		
		
		add $a0,$s2,$zero
		jal U32BIG
		lw  $s6,cipherText($gp)
		xor $s4,$s6,$a0
		sw  $s4,m($gp)
		
		add $a0,$s5,$zero
		add $a1,$s6,$zero
		jal COMPRESS_BYTE_ARRAY
		add $t0,$a2,$zero
		add $t1,$a3,$zero
		
		jal P6_32								
										
		
	
		subiu $s7,$s7,8 # rlen -= RATE
		addi  $gp,$gp,4 # m += RATE , c += RATE
		j     while_p1		
	Exit_p1:							
																	
		######################################### End of While #######################
	
		add $a0,$zero,$t0
		add $a1,$zero,$t1
		jal EXPAND_U32
		add $s2,$zero,$a0 # EXPAND_U32(t1_e,x0_o,x0_e);
		
		srl $a0,$t0,16
		srl $a1,$t1,16
		jal EXPAND_U32
		add $s3,$zero,$a0 # EXPAND_U32(t1_o,x0_o>>16,x0_e>>16);
		
		############################### FOR LOOP #####################################
		
		li $k0,0 # initializing the counter i=0
	for_p2:	
		bgeu $k0,$s7,Exit_p2
				################### IF STATEMENT ####################
				bgeu $k0,4,DoElse_p2 # ELSE ( if (i < 4) )
				
				add $a0,$s3,$zero
				add $a1,$k0,$zero
				jal EXT_BYTE32 #retutn the Extracted byte from t1_o in a0
				lbu  $s5,cipherText($gp) #get 8 bits of the cipher and store them in s5
				xor $s6,$a0,$s5
				sb  $s6,m($gp) # *m = EXT_BYTE32(t1_o, i) ^ *c
				
				addiu $a0,$zero,0xff
				add   $a1,$zero,$k0
				jal   INS_BYTE32 #INS_BYTE32(0xff, i); 
				not   $a0,$a0 #~INS_BYTE32(0xff, i);
				and   $s3,$s3,$a0 # t1_o &= ~INS_BYTE32(0xff, i);
				
				
				add   $a0,$zero,$s5
				add   $a1,$zero,$k0
				jal   INS_BYTE32
				or    $s3,$s3,$a0
				
				
				
				j SkipElse_p2
			DoElse_p2:
				add $a0,$s2,$zero
				subi $a1,$k0,4
				jal EXT_BYTE32 #retutn the Extracted byte from t1_o in a0
				lb  $s5,cipherText($gp) #get 32 bits of the cipher and store them in s5
				xor $s6,$a0,$s5
				sb  $s6,m($gp) # *m = EXT_BYTE32(t1_o, i) ^ *c
				
				addiu $a0,$zero,0xff
				subi  $a1,$k0,4
				jal   INS_BYTE32 #INS_BYTE32(0xff, i); 
				not   $a0,$a0 #~INS_BYTE32(0xff, i);
				and   $s3,$s3,$a0 # t1_o &= ~INS_BYTE32(0xff, i);
				
				
				add   $a0,$zero,$s5
				subi  $a1,$k0,4
				jal   INS_BYTE32
				or    $s3,$s3,$a0				
			
			SkipElse_p2:
			################################### END of IF STATEEMENT ##########
					
		addiu $k0,$k0,1 #i++
		addiu $gp,$gp,1 # m++ c++
		
		j for_p2
							
	Exit_p2:
	############################################# IF ################################
	
		bgeu $s7,4,DoElse_p3
		
		addi $a0,$zero,0x80
		add  $a1,$zero,$s7
		jal  INS_BYTE32
		xor $s3,$s3,$a0
		
		j SkipElse_p3
	DoElse_p3:
		addi $a0,$zero,0x80
		subi  $a1,$s7,4
		jal  INS_BYTE32
		xor $s2,$s2,$a0
	SkipElse_p3:			
	#################################################################################
		
		add $a0,$s2,$zero
		jal COMPRESS_U32
		add $t1,$a1,$zero
		add $t0,$a2,$zero
		
		add $a0,$s3,$zero
		jal COMPRESS_U32
		add $s1,$a1,$zero
		add $s0,$a2,$zero
		
		sll $s5,$s1,16
		or  $t1,$t1,$s5
		
		sll $s5,$s0,16
		or  $t0,$t0,$s5
	###########################################################################					
		
		
		
		lw   $s1,0($sp)
		lw   $s2,4($sp)
		lw   $s3,8($sp)
		lw   $s4,12($sp)
		lw   $s5,16($sp)
		lw   $s6,20($sp)
		lw   $s7,24($sp)
		lw   $ra,28($sp)
		addi $sp,$sp,32
		jr $ra
##########################################################################		
#Finalization
FD: addi $sp,$sp,-4
	sw $ra , 0($sp)
	la $s7,k
    # COMPRESS_BYTE_ARRAY(k,K0_o,K0_e)  #COMPRESS_BYTE_ARRAY(a,var_o,var_e)=COMPRESS_BYTE_ARRAY(a0,a1,$a3,$a2)
	lw $a0,0($s7)
	lw $a1,4($s7)	
	jal COMPRESS_BYTE_ARRAY
	add $s0,$a2,0 #k0_e
	add $s1,$a3,0 #K0_o
	
	# COMPRESS_BYTE_ARRAY(k+8,K1_o,K1_e)
	lw $a0,8($s7)
	lw $a1,12($s7)	
	jal COMPRESS_BYTE_ARRAY
	add $s2,$a2,0 #K1_e
	add $s3,$a3,0 #K1_o
        xor $t2,$t2,$s0 #x1_e ^= K0_e;
	xor $t3,$t3,$s1 #x1_o ^= K0_o;
	xor $t4,$t4,$s2 #x2_e ^= K1_e;
	xor $t5,$t5,$s3 #x2_o ^= K1_o;
	jal P12_32    #P12_32;
	xor $t6,$t6,$s0 #x3_e ^= K0_e;
	xor $t7,$t7,$s1 #x3_o ^= K0_o;
	xor $t8,$t8,$s2 #x4_e ^= K1_e;
	xor $t9,$t9,$s3 #x4_o ^= K1_o;
	#EXPAND_U32(var,var_o,var_e)=EXPAND_U32($a0,$a1,$a0)
        #a0->var_e and a1->var_o   a0->var
	li $s4,0 #ret_value
	add $a0,$zero,$t6
	add $a1,$zero,$t7
	jal EXPAND_U32   #  EXPAND_U32(t1_e, x3_o, x3_e);
	add $s6,$zero,$a0 #t1_e
	srl $a0,$t6,16
	srl $a1,$t7,16
	jal EXPAND_U32  #EXPAND_U32(t1_o, x3_o >> 16, x3_e >> 16);
	add $s5,$zero,$a0 #t1_o
	#############Verify######################
	la $k0,cipherText  # if the length of the plain text(or the cipher text )  we add the some bytes to start saving the tag in a suitable place after the cipher
        li $a1,4    # $gp = $v1 + [4 - ($v1 mod 4 )] + $k0 
        div  $v1, $a1
        mfhi $a0
        subu $a1,$a1,$a0
        addu $gp,$v1,$a1
        addu $gp,$gp,$k0
        lw $s1,0($gp) #((u32*) c)[0]
        add $a0,$zero,$s5 
        jal U32BIG
        bne $a0,$s1 ,noteq1 #if (((u32*) c)[0] != U32BIG(t1_o))
        addi $s4,$s4,1#ret_val++
noteq1:  lw $s0,4($gp) #((u32*) c)[1]
        add $a0,$zero,$s6 
        jal U32BIG
        bne $a0,$s0 ,noteq2 #if (((u32*) c)[1] != U32BIG(t1_e))
        addi $s4,$s4,1  #ret_val++
 noteq2: add $a0,$zero,$t8
	add $a1,$zero,$t9
	jal EXPAND_U32   #  EXPAND_U32(t1_e, x3_o, x3_e);
	add $s6,$zero,$a0 #t1_e
	srl $a0,$t8,16
	srl $a1,$t9,16
	jal EXPAND_U32  #EXPAND_U32(t1_o, x3_o >> 16, x3_e >> 16);
	add $s5,$zero,$a0 #t1_o    
        lw $s1,8($gp) #((u32*) c)[2]
        add $a0,$zero,$s5 
        jal U32BIG
        bne $a0,$s1 ,noteq3 #if (((u32*) c)[2] != U32BIG(t1_o))
        addi $s4,$s4,1    #ret_val++
 noteq3:  lw $s0,4($gp) #((u32*) c)[3]
        add $a0,$zero,$s6 
        jal U32BIG
        bne $a0,$s0 ,noteq4   #if (((u32*) c)[3] != U32BIG(t1_e))
        addi $s4,$s4,1 #ret_val++
 noteq4: addi $s0,$zero,4
        bne $s0,$s4, ret_1
       addi $a0,$zero,0   #return 0 if the two tags are equal
       j ENDFD
ret_1:addi $a0,$zero,-1      #return -1 if the two tags aren't equal
 #return value in $a0       
ENDFD:        
        lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra		
		
		
		
		
		
		
		
		
