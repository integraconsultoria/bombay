#Include "protheus.ch"

/*/{Protheus.doc} M460FIM
//TODO Descrição auto-gerada.
@author Pedro Lima
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M460FIM()
//Local lRet		:= .T.
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aAreaSF6 := SF6->(GetArea())
Local aAreaSE2 := SE2->(GetArea())
Local cSeekSD2	:= SF2->( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )

If Findfunction("U_BOSF1BYSF2")
	U_BOSF1BYSF2(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
EndIf

//->> Marcelo Celi - 14/03/2022
If SF2->(Fieldpos("F2_XORIGEM"))>0 .And. SC5->(Fieldpos("C5_XORIGEM"))>0
	RecLock("SF2",.F.)
	SF2->F2_XORIGEM := SC5->C5_XORIGEM
	SF2->(MsUnlock())
EndIf
If SF2->(Fieldpos("F2_XIDINTG"))>0 .And. SC5->(Fieldpos("C5_XIDINTG"))>0
	RecLock("SF2",.F.)
	SF2->F2_XIDINTG := SC5->C5_XIDINTG
	SF2->(MsUnlock())
EndIf

SD2->(dbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If SD2->( dbSeek(cSeekSD2) )
	While SD2->( ! Eof()  .And. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == cSeekSD2 )
		SD2->( RecLock("SD2",.F.) )
		SD2->D2_QTSEGUM := ROUND(SD2->D2_QTSEGUM,0) // CEILING(SD2->D2_QTSEGUM)
		SD2->( MsUnlock() )
		SD2->( dbSkip() )				
	End
Endif

//Luis - 14/10/2022 gravação do numero da nota de origem nos títulos DIFAL
cquery := " "
 cquery += " SELECT SUBSTRING(F6_NUMERO,1,3) AS PREFIXO, SUBSTRING(F6_NUMERO,4,9) AS NUM, F6_CLIFOR,F6_LOJA,F6_DOC,F6_SERIE,F6_DTARREC "
 cquery += " from "+retsqlname("SF6")
 cquery += " where F6_DOC = '"+SF2->F2_DOC+ "'"
 cquery += " AND F6_SERIE = '"+SF2->F2_SERIE+ "'"
 cquery += " AND F6_CLIFOR = '"+SF2->F2_CLIENTE+ "'"
 cquery += " AND F6_LOJA = '"+SF2->F2_LOJA+ "'"
 cquery += " AND "+retsqlname("SF6")+".D_E_L_E_T_ <> '*' "
 
  cQuery := ChangeQuery(cQuery)
   	
   		
	if select("TRB")>0
		TRB->(DBCLOSEAREA())
	endif


	dbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

IF TRB->( !EOF () )

		dbSelectArea("TRB")
		dbGoTop()
		While TRB->(!Eof())
		   DBSELECTAREA("SE2")
		   DBGOTOP()
		   DBSETORDER(1)
			IF DBSEEK(xfilial("SE2")+TRB->PREFIXO+TRB->NUM+"  "+"TX ")
				IF stod(TRB->F6_DTARREC) == SE2->E2_EMISSAO
					RECLOCK("SE2",.F.)
						SE2->E2_XNFORI := TRB->F6_DOC +"  " + TRB->F6_SERIE
					MSUNLOCK()
				ENDIF
			ENDIF
			DBSELECTAREA("TRB")
			DBSKIP()
			ENDDO
ENDIF

	if select("TRB")>0
		TRB->(DBCLOSEAREA())
	endif

RestArea(aAreaSF2)	
RestArea(aAreaSD2)
RestArea(aAreaSF6)
RestArea(aAreaSE2)





Return

