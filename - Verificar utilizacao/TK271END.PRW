
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} TK271END
//TODO Descrição auto-gerada.
@author Pedro Lima
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TK271END()     

Local aArea := GetArea() 
Local cMemo := "" 

If FunName() == "TMKA271" 
      
    DbSelectArea("SC6") 
    SC6->(DbSetOrder(1)) 
    If dbSeek(xFilial("SC6") + SC5->C5_NUM) 
       
       While SC6->(!EOF()) .AND. SC6->C6_NUM == SC5->C5_NUM
      
         RecLock("SC6",.F.) 
         SC6->C6_PRUNIT := 0.00 // Observação Comercial do Televendas que será gravado na Observação personalizada do Pedido de Vendas 
         SC6->(MsUnlock())     
          
         SC6->(DbSkip()) 
       
       EndDo 

    Endif 
    
     SC5->(DbCloseArea()) 
                                                                                      
Endif 

RestArea( aArea ) 

Return