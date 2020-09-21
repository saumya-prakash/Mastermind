.model large

.stack 100   

.data
    ESCAPE equ 1bh         ; ESCAPE key
    ENTER equ 0dh       ; ENTER key
    cr equ 0dh          ; carriage return
    lf equ 0ah          ; line feed

    n equ 09h
    m equ 47h
    wlcm1 db "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * $"
    wlcm2 db "* * * * * * * * * * * * * *MASTERMIND* * * *  * * * * * * * * * * * * $"
    wlcm3 db "                                                                      $"
    wlcm4 db "This game is based on the popular MASTERMIND board game.              $"
    wlcm5 db "The system will generate a 4-digit code. Player has to guess          $"
    wlcm6 db "the code in atmost 10 attempts. After each attempt,                   $"
    wlcm7 db "the system will give hint indicating if the pattern entered is        $"
    wlcm8 db "correct. A green star means that digit in that position is exactly    $"
    wlcm9 db "matching. Otherwise, it will give a red star for that position.       $"

    atmpt db "Attempt No.: $"
    
    inv_len db "Please enter a pattern of length 4.$"
    
    win db "Congratulations!! You correctly guessed the code. $"

    end1 db "The pattern was: $"
    end2 db "Thanks for playing. $"

   
    plen equ 04h          ; length of pattern
    pattern db plen dup (00h)       ; to store generated pattern
    aux db plen dup (00h)       ; to store guessed pattern
    result db plen dup (00h)    ; to store match/not match

    trials dw 000ah       ; max attempts allowed
    
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


print   PROC NEAR               ; procudure for printing string
        push ax
        mov ah,09h
        int 21h
        
        pop ax

        ret
print   ENDP


green_star      PROC NEAR

        push ax
        push bx
        push cx
        push dx
        
        mov bh,00h      ; page number
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

        mov bh,00h      ; page number
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


rand    PROC NEAR       ; puts a random digit in dl

        push ax
        push cx

        mov ah, 00h          
        int 1ah            

        mov  ax, dx
        mov dx,0000h
        mov  cx, 0ah    
        div  cx       

        add  dl, 30h 

        pop cx
        pop ax

        ret
rand    ENDP


start:  mov ax,@data
        mov ds,ax

        mov cx,n
        lea dx,wlcm1


wlcm:   call print              ; prints the WELCOME message
        call line_change
        add dx,m
        loop wlcm
        call line_change

        mov cx,plen
        lea si,pattern

generate:       call rand
                mov [si],dl
                inc si
                loop generate


                
attempt:
        mov ah,01h
        mov cx,0000h
        mov bl,ENTER
        lea si,aux


read_input:     int 21h     
                inc cx          ; number of chars read

                cmp al,ESCAPE   ; if ESC pressed, end program
                jnz enter_chk   ; test inverted->prevents out of range error
                jmp escexit

        
        enter_chk:      cmp bl,al
                        jz check

        conti:  cmp cx,plen
                jbe store
                conti_back:     jmp read_input

        store:  mov [si],al
                inc si
                jmp conti_back

check:  
        dec cx
        cmp cx,plen
        jnz invalid_length     ; length entered more or less than plen -> attempt doesn't count, clear the stack 
        jmp match



invalid_length: lea dx,inv_len
                call print
                call line_change
                jmp attempt



; match and give appropriate output -> pattern guessed -> start exit process 
match:  mov cx,0000h
        lea si,pattern
        lea di,aux
        push ds         ; ES made equal to DS
        pop es

comp1:  cmpsb
        jz correct1
        jnz wrong1

comp2:  cmpsb
        jz correct2
        jnz wrong2

comp3:  cmpsb
        jz correct3
        jnz wrong3

comp4:  cmpsb
        jz correct4
        jnz wrong4



correct1:       call green_star
                inc cx
                jmp comp2
wrong1:         call red_star
                jmp comp2

correct2:       call green_star
                inc cx
                jmp comp3
wrong2:         call red_star
                jmp comp3

correct3:       call green_star
                inc cx
                jmp comp4
wrong3:         call red_star
                jmp comp4

correct4:       call green_star
                inc cx
                jmp all_match
wrong4:         call red_star
                jmp all_match

        all_match:      call line_change
                        cmp cx,0004h
                        jz winner
                        mov cx,trials
                        dec cx
                        cmp cx,0000h
                        jz escexit      ; attempts exhausted
                        mov trials,cx
                        jmp attempt     ; more attempts left


winner: lea dx,win
        call print
        call line_change
        jmp exit


escexit:        call line_change
                lea dx,end1
                call print      ; reveal the pattern to player
                lea si,pattern
                mov cx,plen
                mov ah,02h

        elp:    mov dl,[si]     ; print the generated pattern
                int 21h
                loop elp

                call line_change
                jmp exit        

        

exit:   call line_change
        mov ah,09h
        lea dx,end2
        int 21h
        call line_change
        mov ah,4ch      ; setup to
        int 21h         ; return to DOS
        end start
        
.end


