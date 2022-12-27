#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "ApWizard.ch"

/*/{protheus.doc} MCAMet010A
******************************************************************************************* 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MCAMet010A()
Local oWizard, oPanel1, oPanel2
Local aParambox 	:= {} 
Local lOk		 	:= .F.
Local nMes			:= 0
Local nAno			:= 0

Private aMeses		:= {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}        
Private aPeriodos	:= GetPeriodos()
Private oPeriodos	:= NIL
Private aRetParam 	:= {}
Private oNo 		:= LoadBitmap( GetResources(), "LBNO" 	)
Private oOk 		:= LoadBitmap( GetResources(), "LBTIK"	)    
Private lRunDblClick:= .T.      
Private lChkTWiz 	:= .F.
Private _oProcess	:= NIL
Private aCols		:= {}
Private aHeader		:= {}
Private UltDoc		:= ""
Private UltSeq		:= ""
Private aColsPerc	:= {}
Private aHeadPerc	:= {}
Private oPercent	:= Nil

Aadd(aHeader,{ "Vendedor"			,"CPO01","@!"					,06,0,"",,"C","",,,,,"V" })
Aadd(aHeader,{ "Nome Vendedor"		,"CPO02","@!"					,06,0,"",,"C","",,,,,"V" })
Aadd(aHeader,{ "Cliente"			,"CPO03","@!"					,06,0,"",,"C","",,,,,"V" })
Aadd(aHeader,{ "Nome"				,"CPO04","@!"					,30,0,"",,"C","",,,,,"V" })
Aadd(aHeader,{ "Valor"				,"CPO05","@E 999,999,999,999.99",14,2,"",,"N","",,,,,"A" })

Aadd(aHeadPerc,{ "% Acumulativo"	,"CPO01","@E 999.99"			,06,2,"",,"N","",,,,,"A" })
aAdd(aColsPerc,{0,.F.})

If Month(dDatabase) == 12
	nMes := 01
	nAno := Year(dDatabase)+1
Else
	nMes := Month(dDatabase)+1
	nAno := Year(dDatabase)
EndIf

aRetParam := {nAno,nMes,0,Space(Tamsx3("CT_DESCRI")[01]),Criavar("A3_COD",.F.),Criavar("A3_COD",.F.),Stod(""),.F.}
aAdd(aParambox,{1,"Ano" 																	,aRetParam[01],"9999","","" ,".T.",30 ,.T.})
aAdd(aParambox,{2,"Mes" 																	,aRetParam[02],aMeses,100,".T.",.T.})
aAdd(aParambox,{1,"Percentual"  															,aRetParam[03],"@E 999.99","","" ,".T.",60 ,.T.})
aAdd(aParambox,{1,"Descricao"																,aRetParam[04],"@!","","" ,".T.",120 ,.T.})
aAdd(aParambox,{1,"Vendedor de" 															,aRetParam[05],"@!","","SA3" 	,".T.",40 ,.F.	})
aAdd(aParambox,{1,"Vendedor ate"															,aRetParam[06],"@!","","SA3" 	,".T.",40 ,.F.	})
aAdd(aParambox,{1,"Clientes novos superior a " 												,aRetParam[07],""  ,"","" 		,".T.",60 ,.F.	})
aAdd(aParambox,{5,"Somente Clientes Cadastrados na Data acima (nao considera vendas)"		,aRetParam[08],200,".T.",.F.})  

DEFINE WIZARD oWizard ;
	TITLE "Gerador de Metas" ;
          	HEADER "Metas de Vendas" ;
          	MESSAGE "Avance para Continuar" 		;
          	TEXT "Este procedimento devera gerar as metas de vendas para serem usadas nos Relatorios Gerenciais nas Visoes Financeiras." PANEL;
          	NEXT {|| PodeUsar(aPeriodos) } ;
          	FINISH {|| PodeUsar(aPeriodos) }; 
          	          	                            
   	CREATE PANEL oWizard ;				
          	HEADER "Metas de Vendas" ;
          	MESSAGE "Informe os parametros para a Geracao das Metas" PANEL;          	          	
          	NEXT {|| 	lOK := ConfProcess() } ;
          	FINISH {|| 	lOK := ConfProcess() } ;
          	PANEL
   	                      
   	//->> Painel superior com os dados da geracao
	oPanel1 := TPanel():New(0,0,'',oWizard:GetPanel(2), oWizard:oDlg:oFont, .T., .T.,,Rgb(210,210,210),(oWizard:GetPanel(2):NCLIENTWIDTH)/2,70,.F.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oPanel1,,.F.,.F.)
	
	//->> Painel inferior com os dados dos periodos para se basear na geracao
	oPanel2 := TPanel():New(0,0,'',oWizard:GetPanel(2), oWizard:oDlg:oFont, .T., .T.,,,(oWizard:GetPanel(2):NCLIENTWIDTH)/2,((oWizard:GetPanel(2):NCLIENTHEIGHT)/2)-70,.F.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT	      

	oPanel2A := TPanel():New(0,0,'',oPanel2, oWizard:oDlg:oFont, .T., .T.,,,((oPanel2:NCLIENTWIDTH)/2)-70,((oPanel2:NCLIENTHEIGHT)/2),.F.,.T. )
	oPanel2A:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2B := TPanel():New(0,0,'',oPanel2, oWizard:oDlg:oFont, .T., .T.,,,70,((oPanel2:NCLIENTHEIGHT)/2),.F.,.T. )
	oPanel2B:Align := CONTROL_ALIGN_RIGHT

	//->> Seleção dos meses
	@ 000, 000 LISTBOX oPeriodos FIELDS HEADER 	""								,;
					   							"Mes"							,;
												"Ano"							,;
												"Percentual"					 ;
										COLSIZES 	5							,;
													50 							,;
									 				60							,;
													60							 ;
								SIZE (oPanel2A:NWIDTH/2)-2,(oPanel2A:NHEIGHT/2)-2;
								ON DBLCLICK (If(!Empty(aPeriodos[oPeriodos:nAt,2]),(aPeriodos[oPeriodos:nAt,1]:=!aPeriodos[oPeriodos:nAt,1],AjustPerc(@aPeriodos[oPeriodos:nAt,5],aPeriodos[oPeriodos:nAt])),aPeriodos[oPeriodos:nAt,1]:=oPeriodos[oPeriodos:nAt,1]),If(!aPeriodos[oPeriodos:nAt,1],lChkTWiz := .F., ),oPeriodos:Refresh(.f.)) OF oPanel2A PIXEL
	
	oPeriodos:SetArray(aPeriodos)	
	oPeriodos:bLine 		:= {|| {If(aPeriodos[oPeriodos:nAt,1],oOK,oNO),aPeriodos[oPeriodos:nAt,2],aPeriodos[oPeriodos:nAt,3],aPeriodos[oPeriodos:nAt,5]}}

	//->> Informação dos percentuais acumulativos
	oPercent := MSNewGetDados():New(00,00,((oPanel2B:NHEIGHT)/2),((oPanel2B:NWIDTH)/2),GD_INSERT+GD_UPDATE+GD_DELETE,.T.,.T.,,,,,,,,oPanel2B,aHeadPerc,aColsPerc)
	oPercent:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE WIZARD oWizard CENTERED

If lOk	  
	_oProcess := MsNewProcess():New( {|lEnd| ProcMetas() }, 'Aguarde...', 'Gerando as Metas...', .F. )
	_oProcess:Activate() 
	If !aRetParam[08]
		If Len(aCols) > 0
			If MsgYesNo("Algumas metas nao foram geradas."+CRLF+"Deseja cria-las manualmente ?")
				Processa( {|lEnd| MetasManual() }, "Aguarde... Gerando metas manuais..." )
			EndIf
		EndIf
	else
		If Len(aCols) > 0
			Processa( {|lEnd| MetasManual() }, "Aguarde... Gerando metas manuais..." )
		Else
			MsgAlert("Nenhum Cliente Cadastrado na Data Informada...")	
		EndIf	
	EndIf		
EndIf
		
Return

/*/{protheus.doc} GetPeriodos
******************************************************************************************* 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetPeriodos()
Local aPeriodos := {}
Local cQuery    := ""
Local cAlias	:= GetNextAlias()
Local cTesVends := Upper(Alltrim(GetNewPar("MC_TESVNDS","")))

cTesVends := FormatIn(cTesVends,";")           

cQuery := "SELECT PERIODO FROM"																													+CRLF
cQuery += "		("																																+CRLF
cQuery += "		SELECT DISTINCT"																												+CRLF
cQuery += "				CAST(YEAR(F2_EMISSAO) AS VARCHAR(04)) + RIGHT('0'+CAST(MONTH(F2_EMISSAO) AS VARCHAR(02)),2)  AS PERIODO"				+CRLF
cQuery += "			FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"																					+CRLF
cQuery += "			INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK) ON  SD2.D2_FILIAL = SF2.F2_FILIAL"											+CRLF
cQuery += "			                            				  AND SD2.D2_DOC    = SF2.F2_DOC"												+CRLF
cQuery += "			                            				  AND SD2.D2_SERIE  = SF2.F2_SERIE"												+CRLF
cQuery += "			                             				  AND SD2.D_E_L_E_T_ = ' '"														+CRLF
cQuery += "			WHERE 	SF2.F2_FILIAL = '"+xFilial("SF2")+"'"																				+CRLF
cQuery += "				AND SF2.F2_TIPO = 'N'"																									+CRLF
cQuery += "				AND SD2.D2_TES IN "+cTesVends+""																						+CRLF
cQuery += "				AND SF2.D_E_L_E_T_ = ' '"																								+CRLF
cQuery += "		) AS TMP"																														+CRLF
cQuery += "ORDER BY TMP.PERIODO DESC"																											+CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
Do While (cAlias)->(!Eof())
	aAdd(aPeriodos,{  .F. , GetMes( Val(Right((cAlias)->PERIODO,2)) ) , Left((cAlias)->PERIODO,4) , (cAlias)->PERIODO , 0  })
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return aPeriodos

/*/{protheus.doc} GetMes
*******************************************************************************************
Retorna o mes
 
@author: Marcelo Celi Marques
@since: 24/02/2020
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

/*/{protheus.doc} ConfProcess
*******************************************************************************************
Confirma o processamento dos dados
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConfProcess()
Local lRet 	:= .T.

If lRet .And. aRetParam[01] < Year(dDatabase)
	MsgAlert("Ano invalido"+CRLF+"Favor informar um ano superior ou igual ao da data atual do sistema.")	
    lRet := .F.
EndIf

If ValType(aRetParam[02]) <> "N"
	aRetParam[02] := Ascan(aMeses,{|x| Alltrim(x)==Alltrim(aRetParam[02]) })
EndIf

If lRet .And. aRetParam[02] < Month(dDatabase)
	If aRetParam[01] <= Year(dDatabase)
		MsgAlert("Mes invalido"+CRLF+"Favor informar um mes superior ou igual ao da data atual do sistema.")	
	    lRet := .F.
	EndIf
EndIf
	
If lRet	
	lRet := MsgYesNo("Confirma a Geracao das metas das Visoes Gerenciais ?")
EndIf

Return lRet

/*/{protheus.doc} ProcMetas
*******************************************************************************************
Processamento da geracao das metas
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcMetas()
Local cQuery 	:= ""
Local cWherePer := ""
Local cAno		:= ""
Local cMes		:= ""
Local cDoc		:= GetDoc()
Local cSeq		:= StrZero(1,Tamsx3("CT_SEQUEN")[01])
Local cAlias	:= GetNextAlias()
Local nX	 	:= 1
Local nY	 	:= 1
Local nZ		:= 1
Local aVendedor := GetVendedor(aRetParam[05],aRetParam[06])
Local cTesVends := Upper(Alltrim(GetNewPar("MC_TESVNDS","")))
Local nTotPer	:= 0
Local nValor	:= 0
Local aPercents	:= {}
Local aPercAcul	:= {}

If !aRetParam[08]
	cTesVends := FormatIn(cTesVends,";")           

	For nX:=1 to Len(aPeriodos)
		If aPeriodos[nX,01]
			nTotPer++
			
			If !Empty(cWherePer)
				cWherePer += " OR "
			EndIf
			cAno := Left(aPeriodos[nX,04],4)
			cMes := Right(aPeriodos[nX,04],2)        
			
			cWherePer += "( YEAR(SF2.F2_EMISSAO) = "+cAno+" AND MONTH(SF2.F2_EMISSAO) = "+cMes+" )"
			
			aAdd(aPercents,aPeriodos[nX,05])
		EndIf
	Next nX

	For nX:=1 to Len(oPercent:aCols)
		If !oPercent:aCols[nX,02] .And. oPercent:aCols[nX,01] > 0
			aAdd(aPercAcul,oPercent:aCols[nX,01])
		EndIf	
	Next nX

	_oProcess:SetRegua1(Len(aVendedor)) 
	For nX:=1 to Len(aVendedor)	
		_oProcess:IncRegua1( "Gerando Metas para "+GetMes(aRetParam[02])+"/"+Alltrim(Str(aRetParam[01]))+"..." )
		LimpaMeta(aVendedor[nX,01],StrZero(aRetParam[02],2)+StrZero(aRetParam[01],4))

		_oProcess:SetRegua2(Len(aVendedor[nX,03]))
		For nY:=1 to Len(aVendedor[nX,03])
			_oProcess:IncRegua2( "Vendedor: " + Alltrim(aVendedor[nX,02]) )

			cQuery := "SELECT ISNULL((SUM(SD2.D2_TOTAL)) / "+Alltrim(Str(nTotPer))+",0)  AS VALBRUT"													+CRLF
			cQuery += "		FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"																					+CRLF
			cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK) ON  SD2.D2_FILIAL = SF2.F2_FILIAL"											+CRLF
			cQuery += "		                            				  AND SD2.D2_DOC    = SF2.F2_DOC"												+CRLF
			cQuery += "		                            				  AND SD2.D2_SERIE  = SF2.F2_SERIE"												+CRLF
			cQuery += "		                             				  AND SD2.D_E_L_E_T_ = ' '"														+CRLF
			cQuery += "		WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"																				+CRLF
			cQuery += "			AND SF2.F2_TIPO    = 'N'"																								+CRLF
			cQuery += "			AND SF2.F2_CLIENTE = '"+aVendedor[nX,03][nY,01]+"'"																		+CRLF
			cQuery += "			AND SD2.D2_TES    IN "+cTesVends+""																						+CRLF
			cQuery += "         AND ( "+cWherePer+" )"																									+CRLF
			cQuery += "			AND SF2.D_E_L_E_T_ = ' '"																								+CRLF
			
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
			Do While (cAlias)->(!Eof())
				If (cAlias)->VALBRUT > 0
					Reclock("SCT",.T.)
					SCT->CT_FILIAL 	:= xFilial("SCT")
					SCT->CT_DOC    	:= cDoc
					SCT->CT_SEQUEN 	:= cSeq
					SCT->CT_DESCRI 	:= aRetParam[04]
					SCT->CT_DATA	:= dDatabase
					SCT->CT_VEND	:= aVendedor[nX,01]
					SCT->CT_QUANT	:= 1
					
					nValor := (cAlias)->VALBRUT * (1 + aRetParam[03]/100)
					For nZ := 1 to Len(aPercents)
						nValor := nValor * (1 + aPercents[01]/100)
					Next nZ

					For nZ := 1 to Len(aPercAcul)
						nValor := nValor * (1 + aPercAcul[01]/100)
					Next nZ				
					
					SCT->CT_VALOR	:= nValor
					SCT->CT_MOEDA	:= 1
					SCT->CT_MSBLQL  := "2"
					SCT->CT_CLIENTE	:= aVendedor[nX,03][nY,01]
					SCT->CT_DATAMET := StrZero(aRetParam[02],2)+StrZero(aRetParam[01],4)
					SCT->(MsUnlock())

					cSeq := Soma1(cSeq)
					UltSeq := cSeq
					UltDoc := cDoc

				else
					//->> Itens zerados
					SA1->(dbSetOrder(1))
					If SA1->(dbSeek(xFilial("SA1")+aVendedor[nX,03][nY,01]))
						If 	Empty(aRetParam[07]) .Or. (!Empty(SA1->A1_DTCAD) .And. SA1->A1_DTCAD >= aRetParam[07])
							aAdd(aCols,{aVendedor[nX,01],						; // 01 - Codigo Vendedor
										aVendedor[nX,02],						; // 02 - Vendedor
										aVendedor[nX,03][nY,01],				; // 03 - Cliente
										SA1->A1_NOME,							; // 04 - Nome
										0,										; // 05 - Meta
										.F.})
						EndIf
					EndIf					
				EndIf
				(cAlias)->(dbSkip())
			EndDo
			(cAlias)->(dbCloseArea())
		Next nY
	Next nX
else
	_oProcess:SetRegua1(Len(aVendedor)) 
	For nX:=1 to Len(aVendedor)	
		_oProcess:IncRegua1( "Filtrando Clientes na data informada..." )

		//->> Clientes Novos
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+aVendedor[nX,03][nY,01]))
			If 	!Empty(aRetParam[07]) .And. !Empty(SA1->A1_DTCAD) .And. SA1->A1_DTCAD >= aRetParam[07]
				aAdd(aCols,{aVendedor[nX,01],						; // 01 - Codigo Vendedor
							aVendedor[nX,02],						; // 02 - Vendedor
							aVendedor[nX,03][nY,01],				; // 03 - Cliente
							SA1->A1_NOME,							; // 04 - Nome
							0,										; // 05 - Meta
							.F.})
			EndIf
		EndIf

	Next nX
EndIf

//->> Ordenar por cliente e vendedor os itens sem meta
aCols := aSort(aCols,,,{|x,y| x[02]+x[01] <= y[02]+y[01] })

Return

/*/{protheus.doc} GetVendedor
*******************************************************************************************
Retorna array com os vendedores.
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetVendedor(cVendDe,cVendAte)
Local aVendedores 	:= {}
Local cQuery 		:= ""
Local cAlias		:= GetNextAlias()
Local nPos			:= 0

cQuery := "SELECT DISTINCT * FROM ("												+CRLF
cQuery += "SELECT DISTINCT 	SA3.R_E_C_N_O_ 		AS RECSA3,"							+CRLF
cQuery += "		  			SA3.A3_COD 	 		AS CODIGO,"							+CRLF
cQuery += "		  			SA3.A3_NOME 	 	AS NOME,"							+CRLF
cQuery += "		  			SA1.A1_COD 	 		AS CLIENTE,"						+CRLF
cQuery += "		  			SA1.A1_LOJA  		AS LOJA"							+CRLF
cQuery += "	 FROM "+RetSqlName("SA3")+" SA3 (NOLOCK)"								+CRLF
cQuery += "	 INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"							+CRLF
cQuery += "			ON	SA1.A1_FILIAL  =	'"+xFilial("SA1")+"'"					+CRLF
cQuery += "			AND SA1.A1_VEND    = SA3.A3_COD"								+CRLF
cQuery += "			AND SA1.D_E_L_E_T_ = ' '"										+CRLF
cQuery += "		WHERE   SA3.A3_FILIAL = '"+xFilial("SA3")+"'"						+CRLF
cQuery += "			AND SA3.A3_COD BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'"		+CRLF
cQuery += "			AND SA3.A3_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA1.A1_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA3.D_E_L_E_T_ = ' '"										+CRLF

/*
cQuery += "UNION ALL"																+CRLF
cQuery += "SELECT DISTINCT 	SA3.R_E_C_N_O_ 		AS RECSA3,"							+CRLF
cQuery += "		  			SA3.A3_COD 	 		AS CODIGO,"							+CRLF
cQuery += "		  			SA3.A3_NOME 	 	AS NOME,"							+CRLF
cQuery += "		  			SA1.A1_COD 	 		AS CLIENTE,"						+CRLF
cQuery += "		  			SA1.A1_LOJA  		AS LOJA"							+CRLF
cQuery += "	 FROM "+RetSqlName("SA3")+" SA3 (NOLOCK)"								+CRLF
cQuery += "	 INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"							+CRLF
cQuery += "			ON	SA1.A1_FILIAL  =	'"+xFilial("SA1")+"'"					+CRLF
cQuery += "			AND SA1.A1_VEND1   = SA3.A3_COD"								+CRLF
cQuery += "			AND SA1.D_E_L_E_T_ = ' '"										+CRLF
cQuery += "		WHERE   SA3.A3_FILIAL = '"+xFilial("SA3")+"'"						+CRLF
cQuery += "			AND SA3.A3_COD BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'"		+CRLF
cQuery += "			AND SA3.A3_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA1.A1_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA3.D_E_L_E_T_ = ' '"										+CRLF
*/

cQuery += ") AS TMP"																+CRLF
cQuery += "	 ORDER BY TMP.CODIGO"													+CRLF

FwMsgRun(,{|| (	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.),;
   				(cAlias)->(dbGotop())) },;
				"Aguarde...","Filtrando Vendedores para o processamento...")

Do While (cAlias)->(!Eof())
	nPos := Ascan(aVendedores,{|x| x[01]==(cAlias)->CODIGO })
	If nPos == 0
		aAdd(aVendedores,{	(cAlias)->CODIGO,; 	// 01 - CODIGO DO VENDEDOR
							(cAlias)->NOME,; 	// 02 - NOME DO VENDEDOR
							{}})				// 03 - CLIENTES

	    nPos := Len(aVendedores)
	EndIf
	aAdd(aVendedores[nPos,03],{	(cAlias)->CLIENTE,; // 01 - CODIGO DO CLIENTE
					 			(cAlias)->LOJA})	// 02 - LOJA DO CLIENTE
	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return aVendedores

/*/{protheus.doc} PodeUsar
*******************************************************************************************
Retorna se rotina pode prosseguir.
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function PodeUsar(aPeriodos)
Local lRet := .T.

If Len(aPeriodos) > 0
	lRet := .T.
else
	MsgAlert("Nao existem periodos disponiveis para composicao das metas.")
	lRet := .F.
EndIf	

Return lRet

/*/{protheus.doc} GetDoc
*******************************************************************************************
Retorna o proximo documento
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDoc()
Local cDoc 	 := ""
Local cAlias := GetNextAlias()
Local cQuery := ""

cQuery := "SELECT TOP 1 CT_DOC FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"	+CRLF
cQuery += "	WHERE SCT.CT_FILIAL = '"+xFilial("SCT")+"'"					+CRLF
cQuery += "	ORDER BY CT_DOC DESC"										+CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
	cDoc := Soma1((cAlias)->CT_DOC)
else
	cDoc := Strzero(1,Tamsx3("CT_DOC")[01])	
EndIf	
(cAlias)->(dbCloseArea())

Return cDoc

/*/{protheus.doc} LimpaMeta
*******************************************************************************************
Limpa a Meta ja cadastrada para o periodo.
 
@author: Marcelo Celi Marques
@since: 24/02/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function LimpaMeta(cVendedor,cPeriodo,cCliente)
Local cQuery 		:= ""
Default cCliente 	:= ""

cQuery := "DELETE FROM "+RetSqlName("SCT")				+CRLF
cQuery += "	WHERE 	CT_FILIAL 	= '"+xFilial("SCT")+"'"	+CRLF
cQuery += "		AND CT_VEND 	= '"+cVendedor+"'"		+CRLF
cQuery += "		AND CT_DATAMET 	= '"+cPeriodo+"'"		+CRLF
If !Empty(cCliente)
	cQuery += "		AND CT_CLIENTE 	= '"+cCliente+"'"	+CRLF
EndIf
cQuery += "		AND D_E_L_E_T_ 	= ' '"					+CRLF

TcSqlExec(cQuery)

Return

/*/{protheus.doc} AjustPerc
*******************************************************************************************
Ajusta o Percentual Digitado.
 
@author: Marcelo Celi Marques
@since: 05/03/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustPerc(nPerc,_aPeriodo)
Local aRetPPerc := {}
Local aParamPerc:= {}

If oPeriodos:COLPOS == 4
	aRetPPerc := {nPerc}
	aAdd(aParamPerc,{1,"Percentual"  ,aRetPPerc[01],"@E 999.99","","" ,".T.",60 ,.T.})

	If _aPeriodo[01]
		If Parambox(aParamPerc,"Percentual Acumulativo - "+_aPeriodo[02]+"/"+_aPeriodo[03]	,@aRetPPerc,,,.T.,,,,,.F.,.F.)
			nPerc := aRetPPerc[01]
		EndIf
	Else
		nPerc := 0
	EndIf
else
	If !_aPeriodo[01]
		nPerc := 0
	EndIf
	
EndIf

Return

/*/{protheus.doc} MetasManual
*******************************************************************************************
Gera as metas manualmente
 
@author: Marcelo Celi Marques
@since: 05/03/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MetasManual()
Local oWizard 	:= NIL
Local oPan01	:= NIL
Local oPan02	:= NIL
Local lOk		:= .F.
Local nX		:= 1
Local cDoc		:= UltDoc
Local cSeq		:= Soma1(UltSeq)
Local cMsg1		:= "Geracao de Metas Manuais"
Local aButtons	:= {}

Private oMetas	:= NIL

aAdd(aButtons,{"PRECO"	,{|| PosiCli() },"Posicao do Cliente"}) 

DEFINE WIZARD oWizard 																			;
		TITLE "Metas Manuais"																	;
				HEADER "" 																		;	
				MESSAGE ""																		;
				TEXT cMsg1 PANEL																;
				NEXT 	{|| lOk := MsgYesNo("Confirma as metas geradas manualmente ?"), lOk } 	;
				FINISH 	{|| lOk := MsgYesNo("Confirma as metas geradas manualmente ?"), lOk }	; 		 	          	          	                            
		
			oPan01 := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:oDlg:oFont, .T., .T.,,,(oWizard:GetPanel(1):NCLIENTWIDTH)/2,20,.F.,.T. )
			oPan01:Align := CONTROL_ALIGN_TOP

			MyEnchBar(oPan01,,,aButtons,/*aButtonTxt*/,.F.,,,0,.F.)

			oPan02 := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:oDlg:oFont, .T., .T.,,,(oWizard:GetPanel(1):NCLIENTWIDTH)/2,((oWizard:GetPanel(1):NCLIENTHEIGHT)/2)-20,.F.,.T. )
			oPan02:Align := CONTROL_ALIGN_ALLCLIENT	
			
		oMetas := MSNewGetDados():New(00,00,((oPan02:NHEIGHT)/2),((oPan02:NWIDTH)/2),GD_UPDATE+GD_DELETE,.T.,.T.,,,,,,,,oPan02,aHeader,aCols)
		oMetas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oWizard:OFINISH:CCAPTION := "&Gerar"
	oWizard:OFINISH:CTITLE 	 := "&Gerar"

ACTIVATE WIZARD oWizard CENTERED

If lOk
	ProcRegua(Len(oMetas:aCols))
	For nX:=1 to Len(oMetas:aCols)
		IncProc("")

		LimpaMeta(oMetas:aCols[nX,01],StrZero(aRetParam[02],2)+StrZero(aRetParam[01],4),oMetas:aCols[nX,03])
		If !oMetas:Acols[nX,Len(oMetas:aHeader)+1] .And. oMetas:aCols[nX,05] > 0
			Reclock("SCT",.T.)
			SCT->CT_FILIAL 	:= xFilial("SCT")
			SCT->CT_DOC    	:= cDoc
			SCT->CT_SEQUEN 	:= cSeq
			SCT->CT_DESCRI 	:= aRetParam[04]
			SCT->CT_DATA	:= dDatabase
			SCT->CT_VEND	:= oMetas:aCols[nX,01]
			SCT->CT_QUANT	:= 1
			SCT->CT_VALOR	:= oMetas:aCols[nX,05]
			SCT->CT_MOEDA	:= 1
			SCT->CT_MSBLQL  := "2"
			SCT->CT_CLIENTE	:= oMetas:aCols[nX,03]
			SCT->CT_DATAMET := StrZero(aRetParam[02],2)+StrZero(aRetParam[01],4)
			SCT->(MsUnlock())

			cSeq := Soma1(cSeq)
		EndIf
	Next nX
EndIf

Return

/*/{protheus.doc} MyEnchBar
*******************************************************************************************
Botoes personalizados
 
@author: Marcelo Celi Marques
@since: 10/03/2020
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

/*/{protheus.doc} PosiCli
*******************************************************************************************
Chama a Posicao do cliente
 
@author: Marcelo Celi Marques
@since: 10/03/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function PosiCli() 
Local nPosCli 	:= Ascan(oMetas:aHeader,{|x| Alltrim(x[02])=="CPO03" })
Local cCliente	:= ""
Local aArea		:= GetArea()

If nPosCli > 0
	cCliente := oMetas:aCols[oMetas:nAt][nPosCli]
	If !Empty(cCliente)
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+cCliente))
			Finc010(2)
		EndIf
	else
		MsgAlert("Nao foi possivel acessar a posicao do cliente.")	
	EndIf	
Else
	MsgAlert("Nao foi possivel acessar a posicao do cliente.")
EndIf

RestArea(aArea)

Return
