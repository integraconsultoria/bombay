#Include 'Protheus.ch'

User Function M410PVNF()
Local aAreaAtu 		:= GetArea()
Local aAreaSc5 		:= SC5->(GetArea())
Local aAreaSF2 		:= SF2->(GetArea())
Local lRet			:= .T.
Local lVldConf		:= GetNewPar("BO_CONFPV","N") == "S"

//->> Marcelo Celi - 14/01/2021
Local lNoFluxo		:= SC5->(FieldPos("C5_XFLUXCF"))>0 .And. SC5->C5_XFLUXCF == "N"

If lVldConf		
	lRet := !Empty(SC5->C5_PESOL) .And. !Empty(SC5->C5_PBRUTO) .And. !Empty(SC5->C5_VOLUME1)
	If !lRet
		MsgAlert("Existe(m) Pedido(s) sem pedo bruto, liquido e volumes sem informar."+CRLF+"Faturamento não Permitido.")
	EndIf	
	
	//->> Ajusta o pode faturar
	u_BoAjPodFat(SC5->C5_NUM)

	If !lNoFluxo
		If lRet .And. SC5->C5_XSTATUS <> "5" .And. SC5->C5_XFLUXCF <> "N" .And. SC5->C5_TIPO == "N" // Marcelo Celi - 19/01/2021
			MsgAlert("Existe(m) Pedido(s) Marcados com pendencias do fluxo de liberação ou separação."+CRLF+"Faturamento não Permitido.")
			lRet := .F.
		EndIf
	EndIf
EndIf	

RestArea(aAreaSF2)
RestArea(aAreaSc5)
RestArea(aAreaAtu)

Return lRet

