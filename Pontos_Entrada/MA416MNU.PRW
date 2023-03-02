#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MA416MNU
*******************************************************************************************
Ponto de entrada para adicionar chamadas no menu da efetivação de orçamentos de vendas.
 
@author: Marcelo Celi Marques
@since: 06/01/2023
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function MA416MNU()
aAdd(aRotina,{'Desbloquear Orc Vlr Minimo','U_BOSCJDesbl()',0,7,0,NIL})   

Return                                                                             

/*/{protheus.doc} BOSCJDesbl
*******************************************************************************************
Desbloqueia o Orçamento de Vendas que fora bloqueado por falta de minimo de faturamento
 
@author: Marcelo Celi Marques
@since: 06/01/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOSCJDesbl()

If SCJ->CJ_STATUS == "Z"
	If MsgYesNo("Confirma o Desbloqueio do Orçamento de Vendas que foi Bloqueado por Falta de Vlr Minimo de Faturamento.")
		RecLock("SCJ",.F.)
		SCJ->CJ_STATUS := "A"
		SCJ->(MsUnlock())
		
		SCK->(dbSetOrder(1))
		SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
		Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM)
			RecLock("SCK",.F.)
			If SCK->(FieldPos("CK_XBKQTD"))>0
				SCK->CK_XBKQTD := 0
			EndIf
			If SCK->(FieldPos("CK_XBKTIP"))>0
				SCK->CK_XBKTIP := ""
			EndIf
			SCK->(MsUnlock())			
			SCK->(dbSkip())
		EndDo
	EndIf
Else
	MsgAlert("Orçamento de Vendas não Bloqueado por Falta de Vlr Minimo de Faturamento.")
EndIf

Return
