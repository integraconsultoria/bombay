#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "ApWizard.ch"

Static cNomeArq		:= "RELATORIO_FLUXOCAIXA"

/*/{protheus.doc} IntRFFluxc
******************************************************************************************* 
Relatório de Fluxo de Caixa

@author: Marcelo Celi Marques
@since: 01/12/2019
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function IntRFFluxc()
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

	Private aRetParam 	:= {}
	Private aTpData		:= {"Realizado","A Realizar"}
	Private aTpConcil	:= {"Conciliado","Não Conciliado","Todos"}
	Private aBancos		:= {}
	Private oLbxBcos	:= NIL
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO" 	)
	Private oOk 		:= LoadBitmap( GetResources(), "LBTIK"	)    
	Private lRunDblClick:= .T.      
	Private lChkTWiz 	:= .F.
	Private nSaldo		:= 0
	Private oSaldo		:= NIL

	aAdd(aBancos,{.F.,"","","","",0})

	aRetParam := {cFilAnt,cFilAnt,30,dDatabase,Space(150),Replicate(" ",Tamsx3("E5_BANCO")[01]),Replicate(" ",Tamsx3("E5_AGENCIA")[01]),Replicate(" ",Tamsx3("E5_CONTA")[01]),Replicate("Z",Tamsx3("E5_BANCO")[01]),Replicate("Z",Tamsx3("E5_AGENCIA")[01]),Replicate("Z",Tamsx3("E5_CONTA")[01]),2,3,.T.,.T.,.F.,.F.,.F.,.T.,Space(150),Space(150),Left("ECO;"+Space(150),150),Space(150),.F.,dDatabase-1,.T.}

	aAdd(aParambox,{1,"Filial de" 										,aRetParam[01],"@!","","SM0" 	,".F.",20 ,.F.	})
	aAdd(aParambox,{1,"Filial ate" 										,aRetParam[02],"@!","","SM0" 	,".F.",20 ,.F.	})
	aAdd(aParambox,{1,"Dias" 											,aRetParam[03],"@!","","" 		,".T.",30 ,.T.	})
	aAdd(aParambox,{1,"Inicio" 											,aRetParam[04],"@!","","" 		,".F.",70 ,.F.	})
	aAdd(aParambox,{1,"Pasta Gravação"									,aRetParam[05],"@!","","MCPFN"  ,".T.",180,.T.	})
	aAdd(aParambox,{1,"Banco de" 										,aRetParam[06],"@!","","SA6" 	,".T.",30 ,.F.	})
	aAdd(aParambox,{1,"Agencia de" 										,aRetParam[07],"@!","","" 		,".T.",50 ,.F.	})
	aAdd(aParambox,{1,"Conta de" 										,aRetParam[08],"@!","","" 		,".T.",70 ,.F.	})
	aAdd(aParambox,{1,"Banco ate" 										,aRetParam[09],"@!","","SA6" 	,".T.",30 ,.F.	})
	aAdd(aParambox,{1,"Agencia ate" 									,aRetParam[10],"@!","","" 		,".T.",50 ,.F.	})
	aAdd(aParambox,{1,"Conta ate" 										,aRetParam[11],"@!","","" 		,".T.",70 ,.F.	})
	aAdd(aParambox,{2,"Considerar Fluxo" 								,aRetParam[12],aTpData,100,".F.",.F.})
	aAdd(aParambox,{2,"Considerar Movimentos" 	   						,aRetParam[13],aTpConcil,100,".T.",.T.})
	aAdd(aParambox,{5,"(+) Compor Desconto no Total do Pagamento" 		,aRetParam[14],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor Desconto no Total do Recebimento" 	,aRetParam[15],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor NCC no Total do Recebimento" 			,aRetParam[16],190,".T.",.F.})
	aAdd(aParambox,{5,"(+) Compor Abatimento no Total do Recebimento" 	,aRetParam[17],190,".T.",.F.})
	aAdd(aParambox,{5,"(-) Compor Multa no Total do Recebimento" 		,aRetParam[18],190,".T.",.F.})
	aAdd(aParambox,{5,"Extrair Juros" 									,aRetParam[19],190,".T.",.F.})
    aAdd(aParambox,{1,"Nao Clientes + Loja (Sep por ;)" 				,aRetParam[20],"@!","","" 		,".T.",180 ,.F.	})
    aAdd(aParambox,{1,"Nao Fornecedores + Loja (Sep por ;)"				,aRetParam[21],"@!","","" 		,".T.",180 ,.F.	})
    aAdd(aParambox,{1,"Nao Prefixos a Receber (Sep por ;)"				,aRetParam[22],"@!","","" 		,".T.",180 ,.F.	})
    aAdd(aParambox,{1,"Nao Prefixos a Pagar (Sep por ;)"	    		,aRetParam[23],"@!","","" 		,".T.",180 ,.F.	})	
	aAdd(aParambox,{5,"Considera Vencidos" 								,aRetParam[24],190,".T.",.F.})
	aAdd(aParambox,{1,"Vencidos a Partir " 								,aRetParam[25],"@!","","" 		,".T.",70  ,.F.	})
	//->> Marcelo Celi - 04/01/2023
	aAdd(aParambox,{5,"Boletos Recebiveis em D+1 " 						,aRetParam[26],190,".T.",.F.})

	DEFINE WIZARD oWizard ;
		TITLE "Relatórios Gerenciais do Financeiro" ;
		HEADER "Fluxo de Caixa" ;
		MESSAGE "Avance para Continuar" 		;
		TEXT "Este procedimento deverá gerar em Planilhas Eletrônicas no formato Excel, o Relatório de Fluxo de Caixa." PANEL;
	NEXT {|| .T. } ;
	FINISH {|| .T. };

CREATE PANEL oWizard ;
	HEADER "Fluxo de Caixa" ;
	MESSAGE "Informe os parametros para a Extração do Relatório" PANEL;
	NEXT {|| 	ConfProcess() } ;
	FINISH {|| 	ConfProcess() } ;
	PANEL

Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)

CREATE PANEL oWizard HEADER "Fluxo de Caixa"; 
		MESSAGE "Informe os Bancos que compõe o Fluxo" PANEL;
		BACK 	{|| .T. }; 
		NEXT 	{|| lOk:=MsgYesNo("Confirma a Geração do Fluxo"),lOk };		
		FINISH 	{|| lOk:=MsgYesNo("Confirma a Geração do Fluxo"),lOk }
				
		@ 000, 000 LISTBOX oLbxBcos FIELDS HEADER 	""								,;
					   								"Banco"							,;
													"Agencia"						,;
													"Conta"							,; 
													"Nome"							,;													
													"Saldo"							 ;
										COLSIZES 	5								,;
													25 								,;
													30 								,; 
													30 								,; 
													30 								,; 
									 				60								 ;
								SIZE (oWizard:GetPanel(3):NWIDTH/2)-2,(oWizard:GetPanel(3):NHEIGHT/2)-30;
								ON DBLCLICK (If(!Empty(aBancos[oLbxBcos:nAt,2]),aBancos[oLbxBcos:nAt,1]:=!aBancos[oLbxBcos:nAt,1],aBancos[oLbxBcos:nAt,1]:=oLbxBcos[oLbxBcos:nAt,1]),If(!aBancos[oLbxBcos:nAt,1],lChkTWiz := .F., ),oLbxBcos:Refresh(.f.),AtuSaldo()) OF oWizard:GetPanel(3) PIXEL 		
	
		oLbxBcos:SetArray(aBancos)	
		oLbxBcos:bLine := {|| {If(aBancos[oLbxBcos:nAt,1],oOK,oNO),aBancos[oLbxBcos:nAt,2],aBancos[oLbxBcos:nAt,3],aBancos[oLbxBcos:nAt,4],aBancos[oLbxBcos:nAt,5],aBancos[oLbxBcos:nAt,6]}}
		oLbxBcos:bRClicked 		:= { || AEVAL(aBancos,{|x|x[1]:=!x[1]}),oLbxBcos:Refresh(.F.),AtuSaldo()}    	
		oLbxBcos:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aBancos, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxBcos:Refresh(),AtuSaldo()}
			
		@ (oWizard:GetPanel(3):NHEIGHT/2)-26,010 MSGet oSaldo Var nSaldo Picture "@E 999,999,999,999.99"  SIZE 80,12 OF oWizard:GetPanel(3) PIXEL Hasbutton
		@ (oWizard:GetPanel(3):NHEIGHT/2)-10,010 Say "Saldo Bancário "																				 OF oWizard:GetPanel(3) PIXEL 

ACTIVATE WIZARD oWizard CENTERED

If lOk
	Processa({|x| ProcRelato(.F.) },"Processando","Aguarde, Extraindo Relatório Gerencial",.F.)
EndIf

Return

/*/{protheus.doc} AtuSaldo
*******************************************************************************************
Atualização do Saldo na Tela
 
@author: Marcelo Celi Marques
@since: 21/09/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuSaldo()
Local nX := 1

nSaldo := 0
For nX:=1 to Len(aBancos)
	If aBancos[nX,01]
		nSaldo+=aBancos[nX,06]
	EndIf
Next nX
oSaldo:Refresh()

Return

/*/{protheus.doc} ConfProcess
*******************************************************************************************
Confirma a Exportaï¿½ï¿½o dos dados
 
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
	Local cQuery := ""
	Local cAlias := ""
	Local nX	 := 0

	aBancos := {}

	If Empty(cPasta)
		MsgAlert("A Pasta destino para a gravação das Planilhas Eletrônicas não é válida ou você não tem permissão para gravar nesse local."+CRLF+"Selecione uma Pasta válida para continuar.")
		lRet := .F.
	Else
		cPasta += If(Right(cPasta,1)=="\","","\")
		cPath := cPasta+"Teste_"+Criatrab(,.F.)+".Tst"

		nHdl := fCreate(cPath)
		If nHdl <= 0
			MsgAlert("A Pasta destino para a gravação das Planilhas Eletrônicas não é válida ou você não tem permissão para gravar nesse local."+CRLF+"Selecione uma Pasta válida para continuar.")
			lRet := .F.
		Else
			fClose(nHdl)
			FErase(cPath)
		EndIf
	EndIf

	If lRet .And. aRetParam[03] <=0
		MsgAlert("Período Inválido"+CRLF+"Favor informar um periodo superior a zero dias.")
		lRet := .F.	
	EndIf

    If lRet .And. Empty(aRetParam[04])
		MsgAlert("Data Inicial inválida"+CRLF+"Favor informar uma data de inicio válida.")
		lRet := .F.	
	EndIf

	If ValType(aRetParam[12]) <> "N"
		aRetParam[12] := Ascan(aTpData,{|x| Alltrim(x)==Alltrim(aRetParam[12]) })
	EndIf

	If ValType(aRetParam[13]) <> "N"
		aRetParam[13] := Ascan(aTpConcil,{|x| Alltrim(x)==Alltrim(aRetParam[13]) })
	EndIf

	If aRetParam[12] <> 2
		MsgAlert("Somente o Fluxo a Realizar está Disponível no momento.")
		lRet := .F.
	EndIf

	If lRet
		cAlias := GetNextAlias()
		cQuery := "SELECT SA6.R_E_C_N_O_ AS RECSA6"												+CRLF
		cQuery += "	FROM "+RetSqlName("SA6")+" SA6 (NOLOCK)"									+CRLF
		cQuery += "	WHERE SA6.A6_FILIAL = '"+xFilial("SA6")+"'"									+CRLF
		cQuery += "	  AND SA6.A6_COD BETWEEN '"+aRetParam[06]+"' AND '"+aRetParam[09]+"'"		+CRLF
		cQuery += "	  AND SA6.A6_AGENCIA BETWEEN '"+aRetParam[07]+"' AND '"+aRetParam[10]+"'"	+CRLF
		cQuery += "	  AND SA6.A6_NUMCON BETWEEN '"+aRetParam[08]+"' AND '"+aRetParam[11]+"'"	+CRLF
		cQuery += "   AND SA6.D_E_L_E_T_ = ' '"													+CRLF
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		Do While (cAlias)->(!Eof())
			SA6->(dbGoto((cAlias)->RECSA6))
			aAdd(aBancos,{.T.,				;
						  SA6->A6_COD,		;
						  SA6->A6_AGENCIA,	;
						  SA6->A6_NUMCON,	;
						  SA6->A6_NOME,		;
						  0}				)
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())

		For nX:=1 to Len(aBancos)
			cQuery := "SELECT TOP 1 SE8.E8_SALATUA, SE8.E8_SALRECO, SE8.E8_DTSALAT"					+CRLF
			cQuery += "	FROM "+RetSqlName("SE8")+" SE8 (NOLOCK)"									+CRLF
			cQuery += "	WHERE SE8.E8_FILIAL  = '"+xFilial("SE8")+"'"								+CRLF
			cQuery += "	  AND SE8.E8_BANCO   = '"+aBancos[nX,02]+"'"								+CRLF
			cQuery += "	  AND SE8.E8_AGENCIA = '"+aBancos[nX,03]+"'"								+CRLF
			cQuery += "	  AND SE8.E8_CONTA   = '"+aBancos[nX,04]+"'"								+CRLF
			cQuery += "   AND SE8.E8_DTSALAT <= '"+dTos(aRetParam[04])+"'"							+CRLF
			cQuery += "   AND SE8.D_E_L_E_T_ = ' '"													+CRLF
			cQuery += " ORDER BY SE8.E8_DTSALAT DESC"												+CRLF
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
			If !(cAlias)->(Eof()) .And. !(cAlias)->(Bof())
				If aRetParam[13]==1 // Conciliado
					aBancos[nX,06] := (cAlias)->E8_SALRECO
				Else
					aBancos[nX,06] := (cAlias)->E8_SALATUA
				EndIf				
			EndIf
			If aBancos[nX,01]
				nSaldo+=aBancos[nX,06]
			EndIf
			(cAlias)->(dbCloseARea())
		Next nX

		If Len(aBancos)==0
			lRet := MsgYesNo("Não foram Localizados Bancos bancos dentre os ranges informados."+CRLF+"Deseja continuar sem os saldos do sistema ?")
			If lRet 
				aBancos := {}
				aAdd(aBancos,{.F.,"","","","",0})
				oLbxBcos:SetArray(aBancos)	
				oLbxBcos:bLine := {|| {If(aBancos[oLbxBcos:nAt,1],oOK,oNO),aBancos[oLbxBcos:nAt,2],aBancos[oLbxBcos:nAt,3],aBancos[oLbxBcos:nAt,4],aBancos[oLbxBcos:nAt,5],aBancos[oLbxBcos:nAt,6]}}
				oLbxBcos:bRClicked 		:= { || AEVAL(aBancos,{|x|x[1]:=!x[1]}), oLbxBcos:Refresh(.F.)}    	
				oLbxBcos:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aBancos, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxBcos:Refresh()}
				oLbxBcos:Refresh()
			EndIf
		Else
			oLbxBcos:SetArray(aBancos)	
			oLbxBcos:bLine := {|| {If(aBancos[oLbxBcos:nAt,1],oOK,oNO),aBancos[oLbxBcos:nAt,2],aBancos[oLbxBcos:nAt,3],aBancos[oLbxBcos:nAt,4],aBancos[oLbxBcos:nAt,5],aBancos[oLbxBcos:nAt,6]}}
			oLbxBcos:bRClicked 		:= { || AEVAL(aBancos,{|x|x[1]:=!x[1]}), oLbxBcos:Refresh(.F.)}    	
			oLbxBcos:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aBancos, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxBcos:Refresh()}
			oLbxBcos:Refresh()
		EndIf
	EndIf

	If lRet
		lRet := MsgYesNo("Confirma os Parâmetros Informados?")
	EndIf

Return lRet

/*/{protheus.doc} ProcRelato
*******************************************************************************************
Processamento do Relatï¿½rio
 
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
    dInicio	:= aRetParam[04]

    If aRetParam[12]==1
        dFim := dInicio - aRetParam[03]
    Else
	    dFim := dInicio + aRetParam[03]
    EndIf

    If lJob
		MakeDir(cPastServ)	
	EndIf

	If !lJob
		ProcRegua(0)
		IncProc("Gerando o Relatório...")
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

	//->> cabecalho de dias
	aCols  := {}
	aHeader:= GetaHeader(0,@aCabec,@aRodape,dDataDe,dDataAte)
	aDados := GetaCols(0,dDataDe,dDataAte,lJob,aReceb,aPgtos)
	aDados := aSort(aDados,,,{|x,y| x[01] < y[01]})
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
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
	Local nValNCC	:= 0
	Local nValAbat	:= 0
	Local nPos		:= 0
    Local cCliNo    := ""
	Local nValor	:= 0
	//->> Marcelo Celi - 04/01/2023	
	Local dDataTrab  := Stod("")
	Local dDataVcOri := Stod("")
	Local nDiasRet   := 0
	Local dDatcalcul := Stod("")
	Local nX		 := 1

	Private nJuros := 0

    If !Empty(aRetParam[20])
        cCliNo := Alltrim(aRetParam[20])
        cCliNo := FormatIn(cCliNo,";")
    EndIf
    
    cQuery := "SELECT * FROM ("+CRLF
	If aRetParam[12] == 1 // Fluxo Realizado
		//->> Contas a Receber
        cQuery += "SELECT"									 																	+CRLF
		cQuery += "			SE5.E5_FILIAL     AS FILIAL,"	 																	+CRLF
		cQuery += "			SE5.E5_PREFIXO 	  AS PREFIXO," 	 																	+CRLF
		cQuery += "			SE5.E5_NUMERO  	  AS NUMERO,"	 																	+CRLF
		cQuery += "			SE5.E5_PARCELA 	  AS PARCELA,"	 																	+CRLF
		cQuery += "			SE5.E5_TIPO  	  AS TIPO,"		 																	+CRLF
		cQuery += "			SE5.E5_CLIFOR  	  AS CLIFOR,"	 																	+CRLF
		cQuery += "			SE5.E5_LOJA  	  AS LOJA,"		 																	+CRLF
		cQuery += "			SE5.E5_DATA  	  AS DATA,"		 																    +CRLF		
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
        cQuery += "			'R'  	          AS CARTEIRA,"			 															+CRLF
		cQuery += "			(SELECT SE1.R_E_C_N_O_ FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"										+CRLF
		cQuery += "				WHERE SE1.E1_FILIAL  = SE5.E5_FILIAL"															+CRLF
		cQuery += "				  AND SE1.E1_PREFIXO = SE5.E5_PREFIXO"															+CRLF
		cQuery += "				  AND SE1.E1_NUM     = SE5.E5_NUMERO"															+CRLF
		cQuery += "				  AND SE1.E1_PARCELA = SE5.E5_PARCELA"															+CRLF
		cQuery += "				  AND SE1.E1_TIPO    = SE5.E5_TIPO"																+CRLF
		cQuery += "				  AND SE1.E1_CLIENTE = SE5.E5_CLIFOR"															+CRLF
		cQuery += "				  AND SE1.E1_LOJA    = SE5.E5_LOJA"																+CRLF
		cQuery += "				  AND SE1.D_E_L_E_T_ = ' ') AS RECTIT,"															+CRLF
		cQuery += "			SE5.R_E_C_N_O_ 	  AS RECSE5"		 																+CRLF
		cQuery += "	 	FROM "+RetSqlName("SE5")+" SE5 (NOLOCK)"																+CRLF
		cQuery += "		WHERE   SE5.E5_FILIAL  BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"								+CRLF
		cQuery += "			AND SE5.E5_DATA    BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"						    +CRLF		
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
		cQuery += "			AND SE5.E5_BANCO 	<> 	' ' "																		+CRLF
		cQuery += "			AND SE5.E5_NUMERO   <> 	' ' "																		+CRLF				
        If !Empty(cCliNo)
            cQuery += "			AND SE5.E5_CLIFOR + SE5.E5_LOJA NOT IN "+cCliNo	    										    +CRLF            
        EndIf
        cQuery += "			AND SE5.E5_RECPAG = 'R'"																			+CRLF		
		cQuery += "			AND SE5.D_E_L_E_T_ = ' '"																			+CRLF	
    Else // Fluxo a Realizar
		// Contas a Receber
        cQuery += "SELECT   SE1.E1_FILIAL     AS FILIAL,"   +CRLF
		cQuery += "         SE1.E1_PREFIXO 	  AS PREFIXO,"  +CRLF
		cQuery += "         SE1.E1_NUM  	  AS NUMERO,"   +CRLF
		cQuery += "         SE1.E1_PARCELA 	  AS PARCELA,"  +CRLF
		cQuery += "         SE1.E1_TIPO  	  AS TIPO,"     +CRLF
		cQuery += "         SE1.E1_CLIENTE    AS CLIFOR,"   +CRLF
		cQuery += "         SE1.E1_LOJA  	  AS LOJA,"     +CRLF
		cQuery += "         SE1.E1_VENCREA    AS DATA,"     +CRLF
		cQuery += "         SE1.E1_SALDO  	  AS VALOR,"    +CRLF
		cQuery += "         SE1.E1_DESCFIN 	  AS DESCONTO," +CRLF
		cQuery += "         SE1.E1_JUROS 	  AS JUROS,"    +CRLF
		cQuery += "         SE1.E1_VLMULTA 	  AS MULTA,"    +CRLF
		cQuery += "         SE1.E1_NATUREZ 	  AS NATUREZA," +CRLF
		cQuery += "         ''			 	  AS MOTBX,"    +CRLF
		cQuery += "         ''			 	  AS DOCUMEN,"  +CRLF
		cQuery += "         SE1.E1_NUMBCO  	  AS BANCO,"    +CRLF
		cQuery += "         SE1.E1_AGEDEP 	  AS AGENCIA,"  +CRLF
		cQuery += "         SE1.E1_CONTA  	  AS CONTA,"    +CRLF
        cQuery += "		    'R'  	          AS CARTEIRA," +CRLF
		cQuery += "         SE1.R_E_C_N_O_	  AS RECTIT,"   +CRLF
		cQuery += "         0   			  AS RECSE5"    +CRLF
		cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"+CRLF
		cQuery += " WHERE"                                  +CRLF		
		cQuery += "         SE1.E1_SALDO > 0"               +CRLF		
		cQuery += "     AND SE1.D_E_L_E_T_ <> '*' "         +CRLF
		cQuery += "     AND SE1.E1_FILIAL BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"+CRLF		
        If !Empty(cCliNo)
            cQuery += "		AND SE1.E1_CLIENTE + SE1.E1_LOJA NOT IN "+cCliNo +CRLF
        EndIf				
		If aRetParam[24]		
			cQuery += "	    AND SE1.E1_VENCREA   BETWEEN '"+dTos(aRetParam[25])+"' AND '"+dTos(dDataAte)+"'"+CRLF			
		Else
			cQuery += "	    AND SE1.E1_VENCREA   BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		EndIf
        //->> Não considerar carteira descontada
        cQuery += "     AND SE1.E1_SITUACA <> '2'"+CRLF

	EndIf
    cQuery += ") AS TMP"                +CRLF
    cQuery += "	ORDER BY TMP.FILIAL,"   +CRLF
	cQuery += "          TMP.PREFIXO,"  +CRLF
	cQuery += "          TMP.NUMERO,"   +CRLF
	cQuery += "          TMP.PARCELA,"  +CRLF
	cQuery += "          TMP.TIPO,"     +CRLF
	cQuery += "          TMP.CLIFOR,"   +CRLF
	cQuery += "          TMP.LOJA"      +CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

	ProcRegua(0)
	Do While (cAlias)->(!Eof())
		//->> Teste, tirar depois		
		//If (cAlias)->NUMERO == "000054757"
		//	MsgAlert("aqui")
		//EndIf
		
		nJuros := 0

		IncProc("Extraindo Movimentos Recebidos...")		
		If Ascan(aReceb,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[06]+x[07]==(cAlias)->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA)})==0				
			If aRetParam[12] == 1
				nValor := (cAlias)->VALOR + If(aRetParam[15], Round((cAlias)->DESCONTO,Tamsx3("E1_VALOR")[02]),0) - If(aRetParam[19],(cAlias)->JUROS,0)		
			Else								
				//nValor := (cAlias)->VALOR - If(aRetParam[15],(cAlias)->DESCONTO,0)
				nValor := (cAlias)->VALOR - If(aRetParam[15], Round((cAlias)->VALOR * ((cAlias)->DESCONTO/100),Tamsx3("E1_VALOR")[02]),0) 

				nJuros := 0
				If Alltrim(Upper((cAlias)->TIPO))=="NCC"
					nValor := nValor * -1
				Else
					If aRetParam[19] .And. Stod((cAlias)->DATA) < aRetParam[04]
						SE1->(dbGoto((cAlias)->RECTIT))
						nJuros := fa070Juros(SE1->E1_MOEDA,SE1->E1_SALDO,"SE1",SE1->E1_BAIXA)
					EndIf
				EndIf
				nValor -= nJuros
			EndIf

			//->>Marcelo Celi - 25/01/2023
			SE1->(dbGoto((cAlias)->RECTIT))
			dDataTrab := SE1->E1_VENCREA

			//->>Marcelo Celi - 04/01/2023			
			dDatcalcul := Stod((cAlias)->DATA)
			If aRetParam[26]
				SE1->(dbSetOrder(1))
				If SE1->(dbSeek((cAlias)->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO))) 
					dDataTrab := SE1->E1_VENCREA
					If FN022SITCB( SE1->E1_SITUACA )[2]
						dDataVcOri := SE1->E1_VENCTO

						//Verifico se o proximo dia util apos o vencimento eh igual ao vencto real do titulo
						//Se for igual e o titulo estiver em cobranca, aplico os dias de retencao do banco
						//Se for diferente e o titulo estiver em cobranca, quer dizer que ja foram aplicados os dias de retencao
						//logo nao aplico novamente.
						If DTOS(DataValida(dDataVcOri)) == DTOS(dDataTrab)
							SA6->(MsSeek(xFilial("SA6",SE1->E1_FILORIG)+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
							nDiasRet := SA6->A6_RETENCA
							For nX := 1 To nDiasRet
								dDataTrab := DataValida(dDataTrab+1,.T.)
								dDatcalcul:= dDataTrab
							Next
						Endif
					EndIf
				EndIf
			EndIf

			//->>Marcelo Celi - 25/01/2023
			nSaldoTit := SaldoTit(	SE1->E1_PREFIXO,	;
									SE1->E1_NUM,		;
									SE1->E1_PARCELA,	;
									SE1->E1_TIPO,		;
									SE1->E1_NATUREZA,	;
									"R",				;
									SE1->E1_CLIENTE,	;
									SE1->E1_MOEDA,		;
									SE1->E1_VENCREA,	;
									dDataTrab,			;
									SE1->E1_LOJA,		;
									,					;
									SE1->E1_TXMOEDA		)
				
			nDesconto := FaDescFin("SE1",dDataDe,nSaldoTit,1)
			nSaldoTit -= nDesconto
			nSaldoTit += ( SE1->E1_ACRESC - SE1->E1_DECRESC )
			nSaldoTit += nJuros
			
			If Alltrim(Upper((cAlias)->TIPO))=="NCC"
				nSaldoTit := nSaldoTit * -1
			EndIf

			If dDatcalcul <= dDataAte			
				aAdd(aReceb,{(cAlias)->FILIAL,																			;
					(cAlias)->PREFIXO,																					;
					(cAlias)->NUMERO,																					;
					(cAlias)->PARCELA,																					;
					(cAlias)->TIPO,																						;
					(cAlias)->CLIFOR,																					;
					(cAlias)->LOJA,																						;
					dDatcalcul,																							;
					nSaldoTit /*nValor*/,																				;
					(cAlias)->NATUREZA,																					;
					(cAlias)->BANCO,																					;
					(cAlias)->AGENCIA,																					;
					(cAlias)->CONTA,																					;
					(cAlias)->RECTIT,																					;
					(cAlias)->MOTBX,																					;
					(cAlias)->JUROS,		 																			;
					(cAlias)->DOCUMEN,																					;
					0,																									;
					0,																									;
					(cAlias)->MULTA,																					;
					(cAlias)->RECSE5,	  	 																			;
					{} })
				
				nPos := Len(aReceb)
			//	If aRetParam[16]
			//		nValNCC := GetValNCC(aReceb[nPos])
			//		nValNCC	+= GetNccxNf((cAlias)->FILIAL,(cAlias)->PREFIXO,(cAlias)->NUMERO,(cAlias)->PARCELA,(cAlias)->TIPO,(cAlias)->CLIFOR,(cAlias)->LOJA)

			//		aReceb[nPos][18] := nValNCC
			//		aReceb[nPos][09] += nValNCC
			//	EndIf
				If aRetParam[17]
					nValAbat:= GetValAbat(aReceb[nPos])
					aReceb[nPos][19] := nValAbat
					aReceb[nPos][09] += nValAbat
				EndIf
				If aRetParam[18]
					aReceb[nPos][09] -= (cAlias)->MULTA
				EndIf
			EndIf
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

	aReceb := aSort(aReceb,,,{|x,y| dTos(x[8])+x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] <=dTos(y[8])+y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})

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
    Local cForNo    := ""

    If !Empty(aRetParam[21])
        cForNo := Alltrim(aRetParam[21])
        cForNo := FormatIn(cForNo,";")
    EndIf

    cQuery := "SELECT * FROM ("+CRLF
	If aRetParam[12] == 1 // Fluxo Realizado
		cQuery += "SELECT"									 																	+CRLF
		cQuery += "			SE5.E5_FILIAL     AS FILIAL,"	 																	+CRLF
		cQuery += "			SE5.E5_PREFIXO 	  AS PREFIXO," 	 																	+CRLF
		cQuery += "			SE5.E5_NUMERO  	  AS NUMERO,"	 																	+CRLF
		cQuery += "			SE5.E5_PARCELA 	  AS PARCELA,"	 																	+CRLF
		cQuery += "			SE5.E5_TIPO  	  AS TIPO,"		 																	+CRLF
		cQuery += "			SE5.E5_CLIFOR  	  AS CLIFOR,"	    																+CRLF
		cQuery += "			SE5.E5_LOJA  	  AS LOJA,"		 																	+CRLF
		cQuery += "			SE5.E5_DATA  	  AS DATA,"		 																    +CRLF		
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
		cQuery += "				  AND SE2.D_E_L_E_T_ = ' ') AS RECTIT,"															+CRLF
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
		cQuery += "			AND SE5.E5_CLIFOR + SE5.E5_LOJA NOT IN "+cForNo 													+CRLF
		cQuery += "			AND SE5.D_E_L_E_T_ = ' '"																			+CRLF		
	else
        // Fluxo a Realizar
		cQuery += "SELECT SE2.E2_FILIAL     AS FILIAL,"+CRLF
		cQuery += " SE2.E2_PREFIXO 	  AS PREFIXO,"+CRLF
		cQuery += " SE2.E2_NUM  	  AS NUMERO,	"+CRLF
		cQuery += " SE2.E2_PARCELA 	  AS PARCELA,"+CRLF
		cQuery += " SE2.E2_TIPO  	  AS TIPO,"+CRLF
		cQuery += " SE2.E2_FORNECE    AS CLIFOR,"+CRLF
		cQuery += " SE2.E2_LOJA  	  AS LOJA,"+CRLF
		cQuery += " SE2.E2_VENCREA    AS DATA,"+CRLF
		cQuery += " SE2.E2_SALDO  	  AS VALOR,"+CRLF
		cQuery += " SE2.E2_DESCONT 	  AS DESCONTO,"+CRLF
		cQuery += " SE2.E2_JUROS 	  AS JUROS,"+CRLF
		cQuery += " SE2.E2_MULTA 	  AS MULTA,"+CRLF
		cQuery += " SE2.E2_NATUREZ 	  AS NATUREZA,"+CRLF
		cQuery += " ''			 	  AS MOTBX,	"+CRLF
		cQuery += " ''			 	  AS DOCUMEN,	"+CRLF
		cQuery += " SE2.E2_BCOPAG  	  AS BANCO,"+CRLF
		cQuery += " SE2.E2_AGECHQ 	  AS AGENCIA,"+CRLF
		cQuery += " SE2.E2_NUMBCO  	  AS CONTA,"+CRLF
		cQuery += " R_E_C_N_O_		  AS RECTIT,"+CRLF
		cQuery += " 0   			  AS RECSE5"+CRLF
		cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK)"+CRLF
		cQuery += " WHERE"+CRLF
		cQuery += " 		SE2.E2_SALDO > 0"													+CRLF
		cQuery += " 	AND SE2.D_E_L_E_T_ <> '*' "												+CRLF
		cQuery += " 	AND SE2.E2_FILIAL BETWEEN '"+aRetParam[01]+"' AND '"+aRetParam[02]+"'"	+CRLF
		If !Empty(cForNo)
			cQuery += "		AND SE2.E2_FORNECE + SE2.E2_LOJA NOT IN "+cForNo+" "				+CRLF
		EndIf
		If aRetParam[24]		
			cQuery += "	    AND SE2.E2_VENCREA   BETWEEN '"+dTos(aRetParam[25])+"' AND '"+dTos(dDataAte)+"'"+CRLF			
		Else
			cQuery += "	    AND SE2.E2_VENCREA   BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		EndIf
	EndIf
    cQuery += ") AS TMP"                +CRLF
    cQuery += "	ORDER BY TMP.FILIAL,"   +CRLF
	cQuery += "          TMP.PREFIXO,"  +CRLF
	cQuery += "          TMP.NUMERO,"   +CRLF
	cQuery += "          TMP.PARCELA,"  +CRLF
	cQuery += "          TMP.TIPO,"     +CRLF
	cQuery += "          TMP.CLIFOR,"   +CRLF
	cQuery += "          TMP.LOJA"      +CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

	ProcRegua(0)
	Do While (cAlias)->(!Eof())
		IncProc("Extraindo Movimentos Pagos...")
		If Ascan(aPagtos,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[06]+x[07]==(cAlias)->(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA)})==0				
			aAdd(aPagtos,{(cAlias)->FILIAL,		 																			;
				(cAlias)->PREFIXO,	 																			;
				(cAlias)->NUMERO,		 																			;
				(cAlias)->PARCELA,	 																			;
				(cAlias)->TIPO,		 																			;
				(cAlias)->CLIFOR,	 																			;
				(cAlias)->LOJA,		 																			;
				Stod((cAlias)->DATA),	 								   											;
				(cAlias)->VALOR + If(aRetParam[14],(cAlias)->DESCONTO,0) - If(aRetParam[19],(cAlias)->JUROS,0),	;
				(cAlias)->NATUREZA,	 																			;
				(cAlias)->BANCO,		 																			;
				(cAlias)->AGENCIA,	 																			;
				(cAlias)->CONTA,		 																			;
				(cAlias)->RECTIT,																					;
				(cAlias)->MOTBX,		 																			;
				(cAlias)->JUROS,		 																			;
				(cAlias)->DOCUMEN,																				;
				(cAlias)->RECSE5,																					;
				{} })
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

	aPagtos := aSort(aPagtos,,,{|x,y| dTos(x[8])+x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] <=dTos(y[8])+y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})

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
	Local aTmpRec	:= {}
	Local aTmpPag	:= {}
	Local aDadData  := {}
	Local nX	 	:= 1
	Local nY		:= 1
	Local dX		:= Stod("")
	Local nPosEnt	:= 0
	Local nDia		:= 0
	Local nTotal	:= 0
	Local nPosData  := 0
	
	// Fluxo diário
	If nTipo == 0
		aDadTmp := {}
		aAdd(aDadTmp,"")
		aAdd(aDadTmp,nSaldo)
		aAdd(aDadTmp,0)

		aAdd(aTmpRec,"")
		aAdd(aTmpRec,nSaldo)
		aAdd(aTmpRec,0)

		aAdd(aTmpPag,"")
		aAdd(aTmpPag,nSaldo)
		aAdd(aTmpPag,0)

		aAdd(aDadData,Stod(""))
		aAdd(aDadData,Stod(""))
		aAdd(aDadData,aRetParam[04]-1)
		For dX := dDataDe to dDataAte
			aAdd(aDadTmp,0)
			aAdd(aTmpRec,0)
			aAdd(aTmpPag,0)
			aAdd(aDadData,dX)
		Next dX
		aAdd(aTmpRec,0)
		aAdd(aTmpRec,0)

		aAdd(aTmpPag,0)
		aAdd(aTmpPag,0)

		aAdd(aDadTmp,0)
		aAdd(aDadTmp,0)

		aAdd(aDadData,Stod(""))
		aAdd(aDadData,Stod(""))

		//->> Composição dos Rcebimentos		
		For nX:=1 to Len(aReceb)
			If aReceb[nX][08] >= aRetParam[04]
				nDia := (aReceb[nX][08] - dDataDe) + 2
			Else
				nDia := 1
			EndIf
			aDadTmp[nDia+If(aRetParam[12]==1,2,2)]+=aReceb[nX][09]
		Next nX
						
		//->> Composição dos Pagamentos				
		For nX:=1 to Len(aPgto)
			If aPgto[nX][08] >= aRetParam[04]
				nDia := (aPgto[nX][08] - dDataDe) + 2
			Else
				nDia := 1
			EndIf
			aDadTmp[nDia+If(aRetParam[12]==1,2,2)]-=aPgto[nX][09]			
		Next nX
				
		//->> Adequação dos valores do fluxo
		For nX:=4 to Len(aDadTmp)-2
			//aDadTmp[nX] := aDadTmp[nX-1]+aDadTmp[nX]
			If nX==4
				aDadTmp[nX] := aDadTmp[2]+aDadTmp[nX]
			Else
				aDadTmp[nX] := aDadTmp[nX-1]+aDadTmp[nX]
			EndIf			
		Next nX
		
		//->> Fluxo Montado
		aAdd(aDados,aDadTmp)
	EndIf

	// Recebidos 
	If nTipo == 2
		For nX:=1 to Len(aReceb)
			//->> Extrai Detalhes
			IncProc("Extraindo Movimentos Recebidos...")
			
			//nDia := Day(aReceb[nX][08])
			If aReceb[nX][08] >= aRetParam[04]
				nDia := (aReceb[nX][08] - dDataDe) + 2
			Else
				nDia := 1
			EndIf	
			
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
					aAdd(aDadTmp,0)
					For dX := dDataDe to dDataAte
						aAdd(aDadTmp,0)
					Next dX
					aAdd(aDadTmp,0)
					aAdd(aDadTmp,0)

					aAdd(aDados,aDadTmp)
					nPosEnt := Len(aDados)
				EndIf
				aDados[nPosEnt][nDia+If(aRetParam[12]==1,2,2)]+= Round((aReceb[nX][09] * (aDetalhes[nY][04] / 100)),2)
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
						aAdd(aDadTmp,0)
						For dX := dDataDe to dDataAte
							aAdd(aDadTmp,0)
						Next dX
						aAdd(aDadTmp,0)
						aAdd(aDadTmp,0)

						aAdd(aDados,aDadTmp)
						nPosEnt := Len(aDados)
					EndIf
					aDados[nPosEnt][nDia+If(aRetParam[12]==1,2,2)] += Round(aReceb[nX][16],2)
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

			//nDia := Day(aPgto[nX][08])			
			If aPgto[nX][08] >= aRetParam[04]
				nDia := (aPgto[nX][08] - dDataDe) + 2
			Else
				nDia := 1
			EndIf	

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
					aAdd(aDadTmp,0)
					For dX := dDataDe to dDataAte
						aAdd(aDadTmp,0)
					Next dX
					aAdd(aDadTmp,0)
					aAdd(aDadTmp,0)

					aAdd(aDados,aDadTmp)
					nPosEnt := Len(aDados)
				EndIf
				aDados[nPosEnt][nDia+If(aRetParam[12]==1,2,2)] 				+= Round((aPgto[nX][09] * (aDetalhes[nY][04] / 100)),2)
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
					aDados[nPosEnt][nDia+If(aRetParam[12]==1,2,2)] += Round(aPgto[nX][16],2)
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
		If aRetParam[12] == 1
			aAdd(aCabec,{2,Upper("Fluxo Diario Realizados entre "+dToc(dDataDe)+" e "+dToc(dDataAte)),"@E!",300,"C","s01"})
		Else
			aAdd(aCabec,{2,Upper("Fluxo Diario a Realizar entre "+dToc(dDataDe)+" e "+dToc(dDataAte)),"@E!",300,"C","s01"})			
		EndIf
		
		If aRetParam[12] == 2
			aAdd(aCabec,{1,"Atrasados","@E!",080,"C","s01"})
		EndIf

		For dX := dDataDe to dDataAte
			aAdd(aCabec,{1,GetSemana(dX),"@E!",080,"C","s01"})
		Next dX
		aAdd(aCabec,{1,"","@E!",080,"C","s01"})
		aAdd(aCabec,{1,"","@E!",080,"C","s01"})

		//->> Dados
		aAdd(aHeader,{"","CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Saldo em: "+dToc(dDataDe-1),"CPO2", "@E!",140,"N",'"s02"',"s01","N"})

		If aRetParam[12] == 2
			aAdd(aHeader,{"( < "+StrZero(Day(aRetParam[04]),2)+"/"+StrZero(Month(aRetParam[04]),2)+" )","CPO3", "@E!",140,"N",'"s02"',"s01","N"})
			nCpo := 4
		Else
			nCpo := 3
		EndIf
		
		For dX := dDataDe to dDataAte
			aAdd(aHeader,{StrZero(Day(dX),2)+"/"+StrZero(Month(dX),2),"CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
			nCpo++
		Next dX
		aAdd(aHeader,{"Acumulado","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
		nCpo++
		aAdd(aHeader,{"% do Total","CPO"+Alltrim(Str(nCpo)), "@E!",080,"N",'"s02"',"s01","N"})
	EndIf

	If nTipo == 2
		//->> Dados recebimentos por grupo
		//->> Cabecalho

		If aRetParam[12] == 1
			aAdd(aCabec,{2,"Movimentos Recebidos","@E!",300,"C","s01"})
		Else
			aAdd(aCabec,{2,"Movimentos a Receber","@E!",300,"C","s01"})
		EndIf
		aAdd(aCabec,{Day(dDataAte)+2,"","@E!",200,"C","s01"})

		aAdd(aHeader,{"Codigo"	 ,"CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descrição","CPO2", "@E!",140,"C",'"s02"',"s01","N"})

		If aRetParam[12] == 2
			aAdd(aHeader,{"","CPO3", "@E!",140,"N",'"s02"',"s01","N"})
			nCpo := 4
		Else
			nCpo := 3
		EndIf

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
		If aRetParam[12] == 1
			aAdd(aCabec,{2,"Movimentos Pagos","@E!",300,"C","s01"})
		Else
			aAdd(aCabec,{2,"Movimentos a Pagar","@E!",300,"C","s01"})
		EndIf
		aAdd(aCabec,{Day(dDataAte)+2,""	 ,"@E!",200,"C","s01"})

		aAdd(aHeader,{"Codigo"	 ,"CPO1", "@E!",060,"C",'"s02"',"s01","N"})
		aAdd(aHeader,{"Descrição","CPO2", "@E!",140,"C",'"s02"',"s01","N"})

		If aRetParam[12] == 2
			aAdd(aHeader,{"","CPO3", "@E!",140,"N",'"s02"',"s01","N"})
			nCpo := 4
		Else
			nCpo := 3
		EndIf

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
		If aRetParam[12] == 1
			aAdd(aHeader,{"Baixa"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		else
			aAdd(aHeader,{"Vencimento"	,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
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
		If aRetParam[12] == 1
			aAdd(aHeader,{"Baixa"		,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
		Else
			aAdd(aHeader,{"Vencimento"	,"CPO9", "@E!",100,"D",'"s02"',"s01","N"})
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
	Local _cFilAnt	:= cFilAnt	
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
		If aRetParam[12] == 1 // Realizado
			//->> Verificar se compensaï¿½ï¿½o.		
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
				cDocumento := aMovimento[02] + aMovimento[03] + aMovimento[04] + aMovimento[05] //->> pref + num + parc + tipÃ³
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
		Else // A Realizar
			cNatureza := aMovimento[10]
		EndIf

		SED->(dbSetOrder(1))
        If SED->(dbSeek(xFilial("SED")+cNatureza))
            aAdd(aDetalhes,{SED->ED_CODIGO,												; // 01 - CODIGO DA NATUREZA
            Alltrim(SED->ED_DESCRIC),													; // 02 - DESCRIï¿½ï¿½O DA NATUREZA
            aMovimento[09],																; // 03 - VALOR TOTAL DO TITULO
            100}																		) // 04 - PERCENTUAL DE USO
        Else
			aAdd(aDetalhes,{cNatureza,													; // 01 - CODIGO DA NATUREZA
            Alltrim("NAO LOCALIZADO"),													; // 02 - DESCRIï¿½ï¿½O DA NATUREZA
            aMovimento[09],																; // 03 - VALOR TOTAL DO TITULO
            100}																		) // 04 - PERCENTUAL DE USO
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

        SED->(dbSetOrder(1))
        If SED->(dbSeek(xFilial("SED")+cNatureza))
            aAdd(aDetalhes,{SED->ED_CODIGO,																; // 01 - CODIGO DA NATUREZA
            Alltrim(SED->ED_DESCRIC)+If(!Empty(cTitPai)," - TIT PRINC:"+cTitPai,""),	; // 02 - DESCRIï¿½ï¿½O DA NATUREZA
            aMovimento[09],																; // 03 - VALOR TOTAL DO TITULO
            100}																		) // 04 - PERCENTUAL DE USO
		Else
        	aAdd(aDetalhes,{cNatureza,													; // 01 - CODIGO DA NATUREZA
            Alltrim("NAO LOCALIZADO"),													; // 02 - DESCRIï¿½ï¿½O DA NATUREZA
            aMovimento[09],																; // 03 - VALOR TOTAL DO TITULO
            100}																		) // 04 - PERCENTUAL DE USO
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
	Aadd( aSXB,	{"MCPFN"	,"1"		,"01"		,"RE"			,"Pasta Gravaï¿½ï¿½o da Planilha"	,"Pasta Gravaï¿½ï¿½o da Planilha"	,"Pasta Gravaï¿½ï¿½o da Planilha"	,"SA3"				})
	Aadd( aSXB,	{"MCPFN"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."				})
	Aadd( aSXB,	{"MCPFN"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_InGetPFN10()"	})

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

/*/{protheus.doc} InGetPFN10
*******************************************************************************************
Retorna a Pasta.
 
@author: Marcelo Celi Marques
@since: 18/12/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function InGetPFN10()
	Local cPasta 	:= ""

	cPasta := Alltrim( cGetFile("Diretorios", "Diretorio para a Gravação da Planilha",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
	aRetParam[05]  := cPasta

Return
