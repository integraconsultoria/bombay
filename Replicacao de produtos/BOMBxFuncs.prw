#INCLUDE "TOTVS.CH"
#INCLUDE "ApWizard.ch"

//****************************************************************************> PERSONALIZACOES DO CADASTRO DE PRODUTOS <*****

/*/{protheus.doc} BOAtuProd
*******************************************************************************************
Funcao para atualizar o cadastro de produtos replicando para as demais filiais.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOAtuProd()
Local aArea     := {}
Local aAreaSB1  := {}
Local aAreaSB5  := {}
Local nRecSB1   := 0
Local aFiliais  := {}
Local cProduto  := SB1->B1_COD

aFiliais  := GetFiliais()
If Len(aFiliais) > 0
    aArea     := GetArea()
    aAreaSB1  := SB1->(GetArea())
    aAreaSB5  := SB5->(GetArea())
    nRecSB1   := SB1->(Recno())
        
    Processa({|a| ProcRepProd(cProduto,aFiliais) },"Aguarde","Replicando Cadastro do Produto com Filiais Selecionadas...")

    SB5->(RestArea(aAreaSB5))
    SB1->(RestArea(aAreaSB1))
    RestArea(aArea)

    If nRecSB1 > 0
        SB1->(dbGoto(nRecSB1))
    EndIf
EndIf

Return

/*/{protheus.doc} ProcRepProd
*******************************************************************************************
Funcao de processamento de replicacao de cadastro da sb1
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function ProcRepProd(cProduto,aFiliais)

AtuSB1(aFiliais)
SB5->(dbSetOrder(1))
If SB5->(dbSeek(xFilial()+cProduto))
    AtuSB5(aFiliais)
EndIf

Return

/*/{protheus.doc} AtuSB1
*******************************************************************************************
Funcao para atualizar o cadastro de produtos replicando para as demais filiais.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuSB1(aFiliais)
Local bCampo    := { |nCPO| Field(nCPO) }
Local nX        := 1
Local nY        := 1
Local _cFilAnt  := cFilAnt

dbSelectArea("SB1")
RegToMemory("SB1",.F.,.T.)     	

ProcRegua(Len(aFiliais))
For nX:=1 to Len(aFiliais)
    IncProc("")
    If Alltrim(aFiliais[nX,01]) <> _cFilAnt
        cFilAnt := aFiliais[nX,01]
        
        If SB1->(dbSeek(xFilial("SB1")+M->B1_COD))
            RecLock("SB1",.F.)
        Else
            RecLock("SB1",.T.)
        EndIf

        For nY := 1 To FCount()
            If "B1_FILIAL" == FieldName(nY)
                FieldPut(nY,xFilial("SB1"))    
            Else	
                FieldPut(nY,M->&(EVAL(bCampo,nY)))
            EndIf
        Next nY
        SB1->(MsUnLock())
    EndIf
Next nX

cFilAnt := _cFilAnt

Return

/*/{protheus.doc} AtuSB5
*******************************************************************************************
Funcao para atualizar o cadastro de produtos replicando para as demais filiais.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuSB5(aFiliais)
Local bCampo    := { |nCPO| Field(nCPO) }
Local nX        := 1
Local nY        := 1
Local _cFilAnt  := cFilAnt

dbSelectArea("SB5")
RegToMemory("SB5",.F.,.T.)     	

ProcRegua(Len(aFiliais))
For nX:=1 to Len(aFiliais)    
    IncProc("")
    If Alltrim(aFiliais[nX,01]) <> _cFilAnt
        cFilAnt := aFiliais[nX,01]
        
        If SB5->(dbSeek(xFilial("SB5")+M->B5_COD))
            RecLock("SB5",.F.)
        Else
            RecLock("SB5",.T.)
        EndIf

        For nY := 1 To FCount()
            If "B5_FILIAL" == FieldName(nY)
                FieldPut(nY,xFilial("SB5"))    
            Else	
                FieldPut(nY,M->&(EVAL(bCampo,nY)))
            EndIf
        Next nY
        SB5->(MsUnLock())
    EndIf
Next nX

cFilAnt := _cFilAnt

Return

/*/{protheus.doc} GetFiliais
*******************************************************************************************
FunÃ§Ã£o de retorno de filiais.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetFiliais()
Local aFiliais  := {}
Local aSelFils  := {}
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local oWizard	:= NIL
Local oPan01    := NIL
Local oPan02    := NIL
Local oSelFis   := NIL
Local oProduto  := NIL
Local oDescric  := NIL
Local lOk       := .F.
Local nX        := 1

Private oNo 	        := LoadBitmap( GetResources(), "LBNO" 	)
Private oOk 	        := LoadBitmap( GetResources(), "LBTIK"	)    
Private lRunDblClick    := .T.      
Private lChkTWiz 	    := .F.

SM0->(dbGotop())
Do While !SM0->(Eof())
    If  Alltrim(SM0->M0_CODIGO) == Alltrim(cEmpAnt) .And.                   ;
        Alltrim(SM0->M0_CODFIL) <> Alltrim(cFilAnt) .And.                   ;
        Ascan(aSelFils,{|x| Left(x[02],2) == Left(SM0->M0_CODFIL,2) }) == 0
        
        aAdd(aSelFils,{.F.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOMECOM})
    EndIf
    SM0->(dbSkip())
EndDo

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

DEFINE WIZARD oWizard 																		                                ;
        TITLE "Replicacao de Cadastro"										                                	            ;
                HEADER "Cadastro de Produtos" 														                        ;	
                MESSAGE "Selecione as Filiais para a Replicacao"														    ;
                TEXT "" PANEL															                                    ;
                NEXT 	{|| lOk := MsgYesNo("Confirma a Replicacao do Cadastro para as filiais selecionadas ?"), lOk } 		;
                FINISH 	{|| lOk := MsgYesNo("Confirma a Replicacao do Cadastro para as filiais selecionadas ?"), lOk }		; 		 	          	          	                            
        
            //->> Painel superior
            oPan01 := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:oDlg:oFont, .T., .T.,,Rgb(210,210,210),(oWizard:GetPanel(1):NCLIENTWIDTH)/2,25,.T.,.F. )
            oPan01:Align := CONTROL_ALIGN_TOP

            @ 002,002 GET oProduto VAR SB1->B1_COD  WHEN .F. SIZE 40,10 OF oPan01 PIXEL
			@ 014,002 Say "Produto"	    OF oPan01 PIXEL

            @ 002,045 GET oDescric VAR SB1->B1_DESC WHEN .F. SIZE 220,10 OF oPan01 PIXEL
			@ 014,045 Say "Descricao"	OF oPan01 PIXEL

            //->> Painel inferior
            oPan02 := TPanel():New(0,0,'',oWizard:GetPanel(1), oWizard:oDlg:oFont, .T., .T.,,,(oWizard:GetPanel(1):NCLIENTWIDTH)/2,((oWizard:GetPanel(1):NCLIENTHEIGHT)/2)-25,.F.,.T. )
            oPan02:Align := CONTROL_ALIGN_ALLCLIENT	

       		@ 000, 000 LISTBOX oSelFis FIELDS HEADER 	""								,;
					   								    "Filial"		    			,;
													    "Nome"							,;
													    "Grupo"							 ;
										COLSIZES 	5						    		,;
													25 							    	,;
													30 								    ,;
									 				30								    ;
								SIZE (oPan02:NWIDTH/2)-2,(oPan02:NHEIGHT/2)-2;
								ON DBLCLICK (If(!Empty(aSelFils[oSelFis:nAt,2]),aSelFils[oSelFis:nAt,1]:=!aSelFils[oSelFis:nAt,1],aSelFils[oSelFis:nAt,1]:=oSelFis[oSelFis:nAt,1]),If(!aSelFils[oSelFis:nAt,1],lChkTWiz := .F., ),oSelFis:Refresh(.f.)) OF oPan02 PIXEL
	
		oSelFis:SetArray(aSelFils)	
		oSelFis:bLine := {|| {If(aSelFils[oSelFis:nAt,1],oOK,oNO),aSelFils[oSelFis:nAt,2],aSelFils[oSelFis:nAt,3],aSelFils[oSelFis:nAt,4]}}    
		oSelFis:bRClicked 		:= { || AEVAL(aSelFils,{|x|x[1]:=!x[1]}), oSelFis:Refresh(.F.)}    	
		oSelFis:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aSelFils, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oSelFis:Refresh()}

    oWizard:OFINISH:CCAPTION := "&Replicar"
    oWizard:OFINISH:CTITLE 	 := "&Replicar"

ACTIVATE WIZARD oWizard CENTERED

If lOk
    For nX:=1 to Len(aSelFils)
        If aSelFils[nX,01]
            aAdd(aFiliais,{aSelFils[nX,02],aSelFils[nX,03]})
        EndIf
    Next nX
EndIf

Return aFiliais

/*/{protheus.doc} BONewCdPrd
*******************************************************************************************
FunÃ§Ã£o de geracao de codigos de produtos
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BONewCdPrd()
Local cCodigo       := ""
Local cSubCod       := ""
Local cSequencia    := ""
Local lOk           := .T.
Local aArea         := GetArea()
Local aAreaSB1      := SB1->(GetArea())

If lOk .And. Empty(M->B1_GRUPO)        
    lOk := .F.
EndIf
If lOk .And. Empty(M->B1_XCSGRP)        
    lOk := .F.
EndIf
If lOk    
    cSubCod := M->B1_GRUPO + "." + M->B1_XCSGRP + "."
    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+cSubCod,.T.))
    Do While SB1->B1_FILIAL == xFilial("SB1") .And. Left(SB1->B1_COD,Len(cSubCod)) == cSubCod
        cSequencia := SubStr(SB1->B1_COD,Len(cSubCod)+1,Tamsx3("B1_COD")[01]-Len(cSubCod))
        SB1->(dbSkip())
    EndDo
    cSequencia := Alltrim(cSequencia)
    If Empty(cSequencia)
        cSequencia := StrZero(1,4)
    Else
        cSequencia := Soma1(cSequencia)
    EndIf
    cCodigo += cSubCod + cSequencia
    Do While .T.    
        If !SB1->(dbSeeK(xFilial("SB1")+cCodigo))
            lOk := .T.
        Else
            lOk := .F.
        EndIf

        If lOk
            lOk := MayIUseCode("SB1"+xFilial("SB1")+cCodigo)
        EndIf

        If !lOk
            cSequencia := Soma1(cSequencia)
            cCodigo := cSubCod + cSequencia
        Else
            Exit
        EndIf    
    EndDo
    m->B1_COD := cCodigo
EndIf

SB1->(RestArea(aAreaSB1))
RestARea(aArea)

Return cCodigo

/*/{protheus.doc} BOAjsGatB1
*******************************************************************************************
Funcao para ajustes dos gatilhos do cadastro de produtos.
 
@author: Marcelo Celi Marques
@since: 21/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOAjsGatB1()
Local aSX7      := {} 
Local aEstrut	:= {}
Local i, j, nX

//->>CriaÃ§Ã£o dos Gatilhos
aEstrut:= {"X7_CAMPO"	,"X7_SEQUENC"	,"X7_REGRA"						,"X7_CDOMIN"	,"X7_TIPO"	,"X7_SEEK"	,"X7_ALIAS"	,"X7_ORDEM"	,"X7_CHAVE"					        	,"X7_PROPRI"	,"X7_CONDIC"                }
aAdd(aSX7,{'B1_GRUPO'	,'002'			,'U_BONewCdPrd()'	   			,'B1_COD'	    ,'P'		,'N'		,''	    	,1			,''	                                    ,'U'			,'!Empty(M->B1_GRUPO)'	    })
aAdd(aSX7,{'B1_XCSGRP'	,'002'			,'U_BONewCdPrd()'	   			,'B1_COD'	    ,'P'		,'N'		,''	    	,1			,''	                                    ,'U'			,'!Empty(M->B1_XCSGRP)'	    })

dbSelectArea("SX7")
dbSetOrder(1)
For i:= 1 To Len(aSX7)
	If !Empty(aSX7[i][1])
		If !dbSeek(PadR(aSX7[i,1],Len(SX7->X7_CAMPO)) +  PadR(aSX7[i,2],Len(SX7->X7_SEQUENC)) )
			RecLock("SX7",.T.)
		Else
			RecLock("SX7",.F.)
		EndIf	
		For j:=1 To Len(aSX7[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSX7[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()
	EndIf
Next i

SX3->(dbSetOrder(2))
For nX:=1 to Len(aSX7)
    If SX3->(dbSeek(aSX7[nX,01]))
        Reclock("SX3",.F.)
        SX3->X3_TRIGGER := "S"
        SX3->X3_WHEN    := "INCLUI"
        SX3->(MsUnlock())
    EndIf
Next nX

SX3->(dbSetOrder(2))
If SX3->(dbSeek("B1_COD"))
    Reclock("SX3",.F.)
    SX3->X3_WHEN    := ".F."
    SX3->X3_RELACAO := "U_BONewCdPrd()"
    SX3->(MsUnlock())
EndIf

Return

//****************************************************************************> PERSONALIZACOES DO FATURAMENTO <*****

/*/{protheus.doc} BOSF1BYSF2
*******************************************************************************************
Funcao para criacao de documentos de entrada a partir de documentos de saida, entre filiais
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOSF1BYSF2(_cDocument,_cSerie,_cCliente,_cLoja)
Local aArea     := GetArea()
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSM0  := SM0->(GetArea())
Local cFornece  := ""
Local cLoja     := ""
Local _cFilAnt  := cFilAnt
Local aCabec    := {}
Local aItem     := {}
Local aItens    := {}
Local lCriaSD1  := Alltrim(Upper(GetNewPar("BO_SF1SF2","S")))=="S"

If lCriaSD1
    SA1->(dbSetOrder(1))
    If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))
        SM0->(DbGotop())
        Do While !SM0->(Eof())
            If  SM0->M0_CODIGO == cEmpAnt  .And. ;
                SM0->M0_CODFIL <> cFilAnt  .And. ;
                SM0->M0_CGC == SA1->A1_CGC .And. ;
                !Empty(SM0->M0_CGC)

                SA2->(dbSetOrder(3))
                If SA2->(dbSeek(xFilial("SA2")+SM0->M0_CGC))
                    cFornece    := SA2->A2_COD
                    cLoja       := SA2->A2_LOJA
                    cFilAnt     := SM0->M0_CODFIL
                    Exit
                EndIf
            EndIf

            SM0->(dbSkip())
        EndDo
    EndIf

    If !Empty(cFornece)
        SA2->(dbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+cFornece+cLoja))

            aCabec	:= {{"F1_FILIAL"	,cFilAnt		    ,Nil},;		// Filial
                        {"F1_TIPO"		,SF2->F2_TIPO	    ,Nil},;		// Tipo da Nota Fiscal de Entrada
                        {"F1_FORMUL" 	,"N"    		    ,Nil},;		// Formulario
                        {"F1_DOC"		,SF2->F2_DOC	    ,Nil},;		// Numero da Nota Fiscal de Entrada
                        {"F1_SERIE"		,SF2->F2_SERIE	    ,Nil},;		// Serie da Nota Fiscal de Entrada
                        {"F1_FORNECE"	,SA2->A2_COD	    ,Nil},;		// Codigo do Fornecedor
                        {"F1_LOJA"		,SA2->A2_LOJA	    ,Nil},;		// Loja do Fornecedor
                        {"F1_EMISSAO"	,SF2->F2_EMISSAO    ,Nil},;		// Emissao da Nota Fiscal de Entrada
                        {"F1_EST"		,SA2->A2_EST	    ,Nil},;		// Estado do Fornecedor
                        {"F1_DTDIGIT"	,SF2->F2_EMISSAO    ,Nil},;		// Data de Digitacao da Nota Fiscal de Entrada
                        {"F1_ESPECIE"	,"SPED"			    ,Nil},;		// Especie da Nota Fiscal de Entrada
                        {"F1_COND"   	,SF2->F2_COND	    ,Nil},;		// Condicao do Fornecedor
                        {"F1_RECBMTO"	,SF2->F2_EMISSAO    ,Nil}}		// Data do Recebimento da Nota Fiscal de Entrada

            SD2->(dbSetOrder(3))
            SD2->(dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE) ))
            Do While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE)
                aItem	:= {}	
                aAdd(aItem,{"D1_FILIAL"	    ,cFilAnt				,Nil} )
                aAdd(aItem,{"D1_ITEM"		,SD2->D2_ITEM			,Nil} )
                aAdd(aItem,{"D1_COD"		,SD2->D2_COD	    	,Nil} )
                aAdd(aItem,{"D1_QUANT"		,SD2->D2_QUANT  		,Nil} )
                aAdd(aItem,{"D1_VUNIT"		,SD2->D2_PRCVEN	        ,Nil} )
                aAdd(aItem,{"D1_TOTAL"		,SD2->D2_TOTAL 	        ,Nil} )
                aAdd(aItem,{"D1_FORNECE"	,SA2->A2_COD			,Nil} )
                aAdd(aItem,{"D1_LOJA"		,SA2->A2_LOJA			,Nil} )
                aAdd(aItem,{"D1_DOC"		,SD2->D2_DOC	    	,Nil} )
                aAdd(aItem,{"D1_EMISSAO"	,SD2->D2_EMISSAO	    ,Nil} )
                aAdd(aItem,{"D1_DTDIGIT"	,SD2->D2_EMISSAO	    ,Nil} )
                aAdd(aItem,{"D1_GRUPO"		,SD2->D2_GRUPO	    	,Nil} )
                
                aAdd(aItens,aItem)
                SD2->(dbSkip())
            EndDo

            If Len(aCabec) > 0 .And. Len(aItens) > 0
                lMsErroAuto := .F.
                Begin Transaction
                    MsgRun("Gerando Pre-Nota de Entrada na Filial Destino...","Aguarde",{|| MSExecAuto({|x,y,z| MATA140(x,y,z) },aCabec,aItem,3) })            
                    If lMsErroAuto
                        If MsgYesNo("Ocorrem erros na GeraÃ§Ã£o da Pre-Nota de Entrada na Filial Destino Ocasionando a nao Geracao da Pre-Nota."+CRLF+"Deseja Visualizar os Erros Encontrados ?")
                            MostraErro()
                        EndIf
                        DisarmTransaction()
                    EndIf
                End Transaction
            EndIf

        EndIf
    EndIf

    SM0->(RestArea(aAreaSM0))
    SA2->(RestArea(aAreaSA2))
    SA1->(RestArea(aAreaSA1))
    SF1->(RestArea(aAreaSF1))
    SF2->(RestArea(aAreaSF2))
    RestArea(aArea)

    cFilAnt  := _cFilAnt
EndIf

Return

/*/{protheus.doc} BOReplPed
*******************************************************************************************
Funcao para a replicação de pedidos
 
@author: Marcelo Celi Marques
@since: 22/07/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOReplPed(_cDocument,_cSerie,_cCliente,_cLoja)
Local aArea     := GetArea()
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSM0  := SM0->(GetArea())
Local cFornece  := ""
Local cLoja     := ""
Local aCabec    := {}
Local aItem     := {}
Local aSC6      := {}
Local aSC7      := {}
Local lCriaSD1  := Alltrim(Upper(GetNewPar("BO_SF1SF2" ,"S")))=="S"
Local cFilProd  := Alltrim(Upper(GetNewPar("BO_FILPROD","0101")))
Local cCond     := Alltrim(Upper(GetNewPar("BO_CONDREP","001")))
Local cTesSaida := Alltrim(Upper(GetNewPar("BO_TSREP"  ,"501")))
Local cForProd  := ""
Local cCliProd  := ""
Local cLojaProd := ""
Local cPedCom   := ""
Local cPedVen   := ""
Local lContinua := .T.
Local cItem     := StrZero(1,Tamsx3("C6_ITEM")[01])
Local _cFilNew  := ""
Local _cFilAnt  := cFilAnt
Local nVlr2Unid := 0

//->> Marcelo Celi - 16/01/2021
Local cFilPV    := cFilAnt

//->> Marcelo Celi - 19/02/2021
Local nVlrUnit  := 0
Local nVlrTota  := 0
Local cTabCust  := PadR(GetNewPar("BO_TABCUST","022"),Tamsx3("DA1_CODTAB")[01])

Private lMsErroAuto := .F.

//->> Declaração de publicas que serao utilizadas na rotina
Public p__cUM  := ""
Public p__lUM  := .F.

If lCriaSD1 .And. cFilProd <> cFilAnt    
    Begin Transaction
        If lContinua .And. !Empty(cFilProd) 
            lContinua := .F.
            SM0->(DbGotop())
            Do While !SM0->(Eof())
                If  SM0->M0_CODIGO  == cEmpAnt  .And. ;                
                    Alltrim(SM0->M0_CODFIL)  == Alltrim(cFilProd)

                    SA2->(dbSetOrder(3))
                    If SA2->(dbSeek(xFilial("SA2")+SM0->M0_CGC))
                        cForProd    := SA2->A2_COD
                        cLojaProd   := SA2->A2_LOJA
                        _cFilNew    := SM0->M0_CODFIL
                        Exit
                    EndIf
                EndIf
                SM0->(dbSkip())
            EndDo
        
            SA2->(dbSetOrder(1))
            If SA2->(dbSeek(xFilial("SA2")+cForProd+cLojaProd))
                cPedCom := GetSXENum("SC7","C7_NUM")
                SC7->(dbSetOrder(1))
                While SC7->(dbSeek(xFilial("SC7")+cPedCom))
                    ConfirmSX8()
                    cPedCom := GetSXENum("SC7","C7_NUM")
                EndDo

                aCabec := {}
                //aAdd(aCabec,{"C7_NUM"       ,cPedCom        })
                aAdd(aCabec,{"C7_EMISSAO"   ,dDataBase      })
                aAdd(aCabec,{"C7_FORNECE"   ,SA2->A2_COD    })
                aAdd(aCabec,{"C7_LOJA"      ,SA2->A2_LOJA   })
                aAdd(aCabec,{"C7_COND"      ,cCond          })
                aAdd(aCabec,{"C7_CONTATO"   ,"AUTO"         })
                aAdd(aCabec,{"C7_FILENT"    ,cFilAnt        })

                SD2->(dbSetOrder(3))
                SD2->(dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE) ))
                Do While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE)
                    //->> Marcelo Celi - 10/01/2021
                    SB1->(dbSetOrder(1))
                    SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
                    
                    //->> Marcelo Celi - 20/07/2021
                    //nVlrUnit := u_BoGetVCust(cFilAnt,SB1->B1_COD)
                    DA1->(dbSetOrder(1))
                    If DA1->(dbSeek(xFilial("DA1")+cTabCust+SB1->B1_COD))
                        nVlrUnit := DA1->DA1_PRCVEN
                    EndIf
                    nVlrTota := Round( SD2->D2_QUANT * nVlrUnit,Tamsx3("D2_TOTAL")[02] )

                    aItem	:= {}	
                    aAdd(aItem,{"C7_FILIAL"	    ,cFilAnt				,Nil} )
                    aAdd(aItem,{"C7_PRODUTO"	,SD2->D2_COD	    	,Nil} )
                    aAdd(aItem,{"C7_QUANT"		,SD2->D2_QUANT  		,Nil} )
                    aAdd(aItem,{"C7_OPER"       , "01"   , NIL })   // FLAVIO 04/06/2021
                    aAdd(aItem,{"C7_VLDESC"     , 0   , NIL })   // FLAVIO 05/06/2021
                   
                    //->> Marcelo Celi - 19/02/2021
                    //aAdd(aItem,{"C7_PRECO"		,SD2->D2_PRCVEN	    ,Nil} )
                    //aAdd(aItem,{"C7_TOTAL"		,SD2->D2_TOTAL 	    ,Nil} )
                    aAdd(aItem,{"C7_PRECO"		,nVlrUnit	            ,Nil} )
                    aAdd(aItem,{"C7_TOTAL"		,nVlrTota  	            ,Nil} )                                
                    aAdd(aSC7,aItem)

                    aItem	:= {}	
                    //->> Marcelo Celi - 19/02/2021
                    //nVlr2Unid := Round(SD2->D2_PRCVEN,Tamsx3("C6_PRUNIT")[2])
                    nVlr2Unid := Round(nVlrUnit,Tamsx3("C6_PRUNIT")[2])
                    If SB1->B1_TIPCONV == "D"
                        nVlr2Unid := Round(nVlr2Unid / SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
                    Else
                        nVlr2Unid := Round(nVlr2Unid * SB1->B1_CONV,Tamsx3("C6_UNSVEN")[02])
                    EndIf

                    aAdd(aItem,{"C6_ITEM"	    ,cItem			    	,Nil} )
                    aAdd(aItem,{"C6_PRODUTO"	,SD2->D2_COD	    	,Nil} )
                    aAdd(aItem,{"C6_QTDVEN"		,SD2->D2_QUANT  		,Nil} )
                    //->> Marcelo Celi - 19/02/2021
                    //aAdd(aItem,{"C6_PRCVEN"		,SD2->D2_PRCVEN	    ,Nil} )
                    //aAdd(aItem,{"C6_PRUNIT"		,SD2->D2_PRCVEN     ,Nil} )
                    //aAdd(aItem,{"C6_VALOR"		,SD2->D2_TOTAL 	    ,Nil} )
                    aAdd(aItem,{"C6_PRCVEN"		,nVlrUnit               ,Nil} )
                    aAdd(aItem,{"C6_PRUNIT"		,nVlrUnit               ,Nil} )                                
                    aAdd(aItem,{"C6_VALOR"		,nVlrTota 	            ,Nil} )

                    //SF4->(dbSetOrder(1))
                    //If !SF4->(dbSeek(xFilial("SF4")+cTesSaida))
                    //    MsgAlert("TES de saida não cadastrada...")
                    //EndIf
                    aAdd(aItem,{"C6_TES"		,cTesSaida  	        ,Nil} )

                    //->> Marcelo Celi - 10/01/2021
                    aAdd(aItem,{"C6_DESCRI" ,SB1->B1_DESC 				,Nil} )
                    aAdd(aItem,{"C6_ENTREG" ,dDatabase  				,Nil} )
// MSG - INICIO
                    aAdd(aItem,{"C6_CLI"    , "015119"  			,Nil} ) // MSG
                    aAdd(aItem,{"C6_LOJA"   , "01"  				,Nil} ) // MGG
// MSG -FIM

                    //SAH->(dbSetOrder(1))
                    //If !SAH->(dbSeek(xFilial("SAH")+SB1->B1_UM))
                    //    MsgAlert("primeira unidade de medida não cadastrada...")
                    //EndIf
                    aAdd(aItem,{"C6_UM"     ,SB1->B1_UM					,Nil} )

                    aAdd(aItem,{"C6_CF"     ,SD2->D2_CF					,Nil} )
                    aAdd(aItem,{"C6_CLASFIS",SD2->D2_CLASFIS    		,Nil} )

                    //NNR->(dbSetOrder(1))
                    //If !NNR->(dbSeek(xFilial("NNR")+SB1->B1_LOCPAD))
                    //    MsgAlert("armazem padrao não cadastrado...")
                    //EndIf
                    aAdd(aItem,{"C6_LOCAL"  ,SB1->B1_LOCPAD				,Nil} )

                    //SAH->(dbSetOrder(1))
                    //If !SAH->(dbSeek(xFilial("SAH")+SB1->B1_SEGUM))
                    //    MsgAlert("segunda unidade de medida não cadastrada...")
                    //EndIf
                    aAdd(aItem,{"C6_SEGUM"  ,SB1->B1_SEGUM	            ,Nil} )

                    //If nVlr2Unid <= 0
                    //    MsgAlert("valor na segunda unidade de medida não cadastrada corretamente...")
                    //EndIf
                    aAdd(aItem,{"C6_UNSVEN" ,nVlr2Unid  	            ,Nil} )

                    cItem := Soma1(cItem)

                    aAdd(aSC6,aItem)                

                    SD2->(dbSkip())
                EndDo

                MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aSC7,3,.F.)
                If lMsErroAuto
                    lContinua := .F.
                    If MsgYesNo("Ocorreram erros na geração do pedido de compras da replicação entre filiais."+CRLF+"Deseja visualizar o erro ?")
                        MostraErro()
                    EndIf    
                Else
                    lContinua := .T.
                EndIf
            EndIf
        EndIf

        aItens := {}
        If lContinua
            //->> Marcelo Celi - 10/01/2021
            //cFilAnt := _cFilNew
            
            SM0->(DbGotop())
            Do While !SM0->(Eof())
                If  SM0->M0_CODIGO  == cEmpAnt  .And. ;                
                    Alltrim(SM0->M0_CODFIL) == Alltrim(cFilPV)

                    SA1->(dbSetOrder(3))
                    If SA1->(dbSeek(xFilial("SA1")+SM0->M0_CGC))
                        cCliProd    := SA1->A1_COD
                        cLojaProd   := SA1->A1_LOJA                    
                        Exit
                    EndIf
                EndIf
                SM0->(dbSkip())
            EndDo

            //->> Marcelo Celi - 10/01/2021            
            cFilAnt := cFilProd
            SM0->(dbSetOrder(1))
            SM0->(dbSeek(cEmpAnt+cFilAnt))

            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+cCliProd+cLojaProd))

                cPedVen := GetSXENum("SC6","C6_NUM")
                SC6->(dbSetOrder(1))
                While SC6->(dbSeek(xFilial("SC6")+cPedVen))
                    ConfirmSX8()
                    cPedVen := GetSXENum("SC6","C6_NUM")
                EndDo

                aCabec   := {}            
                aAdd(aCabec, {"C5_NUM"      , cPedVen,        Nil})
                aAdd(aCabec, {"C5_TIPO"     , "N",            Nil})
                aAdd(aCabec, {"C5_CLIENTE"  , SA1->A1_COD,    Nil})
                aAdd(aCabec, {"C5_LOJACLI"  , SA1->A1_LOJA,   Nil})
                aAdd(aCabec, {"C5_CLIENT"   , SA1->A1_COD,    Nil})
                aAdd(aCabec, {"C5_LOJAENT"  , SA1->A1_LOJA,   Nil})
                aAdd(aCabec, {"C5_TIPOCLI"  , SA1->A1_TIPO,   Nil})
// MSG INICIO
                aAdd(aCabec, {"C5_MOEDA"    , 1    ,   Nil})
                aAdd(aCabec, {"C5_TIPLIB"	,"1"		                        		,Nil})	//->> Tipo de Liberacao
                aAdd(aCabec, {"C5_DESCFI"	,0			                        		,Nil})	//->> Desconto Financeiro
                aAdd(aCabec, {"C5_FRETE"    ,0	    	                        		,Nil})	//->> Frete
                aAdd(aCabec, {"C5_DESPESA"	,0			                        		,Nil})	//->> Despesa
                aAdd(aCabec, {"C5_SEGURO"	,0		                        			,Nil})	//->> Seguro
                aAdd(aCabec, {"C5_FRETAUT"	,0		                        			,Nil})	//->> Frete Auto
                aAdd(aCabec, {"C5_MOEDA"    ,1			                        		,Nil})	//->> Moeda
                aAdd(aCabec, {"C5_DESC1"    ,0				                        	,Nil})	//->> Desconto                     
                aAdd(aCabec, {"C5_PESOL"    ,1				                        	,Nil})	//->> Desconto                     
                aAdd(aCabec, {"C5_PBRUTO"   ,1			                        		,Nil})	//->> Moeda
                aAdd(aCabec, {"C5_VOLUME1"  ,1				                        	,Nil})	//->> Desconto                     
                aAdd(aCabec, {"C5_DESCONT"  ,0				                        	,Nil})	//->> Desconto // Flavio 05/06/2021                
 // MSG FIM               
                SE4->(dbSetOrder(1))
                If !SE4->( dbSeek( xFilial("SE4") + cCond, .F. ) )
                    MsgAlert("condição de pagamento não cadastrada...")
                EndIf
                aAdd(aCabec, {"C5_CONDPAG", cCond,          Nil})
                
                //->> Marcelo Celi - 19/01/2021
                aAdd(aCabec, {"C5_XFLUXCF", "N",            Nil})
                
                //->> Marcelo Celi - 21/02/2021
                //MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aSC6, 3, .F.)
                MyMata410(aCabec, aSC6)
                
                If lMsErroAuto
                    lContinua := .F.
                    If MsgYesNo("Ocorreram erros na geração do pedido de vendas da replicação entre filiais."+CRLF+"Deseja visualizar o erro ?")
                        MostraErro()
                    EndIf    
                Else
                    lContinua := .T.
                EndIf
            EndIf
        EndIf

        If !lContinua
            DisarmTransaction()
        EndIf
    
    End Transaction

    SM0->(RestArea(aAreaSM0))
    SA2->(RestArea(aAreaSA2))
    SA1->(RestArea(aAreaSA1))
    SF1->(RestArea(aAreaSF1))
    SF2->(RestArea(aAreaSF2))
    RestArea(aArea)

    cFilAnt  := _cFilAnt
    //->> Marcelo Celi - 10/01/2021
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmpAnt+cFilAnt))

EndIf

Return

/*/{protheus.doc} BoTrfByNF
*******************************************************************************************
Funcao para gerar transferencia por uma nota fiscal
 
@author: Marcelo Celi Marques
@since: 19/02/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoTrfByNF()
Local aBoxParam := {}
Local cMsg		:= ""
Local oWizard	:= NIL

Private aRetParam	:= {}

cMsg := "Este Recurso Permite Gerar os pedidos de Transferencias a partir de Documentos de Entrada."+CRLF
cMsg += CRLF
cMsg += CRLF
cMsg += "Avançar para Continuar..."

AADD( aRetParam, Replicate(" ",Tamsx3("F2_DOC")[01])   )
AADD( aRetParam, Replicate("Z",Tamsx3("F2_DOC")[01])   )
AADD( aRetParam, Replicate(" ",Tamsx3("F2_SERIE")[01]) )

AADD( aBoxParam,{1,"Doc Saida de"	, aRetParam[01]		,""		,""	,"SF2"	,".T."	,(Tamsx3("F2_DOC")[01])*4	,.F.})
AADD( aBoxParam,{1,"Doc Saida ate"	, aRetParam[02]		,""		,""	,"SF2"	,".T."	,(Tamsx3("F2_DOC")[01])*4	,.F.})
AADD( aBoxParam,{1,"Serie"		    , aRetParam[03]		,""		,""	,""		,".T."	,(Tamsx3("F2_SERIE")[01])*4	,.T.})

DEFINE WIZARD oWizard 												;
		TITLE "Transferencias entre Filiais"						;
          	HEADER "Documentos de Saida"							;	
          	MESSAGE ""												;
         	TEXT cMsg PANEL											;
          	NEXT 	{|| .T. } 										;
          	FINISH 	{|| .T. }										; 
          	          	                            
   	CREATE PANEL oWizard 				 							;				
          	HEADER "Documentos de Saida"					 		;
          	MESSAGE "Informe os Dados para Filtrar os Documentos de Saida." PANEL			;          	
          	NEXT 	{|| GetDoctos(aRetParam) }				        ;
          	FINISH 	{|| GetDoctos(aRetParam) }				        ;
          	PANEL
   		Parambox(aBoxParam,"Parametrização",@aRetParam,,,,,,oWizard:GetPanel(2),,.F.,.F.)  		                   

ACTIVATE WIZARD oWizard CENTERED
	
Return

/*/{protheus.doc} GetDoctos
*******************************************************************************************
Funcao para extrair os documentos para geração das transferencias
 
@author: Marcelo Celi Marques
@since: 19/02/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function GetDoctos(aParam)
Local lRet      := .F.
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aNotas    := {}
Local nX        := 1

cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.R_E_C_N_O_ AS RECSF2 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"   +CRLF
cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"                                                         +CRLF
cQuery += "   AND SF2.F2_DOC BETWEEN '"+aParam[01]+"' AND '"+aParam[02]+"'"                                     +CRLF
cQuery += "   AND SF2.F2_SERIE   = '"+aParam[03]+"'"                                                            +CRLF
cQuery += "   AND SF2.D_E_L_E_T_ = ' '"                                                                         +CRLF
cQuery += " ORDER BY F2_DOC, F2_SERIE"                                                                          +CRLF

MsgRun("Filtrando Documentos...",,{ || DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.) })
Do While (cAlias)->(!Eof())
    SF2->(dbGoto((cAlias)->RECSF2))
    aAdd(aNotas,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->(Recno())})
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

If Len(aNotas) > 0
    If MsgYesNo("Confirma a Geração das Transferências?")
        lRet := .T.
        For nX:=1 to Len(aNotas)
            SF2->(dbGoto(aNotas[nX,05]))
            MsgRun("Gerando Transferências ["+Alltrim(Str(nX))+"/"+Alltrim(Str(Len(aNotas)))+"]",,{ || u_BOReplPed(aNotas[nX,01],aNotas[nX,02],aNotas[nX,03],aNotas[nX,04]) })
        Next nX
    EndIf
Else
    lRet := .F.
    MsgAlert("Nenhum Documento filtrado para a realização de Transferências...")
EndIf

Return lRet

/*/{protheus.doc} MyMata410
*******************************************************************************************
Cria por reclock os registros do pedido de vendas.
 
@author: Marcelo Celi Marques
@since: 21/02/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
Static Function MyMata410(aCabec, aSC6)
Local nX        := 1
Local nY        := 1
Local cTes      := ""
Local cTpOper   := Alltrim(Upper(GetNewPar("BO_OPERTRS"  ,"01")))
Local nPCliente := Ascan(aCabec,{|x| Alltrim(x[01]) == "C5_CLIENTE" })
Local nPLoja    := Ascan(aCabec,{|x| Alltrim(x[01]) == "C5_LOJACLI" })
Local nPProduto := 0
Local cCliente  := ""
Local cLoja     := ""
Local cProduto  := ""
Local cCfop     := ""
Local cClasfis  := ""

If nPCliente > 0 .And. nPLoja > 0
    cCliente := aCabec[nPCliente,02]
    cLoja    := aCabec[nPLoja,02]

    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
EndIf

DBSelectArea("SC5")
If Reclock("SC5",.T.)
    SC5->C5_FILIAL := xFilial("SC5")
    For nX:=1 to Len(aCabec)
        SC5->&(Alltrim(aCabec[nX,01])) := aCabec[nX,02]
    Next nX
    SC5->(MsUnlock())
Else
    ALERT( "ERRO ao tentar gravar o SC5 do PEDIDO ! " )
    Return()
EndIf

For nX:=1 to Len(aSC6)
    cProduto := ""
    nPProduto:= Ascan(aSC6[nX],{|x| Alltrim(x[01])=="C6_PRODUTO"})
    If nPProduto > 0
        cProduto := aSC6[nX,nPProduto,02]
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")+cProduto))
    EndIf
    cTes := MaTESInt(2,cTpOper,cCliente,cLoja,"C",cProduto)

    DBSelectArea("SC6")
    Reclock("SC6",.T.)
    SC6->C6_FILIAL := xFilial("SC6")
    SC6->C6_NUM := SC5->C5_NUM
    For nY:=1 to Len(aSC6[nX])    
        If Alltrim(aSC6[nX,nY,01]) == "C6_TES"
            If Empty(cTes)
                cTes := aSC6[nX,nY,02]            
            EndIf
            SC6->&(Alltrim(aSC6[nX,nY,01])) := cTes
            SF4->(dbSetOrder(1))
            If SF4->(dbSeek(xFilial("SF4")+cTes))                
                SC6->C6_CODLAN  := SF4->F4_CODLAN
            EndIf
        ElseIf Alltrim(aSC6[nX,nY,01]) == "C6_CF"        
            cCfop := GetCfop(cTes)
            SC6->&(Alltrim(aSC6[nX,nY,01])) := cCfop
        ElseIf Alltrim(aSC6[nX,nY,01]) == "C6_CLASFIS"        
            cClasfis := SB1->B1_ORIGEM + SF4->F4_SITTRIB
            SC6->&(Alltrim(aSC6[nX,nY,01])) := cClasfis
        Else
            SC6->&(Alltrim(aSC6[nX,nY,01])) := aSC6[nX,nY,02]
        EndIf
    Next nY
    SC6->(MsUnlock())
Next nX

Return

/*/{protheus.doc} GetCfop
*******************************************************************************************
Retorna o cfop
 
@author: Marcelo Celi Marques
@since: 22/02/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetCfop(cTes)
Local aDadosCfo := {}
Local cCfop 	:= ""
Local aArea		:= GetArea()

SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4")+cTes))

Aadd(aDadosCfo,{"OPERNF","S"})
Aadd(aDadosCfo,{"TPCLIFOR","N"})
Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
Aadd(aDadosCfo,{"INSCR", SA1->A1_INSCR})
cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
RestArea(aArea)

Return cCfop
