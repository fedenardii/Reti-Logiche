#Sia dato l'array ed il numero da cercare.
#Scrivere un programma che conta e stampa il numero di occorrenze di un numero da cercare nell'array.

.include "./files/utility.s"

.DATA
array:      .word 1, 256, 256, 512, 42, 2048, 1024, 1, 0
array_len:  .long 9
numero_cercare:     .word 1

.text
_main:
nop

inizializza:
    cld             # Clear DF=0 per esi++ e edi++
    lea array, %esi
    movl array_len, %ecx
    movw numero_cercare, %dx
    xor %bx, %bx    #registro usato per contare quanti occorrenze = 1

ciclo:
    lodsw           # Carica una Word da memoria [%esi] in %ax, poi incrementa %esi di 2
    cmp %ax, %dx    
    jne continua    # Se non sono uguali salta a "continua"
    inc %bx         # Se sono uguali, incrementa il contatore in %bx.

continua:
    loop ciclo      # Decrementa %ecx e, se %ecx > 0, torna all'etichetta "ciclo".

stampa:
    movw %bx, %ax
    call outdecimal_word 
    nop

fine:
    ret
