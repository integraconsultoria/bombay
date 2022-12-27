#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "apwizard.ch"

Static POSIC_ITEM  	:= 0
Static nCorSelec	:= Rgb(255,201,14)

/*/{protheus.doc} MadCfgConn
*******************************************************************************************
Configurador das Conexões
 
@author: Marcelo Celi Marques
@since: 19/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MadCfgConn()
Private aRotina 	:= MenuDef()
Private cCadastro 	:="Configurador das Conexões e-Commerce"

Private Tb_Ferra := u_MAECGetTb("FER")
Private Tb_Ecomm := u_MAECGetTb("ECO")
Private Tb_Conex := u_MAECGetTb("CON")
Private Tb_Produ := u_MAECGetTb("PRD")
Private Tb_Estru := u_MAECGetTb("EST")
Private Tb_IDS   := u_MAECGetTb("IDS")

Private Tb_Monit := u_MAPNGetTb("MON")
Private Tb_ChMon := u_MAPNGetTb("CHM")
Private Tb_LgMon := u_MAPNGetTb("LOG")
Private Tb_ThMon := u_MAPNGetTb("THR")

If u_MAVldEcomm(Tb_Ferra,Tb_Ecomm,Tb_Conex,Tb_Produ,Tb_Estru,Tb_IDS,.F.,.F.) .And. ;
   u_MAVldMonit(Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,.F.)

    mBrowse( 6, 1,22,75,Tb_Ecomm,,,,,,,,,,,,.F.,.F.)
EndIf

Return

/*/{protheus.doc} MenuDef
*******************************************************************************************
Menu do configurador
 
@author: Marcelo Celi Marques
@since: 19/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  	,0,1,0	,.F.},;
					 {"Visualizar"	, "u_MACONNMAN"	,0,2,0	,NIL},;
					 {"Incluir"	    , "u_MACONNMAN"	,0,3,0	,NIL},;
                     {"Alterar"	    , "u_MACONNMAN"	,0,4,0	,NIL},;
                     {"Exclusão"	, "u_MACONNMAN"	,0,5,0	,NIL}}
Return aRotina

/*/{protheus.doc} MACONNMAN
*******************************************************************************************
ManutenÃ§Ã£o do Configurador
 
@author: Marcelo Celi Marques
@since: 19/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MACONNMAN(cAlias,nReg,nOpc)
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
Local aConexoes     := {}

Private oItens      := {}

aAdd(aConexoes,{"GPV","RETORNO DE VENDAS"       })
aAdd(aConexoes,{"GCL","RETORNO DE CLIENTES"     })
aAdd(aConexoes,{"GPR","RETORNO DE PRODUTOS"     })
aAdd(aConexoes,{"UPR","SUBIDA DE PRODUTOS"      })
aAdd(aConexoes,{"UES","SUBIDA DE ESTOQUES"      })
aAdd(aConexoes,{"UPC","SUBIDA DE PREÇOS"        })
aAdd(aConexoes,{"GSK","RETORNO DE SKU"          })
aAdd(aConexoes,{"USK","GRAVACAO DE SKU"         })
aAdd(aConexoes,{"UST","ATUALIZAÇÃO DE STATUS"   })
aAdd(aConexoes,{"GPS","RETORNO PRODUTOS POR SKU"})

//->> Campos visiveis na parte superior da tela
SX3->(dbSetOrder(1))
SX3->(DbSeek(Tb_Ecomm))
aAdd(aCpoEnch,"NOUSER")
Do While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == Tb_Ecomm)
	If X3USO(SX3->X3_USADO)
        aAdd(aCpoEnch,Alltrim(SX3->X3_CAMPO))
    EndIf
    SX3->(dbSkip())
EndDo  

//->> montagem do aHeader
SX3->(dbSetOrder(1))
SX3->(DbSeek(Tb_Conex))
Do While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == Tb_Conex)
	If X3USO(SX3->X3_USADO)
		If Upper(Alltrim(SX3->X3_CAMPO)) <> Tb_Conex+"_FILIAL|"+Tb_Conex+"_CODIGO"
            cValid := Alltrim(SX3->X3_VALID)
            
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
    For nY:=1 to Len(aConexoes)
        aColsTmp := {}
        For nX:=1 to Len(aHeader)
            If Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_CDPATH"
                aAdd(aColsTmp,aConexoes[nY,01])
            ElseIf Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_DESCRI"
                aAdd(aColsTmp,aConexoes[nY,02])
            Else            
                aAdd(aColsTmp,Criavar(aHeader[nX,02],.T.))
            EndIf
        Next nX
        aAdd(aColsTmp,.F.)
        aAdd(aCols,aColsTmp)
    Next nY        
Else
    RegToMemory( cAlias, .F., .F. )
    For nY:=1 to Len(aConexoes)
        (Tb_Conex)->(dbSetOrder(1))
        aColsTmp := {}
        If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+M->&(Tb_Ecomm+"_CODIGO")+aConexoes[nY,01]))            
            For nX:=1 to Len(aHeader)
                If Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_CDPATH"
                    aAdd(aColsTmp,aConexoes[nY,01])
                ElseIf Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_DESCRI"
                    aAdd(aColsTmp,aConexoes[nY,02])
                Else                
                    aAdd(aColsTmp,(Tb_Conex)->&(Alltrim(Upper(aHeader[nX,02]))))
                EndIf    
            Next nX
        Else
            For nX:=1 to Len(aHeader)
                If Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_CDPATH"
                    aAdd(aColsTmp,aConexoes[nY,01])
                ElseIf Alltrim(Upper(aHeader[nX,02])) == Tb_Conex+"_DESCRI"
                    aAdd(aColsTmp,aConexoes[nY,02])
                Else            
                    aAdd(aColsTmp,Criavar(aHeader[nX,02],.T.))
                EndIf
            Next nX
        EndIf
        aAdd(aColsTmp,.F.)
        aAdd(aCols,aColsTmp)
    Next nY
EndIf

Define MsDialog oDlg From 00,00 To aSize[6],aSize[5] Title cCadastro Pixel Of oDlg
oDlg:lMaximized:= .T.

//->> Painel Principal
oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,(oDlg:NCLIENTWIDTH)/2,(oDlg:NCLIENTHEIGHT)/2,.F.,.F. )
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//->> Painel Superior
oPanSup := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,(oPanel:NCLIENTWIDTH)/2,((oPanel:NCLIENTHEIGHT)/2)*.55,.T.,.F. )
oPanSup:Align := CONTROL_ALIGN_TOP

Enchoice(	cAlias, nReg, /*(nOpc*/ nOpc , /*aCRA*/, /*cLetra*/, /*cTexto*/, ;
			aCpoEnch, {00,00,(oPanSup:NCLIENTHEIGHT)/2,(oPanSup:NCLIENTWIDTH)/2}, aCpoEnch, nModelo, /*nColMens*/,;
			/*cMensagem*/,/*cTudoOk*/, oPanSup, lF3, lMemoria, lColumn,;
			caTela, lNoFolder, lProperty)

//->> Painel Inferior
oPanInf := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,(oPanel:NCLIENTWIDTH)/2,((oPanel:NCLIENTHEIGHT)/2)*.45,.F.,.T. )
oPanInf:Align := CONTROL_ALIGN_ALLCLIENT

oItens := MSNewGetDados():New(00,00,((oPanInf:NHEIGHT)/2),((oPanInf:NWIDTH)/2),If(!lEdita,2,GD_UPDATE),,.T.,,,,,,,,oPanInf,aHeader,aCols)
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
        dbSelectArea(Tb_Ecomm)
        If nOpc == 3
            Reclock(Tb_Ecomm,.T.)
        Else
            Reclock(Tb_Ecomm,.F.)
        EndIf

        For nX := 1 To (Tb_Ecomm)->(FCount())
            If Tb_Ecomm+"_FILIAL" $ (Tb_Ecomm)->(FieldName(nX))
                (Tb_Ecomm)->(FieldPut(nX,xFilial(Tb_Ecomm)))
            Else	
                (Tb_Ecomm)->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
            EndIf
        Next nX
        (Tb_Ecomm)->(MsUnLock())

        (Tb_Conex)->(dbSetOrder(1))        
        (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+M->&(Tb_Ecomm+"_CODIGO")))
        Do While (Tb_Conex)->(!Eof()) .And. (Tb_Conex)->&(Tb_Conex+"_FILIAL") + (Tb_Conex)->&(Tb_Conex+"_CODIGO") == xFilial(Tb_Conex)+M->&(Tb_Ecomm+"_CODIGO")
            Reclock(Tb_Conex,.F.)
            Delete
            (Tb_Conex)->(MsUnlock())
            (Tb_Conex)->(dbSkip())
        EndDo

        For nX:=1 to Len(oItens:aCols)
            If !oItens:aCols[nX][Len(aHeader)+1]
                RecLock(Tb_Conex,.T.)
                (Tb_Conex)->&(Tb_Conex+"_FILIAL") := xFilial(Tb_Conex)
                (Tb_Conex)->&(Tb_Conex+"_CODIGO") := M->&(Tb_Ecomm+"_CODIGO")
                For nY:=1 to Len(aHeader)
                   (Tb_Conex)->&(Alltrim(Upper(aHeader[nY,02]))) := oItens:aCols[nX,nY]
                Next nY
                (Tb_Conex)->(MsUnlock())
            EndIf
        Next nX
        ConfirmSX8()

        If nOpc==3 .Or. nOpc==4            
            CriaConfMon(M->&(Tb_Ecomm+"_CODIGO"))
        EndIf    

    End Transaction
EndIf

Return

/*/{protheus.doc} TudoOk
*******************************************************************************************
Funcao para validacao dos dados
 
@author: Marcelo Celi Marques
@since: 19/11/2021
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

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 19/11/2021
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

/*/{protheus.doc} CriaConfMon
*******************************************************************************************
Cria a Configuração no Monitor
 
@author: Marcelo Celi Marques
@since: 19/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CriaConfMon(cCodTecnol)
Local aArea    := GetArea()
Local aMonitor := {}
Local aItens   := {}
Local nX       := 1

cCodTecnol := PadR(cCodTecnol,Tamsx3(Tb_Ecomm+"_CODIGO")[01])

(Tb_Ecomm)->(dbSetOrder(1))
If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodTecnol))
    Do Case
        Case Alltrim(Upper(cCodTecnol)) == "VTEX"
            aAdd(aMonitor,xFilial(Tb_Monit)                   )
            aAdd(aMonitor,cCodTecnol                          )
            aAdd(aMonitor,(Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI")   )
            aAdd(aMonitor,"VTEX"                              )
            aAdd(aMonitor,(Tb_Ecomm)->&(Tb_Ecomm+"_LOGO")     )
            aAdd(aMonitor,30                                  )
            aAdd(aMonitor,"N"                                 )

            If m->&(Tb_Ecomm+"_CARGPR")=="1" .Or. m->&(Tb_Ecomm+"_CARGPR")=="3"
                aAdd(aItens,{xFilial(Tb_Monit),        ;
                            cCodTecnol,                ;
                            "ECVTEXSPRD",              ;
                            "A",                       ;
                            "U_MaPrd2Vtex()",          ;
                            "",                        ;
                            "1",                       ;
                            "PRODUTO.PNG",             ;
                            "SUBIR PRODUTOS",          ;
                            255,                       ;
                            "",                        ;
                            0,                         ;
                            "2"}                       )
            Else
                aAdd(aItens,{xFilial(Tb_Monit),        ;
                            cCodTecnol,                ;
                            "ECVTEXSPRD",              ;
                            "A",                       ;
                            "U_MaPrd2Vtex()",          ;
                            "",                        ;
                            "1",                       ;
                            "PRODUTO.PNG",             ;
                            "SUBIR PRODUTOS",          ;
                            255,                       ;
                            "",                        ;
                            0,                         ;
                            "1"}                       )
            EndIf                

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXGEST",              ;
                        "A",                       ;
                        "U_MaEst2Vtex()",          ;
                        "",                        ;
                        "2",                       ;
                        "ESTOMOVI.PNG",            ;
                        "SUBIR ESTOQUES",          ;
                        65535,                     ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXGPRC",              ;
                        "A",                       ;
                        "U_MaPrc2Vtex()",          ;
                        "",                        ;
                        "3",                       ;
                        "LJPRECO.PNG",             ;
                        "SUBIR PREÇOS",            ;
                        4227327,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXDVDA",              ;
                        "A",                       ;
                        "U_MaPvInVTex()",          ;
                        "",                        ;
                        "4",                       ;
                        "globo.PNG",               ;
                        "DESCIDA DE VENDAS",       ;
                        5524165,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXGVDA",              ;
                        "A",                       ;
                        "U_MaVerVdEco('VTEX')",    ;
                        "",                        ;
                        "5",                       ;
                        "gprimg32.PNG",            ;
                        "ANALITICO VENDAS",        ;
                        0,                         ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXDCLI",              ;
                        "I",                       ;
                        "",                        ;
                        "",                        ;
                        "6",                       ;
                        "cliente.PNG",             ;
                        "DESCIDA DE CLIENTES",     ;
                        5524165,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXUSTA",              ;
                        "A",                       ;
                        "U_MaSta2Vtex()",          ;
                        "",                        ;
                        "7",                       ;
                        "puzzle.PNG",              ;
                        "SUBIDA STATUS VENDAS",    ;
                        3247865,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECVTEXSTPE",              ;
                        "I",                       ;
                        "",                        ;
                        "",                        ;
                        "8",                       ;
                        "tmsimg32.PNG",            ;
                        "STATUS PREPARAR ENTREGA", ;
                        3285780,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )            

            If m->&(Tb_Ecomm+"_CARGPR")=="2" .Or. m->&(Tb_Ecomm+"_CARGPR")=="3"
                aAdd(aItens,{xFilial(Tb_Monit),        ;
                            cCodTecnol,                ;
                            "ECVTXBXPRD",              ;
                            "A",                       ;
                            "U_MaPrdByVtx()",          ;
                            "",                        ;
                            "1",                       ;
                            "PRODUTO.PNG",             ;
                            "DESCIDA DE PRODUTOS",     ;
                            255,                       ;
                            "",                        ;
                            0,                         ;
                            "2"}                       )            
            Else
                aAdd(aItens,{xFilial(Tb_Monit),        ;
                            cCodTecnol,                ;
                            "ECVTXBXPRD",              ;
                            "A",                       ;
                            "U_MaPrdByVtx()",          ;
                            "",                        ;
                            "1",                       ;
                            "PRODUTO.PNG",             ;
                            "DESCIDA DE PRODUTOS",     ;
                            255,                       ;
                            "",                        ;
                            0,                         ;
                            "1"}                       )
            EndIf


        Case Alltrim(Upper(cCodTecnol)) == "PLUGGTO"
            aAdd(aMonitor,xFilial(Tb_Monit)                   )
            aAdd(aMonitor,cCodTecnol                          )
            aAdd(aMonitor,(Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI")   )
            aAdd(aMonitor,"PLUGGTO"                           )
            aAdd(aMonitor,(Tb_Ecomm)->&(Tb_Ecomm+"_LOGO")     )
            aAdd(aMonitor,30                                  )
            aAdd(aMonitor,"N"                                 )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGGPRD",              ;
                        "A",                       ;
                        "U_MaPrd2Plug()",          ;
                        "",                        ;
                        "1",                       ;
                        "PRODUTO.PNG",             ;
                        "SUBIR PRODUTOS",          ;
                        255,                       ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGGEST",              ;
                        "A",                       ;
                        "U_MaEst2Plug()",          ;
                        "",                        ;
                        "2",                       ;
                        "ESTOMOVI.PNG",            ;
                        "SUBIR ESTOQUES",          ;
                        65535,                     ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGGPRC",              ;
                        "A",                       ;
                        "U_MaPrc2Plug()",          ;
                        "",                        ;
                        "3",                       ;
                        "LJPRECO.PNG",             ;
                        "SUBIR PREÇOS",            ;
                        4227327,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGDVDA",              ;
                        "A",                       ;
                        "U_MaPvInPlug()",          ;
                        "",                        ;
                        "4",                       ;
                        "globo.PNG",               ;
                        "DESCIDA DE VENDAS",       ;
                        5524165,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGGVDA",              ;
                        "A",                       ;
                        "U_MaVerVdEco('PLUGGTO')", ;
                        "",                        ;
                        "5",                       ;
                        "gprimg32.PNG",            ;
                        "ANALITICO VENDAS",        ;
                        0,                         ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGDCLI",              ;
                        "I",                       ;
                        "",                        ;
                        "",                        ;
                        "6",                       ;
                        "cliente.PNG",             ;
                        "DESCIDA DE CLIENTES",     ;
                        5524165,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )            

            aAdd(aItens,{xFilial(Tb_Monit),        ;
                        cCodTecnol,                ;
                        "ECPLUGUSTA",              ;
                        "A",                       ;
                        "U_MaSta2Plug()",          ;
                        "",                        ;
                        "7",                       ;
                        "puzzle.PNG",              ;
                        "SUBIDA STATUS VENDAS",    ;
                        3247865,                   ;
                        "",                        ;
                        0,                         ;
                        "2"}                       )

    EndCase
EndIf

If Len(aMonitor) > 0 .And. Len(aItens) > 0
    (Tb_Monit)->(dbSetOrder(1))
    If !(Tb_Monit)->(dbSeek(xFilial(Tb_Monit)+cCodTecnol))
        Reclock(Tb_Monit,.T.)
        (Tb_Monit)->&(Tb_Monit+"_FILIAL") := aMonitor[1]
        (Tb_Monit)->&(Tb_Monit+"_CODIGO") := aMonitor[2]        
    Else
        Reclock(Tb_Monit,.F.)
    EndIf    
    (Tb_Monit)->&(Tb_Monit+"_MSBLQL") := aMonitor[7]
    (Tb_Monit)->&(Tb_Monit+"_DESCRI") := aMonitor[3]
    (Tb_Monit)->&(Tb_Monit+"_DESRED") := aMonitor[4]
    (Tb_Monit)->&(Tb_Monit+"_LOGOTP") := aMonitor[5]
    (Tb_Monit)->&(Tb_Monit+"_TEMPAT") := aMonitor[6]    
    (Tb_Monit)->(MsUnlock())

    For nX:=1 to Len(aItens)
        (Tb_ChMon)->(dbSetOrder(2))
        If !(Tb_ChMon)->(dbSeek(xFilial(Tb_ChMon)+cCodTecnol+aItens[nX,03]))
            Reclock(Tb_ChMon,.T.)
            (Tb_ChMon)->&(Tb_ChMon+"_FILIAL") := aItens[nX,01]
            (Tb_ChMon)->&(Tb_ChMon+"_CODIGO") := aItens[nX,02]
            (Tb_ChMon)->&(Tb_ChMon+"_INTEGR") := aItens[nX,03]            
        Else
            Reclock(Tb_ChMon,.F.)
        EndIf
        (Tb_ChMon)->&(Tb_ChMon+"_MSBLQL") := aItens[nX,13]
        (Tb_ChMon)->&(Tb_ChMon+"_CONEX" ) := aItens[nX,04]
        (Tb_ChMon)->&(Tb_ChMon+"_FUNCAO") := aItens[nX,05]
        (Tb_ChMon)->&(Tb_ChMon+"_FUNREF") := aItens[nX,06]
        (Tb_ChMon)->&(Tb_ChMon+"_ORDEM" ) := aItens[nX,07]
        (Tb_ChMon)->&(Tb_ChMon+"_ICONE" ) := aItens[nX,08]
        (Tb_ChMon)->&(Tb_ChMon+"_NOME"  ) := aItens[nX,09]
        (Tb_ChMon)->&(Tb_ChMon+"_COR"   ) := aItens[nX,10]
        (Tb_ChMon)->&(Tb_ChMon+"_EMAIL" ) := aItens[nX,11]
        (Tb_ChMon)->&(Tb_ChMon+"_VALIDA") := aItens[nX,12]        
        (Tb_ChMon)->(MsUnlock())
    Next nX
EndIf

RestArea(aArea)

Return
