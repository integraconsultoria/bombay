#include 'parmtype.ch'
#include 'protheus.ch'
#include "rwmake.ch"
#include "tbiconn.ch
#include "topconn.ch"
/*
——————————————————E
PE01NFESEFAZ
——————————————————E
Parametros :ParamIXB
ParamIXB[01] aProd
ParamIXB[02] cMensCli
ParamIXB[03] cMensFis
ParamIXB[04] aDest
ParamIXB[05] aNota
ParamIXB[06] aInfoItem
ParamIXB[07] aDupl
ParamIXB[08] aTransp
ParamIXB[09] aEntrega
ParamIXB[10] aRetirada
ParamIXB[11] aVeiculo
ParamIXB[12] aReboque
——————————————————E
Partida : NFESEFAZ (P.E.)
——————————————————E
*/

User Function PE01NFESEFAZ()

Local aRet  := ParamIXB
Local aGet  :=getarea()
Local cString :=" "

Dbselectarea("SC5")
SC5->(dbSetOrder(1))

if SC5->(MsSeek(xFilial("SC5")+SD2->D2_PEDIDO))
    if !Empty(SC5->C5_XIDECOM)  

        cString+="pedido ecommerce : "+ SC5->C5_XIDECOM+ CRLF
        cString+=" pedido   : " + SC5->C5_NUM+ CRLF
        cString+=" vendedor : " + posicione("SA3",1,xfilial("SA3")+SC5->C5_VEND1,"A3_NOME")

    elseif Empty(SC5->C5_XIDECOM) 

	    cString+="pedido   : " + SC5->C5_NUM
        cString+="vendedor : " + posicione("SA3",1,xfilial("SA3")+SC5->C5_VEND1,"A3_NOME")
        cString+="pedido de Compra cliente  : " + SC5->C5_XPEDCLI
		cString+="End Entrega : " + posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_ENDENT")
		cString+="Bairro de Entrega : " + posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_BAIRROE")
		cString+="Estado de Entrega : " + posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_ESTE")
		cString+="Compl : " + posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_COMPENT")
    endif
endif

aRet[2] += cString

restarea(aGet)

Return(aRet)
