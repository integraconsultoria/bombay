#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "apwizard.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"

Static POSITEMPV 	:= 0
Static nCorPan1		:= Rgb(255,201,14)

/*/{protheus.doc} BoConsPV
*******************************************************************************************
Consulta da posição do pedido de vendas.
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoConsPV()
Local aBoxParam     := {}
Local oWizard	    := NIL
Local aMyLegenda    := {}
Local nX		    := 1
Local nLin          := 5
Local cTextApres    := ""
Local cLogotipo     := NIL
Local aCoords       := {}
Local aSize	   		:= MsAdvSize()
Local aHeader       := {}
Local aCols         := {}
Local oFWLayer      := NIL
Local oPanSup       := NIL
Local oPanInf       := NIL
Local oPanIDir      := NIL
Local oPanICen      := NIL
Local oPanIEsq      := NIL

//->> Marcelo Celi - 08/09/2022
Local lEdita        := SC5->(FieldPos("C5_XOBSLOG")) > 0
Local lOk           := .F.
Local nPFil         := 0
Local nPPed         := 0
Local nPObs         := 0

Private aRetParam	:= {}
Private aLegenda	:= {}
Private oPedidos    := NIL
Private oGrfsPizza  := NIL

Private cCliente    := ""
Private oCliente    := NIL
Private cLoja       := ""
Private oLoja       := NIL
Private cCGC        := ""
Private oCGC        := NIL
Private cNome       := ""
Private oNome       := NIL
Private cFanta      := ""
Private oFanta      := NIL

//->> Marcelo Celi - 13/01/2021 - Mudança de cor da legenda de acordo com as solicitações do cliente
//aAdd(aLegenda,{"ENABLE"	    ,"Pedido de Venda em aberto"                , "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)" })
//aAdd(aLegenda,{"DISABLE"	    ,"Pedido de Venda encerrado"                , "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)"   })
//aAdd(aLegenda,{"BR_AMARELO"   ,"Pedido de Venda liberado"                 , "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)" })
//aAdd(aLegenda,{"BR_AZUL"      ,"Pedido de Venda com Bloqueio de Regra"    , "C5_BLQ == '1'"                                            })
//aAdd(aLegenda,{"BR_LARANJA"   ,"Pedido de Venda com Bloqueio de Verba"    , "C5_BLQ == '2'"                                            })

aAdd(aLegenda,{"DISABLE"    ,"Pedido na Area Comercial"                 , "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)", 1 })
aAdd(aLegenda,{"ENABLE"	    ,"Pedido de Venda Encerrado"                , "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)"  , 4 })
aAdd(aLegenda,{"BR_AMARELO" ,"Pedido em Fluxo"                          , "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)", 3 })
aAdd(aLegenda,{"BR_AZUL"    ,"Pedido de Venda com Bloqueio de Regra"    , "C5_BLQ == '1'"                                           , 2 })
aAdd(aLegenda,{"BR_LARANJA" ,"Pedido de Venda com Bloqueio de Verba"    , "C5_BLQ == '2'"                                           , 5 })

aAdd(aHeader,{ 	""           ,"LEGENDA"     ,"@BMP" ,2                          ,0                          ,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Filial"     ,"FILIAL"      ,"@!"   ,Tamsx3("C5_FILIAL")[01]    ,Tamsx3("C5_FILIAL")[02]    ,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Pedido"     ,"PEDIDO"      ,"@!"   ,Tamsx3("C5_NUM")[01]       ,Tamsx3("C5_NUM")[02]       ,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Emissao"    ,"EMISSAO"     ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})

//->> Marcelo Celi - 01/02/2021
//aAdd(aHeader,{"Entrega"    ,"ENTREGA"     ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Previsão Coleta"    ,"ENTREGA"     ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})

aAdd(aHeader,{ 	"Liberação"  ,"LIBERACAO"   ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Produção"   ,"PCP"         ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Seperação"  ,"SEPARACAO"   ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Logistica"  ,"LOGISTICA"   ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
aAdd(aHeader,{ 	"Faturamento","FATURAMENTO" ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})

//->> Marcelo Celi - 01/02/2021
//aAdd(aHeader,{"Expedição"  ,"EXPEDICAO"   ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})

//->> Marcelo Celi - 24/07/2021
//aAdd(aHeader,{ 	"Coleta"     ,"EXPEDICAO"   ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})
//aAdd(aHeader,{"Entreg Real","REAL"        ,""     ,8                          ,0                          ,NIL,NIL,"D",NIL,"V",NIL,NIL,NIL,"V"})

//->> Marcelo Celi - 20/07/2021
aAdd(aHeader,{ 	"Dt Coleta"      ,"COLETA"     ,"@!",8,0,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"   })
aAdd(aHeader,{ 	"Dt Agend"       ,"AGENDAMENTO","@!",8,0,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"   })
aAdd(aHeader,{ 	"Dt Real Entrega","REAL_ENTR"  ,"@!",8,0,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,"V"   })

//->> Marcelo Celi - 01/02/2021
aAdd(aHeader,{ 	"Observação Logistica"    ,"OBS"      ,""     ,100                        ,0                          ,NIL,NIL,"C",NIL,"V",NIL,NIL,NIL,If(lEdita,"A","V")})

cTextApres  := "Este Recurso Permite a Geração da Posição do Pedido de Vendas."+CRLF
aCoords     := {0,0,aSize[6] := aSize[6] - aSize[2] - aSize[8] - 5,aSize[5]}

AADD( aRetParam, Replicate(" ",Tamsx3("C5_NUM")[01]) 	 )
AADD( aRetParam, Replicate(" ",Tamsx3("C5_NUM")[01]) 	 )
AADD( aRetParam, Replicate(" ",Tamsx3("C5_CLIENTE")[01]) )
AADD( aRetParam, Replicate(" ",Tamsx3("C5_LOJACLI")[01]) )
AADD( aRetParam, Replicate(" ",Tamsx3("C5_CLIENTE")[01]) )	
AADD( aRetParam, Replicate(" ",Tamsx3("C5_LOJACLI")[01]) )
AADD( aRetParam, Stod("") )
AADD( aRetParam, Stod("") )

//->> Marcelo Celi - 13/01/2021
AADD( aRetParam, Replicate(" ",Tamsx3("C5_VEND1")[01]) )
AADD( aRetParam, Replicate(" ",Tamsx3("C5_VEND1")[01]) )

AADD( aBoxParam,{1,"Pedido de"		, aRetParam[01]		,""		,""	,"SC5"	,".T."	,(Tamsx3("C5_NUM")[01])*8		,.F.})
AADD( aBoxParam,{1,"Pedido ate"		, aRetParam[02]		,""		,""	,"SC5"	,".T."	,(Tamsx3("C5_NUM")[01])*8		,.F.})
AADD( aBoxParam,{1,"Cliente de"		, aRetParam[03]		,""		,""	,"SA1"	,".T."	,(Tamsx3("C5_CLIENTE")[01])*8	,.F.})
AADD( aBoxParam,{1,"Loja de"		, aRetParam[04]		,""		,""	,""		,".T."	,(Tamsx3("C5_LOJACLI")[01])*3	,.F.})
AADD( aBoxParam,{1,"Cliente ate"	, aRetParam[05]		,""		,""	,"SA1"	,".T."	,(Tamsx3("C5_CLIENTE")[01])*8	,.F.})
AADD( aBoxParam,{1,"Loja ate"		, aRetParam[06]		,""		,""	,""		,".T."	,(Tamsx3("C5_LOJACLI")[01])*3	,.F.})
AADD( aBoxParam,{1,"Emissão de"		, aRetParam[07]		,""		,""	,""		,".T."	,070							,.F.})
AADD( aBoxParam,{1,"Emissão ate"	, aRetParam[08]		,""		,""	,""		,".T."	,070							,.F.})

//->> Marcelo Celi - 13/01/2021
AADD( aBoxParam,{1,"Vendedor de"	, aRetParam[09]		,""		,""	,"SA3"	,".T."	,(Tamsx3("C5_VEND1")[01])*8		,.F.})
AADD( aBoxParam,{1,"Vendedor ate"	, aRetParam[10]		,""		,""	,"SA3"	,".T."	,(Tamsx3("C5_VEND1")[01])*8		,.F.})

oWizard := APWizard():New(  "Posição de Pedidos",               												 ;   // chTitle  - Titulo do cabeï¿½alho
                            "Pedido de Vendas", 	        							         			     ;   // chMsg    - Mensagem do cabeï¿½alho
                            "Business Intelligence",                							 			     ;   // cTitle   - Tï¿½tulo do painel de apresentaï¿½ï¿½o
                            cTextApres,       													 			     ;   // cText    - Texto do painel de apresentaï¿½ï¿½o
                            {|| .T. },          												 			     ;   // bNext    - Bloco de cï¿½digo a ser executado para validar o botï¿½o "Avanï¿½ar"
                            {|| .T. },              											 				 ;   // bFinish  - Bloco de cï¿½digo a ser executado para validar o botï¿½o "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                            cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabeï¿½alho, essa tem que fazer parte do repositï¿½rio 
                            {|| },                												 			     ;   // bExecute - Bloco de cï¿½digo contendo a aï¿½ï¿½o a ser executada no clique dos botï¿½es "Avanï¿½ar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nï¿½o exibe o painel de apresentaï¿½ï¿½o
                            aCoords                     										 				 )   // aCoord   - Array contendo as coordenadas da tela

oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel 
                    "Informe os parametros para continuar com a Consulta", 			             			     ;   // cMsg     - Mensagem posicionada no cabeï¿½alho do painel
                    {|| .T. },                						         				                     ;   // bBack    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Voltar"
                    {|| GetPedidos(oPanIDir,aHeader) }, 			                                             ;   // bNext    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Avanï¿½ar"
                    {|| GetPedidos(oPanIDir,aHeader) },    			                                             ;   // bFinish  - Bloco de cï¿½digo utilizado para validar o botï¿½o "Finalizar"
                    .T.,                                              							  			   	 ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                    {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

	Parambox(aBoxParam,"Parametrizacao",@aRetParam,,,,,,oWizard:GetPanel(2),,.F.,.F.)

oWizard:NewPanel(   "Posição dos Pedidos de Vendas",                          							         ;   // cTitle   - Tï¿½tulo do painel 
                    "", 	                                                		             			     ;   // cMsg     - Mensagem posicionada no cabeï¿½alho do painel
                    {|| .T. },                						         				                     ;   // bBack    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Voltar"
                    {|| lOk:=If(lEdita,MsgYesNo("Confirma os Dados Editados?"),.T.),lOk }, 		                 ;   // bNext    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Avanï¿½ar"
                    {|| lOk:=If(lEdita,MsgYesNo("Confirma os Dados Editados?"),.T.),lOk },                       ;   // bFinish  - Bloco de cï¿½digo utilizado para validar o botï¿½o "Finalizar"
                    .T.,                                              							  			   	 ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                    {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

    oPanSup := TPanel():New(0,0,'',oWizard:GetPanel(3), oWizard:GetPanel(3):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(3):NCLIENTWIDTH)/2),((oWizard:GetPanel(3):NCLIENTHEIGHT)/2)*.50,.T.,.F. )
	oPanSup:Align := CONTROL_ALIGN_TOP

    oPedidos := MSNewGetDados():New(00,00,((oPanSup:NHEIGHT)/2),((oPanSup:NWIDTH)/2),If(lEdita,GD_UPDATE,2),.T.,.T.,,,,,,,,oPanSup,aHeader,aCols)
	oPedidos:bChange := {||POSITEMPV := oPedidos:nAt,oPedidos:Refresh(),AtDadClient()}
	oPedidos:oBrowse:SetBlkBackColor({|| GETDCLR(oPedidos:nAt,POSITEMPV,nCorPan1)})	
	oPedidos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanInf := TPanel():New(0,0,'',oWizard:GetPanel(3), oWizard:GetPanel(3):oFont, .T., .T.,,Rgb(210,210,210),((oWizard:GetPanel(3):NCLIENTWIDTH)/2),((oWizard:GetPanel(3):NCLIENTHEIGHT)/2)*.50,.F.,.T. )
	oPanInf:Align := CONTROL_ALIGN_BOTTOM

    oFWLayer := FWLayer():New()  
    oFWLayer:Init(oPanInf,.F.,.F.)  

    oFWLayer:addLine("LINHA1",100,.F.)  
    oFWLayer:AddCollumn("COLUNA1"	,25,.T.,"LINHA1")
    oFWLayer:AddCollumn("COLUNA2"	,25,.T.,"LINHA1")
    oFWLayer:AddCollumn("COLUNA3"	,50,.T.,"LINHA1")    

    oFWLayer:AddWindow("COLUNA1"	,"oPanIEsq"	,"Legenda"   ,100,.F.,.T.,,"LINHA1",{ || })   
    oPanIEsq := oFWLayer:GetWinPanel("COLUNA1","oPanIEsq","LINHA1")   

    For nX:=1 to Len(aLegenda)		
		aAdd(aMyLegenda,{	TBitmap():New(nLin,01,15,15,,,.T.,oPanIEsq,{|| },,.T.,.F.,,,.F.,,.T.,,.F.),;
							TSay():New(nLin,01, {|| " " }, oPanIEsq,,oWizard:GetPanel(3):oFont,,,,.T.,Rgb(0,0,0),CLR_WHITE,200,20)})
		
		aMyLegenda[Len(aMyLegenda)][1]:NLEFT 	:= 05 
		aMyLegenda[Len(aMyLegenda)][1]:CRESNAME := aLegenda[nX,01]
		aMyLegenda[Len(aMyLegenda)][1]:Refresh()
		
		aMyLegenda[Len(aMyLegenda)][2]:NLEFT 	:= 25
		aMyLegenda[Len(aMyLegenda)][2]:SetText(aLegenda[nX,02])
		aMyLegenda[Len(aMyLegenda)][2]:CtrlRefresh()
		
		nLin+=12
	Next nX

    oFWLayer:AddWindow("COLUNA2"	,"oPanICen"	,"Informações do Cliente"   ,100,.F.,.T.,,"LINHA1",{ || })   
    oPanICen := oFWLayer:GetWinPanel("COLUNA2","oPanICen","LINHA1")   

    @ 005,005 MSGet oCliente Var cCliente 	When .F.	SIZE  40,10 				Picture PesqPict("SA1","A1_COD")	OF oPanICen PIXEL Hasbutton
    @ 018,005 Say SA1->(RetTitle("A1_COD"))	    												  						OF oPanICen PIXEL

    @ 005,050 MSGet oLoja   Var cLoja 	    When .F.	SIZE  20,10 				Picture PesqPict("SA1","A1_LOJA")	OF oPanICen PIXEL Hasbutton
    @ 018,050 Say SA1->(RetTitle("A1_LOJA"))	    												  					OF oPanICen PIXEL

    @ 005,075 MSGet oCGC    Var cCGC 	    When .F.	SIZE  60,10 				Picture PesqPict("SA1","A1_CGC")	OF oPanICen PIXEL Hasbutton
    @ 018,075 Say SC5->(RetTitle("C5_NOTA"))	    												  					OF oPanICen PIXEL

    @ 030,005 MSGet oNome   Var cNome    	When .F.	SIZE 130,10 				Picture PesqPict("SA1","A1_NOME")	OF oPanICen PIXEL Hasbutton
    @ 043,005 Say SA1->(RetTitle("A1_NOME"))	    												  					OF oPanICen PIXEL

    @ 055,005 MSGet oFanta   Var cFanta    	When .F.	SIZE 130,10 				Picture PesqPict("SA1","A1_NREDUZ")	OF oPanICen PIXEL Hasbutton
    @ 068,005 Say SA1->(RetTitle("A1_NREDUZ"))	    												  					OF oPanICen PIXEL

    oFWLayer:AddWindow("COLUNA3"	,"oPanIDir"	,"Posição do Pedido"        ,100,.F.,.T.,,"LINHA1",{ || })   
    oPanIDir := oFWLayer:GetWinPanel("COLUNA3","oPanIDir","LINHA1")   


oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o diï¿½logo serï¿½ centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de cï¿½digo a ser executado no encerramento do diï¿½logo
                    {|| .T. },  ;   // bInit    - Bloco de cï¿½digo a ser executado na inicializaï¿½ï¿½o do diï¿½logo
                    {|| .T. }   )   // bWhen    - Bloco de cï¿½digo para habilitar a execuï¿½ï¿½o do diï¿½logo

    //->> Marcelo Celi - 08/09/2022
    If lOk .And. lEdita
        nPFil := Ascan(oPedidos:aHeader,{|x| Alltrim(Upper(x[02]))=="FILIAL"})
        nPPed := Ascan(oPedidos:aHeader,{|x| Alltrim(Upper(x[02]))=="PEDIDO"})
        nPObs := Ascan(oPedidos:aHeader,{|x| Alltrim(Upper(x[02]))=="OBS"   })

        If nPFil>0 .And. nPPed>0 .And. nPObs>0
            For nX:=1 to Len(oPedidos:aCols)
                SC5->(dbSEtOrder(1))
                If SC5->(dbSeek(PadR(oPedidos:aCols[nX,nPFil],Tamsx3("C5_FILIAL")[01])+;
                                PadR(oPedidos:aCols[nX,nPPed],Tamsx3("C5_NUM")   [01])))

                    RecLock("SC5",.F.)
                    SC5->C5_XOBSLOG := Alltrim(oPedidos:aCols[nX,nPObs])
                    SC5->(MsUnlock())
                EndIf
            Next nX
        Else
            MsgAlert("Dados não puderam ser gravados devido a não estarem devidamente configurados.")
        EndIf
    EndIf

Return

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 06/01/2021
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

/*/{protheus.doc} GetPedidos
*******************************************************************************************
Retorna os Pedidos de Vendas 
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPedidos(oPanIDir,aHeader)
local lRet      := .T.
MsgRun("Filtrando Pedidos de Vendas...",,{ || lRet := GetPV(oPanIDir,aHeader) })
Return lRet

Static Function GetPV(oPanIDir,aHeader)
local lRet      := .T.
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local nX        := 1
Local cImagem   := ""
Local aColsTmp  := {}
Local aCols     := {}

//->> Marcelo Celi - 13/01/2021
Local dDtLiber  := Stod("")

//->> Marcelo Celi - 13/01/2021
Local nOrdem    := 0
Local aNewAcols := {}
Local nY        := 1

//->> Marcelo Celi - 03/03/2021
Local cCgcNot   := ""

//->> Marcelo Celi - 03/03/2021
SM0->(dbGotop())
Do While SM0->(!Eof())
    If !Empty(cCgcNot)
        cCgcNot += ";"
    Endif
    cCgcNot += SM0->M0_CGC
    SM0->(dbSkip())
EndDo
cCgcNot := FormatIn(cCgcNot,";")
SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt+cFilAnt))

cQuery := "SELECT SC5.R_E_C_N_O_ AS RECSC5"                                                             +CRLF
cQuery += " FROM "+RetSqlName("SC5")+" SC5 (NOLOCK)"                                                    +CRLF

//->> Marcelo Celi - 03/03/2021
cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"   +CRLF
cQuery += " ON  SA1.A1_FILIAL = '"+xFilial("SA1")+"'"       +CRLF
cQuery += " AND SA1.A1_COD    = SC5.C5_CLIENTE"             +CRLF
cQuery += " AND SA1.A1_LOJA   = SC5.C5_LOJACLI"             +CRLF
cQuery += " AND SA1.A1_CGC NOT IN "+cCgcNot                 +CRLF
cQuery += " AND SA1.D_E_L_E_T_ = ' '"                       +CRLF

cQuery += " WHERE   SC5.C5_FILIAL = '"+xFilial("SC5")+"'"                                               +CRLF

If !Empty(aRetParam[02])
    cQuery += "     AND SC5.C5_NUM BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"                 +CRLF
ElseIf !Empty(aRetParam[01])    
    cQuery += "     AND SC5.C5_NUM = '"+aRetParam[01]+"'"                                               +CRLF
EndIf

If !Empty(aRetParam[05])
    cQuery += "     AND SC5.C5_CLIENTE BETWEEN '"+aRetParam[03]+"' AND '"+aRetParam[05]+"'"             +CRLF
ElseIf !Empty(aRetParam[03])    
    cQuery += "     AND SC5.C5_CLIENTE = '"+aRetParam[03]+"'"                                           +CRLF
EndIf

If !Empty(aRetParam[06])
    cQuery += "     AND SC5.C5_LOJACLI BETWEEN '"+aRetParam[04]+"' AND '"+aRetParam[06]+"'"             +CRLF
ElseIf !Empty(aRetParam[04])    
    cQuery += "     AND SC5.C5_LOJACLI = '"+aRetParam[04]+"'"                                           +CRLF
EndIf

If !Empty(aRetParam[08])
    cQuery += "     AND SC5.C5_EMISSAO BETWEEN '"+dTos(aRetParam[07])+"' AND '"+dTos(aRetParam[08])+"'" +CRLF
ElseIf !Empty(aRetParam[07])    
    cQuery += "     AND SC5.C5_EMISSAO = '"+dTos(aRetParam[07])+"'"                                     +CRLF
EndIf

//->> Marcelo Celi - 13/01/2021
If !Empty(aRetParam[10])
    cQuery += "     AND SC5.C5_VEND1 BETWEEN '"+aRetParam[09]+"' AND '"+aRetParam[10]+"'" +CRLF
ElseIf !Empty(aRetParam[09])    
    cQuery += "     AND SC5.C5_VEND1 = '"+aRetParam[09]+"'"                                     +CRLF
EndIf

//->> Marcelo Celi - 03/03/2021
cQuery += " AND SC5.C5_TIPO = 'N'"+CRLF

cQuery += "     AND SC5.D_E_L_E_T_ = ' '"                                                               +CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
	dbSelectArea("SC5")
    SC5->(dbGoto((cAlias)->RECSC5))	
    cImagem  := ""
    aColsTmp := {}
    nOrdem   := 0

    For nX:=1 to Len(aLegenda)
        If &(aLegenda[nX,03])
            cImagem := aLegenda[nX,01]
            nOrdem  := aLegenda[nX,04]
        EndIf
    Next nX

    aAdd(aColsTmp, LoadBitmap( GetResources(), cImagem )    )
    aAdd(aColsTmp, SC5->C5_FILIAL                           )
    aAdd(aColsTmp, SC5->C5_NUM                              )
    aAdd(aColsTmp, SC5->C5_EMISSAO                          )
    aAdd(aColsTmp, GetDtEntreg(SC5->C5_NUM,SC5->C5_EMISSAO) )

    //->> Marcelo Celi - 13/01/2021
    dDtLiber := GetDtLiber(SC5->C5_NUM)
    aAdd(aColsTmp, dDtLiber                                 )
    aAdd(aColsTmp, GetDtProd(SC5->C5_NUM,dDtLiber)          )    

    aAdd(aColsTmp, GetDtConf(SC5->C5_NUM)                   )
    aAdd(aColsTmp, cTod(Left(SC5->C5_XDLIBLO,10))           )
    aAdd(aColsTmp, GetDtFatur(SC5->C5_NUM)                  )
    
    //->> Marcelo Celi - 24/07/2021
    //aAdd(aColsTmp, cTod(Left(SC5->C5_XDLIBEX,10))           )
    //aAdd(aColsTmp, SC5->C5_XDENTRE                          )

    //->> Marcelo Celi - 20/07/2021
    aAdd(aColsTmp, SC5->C5_XDCOLET                          )
    aAdd(aColsTmp, SC5->C5_XDAGEND                          )
    aAdd(aColsTmp, SC5->C5_XREAENT                          )

    //->> Marcelo Celi - 01/02/2021
    If SC5->(FieldPos("C5_XOBSLOG")) > 0
        aAdd(aColsTmp, SC5->C5_XOBSLOG                      )
    Else
        aAdd(aColsTmp, ""                                   )    
    EndIf

    aAdd(aColsTmp, .F.                                      )
    aAdd(aColsTmp, nOrdem                                   )

    aAdd(aCols,aColsTmp)
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

//->> Marcelo Celi - 13/01/2021 - Inicio
//aCols := aSort(aCols,,,{|x,y| x[14] < y[14] })
//->> Marcelo Celi - 01/02/2021
//aCols := aSort(aCols,,,{|x,y| x[15] < y[15] })
//->> Marcelo Celi - 20/07/2021
aCols := aSort(aCols,,,{|x,y| x[16] < y[16] })

For nX:=1 to Len(aCols)
    aColsTmp := {}
    For nY:=1 to (Len(aCols[nX])-1)
        aAdd(aColsTmp,aCols[nX,nY])
    Next nY
    aAdd(aNewAcols,aColsTmp)
Next nX
aCols := aClone(aNewAcols)
//->> Fim

If Len(aCols) == 0
    MsgAlert("Nenhum Pedido de Vendas Filtrado no Range Informado...")
    lRet := .F.
Else
    lRet := .T.
    oPedidos:aCols := aCols
    oPedidos:Refresh()
EndIf

AtualGrf(oPanIDir)

Return lRet

/*/{protheus.doc} AtDadClient
*******************************************************************************************
Atualiza os Dados do Cliente na tela
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtDadClient()

cCliente    := ""        
cLoja       := ""        
cCGC        := ""        
cNome       := ""        
cFanta      := ""

SC5->(dbSetOrder(1))
If SC5->(dbSeek(oPedidos:aCols[oPedidos:nAt][02] + oPedidos:aCols[oPedidos:nAt][03] ))
   
cCGC := SC5->C5_NOTA
   
    SA1->(dbSetOrder(1))
    If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
        cCliente    := SA1->A1_COD
        cLoja       := SA1->A1_LOJA
     // cCGC        := SA1->A1_CGC
        cNome       := SA1->A1_NOME
        cFanta      := SA1->A1_NREDUZ
    EndIf
EndIf

oCliente:Refresh()
oLoja:Refresh()
oCGC:Refresh()
oNome:Refresh()
oFanta:Refresh()

Return

/*/{protheus.doc} GetDtEntreg
*******************************************************************************************
Retorna a Data de Entrega do Pedido
 
@author: Marcelo Celi Marques
@since: 06/01/2021
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

/*/{protheus.doc} GetDtLiber
*******************************************************************************************
Retorna a Data de Liberação do Pedido
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDtLiber(cPedido)
Local dLiber := Stod("")

SC9->(dbSetOrder(1))
SC9->(dbSeek(xFilial("SC9")+cPedido))
Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cPedido
    If SC9->C9_DATALIB > dLiber
        dLiber := SC9->C9_DATALIB
    EndIf
    SC9->(dbSkip())
EndDo

Return dLiber

/*/{protheus.doc} GetDtFatur
*******************************************************************************************
Retorna a Data de Faturamento do Pedido
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDtFatur(cPedido)
Local dFatur := Stod("")

SD2->(dbSetOrder(8))
If SD2->(dbSeek(xFilial("SD2")+cPedido))
    SF2->(dbSetOrder(1))
    If SF2->(dbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE)))
        dFatur := SF2->F2_EMISSAO
    EndIf
EndIf

Return dFatur

/*/{protheus.doc} GetDtConf
*******************************************************************************************
Retorna a Data de Conferencia do Pedido
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDtConf(cPedido)
Local dConf := Stod("")

SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6")+cPedido))
Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+cPedido
    If SC6->C6_XDTCONF > dConf
        dConf := SC6->C6_XDTCONF
    EndIf
    SC6->(dbSkip())
EndDo

Return dConf

/*/{protheus.doc} GetDtProd
*******************************************************************************************
Retorna a Data de Produção do Pedido
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDtProd(cPedido,dDtLiber)
Local dProd  := Stod("")
Local cQuery := ""
Local cAlias := GetNextAlias()

cQuery := "SELECT TOP 1 C2_EMISSAO"                         +CRLF
cQuery += " FROM "+RetSqlName("SC2")+" SC2 (NOLOCK)"        +CRLF
cQuery += " WHERE   SC2.C2_FILIAL  = '"+xFilial("SC2")+"'"  +CRLF
cQuery += "     AND SC2.C2_PEDIDO  = '"+cPedido+"'"         +CRLF
cQuery += "     AND SC2.C2_EMISSAO <> ' '"                  +CRLF
cQuery += "     AND SC2.D_E_L_E_T_ = ' '"                   +CRLF
cQuery += " ORDER BY C2_EMISSAO DESC"                       +CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
    dProd := Stod((cAlias)->C2_EMISSAO)
EndIf
(cAlias)->(dbCloseArea())

//->> Marcelo Celi - 13/01/2021
If Empty(dProd)
    dProd := dDtLiber
EndIf

Return dProd

/*/{protheus.doc} AtualGrf
*******************************************************************************************
Atualiza o Grafico
 
@author: Marcelo Celi Marques
@since: 06/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtualGrf(oPanIDir)
Local nTmpLiber := 0
Local nTmpProd  := 0
Local nTmpSepar := 0
Local nTmpLogis := 0
Local nTmpFatur := 0
Local nTmpExped := 0

If Len(oPedidos:aCols) > 0
    nTmpLiber := oPedidos:aCols[oPedidos:nAt][06] - oPedidos:aCols[oPedidos:nAt][04]  //->> Data de Separacao - Data de Emissão
    nTmpProd  := oPedidos:aCols[oPedidos:nAt][07] - oPedidos:aCols[oPedidos:nAt][04]  //->> Data de Produção - Data de Emissao
    nTmpSepar := oPedidos:aCols[oPedidos:nAt][08] - oPedidos:aCols[oPedidos:nAt][06]  //->> Data de Separacao - Data de Liberacao
    nTmpLogis := oPedidos:aCols[oPedidos:nAt][09] - oPedidos:aCols[oPedidos:nAt][08]  //->> Data de Logistica - Data de Separacao
    nTmpFatur := oPedidos:aCols[oPedidos:nAt][10] - oPedidos:aCols[oPedidos:nAt][09]  //->> Data de Faturamento - Data de Logistica
    nTmpExped := oPedidos:aCols[oPedidos:nAt][11] - oPedidos:aCols[oPedidos:nAt][10]  //->> Data de Expedicao - Data de Faturamento

    nTmpLiber := If(nTmpLiber < 0 ,0 ,nTmpLiber)
    nTmpProd  := If(nTmpProd  < 0 ,0 ,nTmpProd)
    nTmpSepar := If(nTmpSepar < 0 ,0 ,nTmpSepar)
    nTmpLogis := If(nTmpLogis < 0 ,0 ,nTmpLogis)
    nTmpFatur := If(nTmpFatur < 0 ,0 ,nTmpFatur)
    nTmpExped := If(nTmpExped < 0 ,0 ,nTmpExped)
EndIf

If Valtype(oGrfsPizza)=="O"
    FreeObj(oGrfsPizza)
EndIf

oGrfsPizza := FWChartPie():New()
oGrfsPizza:init( oPanIDir, .T. ) 

oGrfsPizza:addSerie( "Tempo Liberação"	, nTmpLiber )
oGrfsPizza:addSerie( "Tempo Produção"	, nTmpProd  )	
oGrfsPizza:addSerie( "Tempo Separação"	, nTmpSepar )	
oGrfsPizza:addSerie( "Tempo Logistica"	, nTmpLogis )	
oGrfsPizza:addSerie( "Tempo Faturamento", nTmpFatur )	
oGrfsPizza:addSerie( "Tempo Expedição"	, nTmpExped )	

oGrfsPizza:setLegend( CONTROL_ALIGN_LEFT )
oGrfsPizza:Build()

Return
