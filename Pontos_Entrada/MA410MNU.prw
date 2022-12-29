#Include "PROTHEUS.CH"     
#Include "TOPCONN.CH"
  
/*
------------------------------------------------------------------------------------------------------------
Fun��o: MA410MNU

Tipo: Ponto de entrada

Descri��o: Adiciona a rotina separa pedido no menu

Uso: Genix

Par�metros:

Retorno:
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 19/10/2011 - Karem Ricarte  - Constru��o inicial do fonte
karem.ricarte@totvs.com.br   karem.ricarte@gmail.com
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 12/10/2013 - Anna L�cia   - Altera��o para validar o Laudo 
------------------------------------------------------------------------------------------------------------
*/

User Function MA410MNU 
 
	                      
Local area        := GetArea()   
Local aBotao := {}
// Cria a rotina separar pedido
                                               
 aadd(aRotina,{'Pr� Nota','MATR730' , 0 , 8,0,NIL})
 
 ADel(aRotina, 8)
ASize(aRotina, (Len(aRotina)-1)) 
  
 
RestArea(area)

return NIL