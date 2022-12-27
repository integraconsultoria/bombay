#INCLUDE "PROTHEUS.CH"

/*/{protheus.doc} M460MARK
*******************************************************************************************
Retorna se item do pedido pode ser faturado.
 
@author: Marcelo Celi Marques - Alfa ERP
@since: 14/03/2019
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function M460MARK()
Local cMarca 	:= Paramixb[1]
Local lInverte 	:= Paramixb[2]
Local lRet		:= .T.
Local lVldConf	:= GetNewPar("BO_CONFPV","N") == "S"
Local aArea		:= GetArea()

If lVldConf
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		lRet := !Empty(SC5->C5_PESOL) .And. !Empty(SC5->C5_PBRUTO) .And. !Empty(SC5->C5_VOLUME1)
		If !lRet
			MsgAlert("Existe(m) Pedido(s) sem pedo bruto, liquido e volumes sem informar."+CRLF+"Faturamento não Permitido.")
		EndIf	
		If lRet .And. SC5->C5_XSTATUS <> "5" .And. SC5->C5_XFLUXCF <> "N" .And. SC5->C5_TIPO == "N" // Marcelo Celi - 19/01/2021
			MsgAlert("Existe(m) Pedido(s) Marcados com pendencias do fluxo de liberação ou separação."+CRLF+"Faturamento não Permitido.")
			lRet := .F.
		EndIf
	EndIf	
EndIf

RestArea(aArea)

Return lRet
