#INCLUDE "Totvs.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"

/*/{protheus.doc} BoJbCli2Mg
*******************************************************************************************
Job de Subida de Clientes do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbCli2Mg(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de subida de clientes para o e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOCliToEco(lJob)
EndIf

Return

/*/{protheus.doc} BoJbPrd2Mg
*******************************************************************************************
Job de Subida de Produtos do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbPrd2Mg(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de subida de produtos para o e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOPrdToEco(lJob)
EndIf

Return

/*/{protheus.doc} BoJbCat2Mg
*******************************************************************************************
Job de Subida de Categorias do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbCat2Mg(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de subida de categorias para o e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOCatToEco(lJob)
EndIf

Return

/*/{protheus.doc} BoJbEst2Mg
*******************************************************************************************
Job de Subida de Estoque do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbEst2Mg(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de subida de estoques para o e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOEstToEco(lJob)
EndIf

Return

/*/{protheus.doc} BoJbPrc2Mg
*******************************************************************************************
Job de Subida de Preços do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbPrc2Mg(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de subida de preços para o e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOPreToEco(lJob)
EndIf

Return

/*/{protheus.doc} BoJbVdaMag
*******************************************************************************************
Job de Descida de Vendas do Magento
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoJbVdaMag(cEmp,cFil)
Local lJob := .T. 

Default cEmp := ""   
Default cFil := ""

If !Empty(cEmp) .And. !Empty(cFil)
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

    Conout("Acionando o job de descida de vendas do e-commerce: "+Dtoc(Date())+" - "+Time())
    u_BOPedByEco(lJob)
EndIf

Return
