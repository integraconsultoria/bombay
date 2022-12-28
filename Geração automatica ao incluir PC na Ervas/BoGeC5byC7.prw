#INCLUDE "TOTVS.CH"
#INCLUDE "ApWizard.ch"
#include 'rwmake.ch'
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{protheus.doc} BoGeC5byC7
*******************************************************************************************
Funcao para a replicação de pedidos
 
@author: Marcelo Celi Marques
@since: 13/07/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoGeC5byC7(cFilPed,cNumPed)
Local aArea     := {}
Local aAreaSC5  := {}
Local aAreaSC6  := {}
Local aAreaSC7  := {}
Local aAreaSA1  := {}
Local aAreaSA2  := {}
Local aAreaSM0  := {}
Local _cFilAnt  := ""

If Left(cFilPed,2) == "02"
    aArea     := GetArea()
    aAreaSC5  := SC5->(GetArea())
    aAreaSC6  := SC6->(GetArea())
    aAreaSC7  := SC7->(GetArea())
    aAreaSA1  := SA1->(GetArea())
    aAreaSA2  := SA2->(GetArea())
    aAreaSM0  := SM0->(GetArea())
    _cFilAnt  := cFilAnt
    
    cFilAnt := cFilPed
    SC7->(dbSetOrder(1))
    SA2->(dbSetOrder(1))
    If SC7->(dbSeek(xFilial("SC7")+cNumPed)) .And. SA2->(dbSeek(xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA)))
        If GetFornece(SA2->A2_CGC)        
            MsgRun("Gerando pedido de vendas na Industria...",,{ || BoGeC5byC7() })
        EndIf
    EndIf

    SM0->(RestArea(aAreaSM0))
    SA2->(RestArea(aAreaSA2))
    SA1->(RestArea(aAreaSA1))
    SC7->(RestArea(aAreaSC7))
    SC6->(RestArea(aAreaSC6))
    SC5->(RestArea(aAreaSC5))
    RestArea(aArea)

    cFilAnt  := _cFilAnt

    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))
EndIf

Return

/*/{protheus.doc} BoGeC5byC7
*******************************************************************************************
Funcao para a replicação de pedidos
 
@author: Marcelo Celi Marques
@since: 13/07/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function BoGeC5byC7()
Local cCliente  := ""
Local cLojaCli  := ""
Local nX        := 1
Local aProdutos := {}
Local aCabec    := {}
Local aItem     := {}
Local aSC5      := {}
Local aSC6      := {}
Local cPedVen   := ""
Local cCond     := Alltrim(Upper(GetNewPar("BO_CONDREP","001")))
Local cTesSaida := ""
Local cOper     := "01"
Local cItem     := ""
Local cFilPV    := "0101"
Local lContinua := .T.
Local nVlr2Unid := 0
Local nVlrUnit  := 0
Local nVlrTota  := 0
Local cChave    := SC7->(C7_FILIAL+C7_NUM)

//->> Marcelo Celi - 05/12/2022
Local lExecByJob:= Alltrim(Upper(GetNewPar("BO_C7C5JOB","S")))=="S"
Local aRet      := {.F.,""}

Private lMsErroAuto := .F.

//->> Declaração de publicas que serao utilizadas na rotina
Public p__cUM  := ""
Public p__lUM  := .F.

Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == cChave
    aAdd(aProdutos,{SC7->C7_ITEM,                          ; // 01 - ITEM DO PEDIDO DE VENDAS ORIGINAL
                    SC7->C7_PRODUTO,                       ; // 02 - CODIGO DO PRODUTO
                    SC7->C7_LOCAL,                         ; // 03 - ARMAZEM
                    SC7->C7_QUANT,                         ; // 04 - QUANTIDADE VENDIDA
                    SC7->C7_PRECO}                         ) // 05 - VALOR DE CUSTO
    SC7->(dbSkip())
EndDo

GetCliente(cFilAnt,@cCliente,@cLojaCli)
If !Empty(cCliente) .And. !Empty(cLojaCli)
    //**************************************> PEDIDO DE VENDAS <******************
    cFilAnt := cFilPV
    //->> Verifica o tipo de saida e condição de pagamento        
    SE4->(dbSetOrder(1))
    If SE4->(dbSeek(xFilial("SE4")+cCond)) .And. SE4->E4_MSBLQL <> '1'        
        //->> Posiciona no Cliente
        SA1->(dbSetOrder(1))
        SA1->(dbSeek(xFilial("SA1")+cCliente+cLojaCli))
        //->> Cria numeração do Pedido de Vendas
        cPedVen := GetSXENum("SC6","C6_NUM")
        SC6->(dbSetOrder(1))
        While SC6->(dbSeek(xFilial("SC6")+cPedVen))
            ConfirmSX8()
            cPedVen := GetSXENum("SC6","C6_NUM")
        EndDo
        //->> Montagem do cabeçalho do pedido de vendas
        aCabec   := {}            
        aAdd(aCabec, {"C5_NUM",     cPedVen,        Nil})
        aAdd(aCabec, {"C5_TIPO",    "N",            Nil})
        aAdd(aCabec, {"C5_CLIENTE", SA1->A1_COD,    Nil})
        aAdd(aCabec, {"C5_LOJACLI", SA1->A1_LOJA,   Nil})
        aAdd(aCabec, {"C5_LOJAENT", SA1->A1_LOJA,   Nil})
        aAdd(aCabec, {"C5_CONDPAG", SE4->E4_CODIGO, Nil})
        aAdd(aCabec, {"C5_XORIGPV", cChave        , Nil})

        aSC5 := aClone(aCabec)
        //->> Montagem dos itens do pedido de vendas
        SB1->(dbSetOrder(1))
        For nX:=1 to Len(aProdutos)    
            SB1->(dbSeek(xFilial("SB1")+aProdutos[nX,02]))

            //->> Marcelo Celi - 19/07/2021
            If SB1->B1_MSBLQL == "1"
                Reclock("SB1",.F.)
                SB1->B1_MSBLQL := "2"
                SB1->(MsUnlock())
            EndIf

            aItem	  := {}    
            cItem     := StrZero(nX,Tamsx3("C6_ITEM")[01])
            nVlrUnit  := aProdutos[nX,05]
            nVlr2Unid := Round(nVlrUnit,Tamsx3("C6_PRUNIT")[2])
            If SB1->B1_TIPCONV == "D"
                nVlr2Unid := Round(nVlr2Unid / SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
            Else
                nVlr2Unid := Round(nVlr2Unid * SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
            EndIf
            nVlrTota := Round(nVlrUnit * aProdutos[nX,04],Tamsx3("C6_VALOR")[02])

            //->> Resgatar o TES pelo tes inteligente
            cTesSaida := MaTESInt(2,cOper,cCliente,cLojaCli,"N",SB1->B1_COD)  
            If Empty(cTesSaida)
                cTesSaida := SB1->B1_TS
            EndIf
            If Empty(cTesSaida)
                cTesSaida := "505"
            EndIf

            SF4->(dbSetOrder(1))
            If SF4->(dbSeek(xFilial("SF4")+cTesSaida)) .And. SF4->F4_MSBLQL <> '1' .And. SF4->F4_TIPO == "S"
                aAdd(aItem,{"C6_ITEM"	    ,cItem			    	,Nil} )
                aAdd(aItem,{"C6_PRODUTO"	,SB1->B1_COD	    	,Nil} )
                aAdd(aItem,{"C6_QTDVEN"		,aProdutos[nX,04]  		,Nil} )                    
                aAdd(aItem,{"C6_PRCVEN"		,nVlrUnit               ,Nil} )
                aAdd(aItem,{"C6_PRUNIT"		,nVlrUnit               ,Nil} )                                
                aAdd(aItem,{"C6_VALOR"		,nVlrTota 	            ,Nil} )            
                aAdd(aItem,{"C6_DESCRI"     ,SB1->B1_DESC 			,Nil} )
                aAdd(aItem,{"C6_ENTREG"     ,dDatabase  			,Nil} )
                aAdd(aItem,{"C6_UM"         ,SB1->B1_UM				,Nil} )                    
                aAdd(aItem,{"C6_LOCAL"      ,SB1->B1_LOCPAD			,Nil} )                    
                aAdd(aItem,{"C6_SEGUM"      ,SB1->B1_SEGUM	        ,Nil} )                    
                aAdd(aItem,{"C6_UNSVEN"     ,nVlr2Unid  	        ,Nil} )

               // If !Empty(cTesSaida)
               //     aAdd(aItem,{"C6_TES"	,cTesSaida  	        ,Nil} )
               // Else
                    aAdd(aItem,{"C6_OPER"	,"01"       	        ,Nil} )
               // EndIf

            Else
                MsgAlert("TES "+cTesSaida+" não localizada, ou não é de saida ou bloqueada..."+CRLF+"Favor verificar o produto: "+Alltrim(SB1->B1_COD)+" e as suas regras fiscais.")
                aSC5 := {}
                aSC6 := {}
                Exit
            EndIf

            aAdd(aSC6,aItem)
        Next nX
    Else
        MsgAlert("Condição de Pagamento "+cCond+" não localizada ou bloqueada... ")
    EndIf
Else
    MsgAlert("A Empresa de produção não foi localizada como cliente."+CRLF+"Pedido de Vendas não foi gerado na "+cFilPV)
EndIf

If Len(aSC5)>0 .And. Len(aSC6)>0
    Begin Transaction
        //->> Geração do Pedido de Vendas
        If lContinua
            cFilAnt := cFilPV            
            If lExecByJob
                aRet := StartJob("U_BoExM410Jb",GetEnvServer(),.T.,{cEmpAnt,cFilAnt,aSC5,aSC6,.T.})
            Else
                aRet := U_BoExM410Jb({cEmpAnt,cFilAnt,aSC5,aSC6,.F.})
            EndIf
            If Valtype(aRet)=="A"                
                If !aRet[1]
                    lContinua := .F.
                    If lExecByJob
                        If MsgYesNo("Ocorreram erros na geração do pedido de vendas da replicação da filial."+CRLF+"Deseja visualizar o erro ?")
                            MsgAlert(aRet[2])
                        EndIf
                    EndIf
                Else
                    lContinua := .T.
                    MsgAlert("Pedido de Vendas "+aRet[3]+" gerado com sucesso na filial "+cFilPV+".")
                EndIf
            Else
                lContinua := .F.
                MsgAlert("Erros ocorreram na geração do pedido de vendas na filial "+cFilPV+".")
            EndIf            
        EndIf

        //->> Desarmar a transação se ocorreram erros
        If !lContinua
            DisarmTransaction()
        EndIf

    End Transaction
EndIf

Return

/*/{protheus.doc} BoExM410Jb
*******************************************************************************************
Execução do Mata140 em outra thread
 
@author: Marcelo Celi Marques
@since: 05/12/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoExM410Jb(aDados)
Local aRet    := {.F.,"",""}
Local cEmp    := aDados[01]
Local cFil    := aDados[02]
Local aCab    := aDados[03]
Local aItens  := aDados[04]
Local lJob    := aDados[05]  
Local aTables := {}
Local cNumPed := ""
Local nY      := 1  
Local aLog    := {}
Local cErro   := ""
Local lRet    := .F.
Local cLog    := ""  

Private lMSErroAuto     := .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile 	:= .T. 

//->> Declaração de publicas que serao utilizadas na rotina
Public p__cUM  := ""
Public p__lUM  := .F.

If lJob
    aAdd( aTables, "SC5" )
    aAdd( aTables, "SC6" )
    aAdd( aTables, "SB1" )
    aAdd( aTables, "SA1" )
    aAdd( aTables, "SF4" )

    RPCClearEnv()
    RPCSetType(3)
    RPCSetEnv( cEmp, cFil,,,,, aTables )
Else
    cFilAnt := cFil
EndIf

SC5->(dbSetOrder(1))
cNumPed:=GetSXENum("SC5","C5_NUM")
Do While SC5->(dbSeek(xFilial("SC5")+cNumPed))
    ConfirmSX8()
    cNumPed:=GetSXENum("SC5","C5_NUM")
EndDo
cNumPed := ""

//->> Dar rollback na numeração automatica, do ultimo numero gerado, para considerar o do inicializador padrão da sc5.
RollBackSx8()

MSExecAuto({|a,b,c,d| Mata410(a,b,c,d)},aCab,aItens,3,.F.)

If lMsErroAuto    
    cErro := "Erro na chamado do MATA410 - Gerando C5 BY C7: "
    aLog  := GetAutoGRLog()
    For nY := 1 To Len(aLog)
        If !Empty(cErro)
            cErro += CRLF
        EndIf
        cErro += " -> " + aLog[nY]
    Next nY    
    cLog += cErro
    
    If !lJob
        If MsgYesNo("Ocorreram erros na geração do pedido de vendas da replicação da filial."+CRLF+"Deseja visualizar o erro ?")
            MostraErro()
        EndIf
    EndIf            
    lRet:=.F.    
Else    
    cNumPed:=SC5->C5_NUM
    lRet:=.T.
    cLog += "Gerado com sucesso sob numero: "+cNumPed
Endif

aRet := {lRet,cLog,cNumPed}

If lJob
    RESET ENVIRONMENT
EndIf

Return aRet

/*/{protheus.doc} BoGetVCust
*******************************************************************************************
Funcao para retornar o valor do custo
 
@author: Marcelo Celi Marques
@since: 13/07/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoGetVCust(cFilCust,cProduto)
Local nCusto    := 0
Local _cFilAnt  := cFilAnt
Local cQuery    := ""
Local cAlias    := GetNextAlias()

cFilAnt := cFilCust

cQuery := "SELECT TOP 1"                                        +CRLF
cQuery += "     B9_DATA     AS DATA,"                           +CRLF
cQuery += "     B9_CM1      AS CUSTO,"                          +CRLF
cQuery += "     R_E_C_N_O_  AS RECNO"                           +CRLF
cQuery += " FROM "+RetSqlName("SB9")+" SB9 (NOLOCK)"            +CRLF
cQuery += " WHERE   SB9.B9_FILIAL  = '"+xFilial("SB9")+"'"      +CRLF
cQuery += "     AND SB9.B9_COD     = '"+cProduto+"'"            +CRLF
cQuery += "     AND SB9.B9_LOCAL   = '01'"                      +CRLF
cQuery += "     AND SB9.D_E_L_E_T_ = ' '"                       +CRLF
cQuery += " ORDER BY B9_DATA DESC, R_E_C_N_O_ DESC"             +CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
    nCusto := (cAlias)->CUSTO
EndIf
(cAlias)->(dbCloseArea())

cFilAnt := _cFilAnt

Return nCusto

/*/{protheus.doc} GetCliente
*******************************************************************************************
Retorna o cliente da opereação
 
@author: Marcelo Celi Marques
@since: 13/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetCliente(cFilPV,cCliente,cLojaCli)
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSM0  := SM0->(GetArea())

cCliente := ""
cLojaCli := ""

SM0->(DbGotop())
Do While !SM0->(Eof())
    If SM0->M0_CODIGO  == cEmpAnt .And. Alltrim(SM0->M0_CODFIL) == Alltrim(cFilPV)
        SA1->(dbSetOrder(3))
        If SA1->(dbSeek(xFilial("SA1")+SM0->M0_CGC))
            cCliente := SA1->A1_COD
            cLojaCli := SA1->A1_LOJA                    
            Exit
        EndIf
    EndIf
    SM0->(dbSkip())
EndDo

SM0->(RestArea(aAreaSM0))
SA1->(RestArea(aAreaSA1))
RestArea(aArea)

Return

/*/{protheus.doc} GetFornece
*******************************************************************************************
Retorna o fornecedor da opereação
 
@author: Marcelo Celi Marques
@since: 13/07/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetFornece(cCgc)
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local lRet      := .F.

If !Empty(cCgc)
    SM0->(DbGotop())
    Do While !SM0->(Eof())
        If SM0->M0_CGC  == cCgc
            lRet := .T.
            Exit    
        EndIf
        SM0->(dbSkip())
    EndDo
EndIf

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return lRet
