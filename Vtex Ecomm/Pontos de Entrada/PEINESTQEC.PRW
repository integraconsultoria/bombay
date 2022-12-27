#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    

/*/{protheus.doc} PEINESTQEC
*******************************************************************************************
Ponto de Entrada para tratar especificamente o saldo do estoque do produto

Este ponto de entrada valida a existencia do produto na tabela de preços, e este estando
bloqueado ou não existindo na tabela, envia saldo zerado, contudo se este estiver liberado
retorna saldo infinito.

@author: Marcelo Celi Marques
@since: 21/12/2021
@param: 
@return:
@type function: Usuario (Ponto de Entrada chamado da função MaEcxFun)
*******************************************************************************************
/*/
User Function PEINESTQEC()
Local cSKU      := Paramixb[1]
Local cEcommerce:= Paramixb[2]
Local aTabelas  := Paramixb[3]
Local nSaldo    := 0
Local cTabPrc   := ""
Local cProduto  := ""
Local lOk       := .F.
Local aArea     := GetArea()
Local aAreaEstr := {}
Local aAreaProd := {}
Local cTbEcomm  := aTabelas[Ascan(aTabelas,{|x| Alltrim(Upper(x[02]))=="ECO"})][01]
Local cTbProdu  := aTabelas[Ascan(aTabelas,{|x| Alltrim(Upper(x[02]))=="PRO"})][01]
Local cTbEstru  := aTabelas[Ascan(aTabelas,{|x| Alltrim(Upper(x[02]))=="EST"})][01]
Local cTbids    := aTabelas[Ascan(aTabelas,{|x| Alltrim(Upper(x[02]))=="IDS"})][01]

aAreaEstr := (cTbEstru)->(GetArea())
aAreaProd := (cTbProdu)->(GetArea())

(cTbEcomm)->(dbSetOrder(1))
If (cTbEcomm)->(dbSeek(xFilial(cTbEcomm)+cEcommerce))
    cTabPrc := PadR((cTbEcomm)->&(cTbEcomm+"_TABPRC"),Tamsx3("DA1_CODTAB")[01])    
    (cTbProdu)->(dbSetOrder(1))
    If (cTbProdu)->(dbSeek(xFilial(cTbProdu)+cSKU)) .And. (cTbProdu)->&(cTbProdu+"_MSBLQL") <> "1"
        (cTbEstru)->(dbSetOrder(1))
        If (cTbEstru)->(dbSeek(xFilial(cTbEstru)+cSKU))
            lOk := .T.
            Do While (cTbEstru)->(!Eof()) .And. (cTbEstru)->&(cTbEstru+"_FILIAL+"+cTbEstru+"_SKU") == xFilial(cTbEstru)+cSKU
                cProduto := PadR((cTbEstru)->&(cTbEstru+"_COD"),Tamsx3("B1_COD")[01])    
                DA1->(dbSetOrder(1))
                If DA1->(dbSeek(xFilial("DA1")+cTabPrc+cProduto))
                    If DA1->DA1_ATIVO == "2"
                        lOk := .F.
                        Exit
                    EndIf
                Else
                    lOk := .F.
                    Exit
                EndIf        
                (cTbEstru)->(dbSkip())
            EndDo
        EndIf
    EndIf    
EndIf

If lOk
    nSaldo := 999999999 //Val(Replicate("9",Tamsx3(cTbids+"_ULTQTD")[01]-3))
Else
    nSaldo := 0
EndIf

(cTbProdu)->(RestArea(aAreaProd))
(cTbEstru)->(RestArea(aAreaEstr))
RestArea(aArea)

Return nSaldo
