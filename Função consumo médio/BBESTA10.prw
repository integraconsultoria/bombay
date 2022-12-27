#Include "PROTHEUS.CH"

/*
#############################################################################
##=========================================================================##
## Programa  |BBESTA10  | Autor  |Renato Santos       | Data |  08/12/21   ##
##=========================================================================##
## Desc.     |Rotina que monta busca os valores de meses anteriores, e     ##
##           |calcula a média dividida por 2                               ##
##=========================================================================##
## Parametros                                                              ##
##-------------------------------------------------------------------------##
## cPrdAtu   | Codigo do Produto pesquisado                                ##
## nPerMed   | Periodo, em meses, que deverá buscar valores para media     ##
## nFatDiv   | Fator numerico a dividir o resultado obtido (Num. Inteiro)  ##
##           | Exemplo: Para considerar metade do resultado, use 2         ##
## dDtIni    | Data a ser tratada como inicial, para retroceder            ##
##=========================================================================##
## Data      | Alteracao                                      | Autor      ##
##=========================================================================##
##           |                                                |            ##
##=========================================================================##
#############################################################################
*/
USER FUNCTION BBESTA10(cPrdAtu, nFatDiv, nPerMed, dDtIni)
Local aArSB3 := SB3->(GetArea())
Local nMedret := 0
Local nXF := 0

dDtIni := iif(dDtIni == Nil, dDataBase, dDtIni)
nPerMed := iif(nPerMed == Nil, 2, nPerMed) // alterado de 3 para 2 a pedido da Gabriela - Flávio Monachesi 29/03/2022
nFatDiv := iif(nFatDiv == Nil, 2, nFatDiv)

dbSelectArea("SB3")
SB3->(dbSetOrder(1))
if SB3->(dbSeek( SB3->(xFilial()) + cPrdAtu ))
    For nXF := 1 to nPerMed
        nMedret += &("SB3->B3_Q" + StrZero(Month(MonthSub(dDtIni, nXF)),2))
    Next
    nMedret := ((nMedRet / nPerMed)/2)
Endif

RestArea(aArSB3)
RETURN(nMedret)
