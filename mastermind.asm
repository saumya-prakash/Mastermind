.model 64

.stack 64

.data
    cr equ 0dh
    lf equ 0ah
    wlcm1 db "* * * * * * * * * * * * * * * * * * * $ "
    wlcm2 db "* * * * WELCOME TO MASTERMIND * * * * $ "
    

.code

start:  mov ax,@data
        mov ds,ax

        mov ah,09h
        
        lea dx,wlcm1
        int 21h

        mov ah,02h
        mov dx,000ah
        int 21h
        mov dx,000dh
        int 21h
        
        mov ah,09h
        lea dx,wlcm2
        int 21h


exit:   mov ah,4ch
        int 21h
        end start
        .end