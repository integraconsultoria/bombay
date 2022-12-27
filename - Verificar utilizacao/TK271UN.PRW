#Include "Protheus.ch"

/*/{Protheus.doc} TK271UN
//TODO Descrição auto-gerada.
@author Pedro Lima
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function TK271UN()

Local nQtdSeg := 0
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_QUANT"})

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If DbSeek(xFilial("SB1") + M->UB_PRODUTO)

	If ! Empty(SB1->B1_CONV)              
	   If SB1->B1_TIPCONV == "M"
	       nQtdSeg :=  aCols[n][_nPosQtd]  * SB1->B1_CONV
	   Else
	       nQtdSeg :=  aCols[n][_nPosQtd] / SB1->B1_CONV
	   EndIf
	EndIf
Else 
   MsgInfo("Produto :"+ M->UB_PRODUTO + " Não encontrado")
EndIf


Return(nQtdSeg)

User function TK271QTD()

Local nQtdSeg := 0
Local _nPosPrd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"})
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_QUANT"})

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If DbSeek(xFilial("SB1") + aCols[n][_nPosPrd])

	If ! Empty(SB1->B1_CONV)              
	   If SB1->B1_TIPCONV == "M"
	       nQtdSeg :=  aCols[n][_nPosQtd]  * SB1->B1_CONV
	   Else
	       nQtdSeg :=  aCols[n][_nPosQtd] / SB1->B1_CONV
	   EndIf
	EndIf
Else 
   MsgInfo("Produto :"+ aCols[n][_nPosPrd] + " Não encontrado")
EndIf


Return(nQtdSeg)

User function TK271S()

Local nQtdSeg := 0
Local _nPosPrd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"})
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_X_QTDSE"})

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If DbSeek(xFilial("SB1") + aCols[n][_nPosPrd])

	If ! Empty(SB1->B1_CONV)              
	   If SB1->B1_TIPCONV == "M"
	       nQtdSeg :=  aCols[n][_nPosQtd]  / SB1->B1_CONV
	   Else
	       nQtdSeg :=  aCols[n][_nPosQtd] * SB1->B1_CONV
	   EndIf
	EndIf
Else 
   MsgInfo("Produto :"+ aCols[n][_nPosPrd] + " Não encontrado")
EndIf


Return(nQtdSeg)


User function TK271VLR()

Local nPrcNovo := 0
Local  nPrcUni := 0
Local  nPrcTab := 0
Local _nPosPrd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"})
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_X_QTDSE"})
Local _nPosUni := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VRUNIT"})
Local _nPosTab := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRCTAB"})
Local _nPosQua := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_QUANT"})
Local _nPosVlr := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VLRITEM"})

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If DbSeek(xFilial("SB1") + aCols[n][_nPosPrd])

    nQtdConv := Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosPrd],"B1_CONV" )

	If ! Empty(B1_CONV)              
	   If SB1->B1_TIPCONV == "M"
	       nQtdSeg :=  aCols[n][_nPosQtd]  / SB1->B1_CONV
	   Else
	       nQtdSeg :=  aCols[n][_nPosQtd] * SB1->B1_CONV
	   EndIf
	EndIf
Else 
   MsgInfo("Produto :"+ aCols[n][_nPosPrd] + " Não encontrado")
EndIf

nPrcUni := aCols[n][_nPosUni] 
nPrcTab := aCols[n][_nPosTab]

  If nPrcUni == nPrcTab 
   
   // Formula do Preço Real 
   nPrcReal := (nPrcUni / nQtdConv) * nQtdSeg
   
   // Preço Novo  
   nPrcNovo := (nPrcReal / aCols[n][_nPosQua])
   
   // Atualiza Preço Novo
   aCols[n][_nPosUni] :=  nPrcNovo
   
   // Atualiza Total Novo
   aCols[n][_nPosVlr] :=  aCols[n][_nPosQtd] *  nPrcNovo
   
   EndIf

 

Return(nPrcNovo)


User function TK271VLT()

Local nPrcNovo := 0
Local  nPrcUni := 0
Local  nPrcTab := 0
Local _nPosPrd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"})
Local _nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_X_QTDSE"})
Local _nPosUni := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VRUNIT"})
Local _nPosTab := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRCTAB"})
Local _nPosQua := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_QUANT"})
Local _nPosVlr := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_VLRITEM"})

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If DbSeek(xFilial("SB1") + aCols[n][_nPosPrd])

    nQtdConv := Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosPrd],"B1_CONV" )

	If ! Empty(B1_CONV)              
	   If SB1->B1_TIPCONV == "M"
	       nQtdSeg :=  aCols[n][_nPosQtd]  / SB1->B1_CONV
	   Else
	       nQtdSeg :=  aCols[n][_nPosQtd] * SB1->B1_CONV
	   EndIf
	EndIf
Else 
   MsgInfo("Produto :"+ aCols[n][_nPosPrd] + " Não encontrado")
EndIf

nPrcUni := aCols[n][_nPosUni] 
nPrcTab := aCols[n][_nPosTab]

  If nPrcUni == nPrcTab 
   
   // Formula do Preço Real 
   nPrcReal := (nPrcUni / nQtdConv) * nQtdSeg
   
   // Preço Novo  
   nPrcNovo := (nPrcReal / aCols[n][_nPosQua])
   
   // Atualiza Preço Novo
   aCols[n][_nPosUni] :=  nPrcNovo
   
   // Atualiza Total Novo
   aCols[n][_nPosVlr] :=  aCols[n][_nPosQtd] *  nPrcNovo
   
   EndIf
 

Return(aCols[n][_nPosVlr])


User Function TK271UNC()


Local _nPosUM  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_UM"})
Local _nPosCod := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_PRODUTO"})
Local _nPosSE := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_X_SEGUM"})
Local _nPosDE := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_DESCRI"})
Local _nPosUC := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="UB_X_UNCOM"})
Local _c1UM   := aCols[n][_nPosUM] 
Local _c2UM   := aCols[n][_nPosSE]
Local _c3UM	  := aCols[n][_nPosUC]
Local oSay1, oButton1, oDlg

           
            If  !EMPTY(Posicione("SB1",1,xFilial("SB1") +  aCols[n][_nPosCod],"B1_SEGUM"))

 			//Chama caixa de dialogo para escolha da unidade de medida
			DEFINE MSDIALOG oDlg TITLE "Unidade de Medida?" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL
	
	    	@ 015, 005 SAY oSay1 PROMPT "Em qual unidade de medida será vendido esse produto? "+ aCols[n][_nPosUM] +" ou " + aCols[n][_nPosSE] +" ?" SIZE 120, 400 OF oDlg COLORS 0, 16777215 PIXEL
	    	@ 033, 033 BUTTON oButton1 PROMPT _c1UM SIZE 051, 012 OF oDlg ACTION (_c3UM :=_c1UM,oDlg:End()) PIXEL    
	    	@ 033, 093 BUTTON oButton1 PROMPT _c2UM SIZE 051, 012 OF oDlg ACTION (_c3UM :=_c2UM,oDlg:End()) PIXEL
	    
	  		ACTIVATE MSDIALOG oDlg CENTERED
	  		
	  			//Analisa Opção Escolhida
		    If  _c3UM == _c1UM 
				  MsgInfo("1º Unidade de Medida")
	    	    aCols[n][_nPosDE] := Posicione("SB1",1,xFilial("SB1") + M->UB_PRODUTO,"B1_DESC" )         
	    	Else
		    	  MsgInfo("2º Unidade de Medida")
	            aCols[n][_nPosDE]:= Posicione("SB1",1,xFilial("SB1") + M->UB_PRODUTO,"B1_XDESC" )	 
		    EndIf
	
	            aCols[n][_nPosUC] :=  _c3UM 
	        EndIf    

Return(_c3UM)