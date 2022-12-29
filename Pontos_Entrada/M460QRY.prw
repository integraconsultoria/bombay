# Include "Protheus.ch"

/*/{protheus.doc} M460QRY
*******************************************************************************************
Ponto de entrada para manipular a query de seleção de pedidos a faturar no mata460.
 
@author: Marcelo Celi Marques
@since: 09/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function M460QRY()
Local lVldConf	:= Alltrim(Upper(GetNewPar("BO_CONFPV","S"))) == "S"
Local cQuery    := Paramixb[01]
Local nTipo     := Paramixb[02]

If nTipo == 1 .And. lVldConf
    If SC9->(FieldPos("C9_XPODFAT"))> 0
        cQuery += " AND SC9.C9_XPODFAT = 'S' "
    EndIf
EndIf

Return cQuery
