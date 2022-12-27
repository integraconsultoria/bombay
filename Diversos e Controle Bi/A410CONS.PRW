#include "Protheus.ch"


//Gera pré nota no pedido de vendas
//Rogerio Lino - 18/09/2018


User Function A410CONS() 

Local aBut := {}

//--> Verifica se inclui ou altera
If INCLUI .or. ALTERA 
     aAdd(aBut, { "COMPTITL",{|| MATR730()},"Gera Pré Nota","Pré Nota" } )
EndIf    
 
Return(aBut) 
    
