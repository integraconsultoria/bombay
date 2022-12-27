#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    

/*/{protheus.doc} M460NUM
*******************************************************************************************
Ponto de Entrada para alterar a numeração da nota fiscal de saida

@author: Marcelo Celi Marques
@since: 09/09/2022
@param: 
@return:
@type function: Usuário (Ponto de Entrada)
*******************************************************************************************
/*/
User Function M460NUM()

//->> Utilizado para considerar a numeração da nota, vindo do ecommerce, se necessário considerar a numeração
If IsInCallStack(Upper("u_MaEcGerNot")) .And. Type("_cNewDocto")<>"U" .And. !Empty(_cNewDocto)
	cNumero := _cNewDocto
EndIf	

Return	
