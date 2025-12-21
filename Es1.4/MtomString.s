# 1. Leggere messaggio da terminale.
# 2. Convertire le lettere maiuscole in minuscolo usando le istruzioni String.
# 3. Stampare messaggio modificato.

.include "./files/utility.s"
.DATA

input: .fill 80,1,0
output: .fill 80,1,0

.text
_main:
nop

digita:
mov $80, %cx
lea input, %ebx
call inline

inizializza_puntatori:
cld                     # Clear DF=0 per incrementare i puntatori esi ed edi
lea input, %esi
lea output, %edi

converti:
lodsb                   #viene caricato il byte puntato da %esi in %al ed %esi viene incrementato di 1
cmp $'A', %al 
jb verifica
cmp $'Z', %al
ja verifica
or $0x20, %al           #settiamo il bit5=1

verifica:
stosb 
cmp $0x0D, %al
jne converti

stampa:
lea output, %ebx
call outline
nop

fine:
ret

