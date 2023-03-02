#INCLUDE "TOTVS.CH"

/*/{protheus.doc} F050GER
*******************************************************************************************
Gravação de Dados complementares de titulos a pagar com dados do compras.

@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function F050GER()
Local aRecnos  := Paramixb
Local nX       := 1
Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local cObs     := "" 
Local aPedidos := {}

If FwIsInCallStack("MATA103") .And. SC7->(FieldPos("C7_OBSM"))>0 .And. SE2->(Fieldpos("E2_XOBSCOM"))>0
    aRecnos := GetRecnos(SF1->F1_SERIE,SF1->F1_DOC,"NF",SF1->F1_FORNECE,SF1->F1_LOJA)
    If Len(aRecnos)>0
        SD1->(dbSetOrder(1))
        SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
        Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
            If !Empty(SD1->D1_PEDIDO) .And. Ascan(aPedidos,{|x| Alltrim(x)==Alltrim(SD1->D1_PEDIDO)})==0
                aAdd(aPedidos,SD1->D1_PEDIDO)
            EndIf
            SD1->(dbSkip())
        EndDo

        For nX:=1 to Len(aPedidos)
            SC7->(dbSetOrder(1))
            SC7->(dbSeek(xFilial("SC7")+aPedidos[nX]))
            Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+aPedidos[nX]
                If !Empty(cObs)
                    cObs += CRLF+CRLF
                EndIf
                If !Empty(SC7->C7_OBSM)
                    cObs += Alltrim(SC7->C7_OBSM)
                EndIf
                SC7->(dbSkip())
            EndDo
        Next nX

        If !Empty(cObs)
            For nX:=1 to Len(aRecnos)
                If aRecnos[nX,01]=="SE2"
                    SE2->(dbGoto(aRecnos[nX,02]))
                    If Alltrim(SE2->E2_TIPO) <> 'TX'
                        Reclock("SE2",.F.)
                        SE2->E2_XOBSCOM := cObs
                        SE2->(MsUnlock())                    
                    EndIf
                EndIf
            Next nX
        EndIf
    EndIf
EndIf

SC7->(RestArea(aAreaSC7))
SD1->(RestArea(aAreaSD1))
SF1->(RestArea(aAreaSF1))
SE2->(RestArea(aAreaSE2))
RestArea(aArea)

Return

/*/{protheus.doc} GetRecnos
*******************************************************************************************
Retorna os Recnos do Contas a Pagar Gerado

@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetRecnos(cPrefixo,cNumero,cTipo,cFornece,cLoja)
Local aRecnos := {}
Local aArea   := GetArea()
Local cQuery  := ""
Local cAlias  := GetNextAlias()

cQuery := "SELECT SE2.R_E_C_N_O_ AS RECSE2"             +CRLF
cQuery += "  FROM "+RetSqlName("SE2")+" SE2 (NOLOCK)"   +CRLF
cQuery += "  WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+"'"+CRLF
cQuery += "    AND SE2.E2_PREFIXO = '"+cPrefixo+"'"     +CRLF
cQuery += "    AND SE2.E2_NUM     = '"+cNumero+"'"      +CRLF
cQuery += "    AND SE2.E2_TIPO    = '"+cTipo+"'"        +CRLF
cQuery += "    AND SE2.E2_FORNECE = '"+cFornece+"'"     +CRLF
cQuery += "    AND SE2.E2_LOJA    = '"+cLoja+"'"        +CRLF
cQuery += "    AND SE2.D_E_L_E_T_ = ' '"                +CRLF
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
Do While (cAlias)->(!Eof())
    aAdd(aRecnos,{"SE2",(cAlias)->RECSE2})
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

RestArea(aArea)

Return aRecnos

