#INCLUDE "protheus.ch"

/*/{protheus.doc} MT416FIM
*******************************************************************************************
Ponto de Entrada acionado apos a finalização do orçamento, tornando-o pedido de vendas.
 
@author: Marcelo Celi Marques
@since: 25/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MT416FIM()
Local lLibPv := Alltrim(Upper(GetNewPar("BO_LIBPVRG","S")))=="S"


If lLibPv
    MsgRun("Liberando Pedido de Vendas...",,{ || u_BoLibPv(SC5->C5_NUM) })
EndIf

Return
