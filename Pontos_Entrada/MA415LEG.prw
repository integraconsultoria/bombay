
#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MA415LEG
*******************************************************************************************
Ponto de entrada para tratar as cores da rotina de orçamentos
 
@author: Marcelo Celi Marques
@since: 06/01/2023
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function MA415LEG()
Local aCores := Paramixb

aAdd(aCores,{'qmt_no',"Bloqueado Vrl Min não Atingido"})

Return aCores
