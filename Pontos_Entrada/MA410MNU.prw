#Include "PROTHEUS.CH"     
#Include "TOPCONN.CH"
  
/*
------------------------------------------------------------------------------------------------------------
Função: MA410MNU

Tipo: Ponto de entrada

Descrição: Adiciona a rotina separa pedido no menu

Uso: Genix

Parâmetros:

Retorno:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 19/10/2011 - Karem Ricarte  - Construção inicial do fonte
karem.ricarte@totvs.com.br   karem.ricarte@gmail.com
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
Atualizações:
- 12/10/2013 - Anna Lúcia   - Alteração para validar o Laudo 
------------------------------------------------------------------------------------------------------------
*/

User Function MA410MNU 
 
	                      
Local area        := GetArea()   
Local aBotao := {}
// Cria a rotina separar pedido
                                               
 aadd(aRotina,{'Pré Nota','MATR730' , 0 , 8,0,NIL})
 
 ADel(aRotina, 8)
ASize(aRotina, (Len(aRotina)-1)) 
  
 
RestArea(area)

return NIL