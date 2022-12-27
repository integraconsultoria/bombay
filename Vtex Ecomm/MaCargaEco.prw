#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TBICODE.CH"                                
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "apwizard.ch"

Static Ecommerce:= ""
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
Static Tb_Voucher:=""

Static FilEcomm := ""
Static Armazem  := ""
Static Head_Api := {}
Static Url      := ""

/*/{protheus.doc} MaCargVtex
*******************************************************************************************
Varre os cadastros do Totvs e nas apis em busca de dados para alinhar com o ecommerce vtex

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaCargVtex()
Local cEmp      := "01"
Local cFil      := "0101"
Local aDados    := {}
Local cId       := ""
Local cDtAtualz := ""
Local cProduto  := ""

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

If u_MaEcIniVar(.T.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    Ecommerce:= "VTEX" 
    u_MaSetFilEC(Tb_Ecomm,Ecommerce)
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01]))) .And. (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"    
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")))
        Do While SB1->(!Eof()) .And. SB1->B1_FILIAL == xFilial("SB1")            
            cProduto := Alltrim(SB1->B1_COD)
            aDados := u_MaVTXDPrd(cProduto,"/api/catalog/pvt/stockkeepingunit?refId=")
            If Len(aDados)>0
                //->> Resgata o Id do produto
                cId := aDados[1]
                If Valtype(cId)=="N"
                    cId := Str(cId)
                EndIf
                cId := Alltrim(cId)
                //-> Resgata a ultima data de atualização no site
                If Len(aDados)>=8 .And. Valtype(aDados[8])=="C" .And. !Empty(aDados[8])
                    cDtAtualz := SubStr(aDados[8],9,2)+"/"+SubStr(aDados[8],6,2)+"/"+SubStr(aDados[8],1,4)+"  " + SubStr(aDados[8],12,8)
                Else
                    cDtAtualz := ""
                EndIf

                (Tb_Produ)->(dbSetOrder(1))
                If !(Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+SB1->B1_COD))
                    Reclock(Tb_Produ,.T.)
                    (Tb_Produ)->&(Tb_Produ+"_FILIAL")   := xFilial(Tb_Produ)
                    (Tb_Produ)->&(Tb_Produ+"_SKU")      := SB1->B1_COD
                    (Tb_Produ)->&(Tb_Produ+"_TIPO")     := "P"
                    (Tb_Produ)->&(Tb_Produ+"_DESCRI")   := SB1->B1_DESC
                    (Tb_Produ)->&(Tb_Produ+"_DSCRES")   := SB1->B1_DESC
                    (Tb_Produ)->&(Tb_Produ+"_COMPRI")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_LARGUR")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_ALTURA")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_PESO")     := 0
                    (Tb_Produ)->&(Tb_Produ+"_DEPART")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_CATEGO")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_MARCA")    := ""
                    (Tb_Produ)->&(Tb_Produ+"_FABRIC")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_EAN13")    := SB1->B1_CODBAR
                    (Tb_Produ)->&(Tb_Produ+"_NCM")      := SB1->B1_POSIPI
                    (Tb_Produ)->&(Tb_Produ+"_ATUSIT")   := "2"
                    (Tb_Produ)->&(Tb_Produ+"_MSBLQL")   := If(SB1->B1_MSBLQL <> "1","2","1")
                    (Tb_Produ)->&(Tb_Produ+"_OBSERV")   := ""                    
                    (Tb_Produ)->(MsUnlock())
                EndIf

                (Tb_Estru)->(dbSetOrder(1))
                If !(Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+SB1->B1_COD))
                    Reclock(Tb_Estru,.T.)
                    (Tb_Estru)->&(Tb_Estru+"_FILIAL")   := xFilial(Tb_Estru)
                    (Tb_Estru)->&(Tb_Estru+"_SKU")      := SB1->B1_COD
                    (Tb_Estru)->&(Tb_Estru+"_COD")      := SB1->B1_COD
                    (Tb_Estru)->&(Tb_Estru+"_DESCRI")   := SB1->B1_DESC
                    (Tb_Estru)->&(Tb_Estru+"_QTDE")     := 1
                    (Tb_Estru)->(MsUnlock())
                EndIf

                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+SB1->B1_COD))
                    Reclock(Tb_IDS,.T.)
                    (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                    (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                    (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                    (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := SB1->B1_COD
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                    (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                    (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                    (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                    (Tb_IDS)->(MsUnlock())
                EndIf
            EndIf            
            SB1->(dbSkip())
        EndDo
    EndIf
EndIf

RESET ENVIRONMENT

Return

/*/{protheus.doc} MaCargPlug
*******************************************************************************************
Varre os cadastros do Totvs e nas apis em busca de dados para alinhar com o ecommerce pluggto

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaCargPlug()
Local cEmp      := "02"
Local cFil      := "0101"
Local aDados    := {}
Local cId       := ""
Local cDtAtualz := ""

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

If u_MaEcIniVar(.T.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    Ecommerce:= "PLUGGTO" 
    u_MaSetFilEC(Tb_Ecomm,Ecommerce)
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01]))) .And. (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"    
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")))
        Do While SB1->(!Eof()) .And. SB1->B1_FILIAL == xFilial("SB1")            
            aDados := u_MaPLUDPrd(Alltrim(SB1->B1_COD))
            If Len(aDados)>0
                //->> Resgata o Id do produto
                cId := aDados[1]
                If Valtype(cId)=="N"
                    cId := Str(cId)
                EndIf
                cId := Alltrim(cId)
                //-> Resgata a ultima data de atualização no site
                If Len(aDados)>=8 .And. Valtype(aDados[8])=="C" .And. !Empty(aDados[8])
                    cDtAtualz := SubStr(aDados[8],9,2)+"/"+SubStr(aDados[8],6,2)+"/"+SubStr(aDados[8],1,4)+"  " + SubStr(aDados[8],12,8)
                Else
                    cDtAtualz := ""
                EndIf

                (Tb_Produ)->(dbSetOrder(1))
                If !(Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+SB1->B1_COD))
                    Reclock(Tb_Produ,.T.)
                    (Tb_Produ)->&(Tb_Produ+"_FILIAL")   := xFilial(Tb_Produ)
                    (Tb_Produ)->&(Tb_Produ+"_SKU")      := SB1->B1_COD
                    (Tb_Produ)->&(Tb_Produ+"_TIPO")     := "P"
                    (Tb_Produ)->&(Tb_Produ+"_DESCRI")   := SB1->B1_DESC
                    (Tb_Produ)->&(Tb_Produ+"_DSCRES")   := SB1->B1_DESC
                    (Tb_Produ)->&(Tb_Produ+"_COMPRI")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_LARGUR")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_ALTURA")   := 0
                    (Tb_Produ)->&(Tb_Produ+"_PESO")     := 0
                    (Tb_Produ)->&(Tb_Produ+"_DEPART")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_CATEGO")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_MARCA")    := ""
                    (Tb_Produ)->&(Tb_Produ+"_FABRIC")   := ""
                    (Tb_Produ)->&(Tb_Produ+"_EAN13")    := SB1->B1_CODBAR
                    (Tb_Produ)->&(Tb_Produ+"_NCM")      := SB1->B1_POSIPI
                    (Tb_Produ)->&(Tb_Produ+"_ATUSIT")   := "2"
                    (Tb_Produ)->&(Tb_Produ+"_MSBLQL")   := If(SB1->B1_MSBLQL <> "1","2","1")
                    (Tb_Produ)->&(Tb_Produ+"_OBSERV")   := ""                    
                    (Tb_Produ)->(MsUnlock())
                EndIf

                (Tb_Estru)->(dbSetOrder(1))
                If !(Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+SB1->B1_COD))
                    Reclock(Tb_Estru,.T.)
                    (Tb_Estru)->&(Tb_Estru+"_FILIAL")   := xFilial(Tb_Estru)
                    (Tb_Estru)->&(Tb_Estru+"_SKU")      := SB1->B1_COD
                    (Tb_Estru)->&(Tb_Estru+"_COD")      := SB1->B1_COD
                    (Tb_Estru)->&(Tb_Estru+"_DESCRI")   := SB1->B1_DESC
                    (Tb_Estru)->&(Tb_Estru+"_QTDE")     := 1
                    (Tb_Estru)->(MsUnlock())
                EndIf

                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+SB1->B1_COD))
                    Reclock(Tb_IDS,.T.)
                    (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                    (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                    (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                    (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := SB1->B1_COD
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                    (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                    (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                    (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                    (Tb_IDS)->(MsUnlock())
                EndIf
            EndIf            
            SB1->(dbSkip())
        EndDo
    EndIf
EndIf

RESET ENVIRONMENT

Return

/*/{protheus.doc} MaAtuCarg
*******************************************************************************************
Atualiza cargas de produtos dos dois ecommerces

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaAtuCarg()
MsgRun("Atualizando Carga de Produtos do e-Commerce...",,{ || MaAtuCarg() })
Return

Static Function MaAtuCarg()
u_MaCargVtex()
u_MaCargPlug()
Return








