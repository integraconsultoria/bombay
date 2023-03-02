#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*/{protheus.doc} BoAtuStPv
*******************************************************************************************
Atualiza o status do pedido de vendas
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoAtuStPv(cNumero)
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local lBlq      := .F.

If SC5->(FieldPos("C5_XSTATUS"))>0
    SC5->(dbSetOrder(1))
    If SC5->(dbSeek(xFilial("SC5")+cNumero))        
        SC9->(dbSetOrder(1))
        If SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
            Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == SC5->(C5_FILIAL+C5_NUM)
                If SC9->C9_BLEST=="02" .Or. SC9->C9_BLCRED=="02"
                    lBlq := .T.
                    Exit                
                EndIf
                SC9->(dbSkip())
            EndDo
        Else
            lBlq := .T.
        EndIf

        Reclock("SC5",.F.)        
        If lBlq            
            SC5->C5_XSTATUS := "2" //->> bloqueado estoque
            If SC5->(FieldPos("C5_XDLIBES"))>0
                SC5->C5_XDLIBES := ""
            EndIf
        Else
            SC5->C5_XDLIBES := "3" //->> pendente de separacao
            If SC5->(FieldPos("C5_XDLIBES"))>0
                SC5->C5_XDLIBES := Dtoc(Date())+" "+Time()
            EndIf
        EndIf
        SC5->(MsUnlock())

    EndIf
EndIf

SC9->(RestArea(aAreaSC9))
SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return

/*/{protheus.doc} BOLogLibPv
*******************************************************************************************
Realiza a Liberação Logistica do Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOLogLibPv()
Local cMsg		    := ""
Local lOk           := .F.

//->> Marcelo Celi - 16/02/2021
Local cLogotipo     := NIL
Local aCoords       := {}
Local aSize	   		:= MsAdvSize()

//->> Marcelo Celi - 06/01/2021
AjustaSXB()

Private oWizard	    := NIL
Private _lEdita     := .F.

Private _cPedido    := Space(Tamsx3("C5_NUM")[01])
Private _oPedido    := NIL
Private _cCliente   := ""
Private _oCliente   := NIL
Private _cLoja      := ""
Private _oLoja      := NIL
Private _cNome      := ""
Private _oNome      := NIL
Private _dEmissao   := Stod("")
Private _oEmissao   := NIL
Private _cEndereco  := ""
Private _oEndereco  := NIL

//->> Marcelo Celi - 16/02/2021
Private _nValor     := 0
Private _oValor     := NIL
Private _cMsgNf     := ""
Private _oMsgNf     := NIL

//->> Marcelo Celi - 24/07/2021
Private _dAgendam   := Stod("")
Private _oAgendam   := NIL

Private _cTransp    := Space(Tamsx3("C5_TRANSP")[01])
Private _oTransp    := NIL
Private _cTipFrete  := Space(Tamsx3("C5_TPFRETE")[01])
Private _oTipFrete  := NIL
Private _nFrete     := 0
Private _oFrete     := NIL
Private _nPesoLiq   := 0
Private _oPesoLiq   := NIL
Private _nPesoBrut  := 0
Private _oPesoBrut  := NIL
Private _cEspecie   := Space(Tamsx3("C5_ESPECI1")[01])
Private _oEspecie   := NIL
Private _nVolumes   := 0
Private _oVolumes   := NIL
Private _aCombFret  := {}

//->> Marcelo Celi - 23/12/2020
Private _nCubagem   := 0
Private _oCubagem   := NIL

//->> Marcelo Celi - 23/12/2020
Private _cObsLogi   := ""
Private _oObsLogi   := NIL

If SC5->(FieldPos("C5_XOBSLOG")) > 0
    _cObsLogi := Space(Tamsx3("C5_XOBSLOG")[01])
EndIf

SX3->(dbSetOrder(2))
If SX3->(dbSeek("C5_TPFRETE"))
    _aCombFret := X3Cbox()
    If Valtype(_aCombFret)=="C"
        _aCombFret := StrTokArr( _aCombFret , ";" )        
    EndIf
EndIf
aAdd(_aCombFret," ")
_aCombFret := aSort(_aCombFret,,,{|x,y| x < y })

cMsg := "Este Recurso Permite efetuar a Liberação do Pedido de Vendas Logisticamente, informando os dados necessários para continuar com o Faturamento."+CRLF
cMsg += CRLF
cMsg += CRLF
cMsg += "Avançar para Continuar..."

aCoords     := {0,0,(aSize[6] := aSize[6] - aSize[2] - aSize[8] - 5)*.9,(aSize[5])*.45}

oWizard := APWizard():New(  "Pedidos de Vendas",                   												 ;   // chTitle  - Titulo do cabeï¿½alho
                            "",                              							         			     ;   // chMsg    - Mensagem do cabeï¿½alho
                            "Conferência Logística",                							 			     ;   // cTitle   - Tï¿½tulo do painel de apresentaï¿½ï¿½o
                            cMsg,            													 			     ;   // cText    - Texto do painel de apresentaï¿½ï¿½o
                            {|| .T. },          												 			     ;   // bNext    - Bloco de cï¿½digo a ser executado para validar o botï¿½o "Avanï¿½ar"
                            {|| .T. },              											 				 ;   // bFinish  - Bloco de cï¿½digo a ser executado para validar o botï¿½o "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                            cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabeï¿½alho, essa tem que fazer parte do repositï¿½rio 
                            {|| },                												 			     ;   // bExecute - Bloco de cï¿½digo contendo a aï¿½ï¿½o a ser executada no clique dos botï¿½es "Avanï¿½ar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nï¿½o exibe o painel de apresentaï¿½ï¿½o
                            aCoords                     										 				 )   // aCoord   - Array contendo as coordenadas da tela
//DEFINE WIZARD oWizard 												        ;
//		TITLE "Pedidos de Vendas"									        ;
//          	HEADER "Conferência Logística"							        ;
//          	MESSAGE ""												        ;
//         	TEXT cMsg PANEL											        ;
//          	NEXT 	{|| .T. } 										        ;
//          	FINISH 	{|| .T. }										        ;

oWizard:NewPanel(   "Conferência Logística",               							                			 ;   // cTitle   - Tï¿½tulo do painel 
                    "Informe os Dados Necessários para a Liberação.", 	    		             			     ;   // cMsg     - Mensagem posicionada no cabeï¿½alho do painel
                    {|| .T. },                						         				                     ;   // bBack    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Voltar"
                    {|| lOk:=LibLogTudOk(),lOk }, 			                                                     ;   // bNext    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Avanï¿½ar"
                    {|| lOk:=LibLogTudOk(),lOk },    	    		                                             ;   // bFinish  - Bloco de cï¿½digo utilizado para validar o botï¿½o "Finalizar"
                    .T.,                                              							  			   	 ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                    {|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

//   	CREATE PANEL oWizard 				 							        ;
//          	HEADER "Conferência Logística"					 		        ;
//          	MESSAGE "Informe os Dados Necessários para a Liberação." PANEL  ;
//          	NEXT 	{|| lOk:=LibLogTudOk(),lOk }	                        ;
//          	FINISH 	{|| lOk:=LibLogTudOk(),lOk }	                        ;
//          	PANEL

        @ 005,010 MSGet _oPedido Var _cPedido F3 "SC5LOG"  When .T.    SIZE  50,09     Picture PesqPict("SC5","C5_NUM")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 016,010 Say SC5->(RetTitle("C5_NUM"))													  			                OF oWizard:GetPanel(2) PIXEL

        @ 005,070 MSGet _oEmissao Var _dEmissao 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_EMISSAO")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,070 Say SC5->(RetTitle("C5_EMISSAO"))													  			            OF oWizard:GetPanel(2) PIXEL

        _oTipFrete := TComboBox():New(005,130,{|u|if(PCount()==0,_cTipFrete,_cTipFrete:=u)},_aCombFret,70,09,oWizard:GetPanel(2),,{|| },,,,.T.,,,,,,,,,'_cTipFrete')
        @ 016,130 Say SC5->(RetTitle("C5_TPFRETE"))													  			            OF oWizard:GetPanel(2) PIXEL
        _oTipFrete:lEditable := .F.

        @ 005,210 MSGet _oCliente Var _cCliente 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_CLIENTE")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,210 Say SC5->(RetTitle("C5_CLIENTE"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 005,270 MSGet _oLoja Var _cLoja 	             When .F.   SIZE  20,09     Picture PesqPict("SC5","C5_LOJACLI")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,270 Say SC5->(RetTitle("C5_LOJACLI"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,010 MSGet _oNome Var _cNome 	             When .F.   SIZE 110,09     Picture PesqPict("SA1","A1_NOME")       OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,010 Say SA1->(RetTitle("A1_NOME"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,125 MSGet _oTransp Var _cTransp F3 "SA4"   When _lEdita SIZE  45,09   Picture PesqPict("SC5","C5_TRANSP")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 039,140 Say SC5->(RetTitle("C5_TRANSP"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,175 MSGet _oFrete Var _nFrete              When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_FRETE")      OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 039,175 Say SC5->(RetTitle("C5_FRETE"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,230 MSGet _oCubagem Var _nCubagem          When _lEdita .And. SC5->(FieldPos("C5_XCUBAGE"))>0 SIZE  60,09   Picture "@E 99,999,999.99"    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,230 Say "Cubagem"		                    											  			                                        OF oWizard:GetPanel(2) PIXEL

        @ 051,010 MSGet _oPesoLiq Var _nPesoLiq          When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_PESOL")      OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 062,010 Say SC5->(RetTitle("C5_PESOL"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 051,070 MSGet _oPesoBrut Var _nPesoBrut        When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_PBRUTO")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 062,070 Say SC5->(RetTitle("C5_PBRUTO"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 051,130 MSGet _oEspecie Var _cEspecie          When _lEdita SIZE  90,09   Picture PesqPict("SC5","C5_ESPECI1")    OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 062,130 Say SC5->(RetTitle("C5_ESPECI1"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 051,230 MSGet _oVolumes Var _nVolumes          When _lEdita SIZE  60,09   Picture PesqPict("SC5","C5_VOLUME1")    OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoLogVldPV()
        @ 062,230 Say SC5->(RetTitle("C5_VOLUME1"))													  			            OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 25/01/2021
        @ 074,010 MSGet _oObsLogi Var _cObsLogi          When _lEdita .And. SC5->(FieldPos("C5_XOBSLOG"))>0 SIZE  280,11   Picture "@!"                  OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 088,010 Say "Observação Logistica"		                    											  			                         OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 09/01/2021
        @ 108,010 GET _oEndereco VAR _cEndereco MEMO NO VSCROLL WHEN .F. SIZE 275,25 OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 16/02/2021
        @ 138,010 MSGet _oValor Var _nValor               When .F.  SIZE  90,09   Picture "@E 9,999,999,999.99"                  OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 152,010 Say "Valor Pedido"		                    											  		             OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 21/07/2021
        @ 138,110 MSGet _oAgendam Var _dAgendam           When .F.  SIZE  90,09   Picture "@E 9,999,999,999.99"                  OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 152,110 Say "Agendamento"		                    											  		                 OF oWizard:GetPanel(2) PIXEL

        @ 162,010 MSGet _oMsgNf Var _cMsgNf               When .F.  SIZE  275,11   Picture "@!"                                   OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 176,010 Say "Mensagem Nota Fiscal"		                    											  		     OF oWizard:GetPanel(2) PIXEL

		oWizard:OFINISH:CCAPTION := "&Liberar"
		oWizard:OFINISH:CTITLE 	 := "&Liberar"			  	   		

oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o diï¿½logo serï¿½ centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de cï¿½digo a ser executado no encerramento do diï¿½logo
                    {|| .T. },  ;   // bInit    - Bloco de cï¿½digo a ser executado na inicializaï¿½ï¿½o do diï¿½logo
                    {|| .T. }   )   // bWhen    - Bloco de cï¿½digo para habilitar a execuï¿½ï¿½o do diï¿½logo

//ACTIVATE WIZARD oWizard CENTERED

//->> Marcelo Celi - 25/01/2021
//If lOk
//    LiberLogist()
//EndIf

Return

/*/{protheus.doc} BoLogVldPV
*******************************************************************************************
Efetua a validação do pedido de vendas na liberação logistica.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoLogVldPV()
Local lRet      := .T.
Local xCpo      := ReadVar()
Local xConteudo := &(xCpo)
Local nPos      := 0

If !Empty(xConteudo)
    If Upper("_cPedido") $ Upper(xCpo)
        _nValor := 0 
        _cMsgNf := ""
        
        //->> Marcelo Celi - 24/01/2021
        _dAgendam := Stod("")

        SC5->(dbSetOrder(1))
        If SC5->(dbSeek(xFilial("SC5")+xConteudo))
            //->> Marcelo Celi - 16/02/2021
            _nValor := GetVlrPedid()

            //->> Marcelo Celi - 24/01/2021
            _dAgendam := SC5->C5_XDAGEND
            
            If SC5->(FieldPos("C5_XMSGVNF"))>0
                _cMsgNf := SC5->C5_XMSGVNF
            Else
                _cMsgNf := ""
            EndIf

            If SC5->C5_XSTATUS == "5"
                If MsgYesNo("O Pedido já encontra-se liberado na Logistica, porém ainda está parado no próximo estágio, podendo ainda ter a liberação logística estornada."+CRLF+"Deseja estornar a liberação logística aplicada anteriormente ?")
                    Reclock("SC5",.F.)
                    SC5->C5_XSTATUS := "4" // Pendencia de Logistica
                    SC5->C5_XDLIBLO := ""        
                    SC5->(MsUnlock())

                    //->> Marcelo Celi - 09/01/2021
                        If SC9->(FieldPos("C9_XPODFAT"))> 0
                        SC9->(dbSetOrder(1))
                        SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
                        Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+SC5->C5_NUM
                            Reclock("SC9",.F.)
                            SC9->C9_XPODFAT := ""
                            SC9->(MsUnlock())
                            SC9->(dbSkip())
                        EndDo
                    EndIf

                    MsgAlert("O Pedido sofreu estorno da liberação logística, voltando ao estado anterior.")
                EndIf
            EndIf

            If SC5->C5_XSTATUS == "4"
                _cCliente   := SC5->C5_CLIENTE
                _cLoja      := SC5->C5_LOJACLI
                _cNome      := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
                _dEmissao   := SC5->C5_EMISSAO
                _cTransp    := SC5->C5_TRANSP
                nPos := Ascan(_aCombFret,{|x| Upper(Left(x,1)) == SC5->C5_TPFRETE })
                If nPos > 0
                    _cTipFrete := _aCombFret[nPos]
                    _oTipFrete:nAt := nPos
                Else
                    _cTipFrete := Space(Tamsx3("C5_TPFRETE")[01])
                    _oTipFrete:nAt := 1
                EndIf
                _nFrete     := SC5->C5_FRETE
                _nPesoLiq   := SC5->C5_PESOL
                _nPesoBrut  := SC5->C5_PBRUTO
                _cEspecie   := SC5->C5_ESPECI1
                _nVolumes   := SC5->C5_VOLUME1
                
                //->> Marcelo Celi - 23/12/2020
                _nCubagem   := If(SC5->(FieldPos("C5_XCUBAGE"))>0,SC5->C5_XCUBAGE,0)

                //->> Marcelo Celi - 25/01/2021
                If SC5->(FieldPos("C5_XOBSLOG")) > 0
                    _cObsLogi := SC5->C5_XOBSLOG
                Else
                    _cObsLogi := ""
                EndIf

                //->> Marcelo Celi - 09/01/2021
                _cEndereco := ""
                SA1->(dbSetOrder(1))
                If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
                    _cEndereco := Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - "+Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)
                EndIf                

                lRet        := .T.
                _lEdita     := .T.
                _oTipFrete:lEditable := .T.
                _oTransp:SetFocus()
            Else
                _cPedido    := Space(Tamsx3("C5_NUM")[01])
                _cCliente   := ""
                _cLoja      := ""
                _cNome      := ""
                _dEmissao   := Stod("")
                _cTransp    := Space(Tamsx3("C5_TRANSP")[01])
                _cTipFrete  := Space(Tamsx3("C5_TPFRETE")[01])
                _nFrete     := 0
                _nPesoLiq   := 0
                _nPesoBrut  := 0
                _cEspecie   := Space(Tamsx3("C5_ESPECI1")[01])
                _nVolumes   := 0
                
                //->> Marcelo Celi - 23/12/2020
                _nCubagem   := 0

                //->> Marcelo Celi - 25/01/2021
                If SC5->(FieldPos("C5_XOBSLOG")) > 0
                    _cObsLogi := Space(Tamsx3("C5_XOBSLOG")[01])
                Else
                    _cObsLogi := ""
                EndIf

                //->> Marcelo Celi - 09/01/2021
                _cEndereco := ""

                lRet        := .F.
                _lEdita     := .F.
                _oTipFrete:lEditable := .F.
                MsgAlert("Pedido de Vendas não encontra-se pendente de liberação logística...")
            EndIf
        Else
            _cPedido    := Space(Tamsx3("C5_NUM")[01])
            _cCliente   := ""
            _cLoja      := ""
            _cNome      := ""
            _dEmissao   := Stod("")
            _cTransp    := Space(Tamsx3("C5_TRANSP")[01])
            _cTipFrete  := Space(Tamsx3("C5_TPFRETE")[01])
            _nFrete     := 0
            _nPesoLiq   := 0
            _nPesoBrut  := 0
            _cEspecie   := Space(Tamsx3("C5_ESPECI1")[01])
            _nVolumes   := 0
            
            //->> Marcelo Celi - 23/12/2020
             _nCubagem  := 0

            //->> Marcelo Celi - 25/01/2021
            If SC5->(FieldPos("C5_XOBSLOG")) > 0
                _cObsLogi := Space(Tamsx3("C5_XOBSLOG")[01])
            Else
                _cObsLogi := ""
            EndIf

             //->> Marcelo Celi - 09/01/2021
            _cEndereco := ""

            lRet        := .F.
            _lEdita     := .F.
            _oTipFrete:lEditable := .F.
            MsgAlert("Pedido de Vendas não Localizado...")
        EndIf
    
    ElseIf Upper("_cTransp") $ Upper(xCpo)
        SA4->(dbSetOrder(1))
        If SA4->(dbSeek(xFilial("SA4")+xConteudo))
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Transportadora não Localizada...")
        EndIf
    
    EndIf

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oTransp:Refresh()
    _oFrete:Refresh()
    _oPesoLiq:Refresh()
    _oPesoBrut:Refresh()
    _oEspecie:Refresh()
    _oVolumes:Refresh()
    _oTipFrete:Refresh()

    //->> Marcelo Celi - 25/01/2021
    _oObsLogi:Refresh()

    //->> Marcelo Celi - 09/01/2021
    _oEndereco:Refresh()

    //->> Marcelo Celi - 16/02/2021
    _oValor:Refresh()
    _oMsgNf:Refresh()

    //->> Marcelo Celi - 24/07/2021
    _oAgendam:Refresh()

EndIf

Return lRet

/*/{protheus.doc} LibLogTudOk
*******************************************************************************************
Verifica se esta tudo ok nos campos da validação logistica
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LibLogTudOk()
Local lRet := .F.

If !Empty(_cCliente)
    lRet := .T.

    If lRet
        If  _nPesoLiq > 0
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar o Peso Liquido para continuar com a Liberação Logística...")
        EndIf
    EndIf

    If lRet
        If _nPesoBrut > 0
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar o Peso Bruto para continuar com a Liberação Logística...")
        EndIf
    EndIf

    If lRet
        If !Empty(_cEspecie)
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar a Espécie para continuar com a Liberação Logística...")
        EndIf
    EndIf

    If lRet
        If _nVolumes > 0
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar a Quantidade de Volumes para continuar com a Liberação Logística...")
        EndIf
    EndIf

Else
    lRet := .F.
    MsgAlert("Informe um Pedido de Vendas para Liberar...")
EndIf

If lRet
    lRet := MsgYesNo("Confirma a Liberação Logistica ?")
EndIf

//->> Marcelo Celi - 25/01/2021
If lRet
    LiberLogist()

    _cPedido    := Space(Tamsx3("C5_NUM")[01])
    _cCliente   := ""
    _cLoja      := ""
    _cNome      := ""
    _dEmissao   := Stod("")
    _cTransp    := Space(Tamsx3("C5_TRANSP")[01])
    _cTipFrete  := Space(Tamsx3("C5_TPFRETE")[01])
    _nFrete     := 0
    _nPesoLiq   := 0
    _nPesoBrut  := 0
    _cEspecie   := Space(Tamsx3("C5_ESPECI1")[01])
    _nVolumes   := 0
    _nCubagem   := 0

    //->> Marcelo Celi - 25/01/2021
    If SC5->(FieldPos("C5_XOBSLOG")) > 0
        _cObsLogi := Space(Tamsx3("C5_XOBSLOG")[01])
    Else
        _cObsLogi := ""
    EndIf

    _cEndereco  := ""

    _lEdita := .F.

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oTransp:Refresh()
    _oFrete:Refresh()
    _oPesoLiq:Refresh()
    _oPesoBrut:Refresh()
    _oEspecie:Refresh()
    _oVolumes:Refresh()
    _oTipFrete:Refresh()
    _oEndereco:Refresh()    
    _oObsLogi:Refresh()
    _oPedido:SetFocus()

    lRet        := .F.

EndIf

Return lRet


/*/{protheus.doc} LiberLogist
*******************************************************************************************
Grava a Liberação
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LiberLogist()

Reclock("SC5",.F.)
SC5->C5_TRANSP  := _cTransp
SC5->C5_TPFRETE := Left(_cTipFrete,1)            
SC5->C5_FRETE   := _nFrete
SC5->C5_PESOL   := _nPesoLiq
SC5->C5_PBRUTO  := _nPesoBrut
SC5->C5_ESPECI1 := _cEspecie
SC5->C5_VOLUME1 := _nVolumes
If SC5->(FieldPos("C5_XSTATUS")) > 0
    SC5->C5_XSTATUS := "5" // Pendencia de Faturamento
EndIf
If SC5->(FieldPos("C5_XDLIBLO")) > 0
    SC5->C5_XDLIBLO := dToc(dDatabase)+" "+Time()
EndIf

//->> Marcelo Celi - 23/12/2020
If SC5->(FieldPos("C5_XCUBAGE")) > 0
    SC5->C5_XCUBAGE := _nCubagem
EndIf

SC5->(MsUnlock())

//->> Marcelo Celi - 09/01/2021
If SC9->(FieldPos("C9_XPODFAT"))> 0
    SC9->(dbSetOrder(1))
    SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
    Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+SC5->C5_NUM
        Reclock("SC9",.F.)
        SC9->C9_XPODFAT := "S"
        SC9->(MsUnlock())
        SC9->(dbSkip())
    EndDo
EndIf

Return

/*/{protheus.doc} BOExpLibPv
*******************************************************************************************
Realiza a Liberação da Expedição do Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOExpLibPv()
Local cMsg		    := ""
Local lOk           := .F.

//->> Marcelo Celi - 06/01/2020
AjustaSXB()

Private oWizard	    := NIL
Private _lEdita     := .F.

Private _cPedido    := Space(Tamsx3("C5_NUM")[01])
Private _oPedido    := NIL
Private _cCliente   := ""
Private _oCliente   := NIL
Private _cLoja      := ""
Private _oLoja      := NIL
Private _cNome      := ""
Private _oNome      := NIL
Private _dEmissao   := Stod("")
Private _oEmissao   := NIL

Private _dColeta    := Stod("")
Private _oColeta    := NIL

//->> Marcelo Celi - 04/01/2021
Private _cTracking  := Space(Tamsx3("C5_XTRACKI")[01])
Private _oTracking  := NIL

//->> Marcelo Celi - 16/02/2021
Private _cEndereco  := ""
Private _oEndereco  := NIL

cMsg := "Este Recurso Permite efetuar a Liberação do Pedido de Vendas Referente a Expedição, informando os dados necessários para continuar com o Faturamento."+CRLF
cMsg += CRLF
cMsg += CRLF
cMsg += "Avançar para Continuar..."

DEFINE WIZARD oWizard 												        ;
		TITLE "Pedidos de Vendas"									        ;
          	HEADER "Conferência de Expedição"						        ;
          	MESSAGE ""												        ;
         	TEXT cMsg PANEL											        ;
          	NEXT 	{|| .T. } 										        ;
          	FINISH 	{|| .T. }										        ;
          	          	                            
   	CREATE PANEL oWizard 				 							        ;
          	HEADER "Conferência de Expedição"				 		        ;
          	MESSAGE "Informe os Dados Necessários para a Liberação." PANEL  ;
          	NEXT 	{|| lOk:=LibExpTudOk(),lOk }	                        ;
          	FINISH 	{|| lOk:=LibExpTudOk(),lOk }	                        ;
          	PANEL

        @ 005,010 MSGet _oPedido Var _cPedido F3 "SC5EXP"  When .T.    SIZE  50,09     Picture PesqPict("SC5","C5_NUM")        OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoExpVldPV()
        @ 016,010 Say SC5->(RetTitle("C5_NUM"))													  			                OF oWizard:GetPanel(2) PIXEL

        @ 005,070 MSGet _oEmissao Var _dEmissao 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_EMISSAO")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,070 Say SC5->(RetTitle("C5_EMISSAO"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,010 MSGet _oCliente Var _cCliente 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_CLIENTE")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,010 Say SC5->(RetTitle("C5_CLIENTE"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,070 MSGet _oLoja Var _cLoja 	             When .F.   SIZE  20,09     Picture PesqPict("SC5","C5_LOJACLI")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,070 Say SC5->(RetTitle("C5_LOJACLI"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,100 MSGet _oNome Var _cNome 	             When .F.   SIZE 180,09     Picture PesqPict("SA1","A1_NOME")       OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,100 Say SA1->(RetTitle("A1_NOME"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 065,010 MSGet _oColeta Var _dColeta           When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_XDCOLET")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoExpVldPV()
        @ 076,010 Say SC5->(RetTitle("C5_XDCOLET"))													  			            OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 04/01/2020        
        @ 065,070 MSGet _oTracking Var _cTracking        When _lEdita SIZE 205,09   Picture PesqPict("SC5","C5_XTRACKI")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 076,070 Say SC5->(RetTitle("C5_XTRACKI"))													  			            OF oWizard:GetPanel(2) PIXEL

        //->> Marcelo Celi - 16/02/2021
        @ 095,010 GET _oEndereco VAR _cEndereco MEMO NO VSCROLL WHEN .F. SIZE 275,25 OF oWizard:GetPanel(2) PIXEL


		oWizard:OFINISH:CCAPTION := "&Liberar"
		oWizard:OFINISH:CTITLE 	 := "&Liberar"			  	   		
			  	   		  	   
ACTIVATE WIZARD oWizard CENTERED

//->> Marcelo Celi - 24/02/2021
//If lOk
//    LiberExpedi()
//EndIf

Return

/*/{protheus.doc} BoExpVldPV
*******************************************************************************************
Efetua a validação do pedido de vendas na liberação de expedição.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoExpVldPV()
Local xCpo      := ReadVar()
Local xConteudo := &(xCpo)
Local lRet      := .T.

If !Empty(xConteudo)
    If Upper("_cPedido") $ Upper(xCpo)
        _cEndereco := ""

        SC5->(dbSetOrder(1))
        If SC5->(dbSeek(xFilial("SC5")+xConteudo))             
            //->> Marcelo Celi - 16/02/2021
            _cEndereco := ""
            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
                _cEndereco := Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - "+Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)
            EndIf                
             
             If SC5->C5_XSTATUS == "7"
                If MsgYesNo("O Pedido já encontra-se liberado na Expedição, porém ainda está parado no próximo estágio, podendo ainda ter a liberação da expedição estornada."+CRLF+"Deseja estornar a liberação da expedição aplicada anteriormente ?")
                    Reclock("SC5",.F.)
                    SC5->C5_XSTATUS := "6" // Faturado
                    SC5->C5_XDLIBEX := ""        
                    SC5->(MsUnlock())
                    MsgAlert("O Pedido sofreu estorno da liberação de Expedição, voltando ao estado anterior.")
                EndIf
            EndIf

            If SC5->C5_XSTATUS == "6"
                _cCliente   := SC5->C5_CLIENTE
                _cLoja      := SC5->C5_LOJACLI
                _cNome      := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
                _dEmissao   := SC5->C5_EMISSAO
                _dColeta    := SC5->C5_XDCOLET
                _cTracking  := SC5->C5_XTRACKI
                lRet        := .T.
                _lEdita     := .T.
                _oColeta:SetFocus()
            Else
                _cPedido    := Space(Tamsx3("C5_NUM")[01])
                _cCliente   := ""
                _cLoja      := ""
                _cNome      := ""
                _dEmissao   := Stod("")
                _dColeta    := Stod("")            
                _cTracking  := Space(Tamsx3("C5_XTRACKI")[01])
                lRet        := .F.
                _lEdita     := .F.
                MsgAlert("Pedido de Vendas não encontra-se pendente de liberação para expedição...")
            EndIf
        Else
            _cPedido    := Space(Tamsx3("C5_NUM")[01])
            _cCliente   := ""
            _cLoja      := ""
            _cNome      := ""
            _dEmissao   := Stod("")
            _dColeta    := Stod("")
            _cTracking  := Space(Tamsx3("C5_XTRACKI")[01])
            lRet        := .F.
            _lEdita     := .F.
            MsgAlert("Pedido de Vendas não Localizado...")
        EndIf
    
    ElseIf Upper("_dColeta") $ Upper(xCpo)        
        If !Empty(xConteudo)
            If xConteudo >= dDatabase
                lRet := .T.
            Else
                lRet := .F.
            MsgAlert("Favor informar uma Data da Coleta Superior ou Igual a Database do Sistema...")
            EndIf    
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data da Coleta válida...")
        EndIf
    
    EndIf

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oColeta:Refresh()
    _oTracking:Refresh()
    _oEndereco:Refresh()

EndIf

Return lRet

/*/{protheus.doc} LibExpTudOk
*******************************************************************************************
Verifica se esta tudo ok nos campos da validação da Expedição
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LibExpTudOk()
Local lRet := .F.

If !Empty(_cCliente)
    lRet := .T.

    If lRet
        If _dColeta >= dDatabase
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data de Coleta Superior ou Igual a Database do Sistema...")
        EndIf
    EndIf

    If lRet
        If !Empty(_cTracking)
            lRet := .T.
        Else
            //->> Marcelo Celi - 04/01/2020
            If !Empty(SC5->C5_XIDECOM)
                lRet := .F.
                MsgAlert("Favor informar um Código Tracking Válido para continuar com a Liberação...")
            Else
                lRet := .T.
            EndIf            
        EndIf
    EndIf

Else
    lRet := .F.
    MsgAlert("Informe um Pedido de Vendas para Liberar...")
EndIf

If lRet
    lRet := MsgYesNo("Confirma a Liberação de Expedição ?")    
EndIf

//->> Marcelo Celi - 24/02/2021
If lRet
    LiberExpedi()

    _cPedido    := Space(Tamsx3("C5_NUM")[01])
    _cCliente   := ""
    _cLoja      := ""
    _cNome      := ""
    _dEmissao   := Stod("")
    _dColeta    := Stod("")
    _cTracking  := Space(Tamsx3("C5_XTRACKI")[01])
    _cEndereco  := ""

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oColeta:Refresh()
    _oTracking:Refresh()
    _oEndereco:Refresh()

    _oPedido:SetFocus()

    lRet := .F.

EndIf

Return lRet

/*/{protheus.doc} LiberExpedi
*******************************************************************************************
Grava a Liberação
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LiberExpedi()

Reclock("SC5",.F.)
If SC5->(FieldPos("C5_XSTATUS")) > 0    
    SC5->C5_XSTATUS := "7" // Pendencia de Faturamento
EndIf
If SC5->(FieldPos("C5_XDLIBEX")) > 0
    SC5->C5_XDLIBEX := dToc(dDatabase)+" "+Time()
EndIf
If SC5->(FieldPos("C5_XDCOLET")) > 0
    SC5->C5_XDCOLET := _dColeta
EndIf
If SC5->(FieldPos("C5_XTRACKI")) > 0
    SC5->C5_XTRACKI := _cTracking
EndIf
SC5->(MsUnlock())

Return

/*/{protheus.doc} BoGetLogPv
*******************************************************************************************
Altera os campos volume e pesos a partir do gatilho no pedido de vendas.
 
@author: Marcelo Celi Marques
@since: 17/12/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoGetLogPv(cAcao)
Local nQtdVen   := 0
Local nPesLiq   := 0
Local nPesBru   := 0
Local nVolume   := 0
Local cCpo      := ReadVar()
Local nPProduto := 0
Local nPQtdVen  := 0
Local nPQtd2Uni := 0
Local nX        := 0
Local xRet      := NIL
//->> Marcelo Celi - 04/03/2022
Local nVolTotal := 0

Default cAcao   := "G"

nPProduto := Ascan(aHeader,{|x| Alltrim(Upper(x[02]))=="C6_PRODUTO"})
nPQtdVen  := Ascan(aHeader,{|x| Alltrim(Upper(x[02]))=="C6_QTDVEN"})
nPQtd2Uni := Ascan(aHeader,{|x| Alltrim(Upper(x[02]))=="C6_UNSVEN"})
If nPProduto > 0 .And. nPQtdVen > 0
    For nX:=1 to Len(aCols)
        If !aCols[nX][Len(aHeader)+1]
            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+aCols[nX][nPProduto]))
                If cAcao == "G" .And. nX == n
                    If "C6_QTDVEN" $ Alltrim(Upper(cCpo))
                        nQtdVen := &(cCpo)
                    Else
                        If SB1->B1_TIPCONV == "D"
                            nQtdVen := &(cCpo) * SB1->B1_CONV
                        Else
                            nQtdVen := &(cCpo) / SB1->B1_CONV
                        EndIf    
                    EndIf
                Else
                    nQtdVen := aCols[nX][nPQtdVen]
                EndIf    
                nPesLiq += (nQtdVen * SB1->B1_PESO)
                nPesBru += (nQtdVen * SB1->B1_PESBRU)
                
                If SB1->B1_TIPCONV == "D"
                    nVolume += (nQtdVen / SB1->B1_CONV)
                Else
                    nVolume += (nQtdVen * SB1->B1_CONV)
                EndIf                
                
            EndIf
        EndIf
    Next nX
EndIf

//->> Marcelo Celi - 04/03/2022
nVolTotal := Int(nVolume)
If nVolume > nVolTotal
    nVolTotal++
EndIf
nVolume := nVolTotal

nVolume := Round(nVolume,0)
nPesLiq := Round(nPesLiq,Tamsx3("C5_PESOL")[02])
nPesBru := Round(nPesBru,Tamsx3("C5_PBRUTO")[02])

M->C5_VOLUME1 := nVolume
M->C5_PESOL   := nPesLiq
M->C5_PBRUTO  := nPesBru

If cAcao == "G"
    xRet := &(cCpo)
Else
    xRet := .T.
EndIf

Return xRet

/*/{protheus.doc} BoBlqRegr
*******************************************************************************************
Verifica se ha a necessidade de bloquear o pedido de vendas em regras.
 
@author: Marcelo Celi Marques
@since: 04/01/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoBlqRegr()
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local lBlq      := .F.

If SC5->C5_TABELA <> Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+C5_LOJACLI,"A1_TABELA")
    lBlq := .T.
EndIf

SC6->(dbSetOrder(1))
SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
    If SC6->C6_PRCVEN <> SC6->C6_PRUNIT
        lBlq := .T.
        Exit
    EndIf
    SC6->(dbSkip())
EndDo


If lBlq
    Reclock("SC5",.F.)
    SC5->C5_BLQ := "1"
    SC5->(MsUnlock())
EndIf

RestArea(aArea)
SC5->(RestArea(aAreaSC5))
SC6->(RestArea(aAreaSC6))

Return

/*/{protheus.doc} AjustaSXB
*******************************************************************************************
Ajuste das consultas padrões de pedidos personalizadas
 
@author: Marcelo Celi Marques
@since: 06/01/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustaSXB()
Local aSXB 	  := {} 
Local i, j
Local aEstrut := {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	    ,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"		            }

//->> Consulta de Pedidos de Vendas Pendentes de Logistica
Aadd( aSXB,	{"SC5LOG"	,"1"		,"01"		,"DB"			    ,"Pedido de Venda p/ Logistica"	,"Pedido de Venda p/ Logistica"	,"Pedido de Venda p/ Logistica"	,"SC5"				            })
Aadd( aSXB,	{"SC5LOG"	,"2"		,"01"		,"01"			    ,"Numero"				   		,"Numero"				   		,"Numero"						,""	    			            })
Aadd( aSXB,	{"SC5LOG"	,"2"		,"02"		,"02"				,"Emissao + Numero"				,"Emissao + Numero"		   		,"Emissao + Numero"		   		,""	                            })	
Aadd( aSXB,	{"SC5LOG"	,"2"		,"03"		,"03"				,"Cod. Cliente + Numer"			,"Cod. Cliente + Numer"	   		,"Cod. Cliente + Numer"	   		,""	                            })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"01"		,"01"				,"Numero"						,"Numero"						,"Numero"				  		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"01"		,"02"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"01"		,"03"				,"Loja"	    					,"Loja"					   		,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"01"		,"04"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"02"		,"05"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"02"		,"06"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"02"		,"07"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"   	            })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"02"		,"08"				,"Loja"				    		,"Loja"						   	,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"03"		,"09"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"03"		,"10"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"       	            })	
Aadd( aSXB,	{"SC5LOG"	,"4"		,"03"		,"11"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5LOG"	,"5"		,"01"		,""				    ,""								,""						   		,""						   		,"SC5->C5_NUM"	                })	
Aadd( aSXB,	{"SC5LOG"	,"6"		,"01"		,""				    ,""								,""						   		,""			   		            ,"SC5->C5_XSTATUS=='4'.And.SC5->C5_XFLUXCF<>'N'"	})	

//->> Consulta de Pedidos de Vendas Pendentes de Expedição
Aadd( aSXB,	{"SC5EXP"	,"1"		,"01"		,"DB"			    ,"Pedido de Venda p/ Expedicao"	,"Pedido de Venda p/ Expedicao"	,"Pedido de Venda p/ Expedicao"	,"SC5"				            })
Aadd( aSXB,	{"SC5EXP"	,"2"		,"01"		,"01"			    ,"Numero"				   		,"Numero"				   		,"Numero"						,""	    			            })
Aadd( aSXB,	{"SC5EXP"	,"2"		,"02"		,"02"				,"Emissao + Numero"				,"Emissao + Numero"		   		,"Emissao + Numero"		   		,""	                            })	
Aadd( aSXB,	{"SC5EXP"	,"2"		,"03"		,"03"				,"Cod. Cliente + Numer"			,"Cod. Cliente + Numer"	   		,"Cod. Cliente + Numer"	   		,""	                            })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"01"		,"01"				,"Numero"						,"Numero"						,"Numero"				  		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"01"		,"02"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"01"		,"03"				,"Loja"	    					,"Loja"					   		,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"01"		,"04"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"02"		,"05"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"02"		,"06"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"02"		,"07"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"   	            })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"02"		,"08"				,"Loja"				    		,"Loja"						   	,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"03"		,"09"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"03"		,"10"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"       	            })	
Aadd( aSXB,	{"SC5EXP"	,"4"		,"03"		,"11"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5EXP"	,"5"		,"01"		,""				    ,""								,""						   		,""						   		,"SC5->C5_NUM"	                })	
Aadd( aSXB,	{"SC5EXP"	,"6"		,"01"		,""				    ,""								,""						   		,""			   		            ,"SC5->C5_XSTATUS=='6'.And.SC5->C5_XFLUXCF<>'N'" })	

//->> Consulta de Pedidos de Vendas Para Conferencia
Aadd( aSXB,	{"SC5CNF"	,"1"		,"01"		,"DB"			    ,"Pedido de Venda p/ Conferencia","Pedido de Venda p/ Conferencia","Pedido de Venda p/ Conferencia","SC5"				            })
Aadd( aSXB,	{"SC5CNF"	,"2"		,"01"		,"01"			    ,"Numero"				   		,"Numero"				   		,"Numero"						,""	    			            })
Aadd( aSXB,	{"SC5CNF"	,"2"		,"02"		,"02"				,"Emissao + Numero"				,"Emissao + Numero"		   		,"Emissao + Numero"		   		,""	                            })	
Aadd( aSXB,	{"SC5CNF"	,"2"		,"03"		,"03"				,"Cod. Cliente + Numer"			,"Cod. Cliente + Numer"	   		,"Cod. Cliente + Numer"	   		,""	                            })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"01"		,"01"				,"Numero"						,"Numero"						,"Numero"				  		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"01"		,"02"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"01"		,"03"				,"Loja"	    					,"Loja"					   		,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"01"		,"04"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"02"		,"05"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"02"		,"06"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"	                    })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"02"		,"07"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"   	            })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"02"		,"08"				,"Loja"				    		,"Loja"						   	,"Loja"					  		,"C5_LOJACLI"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"03"		,"09"				,"Cod. Cliente"					,"Cod. Cliente"			   		,"Cod. Cliente"			   		,"C5_CLIENTE"	                })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"03"		,"10"				,"Numero"						,"Numero"				   		,"Numero"				   		,"C5_NUM"       	            })	
Aadd( aSXB,	{"SC5CNF"	,"4"		,"03"		,"11"				,"Emissao"						,"Emissao"				   		,"Emissao"				   		,"C5_EMISSAO"	                })	
Aadd( aSXB,	{"SC5CNF"	,"5"		,"01"		,""				    ,""								,""						   		,""						   		,"SC5->C5_NUM"	                })	

SXB->(dbSetOrder(1))
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !SXB->(dbSeek(PadR(aSXB[i,1],Len(SXB->XB_ALIAS)) +;
						 PadR(aSXB[i,2],Len(SXB->XB_TIPO)) 	+;
						 PadR(aSXB[i,3],Len(SXB->XB_SEQ))	+;
						 PadR(aSXB[i,4],Len(SXB->XB_COLUNA)) ))

			RecLock("SXB",.T.)			
		Else
			RecLock("SXB",.F.)			
		EndIf
		For j:=1 To Len(aSXB[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()		
	EndIf
Next i

Return

/*/{protheus.doc} BoVldPrdPv
*******************************************************************************************
Valida a Digitação do Produto no pedido ou orçamento de vendas.
 
@author: Marcelo Celi Marques
@since: 12/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoVldPrdPv(cProduto,lMsg)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaDA1  := DA1->(GetArea())
Local cTabela   := ""
Local cCpo      := Upper(Alltrim(ReadVar()))

//->> Marcelo Celi - 22/01/2021
Local lTudoOk   := .F.

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 

Default lMsg := .T.

If Funname()=="MATA410"
    cTabela   := M->C5_TABELA
    If "C6_PRODUTO" $ cCpo
        Default cProduto := &(cCpo)
    Else
        Default cProduto := ""
    EndIf

    //->> Marcelo Celi - 22/01/2021
    If M->C5_TIPO == "D" .Or. M->C5_TIPO == "B"
        lTudoOk := .T.
    Else
        lTudoOk := .F.
    EndIf

ElseIf Funname()=="MATA415"
    cTabela   := M->CJ_TABELA
    If "CK_PRODUTO" $ cCpo
        Default cProduto := &(cCpo)
    Else
        Default cProduto := ""
    EndIf

    //->> Marcelo Celi - 06/01/2023
    If lUsaBkOrd
        lTudoOk := .T.
    Else
        lTudoOk := .F.
    EndIf

Else
    cProduto := ""
EndIf

If !lTudoOk //->> Marcelo Celi - 22/01/2021
    If !Empty(cProduto)
        DA1->(dbSetOrder(1))
        If DA1->(dbSeek(xFilial("DA1")+cTabela+cProduto))
            //->> Marcelo Celi - 20/07/2021
            If DA1->DA1_ATIVO == "1"            
                lRet := .T.
            Else
                lRet := .F.
                MsgAlert("Produto bloqueado para uso na tabela de preços..."+CRLF+"Corrija o problema para continuar...")
            EndIf
        Else
            lRet := .F.
            If lMsg
                MsgAlert("Produto não localizado na tabela de preços "+cTabela+CRLF+"O Produto não pode ser utilizado nessas condições."+CRLF+"Corrija o problema para continuar...")
            EndIf            
        EndIf
        DA1->(RestArea(aAreaDA1))
        RestArea(aArea)
    EndIf
Else
    lRet := .T.
EndIf

Return lRet

/*/{protheus.doc} BoAjPodFat
*******************************************************************************************
Ajusta Campo pode Faturar
 
@author: Marcelo Celi Marques
@since: 12/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoAjPodFat(cPedido)
Local cQry      := ""
Local nRetSql   := 0

Default cPedido := ""

If SC9->(FieldPos("C9_XPODFAT"))> 0 .And. SC5->(FieldPos("C5_XSTATUS"))>0
    //->> Ajusta os flags para limpar os itens que não serão exibidos para faturar
    cQry := "UPDATE"                                                              +CRLF
    cQry += RetSQLName("SC9")                                                     +CRLF
    cQry += " SET C9_XPODFAT = ' ' "                                              +CRLF
    cQry += " FROM " + RetSQLName("SC9") + " C9, " + RetSQLName("SC5") + " C5 "   +CRLF
    cQry += " WHERE C5.C5_FILIAL = '"+xFilial("SC5")+"'"                          +CRLF
    cQry += "     AND (C5_XSTATUS <= '4' AND C9_NFISCAL = ' ')"                   +CRLF
    cQry += "     AND C9.C9_FILIAL = C5.C5_FILIAL "                               +CRLF
    cQry += "     AND C9.C9_PEDIDO = C5.C5_NUM "                                  +CRLF
    cQry += "     AND C9.C9_XPODFAT <> 'S' "                                      +CRLF

    //->> Marcelo Celi - 14/01/2021
    If !Empty(cPedido)
        cQry += "     AND C5.C5_NUM <> '"+cPedido+"' "                            +CRLF
    EndIf

    cQry += "     AND C5.D_E_L_E_T_ = ' '"                                        +CRLF
    cQry += "     AND C9.D_E_L_E_T_ = ' '"                                        +CRLF
    nRetSql := TcSqlExec(cQry)

    //->> Ajusta os flags para permitir os itens que serão exibidos para faturar    
    cQry := "UPDATE"                                                              +CRLF
    cQry += RetSQLName("SC9")                                                     +CRLF
    cQry += " SET C9_XPODFAT = 'S' "                                              +CRLF
    cQry += " FROM " + RetSQLName("SC9") + " C9, " + RetSQLName("SC5") + " C5 "   +CRLF
    cQry += " WHERE C5.C5_FILIAL = '"+xFilial("SC5")+"'"                          +CRLF
    
    //->> Marcelo Celi - 14/01/2021
    If !Empty(cPedido)
        cQry += "     AND C5.C5_NUM <> '"+cPedido+"' "                            +CRLF
    EndIf

    //->> Marcelo Celi - 13/01/2021
    If SC5->(FieldPos("C5_XFLUXCF")) > 0
        cQry += "     AND ( (C5_XSTATUS >= '5' OR C9_NFISCAL <> ' ') OR (C5_XFLUXCF = 'N') )" +CRLF
    Else
        cQry += "     AND (C5_XSTATUS >= '5' OR C9_NFISCAL <> ' ')"              +CRLF
    EndIf
    
    cQry += "     AND C9.C9_FILIAL = C5.C5_FILIAL "                               +CRLF
    cQry += "     AND C9.C9_PEDIDO = C5.C5_NUM "                                  +CRLF
    cQry += "     AND C9.C9_XPODFAT <> 'S' "                                      +CRLF
    cQry += "     AND C5.D_E_L_E_T_ = ' '"                                        +CRLF
    cQry += "     AND C9.D_E_L_E_T_ = ' '"                                        +CRLF
    nRetSql := TcSqlExec(cQry)

    //->> Ajusta os flags para permitir os itens que serão exibidos para faturar    
    //->> Marcelo Celi - 21/01/2021
    cQry := "UPDATE"                                                              +CRLF
    cQry += RetSQLName("SC9")                                                     +CRLF
    cQry += " SET C9_XPODFAT = 'S' "                                              +CRLF
    cQry += " FROM " + RetSQLName("SC9") + " C9, " + RetSQLName("SC5") + " C5 "   +CRLF
    cQry += " WHERE C5.C5_FILIAL = '"+xFilial("SC5")+"'"                          +CRLF
    cQry += "     AND C5.C5_TIPO <> 'N' "                                         +CRLF    
    cQry += "     AND C9.C9_FILIAL = C5.C5_FILIAL "                               +CRLF
    cQry += "     AND C9.C9_PEDIDO = C5.C5_NUM "                                  +CRLF
    cQry += "     AND C9.C9_XPODFAT <> 'S' "                                      +CRLF
    cQry += "     AND C5.D_E_L_E_T_ = ' '"                                        +CRLF
    cQry += "     AND C9.D_E_L_E_T_ = ' '"                                        +CRLF
    nRetSql := TcSqlExec(cQry)

EndIf

Return

/*/{protheus.doc} BoLibPv
*******************************************************************************************
Libera o pedido de vendas
 
@author: Marcelo Celi Marques
@since: 25/01/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoLibPv(cPedido)
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aCabec    := {}
Local aItens    := {}
Local aItem     := {}

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cPedido))
    
    aAdd(aCabec,{"C5_FILIAL"   	,SC5->C5_FILIAL                            	,Nil}) 	//->> Filial
    aAdd(aCabec,{"C5_NUM"    	,SC5->C5_NUM                               	,Nil}) 	//->> Numero do Pedido
    aAdd(aCabec,{"C5_TIPO"  	,SC5->C5_TIPO                              	,Nil}) 	//->> Tipo de Pedido
    aAdd(aCabec,{"C5_CLIENTE"	,SC5->C5_CLIENTE                          	,Nil})	//->> Cliente de Faturamento
    aAdd(aCabec,{"C5_LOJACLI"	,SC5->C5_LOJACLI                           	,Nil})	//->> Loja de Faturamento                        
    aAdd(aCabec,{"C5_CLIENT"	,SC5->C5_CLIENT                            	,Nil})	//->> Cliente de Entrega
    aAdd(aCabec,{"C5_LOJAENT"	,SC5->C5_LOJAENT                           	,Nil})	//->> Loja de Entrega
    
    SC6->(dbSetOrder(1)) 
	SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
	Do While SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
        aItem := {}
        aAdd(aItem,{"C6_FILIAL" , SC6->C6_FILIAL   					    	,Nil}) // Filial
        aAdd(aItem,{"C6_NUM"    , SC6->C6_NUM   					    	,Nil}) // Numero do Pedido
        aAdd(aItem,{"C6_ITEM"   , SC6->C6_ITEM   					    	,Nil}) // Item
        aAdd(aItem,{"C6_PRODUTO", SC6->C6_PRODUTO 				      		,Nil}) // Produto
        aAdd(aItem,{"C6_QTDVEN ", SC6->C6_QTDVEN                            ,Nil}) // Quantidade Liberada
//      aAdd(aItem,{"C6_QTDLIB ", SC6->C6_QTDVEN                            ,Nil}) // Quantidade Liberada
        aAdd(aItem,{"C6_PRUNIT" , SC6->C6_PRUNIT   	                        ,Nil}) // Preco Unit.
        aAdd(aItem,{"C6_PRCVEN" , SC6->C6_PRCVEN   	                        ,Nil}) // Preco Unit.
        aAdd(aItem,{"C6_VALOR"  , SC6->C6_VALOR                             ,Nil}) // Valor Tot. 
        aAdd(aItem,{"C6_ENTREG" , SC6->C6_ENTREG     						,Nil}) // Dt.Entrega
        aAdd(aItem,{"C6_UM"     , SC6->C6_UM		  						,Nil}) // Unidade
        aAdd(aItem,{"C6_LOCAL"  , SC6->C6_LOCAL								,Nil}) // Almoxarifado
        aAdd(aItem,{"C6_TES" 	, SC6->C6_TES  								,Nil}) // Tipo de Saida

        //->> Marcelo Celi - 25/03/2021
        aAdd(aItem,{"C6_XVLDPTE" 	, SC6->C6_XVLDPTE  						,Nil}) // Vlc PTE
        aAdd(aItem,{"C6_XUMVEN" 	, SC6->C6_XUMVEN  						,Nil}) // U.M. Venda
    //  aAdd(aItem,{"C6_XQUMVEN" 	, SC6->C6_XQUMVEN  						,Nil}) // Valor Caixa
        aAdd(aItem,{"C6_XDTCONF" 	, SC6->C6_XDTCONF  						,Nil}) // Data Conf.
        aAdd(aItem,{"C6_XQTCONF" 	, SC6->C6_XQTCONF  						,Nil}) // Qtd Conferid
        aAdd(aItem,{"C6_XPRCBAS" 	, SC6->C6_XPRCBAS  						,Nil}) // Preço Base
        aAdd(aItem,{"C6_SEGUM" 	    , SC6->C6_SEGUM  						,Nil}) // Segunda UM
    //  aAdd(aItem,{"C6_UNSVEN" 	, SC6->C6_UNSVEN  						,Nil}) // Qtd Ven 2 UM
        aAdd(aItem,{"C6_DESCRI" 	, SC6->C6_DESCRI  						,Nil}) // Descricao
        aAdd(aItem,{"C6_FCICOD" 	, SC6->C6_FCICOD  						,Nil}) // FCI

        aAdd(aItens,aClone(aItem))
        SC6->(dbSkip())
    EndDo

    If Len(aCabec) > 0 .And. Len(aItens) > 0
        SC5->(dbSetOrder(1))
        SC6->(dbSetOrder(1))
        SA1->(dbSetOrder(1))

        Begin Transaction
            lMSErroAuto := .F.
            MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,4)
            If !lMSErroAuto
                If Funname() == "FATA210"
                    Reclock("SC5",.F.)
                    SC5->C5_BLQ := ""
                    SC5->(MsUnlock())
                EndIf
            EndIf
        End Transaction
    EndIf

EndIf

SA1->(RestArea(aAreaSA1))
SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return

/*/{protheus.doc} GetVlrPedid
*******************************************************************************************
Retorna o valor do pedido
 
@author: Marcelo Celi Marques
@since: 16/02/2021
@param: 
@return:
@type function: Statico
*******************************************************************************************
/*/
Static Function GetVlrPedid()
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local nValor    := 0

SC6->(dbSetOrder(1))
SC6->(dbSeek(SC5->(C5_FILIAL + C5_NUM)))
Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
    nValor += SC6->C6_VALOR
    SC6->(dbSkip())
EndDo

SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return nValor         

/*/{protheus.doc} BOCnfAgePv
*******************************************************************************************
Realiza a conferencia de agendamento do Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOCnfAgePv()
Local cMsg		    := ""
Local lOk           := .F.

AjustaSXB()

Private oWizard	    := NIL
Private _lEdita     := .F.

Private _cPedido    := Space(Tamsx3("C5_NUM")[01])
Private _oPedido    := NIL
Private _cCliente   := ""
Private _oCliente   := NIL
Private _cLoja      := ""
Private _oLoja      := NIL
Private _cNome      := ""
Private _oNome      := NIL
Private _dEmissao   := Stod("")
Private _oEmissao   := NIL

Private _dAgendam   := Stod("")
Private _oAgendam   := NIL
Private _cEndereco  := ""
Private _oEndereco  := NIL

cMsg := "Este Recurso Permite efetuar a Confirmação da Conferência de Agendamento do Pedido de Vendas, informando os dados necessários para continuar com o Faturamento."+CRLF
cMsg += CRLF
cMsg += CRLF
cMsg += "Avançar para Continuar..."

DEFINE WIZARD oWizard 												        ;
		TITLE "Pedidos de Vendas"									        ;
          	HEADER "Conferência de Agendamento"						        ;
          	MESSAGE ""												        ;
         	TEXT cMsg PANEL											        ;
          	NEXT 	{|| .T. } 										        ;
          	FINISH 	{|| .T. }										        ;
          	          	                            
   	CREATE PANEL oWizard 				 							        ;
          	HEADER "Conferência de Agendamento"				 		        ;
          	MESSAGE "Informe os Dados Necessários para a Conferência." PANEL;
          	NEXT 	{|| lOk:=LibCnfTudOk(),lOk }	                        ;
          	FINISH 	{|| lOk:=LibCnfTudOk(),lOk }	                        ;
          	PANEL

        @ 005,010 MSGet _oPedido Var _cPedido F3 "SC5CNF"  When .T.    SIZE  50,09     Picture PesqPict("SC5","C5_NUM")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoCnfVldPV()
        @ 016,010 Say SC5->(RetTitle("C5_NUM"))													  			                OF oWizard:GetPanel(2) PIXEL

        @ 005,070 MSGet _oEmissao Var _dEmissao 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_EMISSAO")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,070 Say SC5->(RetTitle("C5_EMISSAO"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,010 MSGet _oCliente Var _cCliente 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_CLIENTE")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,010 Say SC5->(RetTitle("C5_CLIENTE"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,070 MSGet _oLoja Var _cLoja 	             When .F.   SIZE  20,09     Picture PesqPict("SC5","C5_LOJACLI")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,070 Say SC5->(RetTitle("C5_LOJACLI"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,100 MSGet _oNome Var _cNome 	             When .F.   SIZE 180,09     Picture PesqPict("SA1","A1_NOME")       OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,100 Say SA1->(RetTitle("A1_NOME"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 065,010 MSGet _oAgendam Var _dAgendam           When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_XDAGEND")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoCnfVldPV()
        @ 076,010 Say SC5->(RetTitle("C5_XDAGEND"))													  			            OF oWizard:GetPanel(2) PIXEL
        
        @ 095,010 GET _oEndereco VAR _cEndereco MEMO NO VSCROLL WHEN .F. SIZE 275,25 OF oWizard:GetPanel(2) PIXEL

		oWizard:OFINISH:CCAPTION := "&Conferir"
		oWizard:OFINISH:CTITLE 	 := "&Conferir"			  	   		
			  	   		  	   
ACTIVATE WIZARD oWizard CENTERED

Return

/*/{protheus.doc} BoCnfVldPV
*******************************************************************************************
Efetua a validação do pedido de vendas na conferencia do agendamento
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoCnfVldPV()
Local xCpo      := ReadVar()
Local xConteudo := &(xCpo)
Local lRet      := .T.

If !Empty(xConteudo)
    If Upper("_cPedido") $ Upper(xCpo)
        _cEndereco := ""

        SC5->(dbSetOrder(1))
        If SC5->(dbSeek(xFilial("SC5")+xConteudo))
            _cEndereco := ""
            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
                _cEndereco := Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - "+Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)
            EndIf                
            
            _cCliente   := SC5->C5_CLIENTE
            _cLoja      := SC5->C5_LOJACLI
            _cNome      := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
            _dEmissao   := SC5->C5_EMISSAO
            _dAgendam   := SC5->C5_XDAGEND            
            lRet        := .T.
            _lEdita     := .T.
            _oAgendam:SetFocus()
            
        Else
            _cPedido    := Space(Tamsx3("C5_NUM")[01])
            _cCliente   := ""
            _cLoja      := ""
            _cNome      := ""
            _dEmissao   := Stod("")
            _dAgendam   := Stod("")            
            lRet        := .F.
            _lEdita     := .F.
            MsgAlert("Pedido de Vendas não Localizado...")
        EndIf
    
    ElseIf Upper("_dAgendam") $ Upper(xCpo)        
        If !Empty(xConteudo)
            If xConteudo >= dDatabase
                lRet := .T.
            Else
                lRet := .F.
            MsgAlert("Favor informar uma Data de Agendamento Superior ou Igual a Database do Sistema...")
            EndIf    
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data da Agendamento válida...")
        EndIf
    
    EndIf

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oAgendam:Refresh()
    _oEndereco:Refresh()

EndIf

Return lRet

/*/{protheus.doc} LibCnfTudOk
*******************************************************************************************
Verifica se esta tudo ok nos campos da validação da conferencia
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LibCnfTudOk()
Local lRet := .F.

If !Empty(_cCliente)
    lRet := .T.

    If lRet
        If _dAgendam >= dDatabase
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data de Agendamento Superior ou Igual a Database do Sistema...")
        EndIf
    EndIf

Else
    lRet := .F.
    MsgAlert("Informe um Pedido de Vendas para Conferir...")
EndIf

If lRet
    lRet := MsgYesNo("Confirma a Conferência do Agendamento ?")
EndIf

If lRet
    LiberConfAg()

    _cPedido    := Space(Tamsx3("C5_NUM")[01])
    _cCliente   := ""
    _cLoja      := ""
    _cNome      := ""
    _dEmissao   := Stod("")
    _dAgendam   := Stod("")    
    _cEndereco  := ""

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oAgendam:Refresh()    
    _oEndereco:Refresh()

    _oPedido:SetFocus()

    lRet := .F.

EndIf

Return lRet

/*/{protheus.doc} LiberConfAg
*******************************************************************************************
Grava a Conferencia
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LiberConfAg()

Reclock("SC5",.F.)
If SC5->(FieldPos("C5_XDAGEND")) > 0
    SC5->C5_XDAGEND := _dAgendam
EndIf
SC5->(MsUnlock())

Return

/*/{protheus.doc} BOCnfEntPv
*******************************************************************************************
Realiza a conferencia de data de entrega do Pedido de Vendas.
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BOCnfEntPv()
Local cMsg		    := ""
Local lOk           := .F.

AjustaSXB()

Private oWizard	    := NIL
Private _lEdita     := .F.

Private _cPedido    := Space(Tamsx3("C5_NUM")[01])
Private _oPedido    := NIL
Private _cCliente   := ""
Private _oCliente   := NIL
Private _cLoja      := ""
Private _oLoja      := NIL
Private _cNome      := ""
Private _oNome      := NIL
Private _dEmissao   := Stod("")
Private _oEmissao   := NIL

Private _dEntrega   := Stod("")
Private _oEntrega   := NIL
Private _cEndereco  := ""
Private _oEndereco  := NIL

cMsg := "Este Recurso Permite efetuar a Confirmação da Conferência de Data de Entrega do Pedido de Vendas, informando os dados necessários para continuar com o Faturamento."+CRLF
cMsg += CRLF
cMsg += CRLF
cMsg += "Avançar para Continuar..."

DEFINE WIZARD oWizard 												        ;
		TITLE "Pedidos de Vendas"									        ;
          	HEADER "Conferência de Entrega"	    					        ;
          	MESSAGE ""												        ;
         	TEXT cMsg PANEL											        ;
          	NEXT 	{|| .T. } 										        ;
          	FINISH 	{|| .T. }										        ;
          	          	                            
   	CREATE PANEL oWizard 				 							        ;
          	HEADER "Conferência de Entrega"	    			 		        ;
          	MESSAGE "Informe os Dados Necessários para a Conferência." PANEL;
          	NEXT 	{|| lOk:=LibEntTudOk(),lOk }	                        ;
          	FINISH 	{|| lOk:=LibEntTudOk(),lOk }	                        ;
          	PANEL

        @ 005,010 MSGet _oPedido Var _cPedido F3 "SC5CNF"  When .T.    SIZE  50,09     Picture PesqPict("SC5","C5_NUM")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoEntVldPV()
        @ 016,010 Say SC5->(RetTitle("C5_NUM"))													  			                OF oWizard:GetPanel(2) PIXEL

        @ 005,070 MSGet _oEmissao Var _dEmissao 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_EMISSAO")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 016,070 Say SC5->(RetTitle("C5_EMISSAO"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,010 MSGet _oCliente Var _cCliente 	    When .F.    SIZE  50,09     Picture PesqPict("SC5","C5_CLIENTE")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,010 Say SC5->(RetTitle("C5_CLIENTE"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,070 MSGet _oLoja Var _cLoja 	             When .F.   SIZE  20,09     Picture PesqPict("SC5","C5_LOJACLI")    OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,070 Say SC5->(RetTitle("C5_LOJACLI"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 028,100 MSGet _oNome Var _cNome 	             When .F.   SIZE 180,09     Picture PesqPict("SA1","A1_NOME")       OF oWizard:GetPanel(2) PIXEL Hasbutton
        @ 039,100 Say SA1->(RetTitle("A1_NOME"))													  			            OF oWizard:GetPanel(2) PIXEL

        @ 065,010 MSGet _oEntrega Var _dEntrega           When _lEdita SIZE  50,09   Picture PesqPict("SC5","C5_XREAENT")     OF oWizard:GetPanel(2) PIXEL Hasbutton Valid u_BoEntVldPV()
        @ 076,010 Say SC5->(RetTitle("C5_XREAENT"))													  			            OF oWizard:GetPanel(2) PIXEL
        
        @ 095,010 GET _oEndereco VAR _cEndereco MEMO NO VSCROLL WHEN .F. SIZE 275,25 OF oWizard:GetPanel(2) PIXEL

		oWizard:OFINISH:CCAPTION := "&Conferir"
		oWizard:OFINISH:CTITLE 	 := "&Conferir"			  	   		
			  	   		  	   
ACTIVATE WIZARD oWizard CENTERED

Return

/*/{protheus.doc} BoEntVldPV
*******************************************************************************************
Efetua a validação do pedido de vendas na conferencia da data de entrega
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoEntVldPV()
Local xCpo      := ReadVar()
Local xConteudo := &(xCpo)
Local lRet      := .T.

If !Empty(xConteudo)
    If Upper("_cPedido") $ Upper(xCpo)
        _cEndereco := ""

        SC5->(dbSetOrder(1))
        If SC5->(dbSeek(xFilial("SC5")+xConteudo))
            _cEndereco := ""
            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
                _cEndereco := Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - "+Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)
            EndIf                
            
            _cCliente   := SC5->C5_CLIENTE
            _cLoja      := SC5->C5_LOJACLI
            _cNome      := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
            _dEmissao   := SC5->C5_EMISSAO
            _dEntrega   := SC5->C5_XREAENT            
            lRet        := .T.
            _lEdita     := .T.
            _oEntrega:SetFocus()
            
        Else
            _cPedido    := Space(Tamsx3("C5_NUM")[01])
            _cCliente   := ""
            _cLoja      := ""
            _cNome      := ""
            _dEmissao   := Stod("")
            _dEntrega   := Stod("")            
            lRet        := .F.
            _lEdita     := .F.
            MsgAlert("Pedido de Vendas não Localizado...")
        EndIf
    
    ElseIf Upper("_dEntrega") $ Upper(xCpo)        
        If !Empty(xConteudo)
            If xConteudo >= dDatabase
                lRet := .T.
            Else
                lRet := .F.
            MsgAlert("Favor informar uma Data de Entrega Superior ou Igual a Database do Sistema...")
            EndIf    
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data da Entrega válida...")
        EndIf
    
    EndIf

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oEntrega:Refresh()
    _oEndereco:Refresh()

EndIf

Return lRet

/*/{protheus.doc} LibEntTudOk
*******************************************************************************************
Verifica se esta tudo ok nos campos da validação da data de entrega real
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LibEntTudOk()
Local lRet := .F.

If !Empty(_cCliente)
    lRet := .T.

    If lRet
        If _dEntrega >= dDatabase
            lRet := .T.
        Else
            lRet := .F.
            MsgAlert("Favor informar uma Data de Entrega Real Superior ou Igual a Database do Sistema...")
        EndIf
    EndIf

Else
    lRet := .F.
    MsgAlert("Informe um Pedido de Vendas para Conferir...")
EndIf

If lRet
    lRet := MsgYesNo("Confirma a Conferência da Data de Entrega Real ?")
EndIf

If lRet
    LiberEntRea()

    _cPedido    := Space(Tamsx3("C5_NUM")[01])
    _cCliente   := ""
    _cLoja      := ""
    _cNome      := ""
    _dEmissao   := Stod("")
    _dEntrega   := Stod("")    
    _cEndereco  := ""

    _oPedido:Refresh()
    _oCliente:Refresh()
    _oLoja:Refresh()
    _oNome:Refresh()
    _oEmissao:Refresh()
    _oEntrega:Refresh()    
    _oEndereco:Refresh()

    _oPedido:SetFocus()

    lRet := .F.

EndIf

Return lRet

/*/{protheus.doc} LiberEntRea
*******************************************************************************************
Grava a Conferencia
 
@author: Marcelo Celi Marques
@since: 20/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LiberEntRea()

Reclock("SC5",.F.)
If SC5->(FieldPos("C5_XREAENT")) > 0
    SC5->C5_XREAENT := _dEntrega
EndIf
SC5->(MsUnlock())

Return
