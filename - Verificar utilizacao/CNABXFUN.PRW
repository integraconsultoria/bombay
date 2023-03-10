#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
/*
?????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????ͻ??
??? Programa    ? SISPAG01 ? Rotina para retornar dados da Agencia e Conta dos Fornecedo- ???
???             ?          ? res para tratamento do SISPAG                                ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Solicitante ? 21.10.08 ?  Redlands                                                    ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Autor       ? 21.10.08 ? Fernando de Almeida Augusto                                  ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Produ??o    ? ??.??.?? ? Ignorado                                                     ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Retorno     ? Nil.                                                                    ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Observa??es ?                                                                         ???
?????????????????????????????????????????????????????????????????????????????????????????͹??
??? Altera??es  ? ??.??.?? - Nome - Descri??o                                             ???
?????????????????????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????????
*/
User Function SISPAG01()
Local cSispag	:= ''
Local cAgenc	:= ''
Local cCc		:= ''
Local cDigcc	:= ''
Local cBanco	:= STRZERO(VAL(SA2->A2_BANCO),3)

Local aAreaAtu	:= GetArea()                               

	//?????????????????????????????????????????????????????????????????????Ŀ
	//? Posicao inicial de gravacao da Ag. e Conta do Fornecedor            ?
	//???????????????????????????????????????????????????????????????????????    

  IF (SA2->A2_BANCO) == "341"
    cAgenc	:= STRZERO(VAL(SA2->A2_AGENCIA),5) // Posicoes : 24/25/26/27/28 +"29-Branco" 
    cCc	:= strzero(val(sa2->a2_numcon),12,0)//12 - 30/31/32/33/34/35/36/37/38/39/40+41+"42-Branco"
    cDigcc  := SUBSTR(SA2->A2_DIGCC,1,1)

	cSispag:= "0"+cAgenc+" "+cCc+" "+cDigcc     		

     Else 
    
    cAgenc	:= STRZERO(VAL(SA2->A2_AGENCIA),5)     
    cCc	:= strzero(val(sa2->a2_numcon),12,0)
    cDigcc := SUBSTR(SA2->A2_DIGCC,1,1)      

   	cSispag:= cAgenc+" "+cCc+" "+cDigcc   
     EndIf      
     		
    
RestArea(aAreaAtu)

Return(cSispag)

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao    ? SISPAG02 ? Autor ? Hoeste Morelandes     ? Data ? 28.06.06 ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ?Arquivo SISPAG                                              ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Sintaxe   ?SISPAG02()                                                  ???
?????????????????????????????????????????????????????????????????????????Ĵ??
??? Uso      ?SIGAFIN                                                     ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
USER FUNCTION SISPAG02()

_aArea    := GetArea()
_cChave   := XFILIAL("SE2")+SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_FORNECE
_cRet     := SE2->E2_SALDO 

dbSelectArea("SE2")
dbSetOrder(1)   
dbSeek(_cChave) 
IF !EOF() .and. SE2->E2_BAIXA == CTOD("  /  /  ")     
   _cRet := (_cRet - SE2->E2_VALOR) 
EndIf   
                                                       
_cRet := StrZero((_cRet * 100),15)

RestArea(_aArea)

Return(_cRet)