#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*/{protheus.doc} InWizard
*******************************************************************************************
Esta classe constroi uma interface padrÃ£o de assistente ( Wizard ).

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
CLASS InWizard	
DATA aHeaderTitle	
DATA oMPanel
DATA aCbValid
DATA aCbExecute

DATA oDlg
DATA oBackGround
DATA oNext
DATA oBack
DATA oCancel
DATA oFinish		
DATA oHeaderTitle
DATA oHeaderMsg

DATA oPanPrinc
DATA oPanBarrBt
DATA oImgRodape
DATA oImgCabec
DATA cLogoRod
DATA oHeaderImg

DATA nPanel
DATA nTPanel
DATA nLPWidth
DATA cTitulo_Barra

METHOD New()
METHOD Activate()
METHOD Navigator()
METHOD NewPanel()
METHOD GetPanel()
METHOD SetFinish()
METHOD SetPanel()
METHOD RefreshButtons()
METHOD DisableButtons()
METHOD EnableButtons()
METHOD SetMessage(cMsg)
METHOD SetHeader(cHeader)
METHOD CriaMyTela(oDlg, aCoords, cTitulo, lBotoes,bOk,bCancel)

END CLASS

/*/{protheus.doc} New
*******************************************************************************************
Metodo contrutor da classe

@param cHeaderTitle   	Titulo do header do assistente.
@param cHeaderMsg     	Mensagem do header do assistente.
@param cTitleDlg 		Titulo da janela
@param cWelcome  		Texto de boas vindas
@param bNext     		Bloco de cÃ³digo que Ã© executado no botÃ£o avanÃ§ar.
@param bFinish   		Bloco de cÃ³digo que Ã© executado no botÃ£o finalizar.
@param lNoScrool 		Indica que o texto de boas vindas nÃ£o deve ter scroll
@param cResHead  		fora de uso
@param bExecute  		fora de uso
@param lNoFirst  		fora de uso
@param aCoord    		Tamanho da janela

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD New( cHeaderTitle, cHeaderMsg, cTitleDlg, cWelcome, bNext, bFinish, lNoScroll, cResHead, bExecute, lNoFirst , aCoord, cLogoRod, cTitulo_Barra ) CLASS InWizard
Local oBodyText
Local oHeaderPanel
Local oFontBoldHeader
Local oFontBoldWelcome
Local oFontWelcome
Local oMsgWelcome
Local nLeft            :=  0
Local aTela			   := {}	

PARAMTYPE 00 VAR cHeaderTitle 	AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 01 VAR cHeaderMsg   	AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 02 VAR cTitleDlg    	AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 03 VAR cWelcome     	AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 04 VAR bNext        	AS BLOCK     OPTIONAL DEFAULT {|| .T.}
PARAMTYPE 05 VAR bFinish      	AS BLOCK     OPTIONAL DEFAULT {|| .T.}
PARAMTYPE 06 VAR lNoScroll    	AS LOGICAL   OPTIONAL DEFAULT .T.
PARAMTYPE 07 VAR cResHead     	AS CHARACTER OPTIONAL DEFAULT "fw_logo_mini_black"
PARAMTYPE 08 VAR bExecute     	AS BLOCK     OPTIONAL 
PARAMTYPE 09 VAR lNoFirst     	AS LOGICAL   OPTIONAL 
PARAMTYPE 10 VAR aCoord       	AS ARRAY     OPTIONAL DEFAULT { 000, 000, 500, 700 }
PARAMTYPE 11 VAR cLogoRod     	AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 12 VAR cTitulo_Barra  AS CHARACTER OPTIONAL DEFAULT ""

::oMPanel	:= Array(1)
::nTPanel	    := 1
::nPanel	    := 1
::aCbValid	    := {}
::aHeaderTitle	:= {}
::aCbExecute	:= {}
::cLogoRod		:= cLogoRod
::cTitulo_Barra := cTitulo_Barra

Aadd( ::aHeaderTitle,{cHeaderTitle,cHeaderMsg	})
Aadd( ::aCbValid    ,{{|| .T.},bNext,bFinish	})
Aadd( ::aCbExecute  ,{|| .T. 					})

DEFINE FONT oFontBoldHeader  NAME 'Verdana' SIZE 000,014 BOLD
DEFINE FONT oFontBoldWelcome NAME 'Verdana' SIZE 000,014 BOLD
DEFINE FONT oFontWelcome	 NAME 'Verdana' SIZE 000,012

// Desfoca a janela anterior
::oBackGround := FWCreateTransparent()

// Cria a janela de wizard
::oDlg := FWStyledDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],"",{||})

aTela := ::CriaMyTela(::oDlg,aCoord,cHeaderTitle,.F.,{||  },{|| })
::oPanPrinc   := aTela[2]
::oPanBarrBt  := aTela[3]

// Cria o painel superior
@ 000,000 MSPANEL oHeaderPanel	OF ::oPanPrinc SIZE 000,042
oHeaderPanel:Align := CONTROL_ALIGN_TOP
oHeaderPanel:nClrPane := RGB(234,241,246)
oHeaderPanel:ReadClientCoors()

@ 000,000 BITMAP ::oHeaderImg RESNAME "officepainelprincipalblack" SIZE oHeaderPanel:NCLIENTHEIGHT/2,oHeaderPanel:NCLIENTWIDTH/2 NOBORDER PIXEL OF oHeaderPanel ADJUST

::oHeaderImg:Align := CONTROL_ALIGN_ALLCLIENT
::oHeaderImg:ReadClientCoors()	

::oImgCabec := TBitmap():New(04,04,40,36,cResHead,NIL,.T.,::oHeaderImg,,,.F.,.F.,,,.F.,,.T.,,.F.)

If !Empty(::aHeaderTitle[::nPanel,1])
	@ 003,050 SAY ::oHeaderTitle VAR ::aHeaderTitle[::nPanel,1] OF ::oHeaderImg PIXEL SIZE 000,017 FONT oFontBoldHeader COLOR RGB(000,074,119)
	::oHeaderTitle:nWidth := ::oHeaderImg:nWidth - 050
	
	@ 012,050 SAY ::oHeaderMsg	VAR ::aHeaderTitle[::nPanel,2] OF ::oHeaderImg PIXEL SIZE 000,017 COLOR RGB(000,074,119)
	::oHeaderMsg:nWidth := ::oHeaderImg:nWidth - 050
	::oHeaderMsg:nHeight:= ::oHeaderImg:nHeight - 012
Else
	@ 005,050 SAY ::oHeaderMsg	VAR ::aHeaderTitle[::nPanel,2] OF ::oHeaderImg PIXEL SIZE 000,017 COLOR RGB(000,074,119)
	::oHeaderMsg:nWidth := ::oHeaderImg:nWidth - 050
	::oHeaderMsg:nHeight:= ::oHeaderImg:nHeight - 012
EndIf

nLeft := (::oPanBarrBt:nWidth/2)

@ 005, nLeft - 155 BUTTON ::oBack	 PROMPT "&Voltar"	SIZE 50,20 OF ::oPanBarrBt PIXEL ACTION If(Eval(::aCbValid[::nPanel,1]),(::nPanel-=1, ::Navigator(1),EVAL(::aCbExecute[::nPanel])),) 		
cEstilo := "QPushButton {"
cEstilo += "background:#dddddd;color:black;"
cEstilo += "background-image: url(rpo:"+"prev.png"+");background-repeat: none; margin: 2px;"
cEstilo += "}"
::oBack:SetCss(cEstilo)

@ 005, nLeft - 105 BUTTON ::oNext	 PROMPT "&Avançar"	SIZE 50,20 OF ::oPanBarrBt PIXEL ACTION If(Eval(::aCbValid[::nPanel,2]),(::nPanel+=1, ::Navigator(2),EVAL(::aCbExecute[::nPanel])),)
cEstilo := "QPushButton {"
cEstilo += "background:#4d7f9e;color:white;"		
cEstilo += "background-image: url(rpo:"+"next.png"+");background-repeat: none; margin: 2px;"
cEstilo += "}"
::oNext:SetCss(cEstilo)

@ 005, nLeft - 055 BUTTON ::oCancel PROMPT "&Cancelar"	SIZE 50,20 OF ::oPanBarrBt PIXEL ACTION ::oDlg:End()
cEstilo := "QPushButton {"
cEstilo += "background-image: url(rpo:"+"officebtnwindowsclicked.png"+");background-repeat: none; margin: 2px;"
cEstilo += "background:#dddddd;color:black;"		
cEstilo += "}"
::oCancel:SetCss(cEstilo)

@ 005, nLeft - 105 BUTTON ::oFinish PROMPT "&Finalizar"	SIZE 50,20 OF ::oPanBarrBt PIXEL ACTION If(Eval(::aCbValid[::nPanel,3]), ::Navigator(0),)
cEstilo := "QPushButton {"
cEstilo += "background-image: url(rpo:"+"officebtnwindowsclicked.png"+");background-repeat: none; margin: 2px;"
cEstilo += "background:#4d7f9e;color:white;"		
cEstilo += "}"
::oFinish:SetCss(cEstilo)

::oNext:Hide()
::oBack:Hide()

// Cria o painel de corpo
If ( lNoScroll )
	@ 000,000 MSPANEL ::oMPanel[1]	OF ::oPanPrinc SIZE 000,000 
	::oMPanel[1]:Align := CONTROL_ALIGN_ALLCLIENT
Else
	@ 000,000 SCROLLBOX ::oMPanel[1] SIZE 000,000 OF ::oPanPrinc
	::oMPanel[1]:Align := CONTROL_ALIGN_ALLCLIENT
EndIf
::oMPanel[1]:ReadClientCoors()
::oMPanel[1]:Hide()

If !Empty(cWelcome)
	@ 015, 015 SAY oMsgWelcome PROMPT "Bem-vindo..." OF ::oMPanel[1] PIXEL FONT oFontBoldWelcome

	@ 030, 015 GET oBodyText VAR cWelcome OF ::oMPanel[1] MULTILINE SIZE 260, 100 FONT oFontWelcome PIXEL WHEN .T.;
	READONLY DESIGN NOBORDER
	oBodyText:nWidth := ::oMPanel[1]:nWidth - 60
EndIf

Return

/*/{protheus.doc} Activate
*******************************************************************************************
Metodo de ativação da classe

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/

METHOD Activate( lCenter, bValid, bInit, bWhen ) CLASS InWizard
PARAMTYPE 0 VAR lCenter AS LOGICAL OPTIONAL DEFAULT .T.
PARAMTYPE 1 VAR bValid  AS BLOCK   OPTIONAL DEFAULT {|| .T. }
PARAMTYPE 2 VAR bInit	AS BLOCK   OPTIONAL DEFAULT {|| .T. }
PARAMTYPE 3 VAR bWhen   AS BLOCK   OPTIONAL DEFAULT {|| .T. }

::oMPanel[1]:Show()
::oDlg:Activate( ,,,lCenter, bValid,, bInit,, bWhen )

// Retira o Desfoque da janela anterior
FWDestroyTransparent(::oBackGround)

Return

/*/{protheus.doc} Navigator
*******************************************************************************************
Metodo de navegaÃ§aÃµ entre os paineis do wizard

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD Navigator( nOption ) CLASS InWizard
Local nI

DEFAULT nOption := 0

If ( nOption == 0 )
	::oDlg:End()
	Return
EndIf

For nI := 1 To Len(::oMPanel)
	If ( nI == ::nPanel )
		::oMPanel[nI]:Show()
		If ValType(::oHeaderTitle) == "O"
			::oHeaderTitle:SetText(::aHeaderTitle[nI,1])
		EndIf
		::oHeaderMsg:SetText(::aHeaderTitle[nI,2])
	Else
		::oMPanel[nI]:Hide()
	EndIf
Next nI

::RefreshButtons()
Return

/*/{protheus.doc} NewPanel
*******************************************************************************************
Metodo de criação de paineis no wizard

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD NewPanel( cTitleDlg, cMsg, bBack, bNext, bFinish, lPanel, bExecute ) CLASS InWizard

DEFAULT cTitleDlg   := "Titulo"
DEFAULT cMsg	 	:= "Mensagem"
DEFAULT bBack	 	:= {|| .T.}
DEFAULT bNext	 	:= {|| .T.}
DEFAULT bFinish	 	:= {|| .T.}
DEFAULT lPanel	 	:= .T.
DEFAULT bExecute 	:= {|| NIL }

// Cria o painel de corpo
Aadd( ::oMPanel, Nil )
::nTPanel += 1
If ( lPanel )
	@ 000,000 MSPANEL ::oMPanel[::nTPanel]	OF ::oPanPrinc SIZE 000,000	
Else
	@ 000,000 SCROLLBOX ::oMPanel[::nTPanel] SIZE 000,000 OF ::oPanPrinc
EndIf
::oMPanel[::nTPanel]:Align := CONTROL_ALIGN_ALLCLIENT
::oMPanel[::nTPanel]:ReadClientCoors()
::oMPanel[::nTPanel]:Hide()

Aadd( ::aCbValid,	{bBack,bNext,bFinish} )
Aadd( ::aHeaderTitle,	{cTitleDlg,cMsg} )
Aadd( ::aCbExecute,	bExecute )

::oFinish:Hide()
::oNext:Show()

Return

/*/{protheus.doc} GetPanel
*******************************************************************************************
Metodo de retorno do painel

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD GetPanel(nPanel) CLASS InWizard

DEFAULT nPanel := 0

If ( nPanel > 0 .And. nPanel <= ::nTPanel )
	Return ::oMPanel[nPanel]
EndIf
Return

/*/{protheus.doc} SetFinish
*******************************************************************************************
Metodo de finalização do objeto

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD SetFinish() CLASS InWizard
::oNext:Disable()
::oFinish:Show()
::oCancel:Show()
Return

/*/{protheus.doc} SetPanel
*******************************************************************************************
Metodo de setar o painel a exibir

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD SetPanel(nPanel,lExec) CLASS InWizard
Local nLastPanel := nPanel

DEFAULT lExec := .T.

If nPanel > 0 .and. nPanel <= Len(::oMPanel)
	::oMPanel[::nPanel]:Hide()
	::oMPanel[nPanel]:Show()
	If ValType(::oHeaderTitle) == "O"
		::oHeaderTitle:SetText(::aHeaderTitle[nPanel,1])
	EndIf
	::oHeaderMsg:SetText(::aHeaderTitle[nPanel,2])
	::nPanel := nPanel
	::RefreshButtons()
	EVAL(::aCbExecute[::nPanel])
EndIf
Return nLastPanel

/*/{protheus.doc} SetPanel
*******************************************************************************************
Metodo de atualização dos botões

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD RefreshButtons() CLASS InWizard

If ( ::nPanel == 1 .And. ::nPanel == ::nTPanel )
	::oBack:Hide()
	::oBack:Disable()
	::oNext:Disable()
	::oFinish:Show()
	::oCancel:Show()
	::oFinish:SetFocus()
ElseIf ( ::nPanel == 1 .And. ::nPanel < ::nTPanel )
	::oBack:Hide()
	::oBack:Disable()
	::oNext:Enable()
	::oFinish:Hide()
	::oCancel:Show()
	::oNext:SetFocus()
ElseIf ( ::nPanel > 1 .And. ::nPanel == ::nTPanel )
	::oBack:Show()
	::oBack:Enable()
	::oNext:Disable()
	::oFinish:Show()
	::oCancel:Show()
	::oFinish:SetFocus()
ElseIf ( ::nPanel > 1 .And. ::nPanel < ::nTPanel )
	::oBack:Show()
	::oBack:Enable()
	::oNext:Enable()
	::oFinish:Hide()
	::oCancel:Show()
	::oNext:SetFocus()
EndIf

Return

/*/{protheus.doc} DisableButtons
*******************************************************************************************
Metodo de desabilitação dos botões

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD DisableButtons() CLASS InWizard
::oBack:Disable()
::oNext:Disable()
::oFinish:Disable()
::oCancel:Disable()
Return

/*/{protheus.doc} EnableButtons
*******************************************************************************************
Metodo de habilitar dos botões

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD EnableButtons() CLASS InWizard
::oBack:Enable()
::oNext:Enable()
::oFinish:Enable()
::oCancel:Enable()
::RefreshButtons()
Return

/*/{protheus.doc} SetMessage
*******************************************************************************************
Metodo de setar as mensagens nos paineis

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD SetMessage(cMsg,nPanel,lChange) CLASS InWizard

DEFAULT nPanel := ::nPanel
DEFAULT lChange := .T.

If nPanel > 0 .and. nPanel <= Len(::oMPanel)
	If lChange
		::aHeaderTitle[nPanel,2] := cMsg
	EndIf
	::oHeaderMsg:SetText(cMsg)
EndIf

Return

/*/{protheus.doc} SetHeader
*******************************************************************************************
Metodo de setar as headers nos paineis

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
METHOD SetHeader(cHeader,nPanel,lChange) CLASS InWizard

DEFAULT nPanel := ::nPanel
DEFAULT lChange := .T.

If nPanel > 0 .and. nPanel <= Len(::oMPanel)
	If lChange
		::aHeaderTitle[nPanel,1] := cHeader
	EndIf
	If ValType(::oHeaderTitle) == "O"
		::oHeaderTitle:SetText(cHeader)
	EndIf
EndIf

Return

/*/{protheus.doc} _InWizard
*******************************************************************************************
Função de nome do fonte/metodo

@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Usuário
*******************************************************************************************
/*/
User Function _InWizard()
Return

/*/{protheus.doc} CriaMyTela
*******************************************************************************************
Cria uma tela no layout personalizado.
 
@author: Marcelo Celi Marques
@since: 25/07/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
METHOD CriaMyTela(oDlg, aCoords, cTitulo, lBotoes,bOk,bCancel) CLASS InWizard
Local oPanPrinc := NIL
Local oBmp      := NIL
Local oPanCent  := NIL
Local oPanCSup  := NIL
Local oPanCCen  := NIL
Local oPanCInf  := NIL
Local oButtOK   := NIL
Local oButtCanc := NIL
Local oFonte    := TFont():New("Verdana",,022,,.T.,,,,,.F.,.F.)
Local nX        := 1
Local oButSair	:= NIL
Local cLogoIntegr := "" //GetLogoIntg()

Default oDlg    := FWStyledDialog():New(aCoords[1],aCoords[2],aCoords[3],aCoords[4],"",{||})
Default aCoords := {0,0,500,700}
Default cTitulo := ""
Default lBotoes := .F.
Default bOk     := {|| oDlg:End()}
Default bCancel := {|| oDlg:End()}

//->> Painel principal
oPanPrinc := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,RGB(255,255,255),((oDlg:NCLIENTWIDTH)/2),((oDlg:NCLIENTHEIGHT)/2),.F.,.F. )
oPanPrinc:Align := CONTROL_ALIGN_ALLCLIENT
//->> Construção gráfica com imagem principal
oBmp := TBitmap():New(01,01,(oPanPrinc:NCLIENTWIDTH/2)-2,(oPanPrinc:NCLIENTHEIGHT/2)-2,"fwlgn_bg",NIL,.T.,oPanPrinc,,,.F.,.T.,,,.F.,,.T.,,.F.)
//->> Não usar align para esse painel
oPanCent := TPanel():New(13,10,'',oPanPrinc, oDlg:oFont, .T., .T.,,,((oPanPrinc:NCLIENTWIDTH)/2)-25,((oPanPrinc:NCLIENTHEIGHT)/2)-35,.T.,.F. )
//->> Paineis internos
If !Empty(::cTitulo_Barra)
    oPanCSup := TPanel():New(0,0,'',oPanCent, oDlg:oFont, .T., .T.,,,((oPanCent:NCLIENTWIDTH)/2),(20),.F.,.F. )
    oPanCSup:Align := CONTROL_ALIGN_TOP
EndIf
oPanCCen := TPanel():New(0,0,'',oPanCent, oDlg:oFont, .T., .T.,,,((oPanCent:NCLIENTWIDTH)/2),((oPanCent:NCLIENTHEIGHT)/2)-35-If(!Empty(::cTitulo_Barra),20,0),.F.,.F. )
oPanCCen:Align := CONTROL_ALIGN_ALLCLIENT
oPanCInf := TPanel():New(0,0,'',oPanCent, oDlg:oFont, .T., .T.,,,((oPanCent:NCLIENTWIDTH)/2),(35),.F.,.F. )
oPanCInf:Align := CONTROL_ALIGN_BOTTOM
//->> Imagens
If !Empty(::cTitulo_Barra)
    nVezes := Int((oPanCInf:NCLIENTWIDTH)/200)
    If nVezes < 1
        nVezes := 1
    EndIf
    For nX:=1 to nVezes
        TBitmap():New(00,(nX-1)*200,(oPanCInf:NCLIENTWIDTH/2)-2,(oPanCInf:NCLIENTHEIGHT/2)-2   ,"tafsmallapp_header_barra"     ,NIL,.T.,oPanCInf,,,.F.,.F.,,,.F.,,.T.,,.F.)        
    Next nX
EndIf

If !Empty(cLogoIntegr) .And. File(cLogoIntegr)
	::oImgRodape := TBitmap():New(00,00,(oPanCInf:NCLIENTWIDTH/2)-2,(oPanCInf:NCLIENTHEIGHT/2)-2    ,NIL  					          	  ,cLogoIntegr,.T.,oPanCInf,,,.F.,.F.,,,.F.,,.T.,,.F.)
Else
	If Empty(::cLogoRod)
		::oImgRodape := TBitmap():New(00,00,(oPanCInf:NCLIENTWIDTH/2)-2,(oPanCInf:NCLIENTHEIGHT/2)-2    ,"tafsmallapp_logo_totvs"         ,NIL,.T.,oPanCInf,,,.F.,.F.,,,.F.,,.T.,,.F.)
	Else
		::oImgRodape := TBitmap():New(00,00,(oPanCInf:NCLIENTWIDTH/2)-2,(oPanCInf:NCLIENTHEIGHT/2)-2    ,NIL  					          ,::cLogoRod,.T.,oPanCInf,,,.F.,.F.,,,.F.,,.T.,,.F.)
	EndIf
EndIf

If !Empty(::cTitulo_Barra)
    TBitmap():New(00,00,(oPanCSup:NCLIENTWIDTH/2),(oPanCSup:NCLIENTHEIGHT/2)        ,"officepainelprincipalblack"   ,NIL,.T.,oPanCSup,,,.F.,.T.,,,.F.,,.T.,,.F.)
    //->> Sombra do Texto
    TSay():New((04)-0.25 ,(05)-0.25  ,{|| ::cTitulo_Barra },oPanCSup,,oFonte,,,,.T.,Rgb(122,122,122),CLR_WHITE,(1000),(20) )
    //->> Texto Normal
    TSay():New((04)      ,(05)       ,{|| ::cTitulo_Barra },oPanCSup,,oFonte,,,,.T.,Rgb(255,255,255),CLR_WHITE,(1000),(20) )
EndIf

If lBotoes
    //->> Botão OK
    oButtOK := TButton():New(05,(oPanCInf:NCLIENTWIDTH/2)-55,"OK",oPanCInf,bOk,50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    cEstilo := "QPushButton {"
    cEstilo += " background-image: url(rpo:"+"officebtnwindowsclicked.png"+");background-repeat: none; margin: 2px;"
    cEstilo += "background:#027F9E;color:white;"		
    cEstilo += "}"
    oButtOK:SetCss(cEstilo)
    oButtOK:lActive := .T.
    //->> Botão Cancelar
    oButtCanc := TButton():New(05,(oPanCInf:NCLIENTWIDTH/2)-106,"Cancelar",oPanCInf,bCancel,50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    cEstilo := "QPushButton {"
    cEstilo += " background-image: url(rpo:"+"officebtnwindowsclicked.png"+");background-repeat: none; margin: 2px;"
    cEstilo += "background:#dddddd;color:black;"		
    cEstilo += "}"
    oButtCanc:SetCss(cEstilo)
    oButtCanc:lActive := .T.
EndIf

oButSair := TBtnBmp2():New(03,(oPanCSup:nWidth)-47,43,18,"fw_dp_button_close_hover",,,,{|| ::oDlg:End() },oPanCSup,"Fechar Aplicação",,.T. )

Return {oDlg,oPanCCen,oPanCInf}

/*/{protheus.doc} GetLogot()
*******************************************************************************************
Retorna o logotipo da operação/integração
 
@author: Marcelo Celi Marques
@since: 25/11/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetLogoIntg()
Local cEncode64  := ""
Local cPastLocal := ""
Local cPastDecod := ""
Local cLogoInteg := "tafsmallapp_logo_integra.png"

If !File("\system\"+cLogoInteg)
	cEnc64 := "I3ppcCIlAAAtJQAAeJwBIiXd2olQTkcNChoKAAAADUlIRFIAAADJAAAASggGAAAAEeJwcwAAAAFzUkdCAK7OHOkAAAAEZ0FNQQAAsY8L/GEFAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJTUUH3gIOEDgtMJmwUgAAJJJJREFUeF7tfQuYVdV1/+++ZoZ5M8MAgqCAiggBn1FRiSYmxtSa+K/WpqYxmr+mbZJa0+ZLzatf/FqTpl+T5sv/b5umaRptTRMSTUSjIAjyENCoCARfiIggAjPDMC9m5r66fnufNXffM+fce+cBKtwfrDl7r7322mvvs9Z+nHPvTOTyyy/PCkBEIhFzHQ4iEVuXsHqiJj0yXRGjI79uxruGwbancOuqLlfnUP2FMRxZYmg7he2PRGJeKgy2PnVRpz9t+58/Bi4GZbM5mcGqgqzbPZGxel19ypPiwa5YntU9VL+06l2BdF4DQ6G6CTte+Yh5/uXK5SEb9xLB9Ysh41Rh/ajXjOpatuIeOxpkkGhIqDEhsINkSQd3JMaGIRuhzmCyZUMx3D6MBmFt5cZgqN0u6Zi"
	cEnc64 += "H2xxUR8eaVBiDeiNusJLHNn0BPCjDqyUjwvZMmzlo/9R3TF2vPvUq5VtuKSI2aZpBoBSV9kguL9+3hpK2r/YMG5HUIGWRzE9nhQRsaRAjaUzl/fXCb3pxaF1eZZxCEVRm6oTYRAzlBQ18bJCKIRrN3SgFbVAqFUG2unB1DZW1zhkEtS9/pidk1oxKH0WtJZEzMi7JLK0CPqg9WU7FrAsZK7laNu2zZEONK0p2kLJiD8PBrjL+Nu0kMBgctKkApcWdlWjKcCkeiRuKef9cGzKmD5Zj4N6E/JtrK4XR4GDl1afyYPnhUzEMrTM4wCFl+Ty9jWHkyg6l/LHKRzHHt1A9YWMWjkJtK/wyNm/tsmktl5lffrrbZzftD5TBvuWtUMEoZKddO8KpEPzjW8p4+MEg10B3iUFvAl9grPArz2/c7zT5xIFUsjzC8l254ZDWHYkOtYWUzaYDZfJpKDgeSsF1XMrJK0Y3fsEUVG55RGFnCrdNyiTP+DQxyrwjy7RfXpEnx3ncy1OcdZQsL5dXntrPe6Tk75+RiaYNudsid0vEM4QS3drNl0K6CpEYKwrXVjO6ymBH3c6XAp21czOh1TdWKJ"
	cEnc64 += "9JguroWJMKY1Bv+UwSDF/Q5aW9M0lk6+adZhTZSNCNst05OnBt0E4P5n2m+e7ZEPjrHynYXXc4io5fpshsHR1a5soX7x/tG809VMdXO0vXZeSlf6EwgWW3NCO5T9R/pO6v+tvc+dO8HsseLHBfFnLzjhZGOnCKIzWALhgEhagoJAh0ovaTBoj/PgyvXyXYUBCsT1+wh9qhPpHbMpq0R0ybLRT74NGQPoo+9qVQfwr54FjcX5qtpHDThKx8R8GTyngHY7QrzbsXdP1SFoJIf39/OUje5Sg2z5U6D5Yi58qEOdlw9Ph1+OsG6XJ59rxC2G2hIscPR5Buv56mpqbjdAo5rpA73BZDqTIqV4p8MRTV4W05Cd2mDULKcvXttjBHI8VQPWOwkozGoDL8M9dIMHRGDLonuXZy8jaAbD7YjvwZeahM2IwdPEvnUKjcLTMpLz/IdfJsvVRdfhQs867NTY1lDz8WQEcf6axeyFGGQmdXl4JRzKbh2OvK5gWQpMPs1zKWFqIg+PnhvSzjXQHXSXLOxBlfSZG71cEOWtjpR4pSAoXXQnIuVNZPhOv4yhsLlLDdKjZwwcv00cORtm+0jnN0x"
	cEnc64 += "2fozBpkf5BN9nFsPvh4N/cuwl7z9WX1BWSh9yGCobotgrZrrixTKpHx+G7eXzaIkPZchNmkYGl5u3WMwZ1VC6PU2y6BY4JAicil81zMOWCPFv4+0JmLObQfY7GSqAZZSZLDa32YYOf05g23o6NFoTZ1EEdvkzpPGN7elaiU/mUytg1+Ypjg7J4/dl5QDNGlfStUnm9/kIzytM2hMvn1/PIKf70gPS7clciFW+uorCTqjISbHisU0llokFhWbBCPhL3vRDA4NEAIvinPZFKSooPnnJzjkT8mpZSXDr0fQeOuut02it2/UhDUlh+R9vb2UbWk37mwn+IcOcZSzzvJFuKd0CcXatfAwAAqKxNClSZPp6PTcGVxgyYMxZw0qHwoz7ZTiuxo836wlCESJkdu+UxSBmS7jb6+AUnlVhO9Dp1lyc+5zPDLxw507LHQXyiMVHukra2tcLiVcUyCDpZMpgcdraqqChUVue+L6+zK8txMqwGQv40qvdwiP2/r+GWIIB6h/MJ6w+srtJRyYeHWVF5Jjm+4n949fLhHVpQ+WyBwt1u5GTv/DKIoVu5HTj6HIJ4fdOZiju9HKXqLIdLa2jq8"
	cEnc64 += "Vss4JkDn4dlDHc/MpsLjiqJnlCAUc9Kw8iC+5eWCMVzGgmmSOr5fPigfJku4nKBQYh2uJJEDBw4MrV3GMQ+uFOlsxnx3gsGiQUOMG1fjC5T81SHncMW2VyzPlfkdlXn7UMLy/eVEUB1FoTKC+ZEGiZY1jW8ob7eOVxgH8jyBAUNnisVihgYG+sz2K/dEje8y8t2I8rbcDRC6k/vFrPzgyfEtNM+rnxT+dCl55YWVDZY75IfLk5WkfHA/PjF09lfn0UfAiURCtl/VpozyLNcyV54ImqmJ4vzg7VZYmgjSWSrPj2Iy42UlKW+3yjDOHuaIFRUVsv0aZ9LpdNqsNLo982O4jmrLgoOEcPOFylyUKkdo0BeCCZJiB/fm5mYvVca7HW1tbV6KzkMnD15NNGjUgdzDvK4kOTCd05PvlLmyMGd1t3F+mUL5MH2ElhULglKDxO1tGcc46DxK1nnt7VcenUbzhJ5V+vv7DSlPofIuyAvjjyUK6dMy7ZOSH/7yIBlCesxOF6IyjhWEOYQ/70LLGCSHDx8OkCs0E+eXBbXj5v3lQXm9uukgBPG1XlgdwpVRuai+UAqjMo4d6IqhK4VCnSG"
	cEnc64 += "fn5sklZ9MJtHb22vktY6bdhHGJ/z8oLzLc/N+vnsdDlydxfD2LxWBcUimLRgs9t3Y4cOtX6ouyoXJlqLDq2//OzVyKQt/vhDyNQXng6GOYZ2DWykrq0Gg2yt1C+a5Z2c5+bymUqnBrZcbVFYvPzhZmkvZdnKw9Ut3drftMKjOML2G78iEyR3BIGEnLLFDhjK8poWVMV9ky5hfI8nfA2t/kZmUmhqESZnqGfPSi2OSzaakTtqQFfSkvbT5tZ1m8EiUkav5z+f5Ka+MHwFnmln+kDpmV8D6lig3qMvhmbT5p789llD7bdooM3XYR32jrTzKEHYMmDd1jQ7hcVBMnv9oFw2jzqSUWz2WKGdUWj5V8gfHl7pMoccLA38RrsB1EKPX8HhlO2kTKCSWUYZBw4+vuFsvrWf6bgdTymzAqO5w2Drm/nMMnLzqUrh6VG8YKTQdVGb65KUVfhniKKwkboP8pcTiPNzKyQ2VIURKDE3ROSjnPekwX/rhb5EURCJpIxuRm5rJRJDmd8Rk7Dh8Ei7UaORYN8ubazpIkpskeWlNcrxhCa8sLrIxr57cCP4+YdOUM4jmKkyPlGf45h9/NXNciO"
	cEnc64 += "CfaKCMTRtlXv20OEpa0uwWdeS+vMc/aWDrmHZMXyVjLhwV/pOMOSRb261t0j+R5a213xjkBxStPP+bX7Fj+sdxIAkvD9RnKSLB5ofppwMNDPewTpDPFcV+1isXRArW8Tu5td+SwsrZem6Ztqt5vRIu34Wfp3J+u/SqFAa3vOj3ScaPH++lRg5rqAyYXPlbzKVZ4zAD6TRWrN2Ns+dNwqRm76WV8CMmWOjG4gT8J87Wm0xj/VO7Mfe0ZkyeILIiQmcxt4/qRS9n0O2v7cGu19vlxmUxf/5JaGqsx3ObduDgIdkiyCw4aVId5p1xslSwM/L2HW9h5xutqKyIY96cadj9ZisOtPYipo4hF+rlL3mmcSmxY8qU8Zg0sRG/2/q6aBEBa669SiI1kMT0ac049ZSptl40hkNd3Vi19iX8dtPL6OruwuQTWnDJeafjovNPNxXZRmdXDzY9/5qsnOJ4VCaOzn5WJOKYNnU8pk+dyAbEbhvcMq/jQFsXtmzZJbETg4jhrPfMQF1dhWhjeb5zy732UiZMOAJejjpzaRf6yDeonLyKiirzHoUBzMDhe5QwXQp/eZhuC9uHwjL5COMr3HIGg"
	cEnc64 += "l/ezTc01B2dIJFmTcNsOyKrQURu5oDMZA8ubxMH7sDnbp6OE5qr5I7IkmsimDfFOjH/0ExfJoUHHmnDqzuT+L83TMbkRs8r+afAJMlwoptx1r3jzv/At/7uEaAqhZUPfRWXLjoHF3/kb7Bu1U4pTmDmzHF4dMmdOHX6ZGPZX/zND/H97zyG+kkV+MU9t+Gfvvsgli7ZBlSK7kQMsSo6gGzQ+g6L0RLo/V24/pOX4VO3fBgf+eidYm+j7IakjN/JYOQzuHrbcdOffwj/8f+/YNp4fsur+MLf3ofHV70ssuLgiUrgcAa1jVF8+sYL8HdfvxG11VV4ZtNLuOyKv0XXQLWMhfSnv1NqJ1ApgT5zRg3+9Kb34bO3/D5iZqKxzvOVb96Lu+5cIv2tFU4PfnT3rfjUxz9gxtIuXblAaW1t9VI5+D9u4ls0zD0IciTyGECcwOwLx0ojoy8cFWH1CT8vWMbO6FpWSh2FlrE+MZy6ivp6GVcqKEQjhxhAI4SsLZ7OmLi0OMAjq9uw6qkKxOLj5cZ47XCLIA7PugwW8tPpDB5+vANrn60Qf6kTgynDWVBmrEF5wupIiLOgvgVV9ROlLdli"
	cEnc64 += "Capq6oXXhJqWqdixO4sf/HiZ4RNxCQI0TBIfm4hoPIFzzp6Bsy8/HRd/aA7mnHkSKqvrUFnTjDkLZmLRFfNw1kVzcOb8E1EhgTyutgGJcdWYNXcqLr1yHha+/3RceNlsnHnxXMw+fYrRv2tvG2697Yd4/LFdaJrQgL/4/O/hO3fegMuuPAPdqXH43vfX4P/98DdGtkLar6ydgFhtPWacNhWLPjwf7104E1UyU7/wWgp3fH0x1q7bLJLWk3sP92HpcgnoRqlT14BMtAGPPb4VKXFUGyD598+9r0oMCpf8cGUJ17EsL4Nksn/wY/a5lUTWKgkgrRcEf1khWYLlfhmucsr3l/l5fjle/fW1zMURCRIOkjmIcc8v4yU5SXH/LEMqjv3Q2gN4Yn2FOGWDODI3BTrwcpdk5uCfDOP9SspMtWRlG9Y9XSmLQINsgYRv9uLSMZGjXluV0vYOmxVFZBhGHsuApwiJOAnKevz0f57ClhdfN/wo9+YRPhBIin1RfONrn8TjD9yBZYvvwO23fADJvm6k+7vxpc9ejmW/+BJWPvoN/NVt1+JwT5/YEEfyUDtu/eRCrPzV17Bmydex5sGvYcO"
	cEnc64 += "qb+H2P/sDo/8n963EU8/sRbwmijtuvwLfu+sG3P65y/GTu2/GvNmyokQzeOBXa8ThD8t2iX+QTMaq6xCu/tBsrPjlV/DYr+/AzX9yFmIyJr2d3E7m3pqvWv8SXtreifpxCVxwzixEKmJYs+FV4e2R0uAtUjEE3f+hgTEU/CowA4Xl6nj+ekougvIuT9Pu1SV/H/3lYdDyoDHy13fcaCxhG6YT86DOFT3GLZTwHlvTLjdX9tyxOsRltsvyYO7J85DNEOAfb0nJduE3Kzux+mk5IFdUmz9jYZZeOrvI8yfTdu+d6yjbMiuSCSYL8jKyIk2YPA7TTxyHN3d3yOz9qClj4FGT1SDH3lgcDbW1GFdZKRQXe0wvUFMhs3wiIWU14sxxwzM1xLH372vHthd2YOu2V7F166t4+YVdSPYn0d/Xj/Ubd8hyVYmpJ4zDx6+5xNRhT6dNbsHPfvQF/Pr+v8Tff+MTSMjWLplOyUFfioUSVXFjS12djFO8AumBXlllEph2ov2YENtfumoTutu7cerJdfjMJxegoTqKN97oxpqNrxgZO1bDg+sgrqMoNK/Oxbym+R6lp6fHpNnHUhHUlstz+Y"
	cEnc64 += "S/LIgUQWUkRaEyxREKEgWdj8+C7Jlh+bpWoYQcMidIkLBpuqA6KGWi5sCcEa9+eHUHVj8lARBvlDOqt8c126scpEv8YVIKwzMac7Jm1elPYebJ9fiDq05DRGbenz+wBc88/yqqayukXKzIShuefg2AtKxkBDVqWmF7lkFlfTPuve9ZfOQP/xlX/pHQdd/BVdf/A9Y8u808bHjzLTlXiP1TpjShoUa2jFJv9Yat+MFPHsGmrTvQ3d0njsWtiljOGVjK43W1eOiRLbjuhu/jiqv/QWTXYdKJNbjzq1dj0cK5pv19Bw5hxcrfSbUMLrrwNFzze+/FGXNaZBgjWPzgRqTM4Z7NcVWn7VmzFSJxplcq5iDFyjks3FbxfELimST3DUeeWYbWK6QviEeE1QniEcVkg8oVWqblY77dcpevbFacnsu+pJevO4DfPBlFMiZOL0cFPsI0sz4fadrp37THdwu/kQB5YmNC5OTQJNsx+i63Rd6j/XwE8XxMs/WSn4fbu3DjHy/CgnlT0LG/D3f/21LxKdn2SRs2QPzKbP+Dm40gRXuFsnKWQIVsneRAHuFVVpcoV045e2VkdeCTinRKnNVbt"
	cEnc64 += "e79+Ub86S0/wk23/Tdu/PP78JWv34cumYFjskLFRaRCBuj1nW34xZL1csbYjC6Js1OmTcO111yMqkoGGrDx2Vfwyo6DciZqwJ43DuHn923AQL84flUFtmzbh+e2cDvpTUDebeS98W8v3IAhFYL6g+sftooNBq3Pl40aKEFtEspzdSnyebx3+aTvcSxZ5NfJIYjvT4eR9qfwqIwKMui8SdKh5esP4pF1MlNHG2XrIEduzmzST26VokgJsbPWlZeu7cCKDWKWnB0iZrXhOYSzonVIP8jhhigHpsl1BsKcjTIY6Evj5Gkt+PxNlyJamcLDK7Zjw8a9so3iJ1y1XmlgkFB6oLMNn/rEeVhx/xfx+OK/lvPMF7Hs/i9j0bnzUCHbyQlN1abtvXvb0d1r31SfMWsCLrlsDqZMbpYZXwIrWmVWM8YQN5z9Xd245uqz8OTyr+Jb37wWjXXAujUv4K5//KWpT/zswfVIpWISm5X45eL1+PRN/4TfbnwNFdW1aNvfhUeXP2PkzA2XEWbf3GBQ8sPvKC4vDCyjLl41KNwzCvN+HW5aEcZzSeHnKwWVBcEv45JCA1n6NnTgXAqG65TMcYNi"
	cEnc64 += "Hd/kxCkY7XwBuHxjKx5dE0NatlgJcZooVw2uHjSIwSI3Ly4zOTUsW9uJx56My0GhXrZdNFZI9HAjlpE64WDD1CUpI0cS3qCZ3ErJlkmCLTmQxHUfuwgLz5tm3oes37hTzOEN9kQFfExtwT5J+3K4zgoZeANHeTOhyT78hAm1mHXSRMw+ZYrQVMyeNc38PquaumrMPWMK0NeLfe2H8bP715i6t3/2Gtz349vQJGcI2QeKeZwuBLK6sum0rD7TTmzAhe89A1/6/Mcw5zTZRsUqZHXYi0NdvdgrZ6CnfvummBLHyScmcOttH8Snv/gx3HjThbKlS4nVVVix6iV09trzAbdEfHQS5BB+UidXKgWuLH0mLisikfJeOOojYcqwDUKvfri2BMkMLed9yZHxO4eCeH4qpIMY9XbLDI7sfyN8msUkGzL1oli5Qc4gq3njG2wg8GzAIiGeE8yLNhm/AcmvkNVmxTqpywM9x9TYZ/WQqNKzOQ+GNSgrSabTsr2Rq7FFeXzLnonKDJeUw3A1bvn0B+Rm9mJA6iVFzn6ExMpb+2W4aG9GDulpPtY0LGu/SUgzckk0tODuH2/Epdd8ExdedZe"
	cEnc64 += "hM9/3ZXz5znuMRZ+47hJMnFQlq1gF7vruUnzlrv/Gv/7XCtz8uX/Btu3tiI+rlnao3G5LTVLsPCxnKIsI5s+fJsUxvLlPgu1AJ1Zv3IYdr7ZKURo33bAQP/jWTfj3b9+M//zerXjfQpEVJU9tegObfrfL02A0D95TdWp1bBf+SdJPeq7Rs43fV1Sv8lISKFxVtD6hV8Ktr+SiUBkx3PJSZZSIqDtgQRQMbcjcUXNTyOHWigsAaeVT7Xh0tawgaBFn5ILPF4UiT51caeTCfbtsorFsYz8eW0ffrjNbLPPGPSgiAhCR2dd8tENtSnUBh2WW7RUn4vsCQbr/ENC7B5n+dhM8xLW/fyHef8kM9LfvBHraRP6gmOUFldd2Ji376r59Ur5PAsX7c8Ve4GVSku/bj0iyFa+9tAtPLN+MDauF1mzG86ufw++27TSS5587G9/+++swtSWDA+Lkd317Kf7sM/fKmWIX/s9H56EuexDJ7g4ZSQlpmWgy/WJ371vIDnSbdogFcyfJRn8P9u/eKWeUJ7HkoXXIdrejqaobV7z/bE/K2nflpe8Ru96S81cbFi+274MisgraLZeF39Fd8jtJEI"
	cEnc64 += "9Q3wiqyzKV49X9PoryCTftgnwlP9yy4ZIiqCyMjHxPT09Bb6yulj11KBhIntPINocv+rhErXm6HQ8+EcFAthmxRJa7CeNcGb4hZ9pEiMyUmRh6e9NyPkgjIdsJ+jq3S3E58GbNdiuHpBx8JzV24tbrx6G53pz8qVRA8yUhdvBx87YXd+HlV3ab1ejCc+eiZeJ4rF2/GW/t70BjQ41ss+ZLn/g5rii279iNLZu3y04mYVa6c86ejYktTZ6NwGu79uD5za8aBzvzzNMwnY9fTVkce/a24tnnXjSCfDJmrJD2acrAQBpTpzTj3LNPQ4zPrkVm6ws75JywFdtf3otEVRU++MH34LyzT8Jzz7wobcfwvkVnytYkidVPbkayL4VZsnVbMHeWaI1if1sbnty4VcYrihMmNcghvw9d3QNoaKzGwvPnojJuD/Mcv7a2Dmz47YvilEmMb6zBoosXmEmLE0lXlz6eDYd/YqSj+Hlunmk3P+hYcuXTLk1Thm/m+Q1HplUuCK6+YigmW6quMDl+K3OEQcIqtpNWuVXBjj/xTCseWSkBkmlC1PiyBAk/iiLOz729qWccPC376yy6u7NoaYmhS"
	cEnc64 += "lYQM5uynKuDM/MR/iAxT8SMCVzFeBMYhCk5y1iHIchLZ5LihOQZYVkd7EMAQiY//jRpgi9AucWSPajI2NVRy+1MnzIBYdoUz/Pb6Ec6MyCSMcSNvsKyWX6MRDD4uFvATxuY+SQeXjfDTzTLdtAICvx9Sqc5g/MJXhY93b2WOQzw/pJcp3YdSsuJIMd3y0g8rzBYmHb1hKEUGRfDkS9FlkFdwpnEVWTd2CgXf6cTkiOSIgus3dSKh1bJao/xsjKIC0lgMDh4LLU+zY8DSh1Jd3ZHZGaz9egWMmSm3ILtDgXrKVwJWmjshZwf+H6AdvFzYMKJSKRae8VSOqJZ1qS2EG0XNzIabD0bIOSahwuSN3VYZrTxk7/2H4XMmccMtEteH4QflRWHdjHkzdcETDnB85scsGWmpW1GBZ1cyH5Kweox4y+DY1ZrI2fr2byICM8ELbdTZhWTtmiz1DUysgWLSdDZj/2I1VI+GlJoXp3ML8Otl1umIC8lZxQS4dZz5Vz4ZfzkR5AMKQhBcn4iCk9vLsxNItHJeUPkKjfUPF4VXU8+24aHVySRlBWE2wc+peEqIk2xstkKMceA6e6RVaSbee5j"
	cEnc64 += "WcpyucHmsz5UxzpF4IlQ1ibFwc2+mLOqXOkcooxv+s2ZhTM/eeLo5JPsR+htiJrPGXn7alNGO3jlzM4yqWn4Ro/VSZ4RlFSOvCE1OuSgKzRYz5QT7KfY4bVHFcwboj1GJ/f5tMWz38jZejYvIoZHGU+fSbMVr475egDlKa5tF4a+FFQi1FmsrZYI/+Gd/uFeVU7BPHW6ZxQXWsfVWQwqN9bkwrujhWAr2HnB/uSMyzXBOlMEG57rwJIVshdPT5IVRDrImUxleZUAYUNcVTolODq7ODNzIDwZn1FlHBkEOYAfKlNIVlcJvYbJM0+Hd4OJV4KrCZ96kWcnX/WXYL1hVCqC6vrJhcsTmzljhdMgHB1Zc8bgLBPHhuc7cf/jafRiArIJynO9YBCw81LJdNiuIF1ySO8yK4jMcJIfHBZJ5IaojCMF1yFcJxguStETxFOoX/EjLAwUgjy/PjdwwuDWKUSlIKyeEwWFYcWlovzjF5q4fVj/fCseXJ6SLRbfpHOJ9YhPsQykk2xIgqVLtlgdckjPyh7aaqGcJ1bGOwbuBOk6rsJ1ILfMnf390DL/CsE8PxTJYFH49ahsGJWKoLqFyEU"
	cEnc64 += "JQSJGi+H2++mSNUqiWL+lA79akcbhbBOqZN9unmBlRJ134DUbMu9M0i0rSGeXrCDmS1I0wAYIUyy3Vwd2nHJgnvJmZbIsc7A1BlmGHVxZ3ZRFm7nt4xmKaZbzv+HLacocglkmV+mbwoipvOmzV5//PL5Lpk0Dycs/04ijz8LqMGVvI3I25+B3jiBy5YJAvj+oCqUJtYM8ria6ojDvlhWD6i2FhgO3TtEgsebyp3lGJc4cxcYt7ViytB996RZEY3GzuaKX289giSw//u410MkVpEvcVQJE7aQWkj2siwsZEkeiMwkxLZ7LN52WrLQhtUWkjC6bJ+xslBYHTfHv/YlO2sqAZrumbXOlLh7oedhlUEtOVkX+qpyOQ4c8Oe/JkvAZzWbATGUvLcQXjww0PkNLyf7aPk3il8TEDtYT8OP+1jrmhzro0YbaPlxoPT+5cHn+MoXLZ1qDh+PCMSS5fFd+LKA6h0OmXl9fX8E7l6jgLyGQBP2WW6zNh/DrpUn0JZuBCulMlB9JkaunhVdO+NKEOYMc6qQD2Zd3dPY8p5Gf0WgGk5qj/KasgUpYlzOKyMRAKosTxh/CZz5ejRZ9T0JQxD"
	cEnc64 += "SYRUdHFx5etgrd3Yex8IKzMGP6idi95y3MmDENvX392PfmXkw9capZOfa3tqJ5fCOqqschk05i06YXsXdfK0499STMnDkdnaKL30GZOKUF+986gF27dmPGzBnCS0kMRDHlhIk41N2Ne+/5FZqbGjBn7kxsev4FCbZ+LJg/R/QfxI4dr+OM00/FZYvOR1VVhXEGHfi3A+4nc4cDv7z2gXylMFBWy/1pQvO8ksd3KHyXouWlopANo4EJ2GJBUlnBR5JccKJ4aed+PLyiE90DE1GRYIf16YSeQQjO3zykD6BdAiRjziAkTrAMAW1O1gWZfflB34kTEmAz0lVD9Hn7AUjLIfgycUL9YfzRVU1orq8wBUaXGUuuDlHcc+8vcfrpszBr1gxsf/V1bN/+Ovplz9sycSJaxWnf3LMHp5xyMrp7ekVfEpWxCC5YeB52vfEGdu/aj2i8AgcPHhInn42dr+2UPlZiXHUN9r61F3U1NZg3by5efGk7uro6ccMfX41UOot//u6/473nz8OsU07Bww+tRF19LZqax0t7Hejp6ULtuFpcf+2HMF4CSR3h7YIGyXBBu5UI9sHe9xwvDNpft66/D"
	cEnc64 += "vPuuOgLxyOJYnYrTJD09/cXlI4n+OxeOiHO3tHVi4F0TJyJLqnVvEHQPDsrXp5MyVZEWFwNtPu86gJgpDk48i8hAccwNKsRA0lkzOrgwfRHfmQkkOqrY+YbjbaGyIkYN18MxLt/cB8uOHcB5oqTb3hqM7a98DL+8Pqr8W//uhgtk2txzjkL8MzTm1ArjnzwYDda9+3DVR/9MF55eRfaDrSiobEOtbW14kyHJbAmoKlxPH760wdwxZWLkE1lZFXskRWiA/v27cen/uSjqK9rwL3/9YDouEwGM4Zlj6w3wXfyySegrb3L/AaWRRctwORJE8RS3R5au98OjCRI1JlKcapSHa8YGDAaKIV0sswNrrGEq7dokCQS3ueCzEtDVtSbzGqqyG6OctC0q9otV6gOlQuScSFbNznA2Hc0Xh2xyYZhFrt278OGp7cgJsvTzBlTZTbvQntrG6ZPm4JYZURWrGbZNr2JzkPdEvA95s8P9/T0m887zRTHNjdEutfc3ITXduxCPJbA+An1qKmulMCsxIG2drz++psyJpW48ooLUSury/8sfhjTpk82W64e2eadcspJePnl19Df34f588/A5JZm"
	cEnc64 += "0cvxsfaal51vE/QFnut4fifTF4iFwDrU4Xdgf3400EAhcTZX3dr20QLbKxokuWWPYmFOXKhsLCHtmGXGJoOa5Faqv3/ABAAHs022WRP4oUUB8+x0ciCFLjlP8O/hdXR0gl8lrq2tloNjWpwkjUQ8AX6knvm6uprBAyVfinV2dpmbVlNTbXjt7YfkDNSNxsZ6VMv5hjc1meTHLrISZLIKm0P80Rqfwgh6yz0c+J1zLJy1kA4dc44p0yrL9NEC24oMDAwU7Cn/2lEZxwY0SIbjZHTMUoNhpEGj9oQFga4oBGVc+WJ9GalNCuovB8lxBH0XMVz4HW20jufC7/REUN4NlCMJf9/Y9tt3iizjXQN1WgXzytO0X6ZUuPWC9Gie75/cN/NHCmqDa0vRlaSM4xthq4bLpzOFyY0UqpOkzkroGeVoIpJM8te0l3EsY7QO7K+vedd5idG248IfeMzzyRuvDBIGy9FCeSU5juF3xEIYywBw4Q80P8LK/fxS5fwoVk6UV5IyDEoJgiMVKCPB0bKFX98tB8lxjneS4wdhOPYdib6Ug6SMQBwLgaPbqNH2xfzSinKQlFEK3umBE4YxCZJUKlU"
	cEnc64 += "OkjLeVUFwNG3ly/RykJRREt5tK8lY2VsOkjLe8eDZQh3+7QhUvpOJpNP623HLOB7xblshjjb40rIcJGW8K3G0gjsWi+F/ARJkrGra13LQAAAAAElFTkSuQmCCam7BAA=="

	cPastLocal := GetTempPath()
    cPastLocal := Alltrim(cPastLocal)
    cPastLocal += If(Right(cPastLocal,1)=="\","","\")
    cPastDecod := StrTran(cPastLocal,"\","\\")

    If File(cPastLocal+cLogoInteg)
        FErase(cPastLocal+cLogoInteg)
    EndIf
    Decode64(cEncode64,cPastDecod + cLogoInteg,.F.)
    CpyT2S(cPastLocal+cLogoInteg,"\system")
EndIf

Return "\system\"+cLogoInteg


