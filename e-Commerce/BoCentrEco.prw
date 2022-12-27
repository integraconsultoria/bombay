#INCLUDE "Totvs.ch"
#INCLUDE "Apwizard.ch"
#INCLUDE 'Msgraphi.ch'
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"

/*/{protheus.doc} BoCentrEco
*******************************************************************************************
Monitor do e-Commerce
 
@author: Marcelo Celi Marques
@since: 07/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCentrEco()
Local oDlg          := NIL
Local oPanel        := NIL
Local oPanEsq       := NIL
Local oPanDir       := NIL
Local aButtons      := {}
Local aSize	    	:= MsAdvSize()
Local nTmpLin       := 0
Local nX            := 1
Local bComando		:= {|| }
Local oFonte 		:= TFont():New('Arial Black',,14,.T.)
Local nValidToken	:= GetNewPar("MC_ECOMVTK",60) // Tempo de validade do token, em minutos (default 60 minutos)
Local nLargLogo		:= 268*.13
Local nAltuLogo		:= 574*.13
Local aColsErr		:= {}
Local aHeadErr		:= {}
Local aColsVel		:= {}
Local aHeadVel		:= {}

If VldRotina()
	Private oButtons    := {}
	Private oGraficos   := {}
	Private dProcVdas	:= Date()
	Private nPDadConx	:= 0
	Private nPGrfVds	:= 0
	Private nPPrgInt	:= 0
	Private nPVlcInt	:= 0
	Private oEcomm 		:= ""
	Private cBmpConn	:= "FRTONLINE"
	Private cBmpNoConn	:= "FRTOFFLINE"
	Private lConectado	:= .F.
	Private nOpcGrfInt	:= 1

	Private nPOSIC_ITEM := 0
	Private nCorSelec	:= Rgb(255,201,14)
	Private aErros		:= {}

	//->> montagem do aHeader de erros de integração
	SX3->(dbSetOrder(1))
	SX3->(DbSeek("ZWT"))
	Do While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "ZWT")
		If X3USO(SX3->X3_USADO)
			If !(Upper(Alltrim(SX3->X3_CAMPO)) $ "ZWT_FILIAL|ZWT_WSREQU|ZWT_WSRESP|ZWT_ERRPRO")
				Aadd(aHeadErr,{	TRIM(SX3->X3_DESCRIC)	,;
								SX3->X3_CAMPO			,;
								SX3->X3_PICTURE			,;
								SX3->X3_TAMANHO			,;
								SX3->X3_DECIMAL			,;
								SX3->X3_VALID			,;
								SX3->X3_USADO			,;
								SX3->X3_TIPO			,;
								SX3->X3_F3				,;
								SX3->X3_CONTEXT 		,; 
								SX3->X3_CBOX 			,; 
								Nil			 			,; 
								Nil			 			,;
								"V"						 ;
								})            
			EndIf		        			   	
		EndIf
		SX3->(DbSkip())
	EndDo

	//->> montagem do aHeader de controle de velocidade de integração
	Aadd(aHeadVel,{	"Clientes"	,"CLIENTE","@E 9,999,999.99999",12,5,"","","N","","V","",Nil,Nil,"V"})
	Aadd(aHeadVel,{	"Produtos"	,"CLIENTE","@E 9,999,999.99999",12,5,"","","N","","V","",Nil,Nil,"V"})
	Aadd(aHeadVel,{	"Categorias","CLIENTE","@E 9,999,999.99999",12,5,"","","N","","V","",Nil,Nil,"V"})
	Aadd(aHeadVel,{	"Estoques"	,"CLIENTE","@E 9,999,999.99999",12,5,"","","N","","V","",Nil,Nil,"V"})
	Aadd(aHeadVel,{	"Preços"	,"CLIENTE","@E 9,999,999.99999",12,5,"","","N","","V","",Nil,Nil,"V"})

	DEFINE MSDIALOG oDlg TITLE "Monitor e-Commerce" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,((oDlg:NWIDTH)/2),((oDlg:NHEIGHT)/2)-25,.F.,.F. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oPanEsq := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(195,195,195),80,(((oPanel:NHEIGHT)/2)),.F.,.T. )
	oPanEsq:Align := CONTROL_ALIGN_LEFT

	//->> Formatacao dos botoes
	aAdd(aButtons,{"Upload"+CRLF+"de"+CRLF+"Clientes"     ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"CLIENTE.png"      ,  {|| u_BOCliToEco(.F.,@oEcomm) 															} , ""		})
	aAdd(aButtons,{"Upload"+CRLF+"de"+CRLF+"Produtos"     ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"PRODUTO.png"      ,  {|| u_BOPrdToEco(.F.,@oEcomm)															} , ""  	})
	aAdd(aButtons,{"Upload"+CRLF+"de"+CRLF+"Categorias"   ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"RPMDES.png"      ,   {|| u_BOCatToEco(.F.,@oEcomm)															} , ""  	})
	aAdd(aButtons,{"Upload"+CRLF+"de"+CRLF+"Estoque"      ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"ESTOMOVI.png"     ,  {|| u_BOEstToEco(.F.,@oEcomm) 															} , ""  	})
	aAdd(aButtons,{"Upload"+CRLF+"de"+CRLF+"Preço"        ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"PRECO.png"        ,  {|| u_BOPreToEco(.F.,@oEcomm) 															} , ""  	})
	aAdd(aButtons,{"Download"+CRLF+"de"+CRLF+"Vendas"     ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"PEDIDO.png"       ,  {|| u_BOPedByEco(.F.,@oEcomm) 															} , ""  	})

	//->> Marcelo Celi - 22/12/2020
	//aAdd(aButtons,{"Linkagem"+CRLF+"de"+CRLF+"Produtos"  ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"PMSRELA.png"       ,  {|| u_BOLinkPrd(.F.,@oEcomm) 															} , ""  	})

	aAdd(aButtons,{"Refazer Conexão"       				  ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"WEB.png"    		 ,  {|| MsgRun("Refazendo a Conexão...","Aguarde",{|| Conecta(nPDadConx,nValidToken) })     } , "" 		})
	aAdd(aButtons,{"Saida"              				  ,((oPanEsq:NWIDTH)/2)-4,30 ,3  ,"FINAL.png"        ,  {|| oDlg:End()       				    												} , "" 		})

	nTmpLin := 5
	For nX:=1 to Len(aButtons)
		If nX ==Len(aButtons) //.Or. nX ==Len(aButtons)-1
			nTmpLin := ((oPanEsq:NHEIGHT)/2)-aButtons[nX,03]+5
		EndIf    

		If nX ==Len(aButtons)-1
			nTmpLin := ((oPanEsq:NHEIGHT)/2)-aButtons[nX,03]-28
		EndIf    


		aAdd(oButtons,{TButton():New(nTmpLin,02,aButtons[nX,01],oPanEsq,aButtons[nX,06],aButtons[nX,02],aButtons[nX,03],,,.F.,.T.,.F.,,.F.,,,.F. ),NIL})
		oButtons[Len(oButtons)][01]:SetCss(GetStyloBt(aButtons[nX,04],aButtons[nX,05]))
		oButtons[Len(oButtons)][01]:lActive := .F.

		nTmpLin += aButtons[nX,03] + 5
		
		If !Empty(aButtons[nX,07])
			bComando := &(aButtons[nX,07])
			oButtons[Len(oButtons)][02] := TTimer():New(1000 /*1 segundos*/, bComando , oDlg )
			oButtons[Len(oButtons)][02]:Activate()
		EndIf

	Next nX

	oPanDir := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(216,216,216),((oPanel:NWIDTH)/2)-80,(((oPanel:NHEIGHT)/2)),.T.,.F. )
	oPanDir:Align := CONTROL_ALIGN_RIGHT

	//*********************************************************************************************************************************************
	//->> Painel das informações da conexão
	aAdd(oGraficos,Array(15))
	//->>PAINEL PRINCIPAL
	oGraficos[Len(oGraficos)][01] := TPanel():New(1,1,'',oPanDir, oDlg:oFont, .T., .T.,,RGB(216,216,216),((oPanDir:NWIDTH)/2)-1,(35),.T.,.F. )
	oGraficos[Len(oGraficos)][01]:Align := CONTROL_ALIGN_TOP

	bComando := &("{|| Conecta("+Alltrim(Str(Len(oGraficos)))+","+Alltrim(Str(nValidToken))+") }")
	oGraficos[Len(oGraficos)][02] := TTimer():New(500 /*15 segundos*/, bComando , oDlg )
	oGraficos[Len(oGraficos)][02]:Activate()

	//->> dados da conexao
	@ 02,43+nLargLogo TO ((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)-2,(((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+nLargLogo OF oGraficos[Len(oGraficos)][01] PIXEL
	oGraficos[Len(oGraficos)][03] := TBitmap():New((((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)-25),nLargLogo+45,20,20,,,.T.,oGraficos[Len(oGraficos)][01],{|| },,.T.,.F.,,,.F.,,.T.,,.F.)
	oGraficos[Len(oGraficos)][03]:CRESNAME := cBmpNoConn
	oGraficos[Len(oGraficos)][03]:Refresh()

	oGraficos[Len(oGraficos)][04] := TSay():New(07,63+nLargLogo, {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,50,255),CLR_WHITE,200,20) 
	oGraficos[Len(oGraficos)][04]:SetText( "Versão:" )
	oGraficos[Len(oGraficos)][04]:CtrlRefresh()
	oGraficos[Len(oGraficos)][05] := TSay():New(07,88+nLargLogo, {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20) 

	oGraficos[Len(oGraficos)][06] := TSay():New(18,63+nLargLogo, {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,50,255),CLR_WHITE,200,20) 
	oGraficos[Len(oGraficos)][06]:SetText( "Edição:" )
	oGraficos[Len(oGraficos)][06]:CtrlRefresh()
	oGraficos[Len(oGraficos)][07] := TSay():New(18,88+nLargLogo, {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20) 

	//->> dados da loja virtual
	@ 02,(((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+2+nLargLogo TO ((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)-2,((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)-5 OF oGraficos[Len(oGraficos)][01] PIXEL

	oGraficos[Len(oGraficos)][08] := TSay():New(04,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+10+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,50,255),CLR_WHITE,200,20) 
	oGraficos[Len(oGraficos)][08]:SetText( "Código Loja:" )
	oGraficos[Len(oGraficos)][08]:CtrlRefresh()
	oGraficos[Len(oGraficos)][09] := TSay():New(04,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+45+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20) 

	oGraficos[Len(oGraficos)][10] := TSay():New(14,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+10+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,50,255),CLR_WHITE,200,20) 
	oGraficos[Len(oGraficos)][10]:SetText( "Nome Loja:" )
	oGraficos[Len(oGraficos)][10]:CtrlRefresh()
	oGraficos[Len(oGraficos)][11] := TSay():New(14,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+45+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20) 

	oGraficos[Len(oGraficos)][12] := TSay():New(24,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+10+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,50,255),CLR_WHITE,200,20) 
	oGraficos[Len(oGraficos)][12]:SetText( "Ambiente:" )
	oGraficos[Len(oGraficos)][12]:CtrlRefresh()
	oGraficos[Len(oGraficos)][13] := TSay():New(24,((((oGraficos[Len(oGraficos)][01]:NWIDTH)/2)*.25)+45+nLargLogo), {|| "" }, oGraficos[Len(oGraficos)][01],,oDlg:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20) 

	//->> Timer do controle dos botoes de upload e dowload
	bComando := &("{|| u_BO1BlqBot() }")
	oGraficos[Len(oGraficos)][14] := TTimer():New(500 /*15 segundos*/, bComando , oDlg )
	oGraficos[Len(oGraficos)][14]:Activate()

	//->> Logotipo da Empresa de e-commerce
	//@ 02,05 TO ((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)-2,(nLargLogo) OF oGraficos[Len(oGraficos)][01] PIXEL
	oGraficos[Len(oGraficos)][15] := TBitmap():New(01,02,(nAltuLogo),(nLargLogo),Nil,"",.T.,oGraficos[Len(oGraficos)][01],,,.F.,.T.,,,.F.,,.T.,,.F.)
	oGraficos[Len(oGraficos)][15]:CBMPFILE := GetNewPar("MC_MAGELOG","MAGENTO-LOGO.JPG")
	oGraficos[Len(oGraficos)][15]:Refresh()

	nPDadConx := Len(oGraficos)

	//*********************************************************************************************************************************************
	//->> Painel da Grafico de Projeção diario de descida de pedidos
	aAdd(oGraficos,Array(08))
	//->>PAINEL PRINCIPAL
	oGraficos[Len(oGraficos)][01] := TPanel():New(1,1,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NWIDTH)/2)-1,(((oPanDir:NHEIGHT)/2)*.45)-45,.T.,.T. )
	oGraficos[Len(oGraficos)][01]:Align := CONTROL_ALIGN_TOP
	//->>PAINEL SECUNDARIO
	oGraficos[Len(oGraficos)][02] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][01], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][01]:NWIDTH)/2),(((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)),.F.,.T. )
	oGraficos[Len(oGraficos)][02]:Align := CONTROL_ALIGN_TOP
	//->>PAINEL TTOOBOX
	oGraficos[Len(oGraficos)][03] := TToolBox():New(0,0,oGraficos[Len(oGraficos)][01],(oGraficos[Len(oGraficos)][01]:NWIDTH/2),(oGraficos[Len(oGraficos)][01]:NHEIGHT/2))
	oGraficos[Len(oGraficos)][03]:AddGroup(oGraficos[Len(oGraficos)][02] , "Projeção Diária das Vendas e-Commerce")

	//->>PAINEL SECUNDARIO (ESQUERDO)
	oGraficos[Len(oGraficos)][04] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][02], oDlg:oFont, .T., .T.,,,(150),(((oGraficos[Len(oGraficos)][02]:NHEIGHT)/2)),.F.,.F. )
	oGraficos[Len(oGraficos)][04]:Align := CONTROL_ALIGN_LEFT

	oGraficos[Len(oGraficos)][05] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][02], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][02]:NWIDTH)/2)-150,(((oGraficos[Len(oGraficos)][02]:NHEIGHT)/2)),.F.,.T. )
	oGraficos[Len(oGraficos)][05]:Align := CONTROL_ALIGN_RIGHT

	//->>PAINEL CALENDARIO
	oGraficos[Len(oGraficos)][06] 			:= MsCalend():New(00,01,oGraficos[Len(oGraficos)][04],.T.)
	oGraficos[Len(oGraficos)][06]:dDiaAtu 	:= dProcVdas
	oGraficos[Len(oGraficos)][06]:ColorDay( 1, CLR_RED )
	oGraficos[Len(oGraficos)][06]:ColorDay( 7, CLR_BLUE )
	//oGraficos[Len(oGraficos)][06]:bChange := &("{|| dProcVdas := oGraficos["+Alltrim(Str(Len(oGraficos)))+"][06]:dDiaAtu, GrfAtualiz(1,"+Alltrim(Str(Len(oGraficos)))+"),CalAtualiz(nPPrgInt),oGraficos["+Alltrim(Str(Len(oGraficos)))+"][06]:Refresh() }")
	oGraficos[Len(oGraficos)][06]:bChange := &("{|| AtualCalend() }")
	oGraficos[Len(oGraficos)][06]:canmultsel := .f.
	oGraficos[Len(oGraficos)][06]:Refresh()

	//->>PAINEL GRAFICO
	oGraficos[Len(oGraficos)][07] := FWChartLine():New()
	//GrfAtualiz(1,Len(oGraficos))
	//->>TIMMER ATUALIZADOR DE DADOS
	bComando := &("{|| GrfAtualiz(1,"+Alltrim(Str(Len(oGraficos)))+") }")
	oGraficos[Len(oGraficos)][08] := TTimer():New(500 /*15 segundos*/, bComando , oDlg )
	oGraficos[Len(oGraficos)][08]:Activate()

	nPGrfVds := Len(oGraficos)

	//*********************************************************************************************************************************************
	//->> Painel da calendario de projeção de conexões diarios nos ultimos dias
	aAdd(oGraficos,Array(16))
	//->>PAINEL PRINCIPAL
	oGraficos[Len(oGraficos)][01] := TPanel():New(1,1,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NWIDTH)/2)-1,(((oPanDir:NHEIGHT)/2)*.55)-30,.T.,.T. )
	oGraficos[Len(oGraficos)][01]:Align := CONTROL_ALIGN_ALLCLIENT
	//->>PAINEL SECUNDARIO 1
	oGraficos[Len(oGraficos)][02] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][01], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][01]:NWIDTH)/2),(((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)),.T.,.T. )
	oGraficos[Len(oGraficos)][02]:Align := CONTROL_ALIGN_TOP

	//->>PAINEL SECUNDARIO 2
	oGraficos[Len(oGraficos)][03] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][01], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][01]:NWIDTH)/2),(((oGraficos[Len(oGraficos)][01]:NHEIGHT)/2)),.T.,.T. )
	oGraficos[Len(oGraficos)][03]:Align := CONTROL_ALIGN_TOP

	//->>PAINEL TTOOBOX
	oGraficos[Len(oGraficos)][04] := TToolBox():New(0,0,oGraficos[Len(oGraficos)][01],(oGraficos[Len(oGraficos)][01]:NWIDTH/2),(oGraficos[Len(oGraficos)][01]:NHEIGHT/2))
	oGraficos[Len(oGraficos)][04]:AddGroup(oGraficos[Len(oGraficos)][02] , "Projeção de Integrações com e-Commerce")
	oGraficos[Len(oGraficos)][04]:AddGroup(oGraficos[Len(oGraficos)][03] , "Erros de Integrações com e-Commerce")
	//->>PAINEL GRAFICO

	oPanEInteg := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][02], oDlg:oFont, .T., .T.,,,(298),(((oGraficos[Len(oGraficos)][02]:NHEIGHT)/2)),.T.,.F. )
	oPanEInteg:Align := CONTROL_ALIGN_LEFT

	oPanDInteg := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][02], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][02]:NWIDTH)/2)-298,(((oGraficos[Len(oGraficos)][02]:NHEIGHT)/2)),.T.,.F. )
	oPanDInteg:Align := CONTROL_ALIGN_RIGHT

	oGraficos[Len(oGraficos)][05] := MsCalendGrid():New(oPanEInteg /*oDlg*/,01/*nCol*/,01/*nCol*/,((oPanEInteg:NWIDTH)/2)-1/*nWidth*/,((oPanEInteg:NHEIGHT)/2)-1/*nHeight*/,Date()/*Data Inicio*/,4/*Resolucao*/,/*bWhen*/,{|| }/*bAction*/,RGB(223,218,241)/*nDefColor*/, {|| }/*bRClick*/, .F./*lFilAll*/,/*nTypeUnit 0-Horas, 1-Dias*/ ) 
	oGraficos[Len(oGraficos)][05]:Align   := CONTROL_ALIGN_ALLCLIENT
	oGraficos[Len(oGraficos)][05]:cTopMsg := "Integrações Realizadas em "+Dtoc(dProcVdas)

	//->> Painel de Visualização das integrações realizadas
	oIntegrados := VisuIntegr(oPanDInteg,oDlg:oFont)

	oGraficos[Len(oGraficos)][06] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][03], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][03]:NWIDTH)/2)-280,(((oGraficos[Len(oGraficos)][03]:NHEIGHT)/2)),.T.,.F. )
	oGraficos[Len(oGraficos)][06]:Align := CONTROL_ALIGN_LEFT

	oGraficos[Len(oGraficos)][07] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][03], oDlg:oFont, .T., .T.,,,(280),(((oGraficos[Len(oGraficos)][03]:NHEIGHT)/2)),.T.,.F. )
	oGraficos[Len(oGraficos)][07]:Align := CONTROL_ALIGN_RIGHT

	oGraficos[Len(oGraficos)][08] := MSNewGetDados():New(00,00,((oGraficos[Len(oGraficos)][06]:NHEIGHT)/2),((oGraficos[Len(oGraficos)][06]:NWIDTH)/2),2,,.T.,,,,,,,,oGraficos[Len(oGraficos)][06],aHeadErr,aColsErr)
	bComando := "{|| AtuErros()}
	oGraficos[Len(oGraficos)][08]:bChange := &(bComando)

	//bComando := "{|| GETDCLR(oGraficos["+Alltrim(Str(Len(oGraficos)))+"][06]:nAt, nPOSIC_ITEM, nCorSelec) }"
	//bComando := &(bComando)
	//oGraficos[Len(oGraficos)][06]:oBrowse:SetBlkBackColor(bComando)
	oGraficos[Len(oGraficos)][08]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGraficos[Len(oGraficos)][09] := TFolder():New(0,0,{ "Request","Response","Erro Protheus"},{},oGraficos[Len(oGraficos)][07],,,, .T., .F.,oGraficos[Len(oGraficos)][07]:NCLIENTWIDTH/2,oGraficos[Len(oGraficos)][07]:NCLIENTHEIGHT/2,,.T.)
	oGraficos[Len(oGraficos)][09]:Align := CONTROL_ALIGN_ALLCLIENT

	//->> Request
	oGraficos[Len(oGraficos)][10] := ""
	bComando := &("{| u | If( PCount() == 0, oGraficos["+Alltrim(Str(Len(oGraficos)))+"][10], oGraficos["+Alltrim(Str(Len(oGraficos)))+"][10] := u ) }")
	oGraficos[Len(oGraficos)][11] := TMultiGet():New(01,01,bComando,oGraficos[Len(oGraficos)][09]:ADIALOGS[1],((oGraficos[Len(oGraficos)][07]:NWIDTH)/2)-7,((oGraficos[Len(oGraficos)][07]:NHEIGHT)/2)-45,oDlg:oFont,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)

	//->> Response
	oGraficos[Len(oGraficos)][12] := ""
	bComando := &("{| u | If( PCount() == 0, oGraficos["+Alltrim(Str(Len(oGraficos)))+"][12], oGraficos["+Alltrim(Str(Len(oGraficos)))+"][12] := u ) }")
	oGraficos[Len(oGraficos)][13] := TMultiGet():New(01,01,bComando,oGraficos[Len(oGraficos)][09]:ADIALOGS[2],((oGraficos[Len(oGraficos)][07]:NWIDTH)/2)-7,((oGraficos[Len(oGraficos)][07]:NHEIGHT)/2)-45,oDlg:oFont,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)

	//->> Erro Protheus
	oGraficos[Len(oGraficos)][14] := ""
	bComando := &("{| u | If( PCount() == 0, oGraficos["+Alltrim(Str(Len(oGraficos)))+"][14], oGraficos["+Alltrim(Str(Len(oGraficos)))+"][14] := u ) }")
	oGraficos[Len(oGraficos)][15] := TMultiGet():New(01,01,bComando,oGraficos[Len(oGraficos)][09]:ADIALOGS[3],((oGraficos[Len(oGraficos)][07]:NWIDTH)/2)-7,((oGraficos[Len(oGraficos)][07]:NHEIGHT)/2)-45,oDlg:oFont,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)

	//->>TIMMER ATUALIZADOR DE DADOS
	bComando := &("{|| CalAtualiz("+Alltrim(Str(Len(oGraficos)))+") }")
	oGraficos[Len(oGraficos)][16] := TTimer():New(500 /*15 segundos*/, bComando , oDlg )
	oGraficos[Len(oGraficos)][16]:Activate()

	nPPrgInt := Len(oGraficos)

	//*********************************************************************************************************************************************
	//->> Painel de Informações das conexões
	aAdd(oGraficos,Array(05))
	//->>PAINEL PRINCIPAL

	//->>TIMMER ATUALIZADOR DE DADOS
	bComando := &("{|| AtuVelocTrs() }")
	oGraficos[Len(oGraficos)][01] := TTimer():New(500 /*15 segundos*/, bComando , oDlg )
	oGraficos[Len(oGraficos)][01]:Activate()

	//->>PAINEL PRINCIPAL
	oGraficos[Len(oGraficos)][02] := TPanel():New(1,1,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NWIDTH)/2)-1,(50),.T.,.T. )
	oGraficos[Len(oGraficos)][02]:Align := CONTROL_ALIGN_BOTTOM
	//->>PAINEL SECUNDARIO
	oGraficos[Len(oGraficos)][03] := TPanel():New(1,1,'',oGraficos[Len(oGraficos)][02], oDlg:oFont, .T., .T.,,,((oGraficos[Len(oGraficos)][02]:NWIDTH)/2),(((oGraficos[Len(oGraficos)][02]:NHEIGHT)/2)),.F.,.T. )
	oGraficos[Len(oGraficos)][03]:Align := CONTROL_ALIGN_TOP
	//->>PAINEL TTOOBOX
	oGraficos[Len(oGraficos)][04] := TToolBox():New(0,0,oGraficos[Len(oGraficos)][02],(oGraficos[Len(oGraficos)][02]:NWIDTH/2),(oGraficos[Len(oGraficos)][02]:NHEIGHT/2))
	oGraficos[Len(oGraficos)][04]:AddGroup(oGraficos[Len(oGraficos)][03] , "Tempo Médio no Update (Registro/Segundo) ")

	oGraficos[Len(oGraficos)][05] := MSNewGetDados():New(00,00,((oGraficos[Len(oGraficos)][03]:NHEIGHT)/2),((oGraficos[Len(oGraficos)][03]:NWIDTH)/2),2,,.T.,,,,,,,,oGraficos[Len(oGraficos)][03],aHeadVel,aColsVel)
	oGraficos[Len(oGraficos)][05]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	nPVlcInt := Len(oGraficos)

	ACTIVATE MSDIALOG oDlg CENTER

	//->> Se conexao estiver aberta, fecha
	oEcomm:Fechar()
EndIf

Return

/*/{protheus.doc} Conecta
*******************************************************************************************
Atualiza a conexao de tempos em tempos
 
@author: Marcelo Celi Marques
@since: 16/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function Conecta(nPos,nValidToken)

oGraficos[nPos][02]:nInterval := (nValidToken * 1000)
oGraficos[nPos][02]:lActive := .F.

oGraficos[nPGrfVds][06]:dDiaAtu := dProcVdas
oGraficos[nPGrfVds][06]:Refresh()

If Valtype(oEcomm)<>"O"
	oEcomm := MCMagento():New()
Else	
	If oEcomm:Liberado()	
		If Valtype(oEcomm:oWsdl)=="O"
			oEcomm:GetToken(.T.)
			If Empty(oEcomm:cToken)
				oEcomm:Iniciar(oEcomm:lJob)
			EndIf
		Else
			oEcomm:Iniciar(oEcomm:lJob)
		EndIf	
	Else
		If !oEcomm:lJob
        	MsgAlert(oEcomm:cMsgBloqueio)
    	EndIf
	EndIf	
EndIf	

If oEcomm:lConectado
	oGraficos[nPos][03]:CRESNAME := cBmpConn	

	oGraficos[nPos][05]:SetText( oEcomm:aDadConex[01] )
	oGraficos[nPos][05]:CtrlRefresh()

	oGraficos[nPos][07]:SetText( oEcomm:aDadConex[02] )
	oGraficos[nPos][07]:CtrlRefresh()

	oGraficos[nPos][09]:SetText( oEcomm:aDadConex[03] )
	oGraficos[nPos][09]:CtrlRefresh()

	oGraficos[nPos][11]:SetText( oEcomm:aDadConex[04] )
	oGraficos[nPos][11]:CtrlRefresh()

	oGraficos[nPos][13]:SetText( oEcomm:cUrl )
	oGraficos[nPos][13]:CtrlRefresh()

	oGraficos[nPos][15]:CBMPFILE := oEcomm:cLogo
	oGraficos[nPos][15]:Refresh()

	lConectado	:= .T.
Else
	oGraficos[nPos][03]:CRESNAME := cBmpNoConn
	lConectado	:= .F.
EndIf

oGraficos[nPos][03]:Refresh()

oGraficos[nPos][02]:lActive := .T.

Return

/*/{protheus.doc} BO1BlqBot
*******************************************************************************************
Atualiza o Botao
 
@author: Marcelo Celi Marques
@since: 07/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BO1BlqBot()
oGraficos[nPDadConx][14]:lActive := .F.
oGraficos[nPDadConx][14]:nInterval := 1000

If lConectado
	If oEcomm:lOpCli // Botao Cliente
		oButtons[01,01]:lActive := .T.
	Else
		oButtons[01,01]:lActive := .F.
	EndIf	

	If oEcomm:lOpPrd // Botao Produtos
		oButtons[02,01]:lActive := .T.
	Else
		oButtons[02,01]:lActive := .F.
	EndIf

	If oEcomm:lOpCat // Botao Categorias
		oButtons[03,01]:lActive := .T.
	Else
		oButtons[03,01]:lActive := .F.
	EndIf	

	If oEcomm:lOpEst // Botao Estoque
		oButtons[04,01]:lActive := .T.
	Else
		oButtons[04,01]:lActive := .F.
	EndIf	

	If oEcomm:lOpPrc // Botao Precos
		oButtons[05,01]:lActive := .T.
	Else
		oButtons[05,01]:lActive := .F.
	EndIf	

	oButtons[06,01]:lActive := .T.
Else
	oButtons[01,01]:lActive := .F.
	oButtons[02,01]:lActive := .F.
	oButtons[03,01]:lActive := .F.
	oButtons[04,01]:lActive := .F.
	oButtons[05,01]:lActive := .F.
	oButtons[06,01]:lActive := .F.
EndIf

oButtons[07,01]:lActive := .T.
oButtons[08,01]:lActive := .T.

oGraficos[nPDadConx][14]:lActive := .T.

Return

/*/{protheus.doc} GrfAtualiz
*******************************************************************************************
Atualiza os Graficos
 
@author: Marcelo Celi Marques
@since: 07/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GrfAtualiz(nGrf,nPos)
Local aDados 	:= {}
Local aPeriodo	:= {}
Local nX		:= 1
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias() 	
Local nPosDad	:= 0

oGraficos[nPos][08]:nInterval := 60000
oGraficos[nPos][08]:lActive := .F.

Do Case
	Case nGrf == 1 //->> Grafico de Linhas, de progressao de vendas por horario, no dia.
		For nX:=1 to 24
			aAdd(aDados,{StrZero(nX-1,02)+":00",; // 01 - Hora da Venda
						0					   }) // 02 - Valor da Venda
		Next nX

		cQuery := "SELECT"											+CRLF 
		cQuery += "		C5_XDUPDAT 			AS DATA,"				+CRLF 
        cQuery += "    	LEFT(C5_XHUPDAT,2) 	AS HORA,"				+CRLF 
        cQuery += "    	COUNT(C5_XDUPDAT) 	AS QUANT"				+CRLF 
		cQuery += "	FROM "+RetSqlName("SC5")+" SC5 (NOLOCK)"		+CRLF 
		cQuery += "	WHERE 	SC5.C5_FILIAL  = '"+xFilial("SC5")+"'"	+CRLF 
		cQuery += "		AND SC5.C5_XIDECOM <> ' '"					+CRLF 
		cQuery += "		AND SC5.C5_XDUPDAT = '"+dTos(dProcVdas)+"'"	+CRLF
		cQuery += "	GROUP BY C5_XDUPDAT,C5_XHUPDAT"					+CRLF 
		cQuery += "	ORDER BY C5_XDUPDAT,C5_XHUPDAT"					+CRLF
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		Do While (cAlias)->(!Eof())
			nPosDad := Ascan(aDados,{|x| Left(x[01],02) == (cAlias)->HORA })
			If nPosDad > 0
				aDados[nPosDad,02] += (cAlias)->QUANT
			EndIf
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
		
		If Valtype(oGraficos[nPos][07])=="O"
			FreeObj(oGraficos[nPos][07])
		EndIf	
		oGraficos[nPos][07] := FWChartLine():New()
		oGraficos[nPos][07]:init( oGraficos[nPos][05], .T. ) 

		aPeriodo := {}
		For nX:=1 to Len(aDados)
			aAdd(aPeriodo,{aDados[nX,01],Round(aDados[nX,02],2)})
		Next nX
		oGraficos[nPos][07]:addSerie("Faturamento e-Commerce", aPeriodo )
		oGraficos[nPos][07]:setLegend( CONTROL_ALIGN_BOTTOM )
		oGraficos[nPos][07]:Build()

EndCase

oGraficos[nPos][08]:lActive := .T.

Return

/*/{protheus.doc} CalAtualiz
*******************************************************************************************
Atualiza o Calendario de Execuções
 
@author: Marcelo Celi Marques
@since: 12/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CalAtualiz(nPos)
Local aDados 	 := {}
Local nX		 := 1
Local nY		 := 1
Local nResolucao := 4
Local nRetroc	 := 0
Local dIni		 := Date()
Local nHora      := 1
Local nHorAcumul := 0
Local cQuery 	 := ""
Local cAlias	 := GetNextAlias() 	
Local nPosProc	 := 0
Local dInicio	 := dProcVdas
Local nCorCli	 := RGB(63,72,204) 		// azul
Local nCorPrd	 := RGB(0,162,232) 		// cian
Local nCorCat	 := RGB(34,177,76) 		// verde
Local nCorPre	 := RGB(255,242,0) 		// amarelo
Local nCorEst	 := RGB(255,174,201) 	// rosa
Local nCorVda	 := RGB(237,28,36) 		// vermelho
Local aCols		 := {}
Local aColsTmp	 := {}

oGraficos[nPos][16]:lActive := .F.

//->> [01] - Exibição das subidas de clientes
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Subidas de Clientes",{},nCorCli})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'S'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'C'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"			+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

//->> [02] - Exibição das subidas de Produtos
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Subidas de Produtos",{},nCorPrd})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'S'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'P'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"			+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

//->> [03] - Exibição das subidas de Grupos
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Subidas de Categorias",{},nCorCat})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'S'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'T'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"			+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

//->> [04] - Exibição das subidas de Estoque
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Subidas de Estoque",{},nCorEst})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'S'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'E'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"			+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

//->> [05] - Exibição das subidas de Preços
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Subidas de Preços",{},nCorPre})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'S'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'R'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"				+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

//->> [06] - Exibição das descida de Vendas
nHorAcumul := 0
aAdd(aDados,{Len(aDados)+1,"Descida de Vendas",{},nCorVda})
For dIni:=dInicio-nRetroc to dInicio+nRetroc
	For nHora := 0 to 23		
		aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
										( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
										.F.,									; // 03 - Se pertence a seleção
										dIni,									; // 04 - Data
										StrZero(nHora,2) }						) // 05 - Hora
		nHorAcumul++
	Next nHora
Next dIni

cQuery := "SELECT DISTINCT"																			+CRLF
cQuery += "					ZWS_DATA,"																+CRLF
cQuery += "					LEFT(ZWS_HORA,2) AS ZWS_HORA"											+CRLF 
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = 'D'"																+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = 'V'"																+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"			+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "ORDER BY ZWS_DATA, ZWS_HORA"																+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->ZWS_DATA .And. Alltrim(x[05])==Alltrim((cAlias)->ZWS_HORA) })
	If nPosProc > 0
		aDados[Len(aDados),03][nPosProc,03] := .T.
	EndIf	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados[Len(aDados),03])
	If !aDados[Len(aDados),03][nX,03]
		aDados[Len(aDados),03][nX,01] := 0
		aDados[Len(aDados),03][nX,02] := 0
	EndIf
Next nX

If Valtype(oGraficos[nPos][05])=="O"
	FreeObj(oGraficos[nPos][05])
EndIf	

oGraficos[nPos][05] := MsCalendGrid():New(oPanEInteg /*oDlg*/,01/*nCol*/,01/*nCol*/,((oPanEInteg:NWIDTH)/2)-1/*nWidth*/,((oPanEInteg:NHEIGHT)/2)-1/*nHeight*/,dInicio-nRetroc/*Data Inicio*/,nResolucao /*Resolucao*/,/*bWhen*/,{||  }/*bAction*/,RGB(223,218,241)/*nDefColor*/, {|| }/*bRClick*/, .F./*lFilAll*/, 0 /*nTypeUnit 0-Horas, 1-Dias*/ ) 
oGraficos[nPos][05]:Align   := CONTROL_ALIGN_ALLCLIENT
oGraficos[nPos][05]:cTopMsg := "Integrações Realizadas em "+Dtoc(dProcVdas)

For nX:=1 to Len(aDados)
	For nY:=1 to Len(aDados[nX,03])
		oGraficos[nPos][05]:Add(aDados[nX,02] /*Caption*/,aDados[nX,01]/*Numero da Linha*/, aDados[nX,03,nY,01]/*Data Inicial*/,aDados[nX,03,nY,02]/*Data Final*/,aDados[nX,04]/*cor linha*/,"" )
	Next nY
Next nX

//->> Atualiza os erros
oGraficos[nPos][08]:aCols := {}
aErros := {}
cQuery := "SELECT"																					+CRLF
cQuery += "					ZWT.R_E_C_N_O_ AS RECZWT,"												+CRLF
cQuery += "					ZWT.ZWT_DATA,"															+CRLF
cQuery += "					ZWT.ZWT_HORA"															+CRLF
cQuery += "		FROM "+RetSqlName("ZWT")+" ZWT (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWT.ZWT_FILIAL = '"+xFilial("ZWT")+"'"											+CRLF
cQuery += "		AND ZWT.ZWT_DATA BETWEEN '"+dTos(dInicio-nRetroc)+"' AND '"+dTos(dInicio+nRetroc)+"'"				+CRLF
cQuery += "		AND ZWT.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "	ORDER BY ZWT_DATA DESC, ZWT_HORA DESC"													+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	ZWT->(dbGoto((cAlias)->RECZWT))
	aColsTmp := {}
	For nX:=1 to Len(oGraficos[nPos][08]:aHeader)
		aAdd(aColsTmp,ZWT->&(oGraficos[nPos][08]:aHeader[nX,02]))	
	Next nX
	aAdd(aColsTmp,.F.)
	aAdd(aCols,aColsTmp)

	aAdd(aErros,{Len(aCols),ZWT->ZWT_WSREQU,ZWT->ZWT_WSRESP,ZWT->ZWT_ERRPRO})

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())
oGraficos[nPos][08]:aCols := aCols
oGraficos[nPos][08]:Refresh()

If Len(aCols)>0
	AtuErros(1)
EndIf	

Return

/*/{protheus.doc} GetStyloBt
*******************************************************************************************
Retorna o estilo do botÃ£o
 
@author: Marcelo Celi Marques
@since: 07/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetStyloBt(nStylo,cImagem)
Local cEstilo := ""

Do Case
	Case nStylo == 1
		//A classe QPushButton, ela Ã© responsÃ¡vel em criar a formataÃ§Ã£o do botÃ£o. 
	    cEstilo := "QPushButton {"  
	    //Usando a propriedade background-image, inserimos a imagem que serÃ¡ utilizada, a imagem pode ser pega pelo repositÃ³rio (RPO)
	    cEstilo += " background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;" 
	    cEstilo += " border-style: outset;"
	    cEstilo += " border-width: 2px;"
	    cEstilo += " border: 1px solid #C0C0C0;"
	    cEstilo += " border-radius: 5px;"
	    cEstilo += " border-color: #C0C0C0;"
	    cEstilo += " font: bold 12px Arial;"
	    cEstilo += " padding: 6px;"
	    cEstilo += "}"
	 
	    //Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botÃ£o ele muda
	    cEstilo += "QPushButton:pressed {"
	    cEstilo += " background-color: #e6e6f9;"
	    cEstilo += " border-style: inset;"
	    cEstilo += "}"
	                
	Case nStylo == 2 
	    cEstilo := "QPushButton {background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px; "
	    cEstilo += " border-style: outset;"
	    cEstilo += " border-width: 2px;"
	    cEstilo += " border: 1px solid #C0C0C0;"
	    cEstilo += " border-radius: 0px;"
	    cEstilo += " border-color: #C0C0C0;"
	    cEstilo += " font: bold 12px Arial;"
	    cEstilo += " padding: 6px;"
	    cEstilo += "}"
	    cEstilo += "QPushButton:pressed {"
	    cEstilo += " background-color: #e6e6f9;"
	    cEstilo += " border-style: inset;"
	    cEstilo += "}"
	
	OtherWise
	    cEstilo := "QPushButton {background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;}"
    
EndCase
               
Return cEstilo

/*/{protheus.doc} MyEnchBar
*******************************************************************************************
Cria barra de botoes
 
@author: Marcelo Celi Marques
@since: 07/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MyEnchBar(oDlg,bOk,bCancel,aButtons,aButText,lIsEnchoice,lSplitBar,lLegenda,nDirecao,lBGround)
Local nX 		:= 0

DEFAULT aButtons	:= {}
DEFAULT aButText	:= {}
DEFAULT lIsEnchoice := .T.
DEFAULT lSplitBar 	:= .T.
DEFAULT lLegenda  	:= .F.
DEFAULT nDirecao	:= 0
DEFAULT lBGround	:= .T.

If nDirecao == 0
	xDirecao := CONTROL_ALIGN_BOTTOM
ElseIf nDirecao == 1
	xDirecao := CONTROL_ALIGN_TOP	
ElseIf nDirecao == 2
	xDirecao := CONTROL_ALIGN_RIGHT	
Else
	xDirecao := CONTROL_ALIGN_LEFT	
EndIf
	                 
nTam := 15	
	
oButtonBar := FWButtonBar():new()
oButtonBar:Init(oDlg,nTam,15,xDirecao,.T.,lIsEnchoice)

If lIsEnchoice
	oButtonBar:setEnchBar( bOk, bCancel,,,,.T.)
Else
	//Criacao dos botoes de Texto OK e Cancela quando nao for enchoicebar
	If !Empty(bCancel)
		oButtonBar:addBtnText( "Cancela"	, "Cancela"	, bCancel,,,CONTROL_ALIGN_RIGHT, .T.) 
		SetKEY(24,{||Eval(bCancel)})
	Endif

	If !Empty(bOk)
		oButtonBar:addBtnText( "OK"		, "Confirma", bOk,,,CONTROL_ALIGN_RIGHT) 
		SetKEY(15,{||Eval(bOk)})
	Endif
Endif
	
//Criacao dos botoes de texto do usuario ou complementares
If Len(aButText) > 0
	For Nx := 1 to Len(aButText)
		oButtonBar:addBtnText( aButText[nX,1], aButText[nX,2],aButText[nX,3],,, CONTROL_ALIGN_RIGHT)
	Next
Endif

//Se a FAMYBAR esta sendo montada num browse e este tiver legenda alguns botoes padrao sao criados (botao imagem)
If lLegenda
	oButtonBar:addBtnImage( "PMSCOLOR"  , "Legenda"		, {|| FLegenda(FinWindow:cAliasFile, (FinWindow:cAliasFile)->(RECNO()))},, .T., CONTROL_ALIGN_LEFT)
Endif

// criacao dos botoes de imagem do usuario ou complementares
If Len(aButtons) > 0
	For Nx := 1 To Len(aButtons)
		oButtonBar:addBtnImage( aButtons[nX,1], aButtons[nX,3],aButtons[nX,2],,.T., CONTROL_ALIGN_LEFT)
   Next
EndIf

//altera o fundo da buttonbar
If lBGround
	oButtonBar:setBackGround( "toolbar_mdi.png", 000, 000, .T. ) 
EndIf	

If lIsEnchoice
	oButtonBar:AITEMS[1]:LVISIBLECONTROL := .F. 
	oButtonBar:AITEMS[2]:LVISIBLECONTROL := .F.
	oButtonBar:AITEMS[3]:LVISIBLECONTROL := .F.
	oButtonBar:AITEMS[4]:LVISIBLECONTROL := .F.	
EndIf	

Return Nil

/*/{protheus.doc} BOPedByEco
*******************************************************************************************
Desce os pedidos do e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPedByEco(lJob,oEcomm)
Local lOk      		:= .F.
Local aArea     	:= GetArea()
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""
Local dInicio		:= GetDataVda()
Local dFim			:= dInicio
Local nTipo			:= 1

Private aRet01Param := {}

Default lJob    := .F.

If LockByName("MAGENTO_DESCE_PEDIDOS",.T.,.F.)
    If lJob
        lOk := .T.
		Conout("Execução das baixas de pedidos do e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
		aAdd( aRet01Param, dInicio																	 )
		aAdd( aRet01Param, dFim  																	 )        

        aAdd( aBox01Param,{1,"Vendas de"	,aRet01Param[01] ,"@!"			,""	,""	,".T.",070	,.T.})
		aAdd( aBox01Param,{1,"Vendas ate"	,aRet01Param[02] ,"@!"			,""	,""	,".T.",070	,.T.})
        
        cTextApres := "Este recurso possibilita a descida das vendas do e-Commerce."

        oWizard := APWizard():New(  "Vendas",   			             												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao das vendas", 				             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma a Descida das Vendas do e-Commerce"), lOk }, 	                 ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma a Descida das Vendas do e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        dInicio  := aRet01Param[01]
		dFim  	 := aRet01Param[02]

    EndIf
    If lOk
        u_BOPrcPedEC(lJob,oEcomm,nTipo,dInicio,dFim)
    Else
        UnLockByName("MAGENTO_DESCE_PEDIDOS",.T.,.F.)
    EndIf    
	
Else
	If !lJob
		MsgAlert("A Baixa das Vendas já está sendo realizada no momento.")
	EndIf
EndIf

If !lJob
	CalAtualiz(nPPrgInt)
	GrfAtualiz(1,nPGrfVds)
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOPrcPedEC
*******************************************************************************************
Processamento da descida dos pedidos do e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPrcPedEC(lJob,oEcomm,nTipo,dInicio,dFim)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:DesceVendas(nTipo,dInicio,dFim)
    Else
        MsgRun("Descendo Vendas do e-Commerce...","Aguarde",{|| oEcomm:DesceVendas(nTipo,dInicio,dFim) })
    EndIf    
EndIf

UnLockByName("MAGENTO_DESCE_PEDIDOS",.T.,.F.)

Return

/*/{protheus.doc} BOCliToEco
*******************************************************************************************
Sobe clientes para o e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOCliToEco(lJob,oEcomm)
Local lOk           := .F.
Local aArea         := GetArea()
Local cCliDe        := NIL // Deve iniciar com NIL
Local cLojaDe       := NIL // Deve iniciar com NIL
Local cCliAte       := NIL // Deve iniciar com NIL
Local cLojaAte      := NIL // Deve iniciar com NIL
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""

Private aRet01Param := {}

Default lJob    := .F.

If LockByName("MAGENTO_SOBE_CLIENTES",.T.,.F.)
    If lJob
        lOk := .T.        
		Conout("Execução das subidas de clientes para o e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
        aAdd( aRet01Param, Replicate(" ",Tamsx3("A1_COD")[01])	)
        aAdd( aRet01Param, Replicate(" ",Tamsx3("A1_LOJA")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("A1_COD")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("A1_LOJA")[01])	)

        aAdd( aBox01Param,{1,"Cliente de"							,aRet01Param[01] ,"@!"			,""	,"SA1"	,".T.",050	,.F.})
        aAdd( aBox01Param,{1,"Loja de"								,aRet01Param[02] ,"@!"			,""	,""		,".T.",020	,.F.})
        aAdd( aBox01Param,{1,"Cliente ate"							,aRet01Param[03] ,"@!"			,""	,"SA1"	,".T.",050	,.F.})
        aAdd( aBox01Param,{1,"Loja ate"								,aRet01Param[04] ,"@!"			,""	,""		,".T.",020	,.F.})

        cTextApres := "Este recurso possibilita o envio do cadastro de clientes para o e-Commerce."

        oWizard := APWizard():New(  "Cadastro de Clientes",                												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },       											 					     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },         											 						 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao dos clientes", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Clientes ao e-Commerce"), lOk }, 	                 ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Clientes ao e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        cCliDe   := aRet01Param[01]
        cLojaDe  := aRet01Param[02]
        cCliAte  := aRet01Param[03]
        cLojaAte := aRet01Param[04]

    EndIf
    If lOk
        u_BOPrcCliEC(lJob,cCliDe,cLojaDe,cCliAte,cLojaAte,If(!lJob,@oEcomm,NIL))
    Else
        UnLockByName("MAGENTO_SOBE_CLIENTES",.T.,.F.)
    EndIf    

	If !lJob
		CalAtualiz(nPPrgInt)
		oGraficos[nPVlcInt][05]:aCols[01,01] := CalcVelocTr(Date()-5,Date(),"S","C")
		oGraficos[nPVlcInt][05]:Refresh()
	EndIf

Else
	If !lJob
		MsgAlert("A Subida dos Clientes já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOPrcCliEC
*******************************************************************************************
Processamento da subida dos clientes para o e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPrcCliEC(lJob,cCliDe,cLojaDe,cCliAte,cLojaAte,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:SobeClientes()
    Else
        MsgRun("Subindo Clientes ao e-Commerce...","Aguarde",{|| oEcomm:SobeClientes(cCliDe,cLojaDe,cCliAte,cLojaAte) })
    EndIf    
EndIf

UnLockByName("MAGENTO_SOBE_CLIENTES",.T.,.F.)

Return

/*/{protheus.doc} AMDHMS2S
*******************************************************************************************
Converte string de AAAAMMDD HH:MM:SS em segundos
 
@author: Marcelo Celi Marques
@since: 13/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AMDHMS2S(cPerIni,cPerFim)
Local nSeg	:= 0
Local nAA 	:= Val(SubStr(cPerIni,01,04))
Local nMM 	:= Val(SubStr(cPerIni,05,02))
Local nDD 	:= Val(SubStr(cPerIni,07,02))
Local nHH 	:= Val(SubStr(cPerIni,10,2))
Local nMN 	:= Val(SubStr(cPerIni,13,2))
Local nSS 	:= Val(SubStr(cPerIni,16,02))

If cPerFim >= cPerIni
	Do While .T.
		If StrZero(nAA,4)+StrZero(nMM,2)+StrZero(nDD,2)+" "+StrZero(nHH,2)+":"+StrZero(nMN,2)+":"+StrZero(nSS,2) == Alltrim(cPerFim)
			Exit
		Else
			nSeg++
			
			nSS++
			If nSS>=60
				nSS:=0
				nMN++
			EndIf
			If nMN>=60
				nMN:=0
				nHH++
			EndIf
			If nHH>=24
				nHH:=0
				nDD++
			EndIf
			If nMM==1 .Or. nMM==3 .Or. nMM==5 .Or. nMM==7 .Or. nMM==8 .Or. nMM==10 .Or. nMM==12		
				If nDD>31
					nDD := 1
					nMM++
				EndIf
			ElseIf nMM==4 .Or. nMM==6 .Or. nMM==9 .Or. nMM==11
				If nDD>30
					nDD := 1
					nMM++
				EndIf
			Else
				If nAA % 4 == 0
					If nDD>29
						nDD := 1
						nMM++
					EndIf
				Else
					If nDD>28
						nDD := 1
						nMM++
					EndIf
				EndIf
			EndIf
			If nMM > 12
				nAA++
				nMM:= 1
			EndIf
		EndIf
	EndDo
EndIf

Return nSeg

/*/{protheus.doc} AMDHMS2S
*******************************************************************************************
Converte string de AAAAMMDD HH:MM:SS em segundos
 
@author: Marcelo Celi Marques
@since: 13/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CalcVelocTr(dInicio,dFim,cOper,cTipo)
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local aDados	:= {}
Local nMedia	:= 0
Local nX		:= 0

cQuery := "SELECT "																					+CRLF
cQuery += "					ZWS.R_E_C_N_O_ AS RECZWS"												+CRLF
cQuery += "		FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"											+CRLF
cQuery += "	WHERE 	ZWS.ZWS_FILIAL = '"+xFilial("ZWS")+"'"											+CRLF
cQuery += "		AND ZWS.ZWS_OPER = '"+cOper+"'"														+CRLF
cQuery += "		AND ZWS.ZWS_TIPO = '"+cTipo+"'"														+CRLF
cQuery += "		AND ZWS.ZWS_DATA BETWEEN '"+dTos(dInicio)+"' AND '"+dTos(dFim)+"'"					+CRLF
cQuery += "		AND ZWS.D_E_L_E_T_ = ' '"															+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	ZWS->(dbGoto((cAlias)->RECZWS))
	aAdd(aDados, ZWS->ZWS_QTDGRV / AMDHMS2S(ZWS->ZWS_INICIO,ZWS->ZWS_FINAL) )
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aDados)
	nMedia += aDados[nX]
Next nX
nMedia /= Len(aDados)
nMedia := Round(nMedia,5)

Return nMedia

/*/{protheus.doc} AtuVelocTrs
*******************************************************************************************
Atualiza os campos de velocidade em tela
 
@author: Marcelo Celi Marques
@since: 13/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuVelocTrs()

//->> Desabilita relogio
oGraficos[nPVlcInt][01]:lActive := .F.
oGraficos[nPVlcInt][01]:nInterval := 60000

//->> Clientes
oGraficos[nPVlcInt][05]:aCols[01,01] := CalcVelocTr(Date()-5,Date(),"S","C")
//->> Produtos
oGraficos[nPVlcInt][05]:aCols[01,02] := CalcVelocTr(Date()-5,Date(),"S","P")
//->> Grupos
oGraficos[nPVlcInt][05]:aCols[01,03] := CalcVelocTr(Date()-5,Date(),"S","T")
//->> Estoques
oGraficos[nPVlcInt][05]:aCols[01,04] := CalcVelocTr(Date()-5,Date(),"S","E")
//->> Preços
oGraficos[nPVlcInt][05]:aCols[01,05] := CalcVelocTr(Date()-5,Date(),"S","R")

oGraficos[nPVlcInt][05]:Refresh()

//->> Habilita relogio
oGraficos[nPVlcInt][01]:lActive := .T.

Return

/*/{protheus.doc} BOPrdToEco
*******************************************************************************************
Sobe produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 13/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPrdToEco(lJob,oEcomm)
Local lOk           := .F.
Local aArea         := GetArea()
Local cProdDe       := NIL // Deve iniciar com NIL
Local cProdAte      := NIL // Deve iniciar com NIL
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""

Private aRet01Param := {}

Default lJob    := .F.

//->> Testar
//aItens := oEcomm:GetDadProdut('7898453412784')

If LockByName("MAGENTO_SOBE_PRODUTOS",.T.,.F.)
    If lJob
        lOk := .T.        
		Conout("Execução das subidas de produtos para o e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
        aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_COD")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("B1_COD")[01])	)
        
        aAdd( aBox01Param,{1,"Produto de"							,aRet01Param[01] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        aAdd( aBox01Param,{1,"Produto ate"							,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        
        cTextApres := "Este recurso possibilita o envio do cadastro de produtos para o e-Commerce."

        oWizard := APWizard():New(  "Cadastro de Produtos",                												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao dos produtos", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Produtos ao e-Commerce"), lOk }, 	                 ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Produtos ao e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        cProdDe   := aRet01Param[01]
        cProdAte  := aRet01Param[02]
        
    EndIf
    If lOk
        u_BOPrcPrdEC(lJob,cProdDe,cProdAte,If(!lJob,@oEcomm,NIL))
    Else
        UnLockByName("MAGENTO_SOBE_PRODUTOS",.T.,.F.)
    EndIf    

	If !lJob
		CalAtualiz(nPPrgInt)
		oGraficos[nPVlcInt][05]:aCols[01,02] := CalcVelocTr(Date()-5,Date(),"S","P")
		oGraficos[nPVlcInt][05]:Refresh()
	EndIf

Else
	If !lJob
		MsgAlert("A Subida dos Produtos já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOPrcPrdEC
*******************************************************************************************
Processamento da subida dos produtos para o e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPrcPrdEC(lJob,cProdDe,cProdAte,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:SobeProdutos()
    Else
        MsgRun("Subindo Produtos ao e-Commerce...","Aguarde",{|| oEcomm:SobeProdutos(cProdDe,cProdAte) })
    EndIf    
EndIf

UnLockByName("MAGENTO_SOBE_PRODUTOS",.T.,.F.)

Return

/*/{protheus.doc} BOEstToEco
*******************************************************************************************
Sobe estoques para o e-commerce
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOEstToEco(lJob,oEcomm)
Local lOk           := .F.
Local aArea         := GetArea()
Local cProdDe       := NIL // Deve iniciar com NIL
Local cProdAte      := NIL // Deve iniciar com NIL
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""

Private aRet01Param := {}

Default lJob    := .F.

If LockByName("MAGENTO_SOBE_ESTOQUES",.T.,.F.)
    If lJob
        lOk := .T.        
		Conout("Execução das subidas de estoques para o e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
        aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_COD")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("B1_COD")[01])	)
        
        aAdd( aBox01Param,{1,"Produto de"							,aRet01Param[01] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        aAdd( aBox01Param,{1,"Produto ate"							,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        
        cTextApres := "Este recurso possibilita o envio do estoque de produtos para o e-Commerce."

        oWizard := APWizard():New(  "Estoque de Produtos",                												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao dos produtos", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Estoques ao e-Commerce"), lOk }, 	                 ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Estoques ao e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        cProdDe   := aRet01Param[01]
        cProdAte  := aRet01Param[02]
        
    EndIf
    If lOk
        u_BOEstPrdEC(lJob,cProdDe,cProdAte,If(!lJob,@oEcomm,NIL))
    Else
        UnLockByName("MAGENTO_SOBE_ESTOQUES",.T.,.F.)
    EndIf    

	If !lJob
		CalAtualiz(nPPrgInt)
		oGraficos[nPVlcInt][05]:aCols[01,04] := CalcVelocTr(Date()-5,Date(),"S","E")
		oGraficos[nPVlcInt][05]:Refresh()
	EndIf

Else
	If !lJob
		MsgAlert("A Subida dos Estoques já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOEstPrdEC
*******************************************************************************************
Processamento da subida dos estoques para o e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOEstPrdEC(lJob,cProdDe,cProdAte,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:SobeEstoque()
    Else
        MsgRun("Subindo Estoques ao e-Commerce...","Aguarde",{|| oEcomm:SobeEstoque(cProdDe,cProdAte) })
    EndIf    
EndIf

UnLockByName("MAGENTO_SOBE_ESTOQUES",.T.,.F.)

Return

/*/{protheus.doc} BOPreToEco
*******************************************************************************************
Sobe precos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPreToEco(lJob,oEcomm)
Local lOk           := .F.
Local aArea         := GetArea()
Local cProdDe       := NIL // Deve iniciar com NIL
Local cProdAte      := NIL // Deve iniciar com NIL
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""

Private aRet01Param := {}

Default lJob    := .F.

If LockByName("MAGENTO_SOBE_PRECOS",.T.,.F.)
    If lJob
        lOk := .T.        
		Conout("Execução das subidas de preços para o e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
        aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_COD")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("B1_COD")[01])	)
        
        aAdd( aBox01Param,{1,"Produto de"							,aRet01Param[01] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        aAdd( aBox01Param,{1,"Produto ate"							,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        
        cTextApres := "Este recurso possibilita o envio do preços de produtos para o e-Commerce."

        oWizard := APWizard():New(  "Preços de Produtos",                												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao dos produtos", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Preços ao e-Commerce"), lOk }, 	     		         ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Preços ao e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        cProdDe   := aRet01Param[01]
        cProdAte  := aRet01Param[02]
        
    EndIf
    If lOk
        u_BOPrePrdEC(lJob,cProdDe,cProdAte,If(!lJob,@oEcomm,NIL))
    Else
        UnLockByName("MAGENTO_SOBE_PRECOS",.T.,.F.)
    EndIf    

	If !lJob
		CalAtualiz(nPPrgInt)
		oGraficos[nPVlcInt][05]:aCols[01,05] := CalcVelocTr(Date()-5,Date(),"S","R")
		oGraficos[nPVlcInt][05]:Refresh()
	EndIf

Else
	If !lJob
		MsgAlert("A Subida dos Preços já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOPrePrdEC
*******************************************************************************************
Processamento da subida dos preços para o e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOPrePrdEC(lJob,cProdDe,cProdAte,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:SobePrecos()
    Else
        MsgRun("Subindo Preços ao e-Commerce...","Aguarde",{|| oEcomm:SobePrecos(cProdDe,cProdAte) })
    EndIf    
EndIf

UnLockByName("MAGENTO_SOBE_PRECOS",.T.,.F.)

Return

/*/{protheus.doc} BOCatToEco
*******************************************************************************************
Sobe categorias para o e-commerce
 
@author: Marcelo Celi Marques
@since: 20/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOCatToEco(lJob,oEcomm)
Local lOk           := .F.
Local aArea         := GetArea()
Local cCategDe      := NIL // Deve iniciar com NIL
Local cCategAte     := NIL // Deve iniciar com NIL
Local oWizard		:= NIL
Local aBox01Param 	:= {}
Local cTextApres	:= ""

Private aRet01Param := {}

Default lJob    := .F.

If LockByName("MAGENTO_SOBE_CATEGORIAS",.T.,.F.)
    If lJob
        lOk := .T.        
		Conout("Execução das subidas de categorias para o e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
        aAdd( aRet01Param, Replicate(" ",Tamsx3("BM_GRUPO")[01])	)
        aAdd( aRet01Param, Replicate("Z",Tamsx3("BM_GRUPO")[01])	)
        
        aAdd( aBox01Param,{1,"Grupo de"				,aRet01Param[01] ,"@!"			,""	,"SBM"	,".T.",050	,.F.})
        aAdd( aBox01Param,{1,"Grupo ate"			,aRet01Param[02] ,"@!"			,""	,"SBM"	,".T.",050	,.F.})
        
        cTextApres := "Este recurso possibilita o envio do cadastro de grupos para o e-Commerce."

        oWizard := APWizard():New(  "Cadastro de Categorias",                												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                            "Informe os parametros para a selecao dos grupos", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                            {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Grupos ao e-Commerce"), lOk }, 	                 ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                            {|| lOk:=MsgYesNo("Confirma o Envio dos Grupos ao e-Commerce"), lOk },  		             ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                            .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
                
        cCategDe   := aRet01Param[01]
        cCategAte  := aRet01Param[02]        
    EndIf
    If lOk
        u_BOCatPrdEC(lJob,cCategDe,cCategAte,If(!lJob,@oEcomm,NIL))
    Else
        UnLockByName("MAGENTO_SOBE_CATEGORIAS",.T.,.F.)
    EndIf    

	If !lJob
		CalAtualiz(nPPrgInt)
		oGraficos[nPVlcInt][05]:aCols[01,03] := CalcVelocTr(Date()-5,Date(),"S","T")
		oGraficos[nPVlcInt][05]:Refresh()
	EndIf

Else
	If !lJob
		MsgAlert("A Subida das Categorias já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOCatPrdEC
*******************************************************************************************
Processamento da subida dos grupos para o e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOCatPrdEC(lJob,cCategDe,cCategAte,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:SobeCategoria()
    Else
        MsgRun("Subindo Categorias ao e-Commerce...","Aguarde",{|| oEcomm:SobeCategoria(cCategDe,cCategAte) })
    EndIf    
EndIf

UnLockByName("MAGENTO_SOBE_CATEGORIAS",.T.,.F.)

Return

/*/{protheus.doc} GetDataVda
*******************************************************************************************
Retorna a ultima data de venda baixada na integração
 
@author: Marcelo Celi Marques
@since: 17/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDataVda()
Local dVenda := Stod("20000101")
Local dCorte := GetNewPar("MC_MAGEDCO",Date()-365)
Local cQuery := ""
Local cAlias := GetNextAlias()

cQuery := "SELECT TOP 1"											+CRLF 
cQuery += "		ZWS_MOVIM FROM "+RetSqlName("ZWS")+" ZWS (NOLOCK)"	+CRLF
cQuery += "		WHERE 	ZWS_FILIAL     = '"+xFilial("ZWS")+"'"		+CRLF
cQuery += "			AND ZWS_MOVIM     <> ' '"						+CRLF
cQuery += "			AND ZWS_OPER       = 'D'"						+CRLF
cQuery += "			AND ZWS_TIPO       = 'V'"						+CRLF
cQuery += "			AND ZWS.D_E_L_E_T_ = ''"						+CRLF
cQuery += "		ORDER BY ZWS_MOVIM DESC"							+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	dVenda := Stod((cAlias)->ZWS_MOVIM)
EndIf
(cAlias)->(dbSkip())

If dVenda < dCorte
	dVenda := dCorte
EndIf

Return dVenda

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 21/08/2020
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

/*/{protheus.doc} AtuErros
*******************************************************************************************
Atualiza comandos de erros
 
@author: Marcelo Celi Marques
@since: 21/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuErros(nPos)
Default nPos := oGraficos[nPPrgInt][08]:nAt

If Len(aErros)>=nPos
	oGraficos[nPPrgInt][10] := aErros[nPos][02]
	oGraficos[nPPrgInt][11]:Refresh()

	oGraficos[nPPrgInt][12] := aErros[nPos][03]
	oGraficos[nPPrgInt][13]:Refresh()

	oGraficos[nPPrgInt][14] := aErros[nPos][04]
	oGraficos[nPPrgInt][15]:Refresh()
EndIf
Return

/*/{protheus.doc} AtualCalend
*******************************************************************************************
Atualiza os controles ao clicar no calendario
 
@author: Marcelo Celi Marques
@since: 26/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtualCalend()
dProcVdas := oGraficos[nPGrfVds][06]:dDiaAtu
GrfAtualiz(1,nPGrfVds)
CalAtualiz(nPPrgInt)
oGraficos[nPGrfVds][06]:Refresh()
Return

/*/{protheus.doc} VisuIntegr
*******************************************************************************************
Painel de Integração
 
@author: Marcelo Celi Marques
@since: 28/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VisuIntegr(oDlgPrinc,oFonte)
Local oPanel   := NIL
Local oPanButt := NIL
Local oPanDados:= NIL 
Local aButtBar := {}
Local oGrafico := NIL

oPanel := TPanel():New(1,1,'',oDlgPrinc,oFonte, .T., .T.,,,((oDlgPrinc:NWIDTH)/2),((oDlgPrinc:NHEIGHT)/2),.F.,.F. )

oPanButt := TPanel():New(1,1,'',oPanel,oFonte, .T., .T.,,,(15),((oPanel:NHEIGHT)/2),.T.,.F. )
oPanButt:Align := CONTROL_ALIGN_LEFT

aAdd(aButtBar,{"CLIENTE"	,{|| nOpcGrfInt := 1, AjustGrfInt(nOpcGrfInt,@oPanDados,oFonte) 	 },"Clientes Integrados"	})
aAdd(aButtBar,{"PRODUTO"	,{|| nOpcGrfInt := 2, AjustGrfInt(nOpcGrfInt,@oPanDados,oFonte)	 },"Produtos Integrados"	})
aAdd(aButtBar,{"RPMDES"		,{|| nOpcGrfInt := 3, AjustGrfInt(nOpcGrfInt,@oPanDados,oFonte)	 },"Categorias Integrados"	})

MyEnchBar(oPanButt,,,aButtBar,/*aButtonTxt*/,.F.,,,3,.T.)

oPanDados := TPanel():New(1,1,'',oPanel,oFonte, .T., .T.,,,((oPanel:NWIDTH)/2)-15,((oPanel:NHEIGHT)/2)-20,.T.,.F. )
oPanDados:Align := CONTROL_ALIGN_RIGHT

AjustGrfInt(1,@oPanDados,oFonte)

Return oPanel

/*/{protheus.doc} AjustGrfInt
*******************************************************************************************
Ajusta o Grafico de Integrações
 
@author: Marcelo Celi Marques
@since: 28/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustGrfInt(nTipo,oDlgPrinc,oFonte)
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local cTxtOk 	:= ""
Local cTxtNoOk 	:= ""
Local oGrfsPizza:= NIL

Do Case
	Case nTipo == 1
		cQuery := "SELECT 	(SELECT COUNT(*) FROM "+RetSqlName("SA1")+" OK (NOLOCK)"		+CRLF
		cQuery += "			WHERE OK.A1_FILIAL = '"+xFilial("SA1")+"'"						+CRLF
		cQuery += "				AND   OK.A1_XIDECOM <> ' '"									+CRLF
		cQuery += "				AND OK.D_E_L_E_T_ = ' ') AS QTD_OK,"						+CRLF
        cQuery += "      	(SELECT COUNT(*) FROM "+RetSqlName("SA1")+" NOOK (NOLOCK)"		+CRLF
		cQuery += "				WHERE NOOK.A1_FILIAL = '"+xFilial("SA1")+"'"				+CRLF
		cQuery += "				AND   NOOK.A1_XIDECOM =	' '"								+CRLF
		cQuery += "				AND NOOK.D_E_L_E_T_ = ' ') AS QTD_NOOK"						+CRLF

		cTxtOk 		:= "Clientes Integrados"
		cTxtNoOk 	:= "Clientes Pendentes Integração"

	Case nTipo == 2
		cQuery := "SELECT 	(SELECT COUNT(*) FROM "+RetSqlName("SB1")+" OK (NOLOCK)"		+CRLF
		cQuery += "			WHERE OK.B1_FILIAL = '"+xFilial("SB1")+"'"						+CRLF
		cQuery += "				AND   OK.B1_XIDECOM <> ' '"									+CRLF
		cQuery += "				AND OK.D_E_L_E_T_ = ' ') AS QTD_OK,"						+CRLF
        cQuery += "      	(SELECT COUNT(*) FROM "+RetSqlName("SB1")+" NOOK (NOLOCK)"		+CRLF
		cQuery += "				WHERE NOOK.B1_FILIAL = '"+xFilial("SB1")+"'"				+CRLF
		cQuery += "				AND   NOOK.B1_XIDECOM =	' '"								+CRLF
		cQuery += "				AND NOOK.D_E_L_E_T_ = ' ') AS QTD_NOOK"						+CRLF

		cTxtOk 		:= "Produtos Integrados"
		cTxtNoOk 	:= "Produtos Pendentes Integração"

	Case nTipo == 3
		cQuery := "SELECT 	(SELECT COUNT(*) FROM "+RetSqlName("SBM")+" OK (NOLOCK)"		+CRLF
		cQuery += "			WHERE OK.BM_FILIAL = '"+xFilial("SBM")+"'"						+CRLF
		cQuery += "				AND   OK.BM_XIDECOM <> ' '"									+CRLF
		cQuery += "				AND OK.D_E_L_E_T_ = ' ') AS QTD_OK,"						+CRLF
        cQuery += "      	(SELECT COUNT(*) FROM "+RetSqlName("SBM")+" NOOK (NOLOCK)"		+CRLF
		cQuery += "				WHERE NOOK.BM_FILIAL = '"+xFilial("SBM")+"'"				+CRLF
		cQuery += "				AND   NOOK.BM_XIDECOM =	' '"								+CRLF
		cQuery += "				AND NOOK.D_E_L_E_T_ = ' ') AS QTD_NOOK"						+CRLF

		cTxtOk 		:= "Categorias Integradas"
		cTxtNoOk 	:= "Categorias Pendentes Integração"

EndCase	

oGrfsPizza := FWChartPie():New()
oGrfsPizza:init( oDlgPrinc, .T. ) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	oGrfsPizza:addSerie( cTxtOk		, (cAlias)->QTD_OK 	 )
	oGrfsPizza:addSerie( cTxtNoOk	, (cAlias)->QTD_NOOK )	
EndIf
(cAlias)->(dbCloseArea())
oGrfsPizza:setLegend( CONTROL_ALIGN_LEFT )
oGrfsPizza:Build()

Return 


/*/{protheus.doc} BOLinkPrd
*******************************************************************************************
Linka os produtos do site com o protheus
 
@author: Marcelo Celi Marques
@since: 22/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOLinkPrd(lJob,oEcomm)
Local lOk      		:= .F.
Local aArea     	:= GetArea()
Local oWizard		:= NIL
Local cTextApres	:= ""
Local nTipo			:= 1

Default lJob    := .F.

If LockByName("MAGENTO_LINKA_PRODUTOS",.T.,.F.)
    If lJob
        lOk := .T.
		Conout("Execução das linkagens de produtos do e-commerce por job: "+Dtoc(Date())+" - "+Time())
    Else
		
        cTextApres := "Este recurso possibilita linkar os produtos do protheus com os do e-Commerce."

        oWizard := APWizard():New(  "Cadastros de Produtos",   			             												 ;   // chTitle  - Titulo do cabecalho
                                    "Integração de Atualização", 								         			     ;   // chMsg    - Mensagem do cabecalho
                                    "e-Commerce",        													 		     ;   // cTitle   - Titulo do painel de apresentacao
                                    cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                                    {|| lOk:=MsgYesNo("Confirma a linkagem dos produtos do e-Commerce com o protheus"), lOk },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| lOk:=MsgYesNo("Confirma a linkagem dos produtos do e-Commerce com o protheus"), lOk },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    NIL,  		        												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo    
        
    EndIf
    If lOk
        u_BOLink2Prd(lJob,oEcomm)
    Else
        UnLockByName("MAGENTO_LINKA_PRODUTOS",.T.,.F.)
    EndIf    
	
Else
	If !lJob
		MsgAlert("A linkagem dos produtos já está sendo realizada no momento.")
	EndIf
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} BOLink2Prd
*******************************************************************************************
Processamento da descida das linkagens de produtos e-commerce em outra thread
 
@author: Marcelo Celi Marques
@since: 22/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOLink2Prd(lJob,oEcomm)
Default oEcomm := MCMagento():New()
If oEcomm:lConectado
    If lJob
        oEcomm:LinkProdutos()
    Else
        MsgRun("Linkando Produtos do e-Commerce...","Aguarde",{|| oEcomm:LinkProdutos() })
    EndIf    
EndIf

UnLockByName("MAGENTO_LINKA_PRODUTOS",.T.,.F.)

Return

/*/{protheus.doc} VldRotina
*******************************************************************************************
Valida se rotina pode ser executada.
 
@author: Marcelo Celi Marques
@since: 04/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VldRotina()
Local lRet 		:= .T.
Local cFilExec	:= GetNewPar("MC_FILECOM","")

If Alltrim(cFilExec) == Alltrim(cFilAnt)
	lRet := .T.
Else
	lRet := .F.
	MsgAlert("Filial inválida para uso do e-commerce.")
EndIf

Return lRet



//If(!ISINCALLSTACK("U_BoCentrEco"),GetSXENum("SC5","C5_NUM"),"")
