#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BYCPARC ³ Autor ³                         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CALCUO PRAZO MEDIO FINANCEIRO                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³PARCELAS/PRAZO MEDIO                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXP1: TITULO+PARCELA                                        ³±±
±±³          ³EXP2:TIPO TITULO                                            ³±±
±±³          ³EXP3:FORNECEDOR                                             ³±±
±±³          ³EXP4:FORMA TITULO (PAGAR OU RECEBER)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BYCPARC(cTitParc,cTipTIt,cCadastro,cForma)

	Local aArea := GetArea()

	Local ntPrefix := TamSX3("E2_PREFIXO")[1]
	Local ntTitulo := TamSX3("E2_NUM")[1]
//Local ntParcel := TamSx3("E2_PARCELA")[1]
	Local ntFornec := TamSx3("E2_FORNECE")[1]
//Local ntLoja   := TamSx3("E2_LOJA")[1]

// Trecho extraÃ­do para referÃªncia do Finr150.prx
// aDados[FORNEC]      := SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+If(mv_par28 == 1, SA2->A2_NREDUZ, SA2->A2_NOME)
// aDados[TITUL]	   := SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA
// aDados[TIPO]		   := SE2->E2_TIPO


	Local cTitFil  := Iif(cForma=="P",xFilial("SE2"),xFilial("SE1"))
	Local cPrefixo := Left( cTitParc, ntPrefix )
	Local cTitulo  := Substr( cTitParc, ntPrefix+2,ntTitulo )
	Local cTipTit  := Iif(cForma=="P",SE2->E2_TIPO,SE1->E1_TIPO)
//Local cParcela := Substr( cTitParc, ntPrefix+ntTitulo+3,ntParcel )
	Local cFornCod := Iif(cForma=="P",Left( SE2->E2_FORNECE+"-"+SE2->E2_LOJA, ntFornec ),Left( SE1->E1_CLIENTE+"-"+SE1->E1_LOJA, ntFornec ))
	Local cLoja    :=Iif(cForma=="P", SE2->E2_LOJA,SE1->E1_LOJA)
	Local cParc    := ""
//Local nParcs := 0 
	Local cPrazoMedio := ""
	Local cQuery
	Local nErrTTab

	default cCadastro := Iif(cForma=="P",SE2->E2_FORNECE+"-"+SE2->E2_LOJA,SE1->E1_CLIENTE+"-"+SE1->E1_LOJA)

	If cForma=="P"
		cQuery := " Select R_E_C_N_O_ RECNO, identity(int,1,1) PARCELA,
		cQuery += " SE2.E2_EMISSAO EMISSAO, SE2.E2_VENCREA VENCTO, SE2.E2_VALOR VALOR "
		CQuery += " into TABPARC from "+RetSqlName("SE2")+" SE2 (NoLock)"
		cQuery += " Where SE2.E2_FILIAL   = '"+ cTitFil  +"'
		cQuery += " and   SE2.E2_PREFIXO  = '"+ cPrefixo +"'
		cQuery += " and   SE2.E2_NUM      = '"+ cTitulo  +"'
		cQuery += " and   SE2.E2_TIPO     = '"+ cTipTit  +"'
		cQuery += " and   SE2.E2_FORNECE  = '"+ cFornCod +"'
		cQuery += " and   SE2.E2_LOJA     = '"+ cLoja    +"'
		cQuery += " and   SE2.D_E_L_E_T_ <> '*' "
		cQuery += " order by SE2.E2_EMISSAO "
	else
		cQuery := " Select R_E_C_N_O_ RECNO, identity(int,1,1) PARCELA,
		cQuery += " SE1.E1_EMISSAO EMISSAO, SE1.E1_VENCREA VENCTO, SE1.E1_VALOR VALOR "
		CQuery += " into TABPARC from "+RetSqlName("SE1")+" SE1 (NoLock)"
		cQuery += " Where SE1.E1_FILIAL   = '"+ cTitFil  +"'
		cQuery += " and   SE1.E1_PREFIXO  = '"+ cPrefixo +"'
		cQuery += " and   SE1.E1_NUM      = '"+ cTitulo  +"'
		cQuery += " and   SE1.E1_TIPO     = '"+ cTipTit  +"'
		cQuery += " and   SE1.E1_CLIENTE  = '"+ cFornCod +"'
		cQuery += " and   SE1.E1_LOJA     = '"+ cLoja    +"'
		cQuery += " and   SE1.D_E_L_E_T_ <> '*' "
		cQuery += " order by SE1.E1_EMISSAO "
	EndIf
	nErrTTab := TcSqlExec(cQuery)

	if nErrTTab = 0

		cQuery := "Select PARCELA from TABPARC (NOLOCK) where RECNO = "+Iif(cForma=="P",Str( SE2->( Recno() ),5 ),Str( SE1->( Recno() ),5 ))
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
		cParc  := Strzero(QRY->PARCELA,2)
		QRY->(dbCloseArea())

		cQuery := "Select Count(*) QTD from TABPARC (NOLOCK)"
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
		cParc += "/" +Strzero( QRY->QTD ,2 )
		QRY->(dbCloseArea())

	Endif

	cPrazoMedio := RetPrzMedio()

	TcSqlExec("Drop Table TABPARC")

	RestArea(aArea)

Return({cParc,cPrazoMedio})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetPrzMedio ³ Autor ³                     ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CALCULA O PRAZO MEDIO                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXP1:                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPrzMedio()

	Local aArea := GetArea()
	Local cQuery := ""
	//Local cPrazoMédio := ""
	Local aLines      := {}
	Local vTotValue   := 0
	Local vTotVDifd   := 0
	Local vPrazoMedio := 0
	Local nCount      := 0

	cQuery := "Select * from TABPARC  (NOLOCK)"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QPRZ', .F., .T.)

	QPRZ->(DBEval( {|| aadd( aLines,  { sTod( QPRZ->EMISSAO ) ,stod(QPRZ->VENCTO ), QPRZ->VALOR, 0 } ) } ) )

	QPRZ->(dbCloseArea())

// 1 pra 30 outra pra 45 e outra pra 60 

	For nCOunt := 1 to Len(aLines)


		aLines[nCOunt,4] := aLines[nCOunt,2]-aLines[nCOunt,1]

   /*
   If nCount == 1
      aLines[nCOunt,4] := aLines[nCOunt,2]-aLines[nCOunt,1]
   else 
      aLines[nCount,4] := aLines[nCOunt,2]-aLines[(nCOunt-1),2]    
   Endif 
    */ 

		vTotValue += aLines[nCount,3]
		vTotVDifd += aLines[nCount,4] /*aLines[nCount,3]*/

	Next 1

	vPrazoMedio := ROund( ( vTotVDifd / Len(aLines) ),0 )// /vTotValue )

	cPrazoMedio := Transform(vPrazoMedio, "@E 999" )

	RestArea(aArea)

Return(cPrazoMedio)



