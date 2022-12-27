#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "PCPC200.CH"

//Constantes para uso no array saCargos
#DEFINE IND_ACARGO_PAI  1
#DEFINE IND_ACARGO_COMP 2

//Constantes referentes aos ícones da tree
#DEFINE VALIDO_A   "FOLDER5"
#DEFINE VALIDO_F   "FOLDER6"
#DEFINE INVALIDO_A "FOLDER7"
#DEFINE INVALIDO_F "FOLDER8"

Static soDbTree   := NIL
Static snSeqTree  := 0
Static saCargos   := {}
Static saTreeLoad := {}

Static snTamCod   := GetSx3Cache("G1_COD"    ,"X3_TAMANHO")
Static snTamComp  := GetSx3Cache("G1_COMP"   ,"X3_TAMANHO")
Static snTamTRT   := GetSx3Cache("G1_TRT"    ,"X3_TAMANHO")
Static snTamRev   := GetSx3Cache("B1_REVATU" ,"X3_TAMANHO")
Static snTamPromp := TamPrompt()

/*/{Protheus.doc} PCPC200()
Consulta de Estrutura do Item
@author Jamer Nunes Pedroso 
@since 23/01/2021
@version 1.0
@return NIL
/*/
User Function VBYPC200(cCodProd)
	Local aArea := GetArea()


	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		Help(' ',1,"Help" ,,"Rotina não disponível nesta release.",2,0,,,,,,) // STR0002 - "Rotina não disponível nesta release."
		Return
	EndIf


	Pergunte("PCPC200",.F.)
	MV_PAR01 := cCodProd	

    if !BY200VldPrd(cCodProd)
	   Return(.F.)
	Endif 

	P200Proces()
    

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return oModel
/*/
Static Function ModelDef()
	Local oStruCab := P200StrCab(.T.) // Não exibido
	Local oModel   := MPFormModel():New("BYPC200")

	// Mestre
	oModel:AddFields("MASTER", /*cOwner*/, oStruCab, , ,{|| P200LoadM()})
	oModel:GetModel ("MASTER" ):SetDescription("Consulta da Estrutura do Item") // STR0001 - "Consulta da Estrutura do Item"
	oModel:GetModel ("MASTER" ):SetOnlyQuery()

	// Demais definições do modelo
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription("Consulta da Estrutura do Item") // STR0001 - "Consulta da Estrutura do Item"

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return oView
/*/
Static Function ViewDef()

	Local oModel   := FWLoadModel("BYPC200")
	Local oStruCab := P200StrCab(.F.) // Não exibido
	Local oView    
	
	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_MASTER", oStruCab, "MASTER" )

	// V_TREE - Cria View da Tree
	oView:AddOtherObject("V_TREE", {|oPanel| MontaTree(oPanel)})

	oView:CreateHorizontalBox("HEADER",   0) // Não exibe cabeçalho
	oView:CreateHorizontalBox("DETAIL", 070)

	oView:SetOwnerView("VIEW_MASTER", "HEADER")
	oView:SetOwnerView("V_TREE", "DETAIL")

	oView:AddUserButton("Parâmetros", "", {|oModel| P200AltPar(oModel) }, , , MODEL_OPERATION_VIEW, .T.) // STR0003 - "Parâmetros"

Return oView

/*/{Protheus.doc} P200AltPar
Função acionada no botão "Parâmetros" - abre novamente a Pergunta
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 oModel - Modelo de dados
@return NIL
/*/
Static Function P200AltPar(oModel)
	If Pergunte("PCPC200",.T.)
		MontaTree()
	EndIf

Return

/*/{Protheus.doc} P200StrCab
Monta estrutura de campos do Cabeçalho (não será exibido o cabeçalho)
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 lModel - Modelo de dados
@return oStru
/*/
Static Function P200StrCab(lModel)
	Local oStru := NIL

	// MVC exige que tenha campo no modelo Mestre - Esses campos não são exibidos na VIEW
	If lModel
		oStru := FWFormModelStruct():New()
		oStru:AddField("Cabeçalho","Cabeçalho","CABECALHO","C",1,0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T.) // STR0004 - "Cabeçalho"
	Else
		oStru := FWFormViewStruct():New()
		oStru:AddField("CABECALHO","01","Cabeçalho","Cabeçalho",NIL,"C","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL) // STR0004 - "Cabeçalho"
	EndIf

Return oStru

/*/{Protheus.doc} P200LoadM
Função para carregar o cabeçalho (não exibido)
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return aLoad
/*/
Static Function P200LoadM()
	Local aLoad := {" "}

Return aLoad

/*/{Protheus.doc} P200Proces
Função para abertura da tela
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return nValor
/*/
Static Function P200Proces()
	Local nValor	:= 0
	Local aButtons	:= { { .F., Nil }    ,;  	//  1 - Copiar
	                     { .F., Nil }    ,;  	//  2 - Recortar
	                     { .F., Nil }    ,;  	//  3 - Colar
	                     { .T., Nil }    ,;  	//  4 - Calculadora
	                     { .T., Nil }    ,;  	//  5 - Spool
	                     { .T., Nil }    ,;  	//  6 - Imprimir
	                     { .F., ""  }    ,;  	//  7 - Cancelar
	                     { .T., "Fechar" },;  	//  8 - "Fechar"
	                     { .F., Nil }    ,;		//  9 - WalkTrhough
	                     { .T., Nil }    ,;  	// 10 - Ambiente
	                     { .F., Nil }    ,;  	// 11 - Mashup
	                     { .T., Nil }    ,;  	// 12 - Help
	                     { .T., Nil }    ,;  	// 13 - Formulário HTML
	                     { .F., Nil } }      	// 14 - ECM
	Default lAutoMacao := .F.

	IF !lAutoMacao
		nValor := FWExecView("Consulta","BYPC200",OP_PESQUISAR,/*oDlg2*/,{||.T.},/*bOk*/,/*50*/,aButtons) // STR0005 - "Consulta"
	ENDIF
Return nValor

/*/{Protheus.doc} MontaTree
Função responsável por fazer a criação do objeto da TREE
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 oPanel - Painel onde deve ser criada a tree
@return Nil
/*/
Static Function MontaTree(oPanel)
	//Local lMontouTree  := .F.

	// Inicializa as variáveis do tipo Static deste fonte
	snSeqTree  := 0
	saCargos   := {}
	saTreeLoad := {}

	// Cria ou Reseta a Tree
	If soDbTree == Nil
		soDbTree := DbTree():New(100, 100, 100, 100, oPanel, {|| TreeChange()}, /*bRClick*/, .T.,,,	"Código" 				+ ";" + ; // STR0010 - "Código"
																								"Descrição"					+ ";" + ; // STR0011 - "Descrição"
																								RetTitle("B1_TIPO")		+ ";" + ;
																								RetTitle("B1_UM")		+ ";" + ;
																								"Sequência"					+ ";" + ; // STR0015 - "Sequência"
																								RetTitle("G1_QUANT")	+ ";" + ;
																								"Custo da Unidade(KG,ML)" +   ";" + ;
																								"Custo do Cadastro"     + ";" + ;
																								"Custo Estrutura"       +   ";" + ;
																								"Percentual"            +   ";" + ;
																								"Data Ult. Mov"         +   ";" + ;
																								"Índice Perda"					+ ";" + ; // STR0012 - "Índice Perda"
																								RetTitle("G1_INI")		+ ";" + ;
																								RetTitle("G1_FIM")		+ ";" + ;
																								RetTitle("G1_FIXVAR")	+ ";" + ;
																								RetTitle("G1_GROPC")	+ ";" + ;
																								RetTitle("G1_OPC")		+ ";" + ;
																								RetTitle("G1_REVINI")	+ ";" + ;
																								RetTitle("G1_REVFIM")	+ ";" + ;
																								"Nível"					+ ";" + ; // STR0013 - "Nível"
																								RetTitle("G1_LOCCONS")	+ ";" + ;
																								RetTitle("G1_FANTASM")	+ ";" + ;
																								RetTitle("G1_LISTA")	+ ";" + ;
																								"Roteiro"					+ ";" + ; // STR0016 - "Roteiro"
																								"Operação"					+ ";" + ; // STR0017 - "Operação"
																								"Observação")						  // STR0014 - "Observação"

		soDbTree:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		soDbTree:Reset()
		snSeqTree := 0
	EndIf

	AddPaiTree(MV_PAR01)

	TreeChange()

	If !Empty(saTreeLoad)
		soDbTree:EndTree()
	EndIf

Return Nil

/*/{Protheus.doc} TreeChange
Execuções de ações durante clique/change na Tree
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return NIL
/*/
Static Function TreeChange()
	Local oView  := FwViewActive()
	Local cCargo := soDbTree:GetCargo()

	// Verifica no array saTreeLoad se este item já foi carregado (segundo nível)
	If Carregado(cCargo)
		Return
	EndIf

	// Altera cursor do mouse indicando processamento
	CursorWait()

	// Adiciona componentes na tree de acordo com o que foi carregado no modelo de componentes
	AddCmpTree(cCargo, "COMP")

	// Retorna cursor do mouse
	CursorArrow()

	soDbTree:SetFocus()

Return

/*/{Protheus.doc} AddPaiTree
Adiciona o item pai na tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCodPai, - Código do item pai
@param 02 oModel   - Modelo de dados
@return Nil
/*/
Static Function AddPaiTree(cCodPai,oModel)
	Local cAliasPai    := GetNextAlias()
	Local cRevAtu	   := ""
	Local cPrompt      := ""
	Local lValido	   := .T.
	Local cFolderA     := VALIDO_A
	Local cFolderF     := VALIDO_F
	Default lAutoMacao := .F.

	P200TrataP()

	BeginSQL Alias cAliasPai
		SELECT DISTINCT SG1.G1_COD, SB1.B1_DESC, SB1.B1_REVATU, SB1.B1_TIPO, SB1.B1_UM, SG1.G1_NIV, SG1.G1_INI, SG1.G1_FIM
		  FROM %Table:SG1% SG1,
		       %Table:SB1% SB1
		 WHERE SG1.G1_FILIAL = %XFilial:SG1%
		   AND SB1.B1_FILIAL = %XFilial:SB1%
		   AND SB1.B1_COD    = SG1.G1_COD
		   AND SG1.G1_COD    = %Exp:cCodPai%
		   AND SG1.%NotDel%
		   AND SB1.%NotDel%
	EndSQL

	If !(cAliasPai)->(Eof())
		// Revisão?
		If Empty(MV_PAR05)
			cRevAtu := (cAliasPai)->B1_REVATU
		Else
			cRevAtu := MV_PAR05
		EndIf

		// Itens vencidos?
		If MV_PAR07 = 1
			If dDataBase < StoD((cAliasPai)->G1_INI) .Or. dDataBase > StoD((cAliasPai)->G1_FIM)
				lValido := .F.
			EndIf
		EndIf

		//If P200ValRot((cAliasPai)->G1_COD)
			cCargo  := MontaCargo(MV_PAR01, MV_PAR01, "", cRevAtu, "CPAI")

			cFolderA  := If(lValido, VALIDO_A, INVALIDO_A)
			cFolderF  := If(lValido, VALIDO_F, INVALIDO_F)
 
            VlCusto  := Round( GetCustoPrd( (cAliasPai)->G1_COD )[1],6 ) // CUsto Unitário dividido pela quantidade da estrutura 
			VdData   :=  GetCustoPrd( (cAliasPai)->G1_COD )[2]
            VlStCus  := U_SumCosts((cAliasPai)->G1_COD)[3]
            VlUniSt  := U_SumCosts((cAliasPai)->G1_COD)[5]
			VlPerc   := Round( U_SumCosts((cAliasPai)->G1_COD)[6],2 )

			cPrompt :=	(cAliasPai)->G1_COD 	+ ";" + ;
						(cAliasPai)->B1_DESC 	+ ";" + ;
						(cAliasPai)->B1_TIPO 	+ ";" + ;
						(cAliasPai)->B1_UM		+ ";" + ;
						" "						+ ";" + ;
						cValToChar(MV_PAR06)	+ ";" + ;
						"R$ "+cValTochar(VlUniSt)     + ";" + ;
						"R$ "+cValToChar(vlCusto)     + ";" + ; 
						"R$ "+cValToChar(vlStCus)     + ";" + ;
						cValToChar(vlPerc)+" %"     + ";" + ;
						Dtoc(vdData)                 + ";" +; 
						" " 					+ ";" + ;
						" " 					+ ";" + ;
						" " 					+ ";" + ;
						" "  					+ ";" + ;
						" "						+ ";" + ;
						" " 					+ ";" + ;
						cRevAtu 				+ ";" + ;
						cRevAtu				 	+ ";" + ;
						(cAliasPai)->G1_NIV 	+ ";" + ;
						" "						+ ";" + ;
						" "						+ ";" + ;
						" "						+ ";" + ;
						" "						+ ";" + ;
						" "
			IF !lAutoMacao
				soDbTree:AddTree(PadR(cPrompt,snTamPromp), .T., cFolderA, cFolderF, , , cCargo)
				soDbTree:TreeSeek(cCargo)
				soDbTree:Refresh()
				soDbTree:SetFocus()
			ENDIF
		//EndIf
	EndIf

	(cAliasPai)->(DbCloseArea())

Return

/*/{Protheus.doc} AddCmpTree
Adiciona os componentes na tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargoPai	- Cargo do nível pai de onde os componentes serão adicionados.
@param 02 cTipo		- Indicador de tipo de registro:
					ESTR - Componente da estrutura
					TEMP - Nó temporário da tree, utilizado apenas para exibir a opção de expandir o nível (+)
@return Nil
/*/
Static Function AddCmpTree(cCargoPai, cTipo)
	Local cAliasSG1 	:= GetNextAlias()
	Local cAliasSGF 	:= GetNextAlias()
	Local cDataRef		:= DToS(MV_PAR03)
	Local cCargo    	:= ""
	Local cCodPai   	:= RetInf(cCargoPai, "COMP")
	Local cRevAtu   	:= RetInf(cCargoPai, "REV")
	Local nPos      	:= aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cCargoPai })
	Local lValido		:= .T.
	Local cFolderA  	:= VALIDO_A
	Local cFolderF  	:= VALIDO_F
	Local cFixVar		:= ""
	Local cFantasm		:= ""
	Local cRotPai		:= ""
	Local cRoteiro		:= ""
	Local cOperacao		:= ""
	Local cNivelEstr	:= ""
	Default lAutoMacao  := .F.

	If nPos > 0
		If RetInf(saCargos[nPos][IND_ACARGO_COMP], "TIPO") == "TEMP"
			soDbTree:TreeSeek(saCargos[nPos][2])
			soDbTree:DelItem()
			soDbTree:TreeSeek(cCargoPai)
		EndIf
	EndIf

	If MV_PAR07 = 1
		BeginSQL Alias cAliasSG1
			SELECT SG1.G1_COMP,	 SG1.G1_TRT, SB1.B1_DESC,   SB1.B1_TIPO,   SB1.B1_UM,	  SG1.G1_TRT,  SG1.G1_QUANT,   SG1.G1_PERDA,   SG1.G1_INI,   SG1.G1_FIM,     SG1.G1_FIXVAR,
				   SG1.G1_GROPC, SG1.G1_OPC, SG1.G1_REVINI, SG1.G1_REVFIM, SB1.B1_REVATU, SG1.G1_NIV,  SG1.G1_LOCCONS, SG1.G1_FANTASM, SG1.G1_LISTA, SB1.B1_OPERPAD, SG1.G1_OBSERV
			FROM %Table:SG1% SG1,
				 %Table:SB1% SB1
			WHERE SG1.G1_FILIAL  = %XFilial:SG1%
			AND SB1.B1_FILIAL  = %XFilial:SB1%
			AND SB1.B1_COD     = SG1.G1_COMP
			AND SG1.G1_COD     = %Exp:cCodPai%
			AND SG1.G1_REVINI <= %Exp:cRevAtu%
			AND SG1.G1_REVFIM >= %Exp:cRevAtu%
			AND SG1.%NotDel%
			AND SB1.%NotDel%
			ORDER BY SG1.G1_COMP, SG1.G1_TRT
		EndSQL
	Else
		BeginSQL Alias cAliasSG1
			SELECT SG1.G1_COMP,	 SG1.G1_TRT, SB1.B1_DESC,   SB1.B1_TIPO,   SB1.B1_UM,	  SG1.G1_TRT,  SG1.G1_QUANT,   SG1.G1_PERDA,   SG1.G1_INI,   SG1.G1_FIM,     SG1.G1_FIXVAR,
				   SG1.G1_GROPC, SG1.G1_OPC, SG1.G1_REVINI, SG1.G1_REVFIM, SB1.B1_REVATU, SG1.G1_NIV,  SG1.G1_LOCCONS, SG1.G1_FANTASM, SG1.G1_LISTA, SB1.B1_OPERPAD, SG1.G1_OBSERV
			FROM %Table:SG1% SG1,
				 %Table:SB1% SB1
			WHERE SG1.G1_FILIAL  = %XFilial:SG1%
			AND SB1.B1_FILIAL  = %XFilial:SB1%
			AND SB1.B1_COD     = SG1.G1_COMP
			AND SG1.G1_COD     = %Exp:cCodPai%
			AND SG1.G1_INI    <= %Exp:cDataRef%
			AND SG1.G1_FIM    >= %Exp:cDataRef%
			AND SG1.G1_REVINI <= %Exp:cRevAtu%
			AND SG1.G1_REVFIM >= %Exp:cRevAtu%
			AND SG1.%NotDel%
			AND SB1.%NotDel%
			ORDER BY SG1.G1_COMP, SG1.G1_TRT
		EndSQL
	EndIf

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + cCodPai))
	cRotPai := SB1->B1_OPERPAD

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))

	dbSelectArea("SGF")
	SGF->(dbSetOrder(2))

	BeginSQL Alias cAliasSGF
		SELECT DISTINCT(GF_ROTEIRO)
		FROM %Table:SGF%
	 	WHERE GF_FILIAL	= %XFilial:SGF%
	   	AND GF_PRODUTO 	= %Exp:cCodPai%
	   	AND %NotDel%
    EndSQL

    Count To nCountRot

	(cAliasSGF)->(dbGoTop())

    If nCountRot == 1
    	cRotPai := (cAliasSGF)->GF_ROTEIRO
    EndIf

	While !(cAliasSG1)->(Eof())
		lValido := .T.

		If SG1->(MsSeek(xFilial("SG1")+(cAliasSG1)->G1_COMP))
			cNivelEstr := SG1->G1_NIV
		Else
			cNivelEstr := "99"
		EndIf

		// Itens vencidos?
		If MV_PAR07 = 1
			If cDataRef < ((cAliasSG1)->G1_INI) .Or. cDataRef > ((cAliasSG1)->G1_FIM)
				lValido := .F.
			EndIf
		EndIf

		cCargo := MontaCargo(cCodPai, (cAliasSG1)->G1_COMP, (cAliasSG1)->G1_TRT, (cAliasSG1)->B1_REVATU, cTipo)

		cFolderA  := If(lValido, VALIDO_A, INVALIDO_A)
		cFolderF  := If(lValido, VALIDO_F, INVALIDO_F)

		// Tipo Quantidade
		If (cAliasSG1)->G1_FIXVAR = "V"
			cFixVar = "Variável" // STR0008 - "Variável"
		Else
			cFixVar = "Fixa" // STR0009 - "Fixa"
		EndIf

		// Fantasma?
		If (cAliasSG1)->G1_FANTASM = "1"
			cFantasm = "Sim" // STR0006 - "Sim"
		Else
			cFantasm = "Não" // STR0007 - "Não"
		EndIf

		// Roteiro
		cRoteiro  := ""
		cOperacao := ""

		If Empty(MV_PAR02)
			If !Empty(cRotPai)
				SGF->(dbSeek(xFilial("SGF") + cCodPai + cRotPai + (cAliasSG1)->G1_COMP))
				If SGF->GF_PRODUTO == cCodPai .And. SGF->GF_COMP == (cAliasSG1)->G1_COMP .And. SGF->GF_ROTEIRO == cRotPai
					cRoteiro  := SGF->GF_ROTEIRO
					cOperacao := SGF->GF_OPERAC
				EndIf
			EndIf
		Else
			SGF->(dbSeek(xFilial("SGF") + cCodPai + MV_PAR02 + (cAliasSG1)->G1_COMP))
			If SGF->GF_PRODUTO == cCodPai .And. SGF->GF_COMP == (cAliasSG1)->G1_COMP .And. SGF->GF_ROTEIRO == MV_PAR02
				cRoteiro  := SGF->GF_ROTEIRO
				cOperacao := SGF->GF_OPERAC
			Else
				(cAliasSG1)->(dbSkip())
				Loop
			EndIf
		EndIf

		If cTipo == "TEMP"
			If Empty(MV_PAR04) .Or. AllTrim( (cAliasSG1)->B1_TIPO ) == AllTrim( MV_PAR04 )
				soDbTree:AddItem(" ", cCargo, cFolderA, cFolderF, , , 2)
				aAdd(saCargos, {cCargoPai, cCargo})
				Exit
			EndIf
		Else
			// Tipo do item ?
			If Empty(MV_PAR04) .Or. AllTrim( (cAliasSG1)->B1_TIPO ) == AllTrim( MV_PAR04 )

			    VlCusto := Round( GetCustoPrd( (cAliasSG1)->G1_COMP )[1],6 ) 
				VdData   :=  GetCustoPrd( (cAliasSG1)->G1_COMP )[2]
                VlUniSt  := U_SumCosts((cAliasSG1)->G1_COMP)[5]
				VlStCus  := U_SumCosts((cAliasSG1)->G1_COMP)[3]  
				NqTD :=   Round( (cAliasSG1)->G1_QUANT,6)

                aStruSub := U_SumCosts(cCodPai)[4] 

                nPos := aScan(aStruSub, { |x|,  x[1] == (cAliasSG1)->G1_COMP } )

                VlPerc   := ROund( aStruSub[nPos,6],2 )
				
                //cValToChar(vlStCus*((cAliasSG1)->G1_QUANT * MV_PAR06)) + ";" + ;

				cPrompt :=	(cAliasSG1)->G1_COMP 							+ ";" + ;
							(cAliasSG1)->B1_DESC 							+ ";" + ;
							(cAliasSG1)->B1_TIPO							+ ";" + ;
							(cAliasSG1)->B1_UM								+ ";" + ;
							(cAliasSG1)->G1_TRT								+ ";" + ;
							cValToChar((cAliasSG1)->G1_QUANT)	            + ";" + ;
							"R$ "+cValToChar(VlUniSt)                             + ";" + ;
							"R$ "+cValToChar(vlCusto)                             + ";" + ;
							"R$ "+cValToChar(vlStCus*nQtd)                        + ";" + ;
							cValToChar(vlPerc)+" %"     + ";" + ;
							Dtoc(vdData)                 + ";" + ;
							cValToChar((cAliasSG1)->G1_PERDA)				+ ";" + ;
							DToC(SToD((cAliasSG1)->G1_INI ))				+ ";" + ;
							DToC(SToD((cAliasSG1)->G1_FIM ))				+ ";" + ;
							cFixVar											+ ";" + ;
							(cAliasSG1)->G1_GROPC							+ ";" + ;
							(cAliasSG1)->G1_OPC 							+ ";" + ;
							(cAliasSG1)->G1_REVINI							+ ";" + ;
							(cAliasSG1)->G1_REVFIM							+ ";" + ;
							cNivelEstr										+ ";" + ;
							(cAliasSG1)->G1_LOCCONS							+ ";" + ;
							cFantasm										+ ";" + ;
							(cAliasSG1)->G1_LISTA							+ ";" + ;
							cRoteiro										+ ";" + ;
							cOperacao										+ ";" + ;
							(cAliasSG1)->G1_OBSERV
				IF !lAutoMacao
					soDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderF, , , 2)

					soDbTree:TreeSeek(cCargo)
					AddCmpTree(cCargo, "TEMP")
					aAdd(saCargos, {cCargoPai, cCargo})
					soDbTree:TreeSeek(cCargoPai)
				ENDIF
			EndIf
		EndIf

		(cAliasSG1)->(dbSkip())
	End

	(cAliasSG1)->(DbCloseArea())
	(cAliasSGF)->(DbCloseArea())

Return

/*/{Protheus.doc} P200TrataP
Função para tratar os parâmetros informados na Pergunta
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@return NIL
/*/
Static Function P200TrataP()
	// Data referência?
	If Empty(MV_PAR03)
		MV_PAR03 := dDataBase
	EndIf

	// Quantidade necessária?
	If Empty(MV_PAR06) .Or. MV_PAR06 <= 0
		MV_PAR06 := 1
	EndIf

Return

/*/{Protheus.doc} P200ValRot
Função para validar se o item pertence ao roteiro informado no parâmetro
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cProduto - Código do item
@return lRet
/*/
Static Function P200ValRot(cProduto)
	Local lRet := .F.

	// Roteiro?
	If Empty(MV_PAR02)
		lRet := .T.
	Else
		SGF->(dbSeek( xFilial("SGF") + cProduto + MV_PAR02 ))
		If !SGF->(Eof()) .And. SGF->GF_PRODUTO == cProduto .And. SGF->GF_ROTEIRO == MV_PAR02
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} MontaCargo
Monta o campo CARGO do registro
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCodPai 	- Código do item pai
@param 02 cComp		- Código do item componente
@param 03 cTRT 		- Sequencia do item
@param 04 cRevAtu	- Revisão atual do item
@param 05 cTipo		- Indicador de tipo de registro:
					ESTR - Componente da estrutura
					TEMP - Nó temporário da tree, utilizado apenas para exibir a opção de expandir o nível (+)
@return cCargo - Campo CARGO formatado com o padrão do programa
/*/
Static Function MontaCargo(cCodPai,cComp,cTRT,cRevAtu,cTipo)
	Local cCargo := ""

	snSeqTree++

	cCargo := PadR(cCodPai , snTamCod)  + ;
	          PadR(cComp   , snTamComp) + ;
	          PadR(cTRT    , snTamTRT)  + ;
	          PadR(cRevAtu , snTamRev)  + ;
	          StrZero(snSeqTree, 9)     + ;
	          PadR(cTipo   , 4)

Return cCargo

/*/{Protheus.doc} RetInf
Extrai informações do  CARGO da Tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargo - Cargo o qual as informações serão extraídas
@param 02 cInfo	 - Indica a informação a ser extraída:
				 "IND"   - Indicador (IND_ESTR, IND_TEMP)
				 "PAI"   - Pai
				 "COMP"  - Componente
				 "RECNO" - Recno
				 "INDEX" - Index
				 "POS"   - Posição no array de controle (saCargos)
@return xRet - Informação solicitada
/*/
Static Function RetInf(cCargo, cInfo)
	Local xRet
	Local nStart   := 0
	Local nTamanho := 0

	Default cInfo := "COMP"

	If cInfo == "PAI"
		// Pai
		xRet := Left(cCargo, snTamCod)

	ElseIf cInfo == "COMP"
		// Componente
		nStart   := snTamCod + 1
		nTamanho := snTamComp
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "TRT"
		// Sequencia
		nStart   := snTamCod + snTamComp + 1
		nTamanho := snTamTRT
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "REV"
		// Revisão
		nStart   := snTamCod + snTamComp + snTamTRT + 1
		nTamanho := snTamRev
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "INDEX"
		// Index
		nStart   := snTamCod + snTamComp + snTamTRT + snTamRev + 1
		nTamanho := 9
		xRet := Val(Substr(cCargo, nStart, nTamanho))

	ElseIf cInfo == "TIPO"
		// Tipo
		nStart   := snTamCod + snTamComp + snTamTRT + snTamRev + 9 + 1
		nTamanho := 4
		xRet := Substr(cCargo, nStart, nTamanho)
	EndIf

Return xRet

/*/{Protheus.doc} Carregado
Extrai informações do Cargo da Tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargo - Cargo o qual as informações serão extraídas
@return lExiste - Indica se o item já foi carregado na tree
/*/
Static Function Carregado(cCargo)
	Local lExiste := .F.

	// Verifica no array saTreeLoad se este item já foi carregado
	// Se já foi adicionado na TREE, não faz a carga novamente
	If aScan(saTreeLoad,{|x| x==cCargo}) > 0
		lExiste := .T.
	Else
		aAdd(saTreeLoad,cCargo)
	EndIf

Return lExiste

/*/{Protheus.doc} TamPrompt
Indica o tamanho do Prompt conforme os campos
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@return - Tamanho do Prompt
/*/
Static Function TamPrompt()

Return 	GetSx3Cache("G1_COD"    , "X3_TAMANHO") + ;
		GetSx3Cache("B1_DESC"   , "X3_TAMANHO") + ;
		GetSx3Cache("B1_TIPO"   , "X3_TAMANHO") + ;
		GetSx3Cache("B1_UM"     , "X3_TAMANHO") + ;
		GetSx3Cache("G1_TRT"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_QUANT"  , "X3_TAMANHO") + GetSx3Cache("G1_QUANT","X3_DECIMAL") + 1 + ;
		GetSx3Cache("G1_PERDA"  , "X3_TAMANHO") + GetSx3Cache("G1_PERDA","X3_DECIMAL") + 1 + ;
		GetSx3Cache("G1_INI"    , "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_FIM"    , "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_FIXVAR" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_GROPC"  , "X3_TAMANHO") + ;
		GetSx3Cache("G1_OPC"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_REVINI" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_REVFIM" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_NIV"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_LOCCONS", "X3_TAMANHO") + ;
		GetSx3Cache("G1_FANTASM", "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_LISTA"  , "X3_TAMANHO") + ;
		GetSx3Cache("G1_OBSERV" , "X3_TAMANHO")

/*/{Protheus.doc} C200VldPrd
Valida o produto informado (parâmetro MV_PAR01)
@author Marcelo Neumann
@since 07/03/2019
@version 1.0
@return lValido -  Indica se o produto digitado possui estrutura
/*/
Static Function BY200VldPrd()

	Local lValido := .T.
	Default lAutoMacao := .F.

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	If !SG1->(dbSeek(xFilial("SG1") + MV_PAR01))
		lValido := .F.
		IF !lAutoMacao
			Help( , , 'Help', ,   "Não existe estrutura para esse produto.", ; //"Não existe estrutura para esse produto."
				1, 0, , , , , , {"Informe um produto que possua estrutura cadastrada."})  //"Informe um produto que possua estrutura cadastrada."
		ENDIF
	EndIf

Return lValido


/*/{Protheus.doc} GetCustoPrd
Valida o produto informado (parâmetro MV_PAR01)
@author Marcelo Neumann
@since 07/03/2019
@version 1.0
@return lValido -  Indica se o produto digitado possui estrutura
/*/
Static Function GetCustoPrd(cProduto)
Local nCusto 	:= 0
Local dCusto 	:= Stod("")
Local nSD1 		:= 0
Local dSD1 		:= Stod("")
Local nSD3 		:= 0
Local dSD3 		:= Stod("")
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

If nCusto == 0
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		nCusto := SB1->B1_CUSTD		// Custo Standard
		dCusto := SB1->B1_DATREF  	// Data Referencia do Custo
	EndIf
EndIf

If nCusto == 0
	cQuery := "SELECT TOP 1 SD3.D3_CUSTO1  AS CUSTO,"		+CRLF
	cQuery += "				SD3.D3_EMISSAO AS DATA,"		+CRLF
	cQuery += "				SD3.D3_QUANT   AS QUANT"		+CRLF
	cQuery += "	FROM "+RetSqlName("SD3")+" SD3 (NOLOCK)"	+CRLF
	cQuery += "	WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"+CRLF
	cQuery += "	  AND SD3.D3_COD     = '"+cProduto+"'"		+CRLF
	cQuery += "	  AND SD3.D3_CF      = 'PR0'"				+CRLF
	cQuery += "	  AND SD3.D_E_L_E_T_ = ' '"					+CRLF
	cQuery += "	ORDER BY SD3.D3_EMISSAO DESC"				+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
		nSD3 := Round((cAlias)->CUSTO / (cAlias)->QUANT,Tamsx3("D3_CUSTO1")[02])
		dSD3 := Stod((cAlias)->DATA)
	EndIf
	(cAlias)->(dbCloseArea())

	cQuery := "SELECT TOP 1 SD1.D1_CUSTO   AS CUSTO,"		+CRLF
	cQuery += "				SD1.D1_EMISSAO AS DATA,"		+CRLF
	cQuery += "				SD1.D1_QUANT   AS QUANT"		+CRLF
	cQuery += "	FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"	+CRLF
	cQuery += "	WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"+CRLF
	cQuery += "	     AND SD1.D1_COD     = '"+cProduto+"'"	+CRLF
	cQuery += "	     AND SD1.D1_CF     <> '1902'          "	+CRLF
	cQuery += "	     AND SD1.D1_CF     <> '2902'          "	+CRLF
	cQuery += "	  AND SD1.D_E_L_E_T_ = ' '"					+CRLF
	cQuery += "	ORDER BY SD1.D1_EMISSAO DESC"				+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())  .And. (cAlias)->(!Bof()) 
		nSD1 := Round((cAlias)->CUSTO / (cAlias)->QUANT,Tamsx3("D1_CUSTO")[2])
		dSD1 := Stod((cAlias)->DATA)
	EndIf
	(cAlias)->(dbCloseArea())

//	If dSD1 > dSD3

    If nSD1 > 0
		nCusto := nSD1
		dCusto := dSD1
	Else
		nCusto := nSD3
		dCusto := dSD3
	EndIf
EndIf


Return {nCusto,dCusto}


//Static Function Carrega_Custos_Stru()

