#include "protheus.ch"
#include "TOPCONN.ch"   

// Modulo : SIGAEST
// Fonte  : BBESTA06
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+-----------------------------------------------------------
// 05/01/18 | RENATO SANTOS       | Rotina destinada ao acerto da SB2 se desbalanceada com SB2 
//          | INTEGRA             |    
//          |                     | 
// ---------+---------------------+-----------------------------------------------------------
User Function BBESTA06(aDDAtu)
Local aArAtu 	:= GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local cStrAj	:= ""
Private aDadosAj    := aClone(aDDAtu)
Private lMsErroAuto := .F.          
Private nModulo 	:= 4

//Composição da aDadosAj:
//TMP->B2_FILIAL   - Pos 01
//TMP->B1_COD      - Pos 02
//TMP->B2_LOCAL    - Pos 03
//TMP->B1_TIPOCQ   - Pos 04
//TMP->B2_QATU     - Pos 05
//TMP->TTLMOV      - Pos 06

if aDadosAj[1,06] > aDadosAj[1,05] 
	AcresSB2(aDadosAj)
ElseIf aDadosAj[1,05] > aDadosAj[1,06]
	if aDadosAj[1,04] != "Q"
		dbSelectArea("SB2")
		SB2->(dbsetOrder(1))
		If SB2->(dbSeek( aDadosAj[1,01] + aDadosAj[1,02] + aDadosAj[1,03] ))
			RecLock("SB2",.F.)
			 SB2->B2_QATU -= aDadosAj[1,05]
			 SB2->B2_QTSEGUM := ConvUm(SB2->B2_COD,SB2->B2_QATU,0,2)
			SB2->(MSUNLOCK())
		EndIf
	EndIf
Endif

RestArea(aAreaSB2)
RestArea(aArAtu)

Return 

//#########################################################
//## ACRESSB2 - Acrescenta valores a SB2, para equiparar ##
//## com SB2.                                            ##
//## Sempre inicia o carregamento por Lotes Vencidos.    ##
//##-----------------------------------------------------##
//## RENATO SANTOS                              22/11/21 ##
//#########################################################
Static Function AcresSB2(aDDAcr)
Local aArSB2Acr  := SB2->(GetArea())
Local cTM		 := SuperGetMV("BB_TMAJ98",,"003")
Local ExpA1 	 := {} 		
Local ExpN2 	 := 3

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
dbSelectArea("SB2")
SB2->(dbSetOrder(1))
if SB1->(dbSeek( substr(aDDAcr[01,01],1,2) + "  " + aDDAcr[01,02] ))
	IF SB2->(dbSeek( aDDAcr[01,01] + aDDAcr[01,02] + aDDAcr[01,03] ))
		RecLock("SB2",.F.)
			SB2->B2_QATU += aDDAcr[01,05]
			SB2->B2_QTSEGUM := ConvUm(SB2->B2_COD,SB2->B2_QATU,0,2)
		SB2->(MSUNLOCK())
	Else
		nCstMed := GETADVFVAL("SB2","B2_CM1",aDDAcr[01,01]+aDDAcr[01,02]+"01",1)
		RecLock("SB2",.T.)
			SB2->B2_FILIAL := aDDAcr[01,01]
			SB2->B2_COD := aDDAcr[01,02]
			SB2->B2_LOCAL := aDDAcr[01,03]
			SB2->B2_QATU := aDDAcr[01,05]
			SB2->B2_QTSEGUM := ConvUm(SB2->B2_COD,SB2->B2_QATU,0,2)
			SB2->B2_CM1 := nCstMed
			SB2->B2_VATU1 := aDDAcr[01,05] * nCstMed
			SB2->B2_DMOV := DDATABASE
			SB2->B2_HMOV := TIME()
		SB2->(MSUNLOCK())

		IF SB1->B1_RASTRO == "L"
			aDadosAj := {}
			AADD(aDadosAj,{	aDDAcr[01,01]	, ; //TMP->B2_FILIAL   - Pos 01
							aDDAcr[01,02]	, ; //TMP->B1_COD      - Pos 02
							aDDAcr[01,03]	, ; //TMP->B2_LOCAL    - Pos 03
							SB1->B1_RASTRO	, ; //TMP->B1_RASTRO   - Pos 04
							aDDAcr[01,05]	, ; //TMP->B2_QATU     - Pos 05
							0				, ; //TMP->QSALVAL     - Pos 06
							0				, ; //TMP->QSALVEN     - Pos 07
							0				, ; //TMP->B2_QACLASS  - Pos 08
							0				, ; //TMP->B2_NAOCLAS  - Pos 09
							0				, ; //TMP->QCLAVAL     - Pos 10
							0				, ; //TMP->QCLAVEN     - Pos 11
							0				, ; //TMP->B2_QEMP     - Pos 12
							0				, ; //TMP->QEMPVAL     - Pos 13
							0				, ; //TMP->QEMPVEN     - Pos 14
							0				} ) //TMP->B2_RESERVA  - Pos 15
			U_AcresSB8(aDadosAj)
		EndIf
	EndIf
Endif
//Private lMsErroAuto := .F.          
//Private nModulo 	:= 4
// Begin Transaction   	
// 	aadd(ExpA1,{"D3_FILIAL"	, aDDAcr[1,01] ,})	
// 	aadd(ExpA1,{"D3_TM"		, cTM ,})	
// 	aadd(ExpA1,{"D3_COD"	, aDDAcr[1,02] ,})	
// 	aadd(ExpA1,{"D3_UM"		, GetAdvFVal("SB1","B1_UM",SUBSTR(aDDAcr[1,01],3,2) + aDDAcr[1,02], 1) ,})			
// 	aadd(ExpA1,{"D3_LOCAL"	, aDDAcr[1,03] ,})	
// 	aadd(ExpA1,{"D3_EMISSAO", dDataBase ,})		        
// 	aadd(ExpA1,{"D3_QUANT"	, round(aDDAcr[1,06],TamSX3("B2_QATU")[2]) ,})	
// 	aadd(ExpA1,{"D3_CUSTO1"	, 0 ,})		        
// 	MSExecAuto({|x,y| mata240(x,y)},ExpA1,ExpN2)		
// 	If lMsErroAuto		
// 		ConOut("< < BBESTA06 > > " + DtoC(dDataBase) + " " + Time() + " - " + chr(13) + chr(10) + WFLoadFile(NomeAutoLog()))
// 		MostraErro()
// 	Else		
// 		ConOut( "< < BBESTA06 > > " + DtoC(dDataBase) + " " + Time() + " - Inserida quantidade para CQ do " + aDDAcr[1,02] )	
// 	EndIf	
// End Transaction

RestArea(aArSB2Acr)

Return
