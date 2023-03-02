#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MT415AUT
*******************************************************************************************
Ponto de entrada acionado no momento da efetivação do orçamento de vendas, no mata415.

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
User Function MT415AUT()
Local lRet   	:= .T.
Local cMotivo	:= ""
Local nVlrTotal := 0

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 
Local lItRemov  := .F.
Local cMensagem := ""

Begin Transaction
	If !IsBlind() .And. lUsaBkOrd
		If SCK->(FieldPos("CK_XBKQTD"))>0
			SCK->(dbSetOrder(1))
			SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
			Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM)
				If !VldProduto(SCK->CK_PRODUTO,@cMotivo,.F.)
					RecLock("SCK",.F.)
						SCK->CK_XBKQTD := SCK->CK_QTDVEN
						SCK->CK_XBKTIP := cMotivo
					SCK->(MsUnlock())
					lItRemov := .T.
				Else
					RecLock("SCK",.F.)
						SCK->CK_XBKQTD := 0
						SCK->CK_XBKTIP := ""
					SCK->(MsUnlock())

					nVlrTotal += SCK->CK_VALOR
				EndIf
				SCK->(dbSkip())
			EndDo
		EndIf
	Endif

	If lUsaBkOrd .And. !IsBlind() .And. SA1->(FieldPos("A1_XVMINVD"))>0 .And. SCK->(FieldPos("CK_XBKTIP"))>0
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA))) .And. SA1->A1_XVMINVD > 0
			If nVlrTotal < SA1->A1_XVMINVD
				lRet := .F.
				cMensagem := "O Orçamento não atinge o valor mínimo de R$ "+Alltrim(Transform(SA1->A1_XVMINVD,PesqPict("SA1","A1_XVMINVD")))+" para faturamento e não pode seguir com a Efetivação."
				If lItRemov
					cMensagem += CRLF+"Motivo: Itens foram removidos devido a Bloqueios de BackOrder."
				EndIf
				cMensagem += CRLF+"Deseja Bloquear o Orçamento?"

				If MsgYesNo(cMensagem)				
					RecLock("SCJ",.F.)
					SCJ->CJ_STATUS := "Z"
					SCJ->(MsUnlock())
					
					SCK->(dbSetOrder(1))
					SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
					Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM)
						If Empty(SCK->CK_XBKTIP)				
							RecLock("SCK",.F.)
							SCK->CK_XBKQTD := SCK->CK_QTDVEN
							SCK->CK_XBKTIP := "99"
							SCK->(MsUnlock())						
						EndIf
						SCK->(dbSkip())
					EndDo				
				Else
					DisarmTransaction()
				EndIf
			Else
				DisarmTransaction()
			EndIf
		Else
			DisarmTransaction()
		EndIf
	EndIf
End Transaction

Return lRet

/*/{protheus.doc} VldProduto
*******************************************************************************************
Ponto de entrada acionado no momento de click no botão tudoOk do mata410 (pedidos de vendas)

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
Static Function VldProduto(cProduto,cMotivo,lJob)
Local cTabProd  := ""
Local cQuery 	:= ""
Local cAlias    := GetNextAlias()
Local aArea     := GetArea()
Local lRet      := .F.

cMotivo := ""

cQuery := "SELECT COUNT(*) AS QTDRECS"                      +CRLF
cQuery += "FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"         +CRLF
cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"      +CRLF
cQuery += "  AND SB1.B1_COD    = '"+cProduto+"'"            +CRLF
cQuery += "  AND SB1.B1_MSBLQL <> '1'"                      +CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' '"                      +CRLF            

If lJob
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
Else
	MsgRun("Validando o Produto na Indústria...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })
EndIf

If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof()) .And. (cAlias)->QTDRECS > 0
	lRet := .T.
Else
	lRet := .F.	
	cMotivo := "01"
EndIf
(cAlias)->(dbCloseArea())

If lRet
	cTabProd := SCJ->CJ_TABELA
	If Empty(cTabProd)
		cTabProd := Posicione("SA1",1,xFilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA),"A1_TABELA")
	EndIf
	If !Empty(cTabProd)
		cQuery := "SELECT COUNT(*) AS QTDRECS"                      +CRLF
		cQuery += "FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"         +CRLF
		cQuery += "INNER JOIN "+RetSqlName("DA1")+" DA1 (NOLOCK)"   +CRLF
		cQuery += "  ON DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"      +CRLF
		cQuery += " AND DA1.DA1_CODTAB = DA0.DA0_CODTAB"            +CRLF
		cQuery += " AND DA1.DA1_CODPRO = '"+cProduto+"'"            +CRLF
		cQuery += " AND DA1.DA1_ATIVO = '1'"                        +CRLF
		cQuery += "  AND (DA1.DA1_DATVIG <= '"+dTos(Date())+"'"     +CRLF
		cQuery += "    OR DA1.DA1_DATVIG = ' ')"                    +CRLF                
		cQuery += " AND DA1.D_E_L_E_T_ = ' '"                       +CRLF
		cQuery += "WHERE DA0.DA0_FILIAL = '"+xFilial("DA0")+"'"     +CRLF
		cQuery += "  AND DA0.DA0_CODTAB = '"+cTabProd+"'"           +CRLF
		cQuery += "  AND DA0.DA0_ATIVO = '1'"                       +CRLF
		cQuery += "  AND (DA0.DA0_DATATE <= '"+dTos(Date())+"'"     +CRLF
		cQuery += "    OR DA0.DA0_DATATE = ' ')"                    +CRLF
		cQuery += "  AND DA0.D_E_L_E_T_ = ' '"                      +CRLF            
		
		If lJob
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
		Else
			MsgRun("Validando Tab Preço na Indústria...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })
		EndIf

		If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof()) .And. (cAlias)->QTDRECS > 0
			lRet := .T.
		Else
			lRet := .F.
			cMotivo := "02"
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return lRet
