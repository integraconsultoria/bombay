#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "ApWizard.ch"

Static cNomeArq		:= "RELATORIO_FINANCEIRO"
//Pedido Silmara
/*/{protheus.doc} MCRFIN010A
******************************************************************************************* 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MCRFIN010A()
	Local oWizard
	Local aParambox 	:= {}
	Local lOk		 	:= .F.
	Local cNomeEmpr		:= ""

	AjustaSXB()

	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt+cFilAnt))

	cNomeEmpr := Alltrim(SM0->M0_FILIAL)
	cNomeEmpr := StrTran(cNomeEmpr,"."," ")
	cNomeEmpr := StrTran(cNomeEmpr,";"," ")
	cNomeEmpr := StrTran(cNomeEmpr,"-"," ")
	cNomeEmpr := StrTran(cNomeEmpr,"/"," ")
	cNomeEmpr := StrTran(cNomeEmpr," ","_")

	cNomeArq := Alltrim(cNomeArq)+"-"+Upper(cNomeEmpr)

	Private aMeses		:= {"Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
	Private aRetParam 	:= {}
	Private aTpData		:= {"Data da Baixa","Data da Compensa��o","Fluxo futuro"}
	Private aTpConcil	:= {"Conciliado","N�o Conciliado","Todos"}

	aRetParam := {cFilAnt,cFilAnt,Year(dDatabase),Month(dDatabase),Space(150),Replicate(" ",Tamsx3("E5_BANCO")[01]),Replicate(" ",Tamsx3("E5_AGENCIA")[01]),Replicate(" ",Tamsx3("E5_CONTA")[01]),Replicate("Z",Tamsx3("E5_BANCO")[01]),Replicate("Z",Tamsx3("E5_AGENCIA")[01]),Replicate("Z",Tamsx3("E5_CONTA")[01]),2,3,.F.,.T.,.T.,.T.,.F.,.T.}

	aAdd(aParambox,{1,"Filial de" 										,aRetParam[01],"@!","","SM0" 	,".F.",20 ,.F.	})
	aAdd(aParambox,{1,"Filial ate" 										,aRetParam[02],"@!","","SM0" 	,".F.",20 ,.F.	})
	aAdd(aParambox,{1,"Ano" 											,aRetParam[03],"@!","","" 		,".T.",30 ,.T.	})
	aAdd(aParambox,{2,"M�s" 											,aRetParam[04],aMeses,100,".T.",.T.})
	aAdd(aParambox,{1,"Pasta Grava��o"									,aRetParam[05],"@!","","MCPFN"  ,".T.",180,.T.	})
	aAdd(aParambox,{1,"Banco de" 										,aRetParam[06],"@!","","SA6" 	,".F.",30 ,.F.	})
	aAdd(aParambox,{1,"Agencia de" 										,aRetParam[07],"@!","","" 		,".F.",50 ,.F.	})
	aAdd(aParambox,{1,"Conta de" 										,aRetParam[08],"@!","","" 		,".F.",70 ,.F.	})
	aAdd(aParambox,{1,"Banco ate" 										,aRetParam[09],"@!","","SA6" 	,".F.",30 ,.F.	})
	aAdd(aParambox,{1,"Agencia ate" 									,aRetParam[10],"@!","","" 		,".F.",50 ,.F.	})
	aAdd(aParambox,{1,"Conta ate" 										,aRetParam[11],"@!","","" 		,".F.",70 ,.F.	})
	aAdd(aParambox,{2,"Considerar a Data" 								,aRetParam[12],aTpData,100,".T.",.T.})
	aAdd(aParambox,{2,"Considerar Movimentos" 	   						,aRetParam[13],aTpConcil,100,".T.",.T.})
	aAdd(aParambox,{5,"(+) Compor Desconto no Total do Pagamento" 		,aRetParam[14],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor Desconto no Total do Recebimento" 	,aRetParam[15],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor NCC no Total do Recebimento" 			,aRetParam[16],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor Abatimento no Total do Recebimento" 	,aRetParam[17],190,".T.",.F.})
	aAdd(aParambox,{5,"(-) Compor Multa no Total do Recebimento" 		,aRetParam[18],190,".T.",.F.})
	aAdd(aParambox,{5,"Extrair Juros" 									,aRetParam[19],190,".T.",.F.})

	DEFINE WIZARD oWizard ;
		TITLE "Relat�rios Gerenciais" ;
		HEADER "Vis�es Financeiras" ;
		MESSAGE "Avance para Continuar" 		;
		TEXT "Este procedimento dever� gerar em Planilhas Eletr�nicas no formato Excel, os relat�rios Gerenciais nas Vis�es Financeiras." PANEL;
	NEXT {|| .T. } ;
	FINISH {|| .T. };

CREATE PANEL oWizard ;
	HEADER "Vis�es Financeiras" ;
	MESSAGE "Informe os parametros para a Extra��o do Relat�rio" PANEL;
	NEXT {|| 	lOK := ConfProcess() } ;
	FINISH {|| 	lOK := ConfProcess() } ;
	PANEL

Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)
ACTIVATE WIZARD oWizard CENTERED

If lOk
	Processa({|x| ProcRelato(.F.) },"Processando","Aguarde, Extraindo Relat�rio Gerencial",.F.)
EndIf

Return

/*/{protheus.doc} ConfProcess
*******************************************************************************************
Confirma a Exporta��o dos dados
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConfProcess()
	Local lRet 	 := .T.
	Local nHdl	 := 0
	Local cPasta := Alltrim(aRetParam[05])
	Local cPath	 := ""

	If Empty(cPasta)
		MsgAlert("A Pasta destino para a grava��o das Planilhas Eletr�nicas n�o � v�lida ou voc� n�o tem permiss�o para gravar nesse local."+CRLF+"Selecione uma Pasta v�lida para continuar.")
		lRet := .F.
	Else
		cPasta += If(Right(cPasta,1)=="\","","\")
		cPath := cPasta+"Teste_"+Criatrab(,.F.)+".Tst"

		nHdl := fCreate(cPath)
		If nHdl <= 0
			MsgAlert("A Pasta destino para a grava��o das Planilhas Eletr�nicas n�o � v�lida ou voc� n�o tem permiss�o para gravar nesse local."+CRLF+"Selecione uma Pasta v�lida para continuar.")
			lRet := .F.
		Else
			fClose(nHdl)
			FErase(cPath)
		EndIf
	EndIf

	If lRet .And. aRetParam[03] < 1980
		MsgAlert("Ano inv�lido"+CRLF+"Favor informar um ano superior a 1980.")
		lRet := .F.
	ElseIf lRet .And. aRetParam[03] > Year(Date())
		MsgAlert("Ano inv�lido"+CRLF+"Favor informar um ano at� a data atual")
		lRet := .F.
	EndIf

	If ValType(aRetParam[04]) <> "N"
		aRetParam[04] := Ascan(aMeses,{|x| Alltrim(x)==Alltrim(aRetParam[04]) })
	EndIf

	If ValType(aRetParam[12]) <> "N"
		aRetParam[12] := Ascan(aTpData,{|x| Alltrim(x)==Alltrim(aRetParam[12]) })
	EndIf

	If ValType(aRetParam[13]) <> "N"
		aRetParam[13] := Ascan(aTpConcil,{|x| Alltrim(x)==Alltrim(aRetParam[13]) })
	EndIf

	If lRet
		lRet := MsgYesNo("Confirma a Gera��o da Planilha Eletr�nica de Vis�es Gerenciais Financeiras?")
	EndIf

Return lRet

/*/{protheus.doc} ProcRelato
*******************************************************************************************
Processamento do Relat�rio
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcRelato(lJob)
	Local oExcel		:= NIL
	Local aPlanilha 	:= {}
	Local cArquivo		:= ""
	Local cPasta		:= ""
	Local cHRIni   		:= ""
	Local cHRFim   		:= ""
	Local dInicio		:= Stod("")
	Local dFim			:= Stod("")
	Local cPastServ	 	:= "\RELGER\"

	cHRIni := dToc(Date()) +" "+ Time()

//->> Retorna os Vendedores
	If lJob
		dInicio	:= dDatabase
		dFim	:= dInicio
		dInicio := Stod(StrZero(Year(dInicio),4)+StrZero(Month(dInicio),2)+"01")

		Private aRetParam 	:= {}
		aRetParam := {Replicate(" ",Tamsx3("E1_FILIAL")[01]),Replicate("Z",Tamsx3("E1_FILIAL")[01]),dInicio,dFim,cPastServ,.T.,.T.,Replicate(" ",Tamsx3("E5_BANCO")[01]),Replicate(" ",Tamsx3("E5_AGENCIA")[01]),Replicate(" ",Tamsx3("E5_CONTA")[01]),Replicate("Z",Tamsx3("E5_BANCO")[01]),Replicate("Z",Tamsx3("E5_AGENCIA")[01]),Replicate("Z",Tamsx3("E5_CONTA")[01])}
		MakeDir(cPastServ)

	Else
		dInicio := Stod(StrZero(aRetParam[03],4)+StrZero(aRetParam[04],2)+"01")
		dFim 	:= LastDay(Stod(StrZero(aRetParam[03],4)+StrZero(aRetParam[04],2)+"01"))
	EndIf

	If !lJob
		ProcRegua(0)
		IncProc("Gerando o Relat�rio...")
	EndIf
	aPlanilha := {}
	aAdd(aPlanilha,GetPlanilha(dInicio,dFim,lJob))

	If Len(aPlanilha)>0
		cArquivo := cNomeArq
		cPasta	 := Alltrim(aRetParam[05])
		cPasta   += If(Right(cPasta,1)=="\","","\")

		oExcel := McGeraHtml():New(aPlanilha,aRetParam[05],@cArquivo)
		oExcel:WriteHtml()
		FreeObj(oExcel)
		oExcel := NIL
	EndIf

	cHRFim := dToc(Date()) +" "+ Time()

Return

/*/{protheus.doc} GetPlanilha
*******************************************************************************************
Retorna a planilha
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPlanilha(dDataDe,dDataAte,lJob)
	Local aCols		:= {}
	Local aHeader   := {}
	Local aCabec	:= {}
	Local aRodape	:= {}
	Local aDados	:= {}
	Local nX		:= 1
	Local aPlanilha := {}
	Local nPosPlan	:= 0
	Local aReceb	:= GetReceb(dDataDe,dDataAte)
	Local aPgtos	:= GetPgtos(dDataDe,dDataAte)

	ProcRegua(Len(aReceb)+Len(aPgtos)+Len(aPgtos)+Len(aReceb))

//->> Extracao dos Dados		                        
	aAdd(aPlanilha,{"NR",{},{"Fluxo Diario","",""}})
	nPosPlan := Len(aPlanilha)

	//->> cabe�alho de dias
	aCols  := {}
	aHeader:= GetaHeader(0,@aCabec,@aRodape,dDataDe,dDataAte)
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	//->> recebimentos
	aCols  := {}
	aHeader:= GetaHeader(2,@aCabec,@aRodape,dDataDe,dDataAte)
	aDados := GetaCols(2,dDataDe,dDataAte,lJob,aReceb,aPgtos)
	aDados := aSort(aDados,,,{|x,y| x[01] < y[01]})
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	//->> pagamentos
	aCols  := {}
	aHeader:= GetaHeader(4,@aCabec,@aRodape,dDataDe,dDataAte)
	aDados := GetaCols(4,dDataDe,dDataAte,lJob,aReceb,aPgtos)
	aDados := aSort(aDados,,,{|x,y| x[01] < y[01]})
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	aAdd(aPlanilha,{"DADOS PAGAMENTO",{},{"Dados do Fluxo Diario","",""}})
	nPosPlan := Len(aPlanilha)

	//->> pagamentos detalhados
	aCols  := {}
	aHeader:= GetaHeader(6,@aCabec,@aRodape,dDataDe,dDataAte)
	aDados := GetaCols(6,dDataDe,dDataAte,lJob,aReceb,aPgtos)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	aAdd(aPlanilha,{"DADOS RECEBIMENTOS",{},{"Dados do Fluxo Diario","",""}})
	nPosPlan := Len(aPlanilha)

	//->> recebimentos detalhados
	aCols  := {}
	aHeader:= GetaHeader(8,@aCabec,@aRodape,dDataDe,dDataAte)
	aDados := GetaCols(8,dDataDe,dDataAte,lJob,aReceb,aPgtos)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

Return aPlanilha

/*/{protheus.doc} GetReceb
*******************************************************************************************
Retorna array com recebimentos
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetReceb(dDataDe,dDataAte)
	Local aReceb 	:= {}
	Local cAlias 	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cCliente	:= FormatIn(Alltrim(GetNewPar("FH_CLIF010","")),"|")
	Local nValNCC	:= 0
	Local nValAbat	:= 0
	Local nPos		:= 0

	If aRetParam[12] # 3
		cQuery := "SELECT"									 																	+CRLF
		cQuery += "			SE5.E5_FILIAL     AS FILIAL,"	 																	+CRLF
		cQuery += "			SE5.E5_PREFIXO 	  AS PREFIXO," 	 																	+CRLF
		cQuery += "			SE5.E5_NUMERO  	  AS NUMERO,"	 																	+CRLF
		cQuery += "			SE5.E5_PARCELA 	  AS PARCELA,"	 																	+CRLF
		cQuery += "			SE5.E5_TIPO  	  AS TIPO,"		 																	+CRLF
		cQuery += "			SE5.E5_CLIFOR  	  AS CLIENTE,"	 																	+CRLF
		cQuery += "			SE5.E5_LOJA  	  AS LOJA,"		 																	+CRLF
		If aRetParam[12]==1
			cQuery += "			SE5.E5_DATA  	  AS DATA,"		 																+CRLF
		Else
			cQuery += "			SE5.E5_DTDISPO	  AS DATA,"		 																+CRLF
		EndIf
		cQuery += "			SE5.E5_VALOR  	  AS VALOR,"	 																	+CRLF
		cQuery += "			SE5.E5_VLDESCO 	  AS DESCONTO,"	 																	+CRLF
		cQuery += "			SE5.E5_VLJUROS 	  AS JUROS,"	 																	+CRLF
		cQuery += "			SE5.E5_VLMULTA 	  AS MULTA,"	 																	+CRLF
		cQuery += "			SE5.E5_NATUREZ 	  AS NATUREZA,"	 																	+CRLF
		cQuery += "			SE5.E5_MOTBX 	  AS MOTBX,"	 																	+CRLF
		cQuery += "			SE5.E5_DOCUMEN 	  AS DOCUMEN,"	 																	+CRLF
		cQuery += "			SE5.E5_BANCO  	  AS BANCO,"	 																	+CRLF
		cQuery += "			SE5.E5_AGENCIA 	  AS AGENCIA,"	 																	+CRLF
		cQuery += "			SE5.E5_CONTA  	  AS CONTA,"			 															+CRLF
		cQuery += "			(SELECT SE1.R_E_C_N_O_ FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"										+CRLF
		cQuery += "				WHERE SE1.E1_FILIAL  = SE5.E5_FILIAL"															+CRLF
		cQuery += "				  AND SE1.E1_PREFIXO = SE5.E5_PREFIXO"															+CRLF
		cQuery += "				  AND SE1.E1_NUM     = SE5.E5_NUMERO"															+CRLF
		cQuery += "				  AND SE1.E1_PARCELA = SE5.E5_PARCELA"															+CRLF
		cQuery += "				  AND SE1.E1_TIPO    = SE5.E5_TIPO"																+CRLF
		cQuery += "				  AND SE1.E1_CLIENTE = SE5.E5_CLIFOR"															+CRLF
		cQuery += "				  AND SE1.E1_LOJA    = SE5.E5_LOJA"																+CRLF
		cQuery += "				  AND SE1.D_E_L_E_T_ = ' ') AS RECSE1,"															+CRLF
		cQuery += "			SE5.R_E_C_N_O_ 	  AS RECSE5"		 																+CRLF
		cQuery += "	 	FROM "+RetSqlName("SE5")+" SE5 (NOLOCK)"																+CRLF
		cQuery += "		WHERE   SE5.E5_FILIAL  BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"								+CRLF
		If aRetParam[12]==1
			cQuery += "			AND SE5.E5_DATA    BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"						+CRLF
		Else
			cQuery += "			AND SE5.E5_DTDISPO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"						+CRLF
		EndIf
		If aRetParam[13]==1
			cQuery += "			AND SE5.E5_RECONC 	<> 	' ' "																	+CRLF
		ElseIf aRetParam[13]==2
			cQuery += "			AND SE5.E5_RECONC 	== 	' ' "																	+CRLF
		EndIf
		cQuery += "			AND SE5.E5_BANCO   BETWEEN '"+aRetParam[06]+"' AND '"+aRetParam[09]+"'"								+CRLF
		cQuery += "			AND SE5.E5_AGENCIA BETWEEN '"+aRetParam[07]+"' AND '"+aRetParam[10]+"'"								+CRLF
		cQuery += "			AND SE5.E5_CONTA   BETWEEN '"+aRetParam[08]+"' AND '"+aRetParam[11]+"'"								+CRLF
		cQuery += "			AND SE5.E5_SITUACA NOT IN ('C','E','X') "															+CRLF
		cQuery += "			AND SE5.E5_TIPODOC NOT IN ('DB','DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','CH','TR','TE','CP','CP') " +CRLF

//cQuery += "			AND (SE5.E5_BANCO 	<> 	' '  OR (SE5.E5_BANCO = ' ' AND SE5.E5_MOTBX = 'CMP') ) "				+CRLF
		cQuery += "			AND SE5.E5_BANCO 	<> 	' ' "																		+CRLF

		cQuery += "			AND SE5.E5_NUMERO   <> 	' ' "																		+CRLF
		cQuery += "			AND SE5.E5_RECPAG 	= 	'R' "																		+CRLF
		cQuery += "			AND SE5.E5_CLIFOR + SE5.E5_LOJA NOT IN "+cCliente													+CRLF
		cQuery += "			AND SE5.D_E_L_E_T_ = ' '"																			+CRLF
		cQuery += "	 	ORDER BY  SE5.E5_FILIAL,"	 																			+CRLF
		cQuery += "				  SE5.E5_PREFIXO," 	 																			+CRLF
		cQuery += "				  SE5.E5_NUMERO,"	 																			+CRLF
		cQuery += "				  SE5.E5_PARCELA,"	 																			+CRLF
		cQuery += "				  SE5.E5_TIPO,"		 																			+CRLF
		cQuery += "				  SE5.E5_CLIFOR,"	 																			+CRLF
		cQuery += "				  SE5.E5_LOJA"		 																			+CRLF
	else //TITULOS A VENCER
		cQuery := "SELECT SE1.E1_FILIAL     AS FILIAL,"+CRLF
		cQuery += " SE1.E1_PREFIXO 	  AS PREFIXO,"+CRLF
		cQuery += " SE1.E1_NUM  	  AS NUMERO,	"+CRLF
		cQuery += " SE1.E1_PARCELA 	  AS PARCELA,"+CRLF
		cQuery += " SE1.E1_TIPO  	  AS TIPO,"+CRLF
		cQuery += " SE1.E1_CLIENTE    AS CLIENTE,"+CRLF
		cQuery += " SE1.E1_LOJA  	  AS LOJA,"+CRLF
		cQuery += " SE1.E1_EMISSAO    AS DATA,"+CRLF
		cQuery += " SE1.E1_VALOR  	  AS VALOR,"+CRLF
		cQuery += " SE1.E1_DESCON1 	  AS DESCONTO,"+CRLF
		cQuery += " SE1.E1_JUROS 	  AS JUROS,"+CRLF
		cQuery += " SE1.E1_VLMULTA 	  AS MULTA,"+CRLF
		cQuery += " SE1.E1_NATUREZ 	  AS NATUREZA,"+CRLF
		cQuery += " ''			 	  AS MOTBX,	"+CRLF
		cQuery += " ''			 	  AS DOCUMEN,	"+CRLF
		cQuery += " SE1.E1_NUMBCO  	  AS BANCO,"+CRLF
		cQuery += " SE1.E1_AGEDEP 	  AS AGENCIA,"+CRLF
		cQuery += " SE1.E1_CONTA  	  AS CONTA,"+CRLF
		cQuery += " R_E_C_N_O_		  AS RECSE1,"+CRLF
		cQuery += " 0   			  AS RECSE5"+CRLF
		cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"+CRLF
		cQuery += " WHERE"+CRLF
		//cQuery += " SE1.E1_TIPO = 'NF' AND  "+CRLF
		cQuery += " SE1.E1_SALDO > 0 AND"+CRLF
		cQuery += " SE1.E1_BAIXA = '' AND"+CRLF
		cQuery += " SE1.E1_FATURA = '' AND"+CRLF
		cQuery += " SE1.D_E_L_E_T_ <> '*' "+CRLF
		cQuery += " AND E1_FILIAL BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"+CRLF
		cQuery += "	AND SE1.E1_AGEDEP BETWEEN '"+aRetParam[07]+"' AND '"+aRetParam[10]+"'"+CRLF
		cQuery += "	AND SE1.E1_CONTA   BETWEEN '"+aRetParam[08]+"' AND '"+aRetParam[11]+"'"+CRLF
		cQuery += "	AND SE1.E1_CLIENTE + SE1.E1_LOJA NOT IN "+cCliente+" "+CRLF
		cQuery += "	AND SE1.E1_VENCREA   BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		cQuery += "	ORDER BY  SE1.E1_FILIAL,"+CRLF
		cQuery += " SE1.E1_PREFIXO,"+CRLF
		cQuery += " SE1.E1_NUM,"+CRLF
		cQuery += " SE1.E1_PARCELA,"+CRLF
		cQuery += " SE1.E1_TIPO,"+CRLF
		cQuery += " SE1.E1_CLIENTE,"+CRLF
		cQuery += " SE1.E1_LOJA"+CRLF


	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

	ProcRegua(0)
	Do While (cAlias)->(!Eof())
		IncProc("Extraindo Movimentos Recebidos...")
		aAdd(aReceb,{(cAlias)->FILIAL,																					;
			(cAlias)->PREFIXO,																					;
			(cAlias)->NUMERO,																					;
			(cAlias)->PARCELA,																					;
			(cAlias)->TIPO,																					;
			(cAlias)->CLIENTE,																					;
			(cAlias)->LOJA,																					;
			Stod((cAlias)->DATA),																				;
			(cAlias)->VALOR + If(aRetParam[15],(cAlias)->DESCONTO,0) - If(aRetParam[19],(cAlias)->JUROS,0),	;
			(cAlias)->NATUREZA,																				;
			(cAlias)->BANCO,																					;
			(cAlias)->AGENCIA,																					;
			(cAlias)->CONTA,																					;
			(cAlias)->RECSE1,																					;
			(cAlias)->MOTBX,																					;
			(cAlias)->JUROS,		 																			;
			(cAlias)->DOCUMEN,																					;
			0,																									;
			0,																									;
			(cAlias)->MULTA,																					;
			(cAlias)->RECSE5,	  	 																			;
			{} })

		//->> teste - retirar
		//If "49499" $ (cAlias)->NUMERO
		//	msgalert("aqui")
		//EndIf

		nPos := Len(aReceb)
		If aRetParam[16]
			nValNCC := GetValNCC(aReceb[nPos])
			nValNCC	+= GetNccxNf((cAlias)->FILIAL,(cAlias)->PREFIXO,(cAlias)->NUMERO,(cAlias)->PARCELA,(cAlias)->TIPO,(cAlias)->CLIENTE,(cAlias)->LOJA)

			aReceb[nPos][18] := nValNCC
			aReceb[nPos][09] += nValNCC
		EndIf
		If aRetParam[17]
			nValAbat:= GetValAbat(aReceb[nPos])
			aReceb[nPos][19] := nValAbat
			aReceb[nPos][09] += nValAbat
		EndIf
		If aRetParam[18]
			aReceb[nPos][09] -= (cAlias)->MULTA
		EndIf

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return aReceb

/*/{protheus.doc} GetPgtos
*******************************************************************************************
Retorna array com pagamentos
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPgtos(dDataDe,dDataAte)
	Local aPagtos 	:= {}
	Local cAlias 	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cFornec	:= FormatIn(Alltrim(GetNewPar("FH_FORF010","00018301")),"|")

	If aRetParam[12]# 3
		cQuery := "SELECT"									 																	+CRLF
		cQuery += "			SE5.E5_FILIAL     AS FILIAL,"	 																	+CRLF
		cQuery += "			SE5.E5_PREFIXO 	  AS PREFIXO," 	 																	+CRLF
		cQuery += "			SE5.E5_NUMERO  	  AS NUMERO,"	 																	+CRLF
		cQuery += "			SE5.E5_PARCELA 	  AS PARCELA,"	 																	+CRLF
		cQuery += "			SE5.E5_TIPO  	  AS TIPO,"		 																	+CRLF
		cQuery += "			SE5.E5_CLIFOR  	  AS FORNECEDOR,"	 																+CRLF
		cQuery += "			SE5.E5_LOJA  	  AS LOJA,"		 																	+CRLF
		If aRetParam[12]==1
			cQuery += "			SE5.E5_DATA  	  AS DATA,"		 																+CRLF
		Else
			cQuery += "			SE5.E5_DTDISPO	  AS DATA,"		 																+CRLF
		EndIf
		cQuery += "			SE5.E5_VALOR  	  AS VALOR,"	 																	+CRLF
		cQuery += "			SE5.E5_VLDESCO 	  AS DESCONTO,"	 																	+CRLF
		cQuery += "			SE5.E5_VLJUROS 	  AS JUROS,"	 																	+CRLF
		cQuery += "			SE5.E5_NATUREZ 	  AS NATUREZA,"	 																	+CRLF
		cQuery += "			SE5.E5_MOTBX 	  AS MOTBX,"	 																	+CRLF
		cQuery += "			SE5.E5_DOCUMEN 	  AS DOCUMEN,"	 																	+CRLF
		cQuery += "			SE5.E5_BANCO  	  AS BANCO,"	 																	+CRLF
		cQuery += "			SE5.E5_AGENCIA 	  AS AGENCIA,"	 																	+CRLF
		cQuery += "			SE5.E5_CONTA  	  AS CONTA,"			 															+CRLF
		cQuery += "			(SELECT SE2.R_E_C_N_O_ FROM "+RetSqlName("SE2")+" SE2 (NOLOCK)"										+CRLF
		cQuery += "				WHERE SE2.E2_FILIAL  = SE5.E5_FILIAL"															+CRLF
		cQuery += "				  AND SE2.E2_PREFIXO = SE5.E5_PREFIXO"															+CRLF
		cQuery += "				  AND SE2.E2_NUM     = SE5.E5_NUMERO"															+CRLF
		cQuery += "				  AND SE2.E2_PARCELA = SE5.E5_PARCELA"															+CRLF
		cQuery += "				  AND SE2.E2_TIPO    = SE5.E5_TIPO"																+CRLF
		cQuery += "				  AND SE2.E2_FORNECE = SE5.E5_CLIFOR"															+CRLF
		cQuery += "				  AND SE2.E2_LOJA    = SE5.E5_LOJA"																+CRLF
		cQuery += "				  AND SE2.D_E_L_E_T_ = ' ') AS RECSE2,"															+CRLF
		cQuery += "			SE5.R_E_C_N_O_ 	  AS RECSE5"		 																+CRLF
		cQuery += "	 	FROM "+RetSqlName("SE5")+" SE5 (NOLOCK)"																+CRLF
		cQuery += "		WHERE   SE5.E5_FILIAL  BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"								+CRLF
		If aRetParam[12]==1
			cQuery += "			AND SE5.E5_DATA    BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"						+CRLF
		Else
			cQuery += "			AND SE5.E5_DTDISPO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"						+CRLF
		EndIf
		If aRetParam[13]==1
			cQuery += "			AND SE5.E5_RECONC 	<> 	' ' "																	+CRLF
		ElseIf aRetParam[13]==2
			cQuery += "			AND SE5.E5_RECONC 	== 	' ' "																	+CRLF
		EndIf
		cQuery += "			AND SE5.E5_BANCO   BETWEEN '"+aRetParam[06]+"' AND '"+aRetParam[09]+"'"								+CRLF
		cQuery += "			AND SE5.E5_AGENCIA BETWEEN '"+aRetParam[07]+"' AND '"+aRetParam[10]+"'"								+CRLF
		cQuery += "			AND SE5.E5_CONTA   BETWEEN '"+aRetParam[08]+"' AND '"+aRetParam[11]+"'"								+CRLF
		cQuery += "			AND SE5.E5_SITUACA NOT IN ('C','E','X') "															+CRLF
		cQuery += "			AND SE5.E5_TIPODOC NOT IN ('DB','DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','CH','TR','TE','CP') " +CRLF
		cQuery += "			AND SE5.E5_BANCO 	<> 	' ' "																		+CRLF
		cQuery += "			AND SE5.E5_NUMERO   <> 	' ' "																		+CRLF
		cQuery += "			AND SE5.E5_RECPAG 	= 	'P' "																		+CRLF
		cQuery += "			AND SE5.E5_CLIFOR + SE5.E5_LOJA NOT IN "+cFornec													+CRLF
		cQuery += "			AND SE5.D_E_L_E_T_ = ' '"																			+CRLF

//->> teste - tirar depois
//cQuery += "and SE5.E5_NUMERO = '2558'"+CRLF
//cQuery += "and SE5.E5_PREFIXO = ' '"+CRLF
//cQuery += "and SE5.E5_FILIAL = '0101'"+CRLF

		cQuery += "	 	ORDER BY  SE5.E5_FILIAL,"	 																			+CRLF
		cQuery += "				  SE5.E5_PREFIXO," 	 																			+CRLF
		cQuery += "				  SE5.E5_NUMERO,"	 																			+CRLF
		cQuery += "				  SE5.E5_PARCELA,"	 																			+CRLF
		cQuery += "				  SE5.E5_TIPO,"		 																			+CRLF
		cQuery += "				  SE5.E5_CLIFOR,"	 																			+CRLF
		cQuery += "				  SE5.E5_LOJA"		 																			+CRLF
	else
		cQuery := "SELECT SE2.E2_FILIAL     AS FILIAL,"+CRLF
		cQuery += " SE2.E2_PREFIXO 	  AS PREFIXO,"+CRLF
		cQuery += " SE2.E2_NUM  	  AS NUMERO,	"+CRLF
		cQuery += " SE2.E2_PARCELA 	  AS PARCELA,"+CRLF
		cQuery += " SE2.E2_TIPO  	  AS TIPO,"+CRLF
		cQuery += " SE2.E2_FORNECE    AS FORNECEDOR,"+CRLF
		cQuery += " SE2.E2_LOJA  	  AS LOJA,"+CRLF
		cQuery += " SE2.E2_EMISSAO    AS DATA,"+CRLF
		cQuery += " SE2.E2_VALOR  	  AS VALOR,"+CRLF
		cQuery += " SE2.E2_DESCONT 	  AS DESCONTO,"+CRLF
		cQuery += " SE2.E2_JUROS 	  AS JUROS,"+CRLF
		cQuery += " SE2.E2_MULTA 	  AS MULTA,"+CRLF
		cQuery += " SE2.E2_NATUREZ 	  AS NATUREZA,"+CRLF
		cQuery += " ''			 	  AS MOTBX,	"+CRLF
		cQuery += " ''			 	  AS DOCUMEN,	"+CRLF
		cQuery += " SE2.E2_BCOPAG  	  AS BANCO,"+CRLF
		cQuery += " SE2.E2_AGECHQ 	  AS AGENCIA,"+CRLF
		cQuery += " SE2.E2_NUMBCO  	  AS CONTA,"+CRLF
		cQuery += " R_E_C_N_O_		  AS RECSE2,"+CRLF
		cQuery += " 0   			  AS RECSE5"+CRLF
		cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK)"+CRLF
		cQuery += " WHERE"+CRLF
		cQuery += " SE2.E2_SALDO > 0 AND"+CRLF
		cQuery += " SE2.E2_BAIXA = '' AND"+CRLF
		cQuery += " SE2.E2_FATURA = '' AND"+CRLF
		cQuery += " SE2.D_E_L_E_T_ <> '*' "+CRLF
		cQuery += " AND SE2.E2_FILIAL BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"+CRLF
		cQuery += "	AND SE2.E2_BCOPAG BETWEEN '"+aRetParam[07]+"' AND '"+aRetParam[10]+"'"+CRLF
		cQuery += "	AND SE2.E2_NUMBCO   BETWEEN '"+aRetParam[08]+"' AND '"+aRetParam[11]+"'"+CRLF
		cQuery += "	AND SE2.E2_FORNECE + SE2.E2_LOJA NOT IN "+cFornec+" "+CRLF
		cQuery += "	AND SE2.E2_VENCREA   BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		cQuery += "	ORDER BY  SE2.E2_FILIAL,"+CRLF
		cQuery += " SE2.E2_PREFIXO,"+CRLF
		cQuery += " SE2.E2_NUM,"+CRLF
		cQuery += " SE2.E2_PARCELA,"+CRLF
		cQuery += " SE2.E2_TIPO,"+CRLF
		cQuery += " SE2.E2_FORNECE,"+CRLF
		cQuery += " SE2.E2_LOJA"+CRLF
	EndIf
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

	ProcRegua(0)
	Do While (cAlias)->(!Eof())
		IncProc("Extraindo Movimentos Pagos...")
		aAdd(aPagtos,{(cAlias)->FILIAL,		 																			;
			(cAlias)->PREFIXO,	 																			;
			(cAlias)->NUMERO,		 																			;
			(cAlias)->PARCELA,	 																			;
			(cAlias)->TIPO,		 																			;
			(cAlias)->FORNECEDOR,	 																			;
			(cAlias)->LOJA,		 																			;
			Stod((cAlias)->DATA),	 								   											;
			(cAlias)->VALOR + If(aRetParam[14],(cAlias)->DESCONTO,0) - If(aRetParam[19],(cAlias)->JUROS,0),	;
			(cAlias)->NATUREZA,	 																			;
			(cAlias)->BANCO,		 																			;
			(cAlias)->AGENCIA,	 																			;
			(cAlias)->CONTA,		 																			;
			(cAlias)->RECSE2,																					;
			(cAlias)->MOTBX,		 																			;
			(cAlias)->JUROS,		 																			;
			(cAlias)->DOCUMEN,																				;
			(cAlias)->RECSE5,																					;
			{} })

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return aPagtos

/*/{protheus.doc} GetaCols
*******************************************************************************************
Selecao dos dados.
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaCols(nTipo,dDataDe,dDataAte,lJob,aReceb,aPgto)
	Local aDados 	:= {}
	Local aDadTmp	:= {}
	Local nX	 	:= 1
	Local nY		:= 1
	Local dX		:= Stod("")
	Local nPosEnt	:= 0
	Local nDia		:= 0
	Local nTotal	:= 0

// Recebidos 
	If nTipo == 2
		For nX:=1 to Len(aReceb)
			//->> Extrai Detalhes
			IncProc("Extraindo Movimentos Recebidos...")

			nDia := Day(aReceb[nX][08])
			aDetalhes := GetDetalhes("R",aReceb[nX])

			//->> Marcelo Celi - 23/01/2020
			For nY :=1 to Len(aDetalhes)
				aAdd(aReceb[nX][22],aDetalhes[nY])
			Next nY

			For nY:=1 to Len(aDetalhes)
				cEntidade := Alltrim(aDetalhes[nY][01])
				nPosEnt  := Ascan(aDados,{|x| Alltrim(x[01])==Alltrim(cEntidade) })
				If nPosEnt == 0
					aDadTmp := {}
					aAdd(aDadTmp,cEntidade)
					aAdd(aDadTmp,aDetalhes[nY][02])
					For dX := dDataDe to dDataAte
						aAdd(aDadTmp,0)
					Next dX
					aAdd(aDadTmp,0)
					aAdd(aDadTmp,0)

					aAdd(aDados,aDadTmp)
					nPosEnt := Len(aDados)
				EndIf
				aDados[nPosEnt][nDia+2] 				+= Round((aReceb[nX][09] * (aDetalhes[nY][04] / 100)),2)
				aDados[nPosEnt][Len(aDados[nPosEnt])-1] += Round((aReceb[nX][09] * (aDetalhes[nY][04] / 100)),2)
				nTotal 									+= Round((aReceb[nX][09] * (aDetalhes[nY][04] / 100)),2)

			Next nY

			//->> Capturar os juros
			If aRetParam[19]
				If aReceb[nX][16] > 0
					cEntidade := "JUROS"
					nPosEnt   := Ascan(aDados,{|x| Alltrim(x[01])==Alltrim(cEntidade) })
					If nPosEnt == 0
						aDadTmp := {}
						aAdd(aDadTmp,cEntidade)
						aAdd(aDadTmp,"JUROS")
						For dX := dDataDe to dDataAte
							aAdd(aDadTmp,0)
						Next dX
						aAdd(aDadTmp,0)
						aAdd(aDadTmp,0)

						aAdd(aDados,aDadTmp)
						nPosEnt := Len(aDados)
					EndIf
					aDados[nPosEnt][nDia+2] 				+= Round(aReceb[nX][16],2)
					aDados[nPosEnt][Len(aDados[nPosEnt])-1] += Round(aReceb[nX][16],2)
					nTotal 									+= Round(aReceb[nX][16],2)
				EndIf
			EndIf

		Next nX

		//->> Calculo dos percentuais
		For nX:=1 to Len(aDados)
			aDados[nX][Len(aDados[nX])] := Round((aDados[nX][Len(aDados[nX])-1] / nTotal) * 100,2)
		Next nX

	EndIf

// Pagamentos
	If nTipo == 4
		For nX:=1 to Len(aPgto)
			//->> Extrai Detalhes
			IncProc("Extraindo Movimentos Pagos...")

			nDia := Day(aPgto[nX][08])
			aDetalhes := GetDetalhes("P",aPgto[nX])

			//->> Marcelo Celi - 23/01/2020
			For nY :=1 to Len(aDetalhes)
				aAdd(aPgto[nX][19],aDetalhes[nY])
			Next nY

			For nY:=1 to Len(aDetalhes)
				cEntidade := Alltrim(aDetalhes[nY][01])
				nPosEnt  := Ascan(aDados,{|x| Alltrim(x[01])==Alltrim(cEntidade) })
				If nPosEnt == 0
					aDadTmp := {}
					aAdd(aDadTmp,cEntidade)
					aAdd(aDadTmp,aDetalhes[nY][02])
					For dX := dDataDe to dDataAte
						aAdd(aDadTmp,0)
					Next dX
					aAdd(aDadTmp,0)
					aAdd(aDadTmp,0)

					aAdd(aDados,aDadTmp)
					nPosEnt := Len(aDados)
				EndIf
				aDados[nPosEnt][nDia+2] 				+= Round((aPgto[nX][09] * (aDetalhes[nY][04] / 100)),2)
				aDados[nPosEnt][Len(aDados[nPosEnt])-1] += Round((aPgto[nX][09] * (aDetalhes[nY][04] / 100)),2)
				nTotal 									+= Round((aPgto[nX][09] * (aDetalhes[nY][04] / 100)),2)
			Next nY

			//->> Capturar os juros
			If aRetParam[19]
				If aPgto[nX][16] > 0
					cEntidade := "2006002"
					nPosEnt   := Ascan(aDados,{|x| Alltrim(x[01])==Alltrim(cEntidade) })
					If nPosEnt == 0
						aDadTmp := {}
						aAdd(aDadTmp,cEntidade)
						aAdd(aDadTmp,"JUROS S/ PAGTOS")
						For dX := dDataDe to dDataAte
							aAdd(aDadTmp,0)
						Next dX
						aAdd(aDadTmp,0)
						aAdd(aDadTmp,0)

						aAdd(aDados,aDadTmp)
						nPosEnt := Len(aDados)
					EndIf
					aDados[nPosEnt][nDia+2] 				+= Round(aPgto[nX][16],2)
					aDados[nPosEnt][Len(aDados[nPosEnt])-1] += Round(aPgto[nX][16],2)
					nTotal 									+= Round(aPgto[nX][16],2)
				EndIf
			EndIf

		Next nX

		//->> Calculo dos percentuais
		For nX:=1 to Len(aDados)
			aDados[nX][Len(aDados[nX])] := Round((aDados[nX][Len(aDados[nX])-1] / nTotal) * 100,2)
		Next nX

	EndIf

// Pagamentos detalhados
	If nTipo == 6
		For nX:=1 to Len(aPgto)
			//->> Extrai Detalhes
			IncProc("Extraindo Detalhes de Movimentos Pagos...")
			SE2->(dbGoto(aPgto[nX,14]))

			//->> Marcelo Celi - 23/01/2019
			For nY:=1 to Len(aPgto[nX,19])
				aAdd(aDados,{aPgto[nX,01],;
					aPgto[nX,02],;
					aPgto[nX,03],;
					aPgto[nX,04],;
					aPgto[nX,05],;
					aPgto[nX,06],;
					aPgto[nX,07],;
					Posicione("SA2",1,xFilial("SA2")+aPgto[nX,06]+aPgto[nX,07],"A2_NOME"),;
					aPgto[nX,08],;
					aPgto[nX,09],;
					aPgto[nX,10],;
					Posicione("SED",1,xFilial("SED")+aPgto[nX,10],"ED_DESCRIC"),;
					aPgto[nX,15],;
					SE2->E2_VENCTO,;
					SE2->E2_VENCREA,;
					aPgto[nX,19,nY,01],;
					aPgto[nX,19,nY,02],;
					(aPgto[nX,09]/100)*aPgto[nX,19,nY,04],; //aPgto[nX,19,nY,03],;
					aPgto[nX,19,nY,04]})
			Next nY
		Next nX
	EndIf

// recebimentos detalhados
	If nTipo == 8
		For nX:=1 to Len(aReceb)
			//->> Extrai Detalhes
			IncProc("Extraindo Detalhes de Movimentos Recebidos...")
			SE1->(dbGoto(aReceb[nX,14]))

			//->> Marcelo Celi - 23/01/2019
			For nY:=1 to Len(aReceb[nX,22])
				aAdd(aDados,{aReceb[nX,01],;
					aReceb[nX,02],;
					aReceb[nX,03],;
					aReceb[nX,04],;
					aReceb[nX,05],;
					aReceb[nX,06],;
					aReceb[nX,07],;
					Posicione("SA1",1,xFilial("SA1")+aReceb[nX,06]+aReceb[nX,07],"A1_NOME"),;
					aReceb[nX,08],;
					aReceb[nX,09],;
					aReceb[nX,10],;
					Posicione("SED",1,xFilial("SED")+aReceb[nX,10],"ED_DESCRIC"),;
					aReceb[nX,15],;
					SE1->E1_VENCTO,;
					SE1->E1_VENCREA,;
					aReceb[nX,22,nY,01],;
					aReceb[nX,22,nY,02],;
					(aReceb[nX,09]/100)*aReceb[nX,22,nY,04],;//aReceb[nX,22,nY,03],;
					aReceb[nX,22,nY,04]})
			Next nY
		Next nX
	EndIf

Return aDados

/*/{protheus.doc} GetaHeader
*******************************************************************************************
Criacao do aHeader.
 
@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaHeader(nTipo,aCabec,aRodape,dDataDe,dDataAte)
	Local aHeader 	:= {}
	Local dX		:= Stod("")
	Local nCpo		:= 1

	aCabec := {}
	aRodape:= {}

	If nTipo == 0
		//->> Cabecalho
		aAdd(aCabec,{2,Upper("Fluxo Diario "+GetMes(aRetParam[04])+"/"+StrZero(aRetParam[03],4)),"@E!",200,"C","s01"})
		For dX := dDataDe to dDataAte
			aAdd(aCabec,{1,GetSemana(dX),"@E!",080,"C","s01"})
		Next dX
		aAdd(aCabec,{1,"","@E!",080,"C","s01"})
		aAdd(aCabec,{1,"","@E!",080,"C","s01"})

		//->> Dados
		aAdd(aHeader,{"","CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"","CPO2", "@E!",140,"C",'"s02"',"s01","N"})
		nCpo := 3
		For dX := dDataDe to dDataAte
			aAdd(aHeader,{StrZero(Day(dX),2),"CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
			nCpo++
		Next dX
		aAdd(aHeader,{"Acumulado","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
		nCpo++
		aAdd(aHeader,{"% do Total","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
	EndIf

	If nTipo == 2
		//->> Dados recebimentos por grupo
		//->> Cabecalho

		If aRetParam[12] # 3
			aAdd(aCabec,{2,"Movimentos Recebidos","@E!",200,"C","s01"})
		Else
			aAdd(aCabec,{2,"Movimentos a Receber","@E!",200,"C","s01"})
		EndIf
		aAdd(aCabec,{Day(dDataAte)+2,"","@E!",200,"C","s01"})

		aAdd(aHeader,{"Codigo"	 ,"CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descri��o","CPO2", "@E!",140,"C",'"s02"',"s01","N"})
		nCpo := 3
		For dX := dDataDe to dDataAte
			aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
			nCpo++
		Next dX
		aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
		nCpo++
		aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
	EndIf

	If nTipo == 4
		//->> Dados pagamentos por grupo
		//->> Cabecalho
		If aRetParam[12] # 3
			aAdd(aCabec,{2,"Movimentos Pagos","@E!",200,"C","s01"})
		Else
			aAdd(aCabec,{2,"Movimentos a Pagar","@E!",200,"C","s01"})
		EndIf
		aAdd(aCabec,{Day(dDataAte)+2,""	 ,"@E!",200,"C","s01"})


		aAdd(aHeader,{"Codigo"	 ,"CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descri��o","CPO1", "@E!",140,"C",'"s02"',"s01","N"})
		nCpo := 3
		For dX := dDataDe to dDataAte
			aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
			nCpo++
		Next dX
		aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
		nCpo++
		aAdd(aHeader,{"","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
	EndIf

	If nTipo == 6
		//->> Dados pagamentos detalhados
		aAdd(aHeader,{"Filial"		,"CPO1", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Prefixo"		,"CPO2", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Numero"		,"CPO3", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Parcela"		,"CPO4", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Tipo"		,"CPO5", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Fornecedor"	,"CPO6", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Loja"		,"CPO7", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Nome"		,"CPO8", "@E!",180,"C",'"s02"',"s01","N"})
		If aRetParam[12] # 3
			aAdd(aHeader,{"Baixa"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		else
			aAdd(aHeader,{"Emissao"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		EndIf
		aAdd(aHeader,{"Valor"		,"CPOA", "@E!",100,"N",'"s02"',"s01","N"})
		aAdd(aHeader,{"Natureza"	,"CPOB", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descricao"	,"CPOC", "@E!",180,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Mot Baixa"	,"CPOD", "@E!",040,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Vencimento"	,"CPOE", "@E!",100,"D",'"s02"',"s01","N"})
		aAdd(aHeader,{"Vencto Real"	,"CPOF", "@E!",100,"D",'"s02"',"s01","N"})

		//->> Marcelo Celi - 23/01/2019
		aAdd(aHeader,{"Codigo Rateio"	,"CPOG", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descr. Rateio"	,"CPOH", "@E!",180,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Valor Rateio"	,"CPOI", "@E!",100,"N",'"s02"',"s01","N"})
		aAdd(aHeader,{"Perc.  Rateio"	,"CPOJ", "@E!",100,"N",'"s02"',"s01","N"})

	EndIf

	If nTipo == 8
		//->> Dados recebimentos detalhados
		aAdd(aHeader,{"Filial"		,"CPO1", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Prefixo"		,"CPO2", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Numero"		,"CPO3", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Parcela"		,"CPO4", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Tipo"		,"CPO5", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Cliente"		,"CPO6", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Loja"		,"CPO7", "@E!",030,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Nome"		,"CPO8", "@E!",180,"C",'"s02"',"s01","N"})
		If aRetParam[12] # 3
			aAdd(aHeader,{"Baixa"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		Else
			aAdd(aHeader,{"Emissao"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		EndIf
		aAdd(aHeader,{"Valor"		,"CPOA", "@E!",100,"N",'"s02"',"s01","N"})
		aAdd(aHeader,{"Natureza"	,"CPOB", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descricao"	,"CPOC", "@E!",180,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Mot Baixa"	,"CPOD", "@E!",040,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Vencimento"	,"CPOE", "@E!",100,"D",'"s02"',"s01","N"})
		aAdd(aHeader,{"Vencto Real"	,"CPOF", "@E!",100,"D",'"s02"',"s01","N"})

		//->> Marcelo Celi - 23/01/2019
		aAdd(aHeader,{"Codigo Rateio"	,"CPOG", "@E!",080,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descr. Rateio"	,"CPOH", "@E!",180,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Valor Rateio"	,"CPOI", "@E!",100,"N",'"s02"',"s01","N"})
		aAdd(aHeader,{"Perc.  Rateio"	,"CPOJ", "@E!",100,"N",'"s02"',"s01","N"})

	EndIf

Return aHeader

/*/{protheus.doc} GetMes
*******************************************************************************************
Retorna o m�s
 
@author: Marcelo Celi Marques
@since: 02/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetMes(nMes)
	Local cRet 	:= ""

	Do Case
	Case nMes == 1
		cRet := "Janeiro"

	Case nMes == 2
		cRet := "Fevereiro"

	Case nMes == 3
		cRet := "Marco"

	Case nMes == 4
		cRet := "Abril"

	Case nMes == 5
		cRet := "Maio"

	Case nMes == 6
		cRet := "Junho"

	Case nMes == 7
		cRet := "Julho"

	Case nMes == 8
		cRet := "Agosto"

	Case nMes == 9
		cRet := "Setembro"

	Case nMes == 10
		cRet := "Outubro"

	Case nMes == 11
		cRet := "Novembro"

	Case nMes == 12
		cRet := "Dezembro"

	End Case

Return cRet

/*/{protheus.doc} GetSemana
*******************************************************************************************
Retorna a semana
 
@author: Marcelo Celi Marques
@since: 02/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetSemana(dData)
	Local cSemana := ""
	Local nSemana := Dow(dData)

	Do Case
	Case nSemana == 1
		cSemana := "DOM"

	Case nSemana == 2
		cSemana := "SEG"

	Case nSemana == 3
		cSemana := "TER"

	Case nSemana == 4
		cSemana := "QUA"

	Case nSemana == 5
		cSemana := "QUI"

	Case nSemana == 6
		cSemana := "SEX"

	Case nSemana == 7
		cSemana := "SAB"

	EndCase

Return cSemana

/*/{protheus.doc} GetDetalhes
*******************************************************************************************
Retorna os Detalhes do Movimento
 
@author: Marcelo Celi Marques
@since: 02/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDetalhes(cCarteira,aMovimento)
	Local aDetalhes := {}
	Local cQuery    := ""
	Local cAlias	:= "TMPGETDET"
	Local _cFilAnt	:= cFilAnt
	Local nTotal	:= 0
	Local nX		:= 1
	Local cSerie	:= ""
	Local cDoc		:= ""
	Local cCliente	:= ""
	Local cFornece  := ""
	Local cLoja		:= ""
	Local cNatureza := ""
	Local cDocumento:= ""
	Local cImpostos := "TX |ISS|INS|PIS|COF|CSL|IR "
	Local cTitPai	:= ""

	cFilAnt := aMovimento[01]

	If cCarteira == "R"
		//->> Verificar se compensa��o.
		If aMovimento[15]=="CMP" .And. !Empty(aMovimento[17])
			SE5->(dbSetOrder(10))
			If SE5->(dbSeek( aMovimento[01] + Alltrim(aMovimento[17]) ))
				cSerie		:= SE5->E5_PREFIXO
				cDoc		:= SE5->E5_NUMERO
				cCliente	:= SE5->E5_CLIFOR
				cLoja		:= SE5->E5_LOJA
			Else
				cSerie		:= aMovimento[02]
				cDoc		:= aMovimento[03]
				cCliente	:= aMovimento[06]
				cLoja		:= aMovimento[07]
			EndIf

			//->> Marcelo Celi - 23/01/2020 - Regra nova do recebimento antecipado
		ElseIf Alltrim(aMovimento[05])=="RA"
			cDocumento := aMovimento[02] + aMovimento[03] + aMovimento[04] + aMovimento[05] //->> pref + num + parc + tipó
			SE5->(dbSetOrder(10))
			If SE5->(dbSeek( aMovimento[01] + cDocumento ))
				cSerie		:= SE5->E5_PREFIXO
				cDoc		:= SE5->E5_NUMERO
				cCliente	:= SE5->E5_CLIFOR
				cLoja		:= SE5->E5_LOJA
			Else
				cSerie		:= ""
				cDoc		:= ""
				cCliente	:= ""
				cLoja		:= ""
			EndIf

		Else
			cSerie		:= aMovimento[02]
			cDoc		:= aMovimento[03]
			cCliente	:= aMovimento[06]
			cLoja		:= aMovimento[07]
		EndIf

		If !Empty(cDoc)
			cQuery := "SELECT"											+CRLF
			cQuery += "		BM_GRUPO	  AS GRUPO,"					+CRLF
			cQuery += "		BM_DESC		  AS DESCRICAO,"				+CRLF
			cQuery += "		SUM(D2_TOTAL) AS TOTAL"						+CRLF
			cQuery += "	FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"		+CRLF
			cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"	+CRLF
			cQuery += "		ON  SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"	+CRLF
			cQuery += "		AND SB1.B1_COD     = SD2.D2_COD"			+CRLF
			cQuery += "		AND SB1.D_E_L_E_T_ = ' '"					+CRLF
			cQuery += "	INNER JOIN "+RetSqlName("SBM")+" SBM (NOLOCK)"	+CRLF
			cQuery += "		ON  SBM.BM_FILIAL  = '"+xFilial("SBM")+"'"	+CRLF
			cQuery += "		AND SBM.BM_GRUPO   = SB1.B1_GRUPO"			+CRLF
			cQuery += "		AND SBM.D_E_L_E_T_ = ' '"					+CRLF
			cQuery += "	WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"	+CRLF
			cQuery += "	  AND SD2.D2_SERIE   = '"+cSerie+"'"			+CRLF
			cQuery += "	  AND SD2.D2_DOC     = '"+cDoc+"'"				+CRLF
			cQuery += "	  AND SD2.D2_CLIENTE = '"+cCliente+"'"			+CRLF
			cQuery += "	  AND SD2.D2_LOJA    = '"+cLoja+"'"				+CRLF
			cQuery += "	  AND SD2.D_E_L_E_T_ = ' '"						+CRLF
			cQuery += "	GROUP BY SBM.BM_GRUPO,"							+CRLF
			cQuery += "			 SBM.BM_DESC"							+CRLF

			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

			If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
				Do While (cAlias)->(!Eof())
					nTotal += (cAlias)->TOTAL

					aAdd(aDetalhes,{(cAlias)->GRUPO,	; // 01 - CODIGO DO GRUPO
					(cAlias)->DESCRICAO,; // 02 - DESCRI��O DO GRUPO
					(cAlias)->TOTAL,	; // 03 - VALOR TOTAL DO GRUPO
					0}					) // 04 - PERCENTUAL DE USO

					(cAlias)->(dbSkip())
				EndDo

				For nX:=1 to Len(aDetalhes)
					aDetalhes[nX][04] := (aDetalhes[nX][03] * 100) / nTotal
				Next nX
			Else
				aAdd(aDetalhes,{"DIVERSOS",		  				; // 01 - CODIGO DA NATUREZA
				"MOVIMENTOS SEM CLASSIFICACAO",	; // 02 - DESCRI��O DA NATUREZA
				aMovimento[09],					; // 03 - VALOR TOTAL DO TITULO
				100}							) // 04 - PERCENTUAL DE USO
			EndIf
			(cAlias)->(dbCloseArea())
		else
			aAdd(aDetalhes,{"DIVERSOS",		  			; // 01 - CODIGO DA NATUREZA
			"MOVIMENTOS SEM CLASSIFICACAO",	; // 02 - DESCRI��O DA NATUREZA
			aMovimento[09],					; // 03 - VALOR TOTAL DO TITULO
			100}							) // 04 - PERCENTUAL DE USO
		EndIf

	ElseIf cCarteira == "P"
		cSerie		:= aMovimento[02]
		cDoc		:= aMovimento[03]
		cFornece	:= aMovimento[06]
		cLoja		:= aMovimento[07]
		cNatureza   := aMovimento[10]
		cTitPai		:= ""

		//->> Marcelo Celi - 23/01/2020 - regra dos rateios de impostos
		If aMovimento[05] $ cImpostos
			SE2->(dbSetOrder(1))
			If SE2->(dbSeek(aMovimento[01]+aMovimento[02]+aMovimento[03]+aMovimento[04]+aMovimento[05]+aMovimento[06]+aMovimento[07]))
				cTitPai := SE2->E2_TITPAI
				If !Empty(cTitPai) .And. SE2->(dbSeek(aMovimento[01]+cTitPai))
					cSerie		:= SE2->E2_PREFIXO
					cDoc		:= SE2->E2_NUM
					cFornece	:= SE2->E2_FORNECE
					cLoja		:= SE2->E2_LOJA
					cNatureza	:= SE2->E2_NATUREZ
				else
					cTitPai := ""
				EndIf
			EndIf
		EndIf

		If Left(cNatureza,1)=="2"
			SED->(dbSetOrder(1))
			If SED->(dbSeek(xFilial("SED")+cNatureza))
				aAdd(aDetalhes,{SED->ED_CODIGO,																; // 01 - CODIGO DA NATUREZA
				Alltrim(SED->ED_DESCRIC)+If(!Empty(cTitPai)," - TIT PRINC:"+cTitPai,""),	; // 02 - DESCRI��O DA NATUREZA
				aMovimento[09],																; // 03 - VALOR TOTAL DO TITULO
				100}																		) // 04 - PERCENTUAL DE USO
			EndIf
		Else
			cQuery := "SELECT"											+CRLF
			cQuery += "		CTD_ITEM	  AS ITEM,"						+CRLF
			cQuery += "		CTD_DESC01	  AS DESCRICAO,"				+CRLF
			cQuery += "		SUM(D1_TOTAL) AS TOTAL"						+CRLF
			cQuery += "	FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"		+CRLF
			cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"	+CRLF
			cQuery += "		ON  SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"	+CRLF
			cQuery += "		AND SB1.B1_COD     = SD1.D1_COD"			+CRLF
			cQuery += "		AND SB1.D_E_L_E_T_ = ' '"					+CRLF
			cQuery += "	INNER JOIN "+RetSqlName("CTD")+" CTD (NOLOCK)"	+CRLF
			cQuery += "		ON  CTD.CTD_FILIAL = '"+xFilial("CTD")+"'"	+CRLF
			cQuery += "		AND CTD.CTD_ITEM   = SD1.D1_ITEMCTA"		+CRLF
			cQuery += "		AND CTD.D_E_L_E_T_ = ' '"					+CRLF
			cQuery += "	WHERE SD1.D1_FILIAL  = '"+aMovimento[01]+"'"	+CRLF
			cQuery += "	  AND SD1.D1_SERIE   = '"+cSerie+"'"			+CRLF
			cQuery += "	  AND SD1.D1_DOC     = '"+cDoc+"'"				+CRLF
			cQuery += "	  AND SD1.D1_FORNECE = '"+cFornece+"'"			+CRLF
			cQuery += "	  AND SD1.D1_LOJA    = '"+cLoja+"'"				+CRLF
			cQuery += "	  AND SD1.D_E_L_E_T_ = ' '"						+CRLF
			cQuery += "	GROUP BY CTD.CTD_ITEM,"							+CRLF
			cQuery += "			 CTD.CTD_DESC01"						+CRLF

			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

			If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
				Do While (cAlias)->(!Eof())
					nTotal += (cAlias)->TOTAL

					CTD->(dbSetOrder(1))
					If CTD->(dbSeek(xFilial("CTD")+Left((cAlias)->ITEM,4)))
						aAdd(aDetalhes,{CTD->CTD_ITEM,																; // 01 - CODIGO DO ITEM
						Alltrim(CTD->CTD_DESC01)+If(!Empty(cTitPai)," - TIT PRINC:"+cTitPai,""),	; // 02 - DESCRI��O DO ITEM
						(cAlias)->TOTAL,															; // 03 - VALOR TOTAL DO ITEM
						0}																			) // 04 - PERCENTUAL DE USO
					EndIf

					(cAlias)->(dbSkip())
				EndDo

				For nX:=1 to Len(aDetalhes)
					aDetalhes[nX][04] := (aDetalhes[nX][03] * 100) / nTotal
				Next nX

			Else
				aAdd(aDetalhes,{"DIVERSOS",		  				; // 01 - CODIGO DA NATUREZA
				"MOVIMENTOS SEM CLASSIFICACAO",	; // 02 - DESCRI��O DA NATUREZA
				aMovimento[09],					; // 03 - VALOR TOTAL DO TITULO
				100}							) // 04 - PERCENTUAL DE USO
			EndIf
			(cAlias)->(dbCloseArea())

		EndIf
	EndIf

	cFilAnt	:= _cFilAnt

Return aDetalhes

/*/{protheus.doc} GetValNCC
*******************************************************************************************
Retorna o valor da NCC do titulo a receber.
 
@author: Marcelo Celi Marques
@since: 12/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetValNCC(aMovimento)
	Local _cFilAnt	:= cFilAnt
	Local nValor 	:= 0
	Local cPrefixo	:= aMovimento[02]
	Local cNumero	:= aMovimento[03]
	Local cCliente	:= aMovimento[06]
	Local cLoja		:= aMovimento[07]
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()

	cFilAnt := aMovimento[01]

	cQuery := "SELECT SUM(E1_VALOR) AS VALOR"						+CRLF
	cQuery += "		FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"		+CRLF
	cQuery += "		WHERE 	SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"	+CRLF
	cQuery += "			AND SE1.E1_PREFIXO = '"+cPrefixo+"'"		+CRLF
	cQuery += "			AND SE1.E1_NUM	   = '"+cNumero+"'"			+CRLF
	cQuery += "			AND SE1.E1_TIPO    = 'NCC'"					+CRLF
	cQuery += "			AND SE1.E1_CLIENTE = '"+cCliente+"'"		+CRLF
	cQuery += "			AND SE1.E1_LOJA    = '"+cLoja+"'"			+CRLF
	cQuery += "			AND SE1.D_E_L_E_T_ = ' '"					+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
		nValor := (cAlias)->VALOR
	EndIf
	(cAlias)->(dbCloseArea())

	cFilAnt := _cFilAnt

Return nValor

/*/{protheus.doc} GetValAbat
*******************************************************************************************
Retorna o valor do AB- do titulo a receber.
 
@author: Marcelo Celi Marques
@since: 12/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetValAbat(aMovimento)
	Local _cFilAnt	:= cFilAnt
	Local nValor 	:= 0
	Local cPrefixo	:= aMovimento[02]
	Local cNumero	:= aMovimento[03]
	LOCAL cParcela	:= aMovimento[04]
	Local cCliente	:= aMovimento[06]
	Local cLoja		:= aMovimento[07]
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()

	cFilAnt := aMovimento[01]

	cQuery := "SELECT SUM(E1_VALOR) AS VALOR"						+CRLF
	cQuery += "		FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"		+CRLF
	cQuery += "		WHERE 	SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"	+CRLF
	cQuery += "			AND SE1.E1_PREFIXO = '"+cPrefixo+"'"		+CRLF
	cQuery += "			AND SE1.E1_NUM	   = '"+cNumero+"'"			+CRLF
	cQuery += "			AND SE1.E1_PARCELA = '"+cParcela+"'"		+CRLF
	cQuery += "			AND SE1.E1_TIPO    = 'AB-'"					+CRLF
	cQuery += "			AND SE1.E1_CLIENTE = '"+cCliente+"'"		+CRLF
	cQuery += "			AND SE1.E1_LOJA    = '"+cLoja+"'"			+CRLF
	cQuery += "			AND SE1.D_E_L_E_T_ = ' '"					+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
		nValor := (cAlias)->VALOR
	EndIf
	(cAlias)->(dbCloseArea())

	cFilAnt := _cFilAnt

Return nValor

/*/{protheus.doc} GetNccxNf
*******************************************************************************************
Retorna o valor da ncc x nf
 
@author: Marcelo Celi Marques
@since: 15/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetNccxNf(cFil,cPref,cNum,cParc,Tipo,cCliente,cLoja)
	Local nValor   	:= 0
	Local aArea		:= GetArea()
	Local cQuery    := ""
	Local cAlias	:= GetNextAlias()
	Local nTam		:= Len(cPref)+Len(cNum)+Len(cParc)+Len(Tipo)

	cQuery := "SELECT SE5.E5_VALOR   AS VALOR,"									 						+CRLF
	cQuery += "       SE5.E5_TIPODOC AS TIPODOC"								 						+CRLF
	cQuery += "		FROM "+RetSqlName("SE5")+" SE5 (NOLOCK)"					  						+CRLF
	cQuery += "		WHERE   SE5.E5_FILIAL  = '"+cFil+"'"						  						+CRLF
	cQuery += "			AND SE5.E5_TIPO   NOT IN ('RA','PA')"											+CRLF
	cQuery += "			AND SE5.E5_SITUACA = ' '"           					 						+CRLF
	cQuery += "			AND LEFT(SE5.E5_DOCUMEN,"+Alltrim(Str(nTam))+") = '"+cPref+cNum+cParc+Tipo+"'"	+CRLF
	cQuery += "			AND ((SE5.E5_TIPODOC = 'BA' AND SE5.E5_RECPAG  = 'R')"							+CRLF
	cQuery += "			 OR (SE5.E5_TIPODOC = 'ES' AND SE5.E5_RECPAG  = 'P'))"							+CRLF
	cQuery += "			AND SE5.E5_MOTBX   = 'CMP'"														+CRLF
	cQuery += "			AND SE5.D_E_L_E_T_ = ' '"														+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	Do While (cAlias)->(!Eof())
		If TIPODOC == "BA"
			nValor += (cAlias)->VALOR
		ElseIf TIPODOC == "ES"
			nValor -= (cAlias)->VALOR
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return nValor

/*/{protheus.doc} AjustaSXB
*******************************************************************************************
Ajusta Consulta Padrao de Pasta.
 
@author: Marcelo Celi Marques
@since: 18/12/2019
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
	Aadd( aSXB,	{"MCPFN"	,"1"		,"01"		,"RE"			,"Pasta Grava��o da Planilha"	,"Pasta Grava��o da Planilha"	,"Pasta Grava��o da Planilha"	,"SA3"				})
	Aadd( aSXB,	{"MCPFN"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."				})
	Aadd( aSXB,	{"MCPFN"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_McGetPFN10()"	})

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

/*/{protheus.doc} McGetPFN10
*******************************************************************************************
Retorna a Pasta.
 
@author: Marcelo Celi Marques
@since: 18/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function McGetPFN10()
	Local cPasta 	:= ""

	cPasta := Alltrim( cGetFile("Diretorios", "Diretorio para a Grava��o da Planilha",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
	aRetParam[05]  := cPasta

Return
