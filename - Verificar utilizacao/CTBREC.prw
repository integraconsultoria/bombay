#INCLUDE "PROTHEUS.CH"

/*
PROGRAMA CRIADO PARA RETORNAR CONTA CONTÁBIL DE RECEITA NO FATURAMENTO
Autor: HFBR 
Consultor: Garbi, Wellington Roberto
Data: 29/08/2018
*/

User Function CTBREC()

 Local cCnat := POSICIONE('SC5',1,xFILIAL('SC5')+SD2->D2_PEDIDO,'C5_NATUREZ')
 Local cRet  := ""
    
 IF alltrim(cCnat)=="3001001"
     cRet := '3.1.1.01.001'                                          
 ElseIF alltrim(cCnat)=="3001002"
     cRet := '3.1.1.01.002'
 ElseIF alltrim(cCnat)=="3001003"
     cRet := '3.1.1.01.003'
 ElseIF alltrim(cCnat)=="3001004"
     cRet := '3.1.1.01.004'
 ElseIF alltrim(cCnat)=="3001005"   
     cRet := '3.1.1.01.005'
 ElseIF alltrim(cCnat)=="3002001"
     cRet := '3.1.1.03.001'
 ElseIF alltrim(cCnat)=="3002002"
     cRet := '3.1.1.03.002'
 ElseIF alltrim(cCnat)=="3002003"
     cRet := '3.1.1.03.003'        
 EndIf	 
	 
Return(cRet)                                   

                                                               