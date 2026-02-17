//============================================================================
// ESERCIZIO 2: ABC - Architettura separata PO/PC
//============================================================================
// Implementazione con separazione tra:
// - ABC_PO: Parte Operativa (registri, datapath, rete combinatoria)
// - ABC_PC: Parte Controllo (FSM con ROM per microindirizzi)
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
input [7:0] x1, x2, x3;           // Dati campionati dai tre convertitori A/D
input eoc1, eoc2, eoc3;           // End Of Conversion: segnali di fine conversione
input clock, reset_;              // Clock di sistema e reset asincrono attivo basso
input rfd;                        // Ready For Data: consumatore pronto a ricevere

output soc;                       // Start Of Conversion: avvia le conversioni A/D
output dav_;                      // Data Available: segnala dato disponibile (attivo basso)
output [7:0] min;                 // Valore minimo tra x1, x2, x3

//---- SEGNALI INTERNI DI CONTROLLO ----
wire b4, b3, b2, b1, b0;          // Bit di controllo: PC → PO
wire c2, c1, c0;                  // Bit di condizione: PO → PC

//---- ISTANZA PARTE OPERATIVA ----
ABC_PO po(
    .x1(x1), .x2(x2), .x3(x3),
    .eoc1(eoc1), .eoc2(eoc2), .eoc3(eoc3),
    .soc(soc),
    .min(min), .dav_(dav_), .rfd(rfd),
    .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
    .c2(c2), .c1(c1), .c0(c0),
    .clock(clock), .reset_(reset_)
);

//---- ISTANZA PARTE CONTROLLO ----
ABC_PC pc(
    .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
    .c2(c2), .c1(c1), .c0(c0),
    .clock(clock), .reset_(reset_)
);

endmodule

//============================================================================
// MODULO ABC_PO - Parte Operativa
//============================================================================
// Contiene tutti i registri (SOC, MIN, DAV_) e la logica di datapath.
// Riceve i bit di controllo (b4-b0) dalla parte controllo e genera
// i bit di condizione (c2-c0) da inviare alla parte controllo.
//============================================================================

module ABC_PO(
    x1, x2, x3,
    eoc1, eoc2, eoc3,
    soc,
    min, dav_, rfd,
    b4, b3, b2, b1, b0,
    c2, c1, c0,
    clock, reset_
);

//---- PORTE ----
input [7:0] x1, x2, x3;           // Dati dai convertitori
input eoc1, eoc2, eoc3;           // Segnali End Of Conversion
input rfd;                        // Ready For Data dal consumatore
input clock, reset_;              // Clock e reset

output soc;                       // Start Of Conversion
output [7:0] min;                 // Valore minimo
output dav_;                      // Data Available (attivo basso)

input b4, b3, b2, b1, b0;         // Bit di controllo dalla PC
output c2, c1, c0;                // Bit di condizione verso PC

//---- REGISTRI INTERNI ----
reg SOC;
assign soc = SOC;

reg [7:0] MIN;
assign min = MIN;

reg DAV_;
assign dav_ = DAV_;

//---- RETE COMBINATORIA MINIMO_3 ----
wire [7:0] uscita;
MINIMO_3 min_rc(
    .a(x1), .b(x2), .c(x3),
    .min(uscita)
);

//---- GENERAZIONE BIT DI CONDIZIONE ----
// c0: tutti gli EOC sono bassi (conversioni avviate)
assign #1 c0 = ~eoc1 & ~eoc2 & ~eoc3;

// c1: tutti gli EOC sono alti (conversioni completate)
assign #1 c1 = eoc1 & eoc2 & eoc3;

// c2: consumatore pronto a ricevere
assign #1 c2 = rfd;

//============================================================================
// REGISTRO SOC - Start Of Conversion
//============================================================================
// Codifica (b1, b0):
//   00 → SOC = 1 (avvia conversioni)
//   01 → SOC = 0 (disattiva)
//   1X → SOC mantiene valore corrente
//============================================================================

always @(reset_ == 0) #1 SOC <= 0;
always @(posedge clock) if (reset_ == 1) #3 begin
    casex ({b1, b0})
        2'b00: SOC <= 1;
        2'b01: SOC <= 0;
        2'b1X: SOC <= SOC;
    endcase
end

//============================================================================
// REGISTRO DAV_ - Data Available (attivo basso)
//============================================================================
// Codifica (b3, b2):
//   00 → DAV_ mantiene valore corrente
//   01 → DAV_ = 0 (dato disponibile)
//   1X → DAV_ = 1 (nessun dato disponibile)
//============================================================================

always @(reset_ == 0) #1 DAV_ <= 1;
always @(posedge clock) if (reset_ == 1) #3 begin
    casex ({b3, b2})
        2'b00: DAV_ <= DAV_;
        2'b01: DAV_ <= 0;        // CORRETTO: era 2'b10 (sbagliato!)
        2'b1X: DAV_ <= 1;
    endcase
end

//============================================================================
// REGISTRO MIN - Valore Minimo
//============================================================================
// Codifica b4:
//   0 → MIN mantiene valore corrente
//   1 → MIN = uscita (carica il minimo calcolato)
//============================================================================

always @(posedge clock) if (reset_ == 1) #3 begin
    casex (b4)
        1'b0: MIN <= MIN;        // CORRETTO: era 2'b0 (sbagliato!)
        1'b1: MIN <= uscita;     // CORRETTO: era 2'b1 (sbagliato!)
    endcase
end

endmodule

//============================================================================
// MODULO ABC_PC - Parte Controllo (FSM con ROM)
//============================================================================
// Implementa la macchina a stati finiti con logica di microindirizzi.
// Genera i bit di controllo (b4-b0) in base allo stato corrente (STAR)
// e ai bit di condizione (c2-c0).
//============================================================================

module ABC_PC(
    b4, b3, b2, b1, b0,
    c2, c1, c0,
    clock, reset_
);

input clock, reset_;
output b4, b3, b2, b1, b0;        // Bit di controllo verso PO
input c2, c1, c0;                 // Bit di condizione da PO

//---- REGISTRO DI STATO ----
reg [1:0] STAR;
localparam 
    S0 = 0,  // Avvio conversioni
    S1 = 1,  // Attesa completamento e acquisizione
    S2 = 2,  // Presentazione dato
    S3 = 3;  // Handshake completato

//============================================================================
// ROM PER MICROINDIRIZZI
//============================================================================
// Genera i 5 bit di controllo in base allo stato corrente
// 
// Formato: b4 b3 b2 b1 b0
//   b4:     controllo MIN (0=mantieni, 1=carica)
//   b3b2:   controllo DAV_ (00=mantieni, 01=a 0, 1X=a 1)
//   b1b0:   controllo SOC (00=a 1, 01=a 0, 1X=mantieni)
//============================================================================

assign #1 {b4, b3, b2, b1, b0} =
    (STAR == S0) ? 5'b00000 :     // SOC=1, DAV_=mantieni, MIN=mantieni
    (STAR == S1) ? 5'b10001 :     // SOC=0, DAV_=mantieni, MIN=carica (CORRETTO!)
    (STAR == S2) ? 5'b0011X :     // SOC=mantieni, DAV_=0, MIN=mantieni (CORRETTO!)
    (STAR == S3) ? 5'b01X1X :     // SOC=mantieni, DAV_=1, MIN=mantieni (CORRETTO!)
    /*default*/    5'bXXXXX ;     // CORRETTO: aggiunto : mancante

//============================================================================
// EVOLUZIONE DEGLI STATI
//============================================================================
// Logica di transizione basata sui bit di condizione c2, c1, c0
//============================================================================

always @(reset_ == 0) #1 STAR <= S0;
always @(posedge clock) if (reset_ == 1) #3 begin
    casex (STAR)
        S0: STAR <= c0 ? S1 : S0;        // Se eoc=000 → S1
        S1: STAR <= c1 ? S2 : S1;        // Se eoc=111 → S2
        S2: STAR <= c2 ? S3 : S2;        // Se rfd=1 → S3
        S3: STAR <= ~c2 ? S0 : S3;       // Se rfd=0 → S0
    endcase
end

endmodule

//============================================================================
// MODULO MINIMO_3 - Rete Combinatoria per calcolo del minimo
//============================================================================
// [Codice invariato - già corretto]

module MINIMO_3 (
    a, b, c, min
);

input [7:0] a, b, c;
output [7:0] min;

wire [7:0] min_ab;
wire b_outab;
wire b_outabc;

diff #(.N(8)) controlloab(
    .x(a), .y(b),
    .b_in(1'b0),
    .b_out(b_outab)
);

assign #1 min_ab = b_outab ? a : b;

diff #(.N(8)) controlloabc(
    .x(min_ab), .y(c),
    .b_in(1'b0),
    .b_out(b_outabc)
);

assign #1 min = b_outabc ? min_ab : c;

endmodule

/* DESCRIZIONE DELLA ROM CORRETTA

    S0 = 00, S1 = 01, S2 = 10, S3 = 11
    c0 = eoc=000, c1 = eoc=111, c2 = rfd

    M-addr | b4 b3 b2 b1 b0 | c_eff | M-addr-T | M-addr-F
    -------------------------------------------------------
    00     | 0  0  0  0  0  | c0    | 01       | 00
    01     | 1  0  0  0  1  | c1    | 10       | 01
    10     | 0  0  1  1  X  | c2    | 11       | 10
    11     | 0  1  X  1  X  | ~c2   | 00       | 11
*/