#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TBICODE.CH"                                
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"

#DEFINE _TAMNOSSNUM 8
#DEFINE _TAMCARTEIR 3
#DEFINE _TAMAGENCIA 4
#DEFINE _TAMCONTA   5
#DEFINE _TAMDIGCTA  1
   

/*/{protheus.doc} MC341TamCp
*******************************************************************************************
Retorna o tamanho dos campos default
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC341TamCp()
Local aTamanhos := {_TAMNOSSNUM,_TAMCARTEIR,_TAMAGENCIA,_TAMCONTA,_TAMDIGCTA}
Return aTamanhos

/*/{protheus.doc} MC341GeBol
*******************************************************************************************
Propriedades da gera??o de boletos do Banco Itau.
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC341GeBol(cCarteira,cAgencia,cConta,cDvCta,cNossoNumer,dVencimento,nValor,cSeuNumero,cCodCli)
Local dFator      	:= Ctod("07/10/1997")
Local cModNNum		:= ""
Local cBanco		:= "341"
Local cCampo_1		:= ""
Local cCampo_2		:= ""
Local cCampo_3		:= ""
Local cCampo_4		:= ""
Local cCampo_5		:= "" 
Local cBarra_1		:= ""
Local cBarra_2		:= "" 
Local cDacBarr		:= ""
Local cBarra		:= ""
Local cLinha		:= ""
Local cDacNoss		:= ""

cNossoNumer	:= StrZero(Val(Alltrim(cNossoNumer)),_TAMNOSSNUM)
cCarteira   := StrZero(Val(Alltrim(cCarteira))	,_TAMCARTEIR)
cConta 		:= StrZero(Val(SubStr(cConta,1,5))	,_TAMCONTA  )
cAgencia	:= StrZero(Val(SubStr(cAgencia,1,4)),_TAMAGENCIA)   
cDvCta		:= StrZero(Val(Alltrim(cDvCta))		,_TAMDIGCTA )

If cCarteira $ "107|122|142|143|196|198"
	cModNNum := "12121212121212121212121212121212121212121212121212121212121212121212"
	cDacNoss := GetDacNNum(cCarteira+cNossoNumer+cSeuNumero+cCodCli,cModNNum)
	
	cBarra_1 := cBanco															// C?digo do Banco
	cBarra_1 += "9"																// C?digo da Moeda
	
	cBarra_2 := Str((dVencimento - dFator),4)									// Fator de Vencimento
	cBarra_2 += StrZero(Round(nValor * 100,0),10)								// Valor do T?tulo
	cBarra_2 += cCarteira + cNossoNumer + cDacNoss								// Carteira / Nosso N?mero/DAC
	cBarra_2 += cAgencia + cConta + cDvCta										// Ag?ncia / Conta Corrente/DAC
	cBarra_2 += "000"															// Posi??es Livres (zeros)
	
	cDacBarr := GetDacBarr(cBarra_1 + cBarra_2)
	cBarra	 := cBarra_1 + cDacBarr + cBarra_2
	
	cCampo_1 := cBanco															// C?digo do Banco na C?mara de Compensa??o ?341?
	cCampo_1 += "9"																// C?digo da moeda "9"
	cCampo_1 += cCarteira			 											// C?digo da carteira de cobran?a
	cCampo_1 += SubStr(cNossoNumer,1,2)											// Os 2 primeiros d?gitos do Nosso N?mero
	cCampo_1 += GetDac(1,cCampo_1)      										// DAC que amarra o campo 1 
	
	cCampo_2 := SubStr(cNossoNumer,3,6)											// O restante do Nosso N?mero (sem o DAC)
	cCampo_2 += SubStr(cSeuNumero,1,4)  										// Os 4 primeiros n?meros do campo Seu N?mero (N.? Doc.)
	cCampo_2 += GetDac(2,cCampo_2)												// DAC que amarra o campo 2
	
	cCampo_3 := SubStr(cSeuNumero,5,3)											// 3 ?ltimos d?gitos do campo Seu N?mero (N.?Doc.)
	cCampo_3 += SubStr(cCodCli,1,5)												// C?digo do Cliente (fornecido pelo Banco)
	
	cCampo_3 += cDacNoss														// DAC (Carteira/Nosso N?mero (sem o DAC) / Seu N?mero (sem o DAC) / C?digo do Cliente)
	cCampo_3 += "0"																// Zero
	cCampo_3 += GetDac(3,cCampo_3)												// DAC que amarra o campo 3
                                                                                               
	cCampo_4 += cDacBarr														// DAC do C?digo de Barras
	
	cCampo_5 := Str((dVencimento - dFator),4)						 			// Fator de vencimento
	cCampo_5 += StrZero(Round(nValor * 100,0),10)			 					// Valor do T?tulo 
	
	cLinha := SubStr(cCampo_1,1,5)+"."+SubStr(cCampo_1,6,5) + "  "
	clinha += SubStr(cCampo_2,1,5)+"."+SubStr(cCampo_2,6,6) + "  "
	clinha += SubStr(cCampo_3,1,5)+"."+SubStr(cCampo_3,6,6) + "  "
	cLinha += cCampo_4										+ "  "
	cLinha += cCampo_5	

Else
	//->> Tipo IPTE	
	If cCarteira $ "126|131|146|150|168|112"
		cModNNum := "12121212121"
		cDacNoss := GetDacNNum(cCarteira+cNossoNumer,cModNNum)					// DAC do campo [Ag?ncia/Conta/Carteira/ Nosso N?mero]
	Else
		cModNNum := "12121212121212121212"
		cDacNoss := GetDacNNum(cAgencia+cConta+cCarteira+cNossoNumer,cModNNum)	// DAC do campo [Ag?ncia/Conta/Carteira/ Nosso N?mero]
	EndIf	
	
	cBarra_1 := cBanco															// C?digo do Banco
	cBarra_1 += "9"																// C?digo da Moeda
	
	cBarra_2 := Str((dVencimento - dFator),4)									// Fator de Vencimento
	cBarra_2 += StrZero(Round(nValor * 100,0),10)								// Valor do T?tulo
	cBarra_2 += cCarteira + cNossoNumer + cDacNoss								// Carteira / Nosso N?mero/DAC
	cBarra_2 += cAgencia + cConta + cDvCta										// Ag?ncia / Conta Corrente/DAC
	cBarra_2 += "000"															// Posi??es Livres (zeros)
	
	cDacBarr := GetDacBarr(cBarra_1 + cBarra_2)
	cBarra	 := cBarra_1 + cDacBarr + cBarra_2
		
	cCampo_1 := cBanco															// C?digo do Banco na C?mara de Compensa??o ?341?
	cCampo_1 += "9"																// C?digo da moeda "9"
	cCampo_1 += cCarteira			 											// C?digo da carteira de cobran?a
	cCampo_1 += SubStr(cNossoNumer,1,2)											// Os 2 primeiros d?gitos do Nosso N?mero
	cCampo_1 += GetDac(1,cCampo_1) 	     										// DAC que amarra o campo 1 

	cCampo_2 := SubStr(cNossoNumer,3,6)											// O restante do Nosso N?mero (sem o DAC)	
	cCampo_2 += cDacNoss														// DAC do campo [Ag?ncia/Conta/Carteira/ Nosso N?mero]
	cCampo_2 += SubStr(cAgencia,1,3)								   			// Tr?s primeiros n?meros que identificam a Ag?ncia
	cCampo_2 += GetDac(2,cCampo_2)   		   							   			// DAC que amarra o campo 1 
	
	cCampo_3 := SubStr(cAgencia,4,1)								   			// Restante do n?mero que identifica a ag?ncia
	cCampo_3 += SubStr(cConta,1,5) + cDvCta							  			// N?mero da conta corrente + DAC
	cCampo_3 += "000"												 			// Zeros ( N?o utilizado )
	cCampo_3 += GetDac(3,cCampo_3) 	    							 			// DAC que amarra o campo 3
	        
	cCampo_4 := cDacBarr											 			// DAC do C?digo de Barras
	                                                                 	
	cCampo_5 := Str((dVencimento - dFator),4)						 			// Fator de vencimento
	cCampo_5 += StrZero(Round(nValor * 100,0),10)					 			// Valor do T?tulo 
	
	cLinha := SubStr(cCampo_1,1,5)+"."+SubStr(cCampo_1,6,5) + "  "
	clinha += SubStr(cCampo_2,1,5)+"."+SubStr(cCampo_2,6,6) + "  "
	clinha += SubStr(cCampo_3,1,5)+"."+SubStr(cCampo_3,6,6) + "  "
	cLinha += cCampo_4										+ "  "
	cLinha += cCampo_5	
	
EndIf
	
Return {cBarra,cLinha,cNossoNumer,cDacNoss}

/*/{protheus.doc} GetDac
*******************************************************************************************
Calculo Digito Verificador DAC
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetDac(nTipo,cCampo)
Local cDac 	:= ""
Local nVal 	:= 0
Local nSoma := 0
Local nX	:= 1
Local nY	:= 1

If nTipo == 1
	cModulo := "212121212"
ElseIf nTipo == 2
	cModulo := "1212121212"
Else
	cModulo := "1212121212"
EndIf

For nX:=1 to Len(cCampo)
	nVal := Val(SubStr(cCampo,nX,1)) * Val(SubStr(cModulo,nX,1))
	If nVal > 9
		nVal := Alltrim(Str(nVal))
		For nY:=1 to Len(nVal)
			nSoma += Val(SubStr(nVal,nY,1))
		Next nY	
	Else
		nSoma += nVal
	EndIf                                
Next nX  

If nSoma > 0
	nSoma := 10 - (nSoma % 10)
EndIf

If nSoma >= 10
	cDac := "0"
Else
	cDac := Str(nSoma,1)
EndIf

Return cDac
                
/*/{protheus.doc} GetDacNNum
*******************************************************************************************
RETORNO DO DIGITO VERIFICADOR DO NOSSO NUMERO

Para a grande maioria das carteiras, s?o considerados para a obten??o do DAC, os dados
"AG?NCIA / CONTA(sem DAC) / CARTEIRA / NOSSO N?MERO", calculado pelo crit?rio do M?dulo 10.

?  exce??o,  est?o  as  carteiras  126 - 131 - 146 - 150  e  168  cuja  obten??o  est?  
baseada apenas  nos  dados "CARTEIRA/NOSSO N?MERO" da opera??o.

1 ?Exemplo: AG / CONTA = 0057 / 12345-7CART / Nosso N?mero = 110 / 12345678-? 
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetDacNNum(cCampo,cModulo)
Local cDac 	:= ""
Local nVal 	:= 0
Local nSoma := 0
Local nX	:= 1
Local nY	:= 1

For nX:=1 to Len(cCampo)
	nVal := Val(SubStr(cCampo,nX,1)) * Val(SubStr(cModulo,nX,1))
	If nVal > 9
		nVal := Alltrim(Str(nVal))
		For nY:=1 to Len(nVal)
			nSoma += Val(SubStr(nVal,nY,1))
		Next nY	
	Else
		nSoma += nVal
	EndIf                                
Next nX

If nSoma > 0
	nSoma := 10 - (nSoma % 10)
EndIf

If nSoma >= 10
	cDac := "0"
Else
	cDac := Str(nSoma,1)
EndIf

Return cDac
   
/*/{protheus.doc} GetDacBarr
*******************************************************************************************
RETORNA O DIGITO VERIFICADOR DO CODIGO DE BARRAS
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/                          
Static Function GetDacBarr(cBarras)
Local cDac 		:= ""
Local cModulo 	:= "4329876543298765432987654329876543298765432"
Local nX 		:= 1
Local nVal		:= 0
Local nResto	:= 0
                
For nX:=1 to Len(cBarras)
	nVal += ( Val(SubStr(cBarras,nX,1)) * Val(SubStr(cModulo,nX,1)) )
Next nX

nResto 	:= nVal % 11
cDac	:= 11 - nResto

If cDac <= 1 .Or. cDac >= 10
	cDac := "1"
Else
	cDac := Alltrim(Str(cDac))
EndIf

Return cDac
