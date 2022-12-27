#Include"rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Rdmake   ³ RELEXCEL                               ³ Data ³ 02/02/2022 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor    ³ PAULO BINDO                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Relatorio GERA PLANILHA EXCEL    			   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RELEXCEL()

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT"


	Processa({|| RELEX1() })

	RESET ENVIRONMENT
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RELEXCEL  ºAutor  ³Microsiga           º Data ³  09/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³RELATORIO DE DADOS DE PRODUTOS                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RELEX1()
	Private cArqTxt := "C:\EXCEL\RELEXCELI.CSV"
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"
	MakeDir("C:\EXCEL\")

	cQuery := " select"
	cQuery += " A1_COD ,"
	cQuery += " A1_NOME,"
	cQuery += " (SELECT TOP 1 C5_CONDPAG FROM "+RetSqlName("SC5")+" WHERE C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND C5_TIPO = 'N' AND D_E_L_E_T_ <> '*' ORDER BY C5_NUM DESC) A1_CONDPAG,"
	cQuery += " (SELECT E4_DESCRI FROM "+RetSqlName("SE4")+" WHERE E4_CODIGO = (SELECT TOP 1 C5_CONDPAG FROM "+RetSqlName("SC5")+" WHERE C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND C5_TIPO = 'N' AND D_E_L_E_T_ <> '*' ORDER BY C5_NUM DESC) AND D_E_L_E_T_ <> '*') E4_DESCRI,"
	cQuery += " A1_PRICOM ,"
	cQuery += " A1_ULTCOM,"
	cQuery += " A1_METR,"
	cQuery += " A1_RISCO,"
	cQuery += " A1_VENCLC,"
	cQuery += " A1_LC,"
	cQuery += " A1_MCOMPRA"
	cQuery += " FROM "+RetSqlName("SA1")+""
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += " AND A1_MSBLQL <> '1'"


	MEMOWRIT("RELEXCEL.SQL", cQuery )

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QUERY', .F., .T.)
	Count To nRec

	ProcRegua(nRec)

	If nRec == 0
		MsgStop("Não foram encontrados dados!","Atenção - RELEXCEL")
		QUERY->(dbCloseArea())
		Return
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif


	For n := 1 to FCount()
		aTam := TamSX3(FieldName(n))
		If !Empty(aTam) .and. aTam[3] $ "N/D"
			TCSETFIELD('QUERY',FieldName(n),aTam[3],aTam[1],aTam[2])
		EndIf
	Next

	cLin    := ''
	For n := 1 to FCount()

		If !FieldName(n) $ "R_E_C_N_O_|R_E_C_D_E_L_"
			cLin += AllTrim(Posicione("SX3",2,FieldName(n),"X3_TITULO"))

			IF n == FCount()
				cLin += cEOL//VAI PARA A LINHA DE BAIXO
			Else
				cLin += ';' //PROXIMA COLUNA
			EndIf
		EndIf

	Next

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
//		U_InforConout("Ocorreu um erro na gravacao do arquivo.")
		dbCloseArea()
		fClose(nHdl)
		Return
	Endif


	dbSelectArea("QUERY")
	dbGotop()

	While !Eof()

		IncProc("Processando Aguarde...")

		cLin    := ''
		For n := 1 to FCount()
			If !FieldName(n) $ "R_E_C_N_O_|R_E_C_D_E_L_"
				If Empty(Posicione("SX3",2,FieldName(n),"X3_CBOX"))
					//TIRA PONTO E VIRGULA
					cValor := AllTrim(Transform(FieldGet(n),PesqPict(IIF(At('_',FieldName(n))=3,'S'+Left(FieldName(n),2),Left(FieldName(n),3)),FieldName(n))))
					cLin += StrTran(cValor,";",",")
				Else
					cBox := Posicione("SX3",2,FieldName(n),"X3_CBOX")
					cVar := AllTrim(Transform(FieldGet(n),PesqPict(IIF(At('_',FieldName(n))=3,'S'+Left(FieldName(n),2),Left(FieldName(n),3)),FieldName(n))))+"="
					cConteudo := SubStr(cBox,At(cVar,cBox),Len(cBox))
					cConteudo := SubStr(cConteudo,Len(cVar)+1,At(";",cConteudo)-3)
					cLin += cConteudo
				EndIf
				cLin += IIF(n == FCount(),cEOL,';')
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
		//³ linha montada.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			//U_InforConout("Ocorreu um erro na gravacao do arquivo.")
			TRB->(dbCloseArea())
			fClose(nHdl)
			Return
		Endif

		dbSelectArea("QUERY")
		dbSkip()
	End
	QUERY->(dbCloseArea())

	fClose(nHdl)
//	If ! ApOleClient( 'MsExcel' )
		ShellExecute("open",cArqTxt,"","", 1 )
//		Return
//	EndIf
/*
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cArqTxt ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

	If MsgYesNo("Deseja fechar a planilha do excel?")
		oExcelApp:Quit()
		oExcelApp:Destroy()
	EndIf
*/

Return



