#Scrivere un programma che si comporti come segue:
#Legge da tastiera una cifra decimale N, controllando che sia valida (cioè un carattere tra ‘0’ e ‘9’).
#Se N = 0, il programma termina.
#Altrimenti, va a capo e legge una seconda cifra decimale k, anch’essa con i dovuti controlli.
#Stampa N righe, dove: la prima riga contiene 1 numero, la seconda riga contiene 2 numeri,…, l’ultima riga contiene N numeri,
#tutti i numeri stampati formano un’unica sequenza crescente, con passo k, a partire da 1.
#Stampa una riga vuota e ritorna al punto 1

.include "./files/utility.s"
.data
.text

_main:
nop

inizio:
#1. Inseriamo correttamente il numero N da 0 a 9
call inserisci_N

#2. Controlliamo che N=0 se non lo è lo mettiamo in SI
cmp $0, %al
je fine         #fine del programma
mov $0, %ah     #estendiamo %ax mettendo %ah per poter fare la mov al registro sorgente 16bit
mov %ax, %si    #si contiene N numero di righe da stampare

#3. Inseriamo correttamente numero K da 1 a 9
call newline
call inserisci_N
mov $0, %ah     #estendiamo %ax mettendo %ah per poter fare la mov al registro destinatario 16bit
mov %ax, %di    #di contiene k, che sarà il passo

#4. Inizializzo i registri usati per il triangolo
mov $1, %ax     #prossimo numero da stampare
mov $0, %bx     #numeri per riga

#5. Aggiorniamo la riga
nuovariga:
call newline
dec %si
js rigabianca #se SI<0 allora abbiamo finito tutto, stampiamo la riga bianca sotto
inc %bx       #infatti riga 1 bx=1, riga 2 bx=2
mov $0, %dx   #azzeriamo contatore dei numeri sulla riga 
jmp stampa

#6. Stampiamo la riga bianca
rigabianca:
call newline
jmp inizio 

#7. Stampiamo i numeri del triangolo
stampa:
call outdecimal_word
push %ax
mov $' ', %al #spazio tra un numero ed un altro
call outchar 
pop %ax

add %di, %ax #ax = ax+k
inc %dx
cmp %bx, %dx
je nuovariga
jmp stampa

#8. Fine programma
fine:
ret


#funzione inserimento carattere del numero da 0 a 9
inserisci_N:
call inchar
cmp $'0', %al
jb inserisci_N
cmp $'9', %al
ja inserisci_N
call outchar
and $0x0F, %al #altro metodo di conversione da carattere char a numero
ret

