#Include "Protheus.ch"  
#Include "Totvs.ch"
#INCLUDE "ApWizard.ch"

/*/{protheus.doc} BoPrc2Exce
*******************************************************************************************
Extra��o de dados de forma��o de pre�o e grava��o em excel.
 
@author: Marcelo Celi Marques
@since: 09/03/2021
@param: 
@return:
@type function: Usuário
*******************************************************************************************
/*/
User Function BoPrc2Exce(aProdutos)
Local oWizard	    := NIL
Local cMsgInic	    := ""
Local cTitInic      := ""
Local cTitApres     := ""
Local cTextApres    := ""
Local cLogotipo     := "WIZARD"
Local aCoords       := {}
Local cTitPan2      := ""
Local cMsgPan2      := ""
Local aSize	   		:= MsAdvSize()
Local aParambox     := {}  

Private aRetParam 	:= {}

//->> Ajuste da Consulta Padrao
AjustaSXB()

aRetParam := {Space(200),.T.}

aAdd(aParambox,{1,"Pasta Gravacao"				            ,aRetParam[01],"@!","","VYPST",".T.",300,.T.})
aAdd(aParambox,{5,"Abrir Excel ao Termino do Processamento" ,aRetParam[02],150,".T.",.F.})

aCoords       := {0,0,(aSize[6] := aSize[6] - aSize[2] - aSize[8] - 5),(aSize[5])}

cTitInic    := "Forma��o de Pre�os"
cMsgInic    := "Vendas"
cTitApres   := "EXPORTA��O PARA EXCEL"
cTextApres  := "Este recurso permite exportar para uma planilha Excel os dados da forma��o de pre�os."

oWizard := APWizard():New(  cTitInic,                   ;   // chTitle  - Titulo do cabeçalho
                            cMsgInic,                   ;   // chMsg    - Mensagem do cabeçalho
                            cTitApres,                  ;   // cTitle   - Título do painel de apresentação
                            cTextApres,                 ;   // cText    - Texto do painel de apresentação
                            {|| .T. },                  ;   // bNext    - Bloco de código a ser executado para validar o botão "Avançar"
                            {|| .T. },                   ;   // bFinish  - Bloco de código a ser executado para validar o botão "Finalizar"
                            .T.,                        ;   // lPanel   - Se .T. será criado um painel, se .F. será criado um scrollbox
                            cLogotipo,                  ;   // cResHead - Nome da imagem usada no cabeçalho, essa tem que fazer parte do repositório 
                            {|| },                      ;   // bExecute - Bloco de código contendo a ação a ser executada no clique dos botões "Avançar" e "Voltar"
                            .F.,                        ;   // lNoFirst - Se .T. não exibe o painel de apresentação
                            aCoords                     )   // aCoord   - Array contendo as coordenadas da tela

cTitPan2    := "Parametros"
cMsgPan2    := "Informe os parametros para a extracao do relatorio"

oWizard:NewPanel(   cTitPan2,                                               ;   // cTitle   - Título do painel 
                    cMsgPan2,                                               ;   // cMsg     - Mensagem posicionada no cabeçalho do painel
                    {|| .T. },                                              ;   // bBack    - Bloco de código utilizado para validar o botão "Voltar"
                    {|| ProcRelato(aProdutos) },                            ;   // bNext    - Bloco de código utilizado para validar o botão "Avançar"
                    {|| ProcRelato(aProdutos) },                            ;   // bFinish  - Bloco de código utilizado para validar o botão "Finalizar"
                    .T.,                                                    ;   // lPanel   - Se .T. será criado um painel, se .F. será criado um scrollbox
                    {|| .T. }                                               )   // bExecute - Bloco de código a ser executado quando o painel for selecionado

Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)

oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o diálogo será centralizado na tela
                    {|| .T. },  ;   // bValid   - Bloco de código a ser executado no encerramento do diálogo
                    {|| .T. },  ;   // bInit    - Bloco de código a ser executado na inicialização do diálogo
                    {|| .T. }   )   // bWhen    - Bloco de código para habilitar a execução do diálogo

Return

/*/{protheus.doc} AjustaSXB
*******************************************************************************************
Ajusta Consulta Padrao de Pasta.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustaSXB()
Local aSXB		:= {}  
Local aEstrut	:= {}
Local i, j
Local aArea		:= GetArea()     

aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"		}
Aadd( aSXB,	{"VYPST"	,"1"		,"01"		,"RE"			,"Pasta Gravação da Planilha"	,"Pasta Gravação da Planilha"	,"Pasta Gravação da Planilha"	,"SA3"				})
Aadd( aSXB,	{"VYPST"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."				})
Aadd( aSXB,	{"VYPST"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_BoGetPPSG()"	})	

For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS))+PadR(aSXB[i,2],Len(SXB->XB_TIPO))+PadR(aSXB[i,3],Len(SXB->XB_SEQ))+PadR(aSXB[i,4],Len(SXB->XB_COLUNA)))
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

RestArea(aArea)

Return

/*/{protheus.doc} BoGetPPSG
*******************************************************************************************
Retorna a Pasta.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoGetPPSG()
Local cPasta 	:= ""

cPasta := Alltrim( cGetFile("Diretorios", "Diretorio para a Gravação da Planilha",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
aRetParam[01]  := cPasta

Return

/*/{protheus.doc} ConfProcess
*******************************************************************************************
Confirma a Geracao do Relatorio
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConfProcess()
Local lRet 	 := .T.
Local nHdl	 := 0
Local cPasta := Alltrim(aRetParam[01])
Local cPath	 := ""
Local nX     := 0
Local nMes   := 0

If lRet
    If Empty(cPasta)
        MsgAlert("A Pasta destino para a gravacao da Planilha Eletronica nao e valida ou voce nao tem permissao para gravar nesse local."+CRLF+"Selecione uma Pasta valida para continuar.")	
        lRet := .F.
    Else
        cPasta += If(Right(cPasta,1)=="\","","\")
        cPath := cPasta+"Teste_"+Criatrab(,.F.)+".Tst"
        
        nHdl := fCreate(cPath)
        If nHdl <= 0     
            MsgAlert("A Pasta destino para a gravacao da Planilha Eletronica nao e valida ou voce nao tem permissao para gravar nesse local."+CRLF+"Selecione uma Pasta valida para continuar.")	
            lRet := .F.
        Else
            fClose(nHdl)
            FErase(cPath)
        EndIf
    EndIf
        
    If lRet	
        lRet := MsgYesNo("Confirma a Geracao da Planilha Eletronica?")
    EndIf
EndIf

Return lRet

/*/{protheus.doc} ProcRelato
*******************************************************************************************
Processamento do Relatorio
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcRelato(aProdutos)
Local   lRet        := .F.
Local   nX          := 1
Local _ItensFatur   := {}
Local aRecSub       := {}
Local dEmisDe       := Stod("")
Local dEmisAte      := Stod("")
Local dVencDe       := Stod("")
Local dVencAte      := Stod("")

Private oProcess    := NIL

lRet := ConfProcess()
If lRet
    oProcess := MsNewProcess():New( {|lEnd| lRet := CriaRelato(aProdutos)}, 'Aguarde...', 'Extraindo Dados para o Excel...', .F. )
    oProcess:Activate()    
EndIf

Return lRet

/*/{protheus.doc} CriaRelato
*******************************************************************************************
criação do Relatorio
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CriaRelato(aProdutos)
Local lRet          := .F.
Local aPlanilha     := {}
Local cArquivo      := ""
Local cPasta	    := ""
Local oExcel        := NIL

oProcess:SetRegua1(0)
oProcess:SetRegua2(0)
oProcess:IncRegua1('Extraindo Relatorio')
oProcess:IncRegua2('')

aPlanilha := {}
aAdd(aPlanilha,GetPlanilha(aProdutos))
    
If Len(aPlanilha)>0
    cArquivo := "BOMBAY_"+Dtos(Date())+StrTran(Time(),":","")
    cPasta	 := Alltrim(aRetParam[01])
    cPasta   += If(Right(cPasta,1)=="\","","\")

    oExcel := VyRelgrf():New(aPlanilha,cPasta,@cArquivo)
    oExcel:WriteHtml()
    cArquivo := oExcel:cArquivo

    FreeObj(oExcel)
    oExcel := NIL	
    If aRetParam[02]
        If ! ApOleClient( 'MsExcel' ) 
            If MsgYesNo("Microsoft Excel nao instalado na maquina."+CRLF+"Deseja abrir o relatorio no programa vinculado ao seu estilo?")
                ShellExecute("open",cPasta+cArquivo+".xml","","",5)
            EndIf	
        Else
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open(cPasta+cArquivo+".xml")
            oExcelApp:Run("Main")
            oExcelApp:SetVisible(.T.)
            oExcelApp:Destroy()
            oExcelApp:= Nil     		
        EndIf
    EndIf    
    lRet := .T.	
Else
    lRet := .F.
EndIf

Return lRet

/*/{protheus.doc} GetPlanilha
*******************************************************************************************
Retorna a planilha
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPlanilha(aProdutos)
Local aCols		:= {}
Local aHeader   := {}
Local aCabec	:= {}
Local aRodape	:= {}
Local aDados	:= {}
Local nX		:= 1
Local aPlanilha := {}
Local nPosPlan	:= 0
Local cRefer    := ""
Local cExtracao := "EXTRACAO: " + Dtoc(Date())+" as "+Time() +"  -  Ambiente: "+GetEnvServer()

aAdd(aPlanilha,{"Formacao de Precos",{},{ {"FORMACAO DE PRECOS","s01"},{cRefer,"s13"},{cExtracao,"s13"} }})
nPosPlan := Len(aPlanilha)

aCols  := {}
aHeader:= GetaHeader(@aCabec,@aRodape,aProdutos)
aDados := GetaCols(aProdutos)
For nX:=1 to Len(aDados)
    aAdd(aCols,aDados[nX])
Next nX	
aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

Return aPlanilha

/*/{protheus.doc} GetaHeader
*******************************************************************************************
Criacao do aHeader.
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaHeader(aCabec,aRodape,aProdutos)
Local aHeader 	:= {}

aCabec := {}
aRodape:= {}

aAdd(aHeader,{ "Produto"                ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",090,"C",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Descricao do Produto"   ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",200,"C",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Tipo"                   ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",040,"C",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Codigo da Tabela"       ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"C",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Descricao da Tabela"    ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",200,"C",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Qtde Ult Mes"           ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Preco de Venda"         ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Simulacao - R$"         ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "% CMV"                  ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "% Comiss Vda"           ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "% Logistica"            ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "% Impostos"             ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "% Desconto"             ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Margem Contrib"         ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",100,"N",'"s02"',"s01","N"})    
aAdd(aHeader,{ "Item Ativo"             ,"CP"+StrZero(Len(aHeader)+1,3)   , "@E!",040,"C",'"s02"',"s01","N"})    

Return aHeader

/*/{protheus.doc} GetaCols
*******************************************************************************************
Selecao dos dados.
 
@author: Marcelo Celi Marques
@since: 02/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaCols(aProdutos)
Local aDados 	:= {}
Local nX        := 1
Local nY        := 1
Local aColsTmp  := {}

For nX:=1 to Len(aProdutos)
    For nY:=1 to Len(aProdutos[nX,11])

        cItAtivo := "Nao"
        dbSelectArea("DA1")
        dbSetOrder(1)
        if DA1->(dbSeek( DA1->(xFilial()) + aProdutos[nX,11,nY,02] + aProdutos[nX,01] ))
            IF DA1->DA1_ATIVO == "1"
                cItAtivo := "Sim"
            ENDIF
        Endif
        aColsTmp := {}
        aAdd(aColsTmp,aProdutos[nX,01])       // codigo do produto
        aAdd(aColsTmp,aProdutos[nX,02])       // descri��o do produto
        aAdd(aColsTmp,aProdutos[nX,03])       // tipo do produto
        aAdd(aColsTmp,aProdutos[nX,11,nY,02]) // tabela de pre�o
        aAdd(aColsTmp,aProdutos[nX,11,nY,03]) // nome da tabela
        aAdd(aColsTmp,aProdutos[nX,11,nY,04]) // Qtde Ult Mes
        aAdd(aColsTmp,aProdutos[nX,11,nY,05]) // Preco de Venda
        aAdd(aColsTmp,aProdutos[nX,11,nY,06]) // Simulacao - R$
        aAdd(aColsTmp,aProdutos[nX,11,nY,07]) // % CMV
        aAdd(aColsTmp,aProdutos[nX,11,nY,08]) // % Comiss Vda
        aAdd(aColsTmp,aProdutos[nX,11,nY,09]) // % Logistica
        aAdd(aColsTmp,aProdutos[nX,11,nY,10]) // % Impostos
        aAdd(aColsTmp,aProdutos[nX,11,nY,11]) // % Desconto
        aAdd(aColsTmp,aProdutos[nX,11,nY,12]) // Margem Contrib        
        aAdd(aColsTmp,cItAtivo)               // Indica se o Item encontra-se ativo na Tabela        
        aAdd(aDados,aColsTmp)
    Next nY
Next nX

Return aDados
