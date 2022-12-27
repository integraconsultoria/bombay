#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

#DEFINE _TAMNOSSNUM 11
#DEFINE _TAMCARTEIR 2
#DEFINE _TAMAGENCIA 4
#DEFINE _TAMCONTA   7
#DEFINE _TAMDIGCTA  1

/*/{protheus.doc} MC237TamCp
*******************************************************************************************
Retorna o tamanho dos campos default
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC237TamCp()
Local aTamanhos := {_TAMNOSSNUM,_TAMCARTEIR,_TAMAGENCIA,_TAMCONTA,_TAMDIGCTA}
Return aTamanhos

/*/{protheus.doc} MC237GeBol
*******************************************************************************************
Geração dos Boletos - BRADESCO
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC237GeBol(cCarteira,cAgencia,cConta,cDacCC,cNroDoc,dVencimento,nValor)
Local cCampoLivre 	:= ""                                                                                     
Local cBarras		:= ""
Local cBar01		:= ""
Local cBar02		:= ""
Local cDigCB		:= ""
Local cFator		:= StrZero(dVencimento - ctod("07/10/97"),4)
Local cValor		:= StrZero(nValor * 100,10)
Local cNossNumero	:= StrZero(Val(cNroDoc)  ,_TAMNOSSNUM)
Local cDVNossNum	:= ""
Local cLindigit		:= ""
Local cLin01		:= ""
Local cLin02		:= ""
Local cLin03		:= ""
Local cLin04		:= ""
Local cLin05		:= ""

cCampoLivre := StrZero(Val(cAgencia) ,_TAMAGENCIA)	// 20 a 23 - (Tam 4)	- Agência    Beneficiária(Sem o digito verificador, completar com zeros a esquerda quando necessário)
cCampoLivre += StrZero(Val(cCarteira),_TAMCARTEIR)  // 24 a 25 - (Tam 2)    - Carteira
cCampoLivre += StrZero(Val(cNroDoc)  ,_TAMNOSSNUM)	// 26 a 36 - (Tam 11)   - Número do Nosso Número (Sem o digito verificador)
cCampoLivre += StrZero(Val(cConta)   ,_TAMCONTA)	// 37 a 43 - (Tam 7)    - Conta    do Beneficiário(Sem o digito verificador, completar com zeros a esquerda quando necessário)
cCampoLivre += "0"									// 44 a 44 - (Tam 1)    - Zero
                                                                            
cBar01 := "237"		  								// 01 a 03 - (Tam 3)  	- Identificação  do  Banco 
cBar01 += "9"										// 04 a 04 - (Tam 1)  	- Código da Moeda (Real = 9, Outras=0)
cDigCB := ""            							// 05 a 05 - (Tam 1)  	- Dígito verificador do Código de Barras                   
cBar02 := cFator									// 06 a 09 - (Tam 4)  	- Fator de Vencimento (Vide Nota)
cBar02 += cValor									// 10 a 19 - (Tam 10) 	- Valor
cBar02 += cCampoLivre								// 20 a 44 - (Tam 25) 	- Campo Livre

//->> Calcula digito verificador
cDigCB := GetDVCB(cBar01+cBar02)
cBarras:= cBar01+cDigCB+cBar02

cDVNossNum := GetDVNN(StrZero(Val(cCarteira),_TAMCARTEIR) + StrZero(Val(cNroDoc)  ,_TAMNOSSNUM)) //->> Carteira c(02) + Nosso Numero c(11)
      
// 1º campo
// Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre e o dígito verificador deste campo
cLin01 := "237"
cLin01 += "9"
cLin01 += SubStr(cCampoLivre,1,5)
cLin01 += GetDVLin(cLin01)

// 2º campo
// Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo
cLin02 := SubStr(cCampoLivre,6,10)
cLin02 += GetDVLin(cLin02)

// 3º campo
// Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo
cLin03 := SubStr(cCampoLivre,16,10)
cLin03 += GetDVLin(cLin03)

// 4º campo
// Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de barras
cLin04 := cDigCB

// 5º campo
// Composto  pelo  fator  de  vencimento  com  4(quatro)  caracteres  e  o  valor  do  documento  com  10(dez) caracteres, sem separadores e sem edição. 
cLin05 := cFator
cLin05 += cValor

cLindigit := SubStr(cLin01,1,5)+"."+SubStr(cLin01,6,5)+"  "
cLindigit += SubStr(cLin02,1,5)+"."+SubStr(cLin02,6,6)+"  "
cLindigit += SubStr(cLin03,1,5)+"."+SubStr(cLin03,6,6)+"  "
cLindigit += cLin04+"  "
cLindigit += cLin05

Return({cBarras,cLindigit,cNossNumero,cDVNossNum})

/*/{protheus.doc} GetDVCB
*******************************************************************************************
Calcula o Digito do Codigo de Barras
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVCB(cBarras)
Local cDV 	 		:= ""
Local cRegra 		:= ""
Local cTmp	 		:= ""
Local nX	 		:= 1 
Local nY	 		:= 1
Local nAcumulado    := 0
Local nResto		:= 0

//->> Montagem da regra de multiplicacao - começando por 2 a 9, da esquerda pra direita
For nX:=1 to 10
	For nY:=2 to 9
		cTmp += Alltrim(Str(nY))
    Next nY
Next nX     

For nX:=Len(cTmp) to 1 Step -1
	cRegra += SubStr(cTmp,nX,1)
Next nX
//->> Fim da montagem da regra

cRegra := Right(cRegra,Len(cBarras))                              
For nX:= Len(cBarras) to 1 Step -1
	nAcumulado += (Val(SubStr(cBarras,nX,1)) * Val(SubStr(cRegra,nX,1)))
Next nX

nResto := nAcumulado % 11
If nResto == 0 .Or. nResto == 1 .Or. nResto > 9
	cDV := "1"
Else
	cDV := Alltrim(Str(11 - nResto))
EndIf

Return cDV

/*/{protheus.doc} GetDVNN
*******************************************************************************************
Calcula o Digito do Nosso Numero
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVNN(cNossoNum)
Local cDV := ""
Local cRegra 		:= ""
Local cTmp	 		:= ""
Local nX	 		:= 1 
Local nY	 		:= 1
Local nAcumulado    := 0
Local nResto		:= 0

//->> Montagem da regra de multiplicacao - começando por 2 a 7, da esquerda pra direita
For nX:=1 to 10
	For nY:=2 to 7
		cTmp += Alltrim(Str(nY))
    Next nY
Next nX     

For nX:=Len(cTmp) to 1 Step -1
	cRegra += SubStr(cTmp,nX,1)
Next nX
//->> Fim da montagem da regra

cRegra := Right(cRegra,Len(cNossoNum))                              
For nX:= Len(cNossoNum) to 1 Step -1
	nAcumulado += (Val(SubStr(cNossoNum,nX,1)) * Val(SubStr(cRegra,nX,1)))
Next nX

nResto := nAcumulado % 11
If nResto == 0
	cDV := "0"
ElseIf nResto == 1
	cDV := "P"	
Else
	cDV := Alltrim(Str(11 - nResto))
EndIf

Return cDV
   
/*/{protheus.doc} GetDVLin
*******************************************************************************************
Calcula o Digito do campo da linha digitavel
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDVLin(cCampo)
Local cDV 	 		:= ""
Local cRegra 		:= ""
Local cTmp	 		:= ""
Local nX	 		:= 1 
Local nY	 		:= 1
Local nAcumulado    := 0
Local cValor		:= ""
Local nValor		:= 0

//->> Montagem da regra de multiplicacao - começando por 2 a 1, da esquerda pra direita
For nX:=1 to 10
	For nY:=1 to 2
		cTmp += Alltrim(Str(nY))
    Next nY
Next nX     
//->> Fim da montagem da regra

cRegra := Right(cTmp,Len(cCampo))                              
For nX:= Len(cCampo) to 1 Step -1
	cValor := Alltrim(Str((Val(SubStr(cCampo,nX,1)) * Val(SubStr(cRegra,nX,1)))))
	nValor := 0
	For nY:=1 to Len(cValor)
		nValor += Val(SubStr(cValor,nY,1))
	Next nY
	nAcumulado += nValor
Next nX

If mod(nAcumulado,10) == 0
	cDV := "0"
Else                        
	cDV := Alltrim(Str(10 - mod(nAcumulado,10)))
EndIf	

Return cDV
