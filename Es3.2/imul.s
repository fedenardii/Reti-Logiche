
.include "./files/utility.s"

.data
messaggio1: .asciz "Inserire il primo numero intero:\r"
messaggio2: .asciz "Inserire il secondo numero intero:\r"
messaggio3: .asciz "Il risultato della moltiplicazione e':\r"
a: .word 0
b: .word 0

.text
_main:
    nop
    # 1. Lettura primo numero
    lea messaggio1, %ebx
    call outline
    call inserisci_intero
    mov %ax, a

    # 2. Lettura secondo numero
    lea messaggio2, %ebx
    call outline
    call inserisci_intero
    mov %ax, b

    # 3. Calcolo prodotto (risultato a 32 bit in DX:AX)
    mov a, %ax
    mov b, %bx
    imul %bx 

    # 4. Impacchettamento in EAX - CORRETTO
    shl $16, %edx
    movw %ax, %dx
    movl %edx, %eax

    # 5. Stampa messaggio d'uscita
    lea messaggio3, %ebx
    call outline

    # 6. Gestione del Segno e stampa
    cmp $0, %eax
    jge stampa_positivo

    # --- Caso Negativo ---
    neg %eax
    push %eax
    mov $'-', %al
    call outchar
    pop %eax
    jmp stampa_finale

stampa_positivo:
    push %eax
    mov $'+', %al
    call outchar
    pop %eax

stampa_finale:
    call outdecimal_long
    call newline
    ret

# ---------------------------------------------------------
# FUNZIONI DI SUPPORTO
# ---------------------------------------------------------

inserisci_intero:
    push %ebx
    mov $0, %bl         # Reset %bl=0 positivo
    
in_segno_loop:
    call inchar
    cmp $'+', %al
    je leggi_modulo
    cmp $'-', %al
    jne in_segno_loop   # Continua finché non trova + o -
    mov $1, %bl         # Imposta %bl=1 negativo

leggi_modulo:
    call outchar        # Echo del segno
    call indecimal_word
    call newline
    cmp $1, %bl
    jne fine
    neg %ax             # Applica complemento a due se negativo

fine:
    pop %ebx
    ret
    
