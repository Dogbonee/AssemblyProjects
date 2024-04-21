;fibonacci
extern exit
extern printf

section .data 
fmt db "Fibonacci sequence number %ld is %ld", 10,0
num equ 6

section .text
global main

main:
    mov ebp, esp; for correct debugging
    ;write your code here
   
    mov eax, 0 ;var 1
    mov ebx, 1 ;var 2
    mov cx, num ;loop counter
    
    cmp cx, 0 ;don't bother calculating if it's zero
    je complete

fibonacciLoop:   
    
    mov edx, eax
    add eax, ebx 
    mov ebx, edx

    dec cx
    cmp cx, 0
    jne fibonacciLoop
    
complete:
    push eax
    push num
    push fmt
    call printf
    
    push 0
    call exit
