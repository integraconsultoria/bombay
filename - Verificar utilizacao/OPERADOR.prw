#include 'protheus.ch'
#include 'parmtype.ch'

user function OPERADOR()
	
      Local nNum1 := 10
      Local nNum2 := 20	
      
      //OPERADORES MATEMATICOS	
//	  Alert(nNum1 + nNum2)
//	  Alert(nNum2 - nNum1)
//	  Alert(nNum1 * nNum2)
//	  Alert(nNum2 / nNum1)
//	  Alert(nNum2 % nNum1)
	  
	  //OPERADORES RELACIONAIS
//	  Alert(nNum1 < nNum2)
//	  Alert(nNum1 > nNum2)
//	  Alert(nNum1 = nNum2)
//	  Alert(nNum1 == nNum2)
//	  Alert(nNum1 <= nNum2)
//	  Alert(nNum1 >= nNum2)
//	  Alert(nNum1 != nNum2)

	  //OPERADORES DE ATRIBUICAO
	  Alert(nNum1 := 10)
	  Alert(nNum1 += nNum2)
	  Alert(nNum1 -= nNum2)
	  Alert(nNum1 *= nNum2)
	  Alert(nNum1 /= nNum2)
//	  Alert(nNum1 %= nNum2)
	  Alert(nNum1 *= nNum2)

Alert("Valor Final: "+  cValToChar(nNum1))

return