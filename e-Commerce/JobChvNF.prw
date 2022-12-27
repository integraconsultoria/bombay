#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{protheus.doc} MCMagento
*******************************************************************************************
Programa desenvolvido pra executar a subida de chave de NF via JOB
 
@author: Daniel Bastos
@since: 07/05/2021
@type function
*******************************************************************************************
/*/
user function JobChvNF()
	local oObj   := nil
    local cFil   := ""

	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv("01","0301")

    cFil := superGetMv("MC_FILECOM",,"0301")

    if cFil <> "0301"
    	RpcClearEnv()
        RPCSetType(3)
        RpcSetEnv("01",cFil)
    Endif

	oObj := MCMagento():New()

	Conout("Inicio da execucao do envio de chave da NF do e-commerce por job: " + Dtoc(Date()) + " - " + Time())

	    oObj:SobeChvNF()

	Conout("Fim da execucao do envio de chave da NF e-commerce por job: " + Dtoc(Date()) + " - " + Time())

	RpcClearEnv()
return
