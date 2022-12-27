#include "protheus.ch"
#include "TOPCONN.ch"   

// Modulo : SIGAEST
// Fonte  : BBESTA07
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+-----------------------------------------------------------
// 05/01/18 | RENATO SANTOS       | Rotina para revalidação de Lotes vencidos, para correta 
//          | INTEGRA             | manutenção   
//          |                     | 
// ---------+---------------------+-----------------------------------------------------------
User Function BBESTA07()
Local aArAtu 	:= GetArea()
Local aAreaSB8  := SB8->(GetArea())
Local cStrAj	:= ""

Local nmbkp := BkpSB8()

Private lMsErroAuto := .F.          
Private nModulo 	:= 4


cStrAj := "UPDATE " + RETSQLNAME("SB8") + " SET B8_DTVALID = CONVERT(VARCHAR(8), DATEADD(DD,1,GETDATE()),112) "
cStrAj += "WHERE D_E_L_E_T_ = '' AND B8_SALDO != 0 AND B8_DTVALID < CONVERT(VARCHAR(8), GETDATE(),112) "
TCSQLEXEC(cStrAj)

cStrAj := "UPDATE " + RETSQLNAME("SB2") + " SET B2_CM1 = 0, B2_VATU1 = 0, "
cStrAj += "B2_VFIM1 = CASE WHEN B2_VFIM1 < 0 THEN 0 ELSE B2_VFIM1 END "
cStrAj += "WHERE D_E_L_E_T_ = '' AND B2_QATU <> 0 AND B2_CM1 < 0 "
TCSQLEXEC(cStrAj)

msgalert("Ajuste realizado." + chr(13) + chr(10) + "Backup salvo em " + nmbkp )

RestArea(aAreaSB8)
RestArea(aArAtu)

Return 

//################################################################
//## Rotina que efetua o Backup da SB8, para execucao da rotina ##
//## Evitar problema com Processamento simultaneo com NF        ##
//##------------------------------------------------------------##
//## Renato Santos                                     10/06/21 ##
//################################################################
Static Function BkpSB8()

Local aArSB8 	:= SB8->(GETAREA())
Local cQryBkp 	:= "" 
Local cDtBkp	:= dtos(dDatabase)
Local cTmBkp	:= StrTran(Time(),":","")
Local cNmBkp	:= RetSQLName("SB8") + "_BKP_" + __cUserID + "_" + cDtBkp + "_" + cTmBkp  

cQryBkp += "IF EXISTS(SELECT name FROM sysobjects WHERE name = '" + cNmBkp + "') "
cQryBkp += " DROP TABLE BKP_EMERGENCIAL.dbo." + cNmBkp
TcSQLExec(cQryBkp)

cQryBkp := "SELECT * INTO BKP_EMERGENCIAL.dbo." + cNmBkp + " " 
cQryBkp += "FROM " + RETSQLNAME("SB8") + " SB8 (NOLOCK) "
cQryBkp += "WHERE D_E_L_E_T_ = '' "
TcSQLExec(cQryBkp)

RESTAREA(aArSB8)

Return(cNmBkp)
