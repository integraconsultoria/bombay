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
User Function GatDesc()

Local oModel    := FWModelActive()
Local cDesc     := oModel:GetValue('DA0MASTER','DA0_XDESC')

oModel:SetValue('DA1DETAIL','DA1_XDESC',cDesc)

Return cDesc
