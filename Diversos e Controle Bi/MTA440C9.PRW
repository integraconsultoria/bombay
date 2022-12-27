#INCLUDE "Totvs.ch"

/*/{protheus.doc} MTA440C9
*******************************************************************************************
Ponto de Entrada na atualização da SC9 para atualização de status do pedido de vendas
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MTA440C9()
u_BoAtuStPv(SC5->C5_NUM)
Return
