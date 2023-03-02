#INCLUDE "TOTVS.CH"    
#INCLUDE "apwizard.ch"

/*/{protheus.doc} MaImporLCr
*******************************************************************************************
Importação dos SKUs
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaImporLCr()

RPCClearEnv()
RPCSetType(3)
RPCSetEnv("01","0101")

SetFlatControls(.F.)
MsApp():New('SIGAMDI')
InitPublic()
SetSkinDefault()

oApp:cInternet  := "MaImporLCr"

__cInterNet := "MaImporLCr"
SetFunName( "u_MaImporLCr" )
Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

//->> Permite exibir as mensagens em tela mesmo chamando como se fosse job
lMsHelpAuto := .F.
MaImporLCr()

Return

Static Function MaImporLCr()
Local oWizard   := NIL
Local oPanSup   := NIL
Local oPanInf   := NIL
Local cMensagem := "Este programa realiza a leitura do Arquivo Excel *.CSV e efetua a importação dos Limites de Crédito dos Clientes."
Local cMsgPerg  := "Confirma o Processamento do Arquivo Selecionado no ambiente "+GetEnvServer()+" ?"
Local lOk       := .F.
Local cLogotipo := "finimg32.png"
Local aCoord    := {0,0,400,660}
Local oButtPesq := NIL
Local oFonte1   := TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)
Local oFonte2   := TFont():New("Verdana",,011,,.T.,,,,,.F.,.F.)

Private oPasta      := NIL
Private cPasta      := Space(100)
Private oArquivo    := NIL
Private cArquivo    := Space(100)
Private oExtensao   := NIL
Private cExtensao   := "csv"

oWizard := APWizard():New("Importação de Limites de Credito, Ambiente: "+GetEnvServer(),          				 ;   // chTitle  - Titulo do cabecalho
                            cMensagem, 	                                                           			     ;   // chMsg    - Mensagem do cabecalho
                            "Limites de Crédito de Clientes",                                  	                 ;   // cTitle   - Titulo do painel de apresentacao
                            "",             													         	     ;   // cText    - Texto do painel de apresentacao
                            {|| lOk := ValidaPasta(cPasta,cArquivo,cExtensao,2) .And. MsgYesNo(cMsgPerg) ,lOk }, ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| lOk := ValidaPasta(cPasta,cArquivo,cExtensao,2) .And. MsgYesNo(cMsgPerg) ,lOk }, ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            cLogotipo,        	   												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                            {|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                            .F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                            aCoord 		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

//->> Painel Superior dos Parâmetros
oPanSup := TPanel():New(0,0,'',oWizard:GetPanel(1),oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2)-55,.F.,.T. )
oPanSup:Align := CONTROL_ALIGN_TOP

oScroll := TScrollArea():New(oPanSup,01,01,((oPanSup:NCLIENTHEIGHT/2)-2),((oPanSup:NCLIENTWIDTH/2)-2))
oScroll:Align := CONTROL_ALIGN_ALLCLIENT    

//->> Painel Inferior dos controles de arquivo
oPanInf := TPanel():New(2,2,'',oWizard:GetPanel(1),oWizard:GetPanel(1):oFont, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),(55),.T.,.F. )
oPanInf:Align := CONTROL_ALIGN_BOTTOM

oPasta := TGet():New(05,05,{| u | If( PCount() == 0, cPasta, cPasta := u ) },/*oDlg*/ oPanInf ,300,12,"@!",,0,,oFonte1,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cPasta",,,, /*lHasbutton*/ .T.)
TSay():New(20,05,{|| "Pasta" } ,oPanInf,,oFonte2,,,,.T.,Rgb(000,000,000),CLR_WHITE,200,22)

oArquivo := TGet():New(28,05,{| u | If( PCount() == 0, cArquivo, cArquivo := u ) },/*oDlg*/ oPanInf ,285,12,"@!",{|| ArqInfValid() },0,,oFonte1,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cArquivo",,,, /*lHasbutton*/ .T.)
TSay():New(43,05,{|| "Arquivo" } ,oPanInf,,oFonte2,,,,.T.,Rgb(000,000,000),CLR_WHITE,200,22)    

oExtensao := TGet():New(28,295,{| u | If( PCount() == 0, cExtensao, cExtensao := u ) },/*oDlg*/ oPanInf ,20,12,"@!",,0,,oFonte1,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cExtensao",,,, /*lHasbutton*/ .T.)
TSay():New(43,295,{|| "Extensão" } ,oPanInf,,oFonte2,,,,.T.,Rgb(000,000,000),CLR_WHITE,200,22)    

oButtPesq := TButton():New(04,305,"",oPanInf,{|| GetArquivo() },16,16,,,.F.,.T.,.F.,,.F.,,,.F. )
oButtPesq:SetCss(getStyloBot(2,"lupa.png")) 

oWizard:OFINISH:CTITLE 	 := "&Importar"

//->> Ativacao do Painel
oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                    {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                    {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

If lOK    
    Private lMsHelpAuto := .F.
    MsgRun("Processando Importação de Limites de Crédito...",,{ || ProcImport() })
EndIf

Return

/*/{protheus.doc} ProcImport
*******************************************************************************************
Realiza o Processamento dos movimentos
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcImport()
Local cLinha    := ""
Local aArea     := GetArea()
Local cArqMov   := Alltrim(cPasta)+Alltrim(cArquivo)+"."+Alltrim(cExtensao)
Local aDados    := {}
Local cErro     := ""
Local cArqErro  := ""
Local cArqLog   := "log_erro-"+dTos(Date())+StrTran(Time(),":","")+".txt"
Local cArqErrLg := "log_erro-"+dTos(Date())+StrTran(Time(),":","")+".csv"
Local cLogErro  := ""
Local nValor    := 0
Local dLC       := Stod("")

SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt+cFilAnt))

Ft_fuse(cArqMov)
Ft_FGoTop()
While !ft_fEof()			
	cLinha := ft_fReadln()
    aDados := Separa(cLinha,";")
    cErro  := ""
    
    If "CLIENTE"$Upper(cLinha) .And. "LOJA"$Upper(cLinha) 
        cArqErro += cLinha+CRLF
    Else
        If !Empty(aDados[1])
            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+PadR(aDados[1],Tamsx3("A1_COD")[01])+PadR(aDados[2],Tamsx3("A1_LOJA")[01]) ))
                //->> Valor do Limite de Credito
                nValor := aDados[3]
                nValor := StrTran(nValor,".","")
                nValor := StrTran(nValor,",",".")
                nValor := Val(nValor)
                //->> Data de Vencimento do Limite de Credito
                dLC    := cTod(aDados[4])
                //->> Gravação dos dados
                RecLock("SA1",.F.)
                SA1->A1_LC      := nValor 
                SA1->A1_VENCLC  := dLC                    
                SA1->(MsUnlock())
            Else
                cErro := "Cliente não informado na planilha."
            EndIf            
        Else
            cErro := "Cliente não localizado no ERP."
        EndIf       

        If !Empty(cErro)
            cArqErro += cLinha+CRLF
            cLogErro += cLinha+CRLF+cErro+CRLF+Replicate("=",100)+CRLF+CRLF
        EndIf
    EndIf

    Ft_fSkip()
EndDo

If !Empty(cLogErro)
    MemoWrite(Alltrim(cPasta)+cArqLog,cLogErro)
EndIf

If !Empty(cArqErro)
    MemoWrite(Alltrim(cPasta)+cArqErrLg,cArqErro)
EndIf

lMsHelpAuto := .F.
MsgAlert("Importação Concluída...")

RestArea(aArea)

Return

/*/{protheus.doc} ValidaPasta
*******************************************************************************************
Função para Validação da Pasta
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ValidaPasta(cPasta,cArquivo,cExtensao,nTipo)
Local lRet      := .T.
Local cDestino  := ""
Local cArqTeste := ""
Local nHdl 		:= 0

If nTipo == 1    
    cDestino := Alltrim(cPasta)
    If Empty(cDestino)
        lRet := .F.
        MsgAlert("Favor informar uma pasta válida para a gravação do Arquivo de Logs.")
    Else
        cArqTeste := Criatrab(,.F.)+".Tst"
        cDestino += If(Right(cDestino,1)=="\","","\")+cArqTeste

        nHdl := fCreate(cDestino)
        If nHdl <= 0     
            lRet := .F.
            MsgAlert("Pasta Inacessível para a Gravação do Arquivo...")            
        Else
            fClose(nHdl)
            FErase(cDestino)
        EndIf
    EndIf
Else
    cDestino := Alltrim(cPasta)    
    If Empty(cDestino)
        lRet := .F.
        MsgAlert("Favor informar um arquivo válido para a leitura dos limites de crédito.")
    Else
        cDestino += If(Right(cDestino,1)=="\","","\")+Alltrim(cArquivo)+"."+Alltrim(cExtensao)
        If !File(cDestino)
            lRet := .F.
            MsgAlert("Arquivo de importação inexistente...")
        EndIf
    EndIf
EndIf

Return lRet

/*/{protheus.doc} getStyloBot
*******************************************************************************************
Retorna o estilo do botão
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function getStyloBot(nStylo,cImagem)
Local cEstilo := ""

Default cImagem := ""

Do Case
	Case nStylo == 1
		//A classe QPushButton, ela é responsável em criar a formatação do botão. 
	    cEstilo := "QPushButton {"  
	    //Usando a propriedade background-image, inserimos a imagem que será utilizada, a imagem pode ser pega pelo repositório (RPO)
	    cEstilo += " background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;" 
	    cEstilo += " border-style: outset;"
	    cEstilo += " border-width: 2px;"
	    cEstilo += " border: 1px solid #C0C0C0;"
	    cEstilo += " border-radius: 5px;"
	    cEstilo += " border-color: #C0C0C0;"
	    cEstilo += " font: bold 12px Arial;"
	    cEstilo += " padding: 6px;"
	    cEstilo += "}"
	 
	    //Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botão ele muda
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
	
	OtherWise
	    cEstilo := "QPushButton {background-image: url(rpo:"+cImagem+");background-repeat: none; margin: 2px;}"
    
EndCase

Return cEstilo

/*/{protheus.doc} GetPasta
*******************************************************************************************
Retorna a pasta de origem ou destino da gravação/leitura
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function GetPasta()
Local cOrigem := ""

cOrigem := Alltrim( cGetFile("Diretorios", "Diretorio Destino da Exportação",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
If !Empty(cOrigem)    
    cPasta   := cOrigem    
EndIf
cPasta   := Left(cPasta+Space(100),100)

Return

/*/{protheus.doc} GetArquivo
*******************************************************************************************
Retorna o arquivo de origem da leitura
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function GetArquivo()
Local cOrigem := ""
Local aFiles  := {}
Local nPos    := 0
Local cArqTmp := ""

cOrigem := cGetFile("Arquivo (*.CSV) | *.CSV","Selecione o Arquivo que será usado na Importação LC",0,Alltrim(cPasta),.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.)
If !Empty(cOrigem)
    aFiles := Directory(cOrigem)
    nPos := at(Upper(afiles[1,1]),Upper(cOrigem))
    If nPos > 0
        cPasta  := Alltrim(Upper(Left(cOrigem,nPos-1)))
        cArqTmp := Alltrim(Upper(afiles[1,1]))
        
        nPos := at(".",Upper(cArqTmp))
        If nPos > 0
            cExtensao := Alltrim(Upper(Right(cArqTmp,Len(cArqTmp)-nPos)))
            cArquivo  := Alltrim(Upper(Left(cArqTmp,nPos-1)))
        Else
            cExtensao := ""
            cArquivo  := cArqTmp
        EndIf
    EndIf
EndIf

cPasta   := Left(cPasta+Space(100),100)
cArquivo := Left(cArquivo+Space(100),100)

Return

/*/{protheus.doc} ArqInfValid
*******************************************************************************************
Retorna a validação da digitação do nome do arquivo
 
@author: Marcelo Celi Marques
@since: 28/12/2022
@param: 
@return:
@type function: Estático
*******************************************************************************************
/*/
Static Function ArqInfValid()
Local cArqInform := &(Readvar())
Local aCaracsNo  := {}
Local lRet       := .T.
Local nX         := 1

aAdd(aCaracsNo,'"')
aAdd(aCaracsNo,"'")
aAdd(aCaracsNo,"!")
aAdd(aCaracsNo,"@")
aAdd(aCaracsNo,"#")
aAdd(aCaracsNo,"$")
aAdd(aCaracsNo,"%")
aAdd(aCaracsNo,"¨")
aAdd(aCaracsNo,"&")
aAdd(aCaracsNo,"*")
aAdd(aCaracsNo,"(")
aAdd(aCaracsNo,")")
aAdd(aCaracsNo,"+")
aAdd(aCaracsNo,"=")
aAdd(aCaracsNo,"´")
aAdd(aCaracsNo,"`")
aAdd(aCaracsNo,"{")
aAdd(aCaracsNo,"}")
aAdd(aCaracsNo,"[")
aAdd(aCaracsNo,"]")
aAdd(aCaracsNo,"^")
aAdd(aCaracsNo,"~")
aAdd(aCaracsNo,"<")
aAdd(aCaracsNo,">")
aAdd(aCaracsNo,",")
aAdd(aCaracsNo,".")
aAdd(aCaracsNo,":")
aAdd(aCaracsNo,";")
aAdd(aCaracsNo,"?")
aAdd(aCaracsNo,"/")
aAdd(aCaracsNo,"\")
aAdd(aCaracsNo,"|")

For nX:=1 to Len(aCaracsNo)
    If At(aCaracsNo[nX],AllTrim(cArqInform)) > 0
        lRet := .F.
        MsgStop("Caracter "+aCaracsNo[nX]+" não é permitido no nome do arquivo.")
        Exit
    EndIf
Next nX

Return lRet
