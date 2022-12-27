#Include 'Protheus.ch'
#include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "FIVEWIN.CH" 
                                                                                                                                                                                                                 
/*/{protheus.doc} FATP0002
*******************************************************************************************
Função usada em Gatilho do CK_PRODUTO para perguntar qual unidade comercial.
 
@author: Marcelo Celi Marques
@since: 30/11/2020
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function FATP0002(cProduto,nTipo)
Local oButton1
Local oSay1
Local c3UM	    :=  ""
Local oCheck1   := NIL
Local lCheck1   := .T.
Local _cProduto := TMP1->CK_PRODUTO
Local _nUMVen   := TMP1->CK_XQUMVEN
Local _nQtdVen  := TMP1->CK_QTDVEN
Local _c1UM     := TMP1->CK_UM
Local _c2UM     := TMP1->CK_XSEGUM
Local _n2Qtd    := TMP1->CK_XUNSVEN
Local _nTotal   := TMP1->CK_VALOR

Default nTipo := 1

Static oDlg

If !EMPTY(Posicione("SB1",1,xFilial("SB1") +_cProduto,"B1_SEGUM"))
    TMP1->CK_XSEGUM := SB1->B1_SEGUM
    _c2UM           := TMP1->CK_XSEGUM

    TMP1->CK_XUNSVEN:= If(SB1->B1_TIPCONV=="D",_nQtdVen / SB1->B1_CONV,_nQtdVen * SB1->B1_CONV)
    _n2Qtd          := TMP1->CK_XUNSVEN

  If nTipo == 1
    If !p__lUM

      //Chama caixa de dialogo para escolha da unidade de medida
      DEFINE MSDIALOG oDlg TITLE "Unidade de Medida?" FROM 000, 000  TO 120, 400 COLORS 0, 16777215 PIXEL
      
      @ 015, 005 SAY oSay1 PROMPT "Em qual unidade de medida será vendido esse produto? "+ TMP1->CK_UM +" ou " + TMP1->CK_XSEGUM +" ?" SIZE 120, 400 OF oDlg COLORS 0, 16777215 PIXEL
      @ 033, 033 BUTTON oButton1 PROMPT _c1UM SIZE 051, 012 OF oDlg ACTION (c3UM :=_c1UM, p__cUM := _c1UM,oDlg:End()) PIXEL    
      @ 033, 093 BUTTON oButton1 PROMPT _c2UM SIZE 051, 012 OF oDlg ACTION (c3UM :=_c2UM, p__cUM := _c2UM,oDlg:End()) PIXEL

      lCheck1 := p__lUM
      oCheck1 := TCheckBox():New(48,05,"Não perguntar novamente...",,oDlg,100,15,,,,,,,,.T.,,,) 
      oCheck1:bSetGet   := {|| lCheck1, p__lUM:=lCheck1 } 
      oCheck1:bLClicked := {|| lCheck1:=!lCheck1, p__lUM:=lCheck1 } 
      oCheck1:bWhen     := {|| .T. } 

      ACTIVATE MSDIALOG oDlg CENTERED

    Else
      c3UM := p__cUM
    EndIf

    //Analisa Opção Escolhida
    If c3UM == _c1UM 
        //Alert("1º Unidade de Medida")
        _nUMVen  := _nTotal / _nQtdVen
        TMP1->CK_DESCRI := Posicione("SB1",1,xFilial("SB1") +  _cProduto,"B1_DESC" )         
    Else
        //Alert("2º Unidade de Medida")
        _nUMVen  := _nTotal / _n2Qtd
        TMP1->CK_DESCRI := Posicione("SB1",1,xFilial("SB1") +  _cProduto,"B1_XDESC" )
    EndIf
    
    TMP1->CK_XUMVEN :=  c3UM 

  ElseIf nTipo == 2
    _nUMVen  := TMP1->CK_PRCVEN / If(SB1->B1_TIPCONV=="D",1 / SB1->B1_CONV,1 * SB1->B1_CONV)
    
  ElseIf nTipo == 3
    TMP1->CK_XUNSVEN    := &(ReadVar())
    TMP1->CK_QTDVEN     := If(SB1->B1_TIPCONV=="D",TMP1->CK_XUNSVEN * SB1->B1_CONV,TMP1->CK_XUNSVEN / SB1->B1_CONV)
    TMP1->CK_VALOR      := TMP1->CK_QTDVEN * TMP1->CK_PRCVEN

    _nTotal             := TMP1->CK_VALOR
    _n2Qtd              := TMP1->CK_XUNSVEN
    _nQtdVen            := TMP1->CK_QTDVEN    
        
    _nUMVen             := TMP1->CK_PRCVEN / If(SB1->B1_TIPCONV=="D",1 / SB1->B1_CONV,1 * SB1->B1_CONV)    

  EndIf

EndIf		    
	
Return(_nUMVen)


/*/{protheus.doc} VldCKUnid
*******************************************************************************************
Função usada em validação CK_UM e CK_XUNSVEN para habilitar ou não o campo.
 
@author: Marcelo Celi Marques
@since: 30/11/2020
@param: 
@return:
@type function: Usuario - Ponto de Entrada
*******************************************************************************************
/*/
User Function VldCKUnid(cUm)
Local lRetorno  := .T.
Local _cProduto := TMP1->CK_PRODUTO

Default cUm     := "XX"

If !EMPTY(Posicione("SB1",1,xFilial("SB1") + _cProduto,"B1_SEGUM"))
    If cUm == "1UM"         
        If TMP1->CK_XUMVEN == TMP1->CK_XSEGUM
            lRetorno := .F.
        EndIf
    
    ElseIf cUm == "2UM"
        If TMP1->CK_XUMVEN ==  TMP1->CK_UM
            lRetorno := .F.      
        EndiF
    Else
        lRetorno := .T.     
    EndIf   
EndIf        
 
Return lRetorno


