MAIN:
	lui  s1, 0xFFFFF
        
start:						# Test led and switch
	lw   s0, 0x70(s1)		# read switch
	#addi s0, zero, 0x3
	#slli s0, s0, 8
	#addi s0, s0, 0x2
	#addi s10, zero, 0xc
	#slli s10, s10, 20
	#add s0, s0, s10
	sw   s0, 0x60(s1)		# write led	
	jal getOp

getOp:	
	srli s2, s0, 21 # get operation
	jal getNum

getNum:
	srli s3, s0, 8
	andi s3, s3, 0xff
	andi s4, s0, 0xff	#得到8位数 B,前面全是0
	jal operation

operation:
	addi s5, zero, 0
	beq s2, s5, opAnd	#与运算
	addi s5, s5, 1
	beq s2, s5, opOr	#或运算
	addi s5, s5, 1
	beq s2, s5, opXor	#异或运算
	addi s5, s5, 1
	beq s2, s5, opAsllB	#A逻辑左移B位
	addi s5, s5, 1
	beq s2, s5, opAsraB	#A算术右移B位
	addi s5, s5, 1
	beq s2, s5, opBcomplement	#(A == 0) ? B : [B]补
	addi s5, s5, 1
	beq s2, s5, opAdivB	#A 除以 B
	jal opEmpty	#全都不跳转说明是无效运算符
	
opAnd:
	and s0, s3, s4
	jal transferTobinary
opOr:
	or s0, s3, s4
	jal transferTobinary
opXor:
	xor s0, s3, s4
	jal transferTobinary
opAsllB:
	sll s0, s3, s4
	jal over
opAsraB:
	#由于只取出了前8位，所以还未做符号位扩展
	#给A做符号位扩展
	andi s5, s3, 0x80
	bne s5, zero, extendA
	jal next
extendA:
	lui s6,0xfffff
	srai s6, s6, 4
	or s3, s3, s6
	jal next
next:
	sra s0, s3, s4
	jal over
opBcomplement:
	bne s3, zero , Bcom
	addi s0, s4, 0
	jal transferTobinary
Bcom:
	andi s5, s4, 0x80
	beq s5, zero, positive	#若移了7位后是等于零的，说明符号位为0，即为正数，否则是负数
	xori s0, s4, 0x7f #对低7位取反
	addi s0, s0, 1 #再加1求得负数的补码
	jal transferTobinary
positive:
	addi s0, s4, 0 #正数的补码
	jal transferTobinary
opAdivB:
		addi a1,zero, 1
		addi a6,zero, 6
		addi t1, s3, 0
		addi t0, s4, 0
		addi s0, x0, 0
		addi t6, x0, 0
		addi s10, x0, 0
		# A/B 有符号数
		# 最后的s0: 1符号 + 7数值
		srli s5, t1, 7 #A的符号位--s5
		srli s4, t0, 7 #B的符号位--s4
		xor s6, s5, s4 #结果的符号位--s6

		andi t1, t1, 0x7f #A*, [A*]补--t1
		andi t0, t0, 0x7f #B*, [B*]补--t0
		slli t3, a1, 7    #t3=1000 0000
		xori t4, t0, 0x7f #取反
		addi t4, t4, 1	#加1
		andi t4, t4, 0x7f 
		add t3, t3, t4    
		andi t3, t3, 0xff #[-B*]补--t3

		slli s10, s10, 1
		andi s10, s10, 0xff
		andi s11, t1, 0x40
		srli s11, s11, 6
		slli t1, t1, 1
		andi t1, t1, 0x7f
		add s10, s10, s11 #移位后的结果
		slli s0, s0, 1
		add s10, s10, t3 # no.1 + [-B*]补
		andi s10, s10, 0xff # 余数

		loop:
		srli t5, s10, 7 #余数的符号位--t5
		beq t5, x0, shang1   #余数为+, 商1
		beq t5, a1, shang0   #余数为-, 商0
		

		shang1:
			addi s0, s0, 1
			beq t6, a6, preExit
			slli s0, s0, 1
			slli s10, s10, 1
			andi s10, s10, 0xff
			andi s11, t1, 0x40
			srli s11, s11, 6
			slli t1, t1, 1
			andi t1, t1, 0x7f
			add s10, s10, s11 #移位后的结果
			add s10, s10, t3
			andi s10, s10, 0xff
			addi t6, t6, 1 #次数++
			jal x0, loop

		shang0:
			addi s0, s0, 0
			beq t6, a6, preExit
			slli s0, s0, 1
			slli s10, s10, 1
			andi s10, s10, 0xff
			andi s11, t1, 0x40
			srli s11, s11, 6
			slli t1, t1, 1
			andi t1, t1, 0x7f
			add s10, s10, s11 #移位后的结果
			add s10, s10, t0
			andi s10, s10, 0xff
			addi t6, t6, 1 #次数++
			jal x0, loop

		preExit:
			andi s11, s10, 0x80
			bne s11, zero, recover		#负数的话要恢复余数
		preExit2:
			andi s0, s0, 0xff
			slli s6, s6, 7
			andi s10, s10,0xff
			slli s10, s10, 8
			add s0, s0, s10
			add s0, s0, s6
			jal over_8
recover:
	add s10,s10,t0
	jal preExit2
			
opEmpty:
	addi s0, zero, 0
	jal over
transferTobinary:
	#先用s10保存答案
	addi s10, zero, 0
	srli s9, s0, 7
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 6
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 5
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 4
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 3
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 2
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 1
	andi s9, s9, 0x1
	add s10, s10, s9
	slli s10, s10, 4
	srli s9, s0, 0
	andi s9, s9, 0x1
	add s10, s10, s9
	#最后赋给s0
	addi s0, s10, 0
	sw   s0, 0x00(s1)
	jal  start
over:	#这种就清空前24位,是有符号整数的出口
	andi s0, s0, 0xff
	sw   s0, 0x00(s1)
	jal  start
over_8:	#这种要清空前20位,后面8位分别是余数，和商
	sw   s0, 0x00(s1)
	jal  start
