#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
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

/*/{protheus.doc} MaMnuEcom
*******************************************************************************************
Rotina de Menu do e-Commerce

@author: Marcelo Celi Marques
@since: 28/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaMnuEcom()
Local oDlg        := NIL
Local oPanel      := NIL
Local oPanSup     := NIL
Local oPanSupDir  := NIL
Local oPanSupEsq  := NIL
Local oPanInf     := NIL
Local oLogoInteg  := NIL
Local oTMenuBar   := NIL
Local lCadastros  := Alltrim(Upper(GetNewPar("IN_CADSECO","N")))=="S"
Local oArquivo    := NIL
Local oRelatorios := NIL
Local oCargas     := NIL
Local oConfigurar := NIL
Local oArq0101    := NIL  
Local oArq0102    := NIL  
Local oArq0103    := NIL  

Local aSize	      := MsAdvSize()
Local bLogo       := {|| ShellExecute("Open", "https://www.integraconsultoriaerp.com.br/", "", "", 1) }
Local cLogo       := "integra.png"
Local oFonte1     := TFont():New("Verdana",,011,,.T.,,,,,.F.,.F.)
Local oFonte3     := TFont():New("Verdana",,019,,.T.,,,,,.F.,.F.)
Local oImgTotvs   := NIL
Local oImgSuport  := NIL
Local nAltPainel  := 0  
Local nQtdPainel  := 0
Local aDados      := {}
Local aIcones     := {}
Local nX          := 1
Local bCmd        := {||}

Private aPGrfVisPrd := {}
Private aPGrfVisCan := {}
Private aPGrfVisVda := {}
Private _oTempoAtlz := NIL

INCLUI := .F.
ALTERA := .F.

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    
    oDlg := FWStyledDialog():New(aSize[7],0,aSize[6],aSize[5],"Ferramentas de e-Commerce",{||})
    
    //->> Painel Principal
    oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,RGB(230,230,230),((oDlg:nWIDTH)/2),((oDlg:nHEIGHT)/2),.F.,.F. )
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oPanSup := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(30,29,69),((oPanel:nWIDTH)/2),(20),.F.,.T. )
    oPanSup:Align := CONTROL_ALIGN_TOP

        oPanSupDir := TPanel():New(1,1,'',oPanSup, oDlg:oFont, .T., .T.,,RGB(30,29,69),(70),((oPanSup:nHEIGHT)/2)-2,.F.,.F. )
        oPanSupDir:Align := CONTROL_ALIGN_LEFT

        oLogoInteg := TBitmap():New(01,01,(oPanSupDir:nWidth/2)-2,(oPanSupDir:nHeight/2)-1,,"\SYSTEM\"+cLogo,.T.,oPanSupDir,bLogo,,.T.,.T.,,,.F.,,.T.,,.F.)

        oPanSupEsq := TPanel():New(1,1,'',oPanSup, oDlg:oFont, .T., .T.,,RGB(30,29,69),((oPanSup:nWIDTH)/2)-70,((oPanSup:nHEIGHT)/2)-2,.F.,.F. )
        oPanSupEsq:Align := CONTROL_ALIGN_RIGHT
        
        oTMenuBar := TMenuBar():New(oPanSupEsq)
        oTMenuBar:SetCss(GetMenuCss())

        oArquivo    := TMenu():New(0,0,0,0,.T.,,oPanSupEsq)    
        oRelatorios := TMenu():New(0,0,0,0,.T.,,oPanSupEsq)    
        oCargas     := TMenu():New(0,0,0,0,.T.,,oPanSupEsq)
        oConfigurar := TMenu():New(0,0,0,0,.T.,,oPanSupEsq)   

        oArq0101 := tMenuItem():new(oArquivo, "Cadastros"            , , , , {||                 }, ,            , , , , , , , .T.)
        oArq0102 := tMenuItem():new(oArquivo, "Catálogo de Produtos" , , , , {||u_MAPrdEcomm()   }, ,'produto'   , , , , , , , .T.)
        oArq0103 := tMenuItem():new(oArquivo, "Sair"                 , , , , {||oDlg:End()       }, ,'final'     , , , , , , , .T.)  

        oArquivo:add(oArq0101)    

        oArq0101:add(tMenuItem():new(oArq0101, "Canais de Vendas", , ,          , {||u_MACanEcomm()}, ,'ecoimg32', , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Status das Vendas", , ,         , {||U_MAStaEcomm()}, ,'tabprice', , , , , , , .T.))        
        oArq0101:add(tMenuItem():new(oArq0101, "Condição Pgto", , ,             , {||U_MAPgtEcomm()}, ,'salarios', , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Transportadoras", , ,           , {||U_MATraEcomm()}, ,'tmsimg32', , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Vouchers Desconto", , ,         , {||U_MADscEcomm()}, ,'tpopagto1', , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Categorias"      , , ,lCadastros, {||u_MACatEcomm()}, ,          , , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Departamentos"   , , ,lCadastros, {||u_MADepEcomm()}, ,          , , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Marcas"          , , ,lCadastros, {||u_MAMarEcomm()}, ,          , , , , , , , .T.))
        oArq0101:add(tMenuItem():new(oArq0101, "Fabricantes"     , , ,lCadastros, {||u_MAFabEcomm()}, ,          , , , , , , , .T.))

        oArquivo:add(oArq0102)
        oArquivo:add(oArq0103)

        oCargas:Add(TMenuItem():New(oPanSupEsq,'Monitorar Cargas'    ,,,,{|| u_MaMonIntg() },,'edcimg32',,,,,,,.T.))

        oConfigurar:Add(TMenuItem():New(oPanSupEsq,'Monitoramento'      ,,,,{|| u_MaCfgIntg() },,'engrenagem',,,,,,,.T.))
        oConfigurar:Add(TMenuItem():New(oPanSupEsq,'Conexões'           ,,,,{|| u_Madcfgconn() },,'rpmdes',,,,,,,.T.))
        
        oRelatorios:Add(TMenuItem():New(oPanSupEsq,'Vendas on-line'    ,,,,{|| u_MaR01Ecomm() },,'rpmimp',,,,,,,.T.))

        // Marcelo Celi - 03/03/2022
        oRelatorios:Add(TMenuItem():New(oPanSupEsq,'Etiquetas Expedição' ,,,,{|| u_BoEtq01Vda() },,'rpmimp',,,,,,,.T.))

        oTMenuBar:addItem("&Arquivo"         , oArquivo      , .T.)
        oTMenuBar:addItem("&Relatórios"      , oRelatorios   , .T.)
        oTMenuBar:addItem("&Cargas"          , oCargas       , .T.)
        oTMenuBar:addItem("&Configurações"   , oConfigurar   , .T.)

        //->> Sombra do Texto
        TSay():New((3+1)-0.25 ,((oPanSupEsq:nWIDTH/2-100)+22)-0.25  , {|| "E-COMMERCE"}   ,oPanSupEsq,,oFonte1,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )
        TSay():New((3+6)-0.25 ,((oPanSupEsq:nWIDTH/2-100)+22)-0.25  , {|| "COCKPIT"}     ,oPanSupEsq,,oFonte3,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )

        //->> Texto Normal
        TSay():New((3+1)      ,((oPanSupEsq:nWIDTH/2-100)+22)       , {|| "E-COMMERCE"}   ,oPanSupEsq,,oFonte1,,,,.T.,Rgb(255,255,255),CLR_WHITE,(100),(20) )
        TSay():New((3+6)      ,((oPanSupEsq:nWIDTH/2-100)+22)       , {|| "COCKPIT"}     ,oPanSupEsq,,oFonte3,,,,.T.,Rgb(255,255,255),CLR_WHITE,(100),(20) )

        oImgTotvs  := TBitmap():New(01,(oPanSupEsq:nWIDTH/2-103),(20),(20),"fwhc_blog",,.T.,oPanSupEsq,,,.T.,.T.,,,.F.,,.T.,,.F.)
        oImgSuport := TBitmap():New(0.5,(oPanSupEsq:nWIDTH/2-20) ,(20),(20),"fwskin_lgn_help_transparent",,.T.,oPanSupEsq,,,.T.,.T.,,,.F.,,.T.,,.F.)


    oPanInf := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(230,230,230),((oPanel:nWIDTH)/2),((oPanel:nHEIGHT)/2)-20,.T.,.F. )
    oPanInf:Align := CONTROL_ALIGN_BOTTOM
    
        oPanInfEsq := TPanel():New(0,0,'',oPanInf, oDlg:oFont, .T., .T.,,RGB(230,230,230),((oPanInf:nWIDTH)/2)*.34,((oPanInf:nHEIGHT)/2),.F.,.F. )
        oPanInfEsq:Align := CONTROL_ALIGN_LEFT

        oPanInfCen := TPanel():New(0,0,'',oPanInf, oDlg:oFont, .T., .T.,,RGB(230,230,230),((oPanInf:nWIDTH)/2)*.33,((oPanInf:nHEIGHT)/2),.F.,.F. )
        oPanInfCen:Align := CONTROL_ALIGN_ALLCLIENT

        oPanInfDir := TPanel():New(0,0,'',oPanInf, oDlg:oFont, .T., .T.,,RGB(230,230,230),((oPanInf:nWIDTH)/2)*.33,((oPanInf:nHEIGHT)/2),.F.,.F. )
        oPanInfDir:Align := CONTROL_ALIGN_RIGHT
        
        nQtdPainel := 0
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                nQtdPainel++
            EndIf
        (Tb_Ecomm)->(dbSkip())
        EndDo    

        If nQtdPainel == 1
            nAltPainel := (oPanInfDir:nHEIGHT/2)-15
        Else
            nAltPainel := 140
        EndIf

        //-------->> Grafico de Visão de Produtos com maior demanda
        //->> 01 - Painel Interno
        aAdd(aPGrfVisPrd, TScrollArea():New(oPanInfDir,01,01,(nAltPainel * nQtdPainel),((oPanInfDir:nWIDTH/2)-2)))
        aPGrfVisPrd[01]:Align := CONTROL_ALIGN_ALLCLIENT

        //->> 02 - Painel TTollbox
        aAdd(aPGrfVisPrd,TToolBox():New(01,01,oPanInfDir,oPanInfDir:nWIDTH/2,oPanInfDir:nHEIGHT/2))
        aPGrfVisPrd[02]:AddGroup( aPGrfVisPrd[01] , "Visão dos Produtos com maior Demanda no Site")

        //->> 03 - Multiplos Paineis
        aAdd(aPGrfVisPrd,{})        
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                aAdd(aPGrfVisPrd[03],{(Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO"),            ; // 01 - Codigo do eCommerce
                                      (Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI"),            ; // 02 - Descrição do eCommerce
                                      (Tb_Ecomm)->&(Tb_Ecomm+"_LOGO"),              ; // 03 - Logo do eCommerce
                                      NIL,                                          ; // 04 - Painel Interno do eCommerce
                                      NIL,                                          ; // 05 - Painel Interno Superior do eCommerce
                                      NIL,                                          ; // 06 - Painel Interno Inferior do eCommerce
                                      NIL,                                          ; // 07 - Logotipo do eCommerce
                                      {},                                           ; // 08 - Array com os dados a serem apresentados
                                      "C",                                          ; // 09 - Tipo de Grafico
                                      NIL,                                          ; // 10 - Grafico dos Dados
                                      (Tb_Ecomm)->&(Tb_Ecomm+"_FILECO"),            ; // 11 - Filial dos Dados
                                      "Q",                                          ; // 12 - Tipo de Dados no Retorno
                                      NIL,                                          ; // 13 - Painel Superior Esquerdo
                                      NIL,                                          ; // 14 - Painel Superior Direito
                                      NIL}                                          ) // 15 - Objeto de Seleção de Tipo de Dados
            
                // Painel Interno do eCommerce
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04] := TPanel():New(0,0,'',aPGrfVisPrd[01], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisPrd[01]:nWIDTH)/2),(nAltPainel),.F.,.F. )
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Superior do eCommerce
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05] := TPanel():New(0,0,'',aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04], oDlg:oFont, .T., .T.,,RGB(255,255,255),((aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04]:nWIDTH)/2),(20),.F.,.F. )
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Inferior do eCommerce
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][06] := TPanel():New(0,0,'',aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04]:nWIDTH)/2),((aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][04]:nHEIGHT)/2)-20,.F.,.F. )
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][06]:Align := CONTROL_ALIGN_ALLCLIENT
                
                // Painel Interno Superior Esquerdo do eCommerce
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][13] := TPanel():New(0,0,'',aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(80),((aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][13]:Align := CONTROL_ALIGN_LEFT

                // Painel Interno Superior Direito do eCommerce
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][14] := TPanel():New(0,0,'',aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(70),((aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][14]:Align := CONTROL_ALIGN_LEFT

                // Logotipo do eCommerce
                If File("\SYSTEM\"+Alltrim(aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][03]))
                    aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][07] := TBitmap():New(01,05,(60),(18),,"\SYSTEM\"+Alltrim(aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][03]),.T.,aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][13],,,.T.,.T.,,,.F.,,.T.,,.F.)
                EndIf
                
                // Objeto de Seleção de Tipo de Dados
                aIcones := {}
                aDados  := {}
                aAdd(aIcones,{"qipimg32","Q","Dados Classificados por Quantidade"})
                aAdd(aIcones,{"salarios","V","Dados Classificados por Valor"})
                For nX:=1 to Len(aIcones)
                    bCmd := "{|| aPGrfVisPrd[03]["+Alltrim(Str(Len(aPGrfVisPrd[03])))+"][12] := '"+aIcones[nX,02]+"', AtuGrafico() }"
                    bCmd := &(bCmd)
                    aAdd(aDados,{"",aIcones[nX,03],{"",Alltrim(aIcones[nX,01])+".PNG"},bCmd,.T.})
                Next nX                
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][15] := MARadioImg():New()
                aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][15]:Iniciar(aPGrfVisPrd[03][Len(aPGrfVisPrd[03])][14],2,aDados,"",1,15,15,.F.,.F.,.T.)

            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo

        //-------->> Grafico de Visão de Vendas
        //->> 01 - Painel Interno
        aAdd(aPGrfVisVda, TScrollArea():New(oPanInfEsq,01,01,(nAltPainel * nQtdPainel),((oPanInfEsq:nWIDTH/2)-2)))
        aPGrfVisVda[01]:Align := CONTROL_ALIGN_ALLCLIENT

        //->> 02 - Painel TTollbox
        aAdd(aPGrfVisVda,TToolBox():New(01,01,oPanInfEsq,oPanInfEsq:nWIDTH/2,oPanInfEsq:nHEIGHT/2))
        aPGrfVisVda[02]:AddGroup( aPGrfVisVda[01] , "Visão de Vendas no Site")

        //->> 03 - Multiplos Paineis
        aAdd(aPGrfVisVda,{})        
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                aAdd(aPGrfVisVda[03],{(Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO"),          ; // 01 - Codigo do eCommerce
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI"),            ; // 02 - Descrição do eCommerce
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_LOGO"),              ; // 03 - Logo do eCommerce
                                    NIL,                                          ; // 04 - Painel Interno do eCommerce
                                    NIL,                                          ; // 05 - Painel Interno Superior do eCommerce
                                    NIL,                                          ; // 06 - Painel Interno Inferior do eCommerce
                                    NIL,                                          ; // 07 - Logotipo do eCommerce
                                    {},                                           ; // 08 - Array com os dados a serem apresentados
                                    "L",                                          ; // 09 - Tipo de Grafico
                                    NIL,                                          ; // 10 - Grafico dos Dados
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_FILECO"),            ; // 11 - Filial dos Dados
                                    "Q",                                          ; // 12 - Tipo de Dados no Retorno
                                    NIL,                                          ; // 13 - Painel Superior Esquerdo
                                    NIL,                                          ; // 14 - Painel Superior Direito
                                    NIL}                                          ) // 15 - Objeto de Seleção de Tipo de Dados
            
                // Painel Interno do eCommerce
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][04] := TPanel():New(0,0,'',aPGrfVisVda[01], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisVda[01]:nWIDTH)/2),(nAltPainel),.F.,.F. )
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][04]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Superior do eCommerce
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][05] := TPanel():New(0,0,'',aPGrfVisVda[03][Len(aPGrfVisVda[03])][04], oDlg:oFont, .T., .T.,,RGB(255,255,255),((aPGrfVisVda[03][Len(aPGrfVisVda[03])][04]:nWIDTH)/2),(20),.F.,.F. )
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][05]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Inferior do eCommerce
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][06] := TPanel():New(0,0,'',aPGrfVisVda[03][Len(aPGrfVisVda[03])][04], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisVda[03][Len(aPGrfVisVda[03])][04]:nWIDTH)/2),((aPGrfVisVda[03][Len(aPGrfVisVda[03])][04]:nHEIGHT)/2)-20,.F.,.F. )
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][06]:Align := CONTROL_ALIGN_ALLCLIENT
                
                // Painel Interno Superior Esquerdo do eCommerce
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][13] := TPanel():New(0,0,'',aPGrfVisVda[03][Len(aPGrfVisVda[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(80),((aPGrfVisVda[03][Len(aPGrfVisVda[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][13]:Align := CONTROL_ALIGN_LEFT

                // Painel Interno Superior Direito do eCommerce
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][14] := TPanel():New(0,0,'',aPGrfVisVda[03][Len(aPGrfVisVda[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(70),((aPGrfVisVda[03][Len(aPGrfVisVda[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][14]:Align := CONTROL_ALIGN_LEFT

                // Logotipo do eCommerce
                If File("\SYSTEM\"+Alltrim(aPGrfVisVda[03][Len(aPGrfVisVda[03])][03]))
                    aPGrfVisVda[03][Len(aPGrfVisVda[03])][07] := TBitmap():New(01,05,(60),(18),,"\SYSTEM\"+Alltrim(aPGrfVisVda[03][Len(aPGrfVisVda[03])][03]),.T.,aPGrfVisVda[03][Len(aPGrfVisVda[03])][13],,,.T.,.T.,,,.F.,,.T.,,.F.)
                EndIf
                
                // Objeto de Seleção de Tipo de Dados
                aIcones := {}
                aDados  := {}
                aAdd(aIcones,{"qipimg32","Q","Dados Classificados por Quantidade"})
                aAdd(aIcones,{"salarios","V","Dados Classificados por Valor"})
                For nX:=1 to Len(aIcones)
                    bCmd := "{|| aPGrfVisVda[03]["+Alltrim(Str(Len(aPGrfVisVda[03])))+"][12] := '"+aIcones[nX,02]+"', AtuGrafico() }"
                    bCmd := &(bCmd)
                    aAdd(aDados,{"",aIcones[nX,03],{"",Alltrim(aIcones[nX,01])+".PNG"},bCmd,.T.})
                Next nX                
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][15] := MARadioImg():New()
                aPGrfVisVda[03][Len(aPGrfVisVda[03])][15]:Iniciar(aPGrfVisVda[03][Len(aPGrfVisVda[03])][14],2,aDados,"",1,15,15,.F.,.F.,.T.)

            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo

        //-------->> Grafico de Visão de Vendas por Canal
        //->> 01 - Painel Interno
        aAdd(aPGrfVisCan, TScrollArea():New(oPanInfCen,01,01,(nAltPainel * nQtdPainel),((oPanInfCen:nWIDTH/2)-2)))
        aPGrfVisCan[01]:Align := CONTROL_ALIGN_ALLCLIENT

        //->> 02 - Painel TTollbox
        aAdd(aPGrfVisCan,TToolBox():New(01,01,oPanInfCen,oPanInfCen:nWIDTH/2,oPanInfCen:nHEIGHT/2))
        aPGrfVisCan[02]:AddGroup( aPGrfVisCan[01] , "Visão de Vendas por Canal no Site")

        //->> 03 - Multiplos Paineis
        aAdd(aPGrfVisCan,{})        
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                aAdd(aPGrfVisCan[03],{(Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO"),          ; // 01 - Codigo do eCommerce
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI"),            ; // 02 - Descrição do eCommerce
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_LOGO"),              ; // 03 - Logo do eCommerce
                                    NIL,                                          ; // 04 - Painel Interno do eCommerce
                                    NIL,                                          ; // 05 - Painel Interno Superior do eCommerce
                                    NIL,                                          ; // 06 - Painel Interno Inferior do eCommerce
                                    NIL,                                          ; // 07 - Logotipo do eCommerce
                                    {},                                           ; // 08 - Array com os dados a serem apresentados
                                    "P",                                          ; // 09 - Tipo de Grafico
                                    NIL,                                          ; // 10 - Grafico dos Dados
                                    (Tb_Ecomm)->&(Tb_Ecomm+"_FILECO"),            ; // 11 - Filial dos Dados
                                    "Q",                                          ; // 12 - Tipo de Dados no Retorno
                                    NIL,                                          ; // 13 - Painel Superior Esquerdo
                                    NIL,                                          ; // 14 - Painel Superior Direito
                                    NIL}                                          ) // 15 - Objeto de Seleção de Tipo de Dados
            
                // Painel Interno do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][04] := TPanel():New(0,0,'',aPGrfVisCan[01], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisCan[01]:nWIDTH)/2),(nAltPainel),.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Superior do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][05] := TPanel():New(0,0,'',aPGrfVisCan[03][Len(aPGrfVisCan[03])][04], oDlg:oFont, .T., .T.,,RGB(255,255,255),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:nWIDTH)/2),(20),.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][05]:Align := CONTROL_ALIGN_TOP

                // Painel Interno Inferior do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][06] := TPanel():New(0,0,'',aPGrfVisCan[03][Len(aPGrfVisCan[03])][04], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:nWIDTH)/2),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:nHEIGHT)/2)-20,.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][06]:Align := CONTROL_ALIGN_ALLCLIENT
                
                // Painel Interno Superior Esquerdo do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][13] := TPanel():New(0,0,'',aPGrfVisCan[03][Len(aPGrfVisCan[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(80),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][13]:Align := CONTROL_ALIGN_LEFT

                // Painel Interno Superior Direito do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][14] := TPanel():New(0,0,'',aPGrfVisCan[03][Len(aPGrfVisCan[03])][05], oDlg:oFont, .T., .T.,,RGB(255,255,255),(70),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][05]:nHEIGHT)/2),.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][14]:Align := CONTROL_ALIGN_LEFT

                // Painel Interno Inferior do eCommerce
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][06] := TPanel():New(0,0,'',aPGrfVisCan[03][Len(aPGrfVisCan[03])][04], oDlg:oFont, .T., .T.,,RGB(180,180,180),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:nWIDTH)/2),((aPGrfVisCan[03][Len(aPGrfVisCan[03])][04]:nHEIGHT)/2)-20,.F.,.F. )
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][06]:Align := CONTROL_ALIGN_ALLCLIENT
                
                // Logotipo do eCommerce
                If File("\SYSTEM\"+Alltrim(aPGrfVisCan[03][Len(aPGrfVisCan[03])][03]))
                    aPGrfVisCan[03][Len(aPGrfVisCan[03])][07] := TBitmap():New(01,05,(60),(18),,"\SYSTEM\"+Alltrim(aPGrfVisCan[03][Len(aPGrfVisCan[03])][03]),.T.,aPGrfVisCan[03][Len(aPGrfVisCan[03])][13],,,.T.,.T.,,,.F.,,.T.,,.F.)
                EndIf
                
                // Objeto de Seleção de Tipo de Dados
                aIcones := {}
                aDados  := {}
                aAdd(aIcones,{"qipimg32","Q","Dados Classificados por Quantidade"})
                aAdd(aIcones,{"salarios","V","Dados Classificados por Valor"})
                For nX:=1 to Len(aIcones)
                    bCmd := "{|| aPGrfVisCan[03]["+Alltrim(Str(Len(aPGrfVisCan[03])))+"][12] := '"+aIcones[nX,02]+"', AtuGrafico() }"
                    bCmd := &(bCmd)
                    aAdd(aDados,{"",aIcones[nX,03],{"",Alltrim(aIcones[nX,01])+".PNG"},bCmd,.T.})
                Next nX                
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][15] := MARadioImg():New()
                aPGrfVisCan[03][Len(aPGrfVisCan[03])][15]:Iniciar(aPGrfVisCan[03][Len(aPGrfVisCan[03])][14],2,aDados,"",1,15,15,.F.,.F.,.T.)

            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo

        //->> Timer de atualização de dados nos paineis
        _oTempoAtlz := TTimer():New(100, {|| AtuGrafico() },oDlg)
        _oTempoAtlz:Activate()


    oDlg:Activate(,,,.T.,,, {||  })
EndIf

Return

/*/{protheus.doc} GetMenuCss
*******************************************************************************************
Retorna o estilo do menu suspenso

@author: Marcelo Celi Marques
@since: 28/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetMenuCss()
Local cEstilo := ""

cEstilo := "QMenuBar{color:#ffffff;"+;
		             " padding-top:3px;"+;
		             " background-color:transparent;"+;
           			 " background-image:url(rpo:VistaBgBlackMenu.png);}"+;
                 "QMenuBar::item:selected{border:1px solid white;"+;
                 " border-right:1px solid #A0A0A0;;"+;
                 " border-bottom:1px solid #A0A0A0;}"+;
                 "QMenuBar::item:pressed{border:1px solid white;"+;
                 " border-left:1px solid #A0A0A0;"+;
                 " border-top:1px solid #A0A0A0;}"+;
           			 "QMenu{background-color:#ffffff;"+;
           			 " color:#000000;"+;
			           " border-style:solid;"+;
           			 " border-image:url(rpo:CleanBorderWhite.png) 4 4 4 4 stretch;"+;
           			 " border-style:solid; border-width: 4px;}"+;
				 				 "QMenu::item:selected {margin:1px 3px 1px 3px;"+;
				 				 " background-color:#DEE7EC;"+;
				 				 " border:1px solid #8CACBB;"+;
				 				 " padding:2px 25px 2px 20px;}"+;
				         "QMenu::item{margin:1px 3px 1px 3px;"+;
				         " background-color:transparent;"+;
				         " border:1px solid transparent;"+;
				         " padding:2px 25px 2px 20px;}"+;
           			 "QToolBar{background-image:url(rpo: x.png);}"

Return cEstilo

/*/{protheus.doc} GetVendas
*******************************************************************************************
Retorna os Dados para exibição nos graficos

@author: Marcelo Celi Marques
@since: 29/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetVendas(cFilEcom,cCodEcomm,cTipo,cTpDados)
Local aDados   := {}
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local _cFilAnt := cFilAnt
Local aArea    := GetArea()
Local nDias    := 0
Local dInicio  := Date()
Local nQtdSeq  := 0
Local dData    := Stod("")
Local cCanal   := "" 
Local cDsCanal := ""
Local aCanais  := {}
Local nPos     := 0 

cFilAnt := cFilEcom

(Tb_Ecomm)->(dbSetOrder(1))
If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodEcomm))
    If (Tb_Ecomm)->(FieldPos(Tb_Ecomm+"_DIGRFE"))>0
        nDias := (Tb_Ecomm)->&(Tb_Ecomm+"_DIGRFE")
    EndIf
EndIf
dInicio := Date() - nDias

If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodEcomm))
    If (Tb_Ecomm)->(FieldPos(Tb_Ecomm+"_QTPRGE"))>0
        nQtdSeq := (Tb_Ecomm)->&(Tb_Ecomm+"_QTPRGE")
    EndIf
EndIf

(Tb_Canal)->(dbGotop())
Do While (Tb_Canal)->(!Eof())
    If (Tb_Canal)->&(Tb_Canal+"_FILIAL")==xFilial(Tb_Canal)
        aAdd(aCanais,{(Tb_Canal)->&(Tb_Canal+"_ECOMME"),;
                      (Tb_Canal)->&(Tb_Canal+"_CODIGO"),;
                      (Tb_Canal)->&(Tb_Canal+"_DESCRI"),;
                      (Tb_Canal)->&(Tb_Canal+"_IDECOM")})
    EndIf
    (Tb_Canal)->(dbSkip())
EndDo

Do Case
    Case cTipo == "P" // Produtos
        cQuery := "SELECT TOP "+Alltrim(Str(nQtdSeq))+" * FROM ("       +CRLF
        cQuery += " SELECT "                                            +CRLF
        cQuery +="        SCK.CK_PRODUTO     AS CK_PRODUTO,"            +CRLF
        If cTpDados=="Q"
            cQuery +="    SUM(SCK.CK_QTDVEN) AS VALOR"                  +CRLF
        Else
            cQuery +="    SUM(SCK.CK_VALOR) AS VALOR"                   +CRLF
        EndIf
        cQuery += " FROM "+RetSqlName("SCK")+" SCK (NOLOCK)"            +CRLF
        cQuery += " INNER JOIN "+RetSqlName("SCJ")+" SCJ (NOLOCK)"      +CRLF
        cQuery += "    ON SCJ.CJ_FILIAL   = SCK.CK_FILIAL"              +CRLF
        cQuery += "   AND SCJ.CJ_NUM      = SCK.CK_NUM"                 +CRLF
        cQuery += "   AND SCJ.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " WHERE SCK.CK_FILIAL   = '"+xFilial("SCK")+"'"       +CRLF
        cQuery += "   AND SCJ.CJ_XORIGEM  = '"+Alltrim(cCodEcomm)+"'"   +CRLF
        cQuery += "   AND SCJ.CJ_XIDINTG  <> ' '"                       +CRLF
        cQuery += "   AND SCJ.CJ_XDTINTE  >= '"+dTos(dInicio)+"'"       +CRLF
        cQuery += "   AND SCK.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " GROUP BY CK_PRODUTO"                                +CRLF
        cQuery += "  ) AS TMP"                                          +CRLF
        cQuery += "    ORDER BY TMP.VALOR DESC, TMP.CK_PRODUTO"         +CRLF
        
        MsgRun("Extraindo dados...",,{ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
        Do While (cAlias)->(!Eof())
            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+(cAlias)->CK_PRODUTO))
                aAdd(aDados,{SB1->B1_COD,           ; // 01 - Codigo do Produto
                             SB1->B1_DESC,          ; // 02 - Descrição do Produto
                             (cAlias)->VALOR}       ) // 03 - Quantidade Vendida
            EndIf
            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(dbCloseArea())

    Case cTipo == "V" // Vendas
        cQuery := "SELECT * FROM ("                                     +CRLF
        cQuery += " SELECT "                                            +CRLF
        cQuery +="        SCJ.CJ_XDTINTE,"                              +CRLF
        If cTpDados=="Q"
            cQuery +="    SUM(SCK.CK_QTDVEN) AS VALOR"                  +CRLF
        Else
            cQuery +="    SUM(SCK.CK_VALOR) AS VALOR"                   +CRLF
        EndIf
        cQuery += " FROM "+RetSqlName("SCK")+" SCK (NOLOCK)"            +CRLF        
        cQuery += " INNER JOIN "+RetSqlName("SCJ")+" SCJ (NOLOCK)"      +CRLF
        cQuery += "    ON SCJ.CJ_FILIAL   = SCK.CK_FILIAL"              +CRLF
        cQuery += "   AND SCJ.CJ_NUM      = SCK.CK_NUM"                 +CRLF
        cQuery += "   AND SCJ.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " WHERE SCK.CK_FILIAL   = '"+xFilial("SCK")+"'"       +CRLF
        cQuery += "   AND SCJ.CJ_XORIGEM  = '"+Alltrim(cCodEcomm)+"'"   +CRLF
        cQuery += "   AND SCJ.CJ_XIDINTG  <> ' '"                       +CRLF
        cQuery += "   AND SCJ.CJ_XDTINTE  >= '"+dTos(dInicio)+"'"       +CRLF
        cQuery += "   AND SCK.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " GROUP BY CJ_XDTINTE"                                +CRLF
        cQuery += "  ) AS TMP"                                          +CRLF
        cQuery += "    ORDER BY TMP.CJ_XDTINTE"                         +CRLF        

        MsgRun("Extraindo dados...",,{ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
        Do While (cAlias)->(!Eof())
            dData := Stod((cAlias)->CJ_XDTINTE)            
            aAdd(aDados,{StrZero(Day(dData),2)+"/"+StrZero(Month(dData),2),     ; // 01 - Data Resumida
                         StrZero(Day(dData),2)+"/"+StrZero(Month(dData),2),     ; // 02 - Data Resumida
                         (cAlias)->VALOR,                                       ; // 03 - Quantidade Vendida
                         dData}                                                 ) // 04 - Data
            
            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(dbCloseArea())
        aDados := aSort(aDados,,,{|x,y| x[04]<y[04]})

    Case cTipo == "C" // Canal
        cQuery := "SELECT * FROM ("                                     +CRLF
        cQuery += " SELECT "                                            +CRLF
        cQuery +="        SCJ.CJ_XCANAL,"                               +CRLF
        If cTpDados=="Q"
            cQuery +="    SUM(SCK.CK_QTDVEN) AS VALOR"                  +CRLF
        Else
            cQuery +="    SUM(SCK.CK_VALOR) AS VALOR"                   +CRLF
        EndIf
        cQuery += " FROM "+RetSqlName("SCK")+" SCK (NOLOCK)"            +CRLF        
        cQuery += " INNER JOIN "+RetSqlName("SCJ")+" SCJ (NOLOCK)"      +CRLF
        cQuery += "    ON SCJ.CJ_FILIAL   = SCK.CK_FILIAL"              +CRLF
        cQuery += "   AND SCJ.CJ_NUM      = SCK.CK_NUM"                 +CRLF
        cQuery += "   AND SCJ.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " WHERE SCK.CK_FILIAL   = '"+xFilial("SCK")+"'"       +CRLF
        cQuery += "   AND SCJ.CJ_XORIGEM  = '"+Alltrim(cCodEcomm)+"'"   +CRLF
        cQuery += "   AND SCJ.CJ_XIDINTG  <> ' '"                       +CRLF
        cQuery += "   AND SCJ.CJ_XDTINTE  >= '"+dTos(dInicio)+"'"       +CRLF
        cQuery += "   AND SCK.D_E_L_E_T_  = ' '"                        +CRLF
        cQuery += " GROUP BY CJ_XCANAL"                                 +CRLF
        cQuery += "  ) AS TMP"                                          +CRLF
        cQuery += "    ORDER BY TMP.CJ_XCANAL"                          +CRLF        

        MsgRun("Extraindo dados...",,{ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.) })
        Do While (cAlias)->(!Eof())            
            cCanal   := Alltrim((cAlias)->CJ_XCANAL)
            nPos     := Ascan(aCanais,{|x| Alltrim(Upper(x[1]))==Alltrim(Upper(cCodEcomm)) .And. Alltrim(Upper(x[4]))==Alltrim(Upper(cCanal))  })
            If nPos > 0
                cDsCanal := Alltrim(aCanais[nPos,03])
            Else
                cDsCanal := ""
            EndIf    
            
            aAdd(aDados,{Alltrim(Upper(cCanal+"-"+cDsCanal)),                   ; // 01 - Canal
                         Alltrim(Upper(cCanal+"-"+cDsCanal)),                   ; // 02 - Canal
                         (cAlias)->VALOR}                                       ) // 03 - Quantidade Vendida
                         
            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(dbCloseArea())
        aDados := aSort(aDados,,,{|x,y| x[02]<y[02]})

EndCase

RestArea(aArea)
cFilAnt := _cFilAnt

Return aDados

/*/{protheus.doc} GetGrafico
*******************************************************************************************
Retorna o Objeto de Grafico após a montagem

@author: Marcelo Celi Marques
@since: 29/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetGrafico(oDlg,cTipGrf,aDados,cTpVisao,cCodEcomm)
Local oGrafico := NIL
Local nX       := 1
Local nTpGrf   := 0
Local aPeriodo := {}
Local nDias    := 30
Local dData    := Date()
Local nPos     := 0

Default cCodEcomm := ""

If !Empty(cCodEcomm)
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodEcomm))
        If (Tb_Ecomm)->(FieldPos(Tb_Ecomm+"_DIGRFE"))>0
            nDias := (Tb_Ecomm)->&(Tb_Ecomm+"_DIGRFE")
        EndIf
    EndIf    
EndIf

Do Case
    Case cTipGrf == "P"
        nTpGrf := PIECHART

    Case cTipGrf == "L"
        nTpGrf := LINECHART

    Case cTipGrf == "B"
        nTpGrf := BARCHART

    Case cTipGrf == "C"
        nTpGrf := BARCOMPCHART            

    Case cTipGrf == "F"
        nTpGrf := FUNNELCHART            

    Case cTipGrf == "R"
        nTpGrf := RADARCHART                
    
    OTHERWISE
        nTpGrf := BARCHART

EndCase

If nTpGrf == LINECHART
    oGrafico := FWChartLine():New()
    oGrafico:init( oDlg, .T. )
    For nX:=1 to nDias
        aAdd(aPeriodo,{dData,0})
        dData--
    Next nX
    aPeriodo := aSort(aPeriodo,,,{|x,y| x[1]<y[1]})

    For nX:=1 to Len(aPeriodo)
        aPeriodo[nX,01] := StrZero(Day(aPeriodo[nX,01]),2)+"/"+StrZero(Month(aPeriodo[nX,01]),2)
    Next nX    
    
    For nX:=1 to Len(aDados)	
        nPos := Ascan(aPeriodo,{|x| x[1]==aDados[nX,2]})
        If nPos > 0
            aPeriodo[nPos,02] := aDados[nX,03]
        EndIf
    Next nX

    oGrafico:addSerie("Venda",aPeriodo,Rgb(255,0,0))    
    oGrafico:setLegend( CONTROL_ALIGN_BOTTOM )
    oGrafico:Build()
Else
    oGrafico := FWChartFactory():New()
    oGrafico := oGrafico:getInstance( nTpGrf ) 
    oGrafico:init( oDlg )
    
    If cTpVisao == "Q"
        oGrafico:SetTitle("Visão por Quantidade", CONTROL_ALIGN_CENTER)
    Else
        oGrafico:SetTitle("Visão por Valor (R$)", CONTROL_ALIGN_CENTER)
    EndIf

    If nTpGrf == PIECHART
        oGrafico:SetLegend( CONTROL_ALIGN_BOTTOM )

    ElseIf nTpGrf == BARCOMPCHART
        oGrafico:SetLegend( CONTROL_ALIGN_NONE )
    
    Else
        oGrafico:SetLegend( CONTROL_ALIGN_LEFT )

    Endif	
    oGrafico:nTAlign := CONTROL_ALIGN_ALLCLIENT
    oGrafico:setColor("Random")

    For nX:=1 to Len(aDados)
        If nTpGrf==LINECHART .OR. nTpGrf==BARCOMPCHART 
            //Neste dois tipos de graficos temos:
            //(Titulo, {{ Descrição, Valor }})
            oGrafico:addSerie( aDados[nX,02]   , { { Alltrim(aDados[nX,01]),aDados[nX,03] } } )
        Else
            //Aqui temos:
            //(Titulo, Valor)
            oGrafico:AddSerie(Alltrim(aDados[nX,02]),aDados[nX,03])
        Endif
    Next nX
    oGrafico:build()
EndIf


Return oGrafico

/*/{protheus.doc} AtuGrafico
*******************************************************************************************
Atualiza os Graficos

@author: Marcelo Celi Marques
@since: 29/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuGrafico()
Local nX := 1

_oTempoAtlz:lActive := .F.

//->> Grafico das Vendas
For nX:=1 to Len(aPGrfVisVda[03])
    If Valtype(aPGrfVisVda[03][nX][10])=="O"
        FreeObj(aPGrfVisVda[03][nX][10])
    EndIf

    aPGrfVisVda[03][nX][08] := GetVendas(aPGrfVisVda[03][nX][11], ; // 01 - Filial dos Dados
                                         aPGrfVisVda[03][nX][01], ; // 02 - Codigo do e-Commerce
                                         "V",                     ; // 03 - Tipo dos Dados
                                         aPGrfVisVda[03][nX][12]  ) // 04 - Tipo de Visão

    aPGrfVisVda[03][nX][10] := GetGrafico(aPGrfVisVda[03][nX][06],; // 01 - Dlg do Grafico
                                          aPGrfVisVda[03][nX][09],; // 02 - Tipo de Gráfico
                                          aPGrfVisVda[03][nX][08],; // 03 - Dados do Gráfico
                                          aPGrfVisVda[03][nX][12],; // 04 - Tipo de Visão
                                          aPGrfVisVda[03][nX][01] ) // 05 - Codigo do e-Commerce
Next nX

//->> Grafico dos Produtos
For nX:=1 to Len(aPGrfVisPrd[03])
    If Valtype(aPGrfVisPrd[03][nX][10])=="O"
        FreeObj(aPGrfVisPrd[03][nX][10])
    EndIf

    aPGrfVisPrd[03][nX][08] := GetVendas(aPGrfVisPrd[03][nX][11], ; // 01 - Filial dos Dados
                                         aPGrfVisPrd[03][nX][01], ; // 02 - Codigo do e-Commerce
                                         "P",                     ; // 03 - Tipo dos Dados
                                         aPGrfVisPrd[03][nX][12]  ) // 04 - Codigo do e-Commerce

    aPGrfVisPrd[03][nX][10] := GetGrafico(aPGrfVisPrd[03][nX][06],; // 01 - Dlg do Grafico
                                          aPGrfVisPrd[03][nX][09],; // 02 - Tipo de Gráfico
                                          aPGrfVisPrd[03][nX][08],; // 03 - Dados do Gráfico
                                          aPGrfVisPrd[03][nX][12] ) // 04 - Tipo de Visão
Next nX

//->> Grafico das Vendas por Canal
For nX:=1 to Len(aPGrfVisCan[03])
    If Valtype(aPGrfVisCan[03][nX][10])=="O"
        FreeObj(aPGrfVisCan[03][nX][10])
    EndIf

    aPGrfVisCan[03][nX][08] := GetVendas(aPGrfVisCan[03][nX][11], ; // 01 - Filial dos Dados
                                         aPGrfVisCan[03][nX][01], ; // 02 - Codigo do e-Commerce
                                         "C",                     ; // 03 - Tipo dos Dados
                                         aPGrfVisCan[03][nX][12]  ) // 04 - Codigo do e-Commerce

    aPGrfVisCan[03][nX][10] := GetGrafico(aPGrfVisCan[03][nX][06],; // 01 - Dlg do Grafico
                                          aPGrfVisCan[03][nX][09],; // 02 - Tipo de Gráfico
                                          aPGrfVisCan[03][nX][08],; // 03 - Dados do Gráfico
                                          aPGrfVisCan[03][nX][12] ) // 04 - Tipo de Visão
Next nX


Return
