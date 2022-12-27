#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

#DEFINE _TAMNOSSNUM 12
#DEFINE _TAMCARTEIR 3
#DEFINE _TAMAGENCIA 4
#DEFINE _TAMCONTA   8
#DEFINE _TAMDIGCTA  1
#DEFINE _TAMEMPRES  7

/*/{protheus.doc} MC033TamCp
*******************************************************************************************
Retorna o tamanho dos campos default
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC033TamCp()
Local aTamanhos := {_TAMNOSSNUM,_TAMCARTEIR,_TAMAGENCIA,_TAMCONTA,_TAMDIGCTA,_TAMEMPRES}
Return aTamanhos

/*/{protheus.doc} MC033GeBol
*******************************************************************************************
Geração dos Boletos - SANTANDER
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MC033GeBol(cCarteira,cAgencia,cConta,cDacCC,cNroDoc,dVencimento,nValor,cCedente)
Local cBanco        := "033"
Local cNossNumero	:= StrZero(Val(cNroDoc)  ,_TAMNOSSNUM)
Local cDVNossNum	:= ""
Local cBarras		:= ""
Local cLindigit		:= ""
Local aCB_RN        := {"",""}

cCarteira   := PadR(cCarteira   ,u_MC033TamCp()[02])
cAgencia    := PadR(cAgencia    ,u_MC033TamCp()[03])
cConta      := PadR(cConta      ,u_MC033TamCp()[04])
cDacCC      := PadR(cDacCC      ,u_MC033TamCp()[05])
cCedente    := PadR(cCedente     ,u_MC033TamCp()[06])

cDVNossNum	:= GetDVNN(cNossNumero)
cAgCed		:= Alltrim(cAgencia)+"/"+Alltrim(cCedente)
aCB_RN      := RetBarSant(cBanco,nValor,dVencimento,cNossNumero+cDVNossNum,'9',cCedente,cCarteira)

cBarras 	:= aCB_RN[01]
cLindigit	:= aCB_RN[02]

Return({cBarras,cLindigit,cNossNumero,cDVNossNum})

/*/{protheus.doc} GetDVNN
*******************************************************************************************
Retorna o digito verificador do nosso numero e do codigo de barras
 
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

nSoma		:= nSoma*10
nResto	:= nSoma%11

If nResto == 10 .or. nResto == 0 .or. nResto == 1 .or. nResto == 11
    cRet := "1"
Else
    cRet := AllTrim(Str(nResto,1))
EndIf

Return( cRet )

/*/{protheus.doc} RetBarSant
*******************************************************************************************
Retorna o codigo de barras e a linha digitavel
 
@author: Marcelo Celi Marques
@since: 07/04/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function RetBarSant(cBanco, nValor, dVencimento, cNossoNum, cMoeda, cCodCedente, cCarteira)

//Calculos dos demais valores
Local cFatVenc	:= StrZero(dVencimento - CtoD("07/10/1997"),4)
Local cValTit	:= StrZero(nValor*100,10,0)
Local cCampo1	:= ""
Local cCampo2	:= ""
Local cCampo3	:= SubStr(cNossoNum,8,6)
Local cIOS		:= "0"
Local cCampo5	:= cFatVenc+cValTit
Local cCodBarra	:= ""
Local cDigCdBar	:= ""
Local cLinDig	:= ""

/*
Posicao Tamanho Picture 	Conteudo
01-03 		3 	9 (03) 		Identificacao do Banco = 033
04-04 		1 	9 (01) 		Codigo da moeda = 9 (real)
05-05  		1 	9 (01) 		DV do codigo de barras (calculo abaixo)
06-09 		4 	9 (04) 		Fator de vencimento
10-19 		10 	9 (08)V99 	Valor nominal
20-20 		1 	9 (01) 		Fixo â€œ9â€?
21-27 		7 	9 (07) 		Codigo do cedente padrao Santander Banespa
28-40 		13 	9 (13) 		Nosso Numero
41-41 		1 	9 (01) 		IOS â€“ Seguradoras (Se 7% informar 7. Limitado a 9%) Demais clientes usar 0 (zero)
42-44 		3 	9 (03) 		Tipo de Modalidade Carteira
                101-Cobranca Simples Rapida COM Registro
                102- Cobranca simples â€“ SEM Registro
                201- Penhor Rapida com Registro
*/

//Calculo do codigo de barras
cCodBarra	:= cBanco+cMoeda+cFatVenc+cValTit+cMoeda+SubStr(cCodCedente,1,7)+cNossoNum+cIOS+cCarteira
cDigCdBar	:= GetDVNN(cCodBarra, .T. )
cCodBarra 	:= SubStr(cCodBarra,1,4)+cDigCdBar+SubStr(cCodBarra,5)

//Montando a linha digitavel
cCampo1		:= cBanco+cMoeda+'9'+SubStr(cCodCedente,1,4)

cCampo2		:= SubStr(cCodCedente,5,3)+SubStr(cNossoNum,1,7)

cCampo3 	:= SubStr(StrTran(cNossoNum,"-",""),8,6)+cIOS+SubStr(cCarteira,1,3)

cLinDig		:= Transform(cCampo1+Str(GetDVCPO(cCampo1),1),'@R 99999.99999')		+	Space(2)
cLinDig		+= Transform(cCampo2+Str(GetDVCPO(cCampo2),1),'@R 99999.999999')	+	Space(2)
cLinDig		+= Transform(cCampo3+Str(GetDVCPO(cCampo3),1),'@R 99999.999999')	+	Space(3) 

cLinDig		+= cDigCdBar + Space(2)
cLinDig		+= cCampo5

Return({cCodBarra,cLinDig,cNossoNum})

/*/{protheus.doc} GetDVCPO
*******************************************************************************************
Retorna o digito verificador do campo
 
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
