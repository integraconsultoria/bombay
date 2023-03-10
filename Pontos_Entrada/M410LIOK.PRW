#include "Protheus.ch"

/*  
    AUTOR: PEDRO LIMA
	Ponto de entrada para tratamento de pre?o 
	quando utilizado a segunda unidade de medida.	
    Ultima Revis?o: 18/09/2018  
*/

User Function M410LIOK 

Local     lRet := .T.
Local _nPosUM  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_XUMVEN"}) //Unidade Comercial
Local _nPos2UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_SEGUM"})  //Segunda Unidade
Local _nPosPrc := aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="C6_PRCVEN"}) //Pre?o de Venda
Local _nPosUni := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRUNIT"}) //Pre?o de Lista

//->> Marcelo Celi - 06/01/2023
Local _nPosOrc  := Ascan(aHeader,{|x| Alltrim(x[2])==Alltrim("C6_NUMORC")})//->> NUmero do Or?amento
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 

// If aCols[n][_nPosUM] == aCols[n][_nPos2UM] // Se a unidade Comercial for a Segunda unidade de Medida.
  
//    lRet := u_VldPrc() //Corrige pre?o
    
// EndIf
 
        //Tratamento para pedidos de venda que possuem tabela de pre?o.
   
         IF aCols[n][_nPosPrc] <> aCols[n][_nPosUni]
            aCols[n][_nPosUni] := 0 
         EndIf
         
         IF M->C6_PRCVEN <> M->C6_PRUNIT
            M->C6_PRUNIT := 0 
         EndIf
         
       // GETDREFRESH()
      
       // Atualizacao por linha
    
    // SetFocus(oGetDad:oBrowse:hWnd) 
    // oGetDad:Refresh()
    // A410LinOk(oGetDad)


//->> Marcelo Celi - 06/01/2023
If lRet .And. !aCols[n][Len(aHeader)+1] .And. !IsBlind() .And. IsInCallStack("MATA416") .And. lUsaBkOrd .And. SCK->(FieldPos("CK_XBKQTD"))>0 .And. _nPosOrc>0
    SCK->(dbSetOrder(1))
    If SCK->(dbSeek(xFilial("SCK")+aCols[n][_nPosOrc]))
        If  SCK->CK_XBKQTD > 0
            lRet := .F.
            MsgAlert("O Item foi DELETADO por Backorder de Or?amento e n?o pode ser utilizado no Pedido de Vendas.")
        EndIf
    EndIf
EndIf

Return (lRet)
