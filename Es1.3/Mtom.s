.include "./files/utility.s"

.DATA
input: .fill 80, 1,0
output: .fill 80,1,0

.text
_main:
nop

leggitastiera:
mov $80, %cx
lea input, %ebx
call inline

inizializza:
lea input, %esi
lea output, %edi
mov $0, %ecx

converti:
movb (%esi, %ecx), %al 
cmp $'A', %al
jb verifica
cmp $'Z', %al
ja verifica
or $0x20, %al #a differenza di prima, qui dobbiamo commutare il b5=1 usando una or 

verifica:
movb %al, (%edi, %ecx)
inc %ecx #facciamo scorrere l'indice, ecx++
cmp $0x0D, %al #controllo che %al non abbia carattere speciale di "INVIO" così da mandarlo nuovamente all'etichetta sopra
jne converti

stampa:
lea output, %ebx
call outline
nop

fine:
ret

