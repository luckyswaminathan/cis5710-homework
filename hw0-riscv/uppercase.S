        .section .data
input_string:   .asciz "Hello world!"

        # tohost/fromhost are data locations used by Spike
        .align 8
tohost: .byte 0
        .align 8
fromhost: .byte 0

        
        .section .text
        .globl _start
_start:
        # Load the address of the input string into a0
        la a0, input_string

loop:
        lb a1, 0(a0)
        beqz a1, end_program
        
        addi a2, a1, -'a'
        li a3, 26
        bge a2, a3, next_char
        blt a2, zero, next_char
        
        addi a1, a1, -32
        sb a1, 0(a0)

next_char:
        addi a0, a0, 1
        j loop



end_program:
        # jump here when you're done
        j end_program

