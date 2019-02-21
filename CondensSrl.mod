#Insiemi
set Tipo;
set ElTipo within Tipo;
set Class;
set 1000Class within Class;
set Materials;
set AlMat within Materials;
set Company;
set Company1 within Company;
set Company3 within Company ordered; #deve contenere un'unico elemento

#Parametri
param Vendita {Tipo,Class} >=0;
param Acquisto {Materials,Company} >=0;
param Elementi {Materials,Tipo,Class} >=0 integer;
param Capienza {Materials} >=0 integer;
param Minimo {Class}>=0 integer;

param Percent >=0, <=100 integer;
param PartMin1 >=0 integer;
param PartMinPremio >=0 integer;
param Bonus >=0;
param Big >=0;

#Variabili
var NumCond {Tipo,Class} >=0 integer;
var NumMat {Materials,Company} >=0 integer;
var exist1000 {Tipo} binary;
var BoughtAl {Company} binary;
var BoughtAnyBut3 binary;
var OverThreshold3 binary;
var Price binary;

#Funzione Obiettivo
maximize Guadagno: (sum{i in Tipo,j in Class} Vendita[i,j]*NumCond[i,j]) -
					(sum{m in Materials,a in Company} Acquisto[m,a]*NumMat[m,a]) +
					Bonus*Price;
					
#Vincoli
#vincolo tra materie prime utilizzate e acquistate
s.t. v1 {m in Materials}: sum{i in Tipo,j in Class} Elementi[m,i,j]*NumCond[i,j] <= sum{a in Company} NumMat[m,a];
#vincolo che stabilisce il massimo di materie prime acquistabili
s.t. v2 {m in Materials}: sum{a in Company} NumMat[m,a] <= Capienza[m];
#vincolo che stabilisce il minimo numero di condensatori da produrre di una certa classe
s.t. v3 {j in Class}: sum{i in Tipo} NumCond[i,j] >= Minimo[j];
#vincolo che stabilisce la quota minima di mercato dei condensatori elettrolitici
s.t. v4: sum{el in ElTipo,j in Class} NumCond[el,j] >= (Percent/100)*sum{i in Tipo,j in Class} NumCond[i,j];
#vincolo che stabilisce che il numero minimo di materiali acquistabili da Company1 sia maggiore di PartMin1
s.t. v5: sum{m in Materials, c1 in Company1} NumMat[m,c1] >= PartMin1;
#attivazione variabili exist1000
s.t. v6 {i in Tipo}: sum{j1 in 1000Class} NumCond[i,j1] <= Big*exist1000[i];
#stabilisce l'esclusività di exist1000
s.t. v7: sum{i in Tipo} exist1000[i] == 1;
#attivazione variabili BoughtAl
s.t. v8 {a in Company}: sum{al in AlMat} NumMat[al,a] <= Big*BoughtAl[a];
#attivazione variabile BoughtAnyBut3
s.t. v9: sum{a in Company diff Company3} BoughtAl[a] <= card(Company diff Company3)*BoughtAnyBut3;
#stabilisce la condizione di esclusività di Company3 sull'alluminio
s.t. v10: BoughtAnyBut3 + BoughtAl[first(Company3)] ==1;
#attivazione variabile OverThreshold3
s.t. v11: (sum{m in Materials, c3 in Company3} NumMat[m,c3]) - PartMinPremio <= Big*OverThreshold3;
#attivazione variabile Price
s.t. v12: BoughtAl[first(Company3)] + OverThreshold3 >= 2*Price;