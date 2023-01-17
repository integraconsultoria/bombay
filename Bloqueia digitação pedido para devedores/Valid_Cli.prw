#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"  

//-------------------------------------------------------------------
/*/{Protheus.doc} Valid_Cli
@description  Valida Usuário.
@author  Ronaldo Carvalho
@type	 User Function
@since   05/06/2019
@version All versions Andre
/*/ 
//-------------------------------------------------------------------

User Function Valid_Cli()

Local aArea        := GetArea()
Local lRet         := .T. 
Local cQuery       :=  ""  
Local nValor       := SUPERGETMV("ID_NVALMIN") 
Local cCliente     := SUPERGETMV("ID_CCLINOT")

	cQuery    := "SELECT E1_NUM,E1_VENCREA,E1_CLIENTE "
	cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery    += " Where SE1.E1_CLIENTE  = '" + M->C5_CLIENTE + "' "
	cQuery    += " AND   SE1.E1_SALDO > '" + nValor + "' " 
	cQuery    += " AND   SE1.E1_LOJA = '" + M->C5_LOJACLI + "' " 
	cQuery    += " AND   SE1.E1_TIPO NOT IN ('NCC','RA') "
	cQuery    += " AND   SE1.D_E_L_E_T_ <> '*' "
	
	TcQuery cQuery New Alias "cAlias" 
	
	DbSelectArea("cAlias")
	cAlias->(DbGoTop())

	While cAlias->(!Eof()) 
	  
	  //  Entender pq não funcionou
	  //  If  (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_RISCO") ="A") .OR. (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XORIGEM") <> "")
      
	     If  (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_RISCO") ="A") 
	       lRet := .T.			
	       Exit
	    EndIf  

         If  (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XORIGEM") = "E")
	       lRet := .T.			
	       Exit
	    EndIf  

		 If  M->C5_TIPO <> 'N'
	       lRet := .T.			
	       Exit
	    EndIf  

		If cAlias->E1_VENCREA < Dtos(dDatabase)
            Alert("Este Cliente Possui Título Vencido!" )
			lRet := .F.			
			Exit 
	    EndIf		
       cAlias->(DbSkip())
	End
			
	cAlias->(DbCloseArea())

RestArea(aArea)
Return ( lRet )
