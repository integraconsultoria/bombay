#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"

Static Tb_Ferra := ""
Static Tb_Ecomm := ""
Static Tb_Conex := ""
Static Tb_Produ := ""
Static Tb_Estru := ""
Static Tb_IDS   := ""
Static Tb_Monit := ""
Static Tb_ChMon := ""
Static Tb_LgMon := ""
Static Tb_ThMon := ""
Static Tb_Depar := ""
Static Tb_Categ := ""
Static Tb_Marca := ""
Static Tb_Fabri := ""
Static Tb_Canal := ""
Static Tb_TbPrc := ""
Static Tb_TbSta := ""
Static Tb_CondP := ""
Static Tb_Transp:= ""
Static Tb_Voucher:=""
Static FilEcomm := ""
Static Armazem  := ""

/*/{protheus.doc} BoEtq01Vda
*******************************************************************************************
Impressão de Etiquetas de Vendas
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User function BoEtq01Vda(cEmp,cFil)
Local lExecInJob := Select( "SM0" ) <= 0

If lExecInJob    
    Default cEmp	:= "01"
    Default cFil	:= "0101"     
    RpcSetType(3)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil    
EndIf

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    BoEtq01Vda()
EndIf

If lExecInJob
	RESET ENVIRONMENT
EndIf    

Return

Static function BoEtq01Vda()
Local oWizard    := NIL
Local oPanEsq	 := NIL
Local oPanDir	 := NIL
Local lOk        := .F. 
Local cLogotipo  := "fwskin_barcode.png"
Local cTextApres := ""
Local aParambox  := {}
Local aArea		 := {}
Local aCoord     := {0,0,370,580}
Local aNotas	 := {}
Local _cFilAnt	 := ""
Local aCols		 := {}
Local aHeader	 := {} 
Local aButtons	 := {}

Private oEtq	 := NIL
Private aEtq	 := {"100 mm x 150 mmm"}
Private oEtqBy	 := NIL
Private aEtqBy	 := {"por Pedido","por Volume"}

aArea 	 := GetArea()
_cFilAnt := cFilAnt

aHeader := GetaHeader()
Private aRetParam := {cFilAnt,Replicate(" ",Tamsx3("F2_SERIE")[1]),Replicate(" ",Tamsx3("F2_DOC")[1]),Replicate(" ",Tamsx3("F2_DOC")[1]),dDatabase,dDatabase,1,1}

Aadd(aParambox,{1,"Filial"			  ,aRetParam[01]	,"@!"	,"","SM0"	,".F."	,40,.T.})
Aadd(aParambox,{1,"Serie NF"		  ,aRetParam[02]	,"@!"	,"",""		,""		,20,.F.})
Aadd(aParambox,{1,"Nota Fiscal de"	  ,aRetParam[03]	,"@!"	,"",""		,""		,60,.F.})
Aadd(aParambox,{1,"Nota Fiscal ate"	  ,aRetParam[04]	,"@!"	,"",""		,""		,60,.F.})
Aadd(aParambox,{1,"Emissão de"		  ,aRetParam[05]	,""		,"",""		,""		,60,.T.})
Aadd(aParambox,{1,"Emissão ate"		  ,aRetParam[06]	,""		,"",""		,""		,60,.T.})
Aadd(aParambox,{3,"Tamanho Etiqueta"  ,aRetParam[07],aEtq  ,150,".T.",.T.,".T."})  
Aadd(aParambox,{3,"Gerar Etiqueta por",aRetParam[08],aEtqBy,150,".T.",.T.,".T."})  

cTextApres  := "Este programa atende a impressão de etiquetas de Expedição."
cTextApres  += CRLF
cTextApres  += "Favor utilizar as impressoras Térmicas Homologadas ARGOX ou ZEBRA, estas devidamente instaladas na Máquina Local ou Compartilhadas na Rede e configuradas em relação ao tamanho da página."
cTextApres  += CRLF
cTextApres  += "Foi Definido o Tamanhos Default da Etiqueta: 100mm  x  150mm que deve estar configurado nas impressoras listadas acima no Painel de Controle do Windows."
cTextApres  += CRLF
cTextApres  += "A impressão está preparada para considerar economia de memória de spool."

oWizard := APWizard():New("Etiquetas de Expedição", 			 	                             				 ;   // chTitle  - Titulo do cabecalho
                          "Avance para Continuar",  			                                    	    	 ;   // chMsg    - Mensagem do cabecalho
                          "Etiquetas de Expedição", 		     			                                     ;   // cTitle   - Titulo do painel de apresentacao
                          cTextApres,      										     			         	     ;   // cText    - Texto do painel de apresentacao
                            {|| .T. },                                                                           ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| .T. },                                                                           ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            cLogotipo,        	   												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                            {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                            aCoord 		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

oWizard:NewPanel(   "Geração de Etiquetas",  		                        ;   // cTitle   - TÃ­tulo do painel 
                    "Informe o Range de Documentos que serão Considerados na Geração das"+CRLF+"Etiquetas de Expedição e o Tamanho da Etiqueta a ser impressa.",     ;   // cMsg     - Mensagem posicionada no cabeÃ§alho do painel
                    {|| .T. },                                              ;   // bBack    - Bloco de cÃ³digo utilizado para validar o botÃ£o "Voltar"
                    {|| LoadDados(@aNotas,@aCols) },    					;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                    {|| LoadDados(@aNotas,@aCols) }, 						;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                    .T.,                                                    ;   // lPanel   - Se .T. serÃ¡ criado um painel, se .F. serÃ¡ criado um scrollbox
                    {|| .T. }                                               )   // bExecute - Bloco de cÃ³digo a ser executado quando o painel for selecionado
Parambox(aParambox,"Parametros de Geração"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)

oWizard:NewPanel(   "Geração de Etiquetas",  		                        ;   // cTitle   - TÃ­tulo do painel 
                    "Confirme as Etiquetas a Imprimir",                     ;   // cMsg     - Mensagem posicionada no cabeÃ§alho do painel
                    {|| .F. },                                              ;   // bBack    - Bloco de cÃ³digo utilizado para validar o botÃ£o "Voltar"
                    {|| lOk:= MsgYesNo("Confirma as Etiquetas Selecionadas?"),lOk },   					;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                    {|| lOk:= MsgYesNo("Confirma as Etiquetas Selecionadas?"),lOk },   					;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                    .T.,                                                    ;   // lPanel   - Se .T. serÃ¡ criado um painel, se .F. serÃ¡ criado um scrollbox
                    {|| .T. }                                               )   // bExecute - Bloco de cÃ³digo a ser executado quando o painel for selecionado

oPanEsq:= TPanel():New(00,00,"",oWizard:GetPanel(3),oWizard:GetPanel(3):oFont,.T.,.T.,,,(16),(oWizard:GetPanel(3):NHEIGHT/2),.F.,.T.)
oPanEsq:Align := CONTROL_ALIGN_LEFT

aAdd(aButtons,{"LBOK"		,{|| MarcTodos() 							},"Quantificar Todos com 1"}		) 
aAdd(aButtons,{"LBNO"		,{|| DesmTodos() 							},"Zerar Quantidades"}				) 
MyEnchBar(oPanEsq,,,aButtons,/*aButtonTxt*/,.F.,,,3,.T.)

oPanDir:= TPanel():New(00,00,"",oWizard:GetPanel(3),oWizard:GetPanel(3):oFont,.T.,.T.,,,(oWizard:GetPanel(3):NWIDTH/2)-16,(oWizard:GetPanel(3):NHEIGHT/2),.T.,.F.)
oPanDir:Align := CONTROL_ALIGN_RIGHT

oEtq := MSNewGetDados():New(00,00,((oPanDir:NHEIGHT)/2),((oPanDir:NWIDTH)/2),GD_UPDATE,.T.,.T.,,,,,,,,oPanDir,aHeader,aCols)
oEtq:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oWizard:OFINISH:CCAPTION := "Gerar"

//->> Ativacao do Painel
oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                    {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                    {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

If lOk
	PROCESSA({|| PrtEti01(aNotas)}, "Imprimindo Etiquetas...")	
EndIf

RestArea(aArea)	
cFilAnt := _cFilAnt

Return

/*/{protheus.doc} LoadDados
*******************************************************************************************
Extração dos Dados
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function LoadDados(aEtiquetas,aCols)
Local lRet := .F.
PROCESSA({|| lRet := GetEtiquets(@aEtiquetas,@aCols)}, "Extraindo Dados...")
Return lRet

Static Function GetEtiquets(aEtiquetas,aCols)
Local cQuery 	:= ""
Local cTmp1  	:= GetNextAlias()
Local nY		:= 1
Local nVolumes	:= 0
Local cDocNF	:= ""
Local cSerNF    := ""
Local cChvNfe	:= ""
Local cEndereco := ""
Local cEmissao  := ""
Local cNome     := ""
Local dEmissao  := Stod("")
Local lRet      := .F.
Local nQuant	:= 0
Local cTransp   := ""

//->>Marcelo Celi - 27/10/2022
Local cNumVdaSit:= ""
Local cOrigem   := ""

If !Empty(aRetParam[01])
	cFilAnt 	:= aRetParam[01]
	aEtiquetas  := {}
	aCols		:= {}

	cQuery := " SELECT DISTINCT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_EMISSAO, F2_CHVNFE, C5_NUM"	+CRLF 
	//->>Marcelo Celi - 27/10/2022
	cQuery += ", C5_XIDINTG, C5_XORIGEM"+CRLF

	cQuery += " 	FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"																	+CRLF

	cQuery += "	INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"																	+CRLF
	cQuery += "	   ON SD2.D2_FILIAL = SF2.F2_FILIAL"																			+CRLF
	cQuery += "	  AND SD2.D2_DOC    = SF2.F2_DOC"																				+CRLF
	cQuery += "	  AND SD2.D2_SERIE  = SF2.F2_SERIE"																				+CRLF
	cQuery += "   AND SD2.D_E_L_E_T_ = ' '"																    					+CRLF

	cQuery += "	INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK)"																	+CRLF
	cQuery += "	   ON SC5.C5_FILIAL = SD2.D2_FILIAL"																			+CRLF
	cQuery += "	  AND SC5.C5_NUM    = SD2.D2_PEDIDO"																			+CRLF
	cQuery += "   AND SC5.D_E_L_E_T_ = ' '"																    					+CRLF
	cQuery += "   AND SC5.C5_XIDINTG <> ' '"																					+CRLF

	cQuery += " 	WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"																	+CRLF
	cQuery += " 	  AND SF2.F2_DOC BETWEEN '"+aRetParam[03]+"' AND '"+aRetParam[04]+"'"										+CRLF
	cQuery += " 	  AND SF2.F2_SERIE = '"+aRetParam[02]+"'"																	+CRLF
	cQuery += " 	  AND SF2.F2_EMISSAO BETWEEN '"+Dtos(aRetParam[05])+"' AND '"+dTos(aRetParam[06])+"'"						+CRLF
    cQuery += "       AND SF2.F2_CHVNFE <> ' '"                                                             					+CRLF
	cQuery += "       AND SF2.D_E_L_E_T_ = ' '"																					+CRLF
	cQuery += " ORDER BY F2_CLIENTE, F2_LOJA, F2_FILIAL, F2_DOC, F2_SERIE, F2_VOLUME1"											+CRLF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cTMP1,.T.,.T.)
	(cTMP1)->(dbGoTop())
	(cTMP1)->(dbEval({|| nQuant++}))
	(cTMP1)->(dbGoTop())
	
	ProcRegua(nQuant)	
	Do While (cTMP1)->(!Eof())
		IncProc("")		
		nVolumes  := (cTMP1)->F2_VOLUME1
        If nVolumes <= 0
            nVolumes := 1
        EndIf
        
		cDocNF 	  := (cTMP1)->F2_DOC	
        cSerNF    := (cTMP1)->F2_SERIE	
        cChvNfe   := (cTMP1)->F2_CHVNFE	        
        dEmissao  := Stod((cTmp1)->F2_EMISSAO)
        cEmissao  := StrZero(Day(dEmissao),2)+"/"+StrZero(Month(dEmissao),2)+"/"+StrZero(Year(dEmissao),4)        
        cEndereco := ""
		cTransp   := GetTransp((cTmp1)->C5_NUM)
		cNumVdaSit:= Alltrim((cTMP1)->C5_XIDINTG)
		cOrigem   := Alltrim((cTMP1)->C5_XORIGEM)

        SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + (cTMP1)->F2_CLIENTE + (cTMP1)->F2_LOJA ))
            cNome := Alltrim(SA1->A1_NOME)
            cNome := Left(cNome,20)

            If !Empty(SA1->A1_END)
                cEndereco += Alltrim(SA1->A1_END)
            EndIf
            If !Empty(SA1->A1_COMPLEM)
                cEndereco += " - " + Alltrim(SA1->A1_COMPLEM)
            EndIf
            If !Empty(cEndereco)
                cEndereco += CRLF
            EndIf
            If !Empty(SA1->A1_BAIRRO)
                cEndereco += Alltrim(SA1->A1_BAIRRO)
            EndIf
            If !Empty(SA1->A1_MUN)
                cEndereco += " - " + Alltrim(SA1->A1_MUN)
            EndIf
            If !Empty(SA1->A1_EST)
                cEndereco += " - " + Alltrim(SA1->A1_EST)
            EndIf
			If !Empty(SA1->A1_CEP)
				cEndereco += CRLF
                cEndereco += "CEP: " + Transform(Alltrim(SA1->A1_CEP),"@R 99999-999")
            EndIf

			If aRetParam[08] == 1
				//->> Por Pedido
				AAdd(aEtiquetas,{1,cDocNF,cSerNF,"",cEmissao,cChvNfe,cEndereco,cNome,cTransp,cOrigem,cNumVdaSit})
				aAdd(aCols,{1,cDocNF,cSerNF,"",.F.})
			Else
				//->> Por Volume
				For nY := 1 To nVolumes                
					AAdd(aEtiquetas,{1,cDocNF,cSerNF,Strzero(nY,3)+"/"+Strzero(nVolumes,3),cEmissao,cChvNfe,cEndereco,cNome,cTransp,cOrigem,cNumVdaSit})
					aAdd(aCols,{1,cDocNF,cSerNF,Strzero(nY,3)+"/"+Strzero(nVolumes,3),.F.})
				Next nY			
			EndIf

        EndIf
		(cTMP1)->(DbSkip())
	EndDo
	(cTMP1)->(DbCloseArea())

	//->> Documento + Volume
	aEtiquetas := ASort(aEtiquetas,,,{|x,y| x[2]+x[3] < y[2]+y[3] })

Else
	MsgAlert("Filial não Informada...")
EndIf

If Len(aEtiquetas)>0
	lRet := .T.
	oEtq:aCols := aCols
	oEtq:Refresh()
Else
	lRet := .F.
	MsgAlert("Nenhuma Etiqueta Gerada para os dados informados...")
EndIf

Return lRet

/*/{protheus.doc} CmToPx
*******************************************************************************************
Funcao para converter centimetro em pixel.
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CmToPx(nTamanho,cTipo,nTipo)
Local n1Cmxpixel := 0
Local nRedim 	 := 0

Default nTipo := 1

n1Cmxpixel := If(cTipo=="H",If(nTipo==1,106.8376,128.20512),If(nTipo==1,114.79,164.1497))
nRedim 	 := nTamanho*n1Cmxpixel

If nTipo==2
	If cTipo=="H"
		nRedim /= 1.0388
	Else
		nRedim /= 1.307
    EndIf
Else
	If cTipo=="H"
		nRedim *= 1.105    
	EndIf
EndIf

Return nRedim                

/*/{protheus.doc} LoadDados
*******************************************************************************************
Extração dos Dados
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function PrtEti01(aEtiquetas)
Local oPrint            := NIL
Local oProfile          := NIL
Local cFilePrint        := ""
Local nPrintType        := 0
Local aDevice           := {}
Local cDevice           := ""
Local lAdjustToLegacy 	:= .T.
Local lViewPdf	        := .F.
Local nMargSup          := CmToPx(0,"V")
Local nMargInf          := CmToPx(0,"V")
Local nMargEsq          := CmToPx(0,"H")
Local nMargDir          := CmToPx(0,"H")
Local cPastLocal        := "C:\TEMP"
Local nEtiqueta			:= 1
Local nQtdEtq			:= 1
Local lOk				:= .F.
Local lPrnNoFinal		:= .F.
Local cControle			:= StrZero(0,10)
Local nQtdEtqPrn		:= 20
Local nQtdAtuPrn		:= 0
Local _cFilename   		:= ""
Local _cFileprint  		:= ""
Local _cPathPrint  		:= ""
Local _cPrinter    		:= ""
Local _cSession    		:= ""
Local _cSpoolLocal 		:= ""
Local _lServer     		:= .F.
Local _nDevice     		:= 0
Local aApagar			:= {}
Local nX				:= 0
Local lMv_Logod     	:= If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local cGrpCompany		:= ""
Local cCodEmpGrp		:= ""
Local cUnitGrp			:= ""
Local cFilGrp			:= ""
Local cDescLogo			:= ""
Local cLogo      		:= FisxLogo("1")
Local cLogoD			:= ""
Local cNome				:= ""
Local cRemetente		:= ""
Local cEndRemetent		:= ""
Local lPrnLinha			:= .T.
Local nFontSize			:= 0
Local cLogoPB			:= "logopb_"+Alltrim(cEmpAnt)+Alltrim(cFilAnt)+".png"

//->>Marcelo Celi - 27/10/2022
Local cTransEspec       := Alltrim(Upper(GetNewPar("BO_TRPESPC","EU ENTREGO")))

If lMv_Logod
	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())

	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cDescLogo + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
	EndIf
EndIf

MakeDir(cPastLocal)

If nQtdEtqPrn == 0
	nQtdEtqPrn := 20
EndIf

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

oProfile    := FWProfile():New()
oProfile:SetTask('PRINTTYPE')   
cDevice := oProfile:LoadStrProfile()

nPrintType := aScan(aDevice,{|x| x == cDevice })
If nPrintType == 0
	nPrintType := 2
EndIf

cFilePrint := "MoNewEtq1A_DrvWin_"+dTos(Date())+"-"+StrTran(Time(),":","")+"-A"
Do While File(cFilePrint+".rel")
	cFilePrint := Soma1(cFilePrint)
EndDo

oPrint := FWMSPrinter():New(cFilePrint, nPrintType, lAdjustToLegacy,cPastLocal,.T.,,,,,,,lViewPdf)
oPrint:SetLandscape()
oPrint:SetResolution(78)
//oPrint:SetPortrait()
oPrint:SetMargin(nMargEsq,nMargSup,nMargDir,nMargInf)
oPrint:Setup()

If oPrint:nModalResult == 1 //PD_OK
	oProfile:SetTask('PRINTTYPE')   
	oProfile:SetStringProfile(If(oPrint:nDevice==2, "SPOOL", "PDF"))
	oProfile:Save()
	
	_cFilename   := oPrint:cFileName
	_cFileprint  := oPrint:cFilePrint
	_cPathPrint  := oPrint:cPathPrint
	_cPrinter    := oPrint:cPrinter
	_cSession    := oPrint:cSession
	_cSpoolLocal := oPrint:cSpoolLocal
	_lServer     := oPrint:lServer
	_nDevice     := oPrint:nDevice		

	aAdd(aApagar,{oPrint:cFileName,oPrint:cFilePrint})

	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	cNome := Alltrim(SM0->M0_NOMECOM)
	cRemetente := ""

	If !Empty(SM0->M0_ENDENT)		
		cRemetente += Alltrim(SM0->M0_ENDENT)
		If !Empty(SM0->M0_COMPENT)
			cRemetente += " - " + Alltrim(SM0->M0_COMPENT)
		EndIf
	EndIf	
	
	cEndRemetent := ""
	If !Empty(SM0->M0_BAIRENT)		
		cEndRemetent += Alltrim(SM0->M0_BAIRENT)
	EndIf	
	If !Empty(SM0->M0_CIDENT)
		cEndRemetent += " - " + Alltrim(SM0->M0_CIDENT)
	EndIf	
	If !Empty(SM0->M0_ESTENT)
		cEndRemetent += " - " + Alltrim(SM0->M0_ESTENT)
	EndIf	

	If !Empty(SM0->M0_CEPENT)		
		If (Len(cRemetente) + Len(cEndRemetent)) <=40
			cEndRemetent += CRLF
			cEndRemetent += "CEP: " + Alltrim(SM0->M0_CEPENT)
		Else
			cEndRemetent += " - CEP: " + Transform(Alltrim(SM0->M0_CEPENT),"@R 99999-999")
		EndIf	
	EndIf
	cRemetente += " - " + cEndRemetent

	For nEtiqueta := 1 to Len(aEtiquetas)
		For nQtdEtq := 1 to oEtq:aCols[nEtiqueta,01]
			nQtdAtuPrn++
			
			oPrint:StartPage()
			If aRetParam[07] == 1
				If lPrnLinha
                	oPrint:Box(CmToPx(0.00,"V"),CmToPx(0.00,"H"),CmToPx(10,"V"),CmToPx(15,"H"), "-4")
				EndIf

				//LOGOTIPO DA EMPRESA				
				If File(cLogoPB)
					oPrint:SayBitmap(CmToPx(0.50,"V"),CmToPx(0.50,"H"),cLogoPB,CmToPx(3.00,"H"),CmToPx(1.50,"V"))
				Else
					If lMv_Logod
						oPrint:SayBitmap(CmToPx(0.10,"V"),CmToPx(0.50,"H"),cLogoD,CmToPx(3.00,"H"),CmToPx(2.00,"V"))
					Else
						oPrint:SayBitmap(CmToPx(0.10,"V"),CmToPx(0.50,"H"),cLogo ,CmToPx(3.00,"H"),CmToPx(2.00,"V"))
					EndIF
				EndIf
				oPrint:SayAlign (CmToPx(0.50,"V"),CmToPx(4.00,"H"),"Remetente:"            ,TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(0.70,"V"),CmToPx(4.00,"H"),cNome,TFont():New("CALIBRI"  ,,22,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(3.50,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(1.38,"V"),CmToPx(4.00,"H"),cRemetente,TFont():New("CALIBRI"  ,,13,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(10.00,"H"),/*Altura*/CmToPx(2.50,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)

				//->> Duas chamadas para realçar a linha
				oPrint:Box(CmToPx(2.45,"V"),CmToPx(0.25,"H"),CmToPx(6.25,"V"),CmToPx(14.75,"H"), "-4")
				oPrint:Box(CmToPx(2.45,"V"),CmToPx(0.25,"H"),CmToPx(6.25,"V"),CmToPx(14.75,"H"), "-4")

				//NF SAIDA
				oPrint:SayAlign (CmToPx(2.60,"V"),CmToPx(0.50,"H"),"Documento:"            ,TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(2.80,"V"),CmToPx(0.50,"H"),aEtiquetas[nEtiqueta,02],TFont():New("CALIBRI"  ,,25,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)

   				//NF SERIE
				oPrint:SayAlign (CmToPx(2.60,"V"),CmToPx(5.50,"H"),"Serie:"                ,TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(2.75,"V"),CmToPx(5.50,"H"),aEtiquetas[nEtiqueta,03],TFont():New("CALIBRI"  ,,25,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)

				//TRANSPORTADORA
				oPrint:SayAlign (CmToPx(2.60,"V"),CmToPx(7.50,"H"),"Transportadora:",TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(2.80,"V"),CmToPx(7.50,"H"),Left(Upper(aEtiquetas[nEtiqueta,09]),25),TFont():New("CALIBRI"  ,,18,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(07.00,"H"),/*Altura*/CmToPx(2.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)


				//->>Marcelo Celi - 27/10/2022
				If Upper(Alltrim(aEtiquetas[nEtiqueta,10])) == "VTEX" .And. Alltrim(Left(Upper(aEtiquetas[nEtiqueta,09]),25)) $ cTransEspec
					//CODIGO DA VENDA VTEX
					oPrint:Say(CmToPx(4.13,"V"),CmToPx(0.50,"H"),"NUMERO DO PEDIDO VTEX",TFont():New("Arial"  ,,14,,/*Negrito*/.T.,,,,,.F. ))
					nFontSize := 45
					oPrint:Code128C(CmToPx(5.50,"V"),CmToPx(0.50,"H"),Alltrim(aEtiquetas[nEtiqueta,11]), nFontSize )
					oPrint:SayAlign (CmToPx(5.60,"V"),CmToPx(0.50,"H"),Alltrim(aEtiquetas[nEtiqueta,11]),TFont():New("CALIBRI"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(14.50,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				Else
					//CODIGO DE BARRAS DA CHAVE DA NOTA
					oPrint:Say(CmToPx(4.13,"V"),CmToPx(0.50,"H"),"CHAVE DE ACESSO DA NF-E",TFont():New("Arial"  ,,14,,/*Negrito*/.T.,,,,,.F. ))
					nFontSize := 45
					oPrint:Code128C(CmToPx(5.50,"V"),CmToPx(0.50,"H"),aEtiquetas[nEtiqueta,06], nFontSize )
					oPrint:SayAlign (CmToPx(5.60,"V"),CmToPx(0.50,"H"),TransForm(aEtiquetas[nEtiqueta,06],"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),TFont():New("CALIBRI"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(14.50,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				EndIf

				oPrint:Box(CmToPx(6.20,"V"),CmToPx(0.25,"H"),CmToPx(9.75,"V"),CmToPx(14.75,"H"), "-4")

                //NOME
				oPrint:SayAlign (CmToPx(6.40,"V"),CmToPx(0.50,"H"),"Destinatario:",TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
				oPrint:SayAlign (CmToPx(6.65,"V"),CmToPx(0.50,"H"),aEtiquetas[nEtiqueta,08],TFont():New("CALIBRI"  ,,22,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)

				//VOLUME
				If aRetParam[08] == 2
                	oPrint:SayAlign (CmToPx(6.40,"V"),CmToPx(10.00,"H"),"Volume:"                ,TFont():New("Arial"  ,,12,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(09.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)
					oPrint:SayAlign (CmToPx(6.30,"V"),CmToPx(11.10,"H"),aEtiquetas[nEtiqueta,04],TFont():New("CALIBRI"  ,,13,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(10.00,"H"),/*Altura*/CmToPx(1.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)			
				EndIf

                //ENDEREÇO				
				oPrint:SayAlign (CmToPx(7.50,"V"),CmToPx(0.50,"H"),aEtiquetas[nEtiqueta,07],TFont():New("CALIBRI"  ,,16,,/*Negrito*/.T.,,,,,.F. ),/*Largura*/CmToPx(12.00,"H"),/*Altura*/CmToPx(3.00,"V"),/*nCor_texto*/,/*Alinh_Horz*/ 0 /*(Esquerda)*/,/*Alinh_Vert*/ 1 /*(Superior)*/)

			EndIf
			oPrint:EndPage()

			If !lPrnNoFinal .And. nQtdAtuPrn == nQtdEtqPrn
				nQtdAtuPrn := 0

				oPrint:Print()
				fwFreeObj(oPrint)

				cNewFilePrint := Lower(cFilePrint)
				cControle := Soma1(cControle)
				cNewFilePrint += "-"+cControle

				oPrint := FWMSPrinter():New(cNewFilePrint, nPrintType, lAdjustToLegacy,cPastLocal,.T.,,,,,,,lViewPdf)
				oPrint:SetLandscape()
				oPrint:SetResolution(78)
				//oPrint:SetPortrait()
				oPrint:SetMargin(nMargEsq,nMargSup,nMargDir,nMargInf)
								
				_cFileprint := StrTran(_cFileprint,Lower(cFilePrint),Lower(cFilePrint)+"-"+cControle)
				_cFilename  := StrTran(_cFilename,Lower(cFilePrint),Lower(cFilePrint)+"-"+cControle)
				
				oPrint:cPrinter     := _cPrinter
				oPrint:cSession     := _cSession				
				oPrint:lServer      := _lServer
				oPrint:nDevice	    := _nDevice	
				oPrint:nModalResult := 1

				aAdd(aApagar,{oPrint:cFileName,oPrint:cFilePrint})
			EndIf
			lOk := .T.		
		Next nQtdEtq
	Next nEtiqueta

	If lOk		
		If lPrnNoFinal .Or. nQtdAtuPrn>0
			oPrint:Print()
		EndIf	
	Else
		MsgAlert("Nenhuma Etiqueta foi Impressa...")
	EndIf	
EndIf

//->> Apagar os arquivos de impressão temporarios
For nX:=1 to Len(aApagar)
	If File(aApagar[nX,02])
		FErase(aApagar[nX,02])
	EndIf
Next nX

Return

/*/{protheus.doc} LoadDados
*******************************************************************************************
Extração dos Dados
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetaHeader()
Local aHeader := {}

Aadd(aHeader,{	"Qt Etq"						,;
				"XQTETQ"						,;
				"@E 999"						,;
				3								,;
				0								,;
				""								,;
				""								,;
				"N"								,;
				""								,;
				"V" 							,; 
				"" 								,; 
				Nil			 					,; 
				Nil			 		   			,;
				"A"				   				 ;
				})         

Aadd(aHeader,{	"Documento"						,;
				"DOCUMENTO"						,;
				"@!"							,;
				09								,;
				0								,;
				""								,;
				""								,;
				"C"								,;
				""								,;
				"V" 							,; 
				"" 								,; 
				Nil			 					,; 
				Nil			 		   			,;
				"V"				   				 ;
				})         

Aadd(aHeader,{	"Serie"	    					,;
				"SERIE"		    				,;
				"@!"							,;
				03								,;
				0								,;
				""								,;
				""								,;
				"C"								,;
				""								,;
				"V" 							,; 
				"" 								,; 
				Nil			 					,; 
				Nil			 		   			,;
				"V"				   				 ;
				})

Aadd(aHeader,{	"Volume"						,;
				"VOLUME"						,;
				"@!"							,;
				09								,;
				0								,;
				""								,;
				""								,;
				"C"								,;
				""								,;
				"V" 							,; 
				"" 								,; 
				Nil			 					,; 
				Nil			 		   			,;
				"V"				   				 ;
				})         

Return aHeader

/*/{protheus.doc} MyEnchBar
*******************************************************************************************
Barra e botoes/menus personalizada
 
@author: Marcelo Celi Marques
@since: 03/03/2022
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
Marca Todos
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MarcTodos()
Local nX := 1

For nX:=1 to Len(oEtq:aCols)
	oEtq:aCols[nX,01] := 1
Next nX
oEtq:Refresh()

Return

/*/{protheus.doc} DesmTodos
*******************************************************************************************
Desmarca Todos
 
@author: Marcelo Celi Marques
@since: 03/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function DesmTodos()
Local nX := 1

For nX:=1 to Len(oEtq:aCols)
	oEtq:aCols[nX,01] := 0
Next nX
oEtq:Refresh()

Return

/*/{protheus.doc} GetTransp
*******************************************************************************************
Retorna a transportadora do pedido ecommerce
 
@author: Marcelo Celi Marques
@since: 10/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetTransp(cNumPed)
Local cTransp 	 := ""
Local aOrcamento := {}
Local nX		 := 0 	
Local aArea		 := GetARea()
Local aAreaSCJ   := SCJ->(GetARea())
Local aAreaSCK   := SCK->(GetARea())
Local aAreaSC5   := SC5->(GetARea())
Local aAreaSC6   := SC6->(GetARea())

If SCJ->(FieldPos("CJ_XTRANSP"))>0	
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cNumPed))
		SCJ->(dbOrderNickname("CJXORIGEM"))
		If SCJ->(dbSeek(xFilial("SCJ")+SC5->(C5_XORIGEM+C5_XIDINTG)))
			cTransp := SCJ->CJ_XTRANSP
		Else		
			SC6->(dbSetOrder(1))
			SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
				If !Empty(SC6->C6_NUMORC)
					SCK->(dbSetOrder(1))
					If SCK->(dbSeek(xFilial("SCK")+SC6->C6_NUMORC))
						If aScan(aOrcamento,{|x| x==SCK->CK_NUM})==0
							aAdd(aOrcamento,SCK->CK_NUM)
						EndIf
					EndIf
				EndIf
				SC6->(dbSkip())
			EndDo		
			SCJ->(dbSetOrder(1))
			For nX:=1 to Len(aOrcamento)
				If SCJ->(dbSeek(xFilial("SCJ")+aOrcamento[nX]))
					cTransp := SCJ->CJ_XTRANSP
				EndIf
			Next nX
		EndIf
	EndIf	
EndIf

SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
SCK->(RestArea(aAreaSCK))
SCJ->(RestArea(aAreaSCJ))
RestArea(aArea)

Return cTransp


 
