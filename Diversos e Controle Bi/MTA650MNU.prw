#Include "PROTHEUS.CH"     
#Include "TOPCONN.CH"
  
/*
------------------------------------------------------------------------------------------------------------
Função: MA410MNU

Tipo: Ponto de entrada

Descrição: Inclui OP em Outras ações da rotina MATA650 - Ordens de produção

Uso: INTEGRA

Parâmetros:

Retorno:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 06/01/2020 - Flavio Monachesi  - Construção inicial do fonte
flavio@integraconsultoriaerp.com.br
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
Atualizações:
- 06/01/2020 - Flavio Monachesi   
------------------------------------------------------------------------------------------------------------
*/

User Function MTA650MNU 
 
	                      
Local area   := GetArea()   
Local aBotao := {}
// Inclui OP em Outras ações
                                               
 aadd(aRotina,{'OP','MATR797' , 0 , 9,0,NIL})
 
 ADel(aRotina, 9)
ASize(aRotina, (Len(aRotina)-1)) 
  
 
RestArea(area)

return NIL