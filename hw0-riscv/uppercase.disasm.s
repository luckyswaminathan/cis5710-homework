
uppercase.bin:     file format elf32-littleriscv


Disassembly of section .text:

00010074 <_start>:
   10074:	ffff2517          	auipc	a0,0xffff2
   10078:	f8c50513          	addi	a0,a0,-116 # 2000 <__DATA_BEGIN__>

0001007c <loop>:
   1007c:	00050583          	lb	a1,0(a0)
   10080:	02058263          	beqz	a1,100a4 <end_program>
   10084:	f9f58613          	addi	a2,a1,-97
   10088:	01a00693          	li	a3,26
   1008c:	00d65863          	bge	a2,a3,1009c <next_char>
   10090:	00064663          	bltz	a2,1009c <next_char>
   10094:	fe058593          	addi	a1,a1,-32
   10098:	00b50023          	sb	a1,0(a0)

0001009c <next_char>:
   1009c:	00150513          	addi	a0,a0,1
   100a0:	fddff06f          	j	1007c <loop>

000100a4 <end_program>:
   100a4:	0000006f          	j	100a4 <end_program>
