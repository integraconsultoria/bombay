
#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MA415COR
*******************************************************************************************
Ponto de entrada para tratar as cores da rotina de orçamentos
 
@author: Marcelo Celi Marques
@since: 30/11/2020
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function MA415COR()
Local aCores := Paramixb

//->> Declaração de publicas que serao utilizadas na rotina
Public p__cUM  := ""
Public p__lUM  := .F.

Return aCores
