#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

/*/{protheus.doc} M410STTS
*******************************************************************************************
Ponto de Entrada acionado apos as manutenções do cadastro de pedidos de vendas.
 
@author: Marcelo Celi Marques
@since: 09/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function M410STTS()
Local nTipo     := Paramixb[01]
Local cFilRegr  := GetNewPar("BO_FILREGV","0101")

//->> Marcelo Celi - 13/01/2021
Local lBrq      := cFilAnt $ cFilRegr 

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 

//->> Marcelo Celi - 23/02/2022
If SC5->(FieldPos("C5_XORIGEM")) > 0 .And. !Empty(SC5->C5_XORIGEM) .And. ;
   SC5->(FieldPos("C5_XIDINTG")) > 0 .And. !Empty(SC5->C5_XIDINTG)

   lBrq := .F.
   If SC5->C5_XFLUXCF <> "N"    
        RecLock("SC5",.F.)
        SC5->C5_XFLUXCF := "N"
        SC5->(MsUnlock())
    EndIf
    RecLock("SC5",.F.)    
    SC5->C5_CONDPAG := "SEM"
    SC5->(MsUnlock())

    If SC9->(FieldPos("C9_XIDINTG")) > 0
        SC9->(dbSetOrder(1))
        SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
        Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+SC5->C5_NUM
            Reclock("SC9",.F.)
            SC9->C9_XIDINTG := SC5->C5_XIDINTG
            SC9->(MsUnlock())
            SC9->(dbSkip())
        EndDo
    EndIf

Else
    If SC5->(FieldPos("C5_XFLUXCF")) > 0
        If SC5->C5_XFLUXCF == "N"
            lBrq := .F.
        EndIf
    EndIf
EndIf

If lBrq
    If nTipo == 3 .Or. nTipo==4 .Or. nTipo==6 // inclusao, alteração ou copia
        MsgRun("Verificando Regras de Valores","Aguarde",{|| u_BoBlqRegr() })
    EndIf
EndIf

//->> Marcelo Celi - 14/09/2022
//->> Caso pedido tenha se submetido a alteração, limpar os flags de conferencia
If nTipo == 3 .Or. nTipo==4 .Or. nTipo==6 // inclusao, alteração ou copia
    If SC6->(FieldPos("C6_XDTCONF")) > 0 .And. SC6->(FieldPos("C6_XQTCONF")) > 0
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
        Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
            If SC6->(C6_QTDVEN-C6_QTDENT) > 0
                RecLock("SC6",.F.)
                SC6->C6_XDTCONF := Stod("")
                SC6->C6_XQTCONF := 0
                SC6->(MsUnlock())
            EndIf
            SC6->(dbSkip())
        EndDo
    EndIf
EndIf

//->>Marcelo Celi - 21/12/2022
If nTipo == 3
    If !IsBlind() .And. IsInCallStack("MATA416") .And. lUsaBkOrd
        If Type("_cBoDetalhe")<>"U" .And. Valtype(_cBoDetalhe)=="C" .And. !Empty(_cBoDetalhe) .And. SC5->(FieldPos("C5_XBKDET"))>0
            RecLock("SC5",.F.)
            SC5->C5_XBKDET := _cBoDetalhe
            SC5->(MsUnlock())
        EndIf

        If Type("_cBoMotivo")<>"U" .And. Valtype(_cBoMotivo)=="C" .And. !Empty(_cBoMotivo) .And. SC5->(FieldPos("C5_XBKOBS"))>0
            RecLock("SC5",.F.)
            SC5->C5_XBKOBS := _cBoMotivo
            SC5->(MsUnlock())
        EndIf
    EndIf
EndIf

Return
