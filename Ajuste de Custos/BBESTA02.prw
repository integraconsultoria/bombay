#include "protheus.ch"
#include "TOPCONN.ch"   
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"

// Modulo : SIGAEST
// Fonte  : BBESTA02
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+-----------------------------------------------------------
// 05/01/18 | RENATO SANTOS       | Rotina Movimentos Internos - ARRUMA CUSTO MEDIO MOD 2
//          | INTEGRA             | *** MOVIMENTO MULTIPLO   
//          |                     | 
User Function BBESTA02(aItensArr)
Local _aItmAvEnt    := {}
Local _aItmAvSai    := {}
Local _aCabArrEnt   := {}
Local _aCabArrSai   := {}
Local _aTotItEnt    := {}
Local _aTotItSai    := {}
Local cTMEnt	    := SuperGetMV("BB_TMAJENT",,"005")
Local cTMSai	    := SuperGetMV("BB_TMAJSAI",,"505")
Local cUM 		    := ""
Local nCstRec	    := 0
Local cItBlq        := .F.

Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. //necessario a criacao

Default aItensArr := {}
//cProdAt, cLocAt, nCstSB2, nCstCalc, nQtdSB2
For nPA := 1 to Len(aItensArr)
    cItBlq := GetAdvFVal("SB1","B1_MSBLQL",SB1->(XFILIAL()) + aItensArr[nPA,1], 1)
    If cItBlq != "1"
        if ((aItensArr[nPA,5] * aItensArr[nPA,3]) > (aItensArr[nPA,5] * aItensArr[nPA,4])) .OR. ( aItensArr[nPA,5] == 0 .AND. aItensArr[nPA,3] > 0 )
            if Len(_aCabArrSai) == 0
                AADD(_aCabArrSai, {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  , NIL} )
                AADD(_aCabArrSai, {"D3_TM"      , cTMSai                            , NIL} )
                AADD(_aCabArrSai, {"D3_CC"      , "        "                        , NIL} )
                AADD(_aCabArrSai, {"D3_EMISSAO" , DDATABASE                         , NIL} )
            EndIf
            IF aItensArr[nPA,5] == 0
                nCstRec := aItensArr[nPA,3]
            ELSE        
                nCstRec := ( (aItensArr[nPA,5] * aItensArr[nPA,3]) - (aItensArr[nPA,5] * aItensArr[nPA,4]) )
            ENDIF
            nCstRec := iif(nCstRec < 0, nCstRec * (-1), nCstRec)
            if nCstRec != 0 
                cUM := GetAdvFVal("SB1","B1_UM",SB1->(XFILIAL()) + aItensArr[nPA,1], 1)
                AADD(_aItmAvSai, {"D3_COD"      , aItensArr[nPA,1]  ,NIL} )
                AADD(_aItmAvSai, {"D3_UM"       , cUM               ,NIL} )
                AADD(_aItmAvSai, {"D3_QUANT"    , 0                 ,NIL} )
                AADD(_aItmAvSai, {"D3_LOCAL"    , aItensArr[nPA,2]  ,NIL} )
                AADD(_aItmAvSai, {"D3_CUSTO1"   , nCstRec           ,NIL} )
                aadd(_aTotItSai, _aItmAvSai) 
                _aItmAvSai := {}
            endif
        else
            if Len(_aCabArrEnt) == 0
                AADD(_aCabArrEnt, {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  , NIL} )
                AADD(_aCabArrEnt, {"D3_TM"      , cTMEnt                            , NIL} )
                AADD(_aCabArrEnt, {"D3_CC"      , "        "                        , NIL} )
                AADD(_aCabArrEnt, {"D3_EMISSAO" , DDATABASE                         , NIL} )
            EndIf
            IF aItensArr[nPA,5] == 0
                nCstRec := aItensArr[nPA,3]
            ELSE        
                nCstRec := ( (aItensArr[nPA,5] * aItensArr[nPA,4]) - (aItensArr[nPA,5] * aItensArr[nPA,3]) )
            ENDIF
            nCstRec := iif(nCstRec < 0, nCstRec * (-1), nCstRec)
            if nCstRec != 0
                cUM := GetAdvFVal("SB1","B1_UM",SB1->(XFILIAL()) + aItensArr[nPA,1], 1)
                AADD(_aItmAvEnt, {"D3_COD"      , aItensArr[nPA,1]  ,NIL} )
                AADD(_aItmAvEnt, {"D3_UM"       , cUM               ,NIL} )
                AADD(_aItmAvEnt, {"D3_QUANT"    , 0                 ,NIL} )
                AADD(_aItmAvEnt, {"D3_LOCAL"    , aItensArr[nPA,2]  ,NIL} )
                AADD(_aItmAvEnt, {"D3_CUSTO1"   , nCstRec           ,NIL} )
                aadd(_aTotItEnt, _aItmAvEnt) 
                _aItmAvEnt := {}
            endif
        Endif
    Endif
Next nPA

If Len(_aCabArrSai) > 0
    MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCabArrSai,_aTotItSai,3)
    If lMsErroAuto 
        Mostraerro() 
        DisarmTransaction() 
        //break
    EndIf
Endif

If Len(_aCabArrEnt) > 0
    MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCabArrEnt,_aTotItEnt,3)
    If lMsErroAuto 
        Mostraerro() 
        DisarmTransaction() 
        //break
    EndIf
Endif

if Len(_aCabArrEnt) > 0 .or. Len(_aCabArrSai) > 0 
    MsgAlert("Processamento encerrado... Ajustes proposts realizados.")
Endif

Return 
