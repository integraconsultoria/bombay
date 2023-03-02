#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

/*/{protheus.doc} BoCotRoma
*******************************************************************************************
Cotação de Romaneios
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCotRoma()
Private aRotina 	:= MenuDef()
Private cCadastro 	:="Cotação de Romaneios de Transporte"
Private nVlrMaxCot  := GetNewPar("BO_VMAXCOT",500)

mBrowse( 6, 1,22,75,"ZR3",,,,,,u_BoCotLegen())

Return

/*/{protheus.doc} BoCotLegen
*******************************************************************************************
Cotação de Romaneios - Legenda
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCotLegen(cAlias,nReg)
Local uRetorno := .T.
Local aLegenda := {	{"BR_AMARELO"	, 	"Bloqueado"		},;
					{"BR_VERDE"		, 	"Liberado"	    },;	 
					{"BR_VERMELHO"	, 	"Finalizado"	}}	   	

If nReg = Nil	
	uRetorno := {}
	Aadd(uRetorno, {'ZR3_STATUS == "1"'		, aLegenda[1][1]})  
	Aadd(uRetorno, {'ZR3_STATUS == "2"'		, aLegenda[2][1]}) 
	Aadd(uRetorno, {'ZR3_STATUS == "3"'		, aLegenda[3][1]}) 
Else
	BrwLegenda(cCadastro,"Legenda",aLegenda) 
Endif

Return uRetorno

/*/{protheus.doc} MenuDef
*******************************************************************************************
Cotação de Romaneios - Menus
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  		,0,1,0	,.F.},;  
					 {"Visualizar"	, "u_BoCotManut"	,0,2,0	,nil},;  
					 {"Incluir"		, "u_BoCotManut"	,0,3,81	,nil},; 
					 {"Alterar"		, "u_BoCotManut"	,0,4,3	,nil},;
					 {"Excluir"		, "u_BoCotManut"	,0,5,81	,nil},;
                     {"Liberar"		, "u_BoCotManut"	,0,6,81	,nil},; 
                     {"Bloquear"	, "u_BoCotManut"	,0,7,81	,nil},;
					 {"Legenda"		, "u_BoCotLegen" 	,0,2, 	,.F.}}

Return(aRotina) 

/*/{protheus.doc} BoCotManut
*******************************************************************************************
Cotação de Romaneios - Menutenção
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoCotManut(cAlias,nReg,nOpc)
Local aButtons  := {}
Local cUsrLiber := Alltrim(Upper(GetNewPar("BO_URSLCOT","ADMINISTRADOR")))
Local lLiber    := If( RetCodUsr() $ cUsrLiber .Or. Upper(UsrRetName(RetCodUsr())) $ cUsrLiber,.T.,.F.)
Local aCpos     := {}

If nOpc == 2
    AxVisual(cAlias,nReg,nOpc,,,,,aButtons,)

ElseIf nOpc == 3
    Begin Transaction        
        AxInclui(cAlias,nReg,nOpc,,"u_BoCotInic",,"u_BoCotTdOk("+Alltrim(Str(nOpc))+")",,"u_BoCotAux('"+cAlias+"',"+Alltrim(Str(nOpc))+")",aButtons)
    End Transaction

ElseIf nOpc == 4
    If ZR3->ZR3_STATUS == "3"
        MsgAlert("Cotação já Finalizada e não pode ser Alterada.")
    Else
        aCpos := FWSX3Util():GetAllFields(cAlias)    
        Begin Transaction
            AxAltera(cAlias,nReg,nOpc,,aCpos,,,"u_BoCotTdOk("+Alltrim(Str(nOpc))+")","u_BoCotAux('"+cAlias+"',"+Alltrim(Str(nOpc))+")",,aButtons)
        End Transaction
    EndIf

ElseIf nOpc == 5
    If ZR3->ZR3_STATUS == "3"
        MsgAlert("Cotação já Finalizada e não pode ser Excluida.")
    Else
        Begin Transaction
            AxDeleta(cAlias,nReg,nOpc,,,aButtons,,,.T.)
        End Transaction
    EndIf

ElseIf nOpc == 6
    If ZR3->ZR3_STATUS == "1"
        If lLiber
            Begin Transaction
                If MsgYesNo("Confirma a Liberação da Cotação de Frete?")
                    RecLock("ZR3",.F.)
                    ZR3->ZR3_STATUS := "2"
                    ZR3->ZR3_LIBER  := Dtoc(Date())+" "+Time()
                    ZR3->ZR3_USRCON := Upper(UsrRetName(RetCodUsr()))
                    ZR3->(MsUnlock())
                EndIf
            End Transaction
        Else
            MsgAlert("Usuario não está apto a Efetuar Liberações de Cotações de Frete.")
        EndIf
    Else
        MsgAlert("Cotação não Encontra-se Bloqueada para Liberação.")
    EndIf

ElseIf nOpc == 7
    If ZR3->ZR3_STATUS == "2"
        If lLiber
            Begin Transaction
                If MsgYesNo("Confirma o Bloqueio da Cotação de Frete?")
                    RecLock("ZR3",.F.)
                    ZR3->ZR3_STATUS := "1"
                    ZR3->ZR3_LIBER  := ""
                    ZR3->ZR3_USRCON := ""
                    ZR3->(MsUnlock())
                EndIf
            End Transaction
        Else
            MsgAlert("Usuario não está apto a Efetuar Bloqueios de Cotações de Frete.")
        EndIf
    Else
        MsgAlert("Cotação não Encontra-se Liberada para Bloqueio.")
    EndIf

EndIf

Return

/*/{protheus.doc} BoCotInic
*******************************************************************************************
Cotação de Romaneios - Inicialização dos Campos de Memória
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCotInic()
Local cNumero := ""

cNumero := GetSXENum("ZR3","ZR3_NUMERO")
ZR3->(dbSetOrder(1))

While ZR3->(dbSeek(xFilial("ZR3")+cNumero))
    ConfirmSX8()
    cNumero := GetSXENum("ZR3","ZR3_NUMERO")
EndDo

M->ZR3_NUMERO := cNumero
M->ZR3_COTAC  := Dtoc(Date())+" "+Time()
M->ZR3_USRCRI := Upper(UsrRetName(RetCodUsr()))

Return .T.

/*/{protheus.doc} BoCotAux
*******************************************************************************************
Cotação de Romaneios - Dados auxiliares da rotina de inclusão
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCotAux(cAlias,nOpc)

If nOpc == 3 .Or. nOpc == 4
    RecLock(cAlias,.F.)
    (cAlias)->ZR3_LIBER  := ""
    (cAlias)->ZR3_USRCON := ""
    
    If (cAlias)->ZR3_VLFRET > nVlrMaxCot
        (cAlias)->ZR3_STATUS := "1"        
    Else
        (cAlias)->ZR3_STATUS := "2"
    EndIf

    (cAlias)->(MsUnlock())
EndIf

Return

/*/{protheus.doc} BoTransVld
*******************************************************************************************
Cotação de Romaneios - Validação da Transportadora - Usado no X3_VALID do ZR3_TRANSP
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoTransVld()
Local lRet      := .F.
Local cCodigo   := &(Readvar())

SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+cCodigo))
    If Empty(SA4->A4_XFORNEC)
        MsgAlert("Transportadora não Possui Fornecedor Vinculado...")
        lRet := .F.
    Else
        SA2->(dbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+SA4->(A4_XFORNEC+A4_XLOJFOR)))
            If SA2->A2_MSBLQL == "1"
                MsgAlert("Fornecedor amarrado a Transportadora Bloqueado...")
                lRet := .F.
            Else
                lRet := .T.
            EndIf
        Else
            MsgAlert("Fornecedor amarrado a Transportadora não Localizado...")
            lRet := .F.
        EndIf        
    EndIf
Else
    MsgAlert("Transportadora não Localizada...")
    lRet := .F.
EndIf

If lRet
    M->ZR3_NOME := SA4->A4_NOME
Else
    M->ZR3_NOME := ""
EndIf

Return lRet

/*/{protheus.doc} BoRomaVld
*******************************************************************************************
Cotação de Romaneios - Validação do Romaneio - Usado no X3_VALID do ZR3_ROMANE
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoRomaVld()
Local lRet      := .T.
Local cRomaneio := &(Readvar())

ZR1->(dbSetOrder(1))
If ZR1->(dbSeek(xFilial("ZR1")+cRomaneio))
    If ZR1->ZR1_STATUS == "1"
        lRet := .T.
    Else
        MsgAlert("Romaneio não Encontra-se em Fase de Elaboração...")
        lRet := .F.
    EndIf
Else
    MsgAlert("Romaneio não Localizado...")
    lRet := .F.
EndIf

Return lRet

/*/{protheus.doc} BoRomaVld
*******************************************************************************************
Cotação de Romaneios - TudoOk
 
@author: Marcelo Celi Marques
@since: 01/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoCotTdOk(nOpc)
Local lRet := .T.

If nOpc == 3
    lRet := MsgYesNo("Confirma a Inclusão da Cotação do Frete ?")

ElseIf nOpc == 4
    lRet := MsgYesNo("Confirma a Alteração da Cotação do Frete ?")

EndIf

Return lRet
