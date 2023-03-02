
#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MA416COR
*******************************************************************************************
Ponto de entrada para tratar as cores da rotina de orçamentos na tela de efetivação
 
@author: Marcelo Celi Marques
@since: 06/01/2023
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function MA416COR()
Local aCores := Paramixb

aAdd(aCores,{'SCJ->CJ_STATUS=="Z"','qmt_no'})

Return aCores
