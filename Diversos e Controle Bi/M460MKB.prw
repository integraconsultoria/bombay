# Include "Protheus.ch"

/*/{protheus.doc} M460MKB
*******************************************************************************************
Ponto de entrada acionado ao entrar na rotina de faturamento de documentos de saida
 
@author: Marcelo Celi Marques
@since: 09/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function M460MKB()
Local cCond     := c460Cond

//->> Ajusta o pode faturar
u_BoAjPodFat()

Return cCond
