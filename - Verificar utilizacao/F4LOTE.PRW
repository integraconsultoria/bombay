//#INCLUDE "SIGACUS.CH" 
#INCLUDE "PROTHEUS.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)



/*/{Protheus.doc} cF4LOTE
//TODO Descrição auto-gerada.
@author Pedro Lima
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}

@type variable
/*/
STATIC cF4LOTE := Space(Len(SUB->UB_LOTE)) 

User Function F4Lote()

Local  nPosCod  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"}) //Produto
Local nPosLocal := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_LOCAL"})   //Local de Armazem
Private   lRet  := .T.

If ReadVar() == "M->UB_LOTE"
	cF4LOTE := U_F4LotePesq(,,,"A465",aCols[n,nPosCod],aCols[n,nPosLocal])
Else 
	MsgInfo("Passou pelo Lote")
EndIf

    If Empty(cF4LOTE)
         lRet := .F.
    EndIf


Return lret

User Function F4LotePesq(	a		, b			, c			, cProg		,;
					cCod	, cLocal	, lParam	, cLocaliz	,;
					nLoteCtl, cOP		, lLoja		, lAtNumLote)
Local aStruSB8		:={} 
Local aArrayF4		:={}
Local aHeaderF4		:={}
Local nOpt1			:= 1
Local nX
Local cVar
Local cSeek
Local cWhile
Local nEndereco
Local cAlias		:= Alias()
Local nOrdem		:= IndexOrd()
Local nRec			:= RecNo()
Local nValA440		:= 0
Local nHdl			:= GetFocus()
Local cCpo
Local oDlg2
Local cCadastro
Local nOpca
Local cLoteAnt		:= ""
Local cLoteFor		:= ""
Local dDataVali		:= ""
Local dDataCria		:= ""
Local lAdd			:= .F.
Local nSalLote		:= 0
Local nSalLote2		:= 0
Local nPotencia		:= 0
Local nPos2			:= 7
Local nPos3			:= 5
Local nPos4			:= 9
Local nPos5			:= 10
Local nPos6			:= 11
Local nPos7			:= 12
Local nPos8			:= 13
Local aTamSX3		:= {}
Local nOAT
Local aCombo1		:= {"Lote","Validade","Lote Fornecedor"} 
Local aPosObj		:= {}
Local aObjects		:= {}
Local aSize			:= MsAdvSize(.F.)

Local cCombo1		:= ""
Local oCombo1
Local lRastro := Rastro(cCod,"S")						
Local aAreaSBF:={}  
Local cQuery    := ""
Local cAliasSB8 := "SB8"
Local nLoop     := 0 
Local aUsado     := {}
Local cLote241   := ''
Local cSLote241  := ''
Local lLote      := .F.
Local lSLote     := .F.
Local nPos       := 0
Local nPCod241   := 0
Local nPLoc241   := 0
Local nPLote241  := 0
Local nPSLote241 := 0
Local nQuant241  := 0
Local nPQuant241 := 0
Local nPCod261   := 0
Local nPLoc261   := 0
Local nPosLt261  := 0
Local nPSlote261 := 0
Local nQuant261  := 0
Local nPosQuant  := 0
Local nPosQtdLib := 0
Local nMultiplic := 1
Local lSelLote := (SuperGetMV("MV_SELLOTE") == "1")   
Local lMTF4Lote:= .T.
Local lExisteF4Lote := ExistBlock("F4LoteHeader")
Local cNumDoc  := ""
Local cSerie   := ""
Local cFornece := ""
Local cLoja    := ""
Local lEmpPrev := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local nSaldoCons:=0
Local nPosLotCTL := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_LOTE"})
Local nPosDValid := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_DTVALID"}) 
Local nPosSubLot := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_SUBLOTE"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_VLDLOTE - Utilizado para visualizar somente os lotes que  | 
//| possuem o campo B8_DATA com o valor menor ou igual a database|
//| do sistema                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lVldDtLote := SuperGetMV("MV_VLDLOTE",.F.,.T.)

Default cLocaliz:= ""
Default cOP     := ""
Default nLoteCtl:= 1  
Default lLoja	:= .F.
Default lAtNumLote := .T.
//Private VAR_IXB := "XXXXXX"
//Private lRet := .T.

cCpo := ReadVar()
lParam := IIf(lParam== NIL, .T., lParam) 
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCod))
lLote  := Rastro(cCod)
lSLote := Rastro(cCod, 'S')
If !lLote
	Help(" ",1,"NAORASTRO")
	Return nil
Endif
If !lRastro
	nPos2:=1;nPos3:=5;nPos4:=8;nPos5:=9;nPos6:=10;nPos7:=11;nPos8:=12
EndIf	

// Verifica se o arquivo que chamou a consulta tem potencia para informar no lote
If Type("nPosPotenc") != "N"
	nPosPotenc := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo a ser pesquisado                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB8")
dbSetOrder(1)
cSeek := cCod+cLocal
dbSeek(xFilial("SB8")+cSeek)
If !Found()
	HELP(" ",1,"F4LOTE")
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoto(nRec)
	Return nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o numero de casas decimais que dever ser utilizado na  ³
//³ consulta.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSX3:=TamSX3(Substr(cCpo,4,3)+"QUANT")
If Empty(aTamSX3)
	aTamSX3:=TamSX3("B8_SALDO")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso utilize controle de enderecamento e tenha endereco      ³
//³ preenchido.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Localiza(cCod) .And. !Empty(cLocaliz)
	dbSelectArea("SB8")
	dbSetOrder(3)
	dbSelectArea("SBF")
	aAreaSBF:=GetArea()
	dbSetOrder(1)
	cSeek:=xFilial("SBF")+cLocal+cLocaliz+cCod
	dbSeek(cSeek)
	Do While !Eof() .And. cSeek == BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO
		If SB8->(dbSeek(xFilial("SB8")+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_LOTECTL+If(!Empty(SBF->BF_NUMLOTE),SBF->BF_NUMLOTE,"")))
			If lVldDtLote .And. SB8->B8_DATA > dDataBase
				SBF->(dbSkip())
				Loop
			EndIf		
			If !Empty(SBF->BF_NUMLOTE) .And. lRastro
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_NUMLOTE,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SBF->BF_LOTECTL,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LOCALIZ,SBF->BF_NUMSERI}))
			Else
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_LOTECTL,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LOCALIZ,SBF->BF_NUMSERI}))
			EndIf
		EndIf
		dbSelectArea("SBF")
		dbSkip()
	EndDo
	RestArea(aAreaSBF)
ElseIf lSLote      
	SB8->( dbSetOrder( 1 ) ) 
	cAliasSB8 := GetNextAlias()
	
	aStruSB8 := SB8->( dbStruct() ) 
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND " 
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND " 
	cQuery += "B8_LOCAL='"   + cLocal          	+ "' AND "
	cQuery += IIf(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len( aStruSB8 ) 			
		If aStruSB8[ nLoop, 2 ] <> "C" 
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf 		
	Next nLoop 		
		
	While !( cAliasSB8 )->(Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		If cProg $ "A465"
			AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str((SB8SALDO(,,,,cAliasSB8,lEmpPrev,,,.T.)-(SB8SALDO(.T.,,,,cAliasSB8,lEmpPrev,,,.T.)+nValA440)),14,aTamSX3[2]), ;
			Str((SB8SALDO(,,,.T.,cAliasSB8,lEmpPrev,,,.T.)-(SB8SALDO(.T.,,,.T.,cAliasSB8,lEmpPrev,,,.T.)+ConvUM(( cAliasSB8 )->B8_PRODUTO,nValA440,0,2))),14,aTamSX3[2]), ;
			( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
		Endif
		( cAliasSB8 )->( dbSkip() ) 
	EndDo
	
	( cAliasSB8 )->( dbCloseArea() ) 
	dbSelectArea( "SB8" ) 

	
Else
	SB8->( dbSetOrder( 3 ) ) 
	cAliasSB8 := GetNextAlias()
	
	aStruSB8 := SB8->( dbStruct() ) 
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND " 
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND " 
	cQuery += "B8_LOCAL='"   + cLocal          	+ "' AND "
	cQuery += IIf(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len( aStruSB8 ) 			
		If aStruSB8[ nLoop, 2 ] <> "C" 
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf 		
	Next nLoop 		
	                                            
	While !( cAliasSB8 )->( Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		cLoteAnt:=( cAliasSB8 )->B8_LOTECTL
		cLoteFor:=( cAliasSB8 )->B8_LOTEFOR
		dDataVali:=( cAliasSB8 )->B8_DTVALID
		dDataCria:=( cAliasSB8 )->B8_DATA
		nPotencia:=( cAliasSB8 )->B8_POTENCI 
		cNumDoc  := ( cAliasSB8 )->B8_DOC
		cSerie   := ( cAliasSB8 )->B8_SERIE
		cFornece := ( cAliasSB8 )->B8_CLIFOR
		cLoja    := ( cAliasSB8 )->B8_LOJA

		lAdd	  :=.F.
		nSalLote  :=0
		nSalLote2 :=0
		If cProg == "A440" .Or. cProg == "AT460"
			nValA440 := QtdLote(( cAliasSB8 )->B8_PRODUTO,( cAliasSB8 )->B8_LOCAL,"",.F.,cLoteAnt)
		EndIf
		While !( cAliasSB8 )->( Eof() ) .And. xFilial("SB8")+cSeek+cLoteAnt == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL+( cAliasSB8 )->B8_LOTECTL
			If !(cProg $ "A100/A240/A440/A241/A242/A270/AT460/A685")
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
			ElseIf cProg == "A240" .Or. cProg == "A241" .Or. cProg == "A242"
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.)
			ElseIf cProg $ "A100/A270"
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.)
			ElseIf cProg == "A440" .Or. cProg == "AT460"
				nSalLote  += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.) - nValA440
				nSalLote2 += SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.) - ConvUM(cCod,nValA440,0,2)
                nValA440 :=0 
			ElseIf cProg == "A685"
				If Empty(cOP)
					nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
					nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
				Else
					nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil),,cOP)
					nSalLote2+= SB8Saldo(NIL,NIL,NIL,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil),,cOP)
				EndIf	
			EndIf
			( cAliasSB8 )->( dbSkip() )
		EndDo
		If QtdComp(nSalLote) > QtdComp(0) .Or. ((cProg == "A270" .And. !lParam) .Or. (cProg == "A685" .And. !lParam) .Or. ((cProg == "A240" .Or. cProg == "A241") .And. SF5->F5_TIPO == "D") .Or. (cProg == "A242" .And. cCpo == "M->D3_LOTECTL"))
			AADD(aArrayF4, F4LoteArray(cProg, lSLote, "", "", {cLoteAnt,cCod,Str(nSalLote,aTamSX3[1],aTamSX3[2]),Str(nSalLote2,aTamSX3[1],aTamSX3[2]), (dDataVali), cLoteFor, dDataCria,nPotencia,cNumDoc,cSerie,cFornece,cLoja}))
		EndIf
	EndDo
	
	( cAliasSB8 )->( dbCloseArea() ) 
	dbSelectArea( "SB8" ) 
	
EndIf

If lMTF4Lote
	If !Empty(aArrayF4)
	
		AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
		AAdd( aObjects, { 100, 30, .t., .f. } )
	
		aSize[ 3 ] -= 50
		aSize[ 4 ] -= 50 	
		
		aSize[ 5 ] -= 100
		aSize[ 6 ] -= 100
		
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )
	
		cCadastro := OemToAnsi("Saldos por Lote")	//"Saldos por Lote"
		nOpca := 0
	
		DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],00 To  aSize[6],aSize[5] OF oMainWnd PIXEL	
		@ 7.1,.4 Say OemToAnsi("Pesquisa Por: ") //"Pesquisa Por: "
		If lSLote
			aHeaderF4 := {"Sub-Lote","Produto","Saldo Atual","Saldo Atual 2aUM","Validade","Lote Fornecedor","Lote","Dt Emissao","Potencia","Nota Fiscal","Serie","Cliente/Fornecedor","Loja"} //"Sub-Lote"###"Produto"###"Saldo Atual"###"Saldo Atual 2aUM"###"Validade"###"Lote Fornecedor"###"Lote"###"Dt Emissao"###"Potencia"###"Nota Fiscal"###"Serie"###"Cliente/Fornecedor"###"Loja"
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If lExisteF4Lote  
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
	        
	        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		Else
			aHeaderF4 := {"Lote","Produto","Saldo Atual","Saldo Atual 2aUM","Validade","Lote Fornecedor","Dt Emissao","Potencia","Nota Fiscal","Serie","Cliente/Fornecedor","Loja"}//"Lote"###"Produto"###"Saldo Atual"###"Saldo Atual 2aUM"###"Validade"###"Lote Fornecedor"###"Dt Emissao"###"Potencia"###"Nota Fiscal"###"Serie"###"Cliente/Fornecedor"###"Loja"
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If lExisteF4Lote
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
			
	        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		EndIf
		@ aPosObj[2][1]+10,aPosObj[2][2] Say OemToAnsi("Pesquisa Por: ") PIXEL //"Pesquisa Por: " 	
		@ aPosObj[2][1]+10,aPosObj[2][2]+50 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,44  VALID F4LotePesq(cCombo1,aArrayF4,oQual,oCombo1) OF oDlg2 FONT oDlg2:oFont PIXEL
		
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-58  TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-28   TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2
		
		ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.t.) CENTERED
		
		If nOpca == 1
		  //  If cProg == "A465"
				/*
				If lRastro        
				    aCols[n][nPosLote]   := aArrayF4[nOAT][1]	
					aCols[n][nPosLotCTL] := aArrayF4[nOAT][nPos2]
				Else   
	            aCols[n][nPosLotCTL] := aArrayF4[nOAT][1]
				EndIf   
				aCols[n][nPosDValid] := aArrayF4[nOAT][5]
				If Substr(cCpo,7) == "LOTE"
				   If lRastro			
					  	&(ReadVar()) :=  aArrayF4[nOAT][nPos2]
					Else
						&(ReadVar()) :=  aArrayF4[nOAT][1]					
				   EndIf	  
				Else
					If lRastro
						&(ReadVar()) :=  aArrayF4[nOAT][1]
					EndIf
				EndIf	
				*/	
			//Else
					
				
				//If lSelLote .and. nPosQuant > 0
					SB8->(DbSetOrder(3))
					//If lSLote
					///cSeek:=xFilial("SB8")+cCod+cLocal+aArrayF4[nOAT][nPos2]+aArrayF4[nOAT][1]
						//cWhile:="SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE)"
					//Else
						cSeek:= xFilial("SB8")+cCod+cLocal+aArrayF4[nOAT][nPos2]
						cWhile:="SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)"
					//EndIf
					if dbSeek(cSeek)
					   lRet := .T.
					Else
					   lRet := .F.
					EndIf
					nSaldoCons := 0
					
	     //			While !EOF() .And. cSeek == &(cWhile)
		 //				nSaldoCons+=SB8SALDO(,,,,,lEmpPrev,,,.T.)
		 //			  dbSkip()
		 //		    End
				//EndIf
				  
				  /* 
				   If lRet
					If !Empty(cProg) .And. Type('aCols') == 'A'
						If lSLote                                 
							If lLoja
								aColsDet[n][nPosLote]:=aArrayF4[nOAT][1]
							Else
								If lAtNumLote
									aCols[n][nPosLote]:=aArrayF4[nOAT][1]
								EndIf
							EndIf														
						EndIf
						If nLoteCtl == 1
							If lLoja
							
								aColsDet[n][nPosLotCTL] :=aArrayF4[nOAT][nPos2]
								aColsDet[n][nPosDValid] :=aArrayF4[nOAT][nPos3]
							 
							Else
							*/
								aCols[n][nPosLotCTL] :=aArrayF4[nOAT][nPos2]
								aCols[n][nPosDValid] :=aArrayF4[nOAT][nPos3]
							/*	
							EndIf							
						EndIf	
						If nPosPotenc > 0
							aCols[n][nPosPotenc] :=aArrayF4[nOAT][nPos4]
						EndIf
					Endif
					*/
					
					/*
					If Substr(cCpo,7) == "LOTE" .Or. Substr(cCpo,7) == "_LOTE"
						&(ReadVar()) :=  aArrayF4[nOAT][nPos2]
					Else
						If lSLote
						
				/*
							&(ReadVar()) :=  aArrayF4[nOAT][1]
						EndIf
					EndIf
					*/
				//EndIf	
		    Else
		       cF4Lote := ""
		       Return cF4Lote
			EndIf
		EndIf
	Else
		HELP(" ",1,"F4LOTE")
	Endif 
       
//dbSelectArea(cAlias)
//dbSetOrder(nOrdem)
//dbGoto(nRec)
//SetFocus(nHdl)

  &(ReadVar()) := aArrayF4[nOAT][nPos2]
       VAR_IXB := &(ReadVar())
//cF4LOTE :=  aArrayF4[nOAT][nPos2]
	
Return(VAR_IXB)

User Function RF4LOTE()
//Local lret := .T. 
return(cF4LOTE)
