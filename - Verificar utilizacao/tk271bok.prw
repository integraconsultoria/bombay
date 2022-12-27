#include "Protheus.Ch"
		
/*/{Protheus.doc} TK271BOK
//TODO Descrição auto-gerada.
@author Pedro Lima
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TK271BOK

Local       nI := 0
Local  nVlrTot := 0
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_QUANT"})
Local _nPosUni := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VRUNIT"})
Local _nPosTot := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VLRITEM"})
	 
	If nFolder == 2 // Faturamento
	      
	     For nI := 1 To Len(acols) 
	          //GDFieldPos("ACG_TITULO") retorna a posicao do campo 
	             nVlrTot += aCols[nI][_nPosTot] 
	     Next nI 
	      
	EndIf 
	
	aValores[1] := nVlrTot
	aValores[6] := nVlrTot
	aValores[8] := nVlrTot
	
	//aValores - Total, Suframa. Frete, Desconto, Mercadoria
Return