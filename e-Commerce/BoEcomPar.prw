#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"

/*/{protheus.doc} BoEcomPar
*******************************************************************************************
Atualiza os parametros do processo de e-commerce, em um layout de tela.
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoEcomPar()
Local oWizard       := NIL
Local oScroll       := NIL
Local oFonte        := NIL
Local cTextApres    := ""
Local cLogotipo     := NIL
Local aCoords       := NIL
Local aParams       := {}
Local aSX6          := {}
Local aTelaParms    := {}
Local nX            := 1
Local bCpo          := ""
Local lOk           := .F.
Local xCpo          := NIL
Local cMapPars      := "MC_MAGEURL|MC_MAGEUSR|MC_MAGEPSW|MC_MAGELOJ|MC_ECOMVTK|MC_MAGELOG|MC_MAGETPR|MC_MAGENFE|MC_MAGENAT|MC_MAGETES|MC_MAGECND|MC_MAGESER|MC_MAGEDCO|MC_MAGECLI|MC_MAGEPRD|MC_MAGECAT|MC_MAGEEST|MC_MAGEPRC|MC_MAGEOPE"

Private _aLogico    := {"Verdadeiro","Falso"}

cMapPars := StrTran(cMapPars,"|",";")
cMapPars := StrTran(cMapPars,"/",";")
cMapPars := StrTran(cMapPars,"\",";")
cMapPars := StrTran(cMapPars,",",";")
aParams := StrTokArr(cMapPars, ";" )

oFonte := TFont():New('Arial Black',,16,.T.)

For nX:=1 to Len(aParams)
    SX6->(dbSetOrder(1))
    If SX6->(dbSeek(PadR(cFilAnt,Len(SX6->X6_FIL))+aParams[nX])) .Or. SX6->(dbSeek(PadR(" ",Len(SX6->X6_FIL))+aParams[nX]))
        aAdd(aSX6,{ SX6->X6_VAR,    ;
                    SX6->X6_TIPO,   ;
                    SX6->X6_CONTEUD,;
                    Upper(Alltrim(SX6->X6_DESCRIC))+" "+Upper(Alltrim(SX6->X6_DESC1))+" "+Upper(Alltrim(SX6->X6_DESC2)),;
                    SX6->(Recno())})
    EndIf
Next nX

If Len(aSX6) > 0
    //->> Construcao do Wizard
    oWizard := APWizard():New(  "E-COMMERCE MAGENTO",      		                                ;   // chTitle  - Titulo do cabecalho
                                "Parâmetros",                			                        ;   // chMsg    - Mensagem do cabecalho
                                "",               			        	                        ;   // cTitle   - Titulo do painel de apresentacao
                                cTextApres,       				            		            ;   // cText    - Texto do painel de apresentacao
                                {|| lOk:=MsgYesNo("Confirma a digitacao dos Parametros"),lOk }, ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk:=MsgYesNo("Confirma a digitacao dos Parametros"),lOk }, ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             						                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,          				                            ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                					                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  					                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoords                     				                    )   // aCoord   - Array contendo as coordenadas da tela

    oScroll := TScrollBox():New(oWizard:GetPanel(1),2,2,(oWizard:GetPanel(1):NHEIGHT/2)-8,(oWizard:GetPanel(1):NWIDTH/2)-5,.T.,.T.,.T.)

    For nX:=1 to Len(aSX6)
        aAdd(aTelaParms,Array(10))
        
        //->> [01] - Nome do Parametro
        aTelaParms[Len(aTelaParms)][01] := aSX6[nX,01]
        
        //->> [02] - Painel Superior
        aTelaParms[Len(aTelaParms)][02] := TPanel():New(0,0,'',oScroll, oWizard:oDlg:oFont, .T., .T.,,,(oScroll:NCLIENTWIDTH)/2,38,.T.,.F. )
        aTelaParms[Len(aTelaParms)][02]:Align := CONTROL_ALIGN_TOP

        //->> [03] - Painel com as mesmas dimensoes do acima para ser adicionado dentro do ttoolbox
        aTelaParms[Len(aTelaParms)][03] := TPanel():New(0,0,'',aTelaParms[Len(aTelaParms)][02], oWizard:oDlg:oFont, .T., .T.,,,(aTelaParms[Len(aTelaParms)][02]:NWIDTH)/2,(aTelaParms[Len(aTelaParms)][02]:NHEIGHT)/2,.F.,.F. )
        aTelaParms[Len(aTelaParms)][03]:Align := CONTROL_ALIGN_ALLCLIENT

        //->> [04] - Objeto tToolbox
        aTelaParms[Len(aTelaParms)][04] := TToolBox():New(01,01,aTelaParms[Len(aTelaParms)][02],((aTelaParms[Len(aTelaParms)][02]:NWIDTH)/2)-13,((aTelaParms[Len(aTelaParms)][02]:NHEIGHT)/2)-1 )
        aTelaParms[Len(aTelaParms)][04]:AddGroup( aTelaParms[Len(aTelaParms)][03] , Alltrim(aSX6[nX,01]) )
        aTelaParms[Len(aTelaParms)][04]:cTooltip := aSX6[nX,04]

        //->> [05] - Conteudo do Parametro
        If Upper(Alltrim(aSX6[nX,02])) == "D"
            aTelaParms[Len(aTelaParms)][05] := Stod(Alltrim(aSX6[nX,03]))

        ElseIf Upper(Alltrim(aSX6[nX,02])) == "N"
            aTelaParms[Len(aTelaParms)][05] := Val(Alltrim(aSX6[nX,03]))

        ElseIf Upper(Alltrim(aSX6[nX,02])) == "L"
            If Alltrim(aSX6[nX,03]) == "T" .Or. Alltrim(aSX6[nX,03]) == ".T."
                aTelaParms[Len(aTelaParms)][05] :=  Ascan(_aLogico,{|x| Alltrim(Upper(x))=="VERDADEIRO" })

            ElseIf Alltrim(aSX6[nX,03]) == "F" .Or. Alltrim(aSX6[nX,03]) == ".F." .Or. Empty(aSX6[nX,03])
                aTelaParms[Len(aTelaParms)][05] := Ascan(_aLogico,{|x| Alltrim(Upper(x))=="FALSO" })
            EndIf

        Else
            aTelaParms[Len(aTelaParms)][05] := aSX6[nX,03]
        EndIf

        //->> [06] - Objeto de get/combo a ser exibido na tela para preenchimento dos dados
        bCpo := &("{| u | If( PCount() == 0, aTelaParms["+Alltrim(Str(Len(aTelaParms)))+"][05], aTelaParms["+Alltrim(Str(Len(aTelaParms)))+"][05] := u ) }")

        If Upper(Alltrim(aSX6[nX,02])) == "L"
            //->> Sera combobox        
            aTelaParms[Len(aTelaParms)][06] := TComboBox():New(02,02,bCpo,_aLogico,280,016,/*oDlg*/ aTelaParms[Len(aTelaParms)][03],,{|| },,,,.T.,oFonte,,,,,,,,"aTelaParms["+Alltrim(Str(Len(aTelaParms)))+"][05]")
        Else
            //->> Sera Get            
            aTelaParms[Len(aTelaParms)][06] := TGet():New(01,02,bCpo,/*oDlg*/  aTelaParms[Len(aTelaParms)][03]  ,280,016,If(Upper(Alltrim(aSX6[nX,02])) == "N","9999999999",""),,0,,oFonte,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aTelaParms["+Alltrim(Str(Len(aTelaParms)))+"][05]",,,, /*lHasbutton*/ .T.)
        EndIf

        //->> [07] - Tipo de Dados do Parametro
        aTelaParms[Len(aTelaParms)][07] := Upper(Alltrim(aSX6[nX,02]))

        //->> [08] - Recno do registro do parametro na SX6
        aTelaParms[Len(aTelaParms)][08] := aSX6[nX,05]


    Next nX

    oWizard:OFINISH:CCAPTION := "&Salvar"
	oWizard:OFINISH:CTITLE 	 := "&Salvar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        Begin Transaction
            For nX:=1 to Len(aTelaParms)
                SX6->(dbGoto(aTelaParms[nX,08]))
                
                If aTelaParms[nX,07] == "D"
                    xCpo := dTos(aTelaParms[nX,05])

                ElseIf aTelaParms[nX,07] == "N"
                    xCpo := Alltrim(Str(aTelaParms[nX,05]))

                ElseIf aTelaParms[nX,07] == "L"
                    If Valtype(aTelaParms[nX,05]) <> "N"
                        aTelaParms[nX,05] := Ascan(_aLogico,{|x| Alltrim(Upper(x))==Alltrim(Upper(aTelaParms[nX,05])) })
                    EndIf
                    If aTelaParms[nX,05] == 1
                        xCpo := "T"
                    ElseIf aTelaParms[nX,05] == 2
                        xCpo := "F"
                    Else
                        xCpo := SX6->X6_CONTEUD
                    EndIf

                Else
                    xCpo := Alltrim(aTelaParms[nX,05])

                EndIf

                Reclock("SX6",.F.)
                SX6->X6_CONTEUD := xCpo
                SX6->(MsUnlock())

            Next nX
        End Transaction
    EndIf

EndIf

Return
