#include 'totvs.ch'

/*/{protheus.doc} MTA010MNU
*******************************************************************************************
Ponto de Entrada para adicionar itens no arotina do cadastro de produtos - MATA010
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Ponto de Entrada
*******************************************************************************************
/*/
User Function MTA010MNU()
aAdd(aRotina, { "Bloquear/Desbloquear Tab Pre�o" ,"u_boBlqTPrc"		, 0 , 4, 2, nil} )
Return

/*/{protheus.doc} boBlqTPrc
*******************************************************************************************
Fun��o para bloquear itens nas tabelas de pre�o (Produtos)
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Usu�rio
*******************************************************************************************
/*/
User Function boBlqTPrc()
Local oTabela   := NIL
Local cUsrAcess := "000000|Administrador|"+Alltrim(GetNewPar("BO_USRTBPR",""))
Local lAcess    := .F.

lAcess := (Alltrim(UsrRetName(RetCodUsr())) $ cUsrAcess) .Or. (Alltrim(RetCodUsr()) $ cUsrAcess)
If lAcess
    oTabela := bo05BlqTabPrc():New(SB1->B1_COD)
Else
    MsgAlert("Usuario n�o autorizado a realizar bloqueios por tabelas de pre�o")
EndIf

Return
