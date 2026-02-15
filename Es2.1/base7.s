#Leggere un numero di 4 cifre in base 7
#Stamparlo in notazione decimale (base 10)
#Testare e stampare se è divisibile per 64, senza usare div
#Ci è chiesto di risolvere il primo punto scrivendo due sottoprogrammi:
# -indigit_b7, per la lettura di una cifra in base 7,
# -innumber_b7, per la lettura di un numero a 4 cifre in base 7

.include "./files/utility.s"

.data

.text
_main:
nop

chiamata_inserimento:
call innumber_b7       #legge l'intero numero in base 7 (il risultato finisce in %ax)
call newline          # a capo per ritorno carrello

stampi_numero_convertito:
call outdecimal_word #Stampa il valore in base 10 preso da %ebx
call newline

check_divisibile:
and $0x003F, %ax #facciamo un and 0000 0000 0011 1111 (64) 
jz divisibile #se risultato è tutto 0 allora divisibile ZF=1

no_divisibile:
mov $'0', %al #se non è divisibile stampiamo 0
jmp stampa

divisibile:
mov $'1', %al #se  è divisibile stampiamo 1

stampa:
call outchar #stampa se divisibile 1 o non divisibile 0

indigit_b7:  # prendiamo un numero in base 7 (0 a 6)
call inchar #inseriamo un carattere da tastiera
cmp $'0', %al 
jb indigit_b7 #confrontiamo che sia al<0 e richiediamo inserimento
cmp $'6', %al 
ja indigit_b7 #confrontiamo che sia al>6 e richiediamo inserimento
call outchar
sub $'0', %al #stiamo convertendo il carattere stringa in un numero, '0' corrisponde a 53 in decimale
ret
 
innumber_b7: #inizializziamo tutto
push %bx #salvo accumulatore
push %cx #salvo contatore
push %dx #salvo la parte alta della mul
mov $0, %bx #sarà il numero finale e lo inizializziamo a 0
mov $4, %cl #sarà il nostro contatore delle cifre

innumber_b7_loop:
cmp $0, %cl 
je fine
mov $7, %ax 
mul %bx   # dx:ax = bx * 7
mov %ax, %bx
call indigit_b7
mov $0, %ah #estendo la parte alta per poter usare correttamente  %ax per sommarlo
add %ax, %bx
dec %cl
jmp innumber_b7_loop

fine:
mov %bx, %ax #risultato nuovo sarà su %ax per la chiamata outchar
pop %dx #pulisco risultato mul
pop %cx #pulisco contatore ricorda che push e pop usano 16-32bit
pop %bx #pulisco accumulatore
ret


