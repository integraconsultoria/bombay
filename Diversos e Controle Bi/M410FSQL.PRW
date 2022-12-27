#INCLUDE "protheus.ch"

/*/{protheus.doc} M410FSQL
*******************************************************************************************
Filtra os registros na SC5 no pedido de vendas somente para os usuarios conectados e amarrados
aos vendedores
 
@author: Marcelo Celi Marques
@since: 25/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function M410FSQL()
Local cFiltro   := ""
Local cCondic   := ""
Local lFiltVend := Alltrim(Upper(GetNewPar("BO_FILVEND","S")))=="S"
Local cUsr      := RetCodUsr()
Local aArea     := GetArea()
Local aAreaSA3  := SA3->(GetArea())

If lFiltVend .And. SA3->(FieldPos("A3_XUSER"))>0
    SA3->(dbGotop())
    SA3->(dbSetOrder(1))
    SA3->(dbSeek(xFilial("SA3")))
    Do While SA3->(!Eof()) .And. SA3->A3_FILIAL == xFilial("SA3")
        If !Empty(SA3->A3_XUSER) .And. SA3->A3_XUSER == cUsr
            cCondic += SA3->A3_COD+"|"
        EndIf
        SA3->(dbSkip())
    EndDo

    If !Empty(cCondic)
        cFiltro := "(C5_VEND1 $ '"+cCondic+"' .Or. Empty(C5_VEND1) )"
    Else
        cFiltro := ""
    EndIf

EndIf

SA3->(RestArea(aAreaSA3))
RestArea(aArea)

Return cFiltro
