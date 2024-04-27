extern scanf
extern printf
extern putchar
extern exit

section .data

board db "_________"

promptX db "Enter X: ", 0
promptY db "Enter Y: ", 0
usedMessage db "The coordinates entered have already been used",10,0
OORMessage db "The coordinates must be in the range [1,3]",10,0

victoryMessage db "Victory!", 10, 0

testMsg db "Testing",10,0


players db "XO"
currentPlayer db "X"
playerOffset db 0

;current game is two player
sFmt db "%s"
cFmt db "%c"
dFmt db "%d"

section .bss

XVal resb 4
YVal resb 4

%macro PRINT 1
    push %1
    call printf
    add esp, 4
%endmacro

%macro PRINTBYTE 1
    push %1
    call putchar
    add esp, 4
%endmacro

%macro SCAN 2
    push %2
    push %1
    call scanf
    add esp, 8
%endmacro

section .text
global main
main:
    mov ebp, esp; for correct debugging  
     
    call printBoard

gameLoop:
    call checkCoords
    call doRound
    call checkVictory
    cmp eax, 1
    jne gameLoop ; need exit condition (3 in a row or tie)
       
       
    PRINT victoryMessage
    
    SCAN dFmt, XVal ;getch
    push 0
    call exit

 
    
doRound:
    
    call insertChar
  
    switchPlayer:  
        ;Switch player
        mov al, byte[playerOffset]
        xor al, 1
        mov byte[playerOffset], al
        mov ebx, players
        mov bl, byte[ebx + eax]
        mov byte[currentPlayer], bl
        
        
    ret
      
    
printBoard:
    mov eax, 0
    mov ebx, 0
    printLoop:
        mov al, byte[board+ebx]
        PRINTBYTE eax
        inc ebx
        checkNL:
            mov eax, ebx
            mov esi, 3
            div esi
            cmp edx, 0
            jne checkEnd
            PRINTBYTE 10
        checkEnd:
            cmp ebx, 9
            jne printLoop
    ret
    

OORCoords:
    PRINT OORMessage
checkCoords:
    PRINT promptY
    SCAN dFmt, YVal
    PRINT promptX
    SCAN dFmt, XVal
    
    
    ; Theres gotta be a more efficient way to do this
    mov al, byte[YVal]
    cmp al, 1
    jl OORCoords
    cmp al, 3
    jg OORCoords
    mov al, byte[XVal]
    cmp al, 1
    jl OORCoords
    cmp al, 3
    jg OORCoords
    
    ret
    
    
    
 
insertChar:
    xor ebx, ebx ; reset ebx to 0
    
    ; find offset to insert
    mov eax, dword[YVal] 
    sub eax, 1 ;start from 1, not 0
    mov ecx, 3 ;load multiplier
    mul ecx ; eax *= 3
    mov bl, al ; store for later, we need eax to store board
    add ebx, dword[XVal] ; add XVal to get an effective offset
    sub ebx, 1 ; remember we sub 1 from x and y because we start from 1, not 0
    
    ; Check if coordinates are taken
    mov cl, byte[board + ebx] ; load board at offset into ecx for comparison
    cmp cl, 0x5F ; '_' character
    jne usedCoords ; do not insert if the space is taken
    
    ;actual insertion
    mov eax, board 
    mov cl, byte[currentPlayer] ; load currentplayer char into register
    mov byte[eax + ebx], cl ; set the board at offset (ebx) to the currentchar
    jmp postInsertion
    usedCoords:
        PRINT usedMessage
        call switchPlayer
    postInsertion:
        ;print everything
        PRINTBYTE 10
        call printBoard   
        ret
  
  
victory:
    mov eax, 1
    ret
        
notVictory:
    mov eax, 0
    ret             
                    
                                
checkVictory:
    ;set eax to 1 if victory
    ; mov new byte to board, compare it with previous byte, if they are equal continue,
    ; if still true on edx == 3, victory
    mov eax, -1
    mov ebx, 0
    mov ecx, 0
    mov edx, 0
    victoryLoop:
        inc eax  
        mov ch, 0
        signChange:
            
            ;to check for victory, we are looking ahead one iteration
            ;bh stores our comparison byte, bl stores the byte we need to evaluate
            mov bh, byte[board+edx]
            
            ;check column
            push eax
            imul eax, 3    
            add eax, edx         
            mov bl, byte[board+eax]
            pop eax
            cmp bh, bl
            jne notVictory
            
            ;check row
            add eax, edx
            mov bl, byte[board+eax]
            sub eax, edx
            cmp bh, bl
            jne notVictory
            
            ;check diagonal
            push eax
            imul eax, 4
            add eax, edx
            mov bl, byte[board+eax]
            pop eax
            cmp bh, bl
            jne notVictory

            
            ; now we go kiddie corner and work backwards
            ; eax is negated to subtract instead of add
            ; edx is toggled to 8 to offset the board toward the kiddie corner
            xor edx, 8
            neg eax
            xor ch, 1
            cmp ch, 0
            je victoryLoop ; every other one
            jmp signChange ; when not jumping to victory loop
        
        
        
        ;
        cmp edx, 2
        je victory
        
    
        

          