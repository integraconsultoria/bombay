#include "protheus.ch"
#include "TOPCONN.ch"   

// Modulo : SIGAEST
// Fonte  : BBESTA01
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+-----------------------------------------------------------
// 05/01/18 | RENATO SANTOS       | Rotina Movimentos Internos - ARRUMA CUSTO MEDIO 
//          | INTEGRA             |    
//          |                     | 
// ---------+---------------------+-----------------------------------------------------------
User Function BBESTA01(cProdAt, cLocAt, nCstSB2, nCstCalc, nQtdSB2)

Local aArAtu 	:= GetArea()
Local aAreaSF5  := SF5->(GetArea())
Local 	ExpA1 	:= {} 		
Local ExpN2 	:= 3
Local cTMEnt	:= SuperGetMV("BB_TMAJENT",,"005")
Local cTMSai	:= SuperGetMV("BB_TMAJSAI",,"505")
Local cTM		:= iif((nQtdSB2 * nCstSB2) > (nQtdSB2 * nCstCalc), cTMSai, cTMEnt)
Local cUM 		:= GetAdvFVal("SB1","B1_UM",SB1->(XFILIAL()) + cProdAt, 1)
Local nCstRec	:= 0
Local nSitAt	:= 0
Local cStrAj	:= ""
Private lMsErroAuto := .F.          
Private nModulo 	:= 4

if nQtdSB2 <> 0
	if (nQtdSB2 * nCstSB2) > (nQtdSB2 * nCstCalc)
		nCstRec := ( (nQtdSB2 * nCstSB2) - (nQtdSB2 * nCstCalc) )
		nSitAt  := 1	//Ajusta Reduzindo Custo
	Else
		nCstRec := ( (nQtdSB2 * nCstCalc) - (nQtdSB2 * nCstSB2) )
		nSitAt  := 2	//Ajusta Aumentando Custo
	Endif
Else
	nCstRec := 0
	nSitAt  := 3		//Ajusta Zerando Custo
Endif

If nSitAt > 0
	Begin Transaction   	

		//cStrAj := "UPDATE " + RETSQLNAME("SB2") + " SET B2_CM1 = " + ALLTRIM(STR(round(nCstCalc,4))) + ", B2_VATU1 = ( B2_QATU * " + ALLTRIM(STR(round(nCstCalc,2))) + ") WHERE D_E_L_E_T_ = '' AND B2_FILIAL = '" + SB2->(XFILIAL()) + "' AND B2_COD = '" + cProdat + "' AND B2_LOCAL = '" + cLocAt + "' "
		//TCSQLEXEC(cStrAj)

		aadd(ExpA1,{"D3_TM",cTM,})	
		aadd(ExpA1,{"D3_COD",cProdAt,})	
		aadd(ExpA1,{"D3_UM",cUM,})			
		aadd(ExpA1,{"D3_LOCAL",cLocAt,})	
		aadd(ExpA1,{"D3_EMISSAO",dDataBase,})		        
		aadd(ExpA1,{"D3_QUANT",0,})	
		aadd(ExpA1,{"D3_CUSTO1",nCstRec,})		        
		MSExecAuto({|x,y| mata240(x,y)},ExpA1,ExpN2)		
		If lMsErroAuto		
			//ConOut("Erro na inclusao!")
			ConOut("< < BBESTA01 > > " + DtoC(dDataBase) + " " + Time() + " - " + chr(13) + chr(10) + WFLoadFile(NomeAutoLog()))
			MostraErro()
		Else		
			ConOut( "< < BBESTA01 > > " + DtoC(dDataBase) + " " + Time() + " - Ajustado custo médio para o item " + cProdAt + " / " + cLocAt + " de " + Alltrim(Str(nCstSB2)) + " para " + Alltrim(Str(nCstCalc)) )	
		EndIf	
	End Transaction
Else
	ConOut( "< < BBESTA01 > > " + DtoC(dDataBase) + " " + Time() + " - Não houve necessidade de ajuste para o item " + cProdAt + " / " + cLocAt )	
Endif

RestArea(aAreaSF5)
RestArea(aArAtu)

Return 
