.include "./files/utility.s"

.data
messaggio1: .asciz "Inserire il primo numero naturale x:\r"
messaggio2: .asciz "Inserire il secondo numero naturale y:\r"
messaggio3: .asciz "Il risultato z = x * y e':\r"
x: .word 0
y: .word 0

.text
_main:
    nop
    
    # 1. Lettura primo numero (x)
    lea messaggio1, %ebx
    call outline
    call indecimal_word
    mov %ax, x
    call newline

    # 2. Lettura secondo numero (y)
    lea messaggio2, %ebx
    call outline
    call indecimal_word
    mov %ax, y
    call newline

    # 3. Moltiplicazione usando MUL a 8 bit
    mov x, %bx          # BX = x
    mov y, %cx          # CX = y
    
    xor %edx, %edx      # EDX = 0 (accumulatore risultato)
    
    # Prodotto 1: x_low * y_low
    mov %bl, %al
    mulb %cl
    mov %ax, %si        # Salva risultato
    xor %eax, %eax      # Azzera EAX
    mov %si, %ax        # Estensione a zero
    add %eax, %edx
    
    # Prodotto 2: x_low * y_high (shift di 8)
    mov %bl, %al
    mulb %ch
    mov %ax, %si
    xor %eax, %eax
    mov %si, %ax
    shl $8, %eax
    add %eax, %edx
    
    # Prodotto 3: x_high * y_low (shift di 8)
    mov %bh, %al
    mulb %cl
    mov %ax, %si
    xor %eax, %eax
    mov %si, %ax
    shl $8, %eax
    add %eax, %edx
    
    # Prodotto 4: x_high * y_high (shift di 16)
    mov %bh, %al
    mulb %ch
    mov %ax, %si
    xor %eax, %eax
    mov %si, %ax
    shl $16, %eax
    add %eax, %edx

    # 4. Stampa risultato
    lea messaggio3, %ebx
    call outline
    
    mov %edx, %eax
    call outdecimal_long
    call newline
    
    ret
    
