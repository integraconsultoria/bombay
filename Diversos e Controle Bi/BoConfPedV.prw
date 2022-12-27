#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "apwizard.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE ENTER Chr(13)+Chr(10)

Static POSITEMPV 	:= 0
Static nCorPan1		:= Rgb(255,201,14)
Static nPosItenPV   := 0

/*/{protheus.doc} BOConfPedV
*******************************************************************************************
Conferencia do Pedido de Vendas
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOConfPedV()

	Local lVldConf	:= Alltrim(Upper(GetNewPar("BO_CONFPV","S"))) == "S"

	If lVldConf
		GetPV()
	Else
		MsgAlert("Processo de Conferência de Pedidos de Vendas não configurado..."+CRLF+"Vide Parâmetro BO_CONFPV")
	EndIf

Return

/*/{protheus.doc} GetPV
*******************************************************************************************
Retorna os Pedidos de Vendas pendentes de Conferência.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPV()
	Local aDados	:= {{0,"","","","",Stod(""),Stod(""),.F.}}
	Local aBoxParam := {}
	Local cMsg		:= ""
	Local oWizard	:= NIL
	Local aLegenda	:= {}
	Local aMyLegenda:= {}
	Local nCol		:= 5
	Local nLinha    := 0
	Local nColuna   := 0
	Local nX		:= 1
	Local oBtnImp1	:= NIL

	aAdd(aLegenda,{"BR_VERDE"	,"Item Conferido"})
	aAdd(aLegenda,{"BR_AMARELO"	,"Item em Conferência"})
	aAdd(aLegenda,{"BR_VERMELHO","Item não Conferido"})

	Private aRetParam	:= {}
	Private oVermelho 	:= LoadBitmap( GetResources(), "BR_VERMELHO" 	)
	Private oVerde 		:= LoadBitmap( GetResources(), "BR_VERDE"		)
	Private oAmarelo 	:= LoadBitmap( GetResources(), "BR_AMARELO"		)

//->> Marcelo Celi - 25/01/2021
	Private oImpresso 	:= LoadBitmap( GetResources(), "IMPRESSAO"		)
	Private oNoImpresso := LoadBitmap( GetResources(), ""				)

	Private oLbxPV		:= Nil

	cMsg := "Este Recurso Permite Selecionar os Pedidos de Vendas Pendentes de Conferência e Realizá-la, disponibilizando assim o Pedido para Faturamento."+CRLF
	cMsg += CRLF
	cMsg += CRLF
	cMsg += "Avançar para Continuar..."

	AADD( aRetParam, Replicate(" ",Tamsx3("C5_NUM")[01]) 	 )
	AADD( aRetParam, Replicate("Z",Tamsx3("C5_NUM")[01]) 	 )
	AADD( aRetParam, Replicate(" ",Tamsx3("C5_CLIENTE")[01]) )
	AADD( aRetParam, Replicate(" ",Tamsx3("C5_LOJACLI")[01]) )
	AADD( aRetParam, Replicate("Z",Tamsx3("C5_CLIENTE")[01]) )
	AADD( aRetParam, Replicate("Z",Tamsx3("C5_LOJACLI")[01]) )
	AADD( aRetParam, Stod("") )
	AADD( aRetParam, Stod("") )
	AADD( aRetParam, Stod("") )
	AADD( aRetParam, Stod("") )

	AADD( aBoxParam,{1,"Pedido de"		, aRetParam[01]		,""		,""	,""		,".T."	,(Tamsx3("C5_NUM")[01])*4		,.F.})
	AADD( aBoxParam,{1,"Pedido ate"		, aRetParam[02]		,""		,""	,""		,".T."	,(Tamsx3("C5_NUM")[01])*4		,.F.})
	AADD( aBoxParam,{1,"Cliente de"		, aRetParam[03]		,""		,""	,"SA1"	,".T."	,(Tamsx3("C5_CLIENTE")[01])*4	,.F.})
	AADD( aBoxParam,{1,"Loja de"		, aRetParam[04]		,""		,""	,""		,".T."	,(Tamsx3("C5_LOJACLI")[01])*4	,.F.})
	AADD( aBoxParam,{1,"Cliente ate"	, aRetParam[05]		,""		,""	,"SA1"	,".T."	,(Tamsx3("C5_CLIENTE")[01])*4	,.F.})
	AADD( aBoxParam,{1,"Loja ate"		, aRetParam[06]		,""		,""	,""		,".T."	,(Tamsx3("C5_LOJACLI")[01])*4	,.F.})
	AADD( aBoxParam,{1,"Emissão de"		, aRetParam[07]		,""		,""	,""		,".T."	,050							,.F.})
	AADD( aBoxParam,{1,"Emissão ate"	, aRetParam[08]		,""		,""	,""		,".T."	,050							,.F.})
	AADD( aBoxParam,{1,"Liberação de"	, aRetParam[09]		,""		,""	,""		,".T."	,050							,.F.})
	AADD( aBoxParam,{1,"Liberação ate"	, aRetParam[10]		,""		,""	,""		,".T."	,050							,.F.})

	DEFINE WIZARD oWizard 												;
		TITLE "Pedidos de Vendas"									;
		HEADER "Conferência Física"								;
		MESSAGE ""												;
		TEXT cMsg PANEL											;
	NEXT 	{|| .T. } 										;
	FINISH 	{|| .T. }										;

CREATE PANEL oWizard 				 							;
	HEADER "Conferência Física"						 		;
	MESSAGE "Informe os Dados para Filtrar os Pedidos Pendentes de Conferência." PANEL			;
	NEXT 	{|| FilPedidos(aRetParam,@aDados) }				;
	FINISH 	{|| FilPedidos(aRetParam,@aDados) }				;
	PANEL
Parambox(aBoxParam,"Parametrização",@aRetParam,,,,,,oWizard:GetPanel(2),,.F.,.F.)

CREATE PANEL oWizard HEADER "Conferência Física";
	MESSAGE "Selecione o Pedido para Efetuar a Conferência." PANEL;
	BACK 	{|| .F. };
	NEXT 	{|| .F. };
	FINISH 	{|| .T. };
	EXEC 	{|| oWizard:OCANCEL:LVISIBLECONTROL := .F., oWizard:OBACK:LVISIBLECONTROL := .F. }

@ 000, 000 LISTBOX oLbxPV FIELDS HEADER 	""								,;
	""								,;
	SC5->(RetTitle("C5_NUM"))		,;
	SC5->(RetTitle("C5_CLIENTE"))	,;
	SC5->(RetTitle("C5_LOJACLI"))	,;
	SA1->(RetTitle("A1_NOME"))		,;
	SA1->(RetTitle("A1_NOME"))		,;  // Flavio - Total do pedido
SC5->(RetTitle("C5_EMISSAO"))	,;
	SC6->(RetTitle("C6_ENTREG"))	;
	COLSIZES 	5								,;
	5	 							,;
	Tamsx3("C5_NUM")[01]		+10	,;
	Tamsx3("C5_CLIENTE")[01]	+10	,;
	Tamsx3("C5_LOJACLI")[01]	+10	,;
	Tamsx3("A1_NOME")[01]		-20	,;
	Tamsx3("C5_LOJACLI")[01]	+10	,;  // Flavio  - Total do pedido
Tamsx3("C5_EMISSAO")[01]	+10	,;
	Tamsx3("C6_ENTREG")[01]		+10	;
	SIZE (oWizard:GetPanel(3):NWIDTH/2)-2,(oWizard:GetPanel(3):NHEIGHT/2)-20;
	ON DBLCLICK ( aDados[oLbxPV:nAt,1] := ConferePV(aDados[oLbxPV:nAt,2]),oLbxPV:Refresh() ) OF oWizard:GetPanel(3) PIXEL

oLbxPV:SetArray(aDados)
oLbxPV:bLine := {|| {If(aDados[oLbxPV:nAt,1]==1,oVerde,If(aDados[oLbxPV:nAt,1]==2,oAmarelo,oVermelho)),If(aDados[oLbxPV:nAt,8],oImpresso,oNoImpresso),aDados[oLbxPV:nAt,2],aDados[oLbxPV:nAt,3],aDados[oLbxPV:nAt,4],aDados[oLbxPV:nAt,5],aDados[oLbxPV:nAt,6],aDados[oLbxPV:nAt,7]}}

//->> Legenda Macro
nCol := 5
For nX:=1 to Len(aLegenda)
	aAdd(aMyLegenda,{	TBitmap():New((oWizard:GetPanel(3):NHEIGHT/2)-15,01,15,15,,,.T.,oWizard:GetPanel(3),{|| },,.T.,.F.,,,.F.,,.T.,,.F.),;
		TSay():New((oWizard:GetPanel(3):NHEIGHT/2)-15,01, {|| " " }, oWizard:GetPanel(3),,oWizard:oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20)})

	aMyLegenda[Len(aMyLegenda)][1]:NLEFT 	:= nCol
	aMyLegenda[Len(aMyLegenda)][1]:CRESNAME := aLegenda[nX,01]
	aMyLegenda[Len(aMyLegenda)][1]:Refresh()

	aMyLegenda[Len(aMyLegenda)][2]:NLEFT 	:= nCol + 20
	aMyLegenda[Len(aMyLegenda)][2]:SetText(aLegenda[nX,02])
	aMyLegenda[Len(aMyLegenda)][2]:CtrlRefresh()

	nCol += (Len(aLegenda[nX,02])*7)+20
Next nX

nLinha  := (oWizard:GetPanel(3):NHEIGHT)-47
nColuna := (oWizard:GetPanel(3):NWIDTH) -50

If SC5->(FieldPos("C5_XIMPRPV"))>0
	oBtnImp1 := TBtnBmp2():New(nLinha,nColuna-20, 50,50,'IMPRESSAO' ,,,,{||PVImpresso(aDados[oLbxPV:nAt,2],@aDados)},oWizard:GetPanel(3),"Pedido Impresso",,.T. )
EndIf

oWizard:OFINISH:CCAPTION := "&Fechar"
oWizard:OFINISH:CTITLE 	 := "&Fechar"


ACTIVATE WIZARD oWizard CENTERED

Return

/*/{protheus.doc} FilPedidos
*******************************************************************************************
Seleciona os Pedidos de Vendas Pendentes de Conferência.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function FilPedidos(aRetParam,aDados)
	Local lRet 		:= .T.
	Local cQuery	:= ""
	Local cAlias	:= Criatrab(NIL,.F.)
	Local lImpresso	:= .F.

	aDados := {}

	cQuery := "SELECT DISTINCT"																	 									+CRLF
	cQuery += "			SC5.C5_FILIAL,"															 									+CRLF
	cQuery += "			SC5.C5_NUM,"															   									+CRLF
	cQuery += "			SC5.C5_CLIENTE,"														   									+CRLF
	cQuery += "			SC5.C5_LOJACLI,"														   									+CRLF
	cQuery += "			SA1.A1_NOME,"																								+CRLF
	cQuery += "			SC5.C5_EMISSAO,"																							+CRLF

	If SC5->(FieldPos("C5_XIMPRPV"))>0
		cQuery += "		SC5.C5_XIMPRPV 	AS IMPRESSO"																				+CRLF
	Else
		cQuery += "		'N' 			AS IMPRESSO"																				+CRLF
	EndIf

	cQuery += "	FROM "+RetSqlName("SC5")+" SC5 (NOLOCK)"										 									+CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									 									+CRLF
	cQuery += "				ON  SA1.A1_FILIAL 	= '"+xFilial("SA1")+"'"							 									+CRLF
	cQuery += "				AND SA1.A1_COD    	=  SC5.C5_CLIENTE"								  									+CRLF
	cQuery += "				AND SA1.A1_LOJA   	=  SC5.C5_LOJACLI"								   									+CRLF
	cQuery += "				AND SA1.D_E_L_E_T_  =  ' '"																				+CRLF
	cQuery += "	WHERE 	SC5.C5_FILIAL 	= '"+xFilial("SC5")+"'"																		+CRLF
	cQuery += "		AND	SC5.C5_NUM 		BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"		 								+CRLF
	cQuery += "		AND	SC5.C5_CLIENTE 	BETWEEN '"+aRetParam[03]+"' AND '"+aRetParam[05]+"'"		   								+CRLF
	cQuery += "		AND	SC5.C5_LOJACLI 	BETWEEN '"+aRetParam[04]+"' AND '"+aRetParam[06]+"'"		   								+CRLF

//->> Marcelo Celi - 19/01/2021
	If SC5->(FieldPos("C5_XFLUXCF")) > 0
		cQuery += "	AND	SC5.C5_XFLUXCF 	<> 'N'"																						+CRLF
	EndIf

//->> Marcelo Celi - 23/12/2020
	If !Empty(aRetParam[08])
		cQuery += "		AND	SC5.C5_EMISSAO 	BETWEEN '"+Dtos(aRetParam[07])+"' AND '"+dTos(aRetParam[08])+"'"						+CRLF
	ElseIf !Empty(aRetParam[07])
		cQuery += "		AND	SC5.C5_EMISSAO 	= '"+Dtos(aRetParam[07])+"'"															+CRLF
	EndIf

	cQuery += "		AND EXISTS (SELECT 	SC6.C6_FILIAL,"													 							+CRLF
	cQuery += "							SC6.C6_NUM,"													 							+CRLF
	cQuery += "							SC6.C6_PRODUTO,"																			+CRLF
	cQuery += "							SC6.C6_ITEM,"																				+CRLF
	cQuery += "							SC6.C6_QTDVEN"																				+CRLF
	cQuery += "						FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"														+CRLF
	cQuery += "						INNER JOIN "+RetSqlName("SC9")+" SC9 (NOLOCK)"													+CRLF
	cQuery += "								ON 	SC9.C9_FILIAL 	= SC6.C6_FILIAL"													+CRLF
	cQuery += "								AND SC9.C9_PEDIDO	= SC6.C6_NUM"														+CRLF
	cQuery += "								AND SC9.C9_ITEM		= SC6.C6_ITEM"														+CRLF
	cQuery += "								AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO"													+CRLF

//->> Marcelo Celi - 23/12/2020
	If !Empty(aRetParam[10])
		cQuery += "								AND	SC9.C9_DATALIB 	BETWEEN '"+Dtos(aRetParam[09])+"' AND '"+dTos(aRetParam[10])+"'"+CRLF
	ElseIf !Empty(aRetParam[09])
		cQuery += "								AND	SC9.C9_DATALIB 	= '"+Dtos(aRetParam[09])+"'"									+CRLF
	EndIf

	cQuery += " 							AND SC9.C9_BLCRED	= '"+Space(Tamsx3("C9_BLCRED")[01])+"'"	  							+CRLF
	cQuery += " 							AND SC9.C9_BLEST	= '"+Space(Tamsx3("C9_BLEST") [01])+"'"								+CRLF
	cQuery += " 							AND SC9.C9_BLWMS 	IN('  ','05','06','07') "			  								+CRLF
	cQuery += "			   					AND SC9.D_E_L_E_T_  =  ' '"							 									+CRLF
	cQuery += "						WHERE 	SC6.C6_FILIAL 	= SC5.C5_FILIAL"					 									+CRLF
	cQuery += "							AND SC6.C6_NUM 		= SC5.C5_NUM"															+CRLF
	cQuery += "							AND SC6.C6_QTDVEN 	<> SC6.C6_XQTCONF"														+CRLF
	cQuery += "			   				AND SC6.D_E_L_E_T_  =  ' '"																	+CRLF
	cQuery += "					)"																									+CRLF
	cQuery += "		AND SC5.D_E_L_E_T_  =  ' '"																						+CRLF
	cQuery += " ORDER BY SC5.C5_NUM"																								+CRLF

	MsgRun("Filtrando Pedidos...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })

	Do While (cAlias)->(!Eof())
		If (cAlias)->IMPRESSO == "S"
			lImpresso := .T.
		Else
			lImpresso := .F.
		EndIf

		aAdd(aDados,{	u_BOGetSitPV((cAlias)->C5_NUM),; 							// 01 - Situação do Pedido
		(cAlias)->C5_NUM			,; 								// 02 - Codigo do Pedido de Vendas
		(cAlias)->C5_CLIENTE		,; 								// 03 - Codigo do Cliente
		(cAlias)->C5_LOJACLI		,; 								// 04 - Loja do Cliente
		(cAlias)->A1_NOME			,; 								// 05 - Nome do Cliente
		Stod((cAlias)->C5_EMISSAO)	,; 								// 06 - Data de Emissão do Pedido de Vendas
		GetDtEntreg((cAlias)->C5_NUM,Stod((cAlias)->C5_EMISSAO)),;	// 07 - Data de Entrega
		lImpresso					})								// 08 - se Impresso

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

//->> Marcelo Celi - 05/01/2020 - Colocar em Ordem de Data de Entrega
	aDados := aSort(aDados,,,{|x,y| x[07] < y[07] })

	If Len(aDados)==0
		lRet := .F.
		MsgAlert("Não foram encontrados pedidos a conferir no filtro informado.")
		aDados	:= {{0,"","","","",Stod(""),Stod(""),.F.}}
	EndIf

	oLbxPV:SetArray(aDados)
	oLbxPV:bLine := {|| {If(aDados[oLbxPV:nAt,1]==1,oVerde,If(aDados[oLbxPV:nAt,1]==2,oAmarelo,oVermelho)),If(aDados[oLbxPV:nAt,8],oImpresso,oNoImpresso),aDados[oLbxPV:nAt,2],aDados[oLbxPV:nAt,3],aDados[oLbxPV:nAt,4],aDados[oLbxPV:nAt,5],aDados[oLbxPV:nAt,6],aDados[oLbxPV:nAt,7]}}
	oLbxPV:Refresh()

Return lRet

/*/{protheus.doc} ConferePV
*******************************************************************************************
Confere o Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConferePV(cNumero)
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cNumero))
		If SC5->C5_XSTATUS <= "3" // Pendente de separacao
			//->> MarceloCeli - 23/12/2020
			Begin Transaction
				u_BOManCnfPV("SC5",SC5->(Recno()),4)
			End Transaction
		Else
			MsgAlert("Pedido não encontra-se pendente de liberação, portando a operação a seguir está disponível apenas para visualização.")
			u_BOManCnfPV("SC5",SC5->(Recno()),2)
		EndIf
	Else
		MsgAlert("Pedido de Vendas não Localizado...")
	EndIf
Return u_BOGetSitPV(cNumero)

/*/{protheus.doc} GetVlrPedid
*******************************************************************************************
Retorna o valor do pedido
 
@author: Marcelo Celi Marques
@since: 16/02/2021
@param: 
@return:
@type function: Statico
*******************************************************************************************
/*/
Static Function GetVlrPedid()
	Local aArea     := GetArea()
	Local aAreaSC5  := SC5->(GetArea())
	Local aAreaSC6  := SC6->(GetArea())
	Local nValor    := 0

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(SC5->(C5_FILIAL + C5_NUM)))
	Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
		nValor += SC6->C6_VALOR
		SC6->(dbSkip())
	EndDo

	SC6->(RestArea(aAreaSC6))
	SC5->(RestArea(aAreaSC5))
	RestArea(aArea)

Return nValor




/*/{protheus.doc} BOManCnfPV
*******************************************************************************************
Faz a Manutenção da Conferencia do Pedido.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOManCnfPV(cAlias,nReg,nOpc)
	Local oDlg, oPanel, oPanS1, oPanC1, oPanC2, oPanI1, oPanI2, oTPanI1A, oTPanS1A, oFontGrd, oTimer
	Local aSize	   		:= MsAdvSize()
	Local nOpcA			:= 0
	Local aButtons		:= {}
	Local aHeader		:= {}
	Local aCols			:= {}
	Local aMyLegenda	:= {}
	Local aLegenda		:= {}
	Local nX			:= 1
	Local nY			:= 1
	Local nCol			:= 5
	Local oNumero		:= NIL
	Local oEmissao		:= NIL
	Local aPedido		:= {}
	Local nPos			:= 0
	Local nQtdSep		:= 0
	Local cEspecies		:= Alltrim(GetNewPar("BO_ESPCVDA","VOLUMES;FARDOS;SACOLAS"))
	Local aEspecies		:= STRTOKARR(cEspecies,";")
	local lTudoConf		:= .T.
	Local lSugQtde  	:= GetNewPar("BO_SUGQTDC","N")=="S"
	nvalor := GetVlrPedid()

	DEFINE FONT oFontGrd NAME "Arial" SIZE 0, -28

	Private oItensPV	:= NIL
	Private nP_LEGENDA 	:= 0
	Private nP_ITEM 	:= 0
	Private nP_PRODUTO 	:= 0
	Private nP_UM 		:= 0
	Private nP_LOCAL	:= 0
	Private nP_DESCRIC	:= 0
	Private nP_QTDVEN 	:= 0
	Private nP_QTDCONF 	:= 0
	Private nP_CODBAR	:= 0
	Private nP_FALTA	:= 0
	Private nP_STATCONF := 0
	Private nP_DELETE	:= 0

	Private oBarras		:= NIL
	Private oQtde		:= NIL
	Private oQtdConf	:= NIL
	Private oUnidade	:= NIL
	Private oTempConf	:= NIL
	Private oUserConf	:= NIL
	Private oNmUsrResp	:= NIL
	Private oPesol		:= NIL
	Private oPbruto		:= NIL
	Private oVolume		:= NIL
	Private oEmbalador	:= NIL

	Private cBarras		:= Space(Tamsx3("B1_CODBAR")[01])
	Private nQtde		:= 0
	Private nQtdConf	:= 0
	Private cUnidade	:= Space(Tamsx3("C6_UM")[01])
	Private cTempConf	:= If(Empty(SC5->C5_XTECONF),"00:00:00" ,SC5->C5_XTECONF)
	Private cUserConf	:= If(Empty(SC5->C5_XUSCONF),RetCodUsr(),SC5->C5_XUSCONF)
	Private cNmUsrResp	:= UsrRetName(cUserConf)
	Private nPesol		:= SC5->C5_PESOL
	Private nPbruto		:= SC5->C5_PBRUTO
	Private nVolume		:= SC5->C5_VOLUME1
	Private cEmbalador  := If(SC5->(FieldPos("C5_XUSEMBA"))>0,SC5->C5_XUSEMBA,"")
	Private cEspSel		:= SC5->C5_ESPECI1

//->> Marcelo Celi - 23/12/2020
	Private nCubagem	:= If(SC5->(FieldPos("C5_XCUBAGE"))>0,SC5->C5_XCUBAGE,0)
	Private oCubagem	:= NIL

	If !VlPedNaConf(SC5->C5_NUM)
		MsgAlert("Pedido não encontra-se totalmente liberado em credito e estoque para a realização da conferência.")
	Else
		If !lSugQtde
			nQtde := 1
		EndIf

		aHeader	:= GetaHeader(nOpc)
		aCols	:= GetaCols(aHeader)

		aAdd(aLegenda,{"BR_VERDE"	,"Item Conferido"})
		aAdd(aLegenda,{"BR_AMARELO"	,"Item em Conferência"})
		aAdd(aLegenda,{"BR_VERMELHO","Item não Conferido"})

		Define MsDialog oDlg From 00,00 To aSize[6],aSize[5] Title "Agendamentos de Pedidos de Compras" Pixel Of oDlg
		oDlg:lMaximized:= .T.

		//->> Painel Principal
		oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oDlg:NWIDTH)/2,((oDlg:NHEIGHT)/2)-45,.F.,.F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		//->> Painel Superior
		oPanS1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanel:NWIDTH)/2,40,.F.,.T. )
		oPanS1:Align := CONTROL_ALIGN_TOP

		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))

		@ 005,010 MSGet oNumero Var SC5->C5_NUM 		When .F.	SIZE  65,20 FONT oFontGrd	Picture PesqPict("SC5","C5_NUM")		OF oPanS1 PIXEL Hasbutton
		@ 029,010 Say SC5->(RetTitle("C5_NUM"))													  										OF oPanS1 PIXEL

		@ 005,085 MSGet oEmissao Var SC5->C5_EMISSAO 	When .F.	SIZE  50,09 				Picture PesqPict("SC5","C5_EMISSAO")	OF oPanS1 PIXEL Hasbutton
		@ 018,085 Say SC5->(RetTitle("C5_EMISSAO"))													  									OF oPanS1 PIXEL

		@ 005,140 MSGet oEmissao Var SC5->C5_CLIENTE 	When .F.	SIZE  50,09 				Picture PesqPict("SC5","C5_CLIENTE")	OF oPanS1 PIXEL Hasbutton
		@ 018,140 Say SC5->(RetTitle("C5_CLIENTE"))													  									OF oPanS1 PIXEL

		@ 005,195 MSGet oEmissao Var SC5->C5_LOJACLI 	When .F.	SIZE  20,09 				Picture PesqPict("SC5","C5_LOJACLI")	OF oPanS1 PIXEL Hasbutton
		@ 018,195 Say SC5->(RetTitle("C5_LOJACLI"))													  									OF oPanS1 PIXEL

		@ 005,220 MSGet oEmissao Var SA1->A1_NOME 		When .F.	SIZE 240,09 				Picture PesqPict("SA1","A1_NOME")		OF oPanS1 PIXEL Hasbutton
		@ 018,220 Say SA1->(RetTitle("A1_NOME"))													  									OF oPanS1 PIXEL

		@ 005,480 MSGet oEmissao Var nvalor 		When .F.	SIZE  90,09   Picture "@E 9,999,999,999.99"                         OF oPanS1 PIXEL Hasbutton
		@ 018,480 Say SC6->(RetTitle("C6_VALOR"))													  									OF oPanS1 PIXEL

		//->> Painel Central
		oPanC1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanel:NWIDTH)/2,((oPanel:NHEIGHT)/2-140),.F.,.F. )
		oPanC1:Align := CONTROL_ALIGN_TOP

		oPanC1A := TPanel():New(0,0,'',oPanC1, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanC1:NWIDTH)/2,((oPanC1:NHEIGHT)/2),.F.,.F. )
		oPanC1A:Align := CONTROL_ALIGN_ALLCLIENT

		oTPanS1A := TToolBox():New(00,00,oPanC1,(oPanC1:NWIDTH/2),(oPanC1:NHEIGHT/2))
		oTPanS1A:AddGroup( oPanC1A , "Itens do Pedido de Vendas" )

		oItensPV := MSNewGetDados():New(00,00,((oPanC1A:NHEIGHT)/2),((oPanC1A:NWIDTH)/2),2,.T.,.T.,,,,,,,,oPanC1A,aHeader,aCols)
		oItensPV:bChange := {||POSITEMPV := oItensPV:nAt,oItensPV:Refresh()}
		oItensPV:oBrowse:SetBlkBackColor({|| GETDCLR(oItensPV:nAt,POSITEMPV,nCorPan1)})
		oItensPV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		oPanC2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanel:NWIDTH)/2,25,.F.,.T. )
		oPanC2:Align := CONTROL_ALIGN_TOP

		//->> Legenda Macro
		nCol := 5
		For nX:=1 to Len(aLegenda)
			aAdd(aMyLegenda,{	TBitmap():New(03,01,15,15,,,.T.,oPanC2,{|| },,.T.,.F.,,,.F.,,.T.,,.F.),;
				TSay():New(03,01, {|| " " }, oPanC2,,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20)})

			aMyLegenda[Len(aMyLegenda)][1]:NLEFT 	:= nCol
			aMyLegenda[Len(aMyLegenda)][1]:CRESNAME := aLegenda[nX,01]
			aMyLegenda[Len(aMyLegenda)][1]:Refresh()

			aMyLegenda[Len(aMyLegenda)][2]:NLEFT 	:= nCol + 20
			aMyLegenda[Len(aMyLegenda)][2]:SetText(aLegenda[nX,02])
			aMyLegenda[Len(aMyLegenda)][2]:CtrlRefresh()

			nCol += (Len(aLegenda[nX,02])*7)+20
		Next nX

		//->> Marcelo Celi - 23/12/2020
		@ 003,(oPanC2:NWIDTH/2)-315 MSGet oCubagem 	Var nCubagem When SC5->(FieldPos("C5_XCUBAGE"))>0	SIZE  50,12 Picture "@E 99,999,999.99"	OF oPanC2 PIXEL Hasbutton
		@ 017,(oPanC2:NWIDTH/2)-315 Say "Cubagem"																		  						OF oPanC2 PIXEL

		@ 003,(oPanC2:NWIDTH/2)-260 COMBOBOX cEspSel SIZE 60,12  PIXEL OF oPanC2 ITEMS aEspecies
		@ 017,(oPanC2:NWIDTH/2)-260 Say SC5->(RetTitle("C5_ESPECI1"))													  								OF oPanC2 PIXEL

		@ 003,(oPanC2:NWIDTH/2)-190 MSGet oVolume 	Var nVolume When .T.	SIZE  50,12 Picture PesqPict("SC5","C5_VOLUME1")							OF oPanC2 PIXEL Hasbutton
		@ 017,(oPanC2:NWIDTH/2)-190 Say SC5->(RetTitle("C5_VOLUME1"))													  								OF oPanC2 PIXEL

		@ 003,(oPanC2:NWIDTH/2)-130 MSGet oPbruto 	Var nPbruto When .T.	SIZE  50,12 Picture PesqPict("SC5","C5_PBRUTO")								OF oPanC2 PIXEL Hasbutton
		@ 017,(oPanC2:NWIDTH/2)-130 Say SC5->(RetTitle("C5_PBRUTO"))													  								OF oPanC2 PIXEL

		@ 003,(oPanC2:NWIDTH/2)-70  MSGet oPesol 	Var nPesol 	When .T.	SIZE  50,12 Picture PesqPict("SC5","C5_PESOL")								OF oPanC2 PIXEL Hasbutton
		@ 017,(oPanC2:NWIDTH/2)-70 	Say SC5->(RetTitle("C5_PESOL"))													  									OF oPanC2 PIXEL

		//->> Painel Inferior
		oPanI1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanel:NWIDTH)/2,50,.F.,.F. )
		oPanI1:Align := CONTROL_ALIGN_ALLCLIENT

		oPanI1A := TPanel():New(0,0,'',oPanI1, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanI1:NWIDTH)/2,((oPanI1:NHEIGHT)/2),.F.,.F. )
		oPanI1A:Align := CONTROL_ALIGN_ALLCLIENT

		oTPanI1A := TToolBox():New(00,00,oPanI1,(oPanI1:NWIDTH/2),(oPanI1:NHEIGHT/2))
		oTPanI1A:AddGroup( oPanI1A , "Conferência do Pedido de Vendas" )

		@ 005,010 MSGet oBarras Var cBarras 	   						When (nOpc <> 2) SIZE  (oPanI1A:NWIDTH/2)-280,20 FONT oFontGrd	Picture PesqPict("SB1","B1_CODBAR")		OF oPanI1A PIXEL Hasbutton Valid u_BOVlCpConf()
		@ 029,010 Say SB1->(RetTitle("B1_CODBAR"))													  																			OF oPanI1A PIXEL

		@ 005,(oPanI1A:NWIDTH/2)-262 MSGet oQtdConf 	Var nQtdConf 	When .F.	SIZE  90,20 FONT oFontGrd						Picture PesqPict("SC6","C6_XQTCONF")		OF oPanI1A PIXEL Hasbutton
		@ 029,(oPanI1A:NWIDTH/2)-262 Say SC6->(RetTitle("C6_XQTCONF"))													  														OF oPanI1A PIXEL

		@ 005,(oPanI1A:NWIDTH/2)-160 MSGet oQtde 	Var nQtde 			When (nOpc <> 2 .And. lSugQtde)	SIZE  90,20 FONT oFontGrd						Picture PesqPict("SC6","C6_QTDVEN")			OF oPanI1A PIXEL Hasbutton Valid u_BOVlCpConf()
		@ 029,(oPanI1A:NWIDTH/2)-160 Say SC6->(RetTitle("C6_QTDVEN"))													  														OF oPanI1A PIXEL

		@ 005,(oPanI1A:NWIDTH/2)-58 MSGet oUnidade 	Var cUnidade 		When .F.	SIZE  48,20 FONT oFontGrd						Picture PesqPict("SC6","C6_UM")				OF oPanI1A PIXEL Hasbutton
		@ 029,(oPanI1A:NWIDTH/2)-58 Say SC6->(RetTitle("C6_UM"))													  															OF oPanI1A PIXEL

		oPanI2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),(oPanel:NWIDTH)/2,25,.F.,.T. )
		oPanI2:Align := CONTROL_ALIGN_BOTTOM

		@ 003,05  					MSGet oEmbalador 	Var cEmbalador 		When (SC5->(FieldPos("C5_XUSEMBA"))>0 .And. (nOpc <> 2))  SIZE 150,12 		Picture PesqPict("SC5","C5_XUSEMBA")		OF oPanI2 PIXEL Hasbutton
		@ 017,05 					Say "Separador/Embalador"													  																OF oPanI2 PIXEL

		@ 003,(oPanI2:NWIDTH/2)-32  MSGet oTempConf 	Var cTempConf 		When .F.	SIZE  18,12 																			OF oPanI2 PIXEL Hasbutton
		@ 003,(oPanI2:NWIDTH/2)-133 MSGet oNmUsrResp 	Var cNmUsrResp 		When .F.	SIZE 100,12 																			OF oPanI2 PIXEL Hasbutton
		@ 003,(oPanI2:NWIDTH/2)-163 MSGet oUserConf 	Var cUserConf 		When .F.	SIZE  30,12 																			OF oPanI2 PIXEL Hasbutton
		@ 017,(oPanI2:NWIDTH/2)-163 Say "Conferente"													  																		OF oPanI2 PIXEL

		If nOpc == 4
			oTimer := TTimer():New(1000, {|| AtualTempo() }, oDLG )
			oTimer:Activate()
		EndIf

		oBarras:setfocus()

		Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| If(TudoOk(nOpc,1),(nOpcA := 1, oDlg:End()),.T.)},;
			{|| If(TudoOk(nOpc,0),(nOpcA := 0, oDlg:End()),.T.)},;
			,aButtons)

		If nOpc == 4 .And. nOpcA == 1
			aPedido := GetPedido(oItensPV:aCols,SC5->C5_NUM)
			For nX:=1 to Len(oItensPV:aCols)
				//->> Marcelo Celi - 23/12/2020
				//nPos := Ascan(aPedido,{|x| x[2]==oItensPV:aCols[nX][nP_PRODUTO]})
				nPos := Ascan(aPedido,{|x| Alltrim(x[2])==Alltrim(oItensPV:aCols[nX][nP_PRODUTO])})

				//->> Marcelo Celi - 23/12/2020
				If nPos > 0
					For nY := nPos to Len(aPedido)
						//->> Marcelo Celi - 23/12/2020
						//If aPedido[nY][2] == oItensPV:aCols[nX][nP_PRODUTO]
						If Alltrim(aPedido[nY][2]) == Alltrim(oItensPV:aCols[nX][nP_PRODUTO])
							nQtdSep := 0
							If oItensPV:aCols[nX][nP_QTDCONF] > aPedido[nY][4]
								nQtdSep := aPedido[nY][4]
								oItensPV:aCols[nX][nP_QTDCONF] -= nQtdSep
								aPedido[nY][5] := nQtdSep
							Else
								nQtdSep := oItensPV:aCols[nX][nP_QTDCONF]
								oItensPV:aCols[nX][nP_QTDCONF] -= nQtdSep
								aPedido[nY][5] := nQtdSep
							EndIf
						Else
							Exit
						EndIf
					Next nY
				EndIf
			Next nX

			//->> Marcelo Celi - 23/12/2020
			For nX:=1 to Len(aPedido)
				SC6->(dbGoto(aPedido[nX][01]))
				Reclock("SC6",.F.)
				SC6->C6_XQTCONF := 0
				SC6->C6_XDTCONF	:= Stod("")
				SC6->(MsUnlock())
			Next nX

			For nX:=1 to Len(aPedido)
				SC6->(dbGoto(aPedido[nX][01]))
				Reclock("SC6",.F.)
				//->> Marcelo Celi - 23/12/2020
				//SC6->C6_XQTCONF := aPedido[nX][05]
				SC6->C6_XQTCONF += aPedido[nX][05]
				SC6->C6_XDTCONF	:= Date()
				SC6->(MsUnlock())

				If lTudoConf
					If SC6->C6_XQTCONF <> SC6->C6_QTDVEN
						lTudoConf := .F.
					EndIf
				EndIf

				Reclock("SC5",.F.)
				SC5->C5_XUSCONF := cUserConf
				SC5->C5_PESOL   := nPesol
				SC5->C5_PBRUTO  := nPbruto
				SC5->C5_VOLUME1 := nVolume
				SC5->C5_ESPECI1 := cEspSel

				//->> Marcelo Celi - 23/12/2020
				If SC5->(FieldPos("C5_XCUBAGE"))>0
					SC5->C5_XCUBAGE := nCubagem
				EndIf

				If SC5->(FieldPos("C5_XUSEMBA"))>0
					SC5->C5_XUSEMBA := cEmbalador
				EndIf

				SC5->(MsUnlock())
			Next nX

			//->> Marcelo Celi - 04/01/2020
			lTudoConf := .T.
			SC6->(dbSetOrder(1))
			SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
			Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
				If SC6->C6_XQTCONF <> SC6->C6_QTDVEN
					lTudoConf := .F.
					Exit
				EndIf
				SC6->(dbSkip())
			EndDo

			//->> Tudo Conferido e deve passar de estagio
			If lTudoConf
				If Alltrim(SC5->C5_XSTATUS) < "4"
					Reclock("SC5",.F.)
					SC5->C5_XSTATUS := "4" // Pendencia de Logistico
					SC5->(MsUnlock())
				EndIf
			Else
				//->> Marcelo Celi - 04/01/2021
				If Alltrim(SC5->C5_XSTATUS) >= "2"
					Reclock("SC5",.F.)
					SC5->C5_XSTATUS := "3" // Pendencia de Separação
					SC5->(MsUnlock())
				EndIf
			EndIf
		EndIf

		//->> Grava o tempo que foi utilizado, mesmo que não salve.
		If nOpc == 4
			Reclock("SC5",.F.)
			SC5->C5_XTECONF := cTempConf
			SC5->(MsUnlock())
		EndIf
	EndIf

Return

/*/{protheus.doc} TudoOk
*******************************************************************************************
Faz a Validação da Conferencia.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoOk(nOpc,nOpcA)
	Local lRet := .T.

	If nOpc == 4
		Do Case
		Case nOpcA == 1
			lRet := lRet .And. MsgYesNo("Confirma a Conferência Realizada ?")

		Case nOpcA == 0
			lRet := MsgYesNo("Confirma o Abandono da Conferência ?")

		EndCase
	EndIf

Return lRet

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
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

/*/{protheus.doc} GetaHeader
*******************************************************************************************
Retorna o aHeader
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaHeader(nOpc)
	Local aCpos 	:= {}
	Local nX		:= 1
	Local aHeader 	:= {}

	aAdd(aCpos,{"C6_PRODUTO"	,"V",""})
	aAdd(aCpos,{"C6_UM"			,"V",""})
	aAdd(aCpos,{"C6_QTDVEN"		,"V",""})
	aAdd(aCpos,{"C6_XQTCONF"	,If(nOpc==4,"A","V"),"u_BOVlCpConf()"})
	aAdd(aCpos,{"B1_CODBAR"		,"V",""})
	aAdd(aCpos,{"B1_DESC"		,"V",""})

	aAdd(aHeader,{ "","LEGENDA","@BMP",2,0,/*VALIDACAO*/,,"C",,"V",,,,"V"} )

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX:=1 to Len(aCpos)
		If SX3->(dbSeek(Alltrim(aCpos[nX][01])))
			Aadd(aHeader,{	TRIM(SX3->X3_TITULO)				,;
				TRIM(SX3->X3_CAMPO)					,;
				SX3->X3_PICTURE				,;
				SX3->X3_TAMANHO				,;
				SX3->X3_DECIMAL				,;
				aCpos[nX][03]					,;
				SX3->X3_USADO					,;
				SX3->X3_TIPO					,;
				SX3->X3_F3						,;
				SX3->X3_CONTEXT 				,;
				SX3->X3_CBOX 					,;
				Nil			 				,;
				Nil			 				,;
				aCpos[nX][02]					;
				})

			If Upper(Alltrim(SX3->X3_CAMPO)) == "C6_XQTCONF"
				aAdd(aHeader,{ "Qtd Falta","FALTA",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*VALIDACAO*/,,"C",,"V",,,,"V"} )
			EndIf

		EndIf
	Next nX

	nP_LEGENDA 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("LEGENDA"))		})
	nP_PRODUTO 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("C6_PRODUTO"))	})
	nP_UM 		:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("C6_UM"))		})
	nP_DESCRIC	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("B1_DESC"))		})
	nP_QTDVEN 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("C6_QTDVEN")) 	})
	nP_QTDCONF 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("C6_XQTCONF")) 	})
	nP_CODBAR 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("B1_CODBAR")) 	})
	nP_FALTA 	:= Ascan(aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("FALTA"))	 	})
	nP_STATCONF := Len(aHeader)+1
	nP_DELETE	:= Len(aHeader)+2

Return aHeader

/*/{protheus.doc} GetaCols
*******************************************************************************************
Retorna o GetaCols dos itens.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaCols(aHeader)
	Local aCols 	:= {}
	Local aColsTmp  := {}
	Local nX		:= 1
	Local nPos		:= 0
	Local cCDBarras	:= ""

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
	Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
		nPos := Ascan(aCols,{|x| x[nP_PRODUTO]== SC6->C6_PRODUTO })
		If nPos > 0
			aCols[nPos][nP_QTDVEN]  += SC6->C6_QTDVEN
			aCols[nPos][nP_QTDCONF] += SC6->C6_XQTCONF
			aCols[nPos][nP_FALTA] 	+= SC6->(C6_QTDVEN-C6_XQTCONF)
		Else
			aColsTmp := Array(Len(aHeader)+2)

			SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
			cCDBarras := Posicione("SLK",2,xFilial("SLK")+SC6->C6_PRODUTO,"LK_CODBAR")

			If Empty(cCDBarras)
				cCDBarras := SB1->B1_CODBAR
			EndIf

			aColsTmp[nP_PRODUTO] 	:= SC6->C6_PRODUTO
			aColsTmp[nP_UM] 		:= SC6->C6_UM
			aColsTmp[nP_DESCRIC] 	:= If(!SB1->(Eof()),SB1->B1_DESC,"")
			aColsTmp[nP_QTDVEN] 	:= SC6->C6_QTDVEN
			aColsTmp[nP_QTDCONF] 	:= SC6->C6_XQTCONF
			aColsTmp[nP_CODBAR]		:= If(!SB1->(Eof()),cCDBarras,"")
			aColsTmp[nP_FALTA] 		:= SC6->(C6_QTDVEN-C6_XQTCONF)
			aColsTmp[nP_STATCONF] 	:= ""
			aColsTmp[nP_DELETE]		:= .F.

			aAdd(aCols,aColsTmp)
		EndIf

		SC6->(dbSkip())
	EndDo

//->> Regra de Legenda
	For nX:=1 to Len(aCols)
		If aCols[nX][nP_QTDCONF] == 0
			aCols[nX][nP_LEGENDA]  := LoadBitmap( GetResources(), "BR_VERMELHO" )
			aCols[nX][nP_STATCONF] := "0"

		ElseIf aCols[nX][nP_QTDVEN] - aCols[nX][nP_QTDCONF] > 0
			aCols[nX][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_AMARELO" )
			aCols[nX][nP_STATCONF] := "1"

		Else
			aCols[nX][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_VERDE" )
			aCols[nX][nP_STATCONF] := "2"

		EndIf
	Next nX

//->> Reordenação do acols da conferencia na inicialização do acols
	aCols := aSort(aCols,,,{|x,y| x[nP_STATCONF]+x[nP_DESCRIC] <= y[nP_STATCONF]+y[nP_DESCRIC] })

Return aCols

/*/{protheus.doc} BOVlCpConf
*******************************************************************************************
Faz a Validação dos Campos.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOVlCpConf()
	Local lRet 		:= .T.
	Local nPos		:= 0
	Local xCpo		:= NIL
	Local lSugQtde  := GetNewPar("BO_SUGQTDC","N")=="S"

//->> Marcelo Celi - 20/12/2020
	Local lOk		:= .F. //VARIAVEL ENCONTROU ITEM PEDIDO
	Local lProd 	:= .F. //VARIAVEL ENCONTROU PRODUTO
	Local lAtacado	:= .F.
	Local cMens		:= ""

	If Alltrim(Upper("C6_XQTCONF")) $ Alltrim(Upper(ReadVar()))
		xCpo := &(ReadVar())
		If xCpo <> 0
			MsgAlert("Só é permitido informar uma quantidade zerada para re-startar a conferência do Item.")
			lRet := .F.
		Else
			oItensPV:aCols[oItensPV:nAt][nP_LEGENDA]  := LoadBitmap( GetResources(), "BR_VERMELHO" )
			oItensPV:aCols[oItensPV:nAt][nP_FALTA] 	  := oItensPV:aCols[oItensPV:nAt][nP_QTDVEN]
			oItensPV:aCols[oItensPV:nAt][nP_STATCONF] := "0"
			oItensPV:aCols[oItensPV:nAt][nP_QTDCONF]  := 0

			//->> Reordenação do acols da conferencia após atualização da qtd separada manualmente pelo usuario no restart da qtde.
			oItensPV:aCols 		 := aSort(oItensPV:aCols,,,{|x,y| x[nP_STATCONF]+x[nP_DESCRIC] <= y[nP_STATCONF]+y[nP_DESCRIC] })
			oItensPV:nAt 		 := 1
			oItensPV:OBROWSE:NAT := 1
			oItensPV:Refresh()
		EndIf
	Else
		If !Empty( &(ReadVar()) ) .Or. (Empty( &(ReadVar()) ) .And. Alltrim(Upper(ReadVar())) = Alltrim(Upper("nQtde")) )
			Do Case
			Case Alltrim(Upper(ReadVar())) = Alltrim(Upper("cBarras"))
				xCpo := &(ReadVar())

				//->> Marcelo Celi - 20/12/2020
				lProd		:= .F.
				lOk 		:= .F.
				lAtacado	:= .F.
				SB1->(dbSetOrder(5)) //->> Codigo de Barras - B1_CODBAR
				If SB1->(dbSeek(xFilial("SB1")+PadR(xCpo,Tamsx3("B1_CODBAR")[01])))
					nPos := Ascan(oItensPV:aCols,{|x| Alltrim(x[nP_PRODUTO])==Alltrim(SB1->B1_COD) })
					If nPos == 0
						lOk := .F.
					Else
						lOk 	:= .T.
						lAtacado:= .T.
					EndIf
					lProd		:= .T.
				Else
					SB1->(dbSetOrder(14)) //->> Codigo Getin - B1_CODGTIN
					If SB1->(dbSeek(xFilial("SB1")+PadR(xCpo,Tamsx3("B1_CODGTIN")[01])))
						nPos := Ascan(oItensPV:aCols,{|x| Alltrim(x[nP_PRODUTO])==Alltrim(SB1->B1_COD) })
						If nPos == 0
							lOk := .F.
						Else
							lOk 	:= .T.
							lAtacado:= .F.
						EndIf
						lProd		:= .T.
					Else
						//->> Marcelo Celi - 12/01/2021
						SB1->(dbSetOrder(1)) //->> Codigo do Produto
						If SB1->(dbSeek(xFilial("SB1")+PadR(xCpo,Tamsx3("B1_COD")[01])))
							nPos := Ascan(oItensPV:aCols,{|x| Alltrim(x[nP_PRODUTO])==Alltrim(SB1->B1_COD) })
							If nPos == 0
								lOk := .F.
							Else
								lOk 	:= .T.
								lAtacado:= .F.
							EndIf
							lProd		:= .T.
						EndIf
					EndIf
				EndIf

				If !lProd
					MsgStop("Codigo de barras não cadastrado no sistema, solicite cadastro!","BOCONFPEDV")
				EndIf
				//nPos := Ascan(oItensPV:aCols,{|x| Alltrim(x[nP_CODBAR])==Alltrim(xCpo) })
				//->> Senão achar o produto pelas barras, buscar pelo codigo do produto.
				//If nPos == 0
				//	nPos := Ascan(oItensPV:aCols,{|x| Alltrim(x[nP_PRODUTO])==Alltrim(xCpo) })
				//EndIf
				//If nPos >0

				If lOk
					nPosItenPV := nPos

					cUnidade := oItensPV:aCols[nPos][nP_UM]
					oUnidade:Refresh()

					nQtdConf := oItensPV:aCols[nPos][nP_QTDCONF]
					oQtdConf:Refresh()

					If lSugQtde
						nQtde := oItensPV:aCols[nPos][nP_QTDVEN] - oItensPV:aCols[nPos][nP_QTDCONF]
					Else
						//->> Marcelo Celi - 20/12/2020
						If !lAtacado
							nQtde := 1
						Else
							nQtde := SB1->B1_CONV
							If nQtde == 0
								nQtde := 1
							EndIf
						EndIf
					EndIf
					oQtde:Refresh()

					If !lSugQtde
						If (oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF]) == 0
							MsgAlert("Item já conferido por completo...")
							oBarras:setfocus()

							//->> Marcelo Celi - 19/01/2021
						ElseIf (oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF]) < 0
							MsgAlert("Item ultrapassa a quantidade esperada de separação...")
							oBarras:setfocus()

						Else
							oItensPV:aCols[nPosItenPV][nP_QTDCONF] += nQtde
							oItensPV:Refresh()

							oItensPV:aCols[nPosItenPV][nP_FALTA] -= nQtde
							oItensPV:Refresh()

							//->> Regra de Legenda
							If oItensPV:aCols[nPosItenPV][nP_QTDCONF] == 0
								oItensPV:aCols[nPosItenPV][nP_LEGENDA]  := LoadBitmap( GetResources(), "BR_VERMELHO" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "0"

							ElseIf oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF] > 0
								oItensPV:aCols[nPosItenPV][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_AMARELO" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "1"

							Else
								oItensPV:aCols[nPosItenPV][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_VERDE" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "2"

							EndIf

							//->> Reordenação do aCols Conferido após bipagem
							oItensPV:aCols 		 := aSort(oItensPV:aCols,,,{|x,y| x[nP_STATCONF]+x[nP_DESCRIC] <= y[nP_STATCONF]+y[nP_DESCRIC] })
							oItensPV:nAt 		 := 1
							oItensPV:OBROWSE:NAT := 1
							oItensPV:Refresh()

							nQtdConf := oItensPV:aCols[nPos][nP_QTDCONF]
							oQtdConf:Refresh()

							nPosItenPV := 0
							oBarras:setfocus()
						EndIf
					EndIf

					cBarras := oItensPV:aCols[nPos][nP_DESCRIC]
					oBarras:Refresh()

				Else
					cMens := "Código de Barras não Localizado nos itens do Pedido de Vendas." +ENTER
					cMens += "O Produto encontrado foi o : "+ENTER
					cMens += "Cod: "+SB1->B1_COD+ENTER
					cMens += "Descricao: "+SB1->B1_DESC+ENTER

					MsgAlert(cMens,"BOCONFPEDV")
					cBarras  := Space(Tamsx3("B1_CODBAR")[01])
					oBarras:Refresh()

					cUnidade := ""
					oUnidade:Refresh()

					nQtdConf := 0
					oQtdConf:Refresh()

					nQtde := 0
					oQtde:Refresh()

					nPosItenPV := 0
					lRet := .F.
					oBarras:setfocus()
				EndIf

			Case Alltrim(Upper(ReadVar())) = Alltrim(Upper("nQtde"))
				If nPosItenPV == 0
					MsgAlert("Item não posicionado...")

					//->> Reinicia o processo
					cBarras  := Space(Tamsx3("B1_CODBAR")[01])
					oBarras:Refresh()

					cUnidade := ""
					oUnidade:Refresh()

					nQtdConf := 0
					oQtdConf:Refresh()

					nQtde := 0
					oQtde:Refresh()

					nPosItenPV := 0
					oBarras:setfocus()

				Else
					xCpo := &(ReadVar())
					If xCpo >= 0
						If xCpo > 0 .And. (oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF]) == 0
							MsgAlert("Item já conferido por completo...")

							//->> Reinicia o processo
							cBarras  := Space(Tamsx3("B1_CODBAR")[01])
							oBarras:Refresh()

							cUnidade := ""
							oUnidade:Refresh()

							nQtdConf := 0
							oQtdConf:Refresh()

							nQtde := 0
							oQtde:Refresh()

							nPosItenPV := 0
							oBarras:setfocus()


						ElseIf oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF] - xCpo < 0
							MsgAlert("Quantidade Informada Ultrapassa o Saldo de Conferência...")
							lRet := .F.

						Else
							oItensPV:aCols[nPosItenPV][nP_QTDCONF] += xCpo
							oItensPV:Refresh()

							oItensPV:aCols[nPosItenPV][nP_FALTA] -= xCpo
							oItensPV:Refresh()

							//->> Reinicia o processo
							cBarras  := Space(Tamsx3("B1_CODBAR")[01])
							oBarras:Refresh()

							cUnidade := ""
							oUnidade:Refresh()

							nQtdConf := 0
							oQtdConf:Refresh()

							nQtde := 0
							oQtde:Refresh()

							//->> Regra de Legenda
							If oItensPV:aCols[nPosItenPV][nP_QTDCONF] == 0
								oItensPV:aCols[nPosItenPV][nP_LEGENDA]  := LoadBitmap( GetResources(), "BR_VERMELHO" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "0"

							ElseIf oItensPV:aCols[nPosItenPV][nP_QTDVEN] - oItensPV:aCols[nPosItenPV][nP_QTDCONF] > 0
								oItensPV:aCols[nPosItenPV][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_AMARELO" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "1"

							Else
								oItensPV:aCols[nPosItenPV][nP_LEGENDA] := LoadBitmap( GetResources(), "BR_VERDE" )
								oItensPV:aCols[nPosItenPV][nP_STATCONF] := "2"

							EndIf

							//->> Reordenação do aCols Conferido após bipagem
							oItensPV:aCols 		 := aSort(oItensPV:aCols,,,{|x,y| x[nP_STATCONF]+x[nP_DESCRIC] <= y[nP_STATCONF]+y[nP_DESCRIC] })
							oItensPV:nAt 		 := 1
							oItensPV:OBROWSE:NAT := 1
							oItensPV:Refresh()

							nPosItenPV := 0
							oBarras:setfocus()
						EndIf
					Else
						MsgAlert("Informar uma quantidade válida...")
						lRet := .F.
						oQtde:setfocus()

					EndIf
				EndIf
			EndCase
		EndIf
	EndIf

Return lRet

/*/{protheus.doc} GetPedido
*******************************************************************************************
Retorna os recnos do pedido.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPedido(aCols,cNumero)
	Local aPedidos 	:= {}
	Local cQuery 	:= ""
	Local cAlias	:= Criatrab(NIL,.F.)

	cQuery := "SELECT 	SC6.R_E_C_N_O_ AS RECSC6,"																+CRLF
	cQuery += "			SC6.C6_ITEM,"																			+CRLF
	cQuery += "			SC6.C6_PRODUTO,"																		+CRLF
	cQuery += "			SC6.C6_QTDVEN,"																			+CRLF
	cQuery += "			SC6.C6_XQTCONF"																			+CRLF
	cQuery += "		FROM "+RetSqlName("SC6")+" SC6"																+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC9")+" SC9 (NOLOCK)"												+CRLF
	cQuery += "			ON 	SC9.C9_FILIAL 	= SC6.C6_FILIAL"													+CRLF
	cQuery += "			AND SC9.C9_PEDIDO	= SC6.C6_NUM"														+CRLF
	cQuery += "			AND SC9.C9_ITEM		= SC6.C6_ITEM"														+CRLF
	cQuery += "			AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO"													+CRLF

//->> Marcelo Celi - 23/12/2020
	If !Empty(aRetParam[10])
		cQuery += "			AND	SC9.C9_DATALIB 	BETWEEN '"+Dtos(aRetParam[09])+"' AND '"+dTos(aRetParam[10])+"'"+CRLF
	ElseIf !Empty(aRetParam[09])
		cQuery += "			AND	SC9.C9_DATALIB 	= '"+Dtos(aRetParam[09])+"'"									+CRLF
	EndIf

	cQuery += " 		AND SC9.C9_BLCRED	= '"+Space(Tamsx3("C9_BLCRED")[01])+"'"	  							+CRLF
	cQuery += " 		AND SC9.C9_BLEST	= '"+Space(Tamsx3("C9_BLEST") [01])+"'"								+CRLF
	cQuery += " 		AND SC9.C9_BLWMS 	IN('  ','05','06','07') "			  								+CRLF
	cQuery += "			AND SC9.D_E_L_E_T_  =  ' '"							 									+CRLF
	cQuery += "		WHERE 	SC6.C6_FILIAL = '"+xFilial("SC6")+"'"												+CRLF
	cQuery += "			AND SC6.C6_NUM    = '"+cNumero+"'"														+CRLF
	cQuery += "			AND SC6.D_E_L_E_T_  =  ' '"							 									+CRLF
	cQuery += " ORDER BY SC6.C6_PRODUTO, SC6.C6_ITEM"															+CRLF

	MsgRun("Filtrando Pedidos...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })

	Do While (cAlias)->(!Eof())
		aAdd(aPedidos,{	(cAlias)->RECSC6			,; // 01 - Recno da SC6
		(cAlias)->C6_PRODUTO		,; // 02 - Codigo do Produto
		(cAlias)->C6_ITEM			,; // 03 - Item do Pedido
		(cAlias)->C6_QTDVEN			,; // 04 - Quandidade Vendida
		0							}) // 05 - Quantidade Conferida

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return aPedidos

/*/{protheus.doc} BOGetSitPV
*******************************************************************************************
Retorna a Situação do Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOGetSitPV(cNumero)
	Local nSituac := 0

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+cNumero))
	Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+cNumero
		If SC6->C6_XQTCONF == 0
			If nSituac == 1
				nSituac := 2
				Exit
			Else
				nSituac := 3
			EndIf
		ElseIf SC6->C6_QTDVEN - SC6->C6_XQTCONF > 0
			nSituac := 2
			Exit
		Else
			If nSituac == 3
				nSituac := 2
				Exit
			Else
				nSituac := 1
			EndIf
		EndIf
		SC6->(dbSkip())
	EndDo

	If nSituac == 0
		nSituac := 3
	EndIf

Return nSituac

/*/{protheus.doc} AtualTempo
*******************************************************************************************
Atualiza o Tempo de Conferencia.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtualTempo()
	Local nHH := Val(Substr(cTempConf,1,2))
	Local nMM := Val(Substr(cTempConf,4,2))
	Local nSS := Val(Substr(cTempConf,7,2))

	nSS++
	If nSS>=60
		nMM++
		nSS := 0
	EndIf

	If nMM>=60
		nHH++
		nMM := 0
	EndIf

	cTempConf := StrZero(nHH,2)+":"+StrZero(nMM,2)+":"+StrZero(nSS,2)
	oTempConf:Refresh()

Return

/*/{protheus.doc} VlPedNaConf
*******************************************************************************************
Valida se itens estão de acordo para realizar a separação
 
@author: Marcelo Celi Marques
@since: 22/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VlPedNaConf(cNumero)
	Local cQuery 	:= ""
	Local cAlias	:= Criatrab(NIL,.F.)
	Local lRet		:= .T.

	cQuery := "SELECT 	SC9.C9_BLCRED,"																			+CRLF
	cQuery += "			SC9.C9_BLEST"																			+CRLF
	cQuery += "		FROM "+RetSqlName("SC6")+" SC6"																+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC9")+" SC9 (NOLOCK)"												+CRLF
	cQuery += "			ON 	SC9.C9_FILIAL 	= SC6.C6_FILIAL"													+CRLF
	cQuery += "			AND SC9.C9_PEDIDO	= SC6.C6_NUM"														+CRLF
	cQuery += "			AND SC9.C9_ITEM		= SC6.C6_ITEM"														+CRLF
	cQuery += "			AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO"													+CRLF
	cQuery += " 		AND SC9.C9_BLWMS 	IN('  ','05','06','07') "			  								+CRLF
	cQuery += "			AND SC9.D_E_L_E_T_  =  ' '"							 									+CRLF
	cQuery += "		WHERE 	SC6.C6_FILIAL = '"+xFilial("SC6")+"'"												+CRLF
	cQuery += "			AND SC6.C6_NUM    = '"+cNumero+"'"														+CRLF
	cQuery += "			AND SC6.D_E_L_E_T_  =  ' '"							 									+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
	If (cAlias)->(!Eof())
		Do While (cAlias)->(!Eof())
			If !Empty((cAlias)->C9_BLCRED) .And. !Empty((cAlias)->C9_BLEST)
				lRet := .F.
				Exit
			EndIf
			(cAlias)->(dbSkip())
		EndDo
	Else
		lRet := .F.
	EndIf
	(cAlias)->(dbCloseArea())

Return lRet

/*/{protheus.doc} GetDtEntreg
*******************************************************************************************
Imprime o pedido de vendas
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDtEntreg(cPedido,dEmissao)
	Local dEntrega := Stod("")

	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+cPedido))
		dEntrega := SC6->C6_ENTREG
	EndIf

	If Empty(dEntrega)
		dEntrega := dEmissao
	EndIf

Return dEntrega

/*/{protheus.doc} PVImpresso
*******************************************************************************************
Setar como pedido impresso
 
@author: Marcelo Celi Marques
@since: 25/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function PVImpresso(cNumero,aDados)
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cNumero))
		Reclock("SC5",.F.)
		If SC5->C5_XIMPRPV == "S"
			SC5->C5_XIMPRPV := "N"
			aDados[oLbxPV:nAt,8] := .F.
		Else
			SC5->C5_XIMPRPV := "S"
			aDados[oLbxPV:nAt,8] := .T.
		EndIf
		SC5->(MsUnlock())
	EndIf
	oLbxPV:Refresh()
Return

/*/{protheus.doc} Imprimir
*******************************************************************************************
Imprime o pedido de vendas
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
/*
Static Function Imprimir(cNumero,nTipo)

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cNumero))  
	u_RATORC02(nTipo)
Else
	MsgAlert("Pedido de Vendas não Localizado...")
EndIf

Return
*/
