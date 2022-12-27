#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    

/*/{protheus.doc} PEINCABPVE
*******************************************************************************************
Ponto de Entrada para manipular o cabeçalho do pedido de vendas do ecommerce

@author: Marcelo Celi Marques
@since: 08/12/2021
@param: 
@return:
@type function: Usuario (Ponto de Entrada chamado da função MaEcOrcame)
*******************************************************************************************
/*/
User Function PEINCABPVE()
Local _aTabelas  := Paramixb[1]
Local _cFilEcomm := Paramixb[2]
Local _cArmazem  := Paramixb[3]
Local _aCabec    := Paramixb[4]

aAdd(_aCabec,{"C5_XORIGEM"	,SCJ->CJ_XORIGEM 	,Nil, Posicione("SX3",2,"C5_XORIGEM"    ,"X3_ORDEM")})
aAdd(_aCabec,{'C5_XIDINTG'  ,SCJ->CJ_XIDINTG	,NIL, Posicione("SX3",2,"C5_XIDINTG"    ,"X3_ORDEM")})
aAdd(_aCabec,{'C5_XFLUXCF'  ,"N"	            ,NIL, Posicione("SX3",2,"C5_XFLUXCF"    ,"X3_ORDEM")})

//->> Marcelo Celi - 02/03/2022
aAdd(_aCabec,{'C5_ESPECI1'	,"CAIXAS"   	    ,NIL, Posicione("SX3",2,"C5_ESPECI1"    ,"X3_ORDEM")})
aAdd(_aCabec,{'C5_VOLUME1'	,1   	            ,NIL, Posicione("SX3",2,"C5_VOLUME1"    ,"X3_ORDEM")})

Return _aCabec
