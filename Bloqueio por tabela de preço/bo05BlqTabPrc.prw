#include 'totvs.ch'

/*/{protheus.doc} bo05BlqTabPrc
*******************************************************************************************
Classe de Bloqueio de Tabelas de Preços
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Objeto
*******************************************************************************************
/*/
Class bo05BlqTabPrc
    data cProduto
    data cDescricao
    data cErro
    data aCols
    data aHeader
    data cImgSelec   
    data cImgNoSelec 
    data oTabela
    data nPOSITEM
    data nCorItem

    Method New(cProduto) constructor
    Method SetProduto(cProduto)
    Method GetProduto()
    Method ValidProduto()
    Method TelaBloqueio()
    Method MyEnchoice()
    Method BarraBotoes()
    Method GETDCLR()
    Method MarcDesmarc()
    Method Salvar()
    Method Destroy()
        
EndClass

/*/{protheus.doc} bo05BlqTabPrc
*******************************************************************************************
Método construtor do objeto bo05BlqTabPrc
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method New(cProduto) class bo05BlqTabPrc
Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aAreaDA0  := DA0->(GetArea())
Local aAreaDA1  := DA1->(GetArea())
Local _cFilAnt  := cFilAnt

Default cProduto := ""

SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt + cFilAnt))

Self:cImgSelec   := "CHECKED"
Self:cImgNoSelec := "NOCHECKED"
Self:cDescricao  := ""
Self:cErro       := ""
Self:aCols       := {}
Self:aHeader     := {}
Self:nPOSITEM    := 0
Self:nCorItem    := Rgb(255,201,14)

Self:SetProduto(cProduto)
If Self:ValidProduto()
    Self:TelaBloqueio()
Else
    MsgAlert(Self:cErro)
EndIf
Self:Destroy()

cFilAnt := _cFilAnt
DA1->(RestArea(aAreaDA1))
DA0->(RestArea(aAreaDA0))
SB1->(RestArea(aAreaSB1))
RestArea(aArea)

Return self

/*/{protheus.doc} SetProduto
*******************************************************************************************
Método para setar o produto no objeto bo05BlqTabPrc
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method SetProduto(cProduto) class bo05BlqTabPrc
If !Valtype(cProduto)=="C"
    cProduto := ""
EndIf
cProduto := PadR(cProduto,Tamsx3("B1_COD")[01])
Self:cProduto := cProduto
Return

/*/{protheus.doc} GetProduto
*******************************************************************************************
Método para retornar o produto do objeto bo05BlqTabPrc
 
@author: Marcelo Celi Marques
@since: 30/05/2021

@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method GetProduto() class bo05BlqTabPrc
Return Self:cProduto

/*/{protheus.doc} ValidProduto
*******************************************************************************************
Método para validar o produto do objeto bo05BlqTabPrc
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method ValidProduto() class bo05BlqTabPrc
Local lRet      := .F.
Local lInativo  := .F.
Local nInativad := 0

Self:aCols      := {}
Self:aHeader    := {}
Self:cDescricao := ""

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+Self:GetProduto()))
    Self:cDescricao := Alltrim(SB1->B1_DESC)
    If SB1->B1_MSBLQL == "1"
        Self:cErro := "Produto bloqueado para uso"
        lRet := .F.
    Else
        DA1->(dbSetOrder(2))
        DA1->(dbSeek(xFilial("DA1")+SB1->B1_COD))
        Do While DA1->(!Eof()) .And. DA1->(DA1_FILIAL+DA1_CODPROD) == xFilial("DA1")+SB1->B1_COD
            //->> Marcelo Celi - 14/09/2022
            If Posicione("DA0",1,xFilial("DA0")+DA1->DA1_CODTAB,"DA0_ATIVO") == "1"
                If DA0->(dbSeek(xFilial("DA0")+DA1->DA1_CODTAB)) .And. Posicione("DA0",1,xFilial("DA0")+DA1->DA1_CODTAB,"DA0_ATIVO") == "1"
                    //->> Marcelo Celi - 08/09/2022
                    //lInativo := Dtos(DA0->DA0_DATATE) < Dtos(dDataBase) .And. !Empty(Dtos(DA0->DA0_DATATE))
                    
                    //->> Marcelo Celi - 14/09/2022
                    lInativo := !Empty(Dtos(DA0->DA0_DATATE)) .And. Dtos(dDataBase) > Dtos(DA0->DA0_DATATE)

                    If !lInativo                
                        aAdd(Self:aCols,{If(DA1->DA1_ATIVO=="1",LoadBitmap( GetResources(), Self:cImgSelec ),LoadBitmap( GetResources(), Self:cImgNoSelec )),;     // 01 - Icone de Seleção
                                            DA0->DA0_CODTAB,           ;                                                                                           // 02 - Codigo da Tabela
                                            Alltrim(DA0->DA0_DESCRI),  ;                                                                                           // 03 - Descrição da Tabela
                                            DA0->DA0_DATDE,            ;                                                                                           // 04 - Vigencia de
                                            DA0->DA0_DATATE,           ;                                                                                           // 05 - Vigencia até
                                            DA1->DA1_PRCVEN,           ;                                                                                           // 06 - Preço de Venda
                                            DA1->(Recno()),            ;                                                                                           // 07 - Recno da tabela DA1
                                            .F.}                       )                                                                                           // 08 - Se item deletdo no aCols
                    Else
                        nInativad++
                    EndIf
                EndIf
            EndIf
            DA1->(dbSkip())
        EndDo

        If Len(Self:aCols) > 0            
            aAdd(Self:aHeader,{""                                    ,"MARCACAO"  ,"@BMP"                      ,02                      ,00                      ,,,"C",,"V",Nil ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{Alltrim(DA0->(RetTitle("DA0_CODTAB"))),"DA0_CODTAB",PesqPict("DA0","DA0_CODTAB"),Tamsx3("DA0_CODTAB")[01],Tamsx3("DA0_CODTAB")[02],,,"C",,"V",    ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{Alltrim(DA0->(RetTitle("DA0_DESCRI"))),"DA0_DESCRI",PesqPict("DA0","DA0_DESCRI"),Tamsx3("DA0_DESCRI")[01],Tamsx3("DA0_DESCRI")[02],,,"C",,"V",    ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{Alltrim(DA0->(RetTitle("DA0_DATDE"))) ,"DA0_DATDE" ,PesqPict("DA0","DA0_DATDE") ,Tamsx3("DA0_DATDE")[01] ,Tamsx3("DA0_DATDE")[02] ,,,"D",,"V",    ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{Alltrim(DA0->(RetTitle("DA0_DATATE"))),"DA0_DATATE",PesqPict("DA0","DA0_DATATE"),Tamsx3("DA0_DATATE")[01],Tamsx3("DA0_DATATE")[02],,,"D",,"V",    ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{Alltrim(DA1->(RetTitle("DA1_PRCVEN"))),"DA1_PRCVEN",PesqPict("DA1","DA1_PRCVEN"),Tamsx3("DA1_PRCVEN")[01],Tamsx3("DA1_PRCVEN")[02],,,"N",,"V",    ,Nil,Nil,"V"})
            aAdd(Self:aHeader,{"R_E_C_N_O_"                          ,"RECNODA1"  ,""                          ,15                      ,00                      ,,,"N",,"V",    ,Nil,Nil,"V"})

            Self:cErro := ""
            lRet := .T.
        Else
            Self:cErro := "Produto não Localizado em nenhuma tabela de preços"
            lRet := .F.
        EndIf    
    EndIf
Else
    Self:cErro := "Produto não Localizado"
    lRet := .F.
EndIf

Return lRet

/*/{protheus.doc} BarraBotoes
*******************************************************************************************
Método para exibir a barra de botões em tela.

@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method BarraBotoes(oDlg,bOk,bCancel,aButtons,aButText,lIsEnchoice,lSplitBar,lLegenda,nDirecao,lBGround) class bo05BlqTabPrc
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

Return

/*/{protheus.doc} TelaBloqueio
*******************************************************************************************
Método para exibir a operação de bloqueio/liberação de itens na tabela de preço em tela.

@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method TelaBloqueio() class bo05BlqTabPrc
Local oWizard	    := NIL
Local aCoord        := {0,0,500,800}
Local lOk           := .F.
Local cLogotipo     := "totvsprinter_logo.png"
Local oTbSuper      := NIL
Local oPnSuper      := NIL
Local oPnBSuper     := NIL
Local oPnInfer      := NIL
Local oPnESup       := NIL
Local oPnDSup       := NIL
Local oPnEInf       := NIL
Local oTbDInf       := NIL
Local oPnBDInf      := NIL
Local oPnDInf       := NIL
Local aButSuper     := {}
Local aButInfer     := {}

oWizard := APWizard():New(  "Bloqueio de Itens em Tabelas de Preço",   											 ;   // chTitle  - Titulo do cabecalho
                            "Selecione os itens a manter ativos nas tabelas de preço.",          			     ;   // chMsg    - Mensagem do cabecalho
                            "Controle de Tabelas de Preço",           							 			     ;   // cTitle   - Titulo do painel de apresentacao
                            "",       													         			     ;   // cText    - Texto do painel de apresentacao
                            {|| lOk := MsgYesNo("Confirma a Manutenção de Bloqueio ?"),lOk },                    ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| lOk := MsgYesNo("Confirma a Manutenção de Bloqueio ?"),lOk },                    ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            cLogotipo,        	   												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                            {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                            aCoord 		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

//->> Painel Superior ******************************************************************************************************************************************************
oPnSuper := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NWIDTH)/2),(85),.T.,.F. )
oPnSuper:Align := CONTROL_ALIGN_TOP

oPnBSuper := TPanel():New(0,0,'',oPnSuper, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPnSuper:NWIDTH)/2),((oPnSuper:NHEIGHT)/2),.T.,.F. )
oPnBSuper:Align := CONTROL_ALIGN_TOP

oTbSuper := TToolBox():New(00,00,oPnSuper,(oPnSuper:NCLIENTWIDTH/2),(oPnSuper:NCLIENTHEIGHT/2))
oTbSuper:AddGroup( oPnBSuper , cFilAnt + " - " + SM0->M0_FILIAL)

//->> Painel Superior Esquerdo
oPnESup := TPanel():New(0,0,'',oPnBSuper, oWizard:GetPanel(1):oFont, .T., .T.,,,(17),((oPnBSuper:NHEIGHT)/2),.F.,.T. )
oPnESup:Align := CONTROL_ALIGN_LEFT

aAdd(aButSuper,{"estomovi"	        ,{|| MaViewSB2(SB1->B1_COD) },"Posição de Estoque" })
Self:BarraBotoes(oPnESup,,,aButSuper,/*aButtonTxt*/,.F.,,,3,.F.)

//->> Painel Superior Direito
oPnDSup := TPanel():New(0,0,'',oPnBSuper, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPnBSuper:NWIDTH)/2)-17,((oPnBSuper:NHEIGHT)/2),.F.,.T. )
oPnDSup:Align := CONTROL_ALIGN_RIGHT

Self:MyEnchoice(oPnDSup,{2,2,((oPnDSup:NHEIGHT)/2)-20,((oPnDSup:NWIDTH)/2)-2})

//->> Painel Inferior ******************************************************************************************************************************************************
oPnInfer := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NWIDTH)/2),((oWizard:GetPanel(1):NHEIGHT)/2)-85,.F.,.T. )
oPnInfer:Align := CONTROL_ALIGN_BOTTOM

//->> Painel Superior Esquerdo
oPnEInf := TPanel():New(0,0,'',oPnInfer, oWizard:GetPanel(1):oFont, .T., .T.,,,(17),((oPnInfer:NHEIGHT)/2),.F.,.T. )
oPnEInf:Align := CONTROL_ALIGN_LEFT

aAdd(aButInfer,{Self:cImgSelec	    ,{|| Self:MarcDesmarc(1) },"Desbloquear Todos"  })
aAdd(aButInfer,{Self:cImgNoSelec	,{|| Self:MarcDesmarc(2) },"Bloquear Todos"     })
Self:BarraBotoes(oPnEInf,,,aButInfer,/*aButtonTxt*/,.F.,,,3,.F.)

//->> Painel Superior Direito
oPnDInf := TPanel():New(0,0,'',oPnInfer, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPnInfer:NWIDTH)/2)-17,((oPnInfer:NHEIGHT)/2),.F.,.T. )
oPnDInf:Align := CONTROL_ALIGN_RIGHT

oPnBDInf := TPanel():New(0,0,'',oPnDInf, oWizard:GetPanel(1):oFont, .T., .T.,,,((oPnDInf:NWIDTH)/2),((oPnDInf:NHEIGHT)/2),.F.,.T. )
oPnBDInf:Align := CONTROL_ALIGN_ALLCLIENT

oTbDInf := TToolBox():New(00,00,oPnDInf,(oPnDInf:NCLIENTWIDTH/2),(oPnDInf:NCLIENTHEIGHT/2))
oTbDInf:AddGroup( oPnBDInf , "Tabelas de Preços do Produto")

Self:oTabela := MSNewGetDados():New(00,00,((oPnBDInf:NHEIGHT)/2),((oPnBDInf:NWIDTH)/2),GD_UPDATE,.T.,.T.,,,,,,,,oPnBDInf,Self:aHeader,Self:aCols)
Self:oTabela:bChange := {|| Self:nPOSITEM := Self:oTabela:nAt,Self:oTabela:Refresh()}        
Self:oTabela:oBrowse:SetBlkBackColor({|| Self:GETDCLR(Self:oTabela:nAt,Self:nPOSITEM,Self:nCorItem)})	
Self:oTabela:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Self:oTabela:obrowse:bldblclick := {|| Self:MarcDesmarc(0),Self:oTabela:Refresh() }

oWizard:OFINISH:CCAPTION := "&Salvar"

//->> Ativacao do Painel
oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                    {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                    {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

If lOk
    Self:Salvar()
EndIf

Return

/*/{protheus.doc} MarcDesmarc
*******************************************************************************************
Metodo para marcar e desmarcar tudo
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method MarcDesmarc(nTipo) class bo05BlqTabPrc
Local nX        := 1
Local nPMarca   := Ascan(Self:aHeader,{|x| Alltrim(Upper(x[02])) == "MARCACAO" })

If nPMarca > 0
    If nTipo == 0
        If Self:oTabela:aCols[Self:oTabela:nAt,nPMarca]:cName == Self:cImgSelec
            Self:oTabela:aCols[Self:oTabela:nAt,nPMarca]:cName := Self:cImgNoSelec
        Else
            Self:oTabela:aCols[Self:oTabela:nAt,nPMarca]:cName := Self:cImgSelec            
        EndIf
    Else
        For nX:=1 to Len(Self:oTabela:aCols)
            If nTipo == 1
                Self:oTabela:aCols[nX,nPMarca]:cName := Self:cImgSelec
            Else
                Self:oTabela:aCols[nX,nPMarca]:cName := Self:cImgNoSelec
            EndIf
        Next nX
    EndIf
EndIf    

Return

/*/{protheus.doc} Salvar
*******************************************************************************************
Metodo para salvar os campos
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method Salvar() class bo05BlqTabPrc
Local nPRecno   := Ascan(Self:aHeader,{|x| Alltrim(Upper(x[02])) == "RECNODA1" })
Local nPMarca   := Ascan(Self:aHeader,{|x| Alltrim(Upper(x[02])) == "MARCACAO" })
Local nX        := 1

If nPRecno > 0 .And. nPMarca > 0
    For nX:=1 to Len(Self:oTabela:aCols)
        DA1->(dbGoto(Self:oTabela:aCols[nX,nPRecno]))
        Reclock("DA1",.F.)
        If Self:oTabela:aCols[nX,nPMarca]:cName == Self:cImgSelec
            DA1->DA1_ATIVO := "1"
        Else
            DA1->DA1_ATIVO := "2"
        EndIf
        DA1->(MsUnlock())
    Next nX
EndIf

Return

/*/{protheus.doc} MyEnchoice
*******************************************************************************************
Metodo para exibir os campos da enchoice na tela
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method MyEnchoice(oDlg,aCoord) class bo05BlqTabPrc
Local nModelo		:= 1        
Local lF3			:= .F.
Local lMemoria 		:= .T.
Local lColumn  		:= .F.
Local caTela 		:= ""
Local lNoFolder		:= .T.
Local lProperty		:= .F. 
Local cAlias        := "SB1"
Local nReg          := SB1->(Recno())
Local aCpos         := {}

aAdd(aCpos,"NOUSER"     )
aAdd(aCpos,"B1_COD"     )
aAdd(aCpos,"B1_DESC"    )
aAdd(aCpos,"B1_GRUPO"   )

If SB1->(FieldPos("B1_XNOMGRP")) > 0
    aAdd(aCpos,"B1_XNOMGRP"   )
EndIf
If SB1->(FieldPos("B1_XCSGRP")) > 0
    aAdd(aCpos,"B1_XCSGRP"   )
EndIf
If SB1->(FieldPos("B1_XNSGRP")) > 0
    aAdd(aCpos,"B1_XNSGRP"   )
EndIf    

RegToMemory( cAlias, .F.)

Enchoice(	cAlias, nReg, /*(nOpc*/ 2 ,/*aCRA*/, /*cLetra*/, /*cTexto*/, ;
            aCpos, aCoord, aCpos, nModelo, /*nColMens*/,;
            /*cMensagem*/,/*cTudoOk*/, oDlg, lF3, lMemoria, lColumn,;
            caTela, lNoFolder, lProperty )

Return

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Metodo para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method GETDCLR(nLinha,nSelec,nCor) class bo05BlqTabPrc
Local nCor1 := nCor
Local nRet  := CLR_WHITE

If nLinha == nSelec
	nRet := nCor1
EndIf

Return nRet

/*/{protheus.doc} bo05BlqTabPrc
*******************************************************************************************
Método para destruir o objeto instanciado

@author: Marcelo Celi Marques
@since: 30/05/2021
@param: 
@return:
@type function: Metodo do objeto bo05BlqTabPrc
*******************************************************************************************
/*/
Method Destroy() class bo05BlqTabPrc
If Valtype(self) == 'O'    
    Self:= nil
Endif
Return

