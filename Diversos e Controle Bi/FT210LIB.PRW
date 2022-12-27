#INCLUDE "protheus.ch"

/*/{protheus.doc} FT210LIB
*******************************************************************************************
Ponto de Entrada acionado apos a liberação de regras do pedido de vendas.
 
@author: Marcelo Celi Marques
@since: 25/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function FT210LIB()
Local lLibPv := Alltrim(Upper(GetNewPar("BO_LIBPVRG","S")))=="S"

If lLibPv
    MsgRun("Liberando as Regras do Pedido de Vendas...",,{ || u_BoLibPv(SC5->C5_NUM) })
EndIf

Return
