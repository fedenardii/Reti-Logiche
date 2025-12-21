# Reti Logiche 9 CFU
## Corso di Assembler e Verilog

### Descrizione
Questo repository contiene il materiale e gli esempi pratici per il **corso di Assembler x86** e **Verilog**. 
Il corso si concentra sulla programmazione a basso livello, sia per la scrittura di codice in Assembler (sintassi GAS/AT&T) che per la progettazione di circuiti digitali con Verilog.

>#### Nota Bene:
>Gli esempi utilizzati ed esercizi svolti sono **solo a scopo didattico** e non devono essere considerati come soluzioni definitive o ottimizzate per applicazioni reali.


## Argomenti

### Assembler
1. **Introduzione**
   - Sintassi GAS/AT&T, struttura base di un programma.
2. **Registri e Memoria**
   - Utilizzo dei registri x86, indirizzamento in memoria, `.byte`, `.word`, `.long`.
3. **Operazioni**
   - Aritmetiche, logiche, gestione dei flag.
4. **Controllo del Flusso**
   - Salti condizionati, cicli, strutture di controllo.
5. **Subroutine**
   - Uso di `call`, `ret` e gestione delle chiamate di sistema.
6. **Debugging**
   - Uso di strumenti come GDB e comandi di debug specifici per Assembler.

### Verilog
1. **Introduzione a Verilog**
   - Sintassi e struttura base di un programma Verilog.
2. **Combinational Logic**
   - Creazione di circuiti combinatori come AND, OR, XOR.
3. **Sequential Logic**
   - Flip-flops, registri, contatori, FSM (Finite State Machines).
4. **Testbench e Simulazione**
   - Scrivere testbench per verificare la funzionalità del codice Verilog.

## Come Usare

### Assembler
I seguenti comandi da terminale devono essere scritti sulla PowerShell `phsw`. 
1. **Compilazione**
   - Esegui `./assemble.ps1 nomeprogramma.s` per assemblare il codice .
2. **Esecuzione**
   - Dopo l'assemblaggio, esegui con `./nomeprogramma`.
3. **Debugging**
   - Usa `i r` per visualizzare i registri.
   - Usa `x/b &nomevariabile` per esaminare la memoria.

### Verilog

1. **Compilazione e Simulazione**
   - Usa un tool come **ModelSim** o **Vivado** per compilare e simulare il codice Verilog.
   - Testbench esempio: `vlog nomefile.v`, poi `vsim work.testbench`.
2. **Sintesi**
   - Per sintetizzare il design su FPGA, usa `synth` nei tool come Vivado.

## Requisiti

- **Assembler x86** (GNU Assembler)
- **PowerShell** o **Bash** per eseguire gli script
- **Vivado** o **ModelSim** per Verilog
- **Ambiente Linux/WSL** o simile

