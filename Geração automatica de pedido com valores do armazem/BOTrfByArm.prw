#INCLUDE "TOTVS.CH"
#INCLUDE "apwizard.ch"
#INCLUDE 'MSGRAPHI.CH'

/*/{protheus.doc} BOTrfByArm
*******************************************************************************************
Programa de Transfência do Armazem
 
@author: Marcelo Celi Marques
@since: 18/04/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOTrfByArm()
	Local oWizard			:= NIL
	Local aBox01Param 		:= {}
	Local cTextApres		:= ""
	Local cLogotipo     	:= GetNewpar("BO_LOGOCLI","WIZARD")
	Local lOk				:= .F.
	Local aDados			:= {}

	Private aRet01Param 	:= {}

	aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_COD")[01])	    )
	aAdd( aRet01Param, Replicate("Z",Tamsx3("B1_COD")[01])	    )
	aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_LOCPAD")[01])	)
	aAdd( aRet01Param, Replicate(" ",Tamsx3("B1_TS")[01])	    )
	aAdd( aRet01Param, Replicate(" ",Tamsx3("A1_COD")[01])	    )
	aAdd( aRet01Param, Replicate(" ",Tamsx3("A1_LOJA")[01])	    )
	aAdd( aRet01Param, Replicate(" ",Tamsx3("E4_CODIGO")[01])   )
	aAdd( aRet01Param, Replicate(" ",Tamsx3("DA0_CODTAB")[01])  )

	aAdd( aBox01Param,{1,"Produto de"								,aRet01Param[01] ,"@!"			,""	,"SB1"	,".T.",080	,.F.})
	aAdd( aBox01Param,{1,"Produto ate"								,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",080	,.F.})
	aAdd( aBox01Param,{1,"Armazem Origem"							,aRet01Param[03] ,"@!"			,""	,"NNR"	,".T.",020	,.T.})
	aAdd( aBox01Param,{1,"Tipo de Saida"							,aRet01Param[04] ,"@!"			,""	,"SF4"	,".T.",020	,.T.})
	aAdd( aBox01Param,{1,"Cliente"				        			,aRet01Param[05] ,"@!"			,""	,"SA1"	,".T.",060	,.T.})
	aAdd( aBox01Param,{1,"Loja"		            					,aRet01Param[06] ,"@!"			,""	,""	    ,".T.",020	,.F.})
	aAdd( aBox01Param,{1,"Cond Pgto"	           					,aRet01Param[07] ,"@!"			,""	,"SE4"	,".T.",040	,.T.})
//aAdd( aBox01Param,{1,"Tabela de Preço"	       					,aRet01Param[08] ,"@!"			,""	,"DA0"	,".T.",040	,.T.})

	cTextApres := "Este recurso possibilita a transferencia de produtos de um armazem para um pedido de vendas."

	oWizard := APWizard():New(  "Transferencia",                       												 ;   // chTitle  - Titulo do cabecalho
	"", 														         			     ;   // chMsg    - Mensagem do cabecalho
	"Transferencia do Armazens",     	    							 			     ;   // cTitle   - Titulo do painel de apresentacao
	cTextApres,       													 			     ;   // cText    - Texto do painel de apresentacao
	{|| .T. },          												 			     ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
	{|| .T. },              											 				 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
	.T.,             												     			     ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
	cLogotipo,          												 			     ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio
	{|| },                												 			     ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
	.F.,                  												 			     ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
	NIL  		                   										 				 )   // aCoord   - Array contendo as coordenadas da tela

	oWizard:NewPanel(   "Parametros",                          							                			 ;   // cTitle   - Tï¿½tulo do painel
	"Informe os parametros para a execução da transferência",                    			     ;   // cMsg     - Mensagem posicionada no cabecalho do painel
	{|| .T. },                						         									 ;   // bBack    - Bloco de codigo utilizado para validar o botao "Voltar"
	{|| MsgRun("Extraindo Dados...","Aguarde",{|| lOk := GetProdutos(@aDados) }), lOk }, 	     ;   // bNext    - Bloco de codigo utilizado para validar o botao "Avancar"
	{|| MsgRun("Extraindo Dados...","Aguarde",{|| lOk := GetProdutos(@aDados) }), lOk },  		 ;   // bFinish  - Bloco de codigo utilizado para validar o botao "Finalizar"
	.T.,                                              							  			   	 ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
	{|| .T. }                                            										 )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

	Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oWizard:GetPanel(2),,.F.,.F.)

//->> Ativacao do Painel
	oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
	{|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
	{|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
	{|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

	If lOk
		Processa( {|lEnd|ProcTransfer(aDados)}, "Aguarde...","Executando rotina.", .T. )
	EndIf

Return

/*/{protheus.doc} GetProdutos
*******************************************************************************************
Retorna em array, os dados extraidos dos produtos
 
@author: Marcelo Celi Marques
@since: 18/04/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetProdutos(aDados)
	Local lRet	 	:= .T.
	Local cQuery 	:= ""
	Local cAlias 	:= ""
	Local nPos      := 0

	NNR->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SA1->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	DA0->(dbSetOrder(1))

	If lRet
		lRet := NNR->(dbSeek(xFilial("NNR")+aRet01Param[03]))
		If !lRet
			MsgAlert("Armazém não Localizado...")
		EndIf
	EndIf

	If lRet
		lRet := SF4->(dbSeek(xFilial("SF4")+aRet01Param[04])) .And. SF4->F4_TIPO == "S" .And. SF4->F4_MSBLQL <> '1'
		If !lRet
			MsgAlert("Tipo de Saida não Localizado ou Bloqueado...")
		EndIf
	EndIf

	If lRet
		lRet := SA1->(dbSeek(xFilial("SA1")+aRet01Param[05]+aRet01Param[06])) .And. SA1->A1_MSBLQL <> '1'
		If !lRet
			MsgAlert("Cliente não Localizado ou Bloqueado...")
		EndIf
	EndIf

	If lRet
		lRet := SE4->(dbSeek(xFilial("SE4")+aRet01Param[07])) .And. SE4->E4_MSBLQL <> '1'
		If !lRet
			MsgAlert("Condição de Pagamento não Localizada ou Bloqueada...")
		EndIf
	EndIf

//If lRet
//    lRet := DA0->(dbSeek(xFilial("DA0")+aRet01Param[08]))
//    If !lRet
//        MsgAlert("Tabela de Preços não Localizada...")
//    EndIf
//EndIf

	If lRet
		cAlias := GetNextAlias()
		aDados := {}

		cQuery := "SELECT TOP 100 SB2.R_E_C_N_O_ AS RECSB2"												+CRLF
		cQuery += "	FROM "+RetSqlName("SB2")+" SB2 (NOLOCK)"									+CRLF
		cQuery += "	WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"'"									+CRLF
		cQuery += "	  AND SB2.B2_COD BETWEEN '"+aRet01Param[01]+"' AND '"+aRet01Param[02]+"'"	+CRLF
		cQuery += "	  AND SB2.B2_LOCAL = '"+aRet01Param[03]+"'"									+CRLF
		cQuery += "	  AND (SB2.B2_QATU - SB2.B2_QEMP - SB2.B2_RESERVA) > 0 "					+CRLF
		cQuery += "	  AND SB2.D_E_L_E_T_ = ' '	"												+CRLF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

		Do While (cAlias)->(!Eof())
			SB2->(dbGoto((cAlias)->RECSB2))
			nPos := Ascan(aDados,{|x| Alltrim(x[01]) == SB2->B2_COD })
			If nPos == 0
				aAdd(aDados,{SB2->B2_COD,0})
				nPos := Len(aDados)
			EndIf
			aDados[nPos,02] += SB2->(B2_QATU - B2_QEMP - B2_RESERVA)

			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())

		If Len(aDados) > 0
			lRet := MsgYesNo("Confirma a Geração do Pedido de Vendas de Transferência dos itens filtrados no armazém "+aRet01Param[03]+"?")
		Else
			lRet := .F.
			MsgAlert("Nao foram Localizados Produtos no Armazém "+aRet01Param[03]+" para a realização da Transferência...")
		EndIf
	EndIf

Return lRet

/*/{protheus.doc} ProcTransfer
*******************************************************************************************
Processamento da Transferencia
 
@author: Marcelo Celi Marques
@since: 18/04/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcTransfer(aDados)
	Local nX        := 1
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aItem		:= {}
	Local nVlrUnit  := 0
//	Local nVlr2Unid := 0
	Local cPedido   := ""

	Private lMSErroAuto := .F.

	ProcRegua(Len(aDados))

	aAdd(aCabec,{"C5_TIPO"  	,"N"                                    	,Nil}) 	//->> Tipo de Pedido
	aAdd(aCabec,{"C5_CLIENTE"	,SA1->A1_COD	                           	,Nil})	//->> Cliente de Faturamento
	aAdd(aCabec,{"C5_LOJACLI"	,SA1->A1_LOJA	                           	,Nil})	//->> Loja de Faturamento
	aAdd(aCabec,{"C5_CLIENT"	,SA1->A1_COD	                           	,Nil})	//->> Cliente de Entrega
	aAdd(aCabec,{"C5_LOJAENT"	,SA1->A1_LOJA	                           	,Nil})	//->> Loja de Entrega
	aAdd(aCabec,{"C5_EMISSAO"	,dDatabase		                        	,Nil})	//->> Emissao
	aAdd(aCabec,{"C5_TIPOCLI"	,SA1->A1_TIPO 	                        	,Nil})	//->> Tipo de Cliente
	aAdd(aCabec,{"C5_CONDPAG"	,SE4->E4_CODIGO	                           	,Nil})	//->> Condição de Pagamento
	aAdd(aCabec,{"C5_TIPLIB"	,"1"		                        		,Nil})	//->> Tipo de Liberacao
	aAdd(aCabec,{"C5_DESCFI"	,0			                        		,Nil})	//->> Desconto Financeiro
	aAdd(aCabec,{"C5_FRETE"	    ,0	    	                        		,Nil})	//->> Frete
	aAdd(aCabec,{"C5_DESPESA"	,0			                        		,Nil})	//->> Despesa
	aAdd(aCabec,{"C5_SEGURO"	,0		                        			,Nil})	//->> Seguro
	aAdd(aCabec,{"C5_FRETAUT"	,0		                        			,Nil})	//->> Frete Auto
	aAdd(aCabec,{"C5_MOEDA"	    ,1			                        		,Nil})	//->> Moeda
	aAdd(aCabec,{"C5_DESC1"	    ,0				                        	,Nil})	//->> Desconto

	For nX:=1 to Len(aDados)
		IncProc("Inserindo Item: "+cValToChar(nX)+" de "+cValToChar(Len(aDados)))
		PROCESSMESSAGES( )
		aItem := {}

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aDados[nX,01]))
		If SB1->B1_MSBLQL <> '1'
			//->> Marcelo Celi - 20/07/2021
			//DA1->(dbSetOrder(1))
			//If DA1->(dbSeek(xFilial("DA1")+aRet01Param[08]+SB1->B1_COD))
			//nVlrUnit := DA1->DA1_PRCVEN
			nVlrUnit := Round(u_BoGetVCust(cFilAnt,SB1->B1_COD),2)
            nVlrUnit := Iif(nVlrUnit==0,0.01,nVlrUnit)

			aAdd(aItem,{"C6_ITEM"   ,StrZEro(nX,Tamsx3("C6_ITEM")[1])   					    	,Nil}) // Item
			aAdd(aItem,{"C6_PRODUTO",SB1->B1_COD 										    		,Nil}) // Produto
			aAdd(aItem,{"C6_DESCRI" ,SB1->B1_DESC 									    			,Nil}) // Descricao do Produto
			aAdd(aItem,{"C6_UM"     ,SB1->B1_UM			    			  							,Nil}) // Unidade
			aAdd(aItem,{"C6_QTDVEN" ,aDados[nX,02]                                                  ,Nil}) // Quantidade
			aAdd(aItem,{"C6_PRCVEN" ,Round(nVlrUnit,2)   	                                        ,Nil}) // Preco Unit.
			aAdd(aItem,{"C6_PRUNIT" ,Round(nVlrUnit,2)   	                                        ,Nil}) // Preco Unit.
			aAdd(aItem,{"C6_QTDLIB ",aDados[nX,02]                                                 ,Nil}) // Quantidade Liberada
			aAdd(aItem,{"C6_TES" 	,aRet01Param[04]		        								,Nil}) // Tipo de Saida
			aAdd(aItem,{"C6_VALOR"  ,NoRound(nVlrUnit * aDados[nX,02],2 )                            ,Nil}) // Valor Tot.
			aAdd(aItem,{"C6_LOCAL"  ,aRet01Param[03]			   									,Nil}) // Almoxarifado
			aAdd(aItem,{"C6_ENTREG" ,dDatabase     	    											,Nil}) // Dt.Entrega



               /*     
            nVlr2Unid := Round(nVlrUnit,2)
            If SB1->B1_TIPCONV == "D"
                nVlr2Unid := Round(nVlr2Unid / SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
            Else
                nVlr2Unid := Round(nVlr2Unid * SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
            EndIf
            aAdd(aItem,{"C6_SEGUM" ,SB1->B1_SEGUM	                                                ,Nil}) // Segunda Unidade de Medida
            aAdd(aItem,{"C6_UNSVEN" ,nVlr2Unid  	                                                ,Nil}) // Segunda Unidade de Medida
                 */                       
			aAdd(aItens,aClone(aItem))
			//EndIf
		EndIf
	Next nX

	If Len(aCabec) > 0 .And. Len(aItens) > 0
		Begin Transaction
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)
			If lMSErroAuto
				MostraErro()
				MsgAlert("Pedido de Vendas de Transferência não foi gerado...")
			Else
				cPedido := SC5->C5_NUM
				MsgAlert("Pedido de Vendas "+cPedido+" gerado com sucesso...")
			EndIf
		End Transaction

		If !Empty(cPedido)
			MsgAlert("Pedido de Vendas de Transferência "+cPedido+" gerado com Sucesso...")
		EndIf
	Else
		MsgAlert("Pedido de Vendas de Transferência não foi gerado...")
	EndIf

Return
