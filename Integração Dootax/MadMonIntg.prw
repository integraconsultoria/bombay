#INCLUDE "Totvs.ch"
#INCLUDE "Apwizard.ch"
#INCLUDE 'Msgraphi.ch'
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"

Static POS_IT_OK  	:= 0
Static nCorOk		:= Rgb(143,171,218)

Static POS_IT_ERR  	:= 0
Static nCorERR		:= Rgb(209,88,100)

Static POS_IT_MON	:= 0
Static nCorMON		:= Rgb(218,192,73)

/*/{protheus.doc} MaMonIntg
*******************************************************************************************
Monitor de Integrações
 
@author: Marcelo Celi Marques
@since: 25/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaMonIntg()
Local _cFilAnt := cFilAnt

Private aRotina 	:= MenuDef()
Private cCadastro 	:="Monitor de Integrações do e-Commerce"
Private Tb_Monit    := u_MAPNGetTb("MON")
Private Tb_ChMon    := u_MAPNGetTb("CHM")
Private Tb_LgMon    := u_MAPNGetTb("LOG")
Private Tb_ThMon    := u_MAPNGetTb("THR")

If u_MAVldMonit(Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,.F.)
	//u_MaCpyImgEc()
	mBrowse( 6, 1,22,75,Tb_Monit,,,,,,,,,,,,.F.,.F.)
EndIf

cFilAnt := _cFilAnt

Return

/*/{protheus.doc} MenuDef
*******************************************************************************************
Menu do configurador
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  		,0,1,0	,.F.},;					 
                     {"Monitorar"	, "u_MaMIntegr"	,0,2,0	,NIL}}
Return aRotina


/*/{protheus.doc} MaMonIntg
*******************************************************************************************
Monitor de Integrações
 
@author: Marcelo Celi Marques
@since: 25/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaMIntegr()
Local oDlg      := NIL
Local oFWLayer  := NIL
Local oFW1Layer := NIL
Local oPanel    := NIL
Local oPanEsq   := NIL
Local oPan1Esq  := NIL
Local oPan2Esq  := NIL
Local oPan3Esq  := NIL
Local oPanDir   := NIL
Local oPan1Err	:= NIL
Local oPan2Err	:= NIL
Local oPan3D1	:= NIL
Local oPan3D2	:= NIL
Local oPan3D3	:= NIL
Local oTrackMenu:= NIL
Local oBtSaida  := NIL
Local oFldExecuc:= NIL
Local oLogotipo := NIL
Local aSize	    := MsAdvSize()
Local nX        := 1
Local aColsOk   := {}
Local aHeadOk   := {}
Local aColsNOk  := {}
Local aHeadNOk  := {}
Local aColsMon  := {}
Local aHeadMon  := {}
Local cRaiz     := ""
Local cPasta    := ""
Local cLogo		:= ""
Local nTempoAtlz:= (Tb_Monit)->&(Tb_Monit+"_TEMPAT")
Local cTitulo1	:= Alltrim((Tb_Monit)->&(Tb_Monit+"_DESCRI"))
Local cTitulo2	:= "Powered by MARCELO CELI"
Local bComando	:= {|| }
Local aButtons	:= {}
Local oFonte1 	:= TFont():New("Verdana",,012,,.T.,,,,,.F.,.F.)
Local oFonte2 	:= TFont():New("Verdana",,012,,.F.,,,,,.F.,.T.)

Private aBotoes		:= {}
Private oBotoes     := {}
Private cBmpConn	:= "FRTONLINE"
Private cBmpNoConn	:= "FRTOFFLINE"
Private dProcess    := Date()   
Private oCalendario := NIL
Private oTempoAtlz  := NIL
Private oTempoMoni  := NIL
Private oGrfProjAna := NIL
Private oHistExecs  := NIL
Private oPan1Dir    := NIL
Private oPan2Dir    := NIL
Private oPan3Dir    := NIL
Private oPan4Dir	:= NIL
Private oExecutados := NIL
Private oErros      := NIL
Private oMonitor    := NIL
Private aItensOk	:= {}
Private aItensErr	:= {}
Private aOpcoes		:= {}
Private aBarStatus  := Array(10)

cRaiz   := "\system\"
Makedir(cRaiz)

cPasta  := cRaiz
Makedir(cPasta)

cLogo := cPasta+Alltrim((Tb_Monit)->&(Tb_Monit+"_LOGOTP"))
(Tb_ChMon)->(dbSetOrder(2))        
(Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+(Tb_Monit)->&(Tb_Monit+"_CODIGO")))
Do While (Tb_ChMon)->(!Eof()) .And. (Tb_ChMon)->&(Tb_ChMon+"_FILIAL+"+Tb_ChMon+"_CODIGO") == xFilial(Tb_ChMon)+(Tb_Monit)->&(Tb_Monit+"_CODIGO")
	//->> Marcelo Celi - 02/03/2022
	If (Tb_ChMon)->&(Tb_ChMon+"_MSBLQL") <> '1'	
		bComando := "{|| "+Alltrim((Tb_ChMon)->&(Tb_ChMon+"_FUNCAO"))+" }"
		bComando := &(bComando)
		aAdd(aBotoes,{	Alltrim((Tb_ChMon)->&(Tb_ChMon+"_NOME")),					; // 01 - Nome do Botão
						Alltrim((Tb_ChMon)->&(Tb_ChMon+"_ICONE")),					; // 02 - Icone de Exibição
						bComando,								  					; // 03 - Comando ao clicar no botão
						(Tb_ChMon)->&(Tb_ChMon+"_INTEGR"),		  					; // 04 - Id da Integração
						(Tb_ChMon)->&(Tb_ChMon+"_ORDEM"),		  					; // 05 - Ordem de Exibição do Botão
						Upper(Alltrim((Tb_ChMon)->&(Tb_ChMon+"_MSBLQL")))=="S",	  	; // 06 - Se Botão estará disponivel
						(Tb_ChMon)->&(Tb_ChMon+"_COR"),			  				    ; // 07 - Cor da Legenda
						(Tb_ChMon)->&(Tb_ChMon+"_CONEX")}	 					    ) // 08 - Se Botão é ativo ou receptivo
	EndIf		
	(Tb_ChMon)->(dbSkip())
EndDo

aBotoes := aSort(aBotoes,,,{|x,y| x[05]+x[01] <= y[05]+y[01]  })

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL Style 1 Color CLR_BLACK,CLR_WHITE 

//->> Painel Principal Superior (para todos os controles da tela)
oPanPrinc:= TPanel():New(00,00,"",oDlg,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oDlg:NWIDTH/2),(oDlg:NHEIGHT/2)-22,.F.,.F.)
oPanPrinc:Align := CONTROL_ALIGN_TOP

//->> Painel Principal Inferior (para a barra de status)
aBarStatus[01] := TPanel():New(00,00,"",oDlg,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oDlg:NWIDTH/2),(22),.T.,.T.)
aBarStatus[01]:Align := CONTROL_ALIGN_BOTTOM

//-> Marcelo Celi - 21/12/2021
aBarStatus[02] := TPanel():New(01,01,"",aBarStatus[01],oDlg:oFont,.T.,.T.,,rgb(206,206,206),(5),(aBarStatus[01]:nHeight/2)-2,.F.,.T.)
aBarStatus[02]:Align := CONTROL_ALIGN_LEFT

//If File("CLIENTE-MINILOGO.PNG")
//	oMiniLogo := TBitmap():New(01,01,(aBarStatus[02]:nWidth/2)-2,(aBarStatus[02]:nHeight/2)-2,,"CLIENTE-MINILOGO.PNG",.T.,aBarStatus[02],,,.F.,.T.,,,.F.,,.T.,,.F.)
//EndIf

aBarStatus[03] := TPanel():New(01,01,"",aBarStatus[01],oDlg:oFont,.T.,.T.,,rgb(206,206,206),(100),(aBarStatus[01]:nHeight/2)-2,.T.,.F.)
aBarStatus[03]:Align := CONTROL_ALIGN_LEFT

//->> Botão de Saida
oBtSaida := TButton():New(01,01,"Saida",aBarStatus[03],{|| oDlg:End() },((aBarStatus[03]:NWIDTH)/2)-2,((aBarStatus[03]:NHEIGHT)/2)-2,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtSaida:SetCss(GetStyloBt(5,"FINAL.png"))
oBtSaida:lActive := .T.

aBarStatus[04] := TPanel():New(01,01,"",aBarStatus[01],oDlg:oFont,.T.,.T.,,rgb(206,206,206),(aBarStatus[01]:NWIDTH/2)-(5+100+100+100),(aBarStatus[01]:nHeight/2)-2,.T.,.F.)
aBarStatus[04]:Align := CONTROL_ALIGN_LEFT

aBarStatus[05] := TPanel():New(01,01,"",aBarStatus[01],oDlg:oFont,.T.,.T.,,rgb(206,206,206),(100),(aBarStatus[01]:nHeight/2)-2,.F.,.T.)
aBarStatus[05]:Align := CONTROL_ALIGN_LEFT

//-> Marcelo Celi - 21/12/2021
//oSay1 := TSay():New(02,02,&('{|| "'+cTitulo1+'" }'),aBarStatus[05],,oFonte1,,,,.T.,Rgb(97,97,97),CLR_WHITE,((aBarStatus[05]:NWIDTH/2)-2),((aBarStatus[05]:NHEIGHT/2)-2) )
//oSay1:SetTextAlign( 2, 2 )

If File("CLIENTE-MINILOGO.PNG")
	oMiniLogo := TBitmap():New(01,01,(aBarStatus[05]:nWidth/2)-2,(aBarStatus[05]:nHeight/2)-2,,"CLIENTE-MINILOGO.PNG",.T.,aBarStatus[05],,,.F.,.T.,,,.F.,,.T.,,.F.)
EndIf

aBarStatus[06] := TPanel():New(01,01,"",aBarStatus[01],oDlg:oFont,.T.,.T.,,rgb(206,206,206),(100),(aBarStatus[01]:nHeight/2)-2,.F.,.T.)
aBarStatus[06]:Align := CONTROL_ALIGN_LEFT

AssinaInteg(aBarStatus[06])

//oSay2 := TSay():New(02,02,&('{|| "'+cTitulo2+'" }'),aBarStatus[06],,oFonte1,,,,.T.,Rgb(97,97,97),CLR_WHITE,((aBarStatus[06]:NWIDTH/2)-2),((aBarStatus[06]:NHEIGHT/2)-2) )
//oSay2:SetTextAlign( 2, 2 )

aBarStatus[07] := ""
aBarStatus[08] := TSay():New(02,02,{|| aBarStatus[07] },aBarStatus[04],,oFonte2,,,,.T.,Rgb(97,97,97),CLR_WHITE,((aBarStatus[04]:NWIDTH/2)-2),((aBarStatus[04]:NHEIGHT/2)-2) )
aBarStatus[08]:SetTextAlign( 0, 2 )

//->> Painel Principal
oFWLayer := FWLayer():New()  
oFWLayer:Init(oPanPrinc,.F.,.F.)  
oFWLayer:addLine("LINHA1",100,.F.)  
oFWLayer:AddCollumn("QUADRO1"	,100,.T.,"LINHA1")    
oFWLayer:AddWindow("QUADRO1"	,"oPanel"	,"Monitor de Integrações" ,100,.F.,.T.,,"LINHA1",{ || })   
oPanel := oFWLayer:GetWinPanel("QUADRO1","oPanel","LINHA1")   

//->> Paineis da Esquerda
oPanEsq:= TPanel():New(00,00,"",oPanel,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(140),(oPanel:NHEIGHT/2),.F.,.F.)
oPanEsq:Align := CONTROL_ALIGN_LEFT

//->> Marcelo Celi - 17/09/2021
oPanESup1 := TPanel():New(00,00,"",oPanEsq,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oPanEsq:NWIDTH/2),(oPanEsq:NHEIGHT/2)-(70),.F.,.F.)
oPanESup1:Align := CONTROL_ALIGN_TOP
oPanESup1:SetCss( " QLabel { background-color: white; border-radius: 12px ; border: 2px solid gray;}" )		

oPanESup2 := TPanel():New(00,00,"",oPanEsq,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oPanEsq:NWIDTH/2),(70),.F.,.F.)
oPanESup2:Align := CONTROL_ALIGN_TOP

oPan1Esq:= TPanel():New(00,00,"",oPanESup1,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oPanESup1:NWIDTH/2),(54),.F.,.F.)
oPan1Esq:Align := CONTROL_ALIGN_TOP

oPan2Esq:= TPanel():New(02,02,"",oPanESup1,oDlg:oFont,.T.,.T.,,rgb(255,255,255),(oPanESup1:NWIDTH/2)-4,(oPanESup1:NHEIGHT/2)-(54)-4 ,.F.,.F.)
oPan2Esq:Align := CONTROL_ALIGN_TOP

oTrackMenu := TTrackMenu():New( oPan2Esq, 4, 4, ((oPan2Esq:NWIDTH/2)-8),((oPan2Esq:NHEIGHT/2)-8), {|o,cID| MyAction(o, cId, aBotoes) }, /*cHeigthBtn*/40, /*cColorBackGround*/ "#FFFFFF", /*cColorSeparator*/ "#C0C0C0",/*cGradientTop*/"#57A2EE", /*cGradientBottom*/"#2BD0F7", /*oFont*/TFont():New('Arial',,12,,.T.,,,,,.F.,.F.), /*cColorText*/"#000000") 
For nX:=1 to Len(aBotoes)
    oTrackMenu:Add(aBotoes[nX,04],aBotoes[nX,01],aBotoes[nX,02],If(Alltrim(Upper(aBotoes[nX,08]))<>"A" .Or. aBotoes[nX,06],"BPMSEDT1.png","BPMSEDT3.png") )    
Next nX

oPanVazEsq:= TPanel():New(00,00,"",oPanESup2,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oPanESup2:NWIDTH/2),(2),.F.,.F.)
oPanVazEsq:Align := CONTROL_ALIGN_TOP

oPan3Esq:= TPanel():New(00,00,"",oPanESup2,oDlg:oFont,.T.,.T.,,rgb(216,216,216),(oPanESup2:NWIDTH/2),(68),.F.,.F.)
oPan3Esq:Align := CONTROL_ALIGN_TOP
oPan3Esq:SetCss( " QLabel { background-color: white; border-radius: 14px ; border: 3px solid gray;}" )		

//->> Logotipo
oLogotipo := TBitmap():New(02,02,((oPan1Esq:NWIDTH/2)-4),((oPan1Esq:NHEIGHT/2)-4),Nil,"",.T.,oPan1Esq,,,.F.,.T.,,,.F.,,.T.,,.F.)
oLogotipo:CBMPFILE := cLogo
oLogotipo:Refresh()

//->> Calendario
oCalendario 			:= MsCalend():New(00,00,oPan3Esq,.T.)
oCalendario:dDiaAtu 	:= dProcess
oCalendario:bChange     := {|| AtualCalend() }
oCalendario:ColorDay( 1, CLR_RED )
oCalendario:ColorDay( 7, CLR_BLUE )
oCalendario:canmultsel  := .F.
oCalendario:Refresh()

//->> Paineis da Direita
oPanDir:= TPanel():New(00,00,"",oPanel,oDlg:oFont,.T.,.T.,,rgb(238,238,238),(oPanel:NWIDTH/2)-140,(oPanel:NHEIGHT/2),.F.,.F.)
oPanDir:Align := CONTROL_ALIGN_RIGHT

oFW1Layer := FWLayer():New()  
oFW1Layer:Init(oPanDir,.F.,.F.)  

oFW1Layer:addLine("LINHA1",50,.F.)  
oFW1Layer:AddCollumn("COLUNA1"	,50,.T.,"LINHA1")    
oFW1Layer:AddCollumn("COLUNA2"	,50,.T.,"LINHA1")

oFW1Layer:AddWindow("COLUNA1"	,"oPan1Dir"	,"Histórico das Execuções"  ,100,.F.,.T.,,"LINHA1",{ || })   
oPan1Dir := oFW1Layer:GetWinPanel("COLUNA1","oPan1Dir","LINHA1")   

oHistExecs := MsCalendGrid():New(oPan1Dir /*oDlg*/,01/*nCol*/,01/*nCol*/,((oPan1Dir:NWIDTH)/2)-1/*nWidth*/,((oPan1Dir:NHEIGHT)/2)-1/*nHeight*/,dProcess/*Data Inicio*/,4/*Resolucao*/,/*bWhen*/,{|| }/*bAction*/,RGB(223,218,241)/*nDefColor*/, {|| }/*bRClick*/, .F./*lFilAll*/,/*nTypeUnit 0-Horas, 1-Dias*/ ) 
oHistExecs:Align   := CONTROL_ALIGN_ALLCLIENT
oHistExecs:cTopMsg := "Integrações Realizadas em "+Dtoc(dProcess)

oFW1Layer:AddWindow("COLUNA2"	,"oPan2Dir"	,"Projeção Analítica"       ,100,.F.,.T.,,"LINHA1",{ || })   
oPan2Dir := oFW1Layer:GetWinPanel("COLUNA2","oPan2Dir","LINHA1")   

oGrfProjAna := FWChartLine():New()
oFW1Layer:addLine("LINHA2",50,.F.)  
oFW1Layer:AddCollumn("COLUNA1"	,55,.T.,"LINHA2")
oFW1Layer:AddCollumn("COLUNA2"	,45,.T.,"LINHA2")

oFW1Layer:AddWindow("COLUNA1"	,"oPan3Dir"	,"Integrações"              ,100,.F.,.T.,,"LINHA2",{ || })   
oPan3Dir := oFW1Layer:GetWinPanel("COLUNA1","oPan3Dir","LINHA2")

//->> Marcelo Celi - 17/09/2021
oPan3D1:= TPanel():New(00,00,"",oPan3Dir,oDlg:oFont,.T.,.T.,,rgb(238,238,238),(33),(oPan3Dir:NHEIGHT/2),.F.,.F.)
oPan3D1:Align := CONTROL_ALIGN_LEFT
oPan3DScr := TScrollBox():New(oPan3D1,2,2,(oPan3D1:NHEIGHT/2)-2,(oPan3D1:NWIDTH/2)-2,.T.,.F.,.F.)
oPan3DScr:SetCss( " QLabel { background-color: white; border-radius: 12px ; border: 2px solid gray;}" )		

For nX:=1 to Len(aBotoes)
	aAdd(aOpcoes,{NIL,NIL,NIL,.T.,""})
	aOpcoes[Len(aOpcoes)][01] := TPanel():New(01,01,"",oPan3DScr,,,,,,(oPan3DScr:NWIDTH/2),15,.F.,.F.)
	aOpcoes[Len(aOpcoes)][01]:Align := CONTROL_ALIGN_TOP

	aOpcoes[Len(aOpcoes)][02] := TBitmap():New(02,02,/*Largura*/10,/*Altura*/10,aBotoes[nX,02],Nil,.T.,aOpcoes[Len(aOpcoes)][01],,,.F.,.T.,,,.F.,,.T.,,.F.)

	bCmd := "{|u| If(ValType(u) = 'U', aOpcoes["+Alltrim(Str(Len(aOpcoes)))+"][04], aOpcoes["+Alltrim(Str(Len(aOpcoes)))+"][04] := u)}"	
	bCmd := &(bCmd)
	aOpcoes[Len(aOpcoes)][03] := TCheckBox():New(03,15,"",bCmd,aOpcoes[Len(aOpcoes)][01],10,10,,,oDlg:oFont,,CLR_RED,CLR_WHITE,,.T.,,,)
	aOpcoes[Len(aOpcoes)][03]:bldblclick := {|| AtuDados() }
	aOpcoes[Len(aOpcoes)][03]:blclicked := {|| AtuDados() }

	aOpcoes[Len(aOpcoes)][05] := aBotoes[nX,04]
Next nX

oPan3D2:= TPanel():New(00,00,"",oPan3Dir,oDlg:oFont,.T.,.T.,,rgb(238,238,238),(3),(oPan3Dir:NHEIGHT/2),.F.,.F.)
oPan3D2:Align := CONTROL_ALIGN_LEFT

oPan3D3:= TPanel():New(00,00,"",oPan3Dir,oDlg:oFont,.T.,.T.,,rgb(238,238,238),(oPan3Dir:NWIDTH/2)-33,(oPan3Dir:NHEIGHT/2),.F.,.F.)
oPan3D3:Align := CONTROL_ALIGN_RIGHT

oFldExecuc := TFolder():New(0,0,{"Operações com Sucesso","Operações com Erro"},{},oPan3D3,,,, .T., .F.,(oPan3D3:NWIDTH/2),(oPan3D3:NHEIGHT/2),,.T.)
oFldExecuc:Align := CONTROL_ALIGN_ALLCLIENT

aHeadOk := {}
Aadd(aHeadOk,{"Data"    ,"DATA"     ,"@E"   ,08,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadOk,{"Hora"    ,"HORA"     ,"@E"   ,08,0,"","","D","","V","",Nil,Nil,"V"})
Aadd(aHeadOk,{"Metodo"  ,"METODO"   ,"@BMP" ,02,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadOk,{"Tabela"  ,"ALIAS"	,"@!"   ,03,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadOk,{"Indice"  ,"INDICE"	,""     ,02,0,"","","N","","V","",Nil,Nil,"V"})
Aadd(aHeadOk,{"Chave"   ,"CHAVE"    ,""     ,30,0,"","","C","","V","",Nil,Nil,"V"})

//->> Marcelo Celi - 19/04/2022
oPan1Ok:= TPanel():New(00,00,"",oFldExecuc:ADIALOGS[1],oDlg:oFont,.T.,.T.,,rgb(255,255,255),(oFldExecuc:ADIALOGS[1]:NWIDTH/2),(oFldExecuc:ADIALOGS[1]:NHEIGHT/2)-(15),.T.,.F.)
oPan1Ok:Align := CONTROL_ALIGN_ALLCLIENT

oExecutados := MSNewGetDados():New(00,00,(oPan1Ok:NHEIGHT/2),(oPan1Ok:NWIDTH/2),2,,.T.,,,,,,,,oPan1Ok,aHeadOk,aColsOk)
oExecutados:bChange := {||POS_IT_OK := oExecutados:nAt,oExecutados:Refresh()}
oExecutados:oBrowse:SetBlkBackColor({|| GETDCLR(oExecutados:nAt,POS_IT_OK,nCorOk)})	
oExecutados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oExecutados:oBrowse:lVisible := .F.
//oExecutados:oBrowse:bldblclick := { || VisuOkItens(oExecutados:nAt,oDlg:oFont) }

oPan2Ok:= TPanel():New(00,00,"",oFldExecuc:ADIALOGS[1],oDlg:oFont,.T.,.T.,,rgb(255,255,255),(oFldExecuc:ADIALOGS[1]:NWIDTH/2),(15),.F.,.T.)
oPan2Ok:Align := CONTROL_ALIGN_BOTTOM

aButtons := {}
aAdd(aButtons,{"BMPVISUAL"	,{|| VisuOkItens(oExecutados:nAt,oDlg:oFont,1) 	},"Visualizar"}								) 
aAdd(aButtons,{"PMSRRFSH"	,{|| VisuOkItens(oExecutados:nAt,oDlg:oFont,2)  },"Gerar Visualização Fisica"     }			) 

MyEnchBar(oPan2Ok,,,aButtons,/*aButtonTxt*/,.F.,,,0,.F.)

aHeadNOk := {}

Aadd(aHeadNOk,{""        ,"MARCACAO" ,"@BMP" ,02,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Data"    ,"DATA"     ,"@E"   ,08,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Hora"    ,"HORA"     ,"@E"   ,08,0,"","","D","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Metodo"  ,"METODO"   ,"@BMP" ,02,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Tabela"  ,"ALIAS"	 ,"@!"   ,03,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Indice"  ,"INDICE"	 ,""     ,02,0,"","","N","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Chave"   ,"CHAVE"    ,""     ,30,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadNOk,{"Recno"   ,"RECNO"    ,""     ,10,0,"","","N","","V","",Nil,Nil,"V"})

oPan1Err:= TPanel():New(00,00,"",oFldExecuc:ADIALOGS[2],oDlg:oFont,.T.,.T.,,rgb(255,255,255),(oFldExecuc:ADIALOGS[2]:NWIDTH/2),(oFldExecuc:ADIALOGS[2]:NHEIGHT/2)-(15),.T.,.F.)
oPan1Err:Align := CONTROL_ALIGN_ALLCLIENT

oErros      := MSNewGetDados():New(00,00,(oPan1Err:NHEIGHT/2),(oPan1Err:NWIDTH/2),2,,.T.,,,,,,,,oPan1Err,aHeadNOk,aColsNOk)
oErros:bChange := {||POS_IT_ERR := oErros:nAt,oErros:Refresh()}
oErros:oBrowse:SetBlkBackColor({|| GETDCLR(oErros:nAt,POS_IT_ERR,nCorERR)})
oErros:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oErros:oBrowse:lVisible := .F.
oErros:oBrowse:bldblclick := { || TrocaMarc(oErros:nAt) }

oPan2Err:= TPanel():New(00,00,"",oFldExecuc:ADIALOGS[2],oDlg:oFont,.T.,.T.,,rgb(255,255,255),(oFldExecuc:ADIALOGS[2]:NWIDTH/2),(15),.F.,.T.)
oPan2Err:Align := CONTROL_ALIGN_BOTTOM

aButtons := {}
aAdd(aButtons,{"BMPVISUAL"	,{|| VisuErrItens(oErros:nAt,oDlg:oFont) 	},"Visualizar"}			) 
aAdd(aButtons,{"LBOK"		,{|| MarcTodos() 							},"Marca Todos"}		) 
aAdd(aButtons,{"LBNO"		,{|| DesmTodos() 							},"Desmarca Todos"}		) 
aAdd(aButtons,{"PMSRRFSH"	,{|| Reprocess() 							},"Re-Processa"}		) 
aAdd(aButtons,{"S4WB004N"	,{|| ApagarPend() 							},"Limpar Pendentes"}	) 

MyEnchBar(oPan2Err,,,aButtons,/*aButtonTxt*/,.F.,,,0,.F.)

oFW1Layer:AddWindow("COLUNA2"	,"oPan4Dir"	,"Monitoramento"              ,100,.F.,.T.,,"LINHA2",{ || })   
oPan4Dir := oFW1Layer:GetWinPanel("COLUNA2","oPan4Dir","LINHA2")

aHeadMon := {}
Aadd(aHeadMon,{"User Name" 	    ,"USERNAME" ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Environment"    ,"ENVIRONM" ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Computer Name"  ,"COMPUTER" ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Thread Id" 	    ,"THREADID" ,""     ,10,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"User In Server" ,"USERSRV"  ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Program" 		,"PROGRAM"  ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Elapsed Time"   ,"ELAPSED"  ,""     ,20,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Instruc."	    ,"INSTRUC"  ,""     ,10,0,"","","N","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Instruc./Sec"   ,"INSTSEC"  ,""     ,10,0,"","","N","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Comments" 	    ,"COMMENTS" ,""     ,30,0,"","","C","","V","",Nil,Nil,"V"})
Aadd(aHeadMon,{"Memory" 	    ,"MEMORY"   ,""     ,10,0,"","","N","","V","",Nil,Nil,"V"})

oMonitor	:= MSNewGetDados():New(00,00,(oPan4Dir:NHEIGHT/2),(oPan4Dir:NWIDTH/2),2,,.T.,,,,,,,,oPan4Dir,aHeadMon,aColsMon)
oMonitor:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oMonitor:oBrowse:lVisible := .F.
oMonitor:bChange := {||POS_IT_ERR := oMonitor:nAt,oMonitor:Refresh()}
oMonitor:oBrowse:SetBlkBackColor({|| GETDCLR(oMonitor:nAt,POS_IT_MON,nCorMON)})

//->> Timer de atualização de dados nos paineis
oTempoAtlz := TTimer():New(500, {|| AtuDados(nTempoAtlz) },oDlg)
oTempoAtlz:Activate()

//->> Timer de atualização do monitoramento de execuções
oTempoMoni := TTimer():New(1000, {|| AtuMonitor((Tb_Monit)->&(Tb_Monit+"_CODIGO")) },oDlg)
oTempoMoni:Activate()

ACTIVATE MSDIALOG oDlg CENTER

Return

/*/{protheus.doc} AtuDados
*******************************************************************************************
Atualiza os Dados da tela
 
@author: Marcelo Celi Marques
@since: 31/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuDados(nTempoAtlz)
Local aDados    	:= {}
Local aCols			:= {}
Local nX        	:= 1
Local nY        	:= 1
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()
Local nRetroc		:= 0
Local nResolucao 	:= 4
Local nHorAcumul 	:= 0
Local dIni			:= Stod("")
Local nHora			:= 0
Local nPosDad		:= 0
Local cCodigo		:= (Tb_Monit)->&(Tb_Monit+"_CODIGO")
Local cOpcIntegr	:= ""

Default nTempoAtlz := 0

oTempoAtlz:lActive   := .F.
If !Empty(nTempoAtlz)
    oTempoAtlz:nInterval := (nTempoAtlz*1000)
EndIf
oCalendario:dDiaAtu     := dProcess
oCalendario:canmultsel  := .F.
oCalendario:Refresh()

cOpcIntegr := ""
For nX:=1 to Len(aOpcoes)
	If aOpcoes[nX,04]
		If !Empty(cOpcIntegr)
			cOpcIntegr += ";"
		EndIf
		cOpcIntegr += Alltrim(aOpcoes[nX,05])
	EndIf
Next nX
cOpcIntegr := FormatIn(cOpcIntegr,";")

//->> Atualização dos Históricos de Execuções
aDados := {}
For nX:=1 to Len(aBotoes)
	nHorAcumul := 0
	aAdd(aDados,{	Len(aDados)+1,			; // 01 - Numero da Linha
					Alltrim(aBotoes[nX,01]),; // 02 - Nome do Botão/Instrução
					{},						; // 03 - Itens
					aBotoes[nX,07]}			) // 04 - Cor da Barra da Legenda

	For dIni:=dProcess-nRetroc to dProcess+nRetroc
		For nHora := 0 to 23		
			aAdd(aDados[Len(aDados),03],{ 	( nHorAcumul * (nResolucao) )+1,		; // 01 - Flag inicial
											( (nHorAcumul+1) * (nResolucao) )+1,	; // 02 - Flag Final
											.F.,									; // 03 - Se pertence a seleção
											dIni,									; // 04 - Data
											StrZero(nHora,2) }						) // 05 - Hora
			nHorAcumul++
		Next nHora
	Next dIni

	cQuery := "SELECT DISTINCT"																									+CRLF
	cQuery += "					"+Tb_LgMon+"_DATA,"																				+CRLF
	cQuery += "					LEFT("+Tb_LgMon+"_HORA,2) AS "+Tb_LgMon+"_HORA"													+CRLF 
	cQuery += "		FROM "+RetSqlName(Tb_LgMon)+" "+Tb_LgMon+" (NOLOCK)"														+CRLF
	cQuery += "	WHERE 	"+Tb_LgMon+"."+Tb_LgMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"												+CRLF
	cQuery += "		AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR = '"+Alltrim(aBotoes[nX,04])+"'"										+CRLF
	cQuery += "		AND "+Tb_LgMon+"."+Tb_LgMon+"_DATA BETWEEN '"+dTos(dProcess-nRetroc)+"' AND '"+dTos(dProcess+nRetroc)+"'"	+CRLF
	cQuery += "		AND "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO = '"+Alltrim(cCodigo)+"'"												+CRLF	
	cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR IN "+cOpcIntegr													+CRLF
	cQuery += "		AND "+Tb_LgMon+".D_E_L_E_T_ = ' '"																			+CRLF
	cQuery += "ORDER BY "+Tb_LgMon+"_DATA, "+Tb_LgMon+"_HORA"																	+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	Do While (cAlias)->(!Eof())
		nPosProc := Ascan(aDados[Len(aDados),03],{|x| dTos(x[04]) == (cAlias)->&(Tb_LgMon+"_DATA") .And. Alltrim(x[05])==Alltrim((cAlias)->&(Tb_LgMon+"_HORA")) })
		If nPosProc > 0
			aDados[Len(aDados),03][nPosProc,03] := .T.
		EndIf	
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

	For nY:=1 to Len(aDados[Len(aDados),03])
		If !aDados[Len(aDados),03][nY,03]
			aDados[Len(aDados),03][nY,01] := 0
			aDados[Len(aDados),03][nY,02] := 0
		EndIf
	Next nY	
Next nX

If Valtype(oHistExecs)=="O"
    FreeObj(oHistExecs)
EndIf
oHistExecs := MsCalendGrid():New(oPan1Dir /*oDlg*/,01/*nCol*/,01/*nCol*/,((oPan1Dir:NWIDTH)/2)-1/*nWidth*/,((oPan1Dir:NHEIGHT)/2)-1/*nHeight*/,dProcess/*Data Inicio*/,4/*Resolucao*/,/*bWhen*/,{|| }/*bAction*/,RGB(223,218,241)/*nDefColor*/, {|| }/*bRClick*/, .F./*lFilAll*/,/*nTypeUnit 0-Horas, 1-Dias*/ ) 
oHistExecs:Align   := CONTROL_ALIGN_ALLCLIENT
oHistExecs:cTopMsg := "Integrações Realizadas em "+Dtoc(dProcess)

For nX:=1 to Len(aDados)
	For nY:=1 to Len(aDados[nX,03])
		oHistExecs:Add(aDados[nX,02] /*Caption*/,aDados[nX,01]/*Numero da Linha*/, aDados[nX,03,nY,01]/*Data Inicial*/,aDados[nX,03,nY,02]/*Data Final*/,aDados[nX,04]/*cor linha*/,"" )
	Next nY
Next nX

//->> Atualização da Projeção Analitica de Execuções
aDados := {}
If Valtype(oGrfProjAna)=="O"
    FreeObj(oGrfProjAna)
EndIf

For nX:=1 to Len(aBotoes)
	aAdd(aDados,Array(03))
	aDados[Len(aDados)][01] := Alltrim(aBotoes[nX,01]) 	// 01 - Descrição
	aDados[Len(aDados)][02] := aBotoes[nX,07]			// 02 - Cor
	aDados[Len(aDados)][03] := {}						// 03 - Itens
	
	For nY:=1 to 24
		aAdd(aDados[Len(aDados)][03]	,{StrZero(nY-1,02)+":00",; // 01 - Hora da Execução
										0				  	    }) // 02 - Quantidade de Execuções
	Next nX

	cQuery := "SELECT"																													+CRLF	
	cQuery += "		HORA 		AS HORA,"																								+CRLF
	cQuery += "		COUNT(*) 	AS QTDE"																								+CRLF
	cQuery +="		FROM ("																												+CRLF
	cQuery += "			SELECT"																											+CRLF
	cQuery += "				LEFT("+Tb_LgMon+"_HORA,2) AS HORA"																			+CRLF 	
	cQuery += "			FROM "+RetSqlName(Tb_LgMon)+" "+Tb_LgMon+" (NOLOCK)"															+CRLF
	cQuery += "			WHERE 	"+Tb_LgMon+"."+Tb_LgMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"												+CRLF
	cQuery += "				AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR = '"+Alltrim(aBotoes[nX,04])+"'"										+CRLF
	cQuery += "				AND "+Tb_LgMon+"."+Tb_LgMon+"_DATA BETWEEN '"+dTos(dProcess-nRetroc)+"' AND '"+dTos(dProcess+nRetroc)+"'"	+CRLF
	cQuery += "				AND "+Tb_LgMon+"."+Tb_LgMon+"_SUCESS = 'S'"																	+CRLF
	cQuery += "				AND "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO = '"+Alltrim(cCodigo)+"'"												+CRLF	
	cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR IN "+cOpcIntegr															+CRLF
	cQuery += "				AND "+Tb_LgMon+".D_E_L_E_T_ = ' '"																			+CRLF
	cQuery +="			  ) AS TEMP"																									+CRLF
	cQuery += "GROUP BY TEMP.HORA"																										+CRLF	
	cQuery += "ORDER BY TEMP.HORA"																										+CRLF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	Do While (cAlias)->(!Eof())
		nPosDad := Ascan(aDados[Len(aDados)][03],{|x| Left(x[01],02) == (cAlias)->HORA })
		If nPosDad > 0
			aDados[Len(aDados)][03][nPosDad,02] += (cAlias)->QTDE
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Next nX
oGrfProjAna := FWChartLine():New()
oGrfProjAna:init( oPan2Dir, .T. )
For nX:=1 to Len(aDados)	
	oGrfProjAna:addSerie(Alltrim(aDados[nX,01]),aDados[nX,03],aDados[nX,02])
Next nX
oGrfProjAna:setLegend( CONTROL_ALIGN_BOTTOM )
oGrfProjAna:Build()


//->> Executados com 100% de sucesso
cQuery := "SELECT"																												+CRLF
cQuery += "		"+Tb_LgMon+"."+Tb_LgMon+"_DATA,"																				+CRLF
cQuery += "		"+Tb_LgMon+"."+Tb_LgMon+"_HORA,"																				+CRLF
cQuery += "		"+Tb_ChMon+"."+Tb_ChMon+"_ICONE,"																				+CRLF
cQuery += "		"+Tb_LgMon+".R_E_C_N_O_ AS RECLOG,"																				+CRLF
cQuery += "		"+Tb_ChMon+".R_E_C_N_O_ AS RECCHA"																				+CRLF
cQuery += "		FROM "+RetSqlName(Tb_LgMon)+" "+Tb_LgMon+" (NOLOCK)"															+CRLF
cQuery += "	INNER JOIN "+RetSqlName(Tb_ChMon)+" "+Tb_ChMon+" (NOLOCK)"															+CRLF
cQuery += "		ON  "+Tb_ChMon+"."+Tb_ChMon+"_FILIAL = '"+xFilial(Tb_ChMon)+"'"													+CRLF
cQuery += "		AND "+Tb_ChMon+"."+Tb_ChMon+"_CODIGO = "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO"										+CRLF
cQuery += "		AND "+Tb_ChMon+"."+Tb_ChMon+"_INTEGR = "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR"										+CRLF
cQuery += "		AND "+Tb_ChMon+".D_E_L_E_T_ = ' '"																				+CRLF
cQuery += "		WHERE 	"+Tb_LgMon+"."+Tb_LgMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"												+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_DATA BETWEEN '"+dTos(dProcess-nRetroc)+"' AND '"+dTos(dProcess+nRetroc)+"'"	+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_SUCESS = 'S'"																	+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO = '"+Alltrim(cCodigo)+"'"												+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR IN "+cOpcIntegr														+CRLF
cQuery += "			AND "+Tb_LgMon+".D_E_L_E_T_ = ' '"																			+CRLF
cQuery += "		ORDER BY "+Tb_LgMon+"."+Tb_LgMon+"_DATA,"																			+CRLF
cQuery += "				 "+Tb_LgMon+"."+Tb_LgMon+"_HORA"																		+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
oExecutados:aCols := {}
aItensOk := {}
Do While (cAlias)->(!Eof())
	(Tb_LgMon)->(dbGoto((cAlias)->RECLOG))	
	(Tb_ChMon)->(dbGoto((cAlias)->RECCHA))	

	aCols := {}
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_DATA"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_HORA"))
	aAdd(aCols,LoadBitmap( GetResources(), Alltrim((Tb_ChMon)->&(Tb_ChMon+"_ICONE"))))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_ALIAS"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_ORDCHV"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_CHAVE"))
	aAdd(aCols,.F.)
	aAdd(oExecutados:aCols,aCols)

	aAdd(aItensOk,{(cAlias)->RECLOG})

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())
If Len(oExecutados:aCols)>0
	oExecutados:oBrowse:lVisible := .T.
Else
	oExecutados:oBrowse:lVisible := .F.
EndIf
oExecutados:Refresh()

//->> Executados com erros
cQuery := "SELECT"																												+CRLF
cQuery += "		"+Tb_LgMon+"."+Tb_LgMon+"_DATA,"																				+CRLF
cQuery += "		"+Tb_LgMon+"."+Tb_LgMon+"_HORA,"																				+CRLF
cQuery += "		"+Tb_ChMon+"."+Tb_ChMon+"_ICONE,"																				+CRLF
cQuery += "		"+Tb_LgMon+".R_E_C_N_O_ AS RECLOG,"																				+CRLF
cQuery += "		"+Tb_ChMon+".R_E_C_N_O_ AS RECCHA"																				+CRLF
cQuery += "	FROM "+RetSqlName(Tb_LgMon)+" "+Tb_LgMon+" (NOLOCK)"																+CRLF
cQuery += "	INNER JOIN "+RetSqlName(Tb_ChMon)+" "+Tb_ChMon+" (NOLOCK)"															+CRLF
cQuery += "		ON  "+Tb_ChMon+"."+Tb_ChMon+"_FILIAL = '"+xFilial(Tb_ChMon)+"'"													+CRLF
cQuery += "		AND "+Tb_ChMon+"."+Tb_ChMon+"_CODIGO = "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO"										+CRLF
cQuery += "		AND "+Tb_ChMon+"."+Tb_ChMon+"_INTEGR = "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR"										+CRLF
cQuery += "		AND "+Tb_ChMon+".D_E_L_E_T_ = ' '"																				+CRLF
cQuery += "		WHERE 	"+Tb_LgMon+"."+Tb_LgMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"												+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_DATA BETWEEN '"+dTos(dProcess-nRetroc)+"' AND '"+dTos(dProcess+nRetroc)+"'"	+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_SUCESS = 'N'"																	+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO = '"+Alltrim(cCodigo)+"'"												+CRLF
cQuery += "			AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR IN "+cOpcIntegr														+CRLF
cQuery += "			AND "+Tb_LgMon+".D_E_L_E_T_ = ' '"																			+CRLF
cQuery += "		ORDER BY "+Tb_LgMon+"."+Tb_LgMon+"_DATA,"																		+CRLF
cQuery += "				 "+Tb_LgMon+"."+Tb_LgMon+"_HORA"																		+CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
oErros:aCols := {}
Do While (cAlias)->(!Eof())
	(Tb_LgMon)->(dbGoto((cAlias)->RECLOG))	
	(Tb_ChMon)->(dbGoto((cAlias)->RECCHA))	

	aCols := {}
	aAdd(aCols,LoadBitmap( GetResources(), "LBNO" ))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_DATA"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_HORA"))
	aAdd(aCols,LoadBitmap( GetResources(), Alltrim((Tb_ChMon)->&(Tb_ChMon+"_ICONE"))))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_ALIAS"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_ORDCHV"))
	aAdd(aCols,(Tb_LgMon)->&(Tb_LgMon+"_CHAVE"))
	aAdd(aCols,(Tb_LgMon)->(Recno()))
	aAdd(aCols,.F.)
	aAdd(oErros:aCols,aCols)
	
	aAdd(aItensErr,{(cAlias)->RECLOG})
	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())
If Len(oErros:aCols)>0
	oErros:oBrowse:lVisible := .T.
Else
	oErros:oBrowse:lVisible := .F.
EndIf
oErros:Refresh()

oTempoAtlz:lActive := .T.

Return

/*/{protheus.doc} GetStyloBt
*******************************************************************************************
Retorna o estilo do botoes
 
@author: Marcelo Celi Marques
@since: 25/08/2020
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
	
	Case nStylo == 3 
	    cEstilo := "QPushButton {background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;}"
    
	Case nStylo == 4 
		//A classe QPushButton, ela Ã© responsÃ¡vel em criar a formataÃ§Ã£o do botÃ£o. 
	    cEstilo := "QPushButton {"  
	    //Usando a propriedade background-image, inserimos a imagem que serÃ¡ utilizada, a imagem pode ser pega pelo repositÃ³rio (RPO)
	    cEstilo += " background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;" 
	    cEstilo += " border-style: outset;"
	    cEstilo += " border-width: 2px;"
	    cEstilo += " border: 1px solid #C0C0C0;"
	    cEstilo += " border-radius: 5px;"
	    cEstilo += " border-color: #C0C0C0;"
		cEstilo += "background:#027F9E;color:white;"
	    cEstilo += " font: bold 12px Arial;"
	    cEstilo += " padding: 6px;"
	    cEstilo += "}"

	Case nStylo == 5 
		cEstilo := "QPushButton {"
		cEstilo += " background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;"
		cEstilo += "background:#027F9E;color:white;"		
		cEstilo += "}"
		
EndCase
               
Return cEstilo

/*/{protheus.doc} AtualCalend
*******************************************************************************************
Atualiza os controles em tela quando clicar no dia do calendario
 
@author: Marcelo Celi Marques
@since: 31/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtualCalend()
dProcess := oCalendario:dDiaAtu
AtuDados()
Return

/*/{protheus.doc} MyAction
*******************************************************************************************
Executa as ações clicadas no menu
 
@author: Marcelo Celi Marques
@since: 31/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MyAction(oTrackMenu, cId, aMyBotoes)
local nPos 	:= 0
Local lOk	:= .T.

nPos := Ascan(aMyBotoes,{|x| x[04]==cId })
If nPos > 0
	If lOk .And. Alltrim(Upper(aMyBotoes[nPos,08]))<>"A"
		MsgAlert("Operação somente pode ser acionada de maneira Receptiva.")
		lOk := .F.
	EndIf

	If lOk .And. aMyBotoes[nPos,06]
		MsgAlert("Operação Indisponível no Momento devido a sua ação estar Bloqueada."+CRLF+"Vide o Configurador do Monitor de Integrações.")
		lOk := .F.
	EndIf

	If lOk
		MsgRun("Executando: "+Alltrim(aMyBotoes[nPos,01]),"Aguarde",{|| Eval(aMyBotoes[nPos,03]) })		
		AtuDados()	
	EndIf
EndIf

Return

/*/{protheus.doc} MaExecM
*******************************************************************************************
Executa a ação em thread diferente
 
@author: Marcelo Celi Marques
@since: 02/09/2020
@param: 
@return:
@type function: Usuário
*******************************************************************************************
/*/
User Function MaExecM(aParam)
Local lConect 	:= .F. 

Default aParam		:= Paramixb
Default aParam[01] 	:= ""
Default aParam[02] 	:= ""

If !Empty(aParam[01]) .And. !Empty(aParam[02])	
	lConect := .T.
	//RPCSETTYPE(3)
	//RPCSETENV(aParam[01],aParam[02],,,'FAT')

	Prepare Environment Empresa aParam[01] Filial aParam[02]
EndIf

Eval(aParam[03])

If lConect
	RpcClearEnv()
EndIf	

UnLockByName(aParam[04], .F. , .F., .F. )

Return

/*/{protheus.doc} AtuMonitor
*******************************************************************************************
Atualização do Monitoramento de execuções
 
@author: Marcelo Celi Marques
@since: 02/09/2020
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function AtuMonitor(cCodigo)
Local aCols  	:= {}
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local aInfo	 	:= {}
Local aDados 	:= {}
Local nX	 	:= 1	
Local nPos	 	:= 0
Local cUser	 	:= ""
Local cNickName	:= ""

cQuery := "SELECT "+Tb_ThMon+".*, "+Tb_ThMon+".R_E_C_N_O_ AS RECTHR"												+CRLF
cQuery += "		FROM "+RetSqlName(Tb_ThMon)+" "+Tb_ThMon+" (NOLOCK)"												+CRLF
cQuery += "	WHERE 	"+Tb_ThMon+"."+Tb_ThMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"										+CRLF
cQuery += "		AND "+Tb_ThMon+"."+Tb_ThMon+"_CODIGO = '"+Alltrim(cCodigo)+"'"										+CRLF
cQuery += "		AND "+Tb_ThMon+".D_E_L_E_T_ = ' '"																	+CRLF
cQuery += "ORDER BY "+Tb_ThMon+"_DATA, "+Tb_ThMon+"_HORA"															+CRLF	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	aAdd(aDados,{ (cAlias)->&(Tb_ThMon+"_DATA"),	;
				  (cAlias)->&(Tb_ThMon+"_HORA"),	;
				  (cAlias)->&(Tb_ThMon+"_IPSRV"),	;
				  (cAlias)->&(Tb_ThMon+"_PORTSR"),	;
				  (cAlias)->&(Tb_ThMon+"_USER"),	;
				  (cAlias)->&(Tb_ThMon+"_USRPRO"),	;
				  (cAlias)->&(Tb_ThMon+"_ENVSRV"),	;
				  (cAlias)->&(Tb_ThMon+"_MAQUIN"),	;
				  (cAlias)->&(Tb_ThMon+"_THREAD"),	;
				  (cAlias)->&(Tb_ThMon+"_IPCLT"),   ;
				  (cAlias)->&(Tb_ThMon+"_NICKNA"),  ;
				  (cAlias)->RECTHR }    )

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

If Len(aDados) > 0
	aInfo := GetUserInfoArray(.F.)
	For nX:=1 to Len(aDados)
		nPos := Ascan(aInfo,{|x| x[03]==aDados[nX,09]})
		If nPos > 0
			cUser := UsrFullName(aDados[nX,06])
			If Empty(cUser)
				cUser := "JOB"
			EndIf
			cNickName := Alltrim(aDados[nX,11])
			aAdd(aCols,{	cUser,						; // 01 - USERNAME
							aDados[nX,07],				; // 02 - ENVIRONM
							aDados[nX,08],				; // 03 - COMPUTER
							aDados[nX,09],				; // 04 - THREADID
							aDados[nX,05],				; // 05 - USERSRV
							aInfo[nPos,05],				; // 06 - PROGRAM							
							aInfo[nPos,08],				; // 07 - ELAPSED
							aInfo[nPos,09],				; // 08 - INSTRUC
							aInfo[nPos,10],				; // 09 - INSTSEC
							aInfo[nPos,11],				; // 10 - COMMENTS
							aInfo[nPos,12],				; // 11 - MEMORY
							.F.	}						) // 12 - Controle de item deletado
		EndIf

		//->> Remove o registro caso a conexao deste tenha caido		
		If LockByName(cNickName,.F.,.F.)
			(Tb_ThMon)->(dbGoto(aDados[nX,12]))
			If (Tb_ThMon)->(!Eof()) .And. (Tb_ThMon)->(!Bof())
				If Reclock(Tb_ThMon,.F.)
					UnLockByName(cNickName,.F.,.F.)
					Delete
					(Tb_ThMon)->(MsUnlock())					
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

oMonitor:aCols := {}				
oMonitor:aCols := aCols
oMonitor:oBrowse:lVisible := .T.
oMonitor:Refresh()

Return

/*/{protheus.doc} VisuOkItens
*******************************************************************************************
Visualiza o item ok
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VisuOkItens(nPos,oFonte,nTipo)
Local oWizard 	:= NIL
Local oPanSup	:= NIL
Local oPanInf	:= NIL
Local oFolder	:= NIL
Local cRequest	:= ""
Local cResponse	:= ""
Local oRequest	:= NIL
Local oResponse	:= NIL
Local cOper		:= ""

Local nModelo		:= 1        
Local lF3			:= .F.
Local lMemoria 		:= .T.
Local lColumn  		:= .F.
Local caTela 		:= ""
Local lNoFolder		:= .F.
Local lProperty		:= .F. 
Local aCpos			:= {}

Default nTipo := 1

If nPos > 0 .And. Len(aItensOk) >= nPos
	(Tb_LgMon)->(dbGoto(aItensOk[nPos,01]))
	RegToMemory(Tb_LgMon, .F.)

	(Tb_ChMon)->(dbSetOrder(1))
	If (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+(Tb_LgMon)->&(Tb_LgMon+"_INTEGR")))
		cOper := Alltrim((Tb_ChMon)->&(Tb_ChMon+"_NOME"))
	Else
		cOper := ""
	EndIf
	cRequest	:= (Tb_LgMon)->&(Tb_LgMon+"_REQUES")
	cResponse	:= (Tb_LgMon)->&(Tb_LgMon+"_RESPON")
	
	If nTipo == 1
		aAdd(aCpos,"NOUSER"    			)
		aAdd(aCpos,Tb_LgMon+"_FILDES"	)
		aAdd(aCpos,Tb_LgMon+"_USER"		)
		aAdd(aCpos,Tb_LgMon+"_ENVSRV"	)
		aAdd(aCpos,Tb_LgMon+"_DATFIM"	)
		aAdd(aCpos,Tb_LgMon+"_HORFIM"	)

		DEFINE WIZARD oWizard 						    										;
			TITLE "Monitor de Integrações"	           											;
					HEADER "Operações em Conformidade" 											;	
					MESSAGE cOper																;
					TEXT "" PANEL					    										;
					NEXT 	{|| .T. } 															;
					FINISH 	{|| .T. }											    			; 

				oPanSup:= TPanel():New(00,00,"",oWizard:GetPanel(1),oFonte,.T.,.T.,,rgb(255,255,255),(oWizard:GetPanel(1):NWIDTH/2),((oWizard:GetPanel(1):NHEIGHT/2)*.35),.T.,.F.)
				oPanSup:Align := CONTROL_ALIGN_TOP
				
				Enchoice(	Tb_LgMon, (Tb_LgMon)->(Recno()), /*(nOpc*/ 2 , /*aCRA*/, /*cLetra*/, /*cTexto*/, ;
				aCpos, {00,00,((oPanSup:NCLIENTHEIGHT)/2)-2,((oPanSup:NCLIENTWIDTH)/2)}, aCpos, nModelo, /*nColMens*/,;
				/*cMensagem*/,/*cTudoOk*/, oPanSup, lF3, lMemoria, lColumn,;
				caTela, lNoFolder, lProperty)

				oPanInf:= TPanel():New(00,00,"",oWizard:GetPanel(1),oFonte,.T.,.T.,,rgb(255,255,255),(oWizard:GetPanel(1):NWIDTH/2),((oWizard:GetPanel(1):NHEIGHT/2)*.65),.F.,.T.)
				oPanInf:Align := CONTROL_ALIGN_ALLCLIENT
				
				oFolder := TFolder():New(0,0,{"Envio","Resposta"},{},oPanInf,,,, .T., .F.,(oPanInf:NWIDTH/2),(oPanInf:NHEIGHT/2),,.T.)
				oFolder:Align := CONTROL_ALIGN_ALLCLIENT

				oRequest  := TMultiGet():New(01,01,{| u | If( PCount() == 0,cRequest, cRequest  := u ) },oFolder:ADIALOGS[1],((oPanInf:NWIDTH)/2)-6,((oPanInf:NHEIGHT)/2)-25,oFonte,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)
				oResponse := TMultiGet():New(01,01,{| u | If( PCount() == 0,cResponse,cResponse := u ) },oFolder:ADIALOGS[2],((oPanInf:NWIDTH)/2)-6,((oPanInf:NHEIGHT)/2)-25,oFonte,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)

		ACTIVATE WIZARD oWizard CENTERED
	Else
		MsgRun("Gerando Visualização...","Aguarde",{|| &((Tb_ChMon)->&(Tb_ChMon+"_FUNREF")) })
	EndIf
EndIf

Return

/*/{protheus.doc} VisuErrItens
*******************************************************************************************
Visualiza o item ok
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function VisuErrItens(nPos,oFonte)
Local oWizard 	:= NIL
Local oPanSup	:= NIL
Local oPanInf	:= NIL
Local oFolder	:= NIL
Local cRequest	:= ""
Local cResponse	:= ""
Local oRequest	:= NIL
Local oResponse	:= NIL
Local cOper		:= ""

Local nModelo		:= 1        
Local lF3			:= .F.
Local lMemoria 		:= .T.
Local lColumn  		:= .F.
Local caTela 		:= ""
Local lNoFolder		:= .F.
Local lProperty		:= .F. 
Local aCpos			:= {}

If Len(oErros:aCols)>0
	If nPos > 0 
		(Tb_LgMon)->(dbGoto(oErros:aCols[nPos,8]))
		RegToMemory(Tb_LgMon, .F.)

		(Tb_ChMon)->(dbSetOrder(1))
		If (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+(Tb_LgMon)->&(Tb_LgMon+"_INTEGR")))
			cOper := Alltrim((Tb_ChMon)->&(Tb_ChMon+"_NOME"))
		Else
			cOper := ""
		EndIf
		cRequest	:= (Tb_LgMon)->&(Tb_LgMon+"_REQUES")
		cResponse	:= (Tb_LgMon)->&(Tb_LgMon+"_RESPON")
		
		aAdd(aCpos,"NOUSER"    			)
		aAdd(aCpos,Tb_LgMon+"_FILDES"	)
		aAdd(aCpos,Tb_LgMon+"_USER"		)
		aAdd(aCpos,Tb_LgMon+"_ENVSRV"	)
		aAdd(aCpos,Tb_LgMon+"_DATFIM"	)
		aAdd(aCpos,Tb_LgMon+"_HORFIM"	)

		DEFINE WIZARD oWizard 						    										;
			TITLE "Monitor de Integrações"	           											;
					HEADER "Operações com Erros" 											;	
					MESSAGE cOper																;
					TEXT "" PANEL					    										;
					NEXT 	{|| .T. } 															;
					FINISH 	{|| .T. }											    			; 

				oPanSup:= TPanel():New(00,00,"",oWizard:GetPanel(1),oFonte,.T.,.T.,,rgb(255,255,255),(oWizard:GetPanel(1):NWIDTH/2),((oWizard:GetPanel(1):NHEIGHT/2)*.35),.T.,.F.)
				oPanSup:Align := CONTROL_ALIGN_TOP
				
				Enchoice(	Tb_LgMon, (Tb_LgMon)->(Recno()), /*(nOpc*/ 2 , /*aCRA*/, /*cLetra*/, /*cTexto*/, ;
				aCpos, {00,00,((oPanSup:NCLIENTHEIGHT)/2)-2,((oPanSup:NCLIENTWIDTH)/2)}, aCpos, nModelo, /*nColMens*/,;
				/*cMensagem*/,/*cTudoOk*/, oPanSup, lF3, lMemoria, lColumn,;
				caTela, lNoFolder, lProperty)

				oPanInf:= TPanel():New(00,00,"",oWizard:GetPanel(1),oFonte,.T.,.T.,,rgb(255,255,255),(oWizard:GetPanel(1):NWIDTH/2),((oWizard:GetPanel(1):NHEIGHT/2)*.65),.F.,.T.)
				oPanInf:Align := CONTROL_ALIGN_ALLCLIENT
				
				oFolder := TFolder():New(0,0,{"Envio","Resposta"},{},oPanInf,,,, .T., .F.,(oPanInf:NWIDTH/2),(oPanInf:NHEIGHT/2),,.T.)
				oFolder:Align := CONTROL_ALIGN_ALLCLIENT

				oRequest  := TMultiGet():New(01,01,{| u | If( PCount() == 0,cRequest, cRequest  := u ) },oFolder:ADIALOGS[1],((oPanInf:NWIDTH)/2)-6,((oPanInf:NHEIGHT)/2)-25,oFonte,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)
				oResponse := TMultiGet():New(01,01,{| u | If( PCount() == 0,cResponse,cResponse := u ) },oFolder:ADIALOGS[2],((oPanInf:NWIDTH)/2)-6,((oPanInf:NHEIGHT)/2)-25,oFonte,.F.,,,,.T.,,.F.,{|| .F.},.F.,.F.,.T./*lReadOnly*/,,,.F.,.F.,.F.)

		ACTIVATE WIZARD oWizard CENTERED
	EndIf
EndIf

Return

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 03/09/2020
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

/*/{protheus.doc} MyEnchBar
*******************************************************************************************
Barra e botoes/menus personalizada
 
@author: Marcelo Celi Marques
@since: 03/09/2020
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

/*/{protheus.doc} MarcTodos
*******************************************************************************************
Marca todos os otens de erro para reprocessamento
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MarcTodos()
Local nX:= 1

For nX:=1 to Len(oErros:aCols)
	oErros:aCols[nX,01] := LoadBitmap( GetResources(), "LBOK" )
	oErros:Refresh()
Next nX

Return

/*/{protheus.doc} DesmTodos
*******************************************************************************************
Desmarca todos os otens de erro para reprocessamento
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function DesmTodos()
Local nX:= 1

For nX:=1 to Len(oErros:aCols)
	oErros:aCols[nX,01] := LoadBitmap( GetResources(), "LBNO" )
	oErros:Refresh()
Next nX

Return

/*/{protheus.doc} TrocaMarc
*******************************************************************************************
Troca a marcação
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TrocaMarc(nPos)
Default nPos := 0

If Len(oErros:aCols)>nPos
	If Upper(Alltrim(oErros:aCols[nPos,01]:cName)) == Upper(Alltrim("LBOK"))
		oErros:aCols[nPos,01] := LoadBitmap( GetResources(), "LBNO" )
	Else
		oErros:aCols[nPos,01] := LoadBitmap( GetResources(), "LBOK" )
	EndIf
EndIf
oErros:Refresh()
Return

/*/{protheus.doc} Reprocess
*******************************************************************************************
Reprocessa todos os otens de erro marcados
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function Reprocess()
Local nX 		:= 1
Local cAlias	:= ""
Local nOrdem	:= 0
Local cChave	:= ""
Local aCols		:= oErros:aCols
Local _cFilAnt	:= cFilAnt
Local aArea		:= GetArea()
Local lOk		:= .T.

If Len(aCols)>0
	If MsgYesNo("Reprocessa todos os itens de erro marcados ?")
		For nX:=1 to Len(aCols)
			If Upper(Alltrim(aCols[nX,01]:cName)) == Upper(Alltrim("LBOK"))
				lOk	:= .T.
				(Tb_LgMon)->(dbGoto(aCols[nX,08]))
				If !(Tb_LgMon)->(Eof()) .And. !(Tb_LgMon)->(Bof())
					(Tb_ChMon)->(dbSetOrder(2))
					If (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+(Tb_LgMon)->&(Tb_LgMon+"_CODIGO+"+Tb_LgMon+"_INTEGR")))
						If Alltrim((Tb_ChMon)->&(Tb_ChMon+"_CONEX"))=="A" .And. !Empty((Tb_ChMon)->&(Tb_ChMon+"_FUNREF"))
							cAlias := Alltrim((Tb_LgMon)->&(Tb_LgMon+"_ALIAS"))						
							If !Empty(cAlias) .And. AliasInDic(cAlias) .And. !Empty((Tb_LgMon)->&(Tb_LgMon+"_FILDES")) .And. !Empty((Tb_LgMon)->&(Tb_LgMon+"_CHAVE"))
								nOrdem  := (Tb_LgMon)->&(Tb_LgMon+"_ORDCHV")
								cChave  := Alltrim((Tb_LgMon)->&(Tb_LgMon+"_CHAVE"))
								cFilAnt := Alltrim((Tb_LgMon)->&(Tb_LgMon+"_FILDES"))
								(cAlias)->(dbSetOrder(nOrdem))
								If (cAlias)->(dbSeek(xFilial(cAlias)+cChave))
									//->> Marcelo Celi - 07/11/2020
									Reclock(Tb_LgMon,.F.)
									Delete
									(Tb_LgMon)->(MsUnlock())
									
									MsgRun("Reprocessando chave: "+Alltrim(cChave),"Aguarde",{|| lOk := &((Tb_ChMon)->&(Tb_ChMon+"_FUNREF")) })
									aCols[nX,Len(oErros:aHeader)+1] := .T.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	oErros:aCols := {}
	//For nX:=1 to Len(aCols)
	//	If !aCols[nX,Len(oErros:aHeader)+1]
	//		aAdd(oErros:aCols,aCols[nX])
	//	EndIf
	//Next nX
	oErros:Refresh()
	aItensErr := {}

	cFilAnt	:= _cFilAnt
	RestArea(aArea)
EndIf

Return

/*/{protheus.doc} ApagarPend
*******************************************************************************************
Apaga os itens pendentes marcados
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ApagarPend()
Local nX 	:= 1
Local aCols	:= oErros:aCols

If Len(aCols)>0
	If MsgYesNo("Limpa todos os itens de erro marcados ?")
		For nX:=1 to Len(aCols)
			If Upper(Alltrim(aCols[nX,01]:cName)) == Upper(Alltrim("LBOK"))			
				(Tb_LgMon)->(dbGoto(aCols[nX,08]))
				If !(Tb_LgMon)->(Eof()) .And. !(Tb_LgMon)->(Bof())
					Reclock(Tb_LgMon)
					Delete
					(Tb_LgMon)->(MsUnlock())
					aCols[nX,Len(oErros:aHeader)+1] := .T.
				EndIf
			EndIf
		Next nX
	EndIf	

	oErros:aCols := {}
	For nX:=1 to Len(aCols)
		If !aCols[nX,Len(oErros:aHeader)+1]
			aAdd(oErros:aCols,aCols[nX])
		EndIf
	Next nX
	oErros:Refresh()
	aItensErr := {}

EndIf

Return

/*/{protheus.doc} MaStMsgMon
*******************************************************************************************
Atualiza a mensagem do status do monitor de integração
 
@author: Marcelo Celi Marques
@since: 18/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaStMsgMon(cMensagem)
aBarStatus[07] := cMensagem
aBarStatus[08]:CtrlRefresh()
Return

/*/{protheus.doc} AssinaInteg
*******************************************************************************************
Assina na tela o desenvolvimento da Integra
 
@author: Marcelo Celi Marques
@since: 10/08/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AssinaInteg(oPanel)
Local oLogo      := NIL
Local bLogo      := {|| ShellExecute("Open", "https://www.integraconsultoriaerp.com.br/", "", "", 1) }
Local cLogo      := "integra.png"

//->> Logo da dfs sistemas
oLogo := TBitmap():New(01,01,(oPanel:nWidth/2)-2,(oPanel:nHeight/2)-1,,"\SYSTEM\"+cLogo,.T.,oPanel,bLogo,,.T.,.T.,,,.F.,,.T.,,.F.)

Return
