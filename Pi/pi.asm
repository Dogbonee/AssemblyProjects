extern printf
extern exit

section .data
    msg db 'This is a executable that will compute PI.', 10,0
    format db "Total is %f", 10,0
    
    total dq 0.0
    addition dq 0.0
    constnum dq 4.0
    divide dq 1.0
    sign dq 1.0
    divideInc dq 2.0
    
    
    
section .bss
    result resq 1
    
    
section .text
global main

%macro PrintTotal 0
    sub esp, 8
    fst qword [esp]
    push format 
    call printf
    add esp, 12
%endmacro


main:
    mov ebp, esp; for correct debugging
    fninit
    push msg
    call printf
    add esp, 4; pop stack
    
    call computePI
    
    
    push 0
    call exit
    
    
computePI:

    fld qword [addition] ;push addition to float stack (st0)
    ;do math operations 
    fadd qword [constnum]
    fdiv qword [divide]
    fmul qword [sign]
    
    
    fld qword [total] ;push total to float stack (st1)
    fxch st1, st0 ;exchange addition and total
    faddp ;increment total with addition (st1 -> st0) and pop
    
    ;note at this point we have total in st0 until we printTotal
    
    PrintTotal
    fstp qword [total] ;float stack is now empty, we can change stuff now
    
    
    fld qword [divide]
    fadd qword [divideInc]
    fstp qword [divide]
    
    fld qword [sign]
    fchs
    fstp qword [sign]
    
    
    jmp computePI
    ret

    
    