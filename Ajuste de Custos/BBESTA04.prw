#include "protheus.ch"
#include "TOPCONN.ch"   

// Modulo : SIGAEST
// Fonte  : BBESTA04
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+-----------------------------------------------------------
// 05/01/18 | RENATO SANTOS       | Rotina destinada ao balanceamento do SB8 com saldos do SB2 
//          | INTEGRA             |    
//          |                     | 
// ---------+---------------------+-----------------------------------------------------------
User Function BBESTA04(aDDAtu)
Local aArAtu 	:= GetArea()
Local aAreaSB8  := SB8->(GetArea())
Local cStrAj	:= ""
Private aDadosAj    := aClone(aDDAtu)
Private lMsErroAuto := .F.          
Private nModulo 	:= 4

//Composição da aDadosAj:
//TMP->B2_FILIAL   - Pos 01
//TMP->B1_COD      - Pos 02
//TMP->B2_LOCAL    - Pos 03
//TMP->B1_RASTRO   - Pos 04
//TMP->B2_QATU     - Pos 05
//TMP->QSALVAL     - Pos 06
//TMP->QSALVEN     - Pos 07
//TMP->B2_QACLASS  - Pos 08
//TMP->B2_NAOCLAS  - Pos 09
//TMP->QCLAVAL     - Pos 10
//TMP->QCLAVEN     - Pos 11
//TMP->B2_QEMP     - Pos 12
//TMP->QEMPVAL     - Pos 13
//TMP->QEMPVEN     - Pos 14
//TMP->B2_RESERVA  - Pos 15

if aDadosAj[1,04] == "L"
	if aDadosAj[1,05] > (aDadosAj[1,06] + aDadosAj[1,07])
		U_AcresSB8(aDadosAj)
	ElseIf aDadosAj[1,05] < (aDadosAj[1,06] + aDadosAj[1,07])
		DedzSB8(aDadosAj)
	Endif
else
	ZeraSB8(aDadosAj)
EndIf

RestArea(aAreaSB8)
RestArea(aArAtu)

Return 

//#########################################################
//## ACRESSB8 - Acrescenta valores a SB8, para equiparar ##
//## com SB2.                                            ##
//## Sempre inicia o carregamento por Lotes Vencidos.    ##
//##-----------------------------------------------------##
//## RENATO SANTOS                              22/11/21 ##
//#########################################################
User Function AcresSB8(aDDAcr)
Local aArSB8Acr  := SB8->(GetArea())
Local cStrSB8Acr := ""
Local nDifAt	 := (aDDAcr[1,05] - (aDDAcr[1,06] + aDDAcr[1,07]))
Local nDifCl	 := (aDDAcr[1,09] + aDDAcr[1,10] + aDDAcr[1,11])
Local _nReg		 := 0

cStrSB8Acr := "SELECT R_E_C_N_O_, B8_LOTECTL, B8_SALDO FROM " + RETSQLNAME("SB8") + " SB8 (NOLOCK) "
cStrSB8Acr += "WHERE D_E_L_E_T_ = '' AND B8_FILIAL = '" + aDDAcr[1,1] + "' "
cStrSB8Acr += "AND B8_PRODUTO = '" + aDDAcr[1,2] + "' "
cStrSB8Acr += "AND B8_LOCAL = '" + aDDAcr[1,3] + "' "
cStrSB8Acr += "AND B8_SALDO > 0 "
cStrSB8Acr += "ORDER BY B8_DTVALID "

If Select("ACR") > 0
	ACR->(dbCloseArea())
EndIf
TcQuery cStrSB8Acr Alias "ACR" New

dbselectArea("SB8")
SB8->(dbSetOrder(1))
DbSelectArea("ACR")
ACR->(DbGoTop())
if ACR->(!Eof())
	While ACR->(!Eof())
		if nDifAt > 0 .or. nDifCl > 0
			MsProcTxt("Acrescentando no Lote " + AllTrim(ACR->B8_LOTECTL) + "...")
			SB8->(dbGoto(ACR->R_E_C_N_O_))
			RECLOCK("SB8",.F.)
				SB8->B8_SALDO += nDifAt
				SB8->B8_SALDO2 := ConvUm(SB8->B8_PRODUTO,nDifAt,0,2)
				SB8->B8_QACLASS += nDifCl
				SB8->B8_QACLAS2 := ConvUm(SB8->B8_PRODUTO,nDifCl,0,2)
				nDifAt := 0
				nDifCl := 0
			SB8->(MSUNLOCK())
		Else	
			Exit
		Endif
		ACR->(DBSKIP())
	End
Else
	MsProcTxt("Criando Novo Lote...")
	CriaSB8(aDDAcr)
Endif

If Select("ACR") > 0
	ACR->(dbCloseArea())
EndIf

RestArea(aArSB8Acr)
Return


//#########################################################
//## DEDZSB8 - Subtrai  valores  a  SB8,  para equiparar ##
//## com SB2.                                            ##
//## Sempre inicia o carregamento por Lotes Vencidos.    ##
//##-----------------------------------------------------##
//## RENATO SANTOS                              22/11/21 ##
//#########################################################
Static Function DedzSB8(aDDAcr)
Local aArSB8Ded  := SB8->(GetArea())
Local cStrSB8Ded := ""
Local nDifAt	 := ((aDDAcr[1,06] + aDDAcr[1,07]) - aDDAcr[1,05])
Local nDifCl	 := (aDDAcr[1,09] + aDDAcr[1,10] + aDDAcr[1,11])

cStrSB8Ded := "SELECT R_E_C_N_O_, B8_LOTECTL, B8_SALDO FROM " + RETSQLNAME("SB8") + " SB8 (NOLOCK) "
cStrSB8Ded += "WHERE D_E_L_E_T_ = '' AND B8_FILIAL = '" + aDDAcr[1,1] + "' "
cStrSB8Ded += "AND B8_PRODUTO = '" + aDDAcr[1,2] + "' "
cStrSB8Ded += "AND B8_LOCAL = '" + aDDAcr[1,3] + "' "
cStrSB8Ded += "AND B8_SALDO > 0 "
cStrSB8Ded += "ORDER BY B8_DTVALID "

If Select("ACR") > 0
	ACR->(dbCloseArea())
EndIf
TcQuery cStrSB8Ded Alias "ACR" New

dbselectArea("SB8")
SB8->(dbSetOrder(1))
DbSelectArea("ACR")
ACR->(DbGoTop())
if ACR->(!Eof())
	While ACR->(!Eof())
		If nDifAt > 0 .or. nDifCl > 0
			MsProcTxt("Deduzindo do Lote " + AllTrim(ACR->B8_LOTECTL) + "...")
			SB8->(dbGoto(ACR->R_E_C_N_O_))
			RECLOCK("SB8",.F.)
			IF nDifAt >= SB8->B8_SALDO 
				nDifAt -= SB8->B8_SALDO
				SB8->B8_SALDO := 0
				SB8->B8_SALDO2 := 0
			Else
				SB8->B8_SALDO -= nDifAt
				SB8->B8_SALDO2 := ConvUm(SB8->B8_PRODUTO,nDifAt,0,2)
				nDifAt := 0
			Endif
			if SB8->B8_QACLASS <> 0
				IF nDifCl >= SB8->B8_QACLASS
					nDifCl -= SB8->B8_QACLASS
					SB8->B8_QACLASS := 0
					SB8->B8_QACLAS2 := 0
				Else 
					SB8->B8_QACLASS -= nDifCl
					SB8->B8_QACLAS2 := ConvUm(SB8->B8_PRODUTO,nDifCl,0,2)
					nDifCl := 0
				EndIf
			Endif
			SB8->(MSUNLOCK())
		Else
			Exit
		Endif
		ACR->(DBSKIP())
	End
Else
	MsProcTxt("Criando Novo Lote...")
	CriaSB8(aDDAcr)
Endif

If Select("ACR") > 0
	ACR->(dbCloseArea())
EndIf

RestArea(aArSB8Ded)
Return


//#########################################################
//## ZERASB8 - ZERA  valores  de  SB8,  para equiparar   ##
//## com SB2.                                            ##
//## Sempre inicia o carregamento por Lotes Vencidos.    ##
//##-----------------------------------------------------##
//## RENATO SANTOS                              22/11/21 ##
//#########################################################
Static Function ZeraSB8(aDDAcr)
Local aArSB8Zer  := SB8->(GetArea())
Local cStrSB8Zer := ""

MsProcTxt("Eliminando Lotes de Produtos sem controle...")

cStrSB8Zer := "UPDATE " + RETSQLNAME("SB8") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cStrSB8Zer += "WHERE D_E_L_E_T_ = '' AND B8_FILIAL = '" + aDDAcr[1,1] + "' "
cStrSB8Zer += "AND B8_PRODUTO = '" + aDDAcr[1,2] + "' "
TCSQLEXEC(cStrSB8Zer)

RestArea(aArSB8Zer)
Return


//#########################################################
//## CRIASB8 - CRIA  valores  de  SB8,  para equiparar   ##
//## com SB2.                                            ##
//## Sempre inicia o carregamento por Lotes Vencidos.    ##
//##-----------------------------------------------------##
//## RENATO SANTOS                              22/11/21 ##
//#########################################################
Static Function CriaSB8(aDDAcr)

Local aArSB8Cr := SB8->(GetArea())
Local nOpc := 3
Local cLotNew := "AJ" + RIGHT(DTOS(DDATABASE),4) + STRTRAN(LEFT(TIME(),5),":","")
Local aVetor := {}

Local nQtAjuste := iif( (aDDAcr[01,06] + aDDAcr[01,07]) < 0 .and. aDDAcr[01,05] == 0, (aDDAcr[01,06] + aDDAcr[01,07]) * (-1), aDDAcr[01,05] )

//if aDDAcr[01,05] < 0
	RecLock("SB8",.T.)
		SB8->B8_FILIAL	 := aDDAcr[01,01]
		SB8->B8_QTDORI    := nQtAjuste //aDDAcr[01,05]
		SB8->B8_PRODUTO   := aDDAcr[01,02]
		SB8->B8_LOCAL     := aDDAcr[01,03]
		SB8->B8_DATA      := DDATABASE
		SB8->B8_DTVALID   := DDATABASE + 30
		SB8->B8_SALDO     := nQtAjuste //aDDAcr[01,05]
		SB8->B8_EMPENHO   := aDDAcr[01,12]
		SB8->B8_ORIGLAN   := "AJ"
		SB8->B8_LOTECTL   := "AJ" + RIGHT(DTOS(DDATABASE),4) + STRTRAN(LEFT(TIME(),5),":","")  
		SB8->B8_QACLASS   := aDDAcr[01,08]
		SB8->B8_SALDO2    := ConvUm(aDDAcr[01,02],nQtAjuste,0,2)
		SB8->B8_QTDORI2   := ConvUm(aDDAcr[01,02],nQtAjuste,0,2)
		SB8->B8_EMPENH2   := ConvUm(aDDAcr[01,02],aDDAcr[01,12],0,2)
		SB8->B8_QACLAS2   := ConvUm(aDDAcr[01,02],aDDAcr[01,08],0,2)
		SB8->B8_DOC       := "AJUSTE" + aDDAcr[01,03]
		SB8->B8_SERIE     := "AJ"
		SB8->B8_DFABRIC   := DDATABASE
		SB8->B8_DFABRIC   := DDATABASE
		SB8->B8_DFABRIC   := DDATABASE
		SB8->B8_DFABRIC   := DDATABASE
	SB8->(MSUNLOCK())
//else
// 	aadd(aVetor,{"D5_PRODUTO" 	,aDDAcr[01,02]	,NIL})
// 	aadd(aVetor,{"D5_LOCAL" 	,aDDAcr[01,03] 	,NIL})
// 	aadd(aVetor,{"D5_LOTECTL" 	,cLotNew 		,NIL})
// 	aadd(aVetor,{"D5_DATA" 		,ddatabase 		,NIL})
// 	aadd(aVetor,{"D5_QUANT" 	,aDDAcr[01,05]	,NIL})
// 	aadd(aVetor,{"D5_DTVALID" 	,ddatabase + 30	,NIL})

// 	MSExecAuto({|x,y| Mata390(x,y)},aVetor,nOpc)

// 	If !lMsErroAuto
// 		ConOut("Incluido Lote Novo com sucesso! " + aDDAcr[01,02])
// 	Else
// 		MostraErro()
// 		ConOut("Erro na inclusao!")
// 	EndIf
// Endif

RestArea(aArSB8Cr)

Return
