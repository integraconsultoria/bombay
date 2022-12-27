#include "protheus.ch"
#DEFINE ENTER Chr(13)+Chr(10)   
/*
=====================================================================================
Programa............: COMRD001
Autor...............: Paulo Bindo
Data................: 23/08/2022
Descricao / Objetivo: VALIDAR tabela preco para pedido de compras de transferencia
Solicitante.........: 
Uso.................: 
Obs.................: 
=====================================================================================
*/



User Function COMRD001()
	//Posicione("DA1",1,xFilial("DA1")+"022"+M->C7_PRODUTO,"DA1_PRCVEN")                                  
	Local nConteudo := 0
	Local cTabela := "022"
	Posicione("DA1",1,xFilial("DA1")+"022"+M->C7_PRODUTO,"DA1_PRCVEN")

	dbSelectArea("DA1")
	dbSetOrder(1)
	If dbSeek(xFilial("DA1")+cTabela+M->C7_PRODUTO)

		If  DA1->DA1_ATIVO = "2"

			cErrDesc := "Produto Blq tabela Preco: " + AllTrim( M->C7_PRODUTO )+ENTER
			cErrDesc += "Codigo Tabela : "+cTabela

			Help( , , 'Aviso - COMRD001' , , cErrDesc, 1, 0, , , , , , {"Verifique com o Dpto de Produção qual produto deverá ser comprado no lugar deste produto"})
			Return(0)
		else
            nConteudo := DA1->DA1_PRCVEN
        EndIf
	Else

		cErrDesc := "Produto sem tabela Preco: " + AllTrim( M->C7_PRODUTO )
		Help( , , 'Aviso - COMRD001' , , cErrDesc, 1, 0, , , , , , {"Verifique com o Dpto de Produção qual o motivo do produto não estar cadastrado na tabela 22"})
		Return(0)
	EndIf

Return(nConteudo)
