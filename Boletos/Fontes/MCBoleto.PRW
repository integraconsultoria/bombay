#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#INCLUDE "Ap5Mail.Ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

Static cMVINSIRF  		:= nil
Static lPCCBaixa  		:= nil
Static dLastPcc   		:= nil
Static __cChvSEA  		:= ""
Static __cFilBor 		:= ""

// Motor de Retencoes
Static __lMotorRet 		:= NIL
Static __lPccMR 		:= .F.
Static __lIrfMR 		:= .F.
Static __lIssMR 		:= .F.
Static __lImpMotRet 	:= .F.
Static __lUsaFlag		:= .F.
Static __lImpMT 		:= .F.
Static __nImpMT 		:= 0
Static __nTotImp 		:= 0
Static __lPccBxMR 		:= .F.
//Static __lIrfBxMR 		:= .F.

/*/{protheus.doc} MCBoleto
*******************************************************************************************
Gera��o de Boletos
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MCBoleto()
Local aBoxMsgPara 	:= {}
Local aBox01Param 	:= {}
Local aBox02Param 	:= {}
Local aBox03Param 	:= {}
Local aBox04Param 	:= {}
Local aBox05Param 	:= {}
Local aTipo			:= {"Selecao por Notas Fiscais","Selecao por Titulos de Cobranca","Selecao por Bordero de Cobrancas"}
Local aModelo		:= {"Modelo 1 - 400 posicoes","Modelo 2 - 240 posicoes"}
Local lOk			:= .F.
Local nX			:= 0

Local cTextApres    := ""
Local cLogotipo     := GetNewpar("MC_LOGOREP","BOL_LOGO.BMP")	// "WIZARD"
Local aCoords       := {}
Local aSize	   		:= MsAdvSize()
Local oTbPan2E2		:= NIL
Local oPan02S		:= NIL
Local oPan02I		:= NIL
Local oPan02E		:= NIL
Local oPan02E1		:= NIL
Local oPanT02E2		:= NIL
Local oPan02E2		:= NIL
Local oPan03S		:= NIL
Local oPan03I		:= NIL
Local oPan04S		:= NIL
Local oPan04I		:= NIL
Local oPan05S		:= NIL
Local oPan05I		:= NIL
Local oPan06S		:= NIL
Local oPan06I		:= NIL
Local oPan07S		:= NIL
Local oPan07I		:= NIL
Local oPan08S		:= NIL
Local oPan08I		:= NIL
Local aBancos		:= {}
Local cPerg			:= "MCGERBOL"
Local aPergunte		:= {}
Local nPosBco		:= 0

Private oWizard		:= NIL
Private aRetMsgPara	:= {}
Private aRet01Param	:= {} 
Private aRet02Param	:= {} 
Private aRet03Param	:= {}
Private aRet04Param	:= {}
Private aRet05Param	:= {}
Private oLbxTitulos := NIL    
Private oLbxProcLog := NIL    
Private aTitulos 	:= {{.F.,"","","","","","","",Stod(""),Stod(""),Stod(""),0,0,"",""}}
Private aLogProc	:= {{.F.,.F.,"","",Stod(""),0,"","","","","","","","",""}}
Private oNo 		:= LoadBitmap( GetResources(), "LBNO" 	)
Private oOk 		:= LoadBitmap( GetResources(), "LBTIK"	)
Private oErro 		:= LoadBitmap( GetResources(), "QMT_NO" )
Private oProc 		:= LoadBitmap( GetResources(), "QMT_OK"	)
Private lRunDblClick:= .T.
Private lChkTWiz 	:= .F.
Private _cBcoBolet	:= ""
Private oBMapL03	:= NIL
Private oBMapL04	:= NIL
Private oBMapL05	:= NIL
Private oBMapL06	:= NIL
Private oBMap03		:= NIL
Private oBMap04		:= NIL
Private oBMap05		:= NIL
Private oBMap06		:= NIL
Private oBMap07		:= NIL
Private oBMap08		:= NIL
Private _aPrint		:= {}
Private _oNumBord	:= NIL
Private _cNumBord	:= ""
Private _cIdent		:= ""

SX1Ajusta(cPerg)
SXBAjusta()
Pergunte(cPerg, .F., , , , , @aPergunte , .T., .T.)

//->> TIPO DE SELE��O E DADOS DO BANCO
aAdd( aRet01Param, If(Empty(MV_PAR01),1,MV_PAR01)											)
aAdd( aRet01Param, If(!Empty(MV_PAR08),MV_PAR08,Replicate(" ",Tamsx3("EE_CODIGO")	[01]))	)
aAdd( aRet01Param, If(!Empty(MV_PAR09),MV_PAR09,Replicate(" ",Tamsx3("EE_AGENCIA")	[01]))	)
aAdd( aRet01Param, If(!Empty(MV_PAR10),MV_PAR10,Replicate(" ",Tamsx3("EE_CONTA")	[01]))	)
aAdd( aRet01Param, If(!Empty(MV_PAR11),MV_PAR11,Replicate(" ",Tamsx3("EE_SUBCTA")	[01]))	)
aAdd( aRet01Param, If(!Empty(MV_PAR02),MV_PAR02,Space(99)) )
aAdd( aRet01Param, If(MV_PAR03==1,.T.,.F.)					)
aAdd( aRet01Param, If(MV_PAR12==1,.T.,.F.)					)
aAdd( aRet01Param, If(MV_PAR13==1,.T.,.F.)					)
aAdd( aRet01Param, If(MV_PAR14==1,.T.,.F.)					)

aAdd( aBox01Param,{3,"Tipo de Selecao"							,aRet01Param[01],aTipo,200,".T.",.T.,".T."})  
aAdd( aBox01Param,{1,"Banco"									,aRet01Param[02] ,"@!"	,""	,"MCBOLE"	,".T.",020	,.T.})
aAdd( aBox01Param,{1,"Agencia"									,aRet01Param[03] ,"@!"	,""	,""			,".T.",040	,.T.})
aAdd( aBox01Param,{1,"Conta"									,aRet01Param[04] ,"@!"	,""	,""			,".T.",060	,.T.})
aAdd( aBox01Param,{1,"Sub Conta"								,aRet01Param[05] ,"@!"	,""	,""			,".T.",040	,.T.})
aAdd( aBox01Param,{1,"Pasta Gravacao"							,aRet01Param[06] ,"@!"	,""	,"MCPBOL"	,".T.",200	,.T.})
aAdd( aBox01Param,{5,"Enviar Boleto por E-Mail"   				,aRet01Param[07],200,".T.",.F.})
aAdd( aBox01Param,{5,"Gerar Bordero Documentos em Carteira"     ,aRet01Param[08],200,".T.",.F.})
aAdd( aBox01Param,{5,"Anexar XML da Nota no e-Mail"	   			,aRet01Param[09],200,".T.",.F.})
aAdd( aBox01Param,{5,"Anexar Danfe da Nota no e-Mail"			,aRet01Param[10],200,".T.",.F.})

//->> Mensagem
aAdd( aRetMsgPara, If(!Empty(MV_PAR04),MV_PAR04,0) 	)
aAdd( aRetMsgPara, If(!Empty(MV_PAR05),MV_PAR05,0) 	)
aAdd( aRetMsgPara, If(MV_PAR06==1,.T.,.F.)		   	)
aAdd( aRetMsgPara, If(!Empty(MV_PAR07),MV_PAR07," "))

aAdd( aBoxMsgPara,{1,"Atraso, Multa (%)"			,aRetMsgPara[01] ,"@E 99.999"	,""	,""	,".T.",60	,.F.})
aAdd( aBoxMsgPara,{1,"Atraso, Juros (%)"			,aRetMsgPara[02] ,"@E 99.999"	,""	,""	,".T.",60	,.F.})
aAdd( aBoxMsgPara,{5,"Instrucao de Cobranca Padrao" ,aRetMsgPara[03],200,".T.",.F.})

//->> SELE��O POR NOTA FISCAL
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_SERIE")[01])	)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_DOC")[01]) 		)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_DOC")[01]) 		)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_CLIENTE")[01]) 	)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_LOJA")[01]) 	)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_CLIENTE")[01]) 	)
aAdd( aRet02Param, Replicate(" ",Tamsx3("F2_LOJA")[01]) 	)
aAdd( aRet02Param, Stod("") 								)
aAdd( aRet02Param, Stod("") 								)

aAdd( aBox02Param,{1,"Serie"					, aRet02Param[01]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox02Param,{1,"Nota Fiscal De"			, aRet02Param[02]		,"@!"	,""	,""			,".T.",060	,.F.})
aAdd( aBox02Param,{1,"Nota Fiscal Ate"			, aRet02Param[03]		,"@!"	,""	,""			,".T.",060	,.F.})
aAdd( aBox02Param,{1,"Cliente De"				, aRet02Param[04]		,"@!"	,""	,"SA1"		,".T.",050	,.F.})
aAdd( aBox02Param,{1,"Loja De"					, aRet02Param[05]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox02Param,{1,"Cliente Ate"				, aRet02Param[06]		,"@!"	,""	,"SA1"		,".T.",050	,.F.})
aAdd( aBox02Param,{1,"Loja Ate"					, aRet02Param[07]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox02Param,{1,"Emissao De"				, aRet02Param[08]		,""		,""	,""			,".T.",060	,.F.})
aAdd( aBox02Param,{1,"Emissao Ate"				, aRet02Param[09]		,""		,""	,""			,".T.",060	,.F.})

//->> SELE��O POR CONTAS A RECEBER
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_PREFIXO")[01])	)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_NUM")[01]) 		)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_NUM")[01]) 		)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_CLIENTE")[01]) 	)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_LOJA")[01]) 	)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_CLIENTE")[01]) 	)
aAdd( aRet03Param, Replicate(" ",Tamsx3("E1_LOJA")[01]) 	)
aAdd( aRet03Param, Stod("") 								)
aAdd( aRet03Param, Stod("") 								)
aAdd( aRet03Param, Stod("") 								)
aAdd( aRet03Param, Stod("") 								)

aAdd( aBox03Param,{1,"Prefixo"					, aRet03Param[01]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox03Param,{1,"Numero De"				, aRet03Param[02]		,"@!"	,""	,""			,".T.",060	,.F.})
aAdd( aBox03Param,{1,"Numero Ate"				, aRet03Param[03]		,"@!"	,""	,""			,".T.",060	,.F.})
aAdd( aBox03Param,{1,"Cliente De"				, aRet03Param[04]		,"@!"	,""	,"SA1"		,".T.",050	,.F.})
aAdd( aBox03Param,{1,"Loja De"					, aRet03Param[05]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox03Param,{1,"Cliente Ate"				, aRet03Param[06]		,"@!"	,""	,"SA1"		,".T.",050	,.F.})
aAdd( aBox03Param,{1,"Loja Ate"					, aRet03Param[07]		,"@!"	,""	,""			,".T.",020	,.F.})
aAdd( aBox03Param,{1,"Emissao De"				, aRet03Param[08]		,""		,""	,""			,".T.",060	,.F.})
aAdd( aBox03Param,{1,"Emissao Ate"				, aRet03Param[09]		,""		,""	,""			,".T.",060	,.F.})
aAdd( aBox03Param,{1,"Vencimento De"			, aRet03Param[10]		,""		,""	,""			,".T.",060	,.F.})
aAdd( aBox03Param,{1,"Vencimento Ate"			, aRet03Param[11]		,""		,""	,""			,".T.",060	,.F.})

//->> SELE��O POR BORDERO
aAdd( aRet04Param, Replicate(" ",Tamsx3("E1_NUMBOR")[01])	)
aAdd( aRet04Param, Replicate(" ",Tamsx3("E1_NUMBOR")[01]) 	)

aAdd( aBox04Param,{1,"Bordero De"				, aRet04Param[01]		,"@!"	,""	,""			,".T.",060	,.F.})
aAdd( aBox04Param,{1,"Bordero Ate"				, aRet04Param[02]		,"@!"	,""	,""			,".T.",060	,.F.})

//->> GERACAO DA REMESSA - CNAB
aAdd( aRet05Param, Replicate(" ",Tamsx3("E1_NUMBOR")[01])	)
aAdd( aRet05Param, Replicate(" ",Tamsx3("E1_NUMBOR")[01]) 	)
aAdd( aRet05Param, Replicate(" ",99) 						)
aAdd( aRet05Param, Replicate(" ",99) 						)
aAdd( aRet05Param, Replicate(" ",Tamsx3("EE_CODIGO")[01]) 	)
aAdd( aRet05Param, Replicate(" ",Tamsx3("EE_AGENCIA")[01]) 	)
aAdd( aRet05Param, Replicate(" ",Tamsx3("EE_CONTA")[01]) 	)
aAdd( aRet05Param, Replicate(" ",Tamsx3("EE_SUBCTA")[01]) 	)
aAdd( aRet05Param, 1		 								)
            
aAdd( aBox05Param,{1,"Do Bordero ?"				, aRet05Param[01]		,""		,""	,""			,".F.",040	,.F.})
aAdd( aBox05Param,{1,"Ate o Bordero ?"			, aRet05Param[02]		,""		,""	,""			,".F.",040	,.F.})
aAdd( aBox05Param,{1,"Arquivo de Config. ?"		, aRet05Param[03]		,""		,""	,""			,".T.",180	,.T.})
aAdd( aBox05Param,{1,"Arquivo de Saida ?"		, aRet05Param[04]		,""		,""	,""			,".T.",180	,.T.})
aAdd( aBox05Param,{1,"Codigo do Banco ?"		, aRet05Param[05]		,""		,""	,"MCBOLE"	,".F.",020	,.F.})
aAdd( aBox05Param,{1,"Codigo da Agencia ?"		, aRet05Param[06]		,""		,""	,""			,".F.",040	,.F.})
aAdd( aBox05Param,{1,"Codigo da Conta ?"		, aRet05Param[07]		,""		,""	,""			,".F.",060	,.F.})
aAdd( aBox05Param,{1,"Codigo da Sub-conta ?"	, aRet05Param[08]		,""		,""	,""			,".F.",030	,.F.})
aAdd( aBox05Param,{3,"Configuracao CNAB ?"		, aRet05Param[09]		,aModelo,200,".T.",.T.,".T."})  

aCoords       := {0,0,aSize[6] := aSize[6] - aSize[2] - aSize[8] - 5,aSize[5]}

cTextApres  := "Este recurso possibilita a geracao de Boletos de Cobrancas mediante o Banco Selecionado e encaminha por e-mail aos seus respectivos Pagadores."

//->> Constru��o do Wizard
oWizard := APWizard():New(  "Boletos Bancarios",                												 ;   // chTitle  - Titulo do cabe�alho
                            "Registros de Recebimentos", 								         			     ;   // chMsg    - Mensagem do cabe�alho
                            "BOLETOS",        													 			     ;   // cTitle   - T�tulo do painel de apresenta��o
                            cTextApres,       													 			     ;   // cText    - Texto do painel de apresenta��o
                            {|| .T. },          												 			     ;   // bNext    - Bloco de c�digo a ser executado para validar o bot�o "Avan�ar"
                            {|| .T. },              											 				 ;   // bFinish  - Bloco de c�digo a ser executado para validar o bot�o "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                            cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabe�alho, essa tem que fazer parte do reposit�rio 
                            {|| },                												 			     ;   // bExecute - Bloco de c�digo contendo a a��o a ser executada no clique dos bot�es "Avan�ar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. n�o exibe o painel de apresenta��o
                            aCoords                     										 				 )   // aCoord   - Array contendo as coordenadas da tela

//->> Painel de Parametros Bancarios
oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - T�tulo do painel 
                    "Informe os parametros para a geracao dos boletos", 			             			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| oWizard:NPANEL:=2,.T. },                						         				 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| If(aRet01Param[01]==1,oWizard:NPANEL:=2,If(aRet01Param[01]==2,oWizard:NPANEL:=3,oWizard:NPANEL:=4)),VldParam(1)}, 			     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| If(aRet01Param[01]==1,oWizard:NPANEL:=2,If(aRet01Param[01]==2,oWizard:NPANEL:=3,oWizard:NPANEL:=4)),VldParam(1)},    			 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              							  			   	 ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| .T. }                                            										 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado


		oPan02S := TPanel():New(0,0,'',oWizard:GetPanel(2), oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),80,((oWizard:GetPanel(2):NCLIENTHEIGHT)/2),.F.,.T. )
		oPan02S:Align := CONTROL_ALIGN_LEFT
		
		//->> Botoes de Banco		
		aAdd(aBancos,{"Bradesco"		,"Geracao de Boletos para o Banco Bradesco"					,{""		,"237.bmp"	},{|| _cBcoBolet := "237",AtualizTela()},FindFunction("u_MC237GeBol"),"237"})
		aAdd(aBancos,{"Brasil"			,"Geracao de Boletos para o Banco do Brasil"				,{""		,"001.bmp"	},{|| _cBcoBolet := "001",AtualizTela()},FindFunction("u_MC001GeBol"),"001"})
		aAdd(aBancos,{"Caixa"			,"Geracao de Boletos para o Banco Caixa Economica Federal"	,{""		,"104.bmp"	},{|| _cBcoBolet := "104",AtualizTela()},FindFunction("u_MC104GeBol"),"104"})
		aAdd(aBancos,{"Itau"			,"Geracao de Boletos para o Banco Itau"						,{""		,"341.bmp"	},{|| _cBcoBolet := "341",AtualizTela()},FindFunction("u_MC341GeBol"),"341"})
		aAdd(aBancos,{"Safra"			,"Geracao de Boletos para o Banco Safra"					,{""		,"422.bmp"	},{|| _cBcoBolet := "422",AtualizTela()},FindFunction("u_MC422GeBol"),"422"})		
		aAdd(aBancos,{"Santander"		,"Geracao de Boletos para o Banco Santander"				,{""		,"033.bmp"	},{|| _cBcoBolet := "033",AtualizTela()},FindFunction("u_MC033GeBol"),"033"})		

		If !Empty(aRet01Param[02])
			nPosBco 	:= Ascan(aBancos,{|x|  Alltrim(x[06])==Alltrim(aRet01Param[02]) })
			_cBcoBolet 	:= aRet01Param[02]
		Else
			nPosBco := 0
		EndIf		

		oRdBancos := MCRadioImg():New()
		oRdBancos:Iniciar(oPan02S,1,aBancos,"Selecione o Banco",nPosBco)
				
		oPan02I := TPanel():New(0,0,'',oWizard:GetPanel(2), oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(2):NCLIENTWIDTH)/2)-320,((oWizard:GetPanel(2):NCLIENTHEIGHT)/2),.T.,.F. )
		oPan02I:Align := CONTROL_ALIGN_ALLCLIENT
		
		Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPan02I,,.F.,.F.)

		oPan02E := TPanel():New(0,0,'',oWizard:GetPanel(2), oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),(240),((oWizard:GetPanel(2):NCLIENTHEIGHT)/2),.T.,.F. )
		oPan02E:Align := CONTROL_ALIGN_RIGHT

		oPan02E1 := TPanel():New(0,0,'',oPan02E, oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),((oPan02E:NCLIENTWIDTH)/2),65,.T.,.F. )
		oPan02E1:Align := CONTROL_ALIGN_TOP
		
		Parambox(aBoxMsgPara,"Parametrizacao",@aRetMsgPara,,,,,,oPan02E1,,.F.,.F.)

		oPan02E2 := TPanel():New(0,0,'',oPan02E, oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),((oPan02E:NCLIENTWIDTH)/2),((oPan02E:NCLIENTHEIGHT)/2)-65,.T.,.F. )
		oPan02E2:Align := CONTROL_ALIGN_ALLCLIENT

		oPanT02E2 := TPanel():New(0,0,'',oPan02E2, oWizard:GetPanel(2):oFont, .T., .T.,,Rgb(210,210,210),((oPan02E2:NCLIENTWIDTH)/2),((oPan02E2:NCLIENTHEIGHT)/2),.F.,.F. )
		oPanT02E2:Align := CONTROL_ALIGN_ALLCLIENT

		oTbPan2E2 := TToolBox():New(01,01,oPan02E2,(oPan02E2:NCLIENTWIDTH/2)-2,(oPan02E2:NCLIENTHEIGHT/2)-2)
		oTbPan2E2:AddGroup( oPanT02E2 , "Mensagem complementar das instrucoes no Boleto")	
		
		@ 001,001 GET oTexto VAR aRetMsgPara[04] MEMO NO VSCROLL SIZE (oPanT02E2:NWIDTH/2)-4, (oPanT02E2:NHEIGHT/2)-18 OF oPanT02E2 PIXEL


//->> Painel de Parametros Fiscais
oWizard:NewPanel(   "Parametros",                          							            			     ;   // cTitle   - T�tulo do painel 
                    "Informe os Dados Fiscais para a Selecao dos Documentos",    	            			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| oWizard:NPANEL:=3,.T. },                						    			     	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| oWizard:NPANEL:=5,VldParam(2)}, 													     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| oWizard:NPANEL:=5,VldParam(2)}, 								   						 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              					   					     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| .T. }                                            				   						 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan03S := TPanel():New(0,0,'',oWizard:GetPanel(3), oWizard:GetPanel(3):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(3):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan03S:Align := CONTROL_ALIGN_TOP                             
		
		oBMapL03 := TBitmap():New(00,00,((oPan03S:NCLIENTWIDTH)/2),((oPan03S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan03S,,,.F.,.T.,,,.F.,,.T.,,.F.)		
		oBMap03 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan03S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		oPan03I := TPanel():New(0,0,'',oWizard:GetPanel(3), oWizard:GetPanel(3):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(3):NCLIENTWIDTH)/2),((oWizard:GetPanel(3):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan03I:Align := CONTROL_ALIGN_ALLCLIENT
		
		Parambox(aBox02Param,"Parametrizacao",@aRet02Param,,,,,,oPan03I,,.F.,.F.)	
	
//->> Painel de Parametros Financeiros
oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - T�tulo do painel 
                    "Informe os Dados Financeiros para a Selecao dos Documentos", 	            			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| oWizard:NPANEL:=3,.T. },                						        			 	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| oWizard:NPANEL:=5,VldParam(3)}, 													     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| oWizard:NPANEL:=5,VldParam(3)}, 														 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              										     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| .T. }                                            							 			 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan04S := TPanel():New(0,0,'',oWizard:GetPanel(4), oWizard:GetPanel(4):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(4):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan04S:Align := CONTROL_ALIGN_TOP                             
		oBMapL04 := TBitmap():New(00,00,((oPan04S:NCLIENTWIDTH)/2),((oPan04S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan04S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		oBMap04 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan04S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		oPan04I := TPanel():New(0,0,'',oWizard:GetPanel(4), oWizard:GetPanel(4):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(4):NCLIENTWIDTH)/2),((oWizard:GetPanel(4):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan04I:Align := CONTROL_ALIGN_ALLCLIENT

Parambox(aBox03Param,"Parametrizacao",@aRet03Param,,,,,,oPan04I,,.F.,.F.)	

//->> Painel de Parametros bordero
oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - T�tulo do painel 
                    "Informe os Dados do Bordero para a Selecao dos Documentos", 	            			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| oWizard:NPANEL:=3,.T. },                						        			 	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| oWizard:NPANEL:=5,VldParam(4)}, 													     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| oWizard:NPANEL:=5,VldParam(4)}, 														 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              										     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| .T. }                                            							 			 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan05S := TPanel():New(0,0,'',oWizard:GetPanel(5), oWizard:GetPanel(5):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(5):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan05S:Align := CONTROL_ALIGN_TOP                             
		oBMapL05 := TBitmap():New(00,00,((oPan05S:NCLIENTWIDTH)/2),((oPan05S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan05S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		oBMap05 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan05S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		
		oPan05I := TPanel():New(0,0,'',oWizard:GetPanel(5), oWizard:GetPanel(5):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(5):NCLIENTWIDTH)/2),((oWizard:GetPanel(5):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan05I:Align := CONTROL_ALIGN_ALLCLIENT

Parambox(aBox04Param,"Parametrizacao",@aRet04Param,,,,,,oPan05I,,.F.,.F.)	

//->> Painel de Sele��o de Titulos
oWizard:NewPanel(   "Selecao",                          							            			     ;   // cTitle   - T�tulo do painel 
                    "Selecione os Titulos para a geracao dos Boletos", 				            			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| .F. 				  },                						        			 	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| lOk:= VldParam(5),lOk }, 															     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| lOk:= VldParam(5),lOk }, 																 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              										     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| FwMsgRun( ,{|| GeTitulos() }, , "Aguarde... Selecionando Recebiveis para Selecao..." ) } )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan06S := TPanel():New(0,0,'',oWizard:GetPanel(6), oWizard:GetPanel(6):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(6):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan06S:Align := CONTROL_ALIGN_TOP                             
		oBMapL06 := TBitmap():New(00,00,((oPan06S:NCLIENTWIDTH)/2),((oPan06S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan06S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		oBMap06 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan06S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		
		oPan06I := TPanel():New(0,0,'',oWizard:GetPanel(6), oWizard:GetPanel(6):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(6):NCLIENTWIDTH)/2),((oWizard:GetPanel(6):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan06I:Align := CONTROL_ALIGN_ALLCLIENT

		@ 004,005 SAY OemToAnsi("Bordero:") 						 OF oPan06I PIXEL
		@ 001,030 GET _oNumbord VAR _cNumBord  When .F.	SIZE 050,12	 OF oPan06I PIXEL

		@ 018, 000 LISTBOX oLbxTitulos FIELDS HEADER 	""								,;
					   				  					SE1->(RetTitle("E1_FILIAL"))	,;
									  					SE1->(RetTitle("E1_PREFIXO"))	,;
									  					SE1->(RetTitle("E1_NUM"))  		,;
									  					SE1->(RetTitle("E1_PARCELA"))	,;
									  					SE1->(RetTitle("E1_TIPO"))		,;
									  					SE1->(RetTitle("E1_CLIENTE"))	,;
									  					SE1->(RetTitle("E1_LOJA"))		,;
									  					SE1->(RetTitle("E1_EMISSAO"))	,;
									  					SE1->(RetTitle("E1_VENCTO"))	,;
									  					SE1->(RetTitle("E1_VENCREA"))	,;
														SE1->(RetTitle("E1_SALDO"))	 	,;
														SE1->(RetTitle("E1_PORTADO")) 	,;
														SE1->(RetTitle("E1_NUMBCO")) 	;
											COLSIZES 	5								,;
														10 								,;
														10 								,;
														20 								,;
														05 								,;
														05 								,;
														10 								,;
														05 								,;
														35 								,;
														35 								,;
														35 								,;
									 					50								,;
									 					15								,;
									 					20								 ;
								SIZE (oPan06I:NWIDTH/2)-2,(oPan06I:NHEIGHT/2)-2;
								ON DBLCLICK (If(!Empty(aTitulos[oLbxTitulos:nAt,2]),aTitulos[oLbxTitulos:nAt,1]:=!aTitulos[oLbxTitulos:nAt,1],aTitulos[oLbxTitulos:nAt,1]:=oLbxTitulos[oLbxTitulos:nAt,1]),If(!aTitulos[oLbxTitulos:nAt,1],lChkTWiz := .F., ),oLbxTitulos:Refresh(.f.)) OF oPan06I PIXEL
		
		oLbxTitulos:SetArray(aTitulos)	
		oLbxTitulos:bLine := {|| {If(aTitulos[oLbxTitulos:nAt,1],oOK,oNO),aTitulos[oLbxTitulos:nAt,2],aTitulos[oLbxTitulos:nAt,3],aTitulos[oLbxTitulos:nAt,4],aTitulos[oLbxTitulos:nAt,5],aTitulos[oLbxTitulos:nAt,6],aTitulos[oLbxTitulos:nAt,7],aTitulos[oLbxTitulos:nAt,8],aTitulos[oLbxTitulos:nAt,9],aTitulos[oLbxTitulos:nAt,10],aTitulos[oLbxTitulos:nAt,11],aTitulos[oLbxTitulos:nAt,12],aTitulos[oLbxTitulos:nAt,13],aTitulos[oLbxTitulos:nAt,14]}}
		oLbxTitulos:bRClicked 		:= { || AEVAL(aTitulos,{|x|x[1]:=!x[1]}), oLbxTitulos:Refresh(.F.)}    	
		oLbxTitulos:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aTitulos, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxTitulos:Refresh()}


//->> Painel de Processamento
oWizard:NewPanel(   "Log de Processamento",                          							                 ;   // cTitle   - T�tulo do painel 
                    "Boletos Gerados", 											            			 		 ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| .F. }, 						               						        			 	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| VldParam(6) }, 																		     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| VldParam(6) }, 																			 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              										     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| ProcBoleto(aTitulos,cPerg,aPergunte) }            							 			 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan07S := TPanel():New(0,0,'',oWizard:GetPanel(7), oWizard:GetPanel(7):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(7):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan07S:Align := CONTROL_ALIGN_TOP                             
		oBMapL07 := TBitmap():New(00,00,((oPan07S:NCLIENTWIDTH)/2),((oPan07S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan07S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		oBMap07 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan07S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		oPan07I := TPanel():New(0,0,'',oWizard:GetPanel(7), oWizard:GetPanel(7):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(7):NCLIENTWIDTH)/2),((oWizard:GetPanel(7):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan07I:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000, 000 LISTBOX oLbxProcLog FIELDS HEADER 	"Boleto"		   				,;
														"E-Mail"		   				,;
					   				  					SE1->(RetTitle("E1_FILIAL"))	,;
					   				  					SE1->(RetTitle("E1_NUMBCO")) 	,;
					   				  					SE1->(RetTitle("E1_VENCREA"))	,;
					   				  					SE1->(RetTitle("E1_SALDO"))	 	,;
									  					SE1->(RetTitle("E1_PREFIXO"))	,;
									  					SE1->(RetTitle("E1_NUM"))  		,;
									  					SE1->(RetTitle("E1_PARCELA"))	,;
									  					SE1->(RetTitle("E1_TIPO"))		,;
									  					SE1->(RetTitle("E1_CLIENTE"))	,;
									  					SE1->(RetTitle("E1_LOJA"))		,;
														SA1->(RetTitle("A1_NOME"))	 	,;
														"Arquivo"						,;
														"Erro de Envio"					;
											COLSIZES 	20								,;
														20								,;
														20 								,;
														20 								,;
														40 								,;
														50 								,;
														15 								,;
														30 								,;
														15 								,;
														10 								,;
														30 								,;
														15 								,;
									 					50								,;
									 					50								,;
									 					50								;
								SIZE (oPan07I:NWIDTH/2)-2,(oPan07I:NHEIGHT/2)-2;
								ON DBLCLICK (AbrePdf(aLogProc[oLbxProcLog:nAt,14])) OF oPan07I PIXEL
									
		
		oLbxProcLog:SetArray(aLogProc)	
		oLbxProcLog:bLine := {|| {If(aLogProc[oLbxProcLog:nAt,1],oProc,oErro),If(aLogProc[oLbxProcLog:nAt,2],oProc,oErro),aLogProc[oLbxProcLog:nAt,3],aLogProc[oLbxProcLog:nAt,4],aLogProc[oLbxProcLog:nAt,5],aLogProc[oLbxProcLog:nAt,6],aLogProc[oLbxProcLog:nAt,7],aLogProc[oLbxProcLog:nAt,8],aLogProc[oLbxProcLog:nAt,9],aLogProc[oLbxProcLog:nAt,10],aLogProc[oLbxProcLog:nAt,11],aLogProc[oLbxProcLog:nAt,12],aLogProc[oLbxProcLog:nAt,13],aLogProc[oLbxProcLog:nAt,14],aLogProc[oLbxProcLog:nAt,15]}}

//->> Painel de cnab
oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - T�tulo do painel 
                    "Gerar Remessa Cnab", 											            			     ;   // cMsg     - Mensagem posicionada no cabe�alho do painel
                    {|| .T. }, 						               						        			 	 ;   // bBack    - Bloco de c�digo utilizado para validar o bot�o "Voltar"
                    {|| ProcCnab() }, 																		     ;   // bNext    - Bloco de c�digo utilizado para validar o bot�o "Avan�ar"
                    {|| ProcCnab() }, 																			 ;   // bFinish  - Bloco de c�digo utilizado para validar o bot�o "Finalizar"
                    .T.,                                              										     ;   // lPanel   - Se .T. ser� criado um painel, se .F. ser� criado um scrollbox
                    {|| AtuParCnab() }    							        									 )   // bExecute - Bloco de c�digo a ser executado quando o painel for selecionado

		oPan08S := TPanel():New(0,0,'',oWizard:GetPanel(8), oWizard:GetPanel(8):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(8):NCLIENTWIDTH)/2),45,.F.,.T. )
		oPan08S:Align := CONTROL_ALIGN_TOP                             
		oBMapL08 := TBitmap():New(00,00,((oPan08S:NCLIENTWIDTH)/2),((oPan08S:NCLIENTHEIGHT)/2),Nil,"",.T.,oPan08S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		oBMap08 := TBitmap():New(02,02,150,40,Nil,"",.T.,oPan08S,,,.F.,.T.,,,.F.,,.T.,,.F.)
		
		oPan08I := TPanel():New(0,0,'',oWizard:GetPanel(8), oWizard:GetPanel(8):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(8):NCLIENTWIDTH)/2),((oWizard:GetPanel(8):NCLIENTHEIGHT)/2)-45,.T.,.F. )
		oPan08I:Align := CONTROL_ALIGN_ALLCLIENT

		Parambox(aBox05Param,"Parametrizacao",@aRet05Param,,,,,,oPan08I,,.F.,.F.)

		oWizard:OFINISH:CCAPTION := "&Gera Remessa"		 

//->> Ativa��o do Painel
oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o di�logo ser� centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de c�digo a ser executado no encerramento do di�logo
                    {|| .T. },  ;   // bInit    - Bloco de c�digo a ser executado na inicializa��o do di�logo
                    {|| .T. }   )   // bWhen    - Bloco de c�digo para habilitar a execu��o do di�logo
            
For nX:=1 to Len(_aPrint)
	FreeObj(_aPrint[nX])
	_aPrint[nX] := ""	
Next nX

Return
   
/*/{protheus.doc} GravaParam
*******************************************************************************************
Grava os parametros
 
@author: Marcelo Celi Marques
@since: 23/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GravaParam(cPerg,aPergunte)
aPergunte := {}

Pergunte(cPerg, .F., , , , , @aPergunte , .T., .T.)
MV_PAR01 := If(Empty(aRet01Param[01]),1,aRet01Param[01])
aPergunte[1,08] := MV_PAR01

MV_PAR02 :=	If(!Empty(aRet01Param[06]),aRet01Param[06],Space(99))
aPergunte[2,08] := MV_PAR02

MV_PAR03 :=	If(aRet01Param[07],1,0)
aPergunte[3,08] := MV_PAR03

MV_PAR04 := If(!Empty(aRetMsgPara[01]),aRetMsgPara[01],0)
aPergunte[4,08] := MV_PAR04

MV_PAR05 := If(!Empty(aRetMsgPara[02]),aRetMsgPara[02],0)
aPergunte[5,08] := MV_PAR05

MV_PAR06 :=	If(aRetMsgPara[03],1,0)
aPergunte[6,08] := MV_PAR06

MV_PAR07 :=	If(!Empty(aRetMsgPara[04]),aRetMsgPara[04]," ")
aPergunte[7,08] := MV_PAR07

MV_PAR08 :=	If(!Empty(aRet01Param[02]),aRet01Param[02]," ")
aPergunte[8,08] := MV_PAR08

MV_PAR09 :=	If(!Empty(aRet01Param[03]),aRet01Param[03]," ")
aPergunte[9,08] := MV_PAR09

MV_PAR10 :=	If(!Empty(aRet01Param[04]),aRet01Param[04]," ")
aPergunte[10,08] := MV_PAR10

MV_PAR11 :=If(!Empty(aRet01Param[05]),aRet01Param[05]," ")
aPergunte[11,08] := MV_PAR11

MV_PAR12 := If(aRet01Param[08],1,0)
aPergunte[12,08] := MV_PAR12

MV_PAR13 := If(aRet01Param[09],1,0)
aPergunte[13,08] := MV_PAR13

MV_PAR14 := If(aRet01Param[10],1,0)
aPergunte[14,08] := MV_PAR14

__SaveParam(cPerg, aPergunte)
aPergunte := {}
Pergunte(cPerg, .F., , , , , @aPergunte , .T., .T.)

Return

/*/{protheus.doc} ProcBoleto
*******************************************************************************************
Valida��o dos campos 
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcBoleto(aTitulos,cPerg,aPergunte)
Local nX 		:= 1
Local aBoletos  := {}
Local nRecBol	:= 0
Local aProcs	:= {}
Local lOk		:= .T.
Local aArqBolet	:= {}
Local nPos		:= 0
Local cArquivo	:= ""

// Grava os parametros          
GravaParam(cPerg,aPergunte)

For nX:=1 to Len(aTitulos)
	If aTitulos[nX,01]
		aAdd(aBoletos,{aTitulos[nX,15]})
    EndIf
Next nX
    
If Len(aBoletos)>0    
	Processa({|a| aArqBolet := GeraBoleto(aBoletos,aRet01Param[06]) },"Aguarde","Gerando Boletos...")    
                                                                
	aLogProc := {}
	For nX:=1 to Len(aTitulos)
		If aTitulos[nX,01]
			nRecBol := aTitulos[nX,15]
			SE1->(dbGoto(nRecBol))
			nPos := Ascan(aArqBolet,{|x| x[03]==nRecBol})
			lOk := nPos > 0
			cArquivo := ""
			If lOk
				cArquivo := Alltrim(aArqBolet[nPos,01])
				cArquivo += If(Right(cArquivo,1)=="\","","\")
				cArquivo += Alltrim(aArqBolet[nPos,02])+".pdf"			

				If Empty(cArquivo) .Or. !File(cArquivo)
					cArquivo := ""
					lOk := .F.
				EndIf
			EndIf
			
			aAdd(aLogProc,{	lOk,			;
							.F.,			;
							SE1->E1_FILIAL,	;
							SE1->E1_NUMBCO,	;
							SE1->E1_VENCREA,;
							SE1->E1_SALDO,	;
							SE1->E1_PREFIXO,;
							SE1->E1_NUM,	;
							SE1->E1_PARCELA,;
							SE1->E1_TIPO,	;
							SE1->E1_CLIENTE,;
							SE1->E1_LOJA,	;
							Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_NOME"),;
							cArquivo,		;
							"",				;
							SE1->(Recno())})	
		EndIf
	Next nX
	     
	//->> Envia por e-mail
	If aRet01Param[07] .And. Len(aArqBolet)>0
		aProcs := {}
		Processa({|a| EnviaBoletos(aArqBolet,@aProcs) },"Aguarde","Enviando Boletos por e-Mail...")			
		
		For nX:=1 to Len(aProcs)
			nPos := Ascan(aLogProc,{|x| x[16]==aProcs[nX,01]})
			If nPos > 0
				aLogProc[nPos,02] := aProcs[nX,02]
				aLogProc[nPos,15] := aProcs[nX,03]
		    EndIf
		Next nX		
	EndIf
	
	If Len(aLogProc)==0
		aLogProc := {{.F.,.F.,"","",Stod(""),0,"","","","","","","","",""}}
	EndIf	
	oLbxProcLog:SetArray(aLogProc)	
	oLbxProcLog:bLine := {|| {If(aLogProc[oLbxProcLog:nAt,1],oProc,oErro),If(aLogProc[oLbxProcLog:nAt,2],oProc,oErro),aLogProc[oLbxProcLog:nAt,3],aLogProc[oLbxProcLog:nAt,4],aLogProc[oLbxProcLog:nAt,5],aLogProc[oLbxProcLog:nAt,6],aLogProc[oLbxProcLog:nAt,7],aLogProc[oLbxProcLog:nAt,8],aLogProc[oLbxProcLog:nAt,9],aLogProc[oLbxProcLog:nAt,10],aLogProc[oLbxProcLog:nAt,11],aLogProc[oLbxProcLog:nAt,12],aLogProc[oLbxProcLog:nAt,13],aLogProc[oLbxProcLog:nAt,14],aLogProc[oLbxProcLog:nAt,15]}}
		    
Else
	MsgAlert("Nenhum Boleto Gerado...")
EndIf    

Return

/*/{protheus.doc} VldParam
*******************************************************************************************
Valida��o dos campos 
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VldParam(nTipo)
Local lRet 	 	:= .T.
Local cPasta 	:= ""
Local cPath	 	:= ""
Local nX		:= 1
Local lConteudo := .F.

AtualizTela()						

Do Case
	Case nTipo == 1			

		//->> Verificando a entidade da nota
		If aRet01Param[09] .Or. aRet01Param[10]
			If Empty(_cIdent)
				FwMsgRun( ,{|| _cIdent := GetIdEnt() }, , "Aguarde... Buscando Entidade do Sefaz..." )			
			EndIf	
		Else
			_cIdent := ""	
		EndIf	

		If !Empty(aRet01Param[02]) .And. !Empty(aRet01Param[03]) .And. !Empty(aRet01Param[04]) .And. !Empty(aRet01Param[05])
			If _cBcoBolet == aRet01Param[02]
				SEE->(dbSetOrder(1))
				If SEE->(dbSeek(xFilial("SEE")+aRet01Param[02]+aRet01Param[03]+aRet01Param[04]+aRet01Param[05]))
					lRet := VldConfig(aRet01Param[02])
				Else
					lRet := .F.
					MsgAlert("Favor informar os Parametros Bancarios Validos para continuar...")	        	
				EndIf
			Else
				lRet := .F.
				MsgAlert("Banco informado nos Parametros Bancarios difere do Banco Selecionado...")	        	
			EndIf		
        Else
        	lRet := .F.
        	MsgAlert("Favor informar os Parametros Bancarios para continuar...")        	
        EndIf        
                       
        If lRet         
	        cPasta := Alltrim(aRet01Param[06])
	        If Empty(cPasta)
		        MsgAlert("A Pasta destino para a gravacao dos boletos nao e valida ou voce nao tem permissao para gravar nesse local."+CRLF+"Selecione uma Pasta valida para continuar.")	
		        lRet := .F.
		    Else
		        cPasta += If(Right(cPasta,1)=="\","","\")
		        cPath := cPasta+"Teste_"+Criatrab(,.F.)+".Tst"
		        
		        nHdl := fCreate(cPath)
		        If nHdl <= 0     
		            MsgAlert("A Pasta destino para a gravacao dos boletos nao e valida ou voce nao tem permissao para gravar nesse local."+CRLF+"Selecione uma Pasta valida para continuar.")	
		            lRet := .F.
		        Else
		            fClose(nHdl)
		            FErase(cPath)
		        EndIf
		    EndIf
	    EndIf    
        
        If !lRet
        	oWizard:NPANEL:=2
        EndIf        
	
	Case nTipo == 2
		lConteudo := .F.
		For nX:=1 to Len(aRet02Param)
			If !Empty(aRet02Param[nX])
				lConteudo := .T.
				Exit
			EndIf
		Next nX
		If !lConteudo
			lRet := MsgYesNo("Nenhum parametro para a selecao dos dados foi informado."+CRLF+"Dessa forma a filtragem pode demorar consideravelmente pois a busca sera geral"+CRLF+"Deseja continuar ?")
		EndIf

		If !lRet
        	oWizard:NPANEL:=3
        EndIf        

	Case nTipo== 3
		lConteudo := .F.
		For nX:=1 to Len(aRet03Param)
			If !Empty(aRet03Param[nX])
				lConteudo := .T.
				Exit
			EndIf
		Next nX
		If !lConteudo
			lRet := MsgYesNo("Nenhum parametro para a selecao dos dados foi informado."+CRLF+"Dessa forma a filtragem pode demorar consideravelmente pois a busca sera geral"+CRLF+"Deseja continuar ?")
		EndIf

		If !lRet
        	oWizard:NPANEL:=4
        EndIf        

	Case nTipo== 4
		lRet := .T.
		If Empty(aRet04Param[01]) .Or. Empty(aRet04Param[02])
			lRet := .F.
			MsgAlert("Borderos nao informados nos parametros.")
		Else
			SEA->(dbSetOrder(2))
			If lRet .And. SEA->(!dbSeek(xFilial("SEA")+aRet04Param[01]+"R"))
				lRet := .F.
				MsgAlert("Bordero nao localizado no primeiro parametro.")
			EndIf

			If lRet .And. SEA->(!dbSeek(xFilial("SEA")+aRet04Param[02]+"R"))
				lRet := .F.
				MsgAlert("Bordero nao localizado no segundo parametro.")
			EndIf

			If lRet .And. aRet04Param[01] > aRet04Param[02]
				lRet := .F.
				MsgAlert("Disposicao da numeracao dos borderos informados de maneira incoerente nos parametros.")
			EndIf
		EndIf

		If !lRet
        	oWizard:NPANEL:=5
        EndIf        

	Case nTipo== 5
		lRet := MsgYesNo("Confirma a Geracao dos Boletos dos Titulos Marcados ?")

	Case nTipo== 6
		lRet := .F.
		For nX:=1 to Len(aLogProc)
			If aLogProc[nX,01]
				lRet := .T.
				Exit
			EndIf
		Next nX
		If !lRet
			MsgAlert("Nenhum Boleto foi Gerado nas parametrizacoes informadas.")
		EndIf
EndCase

Return lRet

/*/{protheus.doc} GeTitulos
*******************************************************************************************
Retorna os titulos filtrados
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GeTitulos()
Local aRecnos 	:= {}
Local nX		:= {}
Local cTipAbtPg	:= MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
Local cTipAntPg	:= MVPAGANT
Local lOk		:= .T.

If aRet01Param[01] == 1 // Notas Fiscais
	aRecnos := BolByNotas(	aRet02Param[01],; 	// 01 - Serie
							aRet02Param[02],; 	// 02 - Documento de
							aRet02Param[03],; 	// 03 - Documento ate
							aRet02Param[04],; 	// 04 - Cliente de
							aRet02Param[06],; 	// 05 - Cliente ate
							aRet02Param[05],; 	// 06 - Loja de
							aRet02Param[07],; 	// 07 - Loja ate
							aRet02Param[08],; 	// 08 - Emissao de
							aRet02Param[09] )  	// 09 - Emissao ate

ElseIf aRet01Param[01] == 2 // Titulos
	aRecnos := BolByTits(	aRet03Param[01],;	// 01 - Prefixo
							aRet03Param[02],;	// 02 - Numero de
							aRet03Param[03],;	// 03 - Numero ate
							aRet03Param[08],;	// 04 - Emissao de
							aRet03Param[09],;	// 05 - Emissao ate
							aRet03Param[10],;	// 06 - Vencto de
							aRet03Param[11],;	// 07 - Vencto ate
							aRet03Param[04],;	// 08 - Cliente de
							aRet03Param[05],;	// 09 - Loja de
							aRet03Param[06],;	// 10 - Cliente ate
							aRet03Param[07])	// 11 - Loja ate

ElseIf aRet01Param[01] == 3 // Bordero
	aRecnos := BolByBord(	aRet04Param[01],;	// 01 - Bordero de
							aRet04Param[02])	// 02 - Bordero ate

EndIf

If Len(aRecnos) > 0
	aTitulos := {}
	For nX:=1 to Len(aRecnos)
		SE1->(dbGoto(aRecnos[nX,01]))
		If !(SE1->E1_TIPO $ cTipAbtPg) .And. !(SE1->E1_TIPO $ cTipAntPg)		
			
			lOk := .T.
			//->> Ponto de Entrada para permitir a sele��o do titulo cr posicionado e devidamente filtrado.
			If ExistBlock("MCBOLTITCR")
				lOk := ExecBlock("MCBOLTITCR",.f.,.f.)
			EndIf
			
			If lOk
				aAdd(aTitulos,{.F.,				; 	// 01 - Marca��o
								SE1->E1_FILIAL,	;	// 02 - Filial
								SE1->E1_PREFIXO,;	// 03 - Prefixo
								SE1->E1_NUM,	;	// 04 - Numero
								SE1->E1_PARCELA,;	// 05 - Parcela
								SE1->E1_TIPO,	;	// 06 - Tipo
								SE1->E1_CLIENTE,;	// 07 - Cliente
								SE1->E1_LOJA,	;	// 08 - Loja
								SE1->E1_EMISSAO,;	// 09 - Emissao
								SE1->E1_VENCTO,	;	// 10 - Vencimento
								SE1->E1_VENCREA,;	// 11 - Vencimento real
								SE1->E1_SALDO,	;	// 12 - Saldo		
								SE1->E1_PORTADO,;	// 13 - Portador
								SE1->E1_NUMBCO,	;	// 14 - Nosso Numero							
								SE1->(Recno())})	// 15 - Recno do Titulo
			EndIf

        EndIf
    Next nX
Else
	MsgAlert("Nenhum documento localizado de acordo com o filtro informado.")
   	aTitulos 	:= {{.F.,"","","","","","","",Stod(""),Stod(""),Stod(""),0,0,"",""}}
EndIf

oLbxTitulos:SetArray(aTitulos)	
oLbxTitulos:bLine := {|| {If(aTitulos[oLbxTitulos:nAt,1],oOK,oNO),aTitulos[oLbxTitulos:nAt,2],aTitulos[oLbxTitulos:nAt,3],aTitulos[oLbxTitulos:nAt,4],aTitulos[oLbxTitulos:nAt,5],aTitulos[oLbxTitulos:nAt,6],aTitulos[oLbxTitulos:nAt,7],aTitulos[oLbxTitulos:nAt,8],aTitulos[oLbxTitulos:nAt,9],aTitulos[oLbxTitulos:nAt,10],aTitulos[oLbxTitulos:nAt,11],aTitulos[oLbxTitulos:nAt,12],aTitulos[oLbxTitulos:nAt,13],aTitulos[oLbxTitulos:nAt,14]}}
oLbxTitulos:bRClicked 		:= { || AEVAL(aTitulos,{|x|x[1]:=!x[1]}), oLbxTitulos:Refresh(.F.)}    	
oLbxTitulos:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aTitulos, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxTitulos:Refresh()}

If Len(aRecnos) == 0
	oLbxTitulos:lActive := .F.	
Else
	oLbxTitulos:lActive := .T.	

	If 	aRet01Param[08]	.And. (aRet01Param[01] == 1 .Or. aRet01Param[01] == 2)
		_cNumBord := Soma1(GetMV("MV_NUMBORR"),6)
		_cNumBord := Replicate("0",6-Len(Alltrim(_cNumBord)))+Alltrim(_cNumBord)
		While !MayIUseCode("SE1"+xFilial("SE1")+_cNumBord)  //verifica se esta na memoria, sendo usado
			// busca o proximo numero disponivel 
			_cNumBord := Soma1(_cNumBord)
		EndDo
		_oNumBord:lVisible := .T.
	Else
		_cNumBord := ""
		_oNumBord:lVisible := .F.
	EndIf
	_oNumBord:Refresh()
EndIf
oLbxTitulos:Refresh()

Return

/*/{protheus.doc} BolByNotas
*******************************************************************************************
Gera os Boletos
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function BolByNotas(cSerie,cDocDe,cDocAte,cCliDe,cCliAte,cLojaDe,cLojaAte,dEmissDe,dEmissAte)
Local cQuery 		:= ""
Local cTipo	 		:= MVNOTAFIS
Local cAlias		:= GetNextAlias()
Local aBoletos		:= {}

cQuery := "SELECT DISTINCT SF2.R_E_C_N_O_ AS RECSF2"										+CRLF
cQuery += "	FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"										+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SE1")+" SE1 (NOLOCK)"									+CRLF
cQuery += "			ON SE1.E1_FILIAL   = SF2.F2_FILIAL"										+CRLF
cQuery += "		   	AND SE1.E1_PREFIXO = SF2.F2_SERIE"										+CRLF
cQuery += "		   	AND SE1.E1_NUM     = SF2.F2_DOC"										+CRLF
cQuery += "			AND SE1.E1_TIPO    = '"+cTipo+"'"										+CRLF
cQuery += "			AND SE1.E1_SALDO   > 0"													+CRLF
cQuery += "			AND SE1.E1_VENCTO >= '"+dTos(dDatabase)+"'"								+CRLF
cQuery += "			AND (SE1.E1_PORTADO = ' ' OR SE1.E1_PORTADO = '"+aRet01Param[02]+"')"	+CRLF
cQuery += "			AND SE1.E1_NUMBOR = ' '"												+CRLF
cQuery += "			AND SE1.D_E_L_E_T_ = ' '"												+CRLF
cQuery += "	WHERE   SF2.F2_FILIAL = '"+xFilial("SF2")+"'"	   								+CRLF

If !Empty(cDocAte)
	cQuery += "		AND SF2.F2_DOC BETWEEN '"+cDocDe+"' AND '"+cDocAte+"'"					+CRLF
ElseIf !Empty(cDocDe)
	cQuery += "		AND SF2.F2_DOC = '"+cDocDe+"'"											+CRLF
EndIf	

If !Empty(cSerie)
	cQuery += "		AND SF2.F2_SERIE = '"+cSerie+"'"										+CRLF
EndIf

If !Empty(cCliAte)
	cQuery += "		AND SF2.F2_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"'"				+CRLF
ElseIf !Empty(cCliDe)
	cQuery += "		AND SF2.F2_CLIENTE = '"+cCliDe+"'"										+CRLF
EndIf

If !Empty(cLojaAte)
	cQuery += "		AND SF2.F2_LOJA    BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'"			+CRLF
ElseIf !Empty(cLojaDe)
	cQuery += "		AND SF2.F2_LOJA    = '"+cLojaDe+"'"										+CRLF
EndIf

If !Empty(dEmissAte)
	cQuery += "		AND SF2.F2_EMISSAO BETWEEN '"+dTos(dEmissDe)+"' AND '"+dTos(dEmissAte)+"'"+CRLF
ElseIf !Empty(dEmissDe)
	cQuery += "		AND SF2.F2_EMISSAO = '"+dTos(dEmissDe)+"'"								+CRLF
EndIf

cQuery += "		AND SF2.D_E_L_E_T_ = ' '"													+CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	SF2->(dbGoto((cAlias)->RECSF2))	
	SE1->(dbSetOrder(1))
	SE1->(dbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC)))
	Do While SE1->(!Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == SF2->(F2_FILIAL+F2_SERIE+F2_DOC)
		If Alltrim(SE1->E1_TIPO) == Alltrim(cTipo) .And. SE1->E1_SALDO > 0
			aAdd(aBoletos,{SE1->(Recno())})
	    EndIf
		SE1->(dbSkip())	
    EndDo
	(cAlias)->(dbSkip())
EndDo                  
(cAlias)->(dbCloseArea())
   
Return aBoletos

/*/{protheus.doc} BolByTits
*******************************************************************************************
Gera os Boletos
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function BolByTits(cPrefixo,cNumDe,cNumAte,dEmissDe,dEmissAte,dVencDe,dVencAte,cClide,cLojaDe,cCliAte,cLojaAte)
Local cQuery 		:= ""
Local cAlias		:= GetNextAlias()
Local aBoletos		:= {}
Local cSepNeg   	:= If("|"$MV_CRNEG,"|",",")
Local cSepProv  	:= If("|"$MVPROVIS,"|",",")
Local cSepRec   	:= If("|"$MVRECANT,"|",",")

cQuery := "SELECT DISTINCT SE1.R_E_C_N_O_ AS RECSE1"											+CRLF
cQuery += "	FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"											+CRLF
cQuery += "	WHERE   SE1.E1_FILIAL = '"+xFilial("SE1")+"'"	   									+CRLF

If !Empty(cPrefixo)
	cQuery += "		AND SE1.E1_PREFIXO = '"+cPrefixo+"'"										+CRLF
EndIf

If !Empty(cNumAte)
	cQuery += "		AND SE1.E1_NUM 	   BETWEEN '"+cNumDe+"' AND '"+cNumAte+"'"					+CRLF
ElseIf !Empty(cNumDe)
	cQuery += "		AND SE1.E1_NUM 	   = '"+cNumDe+"'"											+CRLF
EndIf	

If !Empty(cCliAte)	
	cQuery += "		AND SE1.E1_CLIENTE BETWEEN '"+cClide+"' AND '"+cCliAte+"'"					+CRLF
ElseIf !Empty(cCliDe)
	cQuery += "		AND SE1.E1_CLIENTE = '"+cClide+"'"											+CRLF
EndIf

If !Empty(cLojaAte)
	cQuery += "		AND SE1.E1_LOJA    BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'"				+CRLF
ElseIf !Empty(cLojaDe)	
	cQuery += "		AND SE1.E1_LOJA    = '"+cLojaDe+"'"											+CRLF	
EndIf

If !Empty(dVencAte)
	cQuery += "		AND SE1.E1_VENCTO  BETWEEN '"+dTos(dVencDe)+"' AND '"+dTos(dVencAte)+"'"	+CRLF
ElseIf !Empty(dVencDe)
	cQuery += "		AND SE1.E1_VENCTO  = '"+dTos(dVencDe)+"'"									+CRLF
EndIf

If !Empty(dEmissAte)
	cQuery += "		AND SE1.E1_EMISSAO BETWEEN '"+dTos(dEmissDe)+"' AND '"+dTos(dEmissAte)+"'"	+CRLF
ElseIf !Empty(dEmissDe)
	cQuery += "		AND SE1.E1_EMISSAO = '"+dTos(dEmissDe)+"'"									+CRLF
EndIf

cQuery += "		AND SE1.E1_SALDO > 0"															+CRLF
cQuery += "		AND SE1.E1_VENCTO >= '"+dTos(dDatabase)+"'"										+CRLF

cQuery += "		AND SE1.E1_NUMBOR = ' '"														+CRLF

cQuery += "		AND (SE1.E1_PORTADO = ' ' OR SE1.E1_PORTADO = '"+aRet01Param[02]+"')"			+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") 								+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  							+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) 							+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  							+CRLF
cQuery += "		AND SE1.D_E_L_E_T_ = ' '"														+CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	aAdd(aBoletos,{(cAlias)->RECSE1})
	(cAlias)->(dbSkip())
EndDo                  
(cAlias)->(dbCloseArea())
   
Return aBoletos

/*/{protheus.doc} BolByBord
*******************************************************************************************
Gera os Boletos
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function BolByBord(cBordDe,cBordAte)
Local cQuery 		:= ""
Local cAlias		:= GetNextAlias()
Local aBoletos		:= {}
Local cSepNeg   	:= If("|"$MV_CRNEG,"|",",")
Local cSepProv  	:= If("|"$MVPROVIS,"|",",")
Local cSepRec   	:= If("|"$MVRECANT,"|",",")

cQuery := "SELECT DISTINCT SE1.R_E_C_N_O_ AS RECSE1"											+CRLF
cQuery += "	FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"											+CRLF
cQuery += "	WHERE   SE1.E1_FILIAL = '"+xFilial("SE1")+"'"	   									+CRLF
cQuery += "		AND SE1.E1_NUMBOR BETWEEN '"+cBordDe+"' AND '"+cBordAte+"'"						+CRLF
cQuery += "		AND SE1.E1_SALDO > 0"															+CRLF
cQuery += "		AND SE1.E1_VENCTO >= '"+dTos(dDatabase)+"'"										+CRLF                        
cQuery += "		AND SE1.E1_PORTADO = '"+aRet01Param[02]+"'"										+CRLF
cQuery += "		AND SE1.E1_NUMBOR <> ' '"														+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") 								+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  							+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) 							+CRLF
cQuery += "		AND SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  							+CRLF
cQuery += "		AND SE1.D_E_L_E_T_ = ' '"														+CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	aAdd(aBoletos,{(cAlias)->RECSE1})
	(cAlias)->(dbSkip())
EndDo                  
(cAlias)->(dbCloseArea())
   
Return aBoletos

/*/{protheus.doc} SX1Ajusta
*******************************************************************************************
Cria consulta padrao de parametros bancarios
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function SX1Ajusta(cPerg)
Local aCpos := {}
Local aPerg	:= {}    
Local cExces:= ""
Local nX	:= 1
Local nY	:= 1

aCpos	:= {"X1_GRUPO"	,"X1_ORDEM"	,"X1_PERGUNT"				,"X1_PERSPA"					,"X1_PERENG"				,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"				,"X1_DECIMAL"	,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID"		,"X1_VAR01"	,"X1_DEF01"			,"X1_DEFSPA1"		,"X1_DEFENG1"		,"X1_CNT01"	,"X1_VAR02"	,"X1_DEF02"			,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02"	,"X1_VAR03"	,"X1_DEF03"			,"X1_DEFSPA3"	,"X1_DEFENG3"		,"X1_CNT03"	,"X1_VAR04"	,"X1_DEF04"			,"X1_DEFSPA4"		,"X1_DEFENG4"	,"X1_CNT04"	,"X1_VAR05"	,"X1_DEF05"			,"X1_DEFSPA5"		,"X1_DEFENG5"	,"X1_CNT05"	,"X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"	,"X1_PICTURE"	,"X1_IDFIL"	}
cExces	:= "X1_CNT01|X1_CNT02|X1_CNT03|X1_CNT04|X1_CNT05"

aAdd(aPerg,{cPerg		,"01"		,"Tipo Selecao ?"			,""								,""							,"mv_ch1"		,"N"		,1							,2				,0				,"G"		,""				,"mv_par01"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"02"		,"Pasta Gravacao ?"			,""								,""							,"mv_ch2"		,"C"		,99							,0				,0				,"G"		,""				,"mv_par02"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"03"		,"Enviar Email ?"			,""								,""							,"mv_ch3"		,"N"		,1							,0				,0				,"G"		,""				,"mv_par03"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"04"		,"Multa ?"					,""								,""							,"mv_ch4"		,"N"		,6							,3				,0				,"G"		,""				,"mv_par04"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"05"		,"Juros ?"					,""								,""							,"mv_ch5"		,"N"		,6							,3				,0				,"G"		,""				,"mv_par05"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"06"		,"Intruc Cob Pad ?"			,""								,""							,"mv_ch6"		,"N"		,1							,0				,0				,"G"		,""				,"mv_par06"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"07"		,"Mensagem Complem ?"		,""								,""							,"mv_ch7"		,"M"		,99							,0				,0				,"G"		,""				,"mv_par07"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"08"		,"Banco ?"					,""								,""							,"mv_ch8"		,"C"		,Tamsx3("EE_CODIGO")[01]	,0				,0				,"G"		,""				,"mv_par08"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"09"		,"Agencia ?"				,""								,""							,"mv_ch9"		,"C"		,Tamsx3("EE_AGENCIA")[01]	,0				,0				,"G"		,""				,"mv_par09"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"10"		,"Conta ?"					,""								,""							,"mv_chA"		,"C"		,Tamsx3("EE_CONTA")[01]		,0				,0				,"G"		,""				,"mv_par10"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"11"		,"Sub Conta ?"				,""								,""							,"mv_chB"		,"C"		,Tamsx3("EE_SUBCTA")[01]	,0				,0				,"G"		,""				,"mv_par11"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"12"		,"Gera Bordero ?"			,""								,""							,"mv_chC"		,"N"		,1							,0				,0				,"G"		,""				,"mv_par12"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"13"		,"Anexa Xml ?"				,""								,""							,"mv_chD"		,"N"		,1							,0				,0				,"G"		,""				,"mv_par13"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})
aAdd(aPerg,{cPerg		,"14"		,"Anexa Danfe ?"			,""								,""							,"mv_chD"		,"N"		,1							,0				,0				,"G"		,""				,"mv_par13"	,""					,""					,""					,""			,""			,""					,""					,""					,""			,""			,""					,""				,""					,""			,""			,""					,""					,""				,""			,""			,""					,""					,""				,""			,""			,"S"		,""				,""			,""				,""			})

Begin Transaction                    
	SX1->(dbSetOrder(1))
	For nX:=1 to Len(aPerg)
		If !SX1->(dbSeek(PadR(aPerg[nX][Ascan(aCpos,{|x| x=="X1_GRUPO"})],Len(SX1->X1_GRUPO))+; 
						 PadR(aPerg[nX][Ascan(aCpos,{|x| x=="X1_ORDEM"})],Len(SX1->X1_ORDEM))))
			
			Reclock("SX1",.T.)		    
			For nY:=1 to Len(aCpos)
				If !(Upper(Alltrim(aCpos[nY])) $ Upper(cExces))
					SX1->&(aCpos[nY]) := aPerg[nX][nY]
				EndIf	
			Next                                
			SX1->(MsUnlock())
		EndIf	
	Next nX
End Transaction
	
Return

/*/{protheus.doc} SXBAjusta
*******************************************************************************************
Cria consulta padrao de parametros bancarios
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function SXBAjusta()
Local aArea		:= GetArea()
Local aSXB 		:= {}
Local aEstrut	:= {}
Local i, j

aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"				,"XB_DESCSPA"				,"XB_DESCENG"				,"XB_CONTEM"					}

aAdd( aSXB, {"MCBOLE" 	,"1"		, "01"		,"DB"			,"Comunicacao Remota"		,"Comunicacao Remota"		,"Comunicacao Remota"		,"SEE"				  			}) 
aAdd( aSXB, {"MCBOLE" 	,"2"		, "01"		,"01"			,"Banco + Agencia + Co"		,"Banco + Agencia + Co"		,"Banco + Agencia + Co"		,""					  			}) 
aAdd( aSXB, {"MCBOLE" 	,"4"		, "01"		,"01"			,"Banco"					,"Banco"					,"Banco"					,"EE_CODIGO"		  			}) 
aAdd( aSXB, {"MCBOLE" 	,"4"		, "01"		,"02"			,"Agencia"					,"Agencia"					,"Agencia"					,"EE_AGENCIA"		  			}) 
aAdd( aSXB, {"MCBOLE" 	,"4"		, "01"		,"03"			,"Conta"					,"Conta"					,"Conta"					,"EE_CONTA"			  			}) 
aAdd( aSXB, {"MCBOLE" 	,"4"		, "01"		,"04"			,"Sub Conta"				,"Sub Conta"				,"Sub Conta"				,"EE_SUBCTA"		  			}) 
aAdd( aSXB, {"MCBOLE" 	,"5"		, "01"		,"  "			,""							,""							,""							,"SEE->EE_CODIGO"	  			}) 
aAdd( aSXB, {"MCBOLE" 	,"5"		, "02"		,"  "			,""							,""							,""							,"SEE->EE_AGENCIA"	  			}) 
aAdd( aSXB, {"MCBOLE" 	,"5"		, "03"		,"  "			,""							,""							,""							,"SEE->EE_CONTA"	  			}) 
aAdd( aSXB, {"MCBOLE" 	,"5"		, "04"		,"  "			,""							,""							,""							,"SEE->EE_SUBCTA"	   			}) 
aAdd( aSXB, {"MCBOLE" 	,"6"		, "01"		,"  "			,""							,""							,""							,"SEE->EE_CODIGO == _cBcoBolet"	}) 


Aadd( aSXB,	{"MCPBOL"	,"1"		,"01"		,"RE"			,"Pasta Destino"			,"Pasta Destino"			,"Pasta Destino"			,"SE1"							})
Aadd( aSXB,	{"MCPBOL"	,"2"		,"01"		,"01"			,""				   			,""						   	,""						   	,".T."							})
Aadd( aSXB,	{"MCPBOL"	,"5"		,"01"		,""				,""							,""						   	,""						   	,"u_MCGetPABOL()"				})	

dbSelectArea("SXB")
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !SXB->(dbSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS)) + Padr(aSXB[i,2], Len(SXB->XB_TIPO)) + Padr(aSXB[i,3], Len(SXB->XB_SEQ)) + Padr(aSXB[i,4], Len(SXB->XB_COLUNA))))
			RecLock("SXB",.T.)			
		Else
			RecLock("SXB",.F.)			
		EndIf
		For j:=1 To Len(aSXB[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()		
	EndIf
Next i

RestArea(aArea)

Return

/*/{protheus.doc} AtualizTela
*******************************************************************************************
Atualiza a tela
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Est�tico
*******************************************************************************************
/*/
Static Function AtualizTela()
Local cImagem := ""
Local cFaixaL := ""

Do Case
	Case _cBcoBolet == "001"
		cImagem := "faixa_001.bmp"
		cFaixaL := "faixa_L_001.bmp"
		
	Case _cBcoBolet == "237"      
		cImagem := "faixa_237.bmp"
		cFaixaL := "faixa_L_237.bmp"
	
	Case _cBcoBolet == "104"      
		cImagem := "faixa_104.bmp"
		cFaixaL := "faixa_L_104.bmp"
	
	Case _cBcoBolet == "341"      
		cImagem := "faixa_341.bmp"
		cFaixaL := "faixa_L_341.bmp"
	
	Case _cBcoBolet == "422"      
		cImagem := "faixa_422.bmp"
		cFaixaL := "faixa_L_422.bmp"
	
	Case _cBcoBolet == "033"      
		cImagem := "faixa_033.bmp"
		cFaixaL := "faixa_L_033.bmp"
	
EndCase
        
oBMapL03:CBMPFILE := cFaixaL
oBMapL03:Refresh()       
oBMap03:CBMPFILE := cImagem
oBMap03:Refresh()
                         
oBMapL04:CBMPFILE := cFaixaL
oBMapL04:Refresh()       
oBMap04:CBMPFILE := cImagem
oBMap04:Refresh()

oBMapL05:CBMPFILE := cFaixaL
oBMapL05:Refresh()       
oBMap05:CBMPFILE := cImagem
oBMap05:Refresh()       

oBMapL06:CBMPFILE := cFaixaL
oBMapL06:Refresh()       
oBMap06:CBMPFILE := cImagem
oBMap06:Refresh()

oBMapL07:CBMPFILE := cFaixaL
oBMapL07:Refresh()       
oBMap07:CBMPFILE := cImagem
oBMap07:Refresh()

oBMapL08:CBMPFILE := cFaixaL
oBMapL08:Refresh()       
oBMap08:CBMPFILE := cImagem
oBMap08:Refresh()

Return

/*/{protheus.doc} VYGetPPSG
*******************************************************************************************
Retorna a Pasta.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MCGetPABOL()
Local cPasta 	:= ""

cPasta := Alltrim( cGetFile("Diretorios", "Diretorio Destino dos Boletos",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
aRet01Param[06]  := cPasta

Return

/*/{protheus.doc} EnviaBoletos
*******************************************************************************************
Envio dos Boletos por e-mail
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function EnviaBoletos(aArquivos,aProcs)
Local nX 	 	:= 1
Local nY		:= 1
Local nZ		:= 1
Local nPos   	:= 0
Local aEmail 	:= {}
Local cPastSrv  := "\MCBOLETO\"
Local cAnexos	:= ""
Local cArqBol	:= ""
Local aArqSrv	:= {}
Local cCorpoMail:= ""
Local cEmailDes	:= ""
Local cErro		:= ""
Local aNfe		:= {}
Local lCompacta	:= Upper(Alltrim(GetNewPar("MC_COMPBOL","S")))=="S"
Local aCompacta	:= {}
Local nCompacta	:= 0
Local cCompacta	:= ""
Local aArqComp	:= {}

aProcs := {}

ProcRegua(Len(aArquivos))             
For nX:=1 to Len(aArquivos)
	IncProc("Aguarde! Preparando Arquivos...") 	
	SE1->(dbGoto(aArquivos[nX,03]))
	nPos := Ascan(aEmail,{|x| x[01]+x[02] == SE1->(E1_CLIENTE+E1_LOJA)})
	If nPos == 0
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
			cEmailDes := SA1->A1_EMAIL
			
			//->> Ponto de Entrada para alterar o email de envio do boleto
			If ExistBlock("MCBOLEMAIL")
				cEmailDes := ExecBlock("MCBOLEMAIL",.f.,.f.,{cEmailDes})
			EndIf

			//->> teste, tirar depois
			cEmailDes := "marcelo.celi@gmail.com"
			
			If Empty(cEmailDes)
				aAdd(aProcs,{SE1->(Recno()),.F.,"Email destinatario nao informado"})
			Else
				aAdd(aEmail,{SE1->E1_CLIENTE,SE1->E1_LOJA,SA1->A1_NOME,cEmailDes,{}})
			EndIf	
			nPos := Len(aEmail)			
	    Else
	    	aAdd(aProcs,{SE1->(Recno()),.F.,"Cliente nao localizado"})
	    	Loop
	    EndIf
	EndIf                      
	aAdd(aEmail[nPos,05],{aArquivos[nX,01],aArquivos[nX,02],SE1->(Recno())})
Next nX

MakeDir(cPastSrv)
ProcRegua(Len(aEmail))
For nX:=1 to Len(aEmail)
	IncProc("Enviando e-Mail de cobranca para "+Alltrim(aEmail[nX,03]))
	cAnexos := ""
	aArqSrv	  := {}
	For nY:=1 to Len(aEmail[nX][05])
		cArqBol := Alltrim(aEmail[nX,05][nY,01])
		cArqBol += If(Right(cArqBol,1)=="\","","\")
		cArqBol += Alltrim(aEmail[nX,05][nY,02])+".pdf"
		
		CpyT2S(cArqBol,cPastSrv)
		If !Empty(cAnexos)
			cAnexos += ","
		EndIf
		cAnexos += Alltrim(cPastSrv)+Alltrim(aEmail[nX,05][nY,02])+".pdf"
		aAdd(aArqSrv,Alltrim(cPastSrv)+Alltrim(aEmail[nX,05][nY,02])+".pdf")

		If aRet01Param[09] .Or. aRet01Param[10]
			SE1->(dbGoto(aEmail[nX,05][nY,03]))
			FwMsgRun( ,{|| aNfe := AnexarNota() }, , "Aguarde... Localizando Notas Fiscais no Sefaz..." )			
			For nZ:=1 to Len(aNfe)
				If !Empty(cAnexos)
					cAnexos += ","
				EndIf
				cAnexos += aNfe[nZ]
			Next nZ	
		EndIf

    Next nY
    If Len(aArqSrv) > 0
    	cCorpoMail := GetTxtMail()
		If lCompacta
			aArqComp 	:= {}
			cCompacta 	:= "Cobr-bombay_"+aEmail[nX,01]+aEmail[nX,02]+"_"+Dtos(Date())+Strtran(Time(),":","")+".zip"			
			aCompacta 	:= StrTokArr(cAnexos,",")
			For nY:=1 to Len(aCompacta)
				If File(aCompacta[nY])
					aAdd(aArqComp,aCompacta[nY])
				EndIf
			Next nY
			If Len(aArqComp)>0
				nCompacta 	:= FZip(cPastSrv+cCompacta,aArqComp)
				If nCompacta == 0 .And. File(cPastSrv+cCompacta)
					cAnexos	:= cPastSrv+cCompacta
				EndIf
			EndIf	
		EndIf

		If !EnvWF(aEmail[nX,04],,"Boletos de Cobrancas",cCorpoMail,cAnexos)
			cErro := "e-mail com problemas"
    		For nY:=1 to Len(aEmail[nX,05])    	
		    	aAdd(aProcs,{aEmail[nX,05][nY,03],.F.,cErro})    
		    Next nY    	
		Else
			For nY:=1 to Len(aEmail[nX,05])    	
		    	aAdd(aProcs,{aEmail[nX,05][nY,03],.T.,""})
		    Next nY    			    
    	EndIf
    	For nY:=1 to Len(aArqSrv)
    		FErase(aArqSrv[nY])
    	Next nY    
		For nY:=1 to Len(aNfe)
			FErase(aNfe[nY])
		Next nY
    EndIf
Next nX

Return

/*/{protheus.doc} GetTxtMail
*******************************************************************************************
Criacao do texto do email
 
@author: Marcelo Celi Marques
@since: 05/05/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetTxtMail()
Local _cHtml := ""

_cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'																									+CRLF
_cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'																												+CRLF
_cHTML+='<BODY>'																																									+CRLF
_cHTML+='<TABLE cellSpacing=0 cellPadding=0 width="100%" bgColor=#afeeee background=""'																								+CRLF
_cHTML+='  <TBODY>'																																									+CRLF
_cHTML+='  <TR><TD>O boleto da sua compra foi gerado com sucesso e ja esta disponivel.</TD></TR>'																					+CRLF
_cHTML+='  <TR><TD>Para sua comodidade, anexamos o(s) boleto(s) com o valor de pagamento no e-mail.</TD></TR>'																		+CRLF
_cHTML+='  <TR><TD>Voce pode pagar o seu boleto em qualquer Banco, inclusive pelo aplicativo de celular.</TD></TR>'																	+CRLF
_cHTML+='  <TR><TD> </TD></TR>'																																						+CRLF
_cHTML+='  <TR><TD>Se o boleto vencer, sera necesario gerar um novo, para isso entre em contato pelos canais de atendimento com o cliente BOMBAY no horario comercial.</TD></TR>'		+CRLF
_cHTML+='  <TR><TD> </TD></TR>'																																						+CRLF
_cHTML+='  <TR><TD> </TD></TR>'																																						+CRLF
_cHTML+='  <TR><TD>Equipe Bombay - Financeiro</TD></TR>'																																+CRLF
_cHTML+='  </TBODY></TABLE>'																																						+CRLF
_cHTML+='<P>&nbsp;</P>'																																								+CRLF
_cHTML+='</BODY></HTML>'																																							+CRLF

//->> Ponto de Entrada para alterar o texto do html do email
If ExistBlock("MCBOLHTML")
	_cHTML := ExecBlock("MCBOLHTML",.f.,.f.,{_cHTML})
EndIf

Return _cHtml

/*/{protheus.doc} EnvWF
*******************************************************************************************
Envio de E-Mail

Retorno    Logico - .T. - Operacao realizada
                  - .F. - Operacao NAO realizada
 
@author: Marcelo Celi Marques
@since: 05/05/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function EnvWF(cPara, cCc, cAssunto, cMsg, cAnexo)
Local lRet		 	:= .F.
Local lResulConn 	:= .T.
Local lResulSend 	:= .T.
Local cServer  		:= Trim(GetMV("MV_RELSERV")) 
Local cEmail   		:= Trim(GetMV("MV_RELACNT")) 
Local cPass    		:= Trim(GetMV("MV_RELPSW"))  
Local lRelauth 		:= GetMv("MV_RELAUTH")
Local cDe      		:= cEmail             
Local lResult  		:= .F.

Default cCc      := ""
Default cAssunto := ""
Default cAnexo   := ""
Default cMsg     := Space(200)

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
   Return(lRet)
Endif

If lRelauth
	lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))
    
    //Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
	If !lResult
		nA := At("@",cEmail)
		cUser	:= If(nA>0,Subs(cEmail,1,nA-1),cEmail)
		lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
	Endif

Endif

If lResult 
	If Empty(cCc) .And. Empty(cAnexo)
	   SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
	Else
	   If Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend   
	   ElseIf !Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend   	   
	   ElseIf Empty(cCc) .And. Empty(cAnexo)   
			SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend   
	   Endif
	Endif
Endif

DISCONNECT SMTP SERVER

RETURN lResulSend	

/*/{protheus.doc} AbrePdf
*******************************************************************************************
Abre o arquivo pdf
 
@author: Marcelo Celi Marques
@since: 05/05/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AbrePdf(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		ShellExecute("open",cArquivo,"","",5)
	Else
		MsgAlert("Arquivo de Boleto nao localizado.")		
	EndIf	
Else
	MsgAlert("Arquivo de Boleto nao foi gerado.")
EndIf
Return

/*/{protheus.doc} Imprime
*******************************************************************************************
Impress�o do Boleto
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function Imprime(aCB_RN_NN,cCarteira,cBanco,cAgencia,cDvAgencia,cConta,cDvConta,cPasta)
Local cArquivo	 		:= "BOL_"+StrTran(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)," ","")
Local aDetalBanco		:= GetDetBanco(cBanco)
Local cTitulo			:= ""

Local nJuros			:= aRetMsgPara[02]
Local nMulta			:= aRetMsgPara[01]
Local cMsgTxBolet		:= Alltrim(aRetMsgPara[04])
Local cMsgInstruc		:= ""
Local nValorOrig		:= 0
Local nDesconto 		:= 0
Local nValorLiq			:= 0
Local cPastTmp			:= "\MCBOLETO\"

Local aDadosTit			:= {}

Local aBolText			:= {}

Local aDatPagador		:= {}

Local aBitMap 			:= {aDetalBanco[04],"iso9001.bmp"}

Local aDadosEmp			:=	{Left(SM0->M0_NOMECOM,50)  						                      	        ,;//[1]Nome da Empresa
				  			SM0->M0_ENDCOB                                                             		,;//[2]Endere�o
				  			AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB		,;//[3]Complemento
				  			"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)            		,;//[4]CEP
				  			"PABX/FAX: "+SM0->M0_TEL                                                  		,;//[5]Telefones
                  			transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + Space(10)+               		; 													//[6]
                  			IIF(Alltrim(UPPER(SM0->M0_INSC))=="ISENTO",ALLTRIM(UPPER(SM0->M0_INSC)),Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+  ; 	//[7]
				  			Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3))                       	} 														//[7]I.E

Local aDadosBanco  		:= {Alltrim(aDetalBanco[01])+"-"+Alltrim(aDetalBanco[02])						 	,;//[1]Numero do Banco
							aDetalBanco[03]    	            	                                		 	,;//[2]Nome do Banco
							cAgencia					              			                          	,;//[3]Ag�ncia
							cConta																			,;//[4]Conta Corrente
							cDvConta 				                                              			,;//[5]D�gito da conta corrente
							cCarteira		      			                             		 			,;//[6]Codigo da Carteira
							cDvAgencia 		                                                       			,;//[7]Digito da Ag�ncia
							aDetalBanco[05]																	,;//[8]Nome da Instituicao
							aDetalBanco[06]                                                                  }//[9]Mensagem de Pagamento Preferencial

//->> Ponto de Entrada para alterar os dados da Empresa
If ExistBlock("MCBOLDEMPR")
	aDadosEmp := ExecBlock("MCBOLDEMPR",.f.,.f.,{aDadosEmp})
EndIf

//->> Ponto de Entrada para alterar os dados do Banco
If ExistBlock("MCBOLDBANC")
	aDadosBanco := ExecBlock("MCBOLDBANC",.f.,.f.,{aDadosBanco})
EndIf

If Empty(SA1->A1_ENDCOB)
	aDatPagador := {AllTrim(SA1->A1_NOME)               	            ,;  // [1]Raz�o Social
					AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;	//[2]C�digo
					AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,;	//[3]Endere�o
					AllTrim(SA1->A1_MUN )                             	,;	//[4]Cidade
					SA1->A1_EST                                       	,;	//[5]Estado
					SA1->A1_CEP                                       	,;	//[6]CEP
					SA1->A1_CGC                                       	,;	//[7]CNPJ           
					SA1->A1_PESSOA									   	 }	//[8]PESSOA			
Else
	aDatPagador := {AllTrim(SA1->A1_NOME)             					,;	//[1]Raz�o Social
					AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;	//[2]C�digo
					AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	//[3]Endere�o
					AllTrim(SA1->A1_MUNC)	                             ,;	//[4]Cidade
					SA1->A1_ESTC	                                     ,;	//[5]Estado
					SA1->A1_CEPC                                         ,;	//[6]CEP
					SA1->A1_CGC                                          ,;	//[7]CNPJ
					SA1->A1_PESSOA									      }	//[8]PESSOA
Endif

//->> Ponto de Entrada para alterar os dados do Pagador
If ExistBlock("MCBOLDPAGA")
	aDatPagador := ExecBlock("MCBOLDPAGA",.f.,.f.,{aDatPagador})
EndIf

Makedir(cPastTmp)

cMsgInstruc := ""
If aRetMsgPara[03]
	nValorOrig  := SE1->E1_SALDO
	//->>Marcelo Celi - 14/10/2022
    nValorLiq	:= u_MCVlrBolet()[01]
    
    //nDesconto := u_MCVlrBolet()[01] * (SE1->E1_DESCFIN/100)
	//nValorLiq	:= u_MCVlrBolet()[01] - nDesconto
	
    cMsgInstruc += "APOS O VENCIMENTO COBRAR MULTA DE "   +Transform(nMulta,"@E 999,999") + "% E JUROS DE "+Transform(nJuros,"@E 999.999")+"% AO DIA"+CRLF
	
	//->>Marcelo Celi - 27/10/2022
	//cMsgInstruc += "PROTESTAR APOS 5 DIAS CORRIDOS DO VENCIMENTO / VALOR ORIGINAL R$ "+ Alltrim(Transform(nValorOrig,"@E 9,999,999,999.99"))+CRLF	
	cMsgInstruc += "PROTESTAR APOS 6 DIAS CORRIDOS DO VENCIMENTO"+CRLF

    //->>Marcelo Celi - 14/10/2022
    //cMsgInstruc += "DESCONTOS ("+Transform(SE1->E1_DESCFIN,"@E 99.99")+"%) (-) R$ "+Alltrim(Transform((u_MCVlrBolet()[01] * (SE1->E1_DESCFIN/100)),"@E 9,999,999,999.99"))+CRLF
    //cMsgInstruc += "DESCONTOS ("+Transform(SE1->E1_DESCFIN,"@E 99.99")+"%) (-) R$ "+Alltrim(Transform(u_MCVlrBolet()[04],"@E 9,999,999,999.99"))+CRLF


	//cMsgInstruc += "(+) ACRESCIMOS R$ "+Transform(SE1->E1_ACRESC,"@E 9,999,999.99")+"%) (=) VALOR LIQUIDO R$ "+Alltrim(Transform(nValorLiq,"@E 9,999,999,999.99"))
	cMsgInstruc += CRLF
EndIf
cMsgInstruc += cMsgTxBolet

aBolText := {cMsgInstruc}

//->> Ponto de Entrada para alterar os dados da Mensagem
If ExistBlock("MCBOLDMSG")
	aBolText := ExecBlock("MCBOLDMSG",.f.,.f.,{aBolText})
EndIf

If GetNewPar("MC_TITBOLE","I") == "I" .And. !Empty(SE1->E1_IDCNAB)
	cTitulo := SE1->E1_IDCNAB
Else
	cTitulo := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
EndIf	

aDadosTit := {	cTitulo														,;  // [1] N�mero do t�tulo
				SE1->E1_EMISSAO                              				,;  // [2] Data da emiss�o do t�tulo
				Date()                                  					,;  // [3] Data da emiss�o do boleto
				u_MCVlrBolet()[03]											,;  // [4] Data do vencimento
				u_MCVlrBolet()[01]			             					,;  // [5] Valor do t�tulo		
				aCB_RN_NN[03]								    			,;  // [6] Nosso n�mero (Ver f�rmula para calculo)
				SE1->E1_PREFIXO                               				,;  // [7] Prefixo da NF
				SE1->E1_TIPO	                               				,;  // [8] Tipo do Titulo
				SE1->E1_IRRF		    	                           			,;  // [9] IRRF
				SE1->E1_ISS	                             					,;  // [10] ISS
				SE1->E1_INSS 	                               				,;  // [11] INSS
				SE1->E1_PIS                                  				,;  // [12] PIS
				SE1->E1_COFINS                               				,;  // [13] COFINS
				SE1->E1_CSLL                               					,;  // [14] CSLL
				u_MCVlrBolet()[02]                         					}   // [15] Abatimentos

MakeDir(cPasta)

cPasta := Alltrim(cPasta)
cPasta += If(Right(cPasta,1)=="\","","\")
If File(cPasta+cArquivo+".pdf")
	FErase(cPasta+cArquivo+".pdf")
EndIf

// a classe FwMsPrinter() envia o comando de geração para o Windows e não espera a sua finalização.
// com isso, ele pode nõ conseguir gerar o arquivo .rel em tempo para a geração do pdf.
Sleep( 2000 )

aAdd(_aPrint,FWMSPrinter():New(cArquivo,6,.T.,cPastTmp,.T.,,,,,,,.F.))
_aPrint[Len(_aPrint)]:CPATHPDF := cPasta
_aPrint[Len(_aPrint)]:SetPortrait()
_aPrint[Len(_aPrint)]:SetResolution(72)
_aPrint[Len(_aPrint)]:SetPaperSize(DMPAPER_A4)
_aPrint[Len(_aPrint)]:SetMargin(60,60,60,60)
_aPrint[Len(_aPrint)]:StartPage()
MontaBoleto(_aPrint[Len(_aPrint)],aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatPagador,aBolText,aCB_RN_NN)

// a classe FwMsPrinter() envia o comando de geração para o Windows e não espera a sua finalização.
// com isso, ele pode nõ conseguir gerar o arquivo .rel em tempo para a geração do pdf.
Sleep( 2000 )

_aPrint[Len(_aPrint)]:EndPage()
_aPrint[Len(_aPrint)]:Print()

// a classe FwMsPrinter() envia o comando de geração para o Windows e não espera a sua finalização.
// com isso, ele pode nõ conseguir gerar o arquivo .rel em tempo para a geração do pdf.
Sleep( 3000 )

//->> Armazena o nome do arquivo
If File(cPasta+cArquivo+".pdf")
	aAdd(_aArquivos,{cPasta,cArquivo,SE1->(Recno())})
Else 
	aAdd(_aArquivos,{cPasta,"",SE1->(Recno())})
EndIf

Return
   
/*/{protheus.doc} GetDetBanco
*******************************************************************************************
Retorna detalhes do banco
 
@author: Marcelo Celi Marques
@since: 05/05/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDetBanco(cBanco)
Local aBanco := {}

If cBanco == "001"
	aBanco := {cBanco,"9","Banco do Brasil"			,cBanco+".jpg", "Banco do Brasil"			, "Pagavel em Qualquer Banco ate o Vencimento"}
                                                                                            	
ElseIf cBanco == "033"
	aBanco := {cBanco,"7","Santander"				,cBanco+".jpg", "Banco Santander S.A"		, "Pagavel em Qualquer Banco ate o Vencimento"}
	
ElseIf cBanco == "104"
	aBanco := {cBanco,"0","Caixa Economica Federal"	,cBanco+".jpg", "Caixa Economica Federal"	, "Pagavel em Qualquer Banco ate o Vencimento"}
	
ElseIf cBanco == "237"
	aBanco := {cBanco,"2","Bradesco"				,cBanco+".jpg", "Banco Bradesco S.A"		, "Pagavel Preferencialmente em qualquer agencia Bradesco"}

ElseIf cBanco == "341"
	aBanco := {cBanco,"7","Itau"					,cBanco+".jpg", "Banco Itau S.A"			, "Pagavel Preferencialmente em qualquer agencia Itau"}

ElseIf cBanco == "422"
	aBanco := {cBanco,"7","Safra"					,cBanco+".jpg", "Banco Safra S.A"			, "Pagavel em Qualquer Banco ate o Vencimento"}

Else
	aBanco := {cBanco,"0","Desconhecido"			,cBanco+".jpg", ""							, "Pagavel em Qualquer Banco ate o Vencimento"}

EndIf

//->> Ponto de Entrada para alterar os dados do Banco, bem como mensagens, titulos e logotipos
If ExistBlock("MCBOLDBCO")
	aBanco := ExecBlock("MCBOLDBCO",.f.,.f.,{aBanco})
EndIf

Return aBanco

/*/{protheus.doc} MontaBoleto
*******************************************************************************************
Monta o Boleto
 
@author: Marcelo Celi Marques
@since: 05/05/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MontaBoleto(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatPagador,aBolText,aCB_RN_NN)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont24
LOCAL oFontCN8
LOCAL i := 0
Local nX := 0
LOCAL oBrush 
Local nQtdChar	:= 0
Local nLines	:= 0
Local aMsg		:= {}
Local nFatLin 	:= 0   
Local cLogotipo := GetNewpar("MC_LOGOREP","BOL_LOGO.BMP")

//->> Ponto de Entrada para alterar o Layout da Impress�o do Boleto
If ExistBlock("MCBOLLAYOU")
	oPrint := ExecBlock("MCBOLLAYOU",.f.,.f.,{oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatPagador,aBolText,aCB_RN_NN})

Else
	oFont8  := TFont():New("Arial",8,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont7  := TFont():New("Arial",8,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",8,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n:= TFont():New("Tahoma",8,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16 := TFont():New("Arial" ,8,17,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n:= TFont():New("Arial",8,18,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24 := TFont():New("Arial",8,24,.T.,.T.,5,.T.,5,.T.,.F.)
	oFontCN8:= TFont():New("Courier New",8,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oBrush := TBrush():New("",4)

	oPrint:Line (0150,0350,0050,0350)
	oPrint:Line (0150,0600,0050,0600)

	oPrint:SayBitmap(0070,0005,aBitMap[1],300,80)

	oPrint:Say  (0130,0367,aDadosBanco[1]			                                               								,oFont24  )	// [1]Numero do Banco
	oPrint:Say  (0130,1800,"Comprovante de Entrega"                                                								,oFont10  )
	oPrint:Line (0150,000,0150,2300)
	oPrint:Say  (0185,0000,"Beneficiario"                                        											    ,oFont8  )
	oPrint:Say  (0180,0960,"Agencia/Codigo Beneficiario"                      						   							,oFont8  )
	oPrint:Say  (0220,0000,aDadosEmp[1]																							,oFont10 ) //Nome

	nPosFimAgConta := 960+oPrint:GetTextWidth(Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5])	,oFont10)
	
	oPrint:Say  (0220,0960,Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5])						,oFont10,,,,1 )
	oPrint:Say  (0260,0000,"Pagador"                                         													,oFont8  )
	oPrint:Say  (0260,0960,"Nosso Numero"                                    													,oFont8  )
	oPrint:Say  (0300,0000,SUBSTR(aDatPagador[1],1,48)						             										,oFont10 )	//Nome + Codigo

	nPosIniNossoNum := nPosFimAgConta - oPrint:GetTextWidth(Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4]) ,oFont10) 
	oPrint:Say  (0300,nPosIniNossoNum,Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4])						,oFont10,,,,1 )	//Nome + Codigo

	oPrint:Say  (0340,0000,"Vencimento"                                     											,oFont8  )
	oPrint:Say  (0340,0330,"Numero do documento"                                  										,oFont8  )
	oPrint:Say  (0340,0690,"Especie Moeda"                                  											,oFont8  )
	oPrint:Say  (0340,0960,"Valor do Documento"                          												,oFont8  )
	oPrint:Say  (0380,0000,DTOC(aDadosTit[4])                                                   						,oFont10 )

	oPrint:Say  (0380,0330,aDadosTit[1]														  							,oFont10 ) //Prefixo +Numero+Parcela

	oPrint:Say  (0380,0690,"R$"																							,oFont10 ) //Prefixo +Numero+Parcela
	oPrint:Say  (0380,1150,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))			   								,oFont10 )
	oPrint:Say  (0420,0000,"Recebi(emos) o bloqueto/titulo"                 											,oFont8  )
	oPrint:Say  (0420,0510,"Data"                                           											,oFont8  )
	oPrint:Say  (0420,0760,"Assinatura"                                 												,oFont8  )
	oPrint:Say  (0420,1310,"Data"                                           											,oFont8  )
	oPrint:Say  (0420,1560,"Entregador"                                 												,oFont8  )
	oPrint:Say  (0450,0000,"com as caracteristicas acima."             													,oFont8  )
	oPrint:Say  (0500,0000,"Local de Pagamento"                                											,oFont8  )
	oPrint:Say  (0500,1960,"Data do Processamento"                        												,oFont8  )
	oPrint:Say  (0530,0000,	aDadosBanco[09]																				,oFont10 )
							
	oPrint:Say  (0540,1960,DTOC(aDadosTit[2])                                  											,oFont10 )
	oPrint:Line (0230,0000,0230,1300 )
	oPrint:Line (0310,0000,0310,1300 )
	oPrint:Line (0390,0000,0390,2300 )
	oPrint:Line (0470,0000,0470,2300 )
	oPrint:Line (0550,0000,0550,2300 )

	oPrint:Line (0390,0320,0310,0320 )
	oPrint:Line (0470,0500,0390,0500 )
	oPrint:Line (0390,0680,0310,0680 )
	oPrint:Line (0470,0750,0390,0750 )
	oPrint:Line (0390,0900,0150,0900 )
	oPrint:Line (0470,1300,0150,1300 )
	oPrint:Line (0470,1550,0390,1550 )
	oPrint:Line (0550,1950,0470,1950 )

	oPrint:Say  (0180,1310,"Motivo de nao entrega. (Para uso da empresa entregadora)"								,oFont8 )
	oPrint:Say  (0250,1310,"[  ] Mudou-se"                                											,oFont8 )
	oPrint:Say  (0250,1650,"[  ] Ausente"                                    										,oFont8 )
	oPrint:Say  (0250,1950,"[  ] Nao existe n. indicado"                  											,oFont8 )
	oPrint:Say  (0310,1310,"[  ] Nao procurado"                              										,oFont8 )
	oPrint:Say  (0310,1650,"[  ] Recusado"                                											,oFont8 )
	oPrint:Say  (0310,1950,"[  ] Endereco insuficiente"                  											,oFont8 )
	oPrint:Say  (0370,1310,"[  ] Desconhecido"                            											,oFont8 )
	oPrint:Say  (0370,1650,"[  ] Falecido"                                   										,oFont8 )
	oPrint:Say  (0370,1950,"[  ] Outros(anotar no verso)"                											,oFont8 )

	For i := 0000 to 2250 step 50
		oPrint:Line( 0600, i, 0600, i+30)
	Next i

	oPrint:Line (0710,0000,0710,2300)
	oPrint:Line (0710,0350,0610,0350)
	oPrint:Line (0710,0600,0610,0600)

	oPrint:SayBitmap(0622,0005,aBitMap[1],300,80)

	oPrint:Say  (0690,0367,aDadosBanco[1]																			,oFont24 )	// [1]Numero do Banco
	oPrint:Say  (0690,0610,aCB_RN_NN[2]																				,oFont16 )	//Linha Digitavel do Codigo de Barras

	oPrint:Say  (0635,1650,"Recibo do Pagador"																		,oFont10)
	oPrint:SayBitmap(0615,1960,cLogotipo,300,80)

	oPrint:Line (0810,000,0810,2300 )
	oPrint:Line (0910,000,0910,2300 )
	oPrint:Line (0980,000,0980,2300 )
	oPrint:Line (1050,000,1050,2300 )

	oPrint:Line (0980,0220,1050,0220)
	oPrint:Line (0910,0350,1050,0350)
	oPrint:Line (0980,0500,1050,0500)
	oPrint:Line (0910,0750,1050,0750)
	oPrint:Line (0910,1050,0980,1050)
	oPrint:Line (0910,1150,1050,1150)

	oPrint:Say  (0730,000 ,"Local de Pagamento"                                           						    ,oFont8  )
	oPrint:Say  (0730,1710,"Vencimento"                                     										,oFont8  )
	oPrint:Say  (0760,000 ,aDadosBanco[08]																		    ,oFont10 )

	nPosFimVcto := 1855 + oPrint:GetTextWidth(DTOC(aDadosTit[4])													,oFont10)
	oPrint:Say  (0770,1855,DTOC(aDadosTit[4])        																,oFont10,,,,1)
	oPrint:Say  (0790,0000,aDadosBanco[09] 																			,oFont10 )

	oPrint:Say  (0830,0000 ,"Beneficiario/Endereco"                        											,oFont8)
	oPrint:Say  (0830,0795 ,"CNPJ"                                        											,oFont8)
	oPrint:Say  (0830,1125 ,"I.E."                                        											,oFont8)
	oPrint:Say  (0830,1710,"Agencia/Codigo Beneficiario"                         									,oFont8)

	oPrint:Say  (0860,0000,aDadosEmp[1]+"  "+aDadosEmp[6]															,oFont10) //Nome + CNPJ

	oPrint:Say  (0890,0000,aDadosEmp[2]+"     "+aDadosEmp[3]+"  "+aDadosEmp[4]                      				,oFont10 )

	nPosIniAgConta := nPosFimVcto - oPrint:GetTextWidth(Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5]),oFont10)
	oPrint:Say  (0890,nPosIniAgConta,Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5])	,oFont10,,,,1 )

	oPrint:Say  (0930,0000 ,"Data do Documento"                              						,oFont8  )

	oPrint:Say  (0970,0000 ,DTOC(aDadosTit[2])                               						,oFont10 ) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (0930,0370 ,"Numero do documento"                                  					,oFont8  )

	oPrint:Say  (0970,0370 ,aDadosTit[1]															,oFont10 ) //Prefixo +Numero+Parcela

	oPrint:Say  (0930,0770,"Especie Documento"                                   					,oFont8  )
	oPrint:Say  (0970,0770,aDadosTit[8]																,oFont10 ) //Tipo do Titulo

	oPrint:Say  (0930,1070,"Aceite"                                         						,oFont8  )
	oPrint:Say  (0970,1070," "                                             							,oFont10 )

	oPrint:Say  (0930,1180,"Data do Processamento"                          						,oFont8  )
	oPrint:Say  (0970,1180,DTOC(aDadosTit[3])                               						,oFont10 ) // Data impressao

	oPrint:Say  (0930,1710,"Nosso Numero"                                   						,oFont8  )

	nPosIniNossoNum := nPosFimVcto - oPrint:GetTextWidth(Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4])	,oFont10)
	oPrint:Say  (0970,nPosIniNossoNum,Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4]) 	     		  	,oFont10,,,,1)

	oPrint:Say  (1000,0000 ,"Uso do Banco"                                   						,oFont8  )

	oPrint:Say  (1000,0250 ,"Cip" 			                                  						,oFont8  )

	oPrint:Say  (1000,0370 ,"Carteira"                                       						,oFont8  )
	oPrint:Say  (1040,0370 ,aDadosBanco[6]                                  						,oFont10 )

	oPrint:Say  (1000,0525 ,"Especie Moeda"                                        					,oFont8  )
	oPrint:Say  (1040,0525 ,"R$"                                             						,oFont10 )

	oPrint:Say  (1000,0770,"Quantidade"                                     						,oFont8  )
	oPrint:Say  (1000,1180,"Valor"                                          						,oFont8  )

	oPrint:Say  (1000,1710,"Valor do Documento"                          							,oFont8  )

	nPosIniValor := nPosFimVcto - oPrint:GetTextWidth(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say  (1040,nPosIniValor,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))						,oFont10,,,,1 )

	oPrint:Say  (1070,0000,"Instrucoes (Texto de responsabilidade do Beneficiario)"					,oFont8   )

	nQtdChar:= 95
	nLines	:= MLCount(aBolText[1],nQtdChar,3,.T.)
	aMsg	:= {}
	nFatLin := 45
	For nX:=1 to nLines
		aAdd(aMsg,MemoLine(aBolText[1],nQtdChar,nX,3,.T.))
	Next nX		        
	For nX:=1 to Len(aMsg)	
		oPrint:Say  (1100+(nFatLin*nX),0000,aMsg[nX]                          						,oFont10  ) //Mensagem cobranca
	Next nX

	oPrint:Say  (1070,1710,"(-)Desconto/Abatimento"                         						,oFont8  )
	oPrint:Say  (1140,1710,"(-)Outras Deducoes"                             						,oFont8  )
	oPrint:Say  (1210,1710,"(+)Mora/Multa"                                  						,oFont8  )
	oPrint:Say  (1280,1710,"(+)Outros Acrescimos"                           						,oFont8  )
	oPrint:Say  (1350,1710,"(=)Valor Cobrado"                               						,oFont8  )

	oPrint:Say  (1420,0000,"Pagador"                                         						,oFont8  )
	oPrint:Say  (1440,0100,aDatPagador[1]+"   -    "+transform(aDatPagador[7],"@R 99.999.999/9999-99") ,oFont10 )

	oPrint:Say  (1475,0100,aDatPagador[3]                                    						,oFont10 )
	oPrint:Say  (1510,0100,aDatPagador[6]+"    "+aDatPagador[4]+" - "+aDatPagador[5]					,oFont10 ) // CEP+Cidade+Estado

	oPrint:Say  (1530,0000,"Pagador/Avalista"                               						,oFont8  )
	oPrint:Say  (1530,1760,"Papeleta processada e impressa pelo Beneficiario"                  		,oFont8	)
	oPrint:Say  (1565,1870,"Autenticacao Mecanica"                          						,oFont8  )

	oPrint:Line (0710,1700,1400,1700 )
	oPrint:Line (1120,1700,1120,2300 )
	oPrint:Line (1190,1700,1190,2300 )
	oPrint:Line (1260,1700,1260,2300 )
	oPrint:Line (1330,1700,1330,2300 )
	oPrint:Line (1400,0000,1400,2300 )
	oPrint:Line (1540,0000,1540,2300 )

	For i := 0000 to 2250 step 50
		oPrint:Line( 1710-02, i, 1710-02, i+30)
	Next i

	oPrint:Line (2000-03,0000,2000-03,2300)
	oPrint:Line (2000-03,0350,1900-03,0350)
	oPrint:Line (2000-03,0600,1900-03,0600)

	oPrint:SayBitmap(1910-03,0005,aBitMap[1],300,80)

	oPrint:Say  (1980-03,0367,aDadosBanco[1]															,oFont24 )	// [1]Numero do Banco
	oPrint:Say  (1980-03,0610,aCB_RN_NN[2]																,oFont16 )	//Linha Digitavel do Codigo de Barras

	oPrint:Line (2100-03,0000,2100-03,2300 )
	oPrint:Line (2200-03,0000,2200-03,2300 )
	oPrint:Line (2270-03,0000,2270-03,2300 )
	oPrint:Line (2340-03,0000,2340-03,2300 )
	oPrint:Line (2270-03,0220,2340-03,0220)
	oPrint:Line (2200-03,0350,2340-03,0350)
	oPrint:Line (2270-03,0500,2340-03,0500)
	oPrint:Line (2200-03,0750,2340-03,0750)
	oPrint:Line (2200-03,1050,2270-03,1050)
	oPrint:Line (2200-03,1150,2340-03,1150)

	oPrint:Say  (2020-03,0000,"Local de Pagamento"                             						,oFont8  )
	oPrint:Say  (2050-03,0000,aDadosBanco[08]						        						,oFont10 )
	oPrint:Say  (2080-03,0000,aDadosBanco[09] 										 				,oFont10 )

	oPrint:Say  (2020-03,1710,"Vencimento"                                     						,oFont8)

	nPosFimVcto := 1855 + oPrint:GetTextWidth(DTOC(aDadosTit[4]),oFont10)
	oPrint:Say  (2060-03,1855,DTOC(aDadosTit[4])	,oFont10)

	oPrint:Say  (2120-03,0000,"Beneficiario/Endereco"                         						,oFont8)
	oPrint:Say  (2120-03,0795 ,"CNPJ"                                        						,oFont8  )
	oPrint:Say  (2120-03,1125 ,"I.E."                                        						,oFont8  )
	oPrint:Say  (2120-03,1710,"Agencia/Codigo Beneficiario"                         						,oFont8)
	oPrint:Say  (2150-03,0000,aDadosEmp[1]+"  "+aDadosEmp[6]						,oFont10) //Nome + CNPJ
	oPrint:Say  (2180-03,0000,aDadosEmp[2]+"     "+aDadosEmp[3]+"  "+aDadosEmp[4]                        ,oFont10 )

	nPosIniAgConta := nPosFimVcto - oPrint:GetTextWidth(Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5]),oFont10)
	oPrint:Say  (2180-03,nPosIniAgConta,Alltrim(aDadosBanco[3])+" / "+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5])	,oFont10,,,,1 )

	oPrint:Say  (2220-03,0000,"Data do Documento"                              						,oFont8)
	oPrint:Say  (2255-03,0000,DTOC(aDadosTit[2])                               						,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (2220-03,0370,"Numero do documento"                                  						,oFont8)

	oPrint:Say  (2255-03,0370,aDadosTit[1]															,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (2220-03,0770,"Especie Documento"                                   						,oFont8)
	oPrint:Say  (2255-03,0770,aDadosTit[8]																,oFont10 ) //Tipo do Titulo

	oPrint:Say  (2220-03,1070,"Aceite"                                         						,oFont8)
	oPrint:Say  (2250-03,1070," "                                             							,oFont10)

	oPrint:Say  (2220-03,1180,"Data do Processamento"                          						,oFont8)
	oPrint:Say  (2255-03,1180,DTOC(aDadosTit[3])                               						,oFont10) // Data impressao

	oPrint:Say  (2220-03,1710,"Nosso Numero"                                   						,oFont8)

	nPosIniNossoNum := nPosFimVcto - oPrint:GetTextWidth(Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4]),oFont10) 
	oPrint:Say  (2255-03,nPosIniNossoNum,Alltrim(aDadosBanco[6])+"/"+Alltrim(aCB_RN_NN[3])+"-"+Alltrim(aCB_RN_NN[4])    	 			,oFont10,,,,1 )	//Nome + Codigo

	oPrint:Say  (2290-03,0000,"Uso do Banco"                                   						,oFont8)

	oPrint:Say  (2290-03,0250,"Cip"			                                   						,oFont8)

	oPrint:Say  (2290-03,0370,"Carteira"                                       						,oFont8)
	oPrint:Say  (2325-03,0370,aDadosBanco[6]                                  							,oFont10)

	oPrint:Say  (2290-03,0525,"Especie Moeda"                                        						,oFont8)
	oPrint:Say  (2325-03,0525,"R$"                                             						,oFont10)

	oPrint:Say  (2290-03,0770,"Quantidade"                                     						,oFont8)
	oPrint:Say  (2290-03,1180,"Valor"                                          						,oFont8)

	oPrint:Say  (2290-03,1710,"Valor do Documento"                          							,oFont8)

	nPosIniValor := nPosFimVcto - oPrint:GetTextWidth(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say  (2325-03,nPosIniValor,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))						,oFont10,,,,1 )

	oPrint:Say  (2360-03,0000,"Instrucoes (Texto de responsabilidade do Beneficiario)"						,oFont8)

	nQtdChar:= 95
	nLines	:= MLCount(aBolText[1],nQtdChar,3,.T.)
	aMsg	:= {}
	nFatLin := 45
	For nX:=1 to nLines
		aAdd(aMsg,MemoLine(aBolText[1],nQtdChar,nX,3,.T.))
	Next nX		        
	For nX:=1 to Len(aMsg)	
		oPrint:Say  (2390-03+(nFatLin*nX),0000,aMsg[nX]                          						,oFont10  ) //Mensagem cobranca
	Next nX

	oPrint:Say  (2360-03,1710,"(-)Desconto/Abatimento"                         						,oFont8)
	oPrint:Say  (2430-03,1710,"(-)Outras Deducoes"                             						,oFont8)
	oPrint:Say  (2500-03,1710,"(+)Mora/Multa"                                  						,oFont8)
	oPrint:Say  (2570-03,1710,"(+)Outros Acrescimos"                           						,oFont8)
	oPrint:Say  (2640-03,1710,"(=)Valor Cobrado"                               						,oFont8)

	oPrint:Say  (2710-03,0000,"Pagador"                                         						,oFont8)
	oPrint:Say  (2755-03,0100,aDatPagador[1]+"   -    "+Subs(aDatPagador[7],1,2)+"."+Subs(aDatPagador[7],3,3)+;
	"."+Subs(aDatPagador[7],6,3)+"/"+Subs(aDatPagador[7],9,4)+"-"+Subs(aDatPagador[7],13,2)	 ,oFont10 )

	oPrint:Say  (2790-03,0100,aDatPagador[3]                                    						,oFont10)
	oPrint:Say  (2825-03,0100,aDatPagador[6]+"    "+aDatPagador[4]+" - "+aDatPagador[5]					,oFont10) // CEP+Cidade+Estado

	oPrint:Say  (2865-03,0000,"Pagador/Avalista"                               						,oFont8)       //mais 100
	oPrint:Say  (2865-03,1760,"Papeleta processada e impressa pelo Beneficiario"                   			,oFont8)//mais 100
	oPrint:Say  (2905-03,1820,"Ficha de Compensacao"                           						,oFont10)//mais 100
	oPrint:Say  (2925-03,1850,"Autenticacao Meconica"                        							,oFont8)//mais 100

	oPrint:Line (2000-03,1700,2690-03,1700 )
	oPrint:Line (2410-03,1700,2410-03,2300 )
	oPrint:Line (2480-03,1700,2480-03,2300 )
	oPrint:Line (2550-03,1700,2550-03,2300 )
	oPrint:Line (2620-03,1700,2620-03,2300 )
	oPrint:Line (2690-03,0000,2690-03,2300 )

	oPrint:Line (2870-03,0000,2870-03,2300 )

	oPrint:FWMSBAR("INT25" /*cTypeBar*/,66/*nRow*/ ,1/*nCol*/, aCB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.027/*nWidth*/,1.7/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
EndIf

Return Nil

/*/{protheus.doc} MCVlrBolet
*******************************************************************************************
Retorna o Valor do Boleto, o abatimento e a data de vencimento para o boleto e par o cnab.
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MCVlrBolet()
Local _nVlrAbat  := 0
Local _nVlrBolet := 0 
Local _dVncBolet := Stod("")
Local aValImps 	 := RetImp()

//->>Marcelo Celi - 14/10/2022
Local _nDescFin  := 0

Local nSaldoTit  := 0
Local nDesconto  := 0
Local nJuros     := 0
Local aAreaSE1   := SE1->(GetArea())

_nVlrAbat  := 0 // SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

//->> Garantir que n�o despocionou ao usar a fun��o SomaAbat
SE1->(RestArea(aAreaSE1))

nJuros := fa070Juros(SE1->E1_MOEDA,SE1->E1_SALDO,"SE1",SE1->E1_BAIXA)

//->> Garantir que n�o despocionou ao usar a fun��o fa070juros
SE1->(RestArea(aAreaSE1))

nSaldoTit := SaldoTit(	SE1->E1_PREFIXO,	;
						SE1->E1_NUM,		;
						SE1->E1_PARCELA,	;
						SE1->E1_TIPO,		;
						SE1->E1_NATUREZA,	;
						"R",				;
						SE1->E1_CLIENTE,	;
						SE1->E1_MOEDA,		;
						SE1->E1_VENCREA,	;
						SE1->E1_VENCREA,	;
						SE1->E1_LOJA,		;
						,					;
						SE1->E1_TXMOEDA		)

//->> Garantir que n�o despocionou ao usar a fun��o saldotit
SE1->(RestArea(aAreaSE1))

nSaldoTit += ( SE1->E1_ACRESC - SE1->E1_DECRESC )
nSaldoTit -= (aValImps[5]+aValImps[3]+aValImps[4]+aValImps[7]+aValImps[2]+aValImps[6])
nSaldoTit += nJuros
nSaldoTit -= _nVlrAbat

nDesconto  := FaDescFin("SE1",dDatabase,nSaldoTit,1)

//->> Garantir que n�o despocionou ao usar a fun��o dadescfin
SE1->(RestArea(aAreaSE1))

nSaldoTit  -= nDesconto

//->>Marcelo Celi - 14/10/2022
/*/
_nDescFin := Round(SE1->E1_SALDO * (SE1->E1_DESCFIN/100),2)
_nVlrBolet := (SE1->E1_SALDO - _nVlrAbat + SE1->E1_ACRESC - SE1->E1_DECRESC - _nDescFin)

_dVncBolet := SE1->E1_VENCTO
_nVlrBolet := _nVlrBolet - (aValImps[5]+aValImps[3]+aValImps[4]+aValImps[7]+aValImps[2]+aValImps[6])
/*/

_nVlrBolet := nSaldoTit
_dVncBolet := SE1->E1_VENCTO
_nDescFin  := nDesconto

Return {_nVlrBolet,_nVlrAbat,_dVncBolet,_nDescFin}

/*/{protheus.doc} GeraBoleto
*******************************************************************************************
Geracao do Boleto
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Statico
*******************************************************************************************
/*/
Static Function GeraBoleto(aBoletos,cPasta)
Local nX   			:= 1
Local nY   			:= 1
Local aDadBolet		:= {}
Local cNossNumer	:= ""
Local cBarras		:= ""
Local cLinDig		:= ""
Local lOk			:= .T.
Local cArquivo		:= ""
Local aArquivos		:= {}
Local _nVlrAbat  	:= 0
Local _nVlrBolet 	:= 0
Local _dVncBolet 	:= Stod("")
Local aSE1			:= {}
Local cIdCnab 		:= ""
Local cChaveID		:= ""
Local aOrdSE1		:= {}
Local nOrdCNAB		:= 19
Local nRecSE1		:= 0
Local aArea			:= {}
Local aAreaSE1		:= {}

Private _aArquivos	:= {}
                            
ProcRegua(Len(aBoletos))
Begin Transaction	
	For nX:=1 to Len(aBoletos)
		IncProc("Aguarde! Gerando Boletos...") 	
	
		SE1->(dbGoto(aBoletos[nX,01]))
		
		aAdd(aSE1,{SE1->(Recno())})
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
		
		SEE->(dbSetOrder(1))
		SEE->(dbSeek(xFilial("SEE")+aRet01Param[02]+aRet01Param[03]+aRet01Param[04]+aRet01Param[05]))
		
		_nVlrBolet := u_MCVlrBolet()[01]
		_nVlrAbat  := u_MCVlrBolet()[02]
		_dVncBolet := u_MCVlrBolet()[03]
				
		If Empty(SE1->E1_NUMBCO)
			cNossNumer := StrZero(Val(SubStr(SEE->EE_FAXATU,1,GetTamanhos()[01]))+1,GetTamanhos()[01])	
			RecLock("SEE",.F.)
			Replace SEE->EE_FAXATU With cNossNumer
			MsUnlock()
		Else
			cNossNumer := SubStr(SE1->E1_NUMBCO,1,GetTamanhos()[01])
		EndIf
		cNossNumer := Val(cNossNumer)
		cNossNumer := StrZero(cNossNumer,GetTamanhos()[01])
		                    
	   	Do Case
	    	Case aRet01Param[02] == "001"    
			    aDadBolet := u_MC001GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,_dVncBolet,_nVlrBolet)


			Case aRet01Param[02] == "033"    
			    aDadBolet := u_MC033GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,_dVncBolet,_nVlrBolet,SEE->EE_CODEMP)
			
			
			Case aRet01Param[02] == "104"    
			    aDadBolet := u_MC104GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_DVAGE,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,SEE->EE_CODEMP,SEE->EE_LOTE,SEE->EE_NUMCTR,_dVncBolet,_nVlrBolet)


	    	Case aRet01Param[02] == "237"    
			    aDadBolet := u_MC237GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,_dVncBolet,_nVlrBolet)
			
	    		
	    	Case aRet01Param[02] == "341"    
			    aDadBolet := u_MC341GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,_dVncBolet,_nVlrBolet)


	    	Case aRet01Param[02] == "422"    
			    aDadBolet := u_MC422GeBol(SEE->EE_CODCART,SEE->EE_AGENCIA,SEE->EE_CONTA,SEE->EE_DVCTA,cNossNumer,_dVncBolet,_nVlrBolet)
			    
		EndCase 
		
		If Len(aDadBolet) > 0				
			cBarras		:= aDadBolet[01]
			cLinDig		:= aDadBolet[02]
			cLinDig		:= StrTran(cLinDig," ","")
			cLinDig		:= StrTran(cLinDig,".","")
	        
			If lOk .And. !VldCodBar(cBarras)
				lOk := .F.
				MsgAlert("Codigo de Barras gerado com problemas."+CRLF+"Operacao de geracao de boletos abortada.")			
			EndIf
				
			If lOk .And. !VldCodBar(cLinDig)
				lOk := .F.
				MsgAlert("Linha Digitavel gerada com problemas."+CRLF+"Operacao de geracao de boletos abortada.")			
			EndIf
				
			If lOk
				nRecSE1	:= SE1->(Recno())
				aArea	:= GetArea()
				aAreaSE1:= SE1->(GetArea())
				cIdCnab := ""

				If aRet01Param[08] .Or. !Empty(SE1->E1_NUMBOR)
					If Empty(SE1->E1_IDCNAB)
						cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,nOrdCNAB)
						cChaveID := cIdCnab
						dbSelectArea("SE1")
						aOrdSE1 := SE1->(GetArea())
						dbSetOrder(nOrdCNAB)
						While SE1->(MsSeek(cChaveID))
							ConOut("Id CNAB " + cIdCnab + " j� existe para o arquivo SE1. Gerando novo n�mero ")
							If ( __lSx8 )
								ConfirmSX8()
							EndIf
							cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,nOrdCNAB)
							cChaveID := cIdCnab
						EndDo
					Else
						cIdCnab := SE1->E1_IDCNAB
					EndIf
				EndIf

				SE1->(RestArea(aAreaSE1))
				RestArea(aArea)
				SE1->(dbGoto(nRecSE1))

				RecLock("SE1",.F.)
		 		Replace SE1->E1_NUMBCO  With Alltrim(aDadBolet[03])+Alltrim(aDadBolet[04])
		 		Replace SE1->E1_PORTADO With Alltrim(SEE->EE_CODIGO)
				If !Empty(cIdCnab)
					Replace SE1->E1_IDCNAB	With Alltrim(cIdCnab)
					Replace SE1->E1_OCORREN	With "01"
				EndIf	
				SE1->(MsUnlock())
				
				//->> Ponto de Entrada para gravar dados complementares na SE1, passando como referencia
				// (1) - Codigo de Barras
				// (2) - linha Digitavel
				// (3) - Nosso Numero
				// (4) - Digito do Nosso Numero
				If ExistBlock("MCBOLE1GRV")
					ExecBlock("MCBOLE1GRV",.f.,.f.,{aDadBolet[01],aDadBolet[02],aDadBolet[03],aDadBolet[04]})
				EndIf

				Imprime(aDadBolet,SEE->EE_CODCART,SEE->EE_CODIGO,SEE->EE_AGENCIA,SEE->EE_DVAGE,SEE->EE_CONTA,SEE->EE_DVCTA,cPasta)
			Else
				DisarmTransaction()
				aSE1 := {}
				For nY:=1 to Len(_aArquivos)
					cArquivo := Alltrim(_aArquivos[nY,01])
					cArquivo := If(Right(cArquivo,1)=="\","","\")
					cArquivo := cArquivo + Alltrim(_aArquivos[nY,02])+".pdf"
					FErase(cArquivo)				
				Next nY
				_aArquivos := {}
				Exit
			EndIf	
	    EndIf	
	Next nX

	If Len(aSE1)>0 .And. aRet01Param[08] .And. (aRet01Param[01] == 1 .Or. aRet01Param[01] == 2)
		FwMsgRun( ,{|| GravaBord(aSE1) }, , "Aguarde... Gerando Bordero..." )		
	EndIf	

End Transaction

aArquivos := _aArquivos

Return aArquivos

/*/{protheus.doc} GetTamanhos
*******************************************************************************************
Retorna o tamanho do campo
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetTamanhos()
Local aTamanho := {}

Do Case
   	Case aRet01Param[02] == "001"    
		aTamanho := u_MC001TamCp()
	   
	Case aRet01Param[02] == "033"    
	    aTamanho := u_MC033TamCp()
	
	Case aRet01Param[02] == "104"    
	    aTamanho := u_MC104TamCp()	
	
   	Case aRet01Param[02] == "237"    
	    aTamanho := u_MC237TamCp()	
    		
   	Case aRet01Param[02] == "341"    
	    aTamanho := u_MC341TamCp()
	    
   	Case aRet01Param[02] == "422"    
	    aTamanho := u_MC422TamCp()
	    
EndCase 

Return aTamanho
/*
Static cMVINSIRF  		:= nil
Static lPCCBaixa  		:= nil
Static dLastPcc   		:= nil
Static __cChvSEA  		:= ""
Static __cFilBor 		:= ""

// Motor de Retencoes
Static __lMotorRet 		:= NIL
Static __lPccMR 		:= .F.
Static __lIrfMR 		:= .F.
Static __lIssMR 		:= .F.
Static __lImpMotRet 	:= .F.
Static __lUsaFlag		:= .F.
Static __lImpMT 		:= .F.
Static __nImpMT 		:= 0
Static __nTotImp 		:= 0
Static __lPccBxMR 		:= .F.
Static __lIrfBxMR 		:= .F.
*/


/*/{protheus.doc} GravaBord
*******************************************************************************************
Grava o Bordero
 
@author: Marcelo Celi Marques
@since: 24/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GravaBord(aSE1)
Local nX 			:= 1
Local aArea			:= GetArea()
Local nRecProv		:= 0

Private cNumBor 	:= _cNumBord
PRIVATE nRadio		:= 1
Private cPort590	:= aRet01Param[02]
Private cAgen590	:= aRet01Param[03]
Private cConta590	:= aRet01Param[04]
Private cModPgto
Private cTipoPag
Private cLote
Private dDataBor	:= StoD("")
Private dDataBord	:= StoD("")
Private nIrrfFina061:= 0
Private nPisFina061	:= 0
Private nCofFina061	:= 0
Private nCslFina061	:= 0
Private aBaixaSE5	:= {}
Private nPIS		:= 0 // Variaveis Relativas a gravacao dos impostos (Junho/2013) ³
Private nCOFINS		:= 0
Private nCSLL		:= 0
Private nIrrf		:= 0
Private nParciais 	:= 0
Private nValRec		:= 0
Private nOldValRec	:= 0
Private aDadosRef	:= Array(7)
Private aDadosRet	:= Array(7)
Private lRaRtImp	:= FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A
Private aDadosTit	:= {}
Private cBordImp	:= ""
Private lTotMes		:= .F. //Nao calculo na totmes a parte das query´s referentes aos registros gerados por bordero de recebto de imposto.
Private cFilent

dbSelectArea("SX6")         
PutMv("MV_NUMBORR",_cNumBord)

//->> Criacao do registro de bordero provisorio, para usar n rotina FINA590 (Manutencao de bordero)
Reclock("SEA",.T.)
SEA->EA_FILIAL  := xFilial("SEA")
SEA->EA_NUMBOR  := _cNumBord
SEA->EA_DATABOR := dDataBase
SEA->EA_PORTADO := aRet01Param[02]
SEA->EA_AGEDEP  := aRet01Param[03]
SEA->EA_NUMCON  := aRet01Param[04]
SEA->EA_MODELO	:= ""
SEA->EA_TIPOPAG := ""
SEA->EA_CART	:= "R"
SEA->(MsUnlock())

nRecProv := SEA->(Recno())

cPort590  := SEA->EA_PORTADO
cAgen590  := SEA->EA_AGEDEP
cConta590 := SEA->EA_NUMCON
cModPgto  := SEA->EA_MODELO
cTipoPag  := SEA->EA_TIPOPAG
dDataBor  := SEA->EA_DATABOR
dDataBord := SEA->EA_DATABOR
cFilent   := SEA->EA_FILIAL

For nX:=1 to Len(aSE1)
	SE1->(dbGoto(aSE1[nX,01]))
	Fin590Rec(.F.,3,.T.)

	SE1->(dbGoto(aSE1[nX,01]))
	SEA->(dbSetOrder(2))
	If SEA->(dbSeek(Replicate(" ",Tamsx3("EA_FILIAL")[01])+_cNumBord+"R"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))	
		Reclock("SEA",.F.)
		SEA->EA_FILIAL := xFilial("SEA")
		SEA->(MsUnlock())
	EndIf	

	Reclock("SE1",.F.)
	SE1->E1_SITUACA := "1"
	SE1->(MsUnlock())

	//->> Ponto de Entrada na Inclus�o do Bordero a cada grava��o de registros, posicionado na SEA e SE1
	If ExistBlock("MCBOLBORD")
		ExecBlock("MCBOLBORD",.f.,.f.)
	EndIf

Next nX

SEA->(dbGoto(nRecProv))
Reclock("SEA",.F.)
Delete
SEA->(MsUnlock())

dbSelectArea("SX6")
GetMV("MV_NUMBORR")
MsUnlock()

RestArea(aArea)

Return

/*/{protheus.doc} GeraCnab
*******************************************************************************************
Gera o arquivo de remessa cnab
 
@author: Marcelo Celi Marques
@since: 24/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuParCnab()
Local aPergunte		:= {}

Pergunte("AFI150", .F., , , , , @aPergunte , .T., .T.)

If aRet01Param[01] == 1 .Or. aRet01Param[01] == 2
	mv_par01	:= _cNumBord 			// Do Bordero 		  
	mv_par02	:= _cNumBord 			// Ate o Bordero 	  
Else
	mv_par01	:= aRet04Param[01] 		// Do Bordero 		  
	mv_par02	:= aRet04Param[02] 		// Ate o Bordero 	  
EndIf
mv_par03	:= mv_par03					// Arq.Config 		  
mv_par04	:= mv_par04					// Arq. Saida    	  
mv_par05	:= aRet01Param[02]			// Banco     		  
mv_par06	:= aRet01Param[03]	 		// Agenciao     	  
mv_par07	:= aRet01Param[04]	 		// Conta   		  
mv_par08	:= aRet01Param[05]			// Sub-Conta  		  
mv_par09	:= mv_par09					// Cnab 1 / Cnab 2   
mv_par10	:= 2						// Considera Filiais 
mv_par11	:= cFilAnt					// De Filial   	  
mv_par12	:= cFilAnt					// Ate Filial        
mv_par13	:= 3		 				// Quebra por ?	  
mv_par14	:= 2						// Seleciona Filial? 		    

__SaveParam("AFI150", aPergunte)

aRet05Param[01]	:= mv_par01
aRet05Param[02]	:= mv_par02
aRet05Param[03]	:= mv_par03
aRet05Param[04]	:= mv_par04
aRet05Param[05]	:= mv_par05
aRet05Param[06]	:= mv_par06
aRet05Param[07]	:= mv_par07
aRet05Param[08]	:= mv_par08
aRet05Param[09]	:= mv_par09

Return .T.

/*/{protheus.doc} ProcCnab
*******************************************************************************************
Gera o arquivo de remessa cnab
 
@author: Marcelo Celi Marques
@since: 24/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcCnab()
Local aPergunte		:= {}

PRIVATE cCadastro := OemToAnsi("Comunicacao Bancaria - Envio Cobranca")
PRIVATE cNomeSai  := ""
PRIVATE cArqBkp   := ""
PRIVATE lAborta   := .F.

Pergunte("AFI150", .F., , , , , @aPergunte , .T., .T.)

mv_par01 := aRet05Param[01]	
mv_par02 := aRet05Param[02]
mv_par03 := aRet05Param[03]
mv_par04 := aRet05Param[04]
mv_par05 := aRet05Param[05]
mv_par06 := aRet05Param[06]
mv_par07 := aRet05Param[07]
mv_par08 := aRet05Param[08]
mv_par09 := aRet05Param[09]
mv_par10 := 1 // não considera as filiais dos parametros 11 e 12
mv_par11 := Replicate(" ",Len(mv_par11))
mv_par12 := Replicate("Z",Len(mv_par12))
mv_par13 := 3 // não quebra geração
mv_par14 := 1

__SaveParam("AFI150", aPergunte)

//->> Ponto de Entrada antes da cria��o do arquivo de remessa
If ExistBlock("MCBOLANREM")
	ExecBlock("MCBOLANREM",.f.,.f.)
EndIf

fa150Gera("SE1")

//->> Ponto de Entrada depois da cria��o do arquivo de remessa, passando como referencia:
// (1) ARQUIVO de saida gerado
// (2) Banco
// (3) Agencia
// (4) Conta
// (5) SubConta
If ExistBlock("MCBOLDEREM")
	ExecBlock("MCBOLDEREM",.f.,.f.,{mv_par04,mv_par05,mv_par06,mv_par07,mv_par08})
EndIf

Return .F.

/*/{protheus.doc} VldConfig
*******************************************************************************************
Valida as configurações
 
@author: Marcelo Celi Marques
@since: 24/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VldConfig(cBanco)
Local lRet  := .T.
Local cMsg1 := ""
Local cMsg2 := ""
Local cMsg3 := ""

Do Case 
	Case cBanco == "237"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s)."+CRLF
		
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf

	Case cBanco == "341"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s)."+CRLF
				
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf

	Case cBanco == "001"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s), onde os 4 ou 6 (dependendo do contrato com o Banco) primeiros devem ser Numero do Convenio fornecido pelo Banco."+CRLF
		
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf

	Case cBanco == "104"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"		
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF		
		cMsg2 += "Campo: EE_DVAGE, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[06]))+" caractere(s)."+CRLF

		cMsg3 += "Campo: EE_CODEMP, O Codigo do Beneficiario deve ser informado contendo "+Alltrim(Str(GetTamanhos()[07]))+" caractere(s)."+CRLF		
		cMsg3 += "Campo: EE_LOTE, O Lote deve ser informado contendo "+Alltrim(Str(GetTamanhos()[08]))+" caractere(s)."+CRLF		
		cMsg3 += "Campo: EE_NUMCTR, O Codigo da Operacao deve ser informado contendo "+Alltrim(Str(GetTamanhos()[09]))+" caractere(s)."+CRLF
		cMsg3 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s)."+CRLF
		
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVAGE) .Or. Len(Alltrim(SEE->EE_DVAGE)) <> GetTamanhos()[06])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CODEMP) .Or. Len(Alltrim(SEE->EE_CODEMP)) <> GetTamanhos()[07])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_LOTE) .Or. Len(Alltrim(SEE->EE_LOTE)) <> GetTamanhos()[08])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_NUMCTR) .Or. Len(Alltrim(SEE->EE_NUMCTR)) <> GetTamanhos()[09])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf

	Case cBanco == "033"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"		
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF		
		cMsg2 += "Campo: EE_CODEMP, O codigo do Cedente deve ser informado contendo "+Alltrim(Str(GetTamanhos()[06]))+" caractere(s)."+CRLF		
		cMsg2 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s)."+CRLF
		
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CODEMP) .Or. Len(Alltrim(SEE->EE_CODEMP)) <> GetTamanhos()[06])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf

	Case cBanco == "422"
		cMsg1 := "Operacao nao pode continuar ate que isso seja ajustado ou selecione outro Banco para continuar"		
		cMsg2 := "Campo: EE_CODCART, A Carteira deve ser informada contendo "+Alltrim(Str(GetTamanhos()[02]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_AGENCIA, A Agencia deve ser informada contendo "+Alltrim(Str(GetTamanhos()[03]))+" caractere(s)."+CRLF
		cMsg2 += "Campo: EE_CONTA, A Conta deve ser informada contendo "+Alltrim(Str(GetTamanhos()[04]))+" caractere(s) e sem digito verificador no campo."+CRLF
		cMsg2 += "Campo: EE_DVCTA, O Digito Verificador da Conta deve ser informado contendo "+Alltrim(Str(GetTamanhos()[05]))+" caractere(s)."+CRLF		
		cMsg2 += "Campo: EE_FAXATU,A Faixa Atual deve ser informada contendo "+Alltrim(Str(GetTamanhos()[01]))+" caractere(s)."+CRLF
		
		If lRet .And. (Empty(SEE->EE_CODCART) .Or. Len(Alltrim(SEE->EE_CODCART)) <> GetTamanhos()[02])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_AGENCIA) .Or. Len(Alltrim(SEE->EE_AGENCIA)) <> GetTamanhos()[03])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_CONTA) .Or. Len(Alltrim(SEE->EE_CONTA)) <> GetTamanhos()[04])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_DVCTA) .Or. Len(Alltrim(SEE->EE_DVCTA)) <> GetTamanhos()[05])
			lRet  := .F.
		EndIf

		If lRet .And. (Empty(SEE->EE_FAXATU) .Or. Len(Alltrim(SEE->EE_FAXATU)) <> GetTamanhos()[01])
			lRet  := .F.
		EndIf


EndCase

//->> Ponto de Entrada para Validar a SEE posicionada
If ExistBlock("MCBOLVLSEE")
	lRet := ExecBlock("MCBOLVLSEE",.f.,.f.,{lRet})
EndIf

If !lRet
	Aviso("Erro na Parametrizacao Bancaria",cMsg2 ,{ "OK" },2,cMsg1)

	If !Empty(cMsg3)
		Aviso("Erro na Parametrizacao Bancaria",cMsg3 ,{ "OK" },2,cMsg1)
	EndIf

EndIf

Return lRet

/*/{protheus.doc} GetSpedXML
*******************************************************************************************
Recupera o XML da nota.
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatica
*******************************************************************************************
/*/
Static Function GetSpedXML()
Local oWebServ		:= NIL
Local cURLTss      	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt       	:= _cIdent
Local cTextoXML    	:= ""
Local cDocumento 	:= PadR(SF2->F2_DOC, 	TamSX3('F2_DOC')[1])
Local cSerie     	:= PadR(SF2->F2_SERIE,  TamSX3('F2_SERIE')[1])
Local cArqXml		:= StrTran("DANFE_"+Alltrim(SF2->F2_FILIAL)+"-"+Alltrim(SF2->F2_DOC)+"-"+Alltrim(SF2->F2_SERIE)," ","")
Local cPastaInPdf	:= GetNewPar("MC_DIRPDFD","\MCBOLETO\")
Local cDestino		:= ""

cPastaInPdf += If(Right(cPastaInPdf,1)=="\","","\")
MakeDir(cPastaInPdf)

cDestino := cPastaInPdf + cArqXml + ".xml"

//Instancia a conexão com o WebService do TSS    
oWebServ:= WSNFeSBRA():New()
oWebServ:cUSERTOKEN        := "TOTVS"
oWebServ:cID_ENT           := cIdEnt
oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()

aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())

aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)

oWebServ:nDIASPARAEXCLUSAO := 0
oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
         
//Se tiver notas
If oWebServ:RetornaNotas()         
   	If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0		
		If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
			//Se tiver sido cancelada
			cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML			
			cDestino  := ""
		Else
			//Senão, pega o xml normal
			cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
			MemoWrite(cDestino,cTextoXML)
		EndIf
	EndIf
EndIf

Return cDestino

/*/{protheus.doc} GetPdfNota
*******************************************************************************************
Retorna o pdf da nota
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPdfNF()
Local cArqDanfe		:= StrTran("DANFE_"+Alltrim(SF2->F2_FILIAL)+"-"+Alltrim(SF2->F2_DOC)+"-"+Alltrim(SF2->F2_SERIE)," ","")
Local cPastaInPdf	:= Alltrim(GetNewPar("MC_DIRPDFD","\MCBOLETO\"))
Local cDestino  	:= ""

cPastaInPdf += If(Right(cPastaInPdf,1)=="\","","\")
MakeDir(cPastaInPdf)

If SpedDanfe(SF2->F2_DOC, SF2->F2_SERIE, cPastaInPdf, cArqDanfe, "S")			
	If File(cPastaInPdf + cArqDanfe + ".pdf")
		cDestino := cPastaInPdf + cArqDanfe + ".pdf"
	EndIf
Else
	cDestino := ""
EndIf

Return cDestino

/*/{protheus.doc} GetIdEnt
*******************************************************************************************
Retorna o ID da Entidade do sefaz.
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetIdEnt(lUsaColab)
Local cIdEnt := ""
Local cError := ""

Default lUsaColab := .F.

If !lUsaColab
	cIdEnt := getCfgEntidade(@cError)
	If(empty(cIdEnt))
		Conout("SPED - " + cError)
	Endif
Else
	If !( ColCheckUpd() )
		Conout("SPED - UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	Else
		cIdEnt := "000000"
	Endif	 
EndIf	

Return cIdEnt
      
/*/{protheus.doc} SpedDanfe
*******************************************************************************************
Gera o arquivo da Danfe em pdf.
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SpedDanfe(cNota, cSerie, cPasta, cArquivo, cTpOper)
Local aArea     := GetArea()
Local cIdent    := _cIdent
Local lEnd      := .F.
Local nTamNota  := TamSX3('F2_DOC')[1]
Local nTamSerie := TamSX3('F2_SERIE')[1]
Local lExistNFe := .F.
    
Private PixelX
Private PixelY
Private nConsNeg
Private nConsTex
Private oRetNF
Private nColAux
    
Default cNota   := ""
Default cSerie  := ""
Default cPasta  := GetTempPath()
     
//Se existir nota
If !Empty(cNota)
	//Pega o IDENT da empresa	
	If !Empty(cIdent) 		       
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf         
	    	         
		//Define as perguntas da DANFE
		Pergunte("NFSIGW",.F.)
		MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
		MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
		MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
		MV_PAR04 := If(cTpOper=="S",2,1)       //NF de Saida/Entrada
		MV_PAR05 := 2                          //Frente e Verso = Sim
		MV_PAR06 := 2                          //DANFE simplificado = Nao
	        
		If File(cPasta+cArquivo+".pdf")
			FErase(cPasta+cArquivo+".pdf")
		EndIf
	    
		//Propriedades da DANFE
		aAdd(_aPrint, FWMSPrinter():New(cArquivo, 6, .F.,cPasta, .T., , , , .T., , .F., ) )
		_aPrint[Len(_aPrint)]:SetResolution(78)
		_aPrint[Len(_aPrint)]:SetPortrait()
		_aPrint[Len(_aPrint)]:SetPaperSize(DMPAPER_A4)
		_aPrint[Len(_aPrint)]:SetMargin(60, 60, 60, 60)

		//Força a impressão em PDF
		_aPrint[Len(_aPrint)]:nDevice  	:= 6
		_aPrint[Len(_aPrint)]:cPathPDF 	:= cPasta
		_aPrint[Len(_aPrint)]:lInJob  	:= .T.
		_aPrint[Len(_aPrint)]:lServer  	:= .T.
		_aPrint[Len(_aPrint)]:lViewPDF 	:= .F.

		//Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
		PixelX    := _aPrint[Len(_aPrint)]:nLogPixelX()
	    PixelY    := _aPrint[Len(_aPrint)]:nLogPixelY()
	    nConsNeg  := 0.4
	    nConsTex  := 0.5
	    oRetNF    := Nil
	    nColAux   := 0

	   	//Chamando a impressão da danfe no RDMAKE
		//StaticCall(DANFEII, DanfeProc, @(_aPrint[Len(_aPrint)]), @lEnd, cIdent, , , @lExistNFe)
		u_DANFEProc(@(_aPrint[Len(_aPrint)]), @lEnd, cIdent, , , @lExistNFe)
	    _aPrint[Len(_aPrint)]:Print()

		// a classe FwMsPrinter() envia o comando de geração para o Windows e não espera a sua finalização.
		// com isso, ele pode nao conseguir gerar o arquivo .rel em tempo para a geração do pdf.
		Sleep( 2000 )

	EndIf	        
EndIf
     
RestArea(aArea)
	
If File(cPasta+cArquivo+".pdf")
	lRet := .T.	
Else
	lRet := .F.	
EndIf

Return lRet

/*/{protheus.doc} AnexarNota
*******************************************************************************************
Gera os arquivos de Danfe em pdf e o xml da nota para anexar ao email
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AnexarNota()
Local lTemNota 	:= .F.
Local cArqXml	:= ""
Local cArqDanf	:= ""
Local aArquivos	:= {}
Local nRecSF2	:= 0

If !Empty(_cIdent)
	SF2->(dbSetOrder(1))
	lTemNota := SF2->(dbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)))
	If lTemNota
		nRecSF2 := SF2->(Recno())
		
		If aRet01Param[09]
			SF2->(dbGoto(nRecSF2))
			cArqXml := GetSpedXML()
		EndIf	
		
		If aRet01Param[10]
			SF2->(dbGoto(nRecSF2))
			cArqDanf:= GetPdfNF()
		EndIf	

		If !Empty(cArqXml) .And. File(cArqXml)
			aAdd(aArquivos,cArqXml)
		EndIf
		If !Empty(cArqDanf) .And. File(cArqDanf)
			aAdd(aArquivos,cArqDanf)
		EndIf
	EndIf
EndIf

Return aArquivos

/*/{protheus.doc} RetImp
*******************************************************************************************
Funcao criada para Reter os Impostos conforme os Valores das Parcelas.
 
@author: Marcelo Celi Marques
@since: 29/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function RetImp()
Local nValor:=0
Local nValIR:=0
Local nValCF:=0
Local nValPI:=0
Local nValCS:=0
Local nValINS:=0
Local nValISS:=0  
Local cQuery:=""   
If Select("TRB") > 0
   DbSelectArea("TRB")
   DbCloseArea()
EndIf                  
cQuery := " SELECT E1_TIPO,E1_VALOR "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL		= '" + xfilial('SE1') + "' "  
cQuery += " AND   E1_PREFIXO    = '" + SE1->E1_PREFIXO + "' "
cQuery += " AND   E1_NUM        = '" + SE1->E1_NUM + "' "
cQuery += " AND   E1_PARCELA    = '" + SE1->E1_PARCELA + "' "
cQuery += " AND	  D_E_L_E_T_ <> '*' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
DbSelectArea("TRB") 
DbGoTop()

While TRB->(!Eof())
	If Alltrim(TRB->E1_TIPO)=="NF"
		nValor:=TRB->E1_VALOR
	ElseIf Alltrim(TRB->E1_TIPO)=="IR-"
		nValIR:=TRB->E1_VALOR
	ElseIf Alltrim(TRB->E1_TIPO)=="CF-" 
		nValCF:=TRB->E1_VALOR
	ElseIf Alltrim(TRB->E1_TIPO)=="PI-" 
		nValPI:=TRB->E1_VALOR
	ElseIf Alltrim(TRB->E1_TIPO)=="CS-" 
		nValCS:=TRB->E1_VALOR
	ElseIf Alltrim(TRB->E1_TIPO)=="INS" 
		nValINS:=TRB->E1_VALOR 
	ElseIf Alltrim(TRB->E1_TIPO)=="IS-" 
		nValISS:=TRB->E1_VALOR 
	EndIf
	TRB->(DbSkip())		
End
If Select("TRB") > 0
   DbSelectArea("TRB")
   DbCloseArea()
EndIf             

Return ({nValor,nValIR,nValCF,nValPI,nValCS,nValINS,nValISS})


//->> funcao provisoria para copiar as imagens
user function tstcopy(cPastTerm)
Local aArqs 	:= {}
Local nX		:= ""

Default cPastTerm := "D:\Dropbox\Workspace\Integra Consultoria\Boletos\"

aAdd(aArqs,{"001.bmp"})
aAdd(aArqs,{"033.bmp"})
aAdd(aArqs,{"104.bmp"})
aAdd(aArqs,{"237.bmp"})
aAdd(aArqs,{"341.bmp"})
aAdd(aArqs,{"422.bmp"})

aAdd(aArqs,{"001.jpg"})
aAdd(aArqs,{"033.jpg"})
aAdd(aArqs,{"104.jpg"})
aAdd(aArqs,{"237.jpg"})
aAdd(aArqs,{"341.jpg"})
aAdd(aArqs,{"422.jpg"})

aAdd(aArqs,{"faixa_001.bmp"})
aAdd(aArqs,{"faixa_033.bmp"})
aAdd(aArqs,{"faixa_104.bmp"})
aAdd(aArqs,{"faixa_237.bmp"})
aAdd(aArqs,{"faixa_341.bmp"})
aAdd(aArqs,{"faixa_422.bmp"})

aAdd(aArqs,{"faixa_L_001.bmp"})
aAdd(aArqs,{"faixa_L_033.bmp"})
aAdd(aArqs,{"faixa_L_104.bmp"})
aAdd(aArqs,{"faixa_L_237.bmp"})
aAdd(aArqs,{"faixa_L_341.bmp"})
aAdd(aArqs,{"faixa_L_422.bmp"})

For nX:=1 to Len(aArqs)
	cpyt2s(cPastTerm+Alltrim(aArqs[nX,01]),"\system")
Next nX

Return

/*/
User Function BoTst01()
Local nVlrBolet := 0
Local nVlrAbat  := 0
Local dVncBolet := 0
Local nDescFin  := 0

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"

If SE1->(dbSeek(xFilial("SE1")+PadR("1",Tamsx3("E1_PREFIXO")[01])+PadR("000045259",Tamsx3("E1_NUM")[01])+PadR(" ",Tamsx3("E1_PARCELA")[01])+PadR("NF",Tamsx3("E1_TIPO")[01])))
    nVlrBolet := u_MCVlrBolet()[01]
    nVlrAbat  := u_MCVlrBolet()[02]
    dVncBolet := u_MCVlrBolet()[03]
    nDescFin  := u_MCVlrBolet()[04]
EndIf

Return
/*/
