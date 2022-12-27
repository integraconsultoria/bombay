#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"



/*/{Protheus.doc}

Converte Linha digitável em Código de Barras 

@author        
@since 
@version
@param cStr, numerico, número do código de barras      
@return linha digitável convertido em código de barras    

// Criar gatilho na E2_LINDIG contra E2_CODBAR com u_LDXCBAR(M->E2_LINDIG)
/*/


User Function LDXCBAR(cStr)
	Local cStr

	IF VALTYPE(cStr) == NIL .OR. EMPTY(cStr) .OR. !VldCodBar(cStr)
		cStr := ""
	ELSE
		cStr := alltrim(cStr)
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF

	if len(cStr) == 47
		//				1-4/4			  5-19/15             20-24/5          25-34/10            35-44/10
		cStr := Substr(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
	elseif len(cStr) == 48
		//				
		cStr := Substr(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
	else
		cStr := cStr+SPACE(48-LEN(cStr))
	endif
	
	if !VldCodBar(cStr)
		cStr := ""
	endif
	
	IF TYPE("E2_CBAR2")<>'U'
		M->E2_CBAR2 := cStr
	endif
	
return cStr



/*/{Protheus.doc}

Converte Código de Barras em Linha digitável 

@author 
@since 
@version 
@param cStr, numerico, número do código de barras      
@return código de barras convertido em linha digitável     
/*/


User function CBARXLD(cCod)

	Local cStr := cCod

	if valtype(cStr) == nil .OR. empty(cStr) .OR. !LEN(cStr)=44 .OR. !VldCodBar(cStr)
		return ""
	endif
	
	if alltrim(modulo10(substr(cCod,1,3)+substr(cCod,5))) == substr(cCod,4,1)
		cStr := Substr(cStr,1,11)+Modulo10(Substr(cStr,1,11))+Substr(cStr,12,11)+Modulo10(Substr(cStr,12,11))+Substr(cStr,23,11)+Modulo10(Substr(cStr,23,11))+Substr(cStr,34,11)+Modulo10(Substr(cStr,34,11))
	else
		cStr := Substr(cStr,1,4)+Substr(cStr,20,5)+Modulo10(Substr(cStr,1,4)+Substr(cStr,20,5),2)+Substr(cStr,25,10)+Modulo10(Substr(cStr,25,10),1)+Substr(cStr,35,10)+Modulo10(Substr(cStr,35,10),1)+Substr(cStr,5,1)+Substr(cStr,6,14)
	endif
			
	if !VldCodBar(cStr)
		cStr := ""
	endif
	
	IF TYPE("E2_CODBAR")<>'U'
		M->E2_CODBAR := cStr
	endif
	
return cStr

