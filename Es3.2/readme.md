# Esercizio 3.2 - Moltiplicazione di numeri interi con segno

## Obiettivo
Scrivere un programma in assembly che:
1. Legge 2 numeri interi in base 10
2. Calcola il prodotto dei due numeri
3. Stampa il risultato

## Specifica per la lettura
- Come **primo carattere** leggere il **segno** del numero: `+` oppure `-`
- Successivamente leggere il **modulo del numero** (valore assoluto)
- Il modulo deve essere **minore di 256** (rappresentabile in 8 bit)

## Specifica per la stampa
- Stampare prima il **segno** del risultato (`+` o `-`)
- Poi stampare il **modulo** in cifre decimali

## Esempio di esecuzione
```
Inserire il primo numero intero:
-4
Inserire il secondo numero intero:
+5
Il risultato della moltiplicazione e':
-20
```

## Note implementative
- Utilizzare l'istruzione `imul` per la moltiplicazione con segno
- Il risultato della moltiplicazione di due word (16 bit) produce un risultato a 32 bit in `DX:AX`
- Gestire correttamente il segno del risultato prima della stampa
