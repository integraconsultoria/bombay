#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"

//*****************************************************************************************************************> CLASSE/METODOS  <************************

/*/{protheus.doc} MCMagento
*******************************************************************************************
Classe de comunicação com o Magento - Webservices do e-Commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Class MCMagento

//Propriedades                                           
Data cUrl	    					//-->> URL da conexão
Data cUsuario						//-->> Usuario de Conexao
Data cSenha							//-->> Senha de Conexao
Data cToken		    				//-->> Token de Autenticação
Data cGeracToken                    //-->> Data e Hora da Geração do Token
Data oWsdl                          //-->> Objeto de Conexao
Data lConectado                     //-->> Se obteve sucesso na conexão
Data aClientes                      //-->> Lista de Clientes descidos do Magento
Data aPedidos                       //-->> Lista de Pedidos descidos do Magento
Data aUf                            //-->> Unidades Federativas cadastradas no magento
Data aDadConex                      //-->> Dados da conexao
Data cError                         //-->> Erro da conexao
Data lJob                           //-->> Se processo esta sendo executado em Job
Data cTabPreco                      //-->> Tabela de Preco do e-commerce
Data cLoja                          //-->> Loja de Conexao
Data cLogo                          //-->> Logotipo do Magento
Data cProtocolo                     //-->> Protocolo de Comunicacao
Data lCriaNf                        //-->> Se cria o documento fiscal da venda
Data cNatureza                      //-->> Natureza para gravar no cadastro do cliente
Data cTes                           //-->> Tes de Venda
Data cOper                          //-->> Operação de Vendas para TES inteligente
Data cCond                          //-->> Condição de Pagamento
Data cSerie                         //-->> Serie da Nota Fiscal
Data lOpCli                         //-->> Habilitado a usar a conexao com subida de clientes
Data lOpPrd                         //-->> Habilitado a usar a conexao com subida de produtos
Data lOpCat                         //-->> Habilitado a usar a conexao com subida de categorias
Data lOpEst                         //-->> Habilitado a usar a conexao com subida de estoque
Data lOpPrc                         //-->> Habilitado a usar a conexao com subida de preços
Data cMsgBloqueio                   //-->> Mensagem de Bloqueio

//Metodos
Method New() 						//-->> Constructor
Method Fechar()                     //-->> Fechar a Conexao
Method Iniciar()					//-->> Iniciar
Method Liberado()			    	//-->> Verifica se operacao pode ser utilizada
Method Autentica()			    	//-->> Cria autenticação no magento
Method DesceVendas()				//-->> Desce as vendas do e-commerce para o protheus
Method ProcVendas()				    //-->> Processamento das vendas
Method DescePedidos()				//-->> Desce os pedidos do e-commerce para o protheus
Method GetDetPedid()                //-->> Desce os detalhes do pedido
Method GetDetClien()                //-->> Desce os detalhes do cliente
Method GetEndClien()                //-->> Desce os enderecos do cliente
Method DesceUF()	            	//-->> Desce as unidades federativas do cadastro
Method SobeClientes()               //-->> Sobe os Clientes do Protheus para o Magenta
Method ProcClientes()               //-->> Processamento da subida de clientes
Method SobeProdutos()               //-->> Sobe os Produtos do Protheus para o Magenta
Method ProcProdutos()               //-->> Processamento da subida de produtos
Method SobeCategoria()              //-->> Sobe as Categorias de Produtos
Method ProcCategoria()              //-->> Processamento da subida de categorias
Method SobeEstoque()                //-->> Sobe os Estoques do Protheus para o Magenta
Method ProcEstoque()                //-->> Processamento do envio do estoque
Method SobePrecos()                 //-->> Sobe os Precos do Protheus para o Magenta
Method ProcPrecos()                 //-->> Processamento da subida de preços
Method GetToken()                   //-->> Extrai o Token do Magento
Method GetCertif()                  //-->> Extrai o Certificado de Autenticacao
Method GetInfo()                    //-->> Extrai as informações do ambiente magento
Method GetDadProdut()               //-->> Retorna os dados do produto caso ele exiata no site
Method GravaLogErro()               //-->> Grava o log de erro da operação

//->> Marcelo Celi - 22/12/2020
Method LinkProdutos()               //->> Linka os produtos do site com os do protheus
Method DescID2Prd()                 //-->> Desce os ids dos produtos ja cadastrados no site

//->> Marcelo Celi - 28/12/2020
Method EntregPedido()               //->> Sobe a entrega do pedido no ecommerce
Method EntregPV()                   //->> Processa a entrega no ecommerce
Method SobeTracking()               //->> Sobe o trancking pro ecommerce
Method AtuTracking()                //->> Processa o tracking do ecommerce

//->> Daniel Bastos - 03/05/2021
Method SobeChvNF()                  //->> Sobe a chave da NF ecommerce
Method SobeChv()                   //->> Processa a chave da NF no ecommerce

EndClass

/*/{protheus.doc} MCMagento
*******************************************************************************************
Classe de comunicação com o Magento - Webservices do e-Commerce
Construtor
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method New(lJob) Class MCMagento    
Default lJob := .F.
Self:aUf        := {}
Self:aDadConex  := {"","","","","","","","","",""}
Self:Iniciar(lJob)
Return Self
                                   
/*/{protheus.doc} MCMagento
*******************************************************************************************
Classe de comunicação com o Magento - Webservices do e-Commerce
Inicialização

// ************************************ ->> Para testar <<- *******************************

//->> Ambiente de Homologação:  
URL: https://homologbombay.signashop.com.br/api/v2_soap?wsdl=1
USUARIO:  integrador
SENHA:    38824add9911539ada95f0fd5cbb5370
loja:     1


//->> Ambiente de Produção:  
URL: https://admin.bombay.signashop.com.br/api/v2_soap?wsdl=1
USUARIO:  integrador
SENHA:    38824add9911539ada95f0fd5cbb5370
Loja:     1


//->> Cadastros no Protheus (utilizado para testes)
Tabela de Preços: 015
Logotipo: MAGENTO-LOGO.JPG
Natureza: 4002001
Tes: 501
Condição de Pagamento: 001
Serie de Nota: ECO




@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Iniciar(lJob) Class MCMagento

Self:lConectado := .F.
Self:cError     := ""
Self:cUrl       := GetNewPar("MC_MAGEURL","")
Self:cUsuario	:= GetNewPar("MC_MAGEUSR","")
Self:cSenha		:= GetNewPar("MC_MAGEPSW","")
Self:cTabPreco  := GetNewPar("MC_MAGETPR","")
Self:cLoja      := GetNewPar("MC_MAGELOJ","")
Self:cLogo      := GetNewPar("MC_MAGELOG","MAGENTO-LOGO.JPG")
Self:lCriaNf    := GetNewPar("MC_MAGENFE",.F.)
Self:cNatureza  := GetNewPar("MC_MAGENAT","")
Self:cTes       := GetNewPar("MC_MAGETES","")
Self:cOper      := GetNewPar("MC_MAGEOPE","")
Self:cCond      := GetNewPar("MC_MAGECND","")
Self:cSerie     := GetNewPar("MC_MAGESER","")

//->> Se pode executar as operacoes
Self:lOpCli		:= GetNewPar("MC_MAGECLI",.F.)
Self:lOpPrd		:= GetNewPar("MC_MAGEPRD",.F.)
Self:lOpCat		:= GetNewPar("MC_MAGECAT",.F.)
Self:lOpEst		:= GetNewPar("MC_MAGEEST",.F.)
Self:lOpPrc		:= GetNewPar("MC_MAGEPRC",.F.)

Self:cMsgBloqueio   := ""
Self:cProtocolo     := "Soap"
Self:aPedidos       := {}
Self:lJob           := lJob

If !Self:Liberado()
    If !Self:lJob
        MsgAlert(Self:cMsgBloqueio)
    Else
        Conout(Self:cMsgBloqueio)
    EndIf
Else
    If !Self:lJob
        MsgRun("Realizando a Autenticação no Magento","Aguarde",{|| Self:Autentica() })
    Else
        Self:Autentica()
    EndIf
    If Self:lConectado
        If Len(Self:aUf)==0
            //->> Obtendo dados de UFs
            If !Self:lJob
                MsgRun("Obtendo informações do ambiente e-Comerce","Aguarde",{|| Self:DesceUF() })
            Else
                Self:DesceUF()
            EndIf
        EndIf
        If Empty(Self:aDadConex[01])
            //->> Obtendo dados da loja
            If !Self:lJob
                MsgRun("Obtendo informações da Conexão com o e-Comerce","Aguarde",{|| Self:GetInfo() })    
            Else
                Self:GetInfo()
            EndIf    
        EndIf    
    EndIf
EndIf

Return Self

/*/{protheus.doc} Liberado
*******************************************************************************************
Verifica se a rotina esta liberada para uso
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Liberado() Class MCMagento
Local lRet      := .T.
Local dLimite   := Stod("20221231")

Self:cMsgBloqueio := ""

lRet := dLimite >= Date()
If !lRet
    Self:cMsgBloqueio := "O uso da aplicação de e-commerce da Magento foi interrompido por expiração de licença."
EndIf

If lRet 
    If Empty(Self:cUrl)
        lRet := .F.
        Self:cMsgBloqueio := "URL Wsdl de conexão com o Magento não configurada."+CRLF+"Vide parâmetro MC_MAGEURL."
    EndIf
EndIf    

If lRet 
    If Empty(Self:cUsuario)
        lRet := .F.
        Self:cMsgBloqueio := "Usuario de conexão com o Magento não configurado."+CRLF+"Vide parâmetro MC_MAGEUSR."
    EndIf    
EndIf    

If lRet
    If Empty(Self:cSenha)
        lRet := .F.
        Self:cMsgBloqueio := "Senha de conexão com o Magento não configurado."+CRLF+"Vide parâmetro MC_MAGEPSW."
    EndIf
EndIf    

If lRet 
    If Empty(Self:cLoja)
        lRet := .F.
        Self:cMsgBloqueio := "Codigo da Loja no Magento não configurado."+CRLF+"Vide parâmetro MC_MAGELOJ."
    EndIf
EndIf    

If lRet 
    If Empty(Self:cTabPreco)
        lRet := .F.
        Self:cMsgBloqueio := "Tabela de Preço do e-Commerce não configurado."+CRLF+"Vide parâmetro MC_MAGETPR"
    Else
        DA0->(dbSetOrder(1))
        If !DA0->(dbSeek(xFilial("DA0")+Alltrim(Self:cTabPreco)))
            lRet := .F.
            Self:cMsgBloqueio := "Tabela de Preço do e-Commerce não Localizado."+CRLF+"Vide parâmetro MC_MAGETPR"
        Else
            If Alltrim(DA0->DA0_ATIVO) == "2"
                lRet := .F.
                Self:cMsgBloqueio := "Tabela de Preço do e-Commerce Desativada."+CRLF+"Vide parâmetro MC_MAGETPR"
            Else
                If !Empty(DA0->DA0_DATATE) .And. Date() > DA0->DA0_DATATE
                    lRet := .F.
                    Self:cMsgBloqueio := "Tabela de Preço do e-Commerce Fora da Data de Vigência."+CRLF+"Vide parâmetro MC_MAGETPR"
                EndIf
            EndIf
        EndIf
    EndIf    
EndIf    

If lRet 
    If Empty(Self:cNatureza)
        lRet := .F.
        Self:cMsgBloqueio := "Natureza Padrão para o uso nos Clientes Baixados do e-Commerce não configurado."+CRLF+"Vide parâmetro MC_MAGENAT"
    Else
        SED->(dbSetOrder(1))
        If !SED->(dbSeek(xFilial("SED")+Alltrim(Self:cNatureza)))
            lRet := .F.
            Self:cMsgBloqueio := "Natureza Padrão para o uso nos Clientes Baixados do e-Commerce não Localizado."+CRLF+"Vide parâmetro MC_MAGENAT"
        Else
            If Alltrim(SED->ED_MSBLQL) == "1"
                lRet := .F.
                Self:cMsgBloqueio := "Natureza Padrão para o uso nos Clientes Baixados do e-Commerce Bloqueada."+CRLF+"Vide parâmetro MC_MAGENAT"
            EndIf
        EndIf
    EndIf    
EndIf    

If lRet 
    If Empty(Self:cTes)
        lRet := .T.
        Self:cMsgBloqueio := "TES Padrão para vendas do e-Commerce não configurado."+CRLF+"Vide parâmetro MC_MAGETES"
    Else
        SF4->(dbSetOrder(1))
        If !SF4->(dbSeek(xFilial("SF4")+Alltrim(Self:cTes)))
            lRet := .F.
            Self:cMsgBloqueio := "TES Padrão para vendas do e-Commerce não Localizado."+CRLF+"Vide parâmetro MC_MAGETES"
        Else
            If Alltrim(SF4->F4_MSBLQL) == "1"
                lRet := .F.
                Self:cMsgBloqueio := "TES Padrão para vendas do e-Commerce Bloqueada."+CRLF+"Vide parâmetro MC_MAGETES"
            Else
                If Alltrim(SF4->F4_TIPO) <> "S"
                    lRet := .F.
                    Self:cMsgBloqueio := "TES Padrão para vendas do e-Commerce não configurada como Saida."+CRLF+"Vide parâmetro MC_MAGETES"
                EndIf
            EndIf
        EndIf
    EndIf    
EndIf    

If lRet 
    If Empty(Self:cCond)
        lRet := .F.
        Self:cMsgBloqueio := "Cond. Pgto do e-Commerce não configurado."+CRLF+"Vide parâmetro MC_MAGETPR"
    Else
        SE4->(dbSetOrder(1))
        If !SE4->(dbSeek(xFilial("SE4")+Alltrim(Self:cCond)))
            lRet := .F.
            Self:cMsgBloqueio := "Cond. Pgto do e-Commerce não Localizado."+CRLF+"Vide parâmetro MC_MAGETPR"
        Else
            If Alltrim(SE4->E4_MSBLQL) == "1"
                lRet := .F.
                Self:cMsgBloqueio := "Cond. Pgto do e-Commerce Bloqueada."+CRLF+"Vide parâmetro MC_MAGETPR"
            EndIf
        EndIf
    EndIf    
EndIf    

If lRet 
    If Self:lCriaNf
        If Empty(Self:cSerie)
            lRet := .F.
            Self:cMsgBloqueio := "Serie da Nota de Saida para vendas no e-Commerce não Configurada."+CRLF+"Vide parâmetro MC_MAGESER"
        Else
            SX5->(dbSetOrder(1))
            If  SX5->(dbSeek(xFilial("SX5")                     +PadR("01",Tamsx3("X5_TABELA")[01])+PadR(Self:cSerie,Tamsx3("X5_CHAVE")[01]))) .Or. ;
                SX5->(dbSeek(PadR(" ",Tamsx3("X5_FILIAL")[01])  +PadR("01",Tamsx3("X5_TABELA")[01])+PadR(Self:cSerie,Tamsx3("X5_CHAVE")[01])))
                
                lRet := .T.
            Else
                lRet := .F.
                Self:cMsgBloqueio := "Serie da Nota de Saida para vendas no e-Commerce não Configurada na Tabela 01 do SX5."+CRLF+"Vide parâmetro MC_MAGESER"
            EndIf
        EndIf    
    EndIf    
EndIf    

Return lRet

/*/{protheus.doc} Autentica
*******************************************************************************************
Cria a autenticação da conexão
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Autentica() Class MCMagento
If Valtype(Self:oWsdl)<>"O"
    Self:oWsdl                  := TWsdlManager():New()

	//######################################################
	//## Remocao do Certificado!                          ##
	//## Nenecessario em 01/10/21, quando o certificado   ##
	//## expirou para qualquer uso em internet            ##
	//##--------------------------------------------------##
	//## RENATO SANTOS                           01/10/21 ##
	//######################################################
    //Self:oWsdl:cSSLCACertFile   := Self:GetCertif()	//Substituido pela linha abaixo, para não usar mais o Certificado
	Self:oWsdl:lSSLInsecure := .T.						
	
	Self:oWsdl:nTimeout         := 120
    Self:lConectado := Self:oWsdl:ParseURL(Self:cUrl)
EndIf
If Self:lConectado
    If Len(Self:oWsdl:ListOperations())==0
        Self:lConectado := .F.
    Else
        Self:GetToken()
        If Empty(Self:cToken)            
            Self:lConectado := .F.
        EndIf        
    EndIf    
EndIf

Return Self

/*/{protheus.doc} GetToken
*******************************************************************************************
Classe de comunicação com o Magento - Webservices do e-Commerce
Inicialização
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetToken(lSoToken) Class MCMagento
Local oXml      := NIL
Local cEnvelope := ""
Local cResponse := ""
Local cError    := ""
Local cWarning  := ""

Default lSoToken := .F.

If Self:lConectado .Or. lSoToken
    If Self:oWsdl:SetOperation("login")
        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'  + CRLF
        cEnvelope += '<soapenv:Header/>'                                                                                                                                                                                        + CRLF
        cEnvelope += '    <soapenv:Body>'                                                                                                                                                                                       + CRLF
        cEnvelope += '        <urn:login soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'                                                                                                                    + CRLF
        cEnvelope += '            <username xsi:type="xsd:string">'+Self:cUsuario+'</username>'                                                                                                                                 + CRLF
        cEnvelope += '            <apiKey xsi:type="xsd:string">'+Self:cSenha+'</apiKey>'                                                                                                                                       + CRLF
        cEnvelope += '        </urn:login>'                                                                                                                                                                                     + CRLF
        cEnvelope += '    </soapenv:Body>'                                                                                                                                                                                      + CRLF
        cEnvelope += '</soapenv:Envelope>'                                                                                                                                                                                      + CRLF
        
        //Envia uma mensagem SOAP personalizada ao servidor
        If Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()
                                
            //Transforma a resposta em um objeto
            oXml := XmlParser(cResponse, "_", @cError, @cWarning)
            Self:cToken      := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_LOGINRESPONSE:_LOGINRETURN:TEXT
            Self:cGeracToken := Dtos(Date())+" "+Time()
        Else
            Self:cError      := Self:oWsdl:cError
            Self:cToken      := ""
            Self:cGeracToken := ""
        EndIf        
    Else
        Self:cError      := Self:oWsdl:cError
        Self:cToken      := ""
        Self:cGeracToken := ""
    EndIf
EndIf

Return Self

/*/{protheus.doc} Fechar
*******************************************************************************************
Fechar a Conexão
 
@author: Marcelo Celi Marques
@since: 27/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Fechar() Class MCMagento
Local cEnvelope := ""
Local cResponse := ""

If Self:lConectado
    If Self:oWsdl:SetOperation("endSession")
        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
        cEnvelope += '   <soapenv:Header/>'+CRLF
        cEnvelope += '   <soapenv:Body>'+CRLF
        cEnvelope += '      <urn:endSession soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
        cEnvelope += '      </urn:endSession>'+CRLF
        cEnvelope += '   </soapenv:Body>'+CRLF
        cEnvelope += '</soapenv:Envelope>'+CRLF

        If Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()
        EndIf
    EndIf
EndIf

Return Self

/*/{protheus.doc} GetCertif
*******************************************************************************************
Retorna o Certificado de Conexao
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetCertif() Class MCMagento
Local cCertificad   := ""
Local cArquivo      := ""
Local cPasta        := GetSrvProfString ("STARTPATH","")
Local cRetorno      := ""

cPasta := Alltrim(cPasta)
cPasta := StrTran(cPasta,"/","\")
cPasta += If(Right(cPasta,1)=="\","","\")

If Alltrim(Upper(Self:cUrl)) == Alltrim(Upper("https://homologbombay.signashop.com.br/api/v2_soap?wsdl=1"))
    //->> homologação
    cArquivo := "MagentoHom.pem"

    cCertificad := "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIGEzCCA/ugAwIBAgIQfVtRJrR2uhHbdBYLvFMNpzANBgkqhkiG9w0BAQwFADCB"+CRLF
    cCertificad += "iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl"+CRLF
    cCertificad += "cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV"+CRLF
    cCertificad += "BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgx"+CRLF
    cCertificad += "MTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjCBjzELMAkGA1UEBhMCR0IxGzAZBgNV"+CRLF
    cCertificad += "BAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UE"+CRLF
    cCertificad += "ChMPU2VjdGlnbyBMaW1pdGVkMTcwNQYDVQQDEy5TZWN0aWdvIFJTQSBEb21haW4g"+CRLF
    cCertificad += "VmFsaWRhdGlvbiBTZWN1cmUgU2VydmVyIENBMIIBIjANBgkqhkiG9w0BAQEFAAOC"+CRLF
    cCertificad += "AQ8AMIIBCgKCAQEA1nMz1tc8INAA0hdFuNY+B6I/x0HuMjDJsGz99J/LEpgPLT+N"+CRLF
    cCertificad += "TQEMgg8Xf2Iu6bhIefsWg06t1zIlk7cHv7lQP6lMw0Aq6Tn/2YHKHxYyQdqAJrkj"+CRLF
    cCertificad += "eocgHuP/IJo8lURvh3UGkEC0MpMWCRAIIz7S3YcPb11RFGoKacVPAXJpz9OTTG0E"+CRLF
    cCertificad += "oKMbgn6xmrntxZ7FN3ifmgg0+1YuWMQJDgZkW7w33PGfKGioVrCSo1yfu4iYCBsk"+CRLF
    cCertificad += "Haswha6vsC6eep3BwEIc4gLw6uBK0u+QDrTBQBbwb4VCSmT3pDCg/r8uoydajotY"+CRLF
    cCertificad += "uK3DGReEY+1vVv2Dy2A0xHS+5p3b4eTlygxfFQIDAQABo4IBbjCCAWowHwYDVR0j"+CRLF
    cCertificad += "BBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFI2MXsRUrYrhd+mb"+CRLF
    cCertificad += "+ZsF4bgBjWHhMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0G"+CRLF
    cCertificad += "A1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAbBgNVHSAEFDASMAYGBFUdIAAw"+CRLF
    cCertificad += "CAYGZ4EMAQIBMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0"+CRLF
    cCertificad += "LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2Bggr"+CRLF
    cCertificad += "BgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNv"+CRLF
    cCertificad += "bS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDov"+CRLF
    cCertificad += "L29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAMr9hvQ5Iw0/H"+CRLF
    cCertificad += "ukdN+Jx4GQHcEx2Ab/zDcLRSmjEzmldS+zGea6TvVKqJjUAXaPgREHzSyrHxVYbH"+CRLF
    cCertificad += "7rM2kYb2OVG/Rr8PoLq0935JxCo2F57kaDl6r5ROVm+yezu/Coa9zcV3HAO4OLGi"+CRLF
    cCertificad += "H19+24rcRki2aArPsrW04jTkZ6k4Zgle0rj8nSg6F0AnwnJOKf0hPHzPE/uWLMUx"+CRLF
    cCertificad += "RP0T7dWbqWlod3zu4f+k+TY4CFM5ooQ0nBnzvg6s1SQ36yOoeNDT5++SR2RiOSLv"+CRLF
    cCertificad += "xvcRviKFxmZEJCaOEDKNyJOuB56DPi/Z+fVGjmO+wea03KbNIaiGCpXZLoUmGv38"+CRLF
    cCertificad += "sbZXQm2V0TP2ORQGgkE49Y9Y3IBbpNV9lXj9p5v//cWoaasm56ekBYdbqbe4oyAL"+CRLF
    cCertificad += "l6lFhd2zi+WJN44pDfwGF/Y4QA5C5BIG+3vzxhFoYt/jmPQT2BVPi7Fp2RBgvGQq"+CRLF
    cCertificad += "6jG35LWjOhSbJuMLe/0CjraZwTiXWTb2qHSihrZe68Zk6s+go/lunrotEbaGmAhY"+CRLF
    cCertificad += "LcmsJWTyXnW0OMGuf1pGg+pRyrbxmRE1a6Vqe8YAsOf4vmSyrcjC8azjUeqkk+B5"+CRLF
    cCertificad += "yOGBQMkKW+ESPMFgKuOXwIlCypTPRpgSabuY0MLTDXJLR27lk8QyKGOHQ+SwMj4K"+CRLF
    cCertificad += "00u/I5sUKUErmgQfky3xxzlIPK1aEn8="+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF

    cCertificad += "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIF3jCCA8agAwIBAgIQAf1tMPyjylGoG7xkDjUDLTANBgkqhkiG9w0BAQwFADCB"+CRLF
    cCertificad += "iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl"+CRLF
    cCertificad += "cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV"+CRLF
    cCertificad += "BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAw"+CRLF
    cCertificad += "MjAxMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNV"+CRLF
    cCertificad += "BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU"+CRLF
    cCertificad += "aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy"+CRLF
    cCertificad += "dGlmaWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK"+CRLF
    cCertificad += "AoICAQCAEmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B"+CRLF
    cCertificad += "3PHTsdZ7NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkY"+CRLF
    cCertificad += "tJHUYmTbf6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/"+CRLF
    cCertificad += "Fp0YvVGONaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2"+CRLF
    cCertificad += "VN3I5xI6Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT"+CRLF
    cCertificad += "79uq/nROacdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6"+CRLF
    cCertificad += "c0Plfg6lZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmT"+CRLF
    cCertificad += "Yo61Zs8liM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97l"+CRLF
    cCertificad += "c6wjOy0AvzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4ee"+CRLF
    cCertificad += "UB9XVKg+/XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeE"+CRLF
    cCertificad += "Hg9j1uliutZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo0IwQDAd"+CRLF
    cCertificad += "BgNVHQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgEGMA8G"+CRLF
    cCertificad += "A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAFzUfA3P9wF9QZllDHPF"+CRLF
    cCertificad += "Up/L+M+ZBn8b2kMVn54CVVeWFPFSPCeHlCjtHzoBN6J2/FNQwISbxmtOuowhT6KO"+CRLF
    cCertificad += "VWKR82kV2LyI48SqC/3vqOlLVSoGIG1VeCkZ7l8wXEskEVX/JJpuXior7gtNn3/3"+CRLF
    cCertificad += "ATiUFJVDBwn7YKnuHKsSjKCaXqeYalltiz8I+8jRRa8YFWSQEg9zKC7F4iRO/Fjs"+CRLF
    cCertificad += "8PRF/iKz6y+O0tlFYQXBl2+odnKPi4w2r78NBc5xjeambx9spnFixdjQg3IM8WcR"+CRLF
    cCertificad += "iQycE0xyNN+81XHfqnHd4blsjDwSXWXavVcStkNr/+XeTWYRUc+ZruwXtuhxkYze"+CRLF
    cCertificad += "Sf7dNXGiFSeUHM9h4ya7b6NnJSFd5t0dCy5oGzuCr+yDZ4XUmFF0sbmZgIn/f3gZ"+CRLF
    cCertificad += "XHlKYC6SQK5MNyosycdiyA5d9zZbyuAlJQG03RoHnHcAP9Dc1ew91Pq7P8yF1m9/"+CRLF
    cCertificad += "qS3fuQL39ZeatTXaw2ewh0qpKJ4jjv9cJ2vhsE/zB+4ALtRZh8tSQZXq9EfX7mRB"+CRLF
    cCertificad += "VXyNWQKV3WKdwrnuWih0hKWbt5DHDAff9Yk2dDLWKMGwsAvgnEzDHNb842m1R0aB"+CRLF
    cCertificad += "L6KCq9NjRHDEjf8tM7qtj3u1cIiuPhnPQCjY/MiQu12ZIvVS5ljFH4gxQ+6IHdfG"+CRLF
    cCertificad += "jjxDah2nGN59PRbxYvnKkKj9"+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF

    cCertificad += "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIFxjCCBK6gAwIBAgIRAKykQOS64IpBU7vM3XyjtlEwDQYJKoZIhvcNAQELBQAw"+CRLF
    cCertificad += "gY8xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO"+CRLF
    cCertificad += "BgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDE3MDUGA1UE"+CRLF
    cCertificad += "AxMuU2VjdGlnbyBSU0EgRG9tYWluIFZhbGlkYXRpb24gU2VjdXJlIFNlcnZlciBD"+CRLF
    cCertificad += "QTAeFw0yMDA0MTQwMDAwMDBaFw0yMTA0MjYyMzU5NTlaMB0xGzAZBgNVBAMMEiou"+CRLF
    cCertificad += "c2lnbmFzaG9wLmNvbS5icjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB"+CRLF
    cCertificad += "APVMqrcH8tBLmHNxbhZIEr3kJl5wNeluJiivujPonF7wiwIxV11bciqIkPr2UggL"+CRLF
    cCertificad += "dIeOoZRj01w+B+Je7s/VaoowahAAcSj6iscba8uF8ufrcyGLaQo+i703QPM1h53b"+CRLF
    cCertificad += "WI7iB7vAum6QSNeNiOD1QbJ1TX1L3/i8d0ru54XG2VTa1E53hMB92f1i2jcS/1ui"+CRLF
    cCertificad += "pLZCSSP6ALiv4p2sDdc2KjeAW9y1GhKUd6wBOoMvBgPyXxcGN4sQNXia+dMCoqvp"+CRLF
    cCertificad += "85EHBxBTRUCIg0lGaU1FcmjlJdlQLHTA/wPPbRev/sWjmh+Mq2etO2aWHlCl7HPw"+CRLF
    cCertificad += "TF/bfI/6gI6DLz0oA0+IP3sCAwEAAaOCAowwggKIMB8GA1UdIwQYMBaAFI2MXsRU"+CRLF
    cCertificad += "rYrhd+mb+ZsF4bgBjWHhMB0GA1UdDgQWBBR7WK3SN933VrzDhAlzNzUAx7RkpTAO"+CRLF
    cCertificad += "BgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHSUEFjAUBggrBgEFBQcD"+CRLF
    cCertificad += "AQYIKwYBBQUHAwIwSQYDVR0gBEIwQDA0BgsrBgEEAbIxAQICBzAlMCMGCCsGAQUF"+CRLF
    cCertificad += "BwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQUzAIBgZngQwBAgEwgYQGCCsGAQUF"+CRLF
    cCertificad += "BwEBBHgwdjBPBggrBgEFBQcwAoZDaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0"+CRLF
    cCertificad += "aWdvUlNBRG9tYWluVmFsaWRhdGlvblNlY3VyZVNlcnZlckNBLmNydDAjBggrBgEF"+CRLF
    cCertificad += "BQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wLwYDVR0RBCgwJoISKi5zaWdu"+CRLF
    cCertificad += "YXNob3AuY29tLmJyghBzaWduYXNob3AuY29tLmJyMIIBBAYKKwYBBAHWeQIEAgSB"+CRLF
    cCertificad += "9QSB8gDwAHYAfT7y+I//iFVoJMLAyp5SiXkrxQ54CX8uapdomX4i8NcAAAFxemvJ"+CRLF
    cCertificad += "tQAABAMARzBFAiEA9EKkfew/+rXkvijxSGp3//6xYY8vTpdp6ZrGq9v+42gCIFuZ"+CRLF
    cCertificad += "WsQbpo8TXx8dV/X3pMjpkhtUlLk97ME/e1M5943JAHYAlCC8Ho7VjWyIcx+CiyIs"+CRLF
    cCertificad += "DdHaTV5sT5Q9YdtOL1hNosIAAAFxemvLEwAABAMARzBFAiA8s2Z0JQeYj+rFvjUU"+CRLF
    cCertificad += "Mc+B6XiemXhI3PHSq3BFGgRdigIhAIP+RDhjMMqcL6NBrKJV7RZ3S3St2QjU/zWf"+CRLF
    cCertificad += "SLYR4hfSMA0GCSqGSIb3DQEBCwUAA4IBAQBOggO5BLJVim0K83PxW2pQNnea+87A"+CRLF
    cCertificad += "NLTPWTrHEl14HQ8MQu7VhAuvJhljak84MbdnYxqbqVcs2otfY0Vpwo+WLgLluA/G"+CRLF
    cCertificad += "7oKOFLdw7TlbOxpMX+2U/aNMtx0+0qmb1amiF0A6XSessQWU7xCxsd0H45EtTopE"+CRLF
    cCertificad += "j5v2jLJ7hbtlpoZ7Fs+kj6+0Jze618lv6uLd7mieo3vgsgixWXWDNeR2UxailBuU"+CRLF
    cCertificad += "S+YLyLc2iPCdM+GJsa6xZDplIzs5hKfseLPuDHz6G0kzIRkJzB9XM6rf94QUJwbb"+CRLF
    cCertificad += "X2zbVLOaIJZ2NQS1I5jimkL4b3d7TLmmSwEA6gSlHxoaqHxJjKug4uDI"+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF

Else 
    // producao
    cArquivo := "MagentoProd.pem"
    
    cCertificad := "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIFcjCCBFqgAwIBAgISA8M9X7vltvpR1jbg89pnyfq5MA0GCSqGSIb3DQEBCwUA"+CRLF
    cCertificad += "MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD"+CRLF
    cCertificad += "ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0yMDA2MTIwNjA0MzFaFw0y"+CRLF
    cCertificad += "MDA5MTAwNjA0MzFaMCgxJjAkBgNVBAMTHWFkbWluLmJvbWJheS5zaWduYXNob3Au"+CRLF
    cCertificad += "Y29tLmJyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA81iLvdf/zy+h"+CRLF
    cCertificad += "8AUIXfulcuXF5DyxCBs91WIeImlbh8UjF5SjFGQ4j67XgWKnoi1qY0olkjbhiAOh"+CRLF
    cCertificad += "aujJ7hUpg+QMqYQjhq/fxnYOUsZp7ADkPSdiJyqXvrfK0RMvFB3nzws9+WSTz21b"+CRLF
    cCertificad += "f+14ZK7HZZYd/p77eH74qfarMzrPmsesKqq4C/sxQ56d+if4RUiz9Qrj0KI9C4aw"+CRLF
    cCertificad += "P9wf/UiACMUz8ACnYVJfB7g2OH/t31KvknaMehWLq4puVrcWJld7nQrQlDwMh3WI"+CRLF
    cCertificad += "avSzeBk8PEmmt3Hz6jOh27m9zMcSvxnHuSVPDxMO2Q3DNJRAk/0dp1NJEt4xhEWE"+CRLF
    cCertificad += "p0ZVvD/3uwIDAQABo4ICcjCCAm4wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQG"+CRLF
    cCertificad += "CCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQtADCn"+CRLF
    cCertificad += "c3psWiIcsc+ifwsAOZAaQDAfBgNVHSMEGDAWgBSoSmpjBH3duubRObemRWXv86js"+CRLF
    cCertificad += "oTBvBggrBgEFBQcBAQRjMGEwLgYIKwYBBQUHMAGGImh0dHA6Ly9vY3NwLmludC14"+CRLF
    cCertificad += "My5sZXRzZW5jcnlwdC5vcmcwLwYIKwYBBQUHMAKGI2h0dHA6Ly9jZXJ0LmludC14"+CRLF
    cCertificad += "My5sZXRzZW5jcnlwdC5vcmcvMCgGA1UdEQQhMB+CHWFkbWluLmJvbWJheS5zaWdu"+CRLF
    cCertificad += "YXNob3AuY29tLmJyMEwGA1UdIARFMEMwCAYGZ4EMAQIBMDcGCysGAQQBgt8TAQEB"+CRLF
    cCertificad += "MCgwJgYIKwYBBQUHAgEWGmh0dHA6Ly9jcHMubGV0c2VuY3J5cHQub3JnMIIBBAYK"+CRLF
    cCertificad += "KwYBBAHWeQIEAgSB9QSB8gDwAHYAsh4FzIuizYogTodm+Su5iiUgZ2va+nDnsklT"+CRLF
    cCertificad += "Le+LkF4AAAFyp1gnhgAABAMARzBFAiEA8hGXYuWtIeTkX54qPitIw9XalHC3N6Lt"+CRLF
    cCertificad += "tLOC3hT4/9YCIA8M2lD1V/AvFHk1BlulvOMgDlUBUi/wg8SOFyYZhGsZAHYAb1N2"+CRLF
    cCertificad += "rDHwMRnYmQCkURX/dxUcEdkCwQApBo2yCJo32RMAAAFyp1gnswAABAMARzBFAiEA"+CRLF
    cCertificad += "m/zLiNuRjJNnvBCZQWeXUhUTjGoirSiuiN5aPuVL1HwCIAHd5GxS9YGNmTp8G2iJ"+CRLF
    cCertificad += "jF/51r0W7NYmXcH4+y7izdmQMA0GCSqGSIb3DQEBCwUAA4IBAQCBLld2HwRbY5h7"+CRLF
    cCertificad += "P2UyAV+gCx3RLRTGQu3TwYj2GoxkPr7IQK3ulXySjwsB61MbxKyqAipCazBFxOR3"+CRLF
    cCertificad += "NhgCfUCcv7cAaIS0cp515haMXnf+I+kq78V/5RMBC2lvMDNZignr7ndDlNR5cusE"+CRLF
    cCertificad += "ay2LbgSrFpHz/g8Zz3+4Qix8GgtTl+V6K53yZ6c+Y03B9VKWbU3oBBDAHNcvX1op"+CRLF
    cCertificad += "GdTuDoQrdEoZoYrbdcsK+DFycvvGeTgyt8f1lLj8LL9SgBaLKMnLyyb3uQWPwzIX"+CRLF
    cCertificad += "5JTgsv+WeHIRsbuAbuLxXtWA4a2KCa9MJzWWzuHwaUALMaWkHP5hk3p/zc/n2VNx"+CRLF
    cCertificad += "+tKqFPLv"+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF
    cCertificad += "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/"+CRLF
    cCertificad += "MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT"+CRLF
    cCertificad += "DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow"+CRLF
    cCertificad += "SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT"+CRLF
    cCertificad += "GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC"+CRLF
    cCertificad += "AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF"+CRLF
    cCertificad += "q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8"+CRLF
    cCertificad += "SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0"+CRLF
    cCertificad += "Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA"+CRLF
    cCertificad += "a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj"+CRLF
    cCertificad += "/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T"+CRLF
    cCertificad += "AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG"+CRLF
    cCertificad += "CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv"+CRLF
    cCertificad += "bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k"+CRLF
    cCertificad += "c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw"+CRLF
    cCertificad += "VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC"+CRLF
    cCertificad += "ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz"+CRLF
    cCertificad += "MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu"+CRLF
    cCertificad += "Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF"+CRLF
    cCertificad += "AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo"+CRLF
    cCertificad += "uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/"+CRLF
    cCertificad += "wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu"+CRLF
    cCertificad += "X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG"+CRLF
    cCertificad += "PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6"+CRLF
    cCertificad += "KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg=="+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF
    cCertificad += "-----BEGIN CERTIFICATE-----"+CRLF
    cCertificad += "MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/"+CRLF
    cCertificad += "MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT"+CRLF
    cCertificad += "DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow"+CRLF
    cCertificad += "PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD"+CRLF
    cCertificad += "Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB"+CRLF
    cCertificad += "AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O"+CRLF
    cCertificad += "rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq"+CRLF
    cCertificad += "OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b"+CRLF
    cCertificad += "xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw"+CRLF
    cCertificad += "7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD"+CRLF
    cCertificad += "aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV"+CRLF
    cCertificad += "HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG"+CRLF
    cCertificad += "SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69"+CRLF
    cCertificad += "ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr"+CRLF
    cCertificad += "AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz"+CRLF
    cCertificad += "R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5"+CRLF
    cCertificad += "JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo"+CRLF
    cCertificad += "Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ"+CRLF
    cCertificad += "-----END CERTIFICATE-----"+CRLF

EndIf

If !File(cPasta+cArquivo)
    MemoWrite(cPasta+cArquivo,cCertificad)
    If !File(cPasta+cArquivo)
        cRetorno := ""
    Else
        cRetorno := cPasta+cArquivo
    EndIf
Else
    cRetorno := cPasta+cArquivo
EndIf

Return cRetorno

/*/{protheus.doc} DesceUF
*******************************************************************************************
Desce as unidades federativas do cadastro magento
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method DesceUF(cIdPais) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local nX            := 1

Default cIdPais     := "BR"

Private oXml        := NIL

If Self:oWsdl:SetOperation("directoryRegionList")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'  +CRLF
    cEnvelope += '<soapenv:Header/>'                                                                                                                                                                                        +CRLF
    cEnvelope += '<soapenv:Body>'                                                                                                                                                                                           +CRLF
    cEnvelope += '    <urn:directoryRegionList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'                                                                                                          +CRLF
    cEnvelope += '        <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'                                                                                                                                     +CRLF
    cEnvelope += '        <country xsi:type="xsd:string">'+cIdPais+'</country>'                                                                                                                                             +CRLF
    cEnvelope += '    </urn:directoryRegionList>'                                                                                                                                                                           +CRLF
    cEnvelope += '</soapenv:Body>'                                                                                                                                                                                          +CRLF
    cEnvelope += '</soapenv:Envelope>'                                                                                                                                                                                      +CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                    
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM") <> "U"
                If Valtype(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM) == "A"
                    For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM)
                        If Ascan(Self:aUf,{|x| x[01]+x[02] == cIdPais + OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM[nX]:_REGION_ID:Text }) == 0
                            aAdd(Self:aUf ,{    cIdPais,                                                                                                         ; // - 01 - Codigo do Pais
                                                OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM[nX]:_REGION_ID:Text,    ; // - 02 - Codigo do estado
                                                OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_DIRECTORYREGIONLISTRESPONSE:_COUNTRIES:_ITEM[nX]:_CODE:Text}         ) // - 03 - Sigla da Unidade Federativa
                        EndIf                        
                    Next nX
                EndIf
            EndIf
        EndIf
    Else
        Self:cError := Self:oWsdl:cError
    EndIf    
EndIf

Return Self

/*/{protheus.doc} GetInfo
*******************************************************************************************
Retorna as informações do ambiente magento
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetInfo() Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""

Private oXml        := NIL

Self:aDadConex  := {"","","","","","","","","",""}

If Self:oWsdl:SetOperation("magentoInfo")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:magentoInfo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '      </urn:magentoInfo>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                    
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_MAGENTOINFORESPONSE:_INFO") <> "U"
                Self:aDadConex[01] := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_MAGENTOINFORESPONSE:_INFO:_MAGENTO_VERSION:TEXT
                Self:aDadConex[02] := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_MAGENTOINFORESPONSE:_INFO:_MAGENTO_EDITION:TEXT
            EndIf
        EndIf
    Else
        Self:cError := Self:oWsdl:cError
    EndIf    
EndIf

If Self:oWsdl:SetOperation("storeInfo")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:storeInfo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <storeId xsi:type="xsd:string">'+Self:cLoja+'</storeId>'+CRLF
    cEnvelope += '      </urn:storeInfo>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                    
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_STOREINFORESPONSE:_INFO") <> "U"
                Self:aDadConex[03] := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_STOREINFORESPONSE:_INFO:_CODE:TEXT
                Self:aDadConex[04] := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_STOREINFORESPONSE:_INFO:_NAME:TEXT
                Self:aDadConex[05] := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_STOREINFORESPONSE:_INFO:_IS_ACTIVE:TEXT
            EndIf
        EndIf
    Else
        Self:cError := Self:oWsdl:cError
    EndIf    

EndIf

Return Self

/*/{protheus.doc} DescePedidos
*******************************************************************************************
Retorna os pedidos do magento
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method DescePedidos(nTipo,dInicio) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local cDataDe       := ""
Local cDataAte      := ""
Local cStatPedid    := ""
Local dDataProc     := dInicio
Local cIdCliente    := ""


//->> Marcelo Celi - 28/12/2020
Local cDataUpd      := ""
Local cIdPedid      := ""

Private oXml        := NIL
Private nX          := 0

Default nTipo       := 1

//->> Extrai o status do pedido
Do Case
    Case nTipo == 1
        cStatPedid  := "processing"

EndCase    

//->> Extrai a data do pedido
cDataDe  := StrZero(Year(dDataProc),4)+"-"+StrZero(Month(dDataProc),2)+"-"+StrZero(Day(dDataProc),2)+" 00:00:00"
cDataAte := StrZero(Year(dDataProc),4)+"-"+StrZero(Month(dDataProc),2)+"-"+StrZero(Day(dDataProc),2)+" 23:59:59"

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("salesOrderList")
    Self:Iniciar(Self:lJob)
EndIf

Self:aPedidos := {}
If Self:oWsdl:SetOperation("salesOrderList")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:salesOrderList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <filters xsi:type="urn:filters">'+CRLF
    cEnvelope += '            <!--You may enter the following 2 items in any order-->'+CRLF
    cEnvelope += '            <!--Optional:-->'+CRLF
    cEnvelope += '            <filter xsi:type="urn:associativeArray" soapenc:arrayType="urn:associativeEntity[]">'+CRLF
    cEnvelope += '                <item>'+CRLF
    cEnvelope += '				    <key>status</key>'+CRLF
    cEnvelope += '            		<value>'+cStatPedid+'</value>'+CRLF
    cEnvelope += '            	</item>'+CRLF
    cEnvelope += '            </filter>'+CRLF
    cEnvelope += '            <!--Optional:-->'+CRLF
    cEnvelope += '            <complex_filter xsi:type="urn:complexFilterArray" soapenc:arrayType="urn:complexFilter[]">'+CRLF
    
    //->> Marcelo Celi - 28/12/2020
    cEnvelope += '<item>'                                           +CRLF
    cEnvelope += '    <key>updated_at</key>'                        +CRLF
    cEnvelope += '        <value>'                                  +CRLF
    cEnvelope += '          <key>gt</key>'                          +CRLF
    cEnvelope += '          <value>'+cDataDe+'</value>'             +CRLF
    cEnvelope += '        </value>'                                 +CRLF
    cEnvelope += '</item>'                                          +CRLF

    cEnvelope += '<item>'                                           +CRLF
    cEnvelope += '    <key>updated_at</key>'                        +CRLF
    cEnvelope += '        <value>'                                  +CRLF
    cEnvelope += '            <key>lt</key>'                        +CRLF
    cEnvelope += '            <value>'+cDataAte+'</value>'          +CRLF
    cEnvelope += '        </value>'                                 +CRLF
    cEnvelope += '</item>'                                          +CRLF
        
    //->> Marcelo Celi - 28/12/2020
    //cEnvelope += '            	<item>'+CRLF
    //cEnvelope += '                  <key>updated_at</key>'+CRLF
    //cEnvelope += '                    <value>'+CRLF
    //cEnvelope += '                        <key>gt</key>'+CRLF
    //cEnvelope += '                        <value>'+cDataPedid+'</value>'+CRLF
    //cEnvelope += '                    </value>'+CRLF
    //cEnvelope += '                </item>'+CRLF
        
    cEnvelope += '            </complex_filter>'+CRLF
    cEnvelope += '         </filters>'+CRLF
    cEnvelope += '      </urn:salesOrderList>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM")<>"U"
                If Valtype(oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM)=="A"
                    For nX:=1 to Len(oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM)
                        
                        cDataUpd := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_updated_at:Text
                        cIdPedid := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_increment_id:Text
                        
                        SC5->( dbOrderNickName("C5XIDECOM") )
                        If cDataUpd >= cDataDe .And. cDataUpd <= cDataAte
                            If !SC5->(dbSeek(xFilial("SC5")+PadR(cIdPedid,Tamsx3("C5_XIDECOM")[01])))
                                If Type("oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_CUSTOMER_ID:Text")<>"U"
                                    cIdCliente := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_CUSTOMER_ID:Text
                                Else
                                    cIdCliente := ""
                                EndIf    
                                
                                aAdd(Self:aPedidos,{    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_INCREMENT_ID:Text, ;   // 01 - Id de Incremento
                                                        oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_STORE_ID:Text,     ;   // 02 - Id do Armazem
                                                        oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_CREATED_AT:Text,   ;   // 03 - Data de Criacao
                                                        oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_UPDATED_AT:Text,   ;   // 04 - Data de Atualização
                                                        cIdCliente,                                                                                              ;   // 05 - Id Cliente
                                                        {},                                                                                                      ;   // 06 - Itens do pedido
                                                        oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_SHIPPING_AMOUNT:Text, ;// 07 - Valor do frete
                                                        oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM[nX]:_DISCOUNT_AMOUNT:Text}) // 08 - Desconto
                            EndIf
                        EndIf
                    Next nX
                Else
                    
                    cDataUpd := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_updated_at:Text
                    cIdPedid := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_increment_id:Text
                    
                    SC5->( dbOrderNickName("C5XIDECOM") )
                    If cDataUpd >= cDataDe .And. cDataUpd <= cDataAte
                        If !SC5->(dbSeek(xFilial("SC5")+PadR(cIdPedid,Tamsx3("C5_XIDECOM")[01])))
                            If Type("oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_CUSTOMER_ID:Text")<>"U"
                                cIdCliente := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_CUSTOMER_ID:Text
                            Else
                                cIdCliente := ""
                            EndIf

                            aAdd(Self:aPedidos,{    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_INCREMENT_ID:Text, ;   // 01 - Id de Incremento
                                                    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_STORE_ID:Text,     ;   // 02 - Id do Armazem
                                                    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_CREATED_AT:Text,   ;   // 03 - Data de Criacao
                                                    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_UPDATED_AT:Text,   ;   // 04 - Data de Atualização
                                                    cIdCliente,                                                                                          ;   // 05 - Id Cliente
                                                    {},                                                                                                  ;   // 06 - Itens do pedido
                                                    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_SHIPPING_AMOUNT:Text,; // 07 - Valor do frete
                                                    oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERLISTRESPONSE:_RESULT:_ITEM:_DISCOUNT_AMOUNT:Text})   // 08 - Desconto
                        EndIf
                    EndIf
                EndIf
            EndIf
            //->> Obter os detalhes dos pedidos
            //For nX:=1 to Len(Self:aPedidos)
            //    aAdd(Self:aPedidos[nX][06],Self:GetDetPedid(Self:aPedidos[nX][01]))  // 01 - Detalhes dp Pedido
            //    aAdd(Self:aPedidos[nX][06],Self:GetDetClien(Self:aPedidos[nX][05]))  // 02 - Detalhes do Cliente
            //Next nX            
        EndIf                 
    Else
        Self:cError := Self:oWsdl:cError
        Self:aPedidos := {}
    EndIf
Else
    Self:cError := Self:oWsdl:cError
    Self:aPedidos := {}
EndIf

//->> Obter os detalhes dos pedidos
For nX:=1 to Len(Self:aPedidos)
    aAdd(Self:aPedidos[nX][06],Self:GetDetPedid(Self:aPedidos[nX][01]))  // 01 - Detalhes dp Pedido
    aAdd(Self:aPedidos[nX][06],Self:GetDetClien(Self:aPedidos[nX][05]))  // 02 - Detalhes do Cliente
Next nX            

Return Self:aPedidos

/*/{protheus.doc} GetDetPedid
*******************************************************************************************
Retorna os detalhes dos pedidos do magento
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetDetPedid(cIncrementId) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local nX            := 1
Local aEndEntrega   := {}
Local aEndFaturam   := {}
Local aItens        := {}
Local cRegiao       := ""

//->> Marcelo Celi - 31/12/2020
Local cPgto         := ""
Local cNumVdaEc     := ""

Private oXml        := NIL

If Self:oWsdl:SetOperation("salesOrderInfo")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'  +CRLF
    cEnvelope += '   <soapenv:Header/>'                                                                                                                                                                                     +CRLF
    cEnvelope += '   <soapenv:Body>'                                                                                                                                                                                        +CRLF
    cEnvelope += '      <urn:salesOrderInfo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'                                                                                                             +CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'                                                                                                                                         +CRLF
    cEnvelope += '         <orderIncrementId xsi:type="xsd:string">'+cIncrementId+'</orderIncrementId>'                                                                                                                     +CRLF
    cEnvelope += '      </urn:salesOrderInfo>'                                                                                                                                                                              +CRLF
    cEnvelope += '   </soapenv:Body>'                                                                                                                                                                                       +CRLF
    cEnvelope += '</soapenv:Envelope>'                                                                                                                                                                                      +CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                    
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM") <> "U"                                
                If Valtype(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM) == "A"
                    For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM)
                        aAdd(aItens,{   OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_ITEM_ID:TEXT,              ; // 01 - ID FO ITEM
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_PRODUCT_ID:TEXT,           ; // 02 - CODIGO DO PRODUTO
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_NAME:TEXT,                 ; // 03 - NOME DO PRODUTO
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_SKU:TEXT,                  ; // 04 - SKU (CODIGO DE BARRAS)
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_QTY_INVOICED:TEXT),    ; // 05 - QUANTIDADE
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_PRICE:TEXT),           ; // 06 - PREÇO UNITARIO
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_ORIGINAL_PRICE:TEXT),  ; // 06 - PREÇO UNITARIO ORIGINAL
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_ROW_TOTAL:TEXT),       ; // 07 - VALOR TOTAL
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_DISCOUNT_AMOUNT:TEXT), ; // 08 - VALOR DO DESCONTO
                                        Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM[nX]:_DISCOUNT_PERCENT:TEXT)}) // 09 - PERCENTUAL DO DESCONTO
                    Next nX
                Else
                    aAdd(aItens,{   OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_ITEM_ID:TEXT,              ; // 01 - ID FO ITEM
                                    OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_PRODUCT_ID:TEXT,           ; // 02 - CODIGO DO PRODUTO
                                    OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_NAME:TEXT,                 ; // 03 - NOME DO PRODUTO
                                    OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_SKU:TEXT,                  ; // 04 - SKU (CODIGO DE BARRAS)
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_QTY_INVOICED:TEXT),    ; // 05 - QUANTIDADE
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_PRICE:TEXT),           ; // 06 - PREÇO UNITARIO
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_ORIGINAL_PRICE:TEXT),  ; // 06 - PREÇO UNITARIO ORIGINAL
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_ROW_TOTAL:TEXT),       ; // 07 - VALOR TOTAL
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_DISCOUNT_AMOUNT:TEXT), ; // 08 - VALOR DO DESCONTO
                                    Val(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ITEMS:_ITEM:_DISCOUNT_PERCENT:TEXT)}) // 09 - PERCENTUAL DO DESCONTO
                EndIf
            EndIf
            
            //->> Endereço de Faturamento
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS") <> "U"
                
                //->> Marcelo Celi - 28/12/2020
                If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_REGION_ID:TEXT") <> "U"
                    cRegiao := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_REGION_ID:TEXT
                Else
                    cRegiao := ""
                EndIf
                
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_ADDRESS_ID:TEXT}   ) // 01 - Id do Endereço
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_ADDRESS_TYPE:TEXT} ) // 02 - Tipo de Endereço
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_FIRSTNAME:TEXT}    ) // 03 - Nome
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_LASTNAME:TEXT}     ) // 04 - Sobre nome
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_STREET:TEXT}       ) // 05 - Logradouro
                aAdd(aEndFaturam,{  cRegiao }                                                                                                       ) // 06 - Id da Regiao
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_CITY:TEXT}         ) // 07 - Cidade
                
                //->> Marcelo Celi - 28/12/2020
                If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_REGION:TEXT") <> "U"                
                    aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_REGION:TEXT}   ) // 08 - Estado
                Else
                    aAdd(aEndFaturam,{ "" }                                                                                                         ) // 08 - Estado
                EndIf    
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_COUNTRY_ID:TEXT}   ) // 09 - Cidade
                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_POSTCODE:TEXT}     ) // 10 - CEP
                
                //->> Marcelo Celi - 20/12/2020
                //aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_FAX:TEXT}        ) // 11 - FAX
                aAdd(aEndFaturam,{  " " }                                                                                                           ) // 11 - FAX

                aAdd(aEndFaturam,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_BILLING_ADDRESS:_TELEPHONE:TEXT}    ) // 12 - Telefone
            EndIf

            //->> Endereço de Entrega
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS") <> "U"
                
                //->> Marcelo Celi - 28/12/2020
                If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_REGION_ID:TEXT") <> "U"
                    cRegiao := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_REGION_ID:TEXT
                Else
                    cRegiao := ""
                EndIf                
                
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_ADDRESS_ID:TEXT}   ) // 01 - Id do Endereço
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_ADDRESS_TYPE:TEXT} ) // 02 - Tipo de Endereço
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_FIRSTNAME:TEXT}    ) // 03 - Nome
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_LASTNAME:TEXT}     ) // 04 - Sobre nome
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_STREET:TEXT}       ) // 05 - Logradouro
                aAdd(aEndEntrega,{  cRegiao  }                                                                                                       ) // 06 - Id da Regiao
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_CITY:TEXT}         ) // 07 - Cidade
                
                //->> Marcelo Celi - 28/12/2020
                If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_REGION:TEXT") <> "U"
                    aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_REGION:TEXT}   ) // 08 - Estado
                Else
                    aAdd(aEndEntrega,{ "" }                                                                                                          ) // 08 - Estado
                EndIf    
                
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_COUNTRY_ID:TEXT}   ) // 09 - Cidade
                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_POSTCODE:TEXT}     ) // 10 - CEP
                
                //->> Marcelo Celi - 20/12/2020
                //aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_FAX:TEXT}          ) // 11 - FAX
                aAdd(aEndEntrega,{  " "}                                                                                                               ) // 11 - FAX

                aAdd(aEndEntrega,{  OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_SHIPPING_ADDRESS:_TELEPHONE:TEXT}    ) // 12 - Telefone
            EndIf

            //->> Marcelo Celi - 31/12/2020
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_PAYMENT:_METHOD:TEXT") <> "U"
                cPgto := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_PAYMENT:_METHOD:TEXT
            Else
                cPgto := ""
            EndIf

            //->> Marcelo Celi - 04/01/2020
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ORDER_ID:TEXT") <> "U"
                cNumVdaEc := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_SALESORDERINFORESPONSE:_RESULT:_ORDER_ID:TEXT
            Else
                cNumVdaEc := ""
            EndIf

        EndIf
    Else
        cError := Self:oWsdl:cError
        aEndFaturam := {}
        aEndEntrega := {}
        aItens      := {}    
    EndIf    
Else
    cError := Self:oWsdl:cError
    aEndFaturam := {}
    aEndEntrega := {}
    aItens      := {}
EndIf
    
Return {aEndFaturam,aEndEntrega,aItens,cPgto,cNumVdaEc}

/*/{protheus.doc} GetDetClien
*******************************************************************************************
Retorna os detalhes do cliente
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetDetClien(cClienteId) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local aCliente      := {}
Local aTmpCli       := {}

Private nX          := 1
Private oXml        := NIL
Private cCmd        := ""

If Self:oWsdl:SetOperation("customerCustomerList")
    cEnvelope :='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +CRLF
    cEnvelope +='<soapenv:Header/>'                                                                                                                                                                                                                                                 +CRLF
    cEnvelope +='<soapenv:Body>'                                                                                                                                                                                                                                                    +CRLF
    cEnvelope +='    <urn:customerCustomerList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'                                                                                                                                                                  +CRLF
    cEnvelope +='        <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'                                                                                                                                                                                              +CRLF
    cEnvelope +='        <filters xsi:type="urn:filters">'                                                                                                                                                                                                                          +CRLF
    cEnvelope +='            <filter xsi:type="urn:associativeArray" soapenc:arrayType="urn:associativeEntity[]">'                                                                                                                                                                  +CRLF
    cEnvelope +='                <item>'                                                                                                                                                                                                                                            +CRLF
    cEnvelope +='                    <key>customer_id</key>'                                                                                                                                                                                                                        +CRLF
    cEnvelope +='                    <value>'+cClienteId+'</value>'                                                                                                                                                                                                                 +CRLF
    cEnvelope +='                </item>'                                                                                                                                                                                                                                           +CRLF
    cEnvelope +='            </filter>'                                                                                                                                                                                                                                             +CRLF
    cEnvelope +='            <complex_filter xsi:type="urn:complexFilterArray" soapenc:arrayType="urn:complexFilter[]"/>'                                                                                                                                                           +CRLF
    cEnvelope +='        </filters>'                                                                                                                                                                                                                                                +CRLF
    cEnvelope +='    </urn:customerCustomerList>'                                                                                                                                                                                                                                   +CRLF
    cEnvelope +='</soapenv:Body>'                                                                                                                                                                                                                                                   +CRLF
    cEnvelope +='</soapenv:Envelope>'                                                                                                                                                                                                                                               +CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
                                    
        //Transforma a resposta em um objeto
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM")<>"U"
                If ValType(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM)=="A"
                    For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM)
                        aTmpCli := {} 
                        If Alltrim(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_customer_id:Text) == Alltrim(cClienteId)
                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_customer_id:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_customer_id:Text)
                            Else
                                aAdd(aTmpCli,"")
                            EndIf

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_created_at:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_created_at:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf
                                
                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_updated_at:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_updated_at:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_store_id:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_store_id:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_website_id:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_website_id:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_created_in:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_created_in:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_email:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_email:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_firstname:Text"    
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_firstname:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_lastname:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_lastname:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_group_id:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_group_id:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            cCmd := "OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM["+Str(nX)+"]:_taxvat:Text"
                            If Type(cCmd) <> "U"
                                aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_taxvat:Text)
                            Else
                                aAdd(aTmpCli,"")    
                            EndIf    

                            aAdd(aCliente,aTmpCli)
                        EndIf    
                    Next nX
                Else
                    aTmpCli := {} 
                    If Alltrim(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_customer_id:Text) == Alltrim(cClienteId)                            
                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_customer_id:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_customer_id:Text)
                        Else
                            aAdd(aTmpCli,"")
                        EndIf

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_created_at:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_created_at:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf
                            
                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_updated_at:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_updated_at:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_store_id:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_store_id:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_website_id:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_website_id:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_created_in:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_created_in:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_email:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_email:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_firstname:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_firstname:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_lastname:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_lastname:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_group_id:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_group_id:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_taxvat:Text") <> "U"
                            aAdd(aTmpCli,OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERLISTRESPONSE:_STOREVIEW:_ITEM:_taxvat:Text)
                        Else
                            aAdd(aTmpCli,"")    
                        EndIf    

                        aAdd(aCliente,aTmpCli)
                    EndIf    
                EndIf
            EndIf
        EndIf
    Else
        cError   := Self:oWsdl:cError
        aCliente := {}
    EndIf
Else
    cError   := Self:oWsdl:cError
    aCliente := {}
EndIf

Return aCliente

/*/{protheus.doc} SobeClientes
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeClientes(cCliDe,cLojaDe,cCliAte,cLojaAte) Class MCMagento
If Self:lOpCli
    If Self:lJob
        Self:ProcClientes(cCliDe,cLojaDe,cCliAte,cLojaAte)
    Else
        Processa({|a| Self:ProcClientes(cCliDe,cLojaDe,cCliAte,cLojaAte) },"Aguarde","Subindo Clientes ao e-Commerce...")        
    EndIf
EndIf
Return Self

Method ProcClientes(cCliDe,cLojaDe,cCliAte,cLojaAte) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cQuery        := ""
Local cAlias        := GetNextAlias()
Local cNome         := ""
Local cSobrenome    := ""
Local cId           := 0
Local nX            := 1
Local cIdUF         := ""
Local nPosUf        := 0
Local cEstado       := ""
Local cError        := ""
Local cWarning      := ""
Local nTotRegs      := 0
Local nRecno        := 0

Private oXml        := NIL

Default cCliDe      := ""
Default cLojaDe     := ""
Default cCliAte     := ""
Default cLojaAte    := ""

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("customerCustomerCreate")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("customerCustomerCreate")
    cQuery := "SELECT SA1.R_E_C_N_O_ AS RECSA1"                                 +CRLF
    cQuery += " FROM "+RetSqlName("SA1")+" SA1 (NOLOCK)"                        +CRLF
    cQuery += "     WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"                 +CRLF
    If !Empty(cCliDe) .And. !Empty(cCliAte)
        cQuery += "   AND SA1.A1_COD  BETWEEN '"+cCliDe+"'  AND '"+cCliAte+"'"  +CRLF
        cQuery += "   AND SA1.A1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'" +CRLF
    ElseIf !Empty(cCliDe)
        cQuery += "   AND SA1.A1_COD  BETWEEN '"+cCliDe+"'  AND '"+cCliDe+"'"   +CRLF
        cQuery += "   AND SA1.A1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaDe+"'"  +CRLF
    ElseIf !Empty(cCliAte)
        cQuery += "   AND SA1.A1_COD  BETWEEN ' ' AND '"+cCliAte+"'"            +CRLF
        cQuery += "   AND SA1.A1_LOJA BETWEEN ' ' AND '"+cLojaAte+"'"           +CRLF    
    Else    
        If SA1->(FieldPos("A1_XIDENV"))>0
            cQuery += "     AND SA1.A1_XIDENV = ' '"                            +CRLF
        EndIf
    EndIf
    If SA1->(FieldPos("A1_XECOMM"))>0
        cQuery += "     AND SA1.A1_XECOMM = 'S'"                                 +CRLF
    EndIf
    cQuery += "     AND SA1.A1_CEP <> ' '"                                       +CRLF
    cQuery += "     AND SA1.A1_END <> ' '"                                       +CRLF
    cQuery += "     AND SA1.A1_MSBLQL <> 'S'"                                    +CRLF
    cQuery += "     AND SA1.D_E_L_E_T_ = ' '"                                    +CRLF

    If !Self:lJob
        ProcRegua(0)
        IncProc("Selecionando Registros...")
    EndIf

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
    dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
    (cAlias)->(dbGotop())

    //->> Atualização da ZWS
    nRecno := ZWSAtualiza(NIL,"S","C",If(Self:lJob,"J","T"),nTotRegs)

    If !Self:lJob
        ProcRegua(nTotRegs)    
    EndIf

    Do While (cAlias)->(!Eof())
        If !Self:lJob
            IncProc("Subindo Clientes...")
        EndIf
    
        SA1->(dbGoto((cAlias)->RECSA1))
        If SA1->(FieldPos("A1_XIDECOM"))>0
            cId := Alltrim(SA1->A1_XIDECOM)
        Else
            cId := Alltrim(SA1->(A1_COD+A1_LOJA))
        EndIf

        nPosUf := AScan(Self:aUf,{|x| Upper(Alltrim(x[01]))=="BR" .And. Upper(Alltrim(x[03]))==Upper(Alltrim(SA1->A1_EST)) })
        If nPosUf > 0
            cIdUF := Self:aUf[nPosUf,02]
        Else
            cIdUF := ""
        EndIf

        SX5->(dbSetOrder(1))
        If SX5->(dbSeek(xFilial("SX5")+PadR("12",Tamsx3("X5_TABELA")[01])+SA1->A1_EST))
            cEstado := Alltrim(SX5->X5_DESCRI)
        Else
            cEstado := ""
        EndIf    

        cNome := Alltrim(SA1->A1_NOME)
        cSobrenome := ""
        For nX:=Len(cNome) to 1 step -1
            If SubStr(cNome,nX,1)==" "
                cSobrenome  := Alltrim(Right(cNome,Len(cNome)-nX))
                cNome		:= Alltrim(Left(cNome,nX)) 
                Exit
            EndIf	        
        Next nX

        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
        cEnvelope += '<soapenv:Header/>'+CRLF
        cEnvelope += '<soapenv:Body>'+CRLF
        cEnvelope += '    <urn:customerCustomerCreate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '        <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
        cEnvelope += '        <customerData xsi:type="urn:customerCustomerEntityToCreate">'+CRLF
        cEnvelope += '           <!--You may enter the following 18 items in any order-->'+CRLF
        If !Empty(cId)
            cEnvelope += '            <!--Optional:-->'+CRLF
            cEnvelope += '            <customer_id xsi:type="xsd:int">'+cId+'</customer_id>'+CRLF
        EndIf
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <email xsi:type="xsd:string">'+SA1->A1_EMAIL+'</email>'+CRLF
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <firstname xsi:type="xsd:string">'+cNome+'</firstname>'+CRLF
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <lastname xsi:type="xsd:string">'+cSobrenome+'</lastname>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <middlename xsi:type="xsd:string"> </middlename>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <password xsi:type="xsd:string"> </password>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <website_id xsi:type="xsd:int">?</website_id>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
      cEnvelope += '            <store_id xsi:type="xsd:int">'+SA1->A1_LOJA+'</store_id>'+CRLF
      cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <group_id xsi:type="xsd:int">?</group_id>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <prefix xsi:type="xsd:string">?</prefix>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <suffix xsi:type="xsd:string">?</suffix>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <dob xsi:type="xsd:string">?</dob>'+CRLF
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <taxvat xsi:type="xsd:string">'+SA1->A1_CGC+'</taxvat>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
     // cEnvelope += '            <gender xsi:type="xsd:int">?</gender>'+CRLF
     // cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <ie xsi:type="xsd:string">'+SA1->A1_INSCR+'</ie>'+CRLF
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <rg_atribute xsi:type="xsd:string">'+SA1->A1_PFISICA+'</rg_atribute>'+CRLF
        cEnvelope += '            <!--Optional:-->'+CRLF
        cEnvelope += '            <erp_id xsi:type="xsd:string">'+SA1->(A1_COD+A1_LOJA)+'</erp_id>'+CRLF
    //  cEnvelope += '            <!--Optional:-->'+CRLF
    //  cEnvelope += '            <representante_id xsi:type="xsd:string">?</representante_id>'+CRLF
        cEnvelope += '         </customerData>'+CRLF
        cEnvelope += '     </urn:customerCustomerCreate>'+CRLF
        cEnvelope += ' </soapenv:Body>'+CRLF
        cEnvelope += '</soapenv:Envelope>'+CRLF

        If Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()            
            oXml := XmlParser(cResponse, "_", @cError, @cWarning)
            If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERCREATERESPONSE:_RESULT")<>"U"
                cId := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERCUSTOMERCREATERESPONSE:_RESULT:Text

                If SA1->(FieldPos("A1_XIDENV"))>0 .And. SA1->(FieldPos("A1_XIDECOM"))>0
                    Reclock("SA1",.F.)
                    SA1->A1_XIDENV  := Dtoc(Date())+" "+Time()
                    SA1->A1_XIDECOM := cId
                    SA1->(MsUnlock())
                EndIf
                ZWSAtualiza(nRecno)

                If Empty(SA1->A1_XIDENDE)
                    If Self:oWsdl:SetOperation("customerAddressCreate")
                        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                        cEnvelope += '<soapenv:Header/>'+CRLF
                        cEnvelope += '<soapenv:Body>'+CRLF
                        cEnvelope += '    <urn:customerAddressCreate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                        cEnvelope += '        <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
                        cEnvelope += '        <customerId xsi:type="xsd:int">'+cId+'</customerId>'+CRLF
                        cEnvelope += '        <addressData xsi:type="urn:customerAddressEntityCreate">'+CRLF
                        cEnvelope += '            <!--You may enter the following 16 items in any order-->'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <city xsi:type="xsd:string">'+SA1->A1_MUN+'</city>'+CRLF
                    // cEnvelope += '            <!--Optional:-->'+CRLF
                    // cEnvelope += '            <company xsi:type="xsd:string">?</company>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <country_id xsi:type="xsd:string">BR</country_id>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <fax xsi:type="xsd:string">'+SA1->A1_FAX+'</fax>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <firstname xsi:type="xsd:string">'+cNome+'</firstname>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <lastname xsi:type="xsd:string">'+cSobrenome+'</lastname>'+CRLF
                    // cEnvelope += '            <!--Optional:-->'+CRLF
                    // cEnvelope += '            <middlename xsi:type="xsd:string">?</middlename>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <postcode xsi:type="xsd:string">'+SA1->A1_CEP+'</postcode>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <prefix xsi:type="xsd:string">'+SA1->A1_EST+'</prefix>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <region_id xsi:type="xsd:int">'+cIdUF+'</region_id>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <region xsi:type="xsd:string">'+cEstado+'</region>'+CRLF            
                        cEnvelope += '            <!--Optional:-->'+CRLF                        
                        cEnvelope += '            <street xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">
			            cEnvelope += '                  <value>'+SA1->A1_END+'</value>
		                cEnvelope += '            </street>
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <suffix xsi:type="xsd:string">'+SA1->A1_DDD+'</suffix>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <telephone xsi:type="xsd:string">'+SA1->A1_TEL+'</telephone>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <is_default_billing xsi:type="xsd:boolean">True</is_default_billing>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <is_default_shipping xsi:type="xsd:boolean">True</is_default_shipping>'+CRLF
                        cEnvelope += '        </addressData>'+CRLF
                        cEnvelope += '    </urn:customerAddressCreate>'+CRLF
                        cEnvelope += '</soapenv:Body>'+CRLF
                        cEnvelope += '</soapenv:Envelope>'+CRLF
                        
                        If Self:oWsdl:SendSoapMsg(cEnvelope)
                            cResponse := Self:oWsdl:GetSoapResponse()
                            oXml := XmlParser(cResponse, "_", @cError, @cWarning)
                            If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSCREATERESPONSE:_RESULT")<>"U"
                                cId := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSCREATERESPONSE:_RESULT:Text
                                Reclock("SA1",.F.)
                                SA1->A1_XIDENDE := cId
                                SA1->(MsUnlock())
                            EndIf  
                            ZWSAtualiza(nRecno)  
                        Else
                            cError := Self:oWsdl:cError
                            ZWSAtualiza(nRecno,,,,,.T.)
                            Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
                        EndIf
                    Else
                        cError := Self:oWsdl:cError
                        ZWSAtualiza(nRecno,,,,,.T.)
                        Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
                    EndIf
                Else
                    If Self:oWsdl:SetOperation("customerAddressUpdate")
                        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                        cEnvelope += '   <soapenv:Header/>'+CRLF
                        cEnvelope += '   <soapenv:Body>'+CRLF
                        cEnvelope += '      <urn:customerAddressUpdate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                        cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
                        cEnvelope += '         <addressId xsi:type="xsd:int">'+Alltrim(SA1->A1_XIDENDE)+'</addressId>'+CRLF
                        cEnvelope += '         <addressData xsi:type="urn:customerAddressEntityCreate">'+CRLF
                        cEnvelope += '            <!--You may enter the following 16 items in any order-->'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <city xsi:type="xsd:string">'+SA1->A1_MUN+'</city>'+CRLF
                    // cEnvelope += '            <!--Optional:-->'+CRLF
                    // cEnvelope += '            <company xsi:type="xsd:string">?</company>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <country_id xsi:type="xsd:string">BR</country_id>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <fax xsi:type="xsd:string">'+SA1->A1_FAX+'</fax>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <firstname xsi:type="xsd:string">'+cNome+'</firstname>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <lastname xsi:type="xsd:string">'+cSobrenome+'</lastname>'+CRLF
                    // cEnvelope += '            <!--Optional:-->'+CRLF
                    // cEnvelope += '            <middlename xsi:type="xsd:string">?</middlename>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <postcode xsi:type="xsd:string">'+SA1->A1_CEP+'</postcode>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <prefix xsi:type="xsd:string">'+SA1->A1_EST+'</prefix>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <region_id xsi:type="xsd:int">'+cIdUF+'</region_id>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <region xsi:type="xsd:string">'+cEstado+'</region>'+CRLF            
                        cEnvelope += '            <!--Optional:-->'+CRLF                        
                        cEnvelope += '            <street xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">
			            cEnvelope += '                  <value>'+SA1->A1_END+'</value>
		                cEnvelope += '            </street>
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <suffix xsi:type="xsd:string">'+SA1->A1_DDD+'</suffix>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <telephone xsi:type="xsd:string">'+SA1->A1_TEL+'</telephone>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <is_default_billing xsi:type="xsd:boolean">True</is_default_billing>'+CRLF
                        cEnvelope += '            <!--Optional:-->'+CRLF
                        cEnvelope += '            <is_default_shipping xsi:type="xsd:boolean">True</is_default_shipping>'+CRLF
                        cEnvelope += '         </addressData>'+CRLF
                        cEnvelope += '      </urn:customerAddressUpdate>'+CRLF
                        cEnvelope += '   </soapenv:Body>'+CRLF
                        cEnvelope += '</soapenv:Envelope>'+CRLF

                        If Self:oWsdl:SendSoapMsg(cEnvelope)
                            cResponse := Self:oWsdl:GetSoapResponse()
                            ZWSAtualiza(nRecno)
                        Else
                            cError := Self:oWsdl:cError
                            ZWSAtualiza(nRecno,,,,,.T.)
                            Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
                        EndIf
                    Else
                        cError := Self:oWsdl:cError
                        ZWSAtualiza(nRecno,,,,,.T.)
                        Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
                    EndIf
                EndIf
            EndIf
        Else
            cError := Self:oWsdl:cError
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
Else
    cError := Self:oWsdl:cError
    ZWSAtualiza(nRecno,,,,,.T.)
    Self:GravaLogErro("S","C",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SA1->(A1_COD+A1_LOJA))
EndIf

Return Self

/*/{protheus.doc} GetEndClien
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function ZWSAtualiza(nRecno,cOper,cTipo,cConn,nQtdRegs,lErros,dMovimento)
Default nRecno      := 0
Default lErros      := .F.
Default dMovimento  := Stod("")

If nRecno == 0
    Reclock("ZWS",.T.)
    ZWS->ZWS_FILIAL := xFilial("ZWS")
    ZWS->ZWS_DATA   := Date()
    ZWS->ZWS_HORA   := Time()
    ZWS->ZWS_OPER   := cOper
    ZWS->ZWS_TIPO   := cTipo
    ZWS->ZWS_CONN   := cConn
    ZWS->ZWS_USER   := RetCodUsr()
    ZWS->ZWS_QTDREG := nQtdRegs 
    ZWS->ZWS_QTDGRV := 0
    ZWS->ZWS_INICIO := Dtos(Date())+" "+Time()
    ZWS->ZWS_FINAL  := Dtos(Date())+" "+Time()
    ZWS->ZWS_MOVIM  := dMovimento
    ZWS->(MsUnlock())
    nRecno := ZWS->(Recno())
Else
    ZWS->(dbGoto(nRecno))
    Reclock("ZWS",.F.)
    If !lErros
        ZWS->ZWS_QTDGRV++
    Else
        If ZWS->(FieldPos("ZWS_ERROS"))>0
            ZWS->ZWS_ERROS++
        EndIf
    EndIf
    ZWS->ZWS_FINAL  := Dtos(Date())+" "+Time()    
    ZWS->(MsUnlock())
EndIf

Return nRecno

/*/{protheus.doc} GetEndClien
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetEndClien(cClienteId) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local aEnderecos    := {}
Local nX            := 1
Local cError        := ""
Local cWarning      := ""

Private oXml        := NIL

If Self:oWsdl:SetOperation("customerAddressList")
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:customerAddressList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <customerId xsi:type="xsd:int">'+cClienteId+'</customerId>'+CRLF
    cEnvelope += '      </urn:customerAddressList>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()

        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U"
            If Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM")<>"U"
                If ValType(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM)=="A"
                    For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM)                        
                        aAdd(aEnderecos,{   OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_customer_address_id:Text,     ;   // 01 - Id do endereco
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_city:Text,                    ;   // 02 - Cidade
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_country_id:Text,              ;   // 03 - Pais
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_postcode:Text,                ;   // 04 - CEP
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_street:Text,                  ;   // 05 - Logradouro
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_suffix:Text,                  ;   // 06 - DDD
                                            OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM[nX]:_telephone:Text                })  // 07 - Telefone
                    Next nX
                Else
                    aAdd(aEnderecos,{   OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_customer_address_id:Text,     ;   // 01 - Id do endereco
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_city:Text,                    ;   // 02 - Cidade
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_country_id:Text,              ;   // 03 - Pais
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_postcode:Text,                ;   // 04 - CEP
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_street:Text,                  ;   // 05 - Logradouro
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_suffix:Text,                  ;   // 06 - DDD
                                        OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CUSTOMERADDRESSLISTRESPONSE:_RESULT:_ITEM:_telephone:Text                })  // 07 - Telefone
                EndIf
            EndIf
        EndIf
    Else
        cError := Self:oWsdl:cError
    EndIf
Else
    cError := Self:oWsdl:cError
EndIf

Return aEnderecos

/*/{protheus.doc} SobeProdutos
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 13/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeProdutos(cProdutDe,cProdutAte) Class MCMagento
If Self:lOpPrd
    If Self:lJob
        Self:ProcProdutos(cProdutDe,cProdutAte)
    Else
        Processa({|a| Self:ProcProdutos(cProdutDe,cProdutAte) },"Aguarde","Subindo Produtos ao e-Commerce...")        
    EndIf
EndIf
Return Self

Method ProcProdutos(cProdutDe,cProdutAte) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cQuery        := ""
Local cAlias        := GetNextAlias()
Local nTotRegs      := 0
Local nRecno        := 0
Local cType         := "simple"
Local cSet          := '9'
Local cSku          := ""
Local nPreco        := 0
Local nEstoque      := 0
Local cLoja         := Self:cLoja
Local cId           := ""
Local cIdGrupo      := ""
Local cError        := ""
Local cWarning      := ""
Local cDetalhes     := ""

Private oXml        := NIL

Default cProdutDe   := ""
Default cProdutAte  := ""

cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1"                                         +CRLF
cQuery += " FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"                                +CRLF
cQuery += "     WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"                         +CRLF
If !Empty(cProdutDe) .And. !Empty(cProdutAte)
    cQuery += "   AND SB1.B1_COD  BETWEEN '"+cProdutDe+"'  AND '"+cProdutAte+"'"    +CRLF
ElseIf !Empty(cProdutDe)
    cQuery += "   AND SB1.B1_COD  BETWEEN '"+cProdutDe+"'  AND '"+cProdutDe+"'"     +CRLF
ElseIf !Empty(cProdutAte)
    cQuery += "   AND SB1.B1_COD  BETWEEN ' ' AND '"+cProdutAte+"'"                 +CRLF
Else    
    If SB1->(FieldPos("B1_XIDENV"))>0
        cQuery += "     AND SB1.B1_XIDENV = ' '"                                    +CRLF
    EndIf
EndIf
If SB1->(FieldPos("B1_XECOMM"))>0
    cQuery += "     AND SB1.B1_XECOMM = 'S'"                                        +CRLF
EndIf
cQuery += "     AND SB1.B1_MSBLQL <> 'S'"                                           +CRLF
cQuery += "     AND SB1.B1_TIPO IN ('ME','PA')"                                     +CRLF
cQuery += "     AND SB1.D_E_L_E_T_ = ' '"                                           +CRLF

If !Self:lJob
    ProcRegua(0)
    IncProc("Selecionando Registros...")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
(cAlias)->(dbGotop())

//->> Atualização da ZWS
nRecno := ZWSAtualiza(NIL,"S","P",If(Self:lJob,"J","T"),nTotRegs)

If !Self:lJob
    ProcRegua(nTotRegs)    
EndIf

Do While (cAlias)->(!Eof())
    If !Self:lJob
        IncProc("Subindo Produtos...")
    EndIf

    SB1->(dbGoto((cAlias)->RECSB1))
    
    cSku        := Alltrim(SB1->B1_CODGTIN) //Alltrim(SB1->B1_COD)
    nPreco      := 0
    nEstoque    := 0        
    cDetalhes   := SB1->B1_XDETALH
    cDetalhes   := StrTran(cDetalhes,Chr(10) + Chr(13),"")
    cDetalhes   := Alltrim(cDetalhes)

    SBM->(dbSetOrder(1))
    SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
    cIdGrupo := SBM->BM_XIDECOM    
    If Empty(cIdGrupo)
        //->> Sobe a Categoria
        Self:SobeCategoria(SB1->B1_GRUPO,SB1->B1_GRUPO)
    EndIf

    DA0->(dbSetOrder(1))
    If !Empty(Self:cTabPreco) .And. DA0->(dbSeek(xFilial("DA0")+Self:cTabPreco))
        If Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE > Date()
            DA1->(dbSetOrder(1))
            If DA1->(dbSeek(xFilial("DA1") + DA0->DA0_CODTAB + SB1->B1_COD)) .And. Alltrim(DA1->DA1_ATIVO) == "1"
                nPreco := DA1->DA1_PRCVEN
            EndIf
        EndIf
    EndIf

    If !Empty(cSku) .And. nPreco > 0
        If Empty(SB1->B1_XIDECOM)    

            //->> Refaz a Conexão
            If !Self:oWsdl:SetOperation("catalogProductCreate")
                Self:Iniciar(Self:lJob)
            EndIf

            If Self:oWsdl:SetOperation("catalogProductCreate")
                cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                cEnvelope += '   <soapenv:Header/>'+CRLF
                cEnvelope += '   <soapenv:Body>'+CRLF
                cEnvelope += '      <urn:catalogProductCreate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
                cEnvelope += '         <type xsi:type="xsd:string">'+cType+'</type>'+CRLF
                cEnvelope += '         <set xsi:type="xsd:string">'+cSet+'</set>'+CRLF
                cEnvelope += '         <sku xsi:type="xsd:string">'+cSku+'</sku>'+CRLF
                cEnvelope += '         <productData xsi:type="urn:catalogProductCreateEntity">'+CRLF
                cEnvelope += '            <name xsi:type="xsd:string">'+Alltrim(SB1->B1_DESC)+'</name>'+CRLF
             // cEnvelope += '            <description xsi:type="xsd:string">'+Alltrim(cDetalhes)+'</description>'+CRLF
                cEnvelope += '            <short_description xsi:type="xsd:string">'+Alltrim(SB1->B1_XDSCCUR)+'</short_description>'+CRLF
                cEnvelope += '            <weight xsi:type="xsd:string">'+Alltrim(Str(SB1->B1_XPESO))+'</weight>'+CRLF
                cEnvelope += '            <status xsi:type="xsd:string">'+If(SB1->B1_MSBLQL<>"1","1","2")+'</status>'+CRLF
                cEnvelope += '            <category_ids xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">'+CRLF
                cEnvelope += '              <Value>'+cIdGrupo+'</Value>'+CRLF
                cEnvelope += '            </category_ids>'+CRLF
                cEnvelope += '            <price xsi:type="xsd:string">'+Alltrim(Str(nPreco))+'</price>'+CRLF
                cEnvelope += '         </productData>'+CRLF
                cEnvelope += '         <storeView xsi:type="xsd:string">'+cLoja+'</storeView>'+CRLF
                cEnvelope += '      </urn:catalogProductCreate>'+CRLF
                cEnvelope += '   </soapenv:Body>'+CRLF
                cEnvelope += '</soapenv:Envelope>'+CRLF

                If Self:oWsdl:SendSoapMsg(cEnvelope)
                    cResponse := Self:oWsdl:GetSoapResponse()
                    oXml := XmlParser(cResponse, "_", @cError, @cWarning)
                    If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTCREATERESPONSE:_RESULT")<>"U"
                        cId := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTCREATERESPONSE:_RESULT:Text
                        If SB1->(FieldPos("B1_XIDENV"))>0
                            Reclock("SB1",.F.)
                            SB1->B1_XIDENV  := Dtoc(Date())+" "+Time()
                            SB1->B1_XIDECOM := cId
                            SB1->(MsUnlock())
                        EndIf                
                        ZWSAtualiza(nRecno)
                    EndIf    
                Else
                    cError := Self:oWsdl:cError
                    ZWSAtualiza(nRecno,,,,,.T.)
                    Self:GravaLogErro("S","P",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
                EndIf
            Else
                cError := Self:oWsdl:cError
                ZWSAtualiza(nRecno,,,,,.T.)
                Self:GravaLogErro("S","P",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
            EndIf
        Else
            
            //->> Refaz a Conexão
            If !Self:oWsdl:SetOperation("catalogProductUpdate")
                Self:Iniciar(Self:lJob)
            EndIf
            
            If Self:oWsdl:SetOperation("catalogProductUpdate")
                cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                cEnvelope += '   <soapenv:Header/>'+CRLF
                cEnvelope += '   <soapenv:Body>'+CRLF
                cEnvelope += '      <urn:catalogProductUpdate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
                cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
                cEnvelope += '         <product xsi:type="xsd:string">'+Alltrim(SB1->B1_XIDECOM)+'</product>'+CRLF
                cEnvelope += '         <productData xsi:type="urn:catalogProductCreateEntity">'+CRLF
                cEnvelope += '            <name xsi:type="xsd:string">'+Alltrim(SB1->B1_DESC)+'</name>'+CRLF
             // cEnvelope += '            <description xsi:type="xsd:string">'+Alltrim(cDetalhes)+'</description>'+CRLF
                cEnvelope += '            <short_description xsi:type="xsd:string">'+Alltrim(SB1->B1_XDSCCUR)+'</short_description>'+CRLF
                cEnvelope += '            <weight xsi:type="xsd:string">'+Alltrim(Str(SB1->B1_XPESO))+'</weight>'+CRLF
                cEnvelope += '            <status xsi:type="xsd:string">'+If(SB1->B1_MSBLQL<>"1","1","2")+'</status>'+CRLF
                cEnvelope += '            <category_ids xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">'+CRLF
                cEnvelope += '              <Value>'+cIdGrupo+'</Value>'+CRLF
                cEnvelope += '            </category_ids>'+CRLF
                cEnvelope += '            <price xsi:type="xsd:string">'+Alltrim(Str(nPreco))+'</price>'+CRLF                                
                cEnvelope += '         </productData>'+CRLF
                cEnvelope += '         <storeView xsi:type="xsd:string">'+cLoja+'</storeView>'+CRLF
                cEnvelope += '         <identifierType xsi:type="xsd:string">?</identifierType>'+CRLF
                cEnvelope += '      </urn:catalogProductUpdate>'+CRLF
                cEnvelope += '   </soapenv:Body>'+CRLF
                cEnvelope += '</soapenv:Envelope>'+CRLF

                If Self:oWsdl:SendSoapMsg(cEnvelope)
                    cResponse := Self:oWsdl:GetSoapResponse()
                    Reclock("SB1",.F.)
                    SB1->B1_XIDENV  := Dtoc(Date())+" "+Time()                            
                    SB1->(MsUnlock())
                Else
                    cError := Self:oWsdl:cError
                    ZWSAtualiza(nRecno,,,,,.T.)
                    Self:GravaLogErro("S","P",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
                EndIf
            Else
                cError := Self:oWsdl:cError
                ZWSAtualiza(nRecno,,,,,.T.)
                Self:GravaLogErro("S","P",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
            EndIf
        EndIf
        (cAlias)->(dbSkip())
    EndIf
EndDo
(cAlias)->(dbCloseArea())

Return Self

/*/{protheus.doc} GetDadProdut
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 11/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GetDadProdut(cSKU) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local nX            := 1
Local cError        := ""
Local cWarning      := ""
Local aProdutos     := {}

Default cSKU        := ""

Private oXml        := NIL

If Self:oWsdl:SetOperation("catalogProductList")    
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:catalogProductList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <filters xsi:type="urn:filters">'+CRLF
    cEnvelope += '            <filter xsi:type="urn:associativeArray" soapenc:arrayType="urn:associativeEntity[]">'+CRLF
    
    If !Empty(cSKU)    
        cEnvelope += '			    <item>'+CRLF
        cEnvelope += '				    <key>sku</key>'+CRLF
        cEnvelope += '				    <value>'+Alltrim(cSKU)+'</value>'+CRLF    
        cEnvelope += '			    </item>'+CRLF
    EndIf
    
    cEnvelope += '		      </filter>'+CRLF            
    cEnvelope += '            <complex_filter xsi:type="urn:complexFilterArray" soapenc:arrayType="urn:complexFilter[]"/>'+CRLF
    cEnvelope += '         </filters>'+CRLF
    cEnvelope += '         <storeView xsi:type="xsd:string">'+Self:cLoja+'</storeView>'+CRLF
    cEnvelope += '      </urn:catalogProductList>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()

        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM")<>"U"
            If ValType(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM)=="A"
                For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM)
                    aAdd(aProdutos,{OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_PRODUCT_ID:TEXT,   ;
                                    OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_SKU:TEXT,          ;
                                    OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_NAME:TEXT}         )
                Next nX
            Else
                aAdd(aProdutos,{OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM:_PRODUCT_ID:TEXT,   ;
                                OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM:_SKU:TEXT,          ;
                                OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM:_NAME:TEXT}         )
            EndIf    
        EndIf
    Else
        cError := Self:oWsdl:cError
    EndIf    
Else
    cError := Self:oWsdl:cError
EndIf

Return aProdutos

/*/{protheus.doc} SobeEstoque
*******************************************************************************************
Sobe os produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeEstoque(cProdutDe,cProdutAte) Class MCMagento
If Self:lOpEst
    If Self:lJob
        Self:ProcEstoque(cProdutDe,cProdutAte)
    Else
        Processa({|a| Self:ProcEstoque(cProdutDe,cProdutAte) },"Aguarde","Subindo Estoques ao e-Commerce...")        
    EndIf
EndIf
Return Self

Method ProcEstoque(cProdutDe,cProdutAte) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local cQuery        := ""
Local cAlias        := GetNextAlias()
Local nRecno        := 0
Local nTotRegs      := 0

Private oXml        := NIL

cQuery := "SELECT SB2.R_E_C_N_O_ AS RECSB2,"                                        +CRLF
cQuery += "       SB1.R_E_C_N_O_ AS RECSB1"                                         +CRLF
cQuery += " FROM "+RetSqlName("SB2")+" SB2 (NOLOCK)"                                +CRLF
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"                          +CRLF
cQuery += "      ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"                           +CRLF
cQuery += "     AND SB1.B1_COD    = SB2.B2_COD"                                     +CRLF
cQuery += "     AND SB1.B1_XECOMM = 'S'"                                            +CRLF    
cQuery += "     AND SB1.B1_XIDECOM <> ' '"                                          +CRLF    
cQuery += "     AND SB1.B1_TIPO IN ('ME','PA')"                                     +CRLF
cQuery += "     AND SB1.B1_MSBLQL <> 'S'"                                           +CRLF
cQuery += "     AND SB1.D_E_L_E_T_ = ' '"                                           +CRLF
cQuery += "     WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"'"                         +CRLF
If !Empty(cProdutDe) .And. !Empty(cProdutAte)
    cQuery += "   AND SB2.B2_COD  BETWEEN '"+cProdutDe+"'  AND '"+cProdutAte+"'"    +CRLF
ElseIf !Empty(cProdutDe)
    cQuery += "   AND SB2.B2_COD  BETWEEN '"+cProdutDe+"'  AND '"+cProdutDe+"'"     +CRLF
ElseIf !Empty(cProdutAte)
    cQuery += "   AND SB2.B2_COD  BETWEEN ' ' AND '"+cProdutAte+"'"                 +CRLF
Else    
    If SB1->(FieldPos("B2_XIDENV"))>0
        cQuery += "     AND SB2.B2_XIDENV = ' '"                                    +CRLF
    EndIf
EndIf    
cQuery += "     AND SB2.B2_LOCAL = SB1.B1_LOCPAD"                                   +CRLF    
cQuery += "     AND SB2.D_E_L_E_T_ = ' '"                                           +CRLF

If !Self:lJob
    ProcRegua(0)
    IncProc("Selecionando Registros...")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
(cAlias)->(dbGotop())

//->> Atualização da ZWS
nRecno := ZWSAtualiza(NIL,"S","E",If(Self:lJob,"J","T"),nTotRegs)

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("catalogInventoryStockItemUpdate")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("catalogInventoryStockItemUpdate")    
    If !Self:lJob
        ProcRegua(nTotRegs)    
    EndIf

    Do While (cAlias)->(!Eof())
        If !Self:lJob
            IncProc("Subindo Estoques...")
        EndIf

        SB1->(dbGoto((cAlias)->RECSB1))
        SB2->(dbGoto((cAlias)->RECSB2))

        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
        cEnvelope += '<soapenv:Header/>'+CRLF
        cEnvelope += '<soapenv:Body>'+CRLF
        cEnvelope += '    <urn:catalogInventoryStockItemUpdate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '        <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
        cEnvelope += '        <product xsi:type="xsd:string">'+Alltrim(SB1->B1_XIDECOM)+'</product>'+CRLF
        cEnvelope += '        <data xsi:type="urn:catalogInventoryStockItemUpdateEntity">'+CRLF
        cEnvelope += '            <qty xsi:type="xsd:string">'+Alltrim(Str(SB2->(B2_QATU-B2_QEMP-B2_RESERVA)))+'</qty>'+CRLF
        cEnvelope += '        </data>'+CRLF
        cEnvelope += '    </urn:catalogInventoryStockItemUpdate>'+CRLF
        cEnvelope += '</soapenv:Body>'+CRLF
        cEnvelope += '</soapenv:Envelope>'+CRLF

        If Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()
            oXml := XmlParser(cResponse, "_", @cError, @cWarning)
            If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGINVENTORYSTOCKITEMUPDATERESPONSE:_RESULT")<>"U"
                If OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGINVENTORYSTOCKITEMUPDATERESPONSE:_RESULT:Text == "1"
                    Reclock("SB2",.F.)
                    SB2->B2_XIDENV  := Dtoc(Date())+" "+Time()                    
                    SB2->(MsUnlock())                
                EndIf
            Endif
            ZWSAtualiza(nRecno)
        Else
            Self:cError := Self:oWsdl:cError
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","E",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB2->(B2_COD+B2_LOCAL) )
        EndIf
        (cAlias)->(dbSkip())
    EndDo    
Else
    Self:cError := Self:oWsdl:cError
    ZWSAtualiza(nRecno,,,,,.T.)
    Self:GravaLogErro("S","E",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB2->(B2_COD+B2_LOCAL))
EndIf
(cAlias)->(dbCloseArea())

Return Self

/*/{protheus.doc} SobePrecos
*******************************************************************************************
Sobe os preços dos produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 15/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobePrecos(cProdutDe,cProdutAte) Class MCMagento
If lOpPrc
    If Self:lJob
        Self:ProcPrecos(cProdutDe,cProdutAte)
    Else
        Processa({|a| Self:ProcPrecos(cProdutDe,cProdutAte) },"Aguarde","Subindo Preços ao e-Commerce...")        
    EndIf
EndIf
Return Self

Method ProcPrecos(cProdutDe,cProdutAte) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local cQuery        := ""
Local cAlias        := GetNextAlias()
Local nRecno        := 0
Local nTotRegs      := 0
Local cLoja         := Self:cLoja

Private oXml        := NIL

cQuery := "SELECT DA1.R_E_C_N_O_ AS RECDA1,"                                                +CRLF
cQuery += "       SB1.R_E_C_N_O_ AS RECSB1"                                                 +CRLF
cQuery += " FROM "+RetSqlName("DA1")+" DA1 (NOLOCK)"                                        +CRLF
cQuery += " INNER JOIN "+RetSqlName("DA0")+" DA0 (NOLOCK)"                                  +CRLF
cQuery += "      ON DA0.DA0_FILIAL = '"+xFilial("DA0")+"'"                                  +CRLF
cQuery += "     AND DA0.DA0_CODTAB = '"+Self:cTabPreco+"'"                                  +CRLF
cQuery += "     AND (DA0.DA0_DATATE = ' ' OR DA0.DA0_DATATE >= '"+Dtos(Date())+"')"         +CRLF
cQuery += "     AND DA0.D_E_L_E_T_ = ' '"                                                   +CRLF
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"                                  +CRLF
cQuery += "      ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"                                   +CRLF
cQuery += "     AND SB1.B1_COD    = DA1.DA1_CODPRO"                                         +CRLF
cQuery += "     AND SB1.B1_XECOMM = 'S'"                                                    +CRLF    
cQuery += "     AND SB1.B1_XIDECOM <> ' '"                                                  +CRLF    
cQuery += "     AND SB1.B1_TIPO IN ('ME','PA')"                                             +CRLF
cQuery += "     AND SB1.B1_MSBLQL <> 'S'"                                                   +CRLF
cQuery += "     AND SB1.D_E_L_E_T_ = ' '"                                                   +CRLF
cQuery += "     WHERE DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"                                +CRLF
If !Empty(cProdutDe) .And. !Empty(cProdutAte)
    cQuery += "   AND DA1.DA1_CODPRO  BETWEEN '"+cProdutDe+"'  AND '"+cProdutAte+"'"        +CRLF
ElseIf !Empty(cProdutDe)
    cQuery += "   AND DA1.DA1_CODPRO  BETWEEN '"+cProdutDe+"'  AND '"+cProdutDe+"'"         +CRLF
ElseIf !Empty(cProdutAte)
    cQuery += "   AND DA1.DA1_CODPRO  BETWEEN ' ' AND '"+cProdutAte+"'"                     +CRLF
Else    
    If SB1->(FieldPos("DA1_XIDENV"))>0
        cQuery += "     AND DA1.DA1_XIDENV = ' '"                                           +CRLF
    EndIf
EndIf    
cQuery += "     AND DA1.DA1_CODTAB = DA0.DA0_CODTAB"                                        +CRLF
cQuery += "     AND DA1.DA1_ATIVO  = '1'"                                                   +CRLF
cQuery += "     AND DA1.D_E_L_E_T_ = ' '"                                                   +CRLF

If !Self:lJob
    ProcRegua(0)
    IncProc("Selecionando Registros...")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
(cAlias)->(dbGotop())

//->> Atualização da ZWS
nRecno := ZWSAtualiza(NIL,"S","R",If(Self:lJob,"J","T"),nTotRegs)

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("catalogInventoryStockItemUpdate")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("catalogInventoryStockItemUpdate")    
    If !Self:lJob
        ProcRegua(nTotRegs)    
    EndIf

    Do While (cAlias)->(!Eof())
        If !Self:lJob
            IncProc("Subindo Preços...")
        EndIf

        SB1->(dbGoto((cAlias)->RECSB1))
        DA1->(dbGoto((cAlias)->RECDA1))

        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '   <soapenv:Header/>'+CRLF
        cEnvelope += '   <soapenv:Body>'+CRLF
        cEnvelope += '      <urn:catalogProductUpdate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
        cEnvelope += '         <product xsi:type="xsd:string">'+Alltrim(SB1->B1_XIDECOM)+'</product>'+CRLF
        cEnvelope += '         <productData xsi:type="urn:catalogProductCreateEntity">'+CRLF
        cEnvelope += '            <price xsi:type="xsd:string">'+Alltrim(Str(DA1->DA1_PRCVEN))+'</price>'+CRLF
        cEnvelope += '         </productData>'+CRLF
        cEnvelope += '         <storeView xsi:type="xsd:string">'+cLoja+'</storeView>'+CRLF
        cEnvelope += '         <identifierType xsi:type="xsd:string">?</identifierType>'+CRLF
        cEnvelope += '      </urn:catalogProductUpdate>'+CRLF
        cEnvelope += '   </soapenv:Body>'+CRLF
        cEnvelope += '</soapenv:Envelope>'+CRLF

        If Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()

            oXml := XmlParser(cResponse, "_", @cError, @cWarning)
            If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTUPDATERESPONSE:_RESULT")<>"U"
                If Upper(Alltrim(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTUPDATERESPONSE:_RESULT:Text)) == "TRUE"
                    Reclock("DA1",.F.)
                    DA1->DA1_XIDENV  := Dtoc(Date())+" "+Time()                    
                    DA1->(MsUnlock())                
                EndIf
            Endif
            ZWSAtualiza(nRecno)
        Else
            Self:cError := Self:oWsdl:cError
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","R",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
        EndIf
        (cAlias)->(dbSkip())
    EndDo    
Else
    Self:cError := Self:oWsdl:cError
    ZWSAtualiza(nRecno,,,,,.T.)
    Self:GravaLogErro("S","R",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SB1->B1_COD)
EndIf
(cAlias)->(dbCloseArea())

Return Self

/*/{protheus.doc} SobeCategoria
*******************************************************************************************
Sobe as categorias dos produtos para o e-commerce
 
@author: Marcelo Celi Marques
@since: 17/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeCategoria(cCategDe,cCategAte) Class MCMagento
If Self:lOpCat
    If Self:lJob
        Self:ProcCategoria(cCategDe,cCategAte)
    Else
        Processa({|a| Self:ProcCategoria(cCategDe,cCategAte) },"Aguarde","Subindo Categorias ao e-Commerce...")
    EndIf
EndIf    
Return Self

Method ProcCategoria(cCategDe,cCategAte) Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local cQuery        := ""
Local cAlias        := GetNextAlias()
Local nRecno        := 0
Local nTotRegs      := 0
Local cLoja         := Self:cLoja
Local cId           := ""

Private oXml        := NIL

cQuery := "SELECT SBM.R_E_C_N_O_ AS RECSBM"                                                 +CRLF
cQuery += " FROM "+RetSqlName("SBM")+" SBM (NOLOCK)"                                        +CRLF
cQuery += "     WHERE SBM.BM_FILIAL = '"+xFilial("SBM")+"'"                                 +CRLF
If !Empty(cCategDe) .And. !Empty(cProdutAte)
    cQuery += "   AND SBM.BM_GRUPO  BETWEEN '"+cCategDe+"'  AND '"+cCategAte+"'"            +CRLF
ElseIf !Empty(cCategDe)
    cQuery += "   AND SBM.BM_GRUPO  BETWEEN '"+cCategDe+"'  AND '"+cCategDe+"'"             +CRLF
ElseIf !Empty(cCategAte)
    cQuery += "   AND SBM.BM_GRUPO  BETWEEN ' ' AND '"+cCategAte+"'"                        +CRLF
Else    
    cQuery += "     AND SBM.BM_XIDENV = ' '"                                                +CRLF    
EndIf    
cQuery += "     AND SBM.BM_XECOMM = 'S'"                                                    +CRLF
cQuery += "     AND SBM.D_E_L_E_T_ = ' '"                                                   +CRLF

If !Self:lJob
    ProcRegua(0)
    IncProc("Selecionando Registros...")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
(cAlias)->(dbGotop())

//->> Atualização da ZWS
nRecno := ZWSAtualiza(NIL,"S","T",If(Self:lJob,"J","T"),nTotRegs)

If !Self:lJob
    ProcRegua(nTotRegs)    
EndIf

Do While (cAlias)->(!Eof())
    If !Self:lJob
        IncProc("Subindo Categorias...")
    EndIf

    SBM->(dbGoto((cAlias)->RECSBM))
    If Empty(SBM->BM_XIDECOM)
        //->> Refaz a Conexão
        If !Self:oWsdl:SetOperation("catalogCategoryCreate")
            Self:Iniciar(Self:lJob)
        EndIf
        
        If Self:oWsdl:SetOperation("catalogCategoryCreate")
            cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
            cEnvelope += '   <soapenv:Header/>'+CRLF
            cEnvelope += '   <soapenv:Body>'+CRLF
            cEnvelope += '      <urn:catalogCategoryCreate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
            cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
            cEnvelope += '         <parentId xsi:type="xsd:int">1</parentId>'+CRLF
            cEnvelope += '         <categoryData xsi:type="urn:catalogCategoryEntityCreate">'+CRLF
            cEnvelope += '            <name xsi:type="xsd:string">'+SBM->BM_DESC+'</name>'+CRLF
            cEnvelope += '            <is_active xsi:type="xsd:int">1</is_active>'+CRLF            
            cEnvelope += '            <available_sort_by xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">'+CRLF
            cEnvelope += '			        <value>1</value>'+CRLF
            cEnvelope += '            </available_sort_by>'+CRLF            
            cEnvelope += '            <default_sort_by xsi:type="xsd:string">1</default_sort_by>'+CRLF
            cEnvelope += '            <include_in_menu xsi:type="xsd:int">1</include_in_menu>'+CRLF
            cEnvelope += '         </categoryData>'+CRLF
            cEnvelope += '         <storeView xsi:type="xsd:string">'+cLoja+'</storeView>'+CRLF
            cEnvelope += '      </urn:catalogCategoryCreate>'+CRLF
            cEnvelope += '   </soapenv:Body>'+CRLF
            cEnvelope += '</soapenv:Envelope>'+CRLF

            If Self:oWsdl:SendSoapMsg(cEnvelope)
                cResponse := Self:oWsdl:GetSoapResponse()
                oXml := XmlParser(cResponse, "_", @cError, @cWarning)
                If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGCATEGORYCREATERESPONSE:_ATTRIBUTE_ID")<>"U"
                    cId := Alltrim(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGCATEGORYCREATERESPONSE:_ATTRIBUTE_ID:Text)
                    Reclock("SBM",.F.)
                    SBM->BM_XIDENV  := Dtoc(Date())+" "+Time()                    
                    SBM->BM_XIDECOM := cId
                    SBM->(MsUnlock())                    
                Endif
                ZWSAtualiza(nRecno)
            Else
                Self:cError := Self:oWsdl:cError
                ZWSAtualiza(nRecno,,,,,.T.)
                Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SBM->BM_GRUPO)
            EndIf
        Else
            Self:cError := Self:oWsdl:cError
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SBM->BM_GRUPO)
        EndIf
    Else
        //->> Refaz a Conexão
        If !Self:oWsdl:SetOperation("catalogCategoryUpdate")
            Self:Iniciar(Self:lJob)
        EndIf

        If Self:oWsdl:SetOperation("catalogCategoryUpdate")
            cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
            cEnvelope += '   <soapenv:Header/>'+CRLF
            cEnvelope += '   <soapenv:Body>'+CRLF
            cEnvelope += '      <urn:catalogCategoryUpdate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
            cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
            cEnvelope += '         <categoryId xsi:type="xsd:int">'+Alltrim(SBM->BM_XIDECOM)+'</categoryId>'+CRLF
            cEnvelope += '         <categoryData xsi:type="urn:catalogCategoryEntityCreate">'+CRLF
            cEnvelope += '            <name xsi:type="xsd:string">'+SBM->BM_DESC+'</name>'+CRLF
            cEnvelope += '            <is_active xsi:type="xsd:int">1</is_active>'+CRLF
            cEnvelope += '            <available_sort_by xsi:type="urn:ArrayOfString" soapenc:arrayType="xsd:string[]">'+CRLF
            cEnvelope += '			        <value>1</value>'+CRLF
            cEnvelope += '            </available_sort_by>'+CRLF
            cEnvelope += '            <default_sort_by xsi:type="xsd:string">1</default_sort_by>'+CRLF
            cEnvelope += '            <include_in_menu xsi:type="xsd:int">1</include_in_menu>'+CRLF
            cEnvelope += '         </categoryData>'+CRLF
            cEnvelope += '         <storeView xsi:type="xsd:string">'+cLoja+'</storeView>'+CRLF
            cEnvelope += '      </urn:catalogCategoryUpdate>'+CRLF
            cEnvelope += '   </soapenv:Body>'+CRLF
            cEnvelope += '</soapenv:Envelope>'+CRLF

            If Self:oWsdl:SendSoapMsg(cEnvelope)
                cResponse := Self:oWsdl:GetSoapResponse()
                Reclock("SBM",.F.)
                SBM->BM_XIDENV  := Dtoc(Date())+" "+Time()                    
                SBM->(MsUnlock())
                ZWSAtualiza(nRecno)                    
            Else
                Self:cError := Self:oWsdl:cError
                ZWSAtualiza(nRecno,,,,,.T.)
                Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SBM->BM_GRUPO)
            EndIf
        Else
            Self:cError := Self:oWsdl:cError
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,SBM->BM_GRUPO)
        EndIf
    EndIf
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbSkip())

Return Self

/*/{protheus.doc} GravaLogErro
*******************************************************************************************
Grava o Log de Erro da Operação
 
@author: Marcelo Celi Marques
@since: 21/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method GravaLogErro(cOper,cTipo,cConn,cWsOper,cWsRequest,cWsResponse,cChave,cErroProth) Class MCMagento

Default cErroProth := ""

Reclock("ZWT",.T.)    
ZWT->ZWT_FILIAL := xFilial("ZWS")
ZWT->ZWT_DATA   := Date()
ZWT->ZWT_HORA   := Time()
ZWT->ZWT_OPER   := cOper
ZWT->ZWT_TIPO   := cTipo
ZWT->ZWT_CHAVE  := cChave
ZWT->ZWT_CONN   := cConn
ZWT->ZWT_USER   := RetCodUsr()
ZWT->ZWT_WSOPER := cWsOper
ZWT->ZWT_WSREQU := cWsRequest
ZWT->ZWT_WSRESP := cWsResponse
ZWT->ZWT_ERRPRO := cErroProth
ZWT->(MsUnlock())

Return Self

/*/{protheus.doc} DesceVendas
*******************************************************************************************
Desce as vendas do e-commerce
 
@author: Marcelo Celi Marques
@since: 25/08/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method DesceVendas(nTipo,dInicio,dFim) Class MCMagento
If Self:lJob
    Self:ProcVendas(nTipo,dInicio,dFim)
Else
    Processa({|a| Self:ProcVendas(nTipo,dInicio,dFim) },"Aguarde","Descendo as Vendas do e-Commerce...")
EndIf
Return Self

Method ProcVendas(nTipo,dInicio,dFim) Class MCMagento
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local aPedidos  := {}
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local nVlrTot   := 0
Local nFrete    := 0
Local nDescont    := 0
Local dEntrega  := Stod("")
Local dEmissao  := Stod("")
Local cCondPag  := Self:cCond
Local cIdClien  := ""
Local cIdEnder  := ""
Local cCliFat   := ""
Local cLojFat   := ""
Local cCliEnt   := ""
Local cLojEnt   := ""
Local lProdOk   := .F.
Local lCliFOk   := .F.
Local lCliEOk   := .F.
Local cTes      := ""
Local nPos      := ""
Local cUF       := ""
Local _dDatabase:= dDatabase
Local aArea     := GetArea()
Local lCredito  := .F.
Local lEstoque  := .F.
Local aPvlNfs   := {}
Local cNota     := ""
Local cSerie    := Self:cSerie
Local lErro     := .F.
Local cTipoCli  := ""
Local aLog      := {}
Local cErro     := ""
Local cEnder    := ""
Local nRecno    := 0
Local cCgc      := ""
Local cCodCli   := ""
Local cLojCli   := ""
Local cNatureza := ""
Local cPessoa   := ""
Local cNumero   := ""

Local dProc      := Stod("")
Local aEnder     := {}
Local cBairro    := ""
Local cMunicipio := ""
Local cCodMunic  := ""
Local cFormPgto  := ""
Local cObs       := ""
Local cNumVdaEc  := ""
Local nVlr2Unid  := 0

Private lMSErroAuto := .F.

//->> Utilizados internamente na função de extração de TES inteligente
Private aCols   := {}
Private aHeader := {}

Default dFim    := Date()

nRecno   := ZWSAtualiza(NIL,"D","V",If(Self:lJob,"J","T"),0,NIL,NIL)
//->> Marcelo Celi - 28/12/2020
For dProc:=dInicio to dFim
    //->> Marcelo Celi - 28/12/2020
    //aPedidos := Self:DescePedidos(nTipo,dInicio)    
    MsgRun("Buscando as Vendas de "+Dtoc(dProc)+" no Magento...","Aguarde",{|| aPedidos := Self:DescePedidos(nTipo,dProc) })

    If !Self:lJob
        ProcRegua(Len(aPedidos))
    EndIf
    For nX:=1 to Len(aPedidos)

        //->> Marcelo Celi - 28/12/2020
        aCabec	  := {}
        aItens	  := {}
        cFormPgto := Alltrim(Upper(aPedidos[nX][6,1,4]))
        cNumVdaEc := Alltrim(Upper(aPedidos[nX][6,1,5]))
        cObs      := ""

        //->> Daniel Bastos - 05/2021
        nFrete    := alltrim(aPedidos[nX][7])
    //  nFrete    := strTran(nFrete,".","")
    //  nFrete    := strTran(nFrete,",",".")
        nFrete    := val(aPedidos[nX][7])

        //->> Daniel Bastos - 05/2021
        nDescont    := alltrim(aPedidos[nX][8])
     // nDescont    := strTran(nDescont,".","")
     // nDescont    := strTran(nDescont,",",".")
        nDescont    := val(nDescont)
        nDescont    := ABS(nDescont)

        Begin Transaction
            If !Self:lJob
                IncProc("Descendo Vendas em "+Dtoc(dProc)+"...")
            EndIf
            SC5->( dbOrderNickName("C5XIDECOM") )
            If !SC5->(dbSeek(xFilial("SC5")+PadR(aPedidos[nX,01],Tamsx3("C5_XIDECOM")[01])))                
                //->> Marcelo Celi - 04/01/2020
                If AliasInDic("ZWU")
                    ZWU->(dbSetOrder(1))
                    ZWU->(dbSeek(xFilial("ZWU")+PadR(aPedidos[nX,01],Tamsx3("ZWU_IDECOM")[01])))
                    Do While ZWU->(!Eof()) .And. ZWU->(ZWU_FILIAL+ZWU_IDECOM) == xFilial("ZWU")+PadR(aPedidos[nX,01],Tamsx3("ZWU_IDECOM")[01])
                        Reclock("ZWU",.F.)
                        Delete
                        ZWU->(MsUnlock())
                        ZWU->(dbSkip())
                    EndDo                    
                EndIf
                                
                dEmissao := Stod(StrTran(Left(aPedidos[nX,03],10),"-","")) 
                dEntrega := Stod(StrTran(Left(aPedidos[nX,04],10),"-","")) 
                nRecno   := ZWSAtualiza(NIL,"D","V",If(Self:lJob,"J","T"),1,NIL,dEntrega)
                cCgc     := Alltrim(aPedidos[nX,06][02,01,11])
                cCgc     := StrTran(cCgc,".","")
                cCgc     := StrTran(cCgc,"-","")
                cCgc     := StrTran(cCgc,"/","")
                cCgc     := StrTran(cCgc,";","")
                cCgc     := StrTran(cCgc," ","")
                cCgc     := PadR(cCgc,Tamsx3("A1_CGC")[01])
                cPessoa  := If(Len(Alltrim(cCgc))<=11,"F","J")
                cNatureza:= Self:cNatureza

                lCliFOk  := .F.
                lCliEOk  := .F.
                cCliFat  := ""
                cLojFat  := ""
                cCliEnt  := ""
                cLojEnt  := ""
                cIdClien := PadR(aPedidos[nX,05],Tamsx3("A1_XIDECOM")[01])

                // Cliente de Faturamento
                cIdEnder := PadR(aPedidos[nX,06][01,01,01][01],Tamsx3("A1_XIDENDE")[01])
                SA1->( dbOrderNickName("A1XIDENDE") ) // por id do cliente + endereço
                If !SA1->(dbSeek(xFilial("SA1")+cIdClien + cIdEnder ))
                    nPos := Ascan(Self:aUf,{|x| Alltrim(x[2])==Alltrim(aPedidos[nX,06][01,01,06][01]) })
                    If nPos > 0
                        cUF := Self:aUf[nPos,03]
                    else
                        // MGOMES e FLAVIO // 29/09/2021 - INICIO
                        If !EMPTY( aPedidos[nX,06][01,01,08][01] )
                            cUF := aPedidos[nX,06][01,01,08][01]
                        ELSE
                            cUF := ""
                        EndIf
                        // MGOMES e FLAVIO // 29/09/2021 - FIM
                        //cUF := ""
                    EndIf
                    
                    //->> Marcelo Celi - 31/12/2020
                    aEnder := FormatEnder(Alltrim(aPedidos[nX,06][01,01,05][01]),cUF,Alltrim(aPedidos[nX,06][01,01,07][01]))
                    
                    If EMPTY(aEnder[03]) .and. !EMPTY( aEnder[04] )

                    EndIf


                    //->> Marcelo Celi - 31/12/2020
                    //cEnder  := Alltrim(aPedidos[nX,06][01,01,05][01])
                    //cEnder  := StrTran(cEnder,Chr(10) + Chr(13),"")
                    //cEnder  := StrTran(cEnder,Chr(13) + Chr(10),"")
                    //cEnder  := StrTran(cEnder,CRLF,"")
                
                    lCGCEnc     := .F.

                    cEnder      := aEnder[01]
                    cBairro     := aEnder[02]
                    cUF         := aEnder[03]
                    cMunicipio  := aEnder[04]
                    cCodMunic   := aEnder[05]
// AQUI
                    If !Empty(cCgc)
                        SA1->(dbSetOrder(3))
                        If SA1->(dbSeek(xFilial("SA1")+cCgc))
                            lCGCEnc := .T.
                            cCodCli := SA1->A1_COD
                            cLojCli := SA1->A1_LOJA
                            SA1->(dbSetOrder(1))
                            Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                                cLojCli := Soma1(cLojCli)
                                If !Empty(SA1->A1_NATUREZ)
                                    cNatureza := SA1->A1_NATUREZ
                                EndIf
                            EndDo
                        Else
                            cCodCli := GetSxeNum("SA1","A1_COD")
                            cLojCli := "01"
                            ConfirmSX8()
                            SA1->(dbSetOrder(1))
                            Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                                cLojCli := Soma1(cLojCli)                                    
                            EndDo
                        EndIf
                    Else
                        cCodCli := GetSxeNum("SA1","A1_COD")
                        cLojCli := "01"
                        ConfirmSX8()
                        SA1->(dbSetOrder(1))
                        Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                            cLojCli := Soma1(cLojCli)                                    
                        EndDo
                    EndIf
                    
                    if !lCGCEnc
                        Reclock("SA1",.T.)
                        SA1->A1_FILIAL  := xFilial("SA1")
                        SA1->A1_COD     := cCodCli
                        SA1->A1_LOJA    := cLojCli
                        SA1->A1_XIDECOM := cIdClien
                        SA1->A1_XIDENDE := cIdEnder
                        SA1->A1_NOME    := Upper(Alltrim(aPedidos[nX,06][01,01,03][01]) + " " + Alltrim(aPedidos[nX,06][01,01,04][01]))
                        SA1->A1_END     := Upper(Alltrim(cEnder))

                        //->> Marcelo Celi - 31/12/2020
                        SA1->A1_BAIRRO  := Upper(Alltrim(cBairro))
                        SA1->A1_MUN     := cMunicipio
                        SA1->A1_PAIS    := "105"
                        SA1->A1_CODPAIS := "01058"
                        SA1->A1_COD_MUN := cCodMunic

                        SA1->A1_EST     := cUF                    
                        SA1->A1_NATUREZ := cNatureza
                        SA1->A1_CEP     := StrTran(Alltrim(aPedidos[nX,06][01,01,10][01]),"-","")
                        SA1->A1_TEL     := StrTran(Alltrim(aPedidos[nX,06][01,01,12][01]),"-","")
                        SA1->A1_TIPO    := "F" // CONSUMIDOR FINAL
                        SA1->A1_PESSOA  := cPessoa
                        SA1->A1_CGC     := cCgc
                        SA1->A1_XORIGEM := "E"

                        //->> Marcelo Celi - 05/01/2020
                        SA1->A1_INSCR   := "ISENTO"
                        SA1->A1_CONTRIB := "2"
                        SA1->A1_TIPO    := "F"

                        SA1->(MsUnlock())
                    EndIf

                    lCliFOk := .T.
                    cCliFat := SA1->A1_COD
                    cLojFat := SA1->A1_LOJA
                    cTipoCli:= SA1->A1_TIPO                   
                Else
                    lCliFOk := .T.
                    cCliFat := SA1->A1_COD
                    cLojFat := SA1->A1_LOJA
                    cTipoCli:= SA1->A1_TIPO
                EndIf
                
                // Cliente de Entrega
                cIdEnder := PadR(aPedidos[nX,06][01,02,01][01],Tamsx3("A1_XIDENDE")[01])
                SA1->( dbOrderNickName("A1XIDENDE") ) // por id do cliente + endereço
                If !SA1->(dbSeek(xFilial("SA1")+cIdClien + cIdEnder ))
                    nPos := Ascan(Self:aUf,{|x| Alltrim(x[2])==Alltrim(aPedidos[nX,06][01,02,06][01]) })
                    If nPos > 0
                        cUF := Self:aUf[nPos,03]
                   else
                        // MGOMES e FLAVIO // 29/09/2021 - INICIO
                        If !EMPTY( aPedidos[nX,06][01,01,08][01] )
                            cUF := aPedidos[nX,06][01,01,08][01]
                        ELSE
                            cUF := ""
                        EndIf
                        // MGOMES e FLAVIO // 29/09/2021 - FIM
                        //cUF := ""
                    EndIf

                    //->> Marcelo Celi - 31/12/2020
                    aEnder := FormatEnder(Alltrim(aPedidos[nX,06][01,02,05][01]),cUF,Alltrim(aPedidos[nX,06][01,02,07][01]))
                    
                    //->> Marcelo Celi - 31/12/2020
                    //cEnder  := Alltrim(aPedidos[nX,06][01,02,05][01])
                    //cEnder  := StrTran(cEnder,Chr(10) + Chr(13),"")
                    //cEnder  := StrTran(cEnder,Chr(13) + Chr(10),"")
                    //cEnder  := StrTran(cEnder,CRLF,"")
                
                    cEnder      := aEnder[01]
                    cBairro     := aEnder[02]
                    cUF         := aEnder[03]
                    cMunicipio  := aEnder[04]
                    cCodMunic   := aEnder[05]
                
                    lCGCEnc := .F.

                    If !Empty(cCgc)
                        SA1->(dbSetOrder(3))
                        If SA1->(dbSeek(xFilial("SA1")+cCgc))
                            lCGCEnc := .T.
                            cCodCli := SA1->A1_COD
                            cLojCli := SA1->A1_LOJA
                            SA1->(dbSetOrder(1))
                            Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                                cLojCli := Soma1(cLojCli) 
                                If !Empty(SA1->A1_NATUREZ)
                                    cNatureza := SA1->A1_NATUREZ
                                EndIf                                   
                            EndDo
                        Else
                            cCodCli := GetSxeNum("SA1","A1_COD")
                            cLojCli := "01"
                            ConfirmSX8()
                            Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                                cLojCli := Soma1(cLojCli)                                    
                            EndDo
                        EndIf
                    Else
                        cCodCli := GetSxeNum("SA1","A1_COD")
                        cLojCli := "01"
                        ConfirmSX8()
                        SA1->(dbSetOrder(1))
                        Do While SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
                            cLojCli := Soma1(cLojCli)                                    
                        EndDo
                    EndIf

                    if !lCGCEnc
                        Reclock("SA1",.T.)
                        SA1->A1_FILIAL  := xFilial("SA1")
                        SA1->A1_COD     := cCodCli
                        SA1->A1_LOJA    := cLojCli
                        SA1->A1_XIDECOM := cIdClien
                        SA1->A1_XIDENDE := cIdEnder
                        SA1->A1_NOME    := Upper(Alltrim(aPedidos[nX,06][01,02,03][01]) + " " + Alltrim(aPedidos[nX,06][01,02,04][01]))
                        SA1->A1_END     := Upper(Alltrim(cEnder))
                        
                        //->> Marcelo Celi - 31/12/2020                    
                        SA1->A1_BAIRRO  := Upper(Alltrim(cBairro))
                        SA1->A1_MUN     := cMunicipio
                        SA1->A1_PAIS    := "105"
                        SA1->A1_CODPAIS := "01058"
                        SA1->A1_COD_MUN := cCodMunic
                        
                        SA1->A1_EST     := cUF                    
                        SA1->A1_NATUREZ := cNatureza
                        SA1->A1_CEP     := StrTran(Alltrim(aPedidos[nX,06][01,02,10][01]),"-","")
                        SA1->A1_TEL     := StrTran(Alltrim(aPedidos[nX,06][01,02,12][01]),"-","")
                        SA1->A1_TIPO    := "F" // CONSUMIDOR FINAL
                        SA1->A1_PESSOA  := cPessoa
                        SA1->A1_CGC     := cCgc
                        SA1->A1_XORIGEM := "E"

                        //->> Marcelo Celi - 05/01/2020
                        SA1->A1_INSCR   := "ISENTO"
                        SA1->A1_CONTRIB := "2"
                        SA1->A1_TIPO    := "F"

                        SA1->(MsUnlock())
                    Endif

                    lCliEOk := .T.
                    cCliEnt := SA1->A1_COD
                    cLojEnt := SA1->A1_LOJA
                    cTipoCli:= SA1->A1_TIPO
                
                Else
                    lCliEOk := .T.
                    cCliEnt := SA1->A1_COD
                    cLojEnt := SA1->A1_LOJA
                    cTipoCli:= SA1->A1_TIPO
                EndIf

                If lCliEOk .And. lCliFOk
                    For nY:=1 to Len(aPedidos[nX,06][01,03])
                        lProdOk := .F.  
                        aItem   := {}          
                        SB1->( dbOrderNickName("B1XIDECOM") ) // por id do produto
                        If !SB1->(dbSeek(xFilial("SB1")+aPedidos[nX,06][01,03][nY,02]))
                            SB1->(dbSetOrder(1)) // por sku
                            If !SB1->(dbSeek(xFilial("SB1")+aPedidos[nX,06][01,03][nY,04]))
                                SB1->(dbSetOrder(5)) // por codigo de barras
                                If SB1->(dbSeek(xFilial("SB1")+aPedidos[nX,06][01,03][nY,04]))
                                    Reclock("SB1",.F.)
                                    SB1->B1_XIDECOM := aPedidos[nX,06][01,03][nY,02]
                                    SB1->(MsUnlock())
                                    lProdOk := .T.
                                Else
                                    //->> Marcelo Celi - 21/12/2020
                                    SB1->(dbSetOrder(14)) // por codigo getin
                                    If SB1->(dbSeek(xFilial("SB1")+aPedidos[nX,06][01,03][nY,04]))
                                        Reclock("SB1",.F.)
                                        SB1->B1_XIDECOM := aPedidos[nX,06][01,03][nY,02]
                                        SB1->(MsUnlock())
                                        lProdOk := .T.
                                    Else                                
                                        lProdOk := .F.    
                                    EndIf    
                                EndIf
                            Else
                                lProdOk := .T.
                            EndIf        
                        Else
                            lProdOk := .T.
                        EndIf

                        If lProdOk                    
                            //->> Tes inteligente na venda
                            SX5->(dbSetOrder(1))
                            SF4->(dbSetOrder(1))
                            If !Empty(Self:cOper) .And. SX5->(dbSeek(xFilial("SX5")+PadR("DJ",Tamsx3("X5_TABELA")[01])+PadR(Self:cOper,Tamsx3("X5_CHAVE")[01])))
                                aCols   := {}
                                aHeader := {}
                                cTes := MaTESInt(2,Alltrim(Self:cOper),cCliEnt,cLojEnt,"N",SB1->B1_COD)
                                If !(!Empty(cTes) .And. SF4->(dbSeek(xFilial("SF4")+cTes)) .And. SF4->F4_MSBLQL <> "1" .And. SF4->F4_TIPO == "S")                            
                                    cTes := Self:cTes
                                EndIf
                            Else
                                cTes := Self:cTes
                            EndIf                    
                            
                            nVlrTot := Round(aPedidos[nX,06][01,03][nY,05],Tamsx3("C6_QTDVEN")[2]) * Round(aPedidos[nX,06][01,03][nY,06],Tamsx3("C6_PRUNIT")[2])                    
                                                        
                            aAdd(aItem,{"C6_ITEM"   ,StrZEro(nY,Tamsx3("C6_ITEM")[1])   					    	,Nil}) // Item
                            aAdd(aItem,{"C6_PRODUTO",SB1->B1_COD 										    		,Nil}) // Produto
                            aAdd(aItem,{"C6_DESCRI" ,SB1->B1_DESC 									    			,Nil}) // Descricao do Produto	        
                            aAdd(aItem,{"C6_QTDVEN" ,Round(aPedidos[nX,06][01,03][nY,05],Tamsx3("C6_QTDVEN")[2])    ,Nil}) // Quantidade
                            aAdd(aItem,{"C6_QTDLIB ",Round(aPedidos[nX,06][01,03][nY,05],Tamsx3("C6_QTDLIB")[2])    ,Nil}) // Quantidade Liberada
                            aAdd(aItem,{"C6_PRUNIT" ,Round(aPedidos[nX,06][01,03][nY,06],Tamsx3("C6_PRUNIT")[2])   	,Nil}) // Preco Unit.
                            aAdd(aItem,{"C6_PRCVEN" ,Round(aPedidos[nX,06][01,03][nY,06],Tamsx3("C6_PRCVEN")[2])   	,Nil}) // Preco Unit.
                            aAdd(aItem,{"C6_VALOR"  ,Round(nVlrTot                      ,Tamsx3("C6_VALOR")[2])	    ,Nil}) // Valor Tot. 
                        //  aAdd(aItem,{"C6_VALDESC",alltrim(aPedidos[nX][8])                                       ,Nil}) // Valor Desconto. 
                            aAdd(aItem,{"C6_ENTREG" ,dEntrega     	    											,Nil}) // Dt.Entrega
                            aAdd(aItem,{"C6_UM"     ,SB1->B1_UM			    			  							,Nil}) // Unidade
                            aAdd(aItem,{"C6_LOCAL"  ,SB1->B1_LOCPAD			    									,Nil}) // Almoxarifado
                            aAdd(aItem,{"C6_TES" 	,cTes						    								,Nil}) // Tipo de Saida
                            
                            //->> Marcelo Celi - 05/01/2021 - Inicio do ajuste
                            aAdd(aItem,{"C6_QTDLIB" ,0                                                          	,Nil}) // Quantidade Liberada                  

                            nVlr2Unid := Round(aPedidos[nX,06][01,03][nY,06],Tamsx3("C6_PRUNIT")[2])
                            If SB1->B1_TIPCONV == "D"
                                nVlr2Unid := Round(nVlr2Unid / SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
                            Else
                                nVlr2Unid := Round(nVlr2Unid * SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
                            EndIf

                            aAdd(aItem,{"C6_SEGUM" ,SB1->B1_SEGUM	                                                ,Nil}) // Segunda Unidade de Medida
                            aAdd(aItem,{"C6_UNSVEN" ,nVlr2Unid  	                                                ,Nil}) // Segunda Unidade de Medida
                            //->> Marcelo Celi - 05/01/2021 - Fim do ajuste
                                                        
                            aAdd(aItens,aClone(aItem))
                        Else
                            cObs := "ERRO VDA:"+Alltrim(cNumVdaEc)+", SKU: "+Alltrim(Upper(aPedidos[nX,06][01,03][nY,04]))+" - "+Alltrim(Upper(aPedidos[nX,06][01,03][nY,03]))
                            aItens := {}
                            Exit
                        EndIf        
                    Next nY
                EndIf

                If Len(aItens) > 0 .And. lCliEOk .And. lCliFOk
                    dDatabase := dEmissao

                    //->> Marcelo Celi - 23/12/2020
                    SC5->(dbSetOrder(1))
                    cNumero := GetSXENum("SC5","C5_NUM")
                    Do While SC5->(dbSeek(xFilial("SC5")+cNumero))
                        ConfirmSX8()
                        cNumero := GetSXENum("SC5","C5_NUM")
                    EndDo
                    
                    //->> Dar rollback para não pular a numeração devido ao inicializador padrão do numero no sx3
                    RollBAckSx8()
                    
                    SA1->(dbSetOrder(1))
                    SA1->(dbSeek(xFilial("SA1")+cCliEnt+cLojEnt))

                    aAdd(aCabec,{"C5_NUM"    	,cNumero                                   	,Nil}) 	//->> Numero do Pedido
                    aAdd(aCabec,{"C5_TIPO"  	,"N"                                    	,Nil}) 	//->> Tipo de Pedido
                    aAdd(aCabec,{"C5_CLIENTE"	,cCliFat	                            	,Nil})	//->> Cliente de Faturamento
                    aAdd(aCabec,{"C5_LOJACLI"	,cLojFat	                               	,Nil})	//->> Loja de Faturamento                        
                    aAdd(aCabec,{"C5_CLIENT"	,cCliEnt	                            	,Nil})	//->> Cliente de Entrega
                    aAdd(aCabec,{"C5_LOJAENT"	,cLojEnt	                               	,Nil})	//->> Loja de Entrega
                    aAdd(aCabec,{"C5_EMISSAO"	,dEmissao		                        	,Nil})	//->> Emissao
                    aAdd(aCabec,{"C5_TIPOCLI"	,cTipoCli    	                        	,Nil})	//->> Tipo de Cliente
                    aAdd(aCabec,{"C5_CONDPAG"	,cCondPag		                        	,Nil})	//->> Condição de Pagamento	
                    aAdd(aCabec,{"C5_TIPLIB"	,"1"		                        		,Nil})	//->> Tipo de Liberacao
                    aAdd(aCabec,{"C5_DESCFI"	,0			                        		,Nil})	//->> Desconto Financeiro
                    aAdd(aCabec,{"C5_FRETE"	    ,nFrete		                        		,Nil})	//->> Frete
                    aAdd(aCabec,{"C5_DESPESA"	,0			                        		,Nil})	//->> Despesa
                    aAdd(aCabec,{"C5_SEGURO"	,0		                        			,Nil})	//->> Seguro
                    aAdd(aCabec,{"C5_FRETAUT"	,0		                        			,Nil})	//->> Frete Auto
                    aAdd(aCabec,{"C5_MOEDA"	    ,1			                        		,Nil})	//->> Moeda
                    aAdd(aCabec,{"C5_DESCONT"	,nDescont		                        	,Nil})	//->> Desconto        
            //      aAdd(aCabec,{"C5_DESC1"	    ,nDescont		                        	,Nil})	//->> Desconto        
            //      aAdd(aCabec,{"C5_XMSGVNF"	,nDescont		                        	,Nil})	//->> Desconto               
                    aAdd(aCabec,{"C5_XIDECOM"	,aPedidos[nX,01]	                        ,Nil})	//->> Id eCommerce 
                    aAdd(aCabec,{"C5_XDINCLU"	,dEmissao                       			,Nil})	//->> Dt Incl eCom 
                    aAdd(aCabec,{"C5_XHINCLU"	,SubStr(aPedidos[nX,03],12,8)	       	    ,Nil})	//->> Hr Incl eCom 
                    aAdd(aCabec,{"C5_XDUPDAT"	,dEntrega                       			,Nil})	//->> Dt Alte eCom 
                    aAdd(aCabec,{"C5_XHUPDAT"	,SubStr(aPedidos[nX,04],12,8)		       	,Nil})	//->> Hr Alte eCom 
                    
                    //->> Marcelo Celi - 31/12/2020
                    aAdd(aCabec,{"C5_XFORPGT"	,cFormPgto                  		       	,Nil})	//->> Forma de Pgto

                    //->> Marcelo Celi - 04/01/2020
                    aAdd(aCabec,{"C5_XNVDAEC"	,cNumVdaEc                  		       	,Nil})	//->> Numero da Venda no e-Commerce

                    //->> Marcelo Celi - 06/01/2020
                    lAutoErrNoFile := .T.

                    lMSErroAuto := .F.
                    aLog        := {}
                    cErro       := ""
                    MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3) 
                    If lMSErroAuto                        
                        cObs := "ERRO NA ROTINA AUTOMATICA DE PEDIDOS"
                        lErro := .T.
                        aLog  := GetAutoGRLog()
                        For nZ:=1 to 100
                            If nZ <= Len(aLog)
                                cErro += aLog[nZ]+CRLF
                            Else
                                Exit
                            EndIf
                        Next nZ
                    Else
                        lErro := .F.
                        If Self:lCriaNf
                            //->> Liberação do Pedido por credito e estoque
                            SC6->(dbSetOrder(1))
                            SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
                            Do While SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
                                MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,@lCredito,@lEstoque,.T.,.T.,.F.,.F.) 
                                SC6->(dbSkip())
                            EndDo

                            //->> Geração da Nota Fiscal de Saida
                            DbSelectArea("SC6")
                            SC6->(dbSetOrder(1))
                            SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))		
                            DbSelectArea("SC9")
                            SC9->(DbSetOrder(1))
                            DbSelectArea("SE4")
                            SE4->(DbSetOrder(1))
                            DbSelectArea("SB1")
                            SB1->(DbSetOrder(1))
                            DbSelectArea("SF4")
                            SF4->(DbSetOrder(1))

                            aPvlNfs := {}
                            cNota   := ""
                            Do While SC6->(!Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
                                If SC9->(dbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) 		
                                    SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  		
                                    SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))    		
                                    SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))	
                        
                                    Aadd(aPvlNfs,{  SC9->C9_PEDIDO,;
                                                    SC9->C9_ITEM,;
                                                    SC9->C9_SEQUEN,;
                                                    SC9->C9_QTDLIB,;
                                                    SC9->C9_PRCVEN,;
                                                    SC9->C9_PRODUTO,;
                                                    .F.,;
                                                    SC9->(RecNo()),;
                                                    SC5->(RecNo()),;
                                                    SC6->(RecNo()),;
                                                    SE4->(RecNo()),;
                                                    SB1->(RecNo()),;
                                                    SB2->(RecNo()),;
                                                    SF4->(RecNo())})							    
                            
                                EndIf
                                SC6->(dbSkip())
                            EndDo	    	
                            If Len(aPvlNfs)>0
                                cNota := MaPvlNfs(aPvlNfs, cSerie , .F., .F., .F., .T., .F., 0, 0, .T., .F., "")    	
                            EndIf
                            If Empty(cNota)
                                lErro := .T.
                                cErro := "Nota Fiscal de Saida não pode ser gerada."
                                cObs  := Upper(cErro)
                            Else
                                lErro := .F.
                            EndIf
                        EndIf
                    EndIf

                    If lErro
                        DisarmTransaction()
                        Self:GravaLogErro("D","V",If(Self:lJob,"J","T"),"salesOrderInfo","","",aPedidos[nX,01],cErro)
                    EndIf
                Else
                    lErro := .T.
                    DisarmTransaction()
                EndIf
            EndIf
        End Transaction
    
        //->> Marcelo Celi - 04/01/2020
        If lErro
            GrvLogErro(aPedidos[nX,01],cObs,cErro,dToc(dEmissao))
        EndIf
    
    Next nX
Next dProc

dDatabase:= _dDatabase
RestArea(aArea)

Return Self

/*/{protheus.doc} LinkProdutos
*******************************************************************************************
Desce o id dos produtos e grava na SB1
 
@author: Marcelo Celi Marques
@since: 22/12/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method LinkProdutos() Class MCMagento
If Self:lJob
    Self:DescID2Prd()
Else
    Processa({|a| Self:DescID2Prd() },"Aguarde","Linkando Produtos do Protheus com os do site do e-Commerce...")
EndIf
Return Self

Method DescID2Prd() Class MCMagento
Local cEnvelope     := ""
Local cResponse     := ""
Local cError        := ""
Local cWarning      := ""
Local cId           := ""
Local cSku          := ""

Private oXml        := NIL
Private nX          := 1

If !Self:lJob
    ProcRegua(0)
    IncProc("Baixando Ids de Produtos...")
    IncProc("Atualizando Ids de Produtos...")
EndIf
    
//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("catalogProductList")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("catalogProductList")    
    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:catalogProductList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <filters xsi:type="urn:filters">'+CRLF
    cEnvelope += '            <filter xsi:type="urn:associativeArray" soapenc:arrayType="urn:associativeEntity[]"/>'+CRLF
    cEnvelope += '            <complex_filter xsi:type="urn:complexFilterArray" soapenc:arrayType="urn:complexFilter[]"/>'+CRLF
    cEnvelope += '         </filters>'+CRLF
    cEnvelope += '         <storeView xsi:type="xsd:string">1</storeView>'+CRLF
    cEnvelope += '      </urn:catalogProductList>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If Self:oWsdl:SendSoapMsg(cEnvelope)
        cResponse := Self:oWsdl:GetSoapResponse()
        oXml := XmlParser(cResponse, "_", @cError, @cWarning)
        If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM")<>"U"
            For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM)
                cId  := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_product_id:TEXT
                cSku := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_sku:TEXT

                If !Empty(cSku) .And. !Empty(cId)
                    cSku := PadR(cSku,Tamsx3("B1_CODGTIN")[01])
                    SB1->(dbSetOrder(14)) //->> buscar pelo gtin
                    If SB1->(dbSeek(xFilial("SB1")+cSku))
                        Reclock("SB1",.F.)
                        SB1->B1_XIDECOM := cId
                        SB1->B1_XECOMM  := "S"
                        SB1->(MsUnlock())
                    EndIf
                EndIf
            Next nX    
        Endif    
    Else
        Self:cError := Self:oWsdl:cError
    EndIf
Else
    Self:cError := Self:oWsdl:cError
EndIf

Return Self

/*/{protheus.doc} EntregPedido
*******************************************************************************************
Sobe para o ecommerce a informação que a nota fiscal ja foi gerada e vai ser entregue
 
@author: Marcelo Celi Marques
@since: 28/12/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method EntregPedido(cIdEcomm) Class MCMagento
If Self:lJob
    Self:EntregPV(cIdEcomm)
Else
    Processa({|a| Self:EntregPV(cIdEcomm) },"Aguarde","Atualizando e-Commerce...")
EndIf
Return Self

Method EntregPV(cIdEcomm) Class MCMagento
Local cEnvelope := ""

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("salesOrderShipmentCreate")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("salesOrderShipmentCreate")
    If !Self:lJob
        ProcRegua(0)
        IncProc("")
    EndIf

    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '<soapenv:Header/>'+CRLF
    cEnvelope += '  <soapenv:Body>'+CRLF
    cEnvelope += '       <urn:salesOrderShipmentCreate soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '           <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '           <orderIncrementId xsi:type="xsd:string">'+cIdEcomm+'</orderIncrementId>'+CRLF
    cEnvelope += '           <itemsQty xsi:type="urn:orderItemIdQtyArray" soapenc:arrayType="urn:orderItemIdQty[]"/>'+CRLF
    //cEnvelope += '           <comment xsi:type="xsd:string">?</comment>'+CRLF
    //cEnvelope += '           <email xsi:type="xsd:int">?</email>'+CRLF
    //cEnvelope += '           <includeComment xsi:type="xsd:int">?</includeComment>'+CRLF
    cEnvelope += '       </urn:salesOrderShipmentCreate>'+CRLF
    cEnvelope += '  </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If !Self:oWsdl:SendSoapMsg(cEnvelope)
        Self:cError := Self:oWsdl:cError        
    EndIf
Else
    Self:cError := Self:oWsdl:cError    
EndIf

Return Self

/*/{protheus.doc} SobeTracking
*******************************************************************************************
Sobe para o ecommerce o tracking
 
@author: Marcelo Celi Marques
@since: 28/12/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeTracking(cIdEcomm,cTracking) Class MCMagento
If Self:lJob
    Self:EntregPV(cIdEcomm,cTracking)
Else
    Processa({|a| Self:EntregPV(cIdEcomm,cTracking) },"Aguarde","Atualizando e-Commerce...")
EndIf
Return Self

Method AtuTracking(cIdEcomm,cTracking) Class MCMagento
Local cEnvelope     := ""
Local cTitulo       := "FRETE"
Local cLogistica    := "MANDAE"

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("salesOrderShipmentAddTrack")
    Self:Iniciar(Self:lJob)
EndIf

If Self:oWsdl:SetOperation("salesOrderShipmentAddTrack")
    If !Self:lJob
        ProcRegua(0)
        IncProc("")
    EndIf

    cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
    cEnvelope += '   <soapenv:Header/>'+CRLF
    cEnvelope += '   <soapenv:Body>'+CRLF
    cEnvelope += '      <urn:salesOrderShipmentAddTrack soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
    cEnvelope += '         <sessionId xsi:type="xsd:string">'+Self:cToken+'</sessionId>'+CRLF
    cEnvelope += '         <shipmentIncrementId xsi:type="xsd:string">'+cIdEcomm+'</shipmentIncrementId>'+CRLF
    cEnvelope += '         <carrier xsi:type="xsd:string">'+cLogistica+'</carrier>'+CRLF
    cEnvelope += '         <title xsi:type="xsd:string">'+cTitulo+'</title>'+CRLF
    cEnvelope += '         <trackNumber xsi:type="xsd:string">'+cTracking+'</trackNumber>'+CRLF
    cEnvelope += '      </urn:salesOrderShipmentAddTrack>'+CRLF
    cEnvelope += '   </soapenv:Body>'+CRLF
    cEnvelope += '</soapenv:Envelope>'+CRLF

    If !Self:oWsdl:SendSoapMsg(cEnvelope)
        Self:cError := Self:oWsdl:cError        
    EndIf
Else
    Self:cError := Self:oWsdl:cError    
EndIf

Return Self

/*/{protheus.doc} FormatEnder
*******************************************************************************************
Separa em array o endereço do cliente
 
@author: Marcelo Celi Marques
@since: 28/12/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function FormatEnder(cEnder,cUF,cMunicipio)
Local aEnder    := {}
Local aTmpEnder := {}
Local aRet      := {"","","","",""}
Local nX        := 1
Local cFrase    := ""
Local cCodMunic := ""

cUF         := Alltrim(cUF)
cUF         := FwNoAccent(cUF)
cUF         := Upper(cUF)

cMunicipio  := Alltrim(cMunicipio)
cMunicipio  := FwNoAccent(cMunicipio)
cMunicipio  := Upper(cMunicipio)

CC2->(dbSetOrder(4))
If CC2->(dbSeek(xFilial("CC2")+cUF+cMunicipio))
    cCodMunic := CC2->CC2_CODMUN
Else
    cCodMunic := ""
EndIf

For nX:=1 to Len(cEnder)
    If Asc(SubStr(cEnder,nX,1))==10 .Or. Asc(SubStr(cEnder,nX,1))==13
        aAdd(aTmpEnder,cFrase)
        cFrase := ""
    Else
        cFrase += SubStr(cEnder,nX,1)
    EndIf
Next nX
If !Empty(cFrase)
    aAdd(aTmpEnder,cFrase)
EndIf

For nX:=1 to Len(aTmpEnder)
    If !Empty(aTmpEnder[nX])
        aAdd(aEnder,aTmpEnder[nX])
    EndIf
Next nX

If Len(aEnder) > 1
    For nX:=1 to Len(aEnder)-1
        aRet[01]+=Alltrim(aEnder[nX])+" "
    Next nX
    aRet[02] := aEnder[Len(aEnder)]
Else

EndIf

aRet[01] := Alltrim(aRet[01])
aRet[01] := FwNoAccent(aRet[01])
aRet[01] := Upper(aRet[01])

aRet[02] := Alltrim(aRet[02])
aRet[02] := FwNoAccent(aRet[02])
aRet[02] := Upper(aRet[02])

aRet[03] := cUF

aRet[04] := cMunicipio

aRet[05] := cCodMunic

Return aRet

/*/{protheus.doc} GrvLogErro
*******************************************************************************************
Grava o log de erros
 
@author: Marcelo Celi Marques
@since: 04/01/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GrvLogErro(cIdVenda,cObs,cErro,cData)
If AliasInDic("ZWU")
    Reclock("ZWU",.T.)
    ZWU->ZWU_FILIAL := xFilial("ZWU")
    ZWU->ZWU_IDECOM := cIdVenda
    ZWU->ZWU_OBS    := cObs
    ZWU->ZWU_ERRO   := cErro
    ZWU->ZWU_DATA   := cData
    ZWU->(MsUnlock())
EndIf
Return


/*/{protheus.doc} SobeChvNF
*******************************************************************************************
Sobe para o ecommerce a chave da Nota Fiscal
 
@author: Daniel Bastos
@since: 02/05/2021
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SobeChvNF() Class MCMagento
If Self:lJob
    Self:SobeChv()
Else
    Processa({|a| Self:SobeChv() },"Aguarde","Atualizando e-Commerce...")
EndIf
Return Self

Method SobeChv() Class MCMagento
Local nTotRegs  := 0
Local cEnvelope := ""
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local cMensagem := ""
Local cResponse := ""

//->> Refaz a Conexão
If !Self:oWsdl:SetOperation("salesOrderAddComment")
    Self:Iniciar(Self:lJob)
EndIf

cQuery := "SELECT SF2.R_E_C_N_O_ SF2RECNO, F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA,F2_CHVNFE,F2_DAUTNFE,F2_HAUTNFE, C5_XIDECOM, F2_EMISSAO, F2_HORA " +CRLF
cQuery += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + CRLF

cQuery += " INNER JOIN "
cQuery += RetSqlName("SC5") + " SC5 (NOLOCK) " + CRLF
cQuery += "     ON C5_FILIAL = F2_FILIAL " + CRLF
cQuery += "     AND C5_CLIENTE = F2_CLIENTE " + CRLF
cQuery += "     AND C5_LOJACLI = F2_LOJA " + CRLF
cQuery += "     AND C5_NOTA = F2_DOC " + CRLF
cQuery += "     AND C5_SERIE = F2_SERIE " + CRLF
cQuery += "     AND C5_XIDECOM <> ' ' " + CRLF
cQuery += "     AND SC5.D_E_L_E_T_ <> '*' " + CRLF

cQuery += " WHERE F2_FILIAL = '" + xFilial("SF2") + "' " + CRLF
cQuery += "     AND F2_CHVNFE <> ' ' "  + CRLF
cQuery += "     AND F2_XSUBJOB = ' ' "  + CRLF
cQuery += "     AND F2_EMISSAO >= '" + dTos(msDate() - 7) + "' "  + CRLF
cQuery += "     AND SF2.D_E_L_E_T_ <> '*' " + CRLF

cQuery += " ORDER BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA,F2_CHVNFE,F2_DAUTNFE,F2_HAUTNFE, C5_XIDECOM  " + CRLF

If !Self:lJob
    ProcRegua(0)
    IncProc("Selecionando Registros...")
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
dbEval( {|x| nTotRegs++ },,{|| (cAlias)->(!Eof())})
(cAlias)->(dbGotop())

//->> Atualização da ZWS
nRecno := ZWSAtualiza(NIL,"S","R",If(Self:lJob,"J","T"),nTotRegs)

If Self:oWsdl:SetOperation("salesOrderAddComment")
    If !Self:lJob
        ProcRegua(0)
        IncProc("")
    EndIf

    dbSelectArea("SF2")

    while (cAlias)->(!Eof())
        cMensagem := "Chave de acesso: " + (cAlias)->F2_CHVNFE + "; "
    //  cMensagem += "Data: " + (cAlias)->F2_DAUTNFE + " "
        cMensagem += "Data: " + dtoc( ( IIF( EMPTY((cAlias)->F2_DAUTNFE), (cAlias)->F2_EMISSAO, (cAlias)->F2_DAUTNFE ) ) ) + " " // Flávio Monachesi 04/08/21
        cMensagem +=  ( IIF( EMPTY((cAlias)->F2_HAUTNFE), (cAlias)->F2_HORA, (cAlias)->F2_HAUTNFE ) ) + ":00" + "; "

        cEnvelope := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">'+CRLF
        cEnvelope += '<soapenv:Header/>'+CRLF
        cEnvelope += '<soapenv:Body>'+CRLF
        cEnvelope += '    <urn:salesOrderAddComment soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+CRLF
        cEnvelope += '        <sessionId xsi:type="xsd:string">' + Self:cToken + '</sessionId>'+CRLF
        cEnvelope += '        <orderIncrementId xsi:type="xsd:string">' + alltrim((cAlias)->C5_XIDECOM) + '</orderIncrementId>'+CRLF
        cEnvelope += '        <status xsi:type="xsd:string">faturado</status>'+CRLF
        cEnvelope += '        <comment xsi:type="xsd:string"><![CDATA[' + cMensagem + ']]></comment>'+CRLF
        cEnvelope += '        <notify xsi:type="xsd:string">1</notify>'+CRLF
        cEnvelope += '    </urn:salesOrderAddComment>'+CRLF
        cEnvelope += '</soapenv:Body>'+CRLF
        cEnvelope += '</soapenv:Envelope>'+CRLF

        if Self:oWsdl:SendSoapMsg(cEnvelope)
            cResponse := Self:oWsdl:GetSoapResponse()
            
            SF2->(dbGoTop())
            SF2->(dbGoTo((cAlias)->SF2RECNO))
            SF2->(Reclock("SF2",.F.))
                SF2->F2_XSUBJOB := "OK"
            SF2->(MsUnlock())
        else
            Self:cError := Self:oWsdl:cError        
            ZWSAtualiza(nRecno,,,,,.T.)
            Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,"CHAVENFE",Self:cError)
        endIf
        (cAlias)->(dbSkip())
    EndDo
Else
    Self:cError := Self:oWsdl:cError    
    ZWSAtualiza(nRecno,,,,,.T.)
    Self:GravaLogErro("S","T",If(Self:lJob,"J","T"),Self:oWsdl:cCurrentOperation,cEnvelope,cResponse,"CHAVENFE",Self:cError)
EndIf

(cAlias)->(dbCloseArea())

Return Self
