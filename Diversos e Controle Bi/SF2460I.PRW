#INCLUDE "PROTHEUS.CH"

/*/{protheus.doc} SF2460I
*******************************************************************************************
Ponto de Entrada no termino do faturamento do pedido de vendas
 
@author: Marcelo Celi Marques
@since: 17/12/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function SF2460I
Local aArea     := GetArea()
Local aAreaSD2  := SD2->(GetArea())
Local aPedidos  := {}
Local nX        := 0

SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE)))
Do While SD2->(!Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE)
    If Ascan(aPedidos,{|x| Alltrim(x[01]) == Alltrim(SD2->D2_PEDIDO) }) == 0
        aAdd(aPedidos,{SD2->D2_PEDIDO})
    EndIf
    SD2->(dbSkip())
EndDo

For nX:=1 to Len(aPedidos)
    SC5->(dbSetOrder(1))
    If SC5->(dbSeek(xFilial("SC5")+aPedidos[nX,01]))
        Reclock("SC5",.F.)
        SC5->C5_XSTATUS := "6"        
        SC5->(MsUnlock())
    EndIf
Next nX

SD2->(RestArea(aAreaSD2))
RestArea(aArea)

Return
