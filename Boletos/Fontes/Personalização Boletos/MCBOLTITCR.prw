# Include "Protheus.ch"

/*/{protheus.doc} MCBOLTITCR
*******************************************************************************************
Ponto de Entrada para selecionar se titulo pode ou não ser considerado na emissão do 
Boleto na rotina MCBOLETO.
 
@author: Marcelo Celi Marques
@since: 05/01/2021
@param: 
@return:
@type function: Ponto de Entrada
*******************************************************************************************
/*/
User Function MCBOLTITCR()
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local lRet      := .T.

If SA1->(FieldPos("A1_XBOL"))>0
    SA1->(dbSetOrder(1))
    If SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA))) 
        If SA1->A1_XBOL == "S"
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    EndIf
EndIf

SA1->(RestArea(aAreaSA1))
RestArea(aArea)

Return lRet
