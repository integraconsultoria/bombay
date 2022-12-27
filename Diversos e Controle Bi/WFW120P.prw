User Function WFW120P()
Local aArea := GetArea()
    Local cNome := UsrFullName(RetCodUsr())   
    Local cNumPed := SC7->C7_NUM
     
     //Copia nome do usuário que ineriu o pedido para a tabela SCR
      dbSelectArea("SCR")
      dbsetorder(2) //six - CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
     dbseek(xfilial("SCR") + "PC" + cNumPed)
     if found()
          RecLock("SCR",.F.)
          SCR->CR_XFORNE := SC7->C7_XDESCR
          SCR->CR_XCOND  := Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI")
          SCR->CR_XFRETE := SC7->C7_TPFRETE
          SCR->CR_XEST   := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE,"A2_EST")
          SCR->CR_XOBS   := SC7->C7_XOBS
          SCR->CR_XUSR := cNome
          SCR->(MsUnLock())
          RestArea(aArea)
      endif
Return
