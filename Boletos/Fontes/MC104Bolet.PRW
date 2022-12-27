#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

#DEFINE _TAMNOSSNUM 	10
#DEFINE _TAMCARTEIR 	2
#DEFINE _TAMAGENCIA 	4
#DEFINE _TAMCONTA   	8
#DEFINE _TAMDIGCTA  	1
#DEFINE _TAMDIGAGE  	1
#DEFINE _TAMCEDENTE 	9
#DEFINE _TAMEMPRESA 	12
#DEFINE _TAMLOTE 		4
#DEFINE _TAMOPERACAO 	3

/*/{protheus.doc} MC104TamCp
*******************************************************************************************
Retorna o tamanho dos campos default
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC104TamCp()
Local aTamanhos := {_TAMNOSSNUM,_TAMCARTEIR,_TAMAGENCIA,_TAMCONTA,_TAMDIGCTA,_TAMDIGAGE,_TAMCEDENTE,_TAMLOTE,_TAMOPERACAO}
Return aTamanhos

/*/{protheus.doc} MC104GeBol
*******************************************************************************************
Gera��o dos Boletos - CAIXA ECONOMICA FEDERAL
 
@author: Marcelo Celi Marques
@since: 19/06/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC104GeBol(cCarteira,cAgencia,cDacAg,cConta,cDacCC,cNroDoc,cCedente,cLote,cOp,dVencimento,nValor)
Local cBanco		:= "104"
Local cNossNumero	:= ""
Local cDVNossNum	:= ""
Local cNrConvenio	:= ""
Local aCB_RN		:= {"",""}

cNossNumero := PadR(cNroDoc,u_MC104TamCp()[01])
cDVNossNum	:= GetDVNN(cNossNumero)

cCarteira 	:= PadR(cCarteira	,u_MC104TamCp()[02])
cAgencia 	:= PadR(cAgencia	,u_MC104TamCp()[03])
cConta	 	:= PadR(cConta		,u_MC104TamCp()[04])
cDacAg 		:= PadR(cDacAg		,u_MC104TamCp()[06])
cDacCC 		:= PadR(cDacCC		,u_MC104TamCp()[05])
cCedente 	:= PadR(cCedente	,u_MC104TamCp()[07])
cLote 		:= PadR(cLote		,u_MC104TamCp()[08])
cOp 		:= PadR(cOp			,u_MC104TamCp()[09])

// o campo do convenio possui 12 posicoes como o convenio da CEF tem 16 os 4 ultimos foram colocados no lote na tabela SEE (  SEE->(EE_CODEMP+EE_LOTE)  )
cNrConvenio  := PadR(cCedente,u_MC104TamCp()[07])+PadR(cLote,u_MC104TamCp()[08])
aCB_RN		 := CBarCEF(cBanco,"9",dVencimento,nValor,cCarteira,cNossNumero,cAgencia,cOP,cCedente)					
cBarras 	 := aCB_RN[01]
cLindigit 	 := aCB_RN[02]

Return({cBarras,cLindigit,cNossNumero,cDVNossNum,cNrConvenio})

/*/{protheus.doc} GetDVNN
*******************************************************************************************
Retorna o digito verificador do nosso numero
 
@author: Marcelo Celi Marques
@since: 19/06/2020
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

If nResto == 0 .or. nResto = 1
	If lBarra
		cRet := '1'
	Else
		cRet := '0'
	EndIf
Else
	cRet := AllTrim(Str(11-nResto,1))
EndIf

Return( cRet )

/*/{protheus.doc} CBarCEF
*******************************************************************************************
Retorna o codigo de barras e a linha digitavel
 
@author: Marcelo Celi Marques
@since: 19/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CBarCEF(cBanco,cMoeda,dVencto,nValor,cCarteira,cNossso,cAg,cOP,cCodX)
Local cValorFinal 	:= strzero(nValor*100,10)
Local cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
Local nDvcb			:= 0
Local cCB			:= ''
Local cS			:= ''

/*
	Posicao Tamanho Picture Conteudo
01 - 03 	3 		9 		(3) Identificacao do banco
04 - 04 	1 		9 		Codigo da moeda (9 - real)
05 - 05 	1 		9 		Dígito Verificador Geral do Codigo de Barras
06 - 09 	4 		9 		Fator de Vencimento
10 - 19 	10 		9 		(8) V99 Valor do Documento
20 - 44 	25 		9 		(25) Campo Livre
*/

//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS		:= cBanco + cMoeda + cFator +  cValorFinal + left(cNossso,10) + cAg+cOP+cCodX
nDvcb 	:= GetDVCB(Substr(cS,1,43))
cCB   	:= SubStr(cS, 1, 4) + Alltrim(str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//1 Campo - Composto por: codigo banco (posicoes 1 a 3 do codigo de barras)
//codigo da moeda (posicao 4 do codigo de barras),
//as cinco primeiras posicoes do campo livre (posicoes 20 a 24 do codigo de barras)
// e digito verificador deste campo
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS1   := cBanco + cMoeda + SubStr(cCB,20,5)
nDv1  := GetDVCPO(cS1)
cLD1  := SubStr(cS1, 1, 5) + '.' + SubStr(cS1, 6, 4) + AllTrim(Str(nDv1)) + '  '

// 	CAMPO 2:
//2 Campo - Composto pelas posicoes 6 a 15 do campo livre (posicoes 25 a 34 do codigo de barras)
// e digito verificador deste campo
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS2	:= SubStr(cCB,25,10)
nDv2:= GetDVCPO(cS2)
cLD2:= SubStr(cS2, 1, 5) + '.' + SubStr(cS2, 6, 5) + AllTrim(Str(nDv2)) + '  '
//10499.00002 00001.028588 70000.003767 7 51060000010000
// 	CAMPO 3:
// 3 Campo - Composto pelas posicoes 16 a 25 do campo livre (posicoes 35 a 44 do codigo de barras) e digito verificador deste campo
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS3   := SubStr(cCB,35,10)
nDv3  := GetDVCPO(cS3)
cLD3  := SubStr(cS3, 1, 5) + '.' + SubStr(cS3, 6, 5) + AllTrim(Str(nDv3)) + '   '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cLD4  := AllTrim(Str(nDvcb)) + '   '

// 	CAMPO 5:
//Composto pelo "fator de vencimento" (posicoes 6 a 9 do codigo de barras) e pelo valor nominal do documento
//(posicoes 10 a 19 do codigo de barras), com a inclusao de zeros entre eles ate compor as 14 posicoes do
//campo e sem edicao (sem ponto e sem vírgula).
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cLD5  := cFator + cValorFinal

cLD	  := cLD1 + cLD2 + cLD3 + cLD4 + cLD5

Return({cCB,cLD})

/*/{protheus.doc} GetDVCB
*******************************************************************************************
Retorna o digito verificador do codigo de barras (Modulo 11)
 
@author: Marcelo Celi Marques
@since: 19/06/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVCB(cData)
Local L, D, P := 0

L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End

Return(D)

/*/{protheus.doc} GetDVCPO
*******************************************************************************************
Retorna o digito verificador do campo (Modulo 10)
 
@author: Marcelo Celi Marques
@since: 19/06/2020
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
