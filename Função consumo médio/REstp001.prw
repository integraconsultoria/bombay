#include "rwmake.ch"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} REstP001()
Relatório de SEPARAÇÃO DE PEDIDOS

	@author  Jamer Nunes Pedroso - @INTEGRAERP
	@version P12
	@since   04/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------

User Function REstP001( cCodProd, dRefData )

Local nMes 
Local nAno 
Local dDataIni 
Local dDataFIm 
Local nQtd := 0 

Default dRefData :=  dDataBase 
Default cCodProd := "0001.03.0004"

If Month(dRefData)==1
	nMes := 12
	nAno := Year(dRefData)-1
Else
	nMes := Month(dRefData)-1
	nAno := Year(dRefData)
EndIf

dDataIni := Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01")
dDataFim := LastDay(Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01"))

//( <cAlias>, <nOrdem>, <cChave>, <cCampo> )
nQtd := ( Posicione("SB3",1,XFilial("SB3")+cCodProd,"B3_Q"+StrZero(nMes,2)) *1.50 )

Return( nQtd )
