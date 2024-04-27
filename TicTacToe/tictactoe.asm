extern scanf
extern printf
extern putchar
extern exit

;current game is two player
section .data

board db "_________"

promptX db "Enter X: ", 0
promptY db "Enter Y: ", 0
usedMessage db "The coordinates entered have already been used",10,0
OORMessage db "The coordinates must be in the range [1,3]",10,0

victoryMessage db "Player %c has won the Game!", 10, 0
tieMessage db "The game has ended in a tie",10,0

players db "XO"
currentPlayer db "O"
playerOffset db 1

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

    call printBoard ; print empty board on startup

    gameLoop:
        call switchPlayer
        call checkCoords ; prompt player for coordinates and ensure that they are valid
        call insertChar ; try to insert the character and switch the player after the player has used their turn
        call checkTie ; see if the game has tied. If it has, eax will be set to 2, else whatever checkVictory said
        call checkVictory ; see if there are any 3-in-a-rows. If there is, eax will be set to 1, else 0
        
        
        cmp eax, 1 ; Check game status     
        jl gameLoop ; if game is still in progress (eax == 0), do a game round once more      
        je endVictory       
        jg endTie
     
       
    endVictory:
        mov al, byte[currentPlayer]  
        push eax
        push victoryMessage
        call printf
        add esp, 8
        jmp exitProgram
      
    endTie: 
        PRINT tieMessage
        jmp exitProgram
        
    exitProgram:
        SCAN dFmt, XVal ;getch to make sure program doesn't exit immediately on game result
        push 0
        call exit
    
  
switchPlayer:  
    ; The player symbols (X, O) are stored as a list of bytes. Playeroffset offsets the address where the current player symbol is,
    ; and the result is stored in currentPlayer. Afterwords, playeroffset is flipped
    mov al, byte[playerOffset]
    xor al, 1
    mov byte[playerOffset], al
    mov ebx, players
    mov bl, byte[ebx + eax]
    mov byte[currentPlayer], bl
    ret
      
    
printBoard:
    ; print the entire board, inserting newlines every 3 characters
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
    PRINT OORMessage ; print error and loop
checkCoords:
    ; Prompt user and scan X and Y values
    PRINT promptY
    SCAN dFmt, YVal
    PRINT promptX
    SCAN dFmt, XVal
    
    ; compare values to their ranges and handle them accordingly

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
    ; This takes priority over the result of checkTie, so we can pop the stack and set eax to one
    add esp, 4
    mov eax, 1
    ret
                               
checkVictory:
    push eax ;do this in case nobody has won, so we can preserve the result of checkTie.
    ; set registers to 0
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    checkRow:
        ;Run through each row, or them into the same register, then compare it to the currentplayer
        ;if there are any characters in the row that do not match the starting character, the bits will not match
        ;ebx simply shifts the row down
        push ebx
        imul ebx, 3
        add eax, ebx
        mov cl, byte[board + eax]
        sub eax, ebx
        pop ebx
        or ch, cl
        inc eax
        cmp eax, 3
        jne checkRow
        inc ebx

        mov cl, byte[currentPlayer]
        cmp cl, ch
        je victory
        
        xor eax, eax
        xor ch, ch
        cmp ebx, 3
        jne checkRow
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        
        
    checkColumn:
        ;does the same thing as checkRow but instead increments eax to shift the column, and ebx to iterate through the contents of the column
        push ebx
        imul ebx, 3
        add eax, ebx
        mov cl, byte[board + eax]
        sub eax, ebx
        pop ebx
        or ch, cl
        inc ebx
        cmp ebx, 3
        jne checkColumn
        inc eax

        mov cl, byte[currentPlayer]
        cmp cl, ch
        je victory
        
        xor ebx, ebx
        xor ch, ch
        cmp eax, 3
        jne checkColumn
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        
    checkLeftDiagonal:
        ;do the same as the other conditions, but we do not need ebx, we simply need to multiply eax by 4 (shl 2) 
        ;this will shift the row right and column down, and we can compare like normal
        shl eax, 2
        mov cl, byte[board + eax]
        or ch, cl
        shr eax, 2
        inc eax
        cmp eax, 3
        jne checkLeftDiagonal

        mov cl, byte[currentPlayer]
        cmp cl, ch
        je victory
        
        xor ch, ch
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        
    rightDiagonalPrep:    
    ;does the same as the last diagonal but now we need ebx, as we need a tracker for the column (eax) and row (ebx)
    ;we start on the top right and work our way to the bottom left, comparing like normal
        mov eax, 2
    checkRightDiagonal:
        push ebx
        imul ebx, 3
        add eax, ebx
        mov cl, byte[board + eax]
        sub eax, ebx
        pop ebx
        or ch, cl
        dec eax
        inc ebx
        cmp eax, 0
        jge checkRightDiagonal

        mov cl, byte[currentPlayer]
        cmp cl, ch
        je victory
        
        xor ch, ch
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        
    ; we haven't jumped to victory, so assume that nobody has won yet
    pop eax
    ret          


tieFalse:
    mov eax, 0
    ret
checkTie:
    ; This iterates thorugh board and checks if there are any empty spaces (underscores) in the board. if there is,
    ; there is no tie yet, so set eax to zero, otherwise, there is a possible tie, so set eax to 2
    xor eax, eax
    
    tieLoop:
        mov bl, byte[board+eax]
        cmp bl, 0x5F
        je tieFalse
        inc eax
        cmp eax, 9
        jl tieLoop
    
    mov eax, 2
    ret
