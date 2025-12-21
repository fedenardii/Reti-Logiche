# 1. Leggere messaggio da terminale.
# 2. Convertire le lettere minuscole in maiuscolo usando le istruzioni String.
# 3. Stampare messaggio modificato.
.include "files/utility.s" #includiamo le funzioni per gli input ed output contenute nel file utility.s

.DATA
input: .fill 80,1,0
output: .fill 80,1,0

.text
_main: #è il punto di ingresso del programma
    nop

digita:
mov $80, %cx
lea input, %ebx
call inline

inizializza_puntatori:
cld                         #clear df=0 così possiamo incrementare esi
lea input, %esi
lea output, %edi

lavoro_string:
lodsb          #carica il valore della stringa su %al usando %esi come puntatore e suffisso b=byte di quanto si sposterà %esi
cmp $'a', %al 
jb verifica
cmp $'z', %al
ja verifica
and $0xDF, %al                #qui convertiamo direttamente settando b5=0

verifica:
stosb   #fa il percorso inverso di lods prende il valore dal registro %al e lo scrive nella memoria puntata da %edi che sta puntando ad output
cmp $0x0D, %al   
jne lavoro_string # se al!= 0x0D ovvero invio (ENTER / carriage return) allora torna all'etichecca lavoro_string

stampa:
lea output, %ebx # Carichiamo l'indirizzo del primo byte del risultato per la stampa in ebx
call outline
nop

fine:
 ret
 
