#INCLUDE "Protheus.ch"
/*/{Protheus.doc} SumCosts
description
@type User Function
@version  1.0
@author Jamer Nunes Pedroso 
@since 15/02/2021
@param cPrincipal, character, param_description
@return return_type, return_description
/*/

User Function SumCosts(cPrincipal)

	Local aStru    := {cPrincipal,1,0,{},0,0} // Codigo, Quantidade, Custo, aSon
	Local aStruSon := {}
	Local VlCusto  := 0
	Local VlPerc   := 0

	if BuscaEst(cPrincipal,@aStruSon) // Tem estrutura

		vlCusto := 0
		aEval(aStruSon,{|x| vlCusto += NoRound( x[3],6 ) })
		aEval(aStruSon,{|x|, x[6] := ( NoRound( x[3],6)* 100)/ vlCusto })
		aEval(aStruSon,{|x|, VlPerc += x[6] })

		aStru[3] := VlCusto
		aStru[4] := aStruSon
		aStru[5] := VlCusto
		vlPerc := 0
		//aEval(aStruSon,{|x| vlCusto += NoRound( x[3],6 ) })


	else // Não tem estrutura

		aStru[3] := NoRound( GetCustoPrd(cPrincipal),6 )

	endif

Return(aStru)


/*/{Protheus.doc} BuscaEst
description
@type Static Function 
@version  
@author Jamer Nunes Pedroso 
@since 15/02/2021
@param cCodProd, character, param_description
@param aStruSon, array, param_description
@return return_type, return_description
/*/

Static Function BuscaEst(cCodProd,aStruSon)

	Local cQuery
	Local lRet := .F.
	Local aStruSub := {}
	Local cAlias := GetNextAlias()
	Local Vlcusto := 0

	cQuery := "Select SG1.G1_COD, SG1.G1_COMP, SG1.G1_QUANT from "+ RetSqlName("SG1") + " SG1 (NOLOCK) "
	cQuery += "where SG1.G1_FILIAL = '" + xFilial("SG1") +"' "
	cquery += "and   SG1.G1_COD = '"+ cCodProd +"' "
	cQuery += "and   SG1.D_E_L_E_T_ <> '*' "

	DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), (cAlias) , .F., .T. )

	If (cAlias)->(Eof())

		lRet := .F.
	else

		lRet := .T.

		While !(cAlias)->(Eof())

			BuscaEst((cAlias)->G1_COMP,@aStruSub)

			//if Alltrim((cAlias)->G1_COMP)$"0015.99.0204|0015.99.0205"

			//   MsgStop( "0015.99.0204 | 0015.99.0205" )
			//endif

			// Custo do total da estrutura prevalece
			if Len(aStruSub) = 0 // Não há estrutura

				vlCusto := NoRound( GetCustoPrd((cAlias)->G1_COMP),6 )
			else                 // Há estrutura

				vlCusto := 0
				aEval(aStruSub,{|x| vlCusto += NoRound( x[3],6) })
			endif

			aEval(aStruSub,{|x|, x[6] := ( NoRound( x[3],6)* 100)/ vlCusto })

			//Codigo,     Quantidade,   Custo, aSon
			aadd(aStruSon,{(cAlias)->G1_COMP, (cAlias)->G1_QUANT, vlCusto * NoRound( (cAlias)->G1_QUANT,6), aStruSub, vlCusto, 0 })

			aStruSub := {}

			(cAlias)->(dbSkip())

		EndDo

	Endif

	(cAlias)->(dbCloseArea())

Return(lRet)

Static Function GetCustoPrd(cProduto)
//Local vValor := 0      
	//vValor := StaticCall(BYPC200, GetCustoPrd, ccOdprod)[1]

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

Return(nCusto)
