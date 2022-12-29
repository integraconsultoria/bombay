#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

/*/{protheus.doc} M440STTS
*******************************************************************************************
Ponto de Entrada acionado apos as manutenções do cadastro de pedidos de vendas.
 
@author: Marcelo Celi Marques
@since: 09/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/

User Function M440STTS()

    RecLock("SC9",.F.)    
    SC9->C9_XIDINTG := SC5->C5_XIDINTG
    SC9->(MsUnlock())

Return
