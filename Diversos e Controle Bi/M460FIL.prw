# Include "Protheus.ch"

/*/{protheus.doc} M460FIL
*******************************************************************************************
Ponto de entrada para manipular a query de seleção de pedidos a faturar no mata460.
 
@author: Marcelo Celi Marques
@since: 09/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function M460FIL()
Local lVldConf	:= Alltrim(Upper(GetNewPar("BO_CONFPV","S"))) == "S"
Local cFiltro   := ""

If SC9->(FieldPos("C9_XPODFAT"))> 0 .And. lVldConf
    cFiltro := " SC9->C9_XPODFAT == 'S' "
Else
    cFiltro := " .T. "
EndIf

Return cFiltro
