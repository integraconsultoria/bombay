#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "apwizard.ch"

Static POSIC_ITEM  	:= 0
Static nCorSelec	:= Rgb(255,201,14)

/*/{protheus.doc} MACfgIntg
*******************************************************************************************
Configurador do Monitor de Integrações
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MACfgIntg()
Private aRotina 	:= MenuDef()
Private cCadastro 	:="Configurador do Monitor de e-Commerce"
Private Tb_Monit    := u_MAPNGetTb("MON")
Private Tb_ChMon    := u_MAPNGetTb("CHM")
Private Tb_LgMon    := u_MAPNGetTb("LOG")
Private Tb_ThMon    := u_MAPNGetTb("THR")

If u_MAVldMonit(Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,.F.)
    //u_MaCpyImgEc()
    mBrowse( 6, 1,22,75,Tb_Monit,,,,,,,,,,,,.F.,.F.)
EndIf

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
Private aRotina := { {"Pesquisar"	, "AxPesqui"  	,0,1,0	,.F.},;
					 {"Visualizar"	, "u_MAMANCFGI"	,0,2,0	,NIL},;
					 {"Incluir"	    , "u_MAMANCFGI"	,0,3,0	,NIL},;
                     {"Alterar"	    , "u_MAMANCFGI"	,0,4,0	,NIL},;
                     {"Excluir"	    , "u_MAMANCFGI"	,0,5,0	,NIL}}
Return aRotina

/*/{protheus.doc} MAMANCFGI
*******************************************************************************************
Manutenção do Configurador
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAMANCFGI(cAlias,nReg,nOpc)
Local oDlg          := NIL
Local oPanel        := NIL
Local oPanSup       := NIL
Local oPanInf       := NIL
Local aSize	    	:= MsAdvSize()
Local aButtons      := {}
Local nOpcA         := 0
Local lEdita        := nOpc == 3 .Or. nOpc == 4
Local aHeader       := {}
Local aCols         := {}
Local aColsTmp      := {}
Local nX            := 1
Local nY            := 1
Local nModelo		:= 1        
Local lF3			:= .F.
Local lMemoria 		:= .T.
Local lColumn  		:= .F.
Local caTela 		:= ""
Local lNoFolder		:= .F.
Local lProperty		:= .F. 
Local aCpoEnch		:= {}
Local bCampo        := { |nCPO| Field(nCPO) }

Private oItens      := {}

If nOpc <> 2
    MsgAlert("Somente a Opera��o de Visualiza��o est� Disponivel.")
    Return
EndIf

//->> Campos visiveis na parte superior da tela
SX3->(dbSetOrder(1))
SX3->(DbSeek(Tb_Monit))
aAdd(aCpoEnch,"NOUSER")
Do While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == Tb_Monit)
	If X3USO(SX3->X3_USADO)
        aAdd(aCpoEnch,Alltrim(SX3->X3_CAMPO))
    EndIf
    SX3->(dbSkip())
EndDo  

//->> montagem do aHeader
SX3->(dbSetOrder(1))
SX3->(DbSeek(Tb_ChMon))
Do While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == Tb_ChMon)
	If X3USO(SX3->X3_USADO)
		If Upper(Alltrim(SX3->X3_CAMPO)) <> Tb_ChMon+"_FILIAL|"+Tb_ChMon+"_CODIGO"
            cValid := Alltrim(SX3->X3_VALID)            
            If Upper(Alltrim(SX3->X3_CAMPO)) == Tb_ChMon+"_INTEGR"
                If !Empty(cValid)
                    cValid += " .And. "
                EndIf
                cValid += "u_MAVLDCFGI()"
            EndIf
            
            Aadd(aHeader,{ 	TRIM(SX3->X3_DESCRIC)	,;
                            SX3->X3_CAMPO			,;
                            SX3->X3_PICTURE			,;
                            SX3->X3_TAMANHO			,;
                            SX3->X3_DECIMAL			,;
                            cValid					,;
                            SX3->X3_USADO			,;
                            SX3->X3_TIPO			,;
                            SX3->X3_F3				,;
                            SX3->X3_CONTEXT 		,; 
                            SX3->X3_CBOX 			,; 
                            Nil			 			,; 
                            Nil			 			,;
                            If(nOpc==3 .Or. nOpc==4,SX3->X3_VISUAL,"V");
                            })            
        EndIf		        			   	
	EndIf
    SX3->(DbSkip())
EndDo

If nOpc == 3 
    RegToMemory( cAlias, .T., .F. )
    m->&(Tb_Monit+"_CODIGO") := u_MACodIntg(Tb_Monit,Tb_Monit+"_CODIGO")
    aColsTmp := {}
    For nX:=1 to Len(aHeader)
        aAdd(aColsTmp,Criavar(aHeader[nX,02],.T.))        
    Next nX
    aAdd(aColsTmp,.F.)
    aAdd(aCols,aColsTmp)
Else
    RegToMemory( cAlias, .F., .F. )
    (Tb_ChMon)->(dbSetOrder(2))
    (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+M->&(Tb_Monit+"_CODIGO")))
    Do While (Tb_ChMon)->(!Eof()) .And. (Tb_ChMon)->&(Tb_ChMon+"_FILIAL+"+Tb_ChMon+"_CODIGO") == xFilial(Tb_ChMon)+M->&(Tb_Monit+"_CODIGO")
        aColsTmp := {}
        For nX:=1 to Len(aHeader)            
            aAdd(aColsTmp,(Tb_ChMon)->&(Alltrim(Upper(aHeader[nX,02]))))            
        Next nX
        aAdd(aColsTmp,.F.)
        aAdd(aCols,aColsTmp)
        (Tb_ChMon)->(dbSkip())
    EndDo
EndIf

Define MsDialog oDlg From 00,00 To aSize[6],aSize[5] Title cCadastro Pixel Of oDlg
oDlg:lMaximized:= .T.

//->> Painel Principal
oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,(oDlg:NCLIENTWIDTH)/2,(oDlg:NCLIENTHEIGHT)/2,.F.,.F. )
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//->> Painel Superior
oPanSup := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,(oPanel:NCLIENTWIDTH)/2,((oPanel:NCLIENTHEIGHT)/2)*.30,.T.,.F. )
oPanSup:Align := CONTROL_ALIGN_TOP

Enchoice(	cAlias, nReg, /*(nOpc*/ nOpc , /*aCRA*/, /*cLetra*/, /*cTexto*/, ;
			aCpoEnch, {00,00,(oPanSup:NCLIENTHEIGHT)/2,(oPanSup:NCLIENTWIDTH)/2}, aCpoEnch, nModelo, /*nColMens*/,;
			/*cMensagem*/,/*cTudoOk*/, oPanSup, lF3, lMemoria, lColumn,;
			caTela, lNoFolder, lProperty)

//->> Painel Inferior
oPanInf := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,(oPanel:NCLIENTWIDTH)/2,((oPanel:NCLIENTHEIGHT)/2)*.70,.F.,.T. )
oPanInf:Align := CONTROL_ALIGN_ALLCLIENT

oItens := MSNewGetDados():New(00,00,((oPanInf:NHEIGHT)/2),((oPanInf:NWIDTH)/2),If(!lEdita,2,GD_INSERT + GD_UPDATE + GD_DELETE),,.T.,,,,,,,,oPanInf,aHeader,aCols)
oItens:bChange := {||POSIC_ITEM := oItens:nAt,oItens:Refresh()}
oItens:oBrowse:SetBlkBackColor({|| GETDCLR(oItens:nAt,POSIC_ITEM,nCorSelec)})	
oItens:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If nOpc <> 2    
    //->> Gravacao
    Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| If(TudoOk(nOpc),(nOpcA:= 1,oDlg:End()),.T.)},;
                                                    {|| If(MsgYesNo("Confirma o Abandono da Manutencao?"),(nOpcA:= 0,oDlg:End()),.T.)},;
                                                    ,aButtons)
Else
    //->> Visualizacao
    Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()},;
                                                    {|| oDlg:End()},;
                                                    ,aButtons)
EndIf

If nOpcA == 1 .And. (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5)
    Begin Transaction

        dbSelectArea(Tb_Monit)
        If nOpc == 3
            Reclock(Tb_Monit,.T.)
        Else
            Reclock(Tb_Monit,.F.)
        EndIf

        For nX := 1 To FCount()
            If Tb_Monit+"_FILIAL" $ FieldName(nX)
                FieldPut(nX,xFilial(Tb_Monit))            
            Else	
                FieldPut(nX,M->&(EVAL(bCampo,nX)))
            EndIf
        Next nX
        (Tb_Monit)->(MsUnLock())

        (Tb_ChMon)->(dbSetOrder(2))        
        (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+M->&(Tb_Monit+"_CODIGO")))
        Do While (Tb_ChMon)->(!Eof()) .And. (Tb_ChMon)->&(Tb_ChMon+"_FILIAL")+(Tb_ChMon)->&(Tb_ChMon+"_CODIGO") == xFilial(Tb_ChMon)+M->&(Tb_Monit+"_CODIGO")
            Reclock(Tb_ChMon,.F.)
            Delete
            (Tb_ChMon)->(MsUnlock())
            (Tb_ChMon)->(dbSkip())
        EndDo

        For nX:=1 to Len(oItens:aCols)
            If !oItens:aCols[nX][Len(aHeader)+1]
                RecLock(Tb_ChMon,.T.)
                (Tb_ChMon)->&(Tb_ChMon+"_FILIAL") := xFilial(Tb_ChMon)
                (Tb_ChMon)->&(Tb_ChMon+"_CODIGO") := M->&(Tb_Monit+"_CODIGO")
                For nY:=1 to Len(aHeader)
                   (Tb_ChMon)->&(Alltrim(Upper(aHeader[nY,02]))) := oItens:aCols[nX,nY]                   
                Next nY
                (Tb_ChMon)->(MsUnlock())
            EndIf
        Next nX

        ConfirmSX8()

    End Transaction
EndIf

Return

/*/{protheus.doc} TudoOk
*******************************************************************************************
Funcao para validacao dos dados
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoOk(nOpc)
Local lRet := .T.

If lRet
    lRet := MsgYesNo("Confirma a Manutencao Realizada no Cadastro ?")
EndIf

Return lRet

/*/{protheus.doc} MAVLDCFGI
*******************************************************************************************
Validação da digitação dos dados
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAVLDCFGI()
Local lRet  := .T.
Local cCpo  :=  Alltrim(Upper(Readvar()))

Do Case
    Case Tb_ChMon+"_INTEGR" $ cCpo
        (Tb_ChMon)->(dbSetOrder(2))
        (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+&(cCpo)))
        Do While (Tb_ChMon)->(!Eof()) .And. (Tb_ChMon)->&(Tb_ChMon+"_FILIAL" + Tb_ChMon+"_INTEGR") == xFilial(Tb_ChMon)+(Tb_ChMon)->&(Tb_ChMon+"_INTEGR")
            If (Tb_ChMon)->&(Tb_ChMon+"_CODIGO") <> M->&(Tb_ChMon+"_CODIGO")
                lRet := .F.
                MsgAlert("Id de Integracao ja infomado em outra integracao...")
                Exit
            EndIf
            (Tb_ChMon)->(dbSkip())
        EndDo

EndCase

Return lRet

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 01/09/2020
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

/*/{protheus.doc} MAGrvLogI
*******************************************************************************************
Gravação do log de entegração
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/

//->> Declaração da variavel estatica para controle do recno do registro
Static _Recno_log := 0

User Function MAGrvLogI(cIdIntegr,cSucesso,cRequest,cResponse,cErrProtheus,cAlias,nOrdem,cChave)
Local aLog          := {}
Local nX            := 1
Local lNew          := .F.

If CanUsePIntg()

    Default cSucesso    := ""
    Default cRequest    := ""
    Default cResponse   := ""
    Default cErrProtheus:= ""
    Default cAlias      := ""
    Default nOrdem      := 0
    Default cChave      := ""
    
    If Empty(cSucesso)
        Public lAutoErrNoFile 	:= .T. 
    EndIf

    If cSucesso == "N" .And. Empty(cErrProtheus)
        aLog := GetAutoGRLog()    
        For nX:=1 to 100
            If nX <= Len(aLog)
                cErrProtheus += aLog[nX]+CRLF
            Else
                Exit
            EndIf		
        Next nX
    EndIf

    If _Recno_log == 0
        Reclock(Tb_LgMon,.T.)
        lNew := .T.
    Else
        (Tb_LgMon)->(dbGoto(_Recno_log))
        Reclock(Tb_LgMon,.F.)
        lNew := .F.
    EndIf

    If lNew
        (Tb_LgMon)->&(Tb_LgMon+"_FILIAL") := xFilial(Tb_LgMon)
        (Tb_LgMon)->&(Tb_LgMon+"_FILDES") := cFilAnt
        (Tb_LgMon)->&(Tb_LgMon+"_INTEGR") := cIdIntegr
        (Tb_ChMon)->(dbSetOrder(1))
        If (Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+cIdIntegr))
            (Tb_LgMon)->&(Tb_LgMon+"_FUNCAO") := (Tb_ChMon)->&(Tb_ChMon+"_FUNCAO")
            (Tb_LgMon)->&(Tb_LgMon+"_CODIGO") := (Tb_ChMon)->&(Tb_ChMon+"_CODIGO")
        EndIf
        (Tb_LgMon)->&(Tb_LgMon+"_DATA")   := Date()   
        (Tb_LgMon)->&(Tb_LgMon+"_HORA")   := Time()
        (Tb_LgMon)->&(Tb_LgMon+"_IPCLT")  := GetClientIP()
        (Tb_LgMon)->&(Tb_LgMon+"_IPSRV")  := GetServerIP()
        (Tb_LgMon)->&(Tb_LgMon+"_PORTSR") := GetPort(1)
        (Tb_LgMon)->&(Tb_LgMon+"_THREAD") := ThreadID()
        (Tb_LgMon)->&(Tb_LgMon+"_USER")   := GetWebJob()
        (Tb_LgMon)->&(Tb_LgMon+"_USRPRO") := RetCodUsr()
        (Tb_LgMon)->&(Tb_LgMon+"_ENVSRV") := GetEnvServer()
        (Tb_LgMon)->&(Tb_LgMon+"_MAQUIN") := GetComputerName()    
    EndIf
    (Tb_LgMon)->&(Tb_LgMon+"_SUCESS") := cSucesso

    If !Empty(cRequest)
        (Tb_LgMon)->&(Tb_LgMon+"_REQUES") := cRequest
    EndIf

    If !Empty(cResponse)
        (Tb_LgMon)->&(Tb_LgMon+"_RESPON") := cResponse
    EndIf

    If !Empty(cErrProtheus)
        (Tb_LgMon)->&(Tb_LgMon+"_ERRPRO") := cErrProtheus
    EndIf

    If !Empty(cAlias)
        (Tb_LgMon)->&(Tb_LgMon+"_ALIAS")  := Upper(Alltrim(cAlias))
    EndIf

    If !Empty(nOrdem)
        (Tb_LgMon)->&(Tb_LgMon+"_ORDCHV") := nOrdem
    EndIf

    If !Empty(cChave)
        (Tb_LgMon)->&(Tb_LgMon+"_CHAVE")  := Alltrim(cChave)
    EndIf

    If !Empty(cSucesso)
        _Recno_log := 0
        (Tb_LgMon)->&(Tb_LgMon+"_DATFIM") := Date()   
        (Tb_LgMon)->&(Tb_LgMon+"_HORFIM") := Time()
    EndIf
    (Tb_LgMon)->(MsUnlock())

    If lNew
        _Recno_log := (Tb_LgMon)->(Recno())
    EndIf
EndIf

Return

/*/{protheus.doc} MACodIntg
*******************************************************************************************
Cria o novo codigo da integração
 
@author: Marcelo Celi Marques
@since: 31/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MACodIntg(cAlias,cCampo)
Local cCodigo := GetSXENum(cAlias,cCampo)

(cAlias)->(dbSetOrder(1))
Do While (cAlias)->(dbSeek(xFilial(cAlias) + cCampo ))
    ConfirmSX8()
    cCodigo := GetSXENum(cAlias,cCampo)
EndDo    

Return cCodigo

/*/{protheus.doc} MASelCor
*******************************************************************************************
seleciona a Cor
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MASelCor()
Local nCorAtu           := &(Readvar())
Local nCorNova          := nCorAtu
Local oWizard           := NIL
Local oTColorTriangle1  := NIL
Local lOk               := .F.
Local bCmd              := {|| }

DEFINE WIZARD oWizard 						    										;
    TITLE "Monitor de Integrações"	           											;
            HEADER "Definição de Cores" 												;	
            MESSAGE "Cores utilizadas nas Legendas dos Paineis do Monitor"				;
            TEXT "" PANEL					    										;
            NEXT 	{|| nCorNova:=oTColorTriangle1:RetColor(),lOk:=.T.,lOk } 			;
            FINISH 	{|| nCorNova:=oTColorTriangle1:RetColor(),lOk:=.T.,lOk }		    ; 

            oTColorTriangle1 := tColorTriangle():New(01,01,oWizard:GetPanel(1),((oWizard:GetPanel(1):nWidth/2)-1),((oWizard:GetPanel(1):nHeight/2)-1)) 
            oTColorTriangle1:SetColorIni(nCorAtu)
            oTColorTriangle1:SetColor(nCorNova)
            oTColorTriangle1:SetSizeTriangle( 400, 160 )

ACTIVATE WIZARD oWizard CENTERED
	
If lOk
    bCmd := "{|| "+Alltrim(Readvar())+" := "+Alltrim(Str(nCorNova))+" }"
    bCmd := &(bCmd)
    Eval(bCmd)
EndIf

Return

/*/{protheus.doc} MASelIco
*******************************************************************************************
seleciona o Icone
 
@author: Marcelo Celi Marques
@since: 01/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MASelIco()
Local cIcone            := &(Readvar())
Local oWizard           := NIL
Local lOk               := .F.
Local bCmd              := {|| }
Local aDados            := {}
Local aIcones           := {}
Local nX                := 1
Local nPos              := 1
Local nIcoInic          := 1

Private __nSel          := 1

cIcone  := Upper(Alltrim(cIcone))
nPos    := AT(".PNG",cIcone)
If nPos>0
    cIcone := Left(cIcone,nPos-1)
EndIf

aAdd(aIcones,{"AFASTAMENTO"})
aAdd(aIcones,{"CONTAINR"})
aAdd(aIcones,{"DBG06"})
aAdd(aIcones,{"DBG09"})
aAdd(aIcones,{"AGENDA"})
aAdd(aIcones,{"DESTINOS"})
aAdd(aIcones,{"DISCAGEM"})
aAdd(aIcones,{"DOWN"})
aAdd(aIcones,{"BMPPOST"})
aAdd(aIcones,{"BMPTABLE"})
aAdd(aIcones,{"BMPTRG"})
aAdd(aIcones,{"BMPUSER"})
aAdd(aIcones,{"BUDGET"})
aAdd(aIcones,{"CADEADO"})
aAdd(aIcones,{"BPMSDOC"})
aAdd(aIcones,{"PCOCUBE"})
aAdd(aIcones,{"LJPRECO"})
aAdd(aIcones,{"POSCLI"})
aAdd(aIcones,{"PRODUTO"})
aAdd(aIcones,{"PMSMATE"})
aAdd(aIcones,{"PMSRELA"})
aAdd(aIcones,{"OBJETIVO"})
aAdd(aIcones,{"CARGASEQ"})
aAdd(aIcones,{"ARMAZEM"})
aAdd(aIcones,{"SALVAR"})
aAdd(aIcones,{"AVGARMAZEM"})
aAdd(aIcones,{"AVGBOX1"})
aAdd(aIcones,{"AVGLBPAR1"})
aAdd(aIcones,{"SIMULACAO"})
aAdd(aIcones,{"COBROWSR"})
aAdd(aIcones,{"SUGESTAO"})
aAdd(aIcones,{"SVM"})
aAdd(aIcones,{"VENDEDOR"})
aAdd(aIcones,{"DEPENDENTES"})
aAdd(aIcones,{"GLOBO"})
aAdd(aIcones,{"CARGA"})
aAdd(aIcones,{"EMPILHADEIRA"})
aAdd(aIcones,{"ESTOMOVI"})
aAdd(aIcones,{"PROCESSA"})
aAdd(aIcones,{"SDUAPPEND"})
aAdd(aIcones,{"TK_REFRESH"})
aAdd(aIcones,{"CLIENTE"})
aAdd(aIcones,{"PMSEXCEL"})

aIcones := aSort(aIcones,,,{|x,y| x[01]<y[01]})
nIcoInic := Ascan(aIcones,{|x| x[01]==cIcone })
If nIcoInic == 0
    nIcoInic := 1
EndIf

For nX:=1 to Len(aIcones)
    bCmd := "{|| __nSel := "+Alltrim(Str(nX))+"}"
    bCmd := &(bCmd)
    aAdd(aDados,{aIcones[nX,01],aIcones[nX,01],{"",Alltrim(aIcones[nX,01])+".PNG"},bCmd,.T.})
Next nX

DEFINE WIZARD oWizard 						    										;
    TITLE "Monitor de Integrações"	           											;
            HEADER "Seleção do Icone"   												;	
            MESSAGE "Icones Utilizados nos Botões dos Paineis do Monitor"				;
            TEXT "" PANEL					    										;
            NEXT 	{|| lOk:=.T.,lOk } 			;
            FINISH 	{|| lOk:=.T.,lOk }		    ; 
            
            oRdImagem := MARadioImg():New()
            oRdImagem:Iniciar(oWizard:GetPanel(1),5,aDados,"Icones",nIcoInic,15,15)

ACTIVATE WIZARD oWizard CENTERED
	
If lOk
    bCmd := "{|| "+Alltrim(Readvar())+" := '"+PadR(Alltrim(aIcones[__nSel,01])+".PNG",Tamsx3(Tb_ChMon+"_ICONE")[01])+"' }"
    bCmd := &(bCmd)
    Eval(bCmd)
EndIf

Return

/*/{protheus.doc} CanUsePIntg
*******************************************************************************************
Retorna de Painel de Integração pode ser Utilizado
 
@author: Marcelo Celi Marques
@since: 18/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CanUsePIntg()
Local lRet      := .F.
Local lCanUse   := Alltrim(Upper(GetNewPar("VY_USEPINT","S")))=="S" 

If lCanUse
    If AliasInDic(Tb_LgMon) .And. AliasInDic(Tb_ChMon) .And. AliasInDic(Tb_Monit)
        lRet := .T.
    EndIf
EndIf

Return lRet

/*/{protheus.doc} EnviaEmail
*******************************************************************************************
Dispara o e-Mail aos Responsaveis pelas aplicações com erros.
 
@author: Marcelo Celi Marques
@since: 19/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function EnviaEmail(cIdIntegr)
Local cAssunto  := ""
Local cDestino  := ""
Local cCopia    := ""
Local cMsg      := ""
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local nX        := 1
Local nY        := 1
Local nZ        := 1
Local aRecnos   := {}
Local nPosX     := 0
Local nPosY     := 0
Local nPosZ     := 0
Local _cFilAnt  := cFilAnt

Default cIdIntegr := ""

cQuery := "SELECT"                                                                                    +CRLF
cQuery += "         "+Tb_LgMon+".R_E_C_N_O_ AS RECLOG,"                                               +CRLF 
cQuery += "         "+Tb_ChMon+".R_E_C_N_O_ AS RECCHA,"                                               +CRLF 
cQuery += "         "+Tb_Monit+".R_E_C_N_O_ AS RECMON"                                                +CRLF 
cQuery += "     FROM "+RetSqlName(Tb_LgMon)+" "+Tb_LgMon+" (NOLOCK)"                                  +CRLF
cQuery += "     INNER JOIN "+RetSqlName(Tb_ChMon)+" "+Tb_ChMon+" (NOLOCK)"                            +CRLF
cQuery += "         ON "+Tb_ChMon+"."+Tb_ChMon+"_FILIAL       = '"+xFilial(Tb_ChMon)+"'"              +CRLF
cQuery += "        AND "+Tb_ChMon+"."+Tb_ChMon+"_CODIGO       = "+Tb_LgMon+"."+Tb_LgMon+"_CODIGO"     +CRLF
cQuery += "        AND "+Tb_ChMon+"."+Tb_ChMon+"_INTEGR   = "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR"         +CRLF
cQuery += "        AND "+Tb_ChMon+".D_E_L_E_T_ = ' '"                                                 +CRLF
cQuery += "     INNER JOIN "+RetSqlName(Tb_Monit)+" "+Tb_Monit+" (NOLOCK)"                            +CRLF
cQuery += "         ON "+Tb_Monit+"."+Tb_Monit+"_FILIAL       = '"+xFilial(Tb_Monit)+"'"              +CRLF
cQuery += "        AND "+Tb_Monit+"."+Tb_Monit+"_CODIGO       = "+Tb_ChMon+"."+Tb_ChMon+"_CODIGO"     +CRLF
cQuery += "        AND "+Tb_Monit+".D_E_L_E_T_ = ' '"                                                 +CRLF
cQuery += "     WHERE   "+Tb_LgMon+"."+Tb_LgMon+"_FILIAL = '"+xFilial(Tb_LgMon)+"'"                   +CRLF
If !Empty(cIdIntegr)
    cQuery += "     AND "+Tb_LgMon+"."+Tb_LgMon+"_INTEGR = '"+cIdIntegr+"'"                           +CRLF
EndIf
cQuery += "         AND "+Tb_LgMon+"."+Tb_LgMon+"_SUCESS = 'N'"                                       +CRLF
cQuery += "         AND "+Tb_LgMon+"."+Tb_LgMon+"_PENDEN = 'S'"                                       +CRLF
cQuery += "         AND "+Tb_LgMon+"."+Tb_LgMon+"_CHAVE <> ' '"                                       +CRLF
cQuery += "         AND LEFT("+Tb_LgMon+"."+Tb_LgMon+"_ULTENV,8) < '"+dTos(Date())+"'"                +CRLF
cQuery += "         AND "+Tb_LgMon+".D_E_L_E_T_ = ' '"                                                +CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
    nPosX := Ascan(aRecnos,{|x| x[01]==(cAlias)->RECMON})
    If nPosX==0
        aAdd(aRecnos,{(cAlias)->RECMON,{}})
        nPosX := Len(aRecnos)
    EndIf

    nPosY := Ascan(aRecnos[nPosX][02],{|y| y[01]==(cAlias)->RECCHA})
    If nPosY==0
        aAdd(aRecnos[nPosX][02],{(cAlias)->RECCHA,{}})
        nPosY := Len(aRecnos[nPosX][02])
    EndIf

    nPosZ := Ascan(aRecnos[nPosX][02][nPosY][02],{|z| z[01]==(cAlias)->RECLOG})
    If nPosZ==0
        (Tb_LgMon)->(dbGoto((cAlias)->RECLOG))
        aAdd(aRecnos[nPosX][02][nPosY][02],{(cAlias)->RECLOG,(Tb_LgMon)->&(Tb_LgMon+"_FILDES"),dTos((Tb_LgMon)->&(Tb_LgMon+"_DATA")),(Tb_LgMon)->&(Tb_LgMon+"_HORA")})
        nPosZ := Len(aRecnos[nPosX][02][nPosY][02])
    EndIf

    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

For nX:=1 to Len(aRecnos)
    (Tb_Monit)->(dbGoto(aRecnos[nX,01]))
    For nY:=1 to Len(aRecnos[nX,02]) 
        (Tb_ChMon)->(dbGoto(aRecnos[nX,02][nY,01]))        
        cAssunto := "Inconsistencias nas Integracoes - "+Alltrim((Tb_Monit)->&(Tb_Monit+"_DESCRI"))+" -> "+Alltrim((Tb_Monit)->&(Tb_Monit+"_DESRED"))+" -> "+Alltrim((Tb_ChMon)->&(Tb_ChMon+"_NOME"))
        cDestino := Alltrim((Tb_ChMon)->&(Tb_ChMon+"_EMAIL"))
        If !Empty(cDestino)
            Begin Transaction
                cMsg := '<html>' + CRLF
                cMsg += '<head>' + CRLF
                cMsg += '<title> A V I S O </title>' + CRLF
                cMsg += '</head>' + CRLF
                cMsg += '<body>' + CRLF
                cMsg += '<b><font size="3" face="Arial">ATENÇÃO</font></b><br><br>' + CRLF
                cMsg += '<b><font size="2" face="Arial">Este é um e-mail de aviso de Inconsistência na Comunicação com '+Alltrim((Tb_Monit)->&(Tb_Monit+"_DESCRI"))+", "+Alltrim((Tb_Monit)->&(Tb_Monit+"_DESRED"))+", "+Alltrim((Tb_ChMon)->&(Tb_ChMon+"_NOME"))+' </font><br><br>' + CRLF

                //->> Ordenar os dados por data e hora de geração
                aRecnos[nX,02][nY,02] := aSort(aRecnos[nX,02][nY,02],,,{|x,y| x[02]+x[03]+x[04] < y[02]+y[03]+y[04] })

                cMsg += '	<Table border="1" cellspacing="0" cellpadding="2">' + CRLF
                cMsg += '   <tr>' + CRLF
                cMsg += '	<td align="center" bgcolor="0A6739"><Font size="1" face="Segoe ui" color="#FFFFFF"><b>Filial</b></Font></td>'               + CRLF
                cMsg += '	<td align="center" bgcolor="0A6739"><Font size="1" face="Segoe ui" color="#FFFFFF"><b>Data</b></Font></td>'                 + CRLF
                cMsg += '	<td align="center" bgcolor="0A6739"><Font size="1" face="Segoe ui" color="#FFFFFF"><b>Hora</b></Font></td>'                 + CRLF
                cMsg += '	<td align="center" bgcolor="0A6739"><Font size="1" face="Segoe ui" color="#FFFFFF"><b>Chave do Registro</b></Font></td>'    + CRLF
                cMsg += '   </tr>' + CRLF

                For nZ:=1 to Len(aRecnos[nX,02][nY,02]) 
                    (Tb_LgMon)->(dbGoto(aRecnos[nX,02][nY,02][nZ,01]))
                    cFilAnt := (Tb_LgMon)->&(Tb_LgMon+"_FILDES")
                    cMsg += '<tr>' + CRLF
                    cMsg += '<td VAlign="center" align="left"><Font size="1" face="Segoe ui">'+xFilial(Tb_LgMon)+(Tb_LgMon)->&(Tb_LgMon+"_ALIAS")   +'</Font></td>'  + CRLF
                    cMsg += '<td VAlign="center" align="center"><Font size="1" face="Segoe ui">'+dToc((Tb_LgMon)->&(Tb_LgMon+"_DATA"))              +'</Font></td>'  + CRLF
                    cMsg += '<td VAlign="center" align="center"><Font size="1" face="Segoe ui">'+Alltrim((Tb_LgMon)->&(Tb_LgMon+"_HORA"))           +'</Font></td>'  + CRLF
                    cMsg += '<td VAlign="center" align="left"><Font size="1" face="Segoe ui">'+Alltrim((Tb_LgMon)->&(Tb_LgMon+"_CHAVE"))            +'</Font></td>'  + CRLF
                    cMsg += '</tr>' + CRLF
                    
                    //->> Guardar a data e hora do ultimo envio
                    Reclock(Tb_LgMon,.F.)
                    (Tb_LgMon)->&(Tb_LgMon+"_ULTENV") := dTos(Date())+" "+Time()
                    (Tb_LgMon)->(MsUnlock())
                Next nZ

                cMsg+="</table>" + CRLF
                cMsg += '<br><br>' + CRLF
                cMsg += '<font size="2" face="Arial">Esta mensagem é automática e não há necessidade de respondê-la.</font><br>' + CRLF
                cMsg += '</body>' + CRLF
                cMsg += '</html>' + CRLF

                lEmail := EnvEMail(cAssunto, "", cDestino, cMsg, .T., "", cCopia)
                If !lEmail
                    DisarmTransaction()
                EndIf

            End Transaction
        EndIf
    Next nY
Next nX

cFilAnt  := _cFilAnt

Return

/*/{protheus.doc} EnvEMail
*******************************************************************************************
Dispara o e-Mail
 
@author: Marcelo Celi Marques
@since: 19/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function EnvEMail(cAssunto,cRemetente,cDestinatario,cMensagem,lMensagem,aArquivo,cCopia)
Local nY
Local cMailServer := Alltrim(GetMV("MV_RELSERV"))	// smtp.office365.com:587
Local cMailConta  := Alltrim(GetMV("MV_RELACNT")) 	// workflow@vyttra.com
Local cMailSenha  := Alltrim(GetMV("MV_RELPSW")) 
Local oServer
Local oMessage
Local nPortaSMTP  := 587
Local xRet        := 0
Local cMsg        := ""
Local nPosPorta   := 0

//Default cArquivo := ""
Default aArquivo  := {} //- Correção efetuada no dia 04/09/2017 - Adriano Sato
Default cCopia    := ""

If Empty(cRemetente)
    cRemetente	:= cMailConta  //Alltrim(GetMV("MV_RELFROM"))
EndIf

//Verifica se a porta foi informada no servidor smtp
nPosPorta := At(":",cMailServer)
If nPosPorta <> 0
    nPortaSMTP		:= Val(substr(cMailServer,nPosPorta+1))
    cMailServer 	:= left(cMailServer,nPosPorta-1)
EndIf 
                                                            
//Alert(cMailServer+" "+cMailConta+" "+cMailSenha+" "+str(nPortaSMTP)) 

//Cria a conexão com o server STMP ( Envio de e-mail )
oServer := TMailManager():New()
oServer:SetUseSSL( .T. )
oServer:SetUseTLS( .T. )
oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPortaSMTP )

//seta um tempo de time out com servidor de 1min
If oServer:SetSmtpTimeOut( 60 ) != 0
    If lMensagem
        MsgAlert("Falha ao setar o time out","Atencao")
    Else
        Conout( "Falha ao setar o time out" )
    Endif
    Return .F.
EndIf

//realiza a conexão SMTP
If oServer:SmtpConnect() != 0
    If lMensagem
        MsgAlert("Falha ao conectar no servidor SMTP","Atencao")
    Else
        Conout( "Falha ao conectar no servidor SMTP" )
    Endif
    Return .F.
EndIf

// authenticate on the SMTP server (if needed)
xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
if xRet <> 0
    cMsg := "Falha na authenticate no SMTP server: " + oServer:GetErrorString( xRet )
    If lMensagem
        MsgAlert(cMsg,"Atencao")
    Else
        Conout( cMsg )
    Endif
    oServer:SMTPDisconnect()
    return .f.
endif

//Apos a conexão, cria o objeto da mensagem
oMessage := TMailMessage():New()

//Limpa o objeto
oMessage:Clear()

//Popula com os dados de envio
oMessage:cFrom              := cRemetente
oMessage:cTo                := cDestinatario
oMessage:cCc                := cCopia
oMessage:cBcc               := ""
oMessage:cSubject           := cAssunto
oMessage:cBody              := cMensagem

//Adiciona um attach
If !Empty(aArquivo)
    For nY := 1 to len(aArquivo)
        If oMessage:AttachFile( aArquivo[ny,6] ) < 0
            If lMensagem
                MsgAlert("Erro ao atachar o arquivo","Atencao")
            Else
                Conout( "Erro ao atachar o arquivo" )
            Endif
            Return .F.
        Else
            //adiciona uma tag informando que é um attach e o nome do arq
            oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+aArquivo[ny,6]+'')
        EndIf
    Next nY
EndIf

//Envia o e-mail
xRet := oMessage:Send( oServer )
if xRet <> 0
    cMsg := "Erro ao enviar o e-mail: " + oServer:GetErrorString( xRet )
    If lMensagem
        MsgAlert(cMsg,"Atencao")
    Else
        Conout( cMsg )
    Endif
    Return .F.
endif

//Desconecta do servidor
If oServer:SmtpDisconnect() <> 0
    If lMensagem
        MsgAlert("Erro ao disconectar do servidor SMTP","Atencao")
    Else
        Conout( "Erro ao disconectar do servidor SMTP" )
    Endif
    Return .F.
EndIf
/*
If lMensagem
    MsgInfo("Email enviado com sucesso !!!","Sucesso")
Else
    Conout( "EMail enviado com sucesso !!!" )
Endif
    */
Return .T.

/*/{protheus.doc} MAJbMailI
*******************************************************************************************
Executa o job diario de disparo de emails dos erros de integração
 
@author: Marcelo Celi Marques
@since: 19/09/2020
@param: 
@return:
@type function: Usuario/JOB
*******************************************************************************************
/*/
User Function MAJbMailI(_cEmp,_cFil)
Local cNickName	:= "MA_JB_MAIL_INTEGR"

Default _cEmp	:= "01"
Default _cFil   := "101AM01"

If LockByName(cNickName,.F.,.F.)
    RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil
	InitPublic()
	SetsDefault()

    If CanUsePIntg()
        EnviaEmail()
    EndIf

    RESET ENVIRONMENT
    UnLockByName(cNickName,.F.,.F.)
EndIf

Return

/*/{protheus.doc} MATiraGrf
*******************************************************************************************
Executa o job diario de disparo de emails dos erros de integração
 
@author: Marcelo Celi Marques
@since: 19/09/2020
@param: 
@return:
@type function: Usuario/JOB
*******************************************************************************************
/*/
User function MATiraGrf(_sOrig)
local _sRet         := _sOrig
Local _cNewString   := ""
Local nX            := 0

_sRet := Alltrim(FwNoAccent(_sRet))
_sRet := StrTran(_sRet,"'","")
_sRet := StrTran(_sRet,'"','')

For nX:=1 to Len(_sRet)
    If Asc(SubStr(_sRet,nX,1)) >= 32 .And. Asc(SubStr(_sRet,nX,1)) <= 127
        _cNewString += SubStr(_sRet,nX,1)
    EndIf
Next nX

Return _cNewString

/*/{protheus.doc} MARegMonit
*******************************************************************************************
Registra acesso as rotinas do monitor
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MARegMonit(cIdIntegr,cTb_ThMon,cTb_ChMon)
Local cNickName := ""
Local nThread   := ThreadID()
Local cCdUser   := RetCodUsr()
Local aArea     := {}
Local aAreaThr  := {}
Local aAreaChm  := {}
Local cId       := dTos(Date())+StrTran(Time(),":","")
Local nRecThr   := 0

Default cTb_ThMon := Tb_ThMon
Default cTb_ChMon := Tb_ChMon

If Empty(cCdUser)
    cCdUser := "JOB"
EndIf
cCdUser   := AllTrim(cCdUser)
cId       := AllTrim(cId)
cNickName := Alltrim(cIdIntegr)+"_"+Alltrim(Str(nThread))+"_"+cCdUser+"_"+cId
cNickName := Alltrim(cNickName)

If LockByName(cNickName,.F.,.F.)
    aAreaChm := (cTb_ChMon)->(GetArea())
    aAreaThr := (cTb_ThMon)->(GetArea())
    aArea := GetArea()

    (cTb_ChMon)->(dbSetOrder(1))
    If (cTb_ChMon)->(dbSeek(xFilial(cTb_ChMon)+cIdIntegr))
        Reclock(cTb_ThMon,.T.)    
        (cTb_ThMon)->&(cTb_ThMon+"_FILIAL") := xFilial(cTb_ThMon)
        (cTb_ThMon)->&(cTb_ThMon+"_FILDES") := cFilAnt
        (cTb_ThMon)->&(cTb_ThMon+"_INTEGR") := cIdIntegr
        (cTb_ThMon)->&(cTb_ThMon+"_FUNCAO") := (cTb_ChMon)->&(cTb_ChMon+"_FUNCAO")
        (cTb_ThMon)->&(cTb_ThMon+"_CODIGO") := (cTb_ChMon)->&(cTb_ChMon+"_CODIGO")
        (cTb_ThMon)->&(cTb_ThMon+"_DATA")   := Date()   
        (cTb_ThMon)->&(cTb_ThMon+"_HORA")   := Time()
        (cTb_ThMon)->&(cTb_ThMon+"_IPCLT")  := GetClientIP()
        (cTb_ThMon)->&(cTb_ThMon+"_IPSRV")  := GetServerIP()
        (cTb_ThMon)->&(cTb_ThMon+"_PORTSR") := GetPort(1)
        (cTb_ThMon)->&(cTb_ThMon+"_THREAD") := ThreadID()
        (cTb_ThMon)->&(cTb_ThMon+"_USER")   := GetWebJob()
        (cTb_ThMon)->&(cTb_ThMon+"_USRPRO") := If(Empty(RetCodUsr()),"JOB",RetCodUsr())
        (cTb_ThMon)->&(cTb_ThMon+"_ENVSRV") := GetEnvServer()
        (cTb_ThMon)->&(cTb_ThMon+"_MAQUIN") := GetComputerName()    
        (cTb_ThMon)->&(cTb_ThMon+"_NICKNA") := cNickName
        (cTb_ThMon)->(MsUnlock())
        nRecThr := (cTb_ThMon)->(Recno())
    EndIf
    (cTb_ChMon)->(RestArea(aAreaChm))
    (cTb_ThMon)->(RestArea(aAreaThr))
    RestArea(aArea)
EndIf

Return nRecThr

/*/{protheus.doc} MAUnRegMon
*******************************************************************************************
Remove o registro acesso as rotinas do monitor
 
@author: Marcelo Celi Marques
@since: 03/09/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MAUnRegMon(nRecThr)
Local aArea := GetArea()

(Tb_ThMon)->(dbGoto(nRecThr))
If (Tb_ThMon)->(!Eof()) .And. (Tb_ThMon)->(!Bof())
    UnLockByName((Tb_ThMon)->&(Tb_ThMon+"_NICKNA"),.F.,.F.)
    Reclock(Tb_ThMon,.F.)
    Delete
    (Tb_ThMon)->(MsUnlock())
EndIf
RestArea(aArea)

Return

/*/{protheus.doc} MAPNGetTb
*******************************************************************************************
Retorna a tabela a usar do Painel
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAPNGetTb(cTipo)
Local cTab         := ""
Local cTb_Monit    := Upper(Alltrim(GetNewPar("IN_TBMONIT","ZZ6")))
Local cTb_ChMon    := Upper(Alltrim(GetNewPar("IN_TBCHAMA","ZZ7")))
Local cTb_LgMon    := Upper(Alltrim(GetNewPar("IN_TBLOGS" ,"ZZ8")))
Local cTb_ThMon    := Upper(Alltrim(GetNewPar("IN_TBTHREA","ZZ9")))

Do Case
    Case cTipo == "MON"
        cTab := cTb_Monit

    Case cTipo == "CHM"
        cTab := cTb_ChMon

    Case cTipo == "LOG"
        cTab := cTb_LgMon

    Case cTipo == "THR"
        cTab := cTb_ThMon    

EndCase

Return cTab

/*/{protheus.doc} MAECGetTb
*******************************************************************************************
Retorna a tabela a usar do Ecommerce
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAECGetTb(cTipo)
Local cTab         := ""
Local cTb_Ferra    := Upper(Alltrim(GetNewPar("IN_TBFERRA","ZZ0"))) 
Local cTb_Ecomm    := Upper(Alltrim(GetNewPar("IN_TBECOMM","ZZ1"))) 
Local cTb_Conex    := Upper(Alltrim(GetNewPar("IN_TBCONEX","ZZ2")))
Local cTb_Produ    := Upper(Alltrim(GetNewPar("IN_TBPRODU","ZZ3")))
Local cTb_Estru    := Upper(Alltrim(GetNewPar("IN_TBESTRU","ZZ4")))
Local cTb_IDS      := Upper(Alltrim(GetNewPar("IN_TBIDS"  ,"ZZ5")))

Do Case
    Case cTipo == "FER"
        cTab := cTb_Ferra

    Case cTipo == "ECO"
        cTab := cTb_Ecomm

    Case cTipo == "CON"
        cTab := cTb_Conex

    Case cTipo == "PRD"
        cTab := cTb_Produ

    Case cTipo == "EST"
        cTab := cTb_Estru

    Case cTipo == "IDS"
        cTab := cTb_IDS

EndCase

Return cTab

/*/{protheus.doc} MACDGetTb
*******************************************************************************************
Retorna a tabela a usar do Ecommerce para cadastros
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MACDGetTb(cTipo)
Local cTab         := ""
Local cTb_Depar    := Upper(Alltrim(GetNewPar("IN_TBDEPAR","ZZA")))
Local cTb_Categ    := Upper(Alltrim(GetNewPar("IN_TBCATEG","ZZB")))
Local cTb_Marca    := Upper(Alltrim(GetNewPar("IN_TBMARCA","ZZC")))
Local cTb_Fabri    := Upper(Alltrim(GetNewPar("IN_TBFABRI","ZZD")))
Local cTb_Canal    := Upper(Alltrim(GetNewPar("IN_TBCANAL","ZZE")))
Local cTb_TbPrc    := Upper(Alltrim(GetNewPar("IN_TBTBPRC","ZZF")))
Local cTb_TbSta    := Upper(Alltrim(GetNewPar("IN_TBTBSTA","ZZG")))
Local cTb_CondP    := Upper(Alltrim(GetNewPar("IN_TBTBPGT","ZZH")))
Local cTb_Transp   := Upper(Alltrim(GetNewPar("IN_TBTBTRA","ZZI")))
Local cTb_Vouche   := Upper(Alltrim(GetNewPar("IN_TBTBDSC","ZZJ"))) 

Do Case    
    Case cTipo == "DEP"
        cTab := cTb_Depar

    Case cTipo == "CAT"
        cTab := cTb_Categ

    Case cTipo == "MRC"
        cTab := cTb_Marca

    Case cTipo == "FAB"
        cTab := cTb_Fabri

    Case cTipo == "CAN"
        cTab := cTb_Canal

   Case cTipo == "TPC"
        cTab := cTb_TbPrc          

   Case cTipo == "STA"
        cTab := cTb_TbSta

   Case cTipo == "PGT"
        cTab := cTb_CondP     

   Case cTipo == "TRA"
        cTab := cTb_Transp     

   Case cTipo == "DSC"
        cTab := cTb_Vouche               

EndCase

Return cTab

/*/{protheus.doc} MAVldMonit
*******************************************************************************************
Valida o uso do monitor
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAVldMonit(cTb_Monit,cTb_ChMon,cTb_LgMon,cTb_ThMon,lJob,lUpd)
Local lRet := .T.
Local cMsg := ""

Default lJob := .F.
Default lUpd := .F.

If Empty(cTb_Monit) .Or. Empty(cTb_ChMon) .Or. Empty(cTb_LgMon) .Or. Empty(cTb_ThMon)
    lRet := .F.
    cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."   +CRLF
    cMsg += "  Vide par�metros:"                                            +CRLF
    cMsg += "       MA_TBMONIT, MA_TBCHAMA, MA_TBLOGS e MA_TBTHREA"         +CRLF+CRLF
    cMsg += "Favor entrar em contato com o Departamento de TI."
    If lJob
        Connout(cMsg)
    Else
        MsgAlert(cMsg)
    EndIf
Else    
    If !lUpd
        If !AliasInDic(cTb_Monit) .Or. !AliasInDic(cTb_ChMon) .Or. !AliasInDic(cTb_LgMon) .Or. !AliasInDic(cTb_ThMon)
            lRet := .F.
            cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."   +CRLF
            cMsg += "  Vide o uso do compatibilizador u_MadUpdEco()"                +CRLF
            cMsg += "Favor entrar em contato com o Departamento de TI."
            If lJob
                ConOut(cMsg)
            Else
                MsgAlert(cMsg)
            EndIf
        EndIf
    EndIf
EndIf

Return lRet

/*/{protheus.doc} MAVldEcomm
*******************************************************************************************
Valida o uso do ecommerce
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAVldEcomm(cTb_Ferra,cTb_Ecomm,cTb_Conex,cTb_Produ,cTb_Estru,cTb_IDS,lJob,lUpd)
Local lRet := .T.
Local cMsg := ""

Default lJob := .F.
Default lUpd := .F.

If Empty(cTb_Ferra) .Or. Empty(cTb_Ecomm) .Or. Empty(cTb_Conex) .Or. Empty(cTb_Produ) .Or. Empty(cTb_Estru) .Or. Empty(cTb_IDS)
    lRet := .F.
    cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."           +CRLF
    cMsg += "  Vide par�metros:"                                                    +CRLF
    cMsg += "       IN_TBFERRA, IN_TBECOMM, IN_TBCONEX, IN_TBPRODU, IN_TBESTRU e IN_TBIDS"      +CRLF+CRLF
    cMsg += "Favor entrar em contato com o Departamento de TI."
    If lJob
        Connout(cMsg)
    Else
        MsgAlert(cMsg)
    EndIf
Else
    If !lUpd
        If !AliasInDic(cTb_Ferra) .Or. !AliasInDic(cTb_Ecomm) .Or. !AliasInDic(cTb_Conex) .Or. !AliasInDic(cTb_Produ) .Or. !AliasInDic(cTb_Estru) .Or. !AliasInDic(cTb_IDS)
            lRet := .F.
            cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."   +CRLF
            cMsg += "  Vide o uso do compatibilizador u_MadUpdEco()"                +CRLF
            cMsg += "Favor entrar em contato com o Departamento de TI."
            If lJob
                ConOut(cMsg)
            Else
                MsgAlert(cMsg)
            EndIf
        EndIf
    EndIf
EndIf

Return lRet

/*/{protheus.doc} MAVldCadEC
*******************************************************************************************
Valida o uso do ecommerce
 
@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAVldCadEC(cTb_Depar,cTb_Categ,cTb_Marca,cTb_Fabri,cTb_Canal,cTb_TbPrc,cTb_TbSta,cTb_CondP,cTb_Transp,cTb_Voucher,lJob,lUpd)
Local lRet := .T.
Local cMsg := ""

Default lJob := .F.
Default lUpd := .F.

If Empty(cTb_Depar) .Or. Empty(cTb_Categ) .Or. Empty(cTb_Marca) .Or. Empty(cTb_Fabri) .Or. Empty(cTb_Canal) .Or. Empty(cTb_TbPrc) .Or. Empty(cTb_TbSta) .Or. Empty(cTb_CondP) .Or. Empty(cTb_Transp) .Or. Empty(cTb_Voucher)
    lRet := .F.
    cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."           +CRLF
    cMsg += "  Vide par�metros:"                                                    +CRLF
    cMsg += "       IN_TBDEPAR, IN_TBCATEG, IN_TBMARCA e IN_TBFABRI, IN_TBCANAL, IN_TBTBPRC, IN_TBTBSTA, IN_TBTBPGT, IN_TBTBTRA, IN_TBTBDSC"+CRLF+CRLF
    cMsg += "Favor entrar em contato com o Departamento de TI."
    If lJob
        Connout(cMsg)
    Else
        MsgAlert(cMsg)
    EndIf
Else
    If !lUpd
        If !AliasInDic(cTb_Depar) .Or. !AliasInDic(cTb_Categ) .Or. !AliasInDic(cTb_Marca) .Or. !AliasInDic(cTb_Fabri) .Or. !AliasInDic(cTb_Canal) .Or. !AliasInDic(cTb_TbPrc) .Or. !AliasInDic(cTb_TbSta) .Or. !AliasInDic(cTb_CondP) .Or. !AliasInDic(cTb_Transp) .Or. !AliasInDic(cTb_Voucher)
            lRet := .F.
            cMsg := "Rotina n�o dispon�vel devido a mesma n�o estar configurada."   +CRLF
            cMsg += "  Vide o uso do compatibilizador u_MadUpdEco()"                +CRLF
            cMsg += "Favor entrar em contato com o Departamento de TI."
            If lJob
                ConOut(cMsg)
            Else
                MsgAlert(cMsg)
            EndIf
        EndIf
    EndIf
EndIf

Return lRet

