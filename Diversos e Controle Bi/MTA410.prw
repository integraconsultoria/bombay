#include "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MTA410()
Ponto de Entrada no PEDIDO DE VENDA

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   04/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
// https://tdn.totvs.com/pages/releaseview.action?pageId=6784388
User Function MTA410       

Local nTotal := 0
Local nValor := Ascan( aHeader, { |x| Alltrim( X[2] ) == "C6_VALOR" } ) //busca a posição do campo C6_VALOR
Local nI 
Local lRet := .t.

    //----------------------------------------------
    // Percorre todas as linhas do PEDIDO DE VENDA
    //----------------------------------------------
    For nI := 1 To Len( aCols )
        //verifica se a linha não esta deletada
        If !aCols[nI][Len(aHeader)+1]
            nTotal := nTotal + aCols[nI][nValor]     
        EndIf
    Next nI

    //----------------------------------------------
    // Grava o campo na memória
    //----------------------------------------------
    M->C5_XTOTAL := nTotal

Return( lRet )

