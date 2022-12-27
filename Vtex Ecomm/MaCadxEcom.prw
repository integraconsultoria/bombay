#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
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
Static Tb_Voucher:=""

Static FilEcomm := ""
Static Armazem  := ""

/*/{protheus.doc} MADepEcomm
*******************************************************************************************
Cadastro de Departamentos do e-Commerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MADepEcomm()
Private cCadastro 	:= "Catalogo de Departamentos do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Depar,cCadastro)
EndIf

Return

/*/{protheus.doc} MACatEcomm
*******************************************************************************************
Cadastro de Categorias do e-Commerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MACatEcomm()
Private cCadastro 	:= "Catalogo de Categorias do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Categ,cCadastro)
EndIf

Return

/*/{protheus.doc} MAMarEcomm
*******************************************************************************************
Cadastro de Marcas do e-Commerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAMarEcomm()
Private cCadastro 	:= "Catalogo de Marcas do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Marca,cCadastro)
EndIf

Return

/*/{protheus.doc} MAFabEcomm
*******************************************************************************************
Cadastro de Fabricantes do e-Commerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAFabEcomm()
Private cCadastro 	:= "Catalogo de Fabricantes do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Fabri,cCadastro)
EndIf

Return

/*/{protheus.doc} MACanEcomm
*******************************************************************************************
Cadastro de Canais do e-Commerce
 
@author: Marcelo Celi Marques
@since: 15/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MACanEcomm()
Private cCadastro 	:= "Catalogo de Canais do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Canal,cCadastro)
EndIf

Return

/*/{protheus.doc} MAStaEcomm
*******************************************************************************************
Cadastro de Status das Vendas do eCommerce
 
@author: Marcelo Celi Marques
@since: 15/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAStaEcomm()
Private cCadastro 	:= "Cadastro de Status das Vendas do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_TbSta,cCadastro)
EndIf

Return

/*/{protheus.doc} MAPgtEcomm
*******************************************************************************************
Cadastro de Condições Pgto do eCommerce
 
@author: Marcelo Celi Marques
@since: 15/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAPgtEcomm()
Private cCadastro 	:= "Cadastro de Condições de Pagamento do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_CondP,cCadastro)
EndIf

Return

/*/{protheus.doc} MATraEcomm
*******************************************************************************************
Cadastro de transportadoras do eCommerce
 
@author: Marcelo Celi Marques
@since: 17/03/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MATraEcomm()
Private cCadastro 	:= "Cadastro de Transportadoras do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Transp,cCadastro)
EndIf

Return

/*/{protheus.doc} MADscEcomm
*******************************************************************************************
Cadastro de vouchers de desconto do eCommerce
 
@author: Marcelo Celi Marques
@since: 17/03/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MADscEcomm()
Private cCadastro 	:= "Cadastro de Vouchers de Desconto do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    AxCadastro(Tb_Voucher,cCadastro)
EndIf

Return


