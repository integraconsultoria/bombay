#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"

//************************************************************>> COMPATIBILIZADOR << ******

#DEFINE X3_USADO_EMUSO 		"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"
#DEFINE X3_USADO_NAOUSADO 	"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x"      

Static lFWCodFil := FindFunction("FWCodFil")

/*/{protheus.doc} BOUpdConPv
*******************************************************************************************
Compatibilizador/update das operacoes do controle de conferencia de pedidos
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BOUpdConPv()
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
			                  
cMsg := "Este Programa tem o objetivo de criar os dicionarios dos processos de conferencia e separação."+CRLF
cMsg += CRLF
cMsg += CRLF

If lExclusiv
	cMsg += "Avançar para a Continuar..."
Else
	cMsg += "Existem conexões no sistema que impedem o uso do compatibilizador nesse momento..."
EndIf	

DEFINE WIZARD oWizard 											;
		TITLE "Compatibilizador"								;
          	HEADER "CONTROLE DE CONFERENCIA E SEPARAÇÃO"   		;
          	MESSAGE "Update"									;
         	TEXT cMsg PANEL										;
          	NEXT 	{|| lExclusiv }								;
          	FINISH 	{|| lExclusiv }								; 
          	      
  	CREATE PANEL oWizard 										;				
          	HEADER "CONTROLE DE CONFERENCIA E SEPARAÇÃO"	    ;
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
          	HEADER "CONTROLE DE CONFERENCIA E SEPARAÇÃO";
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
@since: 15/12/2020
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
@since: 15/12/2020
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
@since: 15/12/2020
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
@since: 15/12/2020
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

If MsgYesNo("Confirma o Compatibilizador das operacoes de conferencia e separação?"+CRLF+"PERSONALIZAÇÃO DE VENDAS")
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
@since: 15/12/2020
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
@since: 15/12/2020
@param: 
@return:
@type function: Caracter
*******************************************************************************************
/*/
Static Function UpdDics(lFisico)
Local aTabelas  := {"SC5","SC6"}
Local aSX2 		:= {} 
Local aSX3 		:= {} 
Local aSX6 		:= {} 
Local aSIX 		:= {} 
Local aEstrut	:= {}
Local i, j, nX, nY    
Local aArea		:= GetArea()     
Local aStruct	:= {}
Local nTamFil 	:= GetTamSXG("033",TAMSX3("E2_FILIAL")[1])[1]
Local nTamSX1  	:= Len(SX1->X1_GRUPO)
Local cCpoFil	:= ""
Local aCpoFil	:= {}  
Local aCpoObrig	:= {}
Local aFilsSel	:= {}
Local nPosSM0	:= 0

Private _cOrdem	:= ""

//->> Criando array de filiais
nPosSM0 := SM0->(Recno())                
SM0->(dbGotop())
SM0->(dbSeek(cEmpAnt))
Do While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	aAdd(aFilsSel,SM0->M0_CODFIL) 
	SM0->(dbSkip())
EndDo
SM0->(dbGoto(nPosSM0))

Default lFisico	:= .T.
              
Private lUpdAuto 
               
//->> Criacao da Tabela
aEstrut:= 	{"X2_CHAVE"		,"X2_PATH"		,"X2_ARQUIVO"	,"X2_NOME"							,"X2_NOMESPAC"				   		,"X2_NOMEENGC"			   	   		,"X2_DELET"	,"X2_MODO"	,"X2_TTS"	,"X2_ROTINA"	}

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
aEstrut:= 	{	"X3_ARQUIVO","X3_ORDEM" 				,"X3_CAMPO"  	,"X3_TIPO"  ,"X3_TAMANHO"				,"X3_DECIMAL"				,"X3_TITULO" 			,"X3_TITSPA"		,"X3_TITENG"		,"X3_DESCRIC"			,"X3_DESCSPA"		,"X3_DESCENG"		,"X3_PICTURE"					,"X3_VALID" 											,"X3_USADO"  		,"X3_RELACAO"					,"X3_F3"			,"X3_NIVEL" ,"X3_RESERV","X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"									,"X3_CBOX"   																			,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"  ,"X3_INIBRW"		,"X3_GRPSXG","X3_FOLDER"	,"X3_PYME"	}			

_cOrdem:= ""
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XUSCONF")		,"C5_XUSCONF"	,"C"		, 20						, 0							,"Usuario Conf."		,""					,""					,"Usuario Conferencia"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XTECONF")		,"C5_XTECONF"	,"C"		, 8							, 0							,"Tempo Conf."			,""					,""					,"Tempo Conferencia"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XUSEMBA")		,"C5_XUSEMBA"	,"C"		, 20						, 0							,"Embalador"			,""					,""					,"Embalador"			,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 

aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XSTATUS")		,"C5_XSTATUS"	,"C"		, 01						, 0							,"Status"				,""					,""					,"Status"				,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,"0=Blq;1=Blq Regras;2=Blq Estoque;3=Pend Separacao;4=Pend Logistico;5=Pend Exped"		,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XDLIBRE")		,"C5_XDLIBRE"	,"C"		, 20						, 0							,"Lib Regras"			,""					,""					,"Liberacao das Regras"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XDLIBES")		,"C5_XDLIBES"	,"C"		, 20						, 0							,"Lib Estoque"			,""					,""					,"Liberacao do Estoque"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XDLIBLO")		,"C5_XDLIBLO"	,"C"		, 20						, 0							,"Lib Logistica"		,""					,""					,"Liberacao Logistica"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XDLIBEX")		,"C5_XDLIBEX"	,"C"		, 20						, 0							,"Lib Expedicao"		,""					,""					,"Liberacao Expedicao"	,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XDENTRE")		,"C5_XDENTRE"	,"D"		, 08						, 0							,"Data Entrega"			,""					,""					,"Data Entrega"			,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC5"		,GetOrdem("C5_XTRACKI")		,"C5_XTRACKI"	,"C"		, 30						, 0							,"Tracking"				,""					,""					,"Tracking"				,""					,""			  		,"@!"							,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,""				,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 

_cOrdem:= ""
aAdd( aSX3,	{ 	"SC6"		,GetOrdem("C6_XDTCONF")		,"C6_XDTCONF"	,"D"		, 8							, 0							,"Data Conf."			,""					,""					,"data Conferencia"		,""					,""			  		,""								,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,"" 			,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 
aAdd( aSX3,	{ 	"SC6"		,GetOrdem("C6_XQTCONF")		,"C6_XQTCONF"	,"N"		, Tamsx3("C6_QTDVEN")[1]	, Tamsx3("C6_QTDVEN")[2]	,"Qtd Conferida"		,""					,""					,"Qtd Conferida"		,""					,""			  		,PesqPict("SC6","C6_QTDVEN")	,""														,X3_USADO_EMUSO		,""								,""					,0			,"þÀ"		,""			,""				,"U"		,"S"		,"V"		,"R"			,"" 			,""												,""										  												,""				,""				,""				,""			,""			  		,""			,""				,"S"		}) 

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
aEstrut:= {"INDICE"	,"ORDEM","CHAVE"																				,"DESCRICAO"													,"DESCSPA"												,"DESCENG"												,"PROPRI"	,"F3"	,"NICKNAME"		,"SHOWPESQ"}

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
		dbSelecTArea(aTabelas[nX])
	Else
		aAdd(_aTabelas,aTabelas[nX])
	EndIf	
Next nX

aEstrut:= {"X6_FIL"									,"X6_VAR"		,"X6_TIPO"	,"X6_DESCRIC"									,"X6_DSCSPA","X6_DSCENG","X6_DESC1"								,"X6_DSCSPA1"	,"X6_DSCENG1"	,"X6_DESC2"										,"X6_DSCSPA2"	,"X6_DSCENG2"	,"X6_CONTEUD"							,"X6_CONTSPA"	,"X6_CONTENG"	,"X6_PROPRI","X6_PYME"	}
For nX:=1 to Len(aFilsSel)
	AAdd(aSX6,{PadR(aFilsSel[nX],Len(SX6->X6_FIL))	,"BO_CONFPV"	,"C"		,"SE CONTROLE DE CONFERENCIA DE PV SERA USADO."	,""			,""			,"S=SIM, N=NAO"							,""				,""				,""												,""				,""				,"N"									,""				,""				,"U"		,"S"		})
	AAdd(aSX6,{PadR(aFilsSel[nX],Len(SX6->X6_FIL))	,"BO_SUGQTDC"	,"C"		,"SE SALDO DA CONFERENCIA SERA SUGERIDA."		,""			,""			,"S=SIM, N=NAO"							,""				,""				,""												,""				,""				,"N"									,""				,""				,"U"		,"S"		})	
Next nX

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

u_BOAjsGatB1()

Return         

/*/{protheus.doc} GetTamSXG
*******************************************************************************************
Retorna o tamanho do grupo de campos.
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Caracter
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

/*/{protheus.doc} GetOrdem
*******************************************************************************************
Retorna a ordem do campo
 
@author: Marcelo Celi Marques
@since: 15/12/2020
@param: 
@return:
@type function: Caracter
*******************************************************************************************
/*/
Static Function GetOrdem(cCpo)
Local cOrdem := ""
Local aArea	 := GetArea()
Local cAlias := If(SubStr(cCpo,3,1)=="_","S"+Left(cCpo,2),Left(cCpo,3))

SX3->(dbSetOrder(2))
If SX3->(dbSeek(cCpo))
	cOrdem := SX3->X3_ORDEM
Else
	If !Empty(_cOrdem)
		_cOrdem := Soma1(_cOrdem)		
	Else
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(cAlias))
		Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
			If _cOrdem < SX3->X3_ORDEM
				_cOrdem := SX3->X3_ORDEM
			EndIf
			SX3->(dbSkip())
		EndDo
		If Empty(_cOrdem)
			_cOrdem := "01"
		Else
			_cOrdem := Soma1(_cOrdem)
		EndIf
	EndIf
	cOrdem	:= _cOrdem
EndIf

RestArea(aArea)

Return cOrdem
