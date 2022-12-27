#Include "PROTHEUS.CH"     
#Include "TOPCONN.CH"
  
/*
------------------------------------------------------------------------------------------------------------
Fun��o: MA410MNU

Tipo: Ponto de entrada

Descri��o: Inclui OP em Outras a��es da rotina MATA650 - Ordens de produ��o

Uso: INTEGRA

Par�metros:

Retorno:
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 06/01/2020 - Flavio Monachesi  - Constru��o inicial do fonte
flavio@integraconsultoriaerp.com.br
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 06/01/2020 - Flavio Monachesi   
------------------------------------------------------------------------------------------------------------
*/

User Function MTA650MNU 
 
	                      
Local area   := GetArea()   
Local aBotao := {}
// Inclui OP em Outras a��es
                                               
 aadd(aRotina,{'OP','MATR797' , 0 , 9,0,NIL})
 
 ADel(aRotina, 9)
ASize(aRotina, (Len(aRotina)-1)) 
  
 
RestArea(area)

return NIL