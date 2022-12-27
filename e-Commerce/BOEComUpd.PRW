#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#include 'fileio.ch'

//************************************************************>> COMPATIBILIZADOR << ******

#DEFINE X3_USADO_EMUSO 		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"
#DEFINE X3_USADO_NAOUSADO 	"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x"      

Static lFWCodFil := FindFunction("FWCodFil")

/*/{protheus.doc} BOEComUpd
*******************************************************************************************
Compatibilizador/update das operacoes do controle de ecommerce
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOEComUpd()
Local aSM0:= {}
Local oWizard        
Local oFont3  	:= TFont():New("Arial",07,12,,.T.,,,,.T.,.F.)
Local cUsuRep 	:= Space(15)
Local cUsuPsw 	:= space(15)
Local aEmpFil 	:= {}	  
Local lExclusiv := .F. 

Private oNo 		:= LoadBitmap( GetResources(), "LBNO" 	)
Private oOk 		:= LoadBitmap( GetResources(), "LBTIK"	)    
Private oLbxFils	:= NIL
Private aFiliais 	:= {{.F.,"",""}} 
Private lRunDblClick:= .T.    
Private lChkTWiz 	:= .F.     
              
MsgRun("Abrindo Ambiente...",,{ || lExclusiv := Inicializa(@aSM0,@aFiliais,@aEmpFil) })
			                  
cMsg := "Este Programa tem o objetivo de criar os dicionarios dos processos de ecommerce."+CRLF
cMsg += CRLF
cMsg += CRLF

If lExclusiv
	cMsg += "Avançar para a Continuar..."
Else
	cMsg += "Existem conexões no sistema que impedem o uso do compatibilizador nesse momento..."
EndIf	

DEFINE WIZARD oWizard 											;
		TITLE "Compatibilizador"								;
          	HEADER "CONTROLE DE E-COMMERCE"		        		;
          	MESSAGE "Update"									;
         	TEXT cMsg PANEL										;
          	NEXT 	{|| lExclusiv }								;
          	FINISH 	{|| lExclusiv }								; 
          	      
  	CREATE PANEL oWizard 										;				
          	HEADER "CONTROLE DE E-COMMERCE"				        ;
          	MESSAGE "Identificação - Update" PANEL				;          	
          	BACK 	{|| .F. }									;
          	NEXT 	{|| AutUser(cUsuRep,cUsuPsw,aEmpFil)}		;
          	FINISH 	{|| AutUser(cUsuRep,cUsuPsw,aEmpFil)}		;
          	PANEL
   	      
          	      
   	@ 010,010 Say "Usuário:"					Size  50, 09 Of oWizard:GetPanel(2) Pixel 
	@ 008,035 Get cUsuRep						Size  70, 09 Of oWizard:GetPanel(2) Pixel Font oFont3
			
	@ 023,010 Say "Senha:"						Size  50, 09 Of oWizard:GetPanel(2) Pixel 
	@ 021,035 MsGet cUsuPsw PassWord			Size  70, 09 Of oWizard:GetPanel(2) Pixel Font oFont3
			
          	          	                            
   	CREATE PANEL oWizard 								;				
          	HEADER "CONTROLE DE E-COMMERCE"	        	;
          	MESSAGE "Empresas - Update" PANEL			;          	
          	BACK 	{|| .F. }							;
          	NEXT 	{|| ProcUpdate(aSM0,aFiliais)}		;
          	FINISH 	{|| ProcUpdate(aSM0,aFiliais)}		;
          	PANEL
   		
   	@ 000, 000 LISTBOX oLbxFils FIELDS HEADER 	""								,;
				   								"Empresa"						,;
												"Nome"							;
									COLSIZES 	5								,;
												25 								,;
								 				30								 ;
							SIZE (oWizard:GetPanel(3):NWIDTH/2)-2,(oWizard:GetPanel(3):NHEIGHT/2)-2;
							ON DBLCLICK (If(!Empty(aFiliais[oLbxFils:nAt,2]),aFiliais[oLbxFils:nAt,1]:=!aFiliais[oLbxFils:nAt,1],aFiliais[oLbxFils:nAt,1]:=oLbxFils[oLbxFils:nAt,1]),If(!aFiliais[oLbxFils:nAt,1],lChkTWiz := .F., ),oLbxFils:Refresh(.f.)) OF oWizard:GetPanel(3) PIXEL 		

	oLbxFils:SetArray(aFiliais)	
	oLbxFils:bLine := {|| {If(aFiliais[oLbxFils:nAt,1],oOK,oNO),aFiliais[oLbxFils:nAt,2],aFiliais[oLbxFils:nAt,3]}}    
	oLbxFils:bRClicked 		:= { || AEVAL(aFiliais,{|x|x[1]:=!x[1]}), oLbxFils:Refresh(.F.)}    	
	oLbxFils:bHeaderClick 	:= {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aFiliais, {|e| IF(!Empty(e[2]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxFils:Refresh()}
   		   		   
ACTIVATE WIZARD oWizard CENTERED
	
Return

/*/{protheus.doc} Inicializa
*******************************************************************************************
Inicializa o ambiente
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function Inicializa(aSM0,aFiliais,aEmpFil)
Local lExclusiv := FINOpenSM0(@aSM0,@aFiliais,@aEmpFil)

If lExclusiv
	RpcSetEnv( aEmpFil[01], aEmpFil[02] ,,, "COM","UPDATE",{ "SC7" } )
	SetFlatControls(.F.)
	MsApp():New('SIGAMDI')              
	InitPublic()
	SetSkinDefault()
	RpcClearEnv() 	
EndIf
      
Return lExclusiv

/*/{protheus.doc} AutUser
*******************************************************************************************
Autentica o usuario para aplicar o update
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AutUser(cUsuRep,cUsuPsw,aEmpFil)
Local cCodUsr := ""
Local lProc   := .T.

If lProc .And. !Empty(cUsuRep) 
	MsgRun("Validando Usuario e Senha...",,{ || lProc := RpcSetEnv( aEmpFil[1], aEmpFil[2], cUsuRep, cUsuPsw, "FAT", "PORTAL", { "SE5","SE8" } ) })
	If !lProc
		MsgAlert("Usuário não validado."+CRLF+"Acesso negado...")
		RpcClearEnv()
	Else
		cCodUsr := RetCodUsr()
		RpcClearEnv()
	EndIf
Else
	MsgAlert("Usuário e Senha não validado...")
	lProc := .F.
EndIf

Return(lProc)

/*/{protheus.doc} FINOpenSM0
*******************************************************************************************
Realiza a abertura da tabela SM0 em exclusivo.
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function FINOpenSM0(aSM0,aFiliais,aEmpFil)
Local nLoop := 0 
Local lOpen := .F. 
Local nX	:= 1
Local nPos	:= 0

aSM0 	:= {}
aFiliais:= {} 
aEmpFil := {}

//For nLoop := 1 To 20
	//dbUseArea(.T., , "SIGAMAT.EMP", "SM0", .T., .F.)
	//If !Empty(Select("SM0"))
	//	lOpen := .T.
	//	dbSetIndex("SIGAMAT.IND")
	//	Exit
	//EndIf
	//Sleep(500)
//Next nLoop

RpcSetEnv( "01", "0101" ,,, "COM","UPDATE",{ "SC7" } )

lOpen := .T.

If !lOpen
	Aviso( "Atencao!", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva!" , {"Ok"}, 2)
Else
	MsgRun("Selecionando as Empresas para aplicação...",,{|| CursorWait(), aSM0:= AdmAbreSM0() ,CursorArrow()})
	For nX:=1 to Len(aSM0)
		nPos := Ascan(aFiliais,{|x| Alltrim(x[02])==Alltrim(aSM0[nX,01])})
		If nPos == 0		
			aAdd(aFiliais,{.F.,aSM0[nX,01],aSM0[nX,06],{}})
			nPos := Len(aFiliais)
		EndIf	
		aAdd(aFiliais[nPos,04],aSM0[nX,02])
		
		If Len(aEmpFil)==0
			aEmpFil := {aSM0[nX,01],aSM0[nX,02]}
		EndIf
	Next nX
EndIf
     	
Return lOpen

/*/{protheus.doc} ProcUpdate
*******************************************************************************************
Processamento do Update
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcUpdate(aSM0,aFiliais)
Local nInc 		:= 0  
Local lRet		:= .F.  
Local nPos		:= 0

Private oGetUpd

If MsgYesNo("Confirma o Compatibilizador das operacoes de e-commerce?"+CRLF+"PERSONALIZAÇÃO DE VENDAS")
	OpenSm0Excl()	
	lRet := .T.
	For nInc :=1 to Len(aFiliais)
		If aFiliais[nInc][01]
			nPos := Ascan(aSM0,{|x| Alltrim(x[01])==Alltrim(aFiliais[nInc][02]) })
			If nPos > 0
				RpcSetType(3)
				MsgRun("Aguarde... Abrindo o ambiente da empresa ["+Alltrim(aSm0[nPos][1])+"]..."   ,,{ || CursorWait(), RpcSetEnv( aSm0[nPos][1],aSm0[nPos][2]) ,CursorArrow()})				
				MsgRun("Atualizando a Base..."                                                      ,,{ || UpdDics(.T.) })
				RpcClearEnv()
				OpenSm0Excl()
			EndIf	
		EndIf	
	Next
Else
	lRet := .F.
EndIf
	    	
Return lRet

/*/{protheus.doc} AdmAbreSM0
*******************************************************************************************
Abre a tabela SM0 exclusiva garantindo que ninguem esta usando o sistema.
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AdmAbreSM0()
Local aAux			:= {}
Local aRetSM0		:= {}
Local aRetEmp		:= {}
Local lFWLoadSM0	:= .F.	// FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )
Local nX            := 0

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }
		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

//SM0->(dbCloseArea())
RpcClearEnv()
                         
For nX:=1 to Len(aRetSM0)
	If !Empty(aRetSM0[nX,01]) .And. !Empty(aRetSM0[nX,02]) .And. Ascan(aRetEmp,{|x| x[01]==aRetSM0[nX,01]})==0 
		aAdd(aRetEmp,aRetSM0[nX])
	EndIf
Next nX

Return aRetEmp

/*/{protheus.doc} UpdDics
*******************************************************************************************
Compatibilizador de tabelas x campos.
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function UpdDics(lFisico)
Local aTabelas  := {"ZWS","ZWT","ZWU","SC5","SB1","SB2","DA1","SA1","SBM"}
Local aSXA 		:= {} 
Local aSX2 		:= {} 
Local aSX3 		:= {} 
Local aSX6 		:= {} 
Local aSX7 		:= {} 
Local aSIX 		:= {} 
Local aEstrut	:= {}
Local i, j, nX
Local nTamFil 	:= GetTamSXG("033",TAMSX3("E2_FILIAL")[1])[1]

Default lFisico	:= .T.
              
Private lUpdAuto 

//->> Criacao da Tabela
aEstrut:= 	{"X2_CHAVE"		,"X2_PATH"		,"X2_ARQUIVO"	,"X2_NOME"					    ,"X2_NOMESPAC"					,"X2_NOMEENGC"			   		,"X2_DELET"	,"X2_MODO"	,"X2_TTS"	,"X2_ROTINA"	}
aAdd( aSX2, {"ZWS" 			,"\DADOSADV\"	, "ZWS010"		,"Comunicações do e-Commerce"   ,"Comunicações do e-Commerce"   ,"Comunicações do e-Commerce"	,0			,"E"		," "		,"             "}) 
aAdd( aSX2, {"ZWT" 			,"\DADOSADV\"	, "ZWT010"		,"Erros Integracao e-Commerce"  ,"Erros Integracao e-Commerce"  ,"Erros Integracao e-Commerce"	,0			,"E"		," "		,"             "}) 
aAdd( aSX2, {"ZWU" 			,"\DADOSADV\"	, "ZWU010"		,"Erros Integracao e-Commerce"  ,"Erros Integracao e-Commerce"  ,"Erros Integracao e-Commerce"	,0			,"E"		," "		,"             "}) 

dbSelectArea("SX2")
dbSetOrder(1)
dbSeek("SE1")
cPath := SX2->X2_PATH
cNome := Substr(SX2->X2_ARQUIVO,4,5)

For i:= 1 To Len(aSX2)
	If !dbSeek(aSX2[i,1])
		RecLock("SX2",.T.) 
	Else
		RecLock("SX2",.F.)	
	EndIf			
	For j:=1 To Len(aSX2[i])
		If FieldPos(aEstrut[j]) > 0
			FieldPut(FieldPos(aEstrut[j]),aSX2[i,j])
		EndIf
	Next j
	SX2->X2_PATH    := cPath
	SX2->X2_ARQUIVO := aSX2[i,1]+cNome
	dbCommit()
	MsUnLock()
Next i

//->> Criacao dos campos da tabela
aEstrut:= 	{	"X3_ARQUIVO","X3_ORDEM" ,"X3_CAMPO"  	,"X3_TIPO"  ,"X3_TAMANHO"				,"X3_DECIMAL"				,"X3_TITULO" 			,"X3_TITSPA"    ,"X3_TITENG"    ,"X3_DESCRIC"		    					,"X3_DESCSPA"	,"X3_DESCENG"	,"X3_PICTURE"					,"X3_VALID" 									            							,"X3_USADO"  		,"X3_RELACAO"																		,"X3_F3"			,"X3_NIVEL" ,"X3_RESERV","X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"									,"X3_CBOX"   																,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN" 							 	,"X3_INIBRW"	                                                            	,"X3_GRPSXG","X3_FOLDER"	,"X3_PYME"	}			
aAdd( aSX3,	{ 	"ZWS"		,"01"		,"ZWS_FILIAL"	,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""				,""				,"@!"							,""													            						,X3_USADO_NAOUSADO	,"" 																				,""					,0			,"  x  x x"	,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"02"		,"ZWS_DATA" 	,"D"		, 8		                    , 0							,"Data"	        		,""		    	,""			    ,"Data"	    	         					,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"03"		,"ZWS_HORA" 	,"C"		, 8		                    , 0							,"Hora"	        		,""		    	,""			    ,"Hora"	    	         					,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"04"		,"ZWS_OPER" 	,"C"		, 1		                    , 0							,"Operacao"	       		,""		    	,""			    ,"Operacao"	    	         				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Subida;D=Descida"														,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"05"		,"ZWS_TIPO" 	,"C"		, 1		                    , 0							,"Tipo"	       	    	,""		    	,""			    ,"Tipo"	    	            				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"C=Cliente;P=Produto;T=Categoria;E=Estoque;R=Preco;V=Venda"				,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"06"		,"ZWS_CONN" 	,"C"		, 1		                    , 0							,"Conexao"	       	   	,""		    	,""			    ,"Conexao"	    	            			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"J=JOB;T=Tela"							                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"07"		,"ZWS_USER" 	,"C"		, 20		                , 0							,"Usuario"	       	   	,""		    	,""			    ,"Usuario"	    	            			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"08"		,"ZWS_MOVIM" 	,"D"		, 8		                    , 0							,"Movimento"	     	,""		    	,""			    ,"Movimento"	    	         			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"09"		,"ZWS_QTDREG" 	,"N"		, 09		                , 0							,"Qtd Regs Extraid"	    ,""		    	,""			    ,"Qtd Registros Extraidos"	    	      	,""				,""				,"@E 999,999,999"      			,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"10"		,"ZWS_QTDGRV" 	,"N"		, 09		                , 0							,"Qtd Regs Gravados"    ,""		    	,""			    ,"Qtd Registros Gravados"	    	      	,""				,""				,"@E 999,999,999"      			,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"11"		,"ZWS_INICIO" 	,"C"		, 20		                , 0							,"Inicio Process"       ,""		    	,""			    ,"Inicio do Processamento"	    	      	,""				,""				,"@!"                  			,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"12"		,"ZWS_FINAL" 	,"C"		, 20		                , 0							,"Final Process"       ,""		    	,""			    ,"Final do Processamento"	    	      	,""				,""				,"@!"                  			,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWS"		,"13"		,"ZWS_ERROS" 	,"N"		, 09		                , 0							,"Qtd Erros"      	    ,""		    	,""			    ,"Qtd Erros"				    	      	,""				,""				,"@E 999,999,999"      			,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

aAdd( aSX3,	{ 	"ZWT"		,"01"		,"ZWT_FILIAL"	,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""				,""				,"@!"							,""													            						,X3_USADO_NAOUSADO	,"" 																				,""					,0			,"  x  x x"	,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"02"		,"ZWT_DATA" 	,"D"		, 8		                    , 0							,"Data"	        		,""		    	,""			    ,"Data"	    	         					,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"03"		,"ZWT_HORA" 	,"C"		, 8		                    , 0							,"Hora"	        		,""		    	,""			    ,"Hora"	    	         					,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"04"		,"ZWT_OPER" 	,"C"		, 1		                    , 0							,"Operacao"	       		,""		    	,""			    ,"Operacao"	    	         				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Subida;D=Descida"														,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"05"		,"ZWT_TIPO" 	,"C"		, 1		                    , 0							,"Tipo"	       	    	,""		    	,""			    ,"Tipo"	    	            				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"C=Cliente;P=Produto;E=Estoque;V=Venda"									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"06"		,"ZWT_CHAVE" 	,"C"		, 20		                , 0							,"Chave"	       		,""		    	,""			    ,"Chave"	    	          	 			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"07"		,"ZWT_CONN" 	,"C"		, 1		                    , 0							,"Conexao"	       	   	,""		    	,""			    ,"Conexao"	    	            			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"J=JOB;T=Tela"							                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"08"		,"ZWT_USER" 	,"C"		, 20		                , 0							,"Usuario"	       	   	,""		    	,""			    ,"Usuario"	    	            			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"09"		,"ZWT_WSOPER" 	,"C"		, 30		                , 0							,"WS Operacao"	       	,""		    	,""			    ,"WS Operacao"	    	           			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"10"		,"ZWT_WSREQU" 	,"M"		, 10		                , 0							,"Request"	       		,""		    	,""			    ,"Request"	    	          	 			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"11"		,"ZWT_WSRESP" 	,"M"		, 10		                , 0							,"Response"	       		,""		    	,""			    ,"Response"	    	          	 			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWT"		,"12"		,"ZWT_ERRPRO" 	,"M"		, 10		                , 0							,"Erro Protheus"	   	,""		    	,""			    ,"Erro Protheus"	    	          		,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""		                				                            		,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

//->> Marcelo Celi - 31/12/2020
aAdd( aSX3,	{ 	"ZWU"		,"01"		,"ZWU_FILIAL"	,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""				,""				,"@!"							,""													            						,X3_USADO_NAOUSADO	,"" 																				,""					,0			,"  x  x x"	,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWU"		,"02"		,"ZWU_IDECOM" 	,"C"		, 15	                    , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	         				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWU"		,"03"		,"ZWU_PEDECO" 	,"C"		, 15	                    , 0							,"Ped Ecomm"	    	,""		    	,""			    ,"Ped Ecomm"	    	     				,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWU"		,"04"		,"ZWU_OBS" 		,"C"		, 180	                    , 0							,"Observacao"	      	,""		    	,""			    ,"Observacao"	    	         			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWU"		,"05"		,"ZWU_ERRO"		,"M"		, 10	                    , 0							,"Observacao"	      	,""		    	,""			    ,"Observacao"	    	         			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"ZWU"		,"06"		,"ZWU_DATA"		,"C"		, 25	                    , 0							,"Data Venda"	      	,""		    	,""			    ,"Data Venda"	    	         			,""				,""				,""       						,""	                                                					            	,X3_USADO_EMUSO		,""            														             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

//->> Marcelo Celi - 04/01/2021
aAdd( aSX3,	{ 	"SC5"		,"ZU"		,"C5_XFORPGT"	,"C"		, 30                        , 0		                    ,"Form Pgto Ec"	  		,""		    	,""			    ,"Forma Pgto eCommerce"				       	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

aAdd( aSX3,	{ 	"SC5"		,"ZV"		,"C5_XIDECOM"	,"C"		, 20                        , 0		                    ,"Id eCommerce"	  		,""		    	,""			    ,"Id eCommerce"				    	    	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,"ZW"		,"C5_XDINCLU"	,"D"		, 08                        , 0		                    ,"Dt Incl eCom"	  		,""		    	,""			    ,"Data Inclusao eCommerce"				   	,""				,""				,""  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,"ZX"		,"C5_XHINCLU"	,"C"		, 08                        , 0		                    ,"Hr Incl eCom"	  		,""		    	,""			    ,"Hora Inclusao eCommerce"				   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,"ZY"		,"C5_XDUPDAT"	,"D"		, 08                        , 0		                    ,"Dt Alte eCom"	  		,""		    	,""			    ,"Data Alteracao eCommerce"				   	,""				,""				,""  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,"ZZ"		,"C5_XHUPDAT"	,"C"		, 08                        , 0		                    ,"Hr Incl eCom"	  		,""		    	,""			    ,"Hora Inclusao eCommerce"				   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

aAdd( aSX3,	{ 	"SB1"		,"ZU"		,"B1_XECOMM"	,"C"		, 01                        , 0		                    ,"Venda e-Commerce"		,""		    	,""			    ,"Venda e-Commerce"				   		    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SB1"		,"ZV"		,"B1_XIDECOM"	,"C"		, 10                        , 0		                    ,"Id e-Commerce"		,""		    	,""			    ,"Id e-Commerce"				   	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										          							,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SB1"		,"ZW"		,"B1_XDSCCUR"	,"C"		, 20                        , 0		                    ,"Desc. Curta"			,""		    	,""			    ,"Descricao Curta"				   		    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""													          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SB1"		,"ZX"		,"B1_XDETALH"	,"M"		, 10                        , 0		                    ,"Detalhes"				,""		    	,""			    ,"Nome"							   		    ,""				,""				,""  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""													          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SB1"		,"ZY"		,"B1_XPESO"		,"N"		, 12                        , 4		                    ,"Peso"					,""		    	,""			    ,"Peso"						   			    ,""				,""				,"@E 99,999,999.9999"  	 	    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""													          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SB1"		,"ZZ"		,"B1_XIDENV"	,"C"		, 20                        , 0		                    ,"Envio eCommerce"		,""		    	,""			    ,"Envio eCommerce"				    	   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 

aAdd( aSX3,	{ 	"SB2"		,"ZZ"		,"B2_XIDENV"	,"C"		, 20                        , 0		                    ,"Envio eCommerce"		,""		    	,""			    ,"Envio eCommerce"				    	   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

aAdd( aSX3,	{ 	"SBM"		,"ZX"		,"BM_XIDECOM"	,"C"		, 10                        , 0		                    ,"Id e-Commerce"		,""		    	,""			    ,"Id e-Commerce"				   	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										          							,""				,""				,""				,""										,""			  		                                                            ,""	    	,"" 			,"S"		}) 
aAdd( aSX3,	{ 	"SBM"		,"ZY"		,"BM_XIDENV"	,"C"		, 20                        , 0		                    ,"Envio eCommerce"		,""		    	,""			    ,"Envio eCommerce"				    	   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,"" 			,"S"		}) 
aAdd( aSX3,	{ 	"SBM"		,"ZZ"		,"BM_XECOMM"	,"C"		, 01                        , 0		                    ,"Exibe e-Commerce"		,""		    	,""			    ,"Exibe e-Commerce"				   	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"" 			,"S"		}) 

aAdd( aSX3,	{ 	"SA1"		,"ZU"		,"A1_XORIGEM"	,"C"		, 01                        , 0		                    ,"Origem Cadastro"		,""		    	,""			    ,"Origem Cadastro"				   	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,"'S'"                                                                             	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,"S=Sistema;E=e-Commerce"										      		,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SA1"		,"ZV"		,"A1_XIDECOM"	,"C"		, 10                        , 0		                    ,"Id e-Commerce"		,""		    	,""			    ,"Id e-Commerce"				   	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										          							,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SA1"		,"ZX"		,"A1_XIDENDE"	,"C"		, 10                        , 0		                    ,"Id Endereco"			,""		    	,""			    ,"Id Endereco"				   	 	 	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										          							,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SA1"		,"ZY"		,"A1_XIDENV"	,"C"		, 20                        , 0		                    ,"Envio eCommerce"		,""		    	,""			    ,"Envio eCommerce"				    	   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 
aAdd( aSX3,	{ 	"SA1"		,"ZZ"		,"A1_XECOMM"	,"C"		, 01                        , 0		                    ,"Compra e-Commerce"	,""		    	,""			    ,"Compra e-Commerce"				   	    ,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										          				,""				,""				,""				,""										,""			  		                                                            ,""	    	,"9"			,"S"		}) 

aAdd( aSX3,	{ 	"DA1"		,"ZZ"		,"DA1_XIDENV"	,"C"		, 15                        , 0		                    ,"Envio eCommerce"		,""		    	,""			    ,"Envio eCommerce"				    	   	,""				,""				,"@!"  				 		    ,""	                                               					                    ,X3_USADO_EMUSO		,""                                                                                	,""	    			,0			,"  x  x x"	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										            						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 

dbSelectArea("SX3")
dbSetOrder(2)
For i:= 1 To Len(aSX3)
	SX3->(dbSetOrder(2))
	If !dbSeek(aSX3[i,3])
		RecLock("SX3",.T.)
	Else                  
		RecLock("SX3",.F.)
	EndIf			
	For j:=1 To Len(aSX3[i])
		If FieldPos(aEstrut[j])>0
			FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
Next i                      

//->>Criacao dos indices da tabela
aEstrut:= {"INDICE"	,"ORDEM","CHAVE"						                        	,"DESCRICAO"										,"DESCSPA"			,"DESCENG"						,"PROPRI"	,"F3"	,"NICKNAME"		,"SHOWPESQ"}

Aadd(aSIX,{"ZWS"	,"1"	,"ZWS_FILIAL+DTOS(ZWS_DATA)+ZWS_HORA+ZWS_OPER+ZWS_TIPO"	    ,"Data + Hora + Operacao + Tipo"		          	,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZWS"	,"2"	,"ZWS_FILIAL+ZWS_OPER+ZWS_TIPO+DTOS(ZWS_DATA)+ZWS_HORA"	    ,"Operacao + Tipo + Data + Hora "		          	,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZWS"	,"3"	,"ZWS_FILIAL+DTOS(ZWS_MOVIM)+ZWS_OPER+ZWS_TIPO"			    ,"Movimento + Operacao + Tipo"		         	 	,""					,""								,"U"		,""		,""         	,"S"})

Aadd(aSIX,{"ZWT"	,"1"	,"ZWT_FILIAL+DTOS(ZWT_DATA)+ZWT_HORA+ZWT_OPER+ZWT_TIPO"	    ,"Data + Hora + Operacao + Tipo"		          	,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZWT"	,"2"	,"ZWT_FILIAL+ZWT_OPER+ZWT_TIPO+DTOS(ZWT_DATA)+ZWT_HORA"	    ,"Operacao + Tipo + Data + Hora "		          	,""					,""								,"U"		,""		,""         	,"S"})

//->> Marcelo Celi - 31/12/2020
Aadd(aSIX,{"ZWU"	,"1"	,"ZWU_FILIAL+ZWU_IDECOM"	   								,"Id Ecommerce"		          						,""					,""								,"U"		,""		,""         	,"S"})

Aadd(aSIX,{"SC5"	,"X"	,"C5_FILIAL+C5_XIDECOM"	                                    ,"Id e-Commerce"		                         	,""					,""								,"U"		,""		,"C5XIDECOM"   	,"S"})
Aadd(aSIX,{"SC5"	,"Z"	,"C5_FILIAL+DTOS(C5_XDINCLU)+C5_XIDECOM"	                ,"Data Incl e-Commerce + Id e-Commerce"           	,""					,""								,"U"		,""		,"C5XDINCLU"   	,"S"})

Aadd(aSIX,{"SA1"	,"X"	,"A1_FILIAL+A1_XIDECOM+A1_XIDENDE"	 		                ,"Id do E-Commerce + Id Endereco" 					,""					,""								,"U"		,""		,"A1XIDENDE"   	,"S"})
Aadd(aSIX,{"SA1"	,"Z"	,"A1_FILIAL+A1_XIDECOM"	 					                ,"Id do E-Commerce"           						,""					,""								,"U"		,""		,"A1XIDECOM"   	,"S"})

Aadd(aSIX,{"SB1"	,"Z"	,"B1_FILIAL+B1_XIDECOM"	 					                ,"Id do E-Commerce"           						,""					,""								,"U"		,""		,"B1XIDECOM"   	,"S"})

dbSelectArea("SIX")
dbSetOrder(1)
For i:= 1 To Len(aSIX)
	If !dbSeek(aSIX[i,1]+aSIX[i,2])
		RecLock("SIX",.T.)
	Else                  
		RecLock("SIX",.F.)
	EndIf
	For j:=1 To Len(aSIX[i])
		If FieldPos(aEstrut[j])>0
			FieldPut(FieldPos(aEstrut[j]),aSIX[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
Next i                       

//->> Ajuste Fisico na Tabela, caso ja exista.
For nX:=1 to Len(aTabelas)	
	If lFisico
		__SetX31Mode(.F.)
		If Select(aTabelas[nX])>0
			dbSelecTArea(aTabelas[nX])
			dbCloseArea()
		EndIf		
		X31UpdTable(aTabelas[nX])		
	EndIf	
	dbSelecTArea(aTabelas[nX])
Next nX

//->>Criação de Folders
aEstrut:= 	{"XA_ALIAS"	,"XA_ORDEM"	,"XA_DESCRIC"				,"XA_DESCSPA"	,"XA_DESCENG"	,"XA_PROPRI"}
aAdd( aSXA, {"SA1" 		,"9"		,"e-Commerce"				,""				,""				, "U"}) 
aAdd( aSXA, {"SB1" 		,"9"		,"e-Commerce"				,""				,""				, "U"}) 
aAdd( aSXA, {"SBM" 		,"9"		,"e-Commerce"				,""				,""				, "U"}) 

dbSelectArea("SXA")
dbSetOrder(1)
For i:= 1 To Len(aSXA)
	If !Empty(aSXA[i][1])
		If !dbSeek(aSXA[i,1]+aSXA[i,2])
			RecLock("SXA",.T.)
		Else
			RecLock("SXA",.F.)
		EndIf
		For j:=1 To Len(aSXA[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSXA[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()		
	EndIf
Next i               

//->>Criação dos Gatilhos
aEstrut:= {"X7_CAMPO"	,"X7_SEQUENC"	,"X7_REGRA"						,"X7_CDOMIN"	,"X7_TIPO"	,"X7_SEEK"	,"X7_ALIAS"	,"X7_ORDEM"	,"X7_CHAVE"					        	,"X7_PROPRI"	,"X7_CONDIC"                }

//->> Gatilhos Cadastro de Clientes
aAdd(aSX7,{'A1_EMAIL'	,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_NOME'	,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_CGC'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_INSCR'	,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_PFISICA'	,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_MUN'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_FAX'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_CEP'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_EST'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_END'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_DDD'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'A1_TEL'		,'999'			,'Space(20)'	    			,'A1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})

//->> Gatilhos Cadastro de Produtos
aAdd(aSX7,{'B1_DESC'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'B1_XDSCCUR'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'B1_XPESO'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'B1_MSBLQL'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'B1_XDETALH'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})
aAdd(aSX7,{'B1_GRUPO'	,'999'			,'Space(20)'	    			,'B1_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})

//->> Gatilhos Cadastro de Grupos
aAdd(aSX7,{'BM_DESC'	,'999'			,'Space(20)'	    			,'BM_XIDENV'	,'P'		,'N'		,''			,0			,''								        ,'U'			,''							})

dbSelectArea("SX7")
dbSetOrder(1)
For i:= 1 To Len(aSX7)
	If !Empty(aSX7[i][1])
		If !dbSeek(PadR(aSX7[i,1],Len(SX7->X7_CAMPO)) +  PadR(aSX7[i,2],Len(SX7->X7_SEQUENC)) )
			RecLock("SX7",.T.)
		Else
			RecLock("SX7",.F.)
		EndIf	
		For j:=1 To Len(aSX7[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				FieldPut(FieldPos(aEstrut[j]),aSX7[i,j])
			EndIf
		Next j			
		dbCommit()
		MsUnLock()
	EndIf
Next i

For nX:=1 to Len(aSX7)
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(aSx7[nX,01]))
		Reclock("SX3",.F.)
		SX3->X3_TRIGGER := "S"
		SX3->(MsUnlock())
	EndIf
Next nX

//->> Criação das Triggers no Banco de Dados
//CriaTriggBD()

//->> Parametros na SX6
aEstrut:= {"X6_FIL"									,"X6_VAR"		,"X6_TIPO"	,"X6_DESCRIC"									,"X6_DSCSPA","X6_DSCENG","X6_DESC1"								,"X6_DSCSPA1"	,"X6_DSCENG1"	,"X6_DESC2"										,"X6_DSCSPA2"	,"X6_DSCENG2"	,"X6_CONTEUD"							,"X6_CONTSPA"	,"X6_CONTENG"	,"X6_PROPRI","X6_PYME"	}
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEURL"	,"C"		,"URL WSDL DE CONEXAO MAGENTO"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEUSR"	,"C"		,"USUARIO DE CONEXAO MAGENTO"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEPSW"	,"C"		,"SENHA DE CONEXAO MAGENTO"						,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGELOJ"	,"C"		,"CODIGO DA LOJA NO MAGENTO"  					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_ECOMVTK"	,"N"		,"TEMPO (MINUTOS) DURACAO TOKEN"				,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})

AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGELOG"	,"C"		,"LOGOTIPO MAGENTO 268 X 574"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,"DEVE ESTAR NA PASTA SYSTEM"					,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGETPR"	,"C"		,"TABELA DE PRECOS ECOMMERCE"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGENFE"	,"L"		,"GERA NOTA FISCAL NO FINAL"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGENAT"	,"C"		,"NATUREZA PADRAO PARA CLIENTES"				,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGETES"	,"C"		,"TES PADRAO DE VENDAS ECOMMERCE"				,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEOPE"	,"C"		,"OPERACAO DE VENDAS (TES INTELIG)"				,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGECND"	,"C"		,"CONDICAO PGTO VENDAS ECOMMERCE"				,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGESER"	,"C"		,"SERIE NOTAS ECOMMERCE"						,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEDCO"	,"D"		,"DATA CORTE DESCIDA VENDAS"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})

AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGECLI"	,"L"		,"PERMITE SUBIDA DE CLIENTES"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEPRD"	,"L"		,"PERMITE SUBIDA DE PRODUTOS"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGECAT"	,"L"		,"PERMITE SUBIDA DE CATEGORIAS"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEEST"	,"L"		,"PERMITE SUBIDA DE ESTOQUE"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_MAGEPRC"	,"L"		,"PERMITE SUBIDA DE PRECOS"						,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})

//->> Marcelo Celi - 04/01/2020
AAdd(aSX6,{PadR(" ",Len(SX6->X6_FIL))				,"MC_FILECOM"	,"C"		,"FILIAL DE USO DO ECOMMERCE"					,""			,""			,"[ECOMMERCE MAGENTO]"					,""				,""				,""												,""				,""				,""										,""				,""				,"U"		,"S"		})

dbSelectArea("SX6")
dbSetOrder(1)
For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !dbSeek(aSX6[i,1]+aSX6[i,2])			
			RecLock("SX6",.T.)		
			For j:=1 To Len(aSX6[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
				EndIf
			Next j			
			dbCommit()
			MsUnLock()		
		EndIf	
	EndIf
Next i

Return         

/*/{protheus.doc} GetTamSXG
*******************************************************************************************
Retorna o tamanho do grupo de campos.
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetTamSXG( cGrupo, nTamPad )
Local aRet

DbSelectArea( "SXG" )
SXG->( DbSetOrder( 1 ) )
If SXG->( DbSeek( cGrupo ) )
	nTamPad	:= SXG->XG_SIZE
	aRet := { nTamPad, "@!", nTamPad, nTamPad }
Else
	aRet := { nTamPad, "@!", nTamPad, nTamPad }
EndIf

Return aRet

/*/{protheus.doc} CriaTriggBD
*******************************************************************************************
Cria as Triggers no banco de dados
 
@author: Marcelo Celi Marques
@since: 10/08/2020
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function CriaTriggBD()
Local cQuery 	:= ""
Local nRetorno	:= 0

cQuery := "ALTER TRIGGER [dbo].[TGR_SB1_XIDENV]"														+CRLF
cQuery += "ON [dbo].["+RetSqlName("SB1")+"]"															+CRLF
cQuery += "FOR UPDATE AS"																				+CRLF
cQuery += "BEGIN"																						+CRLF
cQuery += "    DECLARE"																					+CRLF
cQuery += "    @RECNO INT"																				+CRLF
cQuery += "    IF NOT UPDATE (B1_XIDENV) BEGIN"															+CRLF
cQuery += "        SELECT @RECNO = R_E_C_N_O_ FROM INSERTED"											+CRLF
cQuery += "        UPDATE "+RetSqlName("SB1")+" SET B1_XIDENV = ' ' WHERE R_E_C_N_O_ = @RECNO"			+CRLF
cQuery += "    END"																						+CRLF
cQuery += "END"																							+CRLF
nRetorno := TcSqlExec(cQuery)

cQuery := "ALTER TRIGGER [dbo].[TGR_SB2_XIDENV]"														+CRLF
cQuery += "ON [dbo].["+RetSqlName("SB2")+"]"															+CRLF
cQuery += "FOR UPDATE AS"																				+CRLF
cQuery += "BEGIN"																						+CRLF
cQuery += "    DECLARE"																					+CRLF
cQuery += "    @RECNO INT"																				+CRLF
cQuery += "    IF NOT UPDATE (B2_XIDENV) BEGIN"															+CRLF
cQuery += "        SELECT @RECNO = R_E_C_N_O_ FROM INSERTED"											+CRLF
cQuery += "        UPDATE "+RetSqlName("SB2")+" SET B2_XIDENV = ' ' WHERE R_E_C_N_O_ = @RECNO"			+CRLF
cQuery += "    END"																						+CRLF
cQuery += "END"																							+CRLF
nRetorno := TcSqlExec(cQuery)

cQuery := "ALTER TRIGGER [dbo].[TGR_SA1_XIDENV]"														+CRLF
cQuery += "ON [dbo].["+RetSqlName("SA1")+"]"															+CRLF
cQuery += "FOR UPDATE AS"																				+CRLF
cQuery += "BEGIN"																						+CRLF
cQuery += "    DECLARE"																					+CRLF
cQuery += "    @RECNO INT"																				+CRLF
cQuery += "    IF NOT UPDATE (A1_XIDENV) BEGIN"															+CRLF
cQuery += "        SELECT @RECNO = R_E_C_N_O_ FROM INSERTED"											+CRLF
cQuery += "        UPDATE "+RetSqlName("SA1")+" SET A1_XIDENV = ' ' WHERE R_E_C_N_O_ = @RECNO"			+CRLF
cQuery += "    END"																						+CRLF
cQuery += "END"																							+CRLF
nRetorno := TcSqlExec(cQuery)

cQuery := "ALTER TRIGGER [dbo].[TGR_DA1_XIDENV]"														+CRLF
cQuery += "ON [dbo].["+RetSqlName("DA1")+"]"															+CRLF
cQuery += "FOR UPDATE AS"																				+CRLF
cQuery += "BEGIN"																						+CRLF
cQuery += "    DECLARE"																					+CRLF
cQuery += "    @RECNO INT"																				+CRLF
cQuery += "    IF NOT UPDATE (DA1_XIDENV) BEGIN"														+CRLF
cQuery += "        SELECT @RECNO = R_E_C_N_O_ FROM INSERTED"											+CRLF
cQuery += "        UPDATE "+RetSqlName("DA1")+" SET DA1_XIDENV = ' ' WHERE R_E_C_N_O_ = @RECNO"			+CRLF
cQuery += "    END"																						+CRLF
cQuery += "END"																							+CRLF
nRetorno := TcSqlExec(cQuery)

Return

//->> EXECUCAO DO UPD SEM AJUSTES FISICOS NAS TABELAS
User Function BOUpdECom()
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
UpdDics(.f.)
Return

User Function BoL2Prd()
Local cArquivo  := "c:\temp\linkprd.txt"
Local nHandle	:= 0
Local cString	:= ""
Local nTamanho	:= 1000000
Local cError	:= ""
Local cWarning	:= ""
Local cSku 		:= ""
Local cId		:= ""

Private oXml := NIL
Private nX   := NIL

If File(cArquivo)	
	nHandle := fopen(cArquivo , FO_READWRITE + FO_SHARED )
  	cString := ""
  	FRead( nHandle, cString, nTamanho ) // Lê os primeiros 10 bytes do arquivo
	fclose(nHandle)

	If !Empty(cString)
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
		
        oXml := XmlParser(cString, "_", @cError, @cWarning)
        If Type("oXml") <> "U" .And. Type("OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM")<>"U"
            For nX:=1 to Len(OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM)
                cId  := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_product_id:TEXT
                cSku := OXML:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CATALOGPRODUCTLISTRESPONSE:_STOREVIEW:_ITEM[nX]:_sku:TEXT

                If !Empty(cSku) .And. !Empty(cId)
                    cSku := PadR(cSku,Tamsx3("B1_CODGTIN")[01])
                    SB1->(dbSetOrder(14)) //->> buscar pelo gtin
                    If SB1->(dbSeek(xFilial("SB1")+cSku))
                        Reclock("SB1",.F.)
                        SB1->B1_XIDECOM := cId
                        SB1->B1_XECOMM  := "S"
                        SB1->(MsUnlock())
                    EndIf
                EndIf
            Next nX    
        Endif    
	EndIf
EndIf

Return


