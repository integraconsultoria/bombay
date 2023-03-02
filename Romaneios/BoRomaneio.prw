#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"

Static POSITEM 	    := 0
Static nCorItem		:= Rgb(255,201,14)

Static POSITHIS	    := 0
Static nCorItHis	:= Rgb(174,227,244)

Static cImgF_OK     := "qmt_ok"
Static cImgF_NOK    := "qmt_no"
Static cImgF_VAS    := "qmt_cond"

/*/{protheus.doc} BoRomaneio
*******************************************************************************************
Controle de Romaneios
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoRomaneio()
Private aRotina 	:= MenuDef()
Private cCadastro 	:="Controle de Romaneios de Transporte"

mBrowse( 6, 1,22,75,"ZR1",,,,,,u_BoRomLegen())

Return

/*/{protheus.doc} BoRomLegen
*******************************************************************************************
Controle de Romaneios - Legenda
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoRomLegen(cAlias,nReg)
Local uRetorno := .T.
Local aLegenda := {	{"BR_VERDE"	    , 	"Elaboração Liberado"    },;
                    {"BR_AZUL"		, 	"Elaboração Bloqueado"   },;	 
					{"BR_VERMELHO"	, 	"Faturado e Finalizado"  }}	   	

If nReg = Nil	
	uRetorno := {}
	Aadd(uRetorno, {'ZR1_STATUS == "1" .And. ZR1_FAPROV <> "B"'		, aLegenda[1][1]})  
	Aadd(uRetorno, {'ZR1_STATUS == "2" .And. ZR1_FAPROV == "B"'		, aLegenda[2][1]}) 
	Aadd(uRetorno, {'ZR1_STATUS == "3"'		                        , aLegenda[3][1]}) 
Else
	BrwLegenda(cCadastro,"Legenda",aLegenda) 
Endif

Return uRetorno

/*/{protheus.doc} MenuDef
*******************************************************************************************
Cotação de Romaneios - Menus
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	        , "AxPesqui"  		,0,1,0	,.F.},;  
					 {"Visualizar"	        , "u_BoRomManut"	,0,2,0	,nil},;  
					 {"Incluir"		        , "u_BoRomManut"	,0,3,81	,nil},; 
					 {"Alterar"		        , "u_BoRomManut"	,0,4,3	,nil},;
					 {"Excluir"		        , "u_BoRomManut"	,0,5,81	,nil},;                     
                     {"Efet Faturar"        , "u_BoRomManut"	,0,6,81	,nil},;
                     {"Voltar Elaboração"   , "u_BoRomManut"	,0,7,81	,nil},;
                     {"Imprimir"            , "u_BoRelRoma"	    ,0,8,81	,nil},;
					 {"Legenda"		        , "u_BoRomLegen" 	,0,2, 	,.F.}}

Return(aRotina) 

/*/{protheus.doc} BoRomManut
*******************************************************************************************
Manutenção de Romaneios - Menutenção
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoRomManut(cAlias,nReg,nOpc)
Local cLogotipo := ""
Local aSize	   	:= MsAdvSize()
Local aCoords   := {}
Local oWizard   := NIL
Local oPan1     := NIL
Local oPan2     := NIL
Local oPan3     := NIL
Local oPanButt  := NIL
Local lOk       := .F.
Local lEdita    := .F.
Local aCposEnch := {}
Local aCposEdit := {}
Local nModelo	:= 1        
Local lF3		:= .F.
Local lMemoria 	:= .T.
Local lColumn  	:= .F.
Local caTela 	:= ""
Local lNoFolder	:= .F.
Local lProperty	:= .F. 
Local cRomaneio := ""
Local aCols     := {}
Local aColsTmp  := {}
Local aHeader   := {}
Local aStruct   := {}
Local nX        := 1
Local nY        := 1
Local cMensagem := ""
Local bCampo    := { |nCPO| Field(nCPO) }
Local lContinua := .T.
Local oFolder   := NIL
Local xConteudo := NIL
Local nTamanho  := 0
Local cCaption  := ""
Local aReentrega:= {}
Local aButtBar  := {}

Private oDoctos     := NIL
Private oHistorico  := NIL
Private oEnch1      := NIL
Private oEnch2      := NIL

Do Case
    Case nOpc == 2
        cLogotipo := "veiimg32"        
        lContinua := .T.
        cCaption  := "OK"

    Case nOpc == 3
        cLogotipo := "veiimg32"
        cMensagem := "Confirma a Inclusão do Romaneio ?"
        lContinua := .T.
        cCaption  := "Incluir"

    Case nOpc == 4
        cLogotipo := "veiimg32"
        cMensagem := "Confirma a Alteração do Romaneio ?"
        cCaption  := "Alterar"
        If ZR1->ZR1_STATUS <> "1"
            MsgAlert("Romaneio não encontra-se em fase de Elaboração e não pode ser Alterado.")
            lContinua := .F.
        EndIf

    Case nOpc == 5
        cLogotipo := "veiimg32"
        cMensagem := "Confirma a Exclusão do Romaneio ?"
        cCaption  := "Excluir"
        If ZR1->ZR1_STATUS <> "1"
            MsgAlert("Romaneio não encontra-se em fase de Elaboração e não pode ser Excluido.")
            lContinua := .F.
        EndIf
    
    Case nOpc == 6
        cLogotipo := "tmsimg32"
        cMensagem := "Confirma a Efetivação do Faturamento do Romaneio ?"
        cCaption  := "Confirmar"
        If ZR1->ZR1_STATUS <> "1"
            MsgAlert("Romaneio não encontra-se em fase de Emaboração e não pode ter seu Faturamento Efetivado.")
            lContinua := .F.
        EndIf

        If ZR1->ZR1_FAPROV == "B"
            MsgAlert("Romaneio não pode ser Faturado devido a este estar Bloqueado."+CRLF+"Solicite a Liberção ao Departamento Responsável.")
            lContinua := .F.
        EndIf

    Case nOpc == 7
        cLogotipo := "puzzle"
        cMensagem := "Confirma o Estorno das etapas anteriores e voltar para a fase de Elaboração ?"
        cCaption  := "Confirmar"
        If ZR1->ZR1_STATUS == "1"
            MsgAlert("Romaneio já Encontra-se em Fase de Elaboração")
            lContinua := .F.
        ElseIf ZR1->ZR1_STATUS == "3"
            SF1->(dbSetOrder(1))
            If SF1->(dbSeek(xFilial("SF1")+ZR1->(ZR1_FATURA+ZR1_SERIE+ZR1_MOTOR+ZR1_LJMOTO)))
                MsgAlert("Romaneio já Faturado."+CRLF+"Para continuar, antes exclua o documento de pre-nota/documento de entrada.")
                lContinua := .F.
            EndIf
        EndIf

EndCase

If lContinua    
    If nOpc == 6
        RegToMemory( cAlias, .F., .F. )
        
        aCoords := {0,0,350,800}
        lEdita  := .T.    
        oWizard := APWizard():New(  "Romaneios de Coleta",                 												 ;   // chTitle  - Titulo do cabeå ?lho
                                    "Efetivação de Faturamento", 	               				         			     ;   // chMsg    - Mensagem do cabeå ?lho
                                    "Manutenção de Romaneios", 											 			     ;   // cTitle   - Tå ?ulo do painel de apresentaí”Œo
                                    "",                													 			     ;   // cText    - Texto do painel de apresentaí”Œo
                                    {|| lOk := If(!Empty(cMensagem),MsgYesNo(cMensagem) .And. TudoOk(nOpc),.T.),lOk},    ;   // bNext    - Bloco de cå ?igo a ser executado para validar o botå ? "Avanå ?r"
                                    {|| lOk := If(!Empty(cMensagem),MsgYesNo(cMensagem) .And. TudoOk(nOpc),.T.),lOk},	 ;   // bFinish  - Bloco de cå ?igo a ser executado para validar o botå ? "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. serå ?criado um painel, se .F. serå ?criado um scrollbox
                                    cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabeå ?lho, essa tem que fazer parte do repositå ?io 
                                    {|| },                												 			     ;   // bExecute - Bloco de cå ?igo contendo a aí”Œo a ser executada no clique dos botå ?s "Avanå ?r" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nå ? exibe o painel de apresentaí”Œo
                                    aCoords                     										 				 )   // aCoord   - Array contendo as coordenadas da tela

        aCposEnch := {}
        aAdd(aCposEnch,"NOUSER")
        aAdd(aCposEnch,"ZR1_CONDIC")
        aAdd(aCposEnch,"ZR1_FATURA")
        aAdd(aCposEnch,"ZR1_SERIE")
        aAdd(aCposEnch,"ZR1_MOTOR")
        aAdd(aCposEnch,"ZR1_LJMOTO")
        aAdd(aCposEnch,"ZR1_NOME")
        aAdd(aCposEnch,"ZR1_VLFRET")

        aAdd(aCposEdit,"ZR1_CONDIC")
        aAdd(aCposEdit,"ZR1_FATURA")
        aAdd(aCposEdit,"ZR1_SERIE")        
        
        oEnch1				:= MsMGet():New( "ZR1", ZR1->( RecNo() ),4,,,,aCposEnch,{00,00,((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),((oWizard:GetPanel(1):NCLIENTWIDTH)/2)},aCposEdit,nModelo,,,,oWizard:GetPanel(1),lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)
        oEnch1:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

        oWizard:OFINISH:CCAPTION := cCaption

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o diå ?ogo serå ?centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de cå ?igo a ser executado no encerramento do diå ?ogo
                            {|| .T. },  ;   // bInit    - Bloco de cå ?igo a ser executado na inicializaí”Œo do diå ?ogo
                            {|| .T. }   )   // bWhen    - Bloco de cå ?igo para habilitar a execuí”Œo do diå ?ogo
        
        If lOk
            Begin Transaction
                If GeraPrenota()
                    Reclock("ZR1",.F.)
                        ZR1->ZR1_CONDIC := M->ZR1_CONDIC
                        ZR1->ZR1_FATURA := M->ZR1_FATURA
                        ZR1->ZR1_SERIE  := M->ZR1_SERIE
                        ZR1->ZR1_STATUS := "3" 
                    ZR1->(MsUnlock())                
                    
                    //->> Gravação do Log
                    GravaLog(nOpc)
                Else
                    DisarmTransaction()
                EndIf
            End Transaction
        EndIf

    ElseIf nOpc == 7
        If MsgYesNo("Confirma o estorno das operações anteriores e disponibilização do romaneio na fase de elaboração?") .And. TudoOk(nOpc)
            Begin Transaction
                RecLock("ZR1",.F.)
                ZR1->ZR1_STATUS := "1"
                ZR1->ZR1_FATURA := ""
                ZR1->ZR1_SERIE  := ""
                ZR1->ZR1_CONDIC := ""
                ZR1->ZR1_COTAC  := ""
                ZR1->ZR1_MOTOR  := ""
                ZR1->ZR1_LJMOTO := ""
                ZR1->ZR1_NOME   := ""
                ZR1->ZR1_VLFRET := 0
                ZR1->(MsUnlock())

                ZR3->(dbSetOrder(2))
                ZR3->(dbSeek(xFilial("ZR3")+ZR1->ZR1_ROMANE))
                Do While ZR3->(!Eof()) .And. ZR3->(ZR3_FILIAL+ZR3_ROMANE) == xFilial("ZR3")+ZR1->ZR1_ROMANE
                    Reclock("ZR3",.F.)
                    ZR3->ZR3_STATUS := "1"
                    ZR3->(MsUnlock())
                    ZR3->(dbSkip())
                EndDo

                //->> Gravação do Log
                GravaLog(nOpc)

            End Transaction
        EndIf

    ElseIf nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5
        aCoords := {0,0,aSize[6] - aSize[2] - aSize[8] - 5,aSize[5]}
        lEdita := nOpc==3 .Or. nOpc==4

        If nOpc == 3 
            RegToMemory( cAlias, .T., .F. )

            cRomaneio := GetSXENum("ZR1","ZR1_ROMANE")
            ZR1->(dbSetOrder(1))
            While ZR1->(dbSeek(xFilial("ZR1")+cRomaneio))
                ConfirmSX8()
                cRomaneio := GetSXENum("ZR1","ZR1_ROMANE")
            EndDo

            M->ZR1_FILIAL := xFilial("ZR1")
            M->ZR1_ROMANE := cRomaneio
            M->ZR1_EMISSA := Date()
            M->ZR1_HORA   := Time()
            M->ZR1_PERDE  := Stod("")
            M->ZR1_PERATE := Stod("")
            M->ZR1_USRCRI := Upper(UsrRetName(RetCodUsr()))
            M->ZR1_STATUS := "1"            
        Else
            RegToMemory( cAlias, .F., .F. )
        EndIf

        oWizard := APWizard():New(  "Romaneios de Coleta",                 												 ;   // chTitle  - Titulo do cabeå ?lho
                                    "Documentos da Carga", 		                				         			     ;   // chMsg    - Mensagem do cabeå ?lho
                                    "Manutenção de Romaneios", 											 			     ;   // cTitle   - Tå ?ulo do painel de apresentaí”Œo
                                    "",                													 			     ;   // cText    - Texto do painel de apresentaí”Œo
                                    {|| lOk := If(!Empty(cMensagem),MsgYesNo(cMensagem) .And. TudoOk(nOpc),.T.),lOk},    ;   // bNext    - Bloco de cå ?igo a ser executado para validar o botå ? "Avanå ?r"
                                    {|| lOk := If(!Empty(cMensagem),MsgYesNo(cMensagem) .And. TudoOk(nOpc),.T.),lOk},    ;   // bFinish  - Bloco de cå ?igo a ser executado para validar o botå ? "Finalizar"
                                    .T.,             												     			     ;   // lPanel   - Se .T. serå ?criado um painel, se .F. serå ?criado um scrollbox
                                    cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabeå ?lho, essa tem que fazer parte do repositå ?io 
                                    {|| },                												 			     ;   // bExecute - Bloco de cå ?igo contendo a aí”Œo a ser executada no clique dos botå ?s "Avanå ?r" e "Voltar"
                                    .F.,                  												 			     ;   // lNoFirst - Se .T. nå ? exibe o painel de apresentaí”Œo
                                    aCoords                     										 				 )   // aCoord   - Array contendo as coordenadas da tela

        //************************************************************>> PAINEL DE ABAS <<*********************************************************************************************************************
        oFolder := TFolder():New(0,0,{ "Carga","Histórico de Operações"},{},oWizard:GetPanel(1),,,, .T., .F.,oWizard:GetPanel(1):NCLIENTWIDTH/2,oWizard:GetPanel(1):NCLIENTHEIGHT/2,,.T.)
        If nOpc == 3 
            oFolder:HidePage(2)
        Else
            aCposEnch := {}            
            aAdd(aCposEnch,"ZR4_SEQUEN")            
            aAdd(aCposEnch,"ZR4_EMISSA")
            aAdd(aCposEnch,"ZR4_HORA")
            aAdd(aCposEnch,"ZR4_USER")
            aAdd(aCposEnch,"ZR4_OPERAC")
            aAdd(aCposEnch,"ZR4_STATUS")
            aAdd(aCposEnch,"ZR4_PERDE")
            aAdd(aCposEnch,"ZR4_PERATE")
            aAdd(aCposEnch,"ZR4_QTDOCS")
            aAdd(aCposEnch,"ZR4_VLDOCS")
            aAdd(aCposEnch,"ZR4_COTAC")
            aAdd(aCposEnch,"ZR4_VLFRET")
            aAdd(aCposEnch,"ZR4_MOTOR")
            aAdd(aCposEnch,"ZR4_LJMOTO")
            aAdd(aCposEnch,"ZR4_NOME")            
            
            aHeader := {}
            For nX:=1 to Len(aCposEnch)        
                aStruct := FWSX3Util():GetFieldStruct(aCposEnch[nX])
                //->> Montagem do aHeader
                nTamanho := aStruct[03]
                                
                Aadd(aHeader,{	Alltrim(ZR4->(RetTitle(aCposEnch[nX])))  	                    ,; // 01
                                Alltrim(aCposEnch[nX])				                            ,; // 02
                                PesqPict("ZR4",aCposEnch[nX])    	                            ,; // 03
                                nTamanho	    		    	                                ,; // 04
                                aStruct[04]		    		                                    ,; // 05
                                Posicione("SX3",2,aCposEnch[nX],"X3_VALID")                     ,; // 06
                                ""	            				                                ,; // 07
                                aStruct[02]		    			                                ,; // 08
                                ""	            				                                ,; // 09
                                Posicione("SX3",2,aCposEnch[nX],"X3_CONTEXT")                   ,; // 10
                                Posicione("SX3",2,aCposEnch[nX],"X3_CBOX")                      ,; // 11
                                Nil			 		    		                                ,; // 12
                                Nil			 			    	                                ,; // 13
                                "V"                                                              ; // 14
                                })
            Next nX
            aCols := {}
            ZR4->(dbSetOrder(1))
            ZR4->(dbSeek(xFilial("ZR4")+ZR1->ZR1_ROMANE))
            Do While ZR4->(!Eof()) .And. ZR4->(ZR4_FILIAL+ZR4_ROMANE) == xFilial("ZR4")+ZR1->ZR1_ROMANE
                aColsTmp := {}
                For nX:=1 to Len(aHeader)
                    xConteudo := ZR4->&(Alltrim(aHeader[nX,02]))
                    If ValType(xConteudo)=="C"
                        xConteudo := Alltrim(xConteudo)
                    EndIf
                    aAdd(aColsTmp,xConteudo)
                Next nX
                aAdd(aColsTmp,.F.)
                aAdd(aCols,aColsTmp)
                ZR4->(dbSkip())
            EndDo

            oHistorico := MSNewGetDados():New(00,00,((oFolder:ADIALOGS[2]:NHEIGHT)/2),((oFolder:ADIALOGS[2]:NWIDTH)/2),2,.T.,.T.,,,,,,,,oFolder:ADIALOGS[2],aHeader,aCols)
            oHistorico:bChange := {|| POSITHIS := oHistorico:nAt,oHistorico:Refresh(),AtuSelecao(nOpc)}
            oHistorico:oBrowse:SetBlkBackColor({|| GETDCLR(oHistorico:nAt,POSITHIS,nCorItHis)})	
            oHistorico:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
        EndIf        

        //************************************************************>> PAINEL DE ENCHOICE <<*********************************************************************************************************************
        oPan1 := TPanel():New(0,0,'',oFolder:ADIALOGS[1], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(210,210,210),((oFolder:ADIALOGS[1]:NCLIENTWIDTH)/2),(35),.T.,.F. )
        oPan1:Align := CONTROL_ALIGN_TOP

        aCposEnch := {}
        aAdd(aCposEnch,"NOUSER")
        aAdd(aCposEnch,"ZR1_FAPROV")
        aAdd(aCposEnch,"ZR1_ROMANE")
        aAdd(aCposEnch,"ZR1_EMISSA")
        aAdd(aCposEnch,"ZR1_HORA")        
        oEnch1				:= MsMGet():New( "ZR1", ZR1->( RecNo() ),2,,,,aCposEnch,{00,00,((oPan1:NCLIENTHEIGHT)/2),((oPan1:NCLIENTWIDTH)/2)},aCposEnch,nModelo,,,,oPan1,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)
        oEnch1:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

        //************************************************************>> PAINEL DE BOTOES <<*********************************************************************************************************************
        If nOpc==3 .Or. nOpc==4
            oPanButt := TPanel():New(0,0,'',oFolder:ADIALOGS[1], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(210,210,210),((oFolder:ADIALOGS[1]:NCLIENTWIDTH)/2),(15),.T.,.F. )
            oPanButt:Align := CONTROL_ALIGN_TOP

            aAdd(aButtBar,{"adicionar_001"	,{|| AdicDoctos() },"Adicionar Documentos"})
            
            MyEnchBar(oPanButt,,,aButtBar,/*aButtonTxt*/,.F.,,,1,.T.)
        EndIf

        //************************************************************>> PAINEL DE GRID DE DOCTOS <<*********************************************************************************************************************
        oPan2 := TPanel():New(0,0,'',oFolder:ADIALOGS[1], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(255,255,255),((oFolder:ADIALOGS[1]:NCLIENTWIDTH)/2),((oFolder:ADIALOGS[1]:NCLIENTHEIGHT)/2)-100-If(nOpc==3 .Or. nOpc==4,15,0),.F.,.T. )
        oPan2:Align := CONTROL_ALIGN_ALLCLIENT
        
        aCposEnch := {}
        aAdd(aCposEnch,"ZR2_SITFRE")
        aAdd(aCposEnch,"ZR2_TPDOC")
        aAdd(aCposEnch,"ZR2_FILDOC")
        aAdd(aCposEnch,"ZR2_DOCTO")
        aAdd(aCposEnch,"ZR2_SERIE")
        aAdd(aCposEnch,"ZR2_CLIFOR")
        aAdd(aCposEnch,"ZR2_LOJA")
        aAdd(aCposEnch,"ZR2_NOME")
        aAdd(aCposEnch,"ZR2_DTDOC")
        aAdd(aCposEnch,"ZR2_VLDOC")
        aAdd(aCposEnch,"ZR2_VLFRET")
        aAdd(aCposEnch,"ZR2_PMAXFR")
        aAdd(aCposEnch,"ZR2_PCALFR")
        aAdd(aCposEnch,"ZR2_SITUAC")

        aHeader := {}
        For nX:=1 to Len(aCposEnch)        
            aStruct := FWSX3Util():GetFieldStruct(aCposEnch[nX])
            //->> Montagem do aHeader de Vouchers
            Aadd(aHeader,{	Alltrim(ZR2->(RetTitle(aCposEnch[nX])))  	                    ,; // 01
                            Alltrim(aCposEnch[nX])				                            ,; // 02
                            PesqPict("ZR2",aCposEnch[nX])    	                            ,; // 03
                            aStruct[03]	    		    	                                ,; // 04
                            aStruct[04]		    		                                    ,; // 05
                            Posicione("SX3",2,aCposEnch[nX],"X3_VALID")                     ,; // 06
                            ""	            				                                ,; // 07
                            aStruct[02]		    			                                ,; // 08
                            ""	            				                                ,; // 09
                            Posicione("SX3",2,aCposEnch[nX],"X3_CONTEXT")                   ,; // 10
                            Posicione("SX3",2,aCposEnch[nX],"X3_CBOX")                      ,; // 11
                            Nil			 		    		                                ,; // 12
                            Nil			 			    	                                ,; // 13
                            If(lEdita,Posicione("SX3",2,aCposEnch[nX],"X3_VISUAL"),"V")      ; // 14
                            })
        Next nX
        
        aCols := GetAcols(aHeader,nOpc)

        oDoctos := MSNewGetDados():New(00,00,((oPan2:NHEIGHT)/2),((oPan2:NWIDTH)/2),If(nOpc==3 .Or. nOpc==4,GD_INSERT+GD_DELETE+GD_UPDATE,2),.T.,.T.,,,,,,,,oPan2,aHeader,aCols)
        oDoctos:bChange := {|| POSITEM := oDoctos:nAt,oDoctos:Refresh(),AtuSelecao(nOpc)}
        oDoctos:oBrowse:SetBlkBackColor({|| GETDCLR(oDoctos:nAt,POSITEM,nCorItem)})	
        oDoctos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
        
        //************************************************************>> PAINEL DE DETALHES <<*********************************************************************************************************************
        oPan3 := TPanel():New(0,0,'',oFolder:ADIALOGS[1], oWizard:GetPanel(1):oFont, .T., .T.,,Rgb(210,210,210),((oFolder:ADIALOGS[1]:NCLIENTWIDTH)/2),(65),.T.,.F. )
        oPan3:Align := CONTROL_ALIGN_BOTTOM

        aCposEnch := {}
        aAdd(aCposEnch,"NOUSER")
        aAdd(aCposEnch,"ZR1_QTDOCS")
        aAdd(aCposEnch,"ZR1_VLDOCS")
        aAdd(aCposEnch,"ZR1_PCFRET")
        aAdd(aCposEnch,"ZR1_STATUS")
        aAdd(aCposEnch,"ZR1_VLFRET")
        aAdd(aCposEnch,"ZR1_MOTOR")
        aAdd(aCposEnch,"ZR1_LJMOTO")
        aAdd(aCposEnch,"ZR1_NOME")       
        aAdd(aCposEnch,"ZR1_PERDE")
        aAdd(aCposEnch,"ZR1_PERATE")     
        aAdd(aCposEnch,"ZR1_OBSERV")            
        
        If M->ZR1_STATUS == "3"
            aAdd(aCposEnch,"ZR1_FATURA")
            aAdd(aCposEnch,"ZR1_SERIE")
        EndIf

        oEnch2				:= MsMGet():New( "ZR1", ZR1->( RecNo() ),nOpc,,,,aCposEnch,{00,00,((oPan3:NCLIENTHEIGHT)/2),((oPan3:NCLIENTWIDTH)/2)},aCposEnch,nModelo,,,,oPan3,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)
        oEnch2:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

        oWizard:OFINISH:CCAPTION := cCaption

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o diå ?ogo serå ?centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de cå ?igo a ser executado no encerramento do diå ?ogo
                            {|| .T. },  ;   // bInit    - Bloco de cå ?igo a ser executado na inicializaí”Œo do diå ?ogo
                            {|| .T. }   )   // bWhen    - Bloco de cå ?igo para habilitar a execuí”Œo do diå ?ogo
        
        If lOk
            Begin Transaction
                Do Case
                    Case nOpc == 3 .Or. nOpc == 4
                        If nOpc == 3
                            RecLock("ZR1",.T.)
                        Else
                            RecLock("ZR1",.F.)
                        EndIf    
                        For nX := 1 To ZR1->(FCount())
                            ZR1->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
                        Next nX
                        ZR1->(MsUnLock())

                        ZR2->(dbSetOrder(1))        
                        ZR2->(dbSeek(xFilial("ZR2")+M->ZR1_ROMANE))
                        Do While ZR2->(!Eof()) .And. ZR2->(ZR2_FILIAL+ZR2_ROMANE) == xFilial("ZR2")+M->ZR1_ROMANE
                            Reclock("ZR2",.F.)
                            Delete
                            ZR2->(MsUnlock())
                            ZR2->(dbSkip())
                        EndDo

                        For nX:=1 to Len(oDoctos:aCols)
                            If !oDoctos:aCols[nX][Len(aHeader)+1]
                                RecLock("ZR2",.T.)
                                ZR2->ZR2_FILIAL := xFilial("ZR2")
                                ZR2->ZR2_ROMANE := M->ZR1_ROMANE
                                For nY:=1 to Len(oDoctos:aHeader)
                                    ZR2->&(Alltrim(Upper(oDoctos:aHeader[nY,02]))) := oDoctos:aCols[nX,nY]                   
                                Next nY
                                ZR2->(MsUnlock())

                                If ZR2->ZR2_SITUAC == "R"
                                    aAdd(aReentrega,{ZR2->ZR2_TPDOC,    ; // 01 - Tipod e Docto
                                                     ZR2->ZR2_FILDOC,   ; // 02 - Filial
                                                     ZR2->ZR2_DOCTO,    ; // 03 - Documento
                                                     ZR2->ZR2_SERIE,    ; // 04 - Serie
                                                     ZR2->ZR2_CLIFOR,   ; // 05 - Cliente/Fornecedor
                                                     ZR2->ZR2_LOJA}     ) // 06 - Loja
                                EndIf
                            EndIf
                        Next nX

                        For nX:=1 to Len(aReentrega)
                            ZR2->(dbSetOrder(2))
                            ZR2->(dbSeek(xFilial("ZR2")+aReentrega[nX,01];
                                                       +aReentrega[nX,02]; 
                                                       +aReentrega[nX,03]; 
                                                       +aReentrega[nX,04]; 
                                                       +aReentrega[nX,05]; 
                                                       +aReentrega[nX,06]))
                            
                            Do While ZR2->(!Eof()) .And. ZR2->(ZR2_FILIAL+ZR2_TPDOC+ZR2_FILDOC+ZR2_DOCTO+ZR2_SERIE+ZR2_CLIFOR+ZR2_LOJA) == xFilial("ZR2")+aReentrega[nX,01]+aReentrega[nX,02]+aReentrega[nX,03]+aReentrega[nX,04]+aReentrega[nX,05]+aReentrega[nX,06]
                                If ZR2->ZR2_SITUAC == "N" .And. ZR2->ZR2_ROMANE <> ZR1->ZR1_ROMANE
                                    RecLock("ZR2",.F.)
                                    ZR2->ZR2_SITUAC := "E"
                                    ZR2->(MsUnlock())
                                EndIf
                                ZR2->(dbSkip())
                            EndDo
                        Next nX

                        //->> Gravação do Log
                        GravaLog(nOpc)

                    Case nOpc == 5
                        //->> Gravação do Log
                        GravaLog(nOpc)
                        
                        RecLock("ZR1",.F.)
                        Delete
                        ZR1->(MsUnLock())                    

                        ZR2->(dbSetOrder(1))        
                        ZR2->(dbSeek(xFilial("ZR2")+M->ZR1_ROMANE))
                        Do While ZR2->(!Eof()) .And. ZR2->(ZR2_FILIAL+ZR2_ROMANE) == xFilial("ZR2")+M->ZR1_ROMANE
                            Reclock("ZR2",.F.)
                            Delete
                            ZR2->(MsUnlock())
                            ZR2->(dbSkip())
                        EndDo

                EndCase
            End Transaction            
        EndIf
    EndIf
EndIf

Return

/*/{protheus.doc} PodeUsarCpo
*******************************************************************************************
Retorna se campo pode ser utilizado
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function PodeUsarCpo(cCpo)
Local lRet      := .F.
Local aArea     := GetArea()
Local nOrdSX3   := 0

dbSelectArea("SX3")
nOrdSX3 := IndexOrd()
dbSetOrder(2)
If dbSeek(cCpo)
    If X3Uso(Alltrim(Posicione("SX3",2,cCpo,"X3_USADO")))
        lRet := .T.
    EndIf
EndIf
If nOrdSX3>0
    dbSetOrder(nOrdSX3)
EndIf
RestArea(aArea)

Return lRet

/*/{protheus.doc} GetAcols
*******************************************************************************************
Retorna o aCols montado para exibir
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetAcols(aHeader,nOpc)
Local aColsTmp   := {}
Local aCols      := {}
Local nX         := 1
Local cQuery     := ""
Local cAlias     := ""
Local aArea      := GetArea()
Local cSituaca   := LoadBitmap( GetResources(), cImgF_VAS )

If nOpc <> 3
    cAlias := GetNextAlias()
    cQuery := "SELECT ZR2.R_E_C_N_O_ AS RECZR2"             +CRLF
    cQuery += " FROM "+RetSqlName("ZR2")+" ZR2 (NOLOCK)"    +CRLF
    cQuery += " WHERE ZR2.ZR2_FILIAL = '"+xFilial("ZR2")+"'"+CRLF
    cQuery += "   AND ZR2.ZR2_ROMANE = '"+M->ZR1_ROMANE+"'" +CRLF
    cQuery += "   AND ZR2.D_E_L_E_T_ = ' '"                 +CRLF
    cQuery += " ORDER BY ZR2.R_E_C_N_O_"                    +CRLF

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    Do While (cAlias)->(!Eof())
        ZR2->(dbGoto((cAlias)->RECZR2))
        aColsTmp := {}
        For nX:=1 to Len(aHeader)
            If Upper(Alltrim(aHeader[nX,02]))=="ZR2_SITFRE"
                If ZR2->ZR2_PCALFR > ZR2->ZR2_PMAXFR
                    cSituaca := LoadBitmap( GetResources(), cImgF_NOK )
                Else
                    cSituaca := LoadBitmap( GetResources(), cImgF_OK )
                EndIf
                aAdd(aColsTmp,cSituaca)
            Else
                aAdd(aColsTmp,ZR2->&(Alltrim(aHeader[nX,02])))
            EndIf
        Next nX
        aAdd(aColsTmp,.F.)
        aAdd(aCols,aColsTmp)
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
EndIf

RestArea(aArea)

Return aCols

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 01/02/2023
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

/*/{protheus.doc} AtuSelecao
*******************************************************************************************
Funcao para atualização dos dados em tela com a inclusão de documentos
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuSelecao(nOpc)
AtuDados(nOpc)
Return

/*/{protheus.doc} BoDocRoman
*******************************************************************************************
Consulta Padrão especifica e dinamica para selecionar docs de entrada e de saida
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoDocRoman(cTpDoc)
Local lRet       := .F.
Local cAlias     := ""
Local nPos       := 0
Local nX         := 0
Local lOk        := .T.
Local cChave     := ""
Local cChvGrid   := "" 
Local nPcFrete   := 0
Local nPZR2TPDOC := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_TPDOC"})
Local nZR2FILDOC := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_FILDOC"})
Local nZR2DOCTO  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DOCTO"})
Local nZR2SERIE  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_SERIE"})
Local nZR2CLIFOR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_CLIFOR"})
Local nZR2LOJA   := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_LOJA"})
Local nZR2NOME   := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_NOME"})
Local nZR2DTDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DTDOC"})
Local nZR2VLDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_VLDOC"})
Local nZR2PMAXFR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_PMAXFR"})
Local nZR2SITUAC := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_SITUAC"})

Local lContinua  := .T.
Local lReentrega := .F.

Default cTpDoc := ""

If Type("oDoctos:aCols")<>"U" .And. Valtype(oDoctos:aCols)=="A"
    nPos := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_TPDOC"})
    If nPos > 0
        If Empty(cTpDoc)
            cTpDoc := oDoctos:aCols[oDoctos:nAt][nPos]
        EndIf
        
        If !Empty(cTpDoc)
            If cTpDoc=="E"
                cAlias := "SF1ROM"                
            Else
                cAlias := "SF2ROM"                
            EndIf
            lRet := CONPAD1(,,,cAlias,,,.F.)
            If lRet
                If cTpDoc=="E"
                    cChave := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
                Else
                    cChave := SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
                EndIf

                lContinua := .T.
                lReentrega := .F.
                ZR2->(dbSetOrder(3))
                If !ZR2->(dbSeek(xFilial("ZR2")+cTpDoc+cChave+"N"))
                    lContinua := .T.
                    lReentrega := .F.
                Else
                    If Posicione("ZR1",1,xFilial("ZR1")+ZR2->ZR2_ROMANE,"ZR1_STATUS")=="1"
                        lContinua := .F.
                        MsgAlert("Documento: "+cChave+CRLF+"Já utilizado no Romaneio: "+ZR2->ZR2_ROMANE+"."+CRLF+"Não é possivel realizar a reentrega desta nota pois este o Romaneio encontra-se em estágio de elaboração."+CRLF+"Favor utilizar esta Nota no Romaneio Identificado.")
                    Else                    
                        lContinua := MsgYesNo("Documento: "+cChave+CRLF+"Já utilizado no Romaneio: "+ZR2->ZR2_ROMANE+"."+CRLF+"Deseja realizar a re-Entrega dessa Nota ?")
                        lReentrega := .T.
                    EndIf
                EndIf

                If lContinua
                    lOk := .T.
                    For nX:=1 to Len(oDoctos:aCols)
                        If nX <> oDoctos:nAt
                            cChvGrid := oDoctos:aCols[nX][nPZR2TPDOC]
                            cChvGrid += oDoctos:aCols[nX][nZR2FILDOC]
                            cChvGrid += oDoctos:aCols[nX][nZR2DOCTO]
                            cChvGrid += oDoctos:aCols[nX][nZR2SERIE]
                            cChvGrid += oDoctos:aCols[nX][nZR2CLIFOR]
                            cChvGrid += oDoctos:aCols[nX][nZR2LOJA]

                            If cChvGrid == cTpDoc+cChave
                                lOk := .F.
                                Exit
                            EndIf
                        EndIf
                    Next nX

                    If lOk
                        If lReentrega
                            oDoctos:aCols[oDoctos:nAt][nZR2SITUAC] := "R"
                        EndIf
                        
                        nPcCalcu := 0
                        nPcFrete := 0
                        If cAlias == "SF1ROM"
                            SA2->(dbSetOrder(1))
                            If SA2->(dbSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
                                oDoctos:aCols[oDoctos:nAt][nZR2NOME] := SA2->A2_NOME
                            Else
                                oDoctos:aCols[oDoctos:nAt][nZR2NOME] := ""
                            EndIf
                            oDoctos:aCols[oDoctos:nAt][nZR2DTDOC] := SF1->F1_EMISSAO
                            oDoctos:aCols[oDoctos:nAt][nZR2VLDOC] := SF1->F1_VALBRUT

                            nPcFrete := GetPcFrete("F",SF1->F1_FORNECE,SF1->F1_LOJA)
                        Else
                            SA1->(dbSetOrder(1))
                            If SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
                                oDoctos:aCols[oDoctos:nAt][nZR2NOME] := SA1->A1_NOME
                            Else
                                oDoctos:aCols[oDoctos:nAt][nZR2NOME] := ""
                            EndIf
                            oDoctos:aCols[oDoctos:nAt][nZR2DTDOC] := SF2->F2_EMISSAO
                            oDoctos:aCols[oDoctos:nAt][nZR2VLDOC] := SF2->F2_VALBRUT

                            nPcFrete := GetPcFrete("C",SF2->F2_CLIENTE,SF2->F2_LOJA)
                        EndIf
                        oDoctos:aCols[oDoctos:nAt][nZR2PMAXFR] := nPcFrete
                        AtuDados()
                    Else
                        MsgAlert("Documento: "+cChave+CRLF+"Já utilizado neste Romaneio.")
                        lRet := .F.
                    EndIf                
                Else
                    lRet := .F.
                EndIf
            EndIf
        Else
            MsgAlert("Favor Informar o Tipo de Documento.")
            lRet := .F.
        EndIf            
    EndIf
EndIf

Return lRet

/*/{protheus.doc} AtuDados
*******************************************************************************************
Atualiza os Dados
 
@author: Marcelo Celi Marques
@since: 02/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuDados(nOpc)
Local nZR2DOCTO  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DOCTO"})
Local nZR2VLDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_VLDOC"})
Local nZR2DTDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DTDOC"})
Local nR2VLFRET  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_VLFRET"})
Local nZR2SITFRE := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_SITFRE"})
Local lBloqueado := .F.
Local nX         := 1
Local aPeriodos  := {}

Default nOpc     := 0

M->ZR1_QTDOCS := 0
M->ZR1_VLDOCS := 0
M->ZR1_VLFRET := 0
M->ZR1_FAPROV := Criavar("ZR1_FAPROV",.T.)

For nX:=1 to Len(oDoctos:aCols)
    If !oDoctos:aCols[nX][Len(oDoctos:aHeader)+1]
        If !Empty(oDoctos:aCols[nX][nZR2DOCTO]) .Or. (Type("M->ZR2_DOCTO")<>"U" .And. !Empty(M->ZR2_DOCTO))
            M->ZR1_QTDOCS++
            M->ZR1_VLDOCS += oDoctos:aCols[nX][nZR2VLDOC]
            M->ZR1_VLFRET += oDoctos:aCols[nX][nR2VLFRET]
            M->ZR1_PCFRET := Round((100 * M->ZR1_VLFRET) / M->ZR1_VLDOCS,Tamsx3("ZR1_PCFRET")[02])

            aAdd(aPeriodos,oDoctos:aCols[nX][nZR2DTDOC])
            If M->ZR1_STATUS == "1" .And. nOpc <> 2
                If oDoctos:aCols[nX,nZR2SITFRE]:cName == cImgF_NOK
                    lBloqueado := .T.
                EndIf
            EndIf
        EndIf
    EndIf
Next nX

If lBloqueado
    M->ZR1_FAPROV := "B"
EndIf

aPeriodos := Asort(aPeriodos,,,{|x,y| x < y })
If Len(aPeriodos)>0
    M->ZR1_PERDE  := aPeriodos[1]
    M->ZR1_PERATE := aPeriodos[Len(aPeriodos)]
EndIf

oEnch1:EnchRefreshAll()
oEnch2:EnchRefreshAll()

Return

/*/{protheus.doc} BoVldTpDoc
*******************************************************************************************
Valida o Tipo de Documento
 
@author: Marcelo Celi Marques
@since: 02/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoVldTpDoc()
Local nX := 1

For nX:=1 to Len(oDoctos:aHeader)
    If Upper(Alltrim(oDoctos:aHeader[nX,02]))=="ZR2_SITFRE"
        oDoctos:aCols[oDoctos:nAt][nX] := LoadBitmap( GetResources(), cImgF_VAS )
    ElseIf Upper(Alltrim(oDoctos:aHeader[nX,02]))<>"ZR2_TPDOC"
        oDoctos:aCols[oDoctos:nAt][nX] := Criavar(Alltrim(oDoctos:aHeader[nX][02]),.T.)
    EndIf
Next nX
AtuDados()

Return .T.

/*/{protheus.doc} BoVldCotac
*******************************************************************************************
Valida a entrada da cotação no romaneio.
 
@author: Marcelo Celi Marques
@since: 03/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoVldCotac()
Local lRet      := .F.
Local cCotacao  := &(ReadVar())

If Empty(cCotacao)
    lRet := .F.
    MsgAlert("Favor informar a Cotação de Frete.")
Else
    ZR3->(dbSetOrder(1))
    If ZR3->(dbSeek(xFilial("ZR3")+cCotacao+M->ZR1_ROMANE))
        If ZR3->ZR3_STATUS == "2"
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Cotação de Frete não Liberado.")
        EndIf
    Else
        lRet := .F.
        MsgAlert("Cotação de Frete não Localizado.")
    EndIf
EndIf

If lRet
    SA4->(dbSetOrder(1))
    If SA4->(dbSeek(xFilial("SA4")+ZR3->ZR3_TRANSP))
        If !Empty(SA4->A4_XFORNEC)
            SA2->(dbSetOrder(1))
            If SA2->(dbSeek(xFilial("SA2")+SA4->(A4_XFORNEC+A4_XLOJFOR)))
                If SA2->A2_MSBLQL == "1"
                    MsgAlert("Fornecedor amarrado a Transportadora Bloqueado...")
                    lRet := .F.
                Else
                    lRet := .T.
                EndIf
            Else
                MsgAlert("Fornecedor amarrado a Transportadora não Localizado...")
                lRet := .F.
            EndIf
        Else
            MsgAlert("Transportadora não Possui Fornecedor Vinculado...")
            lRet := .F.
        EndIf
    Else
        lRet := .F.
        MsgAlert("Transportadora não Localizada.")
    EndIf
EndIf

If lRet
    M->ZR1_MOTOR   := SA2->A2_COD
    M->ZR1_LJMOTO  := SA2->A2_LOJA
    M->ZR1_NOME    := SA2->A2_NOME
    M->ZR1_VLFRET  := ZR3->ZR3_VLFRET
Else
    M->ZR1_MOTOR   := ""
    M->ZR1_LJMOTO  := ""
    M->ZR1_NOME    := ""
    M->ZR1_VLFRET  := 0
EndIf

oEnch1:EnchRefreshAll()

Return lRet

/*/{protheus.doc} BoVldCond
*******************************************************************************************
Valida a condição de pagamento
 
@author: Marcelo Celi Marques
@since: 03/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoVldCond()
Local lRet      := .F.
Local cCondicao := &(ReadVar())

If Empty(cCondicao)
    lRet := .F.
    MsgAlert("Favor informar a Condição de Pagamento.")
Else
    SE4->(dbSetOrder(1))
    If SE4->(dbSeek(xFilial("SE4")+cCondicao))
        If SE4->E4_MSBLQL == "1"
            lRet := .F.
            MsgAlert("Condição de Pagamento Bloqueada para uso.")
        Else
            lRet := .T.
        EndIf
    Else
        lRet := .F.
        MsgAlert("Condição de Pagamento não Localizada.")
    EndIf
EndIf

Return lRet

/*/{protheus.doc} BoVldNFEnt
*******************************************************************************************
Valida a digitação da pre-nota
 
@author: Marcelo Celi Marques
@since: 03/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoVldNFEnt(nOpVld)
Local lRet   := .F.

SF1->(dbSetOrder(1))
If SF1->(dbSeek(xFilial("SF1")+M->(ZR1_FATURA+ZR1_SERIE+ZR1_MOTOR+ZR1_LJMOTO)))
    lRet := .F.
    MsgAlert("Documento de Entrada já Existe.")
Else
    lRet := .T.
EndIf

Return lRet

/*/{protheus.doc} GeraPrenota
*******************************************************************************************
Geração da Pre-nota de Entrada
 
@author: Marcelo Celi Marques
@since: 03/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GeraPrenota()
Local lRet      := .F.
Local cProduto  := GetNewPar("BO_PRDROMA","9990.99.0003")
Local aCabec    := {}
Local aItem     := {}
Local aItens    := {}

Private lMsErroAuto := .F.

SA2->(dbSetOrder(1))
SE4->(dbSetOrder(1))

SA2->(dbSeek(xFilial("SA2")+M->(ZR1_MOTOR+ZR1_LJMOTO)))
SE4->(dbSeek(xFilial("SE4")+M->ZR1_CONDIC))
    
aCabec	:= {{"F1_FILIAL"	,xFilial("SF1")	    ,Nil, POSICIONE("SX3",2,"F1_FILIAL" ,"X3_ORDEM")},;		// Filial
            {"F1_TIPO"		,"N"	            ,Nil, POSICIONE("SX3",2,"F1_TIPO"   ,"X3_ORDEM")},;		// Tipo da Nota Fiscal de Entrada
            {"F1_FORMUL" 	,"N"    		    ,Nil, POSICIONE("SX3",2,"F1_FORMUL" ,"X3_ORDEM")},;		// Formulario
            {"F1_DOC"		,M->ZR1_FATURA	    ,Nil, POSICIONE("SX3",2,"F1_DOC"    ,"X3_ORDEM")},;		// Numero da Nota Fiscal de Entrada
            {"F1_SERIE"		,M->ZR1_SERIE	    ,Nil, POSICIONE("SX3",2,"F1_SERIE"  ,"X3_ORDEM")},;		// Serie da Nota Fiscal de Entrada
            {"F1_FORNECE"	,SA2->A2_COD	    ,Nil, POSICIONE("SX3",2,"F1_FORNECE","X3_ORDEM")},;		// Codigo do Fornecedor
            {"F1_LOJA"		,SA2->A2_LOJA	    ,Nil, POSICIONE("SX3",2,"F1_LOJA"   ,"X3_ORDEM")},;		// Loja do Fornecedor
            {"F1_EMISSAO"	,dDatabase          ,Nil, POSICIONE("SX3",2,"F1_EMISSAO","X3_ORDEM")},;		// Emissao da Nota Fiscal de Entrada
            {"F1_EST"		,SA2->A2_EST	    ,Nil, POSICIONE("SX3",2,"F1_EST"    ,"X3_ORDEM")},;		// Estado do Fornecedor
            {"F1_DTDIGIT"	,dDatabase          ,Nil, POSICIONE("SX3",2,"F1_DTDIGIT","X3_ORDEM")},;		// Data de Digitacao da Nota Fiscal de Entrada
            {"F1_ESPECIE"	,"CTR"			    ,Nil, POSICIONE("SX3",2,"F1_ESPECIE","X3_ORDEM")},;		// Especie da Nota Fiscal de Entrada
            {"F1_COND"   	,SF2->F2_COND	    ,Nil, POSICIONE("SX3",2,"F1_COND"   ,"X3_ORDEM")} }		// Condicao do Fornecedor            

aCabec := ASort(aCabec,,,{|x,y|x[4] < y[4]})

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+PadR(cProduto,Tamsx3("B1_COD")[01])))
    aItem := {}

    aAdd(aItem,{"D1_FILIAL"	    ,xFilial("SD1")			            ,Nil, POSICIONE("SX3",2,"D1_FILIAL"     ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_ITEM"		,StrZero(1,Tamsx3("D1_ITEM")[01])	,Nil, POSICIONE("SX3",2,"D1_ITEM"       ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_COD"		,SB1->B1_COD	                  	,Nil, POSICIONE("SX3",2,"D1_COD"        ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_UM"		    ,SB1->B1_UM	                      	,Nil, POSICIONE("SX3",2,"D1_UM"         ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_LOCAL"	    ,SB1->B1_LOCPAD                  	,Nil, POSICIONE("SX3",2,"D1_LOCAL"      ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_QUANT"		,1  		                        ,Nil, POSICIONE("SX3",2,"D1_QUANT"      ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_VUNIT"		,M->ZR1_VLFRET	                    ,Nil, POSICIONE("SX3",2,"D1_VUNIT"      ,"X3_ORDEM")} )
    aAdd(aItem,{"D1_TOTAL"		,M->ZR1_VLFRET          	        ,Nil, POSICIONE("SX3",2,"D1_TOTAL"      ,"X3_ORDEM")} )

    aItem := ASort(aItem,,,{|x,y|x[4] < y[4]})

    aAdd(aItens,aItem)            
EndIf

If Len(aCabec)>0 .And. Len(aItens)>0
    MsgRun("Gerando Pre-Nota de Entrada...","Aguarde",{|| MsExecAuto( {|x,y,z| MATA140(x,y,z) }, aCabec, aItens, 3, .F.) })
    If lMsErroAuto
        If MsgYesNo("Ocorrem erros na Geração da Pre-Nota de Entrada."+CRLF+"Deseja Visualizar os Erros Encontrados ?")
            MostraErro()
        EndIf        
    Else
        lRet := .T.
    EndIf
EndIf

Return lRet

/*/{protheus.doc} TudoOk
*******************************************************************************************
Função de Validação se está tudo Ok com as opções para avançar com a gravaão ou exclusão.
 
@author: Marcelo Celi Marques
@since: 05/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoOk(nOpc)
Local lRet       := .F.
Local nX         := 1
Local nTotDocs   := 0
Local nZR2DOCTO  := 0

Do Case
    Case nOpc == 2
        // Visualização
        lRet := .T.

    Case nOpc == 3 .Or. nOpc == 4
        // Inclusão ou Alteração
        nZR2DOCTO   := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DOCTO"})
        lRet        := .T.
        nTotDocs    := 0

        AtuDados()

        For nX:=1 to Len(oDoctos:aCols)
            If !oDoctos:aCols[nX][Len(oDoctos:aHeader)+1]
                If Empty(oDoctos:aCols[nX][nZR2DOCTO])
                    MsgAlert("Existem Documentos sem identificação.")
                    lRet := .F.
                    Exit
                Else
                    nTotDocs++
                EndIf
            EndIf
        Next nX
        If lRet
            If nTotDocs<=0
                MsgAlert("Nenhum Documento foi informado.")
                lRet := .F.
            EndIf
        EndIf

        //->> Marcelo Celi - 17/02/2023
        If lRet .And. Empty(M->ZR1_MOTOR)
            lRet := .F.
            MsgAlert("O Motorista não foi informado.")
        EndIf
        
    Case nOpc == 5
        // Exclusão
        lRet := MsgYesNo("tem certeza que deseja excluir definitivamente o Romaneio?"+CRLF+"Atenção: Esta operação não poderá ser revertida.")
        
    Case nOpc == 6
        // Efetivação do Faturamento
        lRet := .T.

        If lRet .And. Empty(M->ZR1_CONDIC)
            lRet := .F.
            MsgAlert("A Condição de Pagamento da Cotação do Frete não foi informada.")
        EndIf

        If lRet .And. Empty(M->ZR1_FATURA)
            lRet := .F.
            MsgAlert("O Numero da Fatura não foi informado.")
        EndIf

        If lRet .And. Empty(M->ZR1_SERIE)
            lRet := .F.
            MsgAlert("A Série da Fatura não foi informada.")
        EndIf

        If lRet .And. Empty(M->ZR1_MOTOR)
            lRet := .F.
            MsgAlert("O Motorista não foi informado.")
        EndIf

    Case nOpc == 7
        // Estorno das operações anteriores e volta para Elaboração
        lRet := MsgYesNo("tem certeza que deseja estornar as operações já realizadas nesse Romaneio?"+CRLF+"O Romaneio será posto em estado inicial de Elaboração, todavia esta operação armazenará um log de estorno e será evidenciado em relatórios de auditoria."+CRLF+"Deseja Continuar ? ? ?")

EndCase

Return lRet

/*/{protheus.doc} GravaLog
*******************************************************************************************
Função de Gravação de Logs de Operação
 
@author: Marcelo Celi Marques
@since: 05/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GravaLog(nOpc)
Local cSequencia := ""
Local cObserv    := ""
Local cOperac    := ""

Do Case
    Case nOpc == 3 
        cObserv := "Inclusão do Romaneio"
        cOperac := "Inclusao"

    Case nOpc == 4
        cObserv := "Alteração do Romaneio"
        cOperac := "Alteracao"
        
    Case nOpc == 5
        cObserv := "Exclusão do Romaneio"
        cOperac := "Exclusao"
                
    Case nOpc == 6
        cObserv := "Efetivação do Faturamento"
        cOperac := "Efet. Faturamento"
        
    Case nOpc == 7
        cObserv := "Estorno das operações anteriores e volta para Elaboração"
        cOperac := "Estorn. Operacoes"
        
EndCase

ZR4->(dbSetOrder(1))
If ZR4->(dbSeek(xFilial("ZR4")+ZR1->ZR1_ROMANE))
    Do While ZR4->(!Eof()) .And. ZR4->(ZR4_FILIAL+ZR4_ROMANE) == xFilial("ZR4")+ZR1->ZR1_ROMANE
        cSequencia := ZR4->ZR4_SEQUEN
        ZR4->(dbSkip())
    EndDo
Else
    cSequencia := StrZero(0,Tamsx3("ZR4_SEQUEN")[01])
EndIf
cSequencia := Soma1(cSequencia)

RecLock("ZR4",.T.)
ZR4->ZR4_FILIAL := xFilial("ZR4")
ZR4->ZR4_ROMANE := ZR1->ZR1_ROMANE
ZR4->ZR4_SEQUEN := cSequencia
ZR4->ZR4_EMISSA := Date()
ZR4->ZR4_HORA   := Time()
ZR4->ZR4_PERDE  := ZR1->ZR1_PERDE
ZR4->ZR4_PERATE := ZR1->ZR1_PERATE
ZR4->ZR4_QTDOCS := ZR1->ZR1_QTDOCS
ZR4->ZR4_VLDOCS := ZR1->ZR1_VLDOCS
ZR4->ZR4_COTAC  := ZR1->ZR1_COTAC
ZR4->ZR4_VLFRET := ZR1->ZR1_VLFRET
ZR4->ZR4_CONDIC := ZR1->ZR1_CONDIC
ZR4->ZR4_FATURA := ZR1->ZR1_FATURA
ZR4->ZR4_SERIE  := ZR1->ZR1_SERIE
ZR4->ZR4_MOTOR  := ZR1->ZR1_MOTOR
ZR4->ZR4_LJMOTO := ZR1->ZR1_LJMOTO
ZR4->ZR4_NOME   := ZR1->ZR1_NOME
ZR4->ZR4_USER   := Upper(UsrRetName(RetCodUsr()))
ZR4->ZR4_STATUS := ZR1->ZR1_STATUS
ZR4->ZR4_OBSERV := cObserv
ZR4->ZR4_OPERAC := cOperac
ZR4->(MsUnlock())

Return

/*/{protheus.doc} BoCalcVlFr
*******************************************************************************************
Função de Gravação Calculo dos Valores de Frete
 
@author: Marcelo Celi Marques
@since: 09/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoCalcVlFr()
Local lRet       := .T.
Local nZR2VLDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_VLDOC"})
Local nZR2PMAXFR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_PMAXFR"})
Local nZR2PCALFR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_PCALFR"})
Local nZR2SITFRE := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_SITFRE"})
Local nVlrFrete  := &(ReadVar())
Local nPcCalcu   := 0

nPcCalcu := Round((nVlrFrete * 100) / oDoctos:aCols[oDoctos:nAt][nZR2VLDOC],Tamsx3("ZR2_PCALFR")[02])
oDoctos:aCols[oDoctos:nAt][nZR2PCALFR] := nPcCalcu

If nVlrFrete > 0
    If oDoctos:aCols[oDoctos:nAt][nZR2PCALFR] > oDoctos:aCols[oDoctos:nAt][nZR2PMAXFR]
        oDoctos:aCols[oDoctos:nAt][nZR2SITFRE] := LoadBitmap( GetResources(), cImgF_NOK )
    Else
        oDoctos:aCols[oDoctos:nAt][nZR2SITFRE] := LoadBitmap( GetResources(), cImgF_OK )
    EndIf
Else
    oDoctos:aCols[oDoctos:nAt][nZR2SITFRE] := LoadBitmap( GetResources(), cImgF_VAS )
EndIf
oDoctos:Refresh()

Return lRet

/*/{protheus.doc} GetPcFrete
*******************************************************************************************
Retorna o Percentual maximo de frete.
 
@author: Marcelo Celi Marques
@since: 09/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPcFrete(cTipo,cCliFor,cLoja)
Local nPercentual := 0
Local aArea       := GetArea()
Local cMunMetrop  := "50308|03901|05708|06607|09007|09205|10609|13009|13801|15004|15103|15707|16309|16408|18305|18800|22208|22505|23107|25003|26209|28502|29401|30607|34401|39103|39806|43303|44103|45001|46801|47304|47809|48708|48807|49953|52502|52809|56453|"

Do Case
    Case cTipo == "C"
        SA1->(dbSetOrder(1))
        If SA1->(dbSeek(xFilial("SA1")+cCliFor+cLoja))
            If SA1->A1_EST == "SP"
                If !Empty(SA1->A1_COD_MUN) .And. Alltrim(SA1->A1_COD_MUN) $ cMunMetrop
                    nPercentual := 3
                Else
                    nPercentual := 3.5
                EndIf
            Else
                Do Case
                    Case Alltrim(Upper(SA1->A1_EST)) $ "PR|SC|RS|RJ|ES|MG"
                        nPercentual := 5

                    Case Alltrim(Upper(SA1->A1_EST)) $ "BA|PI|MA|SE|AL|PE|PB|RN|CE|"
                        nPercentual := 6

                    Case Alltrim(Upper(SA1->A1_EST)) $ "TO|PA|AP|RR|AM|AC|RO|"
                        nPercentual := 6

                    Case Alltrim(Upper(SA1->A1_EST)) $ "BR|GO|MT|MS"
                        nPercentual := 5

                EndCase                
            EndIf
        EndIf

    Case cTipo == "F"
        SA2->(dbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+cCliFor+cLoja))
            If SA2->A2_EST == "SP"
                If !Empty(SA2->A2_COD_MUN) .And. Alltrim(SA2->A2_COD_MUN) $ cMunMetrop
                    nPercentual := 3
                Else
                    nPercentual := 3.5
                EndIf
            Else
                Do Case
                    Case Alltrim(Upper(SA2->A2_EST)) $ "PR|SC|RS|RJ|ES|MG"
                        nPercentual := 5

                    Case Alltrim(Upper(SA2->A2_EST)) $ "BA|PI|MA|SE|AL|PE|PB|RN|CE|"
                        nPercentual := 6

                    Case Alltrim(Upper(SA2->A2_EST)) $ "TO|PA|AP|RR|AM|AC|RO|"
                        nPercentual := 6

                    Case Alltrim(Upper(SA2->A2_EST)) $ "BR|GO|MT|MS"
                        nPercentual := 5

                EndCase                
            EndIf
        EndIf    

EndCase

RestArea(aArea)

Return nPercentual

/*/{protheus.doc} BoImgInRom
*******************************************************************************************
Inicializa a imagem da grid
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoImgInRom()
Local cImagem := ""
cImagem := LoadBitmap(GetResources(),cImgF_VAS)
Return cImagem

/*/{protheus.doc} MyEnchBar
*******************************************************************************************
Cria barra de botoes
 
@author: Marcelo Celi Marques
@since: 10/02/2023
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

/*/{protheus.doc} AdicDoctos
*******************************************************************************************
Adicionar Documentos
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AdicDoctos()
Local oWizard    := NIL
Local aBoxParam  := {}
Local lOk        := .F.
Local nX         := 1
Local nY         := 1
Local aColsTmp   := {}
Local lRet       := .F. 
Local nPZR2TPDOC := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_TPDOC"})
Local nZR2FILDOC := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_FILDOC"})
Local nZR2DOCTO  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DOCTO"})
Local nZR2SERIE  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_SERIE"})
Local nZR2CLIFOR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_CLIFOR"})
Local nZR2LOJA   := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_LOJA"})
Local nZR2NOME   := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_NOME"})
Local nZR2DTDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_DTDOC"})
Local nZR2VLDOC  := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_VLDOC"})
Local nZR2PMAXFR := Ascan(oDoctos:aHeader,{|x| Alltrim(x[02])=="ZR2_PMAXFR"})

Private aRetParam   := {}
Private oLbxDocts   := NIL
Private aDoctos     := {{.F.,"","","","","","","",0,Stod(""),0}}
Private lRunDblClick:= .T.      
Private lChkTWiz 	:= .F.
Private oNoSel 	    := LoadBitmap( GetResources(), "LBNO" 	)
Private oSel 	    := LoadBitmap( GetResources(), "LBTIK"	)

aAdd(aRetParam,dDatabase )
aAdd(aBoxParam,{1, Capital(Alltrim("Data Documento"))+" de:"  , &('aRetParam['+Alltrim(Str(Len(aRetParam)))+']'),PesqPict("SF1","F1_EMISSAO"),"","","",70,.F.})

aAdd(aRetParam,dDatabase )
aAdd(aBoxParam,{1, Capital(Alltrim("Data Documento"))+" até:"  , &('aRetParam['+Alltrim(Str(Len(aRetParam)))+']'),PesqPict("SF1","F1_EMISSAO"),"","","",70,.F.})

aAdd(aRetParam,1)
aAdd(aBoxParam,{3,"Documentos: ",&('aRetParam['+Alltrim(Str(Len(aRetParam)))+']'),{"Entrada","Saída"},150,".T.",.T.,".T."})  


DEFINE WIZARD oWizard ;
	TITLE "Adicionar Documentos" ;
          	HEADER "Romaneio" ;
          	MESSAGE "Avance para Continuar" 		;
          	TEXT "Este procedimento deverá importar os Documentos devidamente filtrados e selecionados ao Romaneio de Transporte." PANEL;
          	NEXT   {|| .T. } ;
          	FINISH {|| .T. }; 
          	          	                            
   	CREATE PANEL oWizard ;				
          	HEADER "Romaneio" ;
          	MESSAGE "Informe os parametros para filtrar os documentos." PANEL;          	          	
          	NEXT   {|| MsgRun("Filtrando Documentos...","Aguarde",{|| lRet := FiltrDoctos() }), lRet } ;
          	FINISH {|| MsgRun("Filtrando Documentos...","Aguarde",{|| lRet := FiltrDoctos() }), lRet } ;
          	PANEL

   	Parambox(aBoxParam,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)

    CREATE PANEL oWizard ;				
          	HEADER "Romaneio" ;
          	MESSAGE "Selecione os documentos." PANEL;          	          	
          	NEXT   {|| lOk := MsgYesNo("Confirma a Seleção dos Documentos ?"),lOk } ;
          	FINISH {|| lOk := MsgYesNo("Confirma a Seleção dos Documentos ?"),lOk } ;
          	PANEL
   	
        @ 000, 000 LISTBOX oLbxDocts FIELDS HEADER 	""								,;                                                    
                                                    "Tp Docto"	    				,;
                                                    "Filial"						,;
                                                    "Documento"						,;
                                                    "Serie"	    					,;
                                                    "Cliente/Fornec"				,;
                                                    "Loja"	           				,;
                                                    "Nome"      					,;
                                                    "Valor Doctos" 					,;
                                                    "Emissão"      					,;
                                                    "Pc Max Frete" 					 ;
                                        COLSIZES 	5								,;                                                    
                                                    10 								,;
                                                    10 								,;
                                                    20 								,;
                                                    10 								,;
                                                    20 								,;
                                                    10 								,;
                                                    60								,;
                                                    30								,;
                                                    20								,;
                                                    20								 ;
                                SIZE (oWizard:GetPanel(3):NWIDTH/2)-2,(oWizard:GetPanel(3):NHEIGHT/2)-2;
                                ON DBLCLICK (If(!Empty(aDoctos[oLbxDocts:nAt,3]),aDoctos[oLbxDocts:nAt,1] := !aDoctos[oLbxDocts:nAt,1],aDoctos[oLbxDocts:nAt,1] := aDoctos[oLbxDocts:nAt,1]) ,oLbxDocts:Refresh(.f.)) OF oWizard:GetPanel(3) PIXEL

        oLbxDocts:SetArray(aDoctos)	
        oLbxDocts:bLine         := {|| {If(aDoctos[oLbxDocts:nAt,1],oSel,oNoSel),aDoctos[oLbxDocts:nAt,2],aDoctos[oLbxDocts:nAt,3],aDoctos[oLbxDocts:nAt,4],aDoctos[oLbxDocts:nAt,5],aDoctos[oLbxDocts:nAt,6],aDoctos[oLbxDocts:nAt,7],aDoctos[oLbxDocts:nAt,8],aDoctos[oLbxDocts:nAt,9],aDoctos[oLbxDocts:nAt,10],aDoctos[oLbxDocts:nAt,11]}}
        oLbxDocts:bRClicked 	:= { || AEVAL(aDoctos,{|x| x[1]:=!x[1] }), oLbxDocts:Refresh(.F.)}    	
        oLbxDocts:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aDoctos, {|e| IF(!Empty(e[3]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxDocts:Refresh()}

        oWizard:OFINISH:CTITLE 	 := "&Adicionar"

ACTIVATE WIZARD oWizard CENTERED

If lOk
    For nX:=1 to Len(aDoctos)
        If aDoctos[nX,01]
            aColsTmp := {}
            For nY:=1 to Len(oDoctos:aHeader)
                If Alltrim(Upper(oDoctos:aHeader[nY,02]))=="ZR2_SITFRE"
                    aAdd(aColsTmp,LoadBitmap( GetResources(), cImgF_VAS ))
                Else
                    aAdd(aColsTmp,Criavar(oDoctos:aHeader[nY,02],.T.))
                EndIf
            Next nY
            aAdd(aColsTmp,.F.)

            aColsTmp[nPZR2TPDOC] := aDoctos[nX,02]
            aColsTmp[nZR2FILDOC] := aDoctos[nX,03]
            aColsTmp[nZR2DOCTO]  := aDoctos[nX,04]
            aColsTmp[nZR2SERIE]  := aDoctos[nX,05]
            aColsTmp[nZR2CLIFOR] := aDoctos[nX,06]
            aColsTmp[nZR2LOJA]   := aDoctos[nX,07]
            aColsTmp[nZR2NOME]   := aDoctos[nX,08]
            aColsTmp[nZR2VLDOC]  := aDoctos[nX,09]
            aColsTmp[nZR2DTDOC]  := aDoctos[nX,10]
            aColsTmp[nZR2PMAXFR] := aDoctos[nX,11]

            If Len(oDoctos:aCols)==1 .And. Empty(oDoctos:aCols[01,04])
                oDoctos:aCols := {}
            EndIf
            aAdd(oDoctos:aCols,aColsTmp)
        EndIf
    Next nX
EndIf
oDoctos:Refresh()
AtuDados()

Return

/*/{protheus.doc} FiltrDoctos
*******************************************************************************************
Filtrar os Documentos
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function FiltrDoctos()
Local cQuery := ""
Local cAlias := GetNextAlias()
Local lRet   := .F.

aDoctos := {}

If ValTYpe(aRetParam[03])<>"N"
    If aRetParam[03]=="Entrada"
        aRetParam[03]:=1
    Else
        aRetParam[03]:=2
    EndIf
EndIf

If aRetParam[03]==1
    cQuery := "SELECT SF1.R_E_C_N_O_ AS RECDOC"                                                         +CRLF
    cQuery += "  FROM "+RetSqlName("SF1")+" SF1 (NOLOCK)"                                               +CRLF
    cQuery += "  WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"'"                                            +CRLF
    cQuery += "    AND SF1.F1_EMISSAO BETWEEN '"+dTos(aRetParam[01])+"' AND '"+dTos(aRetParam[02])+"'"  +CRLF
    cQuery += "    AND SF1.D_E_L_E_T_ = ' '"                                                            +CRLF
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    Do While (cAlias)->(!Eof())
        SF1->(dbGoto((cAlias)->RECDOC))
        ZR2->(dbSetOrder(2))
        If !ZR2->(dbSeek(xFilial("ZR2")+"E"+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
            aAdd(aDoctos,{.F.,"E",SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,Posicione("SA2",1,xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_NOME"),SF1->F1_VALBRUT,SF1->F1_EMISSAO,GetPcFrete("F",SF1->F1_FORNECE,SF1->F1_LOJA)})
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
Else
    cQuery := "SELECT SF2.R_E_C_N_O_ AS RECDOC"                                                         +CRLF
    cQuery += "  FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"                                               +CRLF
    cQuery += "  WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"                                            +CRLF
    cQuery += "    AND SF2.F2_EMISSAO BETWEEN '"+dTos(aRetParam[01])+"' AND '"+dTos(aRetParam[02])+"'"  +CRLF
    cQuery += "    AND SF2.D_E_L_E_T_ = ' '"                                                            +CRLF
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    Do While (cAlias)->(!Eof())
        SF2->(dbGoto((cAlias)->RECDOC))
        ZR2->(dbSetOrder(2))
        If !ZR2->(dbSeek(xFilial("ZR2")+"S"+SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
            aAdd(aDoctos,{.F.,"S",SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME"),SF2->F2_VALBRUT,SF2->F2_EMISSAO,GetPcFrete("C",SF2->F2_CLIENTE,SF2->F2_LOJA)})
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
EndIf

If Len(aDoctos)==0
    aDoctos := {{.F.,"","","","","","","",0,Stod(""),0}}
    lRet := .F.
    MsgAlert("Nenhum Documento Localizado no Filtro Informado.")
Else
    lRet := .T.
EndIf

oLbxDocts:SetArray(aDoctos)	
oLbxDocts:bLine         := {|| {If(aDoctos[oLbxDocts:nAt,1],oSel,oNoSel),aDoctos[oLbxDocts:nAt,2],aDoctos[oLbxDocts:nAt,3],aDoctos[oLbxDocts:nAt,4],aDoctos[oLbxDocts:nAt,5],aDoctos[oLbxDocts:nAt,6],aDoctos[oLbxDocts:nAt,7],aDoctos[oLbxDocts:nAt,8],aDoctos[oLbxDocts:nAt,9],aDoctos[oLbxDocts:nAt,10],aDoctos[oLbxDocts:nAt,11]}}
oLbxDocts:bRClicked 	:= { || AEVAL(aDoctos,{|x| x[1]:=!x[1] }), oLbxDocts:Refresh(.F.)}    	
oLbxDocts:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aDoctos, {|e| IF(!Empty(e[3]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxDocts:Refresh()}
oLbxDocts:Refresh()

Return lRet
