#include "Protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE ENTER Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcertaCusto บAutor  ณPaulo Bindo       บ Data ณ  02/06/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcerta Custo de acordo com a estrutura e ultima entrada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AcertaCusto()
	Local oSay := NIL // CAIXA DE DIมLOGO GERADA
	Local aParamBox := {}
	Private apRet := {}

	aAdd(aParamBox,{1,"Tipo PI",Space(02),"","","02","",2,.T.}) // Tipo caractere
	aAdd(aParamBox,{1,"Tipo PA",Space(02),"","","02","",2,.T.}) // Tipo caractere
	Aadd(aParamBox,{1,"Produto de"  ,Space(TamSx3("B1_COD")[1]),PesqPict("SB1","B1_COD")    ,"" ,"SB1"	, "", 80, .T.})
	Aadd(aParamBox,{1,"Produto Ate" ,Space(TamSx3("B1_COD")[1]),PesqPict("SB1","B1_COD")    ,"" ,"SB1"	, "", 80, .T.})	
	aAdd(aParamBox,{4,"Processa custo MP ?",.F.,"Deseja recalcular MP?.",90,"",.F.})
	aAdd(aParamBox,{4,"Processa custo estrutura?",.F.,"Deseja recalcular estrutura?.",90,"",.F.})

	If ParamBox(aParamBox,"recalcular os custo da SB9 do ๚ltimo fechamento da filial corrente.",@apRet)
		FwMsgRun(NIL, {|oSay| ACusto(oSay)}, "Processando Custos fechamento", "Iniciando processo...")
	Endif


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcertaCusto บAutor  ณPaulo Bindo       บ Data ณ  02/06/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcerta Custo de acordo com a estrutura e ultima entrada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ACusto(oSay)
	Local  nUltCusto:= 0
	Local dFecham := GetMv("MV_ULMES")
	Local aStru := {}
	Local z:= 0
	Local nX := 0
	Local nn := 0
	Private nEstru := 0

	If apRet[5]
		//ACERTA SB9 ULTIMA ENTRADA DE ITENS SEM ESTRUTURA
		cQuery := " SELECT  * FROM "+RetSqlName("SB9")+" WITH(NOLOCK)"
		cQuery += " WHERE B9_FILIAL = '"+cFilAnt+"'"
		cQuery += " AND B9_COD BETWEEN '"+apRet[3]+"' AND '"+apRet[4]+"'" 
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " AND B9_DATA = '"+Dtos(dFecham)+"'"
		cQuery += " AND NOT EXISTS (SELECT 'S' FROM "+RetSqlName("SG1")+" WHERE G1_FILIAL = B9_FILIAL AND G1_COD = B9_COD AND D_E_L_E_T_ <> '*')"

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSB9",.T.,.T.)

		Count To nRec

		If nRec == 0
			MsgStop("NAO EXISTEM DADOS PARA ESTA CONSULTA","ACERTACUSTO")
			TRBSB9->(dbCloseArea())
			Return
		EndIf


		dbSelectArea("TRBSB9")
		dbGoTop()
		While !Eof()
			nUltCusto := 0
			nX++
			oSay:SetText("Processando cuso MP : " + StrZero(nX, 6) +" de "+StrZero(nRec, 6)) // ALTERA O TEXTO CORRETO
			ProcessMessage() // FORวA O DESCONGELAMENTO DO SMARTCLIENT

			//OBTEM O ULTIMO PRECO
			U_AjB9Ult(TRBSB9->B9_COD,TRBSB9->B9_FILIAL,dFecham,@nUltCusto)

			//VALIDA SE A ULTIMA ENTRADA VEIO ZERADA
			If nUltCusto == 0 .And. TRBSB9->B9_CM1 > 0
				nUltCusto := TRBSB9->B9_CM1
			elseIf nUltCusto == 0 .And. TRBSB9->B9_CM1 == 0
				nUltCusto := 0.1
			EndIf

			//ATUALIZA SB9
			DbSelectArea("SB9")
			DbSetOrder(1)
			If dbSeek(xFilial()+TRBSB9->B9_COD+TRBSB9->B9_LOCAL+TRBSB9->B9_DATA)
				RecLock("SB9",.F.)
				B9_CM1 := nUltCusto
				B9_VINI1 := nUltCusto * B9_QINI
				SB9->(MsUnlock())
			EndIf
			dbSelectArea("TRBSB9")
			dbSkip()
		End
		TRBSB9->(dbCloseArea())
	ENDIF

	If apRet[6]

		For nn:=1 To 2
			//ACERTA SB9 ULTIMA ENTRADA DE ITENS COM ESTRUTURA
			cQuery := " SELECT  * FROM "+RetSqlName("SB9")+" B9 WITH(NOLOCK)"
			cQuery += " INNER JOIN "+RetSqlName("SB1")+" B1 WITH(NOLOCK) ON B1_COD = B9_COD AND B1.D_E_L_E_T_ <> '*'"
			cQuery += " WHERE B9_FILIAL = '"+cFilAnt+"'"
			cQuery += " AND B9.D_E_L_E_T_ <> '*'"
			cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'"
			cQuery += " AND B9_COD BETWEEN '"+apRet[3]+"' AND '"+apRet[4]+"'" 
			//cQuery += " AND B9_COD = '0009.99.0001'"
			cQuery += " AND B1_TIPO = '"+Iif(nn== 1,apRet[1],apRet[2])+"'"
			cQuery += " AND B9_DATA = '"+Dtos(dFecham)+"'"
			cQuery += " AND EXISTS (SELECT 'S' FROM "+RetSqlName("SG1")+" WHERE G1_FILIAL = B9_FILIAL AND G1_COD = B9_COD AND D_E_L_E_T_ <> '*')"
			cQuery += " ORDER BY B1_TIPO DESC"
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSB9",.T.,.T.)

			Count To nRec

			If nRec == 0
				//MsgStop("NAO EXISTEM DADOS PARA ESTA CONSULTA DE ESTRUTURA","ACERTACUSTO")
				TRBSB9->(dbCloseArea())
				Loop
			EndIf

			nx := 0
			dbSelectArea("TRBSB9")
			dbGoTop()
			While !Eof()
				nUltCusto := 0
				nx++
				oSay:SetText("Processando custo Estrutura do Tipo "+apRet[1]+" : " + StrZero(nX, 6) +" de "+StrZero(nRec, 6)) // ALTERA O TEXTO CORRETO
				ProcessMessage() // FORวA O DESCONGELAMENTO DO SMARTCLIENT


				//ACERTA SB9 CUSTO MEDIO DE ITENS COM ESTRUTURA
				nEstru:= 0
				aStru := U_Estrut_tel(TRBSB9->B9_COD,,,nEstru) // Obtem a estrutura

				for z := 1 to Len(aStru)
					DbSelectArea("SB9")
					DbSetOrder(1)
					If dbSeek(xFilial()+aStru[z][3]+TRBSB9->B1_LOCPAD+TRBSB9->B9_DATA)
						nUltCusto += Iif(SB9->B9_CM1 > 0,aStru[z][4]*SB9->B9_CM1,0.1)
					EndIf
				next

				//ATUALIZA SB9
				DbSelectArea("SB9")
				DbSetOrder(1)
				If dbSeek(xFilial()+TRBSB9->B9_COD+TRBSB9->B9_LOCAL+TRBSB9->B9_DATA)
					RecLock("SB9",.F.)
					B9_CM1 := nUltCusto
					B9_VINI1 := nUltCusto * B9_QINI
					SB9->(MsUnlock())
				EndIf
				dbSelectArea("TRBSB9")
				dbSkip()
			End
			TRBSB9->(dbCloseArea())
		Next
	Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjB9Ult    บAutor  ณPaulo Bindo       บ Data ณ  02/06/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณACERTA SB9 ULTIMA ENTRADA DE ITENS SEM ESTRUTURA            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AjB9Ult(cCod,cFilEst,dFecham,nUltCusto)


	cQuery := " SELECT TOP 1 * FROM "+RetSqlName("SD1")+" D1"+ENTER
	cQuery += " INNER JOIN  "+RetSqlName("SF4")+" F4"+ENTER
	cQuery += " ON F4_CODIGO = D1_TES AND F4_FILIAL = D1_FILIAL"+ENTER
	cQuery += " WHERE D1_COD = '"+cCod+"' AND  D1.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*' AND D1_TIPO = 'N'"+ENTER
	cQuery += " AND D1_FILIAL = '"+cFilEst+"' AND F4_DUPLIC = 'S'"+ENTER
	cQuery += " AND D1_DTDIGIT <= '"+Dtos(dFecham)+"'"
	cQuery += " AND D1_QUANT > 0"
	cQuery += " ORDER BY D1_DTDIGIT DESC"+ENTER

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBNSD1",.T.,.T.)
	Count To nRec2

	If nRec2 > 0
		dbSelectArea("TRBNSD1")
		dbGoTop()

		nUltCusto := (TRBNSD1->D1_VUNIT*(1-(TRBNSD1->D1_DESC/100))) + Round((TRBNSD1->D1_VUNIT * TRBNSD1->D1_IPI)/100,2)+(TRBNSD1->D1_ICMSRET/TRBNSD1->D1_QUANT)
	else
		nUltCusto:= 0
	EndIf

	TRBNSD1->(dbCloseArea())

RETURN




/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o   ณ Estrut   ณ Autor ณ Rodrigo de A. Sartorioณ Data ณ 03/08/95 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…oณ Faz a explosao de uma estrutura a partir do SG1            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ ExpA1:=Estrut(ExpC1,ExpN1,ExpL1)                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo do produto a ser explodido                  ณฑฑ
ฑฑณ          ณ ExpN1 = Quantidade base para explosao da estrutura         ณฑฑ
ฑฑณ          ณ ExpL1 = Identifica se explode somente primeiro nivel       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservaoณ Como e uma funcao recursiva precisa ser criada uma variavelณฑฑ
ฑฑณ          ณ private nEstru com valor 0 antes da chamada da funo.     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GENERICO                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
User Function Estrut_tel(cProduto,nQuant,lOneLevel,nEstru)

	//Local lOneLevel := .F.
	LOCAL nRegi
	LOCAL nQuantItem:=0


	nQuant:=IF(nQuant == NIL,1,nQuant)
	nEstru++
	If nEstru == 1
		aEstrutura2:={}
	EndIf
	conout("entrou na funcao stru_tel")
	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial()+cProduto)
	While !Eof() .And. G1_FILIAL+G1_COD == xFilial()+cProduto
		conout("entrou na funcao stru_tel dentro do while")
		nRegi:=Recno()
		If G1_COD != G1_COMP
			nProcura:=aScan( aEstrutura2,{|x| x[1] == nEstru .And. x[2] == G1_COD .And. x[3] == G1_COMP .And. x[5] == G1_TRT})
			If nProcura  = 0
				nQuantItem:=U_ExplEstr_Tel(nQuant)
				AADD( aEstrutura2,{nEstru,G1_COD,G1_COMP,nQuantItem,G1_TRT,G1_GROPC,G1_OPC})
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se existe sub-estrutura                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !lOneLevel
				nRecno:=Recno()
				dbSeek(xFilial()+G1_COMP)
				IF Found()
					U_Estrut_tel(G1_COD,nQuantItem,,nEstru)
					nEstru --
					If nEstru = 0
						nEstru := 1
					Endif
				Else
					dbGoto(nRecno)
					nProcura:=aScan( aEstrutura2,{|x| x[1] == nEstru .And. x[2] == G1_COD .And. x[3] == G1_COMP .And. x[5] == G1_TRT})
					If nProcura  = 0
						nQuantItem:=U_ExplEstr_Tel(nQuant)
						AADD( aEstrutura2,{nEstru,G1_COD,G1_COMP,nQuantItem,G1_TRT,G1_GROPC,G1_OPC})
					EndIf
				Endif
			EndIf
		EndIf
		dbGoto(nRegi)
		dbSkip()
	Enddo
Return( aEstrutura2)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ExplEstr_Tel ณ Autor ณ Eveli Morasco         ณ Data ณ 20/08/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula a quantidade usada de um componente da estrutura   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpN1 := ExplEstr_Tel(ExpN2,ExpD1,ExpC1,ExpC2)                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 = Quantidade utilizada pelo componente               ณฑฑ
ฑฑณ          ณ ExpN2 = Quantidade do pai para calcular neces. do filho    ณฑฑ
ฑฑณ          ณ ExpD1 = Data para validacao do componente na estrutura     ณฑฑ
ฑฑณ          ณ ExpC1 = String contendo os opcionais utilizados            ณฑฑ
ฑฑณ          ณ ExpC2 = Revisao da estrutura utilizada                     ณฑฑ
ฑฑณ          ณ ExpN3 = Variavel com valor numerico que justifica o motivo ณฑฑ
ฑฑณ          ณ         pelo qual a quantidade esta zerada.                ณฑฑ
ฑฑณ          ณ         1 - Componente fora das datas inicio / fim         ณฑฑ
ฑฑณ          ณ         2 - Componente fora dos grupos de opcionais        ณฑฑ
ฑฑณ          ณ         3 - Componente fora das revisoes                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ExplEstr_Tel(nQuant,dDataStru,cOpcionais,cRevisao,nMotivo)

	LOCAL nQuantItem:=0,cUnidMod,nG1Quant:=0,nQBase:=0,nDecimal:=0,nBack:=0
	LOCAL aTamSX3:={}
	LOCAL cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
	LOCAL lOk:=.T.
	LOCAL nDecOrig:=Set(3,8)
	//Local nMotivo:=0

	conout("quantidade funcao ExplEstr_Tel 1")
	conout(nQuant)

	aTamSX3:=TamSX3("G1_QUANT")
	nDecimal:=aTamSX3[2]

// Verifica os opcionais cadastrados na Estrutura
	cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

// Verifica a Revisao Atual do Componente
	cRevisao:= If((cRevisao == NIL),"",cRevisao)

	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial()+SG1->G1_COD)
		If Empty(cOpcionais) .And. !Empty(B1_OPC)
			cOpcionais:=B1_OPC
		EndIf
		If Empty(cRevisao) .And. !Empty(B1_REVATU)
			cRevisao:=B1_REVATU
		EndIf
		If !Empty(cOpcionais) .And. !Empty(SG1->G1_GROPC+SG1->G1_OPC) .And. !(SG1->G1_GROPC+SG1->G1_OPC $  cOpcionais)
			nMotivo:=2  // Componente fora dos grupos de opcionais
			lOk:=.F.
		EndIf
		If lOk .And. !Empty(cRevisao) .And. (SG1->G1_REVINI > cRevisao .Or. SG1->G1_REVFIM < cRevisao)
			nMotivo:=3	// Componente fora das revisoes
			lOk:=.F.
		EndIf
	EndIf
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	dbGoto(nRecno)

// Verifica a data de validade
	dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)
	If dDataStru >= SG1->G1_INI .And. dDataStru <= SG1->G1_FIM .And. lOk
		cUnidMod := GetMv("MV_UNIDMOD")
		dbSelectArea("SB1")
		dbSeek(xFilial()+SG1->G1_COD)
		nQBase := B1_QB
		dbSeek(xFilial()+SG1->G1_COMP)
		dbSelectArea("SG1")
		nG1Quant := G1_QUANT
		If SubStr(G1_COMP,1,3)=="MOD"
			cTpHr := GetMv("MV_TPHR")
			If cTpHr == "N"
				nG1Quant := Int(nG1Quant)
				nG1Quant += ((G1_QUANT-nG1Quant)/60)*100
			EndIf
		EndIf
		If G1_FIXVAR $ " V"
			If SubStr(G1_COMP,1,3)=="MOD" .And. cUnidMOD != "H"
				nQuantItem := ((nQuant / nG1Quant) / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
			EndIf
			nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
		Else
			If SubStr(G1_COMP,1,3)=="MOD" .And. cUnidMOD != "H"
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			EndIf
		Endif
		nQuantItem:=Round(nQuantitem,nDecimal)
	ElseIf lOk
		nMotivo:=1 // Componente fora das datas inicio / fim
	EndIf
	Do Case
	Case (SB1->B1_TIPODEC == "A") //TIPO DE TRATAMENTO DE CASAS DECIMAIS PARA ESTRUTURA A=ARREDONDA, I= INCREMENTA, T=TRUNCA
		nBack := Round( nQuantItem,0 )
	Case (SB1->B1_TIPODEC == "I")
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
	Case (SB1->B1_TIPODEC == "T")
		nBack := Int( nQuantItem )
	OtherWise
		nBack := G1_QUANT
	EndCase
//IF Val(G1_NIV) > 01
//	nBack := G1_QUANT
//Endif
	conout("quantidade funcao ExplEstr_Tel 2 variavel nback")
	conout(nBack)

	Set(3,nDecOrig)
Return( nBack )
