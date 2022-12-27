#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TBICODE.CH"                                
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "apwizard.ch"

/*/
*******************************************************************************************
Chamadas dos Jobs
(*) Variáveis Obrigatórias. (campos não informados assumirão valores default)

Sobe Produtos:           u_MaPrdVtx(  * cEmp, * cFil,lNovo,cMsgConexao, * cNickName,cProdDe,cProdAte)
Sobe Preço do Produto:   u_MaPrcVtex( * cEmp, * cFil,lNovo,cMsgConexao, * cNickName,cProdDe,cProdAte)
Sobe Estoque do Produto  u_MaEstVtex( * cEmp, * cFil,lNovo,cMsgConexao, * cNickName,cProdDe,cProdAte)
Sobe Status do Pedido:   u_MaStaVtex( * cEmp, * cFil,lNovo,cMsgConexao, * cNickName,cOrcDe,cOrcAte)
Desce Vendas:            u_MaVdaVtex( * cEmp, * cFil,dDataDe,dDataAte)
Desce Produtos           u_MaBxPrdVtx(* cEmp, * cFil,lNovo,cMsgConexao, * cNickName,cProdDe,cProdAte)

*******************************************************************************************
/*/

Static _cEmp    := "01"
Static _cFil    := "0101"

Static Ecommerce:= "VTEX"
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

/*/{protheus.doc} Inicializar
*******************************************************************************************
Inicializa as variaveis do sistema

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function Inicializar(lJob)
Local lRet      := .F.
Local cApiUser  := ""
Local cApiToken := ""
Local cCodigo   := ""
Local cMsg      := ""

Default lJob := .F.

lRet := u_MaEcIniVar(lJob,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
If lRet
    u_MaSetFilEC(Tb_Ecomm,Ecommerce)
    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))
        Ecommerce := cCodigo
        Url       := Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_URL"))
        cApiUser  := Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_USER"))
        cApiToken := Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_TOKEN"))
        Armazem   := (Tb_Ecomm)->&(Tb_Ecomm+"_LOCAL")

        If !Empty(Url)
            lRet := .T.
            Head_Api := {}
            aAdd(Head_Api,"Accept: application/json"       )
            aAdd(Head_Api,"Content-Type: application/json" )
            aAdd(Head_Api,"X-VTEX-API-AppKey: "  +cApiUser )
            aAdd(Head_Api,"X-VTEX-API-AppToken: "+cApiToken)
        Else
            lRet := .F.
            Head_Api := {}
            Url := ""            
        EndIf
    Else
        lRet := .F.
        Head_Api := {}
        Url := ""        
    EndIf
    If !lRet
        cMsg := "Rotina não disponível devido a mesma não estar configurada."           +CRLF
        cMsg += "Favor entrar em contato com o Departamento de TI."
        If lJob
            Connout(cMsg)
        Else
            MsgAlert(cMsg)
        EndIf
    EndIf
Else
    lRet := .F.
    Head_Api := {}
    Url := ""    
EndIf

Return lRet

/*/{protheus.doc} ExecutConex
*******************************************************************************************
Executa a conexão com o webservice do ecommerce

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ExecutConex(cTipo,cEndPoint,cRequest,oResponse,nTimeOut,cRetApi,lJob,cUrl,lDeserializ)
Local lRet      := .F.
Local cResponse := ""
Local oEcommerce:= NIL
Local nCodeRet  := 0

Default cTipo       := ""
Default cEndPoint   := ""
Default cRequest    := ""
Default nTimeOut    := 140
Default lJob        := .F.
Default cUrl        := ""
Default lDeserializ := .T.

If !Empty(cUrl)
    oEcommerce := FWRest():New(cUrl)
Else
    oEcommerce := FWRest():New(Url)
EndIf
oEcommerce:nTimeout := nTimeOut
oEcommerce:SetPath(cEndPoint)

cRetApi := ""
cTipo   := Alltrim(Upper(cTipo))
Do Case
    Case cTipo == "POST"
        oEcommerce:SetPostParams(cRequest) 
        If oEcommerce:Post(Head_Api)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := Val(oEcommerce:GetHTTPCode())
        cResponse := oEcommerce:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse        
        If !lRet
            cRetApi += CRLF+CRLF+oEcommerce:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Case cTipo == "GET"
        If oEcommerce:Get(Head_Api)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := Val(oEcommerce:GetHTTPCode())
        cResponse := oEcommerce:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse
        If !lRet
            cRetApi += CRLF+CRLF+oEcommerce:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Case cTipo == "PUT"
        If oEcommerce:Put(Head_Api,cRequest)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := Val(oEcommerce:GetHTTPCode())
        cResponse := oEcommerce:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse
        If !lRet
            cRetApi += CRLF+CRLF+oEcommerce:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Otherwise
        lRet := .F.
        oResponse := NIL

EndCase

FreeObj(oEcommerce)
If (nCodeRet >= 200 .And. nCodeRet <= 299) .Or. (Upper(Alltrim(cResponse)) == "TRUE")
    lRet := .T.
Else    
    If lDeserializ .And. Valtype(oResponse) <> "O"
        lRet := .F.
    EndIf
EndIf

Return lRet


/*/{protheus.doc} SobeProduto
*******************************************************************************************
Inicializa as variaveis do sistema

Create Product
Creates a new Product from scratch

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SobeProduto(cSKU,cReq2Api,cRet2Api,lJob,aDadAlter,oRespApi)
Local lRet        := .F.
Local cEndPoint   := ""
Local cRequest    := ""
Local cDtLancam   := ""
Local dData       := Date()
Local nTimeOut    := 0
Local aProdInSite := {}
Local aSKUInSite  := {}
Local oResponse   := NIL
Local cRetApi     := ""
//->> Variaveis do produto
Local nIdProd     := 0  
Local nIdCateg    := 0
Local nIdMarca    := 0
Local nIdDepart   := 0
Local nIdFornec   := 0
Local cLinkId     := ""
Local cKeyWords   := ""
Local cTaxCode    := ""
Local cMetaDescr  := ""
Local nScore      := 0
Local cAtivo      := ""
Local cVisu       := ""
Local cShowEstoq  := ""
// Variaveis do SKU
Local nIdSku      := 0  
Local cIsActive   := ""
Local cName       := ""
Local cRefId      := ""
Local nPckagHeig  := 0
Local nPckagLeng  := 0
Local nPckagWidt  := 0
Local nPckagKgWe  := 0
Local nHeight     := 0
Local nLength     := 0
Local nWidth      := 0
Local nWeightKg   := 0
Local nCubicWeight:= 0
Local cIsKit      := ""
Local cCreationDat:= ""
Local nRewardValue:= 0
Local cEstimaDtArr:= ""
Local cManufCode  := ""
Local nCommeCondId:= 0
Local cMeasurUnit := ""
Local nUnitMultipl:= 0
Local cModalType  := 0
Local cKitItSellAp:= ""
Local cCodigo     := ""  
Local cDescription:= "" 

Local cRespProd   := ""

Default lJob := .F.

aDadAlter := {}
oRespApi  := NIL
cReq2Api  := ""
cRet2Api  := ""

If Inicializar(lJob)
    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
    (Tb_Conex)->(dbSetOrder(1))
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo)) .And. (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"UPR")) //->> Inclusão/Alteração de Produto
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        If !Empty(cEndPoint)
            cSKU := PadR(cSKU,Tamsx3(Tb_Produ+"_SKU")[01])
            If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+cSKU))
                //->> Verifica se produto ja existe no site
                aProdInSite := GetProduto(cSku,lJob)
                If Len(aProdInSite)==0
                    nIdProd   := 0
                    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
                    (Tb_Ecomm)->(dbSetOrder(1))
                    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))                    
                        nIdDepart := Val((Tb_Ecomm)->&(Tb_Ecomm+"_IDDEP"))
                        nIdCateg  := Val((Tb_Ecomm)->&(Tb_Ecomm+"_IDCAT"))
                        nIdMarca  := Val((Tb_Ecomm)->&(Tb_Ecomm+"_IDMAR"))
                        nIdFornec := Val((Tb_Ecomm)->&(Tb_Ecomm+"_IDFOR"))
                    Else
                        nIdDepart := 0
                        nIdCateg  := 0
                        nIdMarca  := 0
                        nIdFornec := 0
                    EndIf    
                    cDtLancam := StrZero(Year(dData),4)+"-"+StrZero(Month(dData),2)+"-"+StrZero(Day(dData),2)+"T00:00:00"
                    cLinkId   := Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU")) //"insert-product-default"
                    cKeyWords := "default"
                    cTaxCode  := (Tb_Produ)->&(Tb_Produ+"_NCM") //"default"
                    cMetaDescr:= "tag default"
                    nScore    := 1
                    cVisu     := "false"  //"true"
                    cShowEstoq:= "true"
                    
                    //->> Marcelo Celi - 11/03/2022
                    cDescription := Alltrim((Tb_Produ)->&(Tb_Produ+"_DSCRES"))                    
                Else
                    nIdProd     := aProdInSite[01]
                    nIdDepart   := aProdInSite[04]
                    nIdCateg    := aProdInSite[05]
                    nIdMarca    := aProdInSite[06]
                    nIdFornec   := aProdInSite[07]
                    cDtLancam   := aProdInSite[08]
                    cLinkId     := aProdInSite[09]
                    cKeyWords   := aProdInSite[10]
                    cTaxCode    := aProdInSite[11]
                    cMetaDescr  := aProdInSite[12]
                    nScore      := aProdInSite[13]
                    cVisu       := aProdInSite[14]
                    cShowEstoq  := aProdInSite[15]
                    
                    //->> Marcelo Celi - 11/03/2022
                    cDescription:= aProdInSite[16]

                    aAdd(aDadAlter,nIdProd)
                    aAdd(aDadAlter,cDtLancam)
                    aAdd(aDadAlter,cDtLancam)                    
                EndIf

                If (Tb_Produ)->&(Tb_Produ+"_MSBLQL")<>"1"
                    cAtivo := "true"
                Else
                    cAtivo := "false"
                EndIf                
                
                cRequest := '{'                                                                         +CRLF
                cRequest += '   "Name": "'+Alltrim((Tb_Produ)->&(Tb_Produ+"_DESCRI"))+'",'              +CRLF // Product Name (string)
                cRequest += '   "DepartmentId": '+Alltrim(Str(nIdDepart))+','                           +CRLF // AProduct Department ID (int32)
                cRequest += '   "CategoryId": '+Alltrim(Str(nIdCateg))+','                              +CRLF // Product Category ID (int32)
                cRequest += '   "BrandId": '+Alltrim(Str(nIdMarca))+','                                 +CRLF // Product Brand ID (int32)
                cRequest += '   "LinkId": "'+cLinkId+'",'                                               +CRLF // Text Link (string)
                cRequest += '   "RefId": "'+Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU"))+'",'                +CRLF // Product Referecial Code (string)
                cRequest += '   "IsVisible": '+cVisu+','                                                +CRLF // If the Product is visible on the store (boolean)
                
                //->> Marcelo Celi - 11/03/2022
                //cRequest += '   "Description": "'+Alltrim((Tb_Produ)->&(Tb_Produ+"_DESCRI"))+'",'       +CRLF // Product Description (string)
                //cRequest += '   "DescriptionShort": "'+Alltrim((Tb_Produ)->&(Tb_Produ+"_DSCRES"))+'",'  +CRLF // Complement Name (string)
                
                cRequest += '   "Description": "'+cDescription+'",'                                     +CRLF // Product Description (string)
                cRequest += '   "DescriptionShort": " ",'                                               +CRLF // Complement Name (string)
                
                cRequest += '   "ReleaseDate": "'+cDtLancam+'",'                                        +CRLF // Product Release Date (string  YYYY-MM-DDTHH:MM:SS)
                cRequest += '   "KeyWords": "'+cKeyWords+'",'                                           +CRLF // Substitutes words for the Product (string)
                cRequest += '   "Title": "'+Alltrim((Tb_Produ)->&(Tb_Produ+"_DESCRI"))+'",'             +CRLF // Tag Title (string)
                cRequest += '   "IsActive": '+cAtivo+','                                                +CRLF // If the Product is active or not (boolean)
                cRequest += '   "TaxCode": "'+cTaxCode+'",'                                             +CRLF // Product Fiscal Code (string)
                cRequest += '   "MetaTagDescription": "'+cMetaDescr+'",'                                +CRLF // Meta Tag Description (string)
                cRequest += '   "SupplierId": '+Alltrim(Str(nIdFornec))+','                             +CRLF // Product Supplier ID (int32)
                cRequest += '   "ShowWithoutStock": '+cShowEstoq+','                                    +CRLF // Defines if the Product will remain being shown in the store even if it’s out of stock (boolean)
                cRequest += '   "Score": '+Alltrim(Str(nScore))                                         +CRLF // Value used for Product search ordenation (int32)
                cRequest += '}'                                                                         +CRLF
                
                If Len(aProdInSite)==0
                    lRet := ExecutConex("POST",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                    If lRet
                        nIdProd := oResponse:Id
                    EndIf
                Else
                    cIdPrd := Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU"))                    
                    cEndPoint += "/"+Alltrim(Str(nIdProd))
                    lRet := ExecutConex("PUT",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                EndIf

                cReq2Api += "Requisicao do Produto:"+CRLF+cRequest+CRLF+CRLF
                cRet2Api += "Retorno do Produto"+CRLF+cRetApi+CRLF+CRLF
                oRespApi := oResponse
                cRespProd:= cRetApi

                //->> Sobe/Atualiza o SKU no site                
                If lRet .Or. Len(aProdInSite) > 0
                    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"USK")) //->> Inclusão/Alteração de Produto
                        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
                        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
                        If Len(cEndPoint)>1
                            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
                            EndIf
                        EndIf
                        If !Empty(cEndPoint)
                            aSKUInSite := GetSKU(Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU")),lJob)
                            If Len(aSKUInSite)==0
                                cIsActive   := "false"
                                cName       := Alltrim((Tb_Produ)->&(Tb_Produ+"_DESCRI"))
                                cRefId      := Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU"))
                                nPckagHeig  := (Tb_Produ)->&(Tb_Produ+"_ALTURA")
                                nPckagLeng  := (Tb_Produ)->&(Tb_Produ+"_COMPRI")
                                nPckagWidt  := (Tb_Produ)->&(Tb_Produ+"_LARGUR")
                                nPckagKgWe  := (Tb_Produ)->&(Tb_Produ+"_PESO")
                                nHeight     := (Tb_Produ)->&(Tb_Produ+"_ALTURA")
                                nLength     := (Tb_Produ)->&(Tb_Produ+"_COMPRI")
                                nWidth      := (Tb_Produ)->&(Tb_Produ+"_LARGUR")
                                nWeightKg   := (Tb_Produ)->&(Tb_Produ+"_PESO")
                                nCubicWeight:= 0
                                cIsKit      := "false"
                                cCreationDat:= StrZero(Year(dData),4)+"-"+StrZero(Month(dData),2)+"-"+StrZero(Day(dData),2)+"T00:00:00"
                                nRewardValue:= 0
                                cEstimaDtArr:= ""
                                cManufCode  := ""
                                nCommeCondId:= 1
                                cMeasurUnit := "un"
                                nUnitMultipl:= 1
                                cModalType  := ""
                                cKitItSellAp:= "false"
                                nIdSku      := 0
                            Else
                                cIsActive   := aSKUInSite[02]
                                cName       := aSKUInSite[03]
                                cRefId      := aSKUInSite[04]
                                nPckagHeig  := aSKUInSite[05]
                                nPckagLeng  := aSKUInSite[06]
                                nPckagWidt  := aSKUInSite[07]
                                nPckagKgWe  := aSKUInSite[08]
                                nHeight     := aSKUInSite[09]
                                nLength     := aSKUInSite[10]
                                nWidth      := aSKUInSite[11]
                                nWeightKg   := aSKUInSite[12]
                                nCubicWeight:= aSKUInSite[13]
                                cIsKit      := aSKUInSite[14]
                                cCreationDat:= aSKUInSite[15]
                                nRewardValue:= aSKUInSite[16]
                                cEstimaDtArr:= aSKUInSite[17]
                                cManufCode  := aSKUInSite[18]
                                nCommeCondId:= aSKUInSite[19]
                                cMeasurUnit := aSKUInSite[20]
                                nUnitMultipl:= aSKUInSite[21]
                                cModalType  := aSKUInSite[22]
                                cKitItSellAp:= aSKUInSite[23]
                                nIdSku      := aSKUInSite[25]
                            EndIf

                            cRequest := '{'                                                                                                   +CRLF
                            cRequest += '   "ProductId": '+Alltrim(Str(nIdProd))                                                        +','  +CRLF
                            cRequest += '   "IsActive": '+cIsActive                                                                     +','  +CRLF
                            cRequest += '   "Name": '                   +If(!Empty(cName)       ,'"'+cName+'"'              ,' null ')  +','  +CRLF
                            cRequest += '   "RefId" : '                 +If(!Empty(cRefId)      ,'"'+cRefId+'"'             ,' null ')  +','  +CRLF
                            cRequest += '   "PackagedHeight": '         +If(!Empty(nPckagHeig)  ,Alltrim(Str(nPckagHeig))   ,' null ')  +','  +CRLF                    
                            cRequest += '   "PackagedLength": '         +If(!Empty(nPckagLeng)  ,Alltrim(Str(nPckagLeng))   ,' null ')  +','  +CRLF                    
                            cRequest += '   "PackagedWidth": '          +If(!Empty(nPckagWidt)  ,Alltrim(Str(nPckagWidt))   ,' null ')  +','  +CRLF
                            cRequest += '   "PackagedWeightKg": '       +If(!Empty(nPckagKgWe)  ,Alltrim(Str(nPckagKgWe))   ,' null ')  +','  +CRLF
                            cRequest += '   "Height": '                 +If(!Empty(nHeight)     ,Alltrim(Str(nHeight))      ,' null ')  +','  +CRLF
                            cRequest += '   "Length": '                 +If(!Empty(nLength)     ,Alltrim(Str(nLength))      ,' null ')  +','  +CRLF
                            cRequest += '   "Width": '                  +If(!Empty(nWidth)      ,Alltrim(Str(nWidth))       ,' null ')  +','  +CRLF
                            cRequest += '   "WeightKg": '               +If(!Empty(nWeightKg)   ,Alltrim(Str(nWeightKg))    ,' null ')  +','  +CRLF                            
                            cRequest += '   "MeasurementUnit": '        +If(!Empty(cMeasurUnit) ,'"'+cMeasurUnit+'"'        ,' null ')        +CRLF                            
                            cRequest += '}'                                                                                                   +CRLF

                            If Len(aSKUInSite)==0
                                lRet := ExecutConex("POST",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                                If lRet
                                    nIdSku := oResponse:Id
                                EndIf
                            Else
                                cEndPoint += "/"+Alltrim(Str(nIdSku))
                                lRet := ExecutConex("PUT",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                            EndIf

                            cReq2Api += "Requisicao do SKU:"+CRLF+cRequest+CRLF+CRLF
                            cRet2Api += "Retorno do SKU"+CRLF+cRetApi+CRLF+CRLF

                        Else
                            lRet := .F.
                        EndIf
                    Else
                        lRet := .F.
                    EndIf
                EndIf
            Else
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

If !Empty(cRespProd)
    FWJsonDeserialize(cRespProd,@oRespApi)    
EndIf

Return lRet

/*/{protheus.doc} GetProduto
*******************************************************************************************
Busca o produto pelo codigo do produto no ecommerce

Get Product by RefId
Retrieves a specific product by its Reference ID.

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetProduto(cSku,lJob,cEndPAuxil)
Local aRet      := {}
Local cEndPoint := ""
Local nTimeOut  := 0
Local cRetApi   := ""
Local lEPStockRf:= .F.

Private oRespProd := NIL

Default lJob := .F.
Default cEndPAuxil := ""

If Inicializar(lJob)
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GPR")) //->> Retorno de Produto
        If !Empty(cEndPAuxil)
            cEndPoint := cEndPAuxil
        Else
            cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        EndIf            
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        If !Empty(cEndPoint)
            If Right(cEndPoint,1)<>"="
                cEndPoint += "/"+Alltrim(cSku)
                lEPStockRf := .F.
            Else
                cEndPoint += Alltrim(cSku)
                lEPStockRf := .T.
            EndIf    
            If ExecutConex("GET",cEndPoint,"",@oRespProd,nTimeOut,@cRetApi,lJob)
                If Valtype(oRespProd)<>"U"                
                    aAdd(aRet,If(!lEPStockRf,oRespProd:Id,oRespProd:ProductId))                                                         // 01 - ID of the Product (integer)
                    aAdd(aRet,oRespProd:RefId)                                                                                          // 02 - Product Reference ID (string)
                    aAdd(aRet,Alltrim(Upper(DecodeUtf8(oRespProd:Name))))                                                               // 03 - Name of the Product (string)
                    aAdd(aRet,If(Type("oRespProd:DepartmentId")<>"U"        ,oRespProd:DepartmentId      ,""))                          // 04 - ID of product department (integer)
                    aAdd(aRet,If(Type("oRespProd:CategoryId")<>"U"          ,oRespProd:CategoryId        ,""))                          // 05 - ID of product Category (integer)
                    aAdd(aRet,If(Type("oRespProd:BrandId")<>"U"             ,oRespProd:BrandId           ,""))                          // 06 - ID of the product Brand (integer)
                    aAdd(aRet,If(Type("oRespProd:SupplierId")<>"U"          ,oRespProd:SupplierId        ,""))                          // 07 - Product Supplier ID (integer)
                    aAdd(aRet,If(Type("oRespProd:ReleaseDate")<>"U"         ,oRespProd:ReleaseDate       ,""))                          // 08 - Product Release Date, for list ordering and product cluster highlight (string)
                    aAdd(aRet,If(Type("oRespProd:LinkId")<>"U"              ,oRespProd:LinkId            ,""))                          // 09 - Category URL (string)
                    aAdd(aRet,If(Type("oRespProd:KeyWords")<>"U"            ,oRespProd:KeyWords          ,""))                          // 10 - Alternatives Keywords to improve the product findability (string)
                    aAdd(aRet,If(Type("oRespProd:TaxCode")<>"U"             ,oRespProd:TaxCode           ,""))                          // 11 - SKU Tax Code (string)
                    aAdd(aRet,If(Type("oRespProd:MetaTagDescription")<>"U"  ,oRespProd:MetaTagDescription,""))                          // 12 - Meta Description for the Product page (string)
                    aAdd(aRet,If(Type("oRespProd:Score")<>"U"               ,oRespProd:Score             ,0 ))                          // 13 - Value used for Product search ordenation (integer)
                    aAdd(aRet,If(Type("oRespProd:IsVisible")<>"U"           ,If(oRespProd:IsVisible,"true","false"),"true") )           // 14 - If the Product is visible on the store (string)
                    aAdd(aRet,If(Type("oRespProd:ShowWithoutStock")<>"U"    ,If(oRespProd:ShowWithoutStock,"true","false"),"true"))     // 15 - Defines if the Product will remain being shown in the store even if it’s out of stock (string)
                    aAdd(aRet,If(Type("oRespProd:Id")<>"U"                  ,oRespProd:Id                ,""))                          // 16 - Id SKU
                EndIf
            EndIf
        EndIf
    EndIf
EndIf

Return aRet

/*/{protheus.doc} GetSKU
*******************************************************************************************
Busca o SKU pelo ID do Produto no ecommerce

Get Product by RefId
Retrieves a specific product by its Reference ID.

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetSKU(cCodSKU,lJob)
Local aRet      := {}
Local cEndPoint := ""
Local oResponse := NIL
Local nTimeOut  := 0
Local cRetApi   := ""

Default lJob := .F.

If Inicializar(lJob)
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GSK")) //->> Retorno de sku
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        If !Empty(cEndPoint)
            cEndPoint += "?refId="+cCodSKU
            If ExecutConex("GET",cEndPoint,"",@oResponse,nTimeOut,@cRetApi,lJob)
                aAdd(aRet,oResponse:ProductId)                              // 01 - Product’s unique numerical identifier
                aAdd(aRet,If(oResponse:IsActive,"true","false"))            // 02 - Shows if the SKU is active                
                aAdd(aRet,Alltrim(Upper(DecodeUtf8(oResponse:Name))))       // 03 - SKU Name                
                aAdd(aRet,oResponse:RefId)                                  // 04 - SKU RefId
                aAdd(aRet,oResponse:PackagedHeight)                         // 05 - Packaged Height
                aAdd(aRet,oResponse:PackagedLength)                         // 06 - Packaged Length
                aAdd(aRet,oResponse:PackagedWidth)                          // 07 - Packaged Width
                aAdd(aRet,oResponse:PackagedWeightKg)                       // 08 - Packaged Weight in Kilos
                aAdd(aRet,oResponse:Height)                                 // 09 - SKU Height
                aAdd(aRet,oResponse:Length)                                 // 10 - SKU Length
                aAdd(aRet,oResponse:Width)                                  // 11 - SKU Width
                aAdd(aRet,oResponse:WeightKg)                               // 12 - SKU Weight in Kilos
                aAdd(aRet,oResponse:CubicWeight)                            // 13 - Cubic Weight                
                aAdd(aRet,If(oResponse:IsKit,"true","false"))               // 14 - Shows if the SKU is a Kit
                aAdd(aRet,oResponse:CreationDate)                           // 15 - SKU Creation Date
                aAdd(aRet,oResponse:RewardValue)                            // 16 - How much the client will get rewarded by buying the SKU
                aAdd(aRet,oResponse:EstimatedDateArrival)                   // 17 - SKU Estimated Date Arrival
                aAdd(aRet,oResponse:ManufacturerCode)                       // 18 - Manufacturer Code
                aAdd(aRet,oResponse:CommercialConditionId)                  // 19 - Commercial Condition ID
                aAdd(aRet,oResponse:MeasurementUnit)                        // 20 - Measurement Unit
                aAdd(aRet,oResponse:UnitMultiplier)                         // 21 - Cubic Weight
                aAdd(aRet,oResponse:ModalType)                              // 22 - Defines deliver model
                aAdd(aRet,If(oResponse:KitItensSellApart,"true","false"))   // 23 - Multiplies the amount of SKUs inserted on the cart
                aAdd(aRet,If(oResponse:ActivateIfPossible,"true","false"))  // 24 - When set to true, this attribute will automatically update the SKU as active once associated with an image or an active component
                aAdd(aRet,oResponse:Id)                                     // 25 - SKU ID
            EndIf
        EndIf
    EndIf
EndIf

Return aRet

/*/{protheus.doc} MaPrd2Vtex
*******************************************************************************************
Envia os produtos para o vtex

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaPrd2Vtex()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "produto.png"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}

Private aRet01Param := {}

If Inicializar()
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, .T.	                                )

    aAdd( aBox01Param,{1,"Produto de"	,aRet01Param[01] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Produto ate"	,aRet01Param[02] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    AADD( aBox01Param,{5,"Somente Produtos Pendentes de Envio?",aRet01Param[03],150,".T.",.F.})  

    oWizard := APWizard():New("Cargas no VTex",                                  									                    ;   // chTitle  - Titulo do cabecalho
                                "Informe as propriedades de subida de carga ao e-Commerce",                                             ;   // chMsg    - Mensagem do cabecalho
                                "Carga de Produtos",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                {|| lOk := MsgYesNo("Confirma a subida de carga de produtos ?"), lOk },                                 ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk := MsgYesNo("Confirma a subida de carga de produtos ?"), lOk },                                 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:OFINISH:CTITLE 	 := "&Enviar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        Processa( {|| u_MaPrdVtx(NIL,NIL,aRet01Param[03],NIL,NIL,aRet01Param[01],aRet01Param[02]) },"Aguarde" ,"Subindo Produtos no VTEX...")
    EndIf
EndIf

Return

/*/{protheus.doc} MaPrdVtx
*******************************************************************************************
Atualiza o cadastro de produtos com os dados no vtex

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPrdVtx(cEmp,cFil,lNovo,cMsgConexao,cNickName,cProdDe,cProdAte)
Local cConex    := "ECVTEXSPRD"
Local lJob      := .F.
Local aArea     := {}
Local cQuery    := ""
Local cAlias    := ""
Local nTotRegs  := 0
Local lUsarRot  := .T.
Local nTimer    := 0
Local _cFilAnt  := ""
Local nRecRegist:= 0
Local cReq2Api  := ""
Local cRet2Api  := ""
Local cIdProd   := ""
Local cDtCad    := ""
Local cDtAtu    := ""
Local cDtAtualz := ""
Local aDadAlter := {}
Local oResponse := NIL

Default cEmp        := _cEmp
Default cFil        := _cFil
Default lNovo       := .T.
Default cMsgConexao := ""
Default cNickName   := ""
Default cProdDe     := ""
Default cProdAte    := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
            cProdDe  := Replicate(" ",Tamsx3(Tb_Estru+"_SKU")[01])
            cProdAte := Replicate("Z",Tamsx3(Tb_Estru+"_SKU")[01])
        Else
            Return
        EndIf    
    Else
        aArea    := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    //->> Registra a entrada na rotina
    nRecRegist := u_MMRegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Produtos...")       
    EndIf
    cAlias := GetNextAlias()
    
    If lNovo        
        cQuery := "SELECT DISTINCT SKU FROM ("                                                                                                      +CRLF
        cQuery += "   SELECT "+Tb_Estru+"."+Tb_Estru+"_SKU                   AS SKU,"                                                               +CRLF 
        cQuery += "          "+Tb_Estru+"."+Tb_Estru+"_COD                   AS PRODUTO,"                                                           +CRLF
        cQuery += "          ISNULL("+Tb_IDS+"."+Tb_IDS+"_PENDEN,'')         AS PENDENCIA"                                                          +CRLF
        cQuery += "      FROM "+RetSqlName(Tb_Estru)+" "+Tb_Estru+" (NOLOCK)"                                                                       +CRLF
        cQuery += "      INNER JOIN "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                                                                 +CRLF
        cQuery += "         ON "+Tb_Produ+"."+Tb_Produ+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"                                                 +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_SKU    = "+Tb_Estru+"."+Tb_Estru+"_SKU"                                                    +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                                                             +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                                                             +CRLF
        cQuery += "        AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                                                       +CRLF
        cQuery += "      LEFT JOIN "+RetSqlName(Tb_IDS)+" "+Tb_IDS+" (NOLOCK)"                                                                      +CRLF
        cQuery += "         ON "+Tb_IDS+"."+Tb_IDS+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"                                                     +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_CHPROT = "+Tb_Estru+"."+Tb_Estru+"_SKU"                                                        +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_TIPO = 'PRD'"                                                                                  +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_ECOM = '"+Ecommerce+"'"                                                                        +CRLF
        cQuery += "        AND "+Tb_IDS+".D_E_L_E_T_ = ' '"                                                                                         +CRLF
        cQuery += "      WHERE "+Tb_Estru+"."+Tb_Estru+"_FILIAL = '"+xFilial(Tb_Estru)+"'"                                                          +CRLF            
        If !Empty(cProdAte)
            cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"                                               +CRLF
        ElseIf !Empty(cProdDe)
            cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU = '"+cProdDe+"'"                                                                        +CRLF
        EndIf
        cQuery += "        AND "+Tb_Estru+".D_E_L_E_T_ = ' '"                                                                                       +CRLF
        cQuery += "     GROUP BY "+Tb_Estru+"_SKU, "+Tb_Estru+"_COD,"+Tb_IDS+"_PENDEN) AS TMP"                                                      +CRLF
        cQuery += " WHERE TMP.PENDENCIA <> 'N'"                                                                                                     +CRLF
        cQuery += " ORDER BY SKU"                                                                                                                   +CRLF
    Else
        cQuery := "   SELECT "+Tb_Produ+"."+Tb_Produ+"_SKU                   AS SKU"                                                                +CRLF 
        cQuery += "      FROM "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                                                                       +CRLF
        cQuery += "      WHERE "+Tb_Produ+"."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"                                                          +CRLF
        If !Empty(cProdAte)
            cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"                                               +CRLF
        ElseIf !Empty(cProdDe)
            cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU = '"+cProdDe+"'"                                                                        +CRLF
        EndIf
        cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                                                              +CRLF
        cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                                                              +CRLF        
        cQuery += "       AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                                                        +CRLF
        cQuery += " ORDER BY "+Tb_Produ+"_SKU"                                                                                                      +CRLF
    EndIf
        
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
    (cAlias)->(dbGotop())

    If !isBlind()
        ProcRegua(nTotRegs)            
    EndIf
    
    Do While (cAlias)->(!Eof())
        If !isBlind()            
            IncProc("Atualizando Produtos no vTex...")       
        EndIf
        (Tb_Produ)->(dbSetOrder(1))
        If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+(cAlias)->SKU))
            cReq2Api := ""
            cRet2Api := ""        
            If SobeProduto((Tb_Produ)->&(Tb_Produ+"_SKU"),@cReq2Api,@cRet2Api,lJob,@aDadAlter,@oResponse)
                u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(Tb_Produ)->&(Tb_Produ+"_SKU"))
                u_MAGrvLogI(cConex,"S",,cRet2Api)

                If Alltrim(Upper(cRet2Api)) == "TRUE"
                    cIdProd   := aDadAlter[1]
                    cDtCad    := aDadAlter[2]
                    cDtAtu    := aDadAlter[3]
                    cDtAtualz := SubStr(cDtAtu,9,2)+"/"+SubStr(cDtAtu,6,2)+"/"+SubStr(cDtAtu,1,4)+"  " + SubStr(cDtAtu,12,8)
                Else
                    cIdProd   := Alltrim(Str(oResponse:Id))
                    cDtCad    := oResponse:ReleaseDate
                    cDtAtu    := oResponse:ReleaseDate
                    cDtAtualz := SubStr(cDtAtu,9,2)+"/"+SubStr(cDtAtu,6,2)+"/"+SubStr(cDtAtu,1,4)+"  " + SubStr(cDtAtu,12,8)
                EndIf

                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+(Tb_Produ)->&(Tb_Produ+"_SKU")))
                    Reclock(Tb_IDS,.T.)
                Else    
                    Reclock(Tb_IDS,.F.)
                EndIf
                (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := (Tb_Produ)->&(Tb_Produ+"_SKU")
                (Tb_IDS)->&(Tb_IDS+"_ID")       := cIdProd            
                (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                (Tb_IDS)->(MsUnlock())
            Else
                u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(Tb_Produ)->&(Tb_Produ+"_SKU"))
                u_MAGrvLogI(cConex,"N",,cRet2Api)
            EndIf
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    //->> Fecha o Registro da entrada na rotina
    u_MAUnRegMon(nRecRegist)
    
    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

//*****************************************************************************************************************
// MECANISMOS DE DESCIDA DE VENDAS
//*****************************************************************************************************************

/*/{protheus.doc} DesceVendas
*******************************************************************************************
Função de descida de vendas do e-commerce

curl --request GET \
     --url 'https://madmais.vtexcommercestable.com.br/api/oms/pvt/orders?f_creationDate=creationDate%3A%5B2021-01-01T00%3A00%3A00.000Z%20TO%202021-11-25T23%3A59%3A59.999Z%5D&f_hasInputInvoice=true' \
     --header 'Accept: application/json' \
     --header 'Content-Type: application/json' \
     --header 'X-VTEX-API-AppKey: vtexappkey-madmais-KQMGCA' \
     --header 'X-VTEX-API-AppToken: LNXBAXUHWAOIMLFMUWMYXVANZHTPYGLUJBBXUVOYLSHNEYHZFGZRQSKPNJCTEFJPPTZLJISZHNMFOMIAZUJRHTEQRMJKTUUGJRYLYWPXOAJCGFBAABTJVRIWOJUWYHGM'

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function DesceVendas(dDataDe,dDataAte,lJob,/*/Marcelo Celi - 06/09/2022/*/cIdPedSite)
Local cConex    := "ECVTEXDVDA"
Local lRet        := .F.
Local cEndPoint   := ""
Local cRequest    := ""
Local nTimeOut    := 0
Local cRetApi     := ""
Local cFiltro     := ""
Local aPedidos    := {}
Local aCliEntreg  := {}
Local aCliPagame  := {}
Local aItens      := {}
Local cFormPgto   := ""
Local cDtPedido   := Stod("")
Local cHrPedido   := ""
Local cReq2Api    := ""
Local cRet2Api    := ""
Local cCodigo     := ""
Local cLoja       := ""  
Local lGravou     := .F.  
Local cStatus     := ""  
Local cEndPBkp    := ""
Local cCnpj       := ""
Local cCpf        := ""
Local cTipoDoc    := ""
Local cInscEst    := ""  
Local cErro       := ""
Local aDatas      := {}
Local dAutorizVda := Stod("")
Local aDatas      := {}
Local dAutorizVda := Stod("")
Local aDadPgto    := {}
Local cDetPgto    := ""
Local aDatPgto    := {}
Local cDtAprov    := Stod("")
Local nParcelas   := 1
Local nVlrTotal   := 0
Local nVlrParcela := 0
Local dRecebiment := Stod("")
Local dPedido     := dDatabase  
Local aDadEntrega := {}
Local cDetEntrega := ""
Local aStatusOk   := {}
Local nVlrFrete   := 0
Local nVlrDesc    := 0
//Local nPosTotal   := 0
Local nDesconto   := 0
//->> Marcelo Celi - 03/03/2022
Local cReqSt2Api  := ""
Local cRetSt2Api  := ""
Local oStResponse := NIL
Local cStConex    := ""
//->> Marcelo Celi - 10/03/2022
Local cTransport  := ""
//->> Marcelo Celi - 14/03/2022
Local aPed2Selec  := {}
Local lPvStOk     := .F.  
//->> Marcelo Celi - 14/03/2022
Local nPagina     := 1
Local cEndReques  := ""
Local aPedByPagin := {}
Local aVoucher    := {}
Local lPvDscOk    := .F.  
//->> Marcelo Celi - 21/03/2022
Local cItRefId    := ""
Local nItQuantity := 0
Local nItPrice    := 0
Local cItId       := ""
Local cItName     := ""
//->> Marcelo Celi - 26/03/2022
Local cIdCliEntr  := ""
Local cIdCepEntr  := ""
Local cRecebe     := ""

//->> Marcelo Celi - 03/08/2022
Local cNomeCli    := ""
Local cFoneFCli   := ""
Local cFoneJCli   := ""
Local cMailCli    := ""
Local aDadsCli    := {}  

//->> Marcelo Celi - 09/09/2022
Local lMercLivre    := .F.
Local cCanaMLivre   := Alltrim(GetNewPar("BO_CANMLIV","9"))
Local cCanal        := ""
Local aNFMercLiv    := {}
Local lExiste       := .F.

Default lJob      := .F.

//->> Marcelo Celi - 06/09/2022
Default cIdPedSite:= ""

Private oResponse   := NIL
Private __nX        := 1  
Private __nY        := 1  
Private __nZ        := 1
//->> Marcelo Celi - 10/03/2022
Private nPosTransp  := 0
Private nPosSla     := 0
Private nPosTotal   := 0

If Inicializar(lJob)
    If !lJob
        ProcRegua(0)
        IncProc("Buscando Vendas no e-Commerce...")
    EndIf

    //->> Retorna os Status das Vendas no site, aptos a descer
    aStatusOk := u_MaEcStGet(Ecommerce)
    
    //->> Retorna os vouchers de desconto das Vendas no site, aptos a dar desconto
    aVoucher  := u_MaEcVouGet(Ecommerce)

    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GPV")) //->> Descida de Pedidos
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        cEndPBkp := cEndPoint

        If !Empty(cEndPoint)
            //->> Marcelo Celi - 17/03/2022
            If !lJob
                ProcRegua(0)
            EndIf
            
            nPagina := 1
            Do While .T.
                If !lJob
                    IncProc("Verificando Vendas do e-Commerce...")
                EndIf

                cFiltro := "f_authorizedDate=authorizedDate%3A%5B"
                cFiltro += StrZero(Year(dDataDe),4)+"-"+StrZero(Month(dDataDe),2)+"-"+StrZero(Day(dDataDe),2)+"T00%3A00%3A00.000Z%20"
                cFiltro += "TO%20"
                cFiltro += StrZero(Year(dDataAte),4)+"-"+StrZero(Month(dDataAte),2)+"-"+StrZero(Day(dDataAte),2)+"T23%3A59%3A59.999Z%5D"
                
                cFiltro +="&per_page=100&page="+Alltrim(Str(nPagina))
                cEndReques := cEndPoint + "?"+cFiltro            
                lRet := ExecutConex("GET",cEndReques,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                If !lRet
                    u_MAGrvLogI(cConex,,cEndReques,,,"SCJ",1,"")
                    u_MAGrvLogI(cConex,"N",,cRetApi)
                Else
                    If Len(oResponse:list) > 0
                        For __nX:=1 to Len(oResponse:list)
                            lMercLivre := .F.
                            
                            //->> Marcelo Celi - 06/09/2022
                            If !Empty(cIdPedSite)
                                If Alltrim(cIdPedSite)<>Alltrim(oResponse:list[__nX]:orderId)
                                    Loop
                                EndIf
                            EndIf

                            If Ascan(aPedByPagin,{|x| x==oResponse:list[__nX]:orderId})==0
                                aAdd(aPedByPagin,oResponse:list[__nX]:orderId)

                                cStatus := If(Valtype("oResponse:list[__nX]:status")<>"U",oResponse:list[__nX]:status,"")
                                cCanal  := If(Valtype("oResponse:list[__nX]:salesChannel")<>"U",oResponse:list[__nX]:salesChannel,"")
                                
                                //->> Marcelo Celi - 09/09/2022
                                If !Empty(cCanal) .And. Alltrim(cCanal) $ cCanaMLivre
                                    aNFMercLiv := u_MaGDoc2Vtx(oResponse:list[__nX]:orderId,lJob)
                                    If Len(aNFMercLiv)>=4 .And. !Empty(aNFMercLiv[1]) .And. !Empty(aNFMercLiv[4])
                                        lMercLivre := .T.
                                    Else
                                        lMercLivre := .F.
                                    EndIf
                                EndIf

                                //->> Marcelo Celi - 23/06/2022
                                If Len(aStatusOk)==0
                                    lPvStOk := .F.
                                EndIf
                                If Valtype(cStatus)<>"C"
                                    lPvStOk := .F.
                                    cStatus := ""
                                EndIf
                                //->> Fim do ajuste
                                
                                lPvStOk := Ascan(aStatusOk,{|x| x==Alltrim(Upper(cStatus))})>0
                                
                                //->> Marcelo Celi - 23/09/2022
                                If lMercLivre
                                    lPvStOk := .T.
                                EndIf
                                
                                aAdd(aPed2Selec,{ lPvStOk                                                                                                            ,  ; // 01 - Se PV esta OK
                                                If(Type("oResponse:list[__nX]:orderId")<>"U"                   ,oResponse:list[__nX]:orderId                     ,""),  ; // 02 - Id do Pedido
                                                If(Type("oResponse:list[__nX]:status")<>"U"                    ,oResponse:list[__nX]:status                      ,""),  ; // 03 - Status do Pedido
                                                If(Type("oResponse:list[__nX]:origin")<>"U"                    ,oResponse:list[__nX]:origin                      ,""),  ; // 04 - Canal do Pedido/Origem
                                                If(Type("oResponse:list[__nX]:sequence")<>"U"                  ,oResponse:list[__nX]:sequence                    ,""),  ; // 05 - Id Original do Pedido/Sequencia
                                                If(Type("oResponse:list[__nX]:creationDate")<>"U"              ,oResponse:list[__nX]:creationDate                ,""),  ; // 06 - Data de Criação
                                                If(Type("oResponse:list[__nX]:authorizedDate")<>"U"            ,oResponse:list[__nX]:authorizedDate              ,""),  ; // 07 - Data de Modificação/Autorização
                                                If(Type("oResponse:list[__nX]:saleschannel")<>"U"              ,oResponse:list[__nX]:saleschannel                ,"")}  ) // 08 - Id do Canal Usado
                            
                                If Ascan(aStatusOk,{|x| x==Alltrim(Upper(cStatus))})>0 .Or. lMercLivre
                                    //->> Controle das Datas de Processamento
                                    If Type("oResponse:list[__nX]:authorizedDate")<>"U"
                                        dAutorizVda := Left(oResponse:list[__nX]:authorizedDate,10)
                                        dAutorizVda := StrTran(dAutorizVda,"-","")
                                        dAutorizVda := Stod(dAutorizVda)                            
                                        aAdd(aDatas,dAutorizVda)
                                    EndIf

                                    //->> Array de Pedidos
                                    aAdd(aPedidos,{ If(Type("oResponse:list[__nX]:orderId")<>"U"                   ,oResponse:list[__nX]:orderId                     ,""),  ; // 01 - Id do Pedido
                                                    If(Type("oResponse:list[__nX]:sequence")<>"U"                  ,oResponse:list[__nX]:sequence                    ,""),  ; // 02 - Sequencia
                                                    If(Type("oResponse:list[__nX]:status")<>"U"                    ,oResponse:list[__nX]:status                      ,""),  ; // 03 - Status do Pedido
                                                    0,                                                                                                                      ; // 04 - Desconto
                                                    If(Type("oResponse:list[__nX]:origin")<>"U"                    ,oResponse:list[__nX]:origin                      ,""),  ; // 05 - Canal do Pedido/Origem
                                                    If(Type("oResponse:list[__nX]:sequence")<>"U"                  ,oResponse:list[__nX]:sequence                    ,""),  ; // 06 - Id Original do Pedido/Sequencia
                                                    If(Type("oResponse:list[__nX]:clientName")<>"U"                ,oResponse:list[__nX]:clientName                  ,""),  ; // 07 - Razao Social
                                                    If(Type("oResponse:list[__nX]:clientName")<>"U"                ,oResponse:list[__nX]:clientName                  ,""),  ; // 08 - Nome Completo
                                                    "",                                                                                                                     ; // 09 - CPF
                                                    "",                                                                                                                     ; // 10 - CNPJ
                                                    "",                                                                                                                     ; // 11 - Inscricao Estadual
                                                    "",                                                                                                                     ; // 12 - Inscricao Municipal
                                                    If(Type("oResponse:list[__nX]:creationDate")<>"U"              ,oResponse:list[__nX]:creationDate                ,""),  ; // 13 - Data de Criação
                                                    If(Type("oResponse:list[__nX]:authorizedDate")<>"U"            ,oResponse:list[__nX]:authorizedDate              ,""),  ; // 14 - Data de Modificação/Autorização
                                                    {},                                                                                                                     ; // 15 - Array de Dados do Recebedor
                                                    {},                                                                                                                     ; // 16 - Array de Dados do Pagador
                                                    {},                                                                                                                     ; // 17 - Itens do Pedido
                                                    {},                                                                                                                     ; // 18 - Dados do Pagamento
                                                    "",                                                                                                                     ; // 19 - Canal de Venda
                                                    {},                                                                                                                     ; // 20 - Dados da Entrega
                                                    If(Type("oResponse:list[__nX]:saleschannel")<>"U"              ,oResponse:list[__nX]:saleschannel                ,""),  ; // 21 - Id do Canal Usado
                                                    ""                                                                                                                   ,  ; // 22 - Id da Entrega
                                                    ""                                                                                                                   ,  ; // 23 - Id da Condicao de Pagamento
                                                    0                                                                                                                    ,  ; // 24 - Valor do Frete
                                                    ""                                                                                                                   ,  ; // 25 - Transportadora
                                                    ""                                                                                                                   ,  ; // 26 - IdCliVtex
                                                    ""                                                                                                                   ,  ; // 27 - IdCep + Num
                                                    ""                                                                                                                   }  ) // 28 - Quem recebera o pedido


                                EndIf
                            EndIf
                        Next __nX
                    Else
                        Exit
                    EndIf                
                EndIf
                nPagina++
            EndDo                       
    
            If Len(aPedidos)>0 .Or. Len(aPed2Selec)>0
                //->> Marcelo Celi - 14/03/2022
                If !lJob .And. Len(aPed2Selec)>0
                    If !SelPedidos(aPed2Selec,Ecommerce,@aPedidos)
                        aPedidos := {}
                    EndIf
                EndIf

                //->> Ordenação das Datas
                aDatas := aSort(aDatas,,,{|x,y| x < y })

                If !lJob
                    ProcRegua(Len(aPedidos))
                EndIf
                For __nX:=1 to Len(aPedidos)
                    If !lJob
                        IncProc("Baixando os detalhes da Venda do e-Commerce...")
                    EndIf
                    aCliEntreg := {}
                    aCliPagame := {}
                    aItens     := {}
                    aInfo      := {} 
                    
                    aPedidos[__nX][01] := If(Valtype(aPedidos[__nX][01])=="C",aPedidos[__nX][01],"")
                    If !Empty(aPedidos[__nX][01])
                        cEndPoint  := cEndPBkp + "/" + Alltrim(aPedidos[__nX,01])
                    EndIf                    

                    lRet := !Empty(aPedidos[__nX][01]) .And. ExecutConex("GET",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                    If lRet
                        //->> Capturar o valor do frete
                        nVlrFrete := 0
                        If Type("oResponse:totals")<>"U" .And. ValType(oResponse:totals)=="A"
                            For nPosTotal := 1 to Len(oResponse:totals)
                                If Alltrim(Upper(oResponse:totals[nPosTotal]:Id)) == Alltrim(Upper("Shipping"))
                                    nVlrFrete := (oResponse:totals[nPosTotal]:value)/100
                                EndIf

                                If Alltrim(Upper(oResponse:totals[nPosTotal]:Id)) == Alltrim(Upper("Discounts"))
                                    nVlrDesc := (oResponse:totals[nPosTotal]:value)/100
                                EndIf
                            Next nPosTotal
                        EndIf
                        If nVlrFrete > 0
                            aPedidos[__nX,24] := nVlrFrete
                        EndIf
                        
                        //->> Marcelo Celi - 10/03/2022
                        //->> Capturar a Transportadora                        
                        cTransport := ""
                        If Type("oResponse:shippingdata:logisticsInfo")<>"U" .And. ValType(oResponse:shippingdata:logisticsInfo)=="A"
                            For nPosTransp := 1 to Len(oResponse:shippingdata:logisticsInfo)
                                If Type("oResponse:shippingdata:logisticsInfo[nPosTransp]:selectedsla")<>"U" .And. Valtype(oResponse:shippingdata:logisticsInfo[nPosTransp]:selectedsla)=="C"
                                    If !Empty(cTransport)
                                        cTransport += ", "
                                    EndIf
                                    cTransport += Alltrim(oResponse:shippingdata:logisticsInfo[nPosTransp]:selectedsla)
                                    If !Empty(cTransport)
                                        Exit
                                    EndIf
                                EndIf
                                /*
                                If Type("oResponse:shippingdata:logisticsInfo[nPosTransp]:slas")<>"U" .And. Valtype(oResponse:shippingdata:logisticsInfo[nPosTransp]:slas)=="A"
                                    For nPosSla := 1 to Len(oResponse:shippingdata:logisticsInfo[nPosTransp]:slas)
                                        If Type("oResponse:shippingdata:logisticsInfo[nPosTransp]:slas[nPosSla]:name")<>"U" .And. Valtype(oResponse:shippingdata:logisticsInfo[nPosTransp]:slas[nPosSla]:name)=="C"                                        
                                            If !Empty(cTransport)
                                                cTransport += ", "
                                            EndIf
                                            cTransport += Alltrim(oResponse:shippingdata:logisticsInfo[nPosTransp]:slas[nPosSla]:name)
                                        EndIf    
                                    Next nPosSla
                                EndIf
                                */
                            Next nPosTransp
                        EndIf
                        aPedidos[__nX,25] := cTransport

                        //***********************************************************************************************************
                        //->> Marcelo Celi - 03/08/2022
                        aDadsCli := {}
                        If Type("oResponse:clientProfileData:isCorporate")<>"U" .And. ValType(oResponse:clientProfileData:isCorporate)=="L" .And. oResponse:clientProfileData:isCorporate
                            If Type("oResponse:clientProfileData:corporateDocument")<>"U" .And. ValType(oResponse:clientProfileData:corporateDocument)=="C" .And. !Empty(oResponse:clientProfileData:corporateDocument)
                                aDadsCli := GetDetClien(lJob,oResponse:clientProfileData:corporateDocument,.T.)
                            EndIf
                        Else
                            If Type("oResponse:clientProfileData:document")<>"U" .And. ValType(oResponse:clientProfileData:document)=="C" .And. !Empty(oResponse:clientProfileData:document)
                                aDadsCli := GetDetClien(lJob,oResponse:clientProfileData:document,.F.)
                            EndIf
                        EndIf    

                        //->> Formatação do Nome do Cliente
                        //->> Nome Pessoa Fisica
                        cNomeCli := ""
                        If Len(aDadsCli)>0
                            cNomeCli := aDadsCli[1,4]
                        EndIf
                        If Empty(cNomeCli)
                            If Type("oResponse:clientProfileData:firstName")<>"U" .And. Valtype(oResponse:clientProfileData:firstName)=="C"
                                cNomeCli := Alltrim(Upper(oResponse:clientProfileData:firstName))
                            EndIf
                            If Type("oResponse:clientProfileData:lastName")<>"U" .And. Valtype(oResponse:clientProfileData:lastName)=="C"
                                cNomeCli += " " + Alltrim(Upper(oResponse:clientProfileData:lastName))
                            EndIf
                            
                            //->> Nome Pessoa Juridica
                            If Type("oResponse:clientProfileData:corporateName")<>"U" .And. Valtype(oResponse:clientProfileData:corporateName)=="C"
                                cNomeCli := Alltrim(Upper(oResponse:clientProfileData:corporateName))
                            EndIf

                            //->> Reorganização do Nome
                            cNomeCli := Alltrim(cNomeCli)
                        EndIf

                        //->> Marcelo Celi - 03/08/2022
                        //->> Formatação do telefone do Cliente
                        //->> Pessoa Fisica
                        cFoneFCli := ""
                        If Len(aDadsCli)>0 .And. aDadsCli[1,2]=="F"
                            cFoneFCli := aDadsCli[1,5]
                        EndIf
                        If Empty(cFoneFCli)
                            If Type("oResponse:clientProfileData:phone")<>"U" .And. Valtype(oResponse:clientProfileData:phone)=="C"
                                cFoneFCli := Alltrim(Upper(oResponse:clientProfileData:phone))
                            EndIf
                        EndIf

                        //->> Pessoa Juridica
                        cFoneJCli := ""
                        If Len(aDadsCli)>0 .And. aDadsCli[1,2]=="J"
                            cFoneJCli := aDadsCli[1,5]
                        EndIf
                        If Empty(cFoneJCli)
                            If Type("oResponse:clientProfileData:corporatePhone")<>"U" .And. Valtype(oResponse:clientProfileData:corporatePhone)=="C"
                                cFoneJCli := Alltrim(Upper(oResponse:clientProfileData:corporatePhone))
                            EndIf
                        EndIf

                        //->> Email do Cliente
                        cMailCli := ""
                        If Len(aDadsCli)>0
                            cMailCli := aDadsCli[1,3]
                        EndIf
                        If Empty(cMailCli)
                            If Type("oResponse:clientProfileData:email")<>"U" .And. Valtype(oResponse:clientProfileData:email)=="C"
                                cMailCli := Alltrim(Upper(oResponse:clientProfileData:email))
                            EndIf
                        EndIf
                        //***********************************************************************************************************

                        cTipoDoc := ""
                        cCpf     := ""
                        cCnpj    := ""
                        cInscEst := ""
                        If Type("oResponse:clientProfileData:documentType")<>"U" .And. Valtype(oResponse:clientProfileData:documentType)=="C"
                            cTipoDoc := Alltrim(Upper(oResponse:clientProfileData:documentType))
                        EndIf
                        If Type("oResponse:clientProfileData:corporateDocument")<>"U" .And. ValType(oResponse:clientProfileData:corporateDocument)=="C" .And. !Empty(oResponse:clientProfileData:corporateDocument)
                            cCnpj := oResponse:clientProfileData:corporateDocument
                        Else
                            cCpf  := Alltrim(If(Type("oResponse:clientProfileData:document")<>"U" .And. Valtype(oResponse:clientProfileData:document)=="C",oResponse:clientProfileData:document,""))
                        EndIf
                        If Type("oResponse:clientProfileData:stateInscription")<>"U" .And. ValType(oResponse:clientProfileData:stateInscription)=="C" .And. !Empty(oResponse:clientProfileData:stateInscription)
                            cInscEst := oResponse:clientProfileData:stateInscription
                        EndIf                        
                        aPedidos[__nX,09] := cCpf
                        aPedidos[__nX,10] := cCnpj
                        
                        //->> Marcelo Celi - 17/03/2022
                        aPedidos[__nX,11] := cInscEst

                        //->> Ajuste da formatação dos dados removendo caracteres especiais, acentuação incorreta e transformando em caixa alta
                        aPedidos[__nX][01] := If(Valtype(aPedidos[__nX][01])=="C",aPedidos[__nX][01],"")
                        aPedidos[__nX][02] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][02]))))
                        aPedidos[__nX][03] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][03]))))
                        aPedidos[__nX][04] := If(Valtype(aPedidos[__nX][04])=="N",aPedidos[__nX][04],0)
                        aPedidos[__nX][05] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][05]))))
                        aPedidos[__nX][06] := aPedidos[__nX][06]
                        aPedidos[__nX][07] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][07]))))
                        aPedidos[__nX][08] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][08]))))
                        aPedidos[__nX][09] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][09]))))
                        aPedidos[__nX][10] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][10]))))
                        aPedidos[__nX][11] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][11]))))
                        aPedidos[__nX][12] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aPedidos[__nX][12]))))
                        aPedidos[__nX][13] := aPedidos[__nX][13]
                        aPedidos[__nX][14] := aPedidos[__nX][14]
                        aPedidos[__nX][19] := Alltrim(Upper(FwNoAccent(DecodeUtf8(If(Type("oResponse:origin")<>"U" .And. ValType(oResponse:origin)=="C",oResponse:origin,"")))))
                                                
                        //->> Array de Cliente de Entrega
                        aAdd(aCliEntreg, ""  ) // 01 - Nome
                        aAdd(aCliEntreg, ""  ) // 02 - Sobrenome
                        aAdd(aCliEntreg, ""  ) // 03 - Endereço
                        aAdd(aCliEntreg, ""  ) // 04 - Numero
                        aAdd(aCliEntreg, ""  ) // 05 - CEP
                        aAdd(aCliEntreg, ""  ) // 06 - Complemento
                        aAdd(aCliEntreg, ""  ) // 07 - Referencia
                        aAdd(aCliEntreg, ""  ) // 08 - Informações Adicionais
                        aAdd(aCliEntreg, ""  ) // 09 - Vizinhança
                        aAdd(aCliEntreg, ""  ) // 10 - Cidade
                        aAdd(aCliEntreg, ""  ) // 11 - Estado
                        aAdd(aCliEntreg, ""  ) // 12 - Pais
                        aAdd(aCliEntreg, ""  ) // 13 - DDD
                        aAdd(aCliEntreg, ""  ) // 14 - Telefone
                        aAdd(aCliEntreg, ""  ) // 15 - DDD 2
                        aAdd(aCliEntreg, ""  ) // 16 - Telefone 2
                        aAdd(aCliEntreg, ""  ) // 17 - Email
                        aAdd(aCliEntreg, ""  ) // 18 - Id do Endereço
                        
                        If Type("oResponse:shippingData:Id")<>"U" .And. Valtype(oResponse:shippingData:Id)=="C" .And. Alltrim(Upper(oResponse:shippingData:Id)) == Alltrim(Upper("shippingData"))
                            //->> Marcelo Celi - 03/08/2022
                            //aCliEntreg[01] := If(Type("oResponse:shippingData:address:receiverName")<>"U"  .And. Valtype(oResponse:shippingData:address:receiverName)=="C"    ,oResponse:shippingData:address:receiverName   ,"")
                            aCliEntreg[01] := cNomeCli
                            
                            aCliEntreg[02] := ""                            
                            aCliEntreg[03] := If(Type("oResponse:shippingData:address:street")<>"U"        .And. Valtype(oResponse:shippingData:address:street)=="C"          ,oResponse:shippingData:address:street         ,"")
                            aCliEntreg[04] := If(Type("oResponse:shippingData:address:number")<>"U"        .And. Valtype(oResponse:shippingData:address:number)=="C"          ,oResponse:shippingData:address:number         ,"")
                            aCliEntreg[05] := If(Type("oResponse:shippingData:address:postalCode")<>"U"    .And. Valtype(oResponse:shippingData:address:postalCode)=="C"      ,oResponse:shippingData:address:postalCode     ,"")
                            aCliEntreg[06] := If(Type("oResponse:shippingData:address:complement")<>"U"    .And. Valtype(oResponse:shippingData:address:complement)=="C"      ,oResponse:shippingData:address:complement     ,"")
                            aCliEntreg[07] := If(Type("oResponse:shippingData:address:reference")<>"U"     .And. Valtype(oResponse:shippingData:address:reference)=="C"       ,oResponse:shippingData:address:reference      ,"")
                            aCliEntreg[08] := If(Type("oResponse:shippingData:address:addressType")<>"U"   .And. Valtype(oResponse:shippingData:address:addressType)=="C"     ,oResponse:shippingData:address:addressType    ,"")
                            aCliEntreg[09] := If(Type("oResponse:shippingData:address:neighborhood")<>"U"  .And. Valtype(oResponse:shippingData:address:neighborhood)=="C"    ,oResponse:shippingData:address:neighborhood   ,"")
                            aCliEntreg[10] := If(Type("oResponse:shippingData:address:city")<>"U"          .And. Valtype(oResponse:shippingData:address:city)=="C"            ,oResponse:shippingData:address:city           ,"")
                            aCliEntreg[11] := If(Type("oResponse:shippingData:address:state")<>"U"         .And. Valtype(oResponse:shippingData:address:state)=="C"           ,oResponse:shippingData:address:state          ,"")
                            aCliEntreg[12] := If(Type("oResponse:shippingData:address:country")<>"U"       .And. Valtype(oResponse:shippingData:address:country)=="C"         ,oResponse:shippingData:address:country        ,"")
                            aCliEntreg[13] := ""
                            
                            //->> Marcelo Celi - 03/08/2022
                            //aCliEntreg[14] := If(Type("oResponse:clientProfileData:phone")<>"U"            .And. Valtype(oResponse:clientProfileData:phone)=="C"              ,oResponse:clientProfileData:phone             ,"")
                            aCliEntreg[14] := cFoneFCli

                            aCliEntreg[15] := ""
                            
                            //->> Marcelo Celi - 03/08/2022
                            //aCliEntreg[16] := If(Type("oResponse:clientProfileData:corporatePhone")<>"U"   .And. Valtype(oResponse:clientProfileData:corporatePhone)=="C"     ,oResponse:clientProfileData:corporatePhone    ,"")
                            aCliEntreg[16] := cFoneJCli

                            //->> Marcelo Celi - 03/08/2022
                            //aCliEntreg[17] := If(Type("oResponse:clientProfileData:email")<>"U"            .And. Valtype(oResponse:clientProfileData:email)=="C"              ,oResponse:clientProfileData:email             ,"")
                            aCliEntreg[17] := cMailCli

                            aCliEntreg[18] := If(Type("oResponse:shippingData:address:addressId")<>"U"     .And. Valtype(oResponse:shippingData:address:addressId)=="C"       ,oResponse:shippingData:address:receiverName   ,"")

                            //->> Marcelo Celi - 26/03/2022
                            cIdCliEntr := ""
                            If Type("oResponse:shippingData:address:addressId")<>"U" .And. Valtype(oResponse:shippingData:address:addressId)=="C"
                                cIdCliEntr := Alltrim(oResponse:shippingData:address:addressId)
                            EndIf
                            aPedidos[__nX][26] := cIdCliEntr
                            
                            cIdCepEntr := ""
                            If Type("oResponse:shippingData:address:postalCode")<>"U" .And. ValType("oResponse:shippingData:address:postalCode")=="C"
                                cIdCepEntr := Alltrim(oResponse:shippingData:address:postalCode)
                                If Type("oResponse:shippingData:address:number")<>"U"
                                    If Valtype(oResponse:shippingData:address:number)=="N"
                                        cIdCepEntr += Alltrim(Str(oResponse:shippingData:address:number))
                                    ElseIf Valtype(oResponse:shippingData:address:number)=="C"
                                        cIdCepEntr += Alltrim(oResponse:shippingData:address:number)
                                    EndIf
                                EndIf
                            EndIf

                            //->> Marcelo Celi - 03/06/2022
                            cIdCepEntr := StrTran(cIdCepEntr,"-","")
                            cIdCepEntr := StrTran(cIdCepEntr,"_","")
                            cIdCepEntr := StrTran(cIdCepEntr,"/","")

                            //->> Marcelo Celi - 06/09/2022
                            cIdCepEntr := StrTran(cIdCepEntr,"'","")
                            cIdCepEntr := StrTran(cIdCepEntr,'"','')

                            aPedidos[__nX][27] := cIdCepEntr

                            cRecebe := ""
                            If Type("oResponse:shippingData:address:receiverName")<>"U" .And. ValType(oResponse:shippingData:address:receiverName)=="C"
                                cRecebe := oResponse:shippingData:address:receiverName
                            EndIf
                            aPedidos[__nX][28] := cRecebe

                            //->> Ajuste do cep, removendo o traço da descida
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"-","")
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"_","")
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"/","")
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"\","")
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"*","")
                            aCliEntreg[05] := StrTran(aCliEntreg[05],"=","")

                            For __nY:=1 to Len(aCliEntreg)
                                aCliEntreg[__nY] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aCliEntreg[__nY]))))
                            Next __nY
                        EndIf

                        //->> Array de Cliente de Pagamento
                        aAdd(aCliPagame, ""  ) // 01 - Nome
                        aAdd(aCliPagame, ""  ) // 02 - Sobrenome
                        aAdd(aCliPagame, ""  ) // 03 - Endereço
                        aAdd(aCliPagame, ""  ) // 04 - Numero
                        aAdd(aCliPagame, ""  ) // 05 - CEP
                        aAdd(aCliPagame, ""  ) // 06 - Complemento
                        aAdd(aCliPagame, ""  ) // 07 - Referencia
                        aAdd(aCliPagame, ""  ) // 08 - Informações Adicionais
                        aAdd(aCliPagame, ""  ) // 09 - Vizinhança
                        aAdd(aCliPagame, ""  ) // 10 - Cidade
                        aAdd(aCliPagame, ""  ) // 11 - Estado
                        aAdd(aCliPagame, ""  ) // 12 - Pais
                        aAdd(aCliPagame, ""  ) // 13 - DDD
                        aAdd(aCliPagame, ""  ) // 14 - Telefone
                        aAdd(aCliPagame, ""  ) // 15 - DDD 2
                        aAdd(aCliPagame, ""  ) // 16 - Telefone 2
                        aAdd(aCliPagame, ""  ) // 17 - Email
                        aAdd(aCliPagame, ""  ) // 18 - Id do Endereço

                        //->> Marcelo Celi - 03/08/2022
                        //aCliPagame[01] := If(Type("oResponse:shippingData:address:receiverName")<>"U"  .And. Valtype(oResponse:shippingData:address:receiverName)=="C"    ,oResponse:shippingData:address:receiverName   ,"")
                        aCliPagame[01] := cNomeCli

                        aCliPagame[02] := ""
                        aCliPagame[03] := If(Type("oResponse:shippingData:address:street")<>"U"        .And. Valtype(oResponse:shippingData:address:street)=="C"          ,oResponse:shippingData:address:street         ,"")
                        aCliPagame[04] := If(Type("oResponse:shippingData:address:number")<>"U"        .And. Valtype(oResponse:shippingData:address:number)=="C"          ,oResponse:shippingData:address:number         ,"")
                        aCliPagame[05] := If(Type("oResponse:shippingData:address:postalCode")<>"U"    .And. Valtype(oResponse:shippingData:address:postalCode)=="C"      ,oResponse:shippingData:address:postalCode     ,"")
                        aCliPagame[06] := If(Type("oResponse:shippingData:address:complement")<>"U"    .And. Valtype(oResponse:shippingData:address:complement)=="C"      ,oResponse:shippingData:address:complement     ,"")
                        aCliPagame[07] := If(Type("oResponse:shippingData:address:reference")<>"U"     .And. Valtype(oResponse:shippingData:address:reference)=="C"       ,oResponse:shippingData:address:reference      ,"")
                        aCliPagame[08] := If(Type("oResponse:shippingData:address:addressType")<>"U"   .And. Valtype(oResponse:shippingData:address:addressType)=="C"     ,oResponse:shippingData:address:addressType    ,"")
                        aCliPagame[09] := If(Type("oResponse:shippingData:address:neighborhood")<>"U"  .And. Valtype(oResponse:shippingData:address:neighborhood)=="C"    ,oResponse:shippingData:address:neighborhood   ,"")
                        aCliPagame[10] := If(Type("oResponse:shippingData:address:city")<>"U"          .And. Valtype(oResponse:shippingData:address:city)=="C"            ,oResponse:shippingData:address:city           ,"")
                        aCliPagame[11] := If(Type("oResponse:shippingData:address:state")<>"U"         .And. Valtype(oResponse:shippingData:address:state)=="C"           ,oResponse:shippingData:address:state          ,"")
                        aCliPagame[12] := If(Type("oResponse:shippingData:address:country")<>"U"       .And. Valtype(oResponse:shippingData:address:country)=="C"         ,oResponse:shippingData:address:country        ,"")
                        aCliPagame[13] := ""
                        
                        //->> Marcelo Celi - 03/08/2022
                        //aCliPagame[14] := If(Type("oResponse:clientProfileData:phone")<>"U"            .And. Valtype(oResponse:clientProfileData:phone)=="C"              ,oResponse:clientProfileData:phone             ,"")
                        aCliPagame[14] := cFoneFCli
                        
                        aCliPagame[15] := ""
                        
                        //->> Marcelo Celi - 03/08/2022
                        //aCliPagame[16] := If(Type("oResponse:clientProfileData:corporatePhone")<>"U"   .And. Valtype(oResponse:clientProfileData:corporatePhone)=="C"     ,oResponse:clientProfileData:corporatePhone    ,"")
                        aCliPagame[16] := cFoneJCli

                        //->> Marcelo Celi - 03/08/2022
                        //aCliPagame[17] := If(Type("oResponse:clientProfileData:email")<>"U"            .And. Valtype(oResponse:clientProfileData:email)=="C"              ,oResponse:clientProfileData:email             ,"")
                        aCliPagame[17] := cMailCli
                        
                        aCliPagame[18] := If(Type("oResponse:shippingData:address:addressId")<>"U"     .And. Valtype(oResponse:shippingData:address:addressId)=="C"       ,oResponse:shippingData:address:receiverName   ,"")

                        //->> Ajuste do cep, removendo o traço da descida
                        aCliPagame[05] := StrTran(aCliPagame[05],"-","")
                        aCliPagame[05] := StrTran(aCliPagame[05],"_","")
                        aCliPagame[05] := StrTran(aCliPagame[05],"/","")
                        aCliPagame[05] := StrTran(aCliPagame[05],"\","")
                        aCliPagame[05] := StrTran(aCliPagame[05],"*","")
                        aCliPagame[05] := StrTran(aCliPagame[05],"=","")

                        For __nY:=1 to Len(aCliPagame)
                            aCliPagame[__nY] := Alltrim(Upper(FwNoAccent(DecodeUtf8(aCliPagame[__nY]))))
                        Next __nY

                        //->> Array de Itens do Pedido
                        For __nY:=1 to Len(oResponse:items)
                            nDesconto := 0
                            If Type("oResponse:items[__nY]:priceTags")<>"U" .And. ValType(oResponse:items[__nY]:priceTags)=="A"
                                For nPosTotal:=1 to Len(oResponse:items[__nY]:priceTags)
                                    //->> Marcelo Celi - 11/03/2022
                                    If Type("oResponse:items[__nY]:priceTags[nPosTotal]:name")<>"U" .And. Valtype(oResponse:items[__nY]:priceTags[nPosTotal]:name)=="C"
                                        //->> Marcelo Celi - 18/03/2022
                                        //If "DISCOUNT@MARKETPLACE" $ Upper(Alltrim(oResponse:items[__nY]:priceTags[nPosTotal]:name))
                                        
                                        lPvDscOk := Ascan(aVoucher,{|x| Upper(Alltrim(x))==Alltrim(Upper(oResponse:items[__nY]:priceTags[nPosTotal]:name))})>0                                        
                                        If lPvDscOk
                                            nDesconto += oResponse:items[__nY]:priceTags[nPosTotal]:rawValue
                                        EndIf
                                    EndIf    
                                Next nPosTotal                                
                                If nDesconto < 0
                                    nDesconto := nDesconto * -1
                                EndIf
                            EndIf
                            
                            //->> Marcelo Celi - 21/03/2022
                            If Type("oResponse:items[__nY]:refId")<>"U" .And. ValType(oResponse:items[__nY]:refId)=="C"
                                cItRefId := oResponse:items[__nY]:refId
                                cItRefId := Upper(FwNoAccent(DecodeUtf8(cItRefId)))
                            Else
                                cItRefId := ""
                            EndIf

                            If Type("oResponse:items[__nY]:quantity")<>"U" .And. Valtype(oResponse:items[__nY]:quantity)=="N"
                                nItQuantity := oResponse:items[__nY]:quantity
                            Else
                                nItQuantity := 0
                            EndIf

                            If Type("oResponse:items[__nY]:price")<>"U" .And. Valtype(oResponse:items[__nY]:price)=="N"
                                nItPrice := oResponse:items[__nY]:price/100
                            Else
                                nItPrice := 0
                            EndIf

                            If Type("oResponse:items[__nY]:id")<>"U" .And. Valtype(oResponse:items[__nY]:id)=="C"
                                cItId := oResponse:items[__nY]:id
                            Else
                                cItId := ""
                            EndIf

                            If Type("oResponse:items[__nY]:name")<>"U" .And. Valtype(oResponse:items[__nY]:name)=="C"
                                cItName := oResponse:items[__nY]:name
                                cItName := Upper(FwNoAccent(DecodeUtf8(cItName)))
                            Else
                                cItName := ""
                            EndIf

                            aAdd(aItens,{cItRefId     ,; // 01 - Ref do ID do Produto
                                         nItQuantity  ,; // 02 - Quantidade
                                         nItPrice     ,; // 03 - Preço Unitario
                                         nDesconto    ,; // 04 - Desconto
                                         0            ,; // 05 - Valor Total do Item
                                         cItId        ,; // 06 - Id do Produto
                                         cItName      }) // 07 - Nome do Produto

                          //  aAdd(aItens,{Alltrim(Upper(FwNoAccent(DecodeUtf8(If(Type("oResponse:items[__nY]:productId")<>"U"  , oResponse:items[__nY]:refId           , "")))))     ,; // 01 - Ref do ID do Produto
                          //               If(Type("oResponse:items[__nY]:quantity")<>"U"                                       , oResponse:items[__nY]:quantity        ,  0    )     ,; // 02 - Quantidade
                          //               If(Type("oResponse:items[__nY]:price")<>"U"                                          , (oResponse:items[__nY]:price/100) ,  0    )         ,; // 03 - Preço Unitario
                          //               nDesconto                                                                                                                                  ,; // 04 - Desconto
                          //               0                                                                                                                                          ,; // 05 - Valor Total do Item
                          //               If(Type("oResponse:items[__nY]:productId")<>"U"                                      , oResponse:items[__nY]:id            ,  0)           ,; // 06 - Id do Produto
                          //               Alltrim(Upper(FwNoAccent(DecodeUtf8(If(Type("oResponse:items[__nY]:name")<>"U"       , oResponse:items[__nY]:name          , "")))))       }) // 07 - Nome do Produto

                        Next __nY

                        //->> Array com os dados do pagamento
                        If Type("oResponse:paymentData:transactions")<>"U" .And. Valtype(oResponse:paymentData:transactions)=="A"
                            For __nY:=1 to Len(oResponse:paymentData:transactions)
                                If Type("oResponse:paymentData:transactions[__nY]:payments")<>"U" .And. ValType(oResponse:paymentData:transactions[__nY]:payments)=="A"
                                    For __nZ:=1 to Len(oResponse:paymentData:transactions[__nY]:payments)
                                        aDadPgto := Array(11)
                                        aDadPgto[01] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:group")<>"U"                                   ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:group                                  ,"")))
                                        aDadPgto[02] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:paymentsystem")<>"U"                           ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:paymentsystem                          ,"")))
                                        aDadPgto[03] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:paymentsystemname")<>"U"                       ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:paymentsystemname                      ,"")))
                                        aDadPgto[04] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:tid")<>"U"                                     ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:tid                                    ,"")))
                                        aDadPgto[05] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:message")<>"U"              ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:message             ,"")))
                                        aDadPgto[06] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:authId")<>"U"               ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:authId              ,"")))
                                        aDadPgto[07] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:nsu")<>"U"                  ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:connectorResponses:nsu                 ,"")))
                                        aDadPgto[08] := If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:installments")<>"U"                                                  ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:installments                           ,0 )
                                        aDadPgto[09] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:bankIssuedInvoiceIdentificationNumber")<>"U"   ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:bankIssuedInvoiceIdentificationNumber  ,"")))
                                        aDadPgto[10] := If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:bankIssuedInvoiceBarCodeNumber")<>"U"                                ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:bankIssuedInvoiceBarCodeNumber         ,0 )
                                        aDadPgto[11] := FwNoAccent(DecodeUtf8(If(Type("oResponse:paymentData:transactions[__nY]:payments[__nZ]:id")<>"U"                                      ,oResponse:paymentData:transactions[__nY]:payments[__nZ]:id                                     ,"")))
                                        
                                        //->> Marcelo Celi - 02/02/2022
                                        If Empty(aPedidos[__nX][23])
                                            aPedidos[__nX][23] := Alltrim(aDadPgto[02])+If(aDadPgto[08]>0,Alltrim(Str(aDadPgto[08])),"")
                                        EndIf

                                        aAdd(aPedidos[__nX][18],aDadPgto)
                                    Next __nZ
                                EndIf
                            Next __nY
                        EndIf

                        //->> Array com os dados da Entrega
                        If Type("oResponse:packageAttachment:packages")<>"U" .And. Valtype(oResponse:packageAttachment:packages)=="A"
                            For __nY:=1 to Len(oResponse:packageAttachment:packages)
                                aDadEntrega := Array(05)
                                aDadEntrega[01] := FwNoAccent(DecodeUtf8(If(Type("oResponse:packageAttachment:packages[__nY]:courier")<>"U"        ,oResponse:packageAttachment:packages[__nY]:courier                                    ,""))) // Correio
                                aDadEntrega[02] := FwNoAccent(DecodeUtf8(If(Type("oResponse:packageAttachment:packages[__nY]:invoiceNumber")<>"U"  ,oResponse:packageAttachment:packages[__nY]:invoiceNumber                              ,""))) // Numero da Fatura
                                aDadEntrega[03] := FwNoAccent(DecodeUtf8(If(Type("oResponse:packageAttachment:packages[__nY]:trackingNumber")<>"U" ,oResponse:packageAttachment:packages[__nY]:trackingNumber                             ,""))) // Numero do Rastreio                                
                                aDadEntrega[04] := FwNoAccent(DecodeUtf8(If(Type("oResponse:packageAttachment:packages[__nY]:invoiceKey")<>"U"     ,oResponse:packageAttachment:packages[__nY]:invoiceKey                                 ,""))) // Chave da Nota Fiscal
                                aDadEntrega[05] := Round(If(Type("oResponse:packageAttachment:packages[__nY]:invoiceValue")<>"U"                         ,oResponse:packageAttachment:packages[__nY]:invoiceValue/100,0),Tamsx3("CK_VALOR")[02]) // Valor da Fatura 
                                
                                aAdd(aPedidos[__nX][20],aDadEntrega)
                            Next __nY
                        EndIf    
                        
                        aPedidos[__nX][15] := aClone(aCliEntreg)
                        aPedidos[__nX][16] := aClone(aCliPagame)
                        aPedidos[__nX][17] := aClone(aItens)

                        //->>Marcelo Celi - 06/09/2022
                        //aPedidos[__nX,07] := cNomeCli
                        //aPedidos[__nX,08] := cNomeCli

                        //->>Marcelo Celi - 20/09/2022 - caracteres estranhos no nome do cliente
                        aPedidos[__nX,07] := Alltrim(Upper(FwNoAccent(DecodeUtf8(cNomeCli))))
                        aPedidos[__nX,08] := Alltrim(Upper(FwNoAccent(DecodeUtf8(cNomeCli))))
                    EndIf
                Next __nX

                If Len(aPedidos)>0                    
                    For __nX:=1 to Len(aPedidos)
                        SCJ->(dbOrderNickName("CJXORIGEM"))
                        lExiste := SCJ->(dbSeek(xFilial("SCJ")+PadR(Ecommerce,Tamsx3("CJ_XORIGEM")[01])+PadR(aPedidos[__nX,01],Tamsx3("CJ_XIDINTG")[01])))                        
                        If !lExiste
                            If u_MaGrvCliEc(Ecommerce,        ; // 01 - Codigo do eCommerce
                                            aPedidos[__nX,09],; // 02 - Cpf
                                            aPedidos[__nX,10],; // 03 - Cnpj
                                            aPedidos[__nX,11],; // 04 - Inscrição Estadual
                                            aPedidos[__nX,12],; // 05 - Inscrição Municipal
                                            aPedidos[__nX,08],; // 06 - Nome Completo
                                            aPedidos[__nX,07],; // 07 - Razão Social
                                            aPedidos[__nX,15],; // 08 - Array com os dados do recebedor
                                            aPedidos[__nX,16],; // 09 - Array com os dados do pagador
                                            @cCodigo,         ; // 10 - Codigo do Cliente a usar no pedido
                                            @cLoja,           ; // 11 - Loja do Cliente a usar no pedido
                                            @lGravou,         ; // 12 - Se registro foi incluido
                                            aPedidos[__nX,26],; // 13 - IdCliente
                                            aPedidos[__nX,27] ) // 14 - Id Pelo Cep

                                If lGravou
                                    u_MAGrvLogI("ECVTEXDCLI",,cEndPoint,,,"SA1",1,xFilial("SA1")+cCodigo+cLoja)
                                    u_MAGrvLogI("ECVTEXDCLI","S",,"Cliente gerado com sucesso sob pedido de id "+Alltrim(aPedidos[__nX,01]))
                                EndIf                                    

                                cDtPedido := SubStr(aPedidos[__nX,13],01,10)
                                cDtPedido := StrTran(cDtPedido,"-","")
                                cDtPedido := Stod(cDtPedido)

                                cDtAprov  := SubStr(aPedidos[__nX,14],01,10)
                                cDtAprov  := StrTran(cDtAprov,"-","")
                                cDtAprov  := Stod(cDtAprov)

                                cHrPedido := SubStr(aPedidos[__nX,13],12,08)

                                cDetPgto    := ""
                                nParcelas   := 1
                                nVlrTotal   := 0
                                nVlrParcela := 0
                                If Len(aPedidos[__nX,18])>0
                                    For __nY:=1 to Len(aPedidos[__nX,18])
                                        cDetPgto += "Tipo: "+Alltrim(aPedidos[__nX,18][__nY,02])+" - "+Alltrim(aPedidos[__nX,18][__nY,01])+"/"+Alltrim(aPedidos[__nX,18][__nY,03]) +CRLF
                                        
                                        If aPedidos[__nX,18][__nY,08] > 0
                                            cDetPgto += "Parcela(s): "+Alltrim(Str(aPedidos[__nX,18][__nY,08]))+CRLF
                                            nParcelas := aPedidos[__nX,18][__nY,08]
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,04])
                                            cDetPgto += "TID: "+Alltrim(aPedidos[__nX,18][__nY,04])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,06])
                                            cDetPgto += "ID Autorização: "+Alltrim(aPedidos[__nX,18][__nY,06])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,07])
                                            cDetPgto += "NSU: "+Alltrim(aPedidos[__nX,18][__nY,07])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,05])
                                            cDetPgto += "Mensagem: "+Alltrim(aPedidos[__nX,18][__nY,05])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,09])
                                            cDetPgto += "Numero Id Banco: "+Alltrim(aPedidos[__nX,18][__nY,09])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,18][__nY,10])
                                            cDetPgto += "Codigo de Barras: "+Alltrim(aPedidos[__nX,18][__nY,10])+CRLF
                                        EndIf
                                        cDetPgto+=CRLF+CRLF
                                    Next __nY

                                    Do Case
                                        Case Alltrim(aPedidos[__nX,18][01,02]) == "6"   // Boleto Bancario
                                            cFormPgto := "1"                                            

                                        Case Alltrim(aPedidos[__nX,18][01,02]) == "4"   // Cartao de Credito
                                            cFormPgto := "5"

                                        Case Alltrim(aPedidos[__nX,18][01,02]) == "16"  // Vale Presente
                                            cFormPgto := "4"

                                        Case Alltrim(aPedidos[__nX,18][01,02]) == "2"   // Cartão de Credito
                                            cFormPgto := "5"

                                        Case Alltrim(aPedidos[__nX,18][01,02]) == "125" // PIX
                                            cFormPgto := "3"
                                        
                                        Otherwise
                                            cFormPgto := "2"

                                    EndCase
                                Else
                                    cFormPgto := "2"
                                EndIf

                                nVlrTotal := 0
                                For __nY:=1 to Len(aPedidos[__nX,17])
                                    // Marcelo Celi - 13/03/2022
                                    //nVlrTotal += aPedidos[__nX,17][__nY,02] * aPedidos[__nX,17][__nY,03]
                                    nVlrTotal += (aPedidos[__nX,17][__nY,02] * aPedidos[__nX,17][__nY,03])-aPedidos[__nX,17][__nY,04]
                                Next __nY
                                nVlrTotal   := Round(nVlrTotal              ,Tamsx3("CK_VALOR")[02])
                                
                                // Marcelo Celi - 13/03/2022 
                                //nVlrParcela := Round(nVlrTotal / nParcelas  ,Tamsx3("CK_VALOR")[02])
                                nVlrParcela := Round((nVlrTotal+nVlrFrete) / nParcelas  ,Tamsx3("CK_VALOR")[02])

                                //->> Adequação do array de datas de recebimento
                                If cFormPgto == "5"
                                    dRecebiment := cDtAprov + 30
                                    For __nY:=1 to nParcelas
                                        aAdd(aDatPgto,{dRecebiment,nVlrParcela})
                                        dRecebiment += 30
                                    Next __nY                                    
                                Else
                                    dRecebiment := cDtAprov
                                    aAdd(aDatPgto,{dRecebiment,nVlrParcela})
                                EndIf
                                dPedido := cDtAprov
                                If Empty(dPedido)
                                    dPedido := dDatabase
                                EndIf

                                cDetEntrega := ""
                                If Len(aPedidos[__nX,20])>0
                                    For __nY:=1 to Len(aPedidos[__nX,20])
                                        If !Empty(aPedidos[__nX,20][__nY,01])
                                            cDetEntrega += "Correio: "+Alltrim(aPedidos[__nX,20][__nY,01])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,20][__nY,03])
                                            cDetEntrega += "Numero Rastreio: "+Alltrim(aPedidos[__nX,20][__nY,03])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,20][__nY,02])
                                            cDetEntrega += "Numero Fatura: "+Alltrim(aPedidos[__nX,20][__nY,02])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,20][__nY,04])
                                            cDetEntrega += "Chave Fatura: "+Alltrim(aPedidos[__nX,20][__nY,04])+CRLF
                                        EndIf
                                        If !Empty(aPedidos[__nX,20][__nY,05])
                                            cDetEntrega += "Valor Fatura: "+Alltrim(Transform(aPedidos[__nX,20][__nY,05],"@E 999,999,9999,999.99"))+CRLF
                                        EndIf
                                    Next __nY
                                EndIf

                                If u_MaEcOrcame(Ecommerce,          ; // 01 - Codigo do eCommerce
                                                aPedidos[__nX,01],  ; // 02 - Id do Pedido
                                                cCodigo,            ; // 03 - Codigo do Cliente
                                                cLoja,              ; // 04 - Loja do Cliente
                                                cFormPgto,          ; // 05 - Forma de Pagamento
                                                cDtPedido,          ; // 06 - Data do Pedido no Site
                                                cHrPedido,          ; // 07 - Hora do Pedido no Site
                                                aPedidos[__nX,17],  ; // 08 - Itens do Pedido
                                                @cErro,             ; // 09 - Mensagem de Erro
                                                cDetPgto,           ; // 10 - Detalhe do Pagamento
                                                aPedidos[__nX,21],  ; // 11 - Canal de Venda
                                                aDatPgto,           ; // 12 - Datas de Recebimento
                                                dPedido,            ; // 13 - Data efetiva do pedido
                                                cDetEntrega,        ; // 14 - Dados da Entrega
                                                NIL,                ; // 15 - Id da Venda
                                                aPedidos[__nX,21],  ; // 16 - Id do Canal
                                                aPedidos[__nX,22],  ; // 17 - Id Entrega
                                                aPedidos[__nX,23],  ; // 18 - Id Condicao de Pagamento
                                                aPedidos[__nX,24],  ; // 19 - Valor do Frete
                                                aPedidos[__nX,25],  ; // 20 - Transportadora
                                                aPedidos[__nX,28]   ) // 21 - Quem recebera o pedido 

                                    u_MAGrvLogI(cConex,,cEndPoint,,,"SCJ",1,xFilial("SCJ")+SCJ->CJ_NUM)
                                    u_MAGrvLogI(cConex,"S",,"Pedido gerado com sucesso sob id "+aPedidos[__nX,01])

                                    // Marcelo Celi - 03/03/2022
                                    cStConex := "ECVTEXSTPE" //->> Status de Preparando para Entrega
                                    If SobeStatus(SCJ->CJ_NUM,@cReqSt2Api,@cRetSt2Api,lJob,@oStResponse,"START-HANDLING")
                                        u_MAGrvLogI(cStConex,,cReqSt2Api,,,"SCJ",1,xFilial("SCJ")+SCJ->CJ_NUM)
                                        u_MAGrvLogI(cStConex,"S",,cRetSt2Api)
                                    Else
                                        u_MAGrvLogI(cStConex,,cReqSt2Api,,,"SCJ",1,xFilial("SCJ")+SCJ->CJ_NUM)
                                        u_MAGrvLogI(cStConex,"N",,cRetSt2Api)
                                    EndIf

                                Else
                                    If !Empty(cErro)
                                        u_MAGrvLogI(cConex,,cEndPoint,,,"SCJ",1,"id: "+aPedidos[__nX,01])
                                        u_MAGrvLogI(cConex,"N",,cErro)
                                    EndIf
                                EndIf
                            EndIf
                        EndIf
                    Next __nX
                    lRet := .T.

                    //->> Guarda a ultima data de processamento
                    If Len(aDatas)>0
                        cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
                        (Tb_Ecomm)->(dbSetOrder(1))
                        If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))                    
                            If aDatas[Len(aDatas)] > (Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC")
                                Reclock(Tb_Ecomm,.F.)                            
                                (Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC") := aDatas[Len(aDatas)]
                                (Tb_Ecomm)->(MsUNlock())
                            EndIf
                        EndIf
                    EndIf
                Else
                    lRet := .F.
                EndIf            
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

cReq2Api := cRequest
cRet2Api := cRetApi

Return lRet

/*/{protheus.doc} MaPvInVTex
*******************************************************************************************
Desce os pedidos do ecommerce

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPvInVTex()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "globo.PNG"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}
Local cCodigo       := ""

Private aRet01Param := {}

If Inicializar()
    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))                    
        If Empty((Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC"))
            aAdd( aRet01Param, Stod("") )
            aAdd( aRet01Param, Stod("") )                        
        Else
            aAdd( aRet01Param, (Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC") )
            aAdd( aRet01Param, Date() )
        EndIf
    Else
        aAdd( aRet01Param, Stod("") )
        aAdd( aRet01Param, Stod("") )
    EndIf
    
    //->> Marcelo Celi - 06/09/2022
    //aAdd( aRet01Param, .T.	    )    
    aAdd( aRet01Param, Space(120) )

    aAdd( aBox01Param,{1,"Data de"	        ,aRet01Param[01] ,"@!"			,""	,""	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Data ate"	        ,aRet01Param[02] ,"@!"			,""	,""	,".T.",070	,.F.})

    //->> Marcelo Celi - 06/09/2022
    aAdd( aBox01Param,{1,"Id Pedido Site"	,aRet01Param[03] ,""			,""	,""	,".T.",120	,.F.})
    
    oWizard := APWizard():New("Pedidos do V-Tex",                                  									                ;   // chTitle  - Titulo do cabecalho
                                "Informe as propriedades de descida de vendas do e-Commerce",                                             ;   // chMsg    - Mensagem do cabecalho
                                "Carga de Vendas",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                {|| lOk := MsgYesNo("Confirma a descida de carga de vendas ?"), lOk },                                 ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk := MsgYesNo("Confirma a descida de carga de vendas ?"), lOk },                                 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:OFINISH:CTITLE 	 := "&Descer"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        //->> Marcelo Celi - 06/09/2022
        //Processa( {|| DesceVendas(aRet01Param[01],aRet01Param[02],.F.) },"Aguarde" ,"Descendo Vendas do V-Tex...")
        Processa( {|| DesceVendas(aRet01Param[01],aRet01Param[02],.F.,aRet01Param[03]) },"Aguarde" ,"Descendo Vendas do V-Tex...")
    EndIf
EndIf

Return

/*/{protheus.doc} MaVTXDPrd
*******************************************************************************************
Retorna array com dados do produto no site

@author: Marcelo Celi Marques
@since: 26/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaVTXDPrd(cSku,cEndPAuxil)
Local lJob  := .T.
Local aResp := {}

aResp := GetProduto(cSku,lJob,cEndPAuxil)

Return aResp

/*/{protheus.doc} MaVdaVtex
*******************************************************************************************
Desce as Vendas do Vtex em Job

@author: Marcelo Celi Marques
@since: 08/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaVdaVtex(cEmp,cFil,dDataDe,dDataAte)
Local aArea     := {}
Local _cFilAnt  := ""
Local cCodigo   := ""

Default cEmp        := _cEmp
Default cFil        := _cFil
Default dDataDe     := Stod("")
Default dDataAte    := Stod("")

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil        
    Else
        aArea := GetArea()        
    EndIf

    If Inicializar()
        u_MaSetFilEC(Tb_Ecomm,Ecommerce)    
        _cFilAnt  := cFilAnt
        cFilAnt   := FilEcomm
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))

        If Empty(dDataDe)
            cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
            (Tb_Ecomm)->(dbSetOrder(1))
            If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))                    
                If aDatas[Len(aDatas)] > (Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC")            
                    dDataDe := (Tb_Ecomm)->&(Tb_Ecomm+"_ULTPRC")
                    dDataAte:= Date()
                EndIf
            EndIf
        Else
            If Empty(dDataAte)
                dDataAte := dDataDe
            EndIf
        EndIf

        If !Empty(dDataDe) .And. !Empty(dDataAte)
            DesceVendas(dDataDe,dDataAte,.T.)
        EndIf
    EndIf

    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf
EndIf

Return

//*****************************************************************************************************************
// MECANISMOS DE SUBIDA DE ESTOQUES
//*****************************************************************************************************************

/*/{protheus.doc} SobeEstoque
*******************************************************************************************
Inicializa as variaveis do sistema

@author: Marcelo Celi Marques
@since: 02/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SobeEstoque(cSKU,cReq2Api,cRet2Api,lJob,nQtdEnv)
Local lRet        := .F.
Local cEndPoint   := ""
Local cRequest    := ""
Local nTimeOut    := 0
Local oResponse   := NIL
Local cRetApi     := ""
//Local aProdInSite := {}
Local aSKUInSite  := {}
//->> Variaveis do produto
Local nIdProd     := 0  
// Variaveis do SKU
Local nEstoque    := 0
Local cIdArmaz    := "" // "EM_1"

Default lJob := .F.

nQtdEnv := 0

If Inicializar(lJob)    
    (Tb_Ecomm)->(dbSetOrder(1))
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+Ecommerce)) .And. (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"UES")) //->> Atualização de Estoque        
        If (Tb_Ecomm)->(FieldPos(Tb_Ecomm+"_ARMSIT"))>0
            cIdArmaz := Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_ARMSIT"))
        Else
            cIdArmaz := "EM_1"
        EndIf
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))        
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        If !Empty(cEndPoint)
            cSKU := PadR(cSKU,Tamsx3(Tb_Produ+"_SKU")[01])
            If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+cSKU))
                nIdProd := 0
                If (Tb_IDS)->(FieldPos(Tb_IDS+"_IDSKU"))>0
                    nIdProd := Val(Posicione(Tb_IDS,1,xFilial(Tb_IDS)+;
                                                  PadR(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])  +;
                                                  PadR("PRD"    ,Tamsx3(Tb_IDS+"_TIPO")[01])  +;
                                                  PadR(cSKU     ,Tamsx3(Tb_IDS+"_CHPROT")[01]),;
                                                  Tb_IDS+"_IDSKU"))
                EndIf

                If nIdProd == 0
                    //->> Verifica se produto ja existe no site                
                    aSKUInSite := GetSKU(Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU")),lJob)
                    If Len(aSKUInSite)==0
                        nIdProd   := 0                    
                    Else
                        nIdProd   := aSKUInSite[25]                    
                    EndIf
                EndIf    

                cEndPoint := Alltrim(cEndPoint)
                cEndPoint := StrTran(cEndPoint," ","")
                cEndPoint := Strtran(cEndPoint,"{sku_id}",Alltrim(Str(nIdProd)))
                cEndPoint := Strtran(cEndPoint,"{armazem_id}",Alltrim(cIdArmaz))
                                
                nEstoque := u_MaGetEstEc(cSKU,ecommerce)
	
                If nEstoque >= 999999999
                    cRequest := '{'                                         +CRLF
                    cRequest += '  "unlimitedQuantity": true,'              +CRLF
                    cRequest += '}'                                         +CRLF
                Else
                    cRequest := '{'                                         +CRLF
                    cRequest += '  "unlimitedQuantity": false,'             +CRLF
                    cRequest += '  "quantity": '+Alltrim(Str(nEstoque))     +CRLF
                    cRequest += '}'                                         +CRLF
                EndIf
                            
                lRet := ExecutConex("PUT",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)

                /*
                //->> Verifica se produto ja existe no site
                aProdInSite := GetProduto(cSku,lJob)
                If Len(aProdInSite)==0
                    nIdProd   := 0                    
                Else
                    nIdProd   := aProdInSite[01]                    
                EndIf

                cEndPoint := Alltrim(cEndPoint)
                cEndPoint := StrTran(cEndPoint," ","")
                cEndPoint := Strtran(cEndPoint,"{sku_id}",Alltrim(Str(nIdProd)))
                cEndPoint := Strtran(cEndPoint,"{armazem_id}",Alltrim(cIdArmaz))
                
                nEstoque := u_MaGetEstEc(cSKU,ecommerce)
	
                cRequest := '{'                                         +CRLF
                cRequest += '  "unlimitedQuantity": false,'             +CRLF
                cRequest += '  "quantity": '+Alltrim(Str(nEstoque))     +CRLF
                cRequest += '}'                                         +CRLF
                            
                lRet := ExecutConex("PUT",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                */

            Else
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

cReq2Api := cRequest
cRet2Api := cEndPoint + CRLF+CRLF+ cRetApi
nQtdEnv  := nEstoque

Return lRet

/*/{protheus.doc} MaEst2Vtex
*******************************************************************************************
Envia os estoques para o Vtex

@author: Marcelo Celi Marques
@since: 02/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEst2Vtex()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "ESTOMOVI.PNG"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}

Private aRet01Param := {}

If Inicializar()
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, .T.	                                )

    aAdd( aBox01Param,{1,"Produto de"	,aRet01Param[01] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Produto ate"	,aRet01Param[02] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    AADD( aBox01Param,{5,"Somente Estoques Pendentes de Envio?",aRet01Param[03],150,".T.",.F.})  

    oWizard := APWizard():New("Cargas no V-Tex",                                  									                    ;   // chTitle  - Titulo do cabecalho
                                "Informe as propriedades de subida de carga ao e-Commerce",                                             ;   // chMsg    - Mensagem do cabecalho
                                "Carga de Estoques",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                {|| lOk := MsgYesNo("Confirma a subida de carga de estoques ?"), lOk },                                 ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk := MsgYesNo("Confirma a subida de carga de estoques ?"), lOk },                                 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:OFINISH:CTITLE 	 := "&Enviar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        Processa( {|| u_MaEstVtex(NIL,NIL,aRet01Param[03],NIL,NIL,aRet01Param[01],aRet01Param[02]) },"Aguarde" ,"Subindo Estoques no Vtex...")
    EndIf
EndIf

Return

/*/{protheus.doc} MaEstVtex
*******************************************************************************************
Atualiza o cadastro de estoques com os dados no Vtex

@author: Marcelo Celi Marques
@since: 08/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaEstVtex(cEmp,cFil,lNovo,cMsgConexao,cNickName,cProdDe,cProdAte)
Local cConex    := "ECVTEXGEST"
Local lJob      := .F.
Local aArea     := {}
Local cQuery    := ""
Local cAlias    := ""
Local nTotRegs  := 0
Local lUsarRot  := .T.
Local nTimer    := 0
Local _cFilAnt  := ""
Local nRecRegist:= 0
Local cReq2Api  := ""
Local cRet2Api  := ""
Local nQtdEnv   := 0
Local cDtAtualz := ""
Local cArmazem  := Armazem

Default cEmp        := _cEmp
Default cFil        := _cFil
Default lNovo       := .T.
Default cMsgConexao := ""
Default cNickName   := ""
Default cProdDe     := ""
Default cProdAte    := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
            cProdDe  := Replicate(" ",Tamsx3(Tb_Estru+"_SKU")[01])
            cProdAte := Replicate("Z",Tamsx3(Tb_Estru+"_SKU")[01])
        Else
            Return
        EndIf    
    Else
        aArea    := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    //->> Registra a entrada na rotina
    nRecRegist := u_MARegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Estoques...")       
    EndIf
    cAlias := GetNextAlias()

    If lNovo        
        cQuery := "SELECT DISTINCT SKU FROM ("                                                                  +CRLF
        cQuery += "   SELECT "+Tb_Estru+"."+Tb_Estru+"_SKU                   AS SKU,"                           +CRLF 
        cQuery += "          "+Tb_Estru+"."+Tb_Estru+"_COD                   AS PRODUTO,"                       +CRLF
        cQuery += "          ISNULL(SUM(SB2.B2_QATU - SB2.B2_QEMP - SB2.B2_RESERVA),0) AS QTDATU,"              +CRLF
        cQuery += "          ISNULL("+Tb_IDS+"."+Tb_IDS+"_ULTQTD,0)          AS ULTQTD"                         +CRLF
        cQuery += "      FROM "+RetSqlName(Tb_Estru)+" "+Tb_Estru+" (NOLOCK)"                                   +CRLF
        cQuery += "      LEFT JOIN "+RetSqlName("SB2")+" SB2 (NOLOCK)"                                          +CRLF
        cQuery += "        ON  SB2.B2_FILIAL = '"+xFilial("SB2")+"'"                                            +CRLF
        cQuery += "        AND SB2.B2_COD = "+Tb_Estru+"."+Tb_Estru+"_COD"                                      +CRLF 
        cQuery += "        AND SB2.B2_LOCAL = '"+cArmazem+"'"                                                   +CRLF
        cQuery += "        AND SB2.D_E_L_E_T_ = ' '"                                                            +CRLF
        cQuery += "      INNER JOIN "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                             +CRLF
        cQuery += "         ON "+Tb_Produ+"."+Tb_Produ+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"             +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_SKU    = "+Tb_Estru+"."+Tb_Estru+"_SKU"                +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                         +CRLF
        cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                         +CRLF
        cQuery += "        AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                   +CRLF
        cQuery += "      LEFT JOIN "+RetSqlName(Tb_IDS)+" "+Tb_IDS+" (NOLOCK)"                                  +CRLF
        cQuery += "         ON "+Tb_IDS+"."+Tb_IDS+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"                 +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_CHPROT = "+Tb_Estru+"."+Tb_Estru+"_SKU"                    +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_TIPO = 'EST'"                                              +CRLF
        cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_ECOM = '"+Ecommerce+"'"                                    +CRLF
        cQuery += "      WHERE "+Tb_Estru+"."+Tb_Estru+"_FILIAL = '"+xFilial(Tb_Estru)+"'"                      +CRLF
        cQuery += "        AND SB2.B2_LOCAL = '"+Armazem+"'"                                                    +CRLF
        If !Empty(cProdAte)
            cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"           +CRLF
        ElseIf !Empty(cProdDe)
            cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU = '"+cProdDe+"'"                                    +CRLF
        EndIf
        cQuery += "        AND "+Tb_Estru+".D_E_L_E_T_ = ' '"                                                   +CRLF
        cQuery += "     GROUP BY "+Tb_Estru+"_SKU, "+Tb_Estru+"_COD,"+Tb_IDS+"_ULTQTD) AS TMP"                  +CRLF
        cQuery += " WHERE TMP.QTDATU <> TMP.ULTQTD"                                                             +CRLF
        cQuery += " ORDER BY SKU"                                                                               +CRLF
    Else
        cQuery := "   SELECT "+Tb_Produ+"."+Tb_Produ+"_SKU                   AS SKU"                            +CRLF 
        cQuery += "      FROM "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                                   +CRLF
        cQuery += "      WHERE "+Tb_Produ+"."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"                      +CRLF
        If !Empty(cProdAte)
            cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"           +CRLF
        ElseIf !Empty(cProdDe)
            cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU = '"+cProdDe+"'"                                    +CRLF
        EndIf
        cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                          +CRLF
        cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                          +CRLF        
        cQuery += "       AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                    +CRLF
        cQuery += " ORDER BY "+Tb_Produ+"_SKU"                                                                  +CRLF
    EndIf

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
    (cAlias)->(dbGotop())
    If !isBlind()
        ProcRegua(nTotRegs)            
    EndIf
    
    Do While (cAlias)->(!Eof())
        If !isBlind()            
            IncProc("Atualizando Estoques no Vtex...")       
        EndIf        
        cReq2Api := ""
        cRet2Api := ""        
        If SobeEstoque((cAlias)->SKU,@cReq2Api,@cRet2Api,lJob,@nQtdEnv)
            u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(cAlias)->SKU)
            u_MAGrvLogI(cConex,"S",,cRet2Api)

            cDtAtualz := StrZero(Day(Date()),2)+"/"+StrZero(Month(Date()),2)+"/"+StrZero(Year(Date()),4)+"  "+Time()

            (Tb_IDS)->(dbSetOrder(1))
            If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"EST"+(Tb_Produ)->&(Tb_Produ+"_SKU")))
                Reclock(Tb_IDS,.T.)
            Else    
                Reclock(Tb_IDS,.F.)
            EndIf
            (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
            (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
            (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "EST"
            (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := (Tb_Produ)->&(Tb_Produ+"_SKU")
            (Tb_IDS)->&(Tb_IDS+"_ULTQTD")   := nQtdEnv            
            (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
            (Tb_IDS)->&(Tb_IDS+"_ULTENV")   := cDtAtualz
            (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
            (Tb_IDS)->(MsUnlock())
        Else
            u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(cAlias)->SKU)
            u_MAGrvLogI(cConex,"N",,cRet2Api)
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    //->> Fecha o Registro da entrada na rotina
    u_MAUnRegMon(nRecRegist)
    
    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

//*****************************************************************************************************************
// MECANISMOS DE SUBIDA DE PREÇOS
//*****************************************************************************************************************

/*/{protheus.doc} MaPrc2Vtex
*******************************************************************************************
Envia os preços para o Vtex

@author: Marcelo Celi Marques
@since: 02/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPrc2Vtex()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "LJPRECO.PNG"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}

Private aRet01Param := {}

If Inicializar()
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
    aAdd( aRet01Param, .T.	                                )

    aAdd( aBox01Param,{1,"Produto de"	,aRet01Param[01] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Produto ate"	,aRet01Param[02] ,"@!"			,""	,Tb_Produ	,".T.",070	,.F.})
    AADD( aBox01Param,{5,"Somente Preços Pendentes de Envio?",aRet01Param[03],150,".T.",.F.})  

    oWizard := APWizard():New("Cargas no V-Tex",                                  									                ;   // chTitle  - Titulo do cabecalho
                                "Informe as propriedades de subida de carga ao e-Commerce",                                             ;   // chMsg    - Mensagem do cabecalho
                                "Carga de Preços",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                {|| lOk := MsgYesNo("Confirma a subida de carga de preços ?"), lOk },                                 ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk := MsgYesNo("Confirma a subida de carga de preços ?"), lOk },                                 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:OFINISH:CTITLE 	 := "&Enviar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        Processa( {|| u_MaPrcVtex(NIL,NIL,aRet01Param[03],NIL,NIL,aRet01Param[01],aRet01Param[02]) },"Aguarde" ,"Subindo Preços no Vtex...")
    EndIf
EndIf

Return

/*/{protheus.doc} MaPrcVtex
*******************************************************************************************
Atualiza o cadastro de preços com os dados no vtex

@author: Marcelo Celi Marques
@since: 02/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPrcVtex(cEmp,cFil,lNovo,cMsgConexao,cNickName,cProdDe,cProdAte)
Local cConex    := "ECVTEXGPRC"
Local lJob      := .F.
Local aArea     := {}
Local cQuery    := ""
Local cAlias    := ""
Local nTotRegs  := 0
Local lUsarRot  := .T.
Local nTimer    := 0
Local _cFilAnt  := ""
Local nRecRegist:= 0
Local cReq2Api  := ""
Local cRet2Api  := ""
Local oResponse := NIL
Local cCodigo   := ""
Local nPrcEnv   := 0
Local cDtAtualz := ""
Local cTabsPrc  := ""

Default cEmp        := _cEmp
Default cFil        := _cFil
Default lNovo       := .T.
Default cMsgConexao := ""
Default cNickName   := ""
Default cProdDe     := ""
Default cProdAte    := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
            cProdDe  := Replicate(" ",Tamsx3(Tb_Estru+"_SKU")[01])
            cProdAte := Replicate("Z",Tamsx3(Tb_Estru+"_SKU")[01])
        Else
            Return
        EndIf    
    Else
        aArea    := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    //->> Registra a entrada na rotina
    nRecRegist := u_MARegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Preços...")       
    EndIf
    cAlias := GetNextAlias()

    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))
        If lNovo        
            cTabsPrc := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
            (Tb_Canal)->(dbGotop())
            Do While (Tb_Canal)->(!Eof())
                If (Tb_Canal)->&(Tb_Canal+"_FILIAL")==xFilial(Tb_Canal) .And. Alltrim((Tb_Canal)->&(Tb_Canal+"_ECOMME"))==Alltrim(cCodigo)
                    If !Empty((Tb_Canal)->&(Tb_Canal+"_TABPRC"))
                        If !Empty(cTabsPrc)
                            cTabsPrc += ";"
                        EndIf
                        cTabsPrc += (Tb_Canal)->&(Tb_Canal+"_TABPRC")
                    EndIf
                EndIf
                (Tb_Canal)->(dbSkip())
            EndDo
            If Empty(cTabsPrc)
                cTabsPrc := "***"
            EndIf

            cQuery := "SELECT DISTINCT SKU FROM ("                                                                                                      +CRLF
            cQuery += "   SELECT "+Tb_Estru+"."+Tb_Estru+"_SKU                   AS SKU,"                                                               +CRLF 
            cQuery += "          "+Tb_Estru+"."+Tb_Estru+"_COD                   AS PRODUTO,"                                                           +CRLF
            cQuery += "          ISNULL(((DA1.DA1_PRCVEN - DA1.DA1_VLRDES) - ((DA1.DA1_PRCVEN - DA1.DA1_VLRDES) * (DA1.DA1_PERDES/100))),0) AS PRECO,"  +CRLF
            cQuery += "          ISNULL("+Tb_IDS+"."+Tb_IDS+"_PRCVEN,0)         AS ULTVLR"                                                              +CRLF
            cQuery += "      FROM "+RetSqlName(Tb_Estru)+" "+Tb_Estru+" (NOLOCK)"                                                                       +CRLF
            cQuery += "      LEFT JOIN "+RetSqlName("DA1")+" DA1 (NOLOCK)"                                                                              +CRLF
            cQuery += "        ON  DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"                                                                               +CRLF
            cQuery += "        AND DA1.DA1_CODPRO = "+Tb_Estru+"."+Tb_Estru+"_COD"                                                                      +CRLF 
            cQuery += "        AND DA1.DA1_CODTAB IN "+FormatIn(cTabsPrc,";")                                                                           +CRLF 
            cQuery += "        AND DA1.D_E_L_E_T_ = ' '"                                                                                                +CRLF
            cQuery += "      INNER JOIN "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                                                                 +CRLF
            cQuery += "         ON "+Tb_Produ+"."+Tb_Produ+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"                                                 +CRLF
            cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_SKU    = "+Tb_Estru+"."+Tb_Estru+"_SKU"                                                    +CRLF
            cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                                                             +CRLF
            cQuery += "        AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                                                             +CRLF
            cQuery += "        AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                                                       +CRLF
            cQuery += "      LEFT JOIN "+RetSqlName(Tb_IDS)+" "+Tb_IDS+" (NOLOCK)"                                                                      +CRLF
            cQuery += "         ON "+Tb_IDS+"."+Tb_IDS+"_FILIAL = "+Tb_Estru+"."+Tb_Estru+"_FILIAL"                                                     +CRLF
            cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_CHPROT = "+Tb_Estru+"."+Tb_Estru+"_SKU"                                                        +CRLF
            cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_TIPO = 'PRC'"                                                                                  +CRLF
            cQuery += "        AND "+Tb_IDS+"."+Tb_IDS+"_ECOM = '"+Ecommerce+"'"                                                                        +CRLF
            cQuery += "      WHERE "+Tb_Estru+"."+Tb_Estru+"_FILIAL = '"+xFilial(Tb_Estru)+"'"                                                          +CRLF            
            If !Empty(cProdAte)
                cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"                                               +CRLF
            ElseIf !Empty(cProdDe)
                cQuery += "   AND "+Tb_Estru+"."+Tb_Estru+"_SKU = '"+cProdDe+"'"                                                                        +CRLF
            EndIf
            cQuery += "        AND "+Tb_Estru+".D_E_L_E_T_ = ' '"                                                                                       +CRLF
            cQuery += "     GROUP BY "+Tb_Estru+"_SKU, "+Tb_Estru+"_COD,"+Tb_IDS+"_PRCVEN,DA1_PRCVEN,DA1_VLRDES,DA1_PERDES) AS TMP"                     +CRLF
            cQuery += " WHERE TMP.PRECO <> TMP.ULTVLR"                                                                                                  +CRLF
            cQuery += " ORDER BY SKU"                                                                                                                   +CRLF
        Else
            cQuery := "   SELECT "+Tb_Produ+"."+Tb_Produ+"_SKU                   AS SKU"                                                                +CRLF 
            cQuery += "      FROM "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                                                                       +CRLF
            cQuery += "      WHERE "+Tb_Produ+"."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"                                                          +CRLF
            If !Empty(cProdAte)
                cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"                                               +CRLF
            ElseIf !Empty(cProdDe)
                cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_SKU = '"+cProdDe+"'"                                                                        +CRLF
            EndIf
            cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_MSBLQL <> '1'"                                                                              +CRLF
            cQuery += "       AND "+Tb_Produ+"."+Tb_Produ+"_ATUSIT  = '1'"                                                                              +CRLF        
            cQuery += "       AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                                                                        +CRLF
            cQuery += " ORDER BY "+Tb_Produ+"_SKU"                                                                                                      +CRLF
        EndIf

        DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
        dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
        (cAlias)->(dbGotop())

        If !isBlind()
            ProcRegua(nTotRegs)            
        EndIf
    
        Do While (cAlias)->(!Eof())
            If !isBlind()            
                IncProc("Atualizando Preços no V-Tex...")       
            EndIf            
            cReq2Api := ""
            cRet2Api := ""        
            If SobePreco((cAlias)->SKU,@cReq2Api,@cRet2Api,lJob,@nPrcEnv)
                u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(Tb_Produ)->&(Tb_Produ+"_SKU"))
                u_MAGrvLogI(cConex,"S",,cRet2Api)

                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRC"+(Tb_Produ)->&(Tb_Produ+"_SKU")))
                    Reclock(Tb_IDS,.T.)
                Else    
                    Reclock(Tb_IDS,.F.)
                EndIf

                cDtAtualz := StrZero(Day(Date()),2)+"/"+StrZero(Month(Date()),2)+"/"+StrZero(Year(Date()),4)+"  "+Time()

                (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRC"
                (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := (Tb_Produ)->&(Tb_Produ+"_SKU")
                (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := nPrcEnv            
                (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                (Tb_IDS)->&(Tb_IDS+"_ULTENV")   := cDtAtualz
                (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                (Tb_IDS)->(MsUnlock())
            Else
                u_MAGrvLogI(cConex,,cReq2Api,,,Tb_Produ,1,xFilial(Tb_Produ)+(Tb_Produ)->&(Tb_Produ+"_SKU"))
                u_MAGrvLogI(cConex,"N",,cRet2Api)
            EndIf
            (cAlias)->(dbSkip())
        EndDo
        //->> Fecha o Registro da entrada na rotina
        u_MAUnRegMon(nRecRegist)        
    EndIf

    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

/*/{protheus.doc} SobePreco
*******************************************************************************************
Subida de preços ao ecommerce

@author: Marcelo Celi Marques
@since: 02/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SobePreco(cSKU,cReq2Api,cRet2Api,lJob,nPrcEnv)
Local lRet        := .F.
Local cEndPoint   := ""
Local cRequest    := ""
Local nTimeOut    := 0
Local oResponse   := NIL
Local cRetApi     := ""
Local aProdInSite := {}
Local aSKUInSite  := {}  
//->> Variaveis do produto
Local nIdProd     := 0  
// Variaveis do SKU
Local nValor      := 0
Local nVlrDesc    := 0
Local nPcDscCan   := 0
Local cUrl        := ""
Local aTbCanais   := {}
Local nX          := 1  

Default lJob := .F.

nPrcEnv := 0

If Inicializar(lJob)
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"UPC")) //->> Atualização de Estoque
        cUrl      := Alltrim((Tb_Conex)->&(Tb_Conex+"_URL"))
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf
        If !Empty(cEndPoint)
            cSKU := PadR(cSKU,Tamsx3(Tb_Produ+"_SKU")[01])
            If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+cSKU))
                nIdProd := 0
                If (Tb_IDS)->(FieldPos(Tb_IDS+"_IDSKU"))>0
                    nIdProd := Val(Posicione(Tb_IDS,1,xFilial(Tb_IDS)+;
                                            PadR(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])  +;
                                            PadR("PRD"    ,Tamsx3(Tb_IDS+"_TIPO")[01])  +;
                                            PadR(cSKU     ,Tamsx3(Tb_IDS+"_CHPROT")[01]),;
                                            Tb_IDS+"_IDSKU"))
                EndIf
                
                If nIdProd == 0
                    //->> Verifica se produto ja existe no site                
                    aSKUInSite := GetSKU(Alltrim(cSku),lJob)
                    If Len(aSKUInSite)==0
                        nIdProd   := 0                    
                    Else
                        nIdProd   := aSKUInSite[25]                    
                    EndIf
                EndIf
                                
                //->> Verifica se produto ja existe no site
                //aProdInSite := GetProduto(cSku,lJob)
                //If Len(aProdInSite)==0
                //    nIdProd   := 0                    
                //Else
                //    nIdProd   := aProdInSite[01]                    
                //EndIf

                //->> Atualização dos Preços nos Canais de Vendas                
                cCodEcomm := PadR(Ecommerce,Tamsx3(Tb_Canal+"_ECOMME")[01])
                (Tb_TbPrc)->(dbSetOrder(2))
                (Tb_TbPrc)->(dbSeek(xFilial(Tb_TbPrc)+cSKU+cCodEcomm))
                Do While (Tb_TbPrc)->(!Eof()) .And. (Tb_TbPrc)->&(Tb_TbPrc+"_FILIAL") + (Tb_TbPrc)->&(Tb_TbPrc+"_SKU") + (Tb_TbPrc)->&(Tb_TbPrc+"_ECOMME") == xFilial(Tb_TbPrc)+cSKU+PadR(Ecommerce,Tamsx3(Tb_Canal+"_ECOMME")[01])
                    (Tb_Canal)->(dbSetOrder(1))
                    If (Tb_Canal)->(dbSeek(xFilial(Tb_Canal)+cCodEcomm+(Tb_TbPrc)->&(Tb_TbPrc+"_CODIGO") ))
                        If (Tb_Canal)->&(Tb_Canal+"_MSBLQL") <> "1"
                            nPcDscCan := (Tb_TbPrc)->&(Tb_TbPrc+"_PCDESC")                                
                            nValor    := u_MaGetVlrEc(Alltrim(cSKU),Ecommerce,Nil,(Tb_Canal)->&(Tb_Canal+"_TABPRC"))
                            nVlrDesc := nValor
                            nVlrDesc := nVlrDesc - (nVlrDesc*(nPcDscCan/100))

                            aAdd(aTbCanais,{(Tb_Canal)->&(Tb_Canal+"_IDECOM"),                      ; // 01 - Codigo do Canal                                            
                                            nValor,                                                 ; // 02 - Preço
                                            nVlrDesc}                                               ) // 03 - Preço Especial
                        EndIf
                    EndIf    
                    (Tb_TbPrc)->(dbSkip())
                EndDo

                cEndPoint := Lower(cEndPoint)
                cEndPoint := Alltrim(cEndPoint)+"/"+Alltrim(Str(nIdProd))
                
                nValor   := u_MaGetVlrEc(cSKU,Ecommerce,NIL,NIL,.F.)
                nVlrDesc := u_MaGetVlrEc(cSKU,Ecommerce,NIL,NIL,.T.)

                cRequest := '{'                                         +CRLF
                cRequest += '  "markup": '   +Alltrim(Str(nVlrDesc))+','+CRLF
                cRequest += '  "listPrice": '+Alltrim(Str(nVlrDesc))+','+CRLF
                cRequest += '  "basePrice": '+Alltrim(Str(nValor))
                If Len(aTbCanais)>0
                    cRequest += ','+CRLF
                    cRequest += '  "fixedPrices": ['                    +CRLF
                    For nX:=1 to Len(aTbCanais)
                        If nX > 1
                            cRequest += ','
                        EndIf
                        cRequest += '{'
                        cRequest += '  "tradePolicyId": "'+Alltrim(aTbCanais[nX,01])+'",'    +CRLF
                        cRequest += '  "value": '         +Alltrim(Str(aTbCanais[nX,02]))+','+CRLF
                        cRequest += '  "listPrice": '     +Alltrim(Str(aTbCanais[nX,03]))    +CRLF
                        cRequest += '}'
                    Next nX
                    cRequest += ']'
                Else
                    cRequest +=                                          CRLF
                EndIf
                cRequest += '}'                                         +CRLF
                           
                lRet := ExecutConex("PUT",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob,cUrl)
            Else
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

cReq2Api := cRequest
cRet2Api := cEndPoint + CRLF+CRLF+ cRetApi
nPrcEnv  := nValor

Return lRet

//*****************************************************************************************************************
// MECANISMOS DE SUBIDA DE STATUS
//*****************************************************************************************************************

/*/{protheus.doc} MaSta2Vtex
*******************************************************************************************
Envia os status para o Vtex

@author: Marcelo Celi Marques
@since: 08/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaSta2Vtex()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "puzzle.PNG"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}

Private aRet01Param := {}

If Inicializar()
    FilEcomm := u_MaSetFilEC(Tb_Ecomm,Ecommerce)
    aAdd( aRet01Param, Replicate(" ",Tamsx3("CJ_NUM")[01]) )
    aAdd( aRet01Param, Replicate(" ",Tamsx3("CJ_NUM")[01]) )
    aAdd( aRet01Param, .T.	                                )

    aAdd( aBox01Param,{1,"Orçamento de"	,aRet01Param[01] ,"@!"			,""	,""	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Orçamento ate",aRet01Param[02] ,"@!"			,""	,""	,".T.",070	,.F.})
    AADD( aBox01Param,{5,"Somente Orçamentos Pendentes de Envio?",aRet01Param[03],150,".T.",.F.})  

    oWizard := APWizard():New("Cargas no Vtex",                                  									                ;   // chTitle  - Titulo do cabecalho
                                "Informe as propriedades de subida de carga ao e-Commerce",                                             ;   // chMsg    - Mensagem do cabecalho
                                "Carga de Status",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                {|| lOk := MsgYesNo("Confirma a subida de carga de status ?"), lOk },                                 ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                {|| lOk := MsgYesNo("Confirma a subida de carga de status ?"), lOk },                                 ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:OFINISH:CTITLE 	 := "&Enviar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        Processa( {|| u_MaStaVtex(NIL,NIL,aRet01Param[03],NIL,NIL,aRet01Param[01],aRet01Param[02]) },"Aguarde" ,"Subindo Status de Vendas no Vtex...")
    EndIf
EndIf

Return

/*/{protheus.doc} MaStaVtex
*******************************************************************************************
Atualiza os status das vendas no Vtex

@author: Marcelo Celi Marques
@since: 27/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaStaVtex(cEmp,cFil,lNovo,cMsgConexao,cNickName,cOrcDe,cOrcAte)
Local cConex    := "ECVTEXUSTA"
Local lJob      := .F.
Local aArea     := {}
Local cQuery    := ""
Local cAlias    := ""
Local nTotRegs  := 0
Local lUsarRot  := .T.
Local nTimer    := 0
Local _cFilAnt  := ""
Local nRecRegist:= 0
Local cReq2Api  := ""
Local cRet2Api  := ""
Local oResponse := NIL
Local cSerMLivr := ""
Local aRetNotas := ""

Default cEmp        := _cEmp
Default cFil        := _cFil
Default lNovo       := .T.
Default cMsgConexao := ""
Default cNickName   := ""
Default cOrcDe      := ""
Default cOrcAte     := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
            cOrcDe  := Replicate(" ",Tamsx3("CJ_NUM")[01])
            cOrcAte := Replicate("Z",Tamsx3("CJ_NUM")[01])
        Else
            Return
        EndIf    
    Else
        aArea    := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    cSerMLivr := Alltrim(GetNewPar("BO_SERMLIV","3"))

    //->> Registra a entrada na rotina
    nRecRegist := u_MARegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Status...")       
    EndIf
    cAlias := GetNextAlias()

    cCodigo := PadR(Ecommerce,Tamsx3(Tb_Ecomm+"_CODIGO")[01])
    (Tb_Ecomm)->(dbSetOrder(1))
    If (Tb_Ecomm)->(dbSeek(xFilial(Tb_Ecomm)+cCodigo))
        cQuery := "SELECT SCJ.CJ_NUM FROM "+RetSqlName("SCJ")+" SCJ (NOLOCK)"   +CRLF
        cQuery += " WHERE SCJ.CJ_FILIAL = '"+xFilial("SCJ")+"'"                 +CRLF
        cQuery += "   AND SCJ.CJ_XORIGEM = '"+Ecommerce+"'"                     +CRLF
        cQuery += "   AND SCJ.CJ_NUM BETWEEN '"+cOrcDe+"' AND '"+cOrcAte+"'"    +CRLF      
        If lNovo
            cQuery += "   AND SCJ.CJ_XENVSTA = ' '"                             +CRLF
        EndIf
        cQuery += "   AND SCJ.D_E_L_E_T_ = ' '"                                 +CRLF
        cQuery += " ORDER BY CJ_NUM"                                            +CRLF

        DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
        dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
        (cAlias)->(dbGotop())

        If !isBlind()
            ProcRegua(nTotRegs)            
        EndIf
        
        Do While (cAlias)->(!Eof())
            If !isBlind()            
                IncProc("Atualizando Status no Vtex...")       
            EndIf            
            cReq2Api := ""
            cRet2Api := ""    

            aRetNotas := u_MaEcNFGet((cAlias)->CJ_NUM,Tb_Ecomm,Ecommerce)
            If Len(aRetNotas)>0 .And. Alltrim(aRetNotas[1,2]) <> cSerMLivr
                If SobeStatus((cAlias)->CJ_NUM,@cReq2Api,@cRet2Api,lJob,@oResponse,"INVOICE")
                    u_MAGrvLogI(cConex,,cReq2Api,,,"SCJ",1,xFilial("SCJ")+(cAlias)->CJ_NUM)
                    u_MAGrvLogI(cConex,"S",,cRet2Api)
                Else
                    u_MAGrvLogI(cConex,,cReq2Api,,,"SCJ",1,xFilial("SCJ")+(cAlias)->CJ_NUM)
                    u_MAGrvLogI(cConex,"N",,cRet2Api)
                EndIf
            EndIf
            (cAlias)->(dbSkip())
        EndDo
        //->> Fecha o Registro da entrada na rotina
        u_MAUnRegMon(nRecRegist)
    EndIf

    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

/*/{protheus.doc} SobeStatus
*******************************************************************************************
Sobe o status do pedido no site

@author: Marcelo Celi Marques
@since: 27/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SobeStatus(cOrcamento,cReq2Api,cRet2Api,lJob,oResp2Ret,cTipo)
Local lRet        := .F.
Local cEndPoint   := ""
Local cRequest    := ""
Local nTimeOut    := 0
Local oResponse   := NIL
Local cRetApi     := ""
Local aNF         := {}

Default lJob  := .F.
Default cTipo := "INVOICE"

cTipo := Upper(Alltrim(cTipo))

If Inicializar(lJob)
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"UST")) //->> subida de status
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        If Len(cEndPoint)>1
            If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
            EndIf
        EndIf

        If !Empty(cEndPoint)
            SCJ->(dbSetOrder(1))
            If SCJ->(dbSeek(xFilial("SCJ")+cOrcamento))
                If cTipo == "INVOICE"
                    aNF := u_MaEcNFGet(SCJ->CJ_NUM,Tb_Ecomm,Ecommerce)
                    If Len(aNF)>0
                        
                        //->> Marcelo Celi - 28/02/2022
                        cRequest := '{'+CRLF
                        cRequest += '   "items": ['+CRLF
                        cRequest += '            ],'+CRLF
                        cRequest += '   "courier": null,'+CRLF
                        cRequest += '   "invoiceNumber": "'+aNF[1,1]+'",'+CRLF
                        cRequest += '   "invoiceValue": '+Alltrim(Str(aNF[1,4] * 100 ))+','+CRLF                    
                        cRequest += '   "invoiceUrl": "https://www.nfe.fazenda.gov.br/portal/principal.aspx",'+CRLF
                        cRequest += '   "issuanceDate": "'+StrZero(Year(aNF[1,3]),4)+'-'+StrZero(Month(aNF[1,3]),2)+'-'+StrZero(Day(aNF[1,3]),2)+'",'+CRLF
                        cRequest += '   "trackingNumber": null,'+CRLF

                        If !Empty(aNF[1,6])
                            cRequest += '"invoiceKey": "'+aNF[1,6]+'",'                                                                             +CRLF
                        Else
                            cRequest += '"invoiceKey": null,'                                                                                       +CRLF
                        EndIf
                        
                        cRequest += '   "trackingUrl": null,'+CRLF
                        cRequest += '   "embeddedInvoice": "",'+CRLF
                        cRequest += '   "type": "Output",'+CRLF
                        cRequest += '   "courierStatus": null,'+CRLF
                        cRequest += '   "cfop": null,'+CRLF
                        cRequest += '   "restitutions": {},'+CRLF
                        cRequest += '   "volumes": null,'+CRLF
                        cRequest += '   "EnableInferItems": null'+CRLF
                        cRequest += '}'+CRLF
                        
                        cEndPoint += "/"+Alltrim(SCJ->CJ_XIDINTG)+"/invoice"
                                    
                        lRet := ExecutConex("POST",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                        If lRet
                            Reclock("SCJ",.F.)
                            SCJ->CJ_XSTATUS := "1"
                            SCJ->CJ_XENVSTA := StrZero(Day(Date()),2)+"/"+StrZero(Month(Date()),2)+"/"+StrZero(Year(Date()),4)+" "+Time()
                            SCJ->(MsUnlock())
                        EndIf
                    Else
                        lRet := .F.
                    EndIf    
                
                ElseIf cTipo == "START-HANDLING"
                    cEndPoint += "/"+Alltrim(SCJ->CJ_XIDINTG)+"/start-handling"
                    lRet := ExecutConex("POST",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
                    


                EndIf
            Else
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

If cTipo == "INVOICE"
    If Len(aNF)>0
        cReq2Api  := "Requisição em: "+cEndPoint+CRLF+CRLF+CRLF+cRequest
        cRet2Api  := "Resposta de Envio de Status:"+CRLF+CRLF+cRetApi
        oResp2Ret := oResponse
    Else
        cReq2Api  := "Não houve Requisição pois o pedido não foi faturado"
        cRet2Api  := "Resposta de Envio de Status: Pedido não Faturado"
        oResp2Ret := oResponse
    EndIf
Else
    cReq2Api  := "Requisição em: "+cEndPoint+CRLF+CRLF+CRLF+cRequest
    cRet2Api  := "Resposta de Envio de Status:"+CRLF+CRLF+cRetApi
    oResp2Ret := oResponse
EndIf

Return lRet

/*/{protheus.doc} MaPrdByVtx
*******************************************************************************************
Baixa os produtos do vtex

@author: Marcelo Celi Marques
@since: 04/03/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPrdByVtx()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "produto.png"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}
Local nOpc          := 0
Local cMsg          := ""

Private aRet01Param := {}

If Inicializar()
    u_MaSetFilEC(Tb_Ecomm,Ecommerce)
    FilEcomm := cFilAnt

    cMsg := "Para a Descida da Carga de Produtos, favor selecionar o tipo de descida abaixo:"+CRLF+CRLF+CRLF
    cMsg += "Pelo Protheus: As cargas terão como base a busca pelo cadastro de produtos no protheus."+CRLF+"Esta opção é mais demorada, porém varre todo o cadastro em busca de produtos disponíveis no site."+CRLF+CRLF
    cMsg += "Pelo Site: As cargas terão como base a busca pelo site."+CRLF+"Esta opção considera a baixa de produtos KIT, se estes estiverem cadastrados no catálogo."

    nOpc := AVISO("Descida de Carga de Produto", cMsg, {"Buscar Pelo Protheus","Buscar Pelo Site","Cancelar"},3,,,,.t.)	
    
    If nOpc == 1
        aAdd( aRet01Param, Replicate(" ",Tamsx3(Tb_Produ+"_SKU")[01]) )
        aAdd( aRet01Param, Replicate("Z",Tamsx3(Tb_Produ+"_SKU")[01]) )
        aAdd( aRet01Param, .T. )

        aAdd( aBox01Param,{1,"Produto de"	,aRet01Param[01] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        aAdd( aBox01Param,{1,"Produto ate"	,aRet01Param[02] ,"@!"			,""	,"SB1"	,".T.",070	,.F.})
        AADD( aBox01Param,{5,"Somente Produtos Pendentes de Baixa?",aRet01Param[03],150,".T.",.F.})  

        oWizard := APWizard():New("Cargas do VTex",                                  									                    ;   // chTitle  - Titulo do cabecalho
                                    "Avance clicando em Baixar para fazer o Download dos Produtos do Vtex.",                                ;   // chMsg    - Mensagem do cabecalho
                                    "Carga de Produtos",                                                                                    ;   // cTitle   - Titulo do painel de apresentacao
                                    "",             													         	                        ;   // cText    - Texto do painel de apresentacao
                                    {|| lOk := MsgYesNo("Confirma a Descida de carga de produtos ?"), lOk },                                ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                                    {|| lOk := MsgYesNo("Confirma a Descida de carga de produtos ?"), lOk },                                ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                                    .T.,             												     			                        ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                                    cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                                    {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                                    .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                                    aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

        oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
        oPanel:Align := CONTROL_ALIGN_TOP
        
        Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

        oWizard:OFINISH:CTITLE 	 := "&Baixar"

        //->> Ativacao do Painel
        oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                            {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                            {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                            {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

        If lOk
            Processa( {|| u_MaBxPrdVtx(NIL,NIL,aRet01Param[03],NIL,NIL,aRet01Param[01],aRet01Param[02]) },"Aguarde a Baixa do Site pelo Protheus" ,"Baixando Produtos do VTEX...")
        EndIf
    
    ElseIf nOpc == 2
        If MsgYesNo("Confirma a Descida de Produtos do vTex ?")
            Processa( {|| u_MaBxSkuVtx(NIL,NIL,NIL,NIL) },"Aguarde a Baixa do Site" ,"Baixando Produtos do VTEX...")
        EndIf
    EndIf    
EndIf

Return

/*/{protheus.doc} MaBxPrdVtx
*******************************************************************************************
Atualiza o cadastro de produtos com os dados do vtex

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaBxPrdVtx(cEmp,cFil,lNovo,cMsgConexao,cNickName,cProdDe,cProdAte)
Local cConex        := "ECVTXBXPRD"
Local lJob          := .F.
Local aArea         := {}
Local cQuery        := ""
Local cAlias        := ""
Local nTotRegs      := 0
Local lUsarRot      := .T.
Local nTimer        := 0
Local _cFilAnt      := ""
Local nRecRegist    := 0
Local cDtAtualz     := ""
Local aDados        := {}
Local cId           := ""
Local cIdSku        := ""
Local cProduto      := ""
Local nTotal        := 0
Local lAtualizado   := .F.

Default cEmp        := _cEmp
Default cFil        := _cFil
Default lNovo       := .T.
Default cMsgConexao := ""
Default cNickName   := ""
Default cProdDe     := ""
Default cProdAte    := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
            cProdDe  := Replicate(" ",Tamsx3(Tb_Estru+"_SKU")[01])
            cProdAte := Replicate("Z",Tamsx3(Tb_Estru+"_SKU")[01])
        Else
            Return
        EndIf    
    Else
        aArea := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    //->> Registra a entrada na rotina
    nRecRegist := u_MARegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Produtos...")       
    EndIf
    cAlias := GetNextAlias()
    
    //->> Processo partindo da SB1    
    If lNovo
        cQuery := "SELECT DISTINCT RECSB1 FROM"+CRLF
        cQuery += "("+CRLF
        cQuery += "    SELECT * FROM"+CRLF
        cQuery += "        ("+CRLF
        cQuery += "        SELECT ISNULL(SB1.R_E_C_N_O_,0) AS RECSB1, ISNULL(TBPRODU.R_E_C_N_O_,0) AS RECCATPRD"+CRLF
        cQuery += "            FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"+CRLF
        cQuery += "            LEFT JOIN "+RetSqlName(Tb_Produ)+" TBPRODU (NOLOCK)"+CRLF
        cQuery += "                 ON TBPRODU."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"+CRLF
        cQuery += "                AND TBPRODU."+Tb_Produ+"_SKU = SB1.B1_COD"+CRLF
        cQuery += "                AND TBPRODU."+Tb_Produ+"_TIPO = 'P'"+CRLF
        cQuery += "                AND TBPRODU.D_E_L_E_T_ = ' '"+CRLF
        cQuery += "            WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"+CRLF
        cQuery += "                AND SB1.B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"+CRLF
        cQuery += "                AND SB1.B1_MSBLQL <> '1'"+CRLF
        cQuery += "                AND SB1.D_E_L_E_T_ = ' '"+CRLF    
        cQuery += "        ) AS TMP"+CRLF
        cQuery += "    WHERE TMP.RECCATPRD = 0"+CRLF
        cQuery += " UNION"+CRLF
        cQuery += "    SELECT ISNULL(SB1.R_E_C_N_O_,0) AS RECSB1, 0 AS RECCATPRD"+CRLF
        cQuery += "        FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"+CRLF
        cQuery += "        INNER JOIN "+RetSqlName(Tb_Produ)+" TBPRODU (NOLOCK)"+CRLF
        cQuery += "             ON TBPRODU."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"+CRLF
        cQuery += "            AND TBPRODU."+Tb_Produ+"_SKU = SB1.B1_COD"+CRLF
        cQuery += "            AND TBPRODU."+Tb_Produ+"_TIPO = 'P'"+CRLF
        cQuery += "            AND TBPRODU.D_E_L_E_T_ = ' '"+CRLF
        cQuery += "        INNER JOIN "+RetSqlName(Tb_IDS)+" TBIDS (NOLOCK)"+CRLF
        cQuery += "             ON TBIDS."+Tb_IDS+"_FILIAL = TBPRODU."+Tb_Produ+"_FILIAL"+CRLF
        cQuery += "            AND TBIDS."+Tb_IDS+"_ECOM = '"+Ecommerce+"'"+CRLF
        cQuery += "            AND TBIDS."+Tb_IDS+"_CHPROT = TBPRODU."+Tb_Produ+"_SKU"+CRLF
        cQuery += "            AND TBIDS."+Tb_IDS+"_ID = ' '"+CRLF
        cQuery += "            AND TBIDS.D_E_L_E_T_ = ' '"+CRLF
        cQuery += "        WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"+CRLF
        cQuery += "          AND SB1.B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"+CRLF
        cQuery += "          AND SB1.B1_MSBLQL <> '1'"+CRLF
        cQuery += "          AND SB1.D_E_L_E_T_ = ' '"+CRLF
        cQuery += ") AS PRODUTOS"+CRLF
        cQuery += "ORDER BY PRODUTOS.RECSB1"+CRLF
    Else
        cQuery += "        SELECT SB1.R_E_C_N_O_ AS RECSB1"+CRLF
        cQuery += "            FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"+CRLF
        cQuery += "            WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"+CRLF
        cQuery += "                AND SB1.B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"+CRLF
        cQuery += "                AND SB1.B1_MSBLQL <> '1'"+CRLF
        cQuery += "                AND SB1.D_E_L_E_T_ = ' '"+CRLF
    EndIf

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
    (cAlias)->(dbGotop())

    If !isBlind()
        ProcRegua(nTotRegs)            
    EndIf
    
    Do While (cAlias)->(!Eof())
        SB1->(dbGoto((cAlias)->RECSB1))
        If !isBlind()            
            IncProc("Atualizando Produtos do vTex...")
        EndIf
        lAtualizado := .F.

        cProduto := Alltrim(SB1->B1_COD)
        aDados := u_MaVTXDPrd(cProduto,"/api/catalog/pvt/stockkeepingunit?refId=")
        If Len(aDados)>0
            //->> Resgata o Id do produto
            cId := aDados[1]
            If Valtype(cId)=="N"
                cId := Str(cId)
            EndIf
            cId := Alltrim(cId)

            //->> Resgata o Id do sku do produto
            cIdSku := aDados[16]
            If Valtype(cIdSku)=="N"
                cIdSku := Str(cIdSku)
            EndIf
            cIdSku := Alltrim(cIdSku)

            //-> Resgata a ultima data de atualização no site
            If Len(aDados)>=8 .And. Valtype(aDados[8])=="C" .And. !Empty(aDados[8])
                cDtAtualz := SubStr(aDados[8],9,2)+"/"+SubStr(aDados[8],6,2)+"/"+SubStr(aDados[8],1,4)+"  " + SubStr(aDados[8],12,8)
            Else
                cDtAtualz := ""
            EndIf
            
            Begin Transaction
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
                    (Tb_Produ)->&(Tb_Produ+"_ATUSIT")   := "1"
                    (Tb_Produ)->&(Tb_Produ+"_MSBLQL")   := If(SB1->B1_MSBLQL <> "1","2","1")
                    (Tb_Produ)->&(Tb_Produ+"_OBSERV")   := ""                    
                    (Tb_Produ)->(MsUnlock())
                    lAtualizado := .T.
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
                    lAtualizado := .T.
                EndIf

                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+SB1->B1_COD))
                    Reclock(Tb_IDS,.T.)
                    (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                    (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                    (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                    (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := SB1->B1_COD
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                    (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                    (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                    (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                    (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                    (Tb_IDS)->(MsUnlock())
                    lAtualizado := .T.
                Else
                    Reclock(Tb_IDS,.F.)
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                    (Tb_IDS)->(MsUnlock())
                EndIf

                If lAtualizado
                    u_MAGrvLogI(cConex,,"Descida do produto "+cProduto,,,Tb_Produ,1,xFilial(Tb_Produ)+cProduto)
                    u_MAGrvLogI(cConex,"S",,"")
                    
                    nTotal++
                EndIf

            End Transaction

        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())

    //->> Processo partindo do catalogo de produtos    
    cQuery := "SELECT TBPRODU.R_E_C_N_O_ AS RECTBPRD"+CRLF
    cQuery += "    FROM "+RetSqlName(Tb_Produ)+" TBPRODU (NOLOCK)"+CRLF
    cQuery += "    WHERE TBPRODU."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"+CRLF
    cQuery += "      AND TBPRODU."+Tb_Produ+"_SKU BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'"+CRLF
    cQuery += "      AND TBPRODU."+Tb_Produ+"_TIPO = 'K'"+CRLF        
    cQuery += "      AND TBPRODU.D_E_L_E_T_ = ' '"+CRLF
    
    nTotRegs := 0
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
    dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
    (cAlias)->(dbGotop())

    If !isBlind()
        ProcRegua(nTotRegs)            
    EndIf
    
    Do While (cAlias)->(!Eof())
        (Tb_Produ)->(dbGoto((cAlias)->RECTBPRD))
        If !isBlind()            
            IncProc("Atualizando Produtos de Kit do vTex...")
        EndIf
        lAtualizado := .F.

        cProduto := Alltrim((Tb_Produ)->&(Tb_Produ+"_SKU"))
        aDados := u_MaVTXDPrd(cProduto,"/api/catalog/pvt/stockkeepingunit?refId=")
        If Len(aDados)>0
            //->> Resgata o Id do produto
            cId := aDados[1]
            If Valtype(cId)=="N"
                cId := Str(cId)
            EndIf
            cId := Alltrim(cId)

            //->> Resgata o Id do sku do produto
            cIdSku := aDados[16]
            If Valtype(cIdSku)=="N"
                cIdSku := Str(cIdSku)
            EndIf
            cIdSku := Alltrim(cIdSku)

            //-> Resgata a ultima data de atualização no site
            If Len(aDados)>=8 .And. Valtype(aDados[8])=="C" .And. !Empty(aDados[8])
                cDtAtualz := SubStr(aDados[8],9,2)+"/"+SubStr(aDados[8],6,2)+"/"+SubStr(aDados[8],1,4)+"  " + SubStr(aDados[8],12,8)
            Else
                cDtAtualz := ""
            EndIf
            
            Begin Transaction                
                (Tb_IDS)->(dbSetOrder(1))
                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+PadR(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+cProduto))
                    Reclock(Tb_IDS,.T.)
                    (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                    (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                    (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                    (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := cProduto
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                    (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                    (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                    (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                    (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                    (Tb_IDS)->(MsUnlock())
                    lAtualizado := .T.
                Else
                    If Alltrim((Tb_IDS)->&(Tb_IDS+"_ID")) <> Alltrim(cId) .Or. Alltrim((Tb_IDS)->&(Tb_IDS+"_IDSKU")) <> Alltrim(cIdSku)
                        lAtualizado := .T.
                    EndIf

                    Reclock(Tb_IDS,.F.)
                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                    (Tb_IDS)->(MsUnlock())
                EndIf

                If lAtualizado
                    u_MAGrvLogI(cConex,,"Descida do Produto "+cProduto,,,Tb_Produ,1,xFilial(Tb_Produ)+cProduto)
                    u_MAGrvLogI(cConex,"S",,"")                    
                    nTotal++
                EndIf

            End Transaction

        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())

    //->> Fecha o Registro da entrada na rotina
    u_MAUnRegMon(nRecRegist)

    If !isBlind()
        If nTotal > 0
            MsgAlert("Foram atualizados "+Alltrim(Str(nTotal))+" Produtos na Descida do vTex.")
        Else
            MsgAlert("Nenhum Produto foi atualizado na Descida do vTex.")
        EndIf
    EndIf

    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

/*/{protheus.doc} MaBxSkuVtx
*******************************************************************************************
Atualiza o cadastro de produtos por sku com os dados do vtex

@author: Marcelo Celi Marques
@since: 05/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaBxSkuVtx(cEmp,cFil,cMsgConexao,cNickName)
Local cConex        := "ECVTXBXPRD"
Local lJob          := .F.
Local aArea         := {}
Local lUsarRot      := .T.
Local nTimer        := 0
Local _cFilAnt      := ""
Local nRecRegist    := 0
Local nTotal        := 0
Local cUrl          := ""
Local cEndPoint     := ""
Local nTimeOut      := 0
Local cEndPEspec    := ""
Local nSkuIni       := 0
Local nSkuFim       := 0
Local aSKU          := {}
Local aCodigos      := {}
Local oResponse     := NIL
Local cRetApi       := ""
Local nX            := 1
Local nY            := 1
Local cPalavra      := ""
Local aPalavra      := {}
Local lAtualizado   := .F.
Local cId           := ""
Local cIdSku        := ""
Local aDados        := {}
Local cDtAtualz     := ""

Default cEmp        := _cEmp
Default cFil        := _cFil
Default cMsgConexao := ""
Default cNickName   := ""

If !Empty(cNickName)    
    lUsarRot := LockByName(cNickName,.F.,.F.)
Else
    lUsarRot  := .T.   
EndIf

If lUsarRot
    If !Empty(cMsgConexao)
        Conout(cMsgConexao)
    EndIf    
    lJob := Select( "SM0" ) <= 0
    If lJob
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
        If Inicializar()
            u_MaSetFilEC(Tb_Ecomm,Ecommerce)
        Else
            Return
        EndIf    
    Else
        aArea := GetArea()        
    EndIf
    _cFilAnt  := cFilAnt
    cFilAnt   := FilEcomm
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

    //->> Registra a entrada na rotina
    nRecRegist := u_MARegMonit(cConex,Tb_ThMon,Tb_ChMon)

    If !isBlind()
        ProcRegua(0)
        IncProc("Extraindo Dados de Produtos...")       
    EndIf
    
    If Inicializar(lJob)
        u_MaSetFilEC(Tb_Ecomm,Ecommerce)

        (Tb_Conex)->(dbSetOrder(1))
        If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GPS"))
            cUrl      := Alltrim((Tb_Conex)->&(Tb_Conex+"_URL"))
            cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
            nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
            If Len(cEndPoint)>1
                If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                    cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
                EndIf
            EndIf

            If !Empty(cEndPoint)
                nSkuIni := 0
                nSkuFim := 50
                Do While .T.            
                    cEndPEspec := "?_from="+Alltrim(Str(nSkuIni))+"&_to="+Alltrim(Str(nSkuFim))
                    If ExecutConex("GET",cEndPoint+cEndPEspec,"",@oResponse,nTimeOut,@cRetApi,lJob,,.F.)
                        cPalavra := ""
                        For nX:=1 to Len(cRetApi)
                            If SubStr(cRetApi,nX,1) == "["                                
                                Do While .T.
                                    If SubStr(cRetApi,nX,1) == "]" .Or. nX==Len(cRetApi)
                                        cPalavra += SubStr(cRetApi,nX,1)
                                        aAdd(aPalavra,cPalavra)
                                        cPalavra := ""
                                        Exit
                                    Else
                                        cPalavra += SubStr(cRetApi,nX,1)
                                    EndIf
                                    nX++
                                EndDo
                            EndIf
                        Next nX
                        If Len(aPalavra)==0
                            Exit
                        Else
                            For nX:=1 to Len(aPalavra)
                                cPalavra := aPalavra[nX]
                                cPalavra := StrTran(cPalavra,"[","{")
                                cPalavra := StrTran(cPalavra,"]","}")
                                aAdd(aSku,&(cPalavra))
                            Next nX
                            aPalavra := {}
                        EndIf
                        nSkuIni += 50 + 1
                        nSkuFim += 50
                    Else
                        Exit
                    EndIf
                EndDo
            EndIf    
        EndIf
    
        For nX:=1 to Len(aSku)
            For nY:=1 to Len(aSku[nX])
                If Ascan(aCodigos,{|x| x == aSku[nX,nY] })==0
                    aAdd(aCodigos,aSku[nX,nY])
                EndIf
            Next nY
        Next nX

        If !isBlind()
            ProcRegua(Len(aCodigos))            
        EndIf
        If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GSK"))
            cUrl      := Alltrim((Tb_Conex)->&(Tb_Conex+"_URL"))
            cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))
            nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
            If Len(cEndPoint)>1
                If Right(cEndPoint,1)=="/" .Or. Right(cEndPoint,1)=="\"
                    cEndPoint := Left(cEndPoint,Len(cEndPoint)-1)
                EndIf
            EndIf
            If !Empty(cEndPoint)
                For nX:=1 to Len(aCodigos)
                    If !isBlind()
                        IncProc("Atualizando Produtos...")
                    EndIf
                    oResponse := NIL
                    cRetApi   := ""
                    If ExecutConex("GET",cEndPoint+"\"+Alltrim(Str(aCodigos[nX])),"",@oResponse,nTimeOut,@cRetApi,lJob)
                        lAtualizado := .F.
                        cCodigo   := Alltrim(oResponse:RefId)
                        cId       := ""
                        cIdSku    := ""
                        cDtAtualz := ""
                        aDados := u_MaVTXDPrd(cCodigo,"/api/catalog/pvt/stockkeepingunit?refId=")
                        If Len(aDados)>0
                            //->> Resgata o Id do produto
                            cId := aDados[1]
                            If Valtype(cId)=="N"
                                cId := Str(cId)
                            EndIf
                            cId := Alltrim(cId)

                            //->> Resgata o Id do sku do produto
                            cIdSku := aDados[16]
                            If Valtype(cIdSku)=="N"
                                cIdSku := Str(cIdSku)
                            EndIf
                            cIdSku := Alltrim(cIdSku)

                            //-> Resgata a ultima data de atualização no site
                            If Len(aDados)>=8 .And. Valtype(aDados[8])=="C" .And. !Empty(aDados[8])
                                cDtAtualz := SubStr(aDados[8],9,2)+"/"+SubStr(aDados[8],6,2)+"/"+SubStr(aDados[8],1,4)+"  " + SubStr(aDados[8],12,8)
                            Else
                                cDtAtualz := ""
                            EndIf

                        EndIf                        
                        
                        SB1->(dbSetOrder(1))
                        If SB1->(dbSeek(xFilial("SB1")+cCodigo))
                            Begin Transaction
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
                                    (Tb_Produ)->&(Tb_Produ+"_ATUSIT")   := "1"
                                    (Tb_Produ)->&(Tb_Produ+"_MSBLQL")   := If(SB1->B1_MSBLQL <> "1","2","1")
                                    (Tb_Produ)->&(Tb_Produ+"_OBSERV")   := ""                    
                                    (Tb_Produ)->(MsUnlock())
                                    lAtualizado := .T.
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
                                    lAtualizado := .T.
                                EndIf

                                (Tb_IDS)->(dbSetOrder(1))
                                If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+SB1->B1_COD))
                                    Reclock(Tb_IDS,.T.)
                                    (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                                    (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                                    (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                                    (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := SB1->B1_COD
                                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                                    (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                                    (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                                    (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                                    (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                                    (Tb_IDS)->(MsUnlock())
                                    lAtualizado := .T.
                                Else
                                    Reclock(Tb_IDS,.F.)
                                    (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                                    (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                                    (Tb_IDS)->(MsUnlock())
                                EndIf
                            End Transaction
                        Else
                            If "KIT" $ Alltrim(Upper(cCodigo))
                                (Tb_Produ)->(dbSetOrder(1))
                                If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+PadR(cCodigo,Tamsx3("B1_COD")[01])))
                                    Begin Transaction
                                        (Tb_IDS)->(dbSetOrder(1))
                                        If !(Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+Pad(Ecommerce,Tamsx3(Tb_IDS+"_ECOM")[01])+"PRD"+SB1->B1_COD))
                                            Reclock(Tb_IDS,.T.)
                                            (Tb_IDS)->&(Tb_IDS+"_FILIAL")   := xFilial(Tb_IDS)
                                            (Tb_IDS)->&(Tb_IDS+"_ECOM")     := Ecommerce 
                                            (Tb_IDS)->&(Tb_IDS+"_TIPO")     := "PRD"
                                            (Tb_IDS)->&(Tb_IDS+"_CHPROT")   := SB1->B1_COD
                                            (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                                            (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                                            (Tb_IDS)->&(Tb_IDS+"_TABPRC")   := (Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC")
                                            (Tb_IDS)->&(Tb_IDS+"_PRCVEN")   := 0
                                            (Tb_IDS)->&(Tb_IDS+"_ULTATU")   := cDtAtualz
                                            (Tb_IDS)->&(Tb_IDS+"_PENDEN")   := "N"
                                            (Tb_IDS)->(MsUnlock())
                                            lAtualizado := .T.
                                        Else
                                            Reclock(Tb_IDS,.F.)
                                            (Tb_IDS)->&(Tb_IDS+"_ID")       := cId
                                            (Tb_IDS)->&(Tb_IDS+"_IDSKU")    := cIdSku
                                            (Tb_IDS)->(MsUnlock())
                                        EndIf
                                    End Transaction
                                EndIf
                            EndIf

                            If !lAtualizado
                                u_MAGrvLogI(cConex,,"Descida do produto "+cCodigo,,,Tb_Produ,1,xFilial(Tb_Produ)+cCodigo)
                                u_MAGrvLogI(cConex,"N",,"Produto não Localizado na tabela de Catalogo e de Produtos"+CRLF+CRLF+cRetApi)
                            EndIf

                        EndIf
                    EndIf

                    If lAtualizado
                        u_MAGrvLogI(cConex,,"Descida do produto "+cCodigo,,,Tb_Produ,1,xFilial(Tb_Produ)+cCodigo)
                        u_MAGrvLogI(cConex,"S",,cRetApi)

                        nTotal++
                    EndIf

                Next nX
            EndIf
        EndIf            

        //->> Fecha o Registro da entrada na rotina
        u_MAUnRegMon(nRecRegist)

        If !isBlind()
            If nTotal > 0
                MsgAlert("Foram atualizados "+Alltrim(Str(nTotal))+" Produtos na Descida do vTex.")
            Else
                MsgAlert("Nenhum Produto foi atualizado na Descida do vTex.")
            EndIf
        EndIf
    EndIf

    If lJob
        RESET ENVIRONMENT
    Else    
        RestArea(aArea)
        cFilAnt := _cFilAnt
        SM0->(dbSetOrder(1))
        SM0->(dbSeek(cEmpAnt+cFilAnt))
    EndIf
    If !Empty(cNickName)
        Sleep(nTimer * 60 * 1000)
        UnLockByName(cNickName,.F.,.F.)
    EndIf    
EndIf

Return

/*/{protheus.doc} SelPedidos
*******************************************************************************************
Permite a seleção dos pedidos disponiveis a descer

Array aPed2Selec:

01 - Se PV esta OK em relação ao status
02 - Id do Pedido
03 - Status do Pedido
04 - Canal do Pedido/Origem
05 - Id Original do Pedido/Sequencia
06 - Data de Criação
07 - Data de Modificação/Autorização
08 - Id do Canal Usado

@author: Marcelo Celi Marques
@since: 14/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function SelPedidos(aPed2Selec,Ecommerce,aPedSite)
Local lRet      := .F.
Local nX        := 1
Local aArea     := GetArea()
Local aAreaSCJ  := SCJ->(GetArea())
Local cMsg      := ""
Local lOk       := .F.
Local oWizard   := NIL
Local aCoord    := {0,0,500,900}
Local cLogotipo := "globo.PNG"
Local nPos      := 0
Local oFonte1   := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local cDataCri  := ""
Local cDataMod  := ""

Private lRunDblClick:= .T.      
Private lChkTWiz 	:= .F.
Private oNo 		:= LoadBitmap( GetResources(), "qmt_no" )
Private oOk 		:= LoadBitmap( GetResources(), "qmt_ok"	)
Private oNoSel 		:= LoadBitmap( GetResources(), "LBNO" 	)
Private oSel 		:= LoadBitmap( GetResources(), "LBTIK"	)
Private aPedidos    := {} 
Private oLbxPeds    := NIL

For nX:=1 to Len(aPed2Selec)
    cMsg := ""
    lOk  := aPed2Selec[nX,01]
    If !lOk
        cMsg := "Pedido fora do range de status permitido."
    EndIf
    
    If lOk
        SCJ->(dbOrderNickName("CJXORIGEM"))
        lOk := !SCJ->(dbSeek(xFilial("SCJ")+PadR(Ecommerce,Tamsx3("CJ_XORIGEM")[01])+PadR(aPed2Selec[nX,02],Tamsx3("CJ_XIDINTG")[01]) ))
        If !lOk
            cMsg := "Pedido já desceu para o ERP."
        EndIf
    EndIf

    cDataCri := SubStr(aPed2Selec[nX,06],9,2)+"/"+SubStr(aPed2Selec[nX,06],6,2)+"/"+SubStr(aPed2Selec[nX,06],1,4)+"  "+SubStr(aPed2Selec[nX,06],12,8)
    cDataMod := SubStr(aPed2Selec[nX,07],9,2)+"/"+SubStr(aPed2Selec[nX,07],6,2)+"/"+SubStr(aPed2Selec[nX,07],1,4)+"  "+SubStr(aPed2Selec[nX,07],12,8)

    aAdd(aPedidos,{lOk,                 ; // 01 - Se pedido pode ser baixado
                   lOk,                 ; // 02 - Estando o pedido ok, se esta marcado automaticamente
                   aPed2Selec[nX,02],   ; // 03 - Id do Pedido
                   aPed2Selec[nX,04],   ; // 04 - Origem do Pedido
                   aPed2Selec[nX,08],   ; // 05 - Canal do Pedido
                   cDataCri,            ; // 06 - Data de Criação
                   cDataMod,            ; // 07 - Data de Modificação
                   aPed2Selec[nX,03],   ; // 08 - Status do Pedido
                   cMsg}                ) // 09 - Observação do Pedido

Next nX

If Len(aPedidos)>0
    lOk := .F.
    oWizard := APWizard():New("Vendas do VTex",                                  									                    ;   // chTitle  - Titulo do cabecalho
                              "Selecione os Pedidos e confirme a descida.",                                                             ;   // chMsg    - Mensagem do cabecalho
                              "Carga de Vendas",                                                                                        ;   // cTitle   - Titulo do painel de apresentacao
                              "",             													            	                        ;   // cText    - Texto do painel de apresentacao
                              {|| lOk := MsgYesNo("Confirma a descida das Vendas Selecionadas ?"), lOk },                               ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                              {|| lOk := MsgYesNo("Confirma a descida das Vendas Selecionadas ?"), lOk },                               ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                              .T.,             												     			                            ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                              cLogotipo,        	   												 			                        ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                              {|| },                												 			                        ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                              .F.,                  												 			                        ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                              aCoord 		                   										 				                    )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_TOP

    @ 000, 000 LISTBOX oLbxPeds FIELDS HEADER 	""								,;
                                                ""								,;
                                                "Id Pedido"	    				,;
                                                "Origem"						,;
                                                "Canal"							,;
                                                "Criação"						,;
                                                "Modificação"					,;
                                                "Status"	    				,;
                                                "Observação"					 ;
                                    COLSIZES 	5								,;
                                                5								,;
                                                30 								,;
                                                30 								,;
                                                30 								,;
                                                30 								,;
                                                30 								,;
                                                30 								,;
                                                60								 ;
                            SIZE (oPanel:NWIDTH/2)-2,(oPanel:NHEIGHT/2)-2;
                            ON DBLCLICK (MarcPV2Desc(),oLbxPeds:Refresh(.f.)) OF oPanel PIXEL

    oLbxPeds:SetArray(aPedidos)	
    oLbxPeds:bLine := {|| {If(aPedidos[oLbxPeds:nAt,1],oOK,oNO),If(aPedidos[oLbxPeds:nAt,2],oSel,oNoSel),aPedidos[oLbxPeds:nAt,3],aPedidos[oLbxPeds:nAt,4],aPedidos[oLbxPeds:nAt,5],aPedidos[oLbxPeds:nAt,6],aPedidos[oLbxPeds:nAt,7],aPedidos[oLbxPeds:nAt,8],aPedidos[oLbxPeds:nAt,9]}}
    oLbxPeds:bRClicked 		:= { || AEVAL(aPedidos,{|x| x[2]:=!x[2] }), oLbxPeds:Refresh(.F.)}    	
    oLbxPeds:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aPedidos, {|e| IF(e[1],e[2]:=!e[2],e[2]:=e[2])})),Nil), lRunDblClick := !lRunDblClick, oLbxPeds:Refresh()}

    oWizard:OFINISH:CTITLE 	 := "&Baixar"

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        lRet := .T.
        aPed2Selec := {}
        For nX:=1 to Len(aPedSite)
            nPos := AScan(aPedidos,{|x| Alltrim(x[03])==Alltrim(aPedSite[nX,01])})
            If nPos > 0
                If aPedidos[nPos,02]
                    aAdd(aPed2Selec,aPedSite[nX])
                EndIf
            EndIf
        Next nX
        aPedSite := aClone(aPed2Selec)
    EndIf

EndIf

SCJ->(RestArea(aAreaSCJ))
RestArea(aArea)

Return lRet

/*/{protheus.doc} MarcPV2Desc
*******************************************************************************************
Marca e desmarca o pedido de vendas a descer.

@author: Marcelo Celi Marques
@since: 14/03/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MarcPV2Desc()

If aPedidos[oLbxPeds:nAt,1]
    aPedidos[oLbxPeds:nAt,2]:=!aPedidos[oLbxPeds:nAt,2]
Else    
    aPedidos[oLbxPeds:nAt,2]:=aPedidos[oLbxPeds:nAt,2]
EndIf    
    
If !aPedidos[oLbxPeds:nAt,2]
    lChkTWiz := .F.
EndIf

Return

/*/{protheus.doc} GetDetClien
*******************************************************************************************
Retorna os detalhes do cliente

https://developers.vtex.com/vtex-rest-api/reference/searchdocuments

Teste: 
curl --request GET \
     --url 'https://madmais.vtexcommercestable.com.br/api/dataentities/CL/search?_fields=email%2CfirstName%2ClastName%2Cdocument%2Cphone%2CcorporatePhone%2CcorporateName%2Cid%2CcorporateDocument&_keyword=01944502017&_sort=firstName%20ASC' \
     --header 'X-VTEX-API-AppKey: vtexappkey-madmais-KQMGCA' \
     --header 'X-VTEX-API-AppToken: LNXBAXUHWAOIMLFMUWMYXVANZHTPYGLUJBBXUVOYLSHNEYHZFGZRQSKPNJCTEFJPPTZLJISZHNMFOMIAZUJRHTEQRMJKTUUGJRYLYWPXOAJCGFBAABTJVRIWOJUWYHGM'

@author: Marcelo Celi Marques
@since: 03/08/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDetClien(lJob,cDocumento,lCorporativo)
Local aDados     := {}
Local lRet       := .F. 
Local cEndPoint  := ""
Local cQryPar    := ""
Local cEndReques := "" 
Local cRequest   := ""
Local oResponse  := NIL
Local nTimeOut   := 140
Local cRetApi    := ""
Local nX         := 1
Local aDadTmp    := {}
Local lOk        := .F.   

Default lCorporativo := .F.

Private _oResponse := NIL
Private _nX        := NIL

cEndPoint  := "/api/dataentities/CL/search"
cQryPar    := "?_fields=email"
cQryPar    += "%2CfirstName"
cQryPar    += "%2ClastName"
cQryPar    += "%2Cdocument"
cQryPar    += "%2Cphone"
cQryPar    += "%2CcorporatePhone"
cQryPar    += "%2CcorporateName"
cQryPar    += "%2Cid"
cQryPar    += "%2CcorporateDocument"

//->> Marcelo Celi - 06/09/2022
//cQryPar    += "&_keyword="+Alltrim(cDocumento)+"&_sort=firstName%20ASC"

If !lCorporativo
    cQryPar    += "&_where=document="+Alltrim(cDocumento)
Else
    cQryPar    += "&_where=corporateDocument="+Alltrim(cDocumento)
EndIf

cQryPar    += "&_sort=firstName%20ASC"

cEndReques := cEndPoint + cQryPar

lRet := ExecutConex("GET",cEndReques,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
If lRet
    If Valtype(oResponse)=="A"
        For nX:=1 to Len(oResponse)
            _oResponse := oResponse
            _nX        := nX
            
            lOk := .F.
            If !lCorporativo
                If Type("_oResponse[_nX]:document")<>"U" .And. Valtype(_oResponse[_nX]:document)=="C" .And. !Empty(_oResponse[_nX]:document)
                    If Alltrim(_oResponse[_nX]:document)==Alltrim(cDocumento)
                        lOk := .T.
                    Else
                        lOk := .F.
                    EndIf
                Else
                    lOk := .F.
                EndIf
            Else
                If Type("_oResponse[_nX]:corporateDocument")<>"U" .And. Valtype(_oResponse[_nX]:corporateDocument)=="C" .And. !Empty(_oResponse[_nX]:corporateDocument)
                    If Alltrim(_oResponse[_nX]:corporateDocument)==Alltrim(cDocumento)
                        lOk := .T.
                    Else
                        lOk := .F.
                    EndIf
                Else
                    lOk := .F.
                EndIf
            EndIf

            If lOk
                aDadTmp := {"","","","",""}
                aDadTmp[1] := cDocumento
                If lCorporativo
                    aDadTmp[2] := "J"
                    If Type("_oResponse[_nX]:corporateName")<>"U" .And. Valtype(_oResponse[_nX]:corporateName)=="C" .And. !Empty(_oResponse[_nX]:corporateName)
                        aDadTmp[4] := _oResponse[_nX]:corporateName
                    EndIf

                    If Type("_oResponse[_nX]:corporatePhone")<>"U" .And. Valtype(_oResponse[_nX]:corporatePhone)=="C" .And. !Empty(_oResponse[_nX]:corporatePhone)
                        aDadTmp[5] := _oResponse[_nX]:corporatePhone
                    EndIf
                Else
                    aDadTmp[2] := "F"
                    If Type("_oResponse[_nX]:firstName")<>"U" .And. Valtype(_oResponse[_nX]:firstName)=="C" .And. !Empty(_oResponse[_nX]:firstName)
                        aDadTmp[4] := Alltrim(_oResponse[_nX]:firstName)
                    EndIf

                    If Type("_oResponse[_nX]:lastName")<>"U" .And. Valtype(_oResponse[_nX]:lastName)=="C" .And. !Empty(_oResponse[_nX]:lastName)
                        aDadTmp[4] += " " + Alltrim(_oResponse[_nX]:lastName)
                    EndIf

                    If Type("_oResponse[_nX]:phone")<>"U" .And. Valtype(_oResponse[_nX]:phone)=="C" .And. !Empty(_oResponse[_nX]:phone)
                        aDadTmp[5] := _oResponse[_nX]:phone
                    EndIf
                EndIf
                aDadTmp[4] := Alltrim(aDadTmp[4])

                If Empty(aDadTmp[5])
                    If Type("_oResponse[_nX]:phone")<>"U" .And. Valtype(_oResponse[_nX]:phone)=="C" .And. !Empty(_oResponse[_nX]:phone)
                        aDadTmp[5] := _oResponse[_nX]:phone
                    EndIf
                EndIf

                If Type("_oResponse[_nX]:email")<>"U" .And. Valtype(_oResponse[_nX]:email)=="C" .And. !Empty(_oResponse[_nX]:email)
                    aDadTmp[3] := _oResponse[_nX]:email
                EndIf

                aAdd(aDados,aDadTmp)
            EndIf
        Next nX
    EndIf
EndIf

Return aDados

/*/{protheus.doc} MaGDoc2Vtx
*******************************************************************************************
Retorna os dados fiscais do pedido do site vtex

@author: Marcelo Celi Marques
@since: 09/09/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaGDoc2Vtx(cIdPedido,lJob)
Local cEndPoint := ""
Local nTimeOut  := 0
Local lRet      := .F.
Local cRequest  := ""
Local oResponse := NIL
Local cRetApi   := ""
Local aDados    := {"","","",""}
Local nX        := 1

Private _oResponse := NIL
Private _nX        := 1 

If Inicializar(lJob)    
    (Tb_Conex)->(dbSetOrder(1))
    If (Tb_Conex)->(dbSeek(xFilial(Tb_Conex)+Ecommerce+"GPV"))
        cEndPoint := Alltrim((Tb_Conex)->&(Tb_Conex+"_PATH"))+"/"+cIdPedido
        nTimeOut  := (Tb_Conex)->&(Tb_Conex+"_TIMOUT")
        lRet := ExecutConex("GET",cEndPoint,cRequest,@oResponse,nTimeOut,@cRetApi,lJob)
        If lRet
            _oResponse := oResponse
            If Valtype(_oResponse)=="O" .And. Type("_oResponse:packageAttachment:packages")<>"U" .And. Valtype(_oResponse:packageAttachment:packages)=="A"
                For nX:=1 to Len(_oResponse:packageAttachment:packages)
                    _nX := nX
                    If  Type("_oResponse:packageAttachment:packages[_nX]:type")<>"U" .And. ;
                        Valtype(_oResponse:packageAttachment:packages[_nX]:type)=="C" .And.; 
                        Alltrim(Upper(_oResponse:packageAttachment:packages[_nX]:type))=="OUTPUT" .And. ;
                        Type("_oResponse:packageAttachment:packages[_nX]:invoiceValue")<>"U" .And. ;
                        Valtype(_oResponse:packageAttachment:packages[_nX]:invoiceValue)=="N" .And.; 
                        _oResponse:packageAttachment:packages[_nX]:invoiceValue>0 .And. ;
                        Type("_oResponse:packageAttachment:packages[_nX]:embeddedInvoice")<>"U" .And. ;
                        Valtype(_oResponse:packageAttachment:packages[_nX]:embeddedInvoice)=="C" .And.; 
                        !Empty(_oResponse:packageAttachment:packages[_nX]:embeddedInvoice)

                        //->> Numero da Nota
                        If Type("_oResponse:packageAttachment:packages[_nX]:invoiceNumber")<>"U" .And. Valtype(_oResponse:packageAttachment:packages[_nX]:invoiceNumber)=="C"
                            aDados[01] := _oResponse:packageAttachment:packages[_nX]:invoiceNumber
                        EndIf
                        //->> Data e Hora de Emissao
                        If Type("_oResponse:packageAttachment:packages[_nX]:issuanceDate")<>"U" .And. Valtype(_oResponse:packageAttachment:packages[_nX]:issuanceDate)=="C"
                            aDados[02] := _oResponse:packageAttachment:packages[_nX]:issuanceDate
                        EndIf
                        //->> Chave da Nota Fiscal
                        If Type("_oResponse:packageAttachment:packages[_nX]:invoiceKey")<>"U" .And. Valtype(_oResponse:packageAttachment:packages[_nX]:invoiceKey)=="C"
                            aDados[03] := _oResponse:packageAttachment:packages[_nX]:invoiceKey
                        EndIf
                        //->> Xml da nota
                        If Type("_oResponse:packageAttachment:packages[_nX]:embeddedInvoice")<>"U" .And. Valtype(_oResponse:packageAttachment:packages[_nX]:embeddedInvoice)=="C"
                            aDados[04] := _oResponse:packageAttachment:packages[_nX]:embeddedInvoice
                        EndIf
                        Exit
                    EndIf
                Next nX
            EndIf
        EndIf
    EndIf
EndIf

Return aDados
