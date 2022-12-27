#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} RFATF04()
Busca a razão social ou nome fantasia do PEDIDO DE VENDA

	@author  Marcos Gomes - @INTEGRA ERP
	@version P12
	@since   23/03/2021
	@type 	 function
/*/
//-------------------------------------------------------------------
USER FUNCTION RFATF04( cNumPed, cTipoRet )

LOCAL cCodigo   := SC5->C5_CLIENTE
LOCAL cLojaCli  := SC5->C5_LOJACLI
LOCAL cNomeCli  := ""

LOCAL aAREA_ATU := GETAREA()
LOCAL aAREA_SA1 := SA1->( GETAREA() )
LOCAL aAREA_SA2 := SA2->( GETAREA() )

DEFAULT cTipoRet := 1

    //-------------------------------------------
    // NOME DO CLIENTE / FORNECEDOR
    //-------------------------------------------
    If SC5->C5_TIPO = "B" .OR. SC5->C5_TIPO = "D"  // SA2 - FORNECEDOR

        DBSelectArea("SA2")
        DBSetOrder(1)
        DBSeek( xFilial("SA2") + cCodigo + cLojaCli, .f. )

        cNomeCli := SA2->A2_NOME
        cNomeFan := SA2->A2_NREDUZ

    Else

        DBSelectArea("SA1")
        DBSetOrder(1)
        DBSeek( xFilial("SA1") + cCodigo + cLojaCli )

        cNomeCli := SA1->A1_NOME
        cNomeFan := SA1->A1_NREDUZ

    EndIf

//-------------------------------------------
// Restaura a(s) area(s) salva(s)
//-------------------------------------------
RESTAREA( aAREA_SA1 )
RESTAREA( aAREA_SA2 )
RESTAREA( aAREA_ATU )

Return( IIF( cTipoRet==1, cNomeCli, cNomeFan ) )
