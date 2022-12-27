#include "Protheus.ch"
#include "FWMVCDEF.CH"
#include "rwmake.ch"
#include "totvs.ch"
#Define ENTER Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} rfatf02()
Gerenciador da rotina de processamento de arquivos EDI - NEOGRID

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   09/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
User Function RFATF02()

	Private oFile

	Private oBrowse
	Private aRotina     := MenuDef()
	Private cCadastro   := 'LOG de Processamento Integração NEOGRID'

	//-------------------------------------------
	// MONTA O BROWSE DE GERENCIAMENTO
	//-------------------------------------------
	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SZ0")

	oBrowse:AddLegend( "EMPTY( Z0_NUMPED ) .AND. Z0_STATUS = '01' "     , "GREEN"   , "Pendente"    )
	oBrowse:AddLegend( "!EMPTY( Z0_NUMPED )"                            , "RED"     , "PV Gerado"   )
	oBrowse:AddLegend( "EMPTY( Z0_STATUS = '10' )"                      , "YELLOW"  , "Código não Encontrado"   )

	oBrowse:SetDescription( cCadastro )

	//oBrowse:DisableDetails()
	oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} menudef()
rotina auxiliar que cria o menu de acesso da rotina principal

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   09/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisa'     Action 'PesqBrw'     OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'   Action 'AxVisual'    OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Lê Arquivos'  Action 'u_LeArqDir'  OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Gera Pedido'  Action 'u_RFATA01C'  OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Imprime'      Action 'u_RFATR05'   OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} LeArqDir()
rotina auxiliar que cria o menu de acesso da rotina principal

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   09/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
User Function LeArqDir()

	LOCAL cDirEDI   := GetMV( "MC_DIREDI",,"C:\TEMP\EDI\" )
	LOCAL cDirLidos := cDirEDI + "lidos\"
	LOCAL cDirErro  := cDirEDI + "erro\"

	LOCAL cDrive    := ""
	LOCAL cDiretorio:= ""
	LOCAL cNomeArq  := ""
	LOCAL cExtensao := ""

	Local aFiles    := {}   // Arquivos na pasta
	Local aSizes    := {}   // Tamanho dos arquivos
	Local aLinSC6   := {}   // linha

	Local aItSZ0    := {}   // Cabeçalho do PV
	Local aItSC6    := {}   // Itens dO PV

	Local x, y
	Local nLin := 1
	Local lRepro := .f.
	Local lRet   := .f.

	//-------------------------------------------
	// Verifica o diretorio de trabalho do EDI
	//-------------------------------------------
	aDir := SplitPath( cDirEDI, @cDrive, @cDiretorio, @cNomeArq, @cExtensao )

	If !ExistDir( cDirEDI )
		MakeDir( cDirEDI,, .T. )
	Endif

	If !ExistDir( cDirLidos )
		MakeDir( cDirLidos,, .T. )
	EndIf

	If !ExistDir( cDirErro )
		MakeDir( cDirErro,, .T. )
	EndIf

	//-------------------------------------------
	// Busca o(s) Arquivo(s) na pasta EDI
	//-------------------------------------------
	aLayOut := fReg01()

	If EMPTY( aLayOut )
		ALERT( "Erro ao carregar o layout Tipo: 01 " )
		Return(.f.)
	EndIf

	//-------------------------------------------
	// Busca o(s) Arquivo(s) na pasta EDI
	//-------------------------------------------
	ADIR( cDirEDI + "*.*", aFiles, aSizes )

	for x := 1 To Len( aFiles )

		cArquivo := cDirEDI + aFiles[x]     // DIRETORIO DE LEITURA DOS ARQUIVOS
		cArqDest := cDirLidos + aFiles[x]   // DIRETORIO DOS ARQUIVOS LIDOS
		cArqErro := cDirErro + aFiles[x]    // DIRETORIO COM ERRO DE LEITURA

		//-------------------------------------------------------
		// Verifica se o arquivo já foi processado anteriormente
		//-------------------------------------------------------
		DBSelectArea( "SZ0" )
		DBOrderNickName( "ZOARQUIVO" )  // (2) Z0_FILIAL+Z0_ARQUIVO+DTOS(Z0_EMISSAO)+Z0_TIPOREG
		If DBSeek( xFilial("SZ0") + Left(cArquivo,30), .f.)
			If MSGYESNO( "O arquivo : " + Chr(13) + Chr(10) + AllTrim( cArquivo ) + Chr(13) + Chr(10) + " Já foi Processado anteriormente, deseja REPROCESSAR ?", "REPROCESSA" )
				lRepro := .T.
			Else
				lRepro := .F.
				loop
			EndIf
		EndIf

		//-------------------------------------------------------
		// Efetua a leitura do(s) arquivo(s)
		//-------------------------------------------------------
		aItSZ0  := {}
		aItSC6  := {}

		//-------------------------------------------------------
		// Efetua a leitura do(s) arquivo(s)
		//-------------------------------------------------------
		oFile := FWFileReader():New( cArquivo )   // Definindo o arquivo a ser lido

		If ( oFile:Open() )

			//Se nÃ£o for fim do arquivo
			If !( oFile:EoF() )

				//Alimenta a Regua de PROCESSAMENTO
				ProcRegua( oFile:getFileSize() )

				//Enquanto houver linhas a serem lidas
				While ( oFile:HasLine() )

					IncProc( "Lendo a linha " + Alltrim( str(nLin) ) + " ,Aguarde ... " )

					//Buscando o texto da linha atual
					cLinAtu  := oFile:GetLine()
					cTpReg   := Substr( cLinAtu, 01, 02 )

					If cTpReg == "01"

						aLayOut := fReg01()

						//----------------------------------------------------------
						// Alimenta o Array com os ITENS do PV
						//----------------------------------------------------------
						For y := 1 To Len( aLayOut )

							cConteudo := SUBSTR( cLinAtu, aLayOut[y][3] + 1, aLayOut[y][5] )

							If aLayOut[y][2] == "N"
								cConteudo   := Val( cConteudo ) / IIF( aLayOut[y][6] > 0, 100, 1 )
							EndIf

							AAdd( aItSZ0, { aLayOut[y][1], aLayOut[y][2], cConteudo } )

						Next y

					ElseIf cTpReg == "04"

						aLayOut := fReg04()

						//----------------------------------------------------------
						// Alimenta o Array com os ITENS do PV
						//----------------------------------------------------------
						For y := 1 To Len( aLayOut )

							cConteudo := SUBSTR( cLinAtu, aLayOut[y][3] + 1, aLayOut[y][5] )

							If aLayOut[y][2] == "N"
								cConteudo   := Val( cConteudo ) / IIF( aLayOut[y][6] > 0, 100, 1 )
							EndIf

							AAdd( aLinSC6, { aLayOut[y][1], aLayOut[y][2], cConteudo } )

						Next y

						AAdd( aItSC6, aLinSC6 )     // 04 - Item do PEDIDO DE VENDA (SC6)
						aLinSC6 := {}

					EndIf

				EndDo

			EndIf

			//----------------------------------------------------------
			// ( SZ0 ) Grava o LOG de controle de Arquivo EDI
			//----------------------------------------------------------
			If !EMPTY( aItSZ0 ) .and. !EMPTY( aItSC6 )
				Processa( { || RFATA01A( cArquivo, aItSZ0, aItSC6 ) }, OemToAnsi("Aguarde... Gravando o LOG ... " ) )
			EndIf

			aItSZ0 := {}
			aItSC6 := {}

			//Fecha o arquivo e finaliza o processamento
			oFile:Close()

			// Move o arquivo processado para a pasta \LIDOS
			lRet := __CopyFile( cArquivo, cArqDest,,,.F.)
			If lRet
				If FERASE( cArquivo ) == -1
					lRet := __CopyFile( cArquivo, cArqErro,,,.F.)
				EndIf
			EndIf

		Else

			// Move o arquivo não processado para a pasta \ERRO
			aItSZ0 := {}
			aItSC6 := {}

			lRet := __CopyFile( cArquivo, cArqErro,,,.F.)
			Alert( "Erro ao abrir o arquivo: " + cArquivo)
		EndIf

	Next x

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} rfatf01A()
Gerenciador da rotina de processamento de arquivos EDI - NEOGRID

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   09/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function RFATA01A( cNomArq, aLinCab, aItens )

	LOCAL x
	LOCAL cID, cTpReg, cItem
	Local cTabela := "" //PAULO BINDO

	//---------------------------------------------------------------------------
	// Caso nao tenha sido passado o array aDados ou esteja vazio, sai da rotina
	//---------------------------------------------------------------------------
	If EMPTY( aLinCab ) .or. EMPTY( aItens )
		ALERT(" Dados nao informados ")
		Return(.f.)
	EndIf

	IncProc( "Gravando o arquivo: " + cArquivo )

	If !EMPTY( aLinCab )
		//----------------------------------------------------------
		// ( SZ0 ) Log de PROCESSAMENTO EDI - NEOGRID
		//----------------------------------------------------------
		DBSelectArea("SZ0")
		DBOrderNickName( "ZOARQUIVO" )  // (2) Z0_FILIAL+Z0_ARQUIVO+DTOS(Z0_EMISSAO)+Z0_TIPOREG
		// Z0_FILIAL + Z0_ID + Z0_TIPOTEG
		If !DBSeek( xFilial("SZ0") + cNomArq, .f. )
			RECLOCK( "SZ0", .T. )
			SZ0->Z0_FILIAL  := xFilial("SZ0")               // FILIAL DO ARQUIVO
			SZ0->Z0_ARQUIVO := cNomArq                      // NOME DO ARQUIVO
			SZ0->Z0_ID      := GETSXENUM( "SZ0", "Z0_ID" )  // ID de Controle de PROCESSAMENTO de arquivo EDI
			SZ0->Z0_STATUS  := "01"                         // 28-STATUS 01-OK; 10-PRODUTO

			ConfirmSX8()
		Else
			RECLOCK( "SZ0", .F. )
		EndIf
		SZ0->Z0_TIPOREG := aLinCab[1][3]     // 01-TIPO DE REGISTRO
		SZ0->Z0_FUNCMSG := aLinCab[2][3]     // 02-FUNCAO MENSAGEM
		SZ0->Z0_TIPOPV  := aLinCab[3][3]     // 03-TIPO DE PEDIDO
		SZ0->Z0_PVCOMPR := aLinCab[4][3]     // 04-NUMERO DO PEDIDO DO COMPRADOR
		SZ0->Z0_PVSISTE := aLinCab[5][3]     // 05-NUMERDO DO PEDIDO DO SISTEMA DE EMISSAO
		SZ0->Z0_EMISSAO := StoD( Substr( aLinCab[6][3], 1, 8 ) ) // 06-DATA-HORA EMISSAO DO PEDIDO
		SZ0->Z0_HORAEMI := Stuff( Substr( aLinCab[6][3], 9, 5 ), 3, 0, ":" )
		SZ0->Z0_DTIENTR := StoD( Substr( aLinCab[7][3], 1, 8 ) ) // 07-DATA-HORA INICIAL DO PERIODO DE ENTREGA
		SZ0->Z0_HRINIEN := Stuff( Substr( aLinCab[7][3], 9, 5 ), 3, 0, ":" )
		SZ0->Z0_DTFENTR := StoD( Substr( aLinCab[8][3], 1, 8 ) ) // 08-DATA-HORA
		SZ0->Z0_HRFINEN := Stuff( Substr( aLinCab[8][3], 9, 5 ), 3, 0, ":" )
		SZ0->Z0_CONTRAT := aLinCab[9][3]     // 09-NUMERO DE CONTRATO
		SZ0->Z0_TABELA  := aLinCab[10][3]    // 10-LISTA DE PREÃ‡OS
		SZ0->Z0_EANFORN := aLinCab[11][3]    // 11-EAN FORNECEDOR
		SZ0->Z0_EANCPRA := aLinCab[12][3]    // 12-EAN COMPRADOR
		SZ0->Z0_EANCOBR := aLinCab[13][3]    // 13-EAN COBRANÃ‡A
		SZ0->Z0_EANENTR := aLinCab[14][3]    // 14-
		SZ0->Z0_CGCFORN := aLinCab[15][3]    // 15-CGC FORNECEDOR
		SZ0->Z0_CGCCOMP := aLinCab[16][3]    // 16-CGC COMPRADOR
		SZ0->Z0_CGCFATU := aLinCab[17][3]    // 17-CGC FATURAMENTO
		SZ0->Z0_CGCENTR := aLinCab[18][3]    // 18-CGC ENTREGA
		SZ0->Z0_TPCODTR := aLinCab[19][3]    // 19-TIPO DE CODIGO DA TRANSPORTADORA
		SZ0->Z0_CODTRAN := aLinCab[20][3]    // 20-CODIGO DA TRANSPORTADORA
		SZ0->Z0_NTRANSP := aLinCab[21][3]    // 21-NOME DA TRANSPORTADORA
		SZ0->Z0_TPFRETE := aLinCab[22][3]    // 22-TIPO DE FRETE CIF ou FOB
		SZ0->Z0_SECAOPV := aLinCab[23][3]    // 23-SEÇAO DO PEDIDO
		SZ0->Z0_OBSERVA := aLinCab[24][3]    // 24-OBSERVACAO
		SZ0->Z0_CODUSR  := RetCodUsr()       // 25-CODIGO DO USUARIO
		SZ0->Z0_DATA    := DATE()            // 26-DATA DE PROCESSAMENTO
		SZ0->Z0_HORA    := TIME()            // 27-HORA DE PROCESSAMENTO
		MSUNLOCK()

	EndIf

	//ALTERADO PAULO BINDO 17/08/22
	//POSICIONA NO CADASTRO DO CLIENTE PARA BUSCAR A TABELA DE PRECO
	DBSelectArea("SA1")
	SA1->( DBSetOrder(3))   // (3) A1_FILIAL + A1_CGC
	SA1->( DBSeek( xFilial("SA1") + SZ0->Z0_CGCCOMP, .f. ) )

	If FOUND()
		cTabela     := SA1->A1_TABELA
	EndIf

	//----------------------------------------------------------
	// ( SZ0 ) Log de PROCESSAMENTO EDI - NEOGRID
	//----------------------------------------------------------
	If !EMPTY( aItens )
			lErro    := .f.
			cErrCod  := "00"

		For x := 1 To Len( aItens )

			cID      := SZ0->Z0_ID
			cTpReg   := aItens[x][1][3]
			cItem    := PadL( aItens[x][2][3], TAMSX3("Z1_ITEM")[1], "0" )
			cCodBar  := PadR( aItens[x][6][3], 14 )
			cCodProd := CRIAVAR( "B1_COD" )

			//----------------------------------------------------------
			// (SB1) Busca o código do Produto
			//----------------------------------------------------------
			DBSelectArea("SB1")
			DBOrderNickName( "B1CODBAR" )  // (5) B1_FILIAL + B1_CODBAR  [B1CODBAR]
			If !DBSeek( xFilial("SB1") + cCodBar, .F. )
				DBOrderNickName( "B1CODGTIN" ) // (14) B1_FILIAL + B1_CODGTIN  [B1CODGTIN]
				If DBSeek( xFilial("SB1") + cCodBar, .F. )
					cCodProd := SB1->B1_COD
					//lErro    := .f.

				Else
					cErrCod  := "10"
					cErrDesc := "Código não Encontrado: " + cCodBar
					lErro    := .t.
				EndIf
			Else
				cCodProd := SB1->B1_COD
				//lErro    := .f.
			EndIf

			//----------------------------------------------------------
			// (SB1) Verifica se o produto está BLOQUEADO
			//----------------------------------------------------------
			If SB1->B1_MSBLQL == "1"
				cErrCod  := "20"    // produto BLOQUEADO
				cErrDesc := "Produto Bloqueado: " + cCodProd
				lErro    := .t.
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


				EndIf
			Else

				cErrCod  := "30"    // produto NAO POSSUI TABELA DE PRECO
				cErrDesc := "Produto sem tabela Preco: " + AllTrim( cCodProd )
				lErro    := .t.

			EndIf

			//----------------------------------------------------------
			// (SZ1) Grava os dados na TABELA SZ1
			//----------------------------------------------------------
			DBSelectArea("SZ1")
			DBOrderNickName("Z1IDITEM")  // (1) Z1_FILIAL+Z1_ID+Z1_TIPOREG+Z1_ITEM
			If !DBSeek( xFilial("SZ1") + cID + cTpReg + cItem , .f. )
				RECLOCK( "SZ1", .t. )
				SZ1->Z1_FILIAL  := xFilial("SZ1")
				SZ1->Z1_ID      := cID
				SZ1->Z1_TIPOREG := aItens[x][1][3]      // 01 - tipo de Registro
				SZ1->Z1_ITEM    := cItem
			Else
				RECLOCK( "SZ1", .f. )
			EndIf
			SZ1->Z1_QALTER  := PadL( aItens[x][4][3], TAMSX3("Z1_QALTER")[1], "0" )
			SZ1->Z1_TPCODPR := aItens[x][5][3]
			SZ1->Z1_CODBAR  := aItens[x][6][3]
			SZ1->Z1_CODPROD := cCodProd
			SZ1->Z1_DESCRIC := aItens[x][7][3]
			SZ1->Z1_REFPROD := aItens[x][8][3]
			SZ1->Z1_UM      := aItens[x][9][3]
			SZ1->Z1_UMEMB   := PadL( aItens[x][10][3], TAMSX3("Z1_UMEMB")[1], "0" )
			SZ1->Z1_QTDPED  := aItens[x][11][3]
			SZ1->Z1_QTDBONI := aItens[x][12][3]
			SZ1->Z1_QTDTROC := aItens[x][13][3]
			SZ1->Z1_TIPEMBA := aItens[x][14][3]
			SZ1->Z1_NUMEMBA := PadL( aItens[x][15][3], TAMSX3("Z1_UMEMB")[1], "0" )
			//        SZ1->Z1_VLBRUTI := aItens[x][16][3]
			//        SZ1->Z1_VLLIQU1 := aItens[x][17][3]
			SZ1->Z1_PRCOBRU := aItens[x][18][3]
			//         SZ1->Z1_PRCOLIQ := aItens[x][19][3]   //Ajustado Flávio Monachesi 07/07/2021 para clientes que não possuem vl liquido
			SZ1->Z1_PRCOLIQ := aItens[x][18][3]
			SZ1->Z1_BASPRC  := aItens[x][20][3]
			SZ1->Z1_UNBPRC  := aItens[x][21][3]
			SZ1->Z1_VLUDECO := aItens[x][22][3]
			SZ1->Z1_PDESCOM := aItens[x][23][3]
			SZ1->Z1_VLIPI   := aItens[x][24][3]
			SZ1->Z1_ALIQIPI := aItens[x][25][3]
			SZ1->Z1_VLUNDES := aItens[x][26][3]
			SZ1->Z1_VLUNDE2 := aItens[x][27][3]
			SZ1->Z1_VLFRETE := aItens[x][28][3]
			SZ1->Z1_VLPAUTA := aItens[x][29][3]
			SZ1->Z1_CODRMS  := aItens[x][30][3]
			SZ1->Z1_CODNCM  := aItens[x][31][3]
			SZ1->Z1_VLLIQU1 := aItens[x][18][3] * aItens[x][11][3]
			SZ1->Z1_VLBRUTI := aItens[x][20][3] * aItens[x][11][3]

			MsUnlock()

		Next x

		If lErro
			DBSelectArea("SZ0")
			RECLOCK("SZ0", .f. )
			SZ0->Z0_STATUS  := cErrCod              // 28-STATUS 01-OK; 10-PRODUTO; 20-BLOQUEADO; 30-ERRO TABELA PRECO
			MSUNLOCK()
		EndIf

	EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} lReg01()
Monta o layout do Registro 001 - CABEÃ‡ALHO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg01()

	Local aReg01 := {}

	// Registro 01 - CabeÃ§alho
	//    array      descriÃ§Ã£o                                  Tipo   Ini  Fim  Tam  Dec
	AAdd( aReg01,   { 'Tipo de Registro'                        , 'C', 000, 001, 02 } ) // 01
	AAdd( aReg01,   { 'Funcao Mensagem'                         , 'C', 002, 004, 03 } ) // 02
	AAdd( aReg01,   { 'Tipo de Pedido'                          , 'C', 005, 007, 03 } ) // 03
	AAdd( aReg01,   { 'Numero do Pedido do Comprador'           , 'C', 008, 027, 20 } ) // 04
	AAdd( aReg01,   { 'Numero do Pedido do Sistema Emissao'     , 'C', 028, 047, 20 } ) // 05
	AAdd( aReg01,   { 'Data-Hora da emissao do pedido'          , 'C', 048, 059, 12, 00 } ) // 06
	AAdd( aReg01,   { 'Data-Hora Inicial Periodo de Entrega'    , 'C', 060, 071, 12, 00 } ) // 07
	AAdd( aReg01,   { 'Data-Hora Fim Periodo de  Entrega'       , 'C', 072, 083, 12, 00 } ) // 08
	AAdd( aReg01,   { 'Numero do Contrato'                      , 'C', 084, 098, 15 } ) // 09
	AAdd( aReg01,   { 'Lista Precos'                            , 'C', 099, 113, 15 } ) // 10
	AAdd( aReg01,   { 'EAN Localizacao do Fornecedor'           , 'C', 114, 126, 13, 00 } ) // 11
	AAdd( aReg01,   { 'EAN Localizacao do Comprador'            , 'C', 127, 139, 13, 00 } ) // 12
	AAdd( aReg01,   { 'EAN Localizacao de Cobranca'             , 'C', 140, 152, 13, 00 } ) // 13
	AAdd( aReg01,   { 'EAN Localizacao de Entrega'              , 'C', 153, 165, 13, 00 } ) // 14
	AAdd( aReg01,   { 'CNPJ do Fornecedor'                      , 'C', 166, 179, 14, 00 } ) // 15
	AAdd( aReg01,   { 'CNPJ do Comprador'                       , 'C', 180, 193, 14, 00 } ) // 16
	AAdd( aReg01,   { 'CNPJ do Local da Cobranca da Fatura'     , 'C', 194, 207, 14, 00 } ) // 17
	AAdd( aReg01,   { 'CNPJ do Local de Entrega'                , 'C', 208, 221, 14, 00 } ) // 18
	AAdd( aReg01,   { 'Tipo de Codigo da Transportadora'        , 'C', 222, 224, 03 } ) // 19
	AAdd( aReg01,   { 'Codigo da Transportadora'                , 'C', 225, 238, 14, 00 } ) // 20
	AAdd( aReg01,   { 'Nome da Transportadora'                  , 'C', 239, 268, 30 } ) // 21
	AAdd( aReg01,   { 'Condicao de Entrega (tipo de frete)'     , 'C', 269, 271, 03 } ) // 22
	AAdd( aReg01,   { 'Secao do Pedido'                         , 'C', 272, 274, 03, 00 } ) // 23
	AAdd( aReg01,   { 'Observacao do Pedido'                    , 'C', 275, 314, 40 } ) // 24

Return( aReg01 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg02()
Monta o layout do Registro 002 - PAGAMENTO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg02()

//-------------------------------------------
// Declaracao de variaveis                   
//-------------------------------------------
	LOCAL aReg02 := {}

	// Registro 02 - PAGAMENTO
	//    array      descriÃ§Ã£o                               Tipo  Ini  Fim  Tam  Dec
	AAdd( aReg02,   { 'Tipo de Registro'                    , 'C', 000, 001, 01  } )
	AAdd( aReg02,   { 'Cond. Pagamento'                     , 'C', 002, 004, 03 } )
	AAdd( aReg02,   { 'Referencia da Data'                  , 'C', 005, 007, 03 } )
	AAdd( aReg02,   { 'Referencia de Tempo da Data'         , 'C', 008 ,010, 03 } )
	AAdd( aReg02,   { 'Tipo do Periodo'                     , 'C', 011, 013, 03 } )
	AAdd( aReg02,   { 'Numero de Periodos'                  , 'N', 014, 016, 03, 00 } )
	AAdd( aReg02,   { 'Data de vencimento'                  , 'N', 017, 024, 08, 00 } )
	AAdd( aReg02,   { 'Valor a Pagar'                       , 'N', 025, 039, 15, 02 } )
	AAdd( aReg02,   { 'Percentual a Pagar Vl Fatur'         , 'N', 040, 044, 05, 02 } )

Return( aReg02 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg03()
Monta o layout do Registro 003 - DESCONTOS E ENCARGOS DO PEDIDO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg03()

//-------------------------------------------
// Declaracao de variaveis                   
//-------------------------------------------
	LOCAL aReg03 := {}

	// Registro 03 - DESCONTOS E ENCARGOS DO PEDIDO
	//    array      descriÃ§Ã£o                              Tipo   Ini  Fim  Tam Dec
	AAdd( aReg03,   { 'Tipo de Registro'                    , 'C', 000, 001, 02 } )
	AAdd( aReg03,   { 'Percentual de Desconto Financeiro'   , 'N', 002, 006, 05, 02 } )
	AAdd( aReg03,   { 'Valor de Desconto Financeiro'        , 'N', 007, 021, 15, 02 } )
	AAdd( aReg03,   { 'Percentual do Desconto Comercial'    , 'N', 022, 026, 05, 02 } )
	AAdd( aReg03,   { 'Valor de Desconto Comercial'         , 'N', 027, 041, 15, 02 } )
	AAdd( aReg03,   { 'Percentual do Desconto Promocional'  , 'N', 042, 046, 05, 02 } )
	AAdd( aReg03,   { 'Valor do Desconto Promocional'       , 'N', 047, 061, 15, 02 } )
	AAdd( aReg03,   { 'Percentual de Encargos Financeiros'  , 'N', 062, 066, 05, 02 } )
	AAdd( aReg03,   { 'Valor de Encargos Financeiros'       , 'N', 067, 081, 15, 02 } )
	AAdd( aReg03,   { 'Percentual de Encargos de Frete'     , 'N', 082, 086, 05, 02 } )
	AAdd( aReg03,   { 'Valor de Encargos de Frete'          , 'N', 087, 101, 15, 02 } )
	AAdd( aReg03,   { 'Percentual de Encargos de Seguro'    , 'N', 102, 106, 05, 02 } )
	AAdd( aReg03,   { 'Valor de Encargos de Seguro'         , 'N', 107, 121, 15, 02 } )

Return( aReg03 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg04()
Monta o layout do Registro 004 - ITENS DO PV

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg04()

//-------------------------------------------
// Declaracao de variaveis                   
//-------------------------------------------
	LOCAL aReg04 := {}

	// Registro 04 - ITENS
	//    array       descriÃ§Ã£o                                         Tipo   Ini  Fim  Tam Dec
	AAdd( aReg04,   { 'Tipo de Registro'                                , 'C', 000, 001, 02 } ) // 01
	AAdd( aReg04,   { 'Numero sequencial da Linha de Item'              , 'N', 002, 005, 04, 00 } ) // 02
	AAdd( aReg04,   { 'Numero do Item no Pedido'                        , 'N', 006, 010, 05, 00 } ) // 03
	AAdd( aReg04,   { 'Qualificador de Alteracao'                       , 'C', 011, 013, 03 } ) // 04
	AAdd( aReg04,   { 'Tipo de Codigo do Produto'                       , 'C', 014, 016, 03 } ) // 05
	AAdd( aReg04,   { 'Codigo do Produto'                               , 'C', 017, 030, 14 } )  // 06
	AAdd( aReg04,   { 'Descricao do Produto'                            , 'C', 031, 070, 40 } ) // 07
	AAdd( aReg04,   { 'Referencia do Produto'                           , 'C', 071, 090, 20 } ) // 08
	AAdd( aReg04,   { 'Unidade de Medida'                               , 'C', 091, 093, 03 } ) // 09
	AAdd( aReg04,   { 'Numero de unidades Consumo na Embalagem Pedida'  , 'N', 094, 098, 05, 00 } ) // 10
	AAdd( aReg04,   { 'Quantidade Pedida'                               , 'N', 099, 113, 15, 02 } ) // 11
	AAdd( aReg04,   { 'Quantidade Bonificada'                           , 'N', 114, 128, 15, 02 } ) // 12
	AAdd( aReg04,   { 'Quantidade Troca'                                , 'N', 129, 143, 15, 02 } ) // 13
	AAdd( aReg04,   { 'Tipo de Embalagem'                               , 'C', 144, 146, 03 } ) // 14
	AAdd( aReg04,   { 'Numero de Embalagens'                            , 'N', 147, 151, 05, 00 } ) // 15
	AAdd( aReg04,   { 'Valor Bruto Linha Item'                          , 'N', 152, 166, 15, 02 } ) // 16
	AAdd( aReg04,   { 'Valor Liquido Linha do Item'                     , 'N', 167, 181, 15, 02 } ) // 17
	AAdd( aReg04,   { 'Preco Bruto Unitario'                            , 'N', 182, 196, 15, 02 } ) // 18
	AAdd( aReg04,   { 'Preco Liquido Unitario'                          , 'N', 197, 211, 15, 02 } ) // 19
	AAdd( aReg04,   { 'Base Preco Unitario'                             , 'N', 212, 216, 05, 00 } ) // 20
	AAdd( aReg04,   { 'Unidade de Medida da Base do Preco Unitario'     , 'C', 217, 219, 03 } ) // 21
	AAdd( aReg04,   { 'Valor Unitario do Desconto Comercial'            , 'N', 220, 234, 15, 02 } ) // 22
	AAdd( aReg04,   { 'Percentual do Desconto Comercial'                , 'N', 235, 239, 05, 02 } ) // 23
	AAdd( aReg04,   { 'Valor Unitario do IPI'                           , 'N', 240, 254, 15, 02 } ) // 24
	AAdd( aReg04,   { 'Aliquota de IPI'                                 , 'N', 255, 259, 05, 02 } ) // 25
	AAdd( aReg04,   { 'Valor Unitario da Desp Acess Tributada'          , 'N', 260, 274, 15, 02 } ) // 26
	AAdd( aReg04,   { 'Valor Unitario da Desp Acess Nao Tributada'      , 'N', 275, 289, 15, 02 } ) // 27
	AAdd( aReg04,   { 'Valor de Encargo de Frete'                       , 'N', 290, 304, 15, 02 } ) // 28
	AAdd( aReg04,   { 'Valor Pauta'                                     , 'N', 305, 311, 07, 02 } ) // 29
	AAdd( aReg04,   { 'Codigo RMS do Item'                              , 'N', 312, 319, 08, 00 } ) // 30
	AAdd( aReg04,   { 'Codigo NCM'                                      , 'C', 320, 329, 10 } ) // 31

Return( aReg04 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg05()
Monta o layout do Registro 005 - GRADE

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg05

	LOCAL aReg05 := {}

	// Registro 05 - GRADE
	//    array       descriÃ§Ã£o                        Tipo Ini  Fim  Tam Dec
	AAdd( aReg05,  { 'Tipo de Registo'               , 'C', 000, 001, 02 } )
	AAdd( aReg05,  { 'Tipo de Codigo de Produto'     , 'C', 002, 004, 03 } )
	AAdd( aReg05,  { 'Codigo do Produto'             , 'C', 005, 018, 14 } )
	AAdd( aReg05,  { 'Quantidade'                    , 'N', 019, 033, 15, 02 } )  // com 2 decimais
	AAdd( aReg05,  { 'Unidade de Medida'             , 'C', 034, 036, 03 } )

Return( aReg05 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg06()
Monta o layout do Registro 006 - CROSSDOCKING

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg06

	LOCAL aReg06 := {}

	// Registro 06 - CROSSDOCKING
	//    array       descriÃ§Ã£o                                      Tipo  Ini  Fim  Tam Dec
	AAdd( aReg06,   { 'Tipo de Registro'                            , 'C', 000, 001, 02 } )
	AAdd( aReg06,   { 'EAN do Local de Entrega'                     , 'N', 002, 014, 03, 00 } )
	AAdd( aReg06,   { 'CNPJ do Local de Entrega'                    , 'N', 015, 028, 14, 00 } )
	AAdd( aReg06,   { 'Data - Hora inicial do Peri­odo de Entrega'   , 'N', 029, 040, 12, 00 } )
	AAdd( aReg06,   { 'Data - Hora Final do Peri­odo de Entrega'     , 'N', 041, 052, 12, 00 } )
	AAdd( aReg06,   { 'Quantidade'                                  , 'N', 053, 067, 15, 02 } )
	AAdd( aReg06,   { 'Unidade de Medida'                           , 'C', 068, 070, 03 } )

Return( aReg06 )

//-------------------------------------------------------------------
/*/{Protheus.doc} fReg09()
Monta o layout do Registro 009 - SUMÃRIO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
Static Function fReg09

	LOCAL aReg09 := {}

	// Registro 09 - SUMARIO
	//    array       descricao                                             Tipo   Ini  Fim  Tam Dec
	AAdd( aReg09,   { 'Tipo de Registro'                                    , 'C', 000, 001, 02 } )
	AAdd( aReg09,   { 'Valor Total das Mercadorias'                         , 'N', 002, 016, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total do IPI'                                  , 'N', 017, 031, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total de Abatimentos'                          , 'N', 032, 046, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total de Encargos'                             , 'N', 047, 061, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total de Descontos Comerciais'                 , 'N', 062, 076, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total de Despesas Acessorias Tributadas'       , 'N', 077, 091, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total de Despesas Acessorias Nao Tributadas'   , 'N', 092, 106, 15, 02 } )
	AAdd( aReg09,   { 'Valor Total do Pedido'                               , 'N', 107, 121, 15, 02 } )

Return( aReg09 )


//-------------------------------------------------------------------
/*/{Protheus.doc} lReg01()
Monta o layout do Registro 001 - CABEÃ‡ALHO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
User Function RFATA01B( )

	LOCAL cLinAtu   := ""
	LOCAL aLinSC6   := {}

	LOCAL cTpReg    := ""
	LOCAL cConteudo := ""

	LOCAL oFile
	LOCAL lRet  := .t.
	LOCAL x
	LOCAL nLin  := 1

	Private aReg01 := {}    // LAYOUT cabecalho
	Private aReg02 := {}    // LAYOUT pagamento
	Private aReg03 := {}    // LAYOUT desconto e encargos
	Private aReg04 := {}    // LAYOUT itens
	Private aReg05 := {}    // LAYOUT grade
	Private aReg06 := {}    // LAYOUT crossdocking
	Private aReg09 := {}    // LAYOUT sumario

	Private aLinhas := {}

	//Se o arquivo pode ser aberto
	If ( oFile:Open() )

		//Se nÃ£o for fim do arquivo
		If !( oFile:EoF() )

			//Alimenta a RÃ©gua de PROCESSAMENTO
			ProcRegua( oFile:getFileSize() )

			//Enquanto houver linhas a serem lidas
			While ( oFile:HasLine() )

				IncProc( "Lendo a linha " + Alltrim( str(nLin) ) + " ,Aguarde ... " )

				//Buscando o texto da linha atual
				cLinAtu  := oFile:GetLine()
				cTpReg   := Substr( cLinAtu, 01, 02 )

				//----------------------------------------------------------
				// (tipo) Carrega o layout de acordo com o tipo do Registro
				//----------------------------------------------------------
				DO Case

				Case cTpReg = "01"      // 01-Cabecalho
					aLayOut := fReg01()


				Case cTpReg = "02"      // 02-PAGAMENTO
					aLayOut := fReg02()

					//----------------------------------------------------------
					// Alimenta o Array com os ITENS do PV
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aItSE4, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x

				Case cTpReg = "03"      // 03-DESCONTOS E ENCARGOS DO PEDIDO
					aLayOut := fReg03()

					//----------------------------------------------------------
					// Alimenta o Array com os ITENS do PV
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aItDESC, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x

				Case cTpReg = "04"      // 04-ITENS DO PEDIDO DE VENDAS

					aLayOut := fReg04()

					//----------------------------------------------------------
					// Alimenta o Array com os ITENS do PV
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aLinSC6, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x

					AAdd( aItSC6, aLinSC6 )     // 04 - Item do PEDIDO DE VENDA (SC6)
					aLinSC6 := {}
				Case cTpReg = "05"      // 05-GRADE
					aLayOut := fReg05()

					//----------------------------------------------------------
					// Alimenta o Array com os ITENS do PV
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aItGrd, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x

				Case cTpReg = "06"      // 06-CROSSDOCKING
					aLayOut := fReg06()

					//----------------------------------------------------------
					// Alimenta o Array com os ITENS do PV
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aItEnt, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x


				Case cTpReg = "09"      // 09-SUMARIO
					aLayOut := fReg09()

					//----------------------------------------------------------
					// Alimenta o Array com os dados do SUMÁRIO
					//----------------------------------------------------------
					For x := 1 To Len( aLayOut )

						cConteudo := SUBSTR( cLinAtu, aLayOut[x][3] + 1, aLayOut[x][5] )

						If aLayOut[x][2] == "N"
							cConteudo   := Val( cConteudo ) / IIF( aLayOut[x][6] > 0, 100, 1 )
						EndIf

						AAdd( aItSum, { aLayOut[x][1], aLayOut[x][2], cConteudo } )

					Next x

				EndCase

			EndDo

		EndIf

		//Fecha o arquivo e finaliza o processamento
		oFile:Close()

	EndIf

	//----------------------------------------------------------
	// ( SZ0 ) Grava o LOG de controle de Arquivo EDI
	//----------------------------------------------------------
	If !EMPTY( aItSC5 )
		Processa( { || xGravaSZ0( aItSC5 ) }, OemToAnsi("Aguarde... Gravando o LOG ... " ) )
	EndIf

	aItSC5  := {}

	//----------------------------------------------------------
	// ( PEDIDO ) Faz o Processamento do PEDIDO DE VENDA
	//----------------------------------------------------------
/*    If !EMPTY( aItSC5 ) .AND. !EMPTY( aItSC6 )
	    Processa( { || ProcEDI( aItSC5, aItSC6 ) }, OemToAnsi("Aguarde..."), OEMToAnsi("Gerando Pedido de Venda ... "),.F. )
    EndIf
*/
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} lReg01()
Monta o layout do Registro 001 - CABEÃ‡ALHO

	@author  Marcos Gomes - @INTEGRAERP
	@version P12
	@since   06/02/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
User Function RFATA01C( cAliasARQ, nRecno, nOpcX )

	Local lRet := .f.
	Local lErro := .f.
	LOCAL aCabec := {}
	LOCAL aItSC6 := {}
	LOCAL nZ
	LOCAL cNumPed   := ""
	LOCAL dEmissao  := dDataBase
	LOCAL l1aUn    := .f.
	LOCAL l2aUn    := .f.
	Local cTabela := "" //PAULO BINDO
	LOCAL cIDProc   := SZ0->Z0_ID

	Local cCodProd := ""

	DEFAULT nOpcX     := 3    // 3-INCLUSAO; 4-ALTERAÇÃO

	//----------------------------------------------------------
	// ( SZ0 ID ) Faz o Processamento do PEDIDO DE VENDA
	//----------------------------------------------------------
/*    DBSelectArea("SZ0")
    DBOrderNickName( "Z0IDTIPO" ) // (1) Z0_FILIAL + Z0_ID + Z0_TIPOREG
    If DBSeek( xFilial("SZ0") + cIDProc, .f. )
        cIDProc := SZ0->Z0_ID
    Else
        ALERT( "ID dessa transação não foi encontrado, VERIFIQUE !!!" )
        Return(.f.)    
    EndIf
*/

	// (SA1) Posiciona o cadastro de cliente do FATURAMENTO
	DBSelectArea("SA1")
	SA1->( DBSetOrder(3))   // (3) A1_FILIAL + A1_CGC
	SA1->( DBSeek( xFilial("SA1") + SZ0->Z0_CGCCOMP, .f. ) )

	If FOUND()
		cCliFat     := SA1->A1_COD
		cLojFat     := SA1->A1_LOJA
		cTipoCli    := SA1->A1_TIPO
		cCondPag    := SA1->A1_COND
		cTabela     := SA1->A1_TABELA
		nFrete      := 0
	Else
		ALERT( "Dados do cliente não encontrados, VERIFIQUE !!! ")
		Return(.f.)
	EndIf

	// (SA1) Posiciona o cadastro de cliente de ENTREGA
	DBSelectArea("SA1")
	SA1->( DBSetOrder(3))   // (3) A1_FILIAL + A1_CGC
	SA1->( DBSeek( xFilial("SA1") + SZ0->Z0_CGCENTR, .f. ) )

	If FOUND()
		cCliEnt     := SA1->A1_COD
		cLojEnt     := SA1->A1_LOJA
	EndIf

	//----------------------------------------------------------
	// ( SC5 ) BUSCA O NUMERO DO PEDIDO DE VENDA
	//----------------------------------------------------------
	If !EMPTY( SZ0->Z0_NUMPED )

		IF MSGYESNO( "Pedido já GERADO anteriormente ! Deseja GERAR novamente ? ", "PEDIDO GERADO")
			DBSelectArea("SC5")
			DBSetOrder(1)
			If DBSeek( xFilial("SC5") + SZ0->Z0_NUMPED, .f. )
				If !EMPTY( SC5->C5_NOTA )
					ALERT( "O pedido de VENDA: " + SZ0->Z0_NUMPED + " não pode ser alterado ! NF JÁ EMITIDA VERIFIQUE !!!" )
					Return(.f.)
				EndIf
			Endif

			cNumPed := SZ0->Z0_NUMPED   // numero do pedido de venda
			nOpcX   := 4                // ALTERAÇÃO

		Else
			Return(.f.)
		EndIf

	Else

		nOpcX   := 3    // INCLUSAO

		DBSelectArea("SC5")
		DBSetOrder(1)

		cNumPed := GetSXENum("SC5","C5_NUM")
		Do While SC5->(dbSeek(xFilial("SC5") + cNumPed))
			ConfirmSX8()
			cNumPed := GetSXENum("SC5","C5_NUM")
		EndDo

		//->> Dar rollback para não pular a numeração devido ao inicializador padrão do numero no sx3
		RollBAckSx8()

	EndIf

	//----------------------------------------------------------
	// ( SC5 ) ALIMENTA O ARRAY COM OS DADOS DO CABECALHO DO PV
	//----------------------------------------------------------
	aAdd( aCabec, { "C5_NUM"    	, cNumPed               , Nil } ) 	//->> Numero do Pedido
	aAdd( aCabec, { "C5_TIPO"  	    , "N"                   , Nil } ) 	//->> Tipo de Pedido
	aAdd( aCabec, { "C5_CLIENTE"	, cCliFat	            , Nil } )	    //->> Cliente de Faturamento
	aAdd( aCabec, { "C5_LOJACLI"	, cLojFat	            , Nil } )	    //->> Loja de Faturamento
	aAdd( aCabec, { "C5_CLIENT"	    , cCliEnt	            , Nil } )	//->> Cliente de Entrega
	aAdd( aCabec, { "C5_LOJAENT"	, cLojEnt	            , Nil } )	//->> Loja de Entrega
	aAdd( aCabec, { "C5_EMISSAO"	, dEmissao		        , Nil } )	//->> Emissao
	aAdd( aCabec, { "C5_TIPOCLI"	, cTipoCli    	        , Nil } )	//->> Tipo de Cliente
	aAdd( aCabec, { "C5_CONDPAG"	, cCondPag		        , Nil } )	//->> Condição de Pagamento
	aAdd( aCabec, { "C5_TIPLIB"	    , "1"		            , Nil } )	//->> Tipo de Liberacao
	aAdd( aCabec, { "C5_DESCFI"	    , SA1->A1_XDESCFI       , Nil } )	//->> Desconto Financeiro
	aAdd( aCabec, { "C5_TRANSP"     , SA1->A1_TRANSP        , Nil } )
	aAdd( aCabec, { "C5_FRETE"	    , nFrete		        , Nil } )	//->> Frete
	aAdd( aCabec, { "C5_DESPESA"	, 0			            , Nil } )	//->> Despesa
	aAdd( aCabec, { "C5_SEGURO"	    , 0		                , Nil } )	//->> Seguro
	aAdd( aCabec, { "C5_FRETAUT"	, 0		                , Nil } )	//->> Frete Auto
	aAdd( aCabec, { "C5_MOEDA"	    , 1			            , Nil } )	//->> Moeda
	aAdd( aCabec, { "C5_XPEDCLI"    , SZ0->Z0_PVCOMPR       , Nil } )
	aAdd( aCabec, { "C5_VEND1"      , SA1->A1_VEND          , Nil } )
	aAdd( aCabec, { "C5_VEND2"      , SA1->A1_XREPRES       , Nil } )
	aAdd( aCabec, { "C5_XTIPOP"     , "01"                  , Nil } )
	aAdd( aCabec, { "C5_XIDECOM"	, ""	                , Nil } )	//->> Id eCommerce
	aAdd( aCabec, { "C5_XDINCLU"	, ddatabase             , Nil } )	//->> Dt Incl eCom
	aAdd( aCabec, { "C5_XHINCLU"	, time()	       	    , Nil } )	//->> Hr Incl eCom
	aAdd( aCabec, { "C5_XDUPDAT"	, dDataBase             , Nil } )	//->> Dt Alte eCom
	aAdd( aCabec, { "C5_XHUPDAT"	, time()		       	, Nil } )	//->> Hr Alte eCom
	aAdd( aCabec, { "C5_XNVDAEC"	, ""               		, Nil } )	//->> Numero da Venda no e-Commerce

	//----------------------------------------------------------
	// (SZ1) Busca o(s) Item(ns) do PV
	//----------------------------------------------------------
	DBSelectArea("SZ1")
	DBSetOrder(1)  //  Z1_FILIAL + Z1_ID + Z1_TIPOREG + Z1_ITEM
	If DBSeek( xFilial("SZ1") + cIDProc, .f. )

		While SZ1->( !EOF() ) .AND. SZ1->Z1_FILIAL = xFilial("SZ1") .AND. SZ1->Z1_ID == cIDProc

			cCodProd := "" 
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
					l1aUn    := .T.
					l2aUn    := .F.
				Else
					cErrCod  := "10"
					cErrDesc := "Código não Encontrado: " + SZ1->Z1_CODPROD
					lErro    := .t.
					l1aUn    := .t.
					l2aUn    := .f.
				EndIf
			Else
				cErrCod  := "00"
				cCodProd := SB1->B1_COD
				lErro    := .f.
				l1aUn    := .f.
				l2aUn    := .t.
			EndIf

			//----------------------------------------------------------
			// (SB1) Verifica se o produto está BLOQUEADO
			//----------------------------------------------------------
			If SB1->B1_MSBLQL == "1"
				cErrCod  := "20"    // produto BLOQUEADO
				cErrDesc := "Produto Bloqueado: " + AllTrim( cCodProd )
				lErro    := .t.

				DBSelectArea("SZ1")
				RECLOCK( "SZ1", .f. )
				SZ1->Z1_CODPROC := cErrCod // PRODUTO BLOQUEADO
				MSUNLOCK()
				ALERT( cErrDesc + " e será ignorado !!! " )
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
					ALERT( cErrDesc + " e será ignorado !!! " )

				EndIf
			Else

				cErrCod  := "30"    // produto NAO POSSUI TABELA DE PRECO
				cErrDesc := "Produto sem tabela Preco: " + AllTrim( cCodProd )
				lErro    := .t.

				DBSelectArea("SZ1")
				RECLOCK( "SZ1", .f. )
				SZ1->Z1_CODPROC := cErrCod // PRODUTO BLOQUEADO OU NAO EXISTE NA TABELA DE PRECO
				MSUNLOCK()
				ALERT( cErrDesc + " e será ignorado !!! " )

			EndIf

			//----------------------------------------------------------
			// (SC6) Alimenta o Array do(s) Item(ns) do PEDIDO DE VENDA
			//----------------------------------------------------------
			If !lErro

				nVlrTot := SZ1->( Z1_PRCOBRU * Z1_QTDPED )

				aItem := {}
				AAdd( aItem, { "C6_ITEM"    , SUBSTR( SZ1->Z1_ITEM, 3 , TamSX3("Z1_ITEM")[1])   , Nil } ) // Item
				AAdd( aItem, { "C6_PRODUTO" , SB1->B1_COD 										, Nil } ) // Produto

				//----------------------------------------------------------
				// (1a Unidade) primeira unidade de medida
				//----------------------------------------------------------
				If l1aUn
					AAdd( aItem, { "C6_DESCRI"  , SB1->B1_DESC 									    , Nil } ) // Descricao do Produto
					AAdd( aItem, { "C6_UM"      , SB1->B1_UM , NIL } )
					AAdd( aItem, { "C6_XUMVEN"  , SB1->B1_UM , NIL } )
					AAdd( aItem, { "C6_QTDVEN"  , Round( SZ1->Z1_QTDPED , TamSX3("C6_QTDVEN")[2])   , Nil } )   // Quantidade
					//  AAdd( aItem, { "C6_PRUNIT"  , Round( SZ1->Z1_PRCOBRU, Tamsx3("C6_PRUNIT")[2])   , Nil } ) // Preco Unit.
					AAdd( aItem, { "C6_PRCVEN"  , Round( SZ1->Z1_PRCOBRU, Tamsx3("C6_PRCVEN")[2])   , Nil } ) // Preco Unit.
					AAdd( aItem, { "C6_VALOR"   , Round( SZ1->Z1_VLLIQU1, Tamsx3("C6_VALOR")[2])	        , Nil } ) // Valor Tot.

					//----------------------------------------------------------
					// (2a Unidade) segunda unidade de medida
					//----------------------------------------------------------
				ElseIf l2aUn

					AAdd( aItem, { "C6_SEGUM"   , SB1->B1_SEGUM     , NIL } )
					AAdd( aItem, { "C6_XUMVEN"  , SB1->B1_SEGUM     , NIL } )
					AAdd( aItem, { "C6_UNSVEN"  , Round( SZ1->Z1_QTDPED  , TamSX3("C6_UNSVEN")[2])    , Nil } )   // Quantidade
					AAdd( aItem, { "C6_QUMVEN"  , Round( SZ1->Z1_PRCOLIQ , TamSX3("C6_UNSVEN")[2])    , Nil } )   // Quantidade

					nQtdVen := ConvUM( SB1->B1_COD, 0, SZ1->Z1_QTDPED, 1 )
					nPrcVen := SZ1->Z1_VLLIQU1 / nQtdVen

					AAdd( aItem, { "C6_DESCRI"  , SB1->B1_XDESC                                 , Nil } )           // Descrição do Produto
					AAdd( aItem, { "C6_QTDVEN"  , Round( nQtdVen , TamSX3("C6_QTDVEN")[2])      , Nil } )   // Quantidade
					//  AAdd( aItem, { "C6_PRUNIT"  , Round( nPrcVen , Tamsx3("C6_PRUNIT")[2])      , Nil } ) // Preco Unit.
					AAdd( aItem, { "C6_PRCVEN"  , Round( nPrcVen , Tamsx3("C6_PRCVEN")[2])      , Nil } ) // Preco Unit.
					AAdd( aItem, { "C6_VALOR"   , Round( SZ1->Z1_VLLIQU1, Tamsx3("C6_VALOR")[2]), Nil } ) // Valor Tot.

				EndIf

				AAdd( aItem, { "C6_ENTREG"  , DataValida(dDatabase+3)     									, Nil } ) // Dt.Entrega
				AAdd( aItem, { "C6_LOCAL"   , SB1->B1_LOCPAD			    	       		    , Nil } ) // Almoxarifado
				AAdd( aItem, { "C6_OPER"    , "01"                                              , nil } )

				AAdd( aItSC6, aClone(aItem) )

			EndIf

			SZ1->( DBSkip() )

		EndDo

	EndIf

	// https://tdn.totvs.com/display/public/PROT/FWVetByDic
	//    aCabec  := FWVetByDic( aCabec, "SC5", 1 )
	//    aItSC6  := FWVetByDic( aItSC6, "SC6", 1 )

	//----------------------------------------------------------
	// ( mata410 ) - Executa o EXECAUTO do PEDIDO DE VENDA -
	//----------------------------------------------------------
	lAutoErrNoFile  := .T.
	lMSErroAuto     := .F.
	aLog            := {}
	cErro           := ""

	MSExecAuto( { |x,y,z| Mata410(x,y,z) }, aCabec, aItSC6, nOpcX )

	If lMSErroAuto
		alert(" Erro !!! ")
		aLog  := GetAutoGRLog()
		For nZ:=1 to 100
			If nZ <= Len(aLog)
				cErro += aLog[nZ]+CRLF
			Else
				Exit
			EndIf
		Next nZ
		alert(cErro)
//              MostraErro( aLog )

		DBSelectArea("SZ0")
		DBSetOrder(1)
		If DBSeek( xFilial("SZ0") + cIDProc, .f. )
			RECLOCK( "SZ0", .f. )
			SZ0->Z0_STATUS  := "00"
			MSUNLOCK()
		EndIf
	Else
		DBSelectArea("SZ0")
		DBSetOrder(1)
		If DBSeek( xFilial("SZ0") + cIDProc, .f. )
			RECLOCK( "SZ0", .f. )
			SZ0->Z0_STATUS  := "01"
			SZ0->Z0_NUMPED  := cNumPed
			MSUNLOCK()
		EndIf

		If nOpcX = 4
			Alert("Pedido de venda: " + cNumPed + " ALTERADO com SUCESSO !!! ")
		Else
			Alert("Pedido de venda: " + cNumPed + " GERADO com SUCESSO !!! ")
		EndIf

	EndIf

Return(lRet)
