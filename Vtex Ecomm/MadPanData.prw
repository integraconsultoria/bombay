#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#INCLUDE 'fileio.ch'

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

/*/{protheus.doc} MaPanData
*******************************************************************************************
Classe de criação de um painel de data
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Class MaPanData
//Propriedades                                           
Data oDlg							//-->> Objeto de Tela
Data aPanels						//-->> Array de Paineis
Data aData  						//-->> Array de Data

//Metodos
Method New() 						//-->> Constructor   

EndClass

/*/{protheus.doc} New
*******************************************************************************************
Classe de incialização da instancia do objeto Mapandata
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Classe MaPanData
*******************************************************************************************
/*/
Method New(oDlg,dData,nAltCel,nLarCel,cTitulo) Class MaPanData    
Local aSemana := Array(7)
Local dInicio := Stod("")
Local dFim    := Stod("")
Local dX      := Stod("")
Local nX      := 0
Local nY      := 0
Local nPosSem := 0
Local dTemp   := Stod("")
Local aLinha  := {}
Local nAltSem := 20
Local oFonte1 := TFont():New("Verdana",,025,,.T.,,,,,.F.,.F.)
Local oFonte2 := TFont():New("Verdana",,035,,.T.,,,,,.F.,.F.)
Local oFonte3 := TFont():New("Verdana",,015,,.T.,,,,,.F.,.F.)
Local oFonte4 := TFont():New("Verdana",,009,,.T.,,,,,.F.,.F.)
Local oFonte5 := TFont():New("Verdana",,010,,.T.,,,,,.F.,.F.)
Local bCmd    := {|| }
Local nCorCel := 0
Local lPan1   := .T.
Local lPan2   := .T.
Local cDia    := ""

Default dData   := Date()
Default nAltCel := 0
Default nLarCel := 0
Default cTitulo := ""

//->> Montagem do Array do Calendario
dInicio := Firstdate(dData)
dFim    := Lastdate(dData)
aData   := {}

aSemana := Array(7)
nX      := Dow(dInicio)
For dX:= dInicio to dFim
    If nX>7
        aAdd(aData,aSemana)
        aSemana := Array(7)
        nX:=1
    EndIf    
    nPosSem := Dow(dX)
    aSemana[nPosSem] := dX
    nX++
Next dX
If Len(aSemana)>0
    aAdd(aData,aSemana)
EndIf

//->> Adequar o inicio do calendario com os dias anteriores
dTemp := dInicio
For nX:=Dow(dInicio) to 1 Step -1
    If Empty(aData[1][nX])
        aData[1][nX] := dTemp
    EndIf
    dTemp--
Next nX

//->> Adequar o final do calendario com os proximos dias
dTemp := dFim
For nX:=Dow(dFim) to 7
    If Empty(aData[Len(aData)][nX])
        aData[Len(aData)][nX] := dTemp
    EndIf
    dTemp++
Next nX

Self:aPanels := {}
Self:aData   := aData

oFWLayer := FWLayer():New()  
oFWLayer:Init(oDlg,.F.,.F.)  
oFWLayer:addLine("LINHA1",100,.F.)  
oFWLayer:AddCollumn("QUADRO1"	,100,.T.,"LINHA1")    
oFWLayer:AddWindow("QUADRO1"	,"Self:oDlg"	,cTitulo,100,.F.,.T.,,"LINHA1",{ || })   
Self:oDlg := oFWLayer:GetWinPanel("QUADRO1","Self:oDlg","LINHA1")   

If nAltCel == 0
    nAltCel := (((Self:oDlg:NHEIGHT/2)-20) - nAltCel)/Len(Self:aData)
EndIf

If nLarCel == 0
    nLarCel := (Self:oDlg:NWIDTH/2)/7
EndIf

oScroll  := TScrollArea():New(Self:oDlg,01,01,((nLarCel*7)+2),((nAltCel*Len(Self:aData))+nAltSem+2),.T.,.T.,.T.)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

For nX:=1 to Len(Self:aData)
    If nX==1
        //->> Dias da Semana
        aAdd(aLinha,TPanel():New(0,0,'',oScroll, oScroll:oFont, .T., .T.,,,((oScroll:NWIDTH)/2),(nAltSem),.F.,.F. ))
        aLinha[Len(aLinha)]:Align := CONTROL_ALIGN_TOP
        
        aAdd(Self:aPanels,Array(7))
        For nY:=1 to Len(Self:aData[nX])
            Self:aPanels[nX,nY] := Array(5)
            Self:aPanels[nX,nY][01] := TPanel():New(0,0,'',aLinha[Len(aLinha)], aLinha[Len(aLinha)]:oFont, .T., .T.,,Rgb(206,206,206),(nLarCel),((aLinha[Len(aLinha)]:NHEIGHT)/2),.F.,.T. )
            Self:aPanels[nX,nY][01]:Align := CONTROL_ALIGN_LEFT
            Self:aPanels[nX,nY][02] := GetSemana(nY)

            bCmd := '{|| Self:aPanels['+Alltrim(Str(Len(Self:aPanels)))+','+Alltrim(Str(nY))+'][02] }'
            bCmd := &bCmd

            Self:aPanels[Len(Self:aPanels),nY][03] := TSay():New((0+3)-0.25 ,(0+5)-0.25  , bCmd  ,Self:aPanels[Len(Self:aPanels),nY][01],,oFonte1,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )
            Self:aPanels[Len(Self:aPanels),nY][04] := TSay():New((0+3)      ,(0+5)       , bCmd  ,Self:aPanels[Len(Self:aPanels),nY][01],,oFonte1,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

        Next nY
    EndIf

    //->> Dias do Mês    
    aAdd(aLinha,TPanel():New(0,0,'',oScroll, oScroll:oFont, .T., .T.,,,((oScroll:NWIDTH)/2),(nAltCel),.F.,.F. ))
    aLinha[Len(aLinha)]:Align := CONTROL_ALIGN_TOP
    
    aAdd(Self:aPanels,Array(7))
    For nY:=1 to Len(Self:aData[nX])
        If Datavalida(Self:aData[nX][nY]) <> Self:aData[nX][nY]
            cFeriado := GetFeriados(Self:aData[nX][nY])
        Else
            cFeriado := ""
        EndIf

        If Self:aData[nX][nY] == Date()
            // Dia Atual
            nCorCel := Rgb(156,156,250)
            lPan1   := .F.
            lPan2   := .T.

        Else
            Do Case
                Case nY==1 // Domingo
                    nCorCel := Rgb(206,206,206)
                    lPan1   := .F.
                    lPan2   := .T.


                Case nY==7 // Sabado
                    nCorCel := Rgb(206,206,206)
                    lPan1   := .F.
                    lPan2   := .T.

                Otherwise // Outros dias                
                    If Datavalida(Self:aData[nX][nY]) <> Self:aData[nX][nY]
                        // Feriado
                        nCorCel := Rgb(206,206,206)
                        lPan1   := .F.
                        lPan2   := .T.

                    Else  
                        // Dias Normais              
                        nCorCel := Rgb(233,233,233)    
                        lPan1   := .T.
                        lPan2   := .F.
                    EndIf   

            EndCase        
        EndIf

        Self:aPanels[Len(Self:aPanels),nY] := Array(7)
        Self:aPanels[Len(Self:aPanels),nY][01] := TPanel():New(0,0,'',aLinha[Len(aLinha)], aLinha[Len(aLinha)]:oFont, .T., .T.,,nCorCel,(nLarCel),((aLinha[Len(aLinha)]:NHEIGHT)/2),lPan1,lPan2)
        Self:aPanels[Len(Self:aPanels),nY][01]:Align := CONTROL_ALIGN_LEFT
        Self:aPanels[Len(Self:aPanels),nY][02] := Self:aData[nX][nY]

        // Painel Superior
        Self:aPanels[Len(Self:aPanels),nY][03] := TPanel():New(1,1,'',Self:aPanels[Len(Self:aPanels),nY][01], Self:aPanels[Len(Self:aPanels),nY][01]:oFont, .T., .T.,,nCorCel,((Self:aPanels[Len(Self:aPanels),nY][01]:NWIDTH)/2)-4,(20)-1,.F.,.F.)
        Self:aPanels[Len(Self:aPanels),nY][03]:Align := CONTROL_ALIGN_TOP

        oPanInf := TPanel():New(1,1,'',Self:aPanels[Len(Self:aPanels),nY][01], Self:aPanels[Len(Self:aPanels),nY][01]:oFont, .T., .T.,,nCorCel,((Self:aPanels[Len(Self:aPanels),nY][01]:NWIDTH)/2)-4,(((Self:aPanels[Len(Self:aPanels),nY][01]:NHEIGHT)/2)-20)-4,.F.,.F.)
        oPanInf:Align := CONTROL_ALIGN_TOP

        oPanInfE := TPanel():New(1,1,'',oPanInf, oPanInf:oFont, .T., .T.,,nCorCel,(5),(((oPanInf:NHEIGHT)/2)),.F.,.F.)
        oPanInfE:Align := CONTROL_ALIGN_LEFT

        oPanInfC := TPanel():New(1,1,'',oPanInf, oPanInf:oFont, .T., .T.,,nCorCel,((oPanInf:NWIDTH)/2)-10,(((oPanInf:NHEIGHT)/2)),.F.,.F.)
        oPanInfC:Align := CONTROL_ALIGN_LEFT

        oPanInfD := TPanel():New(1,1,'',oPanInf, oPanInf:oFont, .T., .T.,,nCorCel,(5),(((oPanInf:NHEIGHT)/2)),.F.,.F.)
        oPanInfD:Align := CONTROL_ALIGN_RIGHT

        // Painel Inferior
        Self:aPanels[Len(Self:aPanels),nY][04] := TPanel():New(1,1,'',oPanInfC,oPanInfC:oFont, .T., .T.,,nCorCel,((oPanInfC:NWIDTH)/2),(((oPanInfC:NHEIGHT)/2)),.F.,.F.)
        Self:aPanels[Len(Self:aPanels),nY][04]:Align := CONTROL_ALIGN_TOP

        //->> Exibição do Dia (com sombra)
        cDia := Alltrim(Str(Day(Self:aPanels[Len(Self:aPanels),nY][02])))
        bCmd := '{|| "'+cDia+'" }'
        bCmd := &bCmd

        oDia1 := TSay():New((0+2)-0.25 ,(0+3 + If(Len(cDia)==1,9,0))-0.25  , bCmd  ,Self:aPanels[Len(Self:aPanels),nY][03],,oFonte2,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )
        oDia2 := TSay():New((0+2)      ,(0+3 + If(Len(cDia)==1,9,0))       , bCmd  ,Self:aPanels[Len(Self:aPanels),nY][03],,oFonte2,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

        //->> Exibição do Mês
        bCmd := '{|| "'+Left(GetMes(Month(Self:aPanels[Len(Self:aPanels),nY][02])),3)+'" }'
        bCmd := &bCmd

        oMes := TSay():New(02,23, bCmd  ,Self:aPanels[Len(Self:aPanels),nY][03],,oFonte3,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

        //->> Exibição do Ano
        bCmd := '{|| "'+Alltrim(Str(Year(Self:aPanels[Len(Self:aPanels),nY][02])))+'" }'
        bCmd := &bCmd

        oAno := TSay():New(08,23, bCmd  ,Self:aPanels[Len(Self:aPanels),nY][03],,oFonte4,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

        //->> Exibição do Feriado (quando houver)
        bCmd := '{|| "'+cFeriado+'" }'
        bCmd := &bCmd

        oFeriado := TSay():New(13,23 , bCmd  ,Self:aPanels[Len(Self:aPanels),nY][03],,oFonte5,,,,.T.,Rgb(255,0,0),CLR_WHITE,(100),(20) )

    Next nY
Next nX

Return Self

/*/{protheus.doc} GetSemana
*******************************************************************************************
Função de retorno do dia da semana
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetSemana(nDiaSemana)
Local cDiaSemana := ""

Do Case
    Case nDiaSemana == 1
        cDiaSemana := "Domingo"

    Case nDiaSemana == 2
        cDiaSemana := "Segunda-Feira"

    Case nDiaSemana == 3
        cDiaSemana := "Terça-Feira"

    Case nDiaSemana == 4
        cDiaSemana := "Quarta-Feira"    

    Case nDiaSemana == 5
        cDiaSemana := "Quinta-Feira"

    Case nDiaSemana == 6
        cDiaSemana := "Sexta-Feira"

    Case nDiaSemana == 7
        cDiaSemana := "Sábado"

EndCase

Return cDiaSemana

/*/{protheus.doc} GetMes
*******************************************************************************************
Função de retorno do mês
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetMes(nMes)
Local cMes := ""

Do Case
    Case nMes == 1
        cMes := "Janeiro"

    Case nMes == 2
        cMes := "Fevereiro"

    Case nMes == 3
        cMes := "Março"

    Case nMes == 4
        cMes := "Abril"

    Case nMes == 5
        cMes := "Maio"

    Case nMes == 6
        cMes := "Jun"

    Case nMes == 7
        cMes := "Julho"

    Case nMes == 8
        cMes := "Agosto"

    Case nMes == 9
        cMes := "Setembro"    

    Case nMes == 10
        cMes := "Outubro"

    Case nMes == 11
        cMes := "Novembro"

    Case nMes == 12
        cMes := "Dezembro"        

EndCase

Return cMes

/*/{protheus.doc} GetFeriados
*******************************************************************************************
Função de Teste de Calendario
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetFeriados(dData)
Local cFeriado  := ""
Local aFeriados := RetFeriados()
Local nX        := 1
Local cDDMM     :=""
Local cDDMMAA   :=""

For nX:=1 to Len(aFeriados)
    If dTos(dData)==aFeriados[nX]
        cDDMM   := StrZero(Day(Stod(aFeriados[nX])),2)+"/"+StrZero(Month(Stod(aFeriados[nX])),2)
        cDDMMAA := StrZero(Day(Stod(aFeriados[nX])),2)+"/"+StrZero(Month(Stod(aFeriados[nX])),2)+"/"+Right(StrZero(Year(Stod(aFeriados[nX])),4),2)
        SX5->(dbSetOrder(1))
        SX5->(dbSeek(xFilial("SX5")+PadR("63",Tamsx3("X5_TABELA")[01])))
        Do While SX5->(!Eof()) .And. SX5->(X5_FILIAL+X5_TABELA) == xFilial("SX5")+PadR("63",Tamsx3("X5_TABELA")[01])
            If Left(SX5->X5_DESCRI,8)==cDDMMAA .Or. Left(SX5->X5_DESCRI,5)==cDDMM
                cFeriado := Capital(Alltrim(SubStr(SX5->X5_DESCRI,9,Tamsx3("X5_DESCRI")[01]-9)))+CRLF
            EndIf
            SX5->(dbSkip())
        EndDo
    EndIf
Next nX

Return cFeriado

/*/{protheus.doc} MaVerVdEco
*******************************************************************************************
Analisa o periodo de vendas do ecommerce
 
@author: Marcelo Celi Marques
@since: 29/09/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaVerVdEco(cEcommerce)
Local oWizard   := NIL
Local lOk       := .F. 
Local aCoord    := {0,0,300,550}
Local cLogotipo := "ng_ico_ss_pendente.png"
Local cTextApres:= ""
Local cMsg      := ""
Local aParambox := {}
Local lJob      := .F.
Local cFilEcom  := ""
Local _cFilAnt  := ""
Local cLogo     := ""
Local cNome     := ""

lJob := Select( "SM0" ) <= 0
If lJob
    RpcSetType(3)
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
    SetFlatControls(.F.)
    MsApp():New('SIGAMDI')              
    InitPublic()
    SetSkinDefault()
EndIf

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,cEcommerce)
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cEcommerce))    
        cLogo := (Tb_Ecomm)->&(Tb_Ecomm+"_LOGO")
        cNome := Capital(Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_DESCRI")))

        Private aGrafico    := {}
        Private aRetParam 	:= {}
        Private aMeses      := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
        Private aTipData    := {"Periodo de Venda no Site"}

        Private _oProcess   := NIL

        _cFilAnt := cFilAnt        
        cFilEcom := FilEcomm
        If !Empty(cFilEcom)
            cFilAnt  := cFilEcom
        EndIf

        aRetParam := {Year(Date()),Month(Date()),1}
        aAdd(aParambox,{1,"Ano" 		    		              ,aRetParam[01],"9999","","",".T.",30 ,.T.})
        aAdd(aParambox,{2,"Mes"                                   ,aRetParam[02],aMeses,150,".T.",.T.})  
        aAdd(aParambox,{2,"Considerar"                            ,aRetParam[03],aTipData,150,".T.",.T.})  

        cTextApres  := "Reste recurso permite uma Visibilidade Geral das Vendas Descidas do e-Commerce do Período para Análise de Desempenho."
        cMsg        := "Confirma os Parâmetros informados para a Visualização do Desempenho ?"

        oWizard := APWizard():New("Desempenho Analitico",                               							     ;   // chTitle  - Titulo do cabecalho
                                "Painel de Análise de Desempenho",                                      	    	     ;   // chMsg    - Mensagem do cabecalho
                                "Descida de Vendas "+cNome,                                                           ;   // cTitle   - Titulo do painel de apresentacao
                                cTextApres,      										     			         	     ;   // cText    - Texto do painel de apresentacao
                                    {|| .T. },                                                                           ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| .T. },                                                                           ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    cLogotipo,        	   												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    aCoord 		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

        oWizard:NewPanel(   "Descida de Vendas "+cNome,                             ;   // cTitle   - TÃ­tulo do painel 
                            "Informe o Periodo da Venda",                           ;   // cMsg     - Mensagem posicionada no cabeÃ§alho do painel
                            {|| .T. },                                              ;   // bBack    - Bloco de cÃ³digo utilizado para validar o botÃ£o "Voltar"
                            {|| lOk:= MsgYesNo(cMsg),lOk },                         ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| lOk:= MsgYesNo(cMsg),lOk },                         ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,                                                    ;   // lPanel   - Se .T. serÃ¡ criado um painel, se .F. serÃ¡ criado um scrollbox
                            {|| .T. }                                               )   // bExecute - Bloco de cÃ³digo a ser executado quando o painel for selecionado

        Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)
        oWizard:OFINISH:CCAPTION := "Gerar"

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

        If lOk
            _oProcess := MsNewProcess():New( {|lEnd| ProcessGrf(cEcommerce,cLogo) }, 'Aguarde...', 'Processando a Análise de Desempenho...', .F. )
            _oProcess:Activate()
        EndIf
    Else
        MsgAlert("e-Commerce não Localizado...")
    EndIf        
EndIf

cFilAnt := _cFilAnt
If lJob
    RESET ENVIRONMENT
EndIf    

Return

/*/{protheus.doc} ProcessGrf
*******************************************************************************************
Função de Processamento do Grafico
 
@author: Marcelo Celi Marques
@since: 30/09/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function ProcessGrf(cEcommerce,cLogo)
Local oDlg      := NIL
Local oPanel    := NIL
Local dData     := Date()
Local nX        := 1
Local nY        := 1
Local nZ        := 1
Local nHH       := 0
Local aDados    := {}
Local aDadTot   := {}
Local nInterv   := 4
Local nIntAtu   := 0
Local nQtd      := 0 
Local oTimeGrfs := NIL
Local nSegunAtu := 60

Private oPandata  := NIL

If Valtype(aRetParam[02]) <> "N"
    aRetParam[02] := Ascan(aMeses,{|x| Alltrim(x)==Alltrim(aRetParam[02]) })
EndIf

If Valtype(aRetParam[03]) <> "N"
    aRetParam[03] := Ascan(aTipData,{|x| Alltrim(x)==Alltrim(aRetParam[03]) })
EndIf

dData := Stod(StrZero(aRetParam[01],4)+StrZero(aRetParam[02],2)+"01")

oDlg := FWStyledDialog():New(0,0,768,1366,"",{||})
oPanel  := TScrollArea():New(oDlg,01,01,((oDlg:NWIDTH)/2)-2,((oDlg:NHEIGHT)/2)-2,.T.,.T.,.T.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPandata := MAPanData():New(oPanel,dData,/*100*/,/*200*/,"Desempenho Analítico de Vendas no Período")

_oProcess:SetRegua1(Len(oPandata:aPanels))
For nX:=2 to Len(oPandata:aPanels)
    _oProcess:IncRegua1("Processando Vendas...")
    _oProcess:SetRegua2(Len(oPandata:aPanels[nX]))
    For nY:=1 to Len(oPandata:aPanels[nX])
        _oProcess:IncRegua2("Processando Períodos...")
        aDados := {}
        aAdd(aDados,Array(03))
        aDados[Len(aDados)][01] := "Vendas" 	            // 01 - Descrição
        aDados[Len(aDados)][02] := Rgb(255,0,0)	    		// 02 - Cor
        aDados[Len(aDados)][03] := {}						// 03 - Itens sem legenda inferior
                
        aDadTot := {}
        aAdd(aDadTot,Array(03))
        aDadTot[Len(aDadTot)][01] := "Vendas" 	            // 01 - Descrição
        aDadTot[Len(aDadTot)][02] := Rgb(255,0,0)	  		// 02 - Cor
        aDadTot[Len(aDadTot)][03] := {}						// 03 - Itens sem legenda inferior
                
        If Month(oPandata:aData[nX-1][nY]) == Month(dData) .And. Year(oPandata:aData[nX-1][nY]) == Year(dData)
            For nHH:=1 to 24
                If oPandata:aData[nX-1][nY] <= Date()
                    nQtd := GetPeriodos(cEcommerce,cFilAnt,aRetParam[03],oPandata:aData[nX-1][nY],oPandata:aData[nX-1][nY],StrZero(nHH-1,2),StrZero(nHH-1,2),2)
                Else
                    nQtd := 0
                EndIf                
                If nIntAtu == nInterv .Or. nHH==1 .Or. nHH==24                    
                    aAdd(aDados[Len(aDados)][03]	,{StrZero(nHH-1,02)      ,; // 01 - Hora da Execução
                                                    nQtd        		   	 }) // 02 - Quantidade de Execuções
                    
                    nIntAtu := 0
                Else
                    aDados[Len(aDados)][03][Len(aDados[Len(aDados)][03])][02] += nQtd
                EndIf
                aAdd(aDadTot[Len(aDadTot)][03]	   ,{StrZero(nHH-1,02)+":00",; // 01 - Hora da Execução
                                                    nQtd        		   	 }) // 02 - Quantidade de Execuções
                nIntAtu++
            Next nHH
        
            aAdd(aGrafico,{ FWChartLine():New(),     ; // 01 - Objeto Grafico
                            oPandata:aData[nX-1][nY],; // 02 - Data do Objeto
                            aDadTot})                  // 03 - Dados do Grafico

            aGrafico[Len(aGrafico)][01]:init( oPandata:aPanels[nX,nY][04] , .T. )
            For nZ:=1 to Len(aDados)	
                aGrafico[Len(aGrafico)][01]:addSerie(Alltrim(aDados[nZ,01]),aDados[nZ,03],aDados[nZ,02])
            Next nZ        
            aGrafico[Len(aGrafico)][01]:Build()
            aGrafico[Len(aGrafico)][01]:oOwner:blclicked := &("{|| ExpandeTela('"+Dtos(oPandata:aData[nX-1][nY])+"','"+cLogo+"') }")
        EndIf
    Next nY
Next nX

//->> Timer de atualização dos graficos
oTimeGrfs := TTimer():New(nSegunAtu * 1000, {|| AtualizGrf(cEcommerce) },oDlg)
oTimeGrfs:Activate()

oDlg:Activate(,,,.T.,,, {||  })

Return

/*/{protheus.doc} AtualizGrf
*******************************************************************************************
Atualiza o Grafico na data atual.
 
@author: Marcelo Celi Marques
@since: 02/10/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function AtualizGrf(cEcommerce)
Local nX        := 1
Local nZ        := 1
Local nPosPan   := 0
Local nPosGrf   := 0
Local nQtd      := 0
Local nHH       := 0
Local aDados    := {}
Local aDadTot   := {}
Local nInterv   := 4
Local nIntAtu   := 0

For nX:=1 to Len(oPandata:aData)
    nPosPan := aScan(oPandata:aData[nX],{|x| x == dDatabase })
    If nPosPan > 0
        nPosGrf := aScan(aGrafico,{|x| x[02]==dDatabase })
        If nPosGrf > 0
            aDados := {}
            aAdd(aDados,Array(03))
            aDados[Len(aDados)][01] := "Vendas" 	            // 01 - Descrição
            aDados[Len(aDados)][02] := Rgb(255,0,0)	    		// 02 - Cor
            aDados[Len(aDados)][03] := {}						// 03 - Itens sem legenda inferior
        
            aDadTot := {}
            aAdd(aDadTot,Array(03))
            aDadTot[Len(aDadTot)][01] := "Vendas" 	            // 01 - Descrição
            aDadTot[Len(aDadTot)][02] := Rgb(255,0,0)	  		// 02 - Cor
            aDadTot[Len(aDadTot)][03] := {}						// 03 - Itens sem legenda inferior

            For nHH:=1 to 24
                nQtd := GetPeriodos(cEcommerce,cFilAnt,aRetParam[03],dDatabase,dDatabase,StrZero(nHH-1,2),StrZero(nHH-1,2),2)                
                If nIntAtu == nInterv .Or. nHH==1 .Or. nHH==24                    
                    aAdd(aDados[Len(aDados)][03]	,{StrZero(nHH-1,02)      ,; // 01 - Hora da Execução
                                                    nQtd        		   	 }) // 02 - Quantidade de Execuções
                    
                    nIntAtu := 0
                Else
                    aDados[Len(aDados)][03][Len(aDados[Len(aDados)][03])][02] += nQtd
                EndIf
                aAdd(aDadTot[Len(aDadTot)][03]	   ,{StrZero(nHH-1,02)+":00",; // 01 - Hora da Execução
                                                    nQtd        		   	 }) // 02 - Quantidade de Execuções
                nIntAtu++
            Next nHH
            
            FreeObj(aGrafico[nPosGrf][01])            
            aGrafico[nPosGrf][01] := FWChartLine():New()
            aGrafico[nPosGrf][03] := aDadTot
            
            aGrafico[nPosGrf][01]:init( oPandata:aPanels[nX+1][nPosPan][04] , .T. )
            For nZ:=1 to Len(aDados)	
                aGrafico[nPosGrf][01]:addSerie(Alltrim(aDados[nZ,01]),aDados[nZ,03],aDados[nZ,02])
            Next nZ        
            aGrafico[nPosGrf][01]:Build()
            aGrafico[nPosGrf][01]:oOwner:blclicked := &("{|| ExpandeTela('"+Dtos(dDatabase)+"') }")
        EndIf    
        Exit
    EndIf
Next nX

Return

/*/{protheus.doc} ExpandeTela
*******************************************************************************************
Função de Expandir a Tela
 
@author: Marcelo Celi Marques
@since: 30/09/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function ExpandeTela(cData,cLogo)
Local dData     := Stod(cData)
Local oDlg      := NIL
Local oPanSup   := NIL
Local oPanCen   := NIL
Local oPanInf   := NIL
Local oPanCSup  := NIL
Local oPanCCen  := NIL
Local oPanCCEsq := NIL
Local oPanCCCen := NIL
Local oPanCCDir := NIL
Local oPanCInf  := NIL
Local oLogo     := NIL
Local oGrafico  := NIL
Local oFonte1   := TFont():New("Verdana",,025,,.T.,,,,,.F.,.F.)
Local oFonte2   := TFont():New("Verdana",,035,,.T.,,,,,.F.,.F.)
Local oFonte3   := TFont():New("Verdana",,015,,.T.,,,,,.F.,.F.)
Local oFonte4   := TFont():New("Verdana",,009,,.T.,,,,,.F.,.F.)
Local aDados    := {}
Local nX        := 1
Local nColInic  := 0
Local nPosGrf   := 0

oDlg := FWStyledDialog():New(0,0,400,1200,"",{||})

oPanSup := TPanel():New(0,0,'',oDlg,oDlg:oFont, .T., .T.,,Rgb(206,206,206),((oDlg:NWIDTH)/2),(40),.F.,.T. )
oPanSup:Align := CONTROL_ALIGN_TOP
            
oPanCen := TPanel():New(0,0,'',oDlg,oDlg:oFont, .T., .T.,,Rgb(233,233,233),((oDlg:NWIDTH)/2),((oDlg:NHEIGHT)/2)-50,.T.,.F. )
oPanCen:Align := CONTROL_ALIGN_TOP

    oPanCSup := TPanel():New(2,2,'',oPanCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),((oPanCen:NWIDTH)/2),(10)-4,.F.,.F. )
    oPanCSup:Align := CONTROL_ALIGN_TOP

    oPanCCen := TPanel():New(2,2,'',oPanCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),((oPanCen:NWIDTH)/2),((oPanCen:NHEIGHT)/2)-20-4,.F.,.F. )
    oPanCCen:Align := CONTROL_ALIGN_TOP

            oPanCCEsq := TPanel():New(2,2,'',oPanCCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),(10),((oPanCCen:NHEIGHT)/2)-20-4,.F.,.F. )
            oPanCCEsq:Align := CONTROL_ALIGN_LEFT

                oPanCCCen := TPanel():New(2,2,'',oPanCCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),((oPanCCen:NWIDTH)/2)-20-4,((oPanCCen:NHEIGHT)/2),.T.,.T. )
                oPanCCCen:Align := CONTROL_ALIGN_LEFT

            oPanCCDir := TPanel():New(2,2,'',oPanCCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),(10),((oPanCCen:NHEIGHT)/2)-20-4,.F.,.F. )
            oPanCCDir:Align := CONTROL_ALIGN_RIGHT

    oPanCInf := TPanel():New(2,2,'',oPanCen,oDlg:oFont, .T., .T.,,Rgb(233,233,233),((oPanCen:NWIDTH)/2),(10)-4,.F.,.F. )
    oPanCInf:Align := CONTROL_ALIGN_BOTTOM

oPanInf := TPanel():New(0,0,'',oDlg,oDlg:oFont, .T., .T.,,Rgb(206,206,206),((oDlg:NWIDTH)/2),(10),.F.,.T. )
oPanInf:Align := CONTROL_ALIGN_BOTTOM

aDados := {}
nPosGrf := Ascan(aGrafico,{|x| x[02]==dData })
If nPosGrf > 0
    aDados := aGrafico[nPosGrf,03]
EndIf

//->> Logo Tipo
oLogo := TBitmap():New(02,02,70,(oPanSup:NHEIGHT/2)-4,"",cLogo,.T.,oPanSup,,,.F.,.T.,,,.F.,,.T.,,.F.)
nColInic := (oLogo:NCLIENTHEIGHT/2)+40

//->> Exibição do Dia (com sombra)
cDia := Alltrim(Str(Day(dData)))
bCmd := '{|| "'+cDia+'" }'
bCmd := &bCmd

oDia1 := TSay():New((0+5)-0.25 ,(nColInic+3 + If(Len(cDia)==1,9,0))-0.25  , bCmd  ,oPanSup,,oFonte2,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )
oDia2 := TSay():New((0+5)      ,(nColInic+3 + If(Len(cDia)==1,9,0))       , bCmd  ,oPanSup,,oFonte2,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

//->> Exibição do Mês
bCmd := '{|| "'+Left(GetMes(Month(dData)),3)+'" }'
bCmd := &bCmd

oMes := TSay():New(05,nColInic+23, bCmd  ,oPanSup,,oFonte3,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

//->> Exibição do Ano
bCmd := '{|| "'+Alltrim(Str(Year(dData)))+'" }'
bCmd := &bCmd

oAno := TSay():New(11,nColInic+23, bCmd  ,oPanSup,,oFonte4,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

cSemana := GetSemana(Dow(dData))
bCmd := "{|| '"+cSemana+"' }"
bCmd := &bCmd

oSeman1 := TSay():New((20)-0.25 ,(nColInic+10)-0.25  , bCmd  ,oPanSup,,oFonte1,,,,.T.,Rgb(122,122,122),CLR_WHITE,(100),(20) )
oSeman2 := TSay():New((20)      ,(nColInic+10)       , bCmd  ,oPanSup,,oFonte1,,,,.T.,Rgb(0,0,0),CLR_WHITE,(100),(20) )

//->> Composição do Gráfico
oGrafico := FWChartLine():New()
oGrafico:init( oPanCCCen , .T. )
For nX:=1 to Len(aDados)	
    oGrafico:addSerie(Alltrim(aDados[nX,01]),aDados[nX,03],aDados[nX,02])
Next nX        
oGrafico:Build()

oDlg:Activate(,,,.T.,,, {||  })

Return

/*/{protheus.doc} GetPeriodos
*******************************************************************************************
Retorna os Periodos de Vendas
 
@author: Marcelo Celi Marques
@since: 02/10/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPeriodos(cEcommerce,cFilPed,nTipo,dInicio,dFim,cHHInic,cHHFinal,nTpRetorno)
Local aPeriodos := {}
Local nQtde     := 0
Local cQuery    := ""
Local cAlias    := GetNextAlias()

cQuery := "SELECT COUNT(*) AS QTDE,"                                                    +CRLF
cQuery += "CJ_XDTINTE AS DATA, LEFT(CJ_XHRINTE,2) AS HORA"                              +CRLF 
cQuery += " FROM "+RetSqlName("SCJ")+" SCJ (NOLOCK)"                                    +CRLF
cQuery += " WHERE SCJ.CJ_FILIAL = '"+cFilPed+"'"                                        +CRLF
cQuery += "   AND SCJ.CJ_XORIGEM = '"+cEcommerce+"'"                                    +CRLF
cQuery += "   AND SCJ.CJ_XIDINTG <> ' '"                                                +CRLF
cQuery += "   AND SCJ.CJ_XDTINTE BETWEEN '"+dTos(dInicio)+"' AND '"+dTos(dFim)+"'"      +CRLF
cQuery += "   AND LEFT(SCJ.CJ_XHRINTE,2) BETWEEN '"+cHHInic+"' AND '"+cHHFinal+"'"      +CRLF
cQuery += "   AND SCJ.D_E_L_E_T_ = ' '"                                                 +CRLF
cQuery += " GROUP BY CJ_XDTINTE, CJ_XHRINTE"                                            +CRLF
cQuery += " ORDER BY CJ_XDTINTE, CJ_XHRINTE"                                            +CRLF    

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
Do While (cAlias)->(!Eof())
    If nTpRetorno == 1
        aAdd(aPeriodos,{Stod((cAlias)->DATA),(cAlias)->HORA,(cAlias)->QTDE})
    Else
        nQtde += (cAlias)->QTDE
    EndIf    
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return If(nTpRetorno==1,aPeriodos,nQtde)
