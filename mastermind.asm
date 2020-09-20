.model large

.stack 256   

.data
    ENTER equ 0dh       ; ENTER key
    cr equ 0dh          ; carriage return
    lf equ 0ah          ; line feed

    n equ 09h
    m equ 47h
    wlcm1 db "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * $"
    wlcm2 db "* * * * * * * * * * * * WELCOME TO MASTERMIND * * * * * * * * * * * * $"
    wlcm3 db "                                                                      $"
    wlcm4 db "This game is based on the popular MASTERMIND board game.              $"
    wlcm5 db "The system will generate a 4-digit code. Player has to guess          $"
    wlcm6 db "the code in atmost 10 attempts. After each attempt,                   $"
    wlcm7 db "the system will give hint indicating if the pattern entered is        $"
    wlcm8 db "correct. A green star means that digit in that position is exactly    $"
    wlcm9 db "matching. Otherwise, it will give a red star for that position.       $"

    plen equ 4          ; length of pattern
    pattern db plen dup (00h)       ; to store generated pattern
    
    trials equ 000ah       ; max attempts allowed
    
    star equ '*'
    green equ 02h
    red equ 0ch

.code

line_change     PROC NEAR            ; procedure to print 'newline' ('\n')
                push ax
                push dx
                
                mov ah,02h
                mov dl,cr
                int 21h
                mov dl,lf
                int 21h

                pop dx
                pop ax

                ret
line_change     ENDP


print   PROC NEAR               ; procudure for printing string and changing line
        push ax
        mov ah,09h
        int 21h
        call line_change
        
        pop ax

        ret
print   ENDP


green_star      PROC NEAR

        push ax
        push bx
        push cx
        push dx
        
        mov ah,09h
        mov al,star
        mov bl,green
        mov cx,0001h
        int 10h

        mov ah,03h      ; get cursor position
        int 10h
        inc dl
        mov ah,02h      ; set cursor position
        int 10h
        
        pop dx
        pop cx
        pop bx
        pop ax

        ret
green_star      ENDP

red_star       PROC NEAR

        push ax
        push bx
        push cx
        push dx

        mov ah,09h
        mov al,star
        mov bl,red
        mov cx,0001h
        int 10h
        
        mov ah,03h      ; get cursor position
        int 10h
        inc dl
        mov ah,02h      ; set cursor position
        int 10h

        pop dx
        pop cx
        pop bx
        pop ax

        ret
red_star        ENDP



start:  mov ax,@data
        mov ds,ax

        mov cx,n
        lea dx,wlcm1


wlcm:   call print              ; prints the WELCOME message
        add dx,m
        loop wlcm

        mov cx,trials

attempt:



        mov ah,01h
        mov cx,0000h
        mov bl,ENTER


read_input:     int 21h     
                inc cx
                push ax

                cmp bl,al
                jnz read_input

check:  pop dx          ; removing the stored ENTER KEY from the stack
        dec cx
        cmp cx,plen
        ;jnz invalid_length     ; length entered more or less than plen -> attempt doesn't count, clear the stack 


; match and give appropriate output -> pattern guessed -> start exit process 
match:  lea si,pattern  ; address of 1st element of pattern



exit:   mov ah,4ch      ; setup to
        int 21h         ; return to DOS
        end start
        
.end


