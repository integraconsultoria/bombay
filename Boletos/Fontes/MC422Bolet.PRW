#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

#DEFINE _TAMNOSSNUM 8
#DEFINE _TAMCARTEIR 2
#DEFINE _TAMAGENCIA 5
#DEFINE _TAMCONTA   9
#DEFINE _TAMDIGCTA  1

/*/{protheus.doc} MC422TamCp
*******************************************************************************************
Retorna o tamanho dos campos default
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC422TamCp()
Local aTamanhos := {_TAMNOSSNUM,_TAMCARTEIR,_TAMAGENCIA,_TAMCONTA,_TAMDIGCTA}
Return aTamanhos

/*/{protheus.doc} MC237GeBol
*******************************************************************************************
Geração dos Boletos - SAFRA
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC422GeBol(cCarteira,cAgencia,cConta,cDacCC,cNroDoc,dVencimento,nValor,dEmissao,cCorresp)
Local cNossNumero	:= StrZero(Val(cNroDoc)  ,_TAMNOSSNUM)
Local cDVNossNum	:= ""
Local cBarras		:= ""
Local cDVBarras		:= ""
Local cLindigit		:= ""
Local cCpoLivre		:= ""
Local cFatVenc 		:= StrZero(dVencimento - CtoD("07/10/1997"),4)
Local blvalorfinal 	:= StrZero(int(nValor*100),10)
Local cPrCpo 		:= ""
Local cDvPrCpo 		:= ""
Local cSgCpo 		:= ""
Local cDvSgCpo 		:= ""
Local cTrCpo 		:= ""
Local cDvTrCpo 		:= ""
Local cDvGeral 		:= ""
Local cCBSemDig		:= ""

Default dEmissao	:= dVencimento
Default cCorresp	:= ""

If Empty(cCorresp) // Cobrança sem correspondente
	cNossNumero := PadR(cNossNumero ,u_MC422TamCp()[01])
	cCarteira   := PadR(cCarteira   ,u_MC422TamCp()[02])
	cAgencia    := PadR(cAgencia    ,u_MC422TamCp()[03])
	cConta      := PadR(cConta      ,u_MC422TamCp()[04])
	cDacCC      := PadR(cDacCC      ,u_MC422TamCp()[05])

	// "7" = Digito do Banco
	// "2" = Cobraça Registrada (tipo de Cobrança)

	cDVNossNum	:= GetDVNN(cNossNumero)
	cCpoLivre 	:= "7"+cAgencia+cConta+cNossNumero+cDVNossNum+"2"
	cCBSemDig 	:= "422" + "9" + cFatVenc + blvalorfinal + cCpoLivre
	cDVBarras	:=  GetDVNN(cCBSemDig,.T.)
	cBarras 	:= "422" + "9" + cDVBarras + cFatVenc + blvalorfinal + cCpoLivre

	//Digito Verificador do Primeiro Campo
	cPrCpo := "422" + "9" +"7" + SubStr(cAgencia,1,4)
	cDvPrCpo := AllTrim(Str(GetDVCPO(cPrCpo)))

	//Digito Verificador do Segundo Campo
	cSgCpo := SubStr(cAgencia,5,1)+cConta
	cDvSgCpo := AllTrim(Str(GetDVCPO(cSgCpo)))

	//Digito Verificador do Terceiro Campo
	cTrCpo := cNossNumero+cDVNossNum+"2"
	cDvTrCpo := AllTrim(Str(GetDVCPO(cTrCpo)))

	//Digito Verificador Geral
	cDvGeral := cDVBarras

	//Linha Digitavel
	cLindigit := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "   	//primeiro campo
	cLindigit += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "   	//segundo campo
	cLindigit += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "   	//terceiro campo
	cLindigit += " " + cDvGeral              										//dig verificador geral
	cLindigit += "  " + cFatVenc+blvalorfinal  										// fator de vencimento e valor nominal do titulo

ElseIf cCorresp == "237" // Cobrança Direta, correspondente Bradesco
	
ElseIf cCorresp == "341" // Cobrança Direta, correspondente Itau

EndIf

Return({cBarras,cLindigit,cNossNumero,cDVNossNum})

/*/{protheus.doc} GetDVCPO
*******************************************************************************************
Retorna o digito verificador do campo (modulo 10)
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVCPO(cData)
Local L,D,P := 0
Local B     := .F.

L := Len(cData)
B := .T.
D := 0

While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		EndIf
	EndIf
	D := D + P
	L := L - 1
	B := !B
EndDo
D := 10 - (Mod(D,10))
If D = 10
	D := 0
EndIf

Return(D)

/*/{protheus.doc} GetDVNN
*******************************************************************************************
Retorna o digito verificador do codigo de barras e do nosso numero
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVNN( cData, lBarra )
Local cRet 		:= ""
Local nSoma		:= 0
Local nFor		:= 0
Local nResto 	:= 0
Local nMult 	:= 2

Default lBarra := .F.

For nFor:= Len( cData ) To 1 Step -1
	nSoma += Val( Substr(cData,nFor,1) ) * nMult
	nMult+=1
	If nMult == 10
		nMult := 2
	EndIf
Next nFor

nResto := nSoma%11

If !lBarra
	If nResto == 0
		cRet := '1'
	ElseIf nResto == 1
		cRet := '0'
	Else
		cRet := Str(11-nResto,1)
	EndIf
Else
	If nResto == 0 .or. nResto == 10 .or. nResto = 1
		cRet := '1'
	Else
		cRet := Str(11-nResto,1)
	EndIf
EndIf

Return( cRet )
