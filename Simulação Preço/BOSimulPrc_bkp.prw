#INCLUDE "TOTVS.CH"
#INCLUDE "apwizard.ch"
#INCLUDE 'MSGRAPHI.CH'

Static POSIC_PROD  	:= 0
Static POSIC_GRID  	:= 0
Static nCorSelPrd	:= Rgb(107,160,248)
Static nCorSelTab	:= Rgb(134,177,249)

/*/{protheus.doc} BOSimulPrc
*******************************************************************************************
Programa de Simulacao de Preco
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOSimulPrc()
Local oWizard			:= NIL
Local aBox01Param 		:= {}
Local cTextApres		:= ""
Local cLogotipo     	:= GetNewpar("BO_LOGOCLI","WIZARD")
Local lOk				:= .F.
Local aDados			:= {}
Local aOpcao			:= {"Somente os Produtos Contidos em Tabelas de Precos","Todos os Produtos, estando ou nao em tabelas de Precos"}

Private  aICMS			:= {"0","7","12","18"}
Private cOK				:= "ENABLE"
Private cNoOk			:= "DISABLE"
Private cSel			:= "CHECKED"	//"LBOK"
Private cNoSel			:= 'UNCHECKED'	//"LBNO"
Private cNoCheck		:= "NOCHECKED"
Private aRet01Param 	:= {}

aAdd( aRet01Param, 1									)
aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_COD")[01])	)
aAdd( aRet01Param, Replicate("Z",Tamsx3("B1_COD")[01])	)
aAdd( aRet01Param, 0									)
aAdd( aRet01Param, 0									)
aAdd( aRet01Param, "0"									)

aAdd( aBox01Param,{3,"Considerar na extracao"					,aRet01Param[01],aOpcao,250,".T.",.T.,".T."					})  
aAdd( aBox01Param,{1,"Produto de"								,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",060	,.F.})
aAdd( aBox01Param,{1,"Produto ate"								,aRet01Param[03] ,"@!"			,""	,"SB1"	,".T.",060	,.F.})

/*
aAdd( aBox01Param,{1,"% Sugerido Frete"							,aRet01Param[04] ,"@E 9,999.99"	,""	,""		,".T.",080	,.F.})
aAdd( aBox01Param,{1,"% Sugerido Comissao"						,aRet01Param[05] ,"@E 9,999.99"	,""	,""		,".T.",080	,.F.})
aAdd( aBox01Param,{3,"% ICMS"									,aRet01Param[06],aICMS,250,".T.",.T.,".T."					})  
*/

cTextApres := "Este recurso possibilita a que o usuario formate os precos mediante consultas e simulacoes."

oWizard := APWizard():New(  "Formacao de Preco",                												 ;   // chTitle  - Titulo do cabecalho
                            "", 														         			     ;   // chMsg    - Mensagem do cabecalho
                            "PRECOS",        													 			     ;   // cTitle   - Titulo do painel de apresentacao
                            cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
                            {|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                            {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                            NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Ttulo do painel 
                    "Informe os parametros para a selecao dos produtos", 			             			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
                    {|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
                    {|| MsgRun("Extraindo Dados...","Aguarde",{|| lOk := GetProdutos(@aDados) }), lOk }, 	     ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
                    {|| MsgRun("Extraindo Dados...","Aguarde",{|| lOk := GetProdutos(@aDados) }), lOk },  		 ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
                    .T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                    {|| .T. }                                            										 )   // bExecute - Bloco de cdigo a ser executado quando o painel for selecionado

Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

//->> Ativacao do Painel
oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                    {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                    {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

If lOk
	ProcimulPrc(aDados)
EndIf

Return

/*/{protheus.doc} ProcimulPrc
*******************************************************************************************
Processamento do Programa de Simulacao de Preco
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function ProcimulPrc(aDados)
Local aButtBar	    := {}
Local aButtons  	:= {}
Local aSize	    	:= MsAdvSize()
Local aCols			:= {}
Local aHeader		:= {}
Local lOk       	:= .F.
Local nColBut   	:= 2
Local nX        	:= 1
Local nY        	:= 1
Local aLegenda		:= {}

Private aObjetos	:= {}
Private aProdutos	:= aDados

//->> Marcelo Celi - 13/12/2020 - Ajusto do CMV e da margem de contribuicao
For nX:=1 to Len(aProdutos)
	nCusto := aProdutos[nX,04]
	For nY:=1 to Len(aProdutos[nX,11])
		aProdutos[nX,11][nY,07] := Round((nCusto / aProdutos[nX,11][nY,06]) * 100,4)
		aProdutos[nX,11][nY,012] := Round(100 - aProdutos[nX,11][nY,07] - aProdutos[nX,11][nY,08] - aProdutos[nX,11][nY,09] - aProdutos[nX,11][nY,10] - aProdutos[nX,11][nY,11],2)
	Next nY
    // Ordenando pela margem de contribui?
	aSort(aProdutos[nX,11], , , { | x,y | x[12] < y[12] } )
Next nX

POSIC_PROD := 1
POSIC_GRID := 1

//->> Layout da tela e controles
aAdd(aObjetos,{}) 									// 01 - oDlg
aAdd(aObjetos,{{},{},{}}) 							// 02 - Painel Principal
aAdd(aObjetos,{}) 									// 03 - Painel de Botoes
aAdd(aObjetos,{{},{},{},{},{},{},{},{}}) 			// 04 - Painel Superior, Painel Superior Interno, Painel de Caixa Superior, GetDados de Produtos
aAdd(aObjetos,{{},{},{},{}}) 						// 05 - Painel Central, Painel Central Interno, Painel de Caixa Central
aAdd(aObjetos,{{{},{}},{{},{}},{{},{}},{{},{}}}) 	// 06 - Controles de tela	
aAdd(aObjetos,{})									// 07 - Grid de Precos
aAdd(aObjetos,{})									// 08 - Botoes
aAdd(aObjetos,{})									// 09 - 1 Legendas
aAdd(aObjetos,{})									// 10 - 2 Legendas

DEFINE MSDIALOG aObjetos[01] TITLE "Simulacao de Formacao de Preco" FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

aObjetos[02][01] := TPanel():New(0,0,'',aObjetos[01], aObjetos[01]:oFont, .T., .T.,,,((aObjetos[01]:NWIDTH)/2),((aObjetos[01]:NHEIGHT)/2)-25,.F.,.F. )
aObjetos[02][01]:Align := CONTROL_ALIGN_ALLCLIENT

aObjetos[03] := TPanel():New(0,0,'',aObjetos[01], aObjetos[01]:oFont, .T., .T.,,RGB(195,195,195),((aObjetos[01]:NWIDTH)/2),(25),.F.,.T. )
aObjetos[03]:Align := CONTROL_ALIGN_BOTTOM

aObjetos[04,01] := TPanel():New(0,0,'',aObjetos[02][01], aObjetos[01]:oFont, .T., .T.,,,((aObjetos[02][01]:NWIDTH)/2),(((aObjetos[02][01]:NHEIGHT)/2)*.45),.F.,.F. )
aObjetos[04,01]:Align := CONTROL_ALIGN_TOP

aObjetos[04,02] := TPanel():New(0,0,'',aObjetos[04][01], aObjetos[01]:oFont, .T., .T.,,,((aObjetos[04][01]:NWIDTH)/2),(((aObjetos[04][01]:NHEIGHT)/2)),.F.,.F. )
aObjetos[04,02]:Align := CONTROL_ALIGN_ALLCLIENT

aObjetos[04,03] := TPanel():New(0,0,'',aObjetos[04,02], aObjetos[01]:oFont, .T., .T.,,RGB(235,235,235),15,(((aObjetos[04,02]:NHEIGHT)/2)),.F.,.F. )
aObjetos[04,03]:Align := CONTROL_ALIGN_LEFT

aAdd(aButtBar,{"CALCULADORA"				,{|| Calculadora() 	 },"Calculadora"		})
aAdd(aButtBar,{"LOCALIZA"					,{|| LocalizaPrd()	 },"Localizar Produto"	})
aAdd(aButtBar,{"BMPVISUAL"					,{|| A010Visul()	 },"Visualizar Produto"	})
aAdd(aButtBar,{"PRECO"						,{|| A010Consul()	 },"Consulta Produto"	})
aAdd(aButtBar,{"CONTAINR"					,{|| PesqEstoque()	 },"Pesquisa Estoque"	})
aAdd(aButtBar,{/*"S4WB013N"*/ "LINE"		,{|| PosicProdut()	 },"Posicao de Vendas"	})
aAdd(aButtBar,{"SDUSTRUCT"					,{|| mostraSG1() 	 },"Estrutura"			})	// MGOMES

//->> Marcelo Celi - 09/03/2021
aAdd(aButtBar,{"PMSEXCEL"					,{|| U_BoPrc2Exce(aProdutos)   },"Exporta Excel"		})

MyEnchBar(aObjetos[04][03],,,aButtBar,/*aButtonTxt*/,.F.,,,3,.T.)

aObjetos[04,04] := TPanel():New(0,0,'',aObjetos[04,02], aObjetos[01]:oFont, .T., .T.,,RGB(235,235,235),((aObjetos[04][02]:NWIDTH)/2)-15-300,(((aObjetos[04,02]:NHEIGHT)/2)),.F.,.F. )
aObjetos[04,04]:Align := CONTROL_ALIGN_ALLCLIENT

aObjetos[04,07] := TPanel():New(0,0,'',aObjetos[04,02], aObjetos[01]:oFont, .T., .T.,,RGB(235,235,235),300,(((aObjetos[04,02]:NHEIGHT)/2)),.T.,.F. )
aObjetos[04,07]:Align := CONTROL_ALIGN_RIGHT

aObjetos[04,05] := TToolBox():New(0,0,aObjetos[04,01],(aObjetos[04,01]:NWIDTH/2),(aObjetos[04,01]:NHEIGHT/2))
aObjetos[04,05]:AddGroup( aObjetos[04,02] , "Produtos")

aHeader := {}
Aadd(aHeader,{ "" 						/*DESCRIC*/, "LEGENDA" 	/*CAMPO*/, "@BMP"					 	/*PICTURE*/, 02 						/*TAMANHO*/, 0					 	/*DECIMAL*/, /*VALID*/, /*USADO*/, "C" 						/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 						 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("B1_COD")[02] 	/*DESCRIC*/, "B1_COD" 	/*CAMPO*/, PesqPict( "SB1", "B1_COD" ) 	/*PICTURE*/, Tamsx3("B1_COD")[01] 		/*TAMANHO*/, Tamsx3("B1_COD")[02] 	/*DECIMAL*/, /*VALID*/, /*USADO*/, Tamsx3("B1_COD")[03] 	/*TIPO*/, /*F3*/, "R" /*CONTEXT*/, GetInfCpo("B1_COD")[03] 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("B1_DESC")[02] /*DESCRIC*/, "B1_DESC" 	/*CAMPO*/, PesqPict( "SB1", "B1_DESC" ) /*PICTURE*/, Tamsx3("B1_DESC")[01]	 	/*TAMANHO*/, Tamsx3("B1_DESC")[02] 	/*DECIMAL*/, /*VALID*/, /*USADO*/, Tamsx3("B1_DESC")[03] 	/*TIPO*/, /*F3*/, "R" /*CONTEXT*/, GetInfCpo("B1_DESC")[03] /*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("B1_TIPO")[01] /*DESCRIC*/, "B1_TIPO" 	/*CAMPO*/, PesqPict( "SB1", "B1_TIPO" ) /*PICTURE*/, Tamsx3("B1_TIPO")[01] 		/*TAMANHO*/, Tamsx3("B1_TIPO")[02] 	/*DECIMAL*/, /*VALID*/, /*USADO*/, Tamsx3("B1_TIPO")[03] 	/*TIPO*/, /*F3*/, "R" /*CONTEXT*/, GetInfCpo("B1_TIPO")[03] /*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("B2_CM1")[02] 	/*DESCRIC*/, "B2_CM1" 	/*CAMPO*/, PesqPict( "SB2", "B2_CM1" ) +"99"	/*PICTURE*/, Tamsx3("B2_CM1")[01] 		/*TAMANHO*/, Tamsx3("B2_CM1")[02] 	/*DECIMAL*/, /*VALID*/, /*USADO*/, Tamsx3("B2_CM1")[03] 	/*TIPO*/, /*F3*/, "R" /*CONTEXT*/, GetInfCpo("B2_CM1")[03] 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("B2_DMOV")[02] /*DESCRIC*/, "B2_DMOV" 	/*CAMPO*/, PesqPict( "SB2", "B2_DMOV" ) /*PICTURE*/, Tamsx3("B2_DMOV")[01] 		/*TAMANHO*/, Tamsx3("B2_DMOV")[02] 	/*DECIMAL*/, /*VALID*/, /*USADO*/, Tamsx3("B2_DMOV")[03] 	/*TIPO*/, /*F3*/, "R" /*CONTEXT*/, GetInfCpo("B2_DMOV")[03] /*CBOX*/, Nil, Nil, "V" /*VISUAL*/})

aCols := {}
For nX:=1 to Len(aProdutos)
	aAdd(aCols,{LoadBitmap( GetResources(), If(aProdutos[nX,12],cOK,cNoOk)),aProdutos[nX,01],aProdutos[nX,02],aProdutos[nX,03],aProdutos[nX,04],aProdutos[nX,05],.F.})
Next nX

aObjetos[04,06] := MSNewGetDados():New(00,00,((aObjetos[04,04]:NHEIGHT)/2)-27,((aObjetos[04,04]:NWIDTH)/2),2,,.T.,,,,,,,,aObjetos[04,04],aHeader,aCols)
aObjetos[04,06]:bChange := {|| GuardaACOLs(),POSIC_PROD := aObjetos[04,06]:nAt,aObjetos[04,06]:Refresh(),AtuCampos(aObjetos[04,06]:aCols[aObjetos[04,06]:nAt]),AtuGrfTab()}
aObjetos[04,06]:oBrowse:SetBlkBackColor({|| GETDCLR(aObjetos[04,06]:nAt,POSIC_PROD,nCorSelPrd)})	

aLegenda := {}
aAdd(aLegenda,{cOK		,"Com Tabela de Preco"})
aAdd(aLegenda,{cNoOK	,"Sem Tabela de Preco"})

nColBut := 5	                     
For nX:=1 to Len(aLegenda)		
    aAdd(aObjetos[09],{	TBitmap():New((((aObjetos[04,04]:NHEIGHT)/2)-25),01,15,15,,,.T.,aObjetos[04,04],{|| },,.T.,.F.,,,.F.,,.T.,,.F.),;
                        TSay():New((((aObjetos[04,04]:NHEIGHT)/2)-25),01, {|| " " }, aObjetos[04,04],,aObjetos[01]:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20)})
    
    aObjetos[09][Len(aObjetos[09])][1]:NLEFT 	:= nColBut 
    aObjetos[09][Len(aObjetos[09])][1]:CRESNAME := aLegenda[nX,01]
    aObjetos[09][Len(aObjetos[09])][1]:Refresh()
    
    aObjetos[09][Len(aObjetos[09])][2]:NLEFT 	:= nColBut + 30
    aObjetos[09][Len(aObjetos[09])][2]:SetText(aLegenda[nX,02])
    aObjetos[09][Len(aObjetos[09])][2]:CtrlRefresh()
    
    nColBut += (Len(aLegenda[nX,02])*7)+35
Next nX

aObjetos[05,01] := TPanel():New(0,0,'',aObjetos[02][01], aObjetos[01]:oFont, .T., .T.,,,((aObjetos[02][01]:NWIDTH)/2),(((aObjetos[02][01]:NHEIGHT)/2)*.55),.F.,.F. )
aObjetos[05,01]:Align := CONTROL_ALIGN_ALLCLIENT

aObjetos[05,02] := TPanel():New(0,0,'',aObjetos[05,01], aObjetos[01]:oFont, .T., .T.,,RGB(235,235,235),((aObjetos[05,01]:NWIDTH)/2),((aObjetos[05,01]:NHEIGHT)/2),.F.,.T. )
aObjetos[05,02]:Align := CONTROL_ALIGN_ALLCLIENT

aObjetos[05,03] := TToolBox():New(0,0,aObjetos[05,01],(aObjetos[05,01]:NWIDTH/2),(aObjetos[05,01]:NHEIGHT/2))
aObjetos[05,03]:AddGroup( aObjetos[05,02] , "Tabelas de Precos")

nColBut := 5
@ 002,nColBut GET aObjetos[06][01,01] VAR aObjetos[06][01,02]  WHEN .F. SIZE (Tamsx3("B1_DESC")[01]*4),10 	OF aObjetos[05,02] PIXEL
@ 014,nColBut Say GetInfCpo("B1_DESC")[02] OF aObjetos[05,02] PIXEL

nColBut += (Tamsx3("B1_DESC")[01]*4)+5 
@ 002,nColBut GET aObjetos[06][02,01] VAR aObjetos[06][02,02]  WHEN .F. SIZE (Tamsx3("B1_XFABRIC")[01]*4),10 	OF aObjetos[05,02] PIXEL
@ 014,nColBut Say GetInfCpo("B1_XFABRIC")[02] OF aObjetos[05,02] PIXEL

nColBut += (Tamsx3("B1_XFABRIC")[01]*4)+5 
@ 002,nColBut GET aObjetos[06][03,01] VAR aObjetos[06][03,02]  WHEN .F. SIZE (Tamsx3("B1_XNOMGRP")[01]*4),10 	OF aObjetos[05,02] PIXEL
@ 014,nColBut Say GetInfCpo("B1_XNOMGRP")[02] OF aObjetos[05,02] PIXEL

nColBut += (Tamsx3("B1_XNOMGRP")[01]*4)+5 
@ 002,nColBut GET aObjetos[06][04,01] VAR aObjetos[06][04,02]  WHEN .F. SIZE (Tamsx3("B1_XVALID")[01]*4),10 	OF aObjetos[05,02] PIXEL
@ 014,nColBut Say GetInfCpo("B1_XVALID")[02] OF aObjetos[05,02] PIXEL

aHeader := {}
Aadd(aHeader,{ "" 							/*DESCRIC*/, "LEGENDA" 		/*CAMPO*/, "@BMP"					 		/*PICTURE*/, 02 							/*TAMANHO*/, 0						 	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, "C" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("DA0_CODTAB")[02] 	/*DESCRIC*/, "TABELA" 		/*CAMPO*/, PesqPict( "DA0", "DA0_CODTAB" ) 	/*PICTURE*/, Tamsx3("DA0_CODTAB")[01] 		/*TAMANHO*/, Tamsx3("DA0_CODTAB")[02] 	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, Tamsx3("DA0_CODTAB")[03] 		/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, GetInfCpo("DA0_CODTAB")[03] 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ GetInfCpo("DA0_DESCRI")[02] 	/*DESCRIC*/, "DESCRICAO" 	/*CAMPO*/, PesqPict( "DA0", "DA0_DESCRI" ) 	/*PICTURE*/, Tamsx3("DA0_DESCRI")[01] 		/*TAMANHO*/, Tamsx3("DA0_DESCRI")[02] 	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, Tamsx3("DA0_DESCRI")[03] 		/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, GetInfCpo("DA0_DESCRI")[03] 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})

//->> Marcelo Celi - 13/12/2020
//Aadd(aHeader,{ GetInfCpo("DA1_TIPPRE")[02] 	/*DESCRIC*/, "TIPPRE"		/*CAMPO*/, "@!" 							/*PICTURE*/, Tamsx3("DA1_TIPPRE")[01]		/*TAMANHO*/, Tamsx3("DA1_TIPPRE")[02]	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, Tamsx3("DA1_TIPPRE")[03] 		/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, GetInfCpo("DA1_TIPPRE")[03]	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ "Quantidade Ult. M?" 	/*DESCRIC*/, "TIPPRE"		/*CAMPO*/, "@!" 							/*PICTURE*/, 12		/*TAMANHO*/, 2	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, "N" 		/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, Nil	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})

Aadd(aHeader,{ GetInfCpo("DA1_PRCVEN")[02] 	/*DESCRIC*/, "PRECO"		/*CAMPO*/, "@E 9,999,999.99" 				/*PICTURE*/, Tamsx3("DA1_PRCVEN")[01]		/*TAMANHO*/, Tamsx3("DA1_PRCVEN")[02]	/*DECIMAL*/, 					/*VALID*/, /*USADO*/, Tamsx3("DA1_PRCVEN")[03] 		/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ "Simulacao - R$" 			/*DESCRIC*/, "SIMULA"		/*CAMPO*/, "@E 9,999,999.99" 				/*PICTURE*/, 12								/*TAMANHO*/, 2						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})
Aadd(aHeader,{ "% CMV" 						/*DESCRIC*/, "MARGEM" 		/*CAMPO*/, "@E 999,999,999,999.9999"		/*PICTURE*/, 16 							/*TAMANHO*/, 4						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ "% Comiss Vda" 				/*DESCRIC*/, "COMISSAO"		/*CAMPO*/, "@E 999.99" 						/*PICTURE*/, 6 								/*TAMANHO*/, 2						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})
Aadd(aHeader,{ "% Logistica" 				/*DESCRIC*/, "FRETE"		/*CAMPO*/, "@E 999.99" 						/*PICTURE*/, 6 								/*TAMANHO*/, 2						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})

//->> Marcelo Celi - 13/12/2020
//Aadd(aHeader,{ "% Impostos" 				/*DESCRIC*/, "ICMS"			/*CAMPO*/, "@!" 							/*PICTURE*/, 2 								/*TAMANHO*/, 0						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "C" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, "0=0%;7=7%;12=12%;18=18%" 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})
Aadd(aHeader,{ "% Impostos" 				/*DESCRIC*/, "ICMS"			/*CAMPO*/, "@E 999.99" 						/*PICTURE*/, 2 								/*TAMANHO*/, 0						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})

//->> Marcelo Celi - 13/12/2020
//Aadd(aHeader,{ "Lucro Operacional - R$"	/*DESCRIC*/, "LUCRO"		/*CAMPO*/, "@E 9,999,999.99" 				/*PICTURE*/, 12								/*TAMANHO*/, 2						 	/*DECIMAL*/, ""					/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ "% Desconto"					/*DESCRIC*/, "DESCONTO"		/*CAMPO*/, "@E 999.99" 						/*PICTURE*/, 12								/*TAMANHO*/, 2						 	/*DECIMAL*/, "u_BOVldSiPrc()"	/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "A" /*VISUAL*/})

Aadd(aHeader,{ "Margem Contribuicao - %"	/*DESCRIC*/, "PERCLUCRO"	/*CAMPO*/, "@E 9,999,999.99" 				/*PICTURE*/, 12								/*TAMANHO*/, 2						 	/*DECIMAL*/, ""					/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})
Aadd(aHeader,{ "Recno"						/*DESCRIC*/, "RECNO"		/*CAMPO*/, "" 								/*PICTURE*/, 12								/*TAMANHO*/, 0						 	/*DECIMAL*/, ""					/*VALID*/, /*USADO*/, "N" 							/*TIPO*/, /*F3*/, "V" /*CONTEXT*/, 							 	/*CBOX*/, Nil, Nil, "V" /*VISUAL*/})

aCols := aClone(aProdutos[01][11])
aObjetos[07] := MSNewGetDados():New(25,05,((aObjetos[05,02]:NHEIGHT)/2)-40,((aObjetos[05,02]:NWIDTH)/2)-5,GD_UPDATE,,.T.,,,,,,,,aObjetos[5,02],aHeader,aCols)
aObjetos[07]:bChange := {|| POSIC_GRID := aObjetos[07]:nAt,aObjetos[07]:Refresh()}
aObjetos[07]:oBrowse:SetBlkBackColor({|| GETDCLR(aObjetos[07]:nAt,POSIC_GRID,nCorSelTab)})	
aObjetos[07]:oBrowse:bldblclick := { || If( aObjetos[07]:oBrowse:COLPOS == 1,MarcaDesmar(),aObjetos[07]:EDITCELL()) }

//->> Formatacao dos botoes                                                         // Executar e se manter na tela                                                                     
aAdd(aButtons,{"Atualizar Tabela de Precos" ,100 ,20 ,3  ,"SALVAR.png"       ,  {|| If(TudoOk(),(/*aObjetos[01]:End()*/lOk:=.T.,GrvPrices(lok),aObjetos[07]:Refresh()),.T.)   								 			    	  }   })
aAdd(aButtons,{"Sair" 		                ,100 ,20 ,3  ,"FINAL.png"     		 ,  {|| If(MsgYesNo("Confirma a Saida da Rotina de Formacao de Precos ?"),(aObjetos[01]:End(),lOk:=.F.),.T.)  }   })

nColBut := 2
For nX:=1 to Len(aButtons)
	aAdd(aObjetos[08],TButton():New(002,nColBut,aButtons[nX,01] ,aObjetos[03],aButtons[nX,06],aButtons[nX,02],aButtons[nX,03],,,.F.,.T.,.F.,,.F.,,,.F. ))
	aObjetos[08][Len(aObjetos[08])]:SetCss(GetStyloBt(aButtons[nX,04],aButtons[nX,05]))     
	nColBut += aButtons[nX,02] + 5
Next nX

aLegenda := {}
aAdd(aLegenda,{cNoSel		,"Nao Selecionado"			})
aAdd(aLegenda,{cSel			,"Selecionado    "			})
aAdd(aLegenda,{cNoCheck		,"Nao Pode ser Selecionado"	})

nColBut := 5	                     
For nX:=1 to Len(aLegenda)		
    aAdd(aObjetos[10],{	TBitmap():New((((aObjetos[05,02]:NHEIGHT)/2)-38),01,15,15,,,.T.,aObjetos[05,02],{|| },,.T.,.F.,,,.F.,,.T.,,.F.),;
                        TSay():New((((aObjetos[05,02]:NHEIGHT)/2)-38),01, {|| " " }, aObjetos[05,02],,aObjetos[01]:oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20)})
    
	aObjetos[10][Len(aObjetos[10])][1]:NTOP -= 4
	
    aObjetos[10][Len(aObjetos[10])][1]:NLEFT 	:= nColBut 
    aObjetos[10][Len(aObjetos[10])][1]:CRESNAME := aLegenda[nX,01]
    aObjetos[10][Len(aObjetos[10])][1]:Refresh()
    
    aObjetos[10][Len(aObjetos[10])][2]:NLEFT 	:= nColBut + 30
    aObjetos[10][Len(aObjetos[10])][2]:SetText(aLegenda[nX,02])
    aObjetos[10][Len(aObjetos[10])][2]:CtrlRefresh()
    
    nColBut += (Len(aLegenda[nX,02])*7)+35
Next nX


ACTIVATE MSDIALOG aObjetos[01] CENTER            


Return

Static Function GrvPrices(lok)

If lOk
	MsgRun("Gravando os Precos Calculados...","Aguarde",{|| GravaPrecos() })
EndIf

MSGINFO( "Processamento finalizado!", "Forma? de pre?." )

Return(.T.)


/*/{protheus.doc} AtuCampos
*******************************************************************************************
Atualiza os campos da tela
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuCampos(aLinGridPrd)
Local nPos := 0

nPos := Ascan(aProdutos,{|x| x[01]==aLinGridPrd[02]})
If nPos > 0
	aObjetos[06][01,02] := aProdutos[nPos,02] // Descricao
	aObjetos[06][02,02] := aProdutos[nPos,06] // Fabricante
	aObjetos[06][03,02] := aProdutos[nPos,07] // Nome do Grupo
	aObjetos[06][04,02] := aProdutos[nPos,08] // Validade
	
	aObjetos[06][01,01]:Refresh()
	aObjetos[06][02,01]:Refresh()
	aObjetos[06][03,01]:Refresh()
	aObjetos[06][04,01]:Refresh()

	aObjetos[07]:aCols 	:= aClone(aProdutos[nPos][11])
	aObjetos[07]:nAt	:= 1	
	POSIC_GRID := aObjetos[07]:nAt

	If aProdutos[nPos][12]
		aObjetos[07]:lActive := .T.
	Else
		aObjetos[07]:lActive := .F.
	EndIf
	aObjetos[07]:Refresh()

	//->> Posiciona no registro do produto
	SB1->(dbGoto(aProdutos[nPos,13]))
EndIf

Return

/*/{protheus.doc} GuardaACOLs
*******************************************************************************************
Guarda o acols atualizado na linha desposicionada
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GuardaACOLs()
Local nPos := 0

nPos := Ascan(aProdutos,{|x| x[01]==aObjetos[04,06]:aCols[POSIC_PROD][02]})
If nPos > 0
	aProdutos[nPos,11] := aClone(aObjetos[07]:aCols)
EndIf

Return

/*/{protheus.doc} GetInfCpo
*******************************************************************************************
Retorna as informacoes do campo
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetInfCpo(cCampo)
Local aRetorno := {}

SX3->(dbSetOrder(2))
If SX3->(dbSeek(cCampo))
	aAdd(aRetorno,X3Titulo())
	aAdd(aRetorno,X3Descric())
	aAdd(aRetorno,X3CBox())
EndIf

Return aRetorno

/*/{protheus.doc} GetProdutos
*******************************************************************************************
Retorna em array, os dados extraidos do cadastro de produtos
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetProdutos(aDados)
Local lOk	 	:= .F.
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local aCusto 	:= {}	
Local lConsidera:= .F.

aDados := {}

cQuery := "SELECT SB1.B1_COD,"															+CRLF
cQuery += "		  SB1.B1_DESC,"															+CRLF
cQuery += "		  SB1.B1_TIPO,"															+CRLF
cQuery += "		  SB1.B1_XFABRIC,"														+CRLF
cQuery += "		  SB1.B1_XNOMGRP,"														+CRLF
cQuery += "		  SB1.B1_XVALID,"														+CRLF
cQuery += "		  SB1.B1_XVLDAAB,"														+CRLF
cQuery += "		  SB1.R_E_C_N_O_ AS RECSB1"												+CRLF
cQuery += "	FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
cQuery += "	WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"									+CRLF
cQuery += "	  AND SB1.B1_COD BETWEEN '"+aRet01Param[02]+"' AND '"+aRet01Param[03]+"'"	+CRLF
//cQuery += "	  AND SB1.B1_TIPO   IN ('PA','ME')"										+CRLF
cQuery += "	  AND SB1.D_E_L_E_T_ = ' '	"												+CRLF
cQuery += " ORDER BY SB1.B1_DESC"														+CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	lConsidera := .T.
	If aRet01Param[01]==1
		DA1->(dbSetOrder(2))
		lConsidera := DA1->(dbSeek(xFilial("DA1")+(cAlias)->B1_COD))
	EndIf

	If lConsidera

        aStCus := U_SumCosts((cAlias)->B1_COD)

		if Len(aStCus[4]) = 0 
		   aCusto := GetCustoPrd((cAlias)->B1_COD)
		else 
		   aCUsto := {aStCus[3],dDataBase}   
        endif
		
		aAdd(aDados,{(cAlias)->B1_COD,		; // 01
					(cAlias)->B1_DESC,		; // 02
					(cAlias)->B1_TIPO,		; // 03
					aCusto[01],				; // 04
					aCusto[02],				; // 05	
					(cAlias)->B1_XFABRIC,	; // 06
					(cAlias)->B1_XNOMGRP,	; // 07
					(cAlias)->B1_XVALID,	; // 08
					(cAlias)->B1_XVLDAAB,	; // 09
					{},						; // 10
					{},						; // 11
					.T.,					; // 12
					(cAlias)->RECSB1}		) // 13

		//->> Marcelo Celi - 14/10/2022
		DA0->(dbSetOrder(1))
		DA1->(dbSetOrder(2))
		If DA1->(dbSeek(xFilial("DA1")+(cAlias)->B1_COD)) //.And. DA0->(dbSeek(xFilial("DA0")+DA1->DA1_CODTAB)) .And. DA0->DA0_ATIVO <> "2"
			Do While DA1->(!Eof()) .And. DA1->(DA1_FILIAL+DA1_CODPRO) == xFilial("DA1")+(cAlias)->B1_COD
				DA0->(dbSetOrder(1))
				If DA0->(dbSeek(xFilial("DA0")+DA1->DA1_CODTAB)) .And. DA0->DA0_ATIVO <> "2"
					
					//->> Dados da tabela de preco
					aAdd(aDados[Len(aDados)][10],{	DA0->DA0_CODTAB,; // 01
													DA0->DA0_DESCRI,; // 02
													DA1->DA1_ITEM,	; // 03
													DA1->DA1_CODPRO,; // 04
													DA1->DA1_PRCVEN,; // 05
													DA1->DA1_PRCVEN,; // 06
													DA1->DA1_VLRDES,; // 07
													DA1->DA1_FRETE,	; // 08
													DA1->(Recno())}	) // 09	
					
					//->> aCols
					//->> Marcelo Celi - 13/12/2020
					/*
					aAdd(aDados[Len(aDados)][11],{	LoadBitmap( GetResources(), If(aCusto[01]<>0,cNoCheck,cNoCheck) ),;	// 01 - Marcacao 
													DA0->DA0_CODTAB,; 													// 02 - Codigo da Tabela
													DA0->DA0_DESCRI,; 													// 03 - Descricao da Tabela
													DA1->DA1_TIPPRE,;													// 04 - Tipo de Preco
													DA1->DA1_PRCVEN,; 													// 05 - Preco da Tabela
													0,				; 													// 06 - Simulacao - R$
													0,				; 													// 07 - % Margem Contribuicao
													DA1->DA1_XCOMIS,; 													// 08 - % Comissao
													DA1->DA1_XFRETE,; 													// 09 - % Frete
													DA1->DA1_XIMPOS,; 													// 10 - % ICMS
													0,				; 													// 11 - Lucro Operacional - R$
													0,				; 													// 12 - Lucro Operacional - %
													DA1->(Recno()),	; 													// 13 - Recno	
													.F.}			)													// 14
					*/
													//DA1->DA1_TIPPRE,;													// 04 - Tipo de Preco
					aAdd(aDados[Len(aDados)][11],{	LoadBitmap( GetResources(), If(aCusto[01]<>0,cNoCheck,cNoCheck) ),;	// 01 - Marcacao 
													DA0->DA0_CODTAB,; 													// 02 - Codigo da Tabela
													DA0->DA0_DESCRI,; 													// 03 - Descricao da Tabela
													VendasCanal(DA1->DA1_CODPRO,DA0->DA0_CODTAB)  ,;    // QUANTIDADE VENDIDA NO ULTIMO M?
													DA1->DA1_PRCVEN,; 													// 05 - Preco da Tabela
													DA1->DA1_PRCVEN,; 													// 06 - Simulacao - R$
													0,				; 													// 07 - % Margem Contribuicao
													DA1->DA1_XCOMIS,; 													// 08 - % Comissao
													DA1->DA1_XFRETE,; 													// 09 - % Frete
													DA1->DA1_XIMPOS,; 													// 10 - % ICMS
													DA1->DA1_XDESC,	; 													// 11 - % Desconto Financeiro
													0,				; 													// 12 - Lucro Operacional - %
													DA1->(Recno()),	; 													// 13 - Recno	
													.F.}			)													// 14
				EndIf
				DA1->(dbSkip())
			EndDo
		EndIf

		If Len(aDados[Len(aDados)][11])==0
			//->> aCols
			aAdd(aDados[Len(aDados)][11],{	LoadBitmap( GetResources(), cNoCheck),;	// 01 - Marcacao 
											"",				; 						// 02 - Codigo da Tabela
											"",				; 						// 03 - Descricao da Tabela
											"",				;						// 04 - Tipo de Preco
											0,				; 						// 05 - Preco da Tabela
											0,				; 						// 06 - Simulacao - R$
											0,				; 						// 07 - % Margem Contribuicao
											DA1->DA1_XCOMIS,; 						// 08 - % Comissao
											DA1->DA1_XFRETE,; 						// 09 - % Frete
											DA1->DA1_XIMPOS,; 						// 10 - % ICMS
											DA1->DA1_XDESC, ; 						// 11 - % Desconto Financeiro
											0,				; 						// 12 - Lucro Operacional - %
											0,				; 						// 13 - Recno
											.F.}			)						// 14

			aDados[Len(aDados)][12] := .F.
		Else
			aDados[Len(aDados)][12] := .T.
		EndIf
	
	EndIf

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

If Len(aDados) > 0
	lOk := .T.
Else
	lOk := .F.
	MsgAlert("Nao foram localizados Produtos conforme o filtro informado...")
EndIf

Return lOk

/*/{protheus.doc} GetCustoPrd
*******************************************************************************************
Retorna o ultimo custo do produto
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/

// Marcelo Celi - 09/12/2020 - Ajustado a forma de composi? do pre?com base no custo

/*
Static Function GetCustoPrd(cProduto)
Local nCusto 	:= 0
Local dCusto 	:= Stod("")
Local nSD1 		:= 0
Local dSD1 		:= Stod("")
Local nSD3 		:= 0
Local dSD3 		:= Stod("")
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

cQuery := "SELECT TOP 1 SD3.D3_CUSTO1  AS CUSTO,"		+CRLF
cQuery += "				SD3.D3_EMISSAO AS DATA"			+CRLF
cQuery += "	FROM "+RetSqlName("SD3")+" SD3 (NOLOCK)"	+CRLF
cQuery += "	WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"+CRLF
cQuery += "	  AND SD3.D3_COD     = '"+cProduto+"'"		+CRLF
cQuery += "	  AND SD3.D3_CF      = 'PR0'"				+CRLF
cQuery += "	  AND SD3.D_E_L_E_T_ = ' '"					+CRLF
cQuery += "	ORDER BY SD3.D3_EMISSAO DESC"				+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
	nSD3 := (cAlias)->CUSTO
	dSD3 := Stod((cAlias)->DATA)
EndIf
(cAlias)->(dbCloseArea())

cQuery := "SELECT TOP 1 SD1.D1_CUSTO   AS CUSTO,"		+CRLF
cQuery += "				SD1.D1_EMISSAO AS DATA"			+CRLF
cQuery += "	FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"	+CRLF
cQuery += "	WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"+CRLF
cQuery += "	  AND SD1.D1_COD     = '"+cProduto+"'"		+CRLF
cQuery += "	  AND SD1.D_E_L_E_T_ = ' '"					+CRLF
cQuery += "	ORDER BY SD1.D1_EMISSAO DESC"				+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
	nSD1 := (cAlias)->CUSTO
	dSD1 := Stod((cAlias)->DATA)
EndIf
(cAlias)->(dbCloseArea())

If dSD1 > dSD3
	nCusto := nSD1
	dCusto := dSD1
Else
	nCusto := nSD3
	dCusto := dSD3
EndIf

If nCusto == 0
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		nCusto := SB1->B1_CUSTD		// Custo Standard
		dCusto := SB1->B1_DATREF  	// Data Referencia do Custo
	EndIf
EndIf

Return {nCusto,dCusto}
*/

Static Function GetCustoPrd(cProduto)
Local nCusto 	:= 0
Local dCusto 	:= Stod("")
Local nSD1 		:= 0
Local dSD1 		:= Stod("")
Local nSD3 		:= 0
Local dSD3 		:= Stod("")
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

If nCusto == 0
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		nCusto := SB1->B1_CUSTD		// Custo Standard
		dCusto := SB1->B1_DATREF  	// Data Referencia do Custo
	EndIf
EndIf

If nCusto == 0
	cQuery := "SELECT TOP 1 SD3.D3_CUSTO1  AS CUSTO,"		+CRLF
	cQuery += "				SD3.D3_EMISSAO AS DATA,"		+CRLF
	cQuery += "				SD3.D3_QUANT   AS QUANT"		+CRLF
	cQuery += "	FROM "+RetSqlName("SD3")+" SD3 (NOLOCK)"	+CRLF
	cQuery += "	WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"+CRLF
	cQuery += "	  AND SD3.D3_COD     = '"+cProduto+"'"		+CRLF
	cQuery += "	  AND SD3.D3_CF      = 'PR0'"				+CRLF
	cQuery += "	  AND SD3.D_E_L_E_T_ = ' '"					+CRLF
	cQuery += "	ORDER BY SD3.D3_EMISSAO DESC"				+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
		nSD3 := Round((cAlias)->CUSTO / (cAlias)->QUANT,Tamsx3("D3_CUSTO1")[02])
		dSD3 := Stod((cAlias)->DATA)
	EndIf
	(cAlias)->(dbCloseArea())

	cQuery := "SELECT TOP 1 SD1.D1_CUSTO   AS CUSTO,"		+CRLF
	cQuery += "				SD1.D1_EMISSAO AS DATA,"		+CRLF
	cQuery += "				SD1.D1_QUANT   AS QUANT"		+CRLF
	cQuery += "	FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"	+CRLF
	cQuery += "	WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"+CRLF
	cQuery += "	  AND SD1.D1_COD     = '"+cProduto+"'"		+CRLF
	cQuery += "	  AND SD1.D_E_L_E_T_ = ' '"					+CRLF
	cQuery += "	ORDER BY SD1.D1_EMISSAO DESC"				+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
		nSD1 := Round((cAlias)->CUSTO / (cAlias)->QUANT,Tamsx3("D1_CUSTO")[2])
		dSD1 := Stod((cAlias)->DATA)
	EndIf
	(cAlias)->(dbCloseArea())

	If dSD1 > dSD3
		nCusto := nSD1
		dCusto := dSD1
	Else
		nCusto := nSD3
		dCusto := dSD3
	EndIf
EndIf

Return {nCusto,dCusto}

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 23/07/2020
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

/*/{protheus.doc} TudoOk
*******************************************************************************************
Funcao que valida os dados para a gravacao
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function TudoOk()
Local lRet := .T.

If lRet
	lRet := MsgYesNo("Confirma a Formacao de Preco ?")
EndIf

Return lRet

/*/{protheus.doc} GetStyloBt
*******************************************************************************************
Retorna o estilo do botão
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function GetStyloBt(nStylo,cImagem)
Local cEstilo := ""

Do Case
	Case nStylo == 1
		//A classe QPushButton, ela é responsável em criar a formatação do botão. 
	    cEstilo := "QPushButton {"  
	    //Usando a propriedade background-image, inserimos a imagem que será utilizada, a imagem pode ser pega pelo repositório (RPO)
	    cEstilo += " background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;" 
	    cEstilo += " border-style: outset;"
	    cEstilo += " border-width: 2px;"
	    cEstilo += " border: 1px solid #C0C0C0;"
	    cEstilo += " border-radius: 5px;"
	    cEstilo += " border-color: #C0C0C0;"
	    cEstilo += " font: bold 12px Arial;"
	    cEstilo += " padding: 6px;"
	    cEstilo += "}"
	 
	    //Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botão ele muda
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
@since: 23/07/2020
@param: 
@return:
@type function: Estático
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

/*/{protheus.doc} PesqEstoque
*******************************************************************************************
Pesquisa o Estoque
 
@author: Marcelo Celi Marques
@since: 23/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function PesqEstoque()
Local cFilBkp := cFilAnt

If FWModeAccess("SB1")=="E"
	cFilAnt := SB1->B1_FILIAL
EndIf	
MaViewSB2(SB1->B1_COD)
cFilAnt := cFilBkp	

Return Nil

/*/{protheus.doc} PesqEstoque
*******************************************************************************************
Pesquisa o Estoque
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
User Function BOVldSiPrc()
Local lRet 			:= .T.
Local cCpoEdt		:= ReadVar()
Local nPPreco		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("PRECO"))})
Local nPSimula		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("SIMULA"))})
Local nPMargem		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("MARGEM"))})
Local nPComissao	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("COMISSAO"))})
Local nPFrete		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("FRETE"))})
Local nPICMS		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("ICMS"))})

//->> Marcelo Celi - 13/12/2020
//Local nPLucro		:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("LUCRO"))})
Local nPDesconto	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("DESCONTO"))})
Local nPPerLucro	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("PERCLUCRO"))})
Local nPCusto 		:= Ascan(aObjetos[04,06]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("B2_CM1"))})

Local nPreco		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPPreco]
Local nSimula		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPSimula]
Local nMargem		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPMargem]
Local nComissao		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPComissao]
Local nFrete		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPFrete]
//Local nICMS		:= Val(aObjetos[07]:aCols[aObjetos[07]:nAt][nPICMS])
Local nICMS			:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPICMS]

//->> Marcelo Celi - 13/12/2020
//Local nLucro		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPLucro]
Local nDesconto		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPDesconto]

Local nPerLucro		:= aObjetos[07]:aCols[aObjetos[07]:nAt][nPPerLucro]
Local nCusto 		:= aObjetos[04,06]:aCols[aObjetos[04,06]:nAt][nPCusto]

Local nDecMargem	:= aObjetos[07]:aHeader[nPMargem][05]
Local nDecSimula	:= aObjetos[07]:aHeader[nPSimula][05]
Local nDecPerLuc	:= aObjetos[07]:aHeader[nPPerLucro][05]

Local nValor		:= 0

Do Case	
	Case "SIMULA" $ cCpoEdt
		nSimula := &(cCpoEdt)				
		
		aObjetos[07]:aCols[aObjetos[07]:nAt][01] := LoadBitmap( GetResources(), cNoSel)
		
		If nSimula == 0
			nMargem := 0
			nLucro  := 0

			aObjetos[07]:aCols[aObjetos[07]:nAt][01] := LoadBitmap( GetResources(), cNoCheck)
		Else			
			//->> Marcelo Celi - 13/12/2020
			/*
			nValor := nCusto
			nValor := nValor  + Round((nValor * (nComissao 	/ 100) ) ,nDecSimula)
			nValor := nValor  + Round((nValor * (nFrete 	/ 100) ) ,nDecSimula)
			nValor := nValor  + Round((nValor * (nICMS 		/ 100) ) ,nDecSimula)
			nValor := Round(nValor,nDecSimula)

			nMargem := ((nSimula / nValor) - 1) * 100
			nMargem := Round(nMargem,nDecMargem)

			nLucro := nSimula
			nLucro -= nCusto 
			nLucro -= Round((nSimula * (nComissao 	/ 100) ),nDecSimula)
			nLucro -= Round((nSimula * (nFrete 		/ 100) ),nDecSimula)
			nLucro -= Round((nSimula * (nICMS 		/ 100) ),nDecSimula)
			*/
			
			nMargem := Round((nCusto / nSimula) * 100,4)

		EndIf	

	Case "MARGEM" $ cCpoEdt		
		//->> Marcelo Celi - 13/12/2020
		/*
		nMargem := &(cCpoEdt)
		nSimula := nCusto + (nCusto * (nMargem / 100) )
		nSimula := nSimula + (nSimula * (nComissao / 100) )
		nSimula := nSimula + (nSimula * (nFrete / 100) )
		nSimula := nSimula + (nSimula * (nICMS / 100) )
		nSimula := Round(nSimula,nDecSimula)

		nLucro := nSimula
		nLucro -= nCusto 
		nLucro -= Round((nSimula * (nComissao 	/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nFrete 		/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nICMS 		/ 100) ),nDecSimula)
		*/
		nMargem := &(cCpoEdt)

	Case "COMISSAO" $ cCpoEdt
		//->> Marcelo Celi - 13/12/2020
		/*
		nComissao := &(cCpoEdt)
		nSimula := nCusto + (nCusto * (nMargem / 100) )
		nSimula := nSimula + (nSimula * (nComissao / 100) )
		nSimula := nSimula + (nSimula * (nFrete / 100) )
		nSimula := nSimula + (nSimula * (nICMS / 100) )
		nSimula := Round(nSimula,nDecSimula)

		nLucro := nSimula
		nLucro -= nCusto 
		nLucro -= Round((nSimula * (nComissao 	/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nFrete 		/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nICMS 		/ 100) ),nDecSimula)
		*/
		nComissao := &(cCpoEdt)

	Case "FRETE" $ cCpoEdt
		//->> Marcelo Celi - 13/12/2020
		/*
		nFrete := &(cCpoEdt)
		nSimula := nCusto + (nCusto * (nMargem / 100) )
		nSimula := nSimula + (nSimula * (nComissao / 100) )
		nSimula := nSimula + (nSimula * (nFrete / 100) )
		nSimula := nSimula + (nSimula * (nICMS / 100) )
		nSimula := Round(nSimula,nDecSimula)

		nLucro := nSimula
		nLucro -= nCusto 
		nLucro -= Round((nSimula * (nComissao 	/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nFrete 		/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nICMS 		/ 100) ),nDecSimula)
		*/
		nFrete := &(cCpoEdt)

	Case "ICMS" $ cCpoEdt
		//->> Marcelo Celi - 13/12/2020
		/*
		//nICMS := Val(&(cCpoEdt))
		nICMS := &(cCpoEdt)
		nSimula := nCusto + (nCusto * (nMargem / 100) )
		nSimula := nSimula + (nSimula * (nComissao / 100) )
		nSimula := nSimula + (nSimula * (nFrete / 100) )
		nSimula := nSimula + (nSimula * (nICMS / 100) )
		nSimula := Round(nSimula,nDecSimula)

		nLucro := nSimula
		nLucro -= nCusto 
		nLucro -= Round((nSimula * (nComissao 	/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nFrete 		/ 100) ),nDecSimula)
		nLucro -= Round((nSimula * (nICMS 		/ 100) ),nDecSimula)
		*/
		nICMS := &(cCpoEdt)

	Case "DESCONTO" $ cCpoEdt
		//->> Marcelo Celi - 13/12/2020
		nDesconto := &(cCpoEdt)
		
EndCase

//->> Calculo do Percentual do lucro
//->> Marcelo Celi - 13/12/2020
//nPerLucro := Round((nLucro / nSimula)*100,nDecPerLuc)
nPerLucro := Round(100 - nDesconto - nComissao - nFrete - nICMS - nMargem,nDecPerLuc)

If lRet
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPPreco] 		:= nPreco
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPSimula] 		:= nSimula
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPMargem] 		:= nMargem
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPComissao] 	:= nComissao
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPFrete] 		:= nFrete
	
	//->> Marcelo Celi - 13/12/2020
	//aObjetos[07]:aCols[aObjetos[07]:nAt][nPLucro] 	:= nLucro
	aObjetos[07]:aCols[aObjetos[07]:nAt][nPDesconto]	:= nDesconto

	aObjetos[07]:aCols[aObjetos[07]:nAt][nPPerLucro]	:= nPerLucro
	aObjetos[07]:Refresh()
EndIf

If nCusto == 0
	aObjetos[07]:aCols[aObjetos[07]:nAt][01] := LoadBitmap( GetResources(), cNoCheck)
EndIf

AtuGrfTab()

Return lRet

/*/{protheus.doc} GravaPrecos
*******************************************************************************************
Grava os precos calculaos
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function GravaPrecos()
Local nPSimula	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("SIMULA"))})
Local nPRecno	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("RECNO"))})
Local nPPreco	:= Ascan(aObjetos[07]:aHeader,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper("PRECO"))})
Local nX		:= 1
Local nY		:= 1
Local nPos

//->> Guarda o ultimo aCols digitado. (deve-se executar essa funcao pois o usuario pode ter clicado no botao e o acols nao ter sido guardado devido a nao execucao do bChange)
GuardaACOLs()

For nX:=1 to Len(aProdutos)
	If aProdutos[nX][12] // Se tem tabela de precos
		For nY:=1 to Len(aProdutos[nX][11])
			If Upper(Alltrim(aProdutos[nX,11][nY,01]:cName)) == Upper(Alltrim(cSel))
				If aProdutos[nX,11][nY][nPRecno] > 0
					DA1->(dbGoto(aProdutos[nX,11][nY][nPRecno]))
					Reclock("DA1",.F.)
					DA1->DA1_PRCVEN := aProdutos[nX,11][nY][nPSimula]
					aProdutos[nX,11][nY][nPPreco] := DA1->DA1_PRCVEN
					aProdutos[nX,11][nY,01]:cName := Upper(Alltrim(cNoCheck))
					DA1->(MsUnlock())
				EndIf
			EndIf
		Next nY	
	EndIf
Next nX



nPos := Ascan(aProdutos,{|x| x[01]==aObjetos[04,06]:aCols[POSIC_PROD][02]})
If nPos > 0
	aObjetos[07]:aCols := aClone(aProdutos[nPos,11])
EndIf

Return

/*/{protheus.doc} LocalizaPrd
*******************************************************************************************
Localiza o Produto na Grip e posiciona
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function LocalizaPrd()
Local oDlg			:= NIL
Local aButtons		:= {}
Local aRetBuscPar 	:= {}
Local aBoxBuscPar 	:= {}
Local aTipo		  	:= {"Buscar por Codigo","Buscar por Descricao"}
Local nPos		  	:= 0
Local lOk			:= .F.
Local nColBut		:= 2
Local aObjButt		:= {}
Local nX			:= 1

aAdd( aRetBuscPar, 2							)
aAdd( aRetBuscPar, Space(Tamsx3("B1_DESC")[01])	)

aAdd( aBoxBuscPar,{3,"Buscar por"	,aRetBuscPar[01],aTipo,200,".T.",.T.,".T."})  
aAdd( aBoxBuscPar,{1,"Buscar"		,aRetBuscPar[02],"@!","","",".T.",200,.T.})

DEFINE MSDIALOG oDlg TITLE "Localizar Produto" FROM 0,0 To 250,700 OF oMainWnd PIXEL

oPanSup := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,((oDlg:NWIDTH)/2),((oDlg:NHEIGHT)/2)-21,.F.,.F. )
oPanSup:Align := CONTROL_ALIGN_ALLCLIENT

Parambox(aBoxBuscPar,"Parametrizacao",@aRetBuscPar,,,,,,oPanSup,,.F.,.F.)

oPanInf := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,RGB(195,195,195),((oDlg:NWIDTH)/2),(21),.F.,.T. )
oPanInf:Align := CONTROL_ALIGN_BOTTOM

//->> Formatacao dos botoes
aAdd(aButtons,{"Confirmar" ,50 ,18 ,3  ,""  ,  {|| oDlg:End(),lOk:=.T.}   })
aAdd(aButtons,{"Cancelar"  ,50 ,18 ,3  ,""  ,  {|| oDlg:End(),lOk:=.F.}   })

nColBut := ((oPanInf:NWIDTH)/2) - 15
For nX:=1 to Len(aButtons)
	nColBut -= aButtons[nX,02] - 07
	
	aAdd(aObjButt,TButton():New(002,nColBut,aButtons[nX,01] ,oPanInf,aButtons[nX,06],aButtons[nX,02],aButtons[nX,03],,,.F.,.T.,.F.,,.F.,,,.F. ))
	aObjButt[Len(aObjButt)]:SetCss(GetStyloBt(aButtons[nX,04],aButtons[nX,05]))     
	
	nColBut -= 7

Next nX

ACTIVATE MSDIALOG oDlg CENTER
//Estrut()
If lOk
	If aRetBuscPar[01] == 1
		//->> Buscar por Codigo
		nPos := Ascan(aProdutos,{|x| Alltrim(Upper(x[01]))==Alltrim(Upper(aRetBuscPar[02]))})
		If nPos > 0
			aObjetos[04,06]:nAt := nPos	
			aObjetos[04,06]:oBrowse:nAt := nPos	
		Else
			MsgAlert("Codigo do Produto nao Localizado...")
		EndIf
	Else
		//->> Buscar por Descricao
		nPos := Ascan(aProdutos,{|x| Alltrim(Upper(aRetBuscPar[02])) $ Alltrim(Upper(x[02])) })
		If nPos > 0
			aObjetos[04,06]:nAt := nPos	
			aObjetos[04,06]:oBrowse:nAt := nPos	
		Else
			MsgAlert("Produto nao Localizado...")
		EndIf
	EndIf
	aObjetos[04,06]:Refresh()
EndIf

Return

/*/{protheus.doc} PosicProdut
*******************************************************************************************
Visualiza a posicao grafica do produto
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function PosicProdut()
Local oWizard	:= NIL
Local nX	 	:= 1
Local nMeses 	:= 6
Local dDataIni	:= Stod("")
Local dDataFim	:= Stod("")
Local nMes		:= 0
Local nAno		:= 0
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local aVdaProd	:= {}
Local aVdaGrp	:= {}
Local aVdaSubGrp:= {}
Local nPos		:= 0
Local aCoords   := {}
Local aSize	   	:= MsAdvSize()
Local cLogotipo := GetNewpar("BO_LOGOCLI","WIZARD")
Local aPeriodo	:= {}
Local oPanSEsq 	:= NIL
Local oGrfSLine := NIL
Local oPanSDir 	:= NIL
Local oGrfsPizza:= NIL

aCoords := {0,0,(aSize[6] - aSize[2] - aSize[8] - 5),(aSize[5])}

aAdd(aVdaGrp,{Upper(Alltrim(SB1->B1_XNOMGRP)),0})
aAdd(aVdaGrp,{Upper("Demais Grupos"),0})

If Month(dDatabase)==1
	nMes := 12
	nAno := Year(dDatabase)-1
Else
	nMes := Month(dDatabase)-1
	nAno := Year(dDatabase)
EndIf
aAdd(aVdaProd,{nMes,nAno,0,0,0})

dDataIni := Stod(StrZero(nAno,4)+StrZero(nMeses,2)+"01")
dDataFim := LastDay(Stod(StrZero(nAno,4)+StrZero(nMeses,2)+"01"))
For nX:=1 to (nMeses-1)
	If Month(dDataIni)==1
		nMes := 12
		nAno := Year(dDataIni)-1
	Else
		nMes := Month(dDataIni)-1
		nAno := Year(dDataIni)
	EndIf
	dDataIni := Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01")
	aAdd(aVdaProd,{nMes,nAno,0,0,nX})
Next nX

aVdaProd := aSort(aVdaProd,,,{|x,y| x[05] > y[05]     })

//->> Vendas do Produto (Valor/Quantidade)
cQuery := "SELECT 	SUM(VENDA) AS VENDA,"															+CRLF
cQuery += "			SUM(QTDE)  AS QTDE,"															+CRLF
cQuery += "			MES,"																			+CRLF
cQuery += "			ANO"																			+CRLF
cQuery += "		FROM ("																				+CRLF
cQuery += "			 SELECT D2_TOTAL AS VENDA,"														+CRLF
cQuery += "			        D2_QUANT AS QTDE,"														+CRLF
cQuery += "					MONTH(SF2.F2_EMISSAO) AS MES,"											+CRLF
cQuery += "					YEAR(SF2.F2_EMISSAO) AS ANO"											+CRLF
cQuery += "		FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"											+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
cQuery += "				  ON SF2.F2_FILIAL  = SD2.D2_FILIAL"										+CRLF
cQuery += "				 AND SF2.F2_DOC     = SD2.D2_DOC"											+CRLF
cQuery += "				 AND SF2.F2_SERIE   = SD2.D2_SERIE"											+CRLF
cQuery += "				 AND SF2.F2_TIPO    = 'N'"													+CRLF
cQuery += "				 AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"	+CRLF
cQuery += "				 AND SF2.D_E_L_E_T_ = ' '"													+CRLF
cQuery += "		WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"										+CRLF
cQuery += " 	  AND SD2.D2_COD     = '"+SB1->B1_COD+"'"											+CRLF
cQuery += " 	  AND SD2.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "			  ) AS TMP"																		+CRLF
cQuery += "GROUP BY MES, ANO"																		+CRLF
cQuery += "ORDER BY ANO, MES"																		+CRLF

MsgRun("Extraindo Vendas...","Aguarde",{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
Do While (cAlias)->(!Eof())
	nPos := Ascan(aVdaProd,{|x|  x[01]==(cAlias)->MES .And. x[02]==(cAlias)->ANO })
	If nPos > 0
		aVdaProd[nPos,03] += (cAlias)->VENDA
		aVdaProd[nPos,04] += (cAlias)->QTDE
	EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

//->> Vendas do Grupo
cQuery := "SELECT SUM(D2_TOTAL) AS VENDA"															+CRLF  
cQuery += "		FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"											+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
cQuery += "				  ON SF2.F2_FILIAL 	= SD2.D2_FILIAL"										+CRLF
cQuery += "				 AND SF2.F2_DOC 	= SD2.D2_DOC"											+CRLF
cQuery += "				 AND SF2.F2_SERIE 	= SD2.D2_SERIE"											+CRLF
cQuery += "				 AND SF2.F2_TIPO 	= 'N'"													+CRLF
cQuery += "				 AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"	+CRLF
cQuery += "				 AND SF2.D_E_L_E_T_ = ' '"													+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
cQuery += "			 ON SB1.B1_FILIAL       = '"+xFilial("SB1")+"'"									+CRLF
cQuery += "			AND	SB1.B1_COD 			= SD2.D2_COD"											+CRLF
cQuery += "			AND SB1.B1_GRUPO 		= '"+SB1->B1_GRUPO+"'"									+CRLF
cQuery += "			AND SB1.D_E_L_E_T_ 		= ' '"													+CRLF
cQuery += "		WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"										+CRLF
cQuery += "		  AND SD2.D_E_L_E_T_ = ' '"															+CRLF

MsgRun("Extraindo Vendas...","Aguarde",{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	aVdaGrp[01,02] := (cAlias)->VENDA
EndIf
(cAlias)->(dbCloseArea())

//->> Vendas diferentes do Grupo
cQuery := "SELECT SUM(D2_TOTAL) AS VENDA"															+CRLF  
cQuery += "		FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"											+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
cQuery += "				  ON SF2.F2_FILIAL 	= SD2.D2_FILIAL"										+CRLF
cQuery += "				 AND SF2.F2_DOC 	= SD2.D2_DOC"											+CRLF
cQuery += "				 AND SF2.F2_SERIE 	= SD2.D2_SERIE"											+CRLF
cQuery += "				 AND SF2.F2_TIPO 	= 'N'"													+CRLF
cQuery += "				 AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"	+CRLF
cQuery += "				 AND SF2.D_E_L_E_T_ = ' '"													+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
cQuery += "			 ON SB1.B1_FILIAL       = '"+xFilial("SB1")+"'"									+CRLF
cQuery += "			AND	SB1.B1_COD 			= SD2.D2_COD"											+CRLF
cQuery += "			AND SB1.B1_GRUPO 	    <> '"+SB1->B1_GRUPO+"'"									+CRLF
cQuery += "			AND SB1.D_E_L_E_T_ 		= ' '"													+CRLF
cQuery += "		WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"										+CRLF
cQuery += "		  AND SD2.D_E_L_E_T_ = ' '"															+CRLF

MsgRun("Extraindo Vendas...","Aguarde",{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	aVdaGrp[02,02] := (cAlias)->VENDA
EndIf
(cAlias)->(dbCloseArea())

//->> Vendas do grupo x sub-grupo
cQuery := "SELECT SUM(D2_TOTAL) AS VENDA, B1_GRUPO, B1_XCSGRP, B1_XNSGRP"							+CRLF  
cQuery += "		FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"											+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
cQuery += "				  ON SF2.F2_FILIAL 	= SD2.D2_FILIAL"										+CRLF
cQuery += "				 AND SF2.F2_DOC 	= SD2.D2_DOC"											+CRLF
cQuery += "				 AND SF2.F2_SERIE 	= SD2.D2_SERIE"											+CRLF
cQuery += "				 AND SF2.F2_TIPO 	= 'N'"													+CRLF
cQuery += "				 AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"	+CRLF
cQuery += "				 AND SF2.D_E_L_E_T_ = ' '"													+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
cQuery += "			 ON SB1.B1_FILIAL       = '"+xFilial("SB1")+"'"									+CRLF
cQuery += "			AND	SB1.B1_COD 			= SD2.D2_COD"											+CRLF
cQuery += "			AND SB1.B1_GRUPO 		= '"+SB1->B1_GRUPO+"'"									+CRLF
cQuery += "			AND SB1.D_E_L_E_T_ 		= ' '"													+CRLF
cQuery += "		WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"										+CRLF
cQuery += "		  AND SD2.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "GROUP BY B1_GRUPO, B1_XCSGRP, B1_XNSGRP"													+CRLF

MsgRun("Extraindo Vendas...","Aguarde",{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	aAdd(aVdaSubGrp,{(cAlias)->VENDA,(cAlias)->B1_XCSGRP,(cAlias)->B1_XNSGRP})
EndIf
(cAlias)->(dbCloseArea())

oWizard := APWizard():New(  "CONSULTA DE POSICAO DE VENDAS",      																		 ;   // chTitle  - Titulo do cabealho
                            "Produto: "+Alltrim(SB1->B1_DESC), 		                        						         			 ;   // chMsg    - Mensagem do cabealho
                            "Vendas entre "+GetMes(Month(dDataIni),Year(dDataini),.T.)+" e "+GetMes(Month(dDataFim),Year(dDataFim),.T.), ;   // cTitle   - Ttulo do painel de apresentao
                            "",   											    				 									     ;   // cText    - Texto do painel de apresentao
                            {|| .T. },         													 									     ;   // bNext    - Bloco de cdigo a ser executado para validar o boto "Avanar"
                            {|| .T. },   														 										 ;   // bFinish  - Bloco de cdigo a ser executado para validar o boto "Finalizar"
                            .T.,             																     					     ;   // lPanel   - Se .T. ser criado um painel, se .F. ser criado um scrollbox
                            cLogotipo,          												 									     ;   // cResHead - Nome da imagem usada no cabealho, essa tem que fazer parte do repositrio 
                            {|| },                																 					     ;   // bExecute - Bloco de cdigo contendo a ao a ser executada no clique dos botes "Avanar" e "Voltar"
                            .F.,                  												 									     ;   // lNoFirst - Se .T. no exibe o painel de apresentao
                            aCoords                     										 										 )   // aCoord   - Array contendo as coordenadas da tela

//->> Linha superior
oPanSup := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NWIDTH)/2),((oWizard:GetPanel(1):NHEIGHT)/2)*.50,.T.,.F. )
oPanSup:Align := CONTROL_ALIGN_TOP

oPanSEsq := TPanel():New(0,0,'',oPanSup, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPanSup:NWIDTH)/2)-200,((oPanSup:NHEIGHT)/2),.T.,.F. )
oPanSEsq:Align := CONTROL_ALIGN_LEFT

oGrfSLine := FWChartLine():New()
oGrfSLine:init( oPanSEsq, .T. ) 
aPeriodo := {}
For nX:=1 to Len(aVdaProd)
	aAdd(aPeriodo,{GetMes(aVdaProd[nX,01],aVdaProd[nX,02]),Round(aVdaProd[nX,03],2)})
Next nX
oGrfSLine:addSerie( Alltrim(SB1->B1_DESC), aPeriodo )
oGrfSLine:setLegend( CONTROL_ALIGN_BOTTOM )
oGrfSLine:Build()

oPanSDir := TPanel():New(0,0,'',oPanSup, oWizard:GetPanel(1):oFont, .T., .T.,,,(200)										,((oPanSup:NHEIGHT)/2),.F.,.T. )
oPanSDir:Align := CONTROL_ALIGN_RIGHT

oGrfsPizza := FWChartPie():New()
oGrfsPizza:init( oPanSDir, .T. ) 

oGrfsPizza:addSerie( aVdaGrp[01,01]	, Round(aVdaGrp[01,02],2) )
oGrfsPizza:addSerie( aVdaGrp[02,01]	, Round(aVdaGrp[02,02],2) )	

oGrfsPizza:setLegend( CONTROL_ALIGN_LEFT )
oGrfsPizza:Build()

//->> Linha Inferior
oPanInf := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NWIDTH)/2),((oWizard:GetPanel(1):NHEIGHT)/2)*.50,.T.,.F. )
oPanInf:Align := CONTROL_ALIGN_BOTTOM

oPanIEsq := TPanel():New(0,0,'',oPanInf, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPanInf:NWIDTH)/2)-200,((oPanInf:NHEIGHT)/2),.T.,.F. )
oPanIEsq:Align := CONTROL_ALIGN_LEFT

oGrfILine := FWChartLine():New()
oGrfILine:init( oPanIEsq, .T. ) 
aPeriodo := {}
For nX:=1 to Len(aVdaProd)
	aAdd(aPeriodo,{GetMes(aVdaProd[nX,01],aVdaProd[nX,02]),Round(aVdaProd[nX,04],Tamsx3("D2_QUANT")[01])})
Next nX
oGrfILine:addSerie( Alltrim(SB1->B1_DESC), aPeriodo )
oGrfILine:setLegend( CONTROL_ALIGN_BOTTOM )
oGrfILine:Build()

oPanIDir := TPanel():New(0,0,'',oPanInf, oWizard:GetPanel(1):oFont, .T., .T.,,,(200)										,((oPanSup:NHEIGHT)/2),.F.,.T. )
oPanIDir:Align := CONTROL_ALIGN_RIGHT

oGrfIPizza := FWChartPie():New()
oGrfIPizza:init( oPanIDir, .T. ) 
For nX:=1 to Len(aVdaSubGrp)
	oGrfIPizza:addSerie( aVdaSubGrp[nX,03]	, Round(aVdaSubGrp[nX,01],2) )
Next nX
oGrfIPizza:setLegend( CONTROL_ALIGN_LEFT )
oGrfIPizza:Build()

oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                    {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                    {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

Return

/*/{protheus.doc} GetMes
*******************************************************************************************
Retorna o periodo por escrito
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function GetMes(nMes,nAno,lInteiro)
Local cPeriodo := ""

Default lInteiro := .F.

Do Case
	Case nMes == 1
		If lInteiro
			cPeriodo := "Janeiro - "+StrZero(nAno,4)
		Else
			cPeriodo := "Jan-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 2
		If lInteiro
			cPeriodo := "Fevereito - "+StrZero(nAno,4)
		Else
			cPeriodo := "Fev-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 3
		If lInteiro
			cPeriodo := "Marco-"+StrZero(nAno,4)
		Else
			cPeriodo := "Mar-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 4
		If lInteiro
			cPeriodo := "Abril - "+StrZero(nAno,4)
		Else
			cPeriodo := "Abr-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 5
		If lInteiro
			cPeriodo := "Maio - "+StrZero(nAno,4)
		Else
			cPeriodo := "Mai-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 6
		If lInteiro
			cPeriodo := "Junho - "+StrZero(nAno,4)
		Else
			cPeriodo := "Jun-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 7
		If lInteiro
			cPeriodo := "Julho - "+StrZero(nAno,4)
		Else
			cPeriodo := "Jul-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 8
		If lInteiro
			cPeriodo := "Agosto - "+StrZero(nAno,4)
		Else
			cPeriodo := "Ago-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 9
		If lInteiro
			cPeriodo := "Setembro - "+StrZero(nAno,4)
		Else
			cPeriodo := "Set-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 10
		If lInteiro
			cPeriodo := "Outubro - "+StrZero(nAno,4)
		Else
			cPeriodo := "Out-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 11
		If lInteiro
			cPeriodo := "Novembro - "+StrZero(nAno,4)
		Else
			cPeriodo := "Nov-"+Right(StrZero(nAno,4),2)
		EndIf	

	Case nMes == 12
		If lInteiro
			cPeriodo := "Dezembro - "+StrZero(nAno,4)
		Else
			cPeriodo := "Dez-"+Right(StrZero(nAno,4),2)
		EndIf	

EndCase	

Return cPeriodo

/*/{protheus.doc} MarcaDesmar
*******************************************************************************************
Funcao para marcer/desmarcar os itens da grid
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function MarcaDesmar(oOjeto)
If Alltrim(Upper(aObjetos[07]:aCols[aObjetos[07]:nAt][01]:cName)) == Upper(Alltrim(cSel))
	aObjetos[07]:aCols[aObjetos[07]:nAt][01] := LoadBitmap( GetResources(), cNoSel)

ElseIf Alltrim(Upper(aObjetos[07]:aCols[aObjetos[07]:nAt][01]:cName)) == Upper(Alltrim(cNoSel))
	aObjetos[07]:aCols[aObjetos[07]:nAt][01] := LoadBitmap( GetResources(), cSel)

EndIf
aObjetos[07]:Refresh()
Return

/*/{protheus.doc} AtuGrfTab
*******************************************************************************************
Atualiza o Grafico de Tabela de Preco
 
@author: Marcelo Celi Marques
@since: 24/07/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function AtuGrfTab()
/*
Local nX := 1
//Local nPosTab  	:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("TABELA")) })
Local nPosDescTab  	:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("DESCRICAO")) })
Local nPosPrc  		:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("PRECO")) })
Local nPosSimu 		:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("SIMULA")) })
Local nPosLucr 		:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("LUCRO")) })

FreeObj(aObjetos[04,08])

aObjetos[04,08] := FWChartBarComp():New()
aObjetos[04,08]:init( aObjetos[04,07], .T. ) 

For nX:=1 to Len(aObjetos[07]:aCols)
	If !aObjetos[07]:aCols[nX][Len(aObjetos[07]:aHeader)+1]
		aObjetos[04,08]:addSerie( Left(aObjetos[07]:aCols[nX][nPosDescTab],20) , { 	{aObjetos[07]:aHeader[nPosPrc,01]	, aObjetos[07]:aCols[nX][nPosPrc]   },;
																	 				{aObjetos[07]:aHeader[nPosSimu,01]	, aObjetos[07]:aCols[nX][nPosSimu]	},;
																	  				{aObjetos[07]:aHeader[nPosLucr,01]	, aObjetos[07]:aCols[nX][nPosLucr]	} })
	EndIf	
Next nX
aObjetos[04,08]:setLegend( CONTROL_ALIGN_LEFT ) 
aObjetos[04,08]:Build()
*/

Local nX			:= 1
Local nPosDescTab  	:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("DESCRICAO")) })
Local nPosPerLucr  	:= Ascan(aObjetos[07]:aHeader,{|x| Upper(Alltrim(x[02]))==Upper(Alltrim("PERCLUCRO")) })

FreeObj(aObjetos[04,08])
aObjetos[04,08] := FWChartPie():New()
aObjetos[04,08]:init( aObjetos[04,07], .T. ) 

For nX:=1 to Len(aObjetos[07]:aCols)
	If !aObjetos[07]:aCols[nX][Len(aObjetos[07]:aHeader)+1]
		aObjetos[04,08]:addSerie( aObjetos[07]:aCols[nX][nPosDescTab],Round(aObjetos[07]:aCols[nX][nPosPerLucr],2) )
	EndIf
Next nX
aObjetos[04,08]:setLegend( CONTROL_ALIGN_LEFT )
aObjetos[04,08]:Build()

Return

/*/{protheus.doc} mostraSG1
*******************************************************************************************
Mostra a Estrutura do PRODUTO
 
@author: 	Marcos Gomes
@since: 	22/01/2021
@param: 	nenhum
@return:	nil
@type function: Usuario
*******************************************************************************************
// https://tdn.totvs.com/display/public/PROT/DBTree
// http://www.helpfacil.com.br/forum/display_topic_threads.asp?ForumID=1&TopicID=14058
/*/
STATIC FUNCTION mostraSG1(o)

Local aArea := GetArea()
LOCAL cCodProd	:= aObjetos[04,06]:aCols[POSIC_PROD][02]

//Chkfile("SB1")
//ChkFile("SG1")
//ChkFile("SGF")

U_VBYPC200(cCodProd)

RestArea(aArea)

Return(.T.)



/*/{protheus.doc} ConsKardex
*******************************************************************************************
Mostra a Estrutura do PRODUTO
 
@author: 	Marcos Gomes
@since: 	22/01/2021
@param: 	Chave para pesquisa do produto
@return:	nil
@type function: Usuario
*******************************************************************************************
// https://tdn.totvs.com/display/public/PROT/DBTree
// http://www.helpfacil.com.br/forum/display_topic_threads.asp?ForumID=1&TopicID=14058
/*/
Static Function ConsKardex(cChave)

LOCAL aAREA_ATU	:= GETAREA()

PRIVATE cCadastro := OemtoAnsi( "Consulta ao Kardex" )

	/* ----------------------------------------------------------------------------------------
	( produto ) Recupera o c??o do PRODUTO
	---------------------------------------------------------------------------------------- */
	cCodProd := Substr( cChave, 1, TAMSX3("B1_COD")[1] )
	Pergunte("MTC030",.T.)	

	/* ----------------------------------------------------------------------------------------
	( SB1 ) Posiciona o CADASTRO DE PRODUTOS e chama a consulta do KARDEX
	---------------------------------------------------------------------------------------- */
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek( xfilial("SB1") + cCodProd, .f. )

	Mc030Con()
	
RESTAREA( aAREA_ATU	)

Return Nil

/*/{protheus.doc} SG1Visual
*******************************************************************************************
Mostra a Estrutura do PRODUTO
 
@author: 	Marcos Gomes
@since: 	22/01/2021
@param: 	Chave para pesquisa do produto
@return:	nil
@type function: Usuario
*******************************************************************************************
/*/
STATIC FUNCTION SG1Visual( cChave )

PRIVATE aAcho := {}

	/* ----------------------------------------------------------------------------------------
	( produto ) Recupera o c??o do PRODUTO
	---------------------------------------------------------------------------------------- */
	cCodProd := Substr( cChave, 1, TAMSX3("B1_COD")[1] )
	nReg := 3

	AxVisual("SG1", nReg, 2, aAcho )

return nil

/*/{protheus.doc} fMontaDesc()
*******************************************************************************************
Monta a descri? do produto
 
@author: 	Marcos Gomes
@since: 	22/01/2021
@param: 	Codigo do PRODUTO
@return:	nil
@type function: Usuario
*******************************************************************************************
/*/
Static Function fMontaDesc( cCodSB1, nTpCusto )

LOCAL cDescSB1
LOCAL nMoeda
LOCAL nCusto	:= 0

LOCAL aAREA_ATU	:= GetArea()
LOCAL cAliasSD1	:= GetNextAlias()
LOCAL cAliasSD3	:= GetNextAlias()

DEFAULT nTpCusto := 9

	/* ----------------------------------------------------------------------------------------
	TIPO DE CUSTO
		[1] - Custo do campo CUSTO STANDARD ( B1_MCUSTD )
		[2] - Custo do campo ULTIMA COMPRA CADASTRO DE PRODUTO ( B1_UCOM )
		[3] - Custo da MOVIMENTA?O INTERNA Produ? ( D3_CUSTO3 )
		[4] - Custo da MOVIMENTA?O INTERNA Produ? ( D1_CUSTO1)
		[9] - Busca o primeiro custo que encontrar
	---------------------------------------------------------------------------------------- */

	/* ----------------------------------------------------------------------------------------
	( SB1 ) Cadastro de PRODUTOS
	// [1] - CUSTO STANDARD
	---------------------------------------------------------------------------------------- */
	If nTpCusto == 1 .OR. ( nTpCusto = 9  .AND. EMPTY( nCusto ) )
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek( xFilial("SB1") + cCodSB1, .f. )

		/* ----------------------------------------------------------------------------------------
		( pre?) - Custo STANTARD
		---------------------------------------------------------------------------------------- */
		cMoeda	 := IIF( EMPTY( SB1->B1_MCUSTD ), "1", SB1->B1_MCUSTD )
		cSimbolo := GETMV( "MV_SIMB" + AllTrim( cMoeda ) )
		nCusto	 := SB1->B1_CUSTD
	EndIf

	/* ----------------------------------------------------------------------------------------
	( pre?) - ULTIMA COMPRA
	// [2] - ULTIMA COMPRA SB1 
	---------------------------------------------------------------------------------------- */
	If nTpCusto == 2 .OR. ( nTpCusto = 9 .AND. EMPTY( nCusto ) )
		nCusto 	:= SB1->B1_UPRC
	EndIf

	/* ----------------------------------------------------------------------------------------
	( sd3 ) - MOVIMENTA?O INTERNA
	// [3] - MOVIMENTA?O INTERNA
	---------------------------------------------------------------------------------------- */
	If nTpCusto == 3 .OR. ( nTpCusto = 9 .AND. EMPTY( nCusto ) )
		cQryCusto	:= " "
		cQryCusto	+= " SELECT TOP 1 	SD3.D3_CUSTO1  AS CUSTO, "	+ CRLF
		cQryCusto	+= " 				SD3.D3_EMISSAO AS DATA "	+ CRLF
		cQryCusto	+= " FROM " + RETSqlName("SD3") + " SD3 (NOLOCK) "	+ CRLF
		cQryCusto	+= " WHERE 	SD3.D3_FILIAL  = '" + xfilial("SD3") + "' "	+ CRLF
		cQryCusto	+= " 	   	AND SD3.D3_COD     = '" + cCodSB1 + "' "	+ CRLF
		cQryCusto	+= " 	   	AND SD3.D3_CF      = 'PR0' "	+ CRLF
		cQryCusto	+= "		AND SD3.D_E_L_E_T_ = ' ' "	+ CRLF
		cQryCusto	+= " ORDER BY SD3.D3_EMISSAO DESC "	+ CRLF

		// fecha a area SD3
		If SELECT( (cAliasSD3) ) > 0
			DBSelectArea( (cAliasSD3) )
			DBCloseArea()
		Endif

		DBUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQryCusto)), cAliasSD3, .T., .T. )

		If (cAliasSD3)->(!Eof())  .And. (cAliasSD3)->(!Bof())
			nCusto := (cAliasSD3)->CUSTO
		EndIf

	EndIf


	/* ----------------------------------------------------------------------------------------
	( sd1 ) - NOTAS FISCAIS DE ENTRADA
	// [3] - NOTAS FISCAIS DE ENTRADA
	---------------------------------------------------------------------------------------- */
	If nTpCusto == 4 .OR. ( nTpCusto = 9 .AND. EMPTY( nCusto ) )
		cQryCusto	:= " "
		cQryCusto	+= " SELECT TOP 1 SD1.D1_CUSTO   AS CUSTO,"	+ CRLF
		cQryCusto	+= " 				SD1.D1_EMISSAO AS DATA" + CRLF
		cQryCusto	+= " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) " + CRLF
		cQryCusto	+= " WHERE 	SD1.D1_FILIAL  = '" +xFilial("SD1") + "' " + CRLF
		cQryCusto	+= " 	  	AND SD1.D1_COD     = '" + cCodSB1 + "' " + CRLF
		cQryCusto	+= " 	  	AND SD1.D_E_L_E_T_ = ' '" + CRLF
		cQryCusto	+= " ORDER BY SD1.D1_EMISSAO DESC" + CRLF
	
		// fecha a area SD1
		If SELECT( (cAliasSD1) ) > 0
			DBSelectArea( (cAliasSD1) )
			DBCloseArea()
		Endif

		DBUseArea( .T., "TOPCONN", TcGenQry( ,,ChangeQuery(cQryCusto)), cAliasSD1, .T., .T. )

		If (cAliasSD1)->(!Eof())  .And. (cAliasSD1)->(!Bof())
			nCusto := (cAliasSD1)->CUSTO
		EndIf

	EndIf

	/* ----------------------------------------------------------------------------------------
	( DESCRI?O DO PRODUTO )
	---------------------------------------------------------------------------------------- */
	cDescSB1 := SB1->B1_COD
	cDescSB1 += " - " + ALLTRIM( SB1->B1_DESC ) + " // "
	cDescSB1 += " Prc: [" + cSimbolo + "] "
	cDescSB1 += TransForm( nCusto, PesqPict( "SB1", "B1_CUSTD" ) )

	/* ----------------------------------------------------------------------------------------
	( fecha area(s) aberta(s) )
	---------------------------------------------------------------------------------------- */
	// fecha a area SD1
	If SELECT( (cAliasSD1) ) > 0
		DBSelectArea( (cAliasSD1) )
		DBCloseArea()
	Endif

	// fecha a area SD3
	If SELECT( (cAliasSD3) ) > 0
		DBSelectArea( (cAliasSD3) )
		DBCloseArea()
	Endif

	RESTAREA( aAREA_ATU )

Return( cDescSB1 )

Static Function VendasCanal(cCodProd,cCodTab)

Local aArea := GetArea()
Local dDataIni	:= Stod("")
Local dDataFim	:= Stod("")
Local nMes		:= 0
Local nAno		:= 0
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local nMeses    := 1
Local nQTd      := 0
Local nX

If Month(dDatabase)==1
	nMes := 12
	nAno := Year(dDatabase)-1
Else
	nMes := Month(dDatabase)-1
	nAno := Year(dDatabase)
EndIf

//dDataIni := Stod(StrZero(nAno,4)+StrZero(nMeses,2)+"01")
//dDataFim := LastDay(Stod(StrZero(nAno,4)+StrZero(nMeses,2)+"01"))

dDataIni := Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01")          // MGOMES 27/03/2021
dDataFim := LastDay(Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01")) // MGOMES 27/03/2021

For nX:=1 to (nMeses-1)
	If Month(dDataIni)==1
		nMes := 12
		nAno := Year(dDataIni)-1
	Else
		nMes := Month(dDataIni)-1
		nAno := Year(dDataIni)
	EndIf
	dDataIni := Stod(StrZero(nAno,4)+StrZero(nMes,2)+"01")
	aAdd(aVdaProd,{nMes,nAno,0,0,nX})
Next nX

//->> Vendas do Produto (Valor/Quantidade)
cQuery := "SELECT 	SUM(VENDA) AS VENDA,"															+CRLF
cQuery += "			SUM(QTDE)  AS QTDE,"															+CRLF
cQuery += "			MES,"																			+CRLF
cQuery += "			ANO,"                                                                           +CRLF 
cQuery += "	        TABPRECO "																		+CRLF
cQuery += "		FROM ("																				+CRLF
cQuery += "			 SELECT D2_TOTAL AS VENDA,"														+CRLF
cQuery += "			        D2_QUANT AS QTDE,"														+CRLF
cQuery += "					MONTH(SF2.F2_EMISSAO) AS MES,"											+CRLF
cQuery += "					YEAR(SF2.F2_EMISSAO) AS ANO,"											+CRLF
cQuery += "     ( SELECT C5_TABELA FROM "+RetSqlName("SC5")+ " SC5 (NOLOCK)"                        +CRLF
cQuery += "       WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "                                      +CRLF
cQuery += "       AND   SC5.C5_NUM    = SD2.D2_PEDIDO "                                             +CRLF
cQuery += "       AND   SC5.D_E_L_E_T_ <> '*' ) AS TABPRECO " 
cQuery += "		FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"											+CRLF
cQuery += "		  INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
cQuery += "				  ON SF2.F2_FILIAL  = SD2.D2_FILIAL"										+CRLF
cQuery += "				 AND SF2.F2_DOC     = SD2.D2_DOC"											+CRLF
cQuery += "				 AND SF2.F2_SERIE   = SD2.D2_SERIE"											+CRLF
cQuery += "				 AND SF2.F2_TIPO    = 'N'"													+CRLF
cQuery += "				 AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"	+CRLF
cQuery += "				 AND SF2.D_E_L_E_T_ = ' '"													+CRLF
cQuery += "		WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"										+CRLF
cQuery += " 	  AND SD2.D2_COD     = '"+cCodProd+"'"											   +CRLF
cQuery += " 	  AND SD2.D_E_L_E_T_ = ' '"															+CRLF
cQuery += "			  ) AS TMP"																		+CRLF
cQuery += "     WHERE TMP.TABPRECO = '"+cCodTab+"' "																		+CRLF
cQuery += "GROUP BY MES, ANO, TABPRECO "     														+CRLF
cQuery += "ORDER BY ANO, MES, TABPRECO "			// MGOMES 27/03/2021															+CRLF

DBUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAlias, .T., .T. )

nQtd := (cAlias)->QTDE

(cAlias)->(dbCloseArea())

RestArea(aArea)
Return(nQtd)
