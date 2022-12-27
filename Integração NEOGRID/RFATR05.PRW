#INCLUDE "rwmake.ch"
#Define ENTER Chr(13)+Chr(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} RFATR05()
Relatório de PEDIDOS EDI 

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   17/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
USER FUNCTION RFATR05

//-------------------------------------------
// Declaracao de variaveis                   
//-------------------------------------------
	Private oReport  := nil

	Private oSecCab1 := Nil
	Private oSecItm1 := Nil

	Private cPerg 	  := PadR( "RFATR05", Len ( SX1->X1_GRUPO ) )
	Private cTitulo   := "RELATÓRIO PEDIDO DE VENDA - EDI-NEOGRID  "
	Private cPrograma := "RFATR05"

	//-------------------------------------------
	// (SX1) Criacao e apresentacao das perguntas
	//-------------------------------------------
	//PUTSX1()
	//Pergunte( cPerg, .f. )

	//-------------------------------------------
	// Criacao e apresentacao das perguntas
	//-------------------------------------------
	ReportDef()
	oReport:PrintDialog()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de PEDIDOS EDI 

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   17/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

	oReport := TReport():New( cPrograma, cTitulo, cPerg,{ |oReport| PrintReport(oReport)},"Impressão de cadastro de produtos em TReport simples.")
	oReport:SetLandscape(.T.)
	oReport:nfontbody:=9
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

	// Carrega as Perguntas de Processamento do Relatório
	Pergunte( oReport:uParam, .F. )

	// CABEÇALHO - DADOS DO PEDIDO ( oSecCab1 )
	oSecCab1:= TRSection():New( oReport, "CAB1", {"cAliasPED"}, NIL , .F., .T.)

	TRCell():New( oSecCab1, "NUM_PEDIDO"	    , "cAliasPED", "NUMERO "  			, "@!", 25 )
	TRCell():New( oSecCab1, "DATA_EMISSAO"	    , "cAliasPED", "EMISSAO "  			, "@!", 10 )
	TRCell():New( oSecCab1, "HORA_EMISSAO"      , "cAliasPED", "HORA "  			, "@!", 08 )
	TRCell():New( oSecCab1, "CNPJ_COMPRADOR"	, "cAliasPED", "CNPJ COMPRADOR "	, PesqPict( "SA1", "A1_CGC" ), 26 )
	TRCell():New( oSecCab1, "COD_COMPRADOR"	    , "cAliasPED", "CODIGO "  			, "@!", 15 )
	TRCell():New( oSecCab1, "NOME_COMPRADOR"    , "cAliasPED", "NOME DO COMPRADOR "	, "@!", 38 )
	TRCell():New( oSecCab1, "PED_PROTHEUS"      , "cAliasPED", "NUM. PEDIDO "    	, "@!", 08 )
	TRCell():New( oSecCab1, "ID"                , "cAliasPED", "ID "               	, "@!", 08 )
	TRCell():New( oSecCab1, "FUNC_PEDIDO"       , "cAliasPED", "FUNCAO "            , PesqPict( "SZ1", "Z0_FUNCMSG")    , 30 )
	TRCell():New( oSecCab1, "TIPO_PEDIDO"       , "cAliasPED", "TIPO DE PEDIDO "   	, "@!", 35 )

	// ITENS - DADOS DO PEDIDO ( oSecItm1 )
	oSecItm1:= TRSection():New( oReport, "ITEM1", {"SZ1"}, NIL , .F., .T.)

	TRCell():New( oSecItm1, "PED_ITEM"	    , "cAliasPED", "Item"  			, PesqPict("SZ1", "Z1_ITEM"), 04 )
	TRCell():New( oSecItm1, "COD_EAN"	    , "cAliasPED", "EAN"     		, PesqPict("SB1", "B1_CODBAR"), 20 )
	TRCell():New( oSecItm1, "COD_PROD"	    , "cAliasPED", "Código" 		, PesqPict("SZ1", "Z1_CODPROD"), 16 )
	TRCell():New( oSecItm1, "DESC_PROD"	    , "cAliasPED", "Descrição" 		, "@!", 50 )
	TRCell():New( oSecItm1, "UN_MEDIDA"	    , "cAliasPED", "UM"      		, "@!", 02 )

	//   TRCell():New( oSecItm1, "QTDE_PED"	    , "cAliasPED", "Qtde Pedida"	    , PesqPict( "SZ1", "Z1_QTDPED")     , TAMSX3("Z1_QTDPED")[1] )
	//   TRCell():New( oSecItm1, "QTDE_BON"	    , "cAliasPED", "Qtde Bonificada"	, PesqPict( "SZ1", "Z1_QTDBONI")    , TAMSX3("Z1_QTDBONI")[1] )
	//   TRCell():New( oSecItm1, "QTDE_TRO"	    , "cAliasPED", "Qtde Troca"	        , PesqPict( "SZ1", "Z1_QTDTROC")    , TAMSX3("Z1_QTDTROC")[1] )
	TRCell():New( oSecItm1, "QUANTIDADE"    , "cAliasPED", "Quantidade "        , PesqPict( "SZ1", "Z1_QTDTROC")    , TAMSX3("Z1_QTDTROC")[1] )
	//   TRCell():New( oSecItm1, "PRCOBRU"	    , "cAliasPED", "Prc Bruto"          , PesqPict( "SZ1", "Z1_PRCOBRU")    , TAMSX3("Z1_PRCOBRU")[1] )
	TRCell():New( oSecItm1, "PRCOLIQ"	    , "cAliasPED", "Prc Liquido"        , PesqPict( "SZ1", "Z1_PRCOLIQ")    , TAMSX3("Z1_PRCOLIQ")[1] )
	//   TRCell():New( oSecItm1, "VLBRUTI"       , "cAliasPED", "Vl Bruto"           , PesqPict( "SZ1", "Z1_VLBRUTI")    , TAMSX3("Z1_VLBRUTI")[1] )
	TRCell():New( oSecItm1, "VLLIQU1"	    , "cAliasPED", "Vl Liquido"         , PesqPict( "SZ1", "Z1_VLLIQU1")    , TAMSX3("Z1_VLLIQU1")[1] )
	TRCell():New( oSecItm1, "PDESCOM"	    , "cAliasPED", "% Desconto"         , PesqPict( "SZ1", "Z1_PDESCOM")    , TAMSX3("Z1_PDESCOM")[1] )
	TRCell():New( oSecItm1, "VLUDECO"	    , "cAliasPED", "Vl. Desconto"       , PesqPict( "SZ1", "Z1_VLUDECO")    , TAMSX3("Z1_VLUDECO")[1] )
	TRCell():New( oSecItm1, "CODPROC"	    , "cAliasPED", "Status"             , PesqPict( "SZ1", "Z1_CODPROC")    , 15 )

	// totalizadores
//	TRFunction():New( oSecItm1:Cell("PED_ITEM"),NIL,"COUNT",,,,,.F.,.T.)

Return( oReport )

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de PEDIDOS EDI-NEOGRID 

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   17/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function PrintReport( oReport )

	LOCAL cAliasEDI := GetNextAlias()
	LOCAL cCodCompra, cLojCompra, cDescrPed

	LOCAL aTipoMSG   := {}  // tipo de mensagem
	LOCAL aTipoPed   := {}  // tipo de pedido
//LOCAL aTipoTrans := {}  // tipo de transportadora
	LOCAL nPosTpPed  := 0   // Posicao do tipo de pedido no Array
	LOCAL cStatus    := ""
	LOCAL aStatus    := {}
	LOCAL cFuncPed   := ""
	LOCAL nPosStatus := 0
	Local cTabela

	/* ----------------------------------------------------------------------------------------
	( aTipoMsg ) ALIMENTA O ARRAY DE TIPOS DE MENSAGENS
	---------------------------------------------------------------------------------------- */
    AAdd( aTipoMSG, { "9  "    , "Original " } )   
    AAdd( aTipoMSG, { "15 "    , "Proposta " } )   
    AAdd( aTipoMSG, { "31 "    , "Cópia " } )
    AAdd( aTipoMSG, { "42 "    , "Confirmação " } )
    AAdd( aTipoMSG, { "46 "    , "Provisório " } )
    
	/* ----------------------------------------------------------------------------------------
	( aTipoPed ) ALIMENTA O ARRAY DE TIPOS DE PEDIDOS
	---------------------------------------------------------------------------------------- */
    AAdd( aTipoPed, { "000", "Pedido com condições especiais " } )
    AAdd( aTipoPed, { "001", "Pedido Normal " } )
    AAdd( aTipoPed, { "002", "Pedido com Mercadorias Bonificadas " } )
    AAdd( aTipoPed, { "003", "Pedido de Consignação " } )
    AAdd( aTipoPed, { "004", "Pedido Vendor " } )
    AAdd( aTipoPed, { "005", "Pedido Compror " } )
    AAdd( aTipoPed, { "006", "Pedido de Demonstração" } )

	/* ----------------------------------------------------------------------------------------
	( QUERY ) Montagem da query de SELEÇÃO DO(S) REGISTRO(S)
	---------------------------------------------------------------------------------------- */
    If mv_par07 == 1    // POR DATA DE EMISSAO DO PEDIDO
            BEGINSQL Alias cAliasEDI

                // SOMENTE ITENS LIBERADOS
                SELECT
                        Z0_PVCOMPR
                        , Z0_EMISSAO
                        , Z0_HORAEMI
                        , Z0_CGCCOMP
                        , Z0_NUMPED
                        , Z0_ID
                        , Z0_DATA
                        , Z0_TIPOPV
                        , Z0_FUNCMSG

                FROM
                        %table:SZ0% SZ0
                WHERE
                        SZ0.Z0_FILIAL = %xfilial:SZ0%
                        AND SZ0.Z0_ID BETWEEN %exp:mv_par01% AND %exp:mv_par02%
                        AND SZ0.Z0_EMISSAO BETWEEN %exp:mv_par04% AND %exp:mv_par05%
                        AND SZ0.%notDel%

                ORDER BY %Order:SZ0,1%
            
            ENDSQL

    ELSE    // por DATA INTERNA

            BEGINSQL Alias cAliasEDI

                // SOMENTE ITENS LIBERADOS
                SELECT
                        Z0_PVCOMPR
                        , Z0_EMISSAO
                        , Z0_HORAEMI
                        , Z0_CGCCOMP
                        , Z0_NUMPED
                        , Z0_ID
                        , Z0_DATA
                        , Z0_TIPOPV
                        , Z0_FUNCMSG

                FROM
                        %table:SZ0% SZ0

                WHERE
                        SZ0.Z0_FILIAL = %xfilial:SZ0%
                        AND SZ0.Z0_ID BETWEEN %exp:mv_par01% AND %exp:mv_par02%
                        AND SZ0.Z0_DATA BETWEEN %exp:mv_par04% AND %exp:mv_par05%
                        AND SZ0.%notDel%

                ORDER BY %Order:SZ0,1%
   
            ENDSQL

    ENDIF

	DBSelectArea( (cAliasEDI) )
	While (cAliasEDI)->( !EOF() )

        If oReport:Cancel()
            Exit
        EndIf
 
        oReport:IncMeter()
        IncProc( "Imprimindo ... PEDIDO: " + (cAliasEDI)->Z0_PVCOMPR )

        /* ----------------------------------------------------------------------------------------
        ( SA1 ) Posiciona o CADASTRO DE CLIENTES
        ---------------------------------------------------------------------------------------- */
        DBSelectArea("SA1")
        DBSetOrder(3)
        DBSeek( xFilial("SA1") + (cAliasEDI)->Z0_CGCCOMP, .f. )

        cCodCompra  := SA1->A1_COD
        cLojCompra  := SA1->A1_LOJA
        cTabela     := SA1->A1_TABELA
        /* ----------------------------------------------------------------------------------------
        ( tipo ) TABELAS GENERICAS DO PROTHEUS
        ---------------------------------------------------------------------------------------- */
        nPosTpPed   := aScan( aTipoPed, { |x| AllTrim(x[1]) == (cAliasEDI)->Z0_TIPOPV } )

        If !empty( nPosTpPed )
            cDescrPed  := (cAliasEDI)->Z0_TIPOPV + " - " + aTipoPed[nPosTpPed][2]
        EndIf

        nPosFncMsg  := aScan( aTipoMSG, { |x| x[1] == (cAliasEDI)->Z0_FUNCMSG } ) 

        If !empty( nPosFncMsg )
            cFuncPed  := (cAliasEDI)->Z0_FUNCMSG + " - " + aTipoMSG[nPosFncMsg][2]
        EndIf

	    // inicializa a primeira seção - CABEÇALHO    
	 	oSecCab1:init()
		
        oSecCab1:Cell( "NUM_PEDIDO" ):SetValue( (cAliasEDI)->Z0_PVCOMPR )
        oSecCab1:Cell( "DATA_EMISSAO" ):SetValue( StoD( (cAliasEDI)->Z0_EMISSAO ) )	//
        oSecCab1:Cell( "HORA_EMISSAO" ):SetValue( (cAliasEDI)->Z0_HORAEMI ) 	//
        oSecCab1:Cell( "CNPJ_COMPRADOR" ):SetValue( (cAliasEDI)->Z0_CGCCOMP  )	//
        oSecCab1:Cell( "COD_COMPRADOR" ):SetValue( cCodCompra + "-" + cLojCompra )	//
        oSecCab1:Cell( "NOME_COMPRADOR" ):SetValue( SA1->A1_NOME )
        oSecCab1:Cell( "PED_PROTHEUS" ):SetValue( (cAliasEDI)->Z0_NUMPED )
        oSecCab1:Cell( "ID" ):SetValue( (cAliasEDI)->Z0_ID )
        oSecCab1:Cell( "FUNC_PEDIDO" ):SetValue( cFuncPed )
        oSecCab1:Cell( "TIPO_PEDIDO" ):SetValue( cDescrPed )
			
	    // imprime os dados do cabeçalho   
		oSecCab1:Printline()

        //imprimo uma linha para separar uma NCM de outra
        oReport:ThinLine()   
        oSecCab1:Finish()

        /* ----------------------------------------------------------------------------------------
        ( SZ1 ) - imprime o(s) item(ns) do PEDIDO
        ---------------------------------------------------------------------------------------- */
        DBSelectArea("SZ1")
        DBSetOrder(1)
        If DBSeek( xFilial("SZ1") + (cAliasEDI)->Z0_ID, .f. )

            oSecItm1:init()

            While SZ1->( !EOF() ) .AND. SZ1->Z1_FILIAL = xFilial("SZ1") .AND. SZ1->Z1_ID = (cAliasEDI)->Z0_ID

                /* ----------------------------------------------------------------------------------------
                ( SB1 ) - Cadastro de PRODUTOS
                ---------------------------------------------------------------------------------------- */
                DBSelectArea("SB1")
                DBSetOrder(1)
                DBSeek( xFilial("SB1") + SZ1->Z1_CODPROD, .f. )

                oSecItm1:Cell( "PED_ITEM" ):SetValue( SZ1->Z1_ITEM )
                oSecItm1:Cell( "COD_EAN" ):SetValue( SZ1->Z1_CODBAR )	
                oSecItm1:Cell( "COD_PROD" ):SetValue( SZ1->Z1_CODPROD )
                //If 
                oSecItm1:Cell( "DESC_PROD" ):SetValue( SZ1->Z1_DESCRIC )
                oSecItm1:Cell( "UN_MEDIDA" ):SetValue( SZ1->Z1_UM )
                If (cAliasEDI)->Z0_TIPOPV = "001"
                    oSecItm1:Cell( "QUANTIDADE" ):SetValue( SZ1->Z1_QTDPED )
                ElseIf (cAliasEDI)->Z0_TIPOPV = "002"
                    oSecItm1:Cell( "QUANTIDADE" ):SetValue( SZ1->Z1_QTDBONI )
                ElseIf (cAliasEDI)->Z0_TIPOPV = "003"
                    oSecItm1:Cell( "QUANTIDADE" ):SetValue( SZ1->Z1_QTDTROC )
                EndIf
                oSecItm1:Cell( "PRCOLIQ" ):SetValue( SZ1->Z1_PRCOLIQ )
                oSecItm1:Cell( "VLLIQU1" ):SetValue( SZ1->Z1_VLLIQU1 )
//              oSecItm1:Cell( "VLBRUTI" ):SetValue( SZ1->Z1_VLBRUTI )
//              oSecItm1:Cell( "PRCOBRU" ):SetValue( SZ1->Z1_PRCOBRU )
                oSecItm1:Cell( "PDESCOM" ):SetValue( SZ1->Z1_PDESCOM )
                oSecItm1:Cell( "VLUDECO" ):SetValue( SZ1->Z1_VLUDECO )

                /* ----------------------------------------------------------------------------------------
                ( SB1 ) - Cadastro de PRODUTOS
                ---------------------------------------------------------------------------------------- */
                aStatus := {}
                AAdd( aStatus, { "00", "00-Ok" } )
                AAdd( aStatus, { "01", "01-PV GERADO" } )
                AAdd( aStatus, { "10", "10-Código" } )
                AAdd( aStatus, { "20", "20-Produto Bloqueado " } )
                AAdd( aStatus, { "30", "30-Bloq ou S/ Tabela Preco " } )

                //----------------------------------------------------------
                // (SB1) Busca o código do Produto
                //----------------------------------------------------------
                DBSelectArea("SB1")
                DBSetOrder(5)   // 5 - B1_FILIAL + B1_CODBAR  [B1CODBAR]

                If !DBSeek( xFilial("SB1") + SZ1->Z1_CODBAR, .F. )
                    DBSetOrder(14)  // 14 - B1_FILIAL + B1_CODGTIN  [B1CODGTIN]
                    If DBSeek( xFilial("SB1") + SZ1->Z1_CODBAR, .F. )
                        cErrCod  := "00"
                        cCodProd := SB1->B1_COD
                        lErro    := .f.
                    Else    
                        cErrCod  := "10"
                        cErrDesc := "Código não Encontrado: " + SZ1->Z1_CODPROD
                        lErro    := .t.
                    EndIf
                Else
                    cErrCod  := "00"
                    cCodProd := SB1->B1_COD
                    lErro    := .f.
                EndIf

                //----------------------------------------------------------
                // (SB1) Verifica se o produto está BLOQUEADO
                //----------------------------------------------------------
                If SB1->B1_MSBLQL == "1"
                    cErrCod  := "20"    // produto BLOQUEADO
                    cErrDesc := "Produto Bloqueado: " + cCodProd
                    lErro    := .t.

                    DBSelectArea("SZ1")
                    RECLOCK( "SZ1", .f. )
                        SZ1->Z1_CODPROC := cErrCod // PRODUTO BLOQUEADO
                    MSUNLOCK()
                EndIf

			//alterado paulo bindo 17/08/22
			//----------------------------------------------------------
			// (DA1) Verifica se o produto está BLOQUEADO OU EXISTE NA TABELA DE PREÇO
			//----------------------------------------------------------
			dbSelectArea("DA1")
			dbSetOrder(1)
			If dbSeek(xFilial("DA1")+cTabela+SB1->B1_COD)

				If  DA1->DA1_ATIVO = "2"
					cErrCod  := "30"    // produto BLOQUEADO NA TABELA DE PRECO
					cErrDesc := "Produto Blq tabela Preco: " + AllTrim( cCodProd )+ENTER
					cErrDesc += "Codigo Tabela : "+cTabela
					lErro    := .t.

					DBSelectArea("SZ1")
					RECLOCK( "SZ1", .f. )
					SZ1->Z1_CODPROC := cErrCod // PRODUTO BLOQUEADO NA TABELA DE PRECO
					MSUNLOCK()
					

				EndIf
			Else

				cErrCod  := "30"    // produto NAO POSSUI TABELA DE PRECO
				cErrDesc := "Produto sem tabela Preco: " + AllTrim( cCodProd )
				lErro    := .t.

				DBSelectArea("SZ1")
				RECLOCK( "SZ1", .f. )
				SZ1->Z1_CODPROC := cErrCod // PRODUTO BLOQUEADO OU NAO EXISTE NA TABELA DE PRECO
				MSUNLOCK()
				

			EndIf

                nPosStatus := 0
                nPosStatus := ASCan( aStatus, { |x| x[1] == cErrCod } )

                If EMPTY( nPosStatus )
                    cStatus := "STATUS NÃO ENCONTRADO"
                Else
                    cStatus := aStatus[nPosStatus][2]
                EndIf

                oSecItm1:Cell( "CODPROC" ):SetValue( cStatus )

                oSecItm1:Printline()

                SZ1->( DBSkip() )

            End

            oSecItm1:Finish()

        EndIf

        (cAliasEDI)->( DBSkip() )

        If mv_par07 == 1 .OR. (cAliasEDI)->( EOF() )
            oReport:EndPage()     // Finaliza a página 
        EndIf

    EndDo

	/* ----------------------------------------------------------------------------------------
	( CONTEUDO ) Fecha a area de trabalho aberta
	---------------------------------------------------------------------------------------- */
	If SELECT( (cAliasEDI) ) > 0
		DBSelectArea( (cAliasEDI) )
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
    //                1     2                                3                                 4                                5        6   7                              8 9 10  11  12        13                14 15 16 17 18                19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36  37   38 39  40  41   42
    AAdd( aRegSX1, { "01", "Do ID ?                     ", "¿ Del ID ?                      ", "From ID ?                     ","mv_ch1","C", TAMSx3( "Z0_ID" )[1]        , 0,, "G","","mv_par01","               ","               ","               ","","","                ","                ","                ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
    AAdd( aRegSX1, { "02", "Ate o ID ?                  ", "¿ A ID ?                        ", "To ID ?                       ","mv_ch2","C", TAMSx3( "Z0_ID" )[1]        , 0,, "G","","mv_par02","               ","               ","               ","","","                ","                ","                ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
    AAdd( aRegSX1, { "03", "Tipo de Data ?              ", "¿ Tipo de Fecha ?               ", "Date Type ?                   ","mv_ch3","N", 1                           , 0,, "C","","mv_par03","Data Emissao   ","               ","               ","","","Data do Pedido  ","                ","                ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
    AAdd( aRegSX1, { "04", "Data Inicial ?              ", "¿ Fecha Inicial ?               ", "Initial Date ?                ","mv_ch4","D", TAMSx3( "Z0_EMISSAO" )[1]   , 0,, "G","","mv_par04","               ","               ","               ","","","                ","                ","                ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )  
	AAdd( aRegSX1, { "05", "Data Final ?                ", "¿ Fecha final ?                 ", "Final Date ?                  ","mv_ch5","D", TAMSx3( "Z0_EMISSAO" )[1]   , 0,, "C","","mv_par05","               ","Si             ","Yes            ","","","Nao             ","No              ","No              ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
	AAdd( aRegSX1, { "06", "Status ?                    ", "¿ Status ?                      ", "Status ?                      ","mv_ch6","N", 1                           , 0,, "C","","mv_par06","Todos          ","Todos          ","All            ","","","Aptos a Faturar ","Aptos a Faturar ","Aptos a Faturar ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )
	AAdd( aRegSX1, { "07", "Pula Página ?               ", "¿ Salta Pagina ?                ", "Skip Page ?                   ","mv_ch7","N", 1                           , 0,, "C","","mv_par07","Sim            ","Si             ","Yes            ","","","Nao             ","                ","                ","","","","","","","","","","","","","","","","","   ","","", "", "" , "" } )

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
