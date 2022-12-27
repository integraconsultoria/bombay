#include "Protheus.ch"

/*  
    AUTOR: PEDRO LIMA
	Ponto de entrada para tratamento de preço 
	quando utilizado a segunda unidade de medida.	
    Ultima Revisão: 18/09/2018  
*/

User Function M410LIOK 

Local     lRet := .T.
Local _nPosUM  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_XUMVEN"}) //Unidade Comercial
Local _nPos2UM := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_SEGUM"})  //Segunda Unidade
Local _nPosPrc := aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="C6_PRCVEN"}) //Preço de Venda
Local _nPosUni := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRUNIT"}) //Preço de Lista

// If aCols[n][_nPosUM] == aCols[n][_nPos2UM] // Se a unidade Comercial for a Segunda unidade de Medida.
  
//    lRet := u_VldPrc() //Corrige preço
    
// EndIf
 
        //Tratamento para pedidos de venda que possuem tabela de preço.
   
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
    
 
Return (lRet)