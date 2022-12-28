#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TBICODE.CH"                                
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "apwizard.ch"

Static Tb_Ferra := ""
Static Tb_Ecomm := ""
Static Tb_Conex := ""
Static Tb_Produ := ""
Static Tb_Estru := ""
Static Tb_IDS   := ""
Static Tb_Monit := ""
Static Tb_ChMon := ""
Static Tb_LgMon := ""
Static Tb_ThMon := ""
Static Tb_Depar := ""
Static Tb_Categ := ""
Static Tb_Marca := ""
Static Tb_Fabri := ""
Static Tb_Canal := ""
Static Tb_TbPrc := ""
Static Tb_TbSta := ""
Static Tb_CondP := ""
Static Tb_Transp:= ""
Static Tb_Voucher:= ""

Static FilEcomm := ""
Static Armazem  := ""

/*/{protheus.doc} MaEcIniVar
*******************************************************************************************
Inicializa as variaveis do sistema

@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcIniVar(lJob,cFerra,cEcomm,cConex,cProdu,cEstru,cIDs,cMonit,cChMon,cLgMon,cThMon,cDepar,cCateg,cMarca,cFabri,cCanal,cTabPr,cTbSta,cTbCondP,cTbTransp,cTbVoucher,cFilEcomm,cArmazem,cCodEcomm)
Local lRet       := .T.
Local cMsg       := ""
//Local dDataValid := Stod("")

Default lJob      := .F.
Default cCodEcomm := ""

Tb_Ferra := u_MAECGetTb("FER")
Tb_Ecomm := u_MAECGetTb("ECO")
Tb_Conex := u_MAECGetTb("CON")
Tb_Produ := u_MAECGetTb("PRD")
Tb_Estru := u_MAECGetTb("EST")
Tb_IDS   := u_MAECGetTb("IDS")
Tb_Monit := u_MAPNGetTb("MON")
Tb_ChMon := u_MAPNGetTb("CHM")
Tb_LgMon := u_MAPNGetTb("LOG")
Tb_ThMon := u_MAPNGetTb("THR")
Tb_Depar := u_MACDGetTb("DEP")
Tb_Categ := u_MACDGetTb("CAT")
Tb_Marca := u_MACDGetTb("MRC")
Tb_Fabri := u_MACDGetTb("FAB")
Tb_Canal := u_MACDGetTb("CAN")
Tb_TbPrc := u_MACDGetTb("TPC")
Tb_TbSta := u_MACDGetTb("STA")
Tb_CondP := u_MACDGetTb("PGT")
Tb_Transp:= u_MACDGetTb("TRA")
Tb_Voucher:= u_MACDGetTb("DSC")

Armazem  := ""

lRet := u_MAVldMonit(Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,lJob,.F.)                  .And. ;
        u_MAVldEcomm(Tb_Ferra,Tb_Ecomm,Tb_Conex,Tb_Produ,Tb_Estru,Tb_IDS,lJob,.F.)  .And. ;
        u_MAVldCadEC(Tb_Depar,Tb_Categ,Tb_Marca,Tb_Fabri,Tb_Canal,Tb_TbPrc,Tb_TbSta,Tb_CondP,Tb_Transp,Tb_Voucher,lJob,.F.)

//If lRet
    //->> Remover quando houver a validação da ferramenta
    //dDataValid := Stod("20220215") 
    //If Date() >= dDataValid
    //    If !isBlind()
    //        MsgAlert("Periodo de Uso da Ferramenta Expirado...")
    //    Else
    //        ConOut("Periodo de Uso da Ferramenta Expirado...")
    //    EndIf    
    //    lRet := .F.
    //EndIf
//EndIf

If !lRet
    If !Empty(cMsg)
        If lJob
            ConOut(cMsg)
        Else
            MsgAlert(cMsg)
        EndIf
    EndIf
    Tb_Ferra := ""
    Tb_Ecomm := ""
    Tb_Conex := ""
    Tb_Produ := ""
    Tb_Estru := ""
    Tb_IDS   := ""
    Tb_Monit := ""
    Tb_ChMon := ""
    Tb_LgMon := ""
    Tb_ThMon := ""
    Tb_Depar := ""
    Tb_Categ := ""
    Tb_Marca := ""
    Tb_Fabri := ""
    Tb_Canal := ""
    Tb_TbPrc := ""
    Tb_TbSta := ""
    Tb_CondP := ""
    Tb_Transp:= ""
    Tb_Voucher:=""
    
    FilEcomm := ""
    Armazem  := ""
EndIf

cFerra := Tb_Ferra
cEcomm := Tb_Ecomm
cConex := Tb_Conex
cProdu := Tb_Produ
cEstru := Tb_Estru
cIDs   := Tb_IDS
cMonit := Tb_Monit
cChMon := Tb_ChMon
cLgMon := Tb_LgMon
cThMon := Tb_ThMon
cDepar := Tb_Depar
cCateg := Tb_Categ
cMarca := Tb_Marca
cFabri := Tb_Fabri
cCanal := Tb_Canal
cTabPr := Tb_TbPrc
cTbSta := Tb_TbSta
cTbCondP := Tb_CondP
cTbTransp := Tb_Transp
cTbVoucher:= Tb_Voucher

cFilEcomm := FilEcomm
cArmazem  := Armazem

Return lRet

/*/{protheus.doc} MaSetFilEC
*******************************************************************************************
Seta a filial do ecommerce

@author: Marcelo Celi Marques
@since: 23/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaSetFilEC(cTbEcomm,cCodEcomm)
Default cCodEcomm := ""

If !Empty(cCodEcomm)
    (cTbEcomm)->(dbSetOrder(1))
    If (cTbEcomm)->(dbSeek(xFilial(cTbEcomm)+cCodEcomm)) .And. (cTbEcomm)->&(cTbEcomm+"_MSBLQL") <> "1"
        FilEcomm := (cTbEcomm)->&(cTbEcomm+"_FILECO")
        cFilAnt := FilEcomm
    EndIf
EndIf

Return cFilAnt

/*/{protheus.doc} MaGetVlrEc
*******************************************************************************************
Retorna o Valor do SKU

@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaGetVlrEc(cSKU,cEcommerce,aEstrutura,cTab,lDesconto)
Local nValor    := 0
Local aArea     := GetArea()
Local aAreaEstr := (Tb_Estru)->(GetArea())
Local aAreaProd := (Tb_Produ)->(GetArea())

If !IsBlind()
    FwMsgRun(,{|| nValor := GetValor(@cSKU,@cEcommerce,@aEstrutura,@cTab,@lDesconto) }, "Aguarde...","Calculando o Valor do SKU...")
Else
    nValor := GetValor(@cSKU,@cEcommerce,@aEstrutura,@cTab,@lDesconto)
EndIf

(Tb_Produ)->(RestArea(aAreaProd))
(Tb_Estru)->(RestArea(aAreaEstr))
RestArea(aArea)

Return nValor

/*/{protheus.doc} GetValor
*******************************************************************************************
Retorna o Valor do SKU

@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetValor(cSKU,cEcommerce,aEstrutura,cTab,lDesconto)
Local cFilAtu   := cFilAnt
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local nValor    := 0
Local cProduto  := ""
Local nQtd      := 0
Local nPreco    := 0
Local cTabela   := ""
Local nX        := 1
Local nPcDesc   := 0
Local nVlrDesc  := 0
Local nVlDscEstr:= 0
Local nPcDscEstr:= 0

Default cSKU       := "" 
Default aEstrutura := {}
Default cTab       := ""
Default lDesconto  := .F.  

If u_MaEcIniVar()
    cSKU        := PadR(cSKU,Tamsx3(Tb_Produ+"_SKU")[01])
    cEcommerce  := PadR(cEcommerce,Tamsx3(Tb_IDS+"_ECOM")[01])
    u_MaSetFilEC(Tb_Ecomm,cEcommerce)

    //->> Montagem da Estrutura, senão vier por referencia
    If Len(aEstrutura)==0
        (Tb_Estru)->(dbSetOrder(1))
        (Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+cSKU))
        Do While (Tb_Estru)->(!Eof()) .And. (Tb_Estru)->&(Tb_Estru+"_FILIAL+"+Tb_Estru+"_SKU") == xFilial(Tb_Estru)+cSKU
            nQtd     := (Tb_Estru)->&(Tb_Estru+"_QTDE")
            cProduto := PadR((Tb_Estru)->&(Tb_Estru+"_COD"),Tamsx3("B1_COD")[01])
            aAdd(aEstrutura,{cProduto,nQtd})
            (Tb_Estru)->(dbSkip())
        EndDo
    EndIf

    cFilAtu := FilEcomm
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cEcommerce)) .And. (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
        If !Empty(cTab)
            cTabela  := PadR(cTab,Tamsx3("DA1_CODTAB")[01])
        Else
            cTabela  := PadR((Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC"),Tamsx3("DA1_CODTAB")[01])
        EndIf
        For nX:=1 to Len(aEstrutura)
            nPreco   := 0
            cProduto := aEstrutura[nX,01]
            nQtd     := aEstrutura[nX,02]

            DA1->(dbSetOrder(1))
            If DA1->(dbSeek(xFilial("DA1")+cTabela+cProduto))
                nPreco := DA1->DA1_PRCVEN
            EndIf
            If lDesconto
                nPcDesc     := DA1->DA1_PERDES
                nPcDscEstr  := Posicione(Tb_IDS,1,xFilial(Tb_IDS)+cEcommerce+"PRD"+cSKU,Tb_IDS+"_PCDESC")
            Else
                nPcDesc := 0
            EndIf

            nVlrDesc    := (nPreco * nQtd) * (nPcDesc/100)
            nVlDscEstr  := ((nPreco * nQtd)-nVlrDesc) * (nPcDscEstr/100)

            nValor += ((nQtd * nPreco) - nVlDscEstr)
        Next nX        
        nValor := Round(nValor,Tamsx3("DA1_PRCVEN")[02])
    EndIf
EndIf
SM0->(RestArea(aAreaSM0))
RestArea(aArea)
cFilAnt := cFilAtu

Return nValor

/*/{protheus.doc} MaGetEstEc
*******************************************************************************************
Retorna o estoque do SKU

@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaGetEstEc(cSKU,cEcommerce)
Local nSaldo := 0

If !IsBlind()
    FwMsgRun(,{|| nSaldo := GetEstoque(@cSKU,cEcommerce) }, "Aguarde...","Obtendo o Saldo do SKU...")
Else
    nSaldo := GetEstoque(@cSKU,cEcommerce)
EndIf

Return nSaldo

/*/{protheus.doc} GetEstoque
*******************************************************************************************
Retorna o estoque do SKU

@author: Marcelo Celi Marques
@since: 04/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetEstoque(cSKU,cEcommerce)
Local cFilAtu       := cFilAnt
Local aArea         := GetArea()
Local aAreaSM0      := SM0->(GetArea())
Local nSaldo        := 0
Local cProduto      := ""
Local aSaldo        := {}
Local cArmazem      := ""
Local lPEINESTQEC   := ExistBlock("PEINESTQEC") // Ponto de Entrada para tratar o estoque do produto
Local aTabelas      := {}

Default cEcommerce := ""
cEcommerce := PadR(cEcommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])

If u_MaEcIniVar()
    cSKU := PadR(cSKU,Tamsx3(Tb_Produ+"_SKU")[01])    
    u_MaSetFilEC(Tb_Ecomm,cEcommerce)

    If lPEINESTQEC
        aAdd(aTabelas,{ Tb_Ferra,"FER" })
        aAdd(aTabelas,{ Tb_Ecomm,"ECO" })
        aAdd(aTabelas,{ Tb_Conex,"CON" })
        aAdd(aTabelas,{ Tb_Produ,"PRO" })
        aAdd(aTabelas,{ Tb_Estru,"EST" })
        aAdd(aTabelas,{ Tb_IDS  ,"IDS" })
        aAdd(aTabelas,{ Tb_Monit,"MON" })
        aAdd(aTabelas,{ Tb_ChMon,"CHM" })
        aAdd(aTabelas,{ Tb_LgMon,"LGM" })
        aAdd(aTabelas,{ Tb_ThMon,"THM" })
        aAdd(aTabelas,{ Tb_Depar,"DEP" })
        aAdd(aTabelas,{ Tb_Categ,"CAT" })
        aAdd(aTabelas,{ Tb_Marca,"MAR" })
        aAdd(aTabelas,{ Tb_Fabri,"FAB" })
        aAdd(aTabelas,{ Tb_Canal,"CAN" })
        aAdd(aTabelas,{ Tb_TbPrc,"TPC" })
        aAdd(aTabelas,{ Tb_TbSta,"STA" })
        aAdd(aTabelas,{ Tb_CondP,"PGT" })        

        nSaldo := Execblock("PEINESTQEC",.F.,.F.,{cSKU,cEcommerce,aTabelas})
    Else
        cFilAtu := FilEcomm
        (Tb_Ecomm)->(dbSetOrder(1))
        If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cEcommerce))
            cArmazem := (Tb_Ecomm)->&(Tb_Ecomm+"_LOCAL")
            (Tb_Produ)->(dbSetOrder(1))
            If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+cSKU)) .And. (Tb_Produ)->&(Tb_Produ+"_MSBLQL") <> "1"
                (Tb_Estru)->(dbSetOrder(1))
                (Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+cSKU))
                Do While (Tb_Estru)->(!Eof()) .And. (Tb_Estru)->&(Tb_Estru+"_FILIAL+"+Tb_Estru+"_SKU") == xFilial(Tb_Estru)+cSKU
                    nQtd     := (Tb_Estru)->&(Tb_Estru+"_QTDE")
                    cProduto := PadR((Tb_Estru)->&(Tb_Estru+"_COD"),Tamsx3("B1_COD")[01])                
                    If SB2->(dbSeek(xFilial("SB2")+cProduto+cArmazem))
                        nSaldo := SB2->(B2_QATU-B2_RESERVA-B2_QEMP)
                        nSaldo := Round(nSaldo / nQtd,Tamsx3("B2_QATU")[02])
                        aAdd(aSaldo,nSaldo)
                    Else
                        aAdd(aSaldo,0)
                    EndIf            
                    (Tb_Estru)->(dbSkip())
                EndDo
            EndIf
        EndIf
        If Len(aSaldo)>0
            aSaldo := aSort(aSaldo,,,{|x,y| x < y})
            nSaldo := aSaldo[1]
        Else
            nSaldo := 0
        EndIf
    EndIf
EndIf
SM0->(RestArea(aAreaSM0))
RestArea(aArea)
cFilAnt := cFilAtu

Return nSaldo

/*/{protheus.doc} MaEcOrcame
*******************************************************************************************
Cria o pre-pedido de vendas (Orçamento)

@author: Marcelo Celi Marques
@since: 12/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcOrcame(cOrigem,cId,cCliente,cLoja,cMetPgto,dIntegr,hIntegr,aItsVenda,cErro,cDetPgto,cCanal,aRecebiment,dPedido,cDetEntrega,cIdVenda,cIdCanal,cIdEntrega,cIdCondPgto,nVrlFrete,cTransport,cRecebe,nJurCartao)
Local lRet          := .F.
Local cNewId        := ""
Local aCabec        := {}
Local aItens        := {}
Local aItem         := {}
Local cNumero       := ""
Local cTabPrec      := ""
Local cCondPgto     := ""
Local nX            := 1
Local cTes          := ""
Local cOper         := ""
Local cOperBrind    := ""
Local cItem         := StrZero(1,Tamsx3("CK_ITEM")[01])
Local nQtde         := 1
Local nVlrUnit      := 0
Local nPrcLista     := 0
Local nTotal        := 0
Local aLog          := {}
Local lErro         := .F.
Local cNumReserv    := ""
Local lReserv       := .F.
Local lPEINCABECO   := ExistBlock("PEINCABECO") // Ponto de Entrada para adicionar/alterar cabeçalho do orçamento de venda
Local lPEINITEECO   := ExistBlock("PEINITEECO") // Ponto de Entrada para adicionar/alterar item do orçamento de venda
Local lPEINALTECO   := ExistBlock("PEINALTECO") // Ponto de Entrada para alterar todos os itens do orçamento de venda
Local lPEINORCECO   := ExistBlock("PEINORCECO") // Ponto de Entrada para executar operações complementares após a geração do orçamento de venda
Local lPEINPVEECO   := ExistBlock("PEINPVEECO") // Ponto de Entrada para executar operações complementares após a geração do pedido de venda
Local lPEINNFEECO   := ExistBlock("PEINNFEECO") // Ponto de Entrada para executar operações complementares após a geração do pedido de venda
Local lPEINGNFECO   := ExistBlock("PEINGNFECO") // Ponto de Entrada para retornar se documento de saida pode ser gerado
Local aTabelas      := {}
Local cNumPV        := ""
Local cDocto        := ""
Local _dDatabase    := dDatabase
Local cSerie        := ""
Local nPcRateio     := 0
Local lGeraDoc      := .T.
Local cTbPadrao     := ""
Local nVlrDesc      := 0
Local cCdTransp     := ""

//->> Marcelo Celi - 08/09/2022
Local nPcAcresc     := 0
Local nVlrTotPed    := 0

//->> Marcelo Celi - 09/09/2022
Local lMercLivre    := .F.
Local cXmlBySite    := ""
Local lExiste       := .F.

Default cMetPgto        := "1" //1=Boleto;2=Cheque;3=Deposito;4=Cartão BNDES;5=Abater Crédito;6=Cartão na Entrega ;7=Dinheiro
Default cDetPgto        := ""
Default cCanal          := ""
Default aRecebiment     := {}
Default dPedido         := dDatabase
Default cDetEntrega     := ""
Default cIdVenda        := ""
Default cIdCanal        := ""
Default cIdEntrega      := ""
Default cIdCondPgto     := ""
Default nVrlFrete       := 0
Default cTransport      := ""
Default cRecebe         := ""

//->> Marcelo Celi - 08/09/2022
Default nJurCartao      := 0

Private lMSErroAuto     := .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile 	:= .T. 

//->> Marcelo Celi - 09/09/2022
If !Empty(cCanal) .And. Alltrim(cCanal) $ Alltrim(GetNewPar("BO_CANMLIV","9")) .And. Alltrim(Upper(cOrigem))=="VTEX"
    lMercLivre := .T.
EndIf

cErro := ""
dDatabase := dPedido

If u_MaEcIniVar()
    u_MaSetFilEC(Tb_Ecomm,cOrigem)

    aAdd(aTabelas,{ Tb_Ferra,"FER" })
    aAdd(aTabelas,{ Tb_Ecomm,"ECO" })
    aAdd(aTabelas,{ Tb_Conex,"CON" })
    aAdd(aTabelas,{ Tb_Produ,"PRO" })
    aAdd(aTabelas,{ Tb_Estru,"EST" })
    aAdd(aTabelas,{ Tb_IDS  ,"IDS" })
    aAdd(aTabelas,{ Tb_Monit,"MON" })
    aAdd(aTabelas,{ Tb_ChMon,"CHM" })
    aAdd(aTabelas,{ Tb_LgMon,"LGM" })
    aAdd(aTabelas,{ Tb_ThMon,"THM" })
    aAdd(aTabelas,{ Tb_Depar,"DEP" })
    aAdd(aTabelas,{ Tb_Categ,"CAT" })
    aAdd(aTabelas,{ Tb_Marca,"MAR" })
    aAdd(aTabelas,{ Tb_Fabri,"FAB" })
    aAdd(aTabelas,{ Tb_Canal,"CAN" })
    aAdd(aTabelas,{ Tb_TbPrc,"TPC" })
    aAdd(aTabelas,{ Tb_TbSta,"STA" })
    aAdd(aTabelas,{ Tb_CondP,"PGT" })
    aAdd(aTabelas,{ Tb_Transp,"TRA"})
    aAdd(aTabelas,{ Tb_Voucher,"DSC"})
    
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+PadR(cOrigem,Tamsx3(Tb_Ecomm+"_CODIGO")[01]))) .And. (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"        
        If Valtype(cId)=="N"
            cNewId := Alltrim(Str(cId))
        Else
            cNewId := Alltrim(cId)
        EndIf    
        
        If !Empty(cIdCanal)
            (Tb_Canal)->(dbSetOrder(1))
            (Tb_Canal)->(dbSeek(xFilial(Tb_Canal)+PadR(cOrigem,Tamsx3(Tb_Canal+"_ECOMME")[01])))
            Do While (Tb_Canal)->(!Eof()) .And. (Tb_Canal)->&(Tb_Canal+"_ECOMME") == PadR(cOrigem,Tamsx3(Tb_Canal+"_ECOMME")[01])
                If Alltrim((Tb_Canal)->&(Tb_Canal+"_IDECOM"))==Alltrim(cIdCanal)
                    cTabPrec := (Tb_Canal)->&(Tb_Canal+"_TABPRC")
                    Exit
                EndIf
                (Tb_Canal)->(dbSkip())
            EndDo
        EndIf
        If Empty(cTabPrec)
            cTabPrec  := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
        EndIf
        cTbPadrao := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")

        cCondPgto := GetCondPgto(cOrigem,cIdCondPgto,Tb_CondP)
        If Empty(cCondPgto)
            cCondPgto := (Tb_Ecomm)->&(Tb_Ecomm+"_CNDPAD")
        EndIf

        cOper      := (Tb_Ecomm)->&(Tb_Ecomm+"_OPEPAD")
        cOperBrind := (Tb_Ecomm)->&(Tb_Ecomm+"_OPEBRI")
        Armazem    := (Tb_Ecomm)->&(Tb_Ecomm+"_LOCAL")
        cSerie     := (Tb_Ecomm)->&(Tb_Ecomm+"_SERIE")

        //->> Marcelo Celi -09/09/2022 - Tratativa para o mercado livre no vtex
        If lMercLivre
            cSerie     := GetNewPar("BO_SERMLIV","3")
            cOper      := GetNewPar("BO_OPEMLIV","") // Tipo de Operação para Mercado Livre
            cOperBrind := GetNewPar("BO_OPBMLIV","") // Tipo de Operação para Mercado Livre para TES de Brinde

            //->> Se os parâmetros do mercado livre estiverem em branco, considerar os default
            If Empty(cSerie)
                cSerie := (Tb_Ecomm)->&(Tb_Ecomm+"_SERIE")
            EndIf
            If Empty(cOper)
                cOper := (Tb_Ecomm)->&(Tb_Ecomm+"_OPEPAD")
            EndIf
            If Empty(cOperBrind)    
                cOperBrind := (Tb_Ecomm)->&(Tb_Ecomm+"_OPEBRI")
            EndIf
        EndIf

        //->> Marcelo Celi - 17/03/2022
        cCdTransp  := ""
        (Tb_Transp)->(dbSetOrder(1))
        If (Tb_Transp)->(dbSeek(xFilial(Tb_Transp)+PadR(cOrigem,Tamsx3(Tb_Transp+"_ECOMME")[01])+PadR(cTransport,Tamsx3(Tb_Transp+"_IDECOM")[01])))
            cCdTransp := (Tb_Transp)->&(Tb_Transp+"_TRANSP")
        EndIf
        
        SA1->(dbSetOrder(1))
        DA0->(dbSetOrder(1))
        SE4->(dbSetOrder(1))
        
        If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja)) .And. ;
           DA0->(dbSeek(xFilial("DA0")+cTabPrec))       .And. ;
           SE4->(dbSeek(xFilial("SE4")+cCondPgto)) 

            //->> Ajustado para caso o campo esteja em branco, para gerar o pedido de vendas corretamente
            If Empty(SA1->A1_NATUREZ)
                Reclock("SA1",.F.)
                SA1->A1_NATUREZ := (Tb_Ecomm)->&(Tb_Ecomm+"_NATPAD")
                SA1->(MsUnlock())
            EndIf

            SCJ->(dbOrderNickName("CJXORIGEM"))
            lExiste := SCJ->(dbSeek(xFilial("SCJ")+PadR(cOrigem,Tamsx3("CJ_XORIGEM")[01])+PadR(cNewId,Tamsx3("CJ_XIDINTG")[01])))
            If lExiste
                Reclock("SCJ",.F.)
                If SCJ->(FieldPos("CJ_XIDVNDA"))>0
                    Alltrim(Upper(SCJ->CJ_XIDVNDA)) := Alltrim(Upper(cIdVenda))
                EndIf
                SCJ->(MsUnlock())
            Else
                SCJ->(dbSetOrder(1))
                cNumero := GetSxeNum("SCJ","CJ_NUM")        
                Do While SCJ->(dbSeek(xFilial("SCJ")+cNumero))
                    ConfirmSX8()
                    cNumero := GetSxeNum("SCJ","CJ_NUM")							
                EndDo

                aAdd(aCabec,{"CJ_NUM"		,cNumero		,Nil, Posicione("SX3",2,"CJ_NUM"        ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_CLIENTE"	,SA1->A1_COD	,Nil, Posicione("SX3",2,"CJ_CLIENTE"    ,"X3_ORDEM")})                
                aAdd(aCabec,{"CJ_LOJA"		,SA1->A1_LOJA	,Nil, Posicione("SX3",2,"CJ_LOJA"       ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_CLIENT"	,SA1->A1_COD	,Nil, Posicione("SX3",2,"CJ_CLIENT"     ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_LOJAENT"	,SA1->A1_LOJA	,Nil, Posicione("SX3",2,"CJ_LOJAENT"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_CONDPAG"	,cCondPgto	    ,Nil, Posicione("SX3",2,"CJ_CONDPAG"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_TABELA"	,cTabPrec		,Nil, Posicione("SX3",2,"CJ_TABELA"     ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XORIGEM"	,cOrigem		,Nil, Posicione("SX3",2,"CJ_XORIGEM"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XIDINTG"	,cNewId 		,Nil, Posicione("SX3",2,"CJ_XIDINTG"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XDTINTE"   ,dIntegr        ,Nil, Posicione("SX3",2,"CJ_XDTINTE"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XHRINTE"   ,hIntegr        ,Nil, Posicione("SX3",2,"CJ_XHRINTE"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XDTDESC"   ,Date()         ,Nil, Posicione("SX3",2,"CJ_XDTDESC"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XHRDESC"   ,Time()         ,Nil, Posicione("SX3",2,"CJ_XHRDESC"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XDETPGT"   ,cDetPgto       ,Nil, Posicione("SX3",2,"CJ_XDETPGT"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XSTATUS"   ,"0"            ,Nil, Posicione("SX3",2,"CJ_XSTATUS"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XIDVNDA"   ,cIdVenda       ,Nil, Posicione("SX3",2,"CJ_XIDVNDA"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XIDENTR"   ,cIdEntrega     ,Nil, Posicione("SX3",2,"CJ_XIDENTR"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_FRETE"     ,nVrlFrete      ,Nil, Posicione("SX3",2,"CJ_FRETE"      ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XTRANSP"   ,cTransport     ,Nil, Posicione("SX3",2,"CJ_XTRANSP"    ,"X3_ORDEM")})
                aAdd(aCabec,{"CJ_XCDTRAN"   ,cCdTransp      ,Nil, Posicione("SX3",2,"CJ_XCDTRAN"    ,"X3_ORDEM")})

                //->> Marcelo Celi - 26/03/2022
                aAdd(aCabec,{"CJ_XRECEBE"   ,cRecebe        ,Nil, Posicione("SX3",2,"CJ_XRECEBE"    ,"X3_ORDEM")})

                For nX:=1 to Len(aRecebiment)
                    If SCJ->(FieldPos("CJ_PARC"+Alltrim(Str(nX)))) > 0 .And. SCJ->(FieldPos("CJ_DATA"+Alltrim(Str(nX)))) > 0
                        aAdd(aCabec,{"CJ_PARC"+Alltrim(Str(nX)),aRecebiment[nX,02],Nil,Posicione("SX3",2,"CJ_PARC"+Alltrim(Str(nX)),"X3_ORDEM")})
                        aAdd(aCabec,{"CJ_DATA"+Alltrim(Str(nX)),aRecebiment[nX,01],Nil,Posicione("SX3",2,"CJ_DATA"+Alltrim(Str(nX)),"X3_ORDEM")})
                    EndIf
                Next nX

                If SCJ->(FieldPos("CJ_XCANAL")) > 0
                    aAdd(aCabec,{"CJ_XCANAL"   ,cIdCanal    ,Nil, Posicione("SX3",2,"CJ_XCANAL"    ,"X3_ORDEM")})
                EndIf

                If SCJ->(FieldPos("CJ_XDETENT")) > 0
                    aAdd(aCabec,{"CJ_XDETENT"  ,cDetEntrega ,Nil, Posicione("SX3",2,"CJ_XDETENT"    ,"X3_ORDEM")})
                EndIf
                
                If lPEINCABECO
                    aCabec := Execblock("PEINCABECO",.F.,.F.,{aTabelas,FilEcomm,Armazem,aCabec,cMetPgto,aItsVenda,nVrlFrete})
                EndIf

                aCabec := aSort(aCabec,,,{|x,y| x[4] < y[4] })

                //->> Marcelo Celi - 08/09/2022
                nPcAcresc := 0
                nVlrTotPed:= 0
                If nJurCartao > 0
                    For nX:=1 to Len(aItsVenda)
                        nVlrTotPed += aItsVenda[nX,02] * aItsVenda[nX,03]
                    Next nX
                    nVlrTotPed := Round(nVlrTotPed,2)
                    nPcAcresc := (nJurCartao * 100) / nVlrTotPed
                EndIf

                For nX:=1 to Len(aItsVenda)
                    (Tb_Produ)->(dbSetOrder(1))
                    (Tb_Estru)->(dbSetOrder(1))
                    If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+aItsVenda[nX,01]))
                        (Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+(Tb_Produ)->&(Tb_Produ+"_SKU")))
                        Do While !lErro .And. (Tb_Estru)->(!Eof()) .And. (Tb_Estru)->&(Tb_Estru+"_FILIAL")+(Tb_Estru)->&(Tb_Estru+"_SKU") == xFilial(Tb_Estru)+(Tb_Produ)->&(Tb_Produ+"_SKU")
                            SB1->(dbSetOrder(1))
                            DA1->(dbSetOrder(1))
                            If SB1->(dbSeek(xFilial("SB1")+(Tb_Estru)->&(Tb_Estru+"_COD"))) .And. ;
                               (DA1->(dbSeek(xFilial("DA1")+DA0->DA0_CODTAB+SB1->B1_COD)) .Or. DA1->(dbSeek(xFilial("DA1")+cTbPadrao+SB1->B1_COD)))
                                //->> Marcelo Celi - 26/03/2022
                                nPrcLista := DA1->DA1_PRCVEN
                                nQtde     := (Tb_Estru)->&(Tb_Estru+"_QTDE")
                                nPcRateio := GetRateiVlr(aItsVenda[nX,01],SB1->B1_COD,cOrigem,DA1->DA1_CODTAB)

                                //->> Marcelo Celi - 08/09/2022 - Verificar se produto não for kit, considerar preço cheio do site sem ratear
                                If (Tb_Produ)->&(Tb_Produ+"_TIPO") == "P"
                                    nPcRateio := 100                                    
                                EndIf

                                nVlrUnit  := Round(aItsVenda[nX,03] * (nPcRateio/100),Tamsx3("CK_PRCVEN")[02])

                                nTotal    := nPrcLista * (nQtde * aItsVenda[nX,02])
                                Armazem   := (Tb_Ecomm)->&(Tb_Ecomm+"_LOCAL")

                                //->> Marcelo Celi - 30/09/2022                                                                
                                //nVlrDesc  := aItsVenda[nX,04]
                                //If nVlrDesc == 0 .And. nVlrUnit < nPrcLista
                                //    nVlrDesc := (nPrcLista - nVlrUnit) * nQtde
                                //EndIf

                                nVlrDesc  := Round((aItsVenda[nX,04] * (nPcRateio/100)),2)

                                If (nVlrUnit * nQtde) - nVlrDesc > 0 //->> Valor Unitario                                    
                                    //->> TES de Venda
                                    cTes := MaTESInt(2,cOper,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
                                    If Empty(cTes)
                                        cTes := (Tb_Ecomm)->&(Tb_Ecomm+"_TESPAD")
                                    EndIf
                                Else
                                    //->> TES de Brinde
                                    cTes := MaTESInt(2,cOperBrind,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
                                    If Empty(cTes)
                                        cTes := (Tb_Ecomm)->&(Tb_Ecomm+"_TESBRI")
                                    EndIf
                                    
                                    //->> Marcelo Celi - 28/09/2022                                    
                                    //nVlrDesc := 0
                                    //nPrcLista:= 0
                                    nVlrDesc := nVlrDesc - 0.01
                                EndIf                                
                                Armazem := (Tb_Ecomm)->&(Tb_Ecomm+"_LOCAL")

                                //->> Caso não exista o registro de estoque na sb2 do produto, criar zerado
                                SB2->(dbSetOrder(1))
                                If !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+Armazem))
                                    CriaSb2(SB1->B1_COD,Armazem)
                                    SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+Armazem))
                                EndIf

                                //->> Marcelo Celi - 08/09/2022
                                If nPcAcresc > 0
                                    nVlrUnit := nVlrUnit + (nVlrUnit*(nPcAcresc/100))
                                    nPrcLista := nPrcLista + (nPrcLista*(nPcAcresc/100))
                                EndIf

                                aItem := {}
                                aAdd(aItem,{"CK_ITEM"		,cItem															,Nil, Posicione("SX3",2,"CK_ITEM"       ,"X3_ORDEM")})
                                aAdd(aItem,{"CK_PRODUTO"	,SB1->B1_COD										   			,Nil, Posicione("SX3",2,"CK_PRODUTO"    ,"X3_ORDEM")})
                                aAdd(aItem,{"CK_LOCAL"	    ,Armazem		    								   			,Nil, Posicione("SX3",2,"CK_LOCAL"      ,"X3_ORDEM")})
                                aAdd(aItem,{"CK_QTDVEN"		,Round(nQtde * 	aItsVenda[nX,02]	,Tamsx3("CK_QTDVEN")[02])	,Nil, Posicione("SX3",2,"CK_QTDVEN"     ,"X3_ORDEM")})
                                aAdd(aItem,{"CK_PRCVEN"		,Round(nVlrUnit			    		,Tamsx3("CK_PRCVEN")[02])	,Nil, Posicione("SX3",2,"CK_PRCVEN"     ,"X3_ORDEM")})
                                aAdd(aItem,{"CK_PRUNIT"		,Round(nPrcLista					,Tamsx3("CK_PRUNIT")[02])	,Nil, Posicione("SX3",2,"CK_PRUNIT"     ,"X3_ORDEM")})                              
                                
                                If nVlrDesc > 0
                                    aAdd(aItem,{"CK_VALDESC"	,Round(nVlrDesc						,Tamsx3("CK_VALDESC")[02])	,Nil, Posicione("SX3",2,"CK_VALDESC"    ,"X3_ORDEM")})
                                EndIf

                                aAdd(aItem,{"CK_TES"		,cTes															,Nil, Posicione("SX3",2,"CK_TES"        ,"X3_ORDEM")})
                                
                                If lPEINITEECO
                                    aItem := Execblock("PEINITEECO",.F.,.F.,{aTabelas,FilEcomm,Armazem,aItem,cMetPgto,aItsVenda,nX})
                                EndIf

                                aItem := aSort(aItem,,,{|x,y| x[4] < y[4] })                                
                                aAdd(aItens,aItem)
                                cItem := Soma1(cItem)
                            Else
                                cErro := "Produto: "+(Tb_Estru)->&(Tb_Estru+"_COD")+" não localizado no catálogo do produtos ou não amarrado na tabela de preços: "+DA0->DA0_CODTAB
                                lErro := .T.
                                lRet  := .F.
                                Exit
                            EndIf
                            (Tb_Estru)->(dbSkip())
                        EndDo
                    Else
                        cErro := "Produto de id: "+aItsVenda[nX,01]+", "+Alltrim(aItsVenda[nX,07])+" não localizado."
                        lErro := .T.
                        lRet  := .F.
                        Exit
                    EndIf
                Next nX

                If !lErro .And. Len(aCabec)>0 .And. Len(aItens)>0
                    If lPEINALTECO
                        aItens := Execblock("PEINALTECO",.F.,.F.,{aTabelas,FilEcomm,Armazem,aItens})
                    EndIf

                //  Begin Transaction
                        lMSErroAuto     := .F.
                        lMsHelpAuto		:= .T.
                        lAutoErrNoFile 	:= .T. 

                        MsExecAuto({|x,y,z| Mata415(x,y,z)},aCabec,aItens,3)
                        If lMSErroAuto
                            aLog := GetAutoGRLog()                        
                            For nX:=1 to 100
                                If nX <= Len(aLog)
                                    cErro += aLog[nX]+CRLF
                                Else
                                    Exit
                                EndIf		
                            Next nX
                     //     DisarmTransaction()
                            lErro := .T.
                            lRet  := .F.
                        Else
                            If lPEINORCECO
                                Execblock("PEINORCECO",.F.,.F.,{aTabelas,FilEcomm,SCJ->CJ_NUM})
                            EndIf
                            If lReserv
                                SCK->(dbSetOrder(1))
                                SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
                                Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM)
                                    cNumReserv := GetSx8Num("SC0","C0_NUM")
                                    ConfirmSX8()                                    
                                    ReservEstoq("I",cNumReserv,SCK->CK_NUM,SCK->CK_PRODUTO,SCK->CK_LOCAL,SCK->CK_QTDVEN)
                                    SCK->(dbSkip())
                                EndDo
                            EndIf                            
                            lRet := .T.
                            If (Tb_Ecomm)->&(Tb_Ecomm+"_GERPV")=="S" .Or. lMercLivre
                                //->> Marcelo Celi - 21/03/2022
                                //cNumPV := u_MaEcPedido(SCJ->CJ_NUM,aTabelas)
                                cNumPV := u_MaEcPedido(SCJ->CJ_NUM,aTabelas,cOrigem,cNewId,lMercLivre)
                                cXmlBySite := ""

                                If !Empty(cNumPV)
                                    If lPEINPVEECO
                                        Execblock("PEINPVEECO",.F.,.F.,{aTabelas,FilEcomm,cNumPV})
                                    EndIf                                    
                                    If (Tb_Ecomm)->&(Tb_Ecomm+"_GERNOT")=="S" .Or. lMercLivre
                                        lGeraDoc := .T.
                                        If lPEINGNFECO
                                            lGeraDoc := Execblock("PEINGNFECO",.F.,.F.,{aTabelas,FilEcomm,SCJ->CJ_NUM,SC5->C5_NUM})
                                        EndIf
                                        If lGeraDoc
                                            //->> Marcelo Celi -09/09/2022 - Tratativa para o mercado livre no vtex
                                            If lMercLivre
                                                cDocto := GetDocMLivr(cNewId,@cXmlBySite,.F.)
                                            EndIf

                                            cDocto := u_MaEcGerNot(cNumPV,cSerie,cDocto)

                                            //->> Marcelo Celi -09/09/2022 - Tratativa para o mercado livre no vtex
                                            If lMercLivre .And. !Empty(cXmlBySite) .And. SF2->(FieldPos("F2_XXMLSIT"))>0
                                                SF2->(dbSetOrder(1))
                                                If SF2->(dbSeek(xFilial("SF2")+PadR(cDocto,Tamsx3("F2_DOC")[01])+PadR(cSerie,Tamsx3("F2_SERIE")[01])))
                                                    RecLock("SF2",.F.)
                                                    SF2->F2_XXMLSIT := cXmlBySite
                                                    SF2->(MsUnlock())
                                                EndIf
                                            EndIf

                                            If !Empty(cDocto)
                                                If lPEINNFEECO
                                                    Execblock("PEINNFEECO",.F.,.F.,{aTabelas,FilEcomm,cDocto})
                                                EndIf
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                        EndIf
                  //End Transaction    
                Else
                    lErro := .T.
                    lRet  := .F.
                EndIf
            EndIf
        Else
            cErro := "cliente, condição de pagamento e/ou tabela de preço não localizado(s)."
            lErro := .T.
            lRet  := .F.
        EndIf
    Else
        cErro := "e-Commerce não configurado."
        lErro := .T.
        lRet  := .F.
    EndIf    
EndIf

dDatabase := _dDatabase

Return lRet

/*/{protheus.doc} ReservEstoq
*******************************************************************************************
Reserva o Estoque

@author: Marcelo Celi Marques
@since: 12/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function ReservEstoq(cTipo,cNumReserv,cOrcamento,cProduto,cLocal,nQtde)

Do Case
    Case cTipo == "I" // Inclui
        If !SC0->(dbSeek(xFilial("SC0")+cNumReserv+cProduto+cLocal))		                                        
            a430Reserv({1,"NF","ECO"+cOrcamento,cUserName,cFilAnt},	            ; //->> Operação da Reserva	
                        cNumReserv,					    						; //->> Numero da Reserva
                        cProduto,	    										; //->> Produto
                        cLocal,	        										; //->> Local Padrao
                        nQtde,	    											; //->> Quantidade
                        {"","","",""}											; //->> LOTE, SUBLOTE, ENDEREÇO, SERIE
                        ,,,)
        Else                
            a430Reserv({2,"NF","ECO"+cOrcamento,cUserName,cFilAnt},	            ; //->> Operação da Reserva	
                        cNumReserv,											    ; //->> Numero da Reserva
                        cProduto,   											; //->> Produto
                        cLocal,	        										; //->> Local Padrao
                        SC0->C0_QUANT + nQtde,									; //->> Quantidade
                        {"","","",""}											; //->> LOTE, SUBLOTE, ENDEREÇO, SERIE
                        ,,,)
        EndIf

    Case cTipo == "E" // Exclui
        a430Reserv({3,"NF","ECO"+cOrcamento,cUserName,cFilAnt},	                ; //->> Operação da Reserva	
                        cNumReserv,											    ; //->> Numero da Reserva
                        cProduto,   											; //->> Produto
                        cLocal,	        										; //->> Local Padrao
                        nQtde,						                			; //->> Quantidade
                        {"","","",""}											; //->> LOTE, SUBLOTE, ENDEREÇO, SERIE
                        ,,,)

EndCase

Return

/*/{protheus.doc} MaEcPedido
*******************************************************************************************
Cria o pedido de vendas

@author: Marcelo Celi Marques
@since: 12/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcPedido(cOrcamento,aTabelas,cOrigem,cIdIntegr,lMercLivre)
Local aArea         := GetArea()
Local aAreaSC9      := SC9->(GetARea())
Local aAreaSC0      := SC0->(GetARea())
Local aAreaSCJ      := SCJ->(GetARea())
Local aAreaSCK      := SCK->(GetARea())
Local aCabPV        := {}
Local aItens        := {}
Local aItemPV       := {}
Local cNumPed       := ""
Local lReserv       := .F.
Local aRecSCK       := {}
Local nX            := 1
Local cParc         := ""
Local lPEINCABPVE   := ExistBlock("PEINCABPVE") // Ponto de Entrada para adicionar/alterar cabeçalho do pedido de venda
Local lPEINITEPVE   := ExistBlock("PEINITEPVE") // Ponto de Entrada para adicionar/alterar item do pedido de venda
Local lPEINGRVPVE   := ExistBlock("PEINGRVPVE") // Ponto de Entrada para gravação de dados complementares ao pedido de vendas
Local nOrdSC5       := SC5->(IndexOrd())

Default cOrigem     := ""
Default cIdIntegr   := ""
Default lMercLivre  := .F.

cOrigem   := PadR(cOrigem,Tamsx3("C5_XORIGEM")[01])
cIdIntegr := PadR(cIdIntegr,Tamsx3("C5_XIDINTG")[01])

Private lMsErroAuto := .F.

SC5->(dbOrderNickName("C5XORIGEM"))
If !Empty(cOrigem) .And. !Empty(cIdIntegr) .And. SC5->(dbSeek(xFilial("SC5")+cOrigem+cIdIntegr))
    cNumPed := SC5->C5_NUM
Else
    //->> Remover reserva para efetivar o pedido
    If lReserv
        SC0->(dbOrderNickName("C0DOCRES"))
        SC0->(dbSeek(xFilial("SC0")+"ECO"+cOrcamento))
        Do While SC0->(!Eof()) .And. SC0->(C0_FILIAL+C0_DOCRES) == xFilial("SC0")+"ECO"+cOrcamento
            ReservEstoq("E",SC0->C0_NUM,cOrcamento,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_QUANT)
            SC0->(dbSkip())
        EndDo
    EndIf

    SCJ->(dbSetOrder(1))
    If SCJ->(dbSeek(xFilial("SCJ")+cOrcamento))
        SC5->(dbSetOrder(1))
        cNumPed := GetSxeNum("SC5","C5_NUM")
        Do While SC5->(dbSeek(xFilial("SC5")+cNumPed))
            ConfirmSX8()
            cNumPed := GetSxeNum("SC5","C5_NUM")
        EndDo

        SA1->(dbSetOrder(1))
        SA1->(dbSeek(xFilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA)))
        
        aCabPV:={ {"C5_NUM"    	,cNumPed      		,Nil, Posicione("SX3",2,"C5_NUM"        ,"X3_ORDEM")},;
                {"C5_TIPO"   	,"N"              	,Nil, Posicione("SX3",2,"C5_TIPO"       ,"X3_ORDEM")},;
                {"C5_CLIENTE"	,SCJ->CJ_CLIENTE  	,Nil, Posicione("SX3",2,"C5_CLIENTE"    ,"X3_ORDEM")},;
                {"C5_LOJACLI"	,SCJ->CJ_LOJA     	,Nil, Posicione("SX3",2,"C5_LOJACLI"    ,"X3_ORDEM")},;
                {"C5_EMISSAO"	,dDatabase		  	,Nil, Posicione("SX3",2,"C5_EMISSAO"    ,"X3_ORDEM")},;
                {"C5_CONDPAG"	,SCJ->CJ_CONDPAG  	,Nil, Posicione("SX3",2,"C5_CONDPAG"    ,"X3_ORDEM")},;
                {"C5_DESC1"  	,0                	,Nil, Posicione("SX3",2,"C5_DESC1"      ,"X3_ORDEM")},;
                {"C5_MOEDA"  	,SCJ->CJ_MOEDA    	,Nil, Posicione("SX3",2,"C5_MOEDA"      ,"X3_ORDEM")},;
                {"C5_FRETE"  	,SCJ->CJ_FRETE	   	,Nil, Posicione("SX3",2,"C5_FRETE"      ,"X3_ORDEM")},;
                {"C5_TRANSP" 	,SCJ->CJ_XCDTRAN   	,Nil, Posicione("SX3",2,"C5_TRANSP"     ,"X3_ORDEM")},;
                {'C5_TABELA'	,SCJ->CJ_TABELA		,NIL, Posicione("SX3",2,"C5_TABELA"     ,"X3_ORDEM")}}

        cParc := "1"
        For nX:=1 to 15        
            If SCJ->(FieldPos("CJ_PARC"+cParc)) > 0 .And. SCJ->(FieldPos("CJ_DATA"+cParc)) > 0 .And. ;
                SC5->(FieldPos("C5_PARC"+cParc)) > 0 .And. SC5->(FieldPos("C5_DATA"+cParc)) > 0

                aAdd(aCabPV,{"C5_PARC"+cParc ,SCJ->&("CJ_PARC"+cParc) ,NIL, Posicione("SX3",2,"C5_PARC"+cParc,"X3_ORDEM")})
                aAdd(aCabPV,{"C5_DATA"+cParc ,SCJ->&("CJ_DATA"+cParc) ,NIL, Posicione("SX3",2,"C5_DATA"+cParc,"X3_ORDEM")})
            EndIf
            cParc := Soma1(cParc)
        Next nX

        If lPEINCABPVE
            aCabPV := Execblock("PEINCABPVE",.F.,.F.,{aTabelas,FilEcomm,Armazem,aCabPV})
        EndIf

        aCabPV := aSort(aCabPV,,,{|x,y| x[4]<y[4] })

        SCK->(dbSetOrder(1))
        SCK->(dbSeek(xFilial("SCK")+cOrcamento))
        Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == xFilial("SCK")+cOrcamento
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+SCK->CK_PRODUTO))
        
            aItemPV:={  {"C6_NUM"    ,cNumPed                    ,Nil            , Posicione("SX3",2,"C6_NUM"        ,"X3_ORDEM")},;
                        {"C6_ITEM"   ,SCK->CK_ITEM	             ,Nil            , Posicione("SX3",2,"C6_ITEM"       ,"X3_ORDEM")},;
                        {"C6_PRODUTO",SCK->CK_PRODUTO            ,Nil            , Posicione("SX3",2,"C6_PRODUTO"    ,"X3_ORDEM")},;
                        {"C6_QTDVEN" ,SCK->CK_QTDVEN             ,Nil            , Posicione("SX3",2,"C6_QTDVEN"     ,"X3_ORDEM")},;
                        {"C6_QTDLIB" ,SCK->CK_QTDVEN             ,Nil            , Posicione("SX3",2,"C6_QTDLIB"     ,"X3_ORDEM")},;
                        {"C6_PRUNIT" ,SCK->CK_PRUNIT             ,Nil            , Posicione("SX3",2,"C6_PRUNIT"     ,"X3_ORDEM")},;
                        {"C6_ENTREG" ,SCK->CK_ENTREG             ,Nil            , Posicione("SX3",2,"C6_ENTREG"     ,"X3_ORDEM")},;
                        {"C6_UM"     ,SB1->B1_UM                 ,Nil            , Posicione("SX3",2,"C6_UM"         ,"X3_ORDEM")},;
                        {"C6_TES"    ,SCK->CK_TES                ,Nil            , Posicione("SX3",2,"C6_TES"        ,"X3_ORDEM")},;
                        {"C6_LOCAL"  ,SCK->CK_LOCAL              ,Nil            , Posicione("SX3",2,"C6_LOCAL"      ,"X3_ORDEM")},;                   
                        {"C6_PRCVEN" ,SCK->CK_PRCVEN             ,Nil            , Posicione("SX3",2,"C6_PRCVEN"     ,"X3_ORDEM")},;                   
                        {"C6_COMIS1" ,SCK->CK_COMIS1             ,Nil            , Posicione("SX3",2,"C6_COMIS1"     ,"X3_ORDEM")},;
                        {"C6_CLI"    ,SCK->CK_CLIENTE            ,Nil            , Posicione("SX3",2,"C6_CLI"        ,"X3_ORDEM")},;
                        {"C6_LOJA"   ,SCK->CK_LOJA               ,Nil            , Posicione("SX3",2,"C6_LOJA"       ,"X3_ORDEM")},;
                        {"C6_NUMORC" ,SCK->CK_NUM + SCK->CK_ITEM ,"AllWaysTrue()", Posicione("SX3",2,"C6_NUMORC"     ,"X3_ORDEM")}}
    
            //->> Marcelo Celi - 16/09/2022
            If SCK->CK_DESCONT > 0
                aAdd(aItemPV,{"C6_DESCONT",SCK->CK_DESCONT       ,Nil            , Posicione("SX3",2,"C6_DESCONT"    ,"X3_ORDEM")})
            EndIf
            If SCK->CK_VALDESC > 0
                aAdd(aItemPV,{"C6_VALDESC",SCK->CK_VALDESC       ,Nil            , Posicione("SX3",2,"C6_VALDESC"    ,"X3_ORDEM")})
            EndIf

            If lPEINITEPVE
                aItemPV := Execblock("PEINITEPVE",.F.,.F.,{aTabelas,FilEcomm,Armazem,aItemPV})
            EndIf

            aItemPV := aSort(aItemPV,,,{|x,y| x[4]<y[4] })
            aAdd(aItens,aItemPV)
            aAdd(aRecSCK,SCK->(Recno()))

            SCK->(dbSkip())
        EndDo
        
        If Len(aCabPV)>0 .And. Len(aItens)>0
            lMSErroAuto     := .F.
            lMsHelpAuto		:= .F.
            lAutoErrNoFile 	:= .F. 
            MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItens,3)
            If lMSErroAuto
                cNumPed := ""
            Else
                //->> Marcelo Celi - 17/03/2022
                SC6->(dbSetOrder(1))
                SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
                Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
                    Reclock("SC6",.F.)
                    SC6->C6_NUMORC := cOrcamento + SC6->C6_ITEM
                    SC6->(MsUnlock())
                    SC6->(dbSkip())
                EndDo            
                
                cNumPed := SC5->C5_NUM            
                Reclock("SCJ",.F.)
                SCJ->CJ_STATUS := 'B'
                SCJ->(MSUNLOCK())

                If lPEINGRVPVE
                    Execblock("PEINGRVPVE",.F.,.F.,{aTabelas,FilEcomm,Armazem})
                EndIf
        
                For nX:=1 to Len(aRecSCK)
                    SCK->(dbGoto(aRecSCK[nX]))
                    Reclock("SCK",.F.)
                    SCK->CK_NUMPV := cNumPed
                    SCK->(MsUnlock())
                Next nX

                //->> Faz a liberação automatica do credito e estoque de pedidos oriundos do mercado livre.
                If lMercLivre .And. !Empty(cNumPed)
                    SC9->(dbSetOrder(1))
                    SC9->(dbSeek(xFilial("SC9")+cNumPed))
                    Do While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cNumPed
                        If Empty(SC9->C9_NFISCAL)
                            RecLock("SC9",.F.)
                            SC9->C9_BLCRED := ""
                            SC9->C9_BLEST  := ""
                            SC9->(MsUnlock())
                        EndIf
                        SC9->(dbSkip())
                    EndDo
                EndIf
            EndIf
        EndIf    
    EndIf
EndIf

SC5->(dbSetOrder(nOrdSC5))
SCK->(RestArea(aAreaSCK))
SCJ->(RestArea(aAreaSCJ))
SC0->(RestArea(aAreaSC0))
SC9->(RestArea(aAreaSC9))
RestArea(aArea)

Return cNumPed

/*/{protheus.doc} MaEcGerNot
*******************************************************************************************
Gera a Nota de Vendas

@author: Marcelo Celi Marques
@since: 12/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcGerNot(cNumPed,cSerie,cDocto)
Local lOk       := .F.
Local aPvlNfs	:= {}

//->> Marcelo Celi - 09/09/2022
Default cDocto := ""
//->> Será utilizado no ponto de entrada M460NUM para alterar a numeração da nota
Private _cNewDocto := cDocto

If !Empty(cSerie)    
    DbSelectArea("SC6")
    SC6->(dbSetOrder(1))
    If SC6->(MsSeek(xFilial("SC6")+cNumPed))
        lOk := .T.
    EndIf

    DbSelectArea("SC9")
    SC9->(DbSetOrder(1))

    DbSelectArea("SE4")
    SE4->(DbSetOrder(1))
    
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    
    DbSelectArea("SF4")
    SF4->(DbSetOrder(1))

    Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
        If SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))
            SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG))
            SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
            SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
            
            If Empty(SC9->C9_NFISCAL)
                If !Empty(SC9->C9_BLCRED) .Or. !Empty(SC9->C9_BLEST)
                    lOk := .F.
                    Exit
                EndIf
            EndIf

            Aadd(aPvlNfs,{ SC9->C9_PEDIDO,  ;
                           SC9->C9_ITEM,    ;
                           SC9->C9_SEQUEN,  ;
                           SC9->C9_QTDLIB,  ;
                           SC9->C9_PRCVEN,  ;
                           SC9->C9_PRODUTO, ;
                           .F.,             ;
                           SC9->(RecNo()),  ;
                           SC5->(RecNo()),  ;
                           SC6->(RecNo()),  ;
                           SE4->(RecNo()),  ;
                           SB1->(RecNo()),  ;
                           SB2->(RecNo()),  ;
                           SF4->(RecNo())}  )
        Else
            lOk := .F.
            Exit
        EndIf    
        SC6->(dbSkip())
    EndDo

    If lOk
        cDocto := MaPvlNfs(aPvlNfs,cSerie , .F., .F., .F., .T., .F., 0, 0, .T., .F., "")
    EndIf
EndIf

Return cDocto

/*/{protheus.doc} MaGrvCliEc
*******************************************************************************************
Função de descida do cliente do pedido do e-commerce

@author: Marcelo Celi Marques
@since: 22/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaGrvCliEc(cEcommerce,cCpf,cCnpj,cInscEst,cInscMun,cNome,cRazaoSoc,aDadEntreg,aDadPgto,cCodigo,cLoja,lGravou,cIdCliEntr,cIdCepEntr)
Local cTpCliente := ""
Local cCgc       := ""
Local lRet       := .F.
Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local cNomeCli   := ""
Local cCodMunic  := ""
Local cUF        := ""
Local cMunicipio := ""
Local cPais      := ""
//->> Marcelo Celi - 26/03/2022
//Local cCliEntreg := ""
//Local cLojEntreg := ""
Local cCodiOk   := ""
Local cLojaOk   := ""

//->> Marcelo Celi - 03/06/2022
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aAreaAnt  := GetArea()

Default cIdCliEntr := ""
Default cIdCepEntr := ""

//->> Variaveis que serão retornados por referencia
cCodigo := ""
cLoja   := ""
lGravou := .F.

If u_MaEcIniVar()
    u_MaSetFilEC(Tb_Ecomm,cEcommerce)

    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cEcommerce))
        Do Case
            Case !Empty(cCnpj) .And. Cgc(cCnpj) // Marcelo Celi - 17/03/2022
                cTpCliente := "J"
                cCgc       := PadR(Alltrim(cCnpj),Tamsx3("A1_CGC")[01])
                cNomeCli   := Alltrim(cRazaoSoc)
                If Empty(cNomeCli)
                    cNomeCli := Alltrim(cNome)
                EndIf
            
            Case !Empty(cCpf) .And. Cgc(cCpf) // Marcelo Celi - 17/03/2022
                cTpCliente := "F"
                cCgc       := PadR(Alltrim(cCpf),Tamsx3("A1_CGC")[01])
                cNomeCli   := Alltrim(cRazaoSoc)
                If Empty(cNomeCli)
                    cNomeCli := Alltrim(cNome)
                EndIf

            Otherwise
                cTpCliente := ""
                cCgc       := ""
                cNomeCli   := ""

        EndCase

        If Empty(cCgc)
            lRet := .F.
        Else
            lRet := .T.
            //->> Marcelo Celi - 26/03/2022
            //->> Comentado em 28/03/2022 pois para canais especificos esse id não é tratado
            /*
            If Empty(cCodiOk)
                If Upper(Alltrim(cEcommerce)) == "VTEX"
                    If !Empty(cIdCliEntr)
                        SA1->(dbOrderNickName("A1XIDVTEX"))
                        If SA1->(dbSeek(xFilial("SA1")+cIdCliEntr))
                            cCodiOk := SA1->A1_COD
                            cLojaOk := SA1->A1_LOJA
                        EndIf
                    EndIf
                EndIf
            EndIf
            */ 

            //->> Marcelo Celi - 03/06/2022 - Inicio
            //If Empty(cCodiOk)
            //    If !Empty(cIdCepEntr)
            //        SA1->(dbOrderNickName("A1XNUMRES"))
            //        If SA1->(dbSeek(xFilial("SA1")+cIdCepEntr))
            //            cCodiOk := SA1->A1_COD
            //            cLojaOk := SA1->A1_LOJA
            //        EndIf
            //    EndIf
            //EndIf
            
            If Empty(cCodiOk)
                If !Empty(cIdCepEntr)
                    aAreaAnt  := GetArea()
                    cQuery := "SELECT SA1.A1_COD,"                              +CRLF
                    cQuery += "       SA1.A1_LOJA"                              +CRLF
                    cQuery += " FROM "+RetSqlName("SA1")+" SA1 (NOLOCK)"        +CRLF
                    cQuery += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"     +CRLF
                    cQuery += "   AND SA1.A1_CGC = '"+cCgc+"'"                  +CRLF
                    cQuery += "   AND SA1.A1_XNUMRES = '"+cIdCepEntr+"'"        +CRLF
                    cQuery += "   AND SA1.D_E_L_E_T_ = ' '"                     +CRLF
                    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
                    If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
                        cCodiOk := (cAlias)->A1_COD
                        cLojaOk := (cAlias)->A1_LOJA
                    EndIf
                    (cAlias)->(dbCloseArea())
                    RestArea(aAreaAnt)
                EndIf
            EndIf
            //->> Marcelo Celi - 03/06/2022 - Fim

            SA1->(dbSetOrder(1))
            If Empty(cCodiOk) .Or. (!Empty(cCodiOk) .And. !SA1->(dbSeek(xFilial("SA1")+cCodiOk+cLojaOk)))            
                SA1->(dbSetOrder(3))
                If SA1->(dbSeek(xFilial("SA1")+cCgc))
                    cCodigo := SA1->A1_COD
                    cLoja   := SA1->A1_LOJA
                    
                    SA1->(dbSetOrder(1))
                    Do While SA1->(dbSeek(xFilial("SA1")+cCodigo+cLoja))
                        cLoja := Soma1(cLoja)                        
                    EndDo
                Else                
                    cCodigo     := GetSXENum("SA1","A1_COD")
                    cLoja       := "01" 
                EndIf    
                cUF         := Upper(Alltrim(aDadPgto[11]))
                cMunicipio  := Upper(Alltrim(aDadPgto[10]))

                SA1->(dbSetOrder(1))
                Do While SA1->(dbSeek(xFilial("SA1")+cCodigo+cLoja))
                    ConfirmSX8()
                    cCodigo := GetSXENum("SA1","A1_COD")
                EndDo

                CC2->(dbSetOrder(4))
                If CC2->(dbSeek(xFilial("CC2")+cUF+cMunicipio))
                    cCodMunic := CC2->CC2_CODMUN
                Else
                    cCodMunic := ""
                EndIf

                SYA->(dbSetOrder(2))
                If SYA->(dbSeek(xFilial("SYA")+aDadPgto[12]))
                    cPais := SYA->YA_CODGI
                Else
                    cPais := ""
                EndIf            

                Reclock("SA1",.T.)
                SA1->A1_COD     := cCodigo
                SA1->A1_LOJA    := cLoja
                SA1->A1_NOME    := cNomeCli
                SA1->A1_NREDUZ  := cNomeCli
                SA1->A1_PESSOA  := cTpCliente
                SA1->A1_CGC     := cCgc
                SA1->A1_TIPO    := "F"
                SA1->A1_RECCOFI := "N"
                SA1->A1_RECCSLL := "N"
                SA1->A1_RECPIS  := "N"
                SA1->A1_MSBLQL  := "2"
                SA1->A1_INSCR   := Alltrim(cInscEst)
                SA1->A1_INSCRM  := Alltrim(cInscMun)
                SA1->A1_CONTA   := (Tb_Ecomm)->&(Tb_Ecomm+"_CTAPAD")
                SA1->A1_COND    := (Tb_Ecomm)->&(Tb_Ecomm+"_CNDPAD")
                SA1->A1_GRPTRIB := ""
                SA1->A1_NATUREZ := (Tb_Ecomm)->&(Tb_Ecomm+"_NATPAD")                    
                SA1->A1_END     := Alltrim(aDadPgto[03])+", "+Alltrim(aDadPgto[04])
                SA1->A1_COMPLEM := Alltrim(aDadPgto[06])
                SA1->A1_CEP     := Alltrim(aDadPgto[05])
                SA1->A1_EST     := cUF
                SA1->A1_COD_MUN := cCodMunic
                SA1->A1_MUN     := cMunicipio
                SA1->A1_BAIRRO  := Alltrim(aDadPgto[09])                
                SA1->A1_DDD     := Alltrim(aDadPgto[13])
                SA1->A1_TEL     := Alltrim(aDadPgto[14])
                SA1->A1_FAX     := Alltrim(aDadPgto[16])
                SA1->A1_PAIS    := ""
                SA1->A1_CONTATO := Alltrim(aDadPgto[01])            
                SA1->A1_CODPAIS := cPais
                SA1->A1_EMAIL   := Alltrim(aDadPgto[17])

                //->> Marcelo Celi - 17/03/2022
                If SA1->A1_PESSOA == "F"
                    SA1->A1_CONTRIB := "2"
                Else
                    SA1->A1_CONTRIB := "1"
                EndIf

                //->> Marcelo Celi - 17/03/2022
                SA1->A1_XIDVTEX := cIdCliEntr
                SA1->A1_XNUMRES := cIdCepEntr

                SA1->(MsUnlock())

                cCodigo := SA1->A1_COD
                cLoja   := SA1->A1_LOJA
                lGravou := .T.
            Else
                SA1->(dbSetOrder(1))
                SA1->(dbSeek(xFilial("SA1")+cCodiOk+cLojaOk))
                cCodigo := SA1->A1_COD
                cLoja   := SA1->A1_LOJA
                lGravou := .F.
            EndIf
        EndIf
    Else
        lRet := .F.
    EndIf
Else
    lRet := .F.
EndIf

SA1->(RestArea(aAreaSA1))
RestArea(aArea)

Return lRet

/*/{protheus.doc} GetRateiVlr
*******************************************************************************************
Retorna o percentual do rateio do valor do codigo do produto em relação ao sku.
Normalmente usando para skus de kits.

@author: Marcelo Celi Marques
@since: 13/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetRateiVlr(cSKU,cCodProd,cEcommerce,cTabela)
Local nPercent  := 0
Local nVlrSku   := 0
Local nVlrProd  := 0
Local aArea     := GetArea()
Local aAreaEstr := (Tb_Estru)->(GetArea())
Local aAreaProd := (Tb_Produ)->(GetArea())

If DA1->(dbSeek(xFilial("DA1")+PadR(cTabela,Tamsx3("DA0_CODTAB")[01])+cCodProd))
    nVlrSku  := u_MaGetVlrEc(cSKU,cEcommerce,NIL,DA1->DA1_CODTAB,NIL)
    DA1->(dbSeek(xFilial("DA1")+PadR(cTabela,Tamsx3("DA0_CODTAB")[01])+cCodProd))
    nVlrProd := DA1->DA1_PRCVEN
    nPercent := Round((nVlrProd / nVlrSku) * 100,5)
EndIf

(Tb_Produ)->(RestArea(aAreaProd))
(Tb_Estru)->(RestArea(aAreaEstr))
RestArea(aArea)

Return nPercent

/*/{protheus.doc} MaEcNFGet
*******************************************************************************************
Extrai os dados de nota fiscal

@author: Marcelo Celi Marques
@since: 28/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcNFGet(cOrcamento,cTbEcomm,Ecommerce)
Local aNota     := {}
Local aPedido   := {}
Local nX        := 1
Local nPos      := 1
Local lNFe      := Posicione(cTbEcomm,1,xFilial(cTbEcomm)+Ecommerce,cTbEcomm+"_TRFSTA")=="1"
Local cLink     := ""

SCK->(dbSetOrder(1))
SCK->(dbSeek(xFilial("SCK")+cOrcamento))
Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == xFilial("SCK")+cOrcamento
    If !Empty(SCK->CK_NUMPV) .And. Ascan(aPedido,{|x| x[01]==SCK->CK_NUMPV})==0
        SCJ->(dbSetOrder(1))
        If SCJ->(dbSeek(xFilial("SCJ")+SCK->CK_NUM))
            aAdd(aPedido,{SCK->CK_NUMPV,SCJ->CJ_XIDENTR})
        EndIf
    EndIf
    SCK->(dbSkip())
EndDo

For nX:=1 to Len(aPedido)
    If !Empty(aPedido[nX,01])
        SD2->(dbSetOrder(8))
        SD2->(dbSeek(xFilial("SD2")+aPedido[nX,01]))
        Do While SD2->(!Eof()) .And. SD2->(D2_FILIAL+D2_PEDIDO) == xFilial("SD2")+aPedido[nX,01]
            nPos := Ascan(aNota,{|x| x[1]+x[2] == SD2->(D2_DOC+D2_SERIE)})
            If nPos == 0
                SF2->(dbSetOrder(1))
                If SF2->(dbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE)))
                    If !lNFe .Or. (lNFe .And. !Empty(SF2->F2_CHVNFE))                        
                        If !Empty(SF2->F2_CHVNFE)
                            cLink := "http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe="+Alltrim(SF2->F2_CHVNFE)
                        Else
                            cLink := ""
                        EndIf

                        aAdd(aNota,{SD2->D2_DOC,                  ; // 01 - Documento
                                    SD2->D2_SERIE,                ; // 02 - Serie
                                    SF2->F2_EMISSAO,              ; // 03 - Data de Emissao
                                    SF2->F2_VALBRUT,              ; // 04 - Valor da Nota
                                    {},                           ; // 05 - Itens da Nota
                                    SF2->F2_CHVNFE,               ; // 06 - Chave da Nota Fiscal
                                    cLink,                        ; // 07 - Link da Nota Fiscal
                                    aPedido[nX,02]}               ) // 08 - Id da Entrega
                        
                        nPos := Len(aNota)
                    Else
                        nPos := 0
                    EndIf
                EndIf
            EndIf
            If nPos > 0
              //aNota[nPos,04] += SD2->D2_TOTAL
                aAdd(aNota[nPos,05],{SD2->D2_COD,   ; // 01 - Codigo do Produto
                                    SD2->D2_PRCVEN,; // 02 - Preço
                                    SD2->D2_QUANT} ) // 03 - Quantidade
            EndIf
            SD2->(dbSkip())
        EndDo
    EndIf
Next nX

Return aNota

/*/{protheus.doc} MaEcPVGet
*******************************************************************************************
Extrai os dados do Pedido

@author: Marcelo Celi Marques
@since: 28/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcPVGet(cOrcamento)
Local aPedido := {}

SCK->(dbSetOrder(1))
SCK->(dbSeek(xFilial("SCK")+cOrcamento))
Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == xFilial("SCK")+cOrcamento
    If Ascan(aPedido,{|x| x==SCK->CK_NUMPV})==0
        aAdd(aPedido,SCK->CK_NUMPV)
    EndIf
    SCK->(dbSkip())
EndDo

Return aPedido

/*/{protheus.doc} MaEcStGet
*******************************************************************************************
Retorna o array com os status de vendas disponiveis para baixa

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcStGet(cCodEcomm)
Local aStatus   := {}
Local cTbTbSta	:= u_MACDGetTb("STA")

If !Empty(cTbTbSta) .And. AliasInDic(cTbTbSta)
    (cTbTbSta)->(dbSetOrder(1))
    (cTbTbSta)->(dbSeek(xFilial(cTbTbSta)+PadR(cCodEcomm,Tamsx3(cTbTbSta+"_ECOMME")[01])))
    Do While (cTbTbSta)->(!Eof()) .And. (cTbTbSta)->&(cTbTbSta+"_FILIAL") + (cTbTbSta)->&(cTbTbSta+"_ECOMME") == xFilial(cTbTbSta)+PadR(cCodEcomm,Tamsx3(cTbTbSta+"_ECOMME")[01])
        If (cTbTbSta)->&(cTbTbSta+"_DESCE")=="1"
            aAdd(aStatus,Upper(Alltrim((cTbTbSta)->&(cTbTbSta+"_CODIGO"))))
        EndIf
        (cTbTbSta)->(dbSkip())
    EndDo
EndIf

Return aStatus

/*/{protheus.doc} MaEcVouGet
*******************************************************************************************
Retorna o array com os vouchers de desconto de vendas disponiveis para baixa

@author: Marcelo Celi Marques
@since: 18/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEcVouGet(cCodEcomm)
Local aVoucher   := {}
Local cTbTbDsc	:= u_MACDGetTb("DSC")

If !Empty(cTbTbDsc) .And. AliasInDic(cTbTbDsc)
    (cTbTbDsc)->(dbSetOrder(1))
    (cTbTbDsc)->(dbSeek(xFilial(cTbTbDsc)+PadR(cCodEcomm,Tamsx3(cTbTbDsc+"_ECOMME")[01])))
    Do While (cTbTbDsc)->(!Eof()) .And. (cTbTbDsc)->&(cTbTbDsc+"_FILIAL") + (cTbTbDsc)->&(cTbTbDsc+"_ECOMME") == xFilial(cTbTbDsc)+PadR(cCodEcomm,Tamsx3(cTbTbDsc+"_ECOMME")[01])
        If (cTbTbDsc)->&(cTbTbDsc+"_DESCON")=="S"
            aAdd(aVoucher,Upper(Alltrim((cTbTbDsc)->&(cTbTbDsc+"_IDECOM"))))
        EndIf
        (cTbTbDsc)->(dbSkip())
    EndDo
EndIf

Return aVoucher

/*/{protheus.doc} MaPutSX1
*******************************************************************************************
Funcao especifica de criação dos perguntes na SX1

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaPutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5)
Local aArea   := GetArea()
Local aEstrut := {}
Local aSX1    := {}
Local i       := 0
Local j       := 0  

cGrupo := Alltrim(cGrupo)
cGrupo := PadR(cGrupo,10)

cOrdem := Alltrim(cOrdem)
cOrdem := PadR(cOrdem,2)

aEstrut := {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_F3","X1_GRPSXG","X1_PYME","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_DEF05","X1_DEFSPA5","X1_DEFENG5"}
aAdd(aSX1,{cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5})

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
    SX1->(dbSetOrder(1))
    If !dbSeek(aSX1[i,1]+aSX1[i,2])
        RecLock("SX1",.T.)
    Else                  
        RecLock("SX1",.F.)
    EndIf			
    For j:=1 To Len(aSX1[i])
        If FieldPos(aEstrut[j])>0
            FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
        EndIf
    Next j
    dbCommit()
    MsUnLock()
Next i                      
     
RestArea(aArea)

Return

/*/{protheus.doc} GetCondPgto
*******************************************************************************************
Retorna a condição de pagamento pelo id no pedido

@author: Marcelo Celi Marques
@since: 02/02/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetCondPgto(cOrigem,cIdCondPgto,cTb_CondP)
Local cCond := ""

If !Empty(cOrigem) .And. !Empty(cIdCondPgto) .And. !Empty(cTb_CondP)
    (cTb_CondP)->(dbSetOrder(1))
    If (cTb_CondP)->(dbSeek(xFilial(cTb_CondP)+PadR(cOrigem,Tamsx3(cTb_CondP+"_ECOMME")[01])+PadR(cIdCondPgto,Tamsx3(cTb_CondP+"_IDECOM")[01])))
        cCond := (cTb_CondP)->&(cTb_CondP+"_CNDPGT")
    EndIf
EndIf

Return cCond

/*/{protheus.doc} GetDocMLivr
*******************************************************************************************
Retorna o Numero da Nota Fiscal do Pedido Mercado Livre no e-commerce vtex

@author: Marcelo Celi Marques
@since: 02/02/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDocMLivr(cIdPedido,cXmlBySite,lJob)
Local aDados := {"","",""}
Local cDocto := ""

aDados      := u_MaGDoc2Vtx(cIdPedido,lJob)
cDocto      := Alltrim(aDados[1])
cXmlBySite  := Alltrim(aDados[4])
If !Empty(cDocto)
    cDocto := Right(Replicate("0",Tamsx3("F2_DOC")[01])+cDocto,Tamsx3("F2_DOC")[01])
EndIf

Return cDocto

