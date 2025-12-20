# 1. Leggere messaggio da terminale.
# 2. Convertire le lettere minuscole in maiuscolo.
# 3. Stampare messaggio modificato.
.include "./files/utility.s" #includiamo procedure inline ed outline
#sezione dei dati
.DATA
input: .fill 80,1,0 #buffer di input
output: .fill 80,1,0 #buffer di output

#corpo del programma 
.text
_main: #è il punto di ingresso del programma
    nop
leggitastiera: 
mov $80, %cx  #nostro contatore cx=80 
lea input, %ebx #carichiamo l'indirizzo del primo byte del buffer input ad ebx
call inline

inizializza:
lea input, %esi #il nostro puntatore sorgente punta al primo byte del buffer input
lea output, %edi #il nostro puntatore destinatario punta al primo byte del buffer output
mov $0, %ecx #inizializziamo l'indice ecx a 0 

converti:
movb (%esi, %ecx), %al #spostiamo input[ecx] in al
cmp $'a', %al 
jb check_finale #se al < a, significa che siamo fuori dal range tra a e z e quindi avremo un carattere maiusc
cmp $'z', %al
ja check_finale #se al > z, significa che siamo fuori dal range tra a e z e quindi avremo un carattere maiusc
and $0xDF, %al #convertiamo il bit 5 a 0 per avere la conversione da min to maiusc in caratteri ASCII

check_finale:
movb %al, (%edi, %ecx) #spostiamo il contenuto di al in output[ecx]
inc %ecx
cmp $0x0D, %al # 0x0D = invio (ENTER / carriage return)
jne converti

stampa:
lea output, %ebx #carichiamo l'indirizzo del primo byte del buffer output ad ebx
call outline
nop

fine:
ret




