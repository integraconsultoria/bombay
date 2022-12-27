#include "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} RFATR01()
Relatório de SEPARAÇÃO DE PEDIDOS

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   19/01/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
USER FUNCTION RFATR01()

//-------------------------------------------
// Declaracao de variaveis                   
//-------------------------------------------
Private oReport  := Nil
Private oSecCab1 := Nil
Private oSecCab2 := Nil
Private oSecCab3 := Nil

Private oSecItm	 := Nil
Private oSecRdp	 := Nil

Private cPerg 	  := PadR( "RFATR01", Len ( SX1->X1_GRUPO ) )
Private cTitulo   := "SEPARAÇÃO DE MATERIAL"
Private cPrograma := "rfatr01"
Private cAliasPED := ""

    //-------------------------------------------
    // (SX1) Criacao e apresentacao das perguntas
    //-------------------------------------------
    PUTSX1()
    Pergunte( cPerg, .f. )

    //-------------------------------------------
    // Criacao e apresentacao das perguntas
    //-------------------------------------------
    ReportDef()
    oReport:PrintDialog()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de SEPARAÇÃO DE PEDIDOS

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   19/01/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

    oReport := TReport():New( cPrograma, cTitulo, cPerg,{ |oReport| PrintReport(oReport)},"Impressão de cadastro de Separação de Produtos.")
    oReport:SetLandscape(.T.)
	oReport:nfontbody:=12
	oReport:SetLineHeight(70)
	oReport:SetColSpace(5,.T.)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	oReport:cFontBody := "Arial"
	oReport:lBold := .F.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.                     
	oReport:lFooterVisible := .T.
	oReport:lParamPage := .F.
	oReport:SetTotalInLine(.F.)
 	
 	
 	// CABEÇALHO - DADOS DO PEDIDO ( oSecCab1 )
 	oSecCab1:= TRSection():New( oReport, "CAB1", {"cAliasPED"}, NIL , .F., .T.)
//	TRBorder():New( oSecCab1 , 5 , , 1 ,  )

    TRCell():New( oSecCab1, "NUM_PEDIDO"	, "cAliasPED", "NÚMERO "  			, "@!", 10 )
    TRCell():New( oSecCab1, "CLIENTE"  		, "cAliasPED", "CLIENTE"  			, "@!", 60 )
    TRCell():New( oSecCab1, "NUM_PEDCLI"	, "cAliasPED", "PED. CLIENTE"  		, "@!", 15 )
    TRCell():New( oSecCab1, "PEDWEB"    	, "cAliasPED", "PED. WEB"	  		, "@!", 15 )
    TRCell():New( oSecCab1, "PBRUTO"       	, "cAliasPED", "PESO BRUTO"			, "@E 999,999.9999", 15  ) 	// PesqPict("SC5", "C5_PBRUTO" ), 15 )
    TRCell():New( oSecCab1, "VOLUME"       	, "cAliasPED", "VOL1"	     		, "@!",  5 )
    TRCell():New( oSecCab1, "ESPECIE"      	, "cAliasPED", "ESPÉCIE1"     		, "@!", 10 )
 
 	// CABEÇALHO - DADOS DO CLIENTE ( oSecCab2 )
	oSecCab2:= TRSection():New( oReport, "CAB2", {"cAliasPED"}, NIL , .F., .T.)
    TRCell():New( oSecCab2, "END"     	, "cAliasPED", "Endereço"	, "@!", 85 )
	TRCell():New( oSecCab2, "BAIRRO"   	, "cAliasPED", "Bairro"	   	, "@!", 40 )
	TRCell():New( oSecCab2, "MUNICIPIO"	, "cAliasPED", "Municipio"	, "@!", 40                  )
	TRCell():New( oSecCab2, "UF"		, "cAliasPED", "UF"			, "@!", 4                   )
	TRCell():New( oSecCab2, "CEP"     	, "cAliasPED", "CEP"	   	, PesqPict("SA1", "A1_CEP"), 15 )

	// CABEÇALHO - DADOS DO CLIENTE ( oSecCab3 )
	oSecCab3:= TRSection():New( oReport, "CAB3", {"cAliasPED"}, NIL , .F., .T.)
    TRCell():New( oSecCab3, "ENT_COD"     	, "cAliasPED", "COD. "		, "@!", 10 )
	TRCell():New( oSecCab3, "ENT_LOJA"   	, "cAliasPED", "LOJA "	   	, "@!",  4 )
	TRCell():New( oSecCab3, "ENT_NOME"   	, "cAliasPED", "NOME ENTREGA "	   	, "@!", 60 )
	oSecCab3:Cell("ENT_COD"):SetBorder("BOTTOM",,, .T.)	// aqui mgomes

 	// ITEM(NS) DO PEDIDO
    oSecItm := TRSection():New( oReport , "ITENS", {"cAliasPED"}, NIL, .F., .T. )
    TRCell():New( oSecItm, "PRODUTO"      , "cAliasPED", "Produto"		, PesqPict("SB1","B1_COD" )		, 20 ) 	//TamSX3( "C6_PRODUTO" )[1] )
    TRCell():New( oSecItm, "DESCRICAO"    , "cAliasPED", "Descrição"	, PesqPict("SB1","B1_DESC" )	, 50 /*TamSX3( "B1_DESC" )[1] */)
    TRCell():New( oSecItm, "QUANT"        , "cAliasPED", "Qtde"      	, PesqPict("SC6","C6_QTDVEN")	, TamSX3( "C6_QTDVEN" )[1] )
    TRCell():New( oSecItm, "UM"           , "cAliasPED", "UM"        	, PesqPict("SB1","B1_UM" )		, 4 )
    TRCell():New( oSecItm, "ARMAZ"        , "cAliasPED", "LC"        	, PesqPict("SB1","B1_LOCPAD")	, 4 )
    TRCell():New( oSecItm, "CHECK"        , "cAliasPED", "  "        	,                            	, 5 )
    TRCell():New( oSecItm, "SALDO"		  ,	"cAliasPED", "Físico"		, PesqPict("SB2","B2_QATU")		, 10 ) // TamSX3( "B2_QATU")[1] )
    TRCell():New( oSecItm, "VENDAS"		  ,	"cAliasPED", "Pedidos"		, PesqPict("SB2","B2_QATU"	)	, 10 ) // TamSX3( "B2_QATU")[1] )
    TRCell():New( oSecItm, "DISPONIVEL"	  ,	"cAliasPED", "Disponível"	, PesqPict("SB2","B2_QATU"	)	, 13 ) // TamSX3( "B2_QATU")[1] )
    TRCell():New( oSecItm, "LOCAL"		  ,	"cAliasPED", "Localização"	, PesqPict("SB2","B2_LOCAL"	)	, 15 )
    TRCell():New( oSecItm, "LOTE"		  ,	"cAliasPED", "Lote"			, PesqPict("SC6","C6_LOTECTL")	, 10 )

	// totalizados
	// TRFunction():New( oSecItm:Cell("PRODUTO"),NIL,"COUNT",,,,,.F.,.T.)

	// RODAPE // DADOS FISCAIS // DADOS INTERNOS
	oSecRdp := TRSection():New( oReport , "RODAPE", {"cAliasPED"}, NIL, .F., .F. )
    TRCell():New( oSecRdp, "DADOS_FISCAIS"   	, "cAliasPED", "DADOS FISCAIS"	, "@!"	,260 )
    TRCell():New( oSecRdp, "DADOS_INTERNOS"    	, "cAliasPED", "DADOS INTERNOS"	, "@!"	,260 )
	                
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport()
Relatório de SEPARAÇÃO DE PEDIDOS

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@type 	 function
	@since   19/01/2021
/*/
//-------------------------------------------------------------------
Static Function PrintReport( oReport )

LOCAL oSecCab1 := oReport:Section(1)
LOCAL oSecCab2 := oReport:Section(2)
LOCAL oSecCab3 := oReport:Section(3)
Local oSecItm  := oReport:Section(4)
Local oSecRdp  := oReport:Section(5)

LOCAL cNumPed := ""
LOCAL cLinha1, cLinha2

Local cPedCli  := ""
Local cPedWeb  := ""
Local cCodVend := ""
Local m, aDadFisc, cVolume, cEspecie

    //-------------------------------------------------
    // (cAliasSC9) Gera o alias da tabela de trabalho
    //-------------------------------------------------
    cAliasPED := GetNextAlias()

    //-------------------------------------------
    // (SX1) Perguntas de Processamento da Rotina
    //-------------------------------------------
    Pergunte( cPerg, .F. )

    //-------------------------------------------------
    // (QUERY) Monta a query de seleção dos Registros 
    //-------------------------------------------------
    If MV_PAR05 == 1		
	    BEGINSQL Alias cAliasPED

			// SOMENTE ITENS LIBERADOS
	        SELECT
		            SC9.C9_PEDIDO AS PEDIDO,
		            SC9.C9_CLIENTE AS CODCLI,
		            SC9.C9_LOJA AS LOJA,   
					SA1.A1_NOME AS CLIENTE,
					SC5.C5_CLIENT AS CLI_ENTREGA,
					SC5.C5_LOJAENT AS LOJ_ENTREGA,
					SC5.C5_VEND1 AS VENDEDOR, 
					SC5.C5_XIDECOM AS PEDWEB, 
					SC5.C5_XPEDCLI AS PEDCLI,
					SC5.C5_XDTENTR AS XDTENTR,
					SA1.A1_END AS ENDERECO,
		            SC9.C9_PRODUTO AS PRODUTO,
					SB1.B1_DESC AS DESCRICAO,
					SB1.B1_UM AS UNIDADE,
					SB1.B1_XCSGRP AS GRUPO,
		            SC9.C9_ITEM AS ITEM,
		            SC9.C9_QTDLIB AS QUANT,
		            SC9.C9_PRCVEN AS PRECO,
					( SC9.C9_QTDLIB * SC9.C9_PRCVEN ) AS ITTOTAL,	// MGOMES 10/03/2021
		            SC9.C9_LOTECTL AS LOTE,
		            SC9.C9_NUMLOTE AS SUBLOTE,
		            SC9.C9_LOCAL AS ARMAZ, 
					SB2.B2_QATU AS SALDO,
					SB2.B2_QPEDVEN AS VENDAS			
			
			FROM
					%table:SC9% SC9
					INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xfilial:SB1% AND SB1.B1_COD = SC9.C9_PRODUTO AND SB1.%notDel%
					LEFT JOIN %table:SB2% SB2 ON SB2.B2_FILIAL = %xfilial:SB2% AND SB2.B2_COD = SC9.C9_PRODUTO AND SB2.B2_LOCAL = SC9.C9_LOCAL AND SB2.%notDel%
					INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xfilial:SA1% AND SA1.A1_COD = SC9.C9_CLIENTE AND SA1.A1_LOJA = SC9.C9_LOJA AND SA1.%notDel%
					INNER JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = %xfilial:SC5% AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.C5_CLIENTE = SC9.C9_CLIENTE AND SC5.C5_LOJACLI = SC9.C9_LOJA AND SC5.%notDel%
		
		 	WHERE
		            SC9.C9_FILIAL = %xfilial:SC9%
		            AND SC9.C9_PEDIDO BETWEEN %exp:mv_par01% AND %exp:mv_par02%
		            AND SC9.C9_CLIENTE BETWEEN %exp:mv_par03% AND %exp:mv_par04%
					AND SC9.C9_DATALIB BETWEEN %exp:mv_par06% AND %exp:mv_par07%
		            AND SC9.%notDel%
		
			ORDER BY C9_FILIAL,C9_PEDIDO, SB1.B1_XCSGRP, B1_DESC, C9_ITEM,C9_PRODUTO

		ENDSQL
	
	ELSE
	
	    BEGINSQL Alias cAliasPED

			// SOMENTE ITENS LIBERADOS
	        SELECT
					SC6.C6_NUM AS PEDIDO,
					SC6.C6_CLI AS CODCLI,
					SC6.C6_LOJA AS LOJA,
					SA1.A1_NOME AS NOME_CLIENTE,
					SC5.C5_CLIENT AS CLI_ENTREGA,
					SC5.C5_LOJAENT AS LOJ_ENTREGA,
					SC5.C5_VEND1 AS VENDEDOR, 
					SC5.C5_XIDECOM AS PEDWEB, 
					SC5.C5_XPEDCLI AS PEDCLI,
					SC5.C5_XDTENTR AS XDTENTR,
					SC5.C5_VOLUME1 AS VOLUME,
					SC5.C5_ESPECI1 AS ESPECIE,
					SA1.A1_END AS ENDERECO,
					SC6.C6_PRODUTO AS PRODUTO,
					SB1.B1_DESC AS DESCRICAO,
					SB1.B1_UM AS UNIDADE,
					SB1.B1_XCSGRP AS GRUPO,
					SC6.C6_ITEM AS ITEM,
					SC6.C6_QTDVEN AS QUANT,
					SC6.C6_PRCVEN AS PRECO,
					SC6.C6_VALOR AS ITTOTAL, // MGOMES 10/03/2021
					SC6.C6_LOTECTL AS LOTE,
					SC6.C6_NUMLOTE AS SUBLOTE,
					SC6.C6_LOCAL AS ARMAZ,
					SB2.B2_QATU AS SALDO,
					SB2.B2_QPEDVEN AS VENDAS 
				
			FROM
					%table:SC6% SC6
					INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xfilial:SB1% AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.%notDel%
					LEFT JOIN %table:SB2% SB2 ON SB2.B2_FILIAL = %xfilial:SB2% AND SB2.B2_COD = SC6.C6_PRODUTO AND SB2.B2_LOCAL = SC6.C6_LOCAL AND SB2.%notDel%
					INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xfilial:SA1% AND SA1.A1_COD = SC6.C6_CLI AND SA1.A1_LOJA = SC6.C6_LOJA AND SC6.%notDel%
					INNER JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = %xfilial:SC5% AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = SC6.C6_CLI AND SC5.C5_LOJACLI = SC6.C6_LOJA AND SC5.%notDel%

			WHERE
		            SC6.C6_FILIAL = %xfilial:SC6%
		            AND SC6.C6_NUM BETWEEN %exp:mv_par01% AND %exp:mv_par02%
		            AND SC6.C6_CLI BETWEEN %exp:mv_par03% AND %exp:mv_par04%
					AND SC5.C5_EMISSAO BETWEEN %exp:mv_par06% AND %exp:mv_par07%
		            AND SC6.%notDel%
				
			ORDER BY C6_FILIAL,C6_NUM, SB1.B1_XCSGRP, B1_DESC, C6_ITEM,C6_PRODUTO

		ENDSQL
		
	EndIf
	
	DBSelectArea((cAliasPED))
	While (cAliasPED)->( !EOF() )

        oReport:IncMeter()
        IncProc( "Imprimindo ... PEDIDO: " + (cAliasPED)->PEDIDO )

		// Tratamento do título
	    oReport:cTitle := cTitulo + " PEDIDO: " + (cAliasPED)->PEDIDO
	        
		If oReport:Cancel()
			Exit
		EndIf
	    
		/* ----------------------------------------------------------------------------------------
		( CABEÇALHO ) Alimenta o conteúdo dos campos do CABEÇALHO
		---------------------------------------------------------------------------------------- */
		If (cAliasPED)->PEDIDO <> cNumPed	

			/* ----------------------------------------------------------------------------------------
			( ENDEREÇO ) Dados do clientes - ENDEREÇO DE FATURAMENTO
			---------------------------------------------------------------------------------------- */
			DBSelectArea("SA1")
			DBSetOrder(1)
			DBSeek( xFilial("SA1") + (cAliasPED)->( CODCLI + LOJA ), .f. )

			cNumPed := (cAliasPED)->PEDIDO
			cCliente:= (cAliasPED)->CODCLI + "-" + (cAliasPED)->LOJA + "  " + SA1->A1_NOME // AQUI
			cCliEnt	:= (cAliasPED)->CLI_ENTREGA + "-" + (cAliasPED)->LOJ_ENTREGA + " " + POSICIONE( "SA1", 1, xFilial("SA1") + (cAliasPED)->( CLI_ENTREGA + LOJ_ENTREGA ), "A1_NOME" ) 
			
			cEndereco := (cAliasPED)->ENDERECO

			// Alimenta variaveis usadas no rodapé
			cPedCli 	:= (cAliasPED)->PEDCLI		// PEDIDO DO CLIENTE
			cPedWeb 	:= (cAliasPED)->PEDWEB		// PEDICO WEB
			cCodVend 	:= (cAliasPED)->VENDEDOR	// CODIGO DO VENDEDOR
			dXDTENTR	:= (cAliasPED)->XDTENTR		// DATA DE ENTREGA
			cVolume     := AllTrim( STR( (cAliasPED)->VOLUME ) )	// VOLUME
			cEspecie	:= (cAliasPED)->ESPECIE		// ESPECIE

		    // inicializa a primeira seção - CABEÇALHO    
		 	oSecCab1:init()
		
			oSecCab1:Cell( "NUM_PEDIDO" ):SetValue( (cAliasPED)->PEDIDO )
			oSecCab1:Cell( "CLIENTE" ):SetValue( cCliente )	// aqui
			oSecCab1:Cell( "NUM_PEDCLI" ):SetValue( cPedCli )	// AQUI
			oSecCab1:Cell( "PEDWEB" ):SetValue( cPedWeb )	// AQUI
			oSecCab1:Cell( "PBRUTO" ):SetValue( Posicione( "SC5", 1, xFilial("SC5") + (cAliasPED)->PEDIDO, "C5_PBRUTO" ) )
			oSecCab1:Cell( "VOLUME" ):SetValue( cVolume )
			oSecCab1:Cell( "ESPECIE" ):SetValue( cEspecie )
			
		    // imprime os dados do cabeçalho   
			oSecCab1:Printline()

			cLinha1 := PadR( " Endereço: " + SA1->A1_END, 70 )
			cLinha1 += " Bairro: " + substr( SA1->A1_BAIRRO, 1, 20 )
			
			cLinha2 := PadR( " Cidade: " + AllTrim( SA1->A1_MUN ) + "-" + SA1->A1_EST, 60 )
			cLinha2 += PadR( " CEP: " + TransForm( SA1->A1_CEP, PesqPict( "SA1", "A1_CEP" ) ), 25 )
			cLinha2 += " Telefone: (" + SA1->A1_DDD +") " + TransForm( SA1->A1_TEL, PesqPict( "SA1", "A1_TEL" ) )

		    // inicializa a primeira seção - CABEÇALHO    
		 	oSecCab2:init()

		    // imprime os dados do cabeçalho   
			oSecCab2:Cell( "END" ):SetValue( SA1->A1_END )
			oSecCab2:Cell( "BAIRRO" ):SetValue( SA1->A1_BAIRRO )
			oSecCab2:Cell( "MUNICIPIO" ):SetValue( SA1->A1_MUN )
			oSecCab2:Cell( "UF" ):SetValue( SA1->A1_EST )
			oSecCab2:Cell( "CEP" ):SetValue( SA1->A1_CEP )

			oSecCab2:Printline()
			oSecCab2:Finish()

			If (cAliasPED)->CODCLI + (cAliasPED)->LOJA <> (cAliasPED)->CLI_ENTREGA + (cAliasPED)->LOJ_ENTREGA 

				DBSelectArea("SA1")
				DBSetOrder(1)
				If DBSeek( xfilial("SA1") + (cAliasPED)->CLI_ENTREGA + (cAliasPED)->LOJ_ENTREGA , .f. )

					cCliente:= (cAliasPED)->CLI_ENTREGA + "-" + (cAliasPED)->LOJ_ENTREGA + "  " + SA1->A1_NOME // AQUI

					// DADOS DE ENTREGA
				 	oSecCab3:init()

//					oSecCab3:Cell( "CLI_ENTREGA" ):SetValue( (cAliasPED)->CLI_ENTREGA )	// AQUI
					oSecCab3:Cell( "ENT_COD" ):SetValue( (cAliasPED)->CLI_ENTREGA )
					oSecCab3:Cell( "ENT_LOJA" ):SetValue( (cAliasPED)->LOJ_ENTREGA )
					oSecCab3:Cell( "ENT_NOME" ):SetValue( SA1->A1_NOME )

					oSecCab3:Printline()
					oSecCab3:Finish()

				 	oSecCab2:init()

				    // imprime os dados do cabeçalho   
					oSecCab2:Cell( "END" ):SetValue( SA1->A1_END )
					oSecCab2:Cell( "BAIRRO" ):SetValue( SA1->A1_BAIRRO )
					oSecCab2:Cell( "MUNICIPIO" ):SetValue( SA1->A1_MUN )
					oSecCab2:Cell( "UF" ):SetValue( SA1->A1_EST )
					oSecCab2:Cell( "CEP" ):SetValue( SA1->A1_CEP )
		
					oSecCab2:Printline()
					oSecCab2:Finish()

				EndIf

			EndIf 		

		EndIf		

	    // inicializo a seção do(s) ITEM(NS)
     	oSecItm:init()

		/* ----------------------------------------------------------------------------------------
		( CALCULO ) Calcula valor da quantidade DISPONÍVEL
		---------------------------------------------------------------------------------------- */
		nQtdDisp := (cAliasPED)->SALDO - (cAliasPED)->VENDAS
	      	
		/* ----------------------------------------------------------------------------------------
		( ITENS ) Alimenta o conteúdo dos campos
		---------------------------------------------------------------------------------------- */
        
		//->> Marcelo Celi - 21/09/2022
		//oSecItm:Cell( "PRODUTO" ):SetValue( (cAliasPED)->PRODUTO )       
		oSecItm:Cell( "PRODUTO" ):SetValue( StrTran((cAliasPED)->PRODUTO,".",""))

        oSecItm:Cell( "DESCRICAO" ):SetValue( (cAliasPED)->DESCRICAO )             
        oSecItm:Cell( "QUANT" ):SetValue( (cAliasPED)->QUANT )               
        oSecItm:Cell( "UM" ):SetValue( (cAliasPED)->UNIDADE )           
        oSecItm:Cell( "ARMAZ" ):SetValue( (cAliasPED)->ARMAZ )             
        oSecItm:Cell( "CHECK" ):SetValue( "[  ]" )        
      
		oSecItm:Cell( "SALDO" ):SetValue( (cAliasPED)->SALDO )
		oSecItm:Cell( "VENDAS" ):SetValue( (cAliasPED)->VENDAS )
		oSecItm:Cell( "DISPONIVEL" ):SetValue( nQtdDisp )

		oSecItm:Cell( "LOCAL"):SetValue( "" )
		oSecItm:Cell( "LOTE"):SetValue( (cAliasPED)->LOTE )

		oSecItm:Printline()
		oReport:ThinLine()	

        (cAliasPED)->( DBSkip() )
  
		/* ----------------------------------------------------------------------------------------
		( QUEBRA ) Quebra de Página / RODAPE DO PEDIDO
		---------------------------------------------------------------------------------------- */
		If (cAliasPED)->PEDIDO <> cNumPed .or. (cAliasPED)->( EOF() )

			aDadFisc := {}
		    // texto dos dados fiscais

			// PEDIDO E VENDEDOR
			cDadFisc	:= ""
			cDadFisc	+= " PEDIDO No: " + cNumPed 
			If !EMPTY( cCodVend )
				cDadFisc += " VEND: " + cCodVend 
				cDadFisc += " " + SUBSTR( POSICIONE( "SA3", 1, xFilial("SA3") + cCodVend, "A3_NOME" ), 1, 30 )
			EndIf
			Aadd( aDadFisc, cDadFisc )

			// DATA DE ENTREGA
			cDadFisc := ""
			If !EMPTY( dXDTENTR)
				cDadFisc += " DATA ENTREGA: " + DtoC( StoD( dXDTENTR ) )
 			EndIf
			If !EMPTY( cPedCli )
				cDadFisc += " S/ PED: " + cPedCli
			EndIf
			Aadd( aDadFisc, cDadFisc )


			For m := 1 to len( aDadFisc ) 
				// inicializo a segunda seção    
				oSecRdp:init()
				oSecRdp:Cell( "DADOS_FISCAIS" ):SetValue( aDadFisc[m] )
	//	  	    oSecRdp:Cell( "DADOS_INTERNOS"):SetValue( "" )
				oSecRdp:Printline()
			next m

			// Finaliza a seção do Item 
	 	 	oSecRdp:Finish()
			
			// Finaliza a seção do Item 
 			oSecItm:Finish()

 			// Finaliza a seção do cabeçalho
 			oSecCab1:Finish()

			oReport:EndPage()     // Finaliza a página 

		Endif
		
	EndDo 

 	// Finaliza a seção do Item 
 	oSecItm:Finish()

 	// Finaliza a seção do cabeçalho
 	oSecCab1:Finish()
	
	/* ----------------------------------------------------------------------------------------
	( CONTEUDO ) Fecha a area de trabalho aberta
	---------------------------------------------------------------------------------------- */
	If SELECT( (cAliasPed) ) > 0
		DBSelectArea( (cAliasPed) )
		DBCloseArea()
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PUTSX1()
Relatório de SEPARAÇÃO DE PEDIDOS

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   28/01/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
// https://tdn.totvs.com/pages/viewpage.action?pageId=22479548
Static Function PUTSX1()

LOCAL s, x
LOCAL aCabSX1 := {} // CAMPOS DA TABELA SX1
LOCAL aRegSX1 := {} // PERGUNTAS DA TABELA SX1

    //--------------------------------------------------------------------
    // Criacao do ARRAY CABECALHO com os campos da tabela SX1 - PERGUNTAS
    //--------------------------------------------------------------------
    //            1           2             3            4            5             6          7             8             9            10        11          12          13          14           15           16          17          18          19            20            21         22          23          24            25            26          27          28          29            30            31         32          33          34            35            36         37       38         39           40         41            42
    aCabSX1 := { "X1_ORDEM", "X1_PERGUNT", "X1_PERSPA", "X1_PERENG", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL", "X1_GSC", "X1_VALID", "X1_VAR01", "X1_DEF01", "X1_DEFSPA1", "X1_DEFENG1","X1_CNT01", "X1_VAR02", "X1_DEF02", "X1_DEFSPA2", "X1_DEFENG2", "X1_CNT2", "X1_VAR03", "X1_DEF03", "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT3", "X1_VAR04", "X1_DEF04", "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT4", "X1_VAR05", "X1_DEF05", "X1_DEFSPA5", "X1_DEFENG5", "X1_CNT5", "X1_F3", "X1_PYME", "X1_GRPSXG", "X1_HELP", "X1_PICTURE", "X1_IDFIL" } 

    //------------------------------------------------
    // Criacao do ARRAY com as perguntas do RELATORIO
    //------------------------------------------------
    //                1     2                                3                                 4                                5        6   7                            8 9 10 11  12        13                14 15 16 17 18                19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36  37   38 39  40  41   42
    Aadd( aRegSX1, { "01", "Do Pedido ?                  ", "¿ De Pedido ?                 ", "Order from ?                  ","mv_ch1","C", TamSx3( "C9_PEDIDO" )[1]    ,0,,"G","","mv_par01","               ","","","","","               ","","","","","","","","","","","","","","","","","","","SC5","","", "", "" , "" } )
    Aadd( aRegSX1, { "02", "Ate o Pedido ?               ", "¿ A Pedido ?                  ", "Order to ?                    ","mv_ch2","C", TamSx3( "C9_PEDIDO" )[1]    ,0,,"G","","mv_par02","               ","","","","","               ","","","","","","","","","","","","","","","","","","","SC5","","", "", "" , "" } )
    Aadd( aRegSX1, { "03", "Do Cliente ?                 ", "¿ Del Cliente ?               ", "From customer ?               ","mv_ch3","C", TamSx3( "C9_CLIENTE" )[1]   ,0,,"G","","mv_par03","               ","","","","","               ","","","","","","","","","","","","","","","","","","","CLI","","", "", "" , "" } )
    Aadd( aRegSX1, { "04", "Ate o Cliente ?              ", "¿ A Cliente ?                 ", "To customer ?                 ","mv_ch4","C", TamSx3( "C9_CLIENTE" )[1]   ,0,,"G","","mv_par04","               ","","","","","               ","","","","","","","","","","","","","","","","","","","CLI","","", "", "" , "" } )  
	Aadd( aRegSX1, { "05", "Somente Liberados ?          ", "¿ A Cliente ?                 ", "To customer ?                 ","mv_ch5","N", 1                           ,0,,"C","","mv_par05","SIM            ","","","","","NAO            ","","","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
    Aadd( aRegSX1, { "06", "Da Data ?                    ", "¿ Fecha De ?                  ", "From Date ?                   ","mv_ch6","D", TamSx3( "C9_DATALIB" )[1]   ,0,,"G","","mv_par03","               ","","","","","               ","","","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
    Aadd( aRegSX1, { "07", "Ate a Data ?                 ", "¿ Fecha A ?                   ", "To Date ?                     ","mv_ch7","D", TamSx3( "C9_DATALIB" )[1]   ,0,,"G","","mv_par04","               ","","","","","               ","","","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )  

    For s := 1 To Len( aRegSX1 )
        DBSelectArea("SX1")
        If !DBSeek( cPerg + aRegSX1[s][1], .f. )
            RECLOCK( "SX1", .t. )
                SX1->X1_GRUPO   := cPerg
                for x := 1 To len( aCabSX1 )
                    SX1->&( aCabSX1[x] ) := aRegSX1[s][x]
                next x
            MSUNLOCK()
        Endif
    Next s

/*
      Local aHelpPor :={}
      Local aHelpEng :={}
      Local aHelpEsp :={}
      //Problema
      aHelpPor := {"Arquivo de Modelo nao encontrado."}
      aHelpEng := {"Template file not found."}
      aHelpSpa := {"Archivo de plantilla no se encuentra."}
    PutHelp("PMATA17704",aHelpPor,aHelpEng,aHelpEsp,.T.)

*/
Return
