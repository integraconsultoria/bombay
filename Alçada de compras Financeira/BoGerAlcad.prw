#INCLUDE "TOTVS.CH"
#INCLUDE "ApWizard.ch"

/*/{protheus.doc} MT120FIM
*******************************************************************************************
Ponto de Entrada acionado ao termino da gravação do pedido de compras
 
@author: Marcelo Celi Marques
@since: 05/04/2021
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
User Function MT120FIM()
Local nOpc      := Paramixb[01]
Local cPedido   := Paramixb[02]
Local nOpcA     := Paramixb[03]
Local cFilPed   := SC7->C7_FILIAL
Local cNumPed   := SC7->C7_NUM

// Alterado Flavio Monachesi 16/08/21 - Para que n�o seja considerada a al�ada financeira
//If (Funname()=="MATA121" .Or. Funname()=="MATA120") .And. !Empty(cPedido) .And. (nOpc == 3 .Or. nOpc == 4) .And. nOpcA == 1 
//    Begin Transaction
//        u_BOGrvAlcPC()
//    End Transaction

  // Marcelo Celi - 14/09/2022  
  //If  FindFunction("u_BoGeC5byC7") .and. nOpc == 3
    If  FindFunction("u_BoGeC5byC7") .and. (nOpc == 3 .Or. nOpc==9).And. nOpcA == 1 
        u_BoGeC5byC7(cFilPed,cNumPed)
    EndIf
//EndIf

Return

/*/{protheus.doc} BOGrvAlcPC
*******************************************************************************************
Realiza a gravação da alçada de compras de acordo com as regras Bombay
 
@author: Marcelo Celi Marques
@since: 05/04/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOGrvAlcPC()
Local aArea     := GetArea()
Local aAreaSC7  := SC7->(GetArea())
// Local nVlrParce := GetNewPar("BO_ALCPCVL",3000)
// Local nPrzMedio := GetNewPar("BO_ALCPCPZ",45)
Local nVlrParce := GetNewPar("BO_ALCPCVL",0)
Local nPrzMedio := GetNewPar("BO_ALCPCPZ",0)
Local nX        := 1
Local nPrzCalc  := 0
Local nParCalc  := 0
Local cNumPC    := SC7->C7_NUM
Local dEmissao  := SC7->C7_EMISSAO
Local nMoeda    := SC7->C7_MOEDA
Local nTxMoeda  := SC7->C7_TXMOEDA
Local cCodUser  := SC7->C7_USER
Local nValor    := 0
Local nTotal    := 0
Local aRecSC7   := {}
Local lBlq      := .F.

SC7->(dbGotop())
SC7->(dbSetOrder(1))
SC7->(dbSeek(xFilial("SC7")+cNumPC))
Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPC
    nValor := (SC7->(C7_QUANT-C7_QUJE) * SC7->C7_PRECO)
    If nValor > 0
        nTotal += nValor
        aAdd(aRecSC7,SC7->(Recno()))
        
        Reclock("SC7",.F.)
        SC7->C7_CONAPRO := "L"
        SC7->C7_APROV   := "" 
        SC7->(MsUnlock())
    EndIf
    SC7->(dbSkip())
EndDo

If nMoeda <> 1
    aVenctos := Condicao(xMoeda(nTotal,nTxMoeda,nMoeda,dEmissao),cCondicao,,dEmissao)
Else
    aVenctos := Condicao(nTotal,cCondicao,,dEmissao)
EndIf

For nX:=1 to Len(aVenctos)
    nPrzCalc += (aVenctos[nX,01] - dEmissao)
    nParCalc += aVenctos[nX,02]
Next nX
nPrzCalc := nPrzCalc / Len(aVenctos)
nParCalc := nParCalc / Len(aVenctos)

If !lBlq
    If nPrzCalc < nPrzMedio
        lBlq := .T.
        MsgAlert("Pedido de Compras "+cNumPC+" bloqueado devido ao prazo medio de pagamento ser inferior a "+Alltrim(Str(nPrzMedio))+" dias.")
    EndIf
EndIf

If !lBlq
    If nParCalc > nVlrParce
        lBlq := .T.
        MsgAlert("Pedido de Compras "+cNumPC+" bloqueado devido a parcela media de pagamento ser superior a R$ "+Alltrim(Transform(nVlrParce,"@E 999,999,999,999.99"))+".")
    EndIf
EndIf

If lBlq
    GerAlcada(cNumPC,dEmissao,nMoeda,nTxMoeda,cCodUser,nTotal,aRecSC7)
EndIf

SC7->(RestArea(aAreaSC7))
RestArea(aArea)

Return

/*/{protheus.doc} GerAlcada
*******************************************************************************************
Gera a Alcada.
 
@author: Marcelo Celi Marques
@since: 05/04/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GerAlcada(cNumPC,dEmissao,nMoeda,nTxMoeda,cCodUser,nTotal,aRecSC7)

SCR->(dbSetOrder(1))
SCR->(dbSeek(xFilial("SCR")+PadR("PC",Tamsx3("CR_TIPO")[01])+PadR(cNumPC,Tamsx3("CR_NUM")[01])))
Do While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == xFilial("SCR")+PadR("PC",Tamsx3("CR_TIPO")[01])+PadR(cNumPC,Tamsx3("CR_NUM")[01])
    Reclock("SCR",.F.)
    Deleted()
    SCR->(MsUnlock())
    SCR->(dbSkip())
EndDo

If Len(aRecSC7)>0   
    GeraSCR(cNumPC,nTotal,dEmissao,nMoeda,nTxMoeda,cCodUser,aRecSC7)
EndIf

Return

/*/{protheus.doc} GeraSCR
*******************************************************************************************
Grava os registros SCR.
 
@author: Marcelo Celi Marques
@since: 05/04/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GeraSCR(cDocto,nValDcto,dEmissao,nMoeda,nTxMoeda,cCodUser,aRecSC7)
Local cGrupo    := ""
Local aAlcada   := {}
Local cAuxNivel := ""
Local lTipoDoc  := .F.
Local nX        := 0
Local dPrazo    := Stod("")
Local dAviso    := Stod("")

Default cCodUser := RetCodUsr()

SY1->(dbSetOrder(3))
If SY1->(dbSeek(xFilial("SY1")+cCodUser))
    cGrupo := SY1->Y1_GRAPROV
EndIf

SAL->(dbSetOrder(3))
If !Empty(cGrupo) .And. SAL->(dbSeek(xFilial("SAL")+cGrupo))
    cAuxNivel := SAL->AL_NIVEL
    lTipoDoc  := SAL->AL_DOCPC
    Do While SAL->(!Eof()) .And. SAL->(AL_FILIAL+AL_COD) == xFilial("SAL")+cGrupo .And. lTipoDoc     
        aAdd(aAlcada,{SAL->AL_NIVEL,IIF(SAL->AL_NIVEL == cAuxNivel  ,"02","01"),SAL->AL_USER,SAL->AL_APROV})
        SAL->(dbSkip())
    EndDo
EndIf

For nX:=1 to Len(aAlcada)
    Reclock("SCR",.T.)
    SCR->CR_FILIAL	:= xFilial("SCR")
    SCR->CR_NUM		:= cDocto
    SCR->CR_TIPO	:= "PC"
    SCR->CR_NIVEL	:= aAlcada[nX,01]
    SCR->CR_USER	:= aAlcada[nX,03]
    SCR->CR_APROV	:= aAlcada[nX,04]
    SCR->CR_STATUS	:= aAlcada[nX,02]
    SCR->CR_TOTAL	:= nValDcto
    SCR->CR_EMISSAO	:= dEmissao
    SCR->CR_MOEDA	:= nMoeda
    SCR->CR_TXMOEDA	:= nTxMoeda
    SCR->CR_PRAZO	:= dPrazo
    SCR->CR_AVISO	:= dAviso
    SCR->CR_ESCALON	:= .F.
    SCR->CR_ESCALSP	:= .F.
    SCR->CR_GRUPO := cGrupo    
    SCR->(MsUnlock())
Next nX

For nX:=1 to Len(aRecSC7)
    SC7->(dbGoto(aRecSC7[nX]))
    Reclock("SC7",.F.)
    SC7->C7_CONAPRO := "B"
    SC7->C7_APROV   := cGrupo 
    SC7->(MsUnlock())
Next nX

Return
