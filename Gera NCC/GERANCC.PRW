#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

USER FUNCTION GERANCC()

    If MSGYESNO( "Confirma a GERA��O ", "NCC")
        Processa( { || FuncPROC() }, "Gerando NCC, AGUARDE ... " )
    Endif

Return
//comentario
//comentario 2
STATIC FUNCTION FuncPROC()

LOCAL cQry  , nX
LOCAL cAliasSF2 := GetNextAlias()


    cQry    := " "
    cQry    += " SELECT  F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DUPL, F2_TIPO, SF2.F2_VALMERC, SF2.F2_VALFAT "
    cQry    += " , SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VALOR, SE1.E1_TIPO "
    cQry    += " FROM " + RETSqlName("SF2") + " SF2 "
    cQry    += " LEFT JOIN " + RETSqlName("SE1") + " SE1 ON SE1.E1_FILIAL = SF2.F2_FILIAL AND SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.D_E_L_E_T_ = ' ' "
    cQry    += " WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
    cQry    += " AND SF2.F2_TIPO = 'D' "
    cQry    += " AND SF2.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSF2,.T.,.T.)

	ProcRegua( RecCount() )

    If (cAliasSF2)->(EOF())
        Alert( "NENHUM REGISTRO ENCONTRADO")
        Return(.f.)
    Else
   
        While (cAliasSF2)->( !EOF() )

            incproc( "PROCESSANDO " +  (cAliasSF2)->F2_SERIE + "-" + (cAliasSF2)->F2_DOC ) 

            cTitPref    := (cAliasSF2)->F2_SERIE
            cTitNum     := (cAliasSF2)->F2_DUPL
            cTitCli     := (cAliasSF2)->F2_CLIENTE
            cTitLoj     := (cAliasSF2)->F2_LOJA    
            nValor      := (cAliasSF2)->F2_VALFAT
            cNatLoc     := "3001006   "

                aFin040 := {}

                AADD( aFin040, {"E1_FILIAL"		,	xFilial("SE1")			, Nil } )
                AADD( aFin040, {"E1_PREFIXO"	,	(cAliasSF2)->F2_SERIE	, Nil } )
                AADD( aFin040, {"E1_NUM"		,	(cAliasSF2)->F2_DOC     , Nil } )
                AADD( aFin040, {"E1_TIPO"		,	'NCC'		            , Nil } )
                AADD( aFin040, {"E1_NATUREZ"	,	cNatLoc					, Nil } )
                AADD( aFin040, {"E1_EMISSAO"	,	StoD( (cAliasSF2)->F2_EMISSAO )            ,Nil})
                AADD( aFin040, {"E1_CLIENTE"	,	(cAliasSF2)->F2_CLIENTE			    ,Nil})
                AADD( aFin040, {"E1_LOJA"		,	(cAliasSF2)->F2_LOJA			    ,Nil})
                AADD( aFin040, {"E1_VALOR"		,	ROUND( (cAliasSF2)->F2_VALFAT, TAMSX3("E1_VALOR")[2] )   ,Nil})		
                AADD( aFin040, {"E1_VLRREAL"	,	ROUND( (cAliasSF2)->F2_VALFAT, TAMSX3("E1_VALOR")[2] ) ,Nil})					
                AADD( aFin040, {"E1_VENCTO"		,	StoD( (cAliasSF2)->F2_EMISSAO ),Nil})

                //Assinatura de vari�veis que controlar�o a inser��o autom�tica da RA;
                lMsErroAuto := .F.
                lMsHelpAuto	:= .T.
                lAutoErrNoFile := .T.         
                

                //Invocando rotina autom�tica para cria��o ;
                MSExecAuto({|x,y| Fina040(x,y)}, aFin040, 3)
                        

                //Quando houver erros, exib�-los em tela;    
                If lMsErroAuto
                    aErro := GetAutoGRLog()
                    cErro := ''
                    _nlen := len(aErro)
                                        
                    For nX := 1 To Len(aErro)                          	
                        cErro += aErro[nX] + Chr(13)+Chr(10)
                    Next nX                             
                    
                    conout ('ERRO AO CADASTRAR TITULO'+CHR(13)+CHR(10)+cErro)
                    U_EMAIL('xxx', 'ERRO CADASTRO CLIENTE', 'ERRO AO CADASTRAR TITULO'+CHR(13)+CHR(10)+cErro)

                    msgStop('ERRO AO CADASTRAR TITULO\r\n' + cErro)
                    Return(.F.)
                else
                    alert("OK")
                Endif

                (cAliasSF2)->( DBSkip() )

        EndDo

    Endif

    If SELECT( (cAliasSF2) ) > 0
        DBSelectArea( (cAliasSF2) )
        DBCloseArea()
    EndIf

Return()
