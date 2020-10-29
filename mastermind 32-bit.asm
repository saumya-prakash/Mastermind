; Name - Saumya Prakash
; Roll No. - 1801CS68


section .data
    
    ENTR equ 0dh        ; ENTER KEY
    ESCAPE equ 1bh      ; ESCAPE key
    LINE_FEED equ 0ah

    nwln db 0dh,0ah         ; line-feed ASCII value


    n equ 0bh
    m equ 47h
    wlcm1 db "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ", 0
    wlcm2 db "* * * * * * * * * * * *    MASTERMIND    * *  * * * * * * * * * * * * ", 0
    wlcm3 db "                                                                      ", 0
    wlcm4 db "This game is based on the popular MASTERMIND board game.              ", 0
    wlcm5 db "The system will generate a 4-digit code. Player has to guess          ", 0
    wlcm6 db "the code in atmost 10 attempts. After each attempt,                   ", 0
    wlcm7 db "the system will give hint indicating if the pattern entered is        ", 0
    wlcm8 db "correct. '*' means that digit in that position is exactly matching    ", 0
    wlcm9 db "Otherwise, it will dosplay '.' for that position.                     ", 0
    wlcm10 db "                                                                      ", 0
    wlcm11 db "Press ESC followed by ENTER to exit the game.                         ", 0


    inv_len db "Please enter a pattern of length 4.",0
    
    win db "Congratulations!! You correctly guessed the code.",0

    end1 db "The pattern was: ", 0
    end2 db "Thanks for playing. ", 0

    pattern db  30h,30h,30h,30h, 0       ; to store generated pattern
    aux db 00h,00h,00h,00h,00h,00h       ; to store guessed pattern

    atmpt db "Attempt No.: ", 0

    at_no db "1", 0, "2", 0, "3", 0, "4", 0, "5", 0, "6", 0, "7", 0, "8", 0, "9", 0, "10", 0, 0, 0    
    
    star db '*',0
    dot db '.',0


section .text
        global _start

_start: push ds
        pop es          ; making ES and DS point to the same segment to facilitate pattern comparison
        
         
        mov edx,wlcm1   ; preparing to print "Welcome" message
        mov ecx,n

wlcm:   push ecx        ; save counter onto stack
        mov ecx,edx
        
        call print
        call line_change

        add ecx,m       ; move to next row
        mov edx,ecx
        pop ecx         ; get counter value
        loop wlcm       ; test for iteration


                                                ; generating a random pattern
generate:       rdtsc           ; reading time-stamp counter
                mov ecx,pattern
                
                mov ebx,0ah     ; divisor

        randoms:        mov edx,0h
                        shr eax,3
                        div ebx
                        add edx,30h             ; scaling up to ascii values
                        mov byte [ecx], dl      ; storing the digit
                        inc ecx

                        cmp [ecx], byte 0       ; checking if all 4-digits have been generated
                        jnz randoms


                                        ; take inputs from user and compare
                mov ecx,at_no
                push ecx        ; saving attempt number(at_no) in the stack

attempt:        call line_change
                mov ecx,atmpt
                call print
                pop ecx                 ; get at_no
                call print              ; print it
                push ecx                ; put at_no back in stack
                call line_change



        mov ecx,aux     ; input will be stored in aux      


read_input:     call read_char                 ; first character read read
                cmp [ecx],byte ESCAPE
                jz gameover
                cmp byte[ecx],byte LINE_FEED
                jz invalid_length       ; 4-digits not entered but ENTER pressed -> shorter length
                

                inc ecx
                call read_char          ; second cahracter read
                cmp [ecx],byte ESCAPE
                jz gameover                 
                cmp byte[ecx],byte LINE_FEED
                jz invalid_length       ; 4-digits not entered but ENTER pressed -> shorter length

                inc ecx
                call read_char          ; third character read
                cmp [ecx],byte ESCAPE
                jz gameover
                cmp byte[ecx],byte LINE_FEED
                jz invalid_length       ; 4-digits not entered but ENTER pressed -> shorter length

                inc ecx
                call read_char          ; fourth character read
                cmp [ecx],byte ESCAPE
                jz gameover
                cmp byte[ecx],byte LINE_FEED
                jz invalid_length       ; 4-digits not entered but ENTER pressed -> shorter length

                inc ecx
                call read_char          ; ENTER key to be read
                cmp [ecx],byte ESCAPE
                jz gameover
                cmp byte [ecx],byte LINE_FEED
                jnz invalid_length       ; 4-digits entered but ENTER not pressed -> longer length




check:  mov esi,pattern
        mov edi,aux
        mov eax,0         ; for counting number of matches

        cld             ; clear direction-flag(DF)
        
        cmp1:   cmpsb   ; compare string byte
                jnz wrg1
                inc eax
                call print_star
                jmp cmp2

                wrg1:    call print_dot
        
        cmp2:   cmpsb   ; compare string byte
                jnz wrg2
                inc eax
                call print_star
                jmp cmp3

                wrg2:   call print_dot

        cmp3:   cmpsb   ; compare string byte
                jnz wrg3
                inc eax
                call print_star
                jmp cmp4

                wrg3:   call print_dot

        cmp4:   cmpsb   ; compare string byte
                jnz wrg4
                inc eax
                call print_star
                jmp testing

                wrg4:   call print_dot


        testing:        cmp eax,byte 4  ; check for an exact match
                        jz winner       ; exact match -> player won
                        

                                        ; else, give player more attempts
        call line_change
        pop ecx         ; get at_no from the stack
        add ecx,2       ; add 2 bytes to get to next attempt number address
        cmp [ecx],byte 0
        jz gameover              ; attempts exhausted -> player loses
        push ecx        ; save at_no back in stack
        jmp attempt     ; give another attempt



invalid_length: mov ecx,inv_len
                call print      ; print appropriate message asking to enter 4-digit pattern
                call line_change
                
                jmp attempt     ; give another attempt (Invalid attempts don't count.)


                                ; player won
winner:         call line_change
                call line_change
                mov ecx,win   
                call print      ; print congratulatory message
                call line_change
                call line_change
                jmp exit        ; end the program


gameover:       call line_change        ; user exited the game OR exhausted all the attempts
                call line_change

                mov ecx,end1
                call print

                mov ecx,pattern         ; reveal the pattern to the player
                call print              

                call line_change
                call line_change

                mov ecx,end2   
                call print

                call line_change         
                call line_change


exit:   mov ebx,0       ; return on SUCCESS
        mov eax,1       ; sys_exit
        int 80h         ; call kernel




; various procedures

print:  push eax        ; procedure for printing string
        push ebx
        push edx

        call slen

        
        mov ebx,1       ; file descriptor for STDOUT
        mov eax,4       ; sys_write
        int 80h         ; call kernel

        pop edx
        pop ebx
        pop eax
        ret


slen:   push ecx        ; returns length of nulll terminated string in EDX

        mov edx,0000h

        lp:     cmp byte [ecx],0
                jz delim
                inc edx
                inc ecx
                jmp lp
        
        delim:  pop ecx
                
                ret




line_change:    push eax        ; procedure for printing newline character
                push ebx
                push ecx
                push edx

                mov edx,2
                mov ecx,nwln
                mov ebx,1
                mov eax,4
                int 80h

                pop edx
                pop ecx
                pop ebx
                pop eax

                ret

read_char:      push eax
                push ebx
                push edx

                mov edx,1       ; read one character
                mov ebx,2       ; file descriptor for STDIN
                mov eax,3       ; sys_read

                int 80h         ; call kernel

                pop edx
                pop ebx
                pop eax

                ret


print_star:   push ecx          ; prints a '*' character
        
        mov ecx,star
        call print

        pop ecx

        ret

print_dot:    push ecx          ; prints a '.' character

        mov ecx,dot
        call print

        pop ecx

        ret