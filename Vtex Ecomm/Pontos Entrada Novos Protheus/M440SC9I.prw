#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    

/*/{protheus.doc} M440SC9I
*******************************************************************************************
Ponto de Entrada para complementar a gravação da SC9.
É executado para cada linha do SC9 no reclock(true).

@author: Marcelo Celi Marques
@since: 11/03/2022
@param: 
@return:
@type function: Ponto de Entrada
*******************************************************************************************
/*/
User Function M440SC9I()
If SC5->(FieldPos("C5_XIDINTG")) > 0 .And. SC9->(FieldPos("C9_XIDINTG")) > 0
    SC9->C9_XIDINTG := SC5->C5_XIDINTG
EndIf

If SC5->(FieldPos("C5_XORIGEM")) > 0 .And. SC9->(FieldPos("C9_XORIGEM")) > 0
    SC9->C9_XORIGEM := SC5->C5_XORIGEM
EndIf

Return
