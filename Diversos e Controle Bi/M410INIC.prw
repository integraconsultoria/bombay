#INCLUDE "TOTVS.CH"

/*/{protheus.doc} M410INIC
*******************************************************************************************
Ponto de entrada para inicializacao do pedido de vendas na inclusao
 
@author: Marcelo Celi Marques
@since: 30/11/2020
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function M410INIC()

//->> Declaração de publicas que serao utilizadas na rotina
Public p__cUM  := ""
Public p__lUM  := .F.

Return
