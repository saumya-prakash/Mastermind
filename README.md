# Mastermind Game in Assembly Language

This repository contains the assembly language (16-bit, 32-bit, 64-bit x86) implementation of the classic MASTERMIND board game.

Computer generates a 4-digit pattern and the player has to guess this pattern. The player has 10 attempts to crack the code.

After each guess, computer responds to indicate if the pattern is partially correct.

For 16-bit veresion, a green star shows that the digit matched with the pattern's at the corresponding place and a red star shows that the digit at the coreponding place is wrong.
For 32-bit and 64-bit versions, '-' is displayed in place of red star and '*' is displayed in place of green star.






* For running the **mastermind_16-bit.asm** program, use [DOSBox](https://www.dosbox.com/). The required DOSBox utility programs are in [DOSBox_utilities](./DOSBox_utilities). Put them in the directory where the .asm file is placed.
    ```
    $ masm mastermind_16-bit.asm
    $ link mastermind_16-bit.o
    $ mastermind_16-bit.exe
    ```
    


* For running the **mastermind_32-bit.asm** program (on a x86_84 machine),
    ```
    $ nasm -f elf mastermind_32-bit.asm
    $ ld –m elf_i386 mastermind_32-bit.o 
    $ ./a.out
    ```  

    
* For running the **mastermind_64-bit.asm** program (on a x86_84 machine), 
    ```
    $ nasm -f elf64 mastermind_64-bit.asm
    $ ld mastermind_64-bit.o
    $ ./a.out
    ```

