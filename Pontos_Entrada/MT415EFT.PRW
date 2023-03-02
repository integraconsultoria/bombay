#INCLUDE "TOTVS.CH"
#INCLUDE "apwizard.ch"

Static POSIC_BK  	:= 0
Static nCorSelBK	:= Rgb(255,201,14)

/*/{protheus.doc} MT415EFT
*******************************************************************************************
Ponto de entrada acionado no momento da efetivação do orçamento de vendas, no mata415.

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
User Function MT415EFT()
Local lRet   	:= .T.
Local nOpcA  	:= Paramixb[01]
Local cMotivo	:= ""

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 

Public _cBoDetalhe := ""
Public _cBoMotivo  := ""

If nOpcA==1 .And. !IsBlind() .And. lUsaBkOrd
	If SCK->(FieldPos("CK_XBKQTD"))>0
		SCK->(dbSetOrder(1))
		SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
		Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM)
			If !VldProduto(SCK->CK_PRODUTO,@cMotivo,.F.)
				RecLock("SCK",.F.)
					SCK->CK_XBKQTD := SCK->CK_QTDVEN
					SCK->CK_XBKTIP := cMotivo
				SCK->(MsUnlock())
			Else
				RecLock("SCK",.F.)
					SCK->CK_XBKQTD := 0
					SCK->CK_XBKTIP := ""
				SCK->(MsUnlock())				
			EndIf
			SCK->(dbSkip())
		EndDo
	EndIf
Endif

If nOpcA == 0
	lRet := .F.
EndIf

Return lRet


/*/{protheus.doc} VldProduto
*******************************************************************************************
Validação do produto de forma automatica para classificação

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
Static Function VldProduto(cProduto,cMotivo,lJob)
Local cTabProd  := ""
Local cQuery 	:= ""
Local cAlias    := GetNextAlias()
Local aArea     := GetArea()
Local lRet      := .F.

cMotivo := ""

cQuery := "SELECT COUNT(*) AS QTDRECS"                      +CRLF
cQuery += "FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"         +CRLF
cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"      +CRLF
cQuery += "  AND SB1.B1_COD    = '"+cProduto+"'"            +CRLF
cQuery += "  AND SB1.B1_MSBLQL <> '1'"                      +CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' '"                      +CRLF            

If lJob
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
Else
	MsgRun("Validando o Produto na Indústria...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })
EndIf

If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof()) .And. (cAlias)->QTDRECS > 0
	lRet := .T.
Else
	lRet := .F.	
	cMotivo := "01"
EndIf
(cAlias)->(dbCloseArea())

If lRet
	cTabProd := SCJ->CJ_TABELA
	If Empty(cTabProd)
		cTabProd := Posicione("SA1",1,xFilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA),"A1_TABELA")
	EndIf
	If !Empty(cTabProd)
		cQuery := "SELECT COUNT(*) AS QTDRECS"                      +CRLF
		cQuery += "FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"         +CRLF
		cQuery += "INNER JOIN "+RetSqlName("DA1")+" DA1 (NOLOCK)"   +CRLF
		cQuery += "  ON DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"      +CRLF
		cQuery += " AND DA1.DA1_CODTAB = DA0.DA0_CODTAB"            +CRLF
		cQuery += " AND DA1.DA1_CODPRO = '"+cProduto+"'"            +CRLF
		cQuery += " AND DA1.DA1_ATIVO = '1'"                        +CRLF
		cQuery += "  AND (DA1.DA1_DATVIG <= '"+dTos(Date())+"'"     +CRLF
		cQuery += "    OR DA1.DA1_DATVIG = ' ')"                    +CRLF                
		cQuery += " AND DA1.D_E_L_E_T_ = ' '"                       +CRLF
		cQuery += "WHERE DA0.DA0_FILIAL = '"+xFilial("DA0")+"'"     +CRLF
		cQuery += "  AND DA0.DA0_CODTAB = '"+cTabProd+"'"           +CRLF
		cQuery += "  AND DA0.DA0_ATIVO = '1'"                       +CRLF
		cQuery += "  AND (DA0.DA0_DATATE <= '"+dTos(Date())+"'"     +CRLF
		cQuery += "    OR DA0.DA0_DATATE = ' ')"                    +CRLF
		cQuery += "  AND DA0.D_E_L_E_T_ = ' '"                      +CRLF            
		
		If lJob
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
		Else
			MsgRun("Validando Tab Preço na Indústria...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })
		EndIf

		If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof()) .And. (cAlias)->QTDRECS > 0
			lRet := .T.
		Else
			lRet := .F.
			cMotivo := "02"
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{protheus.doc} MT410TOK
*******************************************************************************************
Ponto de entrada acionado no momento de click no botão tudoOk do mata410 (pedidos de vendas)

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Usuario (Ponto de Entrada)
*******************************************************************************************
/*/
User Function MT410TOK()
Local lRet 		 := .T.
Local nPC6NUMORC := 0
Local nPC6QTDVEN := 0
Local aArea      := GetArea()
Local aAreaSCJ   := SCJ->(GetArea())
Local aAreaSCK   := SCK->(GetArea())
Local nX		 := 1
Local aDiverge   := {}
Local cMotivo	 := ""
Local cDetalhe	 := ""

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 

If !IsBlind() .And. IsInCallStack("MATA416") .And. SCK->(FieldPos("CK_XBKQTD"))>0 .And. lUsaBkOrd
	If Type("aCols")<>"U" .And. ValType(aCols)=="A" .And. ;
	   Type("aHeader")<>"U" .And. ValType(aHeader)=="A"

		nPC6NUMORC := Ascan(aHeader,{|x| Alltrim(x[2])==Alltrim("C6_NUMORC")})
		nPC6QTDVEN := Ascan(aHeader,{|x| Alltrim(x[2])==Alltrim("C6_QTDVEN")})
		If nPC6NUMORC > 0 .And. nPC6QTDVEN > 0
			For nX:=1 to Len(aCols)
				If !aCols[nX][Len(aHeader)+1]				
					SCK->(dbSetOrder(1))
					If SCK->(dbSeek(xFilial("SCK")+aCols[nX,nPC6NUMORC]))
						If SCK->CK_QTDVEN <> aCols[nX,nPC6QTDVEN]
							aAdd(aDiverge,{	SCK->CK_NUM,			; // 01 - Numero do Orçamento
											SCK->CK_ITEM,			; // 02 - Item
											SCK->CK_PRODUTO,		; // 03 - Produto
											SCK->CK_QTDVEN,			; // 04 - Qtd Orçada
											aCols[nX,nPC6QTDVEN],	; // 05 - Qtd Efetivada
											SCK->CK_XBKTIP}			) // 06 - Motivo
						EndIf
					EndIf
				Else
					SCK->(dbSetOrder(1))
					If SCK->(dbSeek(xFilial("SCK")+aCols[nX,nPC6NUMORC]))
						aAdd(aDiverge,{	SCK->CK_NUM,			; // 01 - Numero do Orçamento
										SCK->CK_ITEM,			; // 02 - Item
										SCK->CK_PRODUTO,		; // 03 - Produto
										SCK->CK_QTDVEN,			; // 04 - Qtd Orçada
										0,						; // 05 - Qtd Efetivada
										SCK->CK_XBKTIP}			) // 06 - Motivo
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	If Len(aDiverge)>0
		lRet := ConfDiverg(aDiverge,@cMotivo,@cDetalhe)
		If lRet
			_cBoDetalhe := cDetalhe
			_cBoMotivo  := cMotivo
		Else
			_cBoDetalhe := ""
			_cBoMotivo  := ""
		EndIf	
	EndIf
EndIf

SCK->(RestArea(aAreaSCK))
SCJ->(RestArea(aAreaSCJ))
RestArea(aArea)

Return lRet

/*/{protheus.doc} ConfDiverg
*******************************************************************************************
Função que retorna a divergencia.

@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConfDiverg(aDiverge,_cMotivo,_cDetalhe)
Local lRet 			:= .T.
Local aColsDiv		:= {}
Local aHeadDiv  	:= {}
Local aColsTmp		:= {}
Local nX			:= 1
Local cImgAviso 	:= "ngbioalerta_03"
Local oWizard		:= NIL
Local cTextApres	:= ""
Local cLogotipo     := "updwarning50.png"
Local lOk			:= .F.
Local oBackOrder	:= NIL
Local aCoords		:= {0,0,580,1200}
Local oFolder		:= NIL
Local oPanel1		:= NIL
Local oPanel2		:= NIL
Local cMotivo		:= ""
Local oMotivo		:= NIL
Local aMotCombo		:= {}
Local oFont12       := TFont():New("Verdana",,012,,.T.,,,,,.F.,.F.)
Local oFont15       := TFont():New("Verdana",,015,,.T.,,,,,.F.,.F.)
Local cBox			:= ""
Local nPOrc   		:= 0
Local nPItm   		:= 0
Local nPProd  		:= 0
Local nPDesc  		:= 0
Local nPQtOr  		:= 0
Local nPQtEf  		:= 0
Local nPMotiv 		:= 0
Local cObs			:= ""
Local cMotItem		:= ""
Local nPos			:= 0
Local nQtdTracos	:= 0

aAdd(aMotCombo,{"01","Produto Fora de Linha"})
aAdd(aMotCombo,{"02","Produto Bloqueado na Tabela de Preço"})
aAdd(aMotCombo,{"03","Diversos"})

_cMotivo  := ""
_cDetalhe := ""

For nX:=1 to Len(aMotCombo)
	If !Empty(cBox)
		cBox += ";"
	EndIf
	cBox += Alltrim(aMotCombo[nX,01])+"="+Alltrim(aMotCombo[nX,02])
Next nX

Aadd(aHeadDiv,{""           		/*TITULO*/,"STATUS" 	/*CAMPO*/,"@BMP"               	/*PICTURE*/,02                      /*TAMANHO*/,00                      /*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Orçamento" 			/*TITULO*/,"ORCAMENTO"	/*CAMPO*/,"@!"                 	/*PICTURE*/,Tamsx3("CK_NUM")[01]	/*TAMANHO*/,00						/*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Item"     			/*TITULO*/,"ITEM"		/*CAMPO*/,"@!"                 	/*PICTURE*/,Tamsx3("CK_ITEM")[01]	/*TAMANHO*/,00						/*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Produto"  			/*TITULO*/,"PRODUTO"	/*CAMPO*/,"@!"                 	/*PICTURE*/,Tamsx3("CK_PRODUTO")[01]/*TAMANHO*/,00						/*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Descrição"  		/*TITULO*/,"DESCRICAO"	/*CAMPO*/,"@!"                 	/*PICTURE*/,Tamsx3("B1_DESC")[01]	/*TAMANHO*/,00						/*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Qtd Orçada" 		/*TITULO*/,"QTD_ORCADA" /*CAMPO*/,"@E 9,999,999,999.99"	/*PICTURE*/,Tamsx3("CK_QTDVEN")[01] /*TAMANHO*/,Tamsx3("CK_QTDVEN")[02] /*DECIMAL*/,""  /*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})    
Aadd(aHeadDiv,{"Qtd Efetivada"  	/*TITULO*/,"QTD_EFETIVA"/*CAMPO*/,"@E 9,999,999,999.99" /*PICTURE*/,Tamsx3("CK_QTDVEN")[01] /*TAMANHO*/,Tamsx3("CK_QTDVEN")[02] /*DECIMAL*/,""	/*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
Aadd(aHeadDiv,{"Motivo BackOrder"  	/*TITULO*/,"MOTIVO"		/*CAMPO*/,"@!" 					/*PICTURE*/,Tamsx3("CK_XBKTIP")[01] /*TAMANHO*/,Tamsx3("CK_XBKTIP")[02] /*DECIMAL*/,""	/*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,cBox/*CBOX*/,Nil,Nil,"A"/*VISUAL*/})

For nX:=1 to Len(aDiverge)
	aColsTmp := {}
	aAdd(aColsTmp,LoadBitmap( GetResources(), cImgAviso ))
	aAdd(aColsTmp,aDiverge[nX,01] )
	aAdd(aColsTmp,aDiverge[nX,02] )
	aAdd(aColsTmp,aDiverge[nX,03] )
	aAdd(aColsTmp,Posicione("SB1",1,xFilial("SB1")+aDiverge[nX,03],"B1_DESC"))
	aAdd(aColsTmp,aDiverge[nX,04] )
	aAdd(aColsTmp,aDiverge[nX,05] )
	aAdd(aColsTmp,aDiverge[nX,06] )
	aAdd(aColsTmp,.F. )
	aAdd(aColsDiv,aColsTmp)
Next nX

If Len(aColsDiv)>0
	cTextApres := "Itens do Orçamento "+Alltrim(SCJ->CJ_NUM)+" com digergência entre o cotado e o efetivado."
	If !FindFunction("u__InWizard")
		oWizard := APWizard():New(  "Orçamento em BackOrder",             												 			;   // chTitle  - Titulo do cabecalho
									cTextApres,													         			     			;   // chMsg    - Mensagem do cabecalho
									"BackOrder",       													 			     			;   // cTitle   - Titulo do painel de apresentacao
									"", 		      													 			     			;   // cText    - Texto do painel de apresentacao
									{|| lOk := MsgYesNo("Confirma a Geração do Pedido, ainda que divergente do cotado ?"), lOk },   ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
									{|| lOk := MsgYesNo("Confirma a Geração do Pedido, ainda que divergente do cotado ?"), lOk },   ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
									.T.,             												     			     			;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
									cLogotipo,          												 			     			;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
									{|| },                												 			     			;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
									.F.,                  												 			     			;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
									aCoords		                   										 				 			)   // aCoord   - Array contendo as coordenadas da tela

	Else   	
		oWizard := InWizard():New(  "Orçamento em BackOrder",             												 			;   // chTitle  - Titulo do cabecalho
									cTextApres,													         			     			;   // chMsg    - Mensagem do cabecalho
									"BackOrder",       													 			     			;   // cTitle   - Titulo do painel de apresentacao
									"", 		      													 			     			;   // cText    - Texto do painel de apresentacao
									{|| lOk := MsgYesNo("Confirma a Geração do Pedido, ainda que divergente do cotado ?"), lOk },   ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
									{|| lOk := MsgYesNo("Confirma a Geração do Pedido, ainda que divergente do cotado ?"), lOk },   ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
									.T.,             												     			     			;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
									cLogotipo,          												 			     			;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
									{|| },                												 			     			;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
									.F.,                  												 			     			;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
									aCoords, 	                   										 				 			;   // aCoord   - Array contendo as coordenadas da tela
									NIL,		    																	 			;	// Imagem do Rodape
									"Pedido em BackOrder") 			    												 	 			// Texto da Barra de Apresentação Principal em 3d
	EndIf

	oFolder := TFolder():New(0,0,{ "Itens em BackOrder","Detalhes"},{},oWizard:GetPanel(1),,,, .T., .F.,oWizard:GetPanel(1):NCLIENTWIDTH/2,oWizard:GetPanel(1):NCLIENTHEIGHT/2,,.T.)

	//->> Folder 1
	oBackOrder := MSNewGetDados():New(01,01,((oFolder:ADIALOGS[1]:NHEIGHT/2)),((oFolder:ADIALOGS[1]:NWIDTH/2)),GD_UPDATE,"AllwaysTrue()",.T.,,,,,,,,oFolder:ADIALOGS[1],aHeadDiv,aColsDiv)
	oBackOrder:bChange := {||POSIC_BK := oBackOrder:nAt,oBackOrder:Refresh()}
	oBackOrder:oBrowse:SetBlkBackColor({|| GETDCLR(oBackOrder:nAt,POSIC_BK,nCorSelBK)})	
	oBackOrder:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//->> Folder 2
	oPanel1 := TPanel():New(0,0,'',oFolder:ADIALOGS[2], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(210,210,210),((oFolder:ADIALOGS[2]:NCLIENTWIDTH)/2),(5),.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oFolder:ADIALOGS[2], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(210,210,210),((oFolder:ADIALOGS[2]:NCLIENTWIDTH)/2),((oFolder:ADIALOGS[2]:NCLIENTHEIGHT)/2)-5,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	
	oMotivo := tMultiget():new(03,01, {| u | if( pCount() > 0, cMotivo := u, cMotivo ) },oPanel2,(oPanel2:NCLIENTWIDTH/2)-1,(oPanel2:NCLIENTHEIGHT/2)-15,oFont15,,,,,.T.,,,{|| .T. })
	TSay():New((oPanel2:NCLIENTHEIGHT/2)-10,02, {|| "Detalhes do BackOrder" },oPanel2,,oFont12,,,,.T.,Rgb(50,50,50),CLR_WHITE,80,15)

	oWizard:Activate(.T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
					{|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
					{|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
					{|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

	lRet := lOk
EndIf

If lRet .And. lOk
	nPOrc   := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="ORCAMENTO"	})
	nPItm   := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="ITEM"			})
	nPProd  := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="PRODUTO"		})
	nPDesc  := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="DESCRICAO"	})
	nPQtOr  := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="QTD_ORCADA"	})
	nPQtEf  := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="QTD_EFETIVA"	})
	nPMotiv := Ascan(oBackOrder:aHeader,{|x| Alltrim(x[02])=="MOTIVO"		})
	
	cObs := "Itens do Orçamento: "+SCJ->CJ_NUM+" fora do pedido por Backorder."
	nQtdTracos := Len(cObs)
	cObs += CRLF
	cObs += Replicate("-",nQtdTracos)+CRLF
	For nX:=1 to Len(oBackOrder:aCols)		
		cMotItem:= ""
		If nPMotiv > 0
			cMotItem := Alltrim(oBackOrder:aCols[nX,nPMotiv])
			If !Empty(cMotItem)
				nPos := Ascan(aMotCombo,{|x| Alltrim(x[01])==Alltrim(cMotItem)})
				If nPos > 0
					cMotItem := Alltrim(aMotCombo[nPos,02])
				EndIf
			Else
				cMotItem := "Não Informado"
			EndIf
		EndIf

		cObs += "Item: "+PadR(Alltrim(If(nPItm>0,oBackOrder:aCols[nX,nPItm],"")),Tamsx3("CK_ITEM")[01])+"   "
		cObs += "Produto: "+PadR(Alltrim(If(nPProd>0,oBackOrder:aCols[nX,nPProd],"")),Tamsx3("CK_PRODUTO")[01])+CRLF
		cObs += "Descrição: "+PadR(Alltrim(If(nPDesc>0,oBackOrder:aCols[nX,nPDesc],"")),Tamsx3("B1_DESC")[01])+CRLF	
		cObs += "Qtd Orçada: "+Transform(If(nPQtOr>0,oBackOrder:aCols[nX,nPQtOr],0),PesqPict("SCK","CK_QTDVEN"))+"   "
		cObs += "Qtd Efetivada: "+Transform(If(nPQtEf>0,oBackOrder:aCols[nX,nPQtEf],0),PesqPict("SCK","CK_QTDVEN"))+CRLF
		cObs += "Motivo: "+Alltrim(cMotItem)+CRLF
		cObs += Replicate("-",nQtdTracos)+CRLF
	Next nX

	_cMotivo  := cMotivo
	_cDetalhe := cObs
EndIf

Return lRet

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 13/12/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GETDCLR(nLinha,nSelec,nCor)
Local nCor1 := nCor
Local nRet  := CLR_WHITE

If nLinha == nSelec
	nRet := nCor1
EndIf

Return nRet


