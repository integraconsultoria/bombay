#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "apwizard.ch"

Static Tb_Ferra := ""
Static Tb_Ecomm := ""
Static Tb_Conex := ""
Static Tb_Produ := ""
Static Tb_Estru := ""
Static Tb_IDS   := ""
Static Tb_Monit := ""
Static Tb_ChMon := ""
Static Tb_LgMon := ""
Static Tb_ThMon := ""
Static Tb_Depar := ""
Static Tb_Categ := ""
Static Tb_Marca := ""
Static Tb_Fabri := ""
Static Tb_Canal := ""
Static Tb_TbPrc := ""
Static Tb_TbSta := ""
Static Tb_CondP := ""
Static Tb_Transp:= ""
Static Tb_Voucher:=""

Static FilEcomm := ""
Static Armazem  := ""

Static POSIC_STRU  	:= 0
Static nCorSelSTRU	:= Rgb(255,201,14)

Static POSIC_IDS  	:= 0
Static nCorSelIDS	:= Rgb(205,151,14)

Static POSIC_CAN  	:= 0
Static nCorSelCAN	:= Rgb(91,181,247)

/*/{protheus.doc} MAPrdEcomm
*******************************************************************************************
Cadastro de Produtos do e-Commerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAPrdEcomm()
Private aRotina 	:= MenuDef()
Private cCadastro 	:="Catalogo de Produtos do e-Commerce"

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    //u_MaCpyImgEc()
    (Tb_Produ)->(dbSetOrder(5))
    mBrowse( 6, 1,22,75,Tb_Produ,,,,,,,,,,,,.F.,.F.)
EndIf

Return

/*/{protheus.doc} MenuDef
*******************************************************************************************
Menu do cadastro de produtos
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  	,0,1,0	,.F.},;
					 {"Visualizar"	, "u_MAMPRDECO"	,0,2,0	,NIL},;
					 {"Incluir"	    , "u_MAMPRDECO"	,0,3,0	,NIL},;
                     {"Alterar"	    , "u_MAMPRDECO"	,0,4,0	,NIL} }                     
Return aRotina

/*/{protheus.doc} MAMPRDECO
*******************************************************************************************
Rotina de manutenção do cadastro do ecommerce
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MAMPRDECO(cAlias,nReg,nOpc)
Local oDlg          := NIL
Local oPanel        := NIL
Local oPanEsq       := NIL
Local oPanCen       := NIL
Local oPanDir       := NIL
Local oPanSupD      := NIL
Local oPanBSupD     := NIL
Local oBoxBSupD     := NIL
Local oPanCenD      := NIL
Local oPanBCenD     := NIL
Local oBoxBCenD     := NIL
Local oPanInfD      := NIL
Local oPanBInfD     := NIL
Local oBoxBInfD     := NIL
Local aSize	   		:= MsAdvSize()
Local lEdita        := nOpc == 3 .Or. nOpc == 4
Local aCposCatal    := {}
Local aCampos       := {}
Local aStruct       := {}
Local nX            := 1
Local nY            := 1
Local aButtons      := {}
Local aColsEst      := {}
Local aHeadEst      := {}
Local aColsIDS      := {}
Local aHeadIDS      := {}
Local aHeadCan      := {}
Local aColsCan      := {}
Local aColsTmp      := {}
Local nModelo		:= 1        
Local lF3			:= .F.
Local lMemoria 		:= .T.
Local lColumn  		:= .F.
Local caTela 		:= ""
Local lNoFolder		:= .T.
Local lProperty		:= .F.
Local aCataObrig    := {}
Local aEstrObrig    := {}
Local aEstrutura    := {}
Local aCpDPIDS      := {}
Local bCampo        := { |nCPO| Field(nCPO) }
Local lOk           := .F.
Local nOpProd       := 3
Local lEdtEstrut    := .F.
Local cEdtIDS       := ""
Local nVlrTab       := 0
Local nLinIniBot    := 0
Local oBtMarc       := NIL
Local oBtDesMarc    := NIL
//->> Marcelo Celi - 26/03/2022
Local lPrimeiro     := .T.

Private oEstrutura  := NIL
Private oIDS        := NIL
Private oCanal      := NIL
Private lProdKit    := .F.
Private cImgSel     := "ngcheckok"
Private cImgNoSel   := "ngcheckno"

//->> Marcelo Celi - 26/03/2022
Private _nPPrcPad   := 0
Private _nPPrcPol   := 0
Private _nPProd     := 0

If nOpc == 3
    nOpProd := Aviso( "Catálogo de SKU no e-Commerce", "Informe o tipo de SKU que deseja criar:" , {"SKU Produto","SKU Kit","Cancelar"}, 2)
    If nOpProd == 1
        lProdKit := .F.
        lEdtEstrut := .F.
    ElseIf nOpProd == 2
        lProdKit := .T.
        lEdtEstrut := .T.
    EndIf
Else
    lEdtEstrut := .F.
EndIf

If (nOpc==3 .And. (nOpProd == 1 .Or. nOpProd == 2)) .Or. (nOpc<>3)
    //->> Campos do Enchoice
    aAdd(aCposCatal,"NOUSER")
    aCampos := FWSX3Util():GetAllFields(Tb_Produ,.T./*lVirtual*/)
    For nX:=1 to Len(aCampos)
        If !("_BITMAP" $ Alltrim(Upper(aCampos[nX])))
            aAdd(aCposCatal,aCampos[nX])
            If X3Obrigat(aCampos[nX])
                aAdd(aCataObrig,{aCampos[nX],(Tb_Produ)->(RetTitle(aCampos[nX]))})
            EndIf
        EndIf
    Next nX    

    //->> Campos da Estrutura
    aCampos := FWSX3Util():GetAllFields(Tb_Estru,.T./*lVirtual*/)
    For nX:=1 to Len(aCampos)
        If  !("_BITMAP" $ Alltrim(Upper(aCampos[nX]))) .And. ; 
            !("_FILIAL" $ Alltrim(Upper(aCampos[nX]))) .And. ; 
            !("_SKU"    $ Alltrim(Upper(aCampos[nX]))) 

            aStruct := FWSX3Util():GetFieldStruct(aCampos[nX])
            Aadd(aHeadEst,{(Tb_Estru)->(RetTitle(aCampos[nX]))                       /*TITULO*/      ,; // 01 
                        aCampos[nX]                                                  /*CAMPO*/       ,; // 02 
                        PesqPict(Tb_Estru,aCampos[nX])                               /*PICTURE*/     ,; // 03 
                        aStruct[03]                                                  /*TAMANHO*/     ,; // 04 
                        aStruct[04]                                                  /*DECIMAL*/     ,; // 05 
                        Posicione("SX3",2,aCampos[nX],"X3_VALID")                    /*VALIDAÇÃO*/   ,; // 06 
                        ""                                                           /*USADO*/       ,; // 07 
                        aStruct[02]                                                  /*TIPO*/        ,; // 08 
                        Posicione("SX3",2,aCampos[nX],"X3_F3")                       /*F3*/          ,; // 09 
                        Posicione("SX3",2,aCampos[nX],"X3_CONTEXT")                  /*CONTEXT*/     ,; // 10 
                        Posicione("SX3",2,aCampos[nX],"X3_CBOX")                     /*CBOX*/        ,; // 11 
                        Nil                                                                          ,; // 12 
                        Nil                                                                          ,; // 13 
                        If(lEdtEstrut,Posicione("SX3",2,aCampos[nX],"X3_VISUAL"),"V")/*VISUAL*/      ,; // 14 
                        Posicione("SX3",2,aCampos[nX],"X3_ORDEM")                    /*X3_ORDEM*/    }) // 15

            If X3Obrigat(aCampos[nX])
                aAdd(aEstrObrig,{aCampos[nX],(Tb_Estru)->(RetTitle(aCampos[nX]))})
            EndIf

        EndIf
    Next nX

    //->>Marcelo Celi - 26/03/2022
    _nPProd := Ascan(aHeadEst,{|x| Alltrim(x[02]) == Tb_Estru+"_COD" })

    Aadd(aHeadEst,{"Prc Padrao"  /*TITULO*/,"PRCPAD"/*CAMPO*/,"@E 999,999,999,999.99"/*PICTURE*/,14/*TAMANHO*/,2/*DECIMAL*/,""/*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/,"80"/*X3_ORDEM*/})
    _nPPrcPad := Len(aHeadEst)

    Aadd(aHeadEst,{"Prc Politica"/*TITULO*/,"PRCPOL"/*CAMPO*/,"@E 999,999,999,999.99"/*PICTURE*/,14/*TAMANHO*/,2/*DECIMAL*/,""/*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/,"81"/*X3_ORDEM*/})
    _nPPrcPol := Len(aHeadEst)

    aHeadEst := aSort(aHeadEst,,,{|x,y| x[15] < y[15] })

    //->> Campos dos IDs    
    aCampos := FWSX3Util():GetAllFields(Tb_IDS,.T./*lVirtual*/)
    For nX:=1 to Len(aCampos)
        If  !("_BITMAP" $ Alltrim(Upper(aCampos[nX]))) .And. ; 
            !("_FILIAL" $ Alltrim(Upper(aCampos[nX]))) .And. ; 
            !("_TIPO"   $ Alltrim(Upper(aCampos[nX]))) .And. ; 
            !("_CHPROT" $ Alltrim(Upper(aCampos[nX]))) 

            aStruct := FWSX3Util():GetFieldStruct(aCampos[nX])            
            cEdtIDS := If(lEdita,Posicione("SX3",2,aCampos[nX],"X3_VISUAL"),"V")
            If Alltrim(Upper(aCampos[nX])) == Alltrim(Upper(Tb_IDS+"_PCDESC"))
                If lEdita
                    cEdtIDS := "A"
                EndIf
            EndIf            
            
            Aadd(aHeadIDS,{(Tb_IDS)->(RetTitle(aCampos[nX]))                         /*TITULO*/      ,; // 01 
                        aCampos[nX]                                                  /*CAMPO*/       ,; // 02 
                        PesqPict(Tb_IDS,aCampos[nX])                                 /*PICTURE*/     ,; // 03 
                        aStruct[03]                                                  /*TAMANHO*/     ,; // 04 
                        aStruct[04]                                                  /*DECIMAL*/     ,; // 05 
                        Posicione("SX3",2,aCampos[nX],"X3_VALID")                    /*VALIDAÇÃO*/   ,; // 06 
                        ""                                                           /*USADO*/       ,; // 07 
                        aStruct[02]                                                  /*TIPO*/        ,; // 08 
                        Posicione("SX3",2,aCampos[nX],"X3_F3")                       /*F3*/          ,; // 09 
                        Posicione("SX3",2,aCampos[nX],"X3_CONTEXT")                  /*CONTEXT*/     ,; // 10 
                        Posicione("SX3",2,aCampos[nX],"X3_CBOX")                     /*CBOX*/        ,; // 11 
                        Nil                                                                          ,; // 12 
                        Nil                                                                          ,; // 13 
                        cEdtIDS                                                      /*VISUAL*/      ,; // 14 
                        Posicione("SX3",2,aCampos[nX],"X3_ORDEM")                    /*X3_ORDEM*/    }) // 15
        EndIf
    Next nX
    aHeadIDS := aSort(aHeadIDS,,,{|x,y| x[15] < y[15] })

    //->> Campos dos Canais
    Aadd(aHeadCan,{""           /*TITULO*/,"MARCA" /*CAMPO*/,"@BMP"               /*PICTURE*/,02                            /*TAMANHO*/,00                            /*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"A"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
    Aadd(aHeadCan,{"Tecnologia" /*TITULO*/,"ECOMME"/*CAMPO*/,"@!"                 /*PICTURE*/,Tamsx3(Tb_Canal+"_ECOMME")[01]/*TAMANHO*/,Tamsx3(Tb_Canal+"_ECOMME")[02]/*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
    Aadd(aHeadCan,{"Codigo"     /*TITULO*/,"CODIGO"/*CAMPO*/,"@!"                 /*PICTURE*/,Tamsx3(Tb_Canal+"_CODIGO")[01]/*TAMANHO*/,Tamsx3(Tb_Canal+"_CODIGO")[02]/*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
    Aadd(aHeadCan,{"Descrição"  /*TITULO*/,"DESCRI"/*CAMPO*/,"@!"                 /*PICTURE*/,Tamsx3(Tb_Canal+"_DESCRI")[01]/*TAMANHO*/,Tamsx3(Tb_Canal+"_DESCRI")[02]/*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
    Aadd(aHeadCan,{"Tab Preço"  /*TITULO*/,"TABELA"/*CAMPO*/,"@!"                 /*PICTURE*/,Tamsx3(Tb_Canal+"_TABPRC")[01]/*TAMANHO*/,Tamsx3(Tb_Canal+"_TABPRC")[02]/*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"C"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})
    Aadd(aHeadCan,{"Valor"      /*TITULO*/,"VALOR" /*CAMPO*/,"@E 9,999,999,999.99"/*PICTURE*/,12                            /*TAMANHO*/,02                            /*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})    
    Aadd(aHeadCan,{"Desconto"   /*TITULO*/,"DESCON"/*CAMPO*/,"@E 999.99"          /*PICTURE*/,05                            /*TAMANHO*/,02                            /*DECIMAL*/,"u_MaPrdVldPC()"/*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"A"/*VISUAL*/})
    Aadd(aHeadCan,{"Preço Final"/*TITULO*/,"FINAL" /*CAMPO*/,"@E 9,999,999,999.99"/*PICTURE*/,12                            /*TAMANHO*/,02                            /*DECIMAL*/,""              /*VALIDAÇÃO*/,""/*USADO*/,"N"/*TIPO*/,""/*F3*/,"V"/*CONTEXT*/,""/*CBOX*/,Nil,Nil,"V"/*VISUAL*/})

    If nOpc == 3 
        RegToMemory(cAlias, .T.)
        If nOpProd == 1
            m->&(Tb_Produ+"_TIPO") := "P"
            lEdtEstrut := .F.
        ElseIf nOpProd == 2
            m->&(Tb_Produ+"_TIPO") := "K"
            lEdtEstrut := .T.
            m->&(Tb_Produ+"_SKU") := GetNewCdKit()
        EndIf

        //->> Marcelo Celi - 26/03/2022
        lPrimeiro := .T.
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                //->> De/Para dos IDs
                aCpDPIDS := {}
                aAdd(aCpDPIDS,{Tb_IDS+"_ECOM"       , (Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO" })            
                aAdd(aCpDPIDS,{Tb_IDS+"_TABPRC"     , (Tb_Ecomm)+"->"+Tb_Ecomm+"_TABPRC" })
                aAdd(aCpDPIDS,{Tb_IDS+"_PRCVEN"     , "nValor"                           })

                aColsTmp := {}            
                nValor := u_MaGetVlrEc(NIL,Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO")),aEstrutura)

                //->> Marcelo Celi - 26/03/2022
                If lPrimeiro
                    AtualVisPrc((Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC"),_nPPrcPad,_nPProd,@aColsEst,@oEstrutura)
                EndIf
                lPrimeiro := .F.

                For nX:=1 to Len(aHeadIDS)
                    nPos := AScan(aCpDPIDS,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(aHeadIDS[nX,02]))})
                    If nPos > 0
                        aAdd(aColsTmp,&(aCpDPIDS[nPos,02]))
                    Else                        
                        aAdd(aColsTmp,Criavar(Alltrim(Upper(aHeadIDS[nX,02])),.F.))                        
                    EndIf
                Next nX
                aAdd(aColsTmp,.F.)
                aAdd(aColsIDS,aColsTmp)
            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo

    Else
        //->> Campos de Memoria para a enchoice
        RegToMemory(cAlias, .F.)
        lEdtEstrut := .F.

        //->> aCols da estrutura
        (Tb_Estru)->(dbSetOrder(1))
        (Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+(Tb_Produ)->&(Tb_Produ+"_SKU")))
        Do While (Tb_Estru)->(!Eof()) .And. (Tb_Estru)->&(Tb_Estru+"_FILIAL+"+Tb_Estru+"_SKU") == xFilial(Tb_Estru)+(Tb_Produ)->&(Tb_Produ+"_SKU")
            aColsTmp := {}
            For nX:=1 to Len(aHeadEst)
                If aHeadEst[nX,10]=="R"
                    aAdd(aColsTmp,(Tb_Estru)->&(aHeadEst[nX,02]))
                Else
                    //->> Marcelo Celi - 26/03/2022
                    Do Case
                        Case Alltrim(Upper(aHeadEst[nX,02])) == "PRCPAD"
                            aAdd(aColsTmp,0)

                        Case Alltrim(Upper(aHeadEst[nX,02])) == "PRCPOL"
                            aAdd(aColsTmp,0)    

                        OTHERWISE
                            aAdd(aColsTmp,Criavar(aHeadEst[nX,02],.F.))
                    
                    EndCase
                EndIf
            Next nX
            aAdd(aColsTmp,.F.)
            aAdd(aColsEst,aColsTmp)
            (Tb_Estru)->(dbSkip())
        EndDo

        //->> aCols dos IDs
        aEstrutura := {}
        For nX:=1 to Len(aColsEst)
            If !aColsEst[nX][Len(aHeadEst)+1]
                aAdd(aEstrutura,{aColsEst[nX][Ascan(aHeadEst,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_COD"}) ] ,;
                                 aColsEst[nX][Ascan(aHeadEst,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_QTDE"})] })
            EndIf
        Next nX

        lPrimeiro := .T.
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                //->> De/Para dos IDs
                aCpDPIDS := {}
                aAdd(aCpDPIDS,{Tb_IDS+"_ECOM"       , (Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO" })            
                aAdd(aCpDPIDS,{Tb_IDS+"_TABPRC"     , (Tb_Ecomm)+"->"+Tb_Ecomm+"_TABPRC" })
                aAdd(aCpDPIDS,{Tb_IDS+"_PRCVEN"     , "nValor"                           })

                aColsTmp := {}            
                nValor := u_MaGetVlrEc(NIL,Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO")),aEstrutura)

                //->> Marcelo Celi - 26/03/2022
                If lPrimeiro
                    AtualVisPrc((Tb_Ecomm)->&(Tb_Ecomm+"_TABPRC"),_nPPrcPad,_nPProd,@aColsEst,@oEstrutura)
                EndIf
                lPrimeiro := .F.

                For nX:=1 to Len(aHeadIDS)
                    nPos := AScan(aCpDPIDS,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(aHeadIDS[nX,02]))})
                    If nPos > 0
                        aAdd(aColsTmp,&(aCpDPIDS[nPos,02]))
                    Else
                        (Tb_IDS)->(dbSetOrder(1))
                        If (Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+&((Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO")+"PRD"+PadR(&((Tb_Produ)+"->"+(Tb_Produ)+"_SKU"),Tamsx3(Tb_IDS+"_CHPROT")[01]) ))
                            aAdd(aColsTmp,(Tb_IDS)->&(aHeadIDS[nX,02]))
                        Else
                            aAdd(aColsTmp,Criavar(Alltrim(Upper(aHeadIDS[nX,02])),.F.))
                        EndIf    
                    EndIf
                Next nX
                aAdd(aColsTmp,.F.)
                aAdd(aColsIDS,aColsTmp)
            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo
    EndIf

    //->> aCols dos Canais
    lPrimeiro := .T.
    (Tb_Canal)->(dbSetOrder(1))
    (Tb_Canal)->(dbGotop())
    Do While (Tb_Canal)->(!Eof())
        If (Tb_Canal)->&(Tb_Canal+"_MSBLQL") <> "1"
            (Tb_TbPrc)->(dbSetOrder(2))
            aColsTmp := {}
            nVlrTab := u_MaGetVlrEc(Nil,Alltrim((Tb_Canal)->&(Tb_Canal+"_ECOMME")),aEstrutura,(Tb_Canal)->&(Tb_Canal+"_TABPRC"))
            If (Tb_TbPrc)->(dbSeek(xFilial(Tb_TbPrc)+m->&(Tb_Produ+"_SKU")+(Tb_Canal)->&(Tb_Canal+"_ECOMME")+(Tb_Canal)->&(Tb_Canal+"_CODIGO")))
                aAdd(aColsTmp,LoadBitmap( GetResources(), cImgSel ))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_ECOMME"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_CODIGO"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_DESCRI"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_TABPRC"))
                aAdd(aColsTmp,nVlrTab)
                aAdd(aColsTmp,(Tb_TbPrc)->&(Tb_TbPrc+"_PCDESC"))
                aAdd(aColsTmp,nVlrTab - (nVlrTab*((Tb_TbPrc)->&(Tb_TbPrc+"_PCDESC")/100)))
            Else
                aAdd(aColsTmp,LoadBitmap( GetResources(), cImgNoSel ))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_ECOMME"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_CODIGO"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_DESCRI"))
                aAdd(aColsTmp,(Tb_Canal)->&(Tb_Canal+"_TABPRC"))
                aAdd(aColsTmp,nVlrTab)
                aAdd(aColsTmp,0)
                aAdd(aColsTmp,nVlrTab)
            EndIf            
            aAdd(aColsTmp,.F.)
            aAdd(aColsCan,aColsTmp)

            //->> Marcelo Celi - 26/03/2022
            If lPrimeiro
                AtualVisPrc((Tb_Canal)->&(Tb_Canal+"_TABPRC"),_nPPrcPol,_nPProd,@aColsEst,@oEstrutura)
            EndIf
            lPrimeiro := .F.
        EndIf
        (Tb_Canal)->(dbSkip())
    EndDo

    DEFINE MSDIALOG oDlg TITLE "Catalogo de Produtos" FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 
        //->> Painel Principal
        oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,,,((oDlg:NCLIENTWIDTH)/2),((oDlg:NCLIENTHEIGHT)/2)-15,.F.,.F. )
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        //->> Painel Superior ----------------------------------------------------------------------------------------------------------
        oPanEsq := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,((oPanel:NCLIENTWIDTH/2)*.50),((oPanel:NCLIENTHEIGHT/2)),.F.,.T. )
        oPanEsq:Align := CONTROL_ALIGN_LEFT

        Enchoice(	cAlias, nReg, /*(nOpc*/ If(lEdita,3,2) , /*aCRA*/, /*cLetra*/, /*cTexto*/, ;
                    aCposCatal, {00,00,((oPanEsq:NCLIENTHEIGHT)/2)-2,((oPanEsq:NCLIENTWIDTH)/2)}, aCposCatal, nModelo, /*nColMens*/,;
                    /*cMensagem*/,/*cTudoOk*/, oPanEsq, lF3, lMemoria, lColumn,;
                    caTela, lNoFolder, lProperty)

        //->> Painel Central ----------------------------------------------------------------------------------------------------------
        oPanCen := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,RGB(224,224,224),(13),((oPanel:NCLIENTHEIGHT/2)),.F.,.T. )
        oPanCen:Align := CONTROL_ALIGN_LEFT

        //->> Painel Superior Direito ----------------------------------------------------------------------------------------------------------
        oPanDir := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,((oPanel:NCLIENTWIDTH/2)*.50),((oPanel:NCLIENTHEIGHT/2)),.F.,.T. )
        oPanDir:Align := CONTROL_ALIGN_ALLCLIENT
            
        oPanSupD := TPanel():New(0,0,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NCLIENTWIDTH)/2),((oPanDir:NCLIENTHEIGHT/2)*.35),.F.,.T. )
        oPanSupD:Align := CONTROL_ALIGN_TOP

        oPanBSupD := TPanel():New(0,0,'',oPanSupD, oDlg:oFont, .T., .T.,,RGB(96,96,96),((oPanSupD:NCLIENTWIDTH)/2),((oPanSupD:NCLIENTHEIGHT/2)),.T.,.F. )
        oPanBSupD:Align := CONTROL_ALIGN_TOP

        oBoxBSupD := TToolBox():New(01,01,oPanSupD,oPanSupD:NCLIENTWIDTH/2,oPanSupD:NCLIENTHEIGHT/2-2)
        oBoxBSupD:AddGroup( oPanBSupD , "Estrutura do Produto")

        oEstrutura := MSNewGetDados():New(01,01,((oPanBSupD:NHEIGHT/2)),((oPanBSupD:NWIDTH/2)),If(lEdtEstrut,GD_INSERT + GD_UPDATE + GD_DELETE,2),"AllwaysTrue()",.T.,,,,,,,,oPanBSupD,aHeadEst,aColsEst)
        oEstrutura:bChange := {||POSIC_STRU := oEstrutura:nAt,oEstrutura:Refresh()}
        oEstrutura:oBrowse:SetBlkBackColor({|| GETDCLR(oEstrutura:nAt,POSIC_STRU,nCorSelSTRU)})	
        oEstrutura:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

        //->> Painel Central Direito----------------------------------------------------------------------------------------------------------
        oPanCenD := TPanel():New(0,0,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NCLIENTWIDTH)/2),((oPanDir:NCLIENTHEIGHT/2)*.30),.F.,.T. )
        oPanCenD:Align := CONTROL_ALIGN_TOP

        oPanBCenD := TPanel():New(0,0,'',oPanCenD, oDlg:oFont, .T., .T.,,RGB(96,96,96),((oPanCenD:NCLIENTWIDTH)/2),((oPanCenD:NCLIENTHEIGHT/2)),.T.,.F. )
        oPanBCenD:Align := CONTROL_ALIGN_TOP

        oBoxBCenD := TToolBox():New(01,01,oPanCenD,oPanCenD:NCLIENTWIDTH/2,oPanCenD:NCLIENTHEIGHT/2-2)
        oBoxBCenD:AddGroup( oPanBCenD , "IDs dos Produtos no Site")

        oIDS := MSNewGetDados():New(01,01,((oPanBCenD:NHEIGHT/2)),((oPanBCenD:NWIDTH/2)),If(lEdita,GD_UPDATE,2),"AllwaysTrue()",.T.,,,,,,,,oPanBCenD,aHeadIDS,aColsIDS)
        
        //-->> Marcelo Celi - 26/03/2022
        oIDS:bChange := {|| AtualVisPrc(oIDS:aCols[oIDS:nAt,Ascan(oIDS:aHeader,{|x| Alltrim(Upper(x[02]))==Tb_IDS+"_TABPRC"})],_nPPrcPad,_nPProd,@oEstrutura:aCols,@oEstrutura), POSIC_IDS := oIDS:nAt,oIDS:Refresh()}
        
        oIDS:oBrowse:SetBlkBackColor({|| GETDCLR(oIDS:nAt,POSIC_IDS,nCorSelIDS)})	
        oIDS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

        //->> Painel Inferior Direito----------------------------------------------------------------------------------------------------------
        oPanInfD := TPanel():New(0,0,'',oPanDir, oDlg:oFont, .T., .T.,,,((oPanDir:NCLIENTWIDTH)/2),((oPanDir:NCLIENTHEIGHT/2)*.35),.F.,.T. )
        oPanInfD:Align := CONTROL_ALIGN_BOTTOM

        oPanBInfD := TPanel():New(0,0,'',oPanInfD, oDlg:oFont, .T., .T.,,RGB(96,96,96),((oPanInfD:NCLIENTWIDTH)/2),((oPanInfD:NCLIENTHEIGHT/2)),.T.,.F. )
        oPanBInfD:Align := CONTROL_ALIGN_TOP

        oBoxBInfD := TToolBox():New(01,01,oPanInfD,oPanInfD:NCLIENTWIDTH/2,oPanInfD:NCLIENTHEIGHT/2-2)
        oBoxBInfD:AddGroup( oPanBInfD , "Canais de Vendas / Políticas Comerciais no Site")

        oCanal := MSNewGetDados():New(01,01,((oPanBInfD:NHEIGHT/2)),((oPanBInfD:NWIDTH/2)),If(lEdita,GD_UPDATE,2),"AllwaysTrue()",.T.,,,1,,,,,oPanBInfD,aHeadCan,aColsCan)
        
        //->> Marcelo Celi - 26/03/2022
        oCanal:bChange := {|| AtualVisPrc(oCanal:aCols[oCanal:nAt,Ascan(oCanal:aHeader,{|x| Alltrim(Upper(x[02]))=="TABELA"})],_nPPrcPol,_nPProd,@oEstrutura:aCols,@oEstrutura), POSIC_CAN := oCanal:nAt,oCanal:Refresh()}
        
        oCanal:oBrowse:SetBlkBackColor({|| GETDCLR(oCanal:nAt,POSIC_CAN,nCorSelCAN)})	
        oCanal:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
        oCanal:oBrowse:blDblClick := {|| If(lEdita,If(oCanal:oBrowse:nColPos==7,oCanal:EditCell(),AtuMarcac()),.T.) }

        //->> Botoes da barra central lateral ao painel inferior direito
        nLinIniBot := (oPanSupD:NHEIGHT/2) + (oPanCenD:NHEIGHT/2) + (oPanInfD:NHEIGHT/2) + 5
        oBtMarc    := TBtnBmp2():New( (nLinIniBot   ),00,27,27,cImgSel  ,,,,{|| MarcDesmarc(1) },oPanCen,"Marcar Todos"     ,,.T. )
        oBtDesMarc := TBtnBmp2():New( (nLinIniBot+17),00,27,27,cImgNoSel,,,,{|| MarcDesmarc(0) },oPanCen,"Desmarcar Todos"  ,,.T. )

    ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,	{|| If(TudoOk(nOpc,aCataObrig,aEstrObrig),(lOk:=.T.,oDlg:End()),.T.)  },;
                                                        {|| (lOk:=.F.,oDlg:End())                       },,aButtons)) CENTER            

    If lOk
        Do Case
            Case nOpc == 3 .Or. nOpc == 4
                Begin Transaction
                    If nOpc == 3
                        Reclock(Tb_Produ,.T.)
                    Else
                        Reclock(Tb_Produ,.F.)
                    EndIf
                    For nX := 1 To (Tb_Produ)->(FCount())
                        If     "_FILIAL" $ (Tb_Produ)->(FieldName(nX))
                            (Tb_Produ)->(FieldPut(nX,xFilial(Tb_Produ)))                                
                        Else	
                            (Tb_Produ)->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
                        EndIf
                    Next nX
                    (Tb_Produ)->(MsUnlock())

                    //->> Apagar a estrutura antes de reconstrui-la na base
                    (Tb_Estru)->(dbSetOrder(1))
                    (Tb_Estru)->(dbSeek(xFilial(Tb_Estru)+&("m->"+Tb_Produ+"_SKU")))
                    Do While (Tb_Estru)->(!Eof()) .And. (Tb_Estru)->&("("+Tb_Estru+"_FILIAL+"+Tb_Estru+"_SKU"+")") == xFilial(Tb_Estru)+&("m->"+Tb_Produ+"_SKU")
                        Reclock(Tb_Estru,.F.)
                        Delete
                        (Tb_Estru)->(MsUnlock())
                        (Tb_Estru)->(dbSkip())
                    EndDo

                    //->> Reconstrução da estrutura na base
                    For nX:=1 to Len(oEstrutura:aCols)
                        If !oEstrutura:aCols[nX][Len(oEstrutura:aHeader)+1]
                            Reclock(Tb_Estru,.T.)
                            (Tb_Estru)->&(Tb_Estru+"_FILIAL") := xFilial(Tb_Estru)
                            (Tb_Estru)->&(Tb_Estru+"_SKU") := &("m->"+Tb_Produ+"_SKU")
                            For nY:=1 to Len(oEstrutura:aHeader)
                                If oEstrutura:aHeader[nY,10] <> "V"
                                    (Tb_Estru)->&(oEstrutura:aHeader[nY,02]) := oEstrutura:aCols[nX,nY]
                                EndIf
                            Next nY
                            (Tb_Estru)->(MsUnlock())
                        EndIf
                    Next nX

                    //->> Apagar os Ids antes de reconstrui-la na base
                    (Tb_IDS)->(dbSetOrder(3))
                    (Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+"PRD"+PadR(&("m->"+Tb_Produ+"_SKU"),Tamsx3(Tb_IDS+"_CHPROT")[01]) ))
                    Do While (Tb_IDS)->(!Eof()) .And. (Tb_IDS)->&("("+Tb_IDS+"_FILIAL+"+Tb_IDS+"_TIPO+"+Tb_IDS+"_CHPROT"+")") == xFilial(Tb_IDS)+PadR("PRD",Tamsx3(Tb_IDS+"_TIPO")[01])+PadR(&("m->"+Tb_Produ+"_SKU"),Tamsx3(Tb_IDS+"_CHPROT")[01])
                        Reclock(Tb_IDS,.F.)
                        Delete
                        (Tb_IDS)->(MsUnlock())
                        (Tb_IDS)->(dbSkip())
                    EndDo

                    //->> Reconstrução dos IDs na base
                    For nX:=1 to Len(oIDS:aCols)
                        If !oIDS:aCols[nX][Len(oIDS:aHeader)+1]
                            Reclock(Tb_IDS,.T.)
                            (Tb_IDS)->&(Tb_IDS+"_FILIAL") := xFilial(Tb_IDS)
                            (Tb_IDS)->&(Tb_IDS+"_TIPO")   := "PRD"
                            (Tb_IDS)->&(Tb_IDS+"_CHPROT") := &("m->"+Tb_Produ+"_SKU")
                            For nY:=1 to Len(oIDS:aHeader)
                                If oIDS:aHeader[nY,10] <> "V"
                                    (Tb_IDS)->&(oIDS:aHeader[nY,02]) := oIDS:aCols[nX,nY]
                                EndIf
                            Next nY
                            (Tb_IDS)->&(Tb_IDS+"_PENDEN") := "S"
                            (Tb_IDS)->(MsUnlock())
                        EndIf
                    Next nX

                    //->> Apagar os Tabelas/Canais antes de reconstrui-la na base
                    (Tb_Canal)->(dbSetOrder(1))
                    (Tb_Canal)->(dbGotop())
                    Do While (Tb_Canal)->(!Eof())
                        (Tb_TbPrc)->(dbSetOrder(2))
                        If (Tb_TbPrc)->(dbSeek(xFilial(Tb_TbPrc)+m->&(Tb_Produ+"_SKU")+(Tb_Canal)->&(Tb_Canal+"_ECOMME")+(Tb_Canal)->&(Tb_Canal+"_CODIGO")))
                            Reclock(Tb_TbPrc,.F.)
                            Delete
                            (Tb_TbPrc)->(MsUnlock())                            
                        EndIf
                        (Tb_Canal)->(dbSkip())
                    EndDo    

                    //->> Reconstrução das tabelas/Canais
                    For nX:=1 to Len(oCanal:aCols)
                        If !oCanal:aCols[nX][Len(oCanal:aHeader)+1] .And. Valtype(oCanal:aCols[nX][01])=="O" .And. Upper(Alltrim(oCanal:aCols[nX][01]:cName)) == Upper(Alltrim(cImgSel))
                            Reclock(Tb_TbPrc,.T.)
                            (Tb_TbPrc)->&(Tb_TbPrc+"_FILIAL") := xFilial(Tb_TbPrc)
                            (Tb_TbPrc)->&(Tb_TbPrc+"_ECOMME") := oCanal:aCols[nX][2]
                            (Tb_TbPrc)->&(Tb_TbPrc+"_CODIGO") := oCanal:aCols[nX][3]
                            (Tb_TbPrc)->&(Tb_TbPrc+"_SKU")    := m->&(Tb_Produ+"_SKU")
                            (Tb_TbPrc)->&(Tb_TbPrc+"_PCDESC") := oCanal:aCols[nX][7]
                            (Tb_TbPrc)->(MsUnlock())
                        EndIf
                    Next nX
                End Transaction
        EndCase
    EndIf
EndIf

Return

/*/{protheus.doc} TudoOk
*******************************************************************************************
Valida a digitação dos dados no catalogo
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoOk(nOpc,aCataObrig,aEstrObrig)
Local lRet := .F.

Do Case
    Case nOpc == 2
        lRet := .T.

    Case nOpc == 3
        lRet := TudoPreench(aCataObrig,aEstrObrig)
        lRet := lRet .And. MsgYesNo("Confirma o Cadastro do Produto no Catálogo do e-Commerce ?")

    Case nOpc == 4
        lRet := TudoPreench(aCataObrig,aEstrObrig)
        lRet := lRet .And. MsgYesNo("Confirma a Alteração do Cadastro do Produto no Catálogo do e-Commerce ?")

EndCase

Return lRet

/*/{protheus.doc} TudoPreench
*******************************************************************************************
Verifica se tudo esta preenchido nos campos
 
@author: Marcelo Celi Marques
@since: 08/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoPreench(aCataObrig,aEstrObrig)
Local lRet      := .T.
Local nX        := 1
Local nY        := 1
Local aErros    := {}
Local cMsgErro  := ""
Local lEstrOk   := .F.
Local cMsg      := ""

For nX:=1 to Len(aCataObrig)
    If Empty(&("m->"+aCataObrig[nX,01]))
        aAdd(aErros,{aCataObrig[nX,01],aCataObrig[nX,02]})
    EndIf
Next nX

For nX:=1 to Len(oEstrutura:aCols)
    If !oEstrutura:aCols[nX][Len(oEstrutura:aHeader)+1]
        lEstrOk := .T.
        For nY:=1 to Len(aEstrObrig)
            If Empty(oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))==aEstrObrig[nY,01]})])
                aAdd(aErros,{aEstrObrig[nY,01],aEstrObrig[nY,02]})
            EndIf
        Next nY
    EndIf
Next nX

If Len(aErros)>0 .Or. !lEstrOk
    lRet := .F.
    If Len(aErros)>0
        For nX:=1 to Len(aErros)
            If nX>1
                cMsgErro += ", "
            EndIf
            cMsgErro += Alltrim(aErros[nX,02])
        Next nX
    EndIf
    cMsg := ""
    If !lEstrOk
        cMsg += "Estrutura do produto não informada..."+CRLF
    EndIf
    If Len(aErros)>0
        cMsg += "Campos Obrigatórios não preenchidos."+CRLF+cMsgErro
    EndIf
    MsgAlert(cMsg)
EndIf

Return lRet

/*/{protheus.doc} GETDCLR
*******************************************************************************************
Funcao para tratamento das regras de cores para a grid da MsNewGetDados.
 
@author: Marcelo Celi Marques
@since: 06/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GETDCLR(nLinha,nSelec,nCor)
Local nCor1 := nCor
Local nRet  := CLR_WHITE

If nLinha == nSelec
	nRet := nCor1
EndIf

Return nRet

/*/{protheus.doc} MaVlSkuCat
*******************************************************************************************
Valida a digitação do sku no catalogo de produtos do ecommerce
 
@author: Marcelo Celi Marques
@since: 07/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaVlSkuCat()
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetARea())
Local cCpo      := ReadVar()
Local aColsTmp  := {}
Local nX        := 1
Local aCpDPEstr := {}
Local aCpDPIDS  := {}
Local nPos      := 0
Local nValor    := 0
Local aEstrutura:= {}
Local lAchou    := .F.

//->> De/Para da Estrutura
aAdd(aCpDPEstr,{Tb_Estru+"_COD"     , "m->"+Tb_Produ+"_SKU"              })
aAdd(aCpDPEstr,{Tb_Estru+"_DESCRI"  , "m->"+Tb_Produ+"_DESCRI"           })
aAdd(aCpDPEstr,{Tb_Estru+"_QTDE"    , "1"                                })
//->> De/Para dos IDs
aAdd(aCpDPIDS,{Tb_IDS+"_ECOM"       , (Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO" })
aAdd(aCpDPIDS,{Tb_IDS+"_TABPRC"     , (Tb_Ecomm)+"->"+Tb_Ecomm+"_TABPRC" })
aAdd(aCpDPIDS,{Tb_IDS+"_PRCVEN"     , "nValor"                           })

(Tb_Produ)->(dbSetOrder(1))
If (Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+&(cCpo)))
    lRet := .F.
    MsgAlert("O SKU informado já está cadastrado no catálogo de produtos do e-commerce."+CRLF+"Informe outro código para continuar com a inclusão...")
Else
    lRet := .T.
    //->> Compor os campos do sku
    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1")+&(cCpo)))
        m->&(Tb_Produ+"_EAN13")  := SB1->B1_CODBAR
        m->&(Tb_Produ+"_DESCRI") := SB1->B1_DESC
        m->&(Tb_Produ+"_DSCRES") := SB1->B1_DESC
        m->&(Tb_Produ+"_NCM")    := SB1->B1_POSIPI
        m->&(Tb_Produ+"_PESO")   := SB1->B1_PESO

        //->> Marcelo Celi - 28/01/2022
        SB5->(dbSetOrder(1))
        If SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
            m->&(Tb_Produ+"_COMPRI")  := SB5->B5_COMPR
            m->&(Tb_Produ+"_LARGUR")  := SB5->B5_LARG
            m->&(Tb_Produ+"_ALTURA")  := SB5->B5_ALTURA
        EndIf

        lAchou := .T.
    Else
        m->&(Tb_Produ+"_EAN13")  := Criavar(Tb_Produ+"_EAN13" ,.F.)
        m->&(Tb_Produ+"_DESCRI") := Criavar(Tb_Produ+"_DESCRI",.F.)
        m->&(Tb_Produ+"_DSCRES") := Criavar(Tb_Produ+"_DSCRES",.F.)
        m->&(Tb_Produ+"_NCM")    := Criavar(Tb_Produ+"_NCM"   ,.F.)
        m->&(Tb_Produ+"_PESO")   := Criavar(Tb_Produ+"_PESO"  ,.F.)
        m->&(Tb_Produ+"_COMPRI") := Criavar(Tb_Produ+"_COMPRI",.F.)
        m->&(Tb_Produ+"_LARGUR") := Criavar(Tb_Produ+"_LARGUR",.F.)
        m->&(Tb_Produ+"_ALTURA") := Criavar(Tb_Produ+"_ALTURA",.F.)

        lAchou := .F.
    EndIf
    //->> Compor o objeto de estrutura
    If lAchou
        oEstrutura:aCols := {}
        aColsTmp := {}
        For nX:=1 to Len(oEstrutura:aHeader)
            nPos := AScan(aCpDPEstr,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(oEstrutura:aHeader[nX,02]))})
            If nPos > 0
                aAdd(aColsTmp,&(aCpDPEstr[nPos,02]))
            Else
                //->> Marcelo Celi - 26/03/2022
                Do Case
                    Case Alltrim(Upper(oEstrutura:aHeader[nX,02])) == "PRCPAD"
                        aAdd(aColsTmp,0)

                    Case Alltrim(Upper(oEstrutura:aHeader[nX,02])) == "PRCPOL"
                        aAdd(aColsTmp,0)    

                    OTHERWISE
                        aAdd(aColsTmp,Criavar(Alltrim(Upper(oEstrutura:aHeader[nX,02])),.F.))
                
                EndCase                
            EndIf
        Next nX
        aAdd(aColsTmp,.F.)
        aAdd(oEstrutura:aCols,aColsTmp)
        oEstrutura:Refresh()

        For nX:=1 to Len(oEstrutura:aCols)
            If !oEstrutura:aCols[nX][Len(oEstrutura:aHeader)+1]
                aAdd(aEstrutura,{oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_COD"}) ] ,;
                                 oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_QTDE"})] })
            EndIf
        Next nX

        oIDS:aCols := {}
        (Tb_Ecomm)->(dbGotop())
        Do While (Tb_Ecomm)->(!Eof())
            If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
                aColsTmp := {}                
                nValor := u_MaGetVlrEc(NIL,Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO")),aEstrutura)

                For nX:=1 to Len(oIDS:aHeader)
                    nPos := AScan(aCpDPIDS,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(oIDS:aHeader[nX,02]))})
                    If nPos > 0
                        aAdd(aColsTmp,&(aCpDPIDS[nPos,02]))
                    Else
                        (Tb_IDS)->(dbSetOrder(3))
                        If (Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+"PRD"+PadR(&("m->"+Tb_Produ+"_SKU"),Tamsx3(Tb_IDS+"_CHPROT")[01])+&((Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO") ))
                            aAdd(aColsTmp,(Tb_IDS)->&(oIDS:aHeader[nX,02]))
                        Else
                            aAdd(aColsTmp,Criavar(Alltrim(Upper(oIDS:aHeader[nX,02])),.F.))
                        EndIf
                    EndIf
                Next nX
                aAdd(aColsTmp,.F.)
                aAdd(oIDS:aCols,aColsTmp)
            EndIf
            (Tb_Ecomm)->(dbSkip())
        EndDo
        oIDS:Refresh()
        AtuVlrCanal()
    
    EndIf
EndIf
SB1->(RestArea(aAreaSB1))
RestArea(aArea)

Return lRet

/*/{protheus.doc} MaVldQtEEc
*******************************************************************************************
Valida a digitação da quantidade da estrutura
 
@author: Marcelo Celi Marques
@since: 07/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaVldQtEEc()
Local lRet      := .T.
Local nPos      := 0
Local nValor    := 0
Local nX        := 1
Local aColsTmp  := {}
Local aCpDPIDS  := {}
Local aEstrutura:= {}
Local nPeso     := 0

//->> De/Para dos IDs
aAdd(aCpDPIDS,{Tb_IDS+"_ECOM"       , (Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO" })
aAdd(aCpDPIDS,{Tb_IDS+"_TABPRC"     , (Tb_Ecomm)+"->"+Tb_Ecomm+"_TABPRC" })
aAdd(aCpDPIDS,{Tb_IDS+"_PRCVEN"     , "nValor"                           })

For nX:=1 to Len(oEstrutura:aCols)
    If !oEstrutura:aCols[nX][Len(oEstrutura:aHeader)+1]
        If oEstrutura:nAt == nX
            aAdd(aEstrutura,{oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_COD"}) ] ,;
                                &(ReadVar())                                                                                   })
        Else
            aAdd(aEstrutura,{oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_COD"}) ] ,;
                                oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_QTDE"})] })
        EndIf
    EndIf
Next nX

nPeso := 0
For nX=1 to Len(aEstrutura)
    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1")+PadR(aEstrutura[nX,01],Tamsx3("B1_COD")[01])))
        nPeso += (SB1->B1_PESO * aEstrutura[nX,02])
    EndIf
Next nX
m->&(Tb_Produ+"_PESO") := nPeso

oIDS:aCols := {}
(Tb_Ecomm)->(dbGotop())
Do While (Tb_Ecomm)->(!Eof())
    If (Tb_Ecomm)->&(Tb_Ecomm+"_MSBLQL") <> "1"
        aColsTmp := {}        
        nValor := u_MaGetVlrEc(NIL,Alltrim((Tb_Ecomm)->&(Tb_Ecomm+"_CODIGO")),aEstrutura)

        For nX:=1 to Len(oIDS:aHeader)
            nPos := AScan(aCpDPIDS,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(oIDS:aHeader[nX,02]))})
            If nPos > 0
                aAdd(aColsTmp,&(aCpDPIDS[nPos,02]))
            Else
                (Tb_IDS)->(dbSetOrder(3))
                If (Tb_IDS)->(dbSeek(xFilial(Tb_IDS)+"PRD"+PadR(&("m->"+Tb_Produ+"_SKU"),Tamsx3(Tb_IDS+"_CHPROT")[01])+&((Tb_Ecomm)+"->"+Tb_Ecomm+"_CODIGO") ))
                    aAdd(aColsTmp,(Tb_IDS)->&(oIDS:aHeader[nX,02]))
                Else
                    aAdd(aColsTmp,Criavar(Alltrim(Upper(oIDS:aHeader[nX,02])),.F.))
                EndIf
            EndIf
        Next nX
        aAdd(aColsTmp,.F.)
        aAdd(oIDS:aCols,aColsTmp)
    EndIf
    (Tb_Ecomm)->(dbSkip())
EndDo
oIDS:Refresh()
AtuVlrCanal(aEstrutura)

Return lRet

/*/{protheus.doc} MaVldCdEEc
*******************************************************************************************
Valida a digitação do codigo do produto da estrutura
 
@author: Marcelo Celi Marques
@since: 07/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaVldCdEEc()
Local lRet := .T.
Local cCpo := ReadVar()
Local cTab := "" 

If !oEstrutura:aCols[oEstrutura:nAt][Len(oEstrutura:aHeader)+1]
    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1")+&(cCpo)))
        lRet := .T.
        oEstrutura:aCols[oEstrutura:nAt][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))==Tb_Estru+"_DESCRI"})] := SB1->B1_DESC    
    Else
        lRet := .F.
        oEstrutura:aCols[oEstrutura:nAt][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))==Tb_Estru+"_DESCRI"})] := ""
        MsgAlert("Produto não Localizado...")
    EndIf
    oEstrutura:Refresh()
EndIf

//->> Marcelo Celi - 26/03/2022
If Len(oIDS:aCols)>0
    cTab := oIDS:aCols[1][Ascan(oIDS:aHeader,{|x| Alltrim(Upper(x[02]))==Tb_IDS+"_TABPRC"})]
    If !Empty(cTab)
        AtualVisPrc(cTab,_nPPrcPad,_nPProd,@oEstrutura:aCols,@oEstrutura)
    EndIf
EndIf

If Len(oCanal:aCols)>0
    cTab := oCanal:aCols[1][Ascan(oCanal:aHeader,{|x| Alltrim(Upper(x[02]))=="TABELA"})]
    If !Empty(cTab)
        AtualVisPrc(cTab,_nPPrcPol,_nPProd,@oEstrutura:aCols,@oEstrutura)
    EndIf
EndIf

Return lRet

/*/{protheus.doc} GetNewCdKit
*******************************************************************************************
Retorna proximo codigo de kit
 
@author: Marcelo Celi Marques
@since: 11/11/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetNewCdKit()
Local cCodKit  := "KIT"+StrZero(1,(Tamsx3(Tb_Produ+"_SKU")[01])-3)
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aArea    := GetArea()
Local aAreaPrd := (Tb_Produ)->(GetArea())

cQuery := "SELECT TOP 1 "+Tb_Produ+"_SKU AS SKU"                                +CRLF
cQuery += " FROM "+RetSqlName(Tb_Produ)+" "+Tb_Produ+" (NOLOCK)"                +CRLF
cQuery += " WHERE "+Tb_Produ+"."+Tb_Produ+"_FILIAL = '"+xFilial(Tb_Produ)+"'"   +CRLF
cQuery += "   AND "+Tb_Produ+"."+Tb_Produ+"_TIPO   = 'K'"                       +CRLF
cQuery += "   AND "+Tb_Produ+".D_E_L_E_T_ = ' '"                                +CRLF
cQuery += " ORDER BY "+Tb_Produ+"_SKU DESC"                                     +CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
If (cAlias)->(!Eof()) .And. (cAlias)->(!Bof())
    cCodKit := Alltrim((cAlias)->SKU)
EndIf
(cAlias)->(dbCloseArea())

(Tb_Produ)->(dbSetOrder(1))
Do While .T.
    If !(Tb_Produ)->(dbSeek(xFilial(Tb_Produ)+cCodKit)) .And. FreeForUse(Tb_Produ,cCodKit)
        Exit
    Else
        cCodKit := Soma1(cCodKit)
    EndIf
EndDo

(Tb_Produ)->(RestArea(aAreaPrd))
RestArea(aArea)

Return cCodKit

/*/{protheus.doc} AtuMarcac
*******************************************************************************************
Atualiza a Marcação da Grid de canais
 
@author: Marcelo Celi Marques
@since: 16/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuMarcac()
If Upper(Alltrim(oCanal:aCols[oCanal:nAt][01]:cName)) == Upper(Alltrim(cImgSel))
    oCanal:aCols[oCanal:nAt][01] := LoadBitmap( GetResources(), cImgNoSel )
Else
    oCanal:aCols[oCanal:nAt][01] := LoadBitmap( GetResources(), cImgSel )
EndIf
oCanal:Refresh()
Return

/*/{protheus.doc} MaPrdVldPC
*******************************************************************************************
Valida o Desconto a aplicar no canal de venda
 
@author: Marcelo Celi Marques
@since: 16/12/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaPrdVldPC(nPcDesc,nAt,lMsg)
Local lRet      := .T.
Local nVlrTab   := 0

Default nPcDesc := &(ReadVar())
Default nAt     := oCanal:nAt
Default lMsg    := .T.

nVlrTab   := oCanal:aCols[nAt][06]

If nPcDesc < 0 .Or. nPcDesc > 100
    lRet := .F.
    If lMsg
        MsgAlert("Desconto Inválido...")
    EndIf
EndIf

If lRet
    oCanal:aCols[nAt][08] := Round(nVlrTab - (nVlrTab*(nPcDesc/100)),2)
EndIf
oCanal:Refresh()

Return lRet

/*/{protheus.doc} AtuVlrCanal
*******************************************************************************************
Atualiza os valores da grid de canais
 
@author: Marcelo Celi Marques
@since: 17/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuVlrCanal(aEstrutura)
Local nX         := 1
Local nVlrTab    := 0
Local cTab       := ""

Default aEstrutura := {}

If Len(aEstrutura)==0
    For nX:=1 to Len(oEstrutura:aCols)
        If !oEstrutura:aCols[nX][Len(oEstrutura:aHeader)+1]
            aAdd(aEstrutura,{oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_COD"}) ] ,;
                            oEstrutura:aCols[nX][Ascan(oEstrutura:aHeader,{|x| Alltrim(Upper(x[02]))== Tb_Estru+"_QTDE"})] })
        EndIf
    Next nX
EndIf

For nX:=1 to Len(oCanal:aCols)
    If !oCanal:aCols[nX][Len(oCanal:aHeader)+1]
        nVlrTab := u_MaGetVlrEc(Nil,Alltrim(oCanal:aCols[nX,02]),aEstrutura,oCanal:aCols[nX,05])
        oCanal:aCols[nX,06] := nVlrTab
        u_MaPrdVldPC(oCanal:aCols[nX,08],oCanal:nAt,.F.)
    EndIf
Next nX
oCanal:Refresh()

//->> Marcelo Celi - 26/03/2022
If Len(oIDS:aCols)>0
    cTab := oIDS:aCols[1][Ascan(oIDS:aHeader,{|x| Alltrim(Upper(x[02]))==Tb_IDS+"_TABPRC"})]
    If !Empty(cTab)
        AtualVisPrc(cTab,_nPPrcPad,_nPProd,@oEstrutura:aCols,@oEstrutura)
    EndIf
EndIf

If Len(oCanal:aCols)>0
    cTab := oCanal:aCols[1][Ascan(oCanal:aHeader,{|x| Alltrim(Upper(x[02]))=="TABELA"})]
    If !Empty(cTab)
        AtualVisPrc(cTab,_nPPrcPol,_nPProd,@oEstrutura:aCols,@oEstrutura)
    EndIf
EndIf

Return

/*/{protheus.doc} MarcDesmarc
*******************************************************************************************
Marca e Desmarca todos os itens da seleção de canais.
 
@author: Marcelo Celi Marques
@since: 17/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MarcDesmarc(nOpc)
Local nX := 1

For nX:=1 to Len(oCanal:aCols)
    If nOpc == 1
        oCanal:aCols[nX][01] := LoadBitmap( GetResources(), cImgSel )
    Else
        oCanal:aCols[nX][01] := LoadBitmap( GetResources(), cImgNoSel )
    EndIf
Next nX
oCanal:Refresh()

Return

/*/{protheus.doc} AtualVisPrc
*******************************************************************************************
Atualiza os preços na tela de esrtutura
 
@author: Marcelo Celi Marques
@since: 26/12/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtualVisPrc(cTabPrc,nPosPrc,nPosPrd,aCols,oEstrutura)
Local aArea     := GetArea()
Local aAreaDA1  := DA1->(GetArea())
Local nX        := 1
Local nPreco    := 0

If nPosPrd > 0 .And. nPosPrc > 0
    DA1->(dbSetOrder(1))
    For nX:=1 to Len(aCols)
        nPreco := 0
        If DA1->(dbSeek(xFilial("DA1")+PadR(cTabPrc,Tamsx3("DA1_CODTAB")[01])+aCols[nX,nPosPrd]))
            nPreco := DA1->DA1_PRCVEN
        EndIf
        aCols[nX,nPosPrc] := nPreco
    Next nX
EndIf

If Valtype(oEstrutura)=="O"
    oEstrutura:Refresh()
EndIf

DA1->(RestArea(aAreaDA1))
RestArea(aArea)

Return
