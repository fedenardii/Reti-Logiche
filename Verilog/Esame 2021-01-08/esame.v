//============================================================================
// ESERCIZIO 2: Verilog - Unità ABC con calcolo del minimo
//============================================================================
// L'Unità ABC preleva ciclicamente tre campioni di tensione (v1, v2, v3) 
// tramite tre convertitori A/D unipolari e trasferisce al consumatore 
// il campione di valore minimo.
//============================================================================

module ABC(
    // Interfaccia convertitori A/D
    eoc1, x1,              // End Of Conversion 1 e dato campionato (8 bit)
    eoc2, x2,              // End Of Conversion 2 e dato campionato (8 bit)
    eoc3, x3,              // End Of Conversion 3 e dato campionato (8 bit)
    
    // Interfaccia consumatore
    dav_, rfd, min,        // Data Available (attivo basso), Ready For Data, valore minimo
    
    // Segnali di sistema
    clock, reset_, soc     // Clock, Reset asincrono (attivo basso), Start Of Conversion
);

//---- DICHIARAZIONE PORTE ----
input [7:0] x1, x2, x3;           // Dati campionati dai tre convertitori A/D (8 bit unsigned)
input eoc1, eoc2, eoc3;           // End Of Conversion: segnali di fine conversione (attivi alti)
input clock;                      // Clock di sistema
input reset_;                     // Reset asincrono attivo basso
input rfd;                        // Ready For Data: consumatore pronto a ricevere dati

output soc;                       // Start Of Conversion: avvia le conversioni A/D
output dav_;                      // Data Available: segnala dato disponibile (attivo basso)
output [7:0] min;                 // Valore minimo tra x1, x2, x3

//---- REGISTRI INTERNI ----
reg SOC;                          // Registro per memorizzare Start Of Conversion
reg [7:0] MIN;                    // Registro per memorizzare il valore minimo calcolato
reg DAV_;                         // Registro per memorizzare Data Available
reg [1:0] STAR;                   // Registro di stato della FSM (2 bit per 4 stati)

//---- PARAMETRI STATI FSM ----
localparam S0 = 0,  // Stato 0: Avvio conversioni (SOC=1), attesa eoc=000
           S1 = 1,  // Stato 1: Attesa completamento conversioni (eoc=111) e acquisizione MIN
           S2 = 2,  // Stato 2: Presentazione dato (DAV_=0), attesa RFD=1
           S3 = 3;  // Stato 3: Handshake completato (DAV_=1), attesa RFD=0

//---- ASSEGNAMENTI CONTINUI ----
// Collega i registri interni alle porte di uscita
assign soc = SOC;                 
assign min = MIN;                 
assign dav_ = DAV_;               

//---- ISTANZA RETE COMBINATORIA MINIMO_3 
wire [7:0] uscita;                // Filo che trasporta il risultato del calcolo del minimo

MINIMO_3 minimo_rc(
    .a(x1),                       // Primo valore in ingresso
    .b(x2),                       // Secondo valore in ingresso
    .c(x3),                       // Terzo valore in ingresso
    .min(uscita)                  // Valore minimo calcolato (combinatorio)
);

//============================================================================
// BLOCCO DI RESET ASINCRONO
//============================================================================
// Quando reset_ va a 0, inizializza tutti i segnali e porta la FSM in S0
always @(reset_ == 0) #1 begin
    SOC <= 0;                     // Start Of Conversion disattivato
    DAV_ <= 1;                    // Data Available disattivato (attivo basso)
    STAR <= S0;                   // Stato iniziale
end

always @(posedge clock) if (reset_ == 1) #3 begin
    casex (STAR)
        
        //---- STATO S0: Avvio delle conversioni A/D ----
        // AZIONI:
        // - Attiva SOC=1 per avviare simultaneamente i tre convertitori
        // TRANSIZIONE:
        // - Rimane in S0 finché almeno un EOC è alto (conversioni non ancora avviate)
        // - Va in S1 quando tutti gli EOC sono bassi (conversioni avviate)
        S0: begin
            SOC <= 1;
            STAR <= ({eoc1, eoc2, eoc3} == 3'b000) ? S1 : S0;
        end
        
        //---- STATO S1: Attesa completamento conversioni ----
        // AZIONI:
        // - Disattiva SOC=0 (conversioni già avviate)
        // - Campiona il valore minimo nel registro MIN quando tutti gli EOC sono alti
        // TRANSIZIONE:
        // - Rimane in S1 finché almeno un EOC è basso (conversioni in corso)
        // - Va in S2 quando tutti gli EOC sono alti (conversioni completate)
        S1: begin
            SOC <= 0;
            MIN <= uscita;        // Acquisisce il minimo dalla rete combinatoria
            STAR <= ({eoc1, eoc2, eoc3} == 3'b111) ? S2 : S1;
        end
        
        //---- STATO S2: Presentazione del dato al consumatore ----
        // AZIONI:
        // - Attiva DAV_=0 per segnalare al consumatore che il dato è disponibile
        // TRANSIZIONE:
        // - Rimane in S2 finché RFD=0 (consumatore non pronto)
        // - Va in S3 quando RFD=1 (consumatore pronto, handshake avviato)
        S2: begin
            DAV_ <= 0;
            STAR <= (rfd == 1'b1) ? S3 : S2;
        end
        
        //---- STATO S3: Completamento handshake ----
        // AZIONI:
        // - Disattiva DAV_=1 per segnalare fine trasmissione
        // TRANSIZIONE:
        // - Rimane in S3 finché RFD=1 (consumatore mantiene ready)
        // - Torna in S0 quando RFD=0 (consumatore ha rilasciato, nuovo ciclo)
        S3: begin
            DAV_ <= 1;
            STAR <= (rfd == 1'b0) ? S0 : S3;
        end

    endcase
end

endmodule

//============================================================================
// MODULO MINIMO_3 - Rete Combinatoria per calcolo del minimo
//============================================================================
// Calcola il valore minimo tra tre ingressi a 8 bit utilizzando
// DUE SOTTRATTORI in cascata e logica di selezione basata sul bit di segno
//
// ALGORITMO:
// 1. Primo sottrattore: confronta a e b → seleziona min(a,b)
// 2. Secondo sottrattore: confronta min(a,b) e c → seleziona min(a,b,c)
//
// PRINCIPIO:
// Il bit di prestito in uscita (b_out) del sottrattore indica:
// - b_out=1 → x < y (sottrazione produce prestito)
// - b_out=0 → x >= y (sottrazione senza prestito)
//============================================================================

module MINIMO_3 (
    a, b, c,              // Tre valori di ingresso a 8 bit
    min                   // Valore minimo (uscita)
);

input [7:0] a, b, c;      // Ingressi unsigned a 8 bit
output [7:0] min;         // Uscita: minimo tra a, b, c

//---- FILI INTERNI ----
wire [7:0] min_ab;        // Risultato parziale: minimo tra a e b
wire b_outab;             // Bit di prestito del primo sottrattore (confronto a-b)
wire b_outabc;            // Bit di prestito del secondo sottrattore (confronto min_ab-c)

//---- PRIMO SOTTRATTORE: confronto tra a e b ----
// Istanza del modulo diff parametrizzato a N=8 bit
// Calcola: a - b
// Se b_outab=1 → a < b → seleziona a
// Se b_outab=0 → a >= b → seleziona b
diff #(.N(8)) controlloab(
    .x(a),                // Minuendo
    .y(b),                // Sottraendo
    .b_in(1'b0),          // Nessun prestito in ingresso
    .b_out(b_outab)       // Bit di prestito in uscita (segno del risultato)
);

assign #1 min_ab = b_outab ? a : b;   // Multiplexer: seleziona il minore tra a e b

//---- SECONDO SOTTRATTORE: confronto tra min_ab e c ----
// Istanza del modulo diff parametrizzato a N=8 bit
// Calcola: min_ab - c
// Se b_outabc=1 → min_ab < c → seleziona min_ab
// Se b_outabc=0 → min_ab >= c → seleziona c
diff #(.N(8)) controlloabc(
    .x(min_ab),           // Minuendo (minimo parziale)
    .y(c),                // Sottraendo
    .b_in(1'b0),          // Nessun prestito in ingresso
    .b_out(b_outabc)      // Bit di prestito in uscita (segno del risultato)
);

assign #1 min = b_outabc ? min_ab : c;  // Multiplexer: seleziona il minore tra min_ab e c

endmodule
