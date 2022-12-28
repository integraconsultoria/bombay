#INCLUDE "TOTVS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

/*/{protheus.doc} WFW120P
*******************************************************************************************
Ponto de Entrada de envio de wf de aprovação de compras
 
@author: Marcelo Celi Marques
@since: 27/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function WFW120P()
Local aArea := GetArea()
Local cNome := UsrFullName(RetCodUsr())   // Jonathan Nascimento

SCR->(dbSetOrder(1))
SCR->(dbSeek(xFilial("SCR") + "PC" + SC7->C7_NUM))
Do While SCR->(!Eof()) .And. Alltrim(xFilial("SCR")) + Alltrim("PC") + Alltrim(SC7->C7_NUM) == Alltrim(SCR->CR_FILIAL) + Alltrim(SCR->CR_TIPO) + Alltrim(SCR->CR_NUM)
    RecLock("SCR",.F.)
    SCR->CR_XFORNE := SC7->C7_XDESCR
    SCR->CR_XCOND  := Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI")
    SCR->CR_XFRETE := SC7->C7_TPFRETE
    SCR->CR_XEST   := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE,"A2_EST")
    SCR->CR_XOBS   := SC7->C7_XOBS
    SCR->CR_XUSR := cNome
    SCR->(MsUnLock())
    SCR->(dbSkip())
EndDo
RestArea(aArea)

Return

/*/{protheus.doc} WFW120P
*******************************************************************************************
Retorna o Saldo do Estoque do Produto
Criado para ser chamado do gatilho: C7_PRODUTO, sequencia 006 e retornado no CDOMIN: C7_XESTDIS

CHAMADA:  If(Findfunction("u_BoGtSldPrd"),u_BoGtSldPrd(M->C7_PRODUTO,"01"),0)

@author: Marcelo Celi Marques
@since: 27/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoGtSldPrd(cProduto,cArmazem)
Local nSaldo    := 0
Local aArea     := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local lEmpenho  := .T.

SB2->(dbSetOrder(1))
If SB2->(dbSeek(xFilial("SB2")+PadR(cProduto,Tamsx3("B2_COD")[01])+PadR(cArmazem,Tamsx3("B2_LOCAL")[01])))    
    nSaldo := SaldoSb2(,lEmpenho)
EndIf

SB2->(RestArea(aAreaSB2))
RestArea(aArea)

Return nSaldo

/*/{protheus.doc} BoTstW120p
*******************************************************************************************
Função usada para testes
 
@author: Marcelo Celi Marques
@since: 27/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoTstW120p()
Local cEmp    := "01"
Local cFil    := "0101"
//Local cPedido := "005368"
Local nSaldo  := 0

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

nSaldo := u_BoGtSldPrd("0001.13.0018","01")

//SC7->(dbSetOrder(1))
//If SC7->(dbSeek(xFilial("SC7")+cPedido))
    //u_WFW120P()
//EndIf

Return



