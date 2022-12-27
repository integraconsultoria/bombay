#INCLUDE "TOTVS.CH"
             
/*/{protheus.doc} MT010INC
*******************************************************************************************
Ponto de Entrada acionado apos a gravação do produto, no MATA010.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MT010INC()

//->> [21/07/2020 - Marcelo Celi Marques] - Replicacao dos produtos para as demais filiais.
If Findfunction("u_BOAtuProd")
    u_BOAtuProd()
EndIf

Return