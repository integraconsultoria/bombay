#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#include 'fileio.ch'

Static cTitulo  := "Compatibilizador"
Static cHeader  := "Romaneio de Coleta"
Static aMessage := {"Update.","Identifique-se para seguir com o update.","Selecione as Empresas a aplicar o update."}
Static cMsg		:= "Este programa tem o objetivo de criar os dicionários do processo do Romaneio de Coleta."

//************************************************************>> COMPATIBILIZADOR << ******
Static lFWCodFil := FindFunction("FWCodFil")

/*/{protheus.doc} CoUpdRelat
*******************************************************************************************
Compatibilizador/update
 
@author: Marcelo Celi Marques
@since: 26/01/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoUpdRoma()
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

Private cObrig   := ""
Private cReserv  := ""	
Private cNaoUsad := ""
Private cUsado	 := ""
Private lDicInDb := If(FindFunction( "MPDicInDB" ),MPDicInDB(),.F.)

If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
	cObrig   := "€€"
	cReserv  := "þÀ"	
	cNaoUsad := "€€€€€€€€€€€€€€€"      
	cUsado	 := "€€€€€€€€€€€€€€"
Else
	cObrig   := "     xx"
	cReserv  := "  x  x x"	
	cNaoUsad := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x"      
	cUsado	 := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"
EndIf

MsgRun("Abrindo Ambiente...",,{ || lExclusiv := Inicializa(@aSM0,@aFiliais,@aEmpFil) })

cMsg += CRLF
cMsg += CRLF
If lExclusiv
	cMsg += "Avançar para a Continuar..."
Else
	cMsg += "Existem conexões no sistema que impedem o uso do compatibilizador nesse momento..."
EndIf	

DEFINE WIZARD oWizard 											;
		TITLE cTitulo											;
          	HEADER cHeader						        		;
          	MESSAGE aMessage[1]									;
         	TEXT cMsg PANEL										;
          	NEXT 	{|| lExclusiv }								;
          	FINISH 	{|| lExclusiv }								; 
          	      
  	CREATE PANEL oWizard 										;				
          	HEADER cHeader								        ;
          	MESSAGE aMessage[2] PANEL							;  	        	
          	BACK 	{|| .F. }									;
          	NEXT 	{|| AutUser(cUsuRep,cUsuPsw,aEmpFil)}		;
          	FINISH 	{|| AutUser(cUsuRep,cUsuPsw,aEmpFil)}		;
          	PANEL   	      
          	      
   	@ 010,010 Say "Usuário:"					Size  50, 09 Of oWizard:GetPanel(2) Pixel 
	@ 008,035 Get cUsuRep						Size  70, 09 Of oWizard:GetPanel(2) Pixel Font oFont3
			
	@ 023,010 Say "Senha:"						Size  50, 09 Of oWizard:GetPanel(2) Pixel 
	@ 021,035 MsGet cUsuPsw PassWord			Size  70, 09 Of oWizard:GetPanel(2) Pixel Font oFont3
          	          	                            
   	CREATE PANEL oWizard 								;				
          	HEADER cHeader					        	;
          	MESSAGE aMessage[3] PANEL					;          	
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
@since: 26/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function Inicializa(aSM0,aFiliais,aEmpFil)
Local lExclusiv := FINOpenSM0(@aSM0,@aFiliais,@aEmpFil)

If lExclusiv
	RpcSetEnv( aEmpFil[01], aEmpFil[02] ,,, "FIN","UPDATE",{ "SE1" } )
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
@since: 26/01/2022
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
@since: 26/01/2022
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

If !lDicInDb
	For nLoop := 1 To 20
		dbUseArea(.T., , "SIGAMAT.EMP", "SM0", .T., .F.)
		If !Empty(Select("SM0"))
			lOpen := .T.
			dbSetIndex("SIGAMAT.IND")
			Exit
		EndIf
		Sleep(500)
	Next nLoop
Else
	If FindFunction( "OpenSM0Excl" )
		For nLoop := 1 To 20
			If OpenSM0Excl(,.F.)
				lOpen := .T.
				Exit
			EndIf
			Sleep( 500 )
		Next nLoop
	Else
		For nLoop := 1 To 20
			dbUseArea( .T., , "SIGAMAT.EMP", "SM0", .T., .F. )
			If !Empty( Select( "SM0" ) )
				lOpen := .T.
				dbSetIndex( "SIGAMAT.IND" )
				Exit
			EndIf
			Sleep( 500 )
		Next nLoop
	EndIf	
EndIf

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
@since: 26/01/2022
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

If MsgYesNo("Confirma a Execução do Compatibilizador ?"+CRLF+Upper(cHeader))
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
@since: 26/01/2022
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

If !lDicInDb
	SM0->(dbCloseArea())
EndIf	
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
@since: 26/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function UpdDics(lFisico)
Local aTabelas   := {}
Local aSX2 		 := {}
Local aSX3 		 := {}
Local aSIX 		 := {}
Local aSXB 		 := {}
Local aSX7 		 := {}
Local aEstrut	 := {}
Local i, j, nX

Default lFisico	:= .T.
              
Private lUpdAuto 

aTabelas := {/*/"SA4",/*/"ZR1","ZR2","ZR4"}

//->> Criacao da Tabela
aEstrut:= 	{"X2_CHAVE"	,"X2_PATH"		,"X2_ARQUIVO"		,"X2_NOME"					    ,"X2_NOMESPAC"					,"X2_NOMEENGC"			   		,"X2_DELET"	,"X2_MODO"	,"X2_MODOUN", "X2_MODOEMP"  ,"X2_TTS"	,"X2_ROTINA"	}
aAdd( aSX2, {"ZR1" 		,"\DADOSADV\"	, "ZR1010"			,"Cabeçalho Romaneio Coleta"	,"Cabeçalho Romaneio Coleta"	,"Cabeçalho Romaneio Coleta"	,0			,"E"		,"E"    	, "E"       	, " "		,"             "}) 
aAdd( aSX2, {"ZR2" 		,"\DADOSADV\"	, "ZR2010"			,"Itens Romaneio Coleta"		,"Itens Romaneio Coleta"		,"Itens Romaneio Coleta"		,0			,"E"		,"E"    	, "E"       	, " "		,"             "}) 
//aAdd( aSX2, {"ZR3" 		,"\DADOSADV\"	, "ZR3010"			,"Cotação"						,"Cotação"						,"Cotação"						,0			,"E"		,"E"    	, "E"       	, " "		,"             "}) 
aAdd( aSX2, {"ZR4" 		,"\DADOSADV\"	, "ZR4010"			,"Log Romaneio Coleta"			,"Log Romaneio Coleta"			,"Log Romaneio Coleta"			,0			,"E"		,"E"    	, "E"       	, " "		,"             "}) 

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
aEstrut:= 	{	"X3_ARQUIVO","X3_ORDEM"	,"X3_CAMPO"     		,"X3_TIPO"  ,"X3_TAMANHO"   			,"X3_DECIMAL"   			,"X3_TITULO"  	,"X3_TITSPA"    ,"X3_TITENG"  	,"X3_DESCRIC"	,"X3_DESCSPA"	,"X3_DESCENG"	,"X3_PICTURE"			,"X3_VALID" 				   								,"X3_USADO" ,"X3_RELACAO"	     			,"X3_F3"   			,"X3_NIVEL","X3_RESERV" ,"X3_CHECK" ,"X3_TRIGGER"   ,"X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT"   ,"X3_OBRIGAT"   ,"X3_VLDUSER"					   				,"X3_CBOX"   									    						,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN" 							 	,"X3_INIBRW"  																	,"X3_GRPSXG","X3_FOLDER"	,"X3_PYME"	}			
aAdd( aSX3,	{	"ZR1"   	,"01"      	,"ZR1_FILIAL"    		,"C"        , Tamsx3("E1_FILIAL")[01] 	, Tamsx3("E1_FILIAL")[02] 	,"Filial"		,"Filial"     	,"Filial"     	,"Filial"		,"Filial"    	,"Filial"    	,"@!" 					,""                         								,cNaoUsad 	,""   							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"02"      	,"ZR1_ROMANE"    		,"C"        , 06 						, 0 						,"Romaneio" 	,"Romaneio"   	,"Romaneio"   	,"Romaneio"		,"Romaneio"   	,"Romaneio"   	,"@!"   				,"" 						 								,cUsado     ,""  				 			,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"03"      	,"ZR1_FAPROV"    		,"C"        , 01 						, 0 						,"Aprovado" 	,"Aprovado"   	,"Aprovado"   	,"Aprovado"		,"Aprovado"   	,"Aprovado"   	,"@!"   				,"" 						 								,cUsado   	,"'L'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,"L=Liberado;B=Bloqueado" 													,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"04"      	,"ZR1_EMISSA"    		,"D"        , 08 						, 0 						,"Emissão"	 	,"Emissão"   	,"Emissão"   	,"Emissão"		,"Emissão"   	,"Emissão"   	,"@!"   				,"" 						 								,cUsado     ,"Date()" 						,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"05"      	,"ZR1_HORA"	    		,"C"        , 10 						, 0 						,"Hora" 		,"Hora"   		,"Hora"   		,"Hora"			,"Hora"   		,"Hora"   		,"@!"   				,"" 						 								,cUsado     ,"Time()" 						,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"06"      	,"ZR1_STATUS"    		,"C"        , 01 						, 0 						,"Status" 		,"Status"   	,"Status"   	,"Status"		,"Status"   	,"Status"   	,"@!"   				,"" 						 								,cUsado   	,"'1'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"1=Elaboração;2=Cotado;3=Faturado" 										,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"07"      	,"ZR1_PERDE"     		,"D"        , 08 						, 0 						,"Period De" 	,"Period De"   	,"Period De"   	,"Period De"	,"Period De"   	,"Period De"   	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"08"      	,"ZR1_PERATE"    		,"D"        , 08 						, 0 						,"Period Ate" 	,"Period Ate"  	,"Period Ate"  	,"Period Ate"	,"Period Ate"   ,"Period Ate"  	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"09"      	,"ZR1_QTDOCS"    		,"N"        , 05 						, 0 						,"Qtd Doctos" 	,"Qtd Doctos"  	,"Qtd Doctos"  	,"Qtd Doctos"	,"Qtd Doctos"   ,"Qtd Doctos"  	,"@E 99,999"			,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"10"      	,"ZR1_VLDOCS"    		,"N"        , 12 						, 2 						,"Vlr Doctos" 	,"Vlr Doctos"  	,"Vlr Doctos"  	,"Vlr Doctos"	,"Vlr Doctos"   ,"Vlr Doctos"  	,"@E 9,999,999,999.99"  ,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"11"      	,"ZR1_COTAC"    		,"C"        , 06						, 0 						,"Cotação" 		,"Cotação"   	,"Cotação"   	,"Cotação"		,"Cotação"   	,"Cotação"   	,"@!"   				,"u_BoVldCotac()"			 								,cUsado     ,""    							,"ZR3"     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""										,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"12"      	,"ZR1_VLFRET"    		,"N"        , 12 						, 2 						,"Vlr Frete" 	,"Vlr Frete"   	,"Vlr Frete"   	,"Vlr Frete"	,"Vlr Frete"   	,"Vlr Frete"   	,"@E 9,999,999,999.99" 	,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"13"      	,"ZR1_PCFRET"    		,"N"        , 05 						, 2 						,"Pc Frete" 	,"Pc Frete"   	,"Pc Frete"   	,"Pc Frete"		,"Pc Frete"   	,"Pc Frete"   	,"@E 999.99" 			,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"14"      	,"ZR1_CONDIC"     		,"C"        , Tamsx3("E4_CODIGO")[01]	, Tamsx3("E4_CODIGO")[02]	,"Condição"		,"Condição"   	,"Condição"   	,"Condição"		,"Condição"   	,"Condição"   	,"@!"   				,"u_BoVldCond()" 											,cUsado     ,""    							,"SE4"     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"15"      	,"ZR1_FATURA"      		,"C"        , Tamsx3("F1_DOC")[01] 		, Tamsx3("F1_DOC")[02] 		,"Fatura" 		,"Fatura" 		,"Fatura" 		,"Fatura"		,"Fatura"  		,"Fatura" 		,"@!"   				,"u_BoVldNFEnt()" 			 								,cUsado  	,"" 				  			,"" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"16"      	,"ZR1_SERIE"      		,"C"        , Tamsx3("F1_SERIE")[01] 	, Tamsx3("F1_SERIE")[02] 	,"Serie" 		,"Serie" 		,"Serie" 		,"Serie"		,"Serie"  		,"Serie" 		,"@!"   				,"u_BoVldNFEnt()" 			 								,cUsado  	,"" 				  			,"" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"17"      	,"ZR1_MOTOR"    		,"C"        , Tamsx3("A2_COD")[01]		, Tamsx3("A2_COD")[02] 		,"Fornecedor" 	,"Fornecedor"  	,"Fornecedor"  	,"Fornecedor"	,"Fornecedor"  	,"Fornecedor"  	,"@!"   				,"ExistCpo('SA2',M->ZR1_MOTOR,,,,.F.)" 						,cUsado     ,""    							,"SA2"     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""										,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"18"      	,"ZR1_LJMOTO"    		,"C"        , Tamsx3("A2_LOJA")[01] 	, Tamsx3("A2_LOJA")[02] 	,"Loja" 		,"Loja"   		,"Loja"   		,"Loja"			,"Loja"   		,"Loja"   		,"@!"   				,"Iif(Vazio(),.T.,ExistCpo('SA2',M->(ZR1_MOTOR+ZR1_LJMOTO)))",cUsado    ,""    							,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"19"      	,"ZR1_NOME" 	    	,"C"        , Tamsx3("A2_NOME")[01] 	, Tamsx3("A2_NOME")[02] 	,"Nome"		 	,"Nome"   		,"Nome"   		,"Nome"			,"Nome"   		,"Nome"   		,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"20"      	,"ZR1_USRCRI"    		,"C"        , 20 						, 0 						,"Usr Criou" 	,"Usr Criou"   	,"Usr Criou"   	,"Usr Criou"	,"Usr Criou"   	,"Usr Criou"   	,"@!"   				,"" 						 								,cUsado     ,"'1'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"21"      	,"ZR1_USRCON"    		,"C"        , 20 						, 0 						,"Usr Confer"	,"Usr Confer"  	,"Usr Confer"  	,"Usr Confer"	,"Usr Confer"  	,"Usr Confer"  	,"@!"   				,"" 						 								,cUsado     ,"'1'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR1"   	,"22"      	,"ZR1_OBSERV"    		,"M"        , 10 						, 0 						,"Observação"	,"Observação"  	,"Observação"  	,"Observação"	,"Observação"  	,"Observação"  	,"" 	  				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })

aAdd( aSX3,	{	"ZR2"   	,"01"      	,"ZR2_FILIAL"    		,"C"        , Tamsx3("E1_FILIAL")[01] 	, Tamsx3("E1_FILIAL")[02] 	,"Filial"		,"Filial"     	,"Filial"     	,"Filial"		,"Filial"    	,"Filial"    	,"@!" 					,""                         								,cNaoUsad 	,""   							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"02"      	,"ZR2_ROMANE"    		,"C"        , 06 						, 0 						,"Romaneio" 	,"Romaneio"   	,"Romaneio"   	,"Romaneio"		,"Romaneio"   	,"Romaneio"   	,"@!"   				,"" 						 								,cNaoUsad   ,"" 				  			,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"03"      	,"ZR2_TPDOC"     		,"C"        , 01 						, 0 						,"Tp Docto" 	,"Tp Docto"   	,"Tp Docto"   	,"Tp Docto"		,"Tp Docto"   	,"Tp Docto"   	,"@!"   				,"u_BoVldTpDoc()" 											,cUsado     ,"" 				  			,""        			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"E=Entrada;S=Saida"  														,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"04"      	,"ZR2_FILDOC"     		,"C"        , Tamsx3("F2_FILIAL")[01] 	, Tamsx3("F2_FILIAL")[02] 	,"Fil. Doc" 	,"Fil. Doc"   	,"Fil. Doc"   	,"Fil. Doc"		,"Fil. Doc"   	,"Fil. Doc"   	,"@!"   				,"" 									 					,cUsado  	,"" 				  			,"DOCROM"  			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"04"      	,"ZR2_DOCTO"     		,"C"        , Tamsx3("F2_DOC")[01] 		, Tamsx3("F2_DOC")[02] 		,"Documento" 	,"Documento"   	,"Documento"   	,"Documento"	,"Documento"   	,"Documento"   	,"@!"   				,"" 									 					,cUsado  	,"" 				  			,""		  			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"05"      	,"ZR2_SERIE"     		,"C"        , Tamsx3("F2_SERIE")[01] 	, Tamsx3("F2_SERIE")[02] 	,"Serie" 		,"Serie"   		,"Serie"   		,"Serie"		,"Serie"   		,"Serie"   		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"06"      	,"ZR2_CLIFOR"    		,"C"        , Tamsx3("A1_COD")[01] 		, Tamsx3("A1_COD")[02] 		,"Cli/For" 		,"Cli/For" 		,"Cli/For" 		,"Cli/For"		,"Cli/For"   	,"Cli/For" 		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"07"      	,"ZR2_LOJA"      		,"C"        , Tamsx3("A1_LOJA")[01] 	, Tamsx3("A1_LOJA")[02] 	,"Loja" 		,"Loja" 		,"Loja" 		,"Loja"			,"Loja"   		,"Loja" 		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"08"      	,"ZR2_NOME"      		,"C"        , Tamsx3("A1_NOME")[01] 	, Tamsx3("A1_NOME")[02] 	,"Nome" 		,"Nome" 		,"Nome" 		,"Nome"			,"Nome"   		,"Nome" 		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"09"      	,"ZR2_DTDOC"     		,"D"        , 8 						, 0 						,"Emissão" 		,"Emissão" 		,"Emissão" 		,"Emissão"		,"Emissão"   	,"Emissão" 		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"10"      	,"ZR2_VLDOC"     		,"N"        , 12 						, 2 						,"Vlr Docto" 	,"Vlr Docto"  	,"Vlr Docto"  	,"Vlr Docto"	,"Vlr Docto"    ,"Vlr Docto"  	,"@E 9,999,999,999.99"  ,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"11"      	,"ZR2_PMAXFR"     		,"N"        , 05 						, 2 						,"PC Max Fret" 	,"PC Max Fret" 	,"PC Max Fret"  ,"PC Max Fret"	,"PC Max Fret"  ,"PC Max Fret" 	,"@E 999.99"  			,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"12"      	,"ZR2_SITFRE"     		,"C"        , 02 						, 2 						,"" 			,"" 			,""  			,""				,""  			,"" 			,"@BMP"  				,"" 						 								,cUsado     ,"u_BoImgInRom()"				,"" 				,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"V"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"13"      	,"ZR2_VLFRET"    		,"N"        , 12 						, 2 						,"Vlr Frete" 	,"Vlr Frete"   	,"Vlr Frete"   	,"Vlr Frete"	,"Vlr Frete"   	,"Vlr Frete"   	,"@E 9,999,999,999.99" 	,"u_BoCalcVlFr()" 						 					,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"14"      	,"ZR2_PCALFR"     		,"N"        , 05 						, 2 						,"PC Calc Fret"	,"PC Calc Fret" ,"PC Calc Fret" ,"PC Calc Fret"	,"PC Calc Fret" ,"PC Calc Fret" ,"@E 999.99"  			,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"15"      	,"ZR2_OBSERV"    		,"M"        , 10 						, 2 						,"Observação" 	,"Observação"  	,"Observação"  	,"Observação"	,"Observação"  	,"Observação"  	,"@!" 					,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR2"   	,"16"      	,"ZR2_SITUAC"    		,"C"        , 01 						, 2 						,"Situação" 	,"Situação"  	,"Situação"  	,"Situação"		,"Situação"  	,"Situação"  	,"@!" 					,"" 						 								,cUsado     ,"'N'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,"N=Normal;R=Re-Entrega;E=Excluído"              							,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })

/*/
aAdd( aSX3,	{	"ZR3"   	,"01"      	,"ZR3_FILIAL"    		,"C"        , Tamsx3("E1_FILIAL")[01] 	, Tamsx3("E1_FILIAL")[02] 	,"Filial"		,"Filial"     	,"Filial"     	,"Filial"		,"Filial"    	,"Filial"    	,"@!" 					,""                         								,cNaoUsad 	,""   							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"02"      	,"ZR3_NUMERO"   		,"C"        , 06 						, 0 						,"Numero"	 	,"Numero"   	,"Numero"   	,"Numero"		,"Numero"   	,"Numero"   	,"@!"   				,"" 						 								,cUsado   	,"" 				  			,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"03"      	,"ZR3_ROMANE"    		,"C"        , 06 						, 0 						,"Romaneio" 	,"Romaneio"   	,"Romaneio"   	,"Romaneio"		,"Romaneio"   	,"Romaneio"   	,"@!"   				,"u_BoRomaVld()" 											,cUsado 	,"" 				  			,"ZR1"     			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"04"      	,"ZR3_TRANSP"    		,"C"        , Tamsx3("A4_COD")[01] 		, Tamsx3("A4_COD")[02] 		,"Transport"	,"Transport" 	,"Transport" 	,"Transport"	,"Transport"   	,"Transport" 	,"@!"   				,"u_BoTransVld()" 			 								,cUsado  	,"" 				  			,"SA4" 				,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"05"      	,"ZR3_NOME"    			,"C"        , Tamsx3("A4_NOME")[01] 	, Tamsx3("A4_NOME")[02] 	,"Nome"			,"Nome" 		,"Nome"	 		,"Nome"			,"Nome"   		,"Nome"		 	,"@!"   				,"" 						 								,cUsado  	,"" 				  			,""	 				,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"06"      	,"ZR3_MOTOR"   			,"C"        , 30 						, 0 						,"Motorista"	,"Motorista" 	,"Motorista"	,"Motorista"	,"Motorista" 	,"Motorista"	,"@!"   				,"" 						 								,cUsado  	,"" 				  			,""	 				,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"07"      	,"ZR3_CARRO"   			,"C"        , 20 						, 0 						,"Veiculo"		,"Veiculo" 		,"Veiculo"		,"Veiculo"		,"Veiculo" 		,"Veiculo"		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,""	 				,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"08"      	,"ZR3_DTCOLE"  			,"D"        , 8 						, 0 						,"Dt Coleta"	,"Dt Coleta" 	,"Dt Coleta"	,"Dt Coleta"	,"Dt Coleta"	,"Dt Coleta"	,"@!"   				,"" 						 								,cUsado  	,"" 				  			,""	 				,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"09"      	,"ZR3_VLFRET"  			,"N"        , Tamsx3("E1_VALOR")[01]	, Tamsx3("E1_VALOR")[02] 	,"Vlr Frete"	,"Vlr Frete" 	,"Vlr Frete"	,"Vlr Frete"	,"Vlr Frete"	,"Vlr Frete"	,"@E 9,999,999,999.99"	,"Positivo()" 				 								,cUsado  	,"" 				  			,""	 				,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"10"      	,"ZR3_OBSERV"    		,"M"        , 10 						, 0 						,"Observação"	,"Observação" 	,"Observação" 	,"Observação"	,"Observação"  	,"Observação" 	,"@!"   				,"" 			 											,cUsado  	,"" 				  			,"" 				,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"11"      	,"ZR3_STATUS"    		,"C"        , 01 						, 0 						,"Status" 		,"Status"   	,"Status"   	,"Status"		,"Status"   	,"Status"   	,"@!"   				,"" 						 								,cUsado    ,"'1'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"1=Bloqueado;2=Liberado;3-Finalizado" 										,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"12"      	,"ZR3_COTAC"    		,"C"        , 20 						, 0 						,"Cotacao" 		,"Cotacao"   	,"Cotacao"   	,"Cotacao"		,"Cotacao"   	,"Cotacao"   	,"@!"   				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"13"      	,"ZR3_USRCRI"    		,"C"        , 20 						, 0 						,"Usr Cotou" 	,"Usr Cotou"   	,"Usr Cotou"   	,"Usr Cotou"	,"Usr Cotou"   	,"Usr Cotou"   	,"@!"   				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"14"      	,"ZR3_LIBER"    		,"C"        , 20 						, 0 						,"Liberacao"	,"Liberacao"   	,"Liberacao"   	,"Liberacao"	,"Liberacao"   	,"Liberacao"   	,"@!"   				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR3"   	,"15"      	,"ZR3_USRCON"    		,"C"        , 20 						, 0 						,"Usr Liberou"	,"Usr Liberou" 	,"Usr Liberou" 	,"Usr Liberou"	,"Usr Liberou" 	,"Usr Liberou" 	,"@!"   				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
/*/

aAdd( aSX3,	{	"ZR4"   	,"01"      	,"ZR4_FILIAL"    		,"C"        , Tamsx3("E1_FILIAL")[01] 	, Tamsx3("E1_FILIAL")[02] 	,"Filial"		,"Filial"     	,"Filial"     	,"Filial"		,"Filial"    	,"Filial"    	,"@!" 					,""                         								,cNaoUsad 	,""   							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"02"      	,"ZR4_ROMANE"    		,"C"        , 06 						, 0 						,"Romaneio" 	,"Romaneio"   	,"Romaneio"   	,"Romaneio"		,"Romaneio"   	,"Romaneio"   	,"@!"   				,"" 						 								,cUsado     ,""  				 			,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"03"      	,"ZR4_SEQUEN"    		,"C"        , 03 						, 0 						,"Sequencia" 	,"Sequencia"   	,"Sequencia"   	,"Sequencia"	,"Sequencia"   	,"Sequencia"   	,"@!"   				,"" 						 								,cUsado     ,""  				 			,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"04"      	,"ZR4_EMISSA"    		,"D"        , 08 						, 0 						,"Emissão"	 	,"Emissão"   	,"Emissão"   	,"Emissão"		,"Emissão"   	,"Emissão"   	,"@!"   				,"" 						 								,cUsado     ,"Date()" 						,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"05"      	,"ZR4_HORA"	    		,"C"        , 10 						, 0 						,"Hora" 		,"Hora"   		,"Hora"   		,"Hora"			,"Hora"   		,"Hora"   		,"@!"   				,"" 						 								,cUsado     ,"Time()" 						,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"06"      	,"ZR4_PERDE"     		,"D"        , 08 						, 0 						,"Period De" 	,"Period De"   	,"Period De"   	,"Period De"	,"Period De"   	,"Period De"   	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"07"      	,"ZR4_PERATE"    		,"D"        , 08 						, 0 						,"Period Ate" 	,"Period Ate"  	,"Period Ate"  	,"Period Ate"	,"Period Ate"   ,"Period Ate"  	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"08"      	,"ZR4_QTDOCS"    		,"N"        , 05 						, 0 						,"Qtd Doctos" 	,"Qtd Doctos"  	,"Qtd Doctos"  	,"Qtd Doctos"	,"Qtd Doctos"   ,"Qtd Doctos"  	,"@E 99,999"			,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"09"      	,"ZR4_VLDOCS"    		,"N"        , 12 						, 2 						,"Vlr Doctos" 	,"Vlr Doctos"  	,"Vlr Doctos"  	,"Vlr Doctos"	,"Vlr Doctos"   ,"Vlr Doctos"  	,"@E 9,999,999,999.99"  ,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"10"      	,"ZR4_COTAC"    		,"C"        , 06						, 0 						,"Cotação" 		,"Cotação"   	,"Cotação"   	,"Cotação"		,"Cotação"   	,"Cotação"   	,"@!"   				,"u_BoVldCotac()"			 								,cUsado     ,""    							,"ZR3"     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""										,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"11"      	,"ZR4_VLFRET"    		,"N"        , 12 						, 2 						,"Vlr Frete" 	,"Vlr Frete"   	,"Vlr Frete"   	,"Vlr Frete"	,"Vlr Frete"   	,"Vlr Frete"   	,"@E 9,999,999,999.99" 	,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"12"      	,"ZR4_CONDIC"     		,"C"        , Tamsx3("E4_CODIGO")[01]	, Tamsx3("E4_CODIGO")[02]	,"Condição"		,"Condição"   	,"Condição"   	,"Condição"		,"Condição"   	,"Condição"   	,"@!"   				,"u_BoVldCond()" 											,cUsado     ,""    							,"SE4"     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"13"      	,"ZR4_FATURA"      		,"C"        , Tamsx3("F1_DOC")[01] 		, Tamsx3("F1_DOC")[02] 		,"Fatura" 		,"Fatura" 		,"Fatura" 		,"Fatura"		,"Fatura"  		,"Fatura" 		,"@!"   				,"u_BoVldNFEnt()" 			 								,cUsado  	,"" 				  			,"" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"14"      	,"ZR4_SERIE"      		,"C"        , Tamsx3("F1_SERIE")[01] 	, Tamsx3("F1_SERIE")[02] 	,"Serie" 		,"Serie" 		,"Serie" 		,"Serie"		,"Serie"  		,"Serie" 		,"@!"   				,"u_BoVldNFEnt()" 			 								,cUsado  	,"" 				  			,"" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"15"      	,"ZR4_MOTOR"    		,"C"        , Tamsx3("A2_COD")[01]		, Tamsx3("A2_COD")[02] 		,"Motorista" 	,"Motorista"   	,"Motorista"   	,"Motorista"	,"Motorista"   	,"Motorista"   	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"Inclui"								,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"16"      	,"ZR4_LJMOTO"    		,"C"        , Tamsx3("A2_LOJA")[01] 	, Tamsx3("A2_LOJA")[02] 	,"Loja Motor" 	,"Romaneio"   	,"Romaneio"   	,"Romaneio"		,"Romaneio"   	,"Romaneio"   	,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"Inclui" 								,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"17"      	,"ZR4_NOME" 	    	,"C"        , Tamsx3("A2_NOME")[01] 	, Tamsx3("A2_NOME")[02] 	,"Nome"		 	,"Nome"   		,"Nome"   		,"Nome"			,"Nome"   		,"Nome"   		,"@!"   				,"" 						 								,cUsado     ,""    							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"18"      	,"ZR4_USER" 	   		,"C"        , 20 						, 0 						,"Usuario" 		,"Usuario"   	,"Usuario"   	,"Usuario"		,"Usuario"   	,"Usuario"   	,"@!"   				,"" 						 								,cUsado     ,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"20"      	,"ZR4_STATUS"    		,"C"        , 01 						, 0 						,"Status" 		,"Status"   	,"Status"   	,"Status"		,"Status"   	,"Status"   	,"@!"   				,"" 						 								,cNaoUsad   ,"'1'" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"1=Elaboração;2=Cotado;3=Faturado" 										,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"21"      	,"ZR4_OBSERV"    		,"M"        , 10 						, 0 						,"Observação"	,"Observação"  	,"Observação"  	,"Observação"	,"Observação"  	,"Observação"  	,""   					,"" 						 								,cUsado   	,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
aAdd( aSX3,	{	"ZR4"   	,"22"      	,"ZR4_OPERAC"    		,"C"        , 20 						, 0 						,"Operação"		,"Operação"  	,"Operação"  	,"Operação"		,"Operação"  	,"Operação"  	,""   					,"" 						 								,cUsado   	,"" 							,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"V"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })

//aAdd( aSX3,	{	"SA4"   	,"MM"      	,"A4_XFORNEC"    		,"C"        , Tamsx3("A2_COD")[01] 		, Tamsx3("A2_COD")[02] 		,"Fornecedor" 	,"Fornecedor"	,"Fornecedor" 	,"Fornecedor"	,"Fornecedor"   ,"Fornecedor"	,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"SA2" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })
//aAdd( aSX3,	{	"SA4"   	,"MN"      	,"A4_XLOJFOR"      		,"C"        , Tamsx3("A2_LOJA")[01] 	, Tamsx3("A2_LOJA")[02] 	,"Loja" 		,"Loja" 		,"Loja" 		,"Loja"			,"Loja"   		,"Loja" 		,"@!"   				,"" 						 								,cUsado  	,"" 				  			,"" 	 			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })

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
aEstrut:= {"INDICE"		,"ORDEM","CHAVE"						           															,"DESCRICAO"																,"DESCSPA"			,"DESCENG"						,"PROPRI"	,"F3"	,"NICKNAME"		,"SHOWPESQ"}
Aadd(aSIX,{"ZR1"		,"1"	,"ZR1_FILIAL + ZR1_ROMANE + ZR1_STATUS"																,"Romaneio + Status"														,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR1"		,"2"	,"DTos(ZR1_EMISSA)"																					,"Emissão"																	,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR1"		,"3"	,"ZR1_FILIAL + ZR1_MOTOR + ZR1_LJMOTO"																,"Motorista + Loja"															,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR1"		,"4"	,"ZR1_FILIAL + ZR1_FAPROV + ZR1_ROMANE + ZR1_STATUS"												,"Situação + Romaneio + Status"												,""					,""								,"U"		,""		,""         	,"S"})

Aadd(aSIX,{"ZR2"		,"1"	,"ZR2_FILIAL + ZR2_ROMANE + ZR2_TPDOC + ZR2_FILDOC + ZR2_DOCTO + ZR2_SERIE  + ZR2_CLIFOR + ZR2_LOJA"				,"Romaneio + Tipo Doc + Docto + Serie + Clifor + Loja"		,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR2"		,"2"	,"ZR2_FILIAL + ZR2_TPDOC  + ZR2_FILDOC + ZR2_DOCTO + ZR2_SERIE + ZR2_CLIFOR + ZR2_LOJA   + ZR2_ROMANE"			,"Tipo Doc + Docto + Serie + Clifor + Loja + Romaneio"			,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR2"		,"3"	,"ZR2_FILIAL + ZR2_TPDOC  + ZR2_FILDOC + ZR2_DOCTO + ZR2_SERIE + ZR2_CLIFOR + ZR2_LOJA + ZR2_SITUAC + ZR2_ROMANE"	,"Tipo Doc + Docto + Serie + Clifor + Loja + Romaneio"			,""					,""								,"U"		,""		,""         	,"S"})

/*/
Aadd(aSIX,{"ZR3"		,"1"	,"ZR3_FILIAL + ZR3_NUMERO + ZR3_ROMANE"																,"Numero + Romaneio"														,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR3"		,"2"	,"ZR3_FILIAL + ZR3_ROMANE + ZR3_NUMERO"																,"Romaneio + Numero"														,""					,""								,"U"		,""		,""         	,"S"})
/*/

Aadd(aSIX,{"ZR4"		,"1"	,"ZR4_FILIAL + ZR4_ROMANE + ZR4_SEQUEN + ZR4_STATUS"												,"Romaneio + Sequencia + Status"											,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR4"		,"2"	,"DTos(ZR4_EMISSA)"																					,"Emissão"																	,""					,""								,"U"		,""		,""         	,"S"})
Aadd(aSIX,{"ZR4"		,"3"	,"ZR4_FILIAL + ZR4_MOTOR + ZR4_LJMOTO"																,"Motorista + Loja"															,""					,""								,"U"		,""		,""         	,"S"})

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

aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"					}
Aadd( aSXB,	{"ZR1"		,"1"		,"01"		,"DB"			,"Romaneios Transporte"			,"Romaneios Transporte"			,"Romaneios Transporte"			,"ZR1"							})
Aadd( aSXB,	{"ZR1"		,"2"		,"01"		,"01"			,"Romaneio + Status"			,"Romaneio + Status"	   		,"Romaneio + Status"	   		,""								})
Aadd( aSXB,	{"ZR1"		,"4"		,"01"		,"01"			,"Romaneio"						,"Romaneio"				   		,"Romaneio"				  		,"ZR1_ROMANE"					})	
Aadd( aSXB,	{"ZR1"		,"4"		,"01"		,"02"			,"Emissão"						,"Emissão"				   		,"Emissão"				   		,"ZR1_EMISSA"					})	
Aadd( aSXB,	{"ZR1"		,"4"		,"01"		,"03"			,"Qtd Doctos"					,"Qtd Doctos"			   		,"Qtd Doctos"			   		,"ZR1_QTDOCS"					})	
Aadd( aSXB,	{"ZR1"		,"4"		,"01"		,"04"			,"Vlr Doctos"					,"Vlr Doctos"			   		,"Vlr Doctos"			   		,"ZR1_VLDOCS"					})	
Aadd( aSXB,	{"ZR1"		,"5"		,"01"		,""				,""								,""						   		,""						   		,"ZR1->ZR1_ROMANE"				})	
Aadd( aSXB,	{"ZR1"		,"6"		,"01"		,""				,""								,""						   		,""						   		,"ZR1->ZR1_STATUS=='1'"			})	

Aadd( aSXB,	{"DOCROM"	,"1"		,"01"		,"RE"			,"Documentos para Romaneio"     ,"Documentos para Romaneio"	    ,"Documentos para Romaneio"	    ,"SB1"							})
Aadd( aSXB,	{"DOCROM"	,"2"		,"01"		,"01"			,""				   			    ,""						   		,""						   		,"u_BoDocRoman()"    			})
Aadd( aSXB,	{"DOCROM"	,"5"		,"01"		,""				,""							    ,""						   		,""						   		,".T."	            			})	

Aadd( aSXB,	{"SF1ROM"	,"1"		,"01"		,"DB"			,"Doc Entrada Romaneio"			,"Doc Entrada Romaneio"			,"Doc Entrada Romaneio"			,"SF1"							})	
Aadd( aSXB,	{"SF1ROM"	,"2"		,"01"		,"01"			,"Numero + Serie + For"			,"Numero + Serie + For"			,"Numero + Serie + For"			,""								})	
Aadd( aSXB,	{"SF1ROM"	,"4"		,"01"		,"01"			,"Filial"						,"Filial"						,"Filial"						,"F1_FILIAL"					})	
Aadd( aSXB,	{"SF1ROM"	,"4"		,"01"		,"02"			,"Numero"						,"Numero"						,"Numero"						,"F1_DOC"						})	
Aadd( aSXB,	{"SF1ROM"	,"4"		,"01"		,"03"			,"Serie"						,"Serie"						,"Serie"						,"F1_SERIE"						})	
Aadd( aSXB,	{"SF1ROM"	,"4"		,"01"		,"04"			,"Fornecedor"					,"Fornecedor"					,"Fornecedor"					,"F1_FORNECE"					})	
Aadd( aSXB,	{"SF1ROM"	,"4"		,"01"		,"05"			,"Loja"							,"Loja"							,"Loja"							,"F1_LOJA"						})	
Aadd( aSXB,	{"SF1ROM"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"SF1->F1_FILIAL"				})	
Aadd( aSXB,	{"SF1ROM"	,"5"		,"02"		,""				,""								,""						   		,""						   		,"SF1->F1_DOC"					})	
Aadd( aSXB,	{"SF1ROM"	,"5"		,"03"		,""				,""								,""						   		,""						   		,"SF1->F1_SERIE"				})	
Aadd( aSXB,	{"SF1ROM"	,"5"		,"04"		,""				,""								,""						   		,""						   		,"SF1->F1_FORNECE"				})	
Aadd( aSXB,	{"SF1ROM"	,"5"		,"05"		,""				,""								,""						   		,""						   		,"SF1->F1_LOJA"					})

Aadd( aSXB,	{"SF2ROM"	,"1"		,"01"		,"DB"			,"Doc Saida Romaneio"			,"Doc Saida Romaneio"			,"Doc Saida Romaneio"			,"SF2"							})	
Aadd( aSXB,	{"SF2ROM"	,"2"		,"01"		,"01"			,"Numero + Serie + For"			,"Numero + Serie + For"			,"Numero + Serie + For"			,""								})	
Aadd( aSXB,	{"SF2ROM"	,"4"		,"01"		,"01"			,"Filial"						,"Filial"						,"Filial"						,"F2_FILIAL"					})	
Aadd( aSXB,	{"SF2ROM"	,"4"		,"01"		,"02"			,"Numero"						,"Numero"						,"Numero"						,"F2_DOC"						})	
Aadd( aSXB,	{"SF2ROM"	,"4"		,"01"		,"03"			,"Serie"						,"Serie"						,"Serie"						,"F2_SERIE"						})	
Aadd( aSXB,	{"SF2ROM"	,"4"		,"01"		,"04"			,"Cliente"						,"Cliente"						,"Cliente"						,"F2_CLIENTE"					})	
Aadd( aSXB,	{"SF2ROM"	,"4"		,"01"		,"05"			,"Loja"							,"Loja"							,"Loja"							,"F2_LOJA"						})	
Aadd( aSXB,	{"SF2ROM"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"SF2->F2_FILIAL"				})	
Aadd( aSXB,	{"SF2ROM"	,"5"		,"02"		,""				,""								,""						   		,""						   		,"SF2->F2_DOC"					})	
Aadd( aSXB,	{"SF2ROM"	,"5"		,"03"		,""				,""								,""						   		,""						   		,"SF2->F2_SERIE"				})	
Aadd( aSXB,	{"SF2ROM"	,"5"		,"04"		,""				,""								,""						   		,""						   		,"SF2->F2_CLIENTE"				})	
Aadd( aSXB,	{"SF2ROM"	,"5"		,"05"		,""				,""								,""						   		,""						   		,"SF2->F2_LOJA"					})

/*/
Aadd( aSXB,	{"ZR3"		,"1"		,"01"		,"DB"			,"Cotações Frete Roman"			,"Cotações Frete Roman"	   		,"Cotações Frete Roman"			,"ZR3"							})	
Aadd( aSXB,	{"ZR3"		,"2"		,"01"		,"02"			,"Romaneio + Numero"			,"Romaneio + Numero"	   		,"Romaneio + Numero"	   		,""								})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"01"			,"Romaneio"						,"Romaneio"				   		,"RomaneioV"			   		,"ZR3_ROMANE"					})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"02"			,"Numero"						,"Numero"				   		,"Numero"				   		,"ZR3_NUMERO"					})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"03"			,"Transport"					,"Transport"			   		,"Transport"			   		,"ZR3_TRANSP"					})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"04"			,"Nome"							,"Nome"					   		,"Nome"					   		,"ZR3_NOME"						})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"05"			,"Dt Coleta"					,"Dt Coleta"			   		,"Dt Coleta"			   		,"ZR3_DTCOLE"					})	
Aadd( aSXB,	{"ZR3"		,"4"		,"01"		,"06"			,"Vlr Frete"					,"Vlr Frete"			   		,"Vlr Frete"			   		,"ZR3_VLFRET"					})	
Aadd( aSXB,	{"ZR3"		,"5"		,"01"		,""				,""								,""						   		,""						   		,"ZR3->ZR3_NUMERO"				})	
Aadd( aSXB,	{"ZR3"		,"6"		,"01"		,""				,""								,""						   		,""						   		,"ZR3_ROMANE == ZR1_ROMANE .And. ZR3_STATUS = '2'"})	
/*/

SXB->(dbSetOrder(1))
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !SXB->(dbSeek(PadR(aSXB[i,1],Len(SXB->XB_ALIAS)) +;
						PadR(aSXB[i,2],Len(SXB->XB_TIPO)) 	+;
						PadR(aSXB[i,3],Len(SXB->XB_SEQ))	+;
						PadR(aSXB[i,4],Len(SXB->XB_COLUNA)) ))

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

aEstrut:= {"X7_CAMPO"	,"X7_SEQUENC"	,"X7_REGRA"						,"X7_CDOMIN"	,"X7_TIPO"	,"X7_SEEK"	,"X7_ALIAS"	,"X7_ORDEM"	,"X7_CHAVE"					        			,"X7_PROPRI"	,"X7_CONDIC"                }
/*/
aAdd(aSX7,{'ZR2_CLIFOR'	,'001'			,'U_BOGat1Roma()'    			,'ZR2_NOME'		,'P'		,'N'		,''			,0			,''								        		,'U'			,''							})
aAdd(aSX7,{'ZR2_LOJA'	,'001'			,'U_BOGat1Roma()'	   			,'ZR2_NOME'		,'P'		,'N'		,''			,0			,''								        		,'U'			,''							})
/*/

//aAdd(aSX7,{'ZR1_MOTOR','001'			,'SA2->A2_NOME' 	   			,'ZR1_NOME'		,'P'		,'S'		,'SA2'		,0			,'XFILIAL("SA2")+M->ZR1_MOTOR'	        		,'U'			,''							})
aAdd(aSX7,{'ZR1_LJMOTO'	,'001'			,'SA2->A2_NOME' 	   			,'ZR1_NOME'		,'P'		,'S'		,'SA2'		,1			,'XFILIAL("SA2")+M->(ZR1_MOTOR+ZR1_LJMOTO)'	    ,'U'			,'!EMPTY(M->ZR1_LJMOTO)'	})

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

Return         


User Function BoRomaUpd()
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"

If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
	cObrig   := "€€"
	cReserv  := "þÀ"	
	cNaoUsad := "€€€€€€€€€€€€€€€"      
	cUsado	 := "€€€€€€€€€€€€€€"
Else
	cObrig   := "     xx"
	cReserv  := "  x  x x"	
	cNaoUsad := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x"      
	cUsado	 := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"
EndIf
UpdDics(.f.)

Return


