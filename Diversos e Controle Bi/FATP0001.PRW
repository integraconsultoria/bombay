#Include 'Protheus.ch'
#include "TOTVS.CH"
#INCLUDE "rwmake.ch"
//#INCLUDE "FIVEWIN.CH" 
                                                                                                                                                                                                                 

/*/{Protheus.doc} FATP0001
//Função usada em Gatilho do C6_PRODUTO para perguntar qual unidade comercial.
@author Pedro Lima
@since 19/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
/*/
User Function FATP0001(cProduto,nTipo)

Local cClifor  :=  M->C5_CLIENTE
Local cLoja	   :=  M->C5_LOJACLI 
Local cProduto :=  M->C6_PRODUTO 
Local nQuant   :=  0
Local _c1UM  := " "
Local _c2UM  := " "
Local c3UM	 :=  ""
Local cRetUM :=  ""

Local oButton1
Local nOpca := 0
Local oGet1
Local cGet1 := space(60)
Local oSay1
Local cRet  := ""

//->> Marcelo Celi - 30/11/2020
Local oCheck1 := NIL
Local lCheck1 := .T.

Default nTipo := 1

Static oDlg
   
  //pesquisa a posição do campo UM no aHeader
  _nPos1UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_UM"})
  
  //pesquisa a posição do campo SEGUM no aHeader
  _nPos2UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_SEGUM"})
  
  //pesquisa a posição do campo DESCRI no aHeader
  _nPosDesc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_DESCRI"})
  
    //pesquisa a posição do campo UNIDADE COMERCIAL no aHeader
  _nPosUM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_XUMVEN"})

  //pesquisa a posição do campo QUANTIDADE COMERCIAL no aHeader
  _nPosUMven := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_XQUMVEN"})

  //pesquisa a posição do campo Código no aHeader
  _nPosCod := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRODUTO"})

  //pesquisa a posição do campo Local no aHeader
  _nPosLoc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_LOCAL"})
  
  //pesquisa a posição do campo Quantidade no aHeader
  _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_QTDVEN"})

  //pesquisa a posição do campo Valor Total no aHeader
  _nPosVlr := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_VALOR"})
  
  //pesquisa a posição do campo QUANTIDA 2 UNIDADE no aHeader
  _nPos2Ven := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_UNSVEN"})
   
  //recupera os dados do aCols para pesquisa
  _cProduto := aCols[n][_nPosCod]
  _cDesc    := aCols[n][_nPosDesc]
  _nUMVen   := aCols[n][_nPosUMVen]  
  _cLocal   := aCols[n][_nPosLoc]
  _nQtdVen  := aCols[n][_nPosQtd]
  _c1UM     := aCols[n][_nPos1UM]
  _c2UM     := aCols[n][_nPos2UM]
  _n2Qtd    := aCols[n][_nPos2Ven]
  _cUm      := aCols[n][_nPosUM]
  _nTotal   := aCols[n][_nPosVlr]
  	        
If !EMPTY(Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_SEGUM"))
  If nTipo == 1
    If !p__lUM
      //Chama caixa de dialogo para escolha da unidade de medida
      DEFINE MSDIALOG oDlg TITLE "Unidade de Medida?" FROM 000, 000  TO 120, 400 COLORS 0, 16777215 PIXEL
      
      @ 015, 005 SAY oSay1 PROMPT "Em qual unidade de medida será vendido esse produto? "+ aCols[n][_nPos1UM] +" ou " + aCols[n][_nPos2UM] +" ?" SIZE 120, 400 OF oDlg COLORS 0, 16777215 PIXEL
      
      //->> Marcelo Celi - 30/11/2020
      //@ 033, 033 BUTTON oButton1 PROMPT _c1UM SIZE 051, 012 OF oDlg ACTION (c3UM :=_c1UM,oDlg:End()) PIXEL    
      //@ 033, 093 BUTTON oButton1 PROMPT _c2UM SIZE 051, 012 OF oDlg ACTION (c3UM :=_c2UM,oDlg:End()) PIXEL
      
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
        _nUMVen  := aCols[n][_nPosVlr] / aCols[n][_nPosQtd]   
        aCols[n][_nPosDesc] := Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_DESC" )         
    Else
        //Alert("2º Unidade de Medida")
        _nUMVen  := aCols[n][_nPosVlr] / aCols[n][_nPos2Ven] 
        aCols[n][_nPosDesc] := Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_XDESC" )
    EndIf
    
    aCols[n][_nPosUM] :=  c3UM 

  ElseIf nTipo == 2
    _nUMVen  := aCols[n][_nPosVlr] / aCols[n][_nPos2Ven] //aCols[n][_nPosQtd]   
    
  ElseIf nTipo == 3
    _nUMVen  := aCols[n][_nPosVlr] / aCols[n][_nPos2Ven] 

  EndIf
  GETDREFRESH()
EndIf		    
	
Return(_nUMVen)

/*/{Protheus.doc} VldUnid
//Função usada em validação C6_UM e C6_UNSVEN para habilitar ou não o campo.
@author Pedro Lima
@since 19/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
/*/

User Function VldPrc()

Local lRet := .T.
Local _nQtd     := 0  //Quantidade 
Local _n2Qtd    := 0  //2 Quantidade 
Local _nPreco   := 0  //Preco Unitário 
Local _nVtotal  := 0  //Valor Total             
Local  nQtdConv := 0
Local  nPrcReal := 0
Local  nPrcNovo := 0

  //pesquisa a posição do campo Código no aHeader
   _nPosCod := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRODUTO"})
   
  //pesquisa a posição do campo Quantidade no aHeader
  _nPosQtd  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_QTDVEN"})
  
  //pesquisa a posição do campo Qtd 2 Unidade no aHeader
  _nPos2Qtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_UNSVEN"})
  
  //pesquisa a posição do campo Preco no aHeader
   _nPosPrc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRCVEN"})
   
  //pesquisa a posição do campo Valor Total no aHeader
  _nPosVlr  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_VALOR"})
       
  //pesquisa a posição do campo preço Lista no aHeader
  _nPosPrl := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRUNIT"})
   

  _nQtd     := aCols[n][_nPosQtd]  //Quantidade 
  _n2Qtd    := aCols[n][_nPos2Qtd] //2 Quantidade 
  _nPreco   := aCols[n][_nPosPrc]  //Preco Unitário 
  _nPrcLis  := aCols[n][_nPosPrl]  //Preco de Lista
  _nVtotal  := aCols[n][_nPosVlr]  //Valor Total     
   
   nQtdConv := Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_CONV" ) // Fator conversão
   
   If _nPrcLis == _nPreco 
   
   // Formula do Preço Real 
   nPrcReal := (_nPreco / nQtdConv) * _n2Qtd
   
   // Preço Novo  
   nPrcNovo := (nPrcReal / _nQtd)
   
   // Atualiza Preço Novo
   aCols[n][_nPosPrc] :=  nPrcNovo
   
   // Atualiza Total Novo
   aCols[n][_nPosVlr] :=  aCols[n][_nPosQtd] *  nPrcNovo
   
   EndIf
   
   //If _nPreco == aCols[n][_nPosPrc] .and. _nVtotal == aCols[n][_nPosVlr] 
    //   lRet := .F.
   //EndIf
   
 _nQtd     := 0   
 _n2Qtd    := 0    
 _nPreco   := 0   
 _nPrcLis  := 0 
 _nVtotal  := 0                
  nQtdConv := 0
   
  
Return(lRet)


/*/{Protheus.doc} VldUnid
//Função usada em validação C6_UM e C6_UNSVEN para habilitar ou não o campo.
@author Pedro Lima
@since 19/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
/*/

User Function VldUnid(cUm)
Local       nP := 0
Local lRetorno := .T.
Default    cUm := "XX"


  _nPosCod := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRODUTO"})
   //pesquisa a posição do campo Unidade no aHeader
  _nPosUM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_XUMVEN"})
  
   //pesquisa a posição do campo UM no aHeader
  _nPos1UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_UM"})
  
  //pesquisa a posição do campo SEGUM no aHeader
  _nPos2UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_SEGUM"})
  
  
  _c1UM     := aCols[n][_nPos1UM]
  _c2UM     := aCols[n][_nPos2UM]
  _cUm      := aCols[n][_nPosUM]
  
   If !EMPTY(Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_SEGUM"))

         If cUm == "1UM" 
         
              iF aCols[n][_nPosUM] == aCols[n][_nPos2UM] 
              	lRetorno := .F.
              EndIf
         
         ElseIf cUm == "2UM"
              iF aCols[n][_nPosUM] ==  aCols[n][_nPos1UM]
                 lRetorno := .F.      
              EndiF
         Else
             lRetorno := .T.     
         EndIf   
    EndIf        
 
Return lRetorno


