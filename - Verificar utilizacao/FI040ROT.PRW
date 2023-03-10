#Include "PROTHEUS.CH"     
#Include "TOPCONN.CH"
  
/*
------------------------------------------------------------------------------------------------------------
Fun??o: MA410MNU

Tipo: Ponto de entrada

Descri??o: Adiciona a rotina separa pedido no menu

Uso: Genix

Par?metros:

Retorno:
------------------------------------------------------------------------------------------------------------
Atualiza??es:
- 19/10/2011 - Karem Ricarte  - Constru??o inicial do fonte
karem.ricarte@totvs.com.br   karem.ricarte@gmail.com
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
Atualiza??es:
- 12/10/2013 - Anna L?cia   - Altera??o para validar o Laudo 
------------------------------------------------------------------------------------------------------------
*/

User Function FI040ROT
 
	                      
Local area   := GetArea()   
Local aBotao := {} 
Local aRotina := AClone(PARAMIXB)
// Cria a rotina separar pedido
                                               
  aadd(aRotina,{'Imp. Duplicata','U_IMPDUP()' , 0 , 7,0,NIL}) // Rotina para imprimir a duplicata ///Clistenis 16/08/2012 
  aadd(aRotina,{'Boleto Bradesco','U_BOLBRD()' , 0 , 8,0,NIL}) // Rotina para imprimir a duplicata ///Clistenis 16/08/2012 
  aadd(aRotina,{'Boletos','Process2()' , 0 , 9,0,NIL}) // Rotina para imprimir a duplicata ///Clistenis 16/08/2012 
  
ADel(aRotina, 7)
ASize(aRotina, (Len(aRotina)-1)) 
  
 
RestArea(area)

Return (aRotina)