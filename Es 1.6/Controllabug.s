#Quello che segue è un tentativo di soluzione dell'esercizio precedente 1.5. 
#Contiene tuttavia uno o più bug. Trovali e correggili.

.include "./files/utility.s"

.data
array:      .word 1, 256, 256, 512, 42, 2048, 1024, 1, 0
array_len:  .long 9
numero:     .word 1

.text

_main:
    nop
    mov $0, %cl   #ok
    mov numero, %ax #ok
    mov $0, %esi #ok abbiamo inzializzato puntatore %esi=0

comp:
    cmp array_len, %esi
    je fine #se la lunghezza di array_len == %esi allora salta all'etichetta "fine"
    cmpw array(,%esi,2), %ax  #-> "cmpw array(%esi), %ax" ecco dove sta l'errore, esi deve scorrere di 2, array+2*esi
    jne poi
    inc %cl

poi:
    inc %esi
    jmp comp

fine:
    mov %cl, %al
    call outdecimal_byte
    ret
