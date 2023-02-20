#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOTVS.CH"  
#INCLUDE "ApWizard.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SzManSB7       ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Geracao de SB7 com base em planilha excel.		      		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SzManSB7()
Local cTexto	:= ""
Local oWizard, oTexto, oTimer
Local aParambox := {}

Private aTipo 		:= {"Substituir Inventario","Acumular Inventário","Zerar Inventario","Limpar Inventario"}
Private aRetParam 	:= {}
Private cEdtP04	  	:= ".T."
Private cEdtP05	  	:= ".T."
Private nOpcAnt		:= 1

//->> Cria Consulta Padrao
AjustaSXB()

aRetParam := {PadR("IN"+StrZero(Day(dDatabase),2)+StrZero(Month(dDatabase),2)+Right(StrZero(Year(dDatabase),4),2),Tamsx3("B7_DOC")[1]),1,.F.,Space(100),Criavar("B2_LOCAL",.F.)}

aAdd(aParambox,{1,"Documento"					,aRetParam[01],"@!"			,"",""		,".T.",25	,.T.}) 
aAdd(aParambox,{2,"Tipo de Processamento" 		,aRetParam[02],aTipo,80		,".T.",.T.}) 
aAdd(aParambox,{5,"Considera Lotes"				,aRetParam[03]		,120	,".T.",.F.}) 
aAdd(aParambox,{1,"Arquivo de Importação"		,aRetParam[04],"@!"			,"","SZARQI","&cEdtP04",150	,.F.}) 
aAdd(aParambox,{1,"Armazem p/Zerar"				,aRetParam[05],"@!"			,"",""		,"&cEdtP05",10	,.F.}) 
      
cTexto := "1) Tipos de Processamento: "+CRLF+CRLF
cTexto += "* SUBSTITUIR INVENTARIO:"+CRLF
cTexto += "  Caso o item em questão da planilha ja exista na importação anterior, ele ira substituir o registro."+CRLF+CRLF

cTexto += "* ACUMULAR INVENTARIO:"+CRLF
cTexto += "  Caso o item em questão da planilha ja exista na importação anterior, ele ira somar no saldo do estoque deste."+CRLF+CRLF

cTexto += "* ZERAR INVENTARIO:"+CRLF
cTexto += "  Gerará movimentos para zerar o inventario de todos os itens da base atual com saldos maiores que zero."+CRLF+CRLF

cTexto += "* LIMPAR INVENTARIO:"+CRLF
cTexto += "  Apagara os registros de inventario."+CRLF+CRLF

cTexto += CRLF 
cTexto += "2) Layout de Planilha CSV: "+CRLF+CRLF 
cTexto += "CONSIDERAR LOTES:"+CRLF
cTexto += "PRODUTO(C) ; ARMAZEM(C) ; Qtde(N) ; LOTE(C) ; VENCIMENTO(DD/MM/AAAA)"+CRLF+CRLF

cTexto += "NÃO CONSIDERANDO LOTES:"+CRLF
cTexto += "PRODUTO(C) ; ARMAZEM(C) ; Qtde(N)"+CRLF+CRLF
                             
DEFINE WIZARD oWizard ;
		TITLE "INVENTARIO" ;
          	HEADER "Importação de SB7" ;
          	MESSAGE "Informe os parametros de geração" ;
          	TEXT "Este procedimento devera gerar os registros de inventario na tabela SB7 com base na importação de uma planilha CSV." PANEL;
          	NEXT {|| .T. } ;
          	FINISH {|| .T. }; 
          	     
    CREATE PANEL oWizard ;				
          	HEADER "Importação de SB7" ;
          	MESSAGE "Atenção" PANEL;
          	NEXT {|| .T. } ;
          	FINISH {|| .T. } ;
          	PANEL      	                      	
    
		    oTexto 	:= tMultiGet():New(	01,;
										01,;  
										{|U|If(Pcount()>0,cTexto:=u, cTexto)},;
										oWizard:GetPanel(2),;
										(oWizard:GetPanel(2):NCLIENTWIDTH/2)-1,;
										(oWizard:GetPanel(2):NCLIENTHEIGHT/2)-22,;
										TFont():New('Courier new',,-12,,.F.),;
										.T.,;
										10,;
										,;
										,;
										.T.,;
										,;
										,;
										{||.T.},;
										,;
										,;
										.T.,;
										,;
										,;
										,;
										.f.,;
										.T.,;
										"Considerar:",;
										1,;
										TFont():New('Courier new',,-12,,.F.),;
										10)
			
          	          	                            
   	CREATE PANEL oWizard ;				
          	HEADER "Parametrização do Inventario" ;
          	MESSAGE "Informe os Parametros de Geração" PANEL;          	
          	NEXT {|| ProcInvent(aRetParam,aTipo) } ;
          	FINISH {|| ProcInvent(aRetParam,aTipo) } ;
          	PANEL
   		Parambox(aParambox,"Parametrização do Inventario",aRetParam,,,,,,oWizard:GetPanel(3),,.F.,.F.)

		oTimer := TTimer():New(500, {|| VldEdtCpos(),If(nOpcAnt<>aRetParam[02],( nOpcAnt:=aRetParam[02],Parambox(aParambox,"Parametrização do Inventario",aRetParam,,,,,,oWizard:GetPanel(3),,.F.,.F.)),.T.) }, /*oWizard:ODLG*/ )
		oTimer:Activate()

   		   		   
ACTIVATE WIZARD oWizard CENTERED
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldEdtCpos     ³ Autor ³Marcelo Celi Marques             ³ Data ³29/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Edicao dos Campos.							      		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldEdtCpos()

If ValType(aRetParam[02])<>"N"
	aRetParam[02] := Ascan(aTipo,{|x| Alltrim(x)==Alltrim(aRetParam[02]) })
EndIf

If aRetParam[02] == 1 .Or. aRetParam[02] == 2
	cEdtP04	 := ".T."
	cEdtP05	 := ".F."
	aRetParam[05] := Criavar("B2_LOCAL",.F.)
ElseIf aRetParam[02] == 3
	cEdtP04	 := ".F."
	cEdtP05	 := ".T."    
	aRetParam[04] := Space(100)
Else
	cEdtP04	 := ".F."
	cEdtP05	 := ".F."	
	aRetParam[04] := Space(100)
	aRetParam[05] := Criavar("B2_LOCAL",.F.)	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInvent     ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento do Inventario.								      		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInvent(aRetParam,aTipo)
Local lRet 		:= .T.
Local aDados	:= {}
Local nX		:= 1

If ValType(aRetParam[02])<>"N"
	aRetParam[02] := Ascan(aTipo,{|x| Alltrim(x)==Alltrim(aRetParam[02]) })
EndIf

If lRet .And. Empty(aRetParam[01])
	lRet := .F.
	MsgAlert("Informar um Documento Valido de Inventario.")
EndIf

If lRet .And. (aRetParam[02]==1 .Or. aRetParam[02]==2) .And. (Empty(aRetParam[04]) .Or. !File(aRetParam[04]))
	lRet := .F.
	MsgAlert("Informar um arquivo valido para a importação.")
EndIf                                                        

If lRet .And. aRetParam[02]==3 .And. Empty(aRetParam[05])
	lRet := .F.
	MsgAlert("Para Gerar o Inventario de itens zerados deve-se informar o armazem.")
EndIf

If lRet .And. aRetParam[02]==4
	lRet := MsgYesNo("Confirma a Limpeza do inventario de documento: "+aRetParam[01]+" ?" )
	If lRet
		Processa( { || LimparInv(aRetParam[01])}, "Aguarde...", "Excluindo o Inventario.")
	EndIf	
EndIf	

Begin Transaction
	If lRet             
		If aRetParam[02]==1	//->> Substituir inventario
			If lRet := MsgYesNo("Confirma a Importação do Inventario: "+aRetParam[01]+" ?" )	
				If aRetParam[03] 
					//->> Com Lotes                   
					FwMsgRun(,{|| aDados := LeCSV(aRetParam[04],.T.) }	, "Aguarde...","Lendo arquivo CSV de Inventario...")
					Processa( { || GravaInv(aRetParam[01],aDados,"S",.T.)}, "Aguarde...", "Gravando Inventario com Lotes em Substituição.")					
					
				Else               
					//->> Sem Lotes                   
					FwMsgRun(,{|| aDados := LeCSV(aRetParam[04],.F.) }	, "Aguarde...","Lendo arquivo CSV de Inventario...")
					Processa( { || GravaInv(aRetParam[01],aDados,"S",.F.)}, "Aguarde...", "Gravando Inventario em Substituição.")					
					
				EndIf		
		    EndIf
		ElseIf aRetParam[02]==2	//->> Acumular inventario
			If lRet := MsgYesNo("Confirma a Importação do Inventario: "+aRetParam[01]+" ?" )			
				If aRetParam[03] 
					//->> Com Lotes                   
					FwMsgRun(,{|| aDados := LeCSV(aRetParam[04],.T.) }	, "Aguarde...","Lendo arquivo CSV de Inventario...")
					Processa( { || GravaInv(aRetParam[01],aDados,"A",.T.)}, "Aguarde...", "Gravando Inventario com Lotes em Acumulação de Saldos.")
					
				Else               
					//->> Sem Lotes                   
					FwMsgRun(,{|| aDados := LeCSV(aRetParam[04],.F.) }	, "Aguarde...","Lendo arquivo CSV de Inventario...")
					Processa( { || GravaInv(aRetParam[01],aDados,"A",.F.)}, "Aguarde...", "Gravando Inventario em Acumulação de Saldos.")					
					
				EndIf	
		    EndIf	
		ElseIf aRetParam[02]==3	//->> Zerar
			If lRet := MsgYesNo("Confirma a Geração do Inventario: "+aRetParam[01]+" Zerando os Saldos?" )		
				If aRetParam[03] 
					//->> Marcelo Celi - DFS - 02/05/2017
					//->> Sem Lotes
					Processa( { || ZeraSemLote(aRetParam[01],aRetParam[05])}, "Aguarde...", "Gravando Inventario zerado.")					
					//->> Com Lotes  	      
					Processa( { || ZeraLote(aRetParam[01],aRetParam[05]) }, "Aguarde...", "Gravando Inventario com lotes zerados.")
					
				Else
					//->> Sem Lotes
					Processa( { || ZeraSemLote(aRetParam[01],aRetParam[05])}, "Aguarde...", "Gravando Inventario zerado.")
					
				EndIf                              
			EndIf	
		EndIf	
	EndIf
End Transaction
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSXB      ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajustes do dicionario de consultas padrao.				      		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSXB()
Local aSXB		:= {}  
Local aEstrut	:= {}
Local i, j
Local aArea		:= GetArea()     

aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"		}
Aadd( aSXB,	{"SZARQI"	,"1"		,"01"		,"RE"			,"Arquivo de Inventario"		,"Arquivo de Inventario"		,"Arquivo de Inventario"		,"SB2"				})
Aadd( aSXB,	{"SZARQI"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."				})
Aadd( aSXB,	{"SZARQI"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_SzGetManB7(1)"	})	

For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS))+PadR(aSXB[i,2],Len(SXB->XB_TIPO))+PadR(aSXB[i,3],Len(SXB->XB_SEQ))+PadR(aSXB[i,4],Len(SXB->XB_COLUNA)))
			RecLock("SXB",.T.)			
		Else
			RecLock("SXB",.F.)			
		EndIf
		For j:=1 To Len(aSXB[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()		
	EndIf
Next i

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SzGetManB7     ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao dos campos dos parametros pelas consultas do SXB.   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SzGetManB7(nTipo)
Local cVariavel := ""
Local cArquivo	:= ""

If nTipo==1		//->> SITUACAO DO FUNCIONARIO
    cVariavel 		:= aRetParam[04]
    cArquivo		:= aRetParam[04]
	&(Readvar()) 	:= aRetParam[04]
	cArquivo:=cGetFile("Arquivo (*.CSV) | *.CSV","Arquivo...",0,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	If Empty(cArquivo)    
		aRetParam[04] := cVariavel
    Else                          
    	aRetParam[04] := cArquivo
    EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LeCSV		     ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le Arquivo Csv.												   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeCSV(cArquivo,lLote)
Local aDados	:= {}
Local aStruct	:= {}
Local nX		:= 0                
Local xBuffer	:= ""

Local cArqTmpCsv := Alltrim(GetTempPath()) + CriaTrab(,.F.)+".CSV" 
Local cArqTmpDbf := CriaTrab(,.F.)+".DBF"
Local ArqCsv	 := cArquivo
	
Local nTot		 := 0     
Local cDocumen	 := ""	
Local lErro		 := .F.

Private lMsErroAuto := .F.
				
nTerHdl :=fOpen(ArqCsv,2+64)
If nTerHdl <= 0
	MsgAlert("Arquivo de Importação não informado ou em aberto por outro programa. Importação não realizada.","Atenção")
	Return {}
EndIf

nTamArq :=fSeek(nTerHdl,0,2)
xBuffer :=Space(nTamArq)
fSeek(nTerHdl,0,0)
fRead(nTerHdl,@xBuffer,nTamArq)
cStrCsv  :=xBuffer
fClose(nTerHdl)

cStrCsv := StrTran(cStrCsv,",","#")        
cStrCsv := StrTran(cStrCsv,";",",")
cStrCsv := StrTran(cStrCsv,",,",", ,")
        
nTerHdl := FCreate(cArqTmpCsv)
fWrite(nTerHdl,cStrCsv)
fClose(nTerHdl)

Aadd(aStruct,{"COLUNA_A"	,"C",50	,0})
Aadd(aStruct,{"COLUNA_B"	,"C",50	,0})  
Aadd(aStruct,{"COLUNA_C"	,"C",50	,0}) 
If lLote
	Aadd(aStruct,{"COLUNA_D"	,"C",50	,0}) 
	Aadd(aStruct,{"COLUNA_E"	,"C",50	,0}) 
EndIf
			
dbCreate(cArqTmpDbf,aStruct)
dbUseArea( .T.,"dbfcdx",cArqTmpDbf,"PLAN_EXCEL",.F.,.F.)
		
If !Select("PLAN_EXCEL") > 0 
	Return {}
EndIf	
                                                                                                                                                                                                                       
Append from &cArqTmpCsv delimited with ","

dbSelectArea("PLAN_EXCEL")
dbGotop()
ProcRegua(RecCount())
Do While !Eof()
	IncProc("Importando Planilha Excel")	
	
	PLAN_EXCEL->COLUNA_A  := StrTran(PLAN_EXCEL->COLUNA_A,"#",",") 
	PLAN_EXCEL->COLUNA_B  := StrTran(PLAN_EXCEL->COLUNA_B,"#",",") 
	PLAN_EXCEL->COLUNA_C  := StrTran(PLAN_EXCEL->COLUNA_C,"#",".")
	If lLote
		PLAN_EXCEL->COLUNA_D  := StrTran(PLAN_EXCEL->COLUNA_D,"#",",")
		PLAN_EXCEL->COLUNA_E  := StrTran(PLAN_EXCEL->COLUNA_E,"#",",")
	EndIf
	
	If lLote
		aAdd(aDados,{	PadR(Alltrim(PLAN_EXCEL->COLUNA_A),Tamsx3("B7_COD")[1]) ,;
						PadR(Alltrim(PLAN_EXCEL->COLUNA_B),Tamsx3("B7_LOCAL")[1]) ,;
						Val(Alltrim(PLAN_EXCEL->COLUNA_C)),;
						PadR(Alltrim(PLAN_EXCEL->COLUNA_D),Tamsx3("B7_LOTECTL")[1]),;
						cTod(Alltrim(PLAN_EXCEL->COLUNA_E))})
	Else                                                     
		aAdd(aDados,{	PadR(Alltrim(PLAN_EXCEL->COLUNA_A),Tamsx3("B7_COD")[1]) ,;
						PadR(Alltrim(PLAN_EXCEL->COLUNA_B),Tamsx3("B7_LOCAL")[1]) ,;
						Val(Alltrim(PLAN_EXCEL->COLUNA_C))})	
	EndIf					
	dbSkip()                                                   
EndDo

If Select("PLAN_EXCEL") > 0
	PLAN_EXCEL->(dbCloseArea())
	FErase(cArqTmpDbf+GetDBExtension())		
EndIf
    
Return aDados

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ZeraLote	     ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Zera o Inventario dos itens com lote.						   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ZeraLote(cDocumento,cLocal)
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()
Local nRecno	:= 0
Local nCount	:= 0

cQuery := "SELECT SB8.* FROM "+RetSqlName("SB8")+" SB8 "+CRLF
cQuery += "	WHERE 	SB8.D_E_L_E_T_ = ' ' "
cQuery += "		AND SB8.B8_FILIAL = '"+xFilial("SB8")+"' "+CRLF	
cQuery += "		AND SB8.B8_LOCAL = 	'"+cLocal+"'"+CRLF
cQuery += "		AND SB8.B8_SALDO > 0 "+CRLF
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

dbEval({|x| nCount++},,{|| !(cAlias)->(Eof())})
(cAlias)->(dbGotop())
ProcRegua(nCount)

Do While !(cAlias)->(Eof())
	IncProc("Gerando Inventario de Itens Zerados com lote.")
	
	nRecno := GetRecSB7(PadR(cDocumento,Tamsx3("B7_DOC")[1]),(cAlias)->B8_PRODUTO,(cAlias)->B8_LOCAL,(cAlias)->B8_LOTECTL,(cAlias)->B8_NUMLOTE)
	If nRecno == 0
   		Reclock("SB7",.T.)
        SB7->B7_FILIAL := xFilial("SB7")
		SB7->B7_COD    := (cAlias)->B8_PRODUTO
		SB7->B7_DOC    := cDocumento	
		SB7->B7_QUANT  := 0
		SB7->B7_LOCAL  := (cAlias)->B8_LOCAL
		SB7->B7_LOTECTL:= (cAlias)->B8_LOTECTL
		SB7->B7_DTVALID:= Stod((cAlias)->B8_DTVALID)
		SB7->B7_DATA   := dDatabase
		SB7->B7_STATUS := "1"        	
		SB7->(MsUnlock())			
    Else                            
    	SB7->(dbGoto(nRecno))
    	Reclock("SB7",.F.)
        SB7->B7_QUANT  := 0
		SB7->(MsUnlock())
    EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())
	
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetRecSB7      ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o recno do registro caso exista.						   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetRecSB7(cDocumento,cProduto,cLocal,cLote)
Local nRecno := 0
Local cQuery := ""
Local cAlias := "TRB_SB7"

cQuery := "SELECT R_E_C_N_O_ AS RECSB7 FROM "+RetSqlName("SB7")+" SB7 "+CRLF
cQuery += "	WHERE 	SB7.D_E_L_E_T_ = ' ' "
cQuery += "		AND SB7.B7_FILIAL  = '"+xFilial("SB7")+"' "+CRLF	
cQuery += "		AND SB7.B7_DOC 	   = '"+cDocumento+"' "+CRLF	
cQuery += "		AND SB7.B7_COD 	   = '"+cProduto+"' "+CRLF	
cQuery += "		AND SB7.B7_LOCAL   = '"+cLocal+"' "+CRLF	 
cQuery += "		AND SB7.B7_LOTECTL = '"+cLote+"' "+CRLF
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
If !(cAlias)->(Eof()) .And. !(cAlias)->(Bof())
	nRecno := (cAlias)->RECSB7
EndIf
(cAlias)->(dbCloseArea())

Return nRecno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ZeraSemLote    ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Zera o Inventario dos itens sem lote.						   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ZeraSemLote(cDocumento,cLocal)
Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()
Local nCount	:= 0

cQuery := "SELECT SB2.* FROM "+RetSqlName("SB2")+" SB2 "+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB2.B2_COD = SB1.B1_COD "+CRLF
cQuery += "	WHERE 	SB1.D_E_L_E_T_ = ' ' AND SB2.D_E_L_E_T_ = ' ' "
cQuery += "		AND SB1.B1_RASTRO NOT IN ('L','S') "+CRLF
cQuery += "		AND SB2.B2_LOCAL  = '"+cLocal+"' "+CRLF 
cQuery += "		AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF	
cQuery += "		AND SB2.B2_FILIAL = '"+xFilial("SB2")+"' "+CRLF	
cQuery += "		AND SB2.B2_QATU <> 0 "+CRLF
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
                    
dbEval({|x| nCount++},,{|| !(cAlias)->(Eof())})
(cAlias)->(dbGotop())
ProcRegua(nCount)
                                            
Do While !(cAlias)->(Eof())
	IncProc("Gerando Inventario de Itens Zerados sem lote.")
	
    SB7->(dbSetOrder(3))
	If !SB7->(dbSeek(xFilial("SB7")+PadR(cDocumento,Tamsx3("B7_DOC")[1])+PadR((cAlias)->B2_COD,Tamsx3("B7_COD")[1])+PadR((cAlias)->B2_LOCAL,Tamsx3("B7_LOCAL")[1])))
        Reclock("SB7",.T.)
        SB7->B7_FILIAL := xFilial("SB7")
		SB7->B7_COD    := (cAlias)->B2_COD
		SB7->B7_DOC    := cDocumento	
		SB7->B7_QUANT  := 0
		SB7->B7_LOCAL  := (cAlias)->B2_LOCAL
		SB7->B7_DATA   := dDatabase
		SB7->B7_STATUS := "1"        	
	    SB7->(MsUnlock())			
	Else                            
		Reclock("SB7",.F.)
		SB7->B7_QUANT  := 0
	    SB7->(MsUnlock())				
	EndIf                   
	
	SB2->(dbSetOrder(1))
	If !SB2->(dbSeek(xFilial("SB2")+SB7->B7_COD+SB7->B7_LOCAL))
		CriaSB2(SB7->B7_COD,SB7->B7_LOCAL)
	EndIf			
	
    (cAlias)->(dbSkip())
EndDo    	    
(cAlias)->(dbCloseArea())
	
Return 
                                     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaInv       ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Zera o Inventario dos itens sem lote.						   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaInv(cDocumento,aDados,cTipo,lLote)
Local nX 	:= 1
Local nRecno:= 0
            
ProcRegua(Len(aDados))    
For nX:=1 to Len(aDados)
	IncProc()
	If !lLote
		SB7->(dbSetOrder(3))
		If !SB7->(dbSeek(xFilial("SB7")+PadR(cDocumento,Tamsx3("B7_DOC")[1])+PadR(aDados[nX,01],Tamsx3("B7_COD")[1])+PadR(aDados[nX,02],Tamsx3("B7_LOCAL")[1])))
	        Reclock("SB7",.T.)
	        SB7->B7_FILIAL := xFilial("SB7")
			SB7->B7_COD    := aDados[nX,01]
			SB7->B7_DOC    := cDocumento	
			SB7->B7_QUANT  := aDados[nX,03]
			SB7->B7_LOCAL  := aDados[nX,02]
			SB7->B7_DATA   := dDatabase
			SB7->B7_STATUS := "1"        	
		    SB7->(MsUnlock())			
		Else                            
			Reclock("SB7",.F.)
			If cTipo=="S"	
				SB7->B7_QUANT  := aDados[nX,03]
			Else                               
				SB7->B7_QUANT  += aDados[nX,03]			
			EndIf	
		    SB7->(MsUnlock())				
		EndIf                   
	Else
		nRecno := GetRecSB7(PadR(cDocumento,Tamsx3("B7_DOC")[1]),aDados[nX,01],aDados[nX,02],aDados[nX,04])
		If nRecno == 0
	   		Reclock("SB7",.T.)
	        SB7->B7_FILIAL := xFilial("SB7")
			SB7->B7_COD    := aDados[nX,01]
			SB7->B7_DOC    := cDocumento	
			SB7->B7_QUANT  := aDados[nX,03]
			SB7->B7_LOCAL  := aDados[nX,02]
			SB7->B7_LOTECTL:= aDados[nX,04]
			SB7->B7_DTVALID:= aDados[nX,05]
			SB7->B7_DATA   := dDatabase
			SB7->B7_STATUS := "1"        	
			SB7->(MsUnlock())			
	    Else                            
	    	SB7->(dbGoto(nRecno))
	    	Reclock("SB7",.F.)
	        If cTipo=="S"				
	        	SB7->B7_QUANT  := aDados[nX,03]
	        Else
		        SB7->B7_QUANT  += aDados[nX,03]
	        EndIf	
			SB7->(MsUnlock())
	    EndIf	
	EndIf	
	
	SB2->(dbSetOrder(1))
	If !SB2->(dbSeek(xFilial("SB2")+SB7->B7_COD+SB7->B7_LOCAL))
		CriaSB2(SB7->B7_COD,SB7->B7_LOCAL)
	EndIf			
	
Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LimparInv      ³ Autor ³Marcelo Celi Marques             ³ Data ³28/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpar o Inventario.											   		  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SALOMAO E ZOPPI DIAGNOSTICOS							              		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LimparInv(cDocumento)
Local nX 	:= 1

ProcRegua(0)
SB7->(dbSetOrder(3))
SB7->(dbSeek(xFilial("SB7")+PadR(cDocumento,Tamsx3("B7_DOC")[1])))
Do While !SB7->(Eof()) .And. SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DOC == PadR(cDocumento,Tamsx3("B7_DOC")[1])
	IncProc("Excluindo o Inventario "+cDocumento)
	Reclock("SB7",.F.)
	Delete
	SB7->(MsUnlock())
	SB7->(dbSkip())
EndDo

Return
