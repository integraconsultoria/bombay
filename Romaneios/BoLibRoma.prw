#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

/*/{protheus.doc} BoLibRoma
*******************************************************************************************
Liberação de Romaneios
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoLibRoma()
Local cUsrLiber := Alltrim(Upper(GetNewPar("BO_URSLCOT","ADMINISTRADOR")))
Local lLiber    := If( RetCodUsr() $ cUsrLiber .Or. Upper(UsrRetName(RetCodUsr())) $ cUsrLiber,.T.,.F.)
Local cCondicao := ""

If lLiber
    cCondicao := "ZR1->ZR1_FILIAL == '"+xFilial("ZR1")+"' .And.  ZR1->ZR1_FAPROV=='B'"
	
    Private aRotina 	:= MenuDef()
    Private cCadastro 	:="Liberação de Romaneios de Transporte"
    mBrowse( 6, 1,22,75,"ZR1",,,,,,,,,,,,,,,,,,cCondicao)    
Else
    MsgAlert("Usuário sem Permissão de Efetuar Liberações de Romaneios de Frete.")
EndIf

Return

/*/{protheus.doc} MenuDef
*******************************************************************************************
Cotação de Romaneios - Menus
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  		,0,1,0	,.F.},;  
					 {"Visualizar"	, "u_BoRomManut"	,0,2,0	,nil},;  					 
                     {"Liberar"		, "u_BoLiberRom"	,0,4,81	,nil}}

Return(aRotina) 

/*/{protheus.doc} BoLiberRom
*******************************************************************************************
Liberação do Romaneio
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoLiberRom(cAlias,nReg,nOpc)

Begin Transaction        
    If MsgYesNo("Confirma a Liberação do Romaneio de Frete "+ZR1->ZR1_ROMANE+"?")
        RecLock("ZR1",.F.)
          ZR1->ZR1_FAPROV := "L"
        ZR1->(MsUnlock())
        GravaLog()
    EndIf
End Transaction

Return

/*/{protheus.doc} GravaLog
*******************************************************************************************
Função de Gravação de Logs de Operação
 
@author: Marcelo Celi Marques
@since: 10/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GravaLog()
Local cSequencia := ""
Local cObserv    := ""
Local cOperac    := ""

cObserv := "Liberação do Romaneio de Transporte bloqueado por valor de frete excedido."
cOperac := "Liber. Romaneio"

ZR4->(dbSetOrder(1))
If ZR4->(dbSeek(xFilial("ZR4")+ZR1->ZR1_ROMANE))
    Do While ZR4->(!Eof()) .And. ZR4->(ZR4_FILIAL+ZR4_ROMANE) == xFilial("ZR4")+ZR1->ZR1_ROMANE
        cSequencia := ZR4->ZR4_SEQUEN
        ZR4->(dbSkip())
    EndDo
Else
    cSequencia := StrZero(0,Tamsx3("ZR4_SEQUEN")[01])
EndIf
cSequencia := Soma1(cSequencia)

RecLock("ZR4",.T.)
ZR4->ZR4_FILIAL := xFilial("ZR4")
ZR4->ZR4_ROMANE := ZR1->ZR1_ROMANE
ZR4->ZR4_SEQUEN := cSequencia
ZR4->ZR4_EMISSA := Date()
ZR4->ZR4_HORA   := Time()
ZR4->ZR4_PERDE  := ZR1->ZR1_PERDE
ZR4->ZR4_PERATE := ZR1->ZR1_PERATE
ZR4->ZR4_QTDOCS := ZR1->ZR1_QTDOCS
ZR4->ZR4_VLDOCS := ZR1->ZR1_VLDOCS
ZR4->ZR4_COTAC  := ZR1->ZR1_COTAC
ZR4->ZR4_VLFRET := ZR1->ZR1_VLFRET
ZR4->ZR4_CONDIC := ZR1->ZR1_CONDIC
ZR4->ZR4_FATURA := ZR1->ZR1_FATURA
ZR4->ZR4_SERIE  := ZR1->ZR1_SERIE
ZR4->ZR4_MOTOR  := ZR1->ZR1_MOTOR
ZR4->ZR4_LJMOTO := ZR1->ZR1_LJMOTO
ZR4->ZR4_NOME   := ZR1->ZR1_NOME
ZR4->ZR4_USER   := Upper(UsrRetName(RetCodUsr()))
ZR4->ZR4_STATUS := ZR1->ZR1_STATUS
ZR4->ZR4_OBSERV := cObserv
ZR4->ZR4_OPERAC := cOperac
ZR4->(MsUnlock())

Return
