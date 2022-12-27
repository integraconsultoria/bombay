#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "apwizard.ch"
#include 'fileio.ch'

//************************************************************>> COMPATIBILIZADOR << ******
Static lFWCodFil := FindFunction("FWCodFil")

/*/{protheus.doc} MadUpdEco
*******************************************************************************************
Compatibilizador/update das operacoes do ecommerce

@author: Marcelo Celi Marques
@since: 21/10/2021
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MadUpdEco()
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
			                  
cMsg := "Este Programa tem o objetivo de criar os dicionarios dos processos de eCommerce."+CRLF
cMsg += CRLF
cMsg += CRLF

If lExclusiv
	cMsg += "Avançar para a Continuar..."
Else
	cMsg += "Existem conexões no sistema que impedem o uso do compatibilizador nesse momento..."
EndIf	

DEFINE WIZARD oWizard 											;
		TITLE "Compatibilizador"								;
          	HEADER "E-COMMERCE"					        		;
          	MESSAGE "Update"									;
         	TEXT cMsg PANEL										;
          	NEXT 	{|| lExclusiv }								;
          	FINISH 	{|| lExclusiv }								; 
          	      
  	CREATE PANEL oWizard 										;				
          	HEADER "E-COMMERCE"							        ;
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
          	HEADER "E-COMMERCE"				        	;
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
@since: 21/10/2021
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
@since: 21/10/2021
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
@since: 21/10/2021
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
@since: 21/10/2021
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

If MsgYesNo("Confirma o Compatibilizador das operacoes de E-COMMERCE?"+CRLF+"PERSONALIZAÇÃO DE VENDAS")
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
@since: 21/10/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AdmAbreSM0()
Local aAux			:= {}
Local aRetSM0		:= {}
Local aRetEmp		:= {}
Local lFWLoadSM0	:= .F.
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
@since: 21/10/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function UpdDics(lFisico)
Local aTabelas  := {}
Local aSXA 		:= {}
Local aSXB 		:= {}
Local aSX2 		:= {}
Local aSX3 		:= {}
Local aSX7 		:= {}
Local aSIX 		:= {}
Local aEstrut	:= {}
Local i, j, nX
Local nTamFil 	:= GetTamSXG("033",TAMSX3("E2_FILIAL")[1])[1]

Default lFisico	:= .T.

Private lUpdAuto 

Private Tb_Ferra 	:= u_MAECGetTb("FER")
Private Tb_Ecomm 	:= u_MAECGetTb("ECO")
Private Tb_Conex 	:= u_MAECGetTb("CON")
Private Tb_Produ 	:= u_MAECGetTb("PRD")
Private Tb_Estru 	:= u_MAECGetTb("EST")
Private Tb_IDS 		:= u_MAECGetTb("IDS")
Private Tb_Monit    := u_MAPNGetTb("MON")
Private Tb_ChMon    := u_MAPNGetTb("CHM")
Private Tb_LgMon    := u_MAPNGetTb("LOG")
Private Tb_ThMon    := u_MAPNGetTb("THR")
Private Tb_Depar    := u_MACDGetTb("DEP")
Private Tb_Categ    := u_MACDGetTb("CAT")
Private Tb_Marca    := u_MACDGetTb("MRC")
Private Tb_Fabri    := u_MACDGetTb("FAB")
Private Tb_Canal    := u_MACDGetTb("CAN")
Private Tb_TbPrc    := u_MACDGetTb("TPC")
Private Tb_TbSta	:= u_MACDGetTb("STA")
Private Tb_CondP	:= u_MACDGetTb("PGT")
Private Tb_Transp	:= u_MACDGetTb("TRA")
Private Tb_Voucher	:= u_MACDGetTb("DSC")

If 	u_MAVldMonit(Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,.F.,.T.) 					.And. ;
	u_MAVldEcomm(Tb_Ferra,Tb_Ecomm,Tb_Conex,Tb_Produ,Tb_Estru,Tb_IDS,.F.,.T.)	.And. ;
	u_MAVldCadEC(Tb_Depar,Tb_Categ,Tb_Marca,Tb_Fabri,Tb_Canal,Tb_TbPrc,Tb_TbSta,Tb_CondP,Tb_Transp,Tb_Voucher,.F.,.T.)

	aTabelas  := {Tb_Ferra,Tb_Ecomm,Tb_Conex,Tb_Produ,Tb_Estru,Tb_IDS,Tb_Monit,Tb_ChMon,Tb_LgMon,Tb_ThMon,Tb_Depar,Tb_Categ,Tb_Marca,Tb_Fabri,Tb_TbSta,Tb_CondP,Tb_Transp,Tb_Voucher,"SB2","SCJ","SC0","SC5","SC9","SA1"}

	//->> Criacao da Tabela
	aEstrut:= 	{"X2_CHAVE"		,"X2_PATH"		,"X2_ARQUIVO"		,"X2_NOME"					    	,"X2_NOMESPAC"						,"X2_NOMEENGC"			   			,"X2_DELET"	,"X2_MODO"	,"X2_MODOUN","X2_MODOEMP"  	,"X2_TTS"	,"X2_ROTINA"	}	
	aAdd( aSX2, {Tb_Ferra		,"\DADOSADV\"	, Tb_Ferra+"010"	,"Ferramenta de e-Commerce"   		,"Ferramenta de e-Commerce"  		,"Ferramenta de e-Commerce"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 	
	aAdd( aSX2, {Tb_Ecomm		,"\DADOSADV\"	, Tb_Ecomm+"010"	,"Cadastro de e-Commerce"   		,"Cadastro de e-Commerce"  			,"Cadastro de e-Commerce"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Conex		,"\DADOSADV\"	, Tb_Conex+"010"	,"Conexoes de e-Commerce"  			,"Conexoes de e-Commerce"  			,"Conexoes de e-Commerce"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Produ		,"\DADOSADV\"	, Tb_Produ+"010"	,"Produtos e-Commerce"     			,"Produtos e-Commerce"     			,"Produtos e-Commerce"				,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Estru 		,"\DADOSADV\"	, Tb_Estru+"010"	,"Estrutura Prod e-Comm"   			,"Estrutura Prod e-Comm" 			,"Estrutura Prod e-Comm"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_IDS			,"\DADOSADV\"	, Tb_IDS+"010"		,"IDs Produtos no Site"	 	    	,"IDs Produtos no Site" 	    	,"IDs Produtos no Site"				,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Monit		,"\DADOSADV\"	, Tb_Monit+"010"	,"Monitor de Integracoes" 	    	,"Monitor de Integracoes" 	    	,"Monitor de Integracoes"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_ChMon		,"\DADOSADV\"	, Tb_ChMon+"010"	,"Chamadas Monitor Integracoes" 	,"Chamadas Monitor Integracoes" 	,"Chamadas Monitor Integracoes"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_LgMon		,"\DADOSADV\"	, Tb_LgMon+"010"	,"Chamadas Monitor Integracoes" 	,"Chamadas Monitor Integracoes" 	,"Chamadas Monitor Integracoes"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_ThMon 		,"\DADOSADV\"	, Tb_ThMon+"010"	,"Threads Operacao Mon. Integ." 	,"Threads Operacao Mon. Integ." 	,"Threads Operacao Mon. Integ."		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Depar 		,"\DADOSADV\"	, Tb_Depar+"010"	,"Cadastro Departamento e-Comm"		,"Cadastro Departamento e-Comm" 	,"Cadastro Departamento e-Comm"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Categ 		,"\DADOSADV\"	, Tb_Categ+"010"	,"Cadastro Categorias e-Comm"		,"Cadastro Categorias e-Comm"   	,"Cadastro Categorias e-Comm"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Marca 		,"\DADOSADV\"	, Tb_Marca+"010"	,"Cadastro Marcas e-Comm"			,"Cadastro Marcas e-Comm"   		,"Cadastro Marcas e-Comm"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Fabri 		,"\DADOSADV\"	, Tb_Fabri+"010"	,"Cadastro Fabricantes e-Comm"		,"Cadastro Fabricantes e-Comm"  	,"Cadastro Fabricantes e-Comm"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Canal 		,"\DADOSADV\"	, Tb_Canal+"010"	,"Cadastro Canais e-Comm"			,"Cadastro Canais e-Comm"  			,"Cadastro Canais e-Comm"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_TbPrc 		,"\DADOSADV\"	, Tb_TbPrc+"010"	,"Tab Precos x Canais e-Comm"		,"Tab Precos x Canais e-Comm"  		,"Tab Precos x Canais e-Comm"		,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_TbSta 		,"\DADOSADV\"	, Tb_TbSta+"010"	,"Cadastro Status Vendas e-Comm"	,"Cadastro Status Vendas e-Comm"	,"Cadastro Status Vendas e-Comm"	,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_CondP 		,"\DADOSADV\"	, Tb_CondP+"010"	,"Cadastro Condição Pgto"			,"Cadastro Condição Pgto"			,"Cadastro Condição Pgto"			,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Transp 		,"\DADOSADV\"	, Tb_Transp+"010"	,"Cadastro Transportadoras e-Comm"	,"Cadastro Transportadoras e-Comm"	,"Cadastro Transportadoras e-Comm"	,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	aAdd( aSX2, {Tb_Voucher		,"\DADOSADV\"	, Tb_Voucher+"010"	,"Cadastro Voucher Desconto e-Comm"	,"Cadastro Voucher Desconto e-Comm"	,"Cadastro Voucher Desconto e-Comm"	,0			,"C"		,"C"		, "C"			," "		,"             "}) 
	
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
	aEstrut:= 	{	"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"     		,"X3_TIPO"  ,"X3_TAMANHO"   			,"X3_DECIMAL"   			,"X3_TITULO"     		,"X3_TITSPA"    ,"X3_TITENG"    ,"X3_DESCRIC"		       					,"X3_DESCSPA"	           	,"X3_DESCENG"	        ,"X3_PICTURE"					,"X3_VALID" 									         								,"X3_USADO" 		,"X3_RELACAO"	     																,"X3_F3"   			,"X3_NIVEL","X3_RESERV" ,"X3_CHECK" ,"X3_TRIGGER"   ,"X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT"   ,"X3_OBRIGAT"   ,"X3_VLDUSER"					   				,"X3_CBOX"   									    						,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN" 							 	,"X3_INIBRW"  																	,"X3_GRPSXG","X3_FOLDER"	,"X3_PYME"	}			
	//->> Campos do Cadastro de Ferramenta de e-commerce
	aAdd( aSX3,	{	Tb_Ferra       	,"01"      	,Tb_Ferra+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ferra       	,"02"      	,Tb_Ferra+"_CODIGO"   	,"C"        , 10             			, 0              			,"Codigo"       		,"Codigo"       ,"Codigo"       ,"Codigo Integracao"       					,"Codigo Integracao"        ,"Codigo Integracao"    ,"@!"                           ,"" 										 											,cUsado     		,""    																				,""        			,1         ,cObrig     	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui"    							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ferra       	,"03"      	,Tb_Ferra+"_DESCRI"   	,"C"        , 100             			, 0              			,"Descricao"    		,"Descricao"    ,"Descricao"    ,"Descricao"  			   					,"Descricao"   		       	,"Descricao" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	//->> Campos do Cadastro de e-commerce
	aAdd( aSX3,	{	Tb_Ecomm       	,"01"      	,Tb_Ecomm+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"02"      	,Tb_Ecomm+"_CODIGO"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,"Tecnologia"   ,"Tecnologia"   ,"Tecnologia Integracao"       				,"Tecnologia Integracao"    ,"Tecnologia Integracao","@!"                           ,"ExistCpo( '"+Tb_Ferra+"', M->&("+Tb_Ecomm+"_CODIGO)) .And. ExistChav('"+Tb_Ecomm+"')"	,cUsado     		,""    																				,Tb_Ferra  			,1         ,cObrig     	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui"    							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"03"      	,Tb_Ecomm+"_DESCRI"   	,"C"        , 30             			, 0              			,"Descricao"    		,"Descricao"    ,"Descricao"    ,"Descricao"  			   					,"Descricao"   		       	,"Descricao" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"04"      	,Tb_Ecomm+"_LOGO"     	,"C"        , 30             			, 0              			,"Logotipo"				,"Logotipo"  	,"Logotipo"  	,"Logotipo"  			   					,"Logotipo Integração"      ,"Logotipo Integração" 	,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"05"      	,Tb_Ecomm+"_URL"      	,"C"        , 180             			, 0              			,"URL"  				,"URL"  		,"URL"  		,"URL"  		   							,"URL"  		    		,"URL" 		    		,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"06"      	,Tb_Ecomm+"_USER"     	,"C"        , 180             			, 0              			,"Usuario"	 			,"Usuario"  	,"Usuario" 		,"Usuario"  	   							,"Usuario"  		    	,"Usuario" 				,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"07"      	,Tb_Ecomm+"_SENHA"    	,"C"        , 180             			, 0              			,"Senha" 				,"Senha"  		,"Senha" 		,"Senha"  	   								,"Senha"  		    		,"Senha" 				,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"08"      	,Tb_Ecomm+"_TOKEN"    	,"C"        , 180             			, 0              			,"Token" 				,"Token"  		,"Token" 		,"Token"  	   								,"Token"  		    		,"Token" 				,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"09"      	,Tb_Ecomm+"_URLTOK"    	,"C"        , 180             			, 0              			,"URL Token" 			,"URL Token"	,"URL Token"	,"URL Token"  		 	  					,"URL Token"  			    ,"URL Token"	 		,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"10"      	,Tb_Ecomm+"_IDCONN"    	,"C"        , 180             			, 0              			,"Id Conexao" 			,"Id Conexao"	,"Id Conexao"	,"Id Conexao"  		 	  					,"Id Conexao"  			    ,"Id Conexao"	 		,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"11"      	,Tb_Ecomm+"_IDSECR"    	,"C"        , 180             			, 0              			,"Id Secreto" 			,"Id Secreto"	,"Id Secreto"	,"Id Secreto"  		 	  					,"Id Secreto"  			    ,"Id Secreto"	 		,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"12"      	,Tb_Ecomm+"_MSBLQL"   	,"C"        , 01             			, 0              			,"Bloqueado"			,"Bloqueado"	,"Bloqueado"	,"Bloqueado" 				   				,"Bloqueado" 		   		,"Bloqueado" 	   		,"@!" 	                        ,"Pertence('12')"                               										,cUsado     		,"'2'"          																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Sim;2=Nao"      														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"13"      	,Tb_Ecomm+"_LOCAL"   	,"C"        , Tamsx3("B1_LOCPAD")[01] 	, 0              			,"Armazem"				,"Armazem"		,"Armazem"		,"Armazem" 	 		  						,"Armazem" 		  			,"Armazem"	 	   		,"@!" 	                        ,"NaoVazio() .And. ExistCpo( 'NNR', M->"+Tb_Ecomm+"_LOCAL  )"      		     			,cUsado   			,""             																	,"NNR"    			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"14"      	,Tb_Ecomm+"_TABPRC"   	,"C"        , Tamsx3("DA0_CODTAB")[01] 	, 0              			,"Tab. Preco"			,"Tab. Preco"	,"Tab. Preco"	,"Tab. Preco" 	 		  					,"Tab. Preco" 		  		,"Tab. Preco"	 	    ,"@!" 	                        ,"NaoVazio() .And. ExistCpo( 'DA0', M->"+Tb_Ecomm+"_TABPRC )" 	     					,cUsado   			,""             																	,"DA0"    			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"15"      	,Tb_Ecomm+"_NATPAD"   	,"C"        , Tamsx3("ED_CODIGO")[01] 	, 0              			,"Natureza Pad"			,"Natureza Pad"	,"Natureza Pad"	,"Natureza Pad" 	 		  				,"Natureza Pad" 	  		,"Natureza Pad" 	    ,"@!" 	                        ,"Vazio() .Or. ExistCpo('SED',M->"+Tb_Ecomm+"_NATPAD)"      							,cUsado   			,""             																	,"SED"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"16"      	,Tb_Ecomm+"_TESPAD"   	,"C"        , Tamsx3("F4_CODIGO")[01] 	, 0              			,"Tes Pad"				,"Tes Pad"		,"TES Pad"		,"TES Pad" 	 		  						,"TES Pad" 	  				,"TES Pad" 	    		,"@!" 	                        ,"Vazio() .Or. ExistCpo('SF4',M->"+Tb_Ecomm+"_TESPAD)"      							,cUsado   			,""             																	,"SF4"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"17"      	,Tb_Ecomm+"_TESBRI"   	,"C"        , Tamsx3("F4_CODIGO")[01] 	, 0              			,"Tes Brinde"			,"Tes Brinde"	,"TES Brinde"	,"TES Brinde" 	 							,"TES Brinde" 	  			,"TES Brinde" 	    	,"@!" 	                        ,"Vazio() .Or. ExistCpo('SF4',M->"+Tb_Ecomm+"_TESBRI)"      							,cUsado   			,""             																	,"SF4"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"18"      	,Tb_Ecomm+"_CNDPAD"   	,"C"        , Tamsx3("E4_CODIGO")[01] 	, 0              			,"Cond Pgto Pad"		,"Cond Pgto Pad","Cond Pgto Pad","Cond Pgto Pad" 	   						,"Cond Pgto Pad" 	  		,"Cond Pgto Pad" 	    ,"@!" 	                        ,"Vazio() .Or. ExistCpo('SE4',M->"+Tb_Ecomm+"_CNDPAD)"      							,cUsado   			,""             																	,"SE4"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"19"      	,Tb_Ecomm+"_OPEPAD"   	,"C"        , Tamsx3("C6_OPER")[01] 	, 0              			,"Operacao Pad"			,"Operacao Pad"	,"Operacao Pad"	,"Operacao Pad" 	   						,"Operacao Pad" 	  		,"Operacao Pad" 	    ,"@!" 	                        ,"Vazio() .Or. ExistCpo('SX5','DJ'+M->"+Tb_Ecomm+"_OPEPAD)" 							,cUsado   			,""             																	,"DJ"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"20"      	,Tb_Ecomm+"_OPEBRI"   	,"C"        , Tamsx3("C6_OPER")[01] 	, 0              			,"Operacao Brinde"		,"Operacao Brinde"	,"Operacao Brinde"	,"Operacao Brinde" 	 				,"Operacao Brinde" 	  		,"Operacao Brinde" 	    ,"@!" 	                        ,"Vazio() .Or. ExistCpo('SX5','DJ'+M->"+Tb_Ecomm+"_OPEBRI)" 							,cUsado   			,""             																	,"DJ"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"21"      	,Tb_Ecomm+"_VENDED"   	,"C"        , Tamsx3("A3_COD")[01] 		, 0              			,"Vendedor Pad"			,"Vendedor Pad"	,"Vendedor Pad"	,"Vendedor Pad" 	   						,"Vendedor Pad" 	  		,"Vendedor Pad" 	    ,"@!" 	                        ,"Vazio() .Or. ExistCpo('SA3',M->"+Tb_Ecomm+"_VENDED)" 									,cUsado   			,""             																	,"SA3"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"22"      	,Tb_Ecomm+"_CTAPAD"   	,"C"        , Tamsx3("A1_CONTA")[01] 	, 0              			,"Conta Pad"			,"Conta Pad"	,"Conta Pad"	,"Conta Pad" 	   							,"Conta Pad" 	  			,"Conta Pad" 	    	,"@!" 	                        ,"Vazio() .Or. ExistCpo('CT1',M->"+Tb_Ecomm+"_CTAPAD)"      							,cUsado   			,""             																	,"CT1"    			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"23"      	,Tb_Ecomm+"_GERPV"   	,"C"        , 1 						, 0              			,"Gera PV"				,"Gera PV"		,"Gera PV"		,"Gera PV" 	   								,"Gera PV" 		  			,"Gera PV" 		    	,"@!" 	                        ,"Pertence('SN')" 																		,cUsado   			,"'N'"             																	,""    				,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"S=Sim;N=Nao"         														,""             ,""             ,""             ,"" 									,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"24"      	,Tb_Ecomm+"_GERNOT"   	,"C"        , 1 						, 0              			,"Gera Nota"			,"Gera Nota"	,"Gera Nota"	,"Gera Nota" 	   							,"Gera Nota" 		  		,"Gera Nota" 		    ,"@!" 	                        ,"Pertence('SN')" 																		,cUsado   			,"'N'"             																	,""    				,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"S=Sim;N=Nao"         														,""             ,""             ,""             ,"M->"+Tb_Ecomm+"_GERPV == 'S'"			,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"25"      	,Tb_Ecomm+"_SERIE"    	,"C"        , Tamsx3("F2_SERIE")[01] 	, 0              			,"Serie Doc"			,"Serie Doc"	,"Serie Doc"	,"Serie Doc" 	   							,"Serie Doc" 		  		,"Serie Doc" 		    ,"@!" 	                        ,"If(m->"+Tb_Ecomm+"_GERNOT=='S',NaoVazio(),Vazio())" 									,cUsado   			,""             																	,""    				,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"M->"+Tb_Ecomm+"_GERNOT == 'S'" 		,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"26"      	,Tb_Ecomm+"_FILECO"   	,"C"        , nTamFil        			, 0              			,"Filial e-Commerce"	,"Sucursal"     ,"Branch"       ,"Filial do e-Commerce"       				,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cUsado 			,""             																	,"SM0"     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"27"      	,Tb_Ecomm+"_ULTPRC"   	,"D"        , 08             			, 0              			,"Ult.Processamento"	,"Ult.Process"	,"Ult.Process"	,"Ult.Processamento"			   			,"Ult.Processamento"	    ,"Ult.Processamento"    ,"" 	                        ,""                               														,cUsado    		 	,"Date()"          																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""      																	,""             ,""             ,""             ,""          							,""             																,""         ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"28"      	,Tb_Ecomm+"_IDDEP"   	,"C"        , 10   		     			, 0              			,"Id Depart Def"		,"Id Depart Def","Id Depart Def","Id Depart Def" 		      				,"Id Depart Def"     		,"Id Depart Def" 	    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"29"      	,Tb_Ecomm+"_IDCAT"   	,"C"        , 10   		     			, 0              			,"Id Categ Def"			,"Id Categ Def","Id Categ Def","Id Categ Def" 		      					,"Id Categ Def"     		,"Id Categ Def" 	    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"30"      	,Tb_Ecomm+"_IDMAR"   	,"C"        , 10   		     			, 0              			,"Id Marca Def"			,"Id Marca Def","Id Marca Def","Id Marca Def" 		      					,"Id Marca Def"     		,"Id Marca Def" 	    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"31"      	,Tb_Ecomm+"_IDFOR"   	,"C"        , 10   		     			, 0              			,"Id Fabric Def"		,"Id Fabric Def","Id Fabric Def","Id Fabric Def" 		      				,"Id Fabric Def"     		,"Id Fabric Def" 	    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"32"      	,Tb_Ecomm+"_TPFRET"   	,"C"        , 01   		     			, 0              			,"Tp Frete"				,"Tp Frete"		,"Tp Frete"		,"Tp Frete" 		      					,"Tp Frete"		     		,"Tp Frete" 		    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete","",""       ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })		
	aAdd( aSX3,	{	Tb_Ecomm       	,"33"      	,Tb_Ecomm+"_TRFSTA"   	,"C"        , 01   		     			, 0              			,"Trans.Status PV"		,"Trans.Status PV","Trans.Status PV","Trans.Status PV" 		      			,"Trans.Status PV"	   		,"Trans.Status PV" 	    ,"@!"                           ,"Pertence('12')"                                             							,cUsado 			,"'1'"             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Com NFe Transmitida;2=Com Documento Saida Gerado"						,""				,""       		,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })			
	aAdd( aSX3,	{	Tb_Ecomm       	,"34"      	,Tb_Ecomm+"_ARMSIT"   	,"C"        , 20   		     			, 0              			,"Id Armaz.Site"		,"Id Armaz.Site","Id Armaz.Site","Id Armaz.Site" 		      				,"Id Armaz.Site"     		,"Id Armaz.Site" 	    ,""                             ,""                                             										,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"35"      	,Tb_Ecomm+"_DIGRFE"   	,"N"        , 02   		     			, 0              			,"Dias Vdas Grafico"	,"Dias Vdas Grafico","Dias Vdas Grafico","Dias Vdas Grafico" 				,"Dias Vdas Grafico"   		,"Dias Vdas Grafico" 	,"99"                           ,"NaoVazio() .And. Positivo()"                             								,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })
	aAdd( aSX3,	{	Tb_Ecomm       	,"36"      	,Tb_Ecomm+"_QTPRGE"   	,"N"        , 02   		     			, 0              			,"Prods.Vdas Grafico"	,"Prods.Vdas Grafico","Prods.Vdas Grafico","Prods.Vdas Grafico" 			,"Prods.Vdas Grafico"   	,"Prods.Vdas Grafico" 	,"99"                           ,"NaoVazio() .And. Positivo()"                             								,cUsado 			,""             																	,""     			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""  	    ,"2"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Ecomm       	,"37"      	,Tb_Ecomm+"_CARGPR"   	,"C"        , 1 						, 0              			,"Carga Produto"		,"Carga Produto"  ,"Carga Produto","Carga Produto" 	   						,"Carga Produto" 		  	,"Carga Produto" 		,"@!" 	                        ,"Pertence('123')" 																		,cUsado   			,"'3'"             																	,""    				,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Na Subida;2=Na Descida;3=Ambos"         								,""             ,""             ,""             ,""										,""             																,""         ,"2"         	,"S"        })	
	//->> Campos dos endpoints do e-commerce
	aAdd( aSX3,	{	Tb_Conex       	,"01"      	,Tb_Conex+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"02"      	,Tb_Conex+"_CODIGO"   	,"C"        , 10             			, 0              			,"Codigo"       		,"Codigo"       ,"Codigo"       ,"Codigo Integracao"       					,"Codigo Integracao"        ,"Codigo Integracao"    ,"@!"                           ,"" 													 								,cNaoUsad   		,""    																				,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,".F." 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"03"      	,Tb_Conex+"_CDPATH"   	,"C"        , 03             			, 0              			,"Cd.Endpoint"   		,"Cd.Endpoint"  ,"Cd.Endpoint"  ,"Cd.Endpoint"  			   				,"Cd.Endpoint"   		   	,"Cd.Endpoint" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"04"      	,Tb_Conex+"_DESCRI"   	,"C"        , 30             			, 0              			,"Descricao"    		,"Descricao"    ,"Descricao"    ,"Descricao"  			   					,"Descricao"   		       	,"Descricao" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"05"      	,Tb_Conex+"_PATH"     	,"C"        , 180             			, 0              			,"EndPoint" 			,"EndPoint"  	,"EndPoint" 	,"EndPoint"  	   							,"EndPoint"  		    	,"EndPoint" 			,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"06"      	,Tb_Conex+"_URL"     	,"C"        , 180             			, 0              			,"URL Especifica" 		,"URL Especifica","URL Especifica","URL Especifica"  	   					,"URL Especifica"  	    	,"URL Especifica" 		,""                             ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Conex       	,"07"      	,Tb_Conex+"_TIMOUT"   	,"N"        , 03             			, 0              			,"Timeout"	 			,"Timeout"  	,"Timeout" 		,"Timeout"  	   							,"Timeout"  		    	,"Timeout" 				,"999"                          ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	//->> Campos de Produtos do e-commerce
	aAdd( aSX3,	{	Tb_Produ       	,"01"      	,Tb_Produ+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"02"      	,Tb_Produ+"_SKU"   		,"C"        , Tamsx3("B1_COD")[01]  	, 0              			,"Sku"  	     		,"Sku"     	    ,"Sku"       	,"Sku" 				      					,"Sku" 				        ,"Sku"    				,"@!"                           ,"u_MaVlSkuCat()" 													 					,cUsado  			,""    																				,"SB1"     			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"Inclui .And. !lProdKit" 				,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"03"      	,Tb_Produ+"_TIPO"  		,"C"        , 01  						, 0              			,"Tipo"  	     		,"Tipo"     	,"Tipo"       	,"Tipo" 				      				,"Tipo" 			        ,"Tipo"    				,"@!"                           ,"" 													 								,cUsado  			,""    																				,""     			,1         ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,"P=SKU de Produto;K=SKU de Kit"   											,""             ,""             ,""             ,".F." 	 	  							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"04"      	,Tb_Produ+"_DESCRI"   	,"C"        , 60             			, 0              			,"Descricao"    		,"Descricao"    ,"Descricao"    ,"Descricao"  			   					,"Descricao"   		       	,"Descricao" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"05"      	,Tb_Produ+"_DSCRES"   	,"C"        , 60             			, 0              			,"Desc. Resumida"  		,"Desc.Resumida","Desc.Resumida","Desc. Resumida"  			   				,"Desc. Resumida"   		,"Desc. Resumida" 		,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"06"      	,Tb_Produ+"_COMPRI"		,"N"        , 9   						, 2              			,"Comprimento" 			,"Comprimento"	,"Comprimento"	,"Comprimento"								,"Comprimento"				,"Comprimento"			,"@E 9,999,999.99"            	,""            																			,cUsado     		,""             																	,"" 	   			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"07"      	,Tb_Produ+"_LARGUR"		,"N"        , 9   						, 2              			,"Largura" 				,"Largura"		,"Largura"		,"Largura"									,"Largura"					,"Largura"				,"@E 9,999,999.99"            	,""            																			,cUsado     		,""             																	,"" 	   			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"08"      	,Tb_Produ+"_ALTURA"		,"N"        , 9   						, 2              			,"Altura"	 			,"Altura"		,"Altura"		,"Altura"									,"Altura"					,"Altura"				,"@E 9,999,999.99"            	,""            																			,cUsado     		,""             																	,"" 	   			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"09"      	,Tb_Produ+"_PESO"		,"N"        , 9   						, 2              			,"Peso" 				,"Peso"			,"Peso"			,"Peso"										,"Peso"						,"Peso"					,"@E 9,999,999.99"            	,""            																			,cUsado     		,""             																	,"" 	   			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Produ       	,"10"      	,Tb_Produ+"_DEPART"		,"C"        , 6   						, 2              			,"Departamento"			,"Departamento"	,"Departamento"	,"Departamento"								,"Departamento"				,"Departamento"			,"@!"            				,"ExistCpo('"+Tb_Depar+"',M->"+Tb_Produ+"_DEPART)"        								,cNaoUsad     		,""             																	,Tb_Depar  			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"11"      	,Tb_Produ+"_CATEGO"		,"C"        , 6   						, 2              			,"Categoria"			,"Categoria"	,"Categoria"	,"Categoria"								,"Categoria"				,"Categoria"			,"@!"            				,"ExistCpo('"+Tb_Categ+"',M->"+Tb_Produ+"_CATEGO)"        								,cNaoUsad     		,""             																	,Tb_Categ  			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"12"      	,Tb_Produ+"_MARCA"		,"C"        , 6   						, 2              			,"Marca"				,"Marca"		,"Marca"		,"Marca"									,"Marca"					,"Marca"				,"@!"            				,"ExistCpo('"+Tb_Marca+"',M->"+Tb_Produ+"_MARCA)"        								,cNaoUsad     		,""             																	,Tb_Marca  			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"13"      	,Tb_Produ+"_FABRIC"		,"C"        , 6   						, 2              			,"Fabricante"			,"Fabricante"	,"Fabricante"	,"Fabricante"								,"Fabricante"				,"Fabricante"			,"@!"            				,"ExistCpo('"+Tb_Fabri+"',M->"+Tb_Produ+"_FABRIC)"        								,cNaoUsad     		,""             																	,Tb_Fabri  			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Produ       	,"14"      	,Tb_Produ+"_EAN13"   	,"C"        , Tamsx3("B1_CODBAR")[01]  	, 0              			,"Barras"       		,"Barras"       ,"Barras"       ,"Codigo Barras"      	 					,"Codigo Barras"    	    ,"Codigo Barras" 	    ,"@!"                           ,"" 													 								,cUsado  			,""    																				,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Produ       	,"15"      	,Tb_Produ+"_NCM"   		,"C"        , Tamsx3("B1_POSIPI")[01]   , 0              			,"NCM"  				,"NCM"			,"NCM"			,"Nomenclatura Ext.Mercosul"				,"Nomenclatura Ext.Mercosul","Nomenclatura Ext.Mercosul","@R 9999.99.99"            ,"ExistCpo('SYD',M->"+Tb_Produ+"_NCM)"            										,cUsado     		,""             																	,"SYD"    			,1         ,cObrig      ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"16"      	,Tb_Produ+"_ATUSIT"   	,"C"        , 01             			, 0              			,"Sincronizar"			,"Sincronizar"	,"Sincronizar"	,"Sincronizar Site" 			   			,"Sincronizar Site" 	   	,"Sincronizar Site" 	,"@!" 	                        ,"Pertence('12')"                               										,cUsado     		,"'2'"          																	,""        			,1         ,cObrig      ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Sim;2=Nao"      														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })	
	aAdd( aSX3,	{	Tb_Produ       	,"17"      	,Tb_Produ+"_MSBLQL"   	,"C"        , 01             			, 0              			,"Bloqueado"			,"Bloqueado"	,"Bloqueado"	,"Bloqueado" 				   				,"Bloqueado" 		   		,"Bloqueado" 	   		,"@!" 	                        ,"Pertence('12')"                               										,cUsado     		,"'2'"          																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Sim;2=Nao"      														,""             ,""             ,""             ,""          							,""             																,""         ,"1"         	,"S"        })
	aAdd( aSX3,	{	Tb_Produ       	,"18"      	,Tb_Produ+"_OBSERV"   	,"M"        , 10  						, 0              			,"Observação"      		,"Observação"   ,"Observação"   ,"Observação" 	     	 					,"Observação"    	    	,"Observação" 		    ,""                           	,"" 													 								,cUsado  			,""    																				,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,"1"         	,"S"        })		
	//->> Campos da Estrutura de Produtos do e-commerce
	aAdd( aSX3,	{	Tb_Estru       	,"01"      	,Tb_Estru+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Estru       	,"02"      	,Tb_Estru+"_SKU"   		,"C"        , Tamsx3("B1_COD")[01]  	, 0              			,"Sku"  	     		,"Sku"     	    ,"Sku"       	,"Sku" 				      					,"Sku" 				        ,"Sku"    				,"@!"                           ,"" 													 								,cNaoUsad  			,""    																				,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,".F." 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Estru       	,"03"      	,Tb_Estru+"_COD"   		,"C"        , Tamsx3("B1_COD")[01]  	, 0              			,"Cod.Produto"     		,"Cod.Produto"  ,"Cod.Produto"  ,"Codigo Produto"      	 					,"Codigo Produto"    	    ,"Codigo Produto" 	    ,"@!"                           ,"u_MaVldCdEEc()" 													 					,cUsado  			,""    																				,"SB1"     			,1         ,cObrig   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Estru       	,"04"      	,Tb_Estru+"_DESCRI"   	,"C"        , 100             			, 0              			,"Descricao"    		,"Descricao"    ,"Descricao"    ,"Descricao"  			   					,"Descricao"   		       	,"Descricao" 		    ,"@!"                           ,""                                             										,cUsado     		,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Estru       	,"05"      	,Tb_Estru+"_QTDE"   	,"N"        , 10  						, 2              			,"Qtde" 	    		,"Qtde"  		,"Qtde"  		,"Qtde"      	 							,"Qtde" 		   	    	,"Qtde" 	    		,"@E 999,999.99"                ,"u_MaVldQtEEc()" 													 					,cUsado  			,""    																				,"SB1"     			,1         ,cObrig   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	//->> Campos da Estrutura de preços de Produtos do e-commerce
	aAdd( aSX3,	{	Tb_IDS       	,"01"      	,Tb_IDS+"_FILIAL"   	,"C"        , nTamFil        			, 0              			,"Filial"       		,"Sucursal"     ,"Branch"       ,"Filial do Sistema"       					,"Sucursal del sistema"     ,"Branch of System"     ,"@!"                           ,""                                             										,cNaoUsad 			,""             																	,""        			,1         ,cReserv     ,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,""          							,""             																,"033"      ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"02"      	,Tb_IDS+"_ECOM"   		,"C"        , 10 						, 0              			,"e-Commerce"    		,"e-Commerce"   ,"e-Commerce"   ,"e-Commerce"	      	 					,"e-Commerce" 	   	    	,"e-Commerce" 	    	,"@!"                           ,"" 													 								,cUsado  			,""    																				,Tb_Ecomm     		,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"03"      	,Tb_IDS+"_TIPO"   		,"C"        , 03 						, 0              			,"Tipo"		    		,"Tipo"		    ,"Tipo"   		,"Tipo"	      	 							,"Tipo" 	   	    		,"Tipo" 	    		,"@!"                           ,"" 													 								,cUsado  			,""    																				,"" 	    		,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,"SKU=Sku;PRD=Produt;CLI=Client;EST=Estoq;PRC=Preco,CAT=Categ;MAR=Marca;FAB=Fabr",""        ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{	Tb_IDS       	,"04"      	,Tb_IDS+"_CHPROT"  		,"C"        , 30  						, 0              			,"Chv Protheus"    		,"Sku"     	    ,"Chv Protheus"	,"Chv Protheus" 				  			,"Chv Protheus" 			,"Chv Protheus"  		,""                             ,"" 													 								,cNaoUsad  			,""    																				,""        			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,".F." 		   							,""             																,""         ,""         	,"S"        })		
	aAdd( aSX3,	{	Tb_IDS       	,"05"      	,Tb_IDS+"_ID"   		,"C"        , 30					 	, 0              			,"Id. Ecommerce"    	,"Id. Ecommerce","Id. Ecommerce","Id. Ecommerce"	      	 				,"Id. Ecommerce"   	    	,"Id. Ecommerce"    	,"@!"                           ,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"06"      	,Tb_IDS+"_IDSKU"   		,"C"        , 30					 	, 0              			,"Id.Ecom.SKU"   	 	,"Id.Ecom.SKU"  ,"Id.Ecom.SKU"	,"Id.Ecom.SKU"	      	 					,"Id.Ecom.SKU"   	    	,"Id.Ecom.SKU" 		   	,"@!"                           ,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"07"      	,Tb_IDS+"_TABPRC"  		,"C"        , Tamsx3("DA0_CODTAB")[01] 	, 0              			,"Tab.Preço"     		,"Tab.Preço" 	,"Tab.Preço"  	,"Tab.Preço"      	 						,"Tab.Preço" 		   	    ,"Tab.Preço"     		,"@!"   					    ,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"08"      	,Tb_IDS+"_PRCVEN"  		,"N"        , 14  						, 2              			,"Vlr. Venda"     		,"Vlr. Venda" 	,"Vlr. Venda"  	,"Vlr. Venda"      	 						,"Vlr. Venda" 		   	    ,"Vlr. Venda"     		,"@E 999,999,999,999.99"        ,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"09"      	,Tb_IDS+"_PCDESC"  		,"N"        , 06  						, 2              			,"% Desconto"     		,"% Desconto" 	,"% Desconto"  	,"% Desconto"      	 						,"% Desconto" 		   	    ,"% Desconto"     		,"@E 999.99"        			,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"10"      	,Tb_IDS+"_ULTATU"  		,"C"        , 20  						, 0              			,"Ult.Atualização"     	,"Ult.Atualização","Ult.Atualização","Ult.Atualização"      	 			,"Ult.Atualização" 		   	,"Ult.Atualização" 		,"@!"        					,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"11"      	,Tb_IDS+"_PENDEN"  		,"C"        , 01  						, 0              			,"Pendente Atualiz."   	,"Pendente Atualiz.","Pendente Atualiz.","Pendente Atualiz."   	 			,"Pendente Atualiz." 	   	,"Pendente Atualiz."	,"@!"        					,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,"S=Sim;N=Nao"       														,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"12"      	,Tb_IDS+"_ULTENV"  		,"C"        , 20  						, 0              			,"Ult.Envio"	     	,"Ult.Envio		","Ult.Envio"	,"Ult.Envio"      	 						,"Ult.Envio" 		   		,"Ult.Envio" 			,"@!"        					,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_IDS       	,"13"      	,Tb_IDS+"_ULTQTD"  		,"N"        , Tamsx3("B2_QATU")[01] 	, Tamsx3("B2_QATU")[02]     ,"Ult.Qtd.Enviada"	  	,"Ult.Qtd.Enviada","Ult.Qtd.Enviada","Ult.Qtd.Enviada"      	 			,"Ult.Qtd.Enviada" 		   	,"Ult.Qtd.Enviada" 		,"@E 9,999,999,999.99"  		,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })	
	//->> Campos do Painel - Cabeçalho
	aAdd( aSX3,	{ 	Tb_Monit		,"01"		,Tb_Monit+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"02"		,Tb_Monit+"_CODIGO" 	,"C"		, 10		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""  								     								        	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"03"		,Tb_Monit+"_DESCRI" 	,"C"		, 40	                    , 0							,"Descrição"	      	,""		    	,""			    ,"Descrição"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"04"		,Tb_Monit+"_DESRED" 	,"C"		, 15	                    , 0							,"Descr. Reduzida"	    ,""		    	,""			    ,"Descr. Reduzida"	    	     			,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"05"		,Tb_Monit+"_LOGOTP" 	,"C"		, 30	                    , 0							,"Logotipo"	   			,""		    	,""			    ,"Logotipo"	    	    		 			,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"N"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"06"		,Tb_Monit+"_TEMPAT" 	,"N"		, 03	                    , 0							,"Atualização"	   		,""		    	,""			    ,"Atualização"	    	    	 			,""							,""						,"999"     						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"N"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Monit		,"07"		,Tb_Monit+"_MSBLQL" 	,"C"		, 01		                , 0							,"Bloqueado"	  	 	,""		    	,""			    ,"Bloqueado"	    		   		  		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,"'N'"         														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"N"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"							  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do Painel - Chamadas
	aAdd( aSX3,	{ 	Tb_ChMon		,"01"		,Tb_ChMon+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"02"		,Tb_ChMon+"_CODIGO" 	,"C"		, 10		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cNaoUsad			,""  								         						             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"03"		,Tb_ChMon+"_INTEGR" 	,"C"		, 10		                , 0							,"Integração"	      	,""		    	,""			    ,"Integração"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"04"		,Tb_ChMon+"_CONEX" 		,"C"		, 01		                , 0							,"Acionamento"	  	 	,""		    	,""			    ,"Acionamento"	    		   		  		,""							,""						,"@!"      						,"Pertence('AR')"	                                              		            	,cUsado				,"''"         														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"A=Ativa;R=Receptiva"														,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"05"		,Tb_ChMon+"_FUNCAO" 	,"C"		, 150		                , 0							,"Função"	      		,""		    	,""			    ,"Função"	    		       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"06"		,Tb_ChMon+"_FUNREF" 	,"C"		, 150		                , 0							,"Função Refazer"	   	,""		    	,""			    ,"Função Refazer"	    		       		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"07"		,Tb_ChMon+"_ORDEM" 		,"C"		, 02		                , 0							,"Ordem Exibição"	   	,""		    	,""			    ,"Ordem Exibição"	    		     		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"08"		,Tb_ChMon+"_ICONE" 		,"C"		, 15		                , 0							,"Icone Exibição"	   	,""		    	,""			    ,"Icone Exibição"	    		     		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,"MMICO"			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"09"		,Tb_ChMon+"_NOME" 		,"C"		, 30		                , 0							,"Nome Botão"	  	 	,""		    	,""			    ,"Nome Botão"	    		   		  		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"10"		,Tb_ChMon+"_COR" 		,"N"		, 10		                , 0							,"Cor Legenda"	  	 	,""		    	,""			    ,"Cor Legenda"	    		   		  		,""							,""						,"9999999999"      				,""	                                                					            	,cUsado				,""            														             	,"MMCOR"  			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"11"		,Tb_ChMon+"_EMAIL" 		,"C"		, 99		                , 0							,"e-Mails"		      	,""		    	,""			    ,"e-Mails"	    	       					,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"12"		,Tb_ChMon+"_VALIDA" 	,"N"		, 03		                , 0							,"Dias Armazenar"		,""		    	,""			    ,"Dias Armazenar"	    	       			,""							,""						,"999"     						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ChMon		,"13"		,Tb_ChMon+"_MSBLQL" 	,"C"		, 01		                , 0							,"Bloqueado"	  	 	,""		    	,""			    ,"Bloqueado"	    		   		  		,""							,""						,"@!"      						,""	                                                					            	,cUsado				,"'2'"         														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"1=Sim;2=Nao"							  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos dos logs do Painel
	aAdd( aSX3,	{ 	Tb_LgMon		,"01"		,Tb_LgMon+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"02"		,Tb_LgMon+"_CODIGO" 	,"C"		, 10		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cNaoUsad			,"u_MMCodIntg('"+Tb_ChMon+"','"+Tb_ChMon+"_CODIGO')"           					   	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"03"		,Tb_LgMon+"_INTEGR" 	,"C"		, 10		                , 0							,"Integração"	      	,""		    	,""			    ,"Integração"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"04"		,Tb_LgMon+"_FUNCAO" 	,"C"		, 20		                , 0							,"Função"	      		,""		    	,""			    ,"Função"	    		       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"05"		,Tb_LgMon+"_DATA" 		,"D"		, 08		                , 0							,"Data"	      			,""		    	,""			    ,"Data"	    		       					,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"06"		,Tb_LgMon+"_HORA" 		,"C"		, 08		                , 0							,"Hora"	      			,""		    	,""			    ,"Hora"	    		       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"07"		,Tb_LgMon+"_SUCESS" 	,"C"		, 01		                , 0							,"Sucesso"	    		,""		    	,""			    ,"Sucesso"	    		      				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										 						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"08"		,Tb_LgMon+"_FILDES" 	,"C"		, nTamFil	                , 0							,"Filial Destino"	    ,""		    	,""			    ,"Filial Destino"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,"033"    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"09"		,Tb_LgMon+"_ALIAS" 		,"C"		, 03		                , 0							,"Alias Registro"	    ,""		    	,""			    ,"Alias Registro"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"10"		,Tb_LgMon+"_ORDCHV" 	,"N"		, 01		                , 0							,"Ordem Chave"		    ,""		    	,""			    ,"Ordem Chave"	    		  	 			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"12"		,Tb_LgMon+"_CHAVE" 		,"C"		, 30		                , 0							,"Chave Registro"	    ,""		    	,""			    ,"Chave Registro"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"13"		,Tb_LgMon+"_REQUES" 	,"M"		, 10		                , 0							,"Request"	    		,""		    	,""			    ,"Request"	    		      				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"14"		,Tb_LgMon+"_RESPON" 	,"M"		, 10		                , 0							,"Response"	    		,""		    	,""			    ,"Response"	    		      				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"15"		,Tb_LgMon+"_ERRPRO" 	,"M"		, 10		                , 0							,"Erro Protheus"	 	,""		    	,""			    ,"Erro Protheus"	    		     		,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"16"		,Tb_LgMon+"_IPSRV" 		,"C"		, 20		                , 0							,"Ip Server"	   		,""		    	,""			    ,"Ip Server"	    		      			,""							,""						,"@R 999.999.999.999" 			,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"17"		,Tb_LgMon+"_PORTSR"		,"N"		, 06		                , 0							,"Porta Server"			,""		    	,""			    ,"Porta Server"	   		       				,""							,""						,"999999" 						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"18"		,Tb_LgMon+"_USER"		,"C"		, 30		                , 0							,"Usuario"				,""		    	,""			    ,"Usuario"	   		       					,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"19"		,Tb_LgMon+"_USRPRO"		,"C"		, 10		                , 0							,"Usuario Protheus"		,""		    	,""			    ,"Usuario Protheus"	   		       			,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"20"		,Tb_LgMon+"_ENVSRV"		,"C"		, 30		                , 0							,"Envinroment"			,""		    	,""			    ,"Envinroment"	   		       				,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"21"		,Tb_LgMon+"_MAQUIN"		,"C"		, 30		                , 0							,"Maquina"				,""		    	,""			    ,"Nome Maquina"	   		       				,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"22"		,Tb_LgMon+"_THREAD"		,"N"		, 10		                , 0							,"Thread Id"			,""		    	,""			    ,"Thread Id"	   		       				,""							,""						,"9999999999" 					,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"23"		,Tb_LgMon+"_IPCLT" 		,"C"		, 20		                , 0							,"Ip Server"	   		,""		    	,""			    ,"Ip Server"	    		      			,""							,""						,"@R 999.999.999.999" 			,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"24"		,Tb_LgMon+"_DATFIM" 	,"D"		, 08		                , 0							,"Data Termino"	   		,""		    	,""			    ,"Data Termino"	    		   				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"25"		,Tb_LgMon+"_HORFIM" 	,"C"		, 08		                , 0							,"Hora Termino"	   		,""		    	,""			    ,"Hora Termino"	    		   				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"26"		,Tb_LgMon+"_PENDEN" 	,"C"		, 01		                , 0							,"Pendente"		   		,""		    	,""			    ,"Pendente"	    		   					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										  						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_LgMon		,"27"		,Tb_LgMon+"_ULTENV" 	,"C"		, 20		                , 0							,"Ult.Env.Email"		,""		    	,""			    ,"Ult. Envio Email"	    					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos dos Logs do Painel de serviços
	aAdd( aSX3,	{ 	Tb_ThMon		,"01"		,Tb_ThMon+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"02"		,Tb_ThMon+"_CODIGO" 	,"C"		, 10		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cNaoUsad			,"u_MMCodIntg('"+Tb_ChMon+"','"+Tb_ChMon+"_CODIGO')"           					   	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"03"		,Tb_ThMon+"_INTEGR" 	,"C"		, 10		                , 0							,"Integração"	      	,""		    	,""			    ,"Integração"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"04"		,Tb_ThMon+"_FUNCAO" 	,"C"		, 20		                , 0							,"Função"	      		,""		    	,""			    ,"Função"	    		       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"05"		,Tb_ThMon+"_DATA" 		,"D"		, 08		                , 0							,"Data"	      			,""		    	,""			    ,"Data"	    		       					,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"06"		,Tb_ThMon+"_HORA" 		,"C"		, 08		                , 0							,"Hora"	      			,""		    	,""			    ,"Hora"	    		       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"07"		,Tb_ThMon+"_SUCESS" 	,"C"		, 01		                , 0							,"Sucesso"	    		,""		    	,""			    ,"Sucesso"	    		      				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										 						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"08"		,Tb_ThMon+"_FILDES" 	,"C"		, nTamFil	                , 0							,"Filial Destino"	    ,""		    	,""			    ,"Filial Destino"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,"033"    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"09"		,Tb_ThMon+"_ALIAS" 		,"C"		, 03		                , 0							,"Alias Registro"	    ,""		    	,""			    ,"Alias Registro"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"10"		,Tb_ThMon+"_ORDCHV" 	,"N"		, 01		                , 0							,"Ordem Chave"		    ,""		    	,""			    ,"Ordem Chave"	    		  	 			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"11"		,Tb_ThMon+"_CHAVE" 		,"C"		, 30		                , 0							,"Chave Registro"	    ,""		    	,""			    ,"Chave Registro"	    		   			,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"12"		,Tb_ThMon+"_REQUES" 	,"M"		, 10		                , 0							,"Request"	    		,""		    	,""			    ,"Request"	    		      				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"13"		,Tb_ThMon+"_RESPON" 	,"M"		, 10		                , 0							,"Response"	    		,""		    	,""			    ,"Response"	    		      				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"14"		,Tb_ThMon+"_ERRPRO" 	,"M"		, 10		                , 0							,"Erro Protheus"	 	,""		    	,""			    ,"Erro Protheus"	    		     		,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										 									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"15"		,Tb_ThMon+"_IPSRV" 		,"C"		, 20		                , 0							,"Ip Server"	   		,""		    	,""			    ,"Ip Server"	    		      			,""							,""						,"@R 999.999.999.999" 			,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"16"		,Tb_ThMon+"_PORTSR"		,"N"		, 06		                , 0							,"Porta Server"			,""		    	,""			    ,"Porta Server"	   		       				,""							,""						,"999999" 						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"17"		,Tb_ThMon+"_USER"		,"C"		, 30		                , 0							,"Usuario"				,""		    	,""			    ,"Usuario"	   		       					,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"18"		,Tb_ThMon+"_USRPRO"		,"C"		, 10		                , 0							,"Usuario Protheus"		,""		    	,""			    ,"Usuario Protheus"	   		       			,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"19"		,Tb_ThMon+"_ENVSRV"		,"C"		, 30		                , 0							,"Envinroment"			,""		    	,""			    ,"Envinroment"	   		       				,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"20"		,Tb_ThMon+"_MAQUIN"		,"C"		, 30		                , 0							,"Maquina"				,""		    	,""			    ,"Nome Maquina"	   		       				,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"21"		,Tb_ThMon+"_THREAD"		,"N"		, 10		                , 0							,"Thread Id"			,""		    	,""			    ,"Thread Id"	   		       				,""							,""						,"9999999999" 					,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"22"		,Tb_ThMon+"_IPCLT" 		,"C"		, 20		                , 0							,"Ip Server"	   		,""		    	,""			    ,"Ip Server"	    		      			,""							,""						,"@R 999.999.999.999" 			,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"23"		,Tb_ThMon+"_DATFIM" 	,"D"		, 08		                , 0							,"Data Termino"	   		,""		    	,""			    ,"Data Termino"	    		   				,""							,""						,""       						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"24"		,Tb_ThMon+"_HORFIM" 	,"C"		, 08		                , 0							,"Hora Termino"	   		,""		    	,""			    ,"Hora Termino"	    		   				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"25"		,Tb_ThMon+"_PENDEN" 	,"C"		, 01		                , 0							,"Pendente"		   		,""		    	,""			    ,"Pendente"	    		   					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"										  						,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"26"		,Tb_ThMon+"_ULTENV" 	,"C"		, 20		                , 0							,"Ult.Env.Email"		,""		    	,""			    ,"Ult. Envio Email"	    					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_ThMon		,"27"		,Tb_ThMon+"_NICKNA" 	,"C"		, 100		                , 0							,"NickName"				,""		    	,""			    ,"NickName"	    							,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do cadastro de departamento
	aAdd( aSX3,	{ 	Tb_Depar		,"01"		,Tb_Depar+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Depar		,"02"		,Tb_Depar+"_CODIGO" 	,"C"		, 06		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Depar		,"03"		,Tb_Depar+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Depar		,"04"		,Tb_Depar+"_IDECOM" 	,"C"		, 20		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do cadastro de categoria
	aAdd( aSX3,	{ 	Tb_Categ		,"01"		,Tb_Categ+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Categ		,"02"		,Tb_Categ+"_CODIGO" 	,"C"		, 06		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Categ		,"03"		,Tb_Categ+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Categ		,"04"		,Tb_Categ+"_IDECOM" 	,"C"		, 20		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do cadastro de marca
	aAdd( aSX3,	{ 	Tb_Marca		,"01"		,Tb_Marca+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Marca		,"02"		,Tb_Marca+"_CODIGO" 	,"C"		, 06		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Marca		,"03"		,Tb_Marca+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Marca		,"04"		,Tb_Marca+"_IDECOM" 	,"C"		, 20		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do cadastro de fabricantes
	aAdd( aSX3,	{ 	Tb_Fabri		,"01"		,Tb_Fabri+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Fabri		,"02"		,Tb_Fabri+"_CODIGO" 	,"C"		, 06		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Fabri		,"03"		,Tb_Fabri+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Fabri		,"04"		,Tb_Fabri+"_IDECOM" 	,"C"		, 20		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	//->> Campos do cadastro de canais 
	aAdd( aSX3,	{ 	Tb_Canal		,"01"		,Tb_Canal+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_Canal       	,"02"      	,Tb_Canal+"_ECOMME"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,"Tecnologia"   ,"Tecnologia"   ,"Tecnologia Integracao"       				,"Tecnologia Integracao"    ,"Tecnologia Integracao","@!"                           ,"NaoVazio() .And. ExistCpo( '"+Tb_Ferra+"', M->&("+Tb_Canal+"_ECOMME))"					,cUsado     	,""    																				,Tb_Ferra  			,0          ,cObrig    	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui"    							,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_Canal		,"03"		,Tb_Canal+"_CODIGO" 	,"C"		, 30		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,"NaoVazio() .And. ExistChav('"+Tb_Canal+"',M->"+Tb_Canal+"_ECOMME+M->"+Tb_Canal+"_CODIGO)"	,cUsado			,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 	
	aAdd( aSX3,	{ 	Tb_Canal		,"04"		,Tb_Canal+"_DESCRI"		,"C"		, 30		                , 0							,"Descricao"	   		,""		    	,""			    ,"Descricao"	    	         			,""							,""						,"@!"      						,"NaoVazio()"	                                                					   	,cUsado				,""           					   													,""	    			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Canal		,"05"		,Tb_Canal+"_IDECOM" 	,"C"		, 20		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_Canal       	,"06"      	,Tb_Canal+"_TABPRC"   	,"C"        , Tamsx3("DA0_CODTAB")[01] 	, 0              			,"Tab. Preco"			,"Tab. Preco"	,"Tab. Preco"	,"Tab. Preco" 	 		  					,"Tab. Preco" 		  		,"Tab. Preco"	 	    ,"@!" 	                        ,"NaoVazio() .And. ExistCpo( 'DA0', M->"+Tb_Canal+"_TABPRC )"      						,cUsado   			,""             																	,"DA0"    			,0          ,cObrig     ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,""                 														,""             ,""             ,""             ,"" 									,""             																,""         ,""         	,"S"        })
	aAdd( aSX3,	{	Tb_Canal       	,"07"      	,Tb_Canal+"_MSBLQL"   	,"C"        , 01             			, 0              			,"Bloqueado"			,"Bloqueado"	,"Bloqueado"	,"Bloqueado" 				   				,"Bloqueado" 		   		,"Bloqueado" 	   		,"@!" 	                        ,"Pertence('12')"                               										,cUsado     		,"'2'"          																	,""        			,0          ,cReserv    ,""         ,""             ,"U"        ,"N"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Sim;2=Nao"      														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })
	//->> Campos do cadastro de tabelas de preços x catalogo
	aAdd( aSX3,	{ 	Tb_TbPrc		,"01"		,Tb_TbPrc+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_TbPrc       	,"02"      	,Tb_TbPrc+"_ECOMME"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,"Tecnologia"   ,"Tecnologia"   ,"Tecnologia Integracao"       				,"Tecnologia Integracao"    ,"Tecnologia Integracao","@!"                           ,""																						,cUsado     		,""    																				,""  				,0          ,cReserv   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,""    									,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_TbPrc		,"03"		,Tb_TbPrc+"_CODIGO" 	,"C"		, 30		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,""	                                                      								,cUsado				,""           					   													,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	
	aAdd( aSX3,	{	Tb_TbPrc       	,"04"      	,Tb_TbPrc+"_SKU"   		,"C"        , Tamsx3("B1_COD")[01]  	, 0              			,"Sku"  	     		,"Sku"     	    ,"Sku"       	,"Sku" 				      					,"Sku" 				        ,"Sku"    				,"@!"                           ,"" 													 								,cUsado  			,""    																				,""     			,1          ,cReserv   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 									,""             																,""         ,""         	,"S"        })		
	aAdd( aSX3,	{	Tb_TbPrc       	,"05"      	,Tb_TbPrc+"_PCDESC"  	,"N"        , 06  						, 2              			,"% Desconto"     		,"% Desconto" 	,"% Desconto"  	,"% Desconto"      	 						,"% Desconto" 		   	    ,"% Desconto"     		,"@E 999.99"        			,"" 													 								,cUsado  			,""    																				,""     			,1         ,cReserv    	,""         ,""             ,"U"        ,"S"        ,"V"        ,"R"            ,""             ,""                                 			,""                															,""             ,""             ,""             ,"" 		   							,""             																,""         ,""         	,"S"        })	
	//->> Campos do cadastro de status das vendas no ecommerce
	aAdd( aSX3,	{ 	Tb_TbSta		,"01"		,Tb_TbSta+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_TbSta       	,"02"      	,Tb_TbSta+"_ECOMME"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,"Tecnologia"   ,"Tecnologia"   ,"Tecnologia Integracao"       				,"Tecnologia Integracao"    ,"Tecnologia Integracao","@!"                           ,"NaoVazio() .And. ExistCpo( '"+Tb_Ferra+"', M->&("+Tb_TbSta+"_ECOMME))"				,cUsado     		,""    																				,Tb_Ferra			,0          ,cReserv   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui" 								,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_TbSta		,"03"		,Tb_TbSta+"_CODIGO" 	,"C"		, 50		                , 0							,"Codigo"	       		,""		    	,""			    ,"Codigo"	    	         				,""							,""						,"@!"      						,"NaoVazio() .And. ExistChav('"+Tb_TbSta+"',M->"+Tb_TbSta+"_ECOMME+M->"+Tb_TbSta+"_CODIGO)"	,cUsado			,""           					   													,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 	
	aAdd( aSX3,	{ 	Tb_TbSta		,"04"		,Tb_TbSta+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"       		,""		    	,""			    ,"Descricao"	   	         				,""							,""						,"@!"      						,""	                                                      								,cUsado				,""           					   													,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	
	aAdd( aSX3,	{	Tb_TbSta       	,"05"      	,Tb_TbSta+"_DESCE"   	,"C"        , 01             			, 0              			,"Desce Integracao"		,""				,""				,"Desce Integracao" 		   				,"" 		   				,"" 			   		,"@!" 	                        ,"Pertence('12')"                               										,cUsado     		,"'2'"          																	,""        			,0          ,cReserv    ,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"1=Sim;2=Nao"      														,""             ,""             ,""             ,""          							,""             																,""         ,""         	,"S"        })				
	//->> Campos do cadastro de condição de pagamento
	aAdd( aSX3,	{ 	Tb_CondP		,"01"		,Tb_CondP+"_FILIAL"		,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_CondP       	,"02"      	,Tb_CondP+"_ECOMME"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,""   			,""   			,"Tecnologia Integracao"       				,""    						,""						,"@!"                           ,"NaoVazio() .And. ExistCpo( '"+Tb_Ferra+"', M->"+Tb_CondP+"_ECOMME)"			    	,cUsado     		,""    																				,Tb_Ferra			,0          ,cReserv   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui" 								,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_CondP		,"03"		,Tb_CondP+"_IDECOM" 	,"C"		, 50		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_CondP		,"04"		,Tb_CondP+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_CondP		,"05"		,Tb_CondP+"_CNDPGT" 	,"C"		, Tamsx3("F4_CODIGO")[01]	, 0							,"Cond Pgto"	   		,""		    	,""			    ,"Cond Pgto"	    	         			,""							,""						,"@!"      						,"NaoVazio() .And. ExistCpo('SE4',M->"+Tb_CondP+"_CNDPGT)" 				            	,cUsado				,""           					   													,"SE4"	   			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 			
	//->> Campos do cadastro de transportadoras
	aAdd( aSX3,	{ 	Tb_Transp		,"01"		,Tb_Transp+"_FILIAL"	,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_Transp      	,"02"      	,Tb_Transp+"_ECOMME"   	,"C"        , 10             			, 0              			,"Tecnologia"       	,""   			,""   			,"Tecnologia Integracao"       				,""    						,""						,"@!"                           ,"NaoVazio() .And. ExistCpo( '"+Tb_Ferra+"', M->"+Tb_Transp+"_ECOMME)"			    	,cObrig     		,""    																				,Tb_Ferra			,0          ,cReserv   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui" 								,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_Transp		,"03"		,Tb_Transp+"_IDECOM" 	,"C"		, 50		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,""      						,""	                                                					            	,cObrig				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Transp		,"04"		,Tb_Transp+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Transp		,"05"		,Tb_Transp+"_TRANSP" 	,"C"		, Tamsx3("A4_COD")[01]	    , 0							,"Transportadora"  		,""		    	,""			    ,"Transportadora"	   	         			,""							,""						,"@!"      						,"NaoVazio() .And. ExistCpo('SA4',M->"+Tb_Transp+"_TRANSP)" 			            	,cObrig				,""           					   													,"SA4"	   			,0			,cObrig		,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 			
	//->> Campos do cadastro de voucher de desconto
	aAdd( aSX3,	{ 	Tb_Voucher		,"01"		,Tb_Voucher+"_FILIAL"	,"C"		, nTamFil					, 0							,"Filial"				,""			    ,""			    ,"Filial"			    					,""							,""						,"@!"							,""													            						,cNaoUsad			,"" 																				,""					,0			,cObrig		,""			,""				,"U"		,"S"		,"A"		,"R"			,""				,""												,""																			,""				,""				,""				,""										,""			                                                            		,"033"		,""				,"S"		}) 
	aAdd( aSX3,	{	Tb_Voucher     	,"02"      	,Tb_Voucher+"_ECOMME"  	,"C"        , 10             			, 0              			,"Tecnologia"       	,""   			,""   			,"Tecnologia Integracao"       				,""    						,""						,"@!"                           ,"NaoVazio() .And. ExistCpo( '"+Tb_Ferra+"', M->"+Tb_Transp+"_ECOMME)"			    	,cUsado     		,""    																				,Tb_Ferra			,0          ,cObrig   	,""         ,""             ,"U"        ,"S"        ,"A"        ,"R"            ,""             ,""                                 			,"" 																		,""             ,""             ,""             ,"Inclui" 								,""             																,""         ,""         	,"S"        })	
	aAdd( aSX3,	{ 	Tb_Voucher		,"03"		,Tb_Voucher+"_IDECOM" 	,"C"		, 50		                , 0							,"Id Ecomm"	      		,""		    	,""			    ,"Id Ecomm"	    	       					,""							,""						,""      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cObrig	    ,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,"Inclui"								,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Voucher		,"04"		,Tb_Voucher+"_DESCRI" 	,"C"		, 50		                , 0							,"Descricao"	      	,""		    	,""			    ,"Descricao"	    	       				,""							,""						,"@!"      						,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	Tb_Voucher		,"05"		,Tb_Voucher+"_DESCON" 	,"C"		, 01					    , 0							,"Desconto" 	 		,""		    	,""			    ,"Desconto"	   	        		 			,""							,""						,"@!"      						,"Pertence('SN')" 											         				   	,cUsado				,""           					   													,""		   			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"A"		,"R"			,""	    		,""												,"S=Sim;N=Nao"							  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 					
	//->> Campos da Tabela de Orçamentos de Vendas
	aAdd( aSX3,	{ 	"SCJ"			,"80"		,"CJ_XORIGEM" 			,"C"		, 10						, 0							,"Origem"				,""		    	,""			    ,"Origem"									,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"81"		,"CJ_XIDINTG" 			,"C"		, 50						, 0							,"Id.Integracao"		,""		    	,""			    ,"Id.Integracao"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 	
	aAdd( aSX3,	{ 	"SCJ"			,"82"		,"CJ_XIDVNDA" 			,"C"		, 30						, 0							,"Id.Venda"				,""		    	,""			    ,"Id.Venda"									,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 		
	aAdd( aSX3,	{ 	"SCJ"			,"83"		,"CJ_XCANAL" 			,"C"		, 30						, 0							,"Canal Ecomm"			,""		    	,""			    ,"Canal Ecomm"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"84"		,"CJ_XDTINTE" 			,"D"		, 08						, 0							,"Dt.Integracao"		,""		    	,""			    ,"Dt.Integracao"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"85"		,"CJ_XHRINTE" 			,"C"		, 08						, 0							,"Hr.Integracao"		,""		    	,""			    ,"Hr.Integracao"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"86"		,"CJ_XDTDESC" 			,"D"		, 08						, 0							,"Dt.Descida"			,""		    	,""			    ,"Dt.Descida"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"87"		,"CJ_XHRDESC" 			,"C"		, 08						, 0							,"Hr.Descida"			,""		    	,""			    ,"Hr.Descida"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"88"		,"CJ_XCDTRAN" 			,"C"		, Tamsx3("A4_COD")[01]		, 0							,"Cd Transp e-Comm"		,""		    	,""			    ,"Cd Transp e-Comm"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""																			,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"89"		,"CJ_XTRANSP" 			,"C"		, 50						, 0							,"Transp e-Comm."		,""		    	,""			    ,"Transp e-Comm."							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"90"		,"CJ_XDETPGT" 			,"M"		, 10						, 0							,"Detalhe Pgto"			,""		    	,""			    ,"Detalhe Pgto"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"91"		,"CJ_XDETENT" 			,"M"		, 10						, 0							,"Detalhe Entrega"		,""		    	,""			    ,"Detalhe Entrega"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"92"		,"CJ_XSTATUS" 			,"C"		, 01						, 0							,"Status"				,""		    	,""			    ,"Status"									,""							,""						,"" 							,""	                                                					            	,cUsado				,"'0'"            														            ,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,"0=Em Carteira;1=Nota Fiscal Gerada"										,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"93"		,"CJ_XENVSTA" 			,"C"		, 20						, 0							,"Envio Status"			,""		    	,""			    ,"Envio Status"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""																			,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"94"		,"CJ_XIDENTR" 			,"C"		, 50						, 0							,"Id Entrega"			,""		    	,""			    ,"Id Entrega"								,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""																			,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	aAdd( aSX3,	{ 	"SCJ"			,"95"		,"CJ_XRECEBE" 			,"C"		, 50						, 0							,"Receber Pedido"		,""		    	,""			    ,"Receber Pedido"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""																			,""				,""				,""				,""										,""			  		                                                            ,""	    	,"5"			,"S"		}) 
	//->> Campos da Tabela de Pedidos de Vendas
	aAdd( aSX3,	{ 	"SC5"			,"80"		,"C5_XORIGEM" 			,"C"		, 10						, 0							,"Origem"				,""		    	,""			    ,"Origem"									,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	"SC5"			,"81"		,"C5_XIDINTG" 			,"C"		, 50						, 0							,"Id.Integracao"		,""		    	,""			    ,"Id.Integracao"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	
	//->> Campos da Tabela de Pedidos de Vendas
	aAdd( aSX3,	{ 	"SC9"			,"80"		,"C9_XORIGEM" 			,"C"		, 10						, 0							,"Origem"				,""		    	,""			    ,"Origem"									,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 
	aAdd( aSX3,	{ 	"SC9"			,"81"		,"C9_XIDINTG" 			,"C"		, 50						, 0							,"Id.Integracao"		,""		    	,""			    ,"Id.Integracao"							,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	
	//->> Campos da Tabela de Clientes
	aAdd( aSX3,	{ 	"SA1"			,"80"		,"A1_XIDVTEX" 			,"C"		, 30						, 0							,"Id.Vtex"				,""		    	,""			    ,"Id.Vtex"									,""							,""						,"" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	
	aAdd( aSX3,	{ 	"SA1"			,"81"		,"A1_XNUMRES" 			,"C"		, 20						, 0							,"Num. Residencia"	    ,""		    	,""			    ,"Numero Residencia"						,""							,""						,"@!" 							,""	                                                					            	,cUsado				,""            														             	,""	    			,0			,cReserv	,""			,""		    	,"U"		,"S"		,"V"		,"R"			,""	    		,""												,""										  									,""				,""				,""				,""										,""			  		                                                            ,""	    	,""				,"S"		}) 	

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
	aEstrut:= {"INDICE"	,"ORDEM","CHAVE"					                   				,"DESCRICAO"										,"DESCSPA"			,"DESCENG"						,"PROPRI"	,"F3"	,"NICKNAME"		,"SHOWPESQ"}

	Aadd(aSIX,{Tb_Ferra	,"1"	,Tb_Ferra+"_FILIAL+"+Tb_Ferra+"_CODIGO"	 				    ,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Ferra	,"2"	,Tb_Ferra+"_FILIAL+"+Tb_Ferra+"_DESCRI"	 				    ,"Descrição"	   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Ecomm	,"1"	,Tb_Ecomm+"_FILIAL+"+Tb_Ecomm+"_CODIGO"	 				    ,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Ecomm	,"2"	,Tb_Ecomm+"_FILIAL+"+Tb_Ecomm+"_DESCRI"	 				    ,"Descrição"	   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Conex	,"1"	,Tb_Conex+"_FILIAL+"+Tb_Conex+"_CODIGO+"+Tb_Conex+"_CDPATH" ,"Codigo + Cod Endpoint"					       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Produ	,"1"	,Tb_Produ+"_FILIAL+"+Tb_Produ+"_SKU"					    ,"SKU"										       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Produ	,"2"	,Tb_Produ+"_FILIAL+"+Tb_Produ+"_EAN13"					    ,"Codigo de Barras"							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Produ	,"3"	,Tb_Produ+"_FILIAL+"+Tb_Produ+"_DESCRI"					   	,"Descrição"								       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Produ	,"4"	,Tb_Produ+"_FILIAL+"+Tb_Produ+"_DSCRES"					    ,"Descrição Resumida"						       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Produ	,"5"	,Tb_Produ+"_FILIAL+"+Tb_Produ+"_TIPO+"+Tb_Produ+"_SKU"		,"Tipo + SKU"								       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Estru	,"1"	,Tb_Estru+"_FILIAL+"+Tb_Estru+"_SKU+"+Tb_Estru+"_COD"	    											,"SKU + Codigo Produto"						       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_IDS	,"1"	,Tb_IDS+"_FILIAL+"+Tb_IDS+"_ECOM+"+Tb_IDS+"_TIPO+"+Tb_IDS+"_CHPROT"	,"Codigo e-Commerce + Tipo + Chv ERP"		,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_IDS	,"2"	,Tb_IDS+"_FILIAL+"+Tb_IDS+"_ECOM+"+Tb_IDS+"_TIPO+"+Tb_IDS+"_ID"		,"Codigo e-Commerce + Tipo + ID Integracao"	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_IDS	,"3"	,Tb_IDS+"_FILIAL+"+Tb_IDS+"_TIPO+"+Tb_IDS+"_CHPROT+"+Tb_IDS+"_ECOM"	,"Tipo + Chv ERP + Codigo e-Commerce"		,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_IDS	,"4"	,Tb_IDS+"_FILIAL+"+Tb_IDS+"_ECOM+"+Tb_IDS+"_TIPO+Str("+Tb_IDS+"_PRCVEN)","Codigo e-Commerce + Tipo + Preco"		,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_IDS	,"5"	,Tb_IDS+"_FILIAL+"+Tb_IDS+"_ECOM+"+Tb_IDS+"_TIPO+Str("+Tb_IDS+"_ULTQTD)","Codigo e-Commerce + Tipo + Ult.Qtde"	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Monit	,"1"	,Tb_Monit+"_FILIAL+"+Tb_Monit+"_CODIGO"	 				    											,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Monit	,"2"	,Tb_Monit+"_FILIAL+"+Tb_Monit+"_DESCRI"	 				    											,"Descrição"								       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_ChMon	,"1"	,Tb_ChMon+"_FILIAL+"+Tb_ChMon+"_INTEGR"	 				    											,"Integração"	  							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_ChMon	,"2"	,Tb_ChMon+"_FILIAL+"+Tb_ChMon+"_CODIGO+"+Tb_ChMon+"_INTEGR" 											,"Codigo + Integração"						       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_ChMon	,"3"	,Tb_ChMon+"_FILIAL+"+Tb_ChMon+"_CODIGO+"+Tb_ChMon+"_ORDEM+"+Tb_ChMon+"_INTEGR"	 		    			,"Codigo + oRDEM + Integração"				       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_LgMon	,"1"	,Tb_LgMon+"_FILIAL+DTOS("+Tb_LgMon+"_DATA)+"+Tb_LgMon+"_INTEGR+"+Tb_LgMon+"_HORA"	 					,"Data + Integracao + Hora"	 				       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_LgMon	,"2"	,Tb_LgMon+"_FILIAL+"+Tb_LgMon+"_SUCESS+DTOS("+Tb_LgMon+"_DATA)+"+Tb_LgMon+"_INTEGR+"+Tb_LgMon+"_HORA"	,"Sucesso + Data + Integracao + Hora"	 	       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_LgMon	,"3"	,Tb_LgMon+"_FILIAL+"+Tb_LgMon+"_INTEGR+DTOS("+Tb_LgMon+"_DATA)+"+Tb_LgMon+"_HORA+"+Tb_LgMon+"_SUCESS"	,"Integracao + Data + Hora + Sucesso"	 	       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_ThMon	,"1"	,Tb_ThMon+"_FILIAL+DTOS("+Tb_ThMon+"_DATA)+"+Tb_ThMon+"_INTEGR+"+Tb_ThMon+"_HORA"	 					,"Data + Integracao + Hora"	 				       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_ThMon	,"2"	,Tb_ThMon+"_FILIAL+"+Tb_ThMon+"_SUCESS+DTOS("+Tb_ThMon+"_DATA)+"+Tb_ThMon+"_INTEGR+"+Tb_ThMon+"_HORA"	,"Sucesso + Data + Integracao + Hora"	 	       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_ThMon	,"3"	,Tb_ThMon+"_FILIAL+"+Tb_ThMon+"_INTEGR+DTOS("+Tb_ThMon+"_DATA)+"+Tb_ThMon+"_HORA+"+Tb_ThMon+"_SUCESS"	,"Integracao + Data + Hora + Sucesso"	 	       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Depar	,"1"	,Tb_Depar+"_FILIAL+"+Tb_Depar+"_CODIGO"	 				    											,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Depar	,"2"	,Tb_Depar+"_FILIAL+"+Tb_Depar+"_DESCRI"	 				    											,"Descricao"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Depar	,"3"	,Tb_Depar+"_FILIAL+"+Tb_Depar+"_IDECOM"	 				    											,"Id"		   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Categ	,"1"	,Tb_Categ+"_FILIAL+"+Tb_Categ+"_CODIGO"	 				    											,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Categ	,"2"	,Tb_Categ+"_FILIAL+"+Tb_Categ+"_DESCRI"	 				    											,"Descricao"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Categ	,"3"	,Tb_Categ+"_FILIAL+"+Tb_Categ+"_IDECOM"	 				    											,"Id"		   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Marca	,"1"	,Tb_Marca+"_FILIAL+"+Tb_Marca+"_CODIGO"	 				    											,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Marca	,"2"	,Tb_Marca+"_FILIAL+"+Tb_Marca+"_DESCRI"	 				    											,"Descricao"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Marca	,"3"	,Tb_Marca+"_FILIAL+"+Tb_Marca+"_IDECOM"	 				    											,"Id"		   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Fabri	,"1"	,Tb_Fabri+"_FILIAL+"+Tb_Fabri+"_CODIGO"	 				    											,"Codigo"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Fabri	,"2"	,Tb_Fabri+"_FILIAL+"+Tb_Fabri+"_DESCRI"	 				    											,"Descricao"		   							       	,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_Fabri	,"3"	,Tb_Fabri+"_FILIAL+"+Tb_Fabri+"_IDECOM"	 				    											,"Id"		   							       	,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Canal	,"1"	,Tb_Canal+"_FILIAL+"+Tb_Canal+"_ECOMME+"+Tb_Canal+"_CODIGO"	 				    						,"Tecnologia + Codigo"		   					,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_TbPrc	,"1"	,Tb_TbPrc+"_FILIAL+"+Tb_TbPrc+"_ECOMME+"+Tb_TbPrc+"_CODIGO+"+Tb_TbPrc+"_SKU"	 				    	,"Tecnologia + Codigo + SKU"		   				,""					,""								,"U"		,""		,""         	,"S"})
	Aadd(aSIX,{Tb_TbPrc	,"2"	,Tb_TbPrc+"_FILIAL+"+Tb_TbPrc+"_SKU+"+Tb_TbPrc+"_ECOMME+"+Tb_TbPrc+"_CODIGO"	 				    	,"SKU + Tecnologia + Codigo"		   				,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_TbSta	,"1"	,Tb_TbSta+"_FILIAL+"+Tb_TbSta+"_ECOMME+"+Tb_TbSta+"_CODIGO"	 								    		,"Tecnologia + Codigo"			   				,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_CondP	,"1"	,Tb_CondP+"_FILIAL+"+Tb_CondP+"_ECOMME+"+Tb_CondP+"_IDECOM"	 								    		,"Tecnologia + Id e-Commerce"			   		,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{Tb_Transp,"1"	,Tb_Transp+"_FILIAL+"+Tb_Transp+"_ECOMME+"+Tb_Transp+"_IDECOM"	 						    			,"Tecnologia + Id e-Commerce"			   		,""					,""								,"U"		,""		,""         	,"S"})
	
	Aadd(aSIX,{Tb_Voucher,"1"	,Tb_Voucher+"_FILIAL+"+Tb_Voucher+"_ECOMME+"+Tb_Voucher+"_IDECOM"	 						    		,"Tecnologia + Id e-Commerce"			   		,""					,""								,"U"		,""		,""         	,"S"})

	Aadd(aSIX,{"SCJ"	,"A"	,"CJ_FILIAL+CJ_XORIGEM+CJ_XIDINTG"	 				    												,"Origem + Id Integracao"		   					,""					,""								,"U"		,""		,"CJXORIGEM"         	,"S"})
	
	Aadd(aSIX,{"SC5"	,"E"	,"C5_FILIAL+C5_XORIGEM+C5_XIDINTG"	 				    												,"Origem + Id Integracao"		   					,""					,""								,"U"		,""		,"C5XORIGEM"         	,"S"})
	
	Aadd(aSIX,{"SC9"	,"E"	,"C9_FILIAL+C9_XORIGEM+C9_XIDINTG"	 				    												,"Origem + Id Integracao"		   					,""					,""								,"U"		,""		,"C9XORIGEM"         	,"S"})

	Aadd(aSIX,{"SA1"	,"M"	,"A1_FILIAL+A1_XIDVTEX"	 				    															,"Id Vtex"		   								,""					,""								,"U"		,""		,"A1XIDVTEX"         	,"S"})
	Aadd(aSIX,{"SA1"	,"N"	,"A1_FILIAL+A1_XNUMRES"	 				    															,"Id Vtex"		   								,""					,""								,"U"		,""		,"A1XNUMRES"         	,"S"})

	Aadd(aSIX,{"SC0"	,"A"	,"C0_FILIAL+C0_DOCRES+C0_PRODUTO+C0_LOCAL"	 				    										,"Doc Reserva + Produto + Armazem"		   			,""					,""								,"U"		,""		,"C0DOCRES"         	,"S"})

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

	//->>Criação dos Gatilhos
	aEstrut:= {"X7_CAMPO"	,"X7_SEQUENC"	,"X7_REGRA"						,"X7_CDOMIN"	,"X7_TIPO"	,"X7_SEEK"	,"X7_ALIAS"	,"X7_ORDEM"	,"X7_CHAVE"					        	,"X7_PROPRI"	,"X7_CONDIC"                }

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

	//->>Criação de Folders
	aEstrut:= 	{"XA_ALIAS"	,"XA_ORDEM"	,"XA_DESCRIC"									,"XA_DESCSPA"	,"XA_DESCENG"	,"XA_PROPRI"}
	aAdd( aSXA, {Tb_Ecomm 		,"1"		,"Cadastro"										,""				,""				, "U"}) 
	aAdd( aSXA, {Tb_Ecomm 		,"2"		,"Configurações de Cadastros"					,""				,""				, "U"}) 

	aAdd( aSXA, {Tb_Produ 		,"1"		,"Detalhes do Cadastro"							,""				,""				, "U"}) 

	aAdd( aSXA, {"SCJ" 			,"1"		,"Orçamento"									,""				,""				, "U"}) 
	aAdd( aSXA, {"SCJ" 			,"5"		,"e-Commerce"									,""				,""				, "U"}) 

	dbSelectArea("SXA")
	dbSetOrder(1)
	For i:= 1 To Len(aSXA)
		If !Empty(aSXA[i][1])
			If !dbSeek(aSXA[i,1]+aSXA[i,2])
				RecLock("SXA",.T.)			
				For j:=1 To Len(aSXA[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSXA[i,j])
					EndIf
				Next j			
				dbCommit()
				MsUnLock()		
			EndIf
		EndIf
	Next i               

	//->> Ajuste dos folders
	/*
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("SCJ"))
	Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SCJ"
		If Empty(SX3->X3_FOLDER)
			Reclock("SX3",.F.)
			SX3->X3_FOLDER := "1"
			SX3->(MsUnlock())
		EndIf
		SX3->(dbSkip())
	EndDo
	*/

	//->> Consulta padrao
	aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"							}
	Aadd( aSXB,	{"MACOR"	,"1"		,"01"		,"RE"			,"Definição de Cores"			,"Definição de Cores"			,"Definição de Cores"			,Tb_Monit								})
	Aadd( aSXB,	{"MACOR"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."									})
	Aadd( aSXB,	{"MACOR"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_MASelCor()"							})	

	Aadd( aSXB,	{"MAICO"	,"1"		,"01"		,"RE"			,"Seleção do Icone"				,"Seleção do Icone"				,"Seleção do Icone"				,Tb_Monit								})
	Aadd( aSXB,	{"MAICO"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."									})
	Aadd( aSXB,	{"MAICO"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_MASelIco()"							})	

	Aadd( aSXB,	{Tb_Ferra	,"1"		,"01"		,"DB"			,"Cadastro e-Commerce"  		,"Cadastro e-Commerce"			,"Cadastro e-Commerce"			,Tb_Ferra				    			})
	Aadd( aSXB,	{Tb_Ferra	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Ferra	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Ferra	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Ferra+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Ferra	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Ferra+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Ferra	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Ferra+"->"+Tb_Ferra+"_CODIGO"	    })	

	Aadd( aSXB,	{Tb_Ecomm	,"1"		,"01"		,"DB"			,"Cadastro e-Commerce"  		,"Cadastro e-Commerce"			,"Cadastro e-Commerce"			,Tb_Ecomm				    			})
	Aadd( aSXB,	{Tb_Ecomm	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Ecomm	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Ecomm	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Ecomm+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Ecomm	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Ecomm+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Ecomm	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Ecomm+"->"+Tb_Ecomm+"_CODIGO"	    })	
	Aadd( aSXB,	{Tb_Ecomm	,"6"		,"01"		,""				,""								,""						   		,""						   		,Tb_Ecomm+"->"+Tb_Ecomm+"_MSBLQL<>'S'"	})

	Aadd( aSXB,	{Tb_Produ	,"1"		,"01"		,"DB"			,"Produtos e-Commerce"  		,"Produtos e-Commerce"			,"Produtos e-Commerce"			,Tb_Produ				    			})
	Aadd( aSXB,	{Tb_Produ	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Produ	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Produ	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Produ+"_SKU"	        			})	
	Aadd( aSXB,	{Tb_Produ	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Produ+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Produ	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Produ+"->"+Tb_Produ+"_SKU"		    })	
	
	Aadd( aSXB,	{Tb_Depar	,"1"		,"01"		,"DB"			,"Cadastro Departamentos"  		,"Cadastro Departamentos"		,"Cadastro Departamentos"		,Tb_Depar				    			})
	Aadd( aSXB,	{Tb_Depar	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Depar	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Depar	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Depar+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Depar	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Depar+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Depar	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Depar+"->"+Tb_Depar+"_CODIGO"	    })	
	
	Aadd( aSXB,	{Tb_Categ	,"1"		,"01"		,"DB"			,"Cadastro Categorias"  		,"Cadastro Categorias"			,"Cadastro Categorias"			,Tb_Categ				    			})
	Aadd( aSXB,	{Tb_Categ	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Categ	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Categ	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Categ+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Categ	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Categ+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Categ	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Categ+"->"+Tb_Categ+"_CODIGO"	    })	
	
	Aadd( aSXB,	{Tb_Marca	,"1"		,"01"		,"DB"			,"Cadastro Marcas"		  		,"Cadastro Marcas"				,"Cadastro Marcas"				,Tb_Marca				    			})
	Aadd( aSXB,	{Tb_Marca	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Marca	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Marca	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Marca+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Marca	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Marca+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Marca	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Marca+"->"+Tb_Marca+"_CODIGO"	    })	

	Aadd( aSXB,	{Tb_Fabri	,"1"		,"01"		,"DB"			,"Cadastro Fabricantes"	  		,"Cadastro Fabricantes"			,"Cadastro Fabricantes"			,Tb_Fabri				    			})
	Aadd( aSXB,	{Tb_Fabri	,"2"		,"01"		,"01"			,"Codigo"		   				,"Codigo"				   		,"Codigo"						,"" 				        			})
	Aadd( aSXB,	{Tb_Fabri	,"2"		,"02"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"					,""	                        			})	
	Aadd( aSXB,	{Tb_Fabri	,"4"		,"01"		,"01"			,"Codigo"						,"Codigo"				   		,"Codigo"					    ,Tb_Fabri+"_CODIGO"	        			})	
	Aadd( aSXB,	{Tb_Fabri	,"4"		,"01"		,"02"			,"Descrição"					,"Descrição"			   		,"Descrição"				    ,Tb_Fabri+"_DESCRI"	        			})	
	Aadd( aSXB,	{Tb_Fabri	,"5"		,"01"		,""				,""								,""						   		,""						   		,Tb_Fabri+"->"+Tb_Fabri+"_CODIGO"	    })	

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

	//->> Cria as Imagens na System
	//u_MaCpyImgEc()
EndIf

Return         

/*/{protheus.doc} GetTamSXG
*******************************************************************************************
Retorna o tamanho do grupo de campos.
 
@author: Marcelo Celi Marques
@since: 21/10/2021
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

/*/{protheus.doc} MaCpyImgEc
*******************************************************************************************
Cria as imagens na system
 
@author: Marcelo Celi Marques
@since: 21/10/2021
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MaCpyImgEc()
Local cEnc64 	 := ""
Local cPastLocal := ""
Local cPastDecod := ""
Local cImagem	 := ""

cImagem := "CLIENTE.PNG"
cEnc64 := "I3ppcIAFAACLBQAAeJwBgAV/+olQTkcNChoKAAAADUlIRFIAAADcAAAAUAgDAAAARfbrEAAAAHtQTFRF////NzQ1OTY3ODU2O7VU0tHSQDw+tLOzPbxXamhpgX+AcnBxfHp7d3V1S0lJRkNDV1RVXFlZYmBgQ7hbkNaeSbthqt+1wcDA8/Pzurm6iIaH4uLi2djYoqGhkpCRXcJye82MmZiYu+XEmdmmUr5o0O3W3fLh7/ryccmDIBBGWAAABMBJREFUeJztmGt36ioQhglo1CSGmLZbjdqe2t3u8/9/4YEwTIAM3rY9XcvF+0UTJgMPl2GAsaSkpKSkpKSkpKSkpLurW3U/3YTv0qvgfPnTjfgmdTzLxIPCrRXbw8KtxAPDabZHhdvzB4abxuGef7/87825r6Jwx8l88vQDDbqnYnDH+WTysHCTyePCPc8fAS4SLd9+ZuQ2U0+7uOXOt9x4hdOZ0YGGe6HhLq6b7X1TlQlNA4OZq20vNY98iXo5JXxXdRYYzgbqohb4Ouvhysvgwrrlck2AzRa5CAwZa7lo0XhXckqwSFwJ3gR4O+VJBFYD3GJceDEcUXeIN5M8dJ9lqla"
cEnc64 += "hjOFk9T5qgGkiAaerKFz3r4R3hJtlROHNcLpuf0q3hA3AqUa8a5OONMmynIRTX7WD+5K2MHDvZOFfwCnPjWMhyTGxcGpwGNtG2PghAufQLSMGPdyBLvwruIyvzrENcPuoDa8Ywolg3vJX435ovrAa4HZiKISlfgvcqO4KyltB1u3ATXHghCeeHxjC1UVVWEfwYyIzVijLqlfRCIRrhC1cvhoVwoP7Berh5v/gs9anhZOqbu7Vzadex6ows4TK8xFcBZ1dFY66be8AUooFcsgGwrl+ZT8VcovdXSAcdJrgByxc8wHu621uBWzDC6UPgBN6FppG5yvwaCYmkPDFsKfKEZwZXU7tIRauRbjaTgY+DJxw13iFcCtjmDv7uQPX58qDejb3+ZOAs9FLryU7cHaBnIQTFBsFx2phnYL/3P1igBPuHArhvk6zTX4zCg5mutB7UetP8QhcSVidgtviO/OlM+1cuBkfux3g3k6zzY80HCSnDcNw4zV3DAebkRuThCzXUTioSmLE8PwjXGf+bN1ChPszP832wWg4qFKtic0QDU7BMWonEGYrI+FayySxGwm4JTHbEe6XGzssGz6/HFkMDr"
cEnc64 += "2Cq1fPPwFX0XmEjgSjaKnhStt7OZITcOUpuM9nRx+G7ekDno9gTcFBMN6AK39JUHCRXVzUt8CVp+AiR543+rB6PZxpI/fgmKTTuO4GONN5EbglBlpPpzKUa+Ag5Qjg1GTiXn6Sgber4WDnjsDB7hBuqfeCK3EL9uBUAl+uUG1tu+BqOJj1NNzC2f+/AW7NyWk5km3/tXCYTlJwcIIYX37dB25qI8c5ONior4Q75Oh/DDerbceObkPuAldgVLzjyGWyNWqyISwhXNYY1Zk9sOOJ5R5wooHKaycH4dhEAzcrV40jaRcHCdf5cFlwmvLhwkIhx135gunkWTiTTiHc6CgHLesGuE3jx0prGYmWMCMQjtAAF0jwTcgAcCpPuQBuF8CRldtNQcNtqCuerN+PSDgTNm6CEzl1/Wjg/lwCZ3K/s3DmvKXhGppNJ4003D4ON1wzEHCCtyEAwplc+TzcRp/HI3B2VTMYMOeaIeTXiyOEEz0cW6vYQcAJ1fqFn355hc12BABwc4KNhmPTnAsKTqUhhUQ4tpHKbEpeYKmW9AcxuHHWHW7+2XBQSa5fuZcuIm+6nfIGN85LnruSbben0Rh7e"
cEnc64 += "vr3i3htPDX4z27+hezh/Cgh23fVCfbGWeuw0ifxfKymirYkKSkpKSkpKSkpKSkpKSkpKSkpKSnpm/QfgYRMRW//5M4AAAAASUVORK5CYIIYLbCC"

cPastLocal := GetTempPath()
cPastLocal := Alltrim(cPastLocal)
cPastLocal += If(Right(cPastLocal,1)=="\","","\")
cPastDecod := StrTran(cPastLocal,"\","\\")

If !File(cPastLocal+cImagem)	
	Decode64(cEnc64,cPastDecod + cImagem,.F.)
	CpyT2S(cPastLocal+cImagem,"\SYSTEM")
EndIf

cImagem := "CLIENTE-MINILOGO.PNG"
cEnc64 := "I3ppcPsOAADPDgAAeJydl/c/FI7jx6XsWREZlZG9eduUQ8ZRx9m7QiIrK7twUTpnZM/DWeeOjrNHXMbJuDJz9p4ne7tv33/h83q8nq/X76/fXp9AT/WY6LnoKSgomAz0dUz/9fz/Q3v9X9J58utTUFwTBRmZ6WqXSZH/6eIfl+Qrsk6pNKBc4uzsRK1E4IJ8cXV5roEU0SqXgHZ90KoQQxCyvrTG4Odxe1d/N46XxfNvzuyN6SMUpbM4keMI8inZoRxIWMK3/Kn1q3PXLZDsXeo4Ix+DyrRUCoTa55vQhJKMn9Bz8v4LlIURXHlsZ8i36RVhsQ+30vK0QEktTzSXkETeJf9Z7LQqNAIjZJVKFOf/El+gwSpVDz91hW+dr0RUe8lXsmPnSn0rHS8vSZGNvu97fZMG3huVmzrVgBJa42Lbwn7t9goVUmhmSka0vHaAg6Y2l2unK3u3W39OdHtUOQVX+ubgswIwVibZ6oW4bNRAeckA7F3FS6FKinXSdEUngjA50DncpJ7GWjRetnI2jl7M98p8Ba7V1YDTUv8bE2qgo2X2Lmc7G2a78ISrZ9+j00iImslZRkSGLqqAsz5Qtrr"
cEnc64 += "pMORztW0QKuB4stWrqvWKHPmjNYUiKuQZMDR0c3o/Ik9T3OBj5ukg7Lgnxp0r6gHt/2BMDFMYSfNB5K3xh/nNDPmsxKJfTnMRJK8wwO8GZedz/CqpuxQHZWGKPlxbJfWURreJyGgfLQxNw57RTI9J/nwjIeL/6UHM7avTs4N8iP+OuKDUqvDBHLlLe5K/+p5YJSyklcxBhrNhzum7yu8edQ1n63BYwU8UzJBBh6H0wW8nFQ/n6MQuXo5E09A7RrjIbK6L+K9TwqgIQCrSVN72CssCjR9nvVGg47wpL0zhhTR24bViq+1TxdYhQ8rWaWyHzaCbwsRt9uzE/icTU/t2ALewCEWbbD/XUC71IAP+I+pYFA6Hs8A3lCYqGqdIokz5qSOtywQMXzy7PXPAN06LwO/Oob8XpJHQ2+bKQR3rEy57Fdjv4yisxQ9LmZe7CXieYROrhAMG7p6Xg6X0WOl1xyDDiA6ftxmLCk5hHXe/DoVSiUpeT7QQ2RGdUjx0gagnw+Wrfry7U+u1jt/6Nre8Ye7EWSIvjXFsJLj43PHLLk0ZMP2wPpfEiMPwyBAJzqMOWnySNpWJ1wGIEeuirLs82b"
cEnc64 += "f5PntSB6hB7g5aLHTutXjKDUuw+fN6aeGOV/9+AJjynkHUwsrPi96N4W8H6Y0b40l5m9BdCtUFWNmqbnqJl0zXAfwmpkC7d2d26aDbicoaRJbl5CuVxF2hbdakhE2ebTDXMGZI4ZfM4K4eo1KMD8ucjMSsSCzw0SnOaEBKZjjcZUUlH5fM5/IcTSlk6kU/ICTD0TI5inhtQ5V2qP1csXtTxv05603Uc9lpgvXTsZx5R1AoO0TXXmlyKMPfHzgOF5uu/biKtvmcC2yAA3soVIQ8uAks4UiJuDUbZoXSaAUrxF8VsP53mzIoUD+Y+w1si0E6RU/5ho/Jp3LV4sXHUCH5jNol1+Sxxrli5MdfZi9d6yTxZh+ge03r72vTUyyTP2jav/aoJzLXcqjGIq25EATnoTBCCdtHvgM0gT2HuAy+niWPW9fBjupvnrugWpiS6hQk3EyxG7EWdSzbX4edk98jkG+AYE0GId/kH2juHrxzBeFrm7sOlIGROdSc+hTE3W/s5szPuY9qBLBaAOsAJ4Udrn602wGOGq7xkdrwl32bRTuXrGLSBmuPe20CSG0H2uBpUYd2TVXVijap8tTGR3f+G"
cEnc64 += "652Eowa2yQSmf9C+9lCwjBBAacr8dJtEyInhNHJLpcqGktHhSbvBSP41dFR4HX3WieBztSZWAoNDfBt95jLhf8U3h6creEKO2s+MyLgNM2OKzw6udEYoEU8TY15BYtABIkbdDqQCu/sj9BDOqo80Ngae933ofZWDAH1JPmN1n3eUpr9RRfqRzKpnTEpJSPm7CFlR9vxWrb5L6gN+STInoahG0/IRPhDhLVVUYzXd0EIJghUcq+2sAuhBkmzRuoX8WZ1fTtXj26oW6HzxFY+tFyzxE5X6ikZyG+6QC1i06iOFgI36lqUQX5TGbSOxtoymSFLElL/9VMjLH/3s2Njh+hnUa+A/Nmyi9QWolsWfmoJ2RsWPucoM+KenNAvkGhLy6jc+c6tDWkRZ+wbZujVT5FSrk8ZIeJdafH0LiU+YQ6g6cm7MH+f628S3YH09WLRlXbbMRLiPI64kdWsL9Ug7tNBy1N28a+q6xqQ3GK6+JRUftXEhHKOQbc2Hrtb0uJGXHxbVsjtZ6JUROyPczD9uNBy28bY1QnvhJpFnKt4J9KZ/vinWkWOoM7fh5BU7u4S5G8ldwGZD90HezgSXWPp3wcR"
cEnc64 += "u+a0aYtnNxaYfu51fPPZ+aaS0+KOO84g9U5NaSm78XRHOt8fZL/z35nJpefXIAyvvLTewnf8ig/YupmlNqUi8EEM+BSuoJSMiyAMrO/YMwaI92vSME28cWgz/GMHnzMH3wl7KT0zYhx7+KrHqhN1vMO24QrttqW2svKrU3WyzlxxlaB1/HVfSuSLPMSCgy0rnn7aufee5QSVB/rouUqeaYQ5bcBExx9dCH1v3H0x58zOPgwAFv8bA7gXwORBkpST3jp59TUU9tlaC65pqcwtXuWuWZKY6OGIKuKlvzlQ2QdbAeU/8UysfGy3D5rfXaSf9qirNSzPDVSMDbpijWJcj4GqOnbkDLI1NXammbqtINkWMI8FEldD0ISFQvidn0ZwoDr3WxaY8ADrC426p/bmctdzlCdo4l4XUDAqclI/C46PRIKoP9FAfUiN+NRvlaxmw261gfuk6ebs7OygnXCGKF7ymANfY4ZocY+nuGXDNUC/HTyJKp3Vd283U25zbtcPcpmgN5JEIV2F1GIB/ups6+X39thlu86WxWJRPm+bCYgOEHd3soMKbsbLGivGJqLo4qDv8c6m0o7O57IVZFHI/R0"
cEnc64 += "2zAMVEwMv69DVWLgdSLn8+7YyOq9utMDWcvmc/nAW5DbIbhPSXsj1KSVa+06fC+SGUBoyNtXwbmDIqbeEZcbVTYicpZUDSISBSLR8XMWynoktqCa4vVHggv7kK6bzUanMizv347yYUamdhBxXJCG7QQhRMOTMP/WtbNPGf3DUk6pxj6PiPSFTqi1xcf9Xfpzedbk+FTJAJcx3HSpymuZsbM15Ux9tMc+PeEkxSMKW9NQ1YJE4RMFr6V6+nqYgGAxZaWHH4dlUBwyZttJxR3G84fJ+NcMJVhvsnfT44csyFDtxtl471phdak55LFfSngLzJUg2sgA0K/qosFoOrM/3OkPMbqt9uQyItFZpCLtT98dBQqomoLm3Zn53J72+WIa4pJv+7GmmMxgWqfcBT+XtOy48LVJJpugOtYYbsnAwnmlDSF7cctXn9Hyj6ZkAm0gqWSViURehQakQcjTpvn5bJOYwfQBesUE9ZltaejF//pC3KcwWFP6n/VEsJvhpKta+8i13W2Rrg7x5grdro25J9ez8gnN47xeukToz3lpKMpex4UYRvHxc7GGvZBo7M823VRT/L94w2qb7Te1Nv1we0U"
cEnc64 += "Zdm5cS3jwnLr6ofuy9v/wOyXA/a9HiUXw3JXuRp2ft4Hq0csY9Ur0q6YX077Lza23fMtOU5p9FavvM/17cnjtz3s4uUPMsInpuhT2a2Tg+n724FU2lIeWVO0xaXnapD/0z3feen2N0wnY3/NopRoDZS+WGURIr69/gH0AwFyLL6kHJhY5Lc27ImTp6VVD2A3Edd/KpQWE+zKRBT5WyTUIdhXYXKBdXR+eO0AnT5AYLHN6oUKOIYZhJa67NK7HWNpDzvpUs3NanlZ3GuwUIYRAgVTB+1fbRurGUkfNXzYnwxtjtj2TAlpyGCaR11R0mOLVxxyoP8V2syi73SsQszFVbRy9OyTuGlpI9SnkIbFL6uXiuuwXVUsN6A9DfusF9uMq1i4lYdhMzFwgMj9DmpWiu08NY83VaCBtV3Ccf/UfDtrQB/InZl3Kv4RqlwebHBY7TfnmsKLXB7yHo8WrSLsHD49jjCesNrTweRUv0jSlhE9l4pkH8yp/yRAbyW32LT3saMRPBzg+nMsZGWXAjQE7Kmf4jTH1yJjAqXtjtGCIup5ejpkzLTOurIXvpRsQqJZmuhQyDRhNCW5s2V2S/94euz"
cEnc64 += "pph44RPQpmSu5dvuzcrwPq2FIxfVMzw3qINTN4TJ3NSPoClNNx7dQ0QdliCtlPSMHAiOVGV3aaLm6B9NkrcElaOlbIX91IcC+L2HjLfUbYnNrjnmmKdpmsc9ndwHsx8LmHTa/cqePJ/oF5Q+s6frjcPx+D62ryOpCJUPoqu5OaixsAX018LbPd62m62MM2WKRVO6pO8e58D7ABDSzBv3G9ZA90mtYvd8HoO7U/vBN7HkoIgLIlY2iYiKZKxn+vrL+qrHlIH2A7hv4k7sarrVtO6ES9Fcrgyk+qje9PdcHMqzfbqm75u2DKH90xWc3lJh/27tXv14y/jSiPPev66vV2JBgzYs8y2a1rPOx23U09PNoVr8AiqPWJAyDRkqTuSDUWNmqB4Fml6w+e/edo8r96G9Hf8XqJv3z829drPz7osDhPUeq4XPwTsSDrZpiZvEi69EKo80HjtDG3pNq62k7Yqi/I7HLEc49PJpvrjl97k4G/pnZyCTFjDU6zD9dsbv5JaGtswj/m+wbyvymF5BQi+5UsHHiY94S606g6m6CMPNU6u4ZpUXWb7/Rzk/Y6R+tirIUfkMBS/7sLo924GLUqz"
cEnc64 += "IKTWf+Frdd3bkPoh2fiQTmzknfk7h9Rik8C+gUZl9D0dgkmvy+Zqu7sJTUt++u+i8fq59Q7Zz7Rb0LkkjCgA+Nr/aQTV7FpwcRPRN79AcnSEz98eMdv46ODEb/ci+Ihbc3BUlkadwjt98IqGUSTnUqFnUN42O4hZNSo0iljnUfrMpKAkglJgpZTB+mLZhRfCLTU0ExKsA1EKXkuOVbQzgvnsv2Q4WazomfksLPW/HKCoB71kITLlTa6ECrGaD3r/Ti2Fge5THTTAKer/AGZjhzA="

cPastLocal := GetTempPath()
cPastLocal := Alltrim(cPastLocal)
cPastLocal += If(Right(cPastLocal,1)=="\","","\")
cPastDecod := StrTran(cPastLocal,"\","\\")

If !File(cPastLocal+cImagem)	
	Decode64(cEnc64,cPastDecod + cImagem,.F.)
	CpyT2S(cPastLocal+cImagem,"\SYSTEM")
EndIf

cImagem := "VTEX_LOGO.PNG"
cEnc64 := "I3ppcOMUAADuFAAAeJwB4xQc64lQTkcNChoKAAAADUlIRFIAAAFsAAAAfQgDAAAAsbypAQAAAPBQTFRF////8xhi9Rdi8Rli8xdk9hZi7hpi+nml7hNd8Rlg/vr7/eXt6xxi+RVi8Rth9DB15R9i5ai9/PL1/RNi++7y/uzy/Njk+Iiu/L3S6Rpf7xtl/JW34SNj/enw9Dl499/n9EqD+Jm5w0Rv9c/c8K/F7lGG+cbX8ypu9l+S90mD7bXH/Nzn+qnE5Tdy9FaL+8zc0l2F6mqV7KC6+bLK8maV8nyj+KPA5EJ58rvOvzFh+naj5WiS6S9u4oqm6pez4YOjyWqK5FSF6Hme6qO6/mma65Cu/svc3FqGzGCE1iZivEtx3Xqb38DK7b7OykNx3pWuPlqO3wAAE65JREFUeJztnQt/2rbXx5FlqdixgUJumITACIGEQJYEki5l3dpu7fbfk+39v5tHR7J8lW9A8D6D3y6fFvDta/no6JwjuVLZ69+lwVPn5d02tOg/npd9seXq9eMS2baGhVBAGhPasK5PDsu+4PJkLhyEESFIsDaM6lure1f2NZclc44wxZhSrGiFb9Gyq7a"
cEnc64 += "93FXaL2TLsAmxyeii7MsuRac22A+EsIr1G4jZKUKI8bns6y5DZtfWmMV+ixacCJvRNmqPZV95CXqkvFFL1BK6+P+btHYGGzQv+8pL0IuBwQtB24ONjBrA7u6e/2fODD3oW0dhR/3ujcDmcgZlX/vWdd4tC7ZxU/a1b10HCthCe9gb1x72FmXOcEmwR5Oyr337mm8fNoxpjNq1Wfalb1+3SMeKaN8bSrNbNqnRk7KvvASZve3DZrRrZzsZHLnU9e3CxjXDJu2fy77uUmRebxs2rdlkuZMNu1J5xBG9NW2D2GQXLTaoOdwybOaNTHc2D3mpi3j21lp2jf5e9jWXJvMaG8yv3hZsXKstdy/i5+mWtjWyNdhsBNkp+4pLlDmkiGzRjOxyw65UbihC1Noa7Ieyr7dUNWcIsutbstndnXVFhG51zSvSeXPYu2yxQc2hZttbgj3daYsNukS+8/fGsD+Vfa2ly+z5w5o3gswMFWE3tN4s+1rL16O+snLCJq1Wy8a0X/aV/gtkDt8atmYD7Oejsq/036Cbt4bN7FPLtnbbx5Zq9t4aNsW2Pd03bK5HZyXUOC9sZrVteyd97PPjmAZdDs"
cEnc64 += "+pF9Goquf2Xpg7sizXFTGPDjw1m1tK7w9+mTYaDcsBWexPok1zp++304MiOu44uVs2xjTFx369fC90ox70vL6X3wtIpvx9oi7DqbfJzc/3z8ulbCa92f3Jw82re/cPb2687eLHP/S/FBWKJvvg62RwU6lc3GS0n6elZVkSNqPN/sBhU4rnhW/3aX6bTVMGj4+UWuKsGspi4qcahWbB1F7wD36puX8XsuLC9UDt5um4znZgUQoxIHk+2Dr7VXz9659/nsl99I4jx57MqCeRPDU/LhvT2/vGXWXYSC8Q/VAzDDl64YaDo9YQtdrTFR7zec4qemxZKT72O9p2I2GUqgJVQ8sLlInynp+8vytyqHw/Fr2VWzcXFga6lIZ/SM9+ED/4md0v+Z31OdLi5i5otoExE4TMW+uiObQWg+dGahnd0TUznrLuye/oNHZ2jVXSVd/ywqbPKeG+W29OD6aX8a8Pzyyvb3jHP/mbBuu3FGJsJezDGew9ek8I8WE3p+xJcEvBcKRRvFo+bF22+lvavJjOe+P58p80OLfVqk1AYdgI19rtVeIWB7l7yLS9n48MKXof//qmQeVe6Cn/hMFOZQ3YX"
cEnc64 += "NjmWDk9y7aJB7ty6sh7R2wtVGjRfAbQliC+8Cgah1ftqx46naZWwCwSYdPaKi37Ki/semq4b+jDvo4bs7/8hu3mef6WLTFJxJawO2CbYlaHeaIB2OaLvHekZdO/AofuS3PNmrw//r3Vm6dn5w+95v2vaVc1N5RmBAYdpLeKzc4JG6dHRT7VJGw0is2SNId+0/wuPvrhjGY1bCxgXywtzxBEbLsPuzIZeU8K6zf9MzgfuT/XWi3HN3CmCf9WxL8pcFJgk9u0LZW6GGXD5jWxGZ3vwGvZSIvdlsEIe7DdAX8mbCRt9gPzMCiOt25EgrArHe8eYYv2PIRfZOiZwZ4V9tXuAbY0UEHYmNbotPDuFk4mbLi5HqQkNUfQAgA2RjHn71beMvYTt66bwQ4VOMdgY9rmsJuf+QytVotEwse2beMA7OY12BDihprl/b5bijsEoR1afF5yX1wQs1hh2Kxpt9tthSeQqsHSyoLNrKeNcObssBcXNjh30d++QzBXkzcRafl/PqPysZHTgKKwp9x1mIygtQJs+FE41uAsX/2DwIiBwKxQKFlypyCbM8q6BvcuLSqFddDF7p2ORDm4IzosZrXN"
cEnc64 += "RSMLNg+t0jQfW+iWuBs4zigyrBAJadbjsUO9uM+e+dDpd1yNPXOl6R1fYi9X0kJjipx3t6chBduq+QLHIO4zJI7ziNjZtxAMhEh9lSBaB6Ay2FoUNn+AngrtazKyMmETm8F+zsw83jkebCcyUGD9ArOj7KlnjVnVq9wir3Hr8S9dE80GORm55smUakQ+Izq0+cOugA2T+1ExMq6a0DtjMXqMwy7mkCxwZhqN/YJoaVERV4czdwM2pL0Pdx2vzGQCbEq1kWp0/IA115XV9Njpn8jzoFY3o21+YjfTsgRsBM/4CR/7aPyZL947cvW5K4TVsHERq33s5ILNLG2OW7jwW3Y3/PMv0HuzvbAHUmnmvmKN9XZEDfud21TZPrJ4mT1EPdioXzmWbh+Dba24asd517Hc4FOkvwA9F7iDc/Z45zAjWtyZU+hShLQwO7lGaCqZOWVunEb4s/yXasuvPMNpJ8IW52HbmY3zygF/3u1h68dzMcbnPuMKvaNQH2DHWQvYTn7bNGjwsrUM2Lat5ep2D+ou7Og5TBBr08yIsCNFrblQOmy3g8wDu7IIwCZdRwS1wNqvXp940AWjnWBGcO5Jc+Z"
cEnc64 += "HS7O1TDc7t2maiYidoxNtHPz8id1SDLApVi8K856iZJu9kFEVDWXDvphKMwLDdsLcH1g7i1KnqEscUAdudRJsJ29S9uqMwjS7jKgfO9VevmZxwtfiYE6SbYds/BxgEwKNrqfc8L2F5DBNBduQp5Kjj+s3ZMwFPFYNuwuVjddIMR3VNXlhPmqEalx0mI+NOWftLQdsnNcw3TkYBkBwNkGnw+wi4SezC1fPxQHY7rOvgF0zhJ+dp2VXmkPqRf9scLrh8jTnKt8VqNUhKbDb+SIkAwyXnwkb4V5Ou2ROMcxI5X1HwFUcuD4BZUc7VW74vpEC+10VBszQd2izHCdxFRiY8rAG+zN5l+8CEnQ4MoxIbAQZYtUVo1rNZ7XnIkyZBVsjue3dFwz9HO+nA/m5r6wBiEEJGamfufcNL9yaCJu1VNKbRFKoF4oLXfiwZdxltGYBRl8F23BhV/PgubLg4chkjVD+Weo3ALvFYV/7PeFHD3Y8QiWUCzaj5nSjuo/b4otpBLamrTR2DOigq2rZwozUSDcHnzH3p0jmQl44/9JbEx1GxxrzRnTHMxhHzwI2+Ltf1dv5sEmyGXHL/cHyCRGj3W"
cEnc64 += "4r9vgQhT1buwCjkwLbtrPv5Z2TDZt/l7O7BTVn3F9mHHTdC2NcUQ+2lbBsRj7YzKljXg3yWdcYbFVSaxaGra/VO3IddcH2q2DXDNuOBTmjMu8hG84fzhRrzWyMXsRDPSEEgvTQBjyj3SeQUOCwklxIDzZJgc0BglcizWW7ze6fCvY3Jwgbrdc7CnXAm9J11jZ9m13jXSRzeowsRHcNiwaWqFOzhjh2XleE61HXKAarresybm3+ZgvY1GokDZnzwYYuEk7XbVS03UYEK9O14yBsZxPlic06d6fcYS6H5t5ygJ0V/JvzMg9hlAPBKM1v6m4cu1CibdKFJXhtvouBPE3Dhd1oJBm3dDNieAle7jjLsRsb/du2EvbByAjA1jey3OMTT4HaLRKBzTPv1XRIg7ZelZCTYPM49rBYYHLu7UNzPe0LXJOwE5fLzQWbD5iIyA7w06ZJsOdGEDbKCszm0tFUJEJRBDZ3CqvpDsm8KmaXyXaigC3i2B+KndPvmgd7KD75x6LS9Uu8cdkdpMSNfGcEcf9GAXughztItJElJHhc26I4BhuadzUtQnJq6VXbHUSnwNa0orURA929QCRt5Y+NN"
cEnc64 += "hhYqJP5krTVSrAJsO5G6/qYPkZSmkjfxHqPB11e6OO3bB8ae45SOJlz2ahTYEMcWy9aGmGO3CQA65i4rWxOG2236CO5qi4Ttttd1xcnESlYf2iwS9BCI8g8w/xM9SlPkClgM6WEj+4cv2tMhp03jh3S2IMtwvUfzjzYCWP1Si7Y0IO08kBr9nAMtrZGgNXfsZuNVC50i5NztPcU0lBaOuz8ceygbrHcAeZG+8TiNhtg9xI3yteyWzmSB5XKJ8vn7AWiNrJKb19WK6tgN5JQ3VkcdrAsVG2zV1i778Kr+cFdCI+MOWuAjZJT43lgsyeN5IB9sfRqf4gfYrVXTooFdFRH4Yxt0J2zkrKRc+7F8MrO1JaNVvBQm0O5L9p4Zd0K85jccS35lrhRNmxhmKKF1wq9eF0jT7RBhwqXp0zqF1VfS4ZNqdpqD6A83ytZToaNCvrYQh25M2oxT/sDO5ALOyXOuTnYd7rsMgA2T4tBorlWLT4lI67zbhgWDqmr6t/MuSZq+JHwiQO3SnYorlbqVl7lwSllF9hBsKYU10vy5eaBDcOZTDNijonXQWsnMJxF/NUbWN/IOLITHgGGWKuLIa8c"
cEnc64 += "XlTAY9kiy5oAe5X6Y2Y0u97xnQkPwHHY1VpKIHJjsB+RD7t+eOpg5BYy1OL1hyvoqBuCHYQO9drxI5hzUTWEgh6jyow4xcuPxf7dslF2iNuJw3YOrHE1rUgmAzYRys5Bml1R3wttCD2xdh4YSWxkmZR+2I6EYKvi2gMYOFsqO+/DFnHsFa1cx6vRxc414rAhfZSWoc8Fm3mqWVn+B168KZaPgOfyboQxka8B20Qf2VyKC4vDhkB+3GqP3QkmCMmXUsRgi1zZqgOBq5FbhwTODhRTQoTdqL2kbJIKu1/l1g5gj9LTAAfPFo9VcdjcRi9w4J1r49SN88lt2uFkIufHfGkjmja6cixv6lQCbIgb42Jx7KCaUx6Rg2SBhG3UqqlGKRX2oxhB8mKb4WnaWS0aANvmvMfuuQTGE6hgUE2lc69eO9TBCasZG5eM3fmCKLEQCpZsJtRavff+yEupRVU05FbYKRnV1IXkU2EfU178DzMP2JD/+fuPQn+w/77/+GvAsDCXlhIZpnKDJpf+0A3lysxmqc8nrsVhc1WjcwLb7exCSptYn1dPkl7K+nF5kewBo89pW6TCPnz290fFPGIxN5j"
cEnc64 += "P8P3D/+FH9oEwI7YtjZY5w3LgllgiVEhHUxGNQkrYIZfHnFeZZ5AOm22kIWuN0M254wZs3ANBGEaZK/SUCrvyC2sgoalL3txoBtufU3PD6NcMCNMj4j9H30aShNZqbaKP7LvTqMJ+sjiEXg1a7avQCxISYTMfe50nbijPRzwpMGymqZeZDvu10W67E/MCngBUuAdhN3ttF7aBScDNW3gm227Z65T8yePU+SgpPAXIa9uB4J/ZQ3nqsZmvutZ460mMJOT+mIGrpd+8dNjmWPhPLmcexoMhThh2H24IwK4aWnD2TNMfZDEnYgPjyCcx3VgNu+b7ATd8GkQO2OO1upLDHg5WfYMVSb/IdNiV46UbM/MsE7yTUgvBnnSphF1FoX7KW8wdKmmVAYyCV9dVze2WB/E6YXPozthKFWyy5otMP4wo9ffHXL+UuAgoA3blMhCf9AwJDsFeiJIpdheq7fBjZI7lVmzcgTfQR/ZVhliemi4jJI/QW5P4D2ObrdewmT4FFmFgsH/LaE/vGxTJkavypzfTAG2Ra+VRj4aEPXDkQI7BjvjTd3JmDfNScHyqd2EddINpF/HAYZlM0N01WcweuG"
cEnc64 += "FZrMGMqAt7i+g9oyP3h16ynt3XhsVfa6kl1gRdzGFyLNwMb9I20G78+T/x/V+Q9yY8NxNf4OaE8lmUlK/FvIH3WPZJMmyEZpAzOYeaDpLZsNnDtnbDZpqc9MTB6y85Bm6fPvdA19fjxLHP4PfxSKAWb8iGN271vv/yf+Lb1+GQbX3dY//MYzNJju7Zdz2hzxtYK69ZjzRtHISNll8eTq5zLhxKyAaGtUwHV0/9fv803yvIDo+4ztOegebk7rEv9XR19e34wP/5kZRqF6b37dFGVu3tK2F7djMcAUk3I71NnM9/Wod1BWzulOKQ15tD61fY/uf1pIatybonL8iX1qjhJ7v4JuSiOrp2PfcobARRgehaHWrWPEy7vm+0A3Lj2uFFy0V4GpYHzoYt6rE34Yr89yWykdFWzFG3WnrP8UJUfrjKvykgePUgbazvY++EeNOOmQwx+bJ7PsuEDT+ke4udT82umCUfzkiKv3Qqj+HUVxw2jGdReih0L19PqnfVYMzGWrAmQQ9nwkZoE0nR3RBzSLyoryejSkRh/KkKdvCXEDdJrsfbK6J+wjKa/J1J5jgDNvNFNlERtys6uhYVfCGRl"
cEnc64 += "rue+wddlhYrS4xh+YXXjAPsFVBH4U1rtlsKbs78qJ+qnnsDceydUrMeKSHmYOVyFI86g41jVt2jvYF5xzulJwVsf1WbISIavMpQDXvvihQU5JKjDdZPf/L19Ro0fj+E9j52QfVjCHuBvP5MVOCpYe8Hj0V13o0yDOaBTvXkaR10b7ELq++EWYfeS9oc69406ijs+70rUljMaodghwvuP1AxOTkMGxzCvY+9ivp+9oCBjJYGzPRgIljA5vXYG5lyvHOC4J94eQVmLTZajfpIoi8Bcuux9wmalXRrwcuOKK9Ijs/RnaEobF6PrXjdyV45dDiEYnEoi2614gWNdzGXj9dj733sFXX83GhYkOVqKaajmTPDiMJG+3Df6rpYLKFU8Vo5aeiUhmFDfZyzzzyuoYvXr5cDdamVF9cOwM4o6d1rZX2I+CN83vNeb6S5vxCXGLpvYjWOvdQ6v4Z8jsfaXn+t0r2SNYFMuzul0MK9g7LP57+to8UIU/E+1+nJvl2/tQa/f//7p59++OMf5Rsf9trr7fX/H7CTLgUTBTAAAAAASUVORK5CYIJP4ML/"

cPastLocal := GetTempPath()
cPastLocal := Alltrim(cPastLocal)
cPastLocal += If(Right(cPastLocal,1)=="\","","\")
cPastDecod := StrTran(cPastLocal,"\","\\")

If !File(cPastLocal+cImagem)	
	Decode64(cEnc64,cPastDecod + cImagem,.F.)
	CpyT2S(cPastLocal+cImagem,"\SYSTEM")
EndIf

cImagem := "INTEGRA.PNG"
cEnc64 := "I3ppcBB1AADUdAAAeJwAU0Csv4lQTkcNChoKAAAADUlIRFIAAAFyAAAAaggCAAAALrRNHAAAAAFzUkdCAK7OHOkAAAAEZ0FNQQAAsY8L/GEFAAAACXBIWXMAAA7DAAAOwwHHb6hkAAB0pUlEQVR4Xu29Z3hbx7U2ev/dX99JLIkEsHsBSKpZXWInegebOil2FTdJjmPHcU8vTuI0x0lcEvuc5KS5F8k1LnJTs4rVuyy5W7Yae8F91wwAghQlkYnk2N8FnlfQxub0WeudtWZmz/5/FNmXQQYZZHABkaGVDDLI4AIjQysZZJDBBUaGVjLIIIMLjAytZJBBBhcYGVrJIIMMLjAytJJBBhlcYGRoJYMMMrjAyNBKBhlkcIGRoZUMMsjgAiNDKxlkkMEFRoZWMsgggwuMDK1kkEEGFxhfTlpRSxXFrco+VQqoUiQFRQ7QXxUv/qooTnxLqlvCTzOSLZRpmh9RRGvA1CoUOUSBFa8qcyApuiOpTkkrYukMiTNKwmAVS1XVo6t+SkQMS2LAJjsFvUTQY1bRq6kBQ/Zr1gBB9BqKZ1D0YYCVNr0MVMck6A7uI0xIQSNQO7BrHjgRDA2"
cEnc64 += "C1nBSg7A2kRSfpAQ40kJSMAZKloXpD8auvYiuS74kvGnwJRvTrXOwm4YY0M+GodNhxUAXqyXUiVQ7Vi85JMkRCd+8MPQT1z5UKlnHM0BxzwtefWoxQQzISljReLJuWXPJWpmEksg+dCKgKn4kK8sefJtmSFXCshREd8uSH39CANyXJDclSwVINWayPfsbn4F+okdKSfxSIJFOIZS4oD8l2hYQNaeY7EQUPi08hWRZJ8C6zJdsNJ4jL0yiyrzrk0VifU0309vnX8GXk1ZYPyX7AE0PTsF3uiIl+5Ja0Dc625M7tloQnLLoyTHLJZsfokCBKRHqJ5YURWftDjFifx0CZ5SEw/CJiksSXJrg18WIJodl1aeYzjG2Mqvk0nXSH9ni08WQDtGUmdiNCLwi50B/4KFKmww2QKa5wDEVTQSmMLzdWNMlaCWpw/yC7rCWT4DLOsfgO8QXjD7Swg9Cf+B0sJI42eCRpBWGVAH6C0aVcrKfQyBR/WGBGgHVlNUgIMpeUfawxN3oWVFwy5JXEj02qxNShOKBWazWUk0NcSAF/BXAnzB6UYKJNh8gh6zkqZZnP/v1fHBh0sBu9qfmBqeIaq"
cEnc64 += "IRECCdU4BEdgzJjFLtlihJMuWkyiTKxkMmc/w38KWklUTzJZomhbQwibZLhBHFCtNOtAKV1hSfLdtlN2MYYVgn0U1KkGiFCS66eUCy6UjLIg2yGbBJZRimTDlkyhHQhyJ5JLnYqjgx4mmaV8NQJoQ1OYoxTZBp9BsZyPIi44shJRnpAbgYJcQu+TM92LnK3/+nVMT+6DxiQrETPwcESIJ+9mfBmpSLe6g//CCk4g4Gz4JVuT933ETVkk1B9xPBuDIMBa5UgzEgr1RhQJdKEECykA0SD5YFXWghUfaDbgx7zLBHVB3U4xckj8XmxDeuFS2Ab0ZGhDNTTmbHypzekukhE2HOQCqRROf2G5s8KT6mnotWkqYNi5KWb1oxOOnw8Mm//uv4ctIKk9cBDcTbMS0M/sRlGjC1uTYrAjhlpViSSqH/mgFBobGCiykNkpB+KWFjJ1M+E+np98OquOH1gD7salC3BcEghhRUJBesGEV322wluhLSlZgqRyGFglo2KPr5kc4pdAcl4aLJwQqWkKSE5CUCDw7Pa8GRln76z0Q66XGBVF6EpJgmpTYB/EzoczJWImIy8JlI6X/SqWFgsVJ9m"
cEnc64 += "so9nVZS94lZBqQzAOnF68cZlU20GPk4iT/B3wlrrMsUKSYrUUEMiVIQsFi98JVUPQwwigkjI0HygXdQcvhQ5Eal0h8MXpF0UCud0SypoqbdZHZNAokqJFpmIK0k+46BJYKRsjQZK5UvhSSZZwWg1NLySpb2X8eXlFbI6xnQHKy5kwGopZJtTbBZyPVVDZdNLtRz/FbJbYMcJMSOSxUTU6IVYhaewlDoL0M6BFjFqk9VPargUaxBU6owtQpNjWSLPtWIZFlKOcHhDnKEYzwo+vnR39MoQ3ICRYoxpCZTksVL1IhVKhGRxUogrSI8QCLMQAxxn0ekRJLCnZTafh3gF3QzGZ7AwgyFBI/wZgdiHKxG3BJh/ZKqHVWKmyq+ZAtQyLR8h4X+SvEsEs1FLUbzJhAwMlvCjFMiskicohuVhlkFWrHafIoaAXdkWZw20Y1xAhXBHXYzKkpRm5Cilf4WSN4Z1AsJsKYbCv3tPABpifcLOaOVlAvJmw6VZe1M009cOyj3FAFx64YMHA4WK5n+v4UvL60wyePGG2t9OJzJAP2cwn17uMSGIwh9FjSvqIVH20JT868Q1QpRiTBy4X1AnURS"
cEnc64 += "PnJrBYaProOVXJLg1uUKXZltEyqzrBFBqb10ymWqVg4xFQWvrgUVzZ9WzuGD554SyiGRVkheowHykfxTCqkwCYFLRWfB+v/KAiS1jsdNTP2SCDKpJfR3xAC5ZCmkq/RAJKMP5BdWHcRlmVI6vHb8DrNWcJ1GK8lyDhuU5oASpsCnY7nZIokEWQrSxIrktlpLRdFlmiHqa8VtGH5RKSPBU1zgF4vNDcZB4TW9gqXMWzK9a/jNwTkORKqpU0j+iZeWJUJcQANVSs7ZdYIpUolQFN62adEHhExiMLMkA//r+JJbK2mcwubGeQDe3Km1Bi/cE1gTghqwKuVWZcGEKV+bW3O3Ra4V5EowC8VKNGVCQyjlocHTHwxRcBsa0Yoi+u3GHEGcc4mlSrTXFZf9wun5karNo8UFeF7gFNnzL9FKmmjyju8XOyZAHP3hB5Y2GWCgMPG5akJalJQCp8LDNXCqSmkSNBWVmEylHAdEodnuxJ+oYMm4iZ9DgXFE4jq9Cpwp2J/6ywYjAgUoYUAxmGqRSiRyGQLJCg5CMpd0UBapxtEgA5JHFhHYa+p+RSm0252qWqAo+XY7yGVGVtYkXS9Q9Xx"
cEnc64 += "VL1S1Yk0v03WPrrNGEPlKH2+ZFFj5h2xPqibvoEHNkryfVkKeGieCBJtwJBInJBOhiAlaSRYAN1PBKEqiieg6EeAC4UtNK1yUE5ySpBVqfd7WnFMMyS3ITvJT9MqvZldOmHbD7IV/XtT88BhhsSDPEeVyNH2q89gQyrVlSPSXIR0wUhxaUBWdks2rqrPH2GZbjYZC33cXNTzvD901akwMjjdRm+zKthWrGOvOSOF8SEbhMkfaW5IGrskAEyYq/wBJYiBRS+nVICSzAAaJYEoHSlS1KKnSKe7gDZWWkVqUKg9XGK48rMBDAuE5WCyAV4TXNPEz1R1wM4ug2wQUg0oOsyKRxZDQZeeQYPVNgSdOFef6pikeACkrcplpuMeNDbU0X/un/3lqw/r9u3Z++NmnfR3t8Y8+7Dx44NPX1+6694+PNi2+ftqMqKIViFKhTA3lSiabvt7Pyp/emBysPXm+qe5INh2b8iOk2yZkpydupu7TNQ8JcE5hkpCilYRZh2Ascd50+EmF4T8pKV7IC4IvJa0k+ynZCmRmE+APCzafoYfs9rBgLZGlUofdK0vFkuaxqpExUq05/lvVNc/Pb3i5uu"
cEnc64 += "ahbGWZVamGtcJ7CGmSHU66UZKW0QDIVifGMV2lfGXJz41kXGsWb47ml6UiWfNY5KpR4mWTS/9Y3bKpsv6N4tDvRsvlsgZRKzNkP8wZltfIoKrsG92vFqxe9WpfPN7Xl0Jfb1+8tzf+zpF2XSuTJAyqcP5LZKVY0wpXrV6LPyEAD9zb1xlH2N7ezu6ujq7O7p74otrLdXW6LDp11S+LHsiWoYZRKdhfaFVSEr1w89bDSITnFY/He3Adj7e2xjesO5hjeERLscNwbd/2Hu5TSZLgOXLgg++urh5+3YWrnh5coCQ9PV34SzzeDfT1IUBfd3cvkuph1ULwqVNculJgakWrn9qI8BQfZeiO9yAElaoPKQzIOA2pAgzC2HFwZKgHafZEiMpCyK6zbQe0kFzqMMqQnaHNnF29+InHnqfseqjcnZ2d3d0oJ32QCP+gtMiqsyu+atVL1bOXaFo+TBtDKVME6m5NDluzIZAxdB/tOWDM+8mnVMHenngfb1Wk0tvXjSTiqF0veqaPNXFne8+JE92HDn20Z8/RtWvffumldd///i/LY7UO+/QEsSpOwVoGaUSx4Z1xW4mhn1Y4u0kCjKmir"
cEnc64 += "1/3nfYuyq67pw8C0Bfv7qU+6cadjs7uju747T/9vSzP0tXEihhbFOsXwhGRzpeUVtI4JQ0SvB4NWuFBK8P1VVWPIJSiuQWt8qu2an3cDXMbXq5a9OaculdrFr/wFWsLfCJRAdnTxi1GK9whOuuUqqEFFcnLdzHgJ00DK35dC+bp4TFfnZGbGxOU2H9lzy8J/XHO0g2+hWvLG94oDINWKsFrcJEMKagJQTYsDE753CCmINIEZcxavXoN5IBpIAFCAh2EZL9z9JSul0gSbczDOA9G0LTiVavXE60gOPuAVjo62rg+MPGKb99+WJGmwM6HgKJqtmwXNAFtizo6HJF+WiFtRAzSalxT9N74+jf3amKBXXEbctGRw5/xP3Hw7NiHIkEtOzqgNvRpBSGxD2cWfEAWXV0d3d2gvMQHkXqIXjpwMX2az64X2/VSTis8zZRWU+y+TnZzyA+FPBPjJ0RI8WSfYA3YtWrJGs4a5cq1V9mN0Ni8oM0yadaM8Jtv7Gxvp6KgHFSHJMBivOQpZqRrRhAgu1defnvK1AB41oTtbCmjFUAtCv2EkFhpw4tbVvM/+bSbh2fAF5FIL7QblevtxjWn"
cEnc64 += "Fcq6J0Hi+GatSkD73f/AU1OnhjW1NMcB19tj6kGMo6LIVhj7mSVFKyThcN9eeHF9IrW+XsYmvWhklk+8tb0N31u3HQJhwVI7i36NQG6/pLSSDt4EiYagyTbFK0hum+iyyR6whqxFRksN5oSbqur/WVW/ZX7L/ora9XManvuqtNSqknmiy7CW3bAw2TJE+vzWYEA4oG+gLb7nEnf4Lildc5tGdPSYsE1pLvLdXdnwaqxlc6hlW6xxbWHo7tFyNUYqTfSYYlgTwv8GrZSq2ozVq19kmtvJgZGmN96J3+8cPYERSZKLyQinqUcXxI5ohcQWo23CKIACkzJi7O3uau/ogpguv+pmWFIYoxxmBMaUoUZBzZZs0JMPJo+q52/eepDJNFEY6VG8r7OzHcK4aeNeQ5llwscRpuzfd5Ru9qsf+0BU+U9SFaY5ffGONoqLGvRCuZIB8YF+QVFp8McY2t3bDarpae/o7M2fFVLEfEUsfHb1VoTBn9NioVxdvX2JGg3/k5sHn9SdnVXiMKthrTj02boSs4xxSdYSwTL9smXXQ3U70LpM55BdT297W/uJrm4wMqcVsix6e7vb205T7eK97e2"
cEnc64 += "MK/vin3zS8emx7orYkhzTCWaBAUg2kRKEBQ2BTNIKysyC0weaTr3APzCI8A2biLcDr29HRwdVmsi3p72NeAeEBkds5fLvCsJMUSimTVKJCZ0UrSRBN2nOaNasqrZOXhu0LoQh8aGuINbCnd6u3rjbvcjQAnzU/Hfw5aSVtCajVkt4njRFIsse6LCo+iyS36rGbNqcMWKVNuFb85a8Wtm4xb9gR6Ruf6RmYzVoRVli1WhRQ1dKDInRilSeMFjS80qDIBFAKOAXND0AFmPbpfxWsTzL1lzo+cPspnX+RRv8TTu8TTsjjWsLwveOkmfLql8TvaYY/RdphZmjzAmCtfIyk/YzaYVbK8wJok1cXk0tS9IKhIaF7yWphRBDgSGmSKetvefo0eN2E1xZRP42c+AxwAo2JqkqrJVBtELGEfwYCP7G9TsMZYZkmeHQ8w8eeI/+1NfBgPIgr25kxwFbBCVub+3gzNIFlWXjL5gF36nBOXEHBaZQpACtbd1u51wV3qVQ8PwzO1ByKjZpISkzywgWTSdX9eFj3PgAaAUVhBNkywrItog1y51rr4Ak3P6j+yjjngT/JrOjXFim1Hr4MAakSu"
cEnc64 += "FmW+sJ3jLQfxhxuPnhBx2RUIOhQuFpngVOJY12UFe5TFZnHvsMDUWJIC7RIroPWbKfKBvLhdWuFznAEEs2OyqL5uPZs47D5Yqrvp2T49ZUFxPI1KabweSCnv3Ot37HmrarJ97W00tVS1WEOive0d3X3tUdv++eJ2TRTUrEFtoZSMX6Ux4evqS00m/jsXksRis0dQof0gdrE5yi5S20aAtHifWOSd+oaHgxUv9GecseT80e78Jd1Ut3xOpXjdKXMlpxG1KpKbp1MaKcl1bYVkuiEtEDh5Y2bsNtVmOjxfAocVGR7w/lNa8HF22KLN7jbdrtatgbaVxfEPrDKHkuYmmC35CiijjIXx0W+AYKmgNSi5JzK8wASXeCaG7FCe+PCUEoSStr8ScILpSa1K+bLAVEYgY8Uxjii/i3v/NbSZopS6Xwg1gJwSywsQMpWuE5JuSbrJ4uqNCGdTvz7CW6VGyq+e8cOsbShLySTcQUAx+uId0dbKDEJaeVHsgvpZgIAF3isy0oDz7QJ9K2bpoAguYWzKowFHgTJU8/tRnal9JAKgnpAxWGEdEQYCGH+OSNJVqhtmUzoLBTxuVVWLLzly25C"
cEnc64 += "a3R2YX2pIq0tZ1ub29n9epGIbu7YOzxWsTbWpkJRi4J7JReZsh09faAVkAFZH18/FGHqc+ym3DDnTmOCtA0BqSBtEJ1R2691DVkS6I6uMOZhbgW2TCfkREcUXZ3D+zBbv6Nhmpv64HNYncUoqNpnZE9QzAAxCk0z+LQ3du2vg/Tj2XUzjKi9u9FzeiDNE939bbhz58di6O1Yeqm9Ov/h7TCOYWtJfPH1SAriltQvDatfLQ09yu2xpyp34vWPFHVsilQt9HfuNPffDC69HDpnJdrrnrl/4jNgkJzaeAUh+A1BNoHISohUT2rBShKQVUPQ2Npf4oSUrVymxjNskYu0ZoKQ/dW1r8Rrt0UadoVat7lqt0RaDkcadxYELp/tDRfVuD+gFYo7r+wwKzK5UwBAqpSsnrV60zJEx8mmlC2QbSCgRGeGpwgTivMWuG8QKEJHR1tuIPPyRNtH33SMSs/rGnFMIjsOkwVWGQRGv3UUj63wnJM0QpGfGhC/K2Ne2Hq2zWfkD3r4P6ToIDu3p5u+Os9kFM2q5oEPnzWE+VlZU6wA0uTfbiIUzakuggCbwAlx+A/aUJAk0rsuvOpJ9Zz5klU"
cEnc64 += "IA0Y8YcEzKAhYXd4TTMAVbebFfD7TD2oa2WhUFNXF02+Mo+mq7OrlQqJgnUTDYJb3jn82X33PArX4+tf++HtP77nwX88h/BUGYSGPca0nSigD85b18mTXX/6n6ckKZ9kVfaNGV1iOsrpWitIpxXGiTCFaIRgxJpoBG71dIJP2DXYDYERjOdy+tRnLG78s8/a//qXZ3gu8LOSFJAkggStOD2u+dSqiNnThkQQl3cH/8ZPTov4gV6YP/dK+NE0Q8dUbEBqaTJ5bnwpaYWtAeMiQStsf4pXl92m4RaEUtWIiMa8r1gXGpd+KzT/6drLt3rmbYC2Bxbv87XsL63dUr5kU7j2qdHaCkGuBpWYgs9hCzBaicB7ErWzPrNjE/wYxiGItD/FrBDF2BhLVLbXTvPdU974aqRha6xlT6h5h7Nmfbhlj79uf6xhU2HwgSxxPu0EF+nJIEFxWY2zrjSdDYgOC4KclHRrJaGTxBv4986RVjhBoljC5ZjmVrTiVU+/QX+OU2BSyD4mXExk+RjITX0kdPvP7jLMfDjqphYRbUHYR7IUhERqesnmLUdYjvhK0ArTsvjadQcQXrDQ8uR99z3z7HM"
cEnc64 += "bVz/z2upnXl/99LpnVm98ZvUm9r3hmafXvfzKq1BmWAEsc0qIrUSQhm986+0nn/zn06tfA12ueuqNZ59Z//TqtYiFO88+88aTj78x5dKIKhY7jLKnV61PmSqp6kMxWk93IscRIS8vDFcRXQkCFW0uh91zyaicPfs+RLOQawNbgHQP9EnmFdFKT/ymm+/IyXFasmeCeeF0WC0z7XZnUUn0tde2kD9CLUqGCjMx0OQ0FYpmmjjRJwjFOQ72AJoaIf9ULTr2GVmX7IPqICTcWGqTI0c/fPjhp1evXrPqqTXPPfvmC8+vW/vmnpMn6G8ID/MNLd/e2dZDtgblQvF74ocOHpPlGSACegaynwWSRKDQdoRf/fKPrISoXcLhoi+SDJBZoiiUWF/vqdOdjz7ygm5AeOBxQ/bYI1EsNfZzuPhS0wo3VUJkqsjwZZyiUAgnyCYFRtkqxk2/qXzRUwuWbgrOXxdp2BNq2utq2F1Y83Zg6d5Q08Y5S17+irhckOYrYqUphBy2UJJWvIJ+VrUXYXHoEVnwSTavrpZbbFFJX1js+1a0+bVwI+yU3e7arcHmLbFl2321W8N1B2L1mxmtLOS0go"
cEnc64 += "4R1DKLWTAo2fOCPHOyWfjcClsJorGFWeQklzT6sSlb2jrBtnt4YW/TAnM/rcC7gKCzWTuwAobyeG97x0mStO7ujt5O6CgMFtg74D5ZDDOfKwqG0vQyopWElUGxkEwnRrt4/M21B3TVL1nDDqNKtNEmMUWDfPO1T9oQQZtElBJdKXJ7fCTTKAWUja8LMylHIrfc9hPdnCrJU0yzSFHyUWaQoyrPMPWZhj5Nlac5DJdoyTfUQtANKwMpQEo92tu6P/rws/5tIAMBHR4StERoI7OOllFph3TR1dd8u4OsKtJflLStrY3sBZg8Hb1wahbUXgVnEE0KgpDEALkbihd8oRszTcf0d979FOYMKgVDDbQCL6az51QHvnrit956l2n6rJYyRKEniRitJFeCUBfefXC6qFkfeuiZ3JyZdmMWap1jL9SU6WNzy2yWCVdcfsPHH7eymRHqva6eTmYBghKQCpl1Y8eVmXYPZ4E09NPK+x8cQ1w+r4xsuSnUdrqVorM1Z1pnJj5F9eMnT3UYplvXEwl+iWmF7QhK7MlJbPhh4PUBibCttP1nhTi0EHwKNgsQECS3qgc0I2ITgpLmgV+TLdYaE"
cEnc64 += "2+J1T1fvniLEzzSfCTccDBYvyPQuA1+UKBpT7D+rdmN/8wSl9FeOGYFQH+QLEwVZEeLzdk+WgzW/ILmtmiuLNWdpXqsWkC1unOVkG714K+CVDFKaprovBe5kHvVtMPftC2A9Bv2Bhr2Bxp2hxp2hJpobiVbnA3xhftDz6FJfraYPaD65wWrNS6gBqVJJ4jGauKKxPAYP/LOSZgnfI6QspMhFkWgFfyJ0wrC4wNLuwu2Oz5MtnoxIveRgd3W1vHwg6tNfRYMEEn06WZYlD2yABUq43MrLAJAUzNQBsTdsH4/WEORPJocTMxKkhyTH8qKzYQb12qJy1ULFYCZzZNhhU8o8U23/FTVyhBRVODPO8n2ph6nTsc1uXKaP7GqteotxiQYt9lERl8nLf32xd89clzRZsG5YHzKveOE/Y+UJbmYJeuyWAqg4bm5IastHzKjaCGwp92MSGKhLF363tHPoKqo5ulWtAYMq1ZG3PGOrviPfnQ/24dSQmt5cgieLHofI5lsdY41A6qQX1XegpidnZ09vYjb0dH1GRE4W21Zt2Gv1TYLVYBlZBVQtRAKeeyzPlSeTAW0A9mPzHCLxx96+BVB"
cEnc64 += "mMkmSmhXBKogiZ6xueWyVDxv/pXUZLAniH9Sm1y6+ISIx7vAZik21HIwl25GrYKLGWK0qc80y6qql1KfsSlzar54L1uziz/z9Aub3nqb3wFgtnCKQeArrrzFMIoNHeRL83pw9hWNPaNPjyzyYyjQubSBkGvomfhi0ApxCtv2x1YiGKeQGcILnaQV0nwGn2rzQeINNQrbAa0PKaF6qhWSFhtlqzTGfX1e03OxhtciTZtDLftcdXtHSit2OB2Slx4kUzz0GJHuA2QjmGuEx/xX4ThzniLOuWTM/JLQPbOXrfPUrDuDVoAvLq0wMYqfPtlOE6gQ095WNk1IQ2BleQusDEizxcZyFIPQ5y1vH0rmSBFZzuegFcYsVOwLTyu8Enx+AbRCLNMXf//d48iChmUilJS4k/AgLt8HYOgh4JKv5psG9M0lqz5ZDVottFHA0J3z5i7paKcxnKpJOaBgNBmM68NH0Kr5MOJy7LRl3jKmDIJHu1HUgMMMZ4+aocnFMC4OHPiIxz1+8jMyKHrbYEK2d/SAowzTBfKCnatqUSqeWgInKI1WCOR79cUffOhFu70UNQWPkECKROvIET6XIE4+dpz"
cEnc64 += "ms+AE8RIiLi26sUJOvNRtNwLWLBIwkBcpiOJnNS0ShOl//cszXWxDAK8bs1mIRG684baf33Enc4J6E7uZ2Gw6vL6XXtwEu1iCQ40CSxiw/ZoRQqOlnoT+stAKA1/QSSEhXiwMH4IIJKysa9lpSdBV2UW7VKSApFSMlmvsl35jdv3T1Y1rq5fuCDa87a3f7m0cMa3oOu0HEyQPSBqgP8kegY4+cJt65ZhRVYJ0eYn33srGV6KLNwdbdiRpBVl8oWmFcwo8CFx3Q3FoBxeu28luhzHdF3/9tZ2yVAShTKwEibgo27otQStIhNIhgjg3rfAKUk+NgFboGT++Oj6QVtTAIGuFLWTwLbnEBe8e+VTX3HDHoOqQCl2JJREBLV7yX0UOo0K0+iAtplYh2YJ2rZrygrUisWV7teg3d/6JVI7aA3pLQzpaFem3tff84Ie/N4zUMwQ+WvtTYeAEbFZS+xx7xG5SCj++/Q+0QtZD88TwJ5EOLAtUGcgvWJCdVaJrUXr0GYnQ3Ar5G4xW6Avo7u3A/39/8Dm4Y4INLAYxoybNNefS7kTJZbcXHzjwARwrHgElbG09hXbAnePHO3RjFrWAAl"
cEnc64 += "MoYmOnEYI6wXo2a36uo+jTYygLM0PYh5sqqFp+vtfnq+K3uUjgQ7uKwDLt8YJZUSoJ7aWI0vF3ahA9knzENEUrjFMS3T0AXwxaSWOTxE0mnf20QmBimuRIyD361Wotpn3xoGopYhWrtYk3z1/8UnXj+kDN5lDDTn/DDtCKr3nXSGnFJjttMuxkalMSPtHPnj1zyYY7WyofLTQXeu6f3bQuULseFoqneShaadwZatz2xbNWaK8Hvnfu3A0562gnyYb9zhIhFYU81dRc6zAh0x5iCrSGXpKiFRg2FJxSOgutoLSs41ixmdgRrZSen1boKXDQSmKaMEkrviStsFWtVW8x/x8ffFOtcQVFO3rkY1kuoCcnpFJZdNK2CwIunKiIqfthC6NZ0MuGFswaVYLexAjBOjdMKWuF69ftQnVIx+mLPnwmGz8mTfbaTUiC32IrQ6lUPYyhGzpmOsrxEzYIutU0A7l5AaerzumuLXXOd3lqXM5yt6vCWVbl9dbn5JA/kpdbBeOXWkObdex4J5qPCIJlSbmyHvz7357LtZeBx2Fl2OgwjZAt2wdCHJsblYTJoH22Kba7raOVdzptlu2Ow5ZUl"
cEnc64 += "Jlf+cqUHEcMnGLYyX632Wh/o6IULm65jlWJ2qq9PTEh1d3Tt2PHIU2dYujTPvmkDT9xM7UTD4HhJX/7W79Q1QK0G5jU0Cll6hSSQ66VXBmZtn6BaYV7PclSErjXw2mFVyAxQQvAPIFASBKdvaYYPosSFPQFuZOujjW+GKlbW96yx1+7x12zq/yyw67araGWPSOmFdUlabCT/TCLJJsf456pxdC+l8i+UdL8Qv/dsUVrAnUb2f6UHa7G7f7G3ZxZvvC0wn2H3sceferxR5+DOMMGZkRD682MNeJ7d3+anTUdNGrqIXoASi/a8nZibmUktEL9Rd+4Pjet3HzHULRCFuJZaIUUkTwU1gLd3b0ff/SZoUNDSEkMbUY6dHW6YJ2Ib1zn2AtNvUCwTB+X65c1D5miyEhyTpkSOn2ayoUE+YQIzwUpf/jhKXhA2VmzrIITwqDqQUHyQcF0MwqnINtaZjeqLNluq4VOS8AIl5sbkaRSq7XQrrlMrQz+kc1aCLMXVUCAMZZ8snq0GXBnBtEK7Z3vi//j78+LtinoNfhlYEOQoCS4ch1hWSj49a/+hIIhdGcXuTCcXlvbYFLFa2pX5uS4"
cEnc64 += "GXm5LDan3U5cSZ2iulRp1nPPvYGWT9in8LSYHHR09v38jj8YWj7w5z89ScvnYCg+44bUeyEk8c2b9+XlFItCoWhz0TKFRGTK9ZGBqWp/dycENYUvDq0ACVohLeLop5UUp9BxB3DzwCwkiEYgWw5cIlTlTb81Ov/Ripa3A4u2QKtDzYcji98pmvtWxbLDgbqdI6UVCzx8gzaq0oqPEjGUSkGIZlsjo7S6wvBvy5teCtRtCLbs8rfsLlu0LbB431loZesXjVagjfjV0dH1zNMvuVwxuER8U2tbG21Lx1/xDwGvv+5nDt0NlaAHedVZm7bsp8gsO0qHfpydVoB+WmFPQpyXVtgjv2fQCi09oNGStFK2atVmVgtoI/yLjoSFRXOlpAZDopM9hIg4AJyF1layyMaNLUJ7IjtdCyJHr68GiTD3ELYArbN0dJCpgmSfffZ1wyjOy4lBNnQQh+AElfBzBbOtpYadnslEh6Lw8JpBHNnZhVBvkiVLmWQtyTVBDbQMhACa5tXt9KzWkLRCFYnHH3rwWbs5gz2iNRNsju4rK5lbv+iap558HQFPnj7Fuw+Bu3q6T7fS1NJbm46AU8BlFks"
cEnc64 += "J2gpdIIq05QSmiq45J030nDrFKZK3FeVHzd8Xj4TqQXy5ds+8OZfjJw0urDysHehz4kRnwL8AEkUnNDPXjw4Dp35J9E6io7/wtEKUgSJyQkkddJBGK+Qi8W1v7Gz0gKiEbHLUps3PnXaLp+rxBcv2uOZvCjcfCDUfCrQcKq19O7Jkn2v+lvLmgyOmFclNtMJYnzxzMTYmu0I2m2Z47i1vfCXcuDG8ZI+vZW9xzTbk5a/bPxSt7PgC0kpiXbYvvublDYo88Q/3PUSCRn/Bp7enl7Z7Yij76MNuXSlwGJAnFwzsDZt28TBIhKUDyT4nrRD+BVqhXmCJDKKVUBqtICLRCmrNr6k6Z/8kH1NKbM/pgh/RFZ8xzUXHCWs0qQnzYcHCFTD/2ZwlTBViFhaRZpoeefh5UZyF4Rq6KkluwwiCNeDyyDL9RPFs1vy8XNSUFtQlsdCSPcM0y9Dsdt2Za3fJwizc1zS/3YxccsksiY5oS1krtKZDjYncYE30tOMSJAgWQPuircCAfNUHFIefrPm7O7voEaQutv0H4Tdu2DdxInIvQ/FgqsAJArtx90dVnIZaev11t7OYHcgIfMGW9inukS"
cEnc64 += "PHxo5Fm5eZhhcXJ0+yBGEKddNeZ8qKpld67vz1A6ZWhKGFdn4q9D4JKEs/raQ4BZ5df78n8EWiFVwPQStoOEKKU3TZbbH6ZaVcViutYnXOpSsj8x4BpwQW7As27oOeu+tJ4YNL9gabdkYb90YWHRg5rXhVMwQLmR5vV8MWW1TUG4q8P6xqWBer3xxq3l26aIenZV9o2RF37Z5Q3Tv+xr0DaWX3F5NWeKyuzr4N63bK0qXTpnohUp2k59z0JdWCp93THf/5z/6siDN1Dc7mjPVv7WSkQJ/z0Qp6ipeZVhAStKI4h0ErAUYrNN4i1tlopaeni9eXA9d8RgCFYhj8QRhoLEwb0CUUhjby9sanT3UqupsWg+Dt2oquuPK2ZPU7emgBKPHcIALfd+/fdY1OHoAlQgcS6z5BKBXFsmXLfvL44zsee2z7k09ueOSRNx57bC3w5FPrnlq1/vEn3njs8ddhXzzy8EtPPv7GQw+9QbHIjwhpBm0vTKMVxoxoAmoZKiH5mDRnfBp/gtHU1UfPW+IOrnup6cCMrPp98GJ6H3vsOba1h85kQRPpWnh0Fh3SDEkGEUhiCbpm44YD4JK+ONsuj"
cEnc64 += "FYimoKj1/P3vz+paYWSUKbK6N9Za9ZsTJ8MRpOytTbaVSwJU2n/kRoQBb+ukrIkmSVFK6n9BAPwhaAVNrIlWJCBLyRD/YgmyTvV/FAYNJbD7oW/x/anRCxyrTb+pvJFL1Q0bfEs3BJq2u+lB/x2B+oPheqOQttD9fuh3oGmzeGGA2fQyvNZ4hK+QMCOmIVY++E5k3pIAcPizlWDqlgqay6LEhwl104r/d3cpo2hxs00YwLWaNgfqD9AoC0q4JQv1twKAmNEVdkuW/yJlAmg/VMQTRoPN2/eo6sz4Mnf8bP7YCDDisFNPipCiPH96acd06a6HarHVAufWfUG/sAWoUns+JIk/m1YvxfMBVpB7Rit0DaihLRRsdl4QD+HQytncYIScyuJlSCKwfbXpowUmPf8DkPqw36S9UHPN/MHfFpbT2GcR0WmTUG3lllF2jSoG64bbryDHlamsnRyWkGytD2sK/7fDzxBT2DSIcQBiZ5TDxqGPztr+s/u+G+k3s5qgwKgLNBdUmDyyBjNsdLhdldXXFHyadxKEq6sFH7yKfkkyJLAPriCXtMDR8xlY0qO6PQ8NyWEOx1sKacnfvxYxx/u"
cEnc64 += "/mthQUBTpqlKic1SluuYI1gDikqzqpAxlJOtIhUWF8VYWejDeJMfg0Adt3LFrYIwXZZK7abPZpv24x/9rr2DKIwCICh9kDOtZFXPaSECkkpJgNkmSaaqnFMYoST6ejC+ILRCIpjklH5A4bOzYKqFSdoUt90exKAB11HSKrKEaiVn5bymF8IL1sRgGjTt99XvA6f4mcKH6g6F8F1Pzoi/aevZaAUEDI8R/UHHpkOOFb+m0FTZeC2S9V+FeegwufL/WKpLwr+bt/TN4Px1jFNS3AFCSeDLQisQl17SnPjWrQdMvWBcrldXp3/4YSvufHb8JL7pgR52BgdU5YH7H1ZsBXatYM3Lm6AnzI8gKWcaTWl9/rTC+YLisepTCqw0xCADmCXBKYwKu9s7TvHhF+FwA7QCayXbVgyXQZKLV179PUYKCElROrpaE4n3oQUeN3QXaMWS7aanuq1ONG9urucXv3oATIQWYBvzuvHNotOHhnpiOlyiZD1n0EpAVoqTtEJtyIvLZ3Oo3EiInYTCDBby4HgWfKa2s72r/XT37+96YPKkkonjnaJQYOp0/LskhEArZHcrftAKTbebZT/9yT2095f"
cEnc64 += "PsrNPZ3cHioSkFWXc1GkB8AU4ZfwE58yZbioJzLTONlYGmsVnW+/iD/7jGZttCm3P08KUy5eLViBDTG04mDgywE7BEAHx4saLlY6P9EtqOFus1cdeM7f+meiCV+cuOeBZsB1s4m0EoRziRgTZKeSJkKr7m7adjVboWUGBjBS2P4Vtu4Dyix6HFMhRq8eMqrIoSwv9d5c3vUTnpzTDSKE0EyCbhZFL/YEvl7UCsTl86FPJBh/Hqesly1d8B149gjFJIoHGaNndAw2JF+fPnjC29O9/fYoNn5QOVwCe4+dPK1A6FpdVh33QAtAaFGZIIH1+AY8CRICyd3XGC/LDRCvWUjoDxVa0ZOlNSIGtlSRoJZF4H5TqOTSRZPObapWhVIJfDM0HE+/HP/4NKnGq7Vh394l4HKrY1sOUnz8bAVCZ0Jyg4sG0EpKVkjRaSRhfsHIQnl1Q84DZ4Qr1kGfU3dF9Gs4pwCdWEK2jtefw4WNlpZXoQWIQo1yVo5oSE6WgoUcEmwfejWEU79v3AVKjNmBNRFMrtNQFR4+GDXQu3wF46hQVGYRCe2dgsqTTNE3c9pr2AnArpBdZMFphFTknpwBfEF"
cEnc64 += "rhLg+uE4TCQQ+V50StgpMOZIL3KARt2pwsqVrKvX7h4n+W175a2bDDv3B3uOlwWe0ub/M+5vvAToHvA82njSSExp1noxWbGLFJIUULqXpAVFwkxPDtRb+uhARbdbZ1SaHn/qqWtb669XCvPE17QV7+RkYZDTsYdlNeXx5agexi9INsHnnnuMNOE9KG7tGN0r17PoACYJzkjj3FgOHd3vPCs5uyR9uffXoN2ef0IRnFaMxz/E/RCovOpJ8pTFtr16pVrxCeWrPqqddWPfUGAy5e++cLG594/JVnnn7zuWfXPf/cxuef3fzEY2vH5brh2yI7jO2iWFJTe3VrK+MRcg/BLFQ7ZNTbE39r435YBJAHVSwHrFluu+YbP9Z1++13MuUElZzu7T3FyKWju6uVnzsBIB1Ulh6u7AatzDyDVqjPErTCuAyBW9tOsKhx+CMdnTQLxCrZB9+EnZIHXufHyqDLwRHxd4+enjjOl+MI0PHJSpiDmxLoU5+/BvyA9FlD0Z5aNheLazKC2jrIPkWP8OGEub0oET3QlPQuE7HQvA2N10BU4G2ZeiVLn/dpOq3wqg3AF4NWSG1SRUws+tBeLNVrt"
cEnc64 += "RbjTxbJb9OrBXPRKLHeful1sbrngzUvzV2207dgS6TxYHTxO+6Gnb7mXWw+5QCfMYWRwjkFRHA2WhGkmKRGZZX2R4liGSTY0GNg5WxbNEtYVOS7N1b7aqCO1n08Tbud4I4GmkwhNknQCpEI45ovDa2w+UsSSlkqRqmsljJo9aK6a5gUAjRZ2NoKRwC/ECU+p7rhr395hMScZlXov/8grfBSQbsoFcTGINwd//ij47DnUXeE0VTa6p4C2zFcAgi2fEksksSSHHso1xFGe9KbCSV6LMDlWshXP6De3EBA8VgWNFbLMhyNoGyLOPTZmhwWrGWaXHj7j38Paw4jPE2edMK66epoP0k80tOBVGj/+whppbObtuQ/++wr4dDChQuuqKpeHC2vW7Ls2scfexF1RF5tHe0oFXQe3UR90Rdvb4//8ud/0pUSOoRY8msqPR9gtXhyHDHU9w/3P4IEMUhw749iQVC6O9H7jL+4n5UCd7KoWxG4lZ6K4mYUsow/+8wbdBaP6OaP4FEtqE9TtEIKy6o2AF8oWuGcwmiFrcjomhvazs9PGSXO+arQZJ/8ndD8R8sXbwk3bvLXbq5ceiDcuMe5"
cEnc64 += "YGv5sgO0+FK/n82ncN+HOIUp+f5z0Ar8IFH20jmgmp/2UIqRbEtsjNJSHLy7svGV4KINoWa2P6V2h38x87BAK/V7w/W7w/XkCiFBmtD5ktAKd9Rx54OPOi3ZM2n357jZcAegdWte3QEZYg/dk2yRAvd1nTrZte3t3b+96x52hyYOUqMZEvlPTNlSJOawUI1QFtDK0SMf0ym//Y+qchEisB39fmg1tAJ2qKmHxlxSjOFdVn2gFWSElO32YvAkMRQd1k1qllyWppulpfMUuQwhRcELF0O0uZDXz3/+N1SnjU5WQSCm5+RWtLO+4O4GmmcEThCt7PbGH33kRdE6TbAV0PKwTlU2tZIffv8eflQKgJQ7OsiMwgc3TxyP0yPO1nzUjqYF1RCky24PiuKMDz6G1UmPJrG2YrVhfhBvt9bWUzBYmB1EYIvrVGs6kornxFqDV+fkyb7c3DJwsWglUSRQnzJa4b1MnlHyT0l8cZwgXPTTCnGK7MaIStO0ko98H6VByrsxMHdVzWX0XHKweW90yT5/ww5f7duRpr1uMEszW/dJ832g3oxoDpzVCbIRrZDCyy7DHhbk8BhLVDHrpnnvjzW"
cEnc64 += "9Gm7cGFm8K9iyq2zhVr4/hXHK/nAdA+MvOEfuFiT75aAVDIx8yvbg4U/HT8D45s22uuAA2o2Q11eDFDu62kkVQCk9vX3saELo7aGDRykJsr0p0/+4tcJUhR9BgPrHj75zjLaZJR/bYfli/CQINpckwtGj5wxRWdOIAiBTempOCcgSTdsJwvR163ZQYdiTlwBbzSHDANW94+f/I4mFkuqkF7wzdoAC22wlolSUk+NWpQK7USjYxtbWLkHEbjpRHyVixWQNNswpW3796MNrYFKBuWAXyAK94AERwTKbNr6DEAhwqvU4MuHPCra3d6Il586+zDTLaB8ArAmMxDQR6Zo7jx53BqlRd6MUiInke/voNCr2oQzpQ1JBAZLFQIsiWGc72Vx0zF3S0rl6xfdg5TFr5czJWj6Pi4sB+ELRCokCDTLs/BT2PpcSUg8jNlqoNCdeG6t9cv6St8ILN3gbDgVaDnvqdrlrt8Za9tLmlLq9wYV7A02b/U1byf0hO4LsFOKUukPnoBVDq4Dk0d5EPWixhSR9Yan3O9Gmt8KNm0PNO1yLtgSadsWWHPTV7Akvgoe1F4QSWXSA9sKwXXCelm3uxZ"
cEnc64 += "u/RE4QAOk/fOS4YbrBKTRdbQREq8c0S/724GM99Mg+0o2fOgGrvgM80tlJd/h32ofS+g/RCp9eZadAsoMR3jv6mawUMpC0IAo1NYOu00PMVmspuMBuRrLGFOOvhkFPzYmyH16DaYbgQP3kJ78lReqjZTBkwEf1ri7yFg8cPAG9FdVCQS6GPWsTvZoeM41ycBMZCKLHVJ1gljff2A6qIOWlCVcwcqKiZ9DK0AvMXT3tiPvwgy+DIOBq2bVqWzbaMwxNNnX/5ctuQYnA+KCJ063H0C9sipcY/4c/+J0m52P01RR61Jv2whmux594o7MXRinCd/BBAnxBlEF1pLVzzirgC4CvYeObbhIRdpPnQ93bSyMQeV7xN17bA/+RHnpEFf6DtALpH9H5KeARQwpKNmbIyR6bCNshZrUFaGotsT/lxlj9s5HF60trt3hbDjE1JrDlGAKb7+j/ORi124JN28OX7XHX7/bX74vVb5td9/xocbEizNVkjGBeSHaWLZhtXn6p5/7o4re41UMcwTEotTNwsWmFz8ZRe9LpcJxW6AOBQMczVzl++B06dFKGxa6WojpEK4pz1eoNTFr4vCB9SFDif"
cEnc64 += "UePHoeiQmr5KXAY1XXdM3NmORn2TK/omVemIwRSFwbKmAEyRzOae1VpFm3wl2jkh3gxOiAeSdkOVGbZ63HWQTFQTqRIYPvu8Btp33rTHYZShmBoH0RhdkRCPAY8wQyKXL0BUaBL7MM2pKNWHfF3j5xICnpS3DnQdKnrQdDJ+mBv2KBN7tWzl6Et0S5cx/BJ2GUd8Z7O+Pe+dYeiTpekfNoPYg1rYpVdnWsd46fHxOTCHHthNLKQ6sK6A64DtRlrIjQ1lBpqjxZABZGXKpZjpPz0UzrQgBMr2phATR1/5MGXDbWYzr6ih9Go03UtarGUTJ4chWmCJGnulhiZiof+aG3reOSxl+wmPfGoKXQAnSQXjRvvPNlKW/GJ3froKQfG5vju/eCDk88+vfHxx9etXr3pyVXrn1y97plnN+Hnc8/tfPKxt1Y9uY4924z+pRekpKwYNAust8L8mKHSk5ywoeiN5jK9ngH9gm6i5/LSZJXj4tDKCM9PMeWQbbTLrtO7itH68EcsNreslEtaLEuYo+R8bV7Tc8GalyLNW+H7uBNTpCOglVjLfn/DdnossG4XdL6icevcluez1KWqOhdtRMOj"
cEnc64 += "HLEqNdNdv4i2rPE2vDmAU74otEImMaOVAYdOQrOStNI2clrxI2UUyTTCdKqebdpvfvu/be2UbBt/VQWpSAqUWQIjppXaJK0gd/hXSVrpZbSCAstkXCB8glaYhJxBK+spCdJ8gKwVlAMs8/GHpxPHOKUAG4oBzTUkLEIBaCU3N4ZCkt8hTdm0aS9Vi9qnr7X1FMuCKo3/O1r7ampXqmoBRmy7HrWM9ili2FCj9CpLs2jSpc733z+B1oDrdOrUCd4+56OVNkYrrEeoNgjNaeVF0AqGZF2lXQ7oGrIBVR/qvnf/R4zVuxMHo7BnlxBt546jNms+P6sBHpAo5X/92h+daqMTKll18I2u76Q5tb74r375R1MvyHGgneHE5etmMR3lp9JRDHbdqUjTVz35ChWeXKfEkhAMQ1YhbhYVkjFFG7sqJCGEsqF3FB0cPYQ8XyRaYSBOSQMzzpkxz4aRRGAylWGnoJ+SVha94keUgrJcMUaq1fO+Maf+BdqfsnSPdwE9Ruhv4Au6g3X7HIg1H/TUboc7E2jaF27cU974VnXj0/8lNihalSDBLKrQ9OaZJXeUL3qhctkmb+PGfkIZBqcAF59"
cEnc64 += "WyL8gslYL0l8/ho5ncgNwWiljtFKi0gVohd4ThD9hvOFmM5czKPbRo58yj8nLC0aHNkluw3SNn+A8caKX5giROvM1GLgmp0DpMFrZP4BWEtu6h6IV10IiM5Z1klZo4obRyk8H0grtS2RgTzAnHjVkB2iuXktJkA2PitP2WRQDCnz6VMfjT740EC9zPPnE0Fh5zS9FpUwQnA5HBKoCP2X5ylvJI2A7d1Dlzq7WNlrc6aXFk+74iVPxlsXfkKSZhu4yNB89Xqx7wEeR8ILt2+nxbpAd90Y7OjoSDsXQtBJT5OJPPkvRCsJAj1Edsrwefgi0Uki0wl82wjodfpwsFzzy2D9ZP7K+7qP3NMFDofOA++KmgfE4CiUHrUjKrNde39XeBdJlRaAPfBnW1H3x6solKDMduaCCreD405t2JXrdggsmDxhtxfLbujpp7pmyYmC0Qgy1e9d7hkYn1yG63ayQxTAVj7E/kBLUFC4OraSxSeImSRsZJglaIRCh8PkUeKq59gqaYGNnHWQLZbJaYRWrxdwb5i9+JVb7ZkXDrsDC7dHmfd6abcHGPYO0ehjY7160M7z4YLB5f7B+e7Thzerm1f"
cEnc64 += "8lN1uU6mxpnqxfll9615y61ysbtnprNwZbtp0R/Ty4+LQCkwr6OSStoOPTaEUhWWG0UnYGrZCgDEErskfVolmWUocjAM257dZfkOvPskjSCkdC1DhGSCvzGa2wXZ4EmELptFLMaIXqyJ6+RyIE1DqNVvKJVlAO0lrUBVVuZ5UiswW1GhLM4xoCP7vjQTSR1VpsmiEY9nbTLYiTd+7+oKOz+1Tr6e5e0nm+5Z9XnF7R0Rffu/f9H/7grqVLrr982c3f++5vnn9uI9r25CmaFsFFW0d7eye9J4w1Hb6GohWaB0jQCjqCh2HtTD348EMvMFopoXcYSW50DepOk01K4Y9u/z1ajW3Vo7lq1gUUHTbg7NnLRZsT1o0ols0qjIEBkRxSIyBp9i5aXKPwqjxj3NiIJasEHJTjiGVb0eMhm60MFCZYy+ymx9Rn8ccOU92NpkZR0SyoUTCwEBauaCtlPRXiBzOyIyMGiytwkWiFez2MUxihwAZhXg+nlQShcM8I4PNqCAMGlXWvai/PkmbTM4T1LwRq1sxeus+7YHukcX/54gOBum2R4VkQA9B4wFdPTyF6F+0KLNpS0bx2ztLnv6Jf+"
cEnc64 += "RVhwWht6fTS31TXvT6ncVd40R7YMoHmEaf/edAKhJIOT/s3rRUKn0YrNO9IjoZOL5/HBe1VV2cdOnisrZXvQOeEwpEgFAZaVe2nFZoZIVE7O63MS6MVPrdyTlphSQ2mlaffQBSa92G0wlSRaAWA/ozoc98fnhWlIoxh8P6ysopgehhGaX5+ZUfyceH2ThBfV1v7CZYXxv7O1vbTnd00iZsCQqbunDrddvTd91N/OhutsNlNopVuKjxKTpqf6kHQCoyydFqBwsNaEYWCpuZriSiRJ5tGpcRZrM6u+C03/RJGhCyVou9u/fYvOnsStEKWF0KgBLQHMn7vvX9VFHoFIoya7KwyOzvtgWaXNBrXwRGSUAar7aUXN8JHQzw2I466I5VO9jxB/He//bMsz2JTOTCm0Dv0wiykwJbqB0vsxaMVIEEr3FIaSCspTqHzU9gcO218BPNZJP8osTp38k2ReY9ULN4Ubtjqq91evvSdQNMe58LNlUv3hxt2DNJq4Nxuka9pH5gl2HDQV7Mz2rSjsmVdpP7Z/9e2/BLjmqneu8vrX4KdEq3dF6k/HGk8lOCFBAYnNSQ+V2slMbfCBJIEiAQU"
cEnc64 += "VyOesk2zVqwCvRzLATbPKsLQ/bWV9JhMRzvo40xCAegzFK1wK+MctAJGo9nEpCGQopUznKB+WqHDaNncCntNPakWCLWb1SjxTenBXiAM+vD9Y0N8fvTjP9sdNLwjR7sZQQvk5YVFoXDF8ltoIphN31JW8e4O4hfaQ4gCgw27uk/hootO5sd9hKDH81Cq7p744iVXoKk7e/ta2evH8MehaCVGC8yf0UseqdiJfkxMusMJQjXRfUQrInQhCCve0EPo1ilT/VRBFIXtQ2FHQ3afbj2OW4hlsUwDLSLu5m37kTRopaevFyYGQjJaQY3jsegih6NMsJbYzRiSFWWvRSgRJE9OXlVWtlcU/CALQ3cuXnI9M1dQeHhZRCuskekYuiNHjhlGIQwW6hGJuoaW7WUvLSYOFFfgIlsrSY29Y3Bm3RMHGD0xJskTJxPbtm07EycTTmzbtm3btm3b9kQ773+3dqt2v+yt6k/n9D3Vt91163fkOF/eKCnSDGJgHPmUg1SzSo69eBlclvxNPHjg2EPSn8XQew7MV08qN35abU89l+DisghOcB7hNu6bbw6Zk9aa2RzF89r6f7DOeC11Wlut5Rj"
cEnc64 += "SWlakWD/ReVIr+RDM2y52+CJ2yxYkGTBOnEhQl1Fqg/HJUEjWYFa15vkpmPOthd1aKaLP5zBYa7gqXQ4mWserRWaenlYqtQqdYktk00yudl9RbAQNSfj6YRLCFCYUormjvtaaB7HE+mlilYLNjSsoN4ObkQ6aBRVbaRIN0oyNpJymp/ze/Q0Cnv32tnXzU71JKaNq1CCGCC5jybphvs2Ck7OoKaL62kBqZ3tO9F1htcD9EsdUycNlxtwXVh4RWsjpIe6jD0odLSmwVSpAU2NFITHPrOjwYMYMHMZf4a0MH9XJLdasKHUOlqV/oBCALjhr8LJhpYyI+wqydIK/nDboPnp6EMOFa+q3paujpDX1aeC+4UTfGiO0kK6oN7MnPGJikk6C7od8SqpwakabiyVYcRjfFLuEXgvTd3dwDG24t2pnQh7GcCY8Iasicc7oTkyUJeLSNMU1wWLejf7Zbz5Ehkg4g5GgZssLUWWLVJqj7LhGK2WgGG6h5dRcNc9oJyo6heqAcQNPsyruMZOO2HH+nNzvplnPvwoftYVfurdxAmX+1GZuEtLj1tODuDx+fV+81Ze+Qq29LPf8xbnZSLrYyr"
cEnc64 += "laSznbGvDcTMOFW84LnxFk/0Y0D6sHsw83CfHIKZL6zePZmqD2I76DPxavIGnqFRUYI0Tan5CKy2tP1IYiAmgYW2TNddJSUPhM19H4tQS2dkQU5KrjAfPBbr4UlJvUQMugzKVyQVLlilllJXFJTUjsl5gGO0wT8bWPbBsQYCoS/PFxn/K9+3unn1igzikKfd3sPV4hNuFAZAsJnw8SPFBJLJyCXNvDNAGb5aQfKQjsKl5aKMN9PykpAv49UV5+dqJ4DCqPjAuuatQEv4G4nhKTmh/tn5Oq6ZJpKWami8X0CGmZPar651eprMB9vY74KCzYmQq6cSmiaMGIael9ryMZm5xnuXymZcpIpbEzm/SO7zi88Mb0+jCysJhrqFNbC2F6IYjFsuSIOvqZmJEuCt3wgNbx3Z9STw7nqbJ1xyNERLKNPw1/f8VgmGAB0ZuNudeKdZmgT736wIfQWika/Y8lYLHSyGUUoCvTgjn4RZfHIVgTSemVRnbQy7RRLddhuUnnGzcWZE5KXv818PPT8nfsNj8Llyhv13R8PukIPktSojXXLyo28MxXMco3ACp0fKGPXbLcoPIPcki/ArBDmylSm"
cEnc64 += "JX42OnYqkAwf8swG6Pe52g9kaFmQQju5lclfPi57ETo2Y9FZmZSbNoHDkLnWKe9XT7YDHyKYbZu6lDYbc2hfR9q4EoKzioycHw8omjQwiouREK7cP14afvtUgJsxH/8Mj3F5OVvMLl4x+yAD0DkIlHiKJikBCapBEDKNY1sdJSRUAycOSuRkdh/IvTsb6yuUnt4WgECOYBKcNp4sPL5+a2K2SU5eQuFKKcBlS8BFXO3djNdM1rWYRiRpr/bCJLbOJf8p35P0TEh1Jj3BmU6fbL7/N0bwaNge9iUEFU0TAc1UcaZ5ZqFTf/MIq6KOK/282E0nSzSbu6Goi28jaT/gSGqmug521UsptKGm4iQkFdF612e5E+Y57zMzVKygOFzmrditez5mEXhaq4eClFBC+aVt4JGFdTkpJ43VDrHtX9lHTqIPpR63/P9579/9uwTpaSdgTVk4X5+fmh82B067JmamgBHgmxI1ADeEiIPEa7OpRFdWpEpORuIJama1vsQio1YM5sYuP7Hu4N+zDpX/L5ZYaWyaLk9ojnYNWJJubORtWn5OHMf2KwcppKzod7+lXzZjt3314szwNnHB5ArLSx7"
cEnc64 += "ZA1u6YndGq9wKSB2H4ioMwAD23Qp7G/rv3s5qft3u5Oav591HirP9lbcIxbAq+ooln4yPFSMJhwT1Q4B1EF80FCFczRqL5QBHsHUc/U5yqAV3qldGHdsyUtHEvUvXJC9qgGhUS9/a6ZVnqeU/xWRxLoZzSqzWMgDL84qBje/lo0Wmj79tK41NUDRHrd3IDb+U1o0VlBCThrHEazFTLYWCHPbaC6RK4n7iizHAQwIzxKSq+bH+erpGs3WTrWeYr1cAKIVpVNVMAPskquVJWnWisyISITEM+u8TsF4fYW5xUeio/J44nWsSoMgnJsdUJjN95RzGIl8R+sbHgT7Rudm087rV+RO1qkr1xoTEn5qLoY7GSVvMH9P73wcLaW0XLm+n5Ljz23wca2b691k1PR8ng7MsLN5EdPP0PrmHdZ3bvoucan+IKdcJxH9WTOKGqfo/Fz06OxSoYw+UI+ZYKXbAdo+KT5+QAbMe3dMaEdKnk6trIsPPJ997StWIcrl0TS42VbzlxBJLKa4J5HMTDWir71YuPqrIombcZBq0iDjH8dq9NfK0/Ivy1Sq/7bBlgitkcWCjBfKIAgiIiQICz1moER"
cEnc64 += "g9LuzNsA9JZW3pN+wgC2ELxqbVzU+Ih6BlRZUKiE2iRUm0/K0ei5lUoQTlAl5NSMVci9/FpY87nAmcAU88/MjkcvrsskBOzuMxtPked7r8iMRfHsY3Lik9kE5VT2eg39og6cSsOvXWL+1U7+i3YMjmUT/Vms6VAagln9Dx5Oygy1B06DThxJDCFDm/i8WpLqbLJvVkATa46KpSfsZJKabpm3JBaSaJ5tpEQ4iHnQOVE5jyzY85hLC98cSRvJjep8lAaW6t3SpJphlGkKBwWQuv2T8vUjuyvGn2QoRjAPto7ECjMEfmRTclyjFkYXD6FLA2txIw5mU4yIe7M2DUEgDqxhNHRXd0xb89lweKZKLNUotTRAZsLOa9QxdXG1DICWTFmF6AdyHa+LRvlOiBRWXE9N0YjrYfqvXJSy9bQS5dMT+U2qBEH16+sL1K6dl0FwVqo15GWZcAViLulp2KREmRZiqbAL1FnXFk4tLWM4BiHfqpFzlaiubnM+h+nba9VLDx2IjxwARu+DqlN4RkYYFyD+v2PnyyoaP3t6MmUbJA2Vxg0KvDadAwVwXzpPjeZhWCQurP4APOA35WjWznqAfjI"
cEnc64 += "1UQJk4HuOViIbhE0jVOfNyXWUnKgkRmmRRd5zv0hogFYk66SkwGEXWnnEWDmR3K3c5WFCabU3NvVVyCdz/UgUhByG5eHxG9JEDF1kBiRuODu8RmgNqHOS5sGGBlf8vdDu8uaB2ERdXUIQI9eZRnxN/CchvXn7Sk+SgCD2qml/Kc61Leg/OpW8KmrSJHwSe+FxpMJlC63JIP+qNSMWLnw8hmi4D+/bNV/XqLg/aJrRPaG1yHJbOBAbewTmD5mA1hfVavahjnToUg/wm4qfYS1ApcxlJx8rK6SqaYp/fJbylk9lHFE3YjYoFmeMul3oeFeDBtKuGoIfV6KTtpjbx+f0FswgG2eYQ1vrxQqGhwcIRInHUy+oO7jFzMSlfG+pLNiDiVQqFH5z9uUeQcZQ6OXZnYiYyZmgo8cOt6xJvNShQrFRDucdh6kxxUkYFi49U1+uHjPGe4TzMIpLIuzD/WQ5i+j4eTCrnsShjLEcqYBivqjZ8sNYKIXXKDFpXjMt7Xmwux5ixpZwj7/s1GM7mXLA2jAjyzVROg9QfLfyXmApRK43mUDC6CFFnlvm2FCFYPY5BItahYQOQe5KAp6DyEutUU"
cEnc64 += "CVhSrMXiRQOYG2IfYRJOPtuhhXI7sTfOsA0TLyGIjo+QTnDWMFatpmMNuowKTlfnVIVQqJmdLfwpyRljNBrG2Cm8QoLcqkJDb6OfuWLq6gyvghf9PQOkttbqzxLUEsXB03kfxfnWl6g3MrRKNTQQKklSfM3t/83P//R0G5/ygndxrX2rVqhuY3xGKHL5x9nGuX9D2D11SPCVRFWbF+4F9krPFxIh3lIjYmP2ZnHEvW6ac1pZXt91X14wlfxS2eUB2esaTx27IRbZiWzXZ05AB0UgwPe8FSRY+xUqxDmKNC91zmIQsBwdZ0weJ8JJCvKBqJZSzqvCDPU3sFIAWUUQXPFKhjNPN5mkiQVr7O/GA2NvsB75ZQG3r2xzM8PCT7s/vBINA57EIhsUEdsKQLVUAgGHwys0+xSi4AiFQEGioCCHEL7mbZ19DJhftrSThyizj34VfJQOPyR4zxPYg3uMeTE8/yzKjmDEA3xOEnI/ZwU0/J63NZQnDvub2KmFULr3MsNTmmrWtJeSyZEmKfySv3AftZG1VpKQcWZzcVYMxDpy6ehrCwGLeM49rOkOItJ7McubNjjw/24nZ8MVkHQHDYF"
cEnc64 += "vL0gscCSXdQ1+A3HZK3+3TGmw+WwVWqaW5uqkViKRoN+m0pY8g8ZQvdRDZLzviAaMRgUVJ7l9cXdx+5xgkNQdKJJRnj412H5w2j+uf4G3z/2pMBn+FyXWYxS6HLf/Tyl2kXjuG0bbmiMJDWOEgYtzpM3yjpSmxBs9oYH5ecQHBdODKsoWm4IUZOGEgXXPyKFHCYayuWUcn1NFQYul+ExVOqZ1Vpzit4mHkf3y+VoI2sNoiIUNILjoYZehFVJnTzuJUAVuE8qoVw09+11slc01niTvZqhojw0JTgqxrOnLAZ2M3HcM5BKtCWbOk6Dz3wQ9Ar2jf0xPO2sLMBvEljK35cC80iUoLwG8CErVX3+DBKDCwIbObnntfQQYbrzMhUgkFn20FH+HGD/MjDYKxyWYG5Dg1kNBMg0E14tcDe4FRmZC/4IgtcO3G8UsE7RlucqEhE2gGCGYqzvhiLwJA5BMtTqW545DtC0lR2GjmQ6qOns2wvN05ecPZjT4UTOTmD6C9xTZGUArOfISKhwVgTqSpsGChrMCk89aovq+MbrE8d+A9j8wudl0LsBFvKP0WLNMJT8+b1n0oiYP/+kzYenYsc"
cEnc64 += "Flharr4pQnQfCLJnxumowWIx6S1oLBJ33XUrxFQXxCXHaoUraOQQ7C9Wn8K5H/dik4CpOSSUNjQZ5UhZHEvBRdmDE4W4GC6rTHO/Nfi2Wgdrf5xRsPS1B209syMlR0uogXe3kbn8VqPVOqXHm5ucnrccchxGVfeWjlJPM/HbmsxWCYb1CYL+Bo3NrsR8aC0/CO5roKFBvTqnh0XR7GmEw0BjturyFEDKsR08rLmLG1bHSGpueDsnM4yUU3oUGn+48RB2MJRAjCDWzcGWcRa0Fh49iNLqXrFe1TyJsiuXfipzfcAP0LIlN+JWLOTRKoN+DsvoC+xNHp8oG8UrTZPNRq0DSZ4ykpyUVXOuXipQWFLNN7ISMVbNOfc3BJI3LewNAvIg1Q/AOQ/2qBIKsxmcDWkODEvP8Xk3ZhBKz7I+F3AhmKZBYwhfj00QrxykhlHxDY+ANMVXF/ipoFcbkZZwIRRohbTgYmhm71/EzElQl7ZLn0Il07JGnA3dagxPAYMTr5pgoCLsVxVm4sSFUA7zz6V5NJdv6aOpl5OFvzwng3VE7wb1BuScsfnTGkB0tQ3AAyAjXo+pw6qhaY0ybhmrJ1A"
cEnc64 += "OCFVQi6U5pSIa2FeVroAiwCmDn+zMpADDGWXP+2L64YUCIljwASC1M1jyR227QHA6NJlxCGVh6slkGvZMLf6hqHFx32osWLD/LCnKDyQLyfkA7Tmtpo9Azsz3vzRvl9fHn11AIT8SzK8Y1lQ0fpvUmfvXOlZ7Izb6v9L719jCZMmomSjU3i0TFTLD+QbbExNdqfMAStZyqjhOXvaj4W/j2fdKvOrQcUfXui19Cj33RCpw/NB1Do03KCvAYI7EhyZ3+/NMpqLgAFO6zFAU4hqMiLLVWkmroLTunL0frfULh/Hk9lCmAA9BPO0aYAQITMW4RRLAgxCSCoKjwEz5DAZzkj0XjA4p/kEb9scENCmlA0JSISDx0nMUcHcnv5KWkBHWAHOGbqaV8KQaOKCSQG5AYYoasROg+bJzSKwfapqFPSRKUlCZdO8/4M5jxeZ7xZezeVh0aOU9LpyXhtIVPY5nYT+RDtG1BBbFLZI3hQz8ZmMHQRTovotyApkl/dZ8bl8Or0SvQJXnBfYgfNyZgI1hy9SyBz2/Al9sQiwx2KsZZKbruJ+YN5URaLlmCVYp8/AphVR9yJQ/X9yIinCe+K+kXo"
cEnc64 += "CAUKKJIyM+QdWkK4UkVjlb/UwCqDHKtygwdQv9qRivjNCMzXYRTMIgq2OFV7/A4N3BSi5B9KvaT0x2TJsDyVVaSPDE0AOXspvvLuWA51itXaJZ3NNRN+zHWVmsXIliU2kooVddxUIeGAZCDIBQxq1dmKbn++ux5fhzh5S1Va4evwr53wHINzzbX0mPA7Rr4x98XG8kV+9njHCk42Zvh3cK0pNKMvgelW178SLXkN71NVsdHYA1fU0ayIsxIb2RwWIQsNZbx7VE/g7nJaYPQm967eRAHgB8c4/0DOA3YnAItsRVIsAth62S5flq+emLFi/z1bHB0P0NVzZP9H0jkKw8jj1ZeEWt9FmYVQ23OJrqJM4Y62h+aILrnN8qz050csKHgrPnGmC7mUwHjs/da5WOdrfT/MWb+Y5Q0Qm1PyI0PnEiAFwvsP8nZw9Q7fFAOBpFJ0l8QXKXcBa5SLlHLq9RwiFbwU2sz/4dWmUMeLEm9eQFqR3ISiHJSErsy0P+jpJaB5ST/1+OD8l/KXr0ecsAPWE/8f+yJa9Ty6jT8qt5HZedJV/8DvZxBHShEiwUUoP0pnJUJT4jNRbv3il9E/Ys7"
cEnc64 += "LS9ZAiJG8e4LklEQlAW2A+Us9aZKTp3S4i9rOLHB9H8eLSZE3So3Oc0lOjWGyIUpQv1RCa4F2lV6UlKoDGIWhJ6NgxSUgRiS7K3Q9tHAqd7S/+KXBUZVpjGH1lH+PyjNW7d9vaKkwX9fpjGehz+oeV9n80F5la0NCHeJwPYzlKUHVfvjZxWpnhtuqRYMpHmE7hJ2V33X/vn2f7ibfSdhe3NS5+mugQTlEM+4ifiwwi9DKLJOaZDWRaqRKIpwv8ee/g7eiJ3r0tmsXeq2Ms43vlSelMDnLRVmjn1SNuIA2FEneBG4bRkPvxLLj0qwtP5Jx+yYTH8DGZyfpNzd/q8NFnAWBupD/A8GtNBIozEeRBvEMGIcQrEoBNqMu+1wicW/vP2VsrweHdu6atG+pqLch0/nxb3VwLLQpKfHG/8gMW9aHkuooq0fNTWD2ZbwjeZdmaMEvhDNMPn/lgCWGAj2nrY6VDn7RknFjR1wibFmlMDrf6n+eItp4Md43T6+voTmZKPWeAm9aP2ydPPA3uWw/KA8XT4PY/qvjK+KxUbq4jchKPlRZfs/2FI+efgEtVeHUx18M7IgYeCv4L6f0gmb/ti"
cEnc64 += "1FHOMSpPl02gO3Zwtd2/lf9mFWHGIori9EDp4EBhUEfVK/720mZ80SuEvJ+n/lMP5T+L+5IQ3Ql591O7YSecRSsfsWFlHP2WRBvdIHnpp89kRPdQyLzqVBymTh+XZ/KovURt1He9Sqzk2vYk+OCfv8bXnf5YgiSLC+P/YWvdpwj5wPVPogg+bl4y+F5yJSjzM4SumaJvvjduvDWko2ep+xRqe/TKU5YpOr7PF9dqdAc4qGTkzxz44nlkoj9dGYs/qXZmq5lyOYIxSVR35/7LEf5Ehf/y3xVmYvWr4qeHoD6/g06VFJtUnCvfVfLXo5PPHsJY2KvyyNitpyathhYls2wc/iQPvF/+pumTe6reM/Aik2qA9whl5yXJ2camxhUfcRn+GvOJPied/h42nvIBQmu5lxv9ffqqjhazK1Wfwo2pWsjNdPfazIEhqpNBGBJ2v2XbtuLez6fp461+W8Xx674JzUW3EDWW7jma5hKFZ93p+UI4/n4pTso8+/NQ/6JaY6FuNH/i9kcPEUkWDf5+W+z+bGOqvNRNlENKM11MRSkf2WwNDyGuwLiwtfaexsGrUotb7GyUxoFyXvMLLemF2lv"
cEnc64 += "LOMSBWu2eb+yVQ+8en9o98qYFLq516qYF4rbdHoYF6rTfUljmHAD1SBTfur4+5TjRrT/Zx6Nr6Ck838lKoRiU7Ve2ncDVX+evggeziz20x3+1LwYidQcTGP7ylridQmrr6pPVDo7hG/IJZe8VNb3Ed9IrU1o77iHjo1BN0krR4i50nQXkLhKbxh8lFuVMoi0tUovkN0Y5RcpwFI9wmXHZaJcyaXe1a0fqfI0xjdFy/khDHn3sbB9lzKXQ3BetPpSBQAT3m/zolM8WYaDVYAgBXikSJ8hQAJwsNQkgk/RKaSAq2aH4x1jwYOGTehH58OCt5NxqNKBx/OssMkWuZzP0VSKEC7wyRJvUoBVWGbdGWF/wGapIuA/VIkZ8T7Vv0sLPl2Fn9Mziq8lzQOTw+BS/ixO8yD55NW1NOTmFB2mrfUTOrzLzUezE9apiyZCDNsYQE44yL1Z91gzzCcRJNSpo+QTUzf8rcjE+SogEHFE+YrCuJKBCkDHJmd2fwn5ryHmo+6jGDf5z+UEtDrFI6speswCWeVLbvZit5W9Ofeqg7joor/hWJ7RwN7TmWxrvSkKIWd/YBnFfyGXhWYE4D3+aK/"
cEnc64 += "A4xSsGraL9XOUIriVcmHwBgUU5sUFebVeluKzqZ9DTtixcPEk+eSqRTWU3c7KJk40TGQKbyfMhVGhBXJine68SZs7KEIC4ahrhEQfsrWLQsbOTlbjsXUFk2IkXZNM2eNRMAQzRlHQd0X2CORj5x3628fxAuIrUjWIcUE1aPIlpA/kBuH0SKDsomRj5laIUMh9KyW6XGkp8Lu1pbG2rjdFShVZq2U9mtkYE54+Ao/F6qmRYpy92GHp5GP0iX9BGV+Cg0Qj2DWO59vVM1GgYS0fEfILron9Q/kE6g0F8oUHhJO1O+gimaHYAdECgWN7iyEpNUdNPASQyKipfWFawq4EUUjf5Bmi+zdOQg7uIcNIjxr1X4GQiqXMo0igEtFY/alovcy+3cpYN+GsgircaYlW1DaaDiuvyCa8KgBB+h5qg9Syh+pSQyoEDMdQYtw1lYroqe15f9PvXmRD+I3sllM0Z30z/VCIXvLft5jezXGVzILATFxHoD0Ur4w2xdtFjk4Ou2/uV3DQ/vu+WtiQB1meqhgd/qYfnzOLXWb/qbVK8h82e5GNSvQtTEaeIAWDYZhpBoUtUckG9N3ZY2hlv+gqGg"
cEnc64 += "epSlwFzKeZfv5CMDYeAEbrQvRbLAETxvfAo3jpRl/QBpHs8ukIIki4+W40zfkdVw7P6eQUH6uVmAKzqRBUvYX+ikh3khmCOUGeCO2lbbgCiZcJegSe0oxpMKuAQv9sUPuWEsiMhNazWlnKXOyZ3fJZ5Fl052xBFG9EEAeN931jeMv97N1RqOWjCMxyESrU/BJobQcHB5YiCfQf/ZbNGStptyhbUSKtkOLy1DVnG0uW7F/KY2KrUfO0ar+ikJHdacuxVJiKHqhAWJh4n41aQpQKTP6O6k+een9cok9oHKoMWvMI5IWAY4Db4VZNG3tl/J28dYH9yY6FWla9U8rJexYLBPpQk/FZIL1gyb4h2UZR8qjlgdvcN7TD1a33wrnENqwqbTfyK/Esx4QYERA/UOnHf2t6qDs7KLu+Kot2u03PL3z5fv0cbC4uNyLURxRoMqk9CsjasqOZyOmQUpTQmTOQsCTyCt8YrdiPhUB+kpjsbbp4b8vsdQLE5F09jy0TwvhLsMvj0JOsBNEa1cnQu904pT+l5nphAMNI5HsIW/8zJnqZ+3JYgwMGlakf72so+Oxss2wzzino/LqYf4CZdkMqW"
cEnc64 += "QcDhbAbIMQUcgEDEQ3h3ZaDORSaSD4QvQnI8bcDQJxD0HlHz1Bt7AGuMTUI/eUBIxT8FB6GP9coPy2nPhSYJwDTAOj+cjYK3Bsm7oqehuRc8xLTIgdkhETprrW7D7o2enaofUTElTxsEnwDrBfYmtbLsvCV+ZBi0vJX6J5LUUYzVu4LDPOYbKva3fk7YJKJ7VenCIxO7NFRRvyIpQTvxU9iUj7Ta1ORnf9dd3XQ4/ZSJpIRK4HFeBz3jWaNYkjukJ79oJmZa3o928ttnG13EfXWtdWKinZxRmtLLV2pvct1wV3DjBxkp/ds9ACqTzwMhUemtaqDsqIZ7Qpq6+jtbZ4iJK1NtC1l772RVOUbZPtc6h3nUf2LFnu88r+DFkBKN08DXxL+5AwWiB5twLf4SpCcirOuFIg738DnvIa0/fZTcAm+UOFuehSl/fnEvhYMz3FzcuwgzMT2O+clsQDdumEBNHh3NU4epii+0i/AGMZYUEB+nyA3UHUO3VxOwaMXnvk4H4+HmwlwN97bVoG0TyZv9AXLqrqAthTgK0kb2xsT3WkoCjP4XpwIXS3UsJeopLuH/C06BVPqLTyQqiM7ddCa"
cEnc64 += "j5Yoq4Kkf0mjSbpozuMi3xs7GH27h/BxziMVugd/nL56v7508eZtVR/rTViyY2bQBW1Gujj1nnCW+zukNhjgZZsRBbNaFTWYSRTKkkprUzSi+Zlrp3lyfl0e3q1Y82zmd2xitqchYXzF7numD608l2kG8wgTvSSIk+Z2KxGfhvKVJMNKgAeAByhStUyKgIYczuJAEO/2onw9Ofj3UE3IApXqm77xSeEb4H7a+3mER6b+7F1inlDt76Szybh+x80QxhdVxb9oHfkp3Llqm7pmA567esl3dLNwW/2qLetxCgClJ84HegRHox4s2PnTjtBkN/dLUT19cz26ty303cs2nwqlLLt60m0mY0ycqsFZtaL0ywyRCoxWtylOSKcVNdrKBD3UyhnPTHq5PECEZpFpf+9io7XSNYG3dCK9ztcFR6y/l+SYrK2OZew96p/5zlfakaHyNNAk+y1Sbj5t75MyKPBI9wrDC7Sf4b1104QSH8HRGq6xVvrw0H0ARKr0ELSCAXd7DfrZ1EsX4sxqmVjB6AqzZQzjDY9EPOk3iE1Y0NXWg7dbTsbP8L23EGCnd4TNABtooIDYKP9ehns5lSpAQdM"
cEnc64 += "yVkcyg8HgpdMjALtpvYybPPvYrn9NSCy42ew+UEOonwynqraY9byxQeV2/eeuXsboRYDiINZQo0GyUDbno+/MLLuqu+dvUg7yrrLuDeXkf3cZpi1IQfwPK0WFp+4T+/jB7ZaN/P8RSj7+p5vz4hl4k8PnQnMVmeavmC3PPYv1t+fg1LuCMWd/d571gyGhHTyMgUpMD9/SgBeTJ8W4mWZAw0LVeNilQ8wU6wsVXlrbsNB88OsglJf/5vbsdxsf3ccklXtoat48nBeYyE4Rnszwl8/3R6/0QI8Y8SF5a9CcbwAcsxuZZKx6LsqU+S7Z7/Shwcv6vt092fw+qqbzAUVR9Stb4NK1dvbL+IcT1jnRmle/rJFP1F3BECI/8gJyaZqRmqbCZZam7pNrDeP9tVcNgWL8WcYiasSIn85C84xQ0f+IMdu+P8E2m/ppJzddHTMs1SUPjBaTfFKGf44T4f86oPu80NVOv4hzTLVpp1n76cDZxhdTjUJbg4iK7v1l6QVvRP5qm4AxzmYHSFXfpTKpYSjeTfofssqD8DLyHnZnFj42Pei0EP8kEywZZbDysSnKIu0/fjzxes7zgdUjSrFgwW"
cEnc64 += "eW574S6W8UX03dc6VGRqxNQn4PHQ0TEJd2b1TXxFwlnQCg8geiKn4DRolFlcSduqNazGwJF4Tmo9OEnjsogwVq2Yb63Zt9AvaBSQIoEaqizWxpSgQVv2EzYCFgklr8WyMInoM2mqCrzm9kODMA72uGi7y+L4ej1fVQGoZEnJHBWefqIrOu8NMXzR/M+DkBHW5eYuej6fN/y82wf3KimcJ606cDWd9+/4npg+Z0ef0bjPruOxmLMYWJn4A/lo7uAFuChFtaplP9mv1lf9R9Bp1o5yGthVXCg2HQe1O1ZUO4g7XW1K00r7cnj4TV6hV25IY28EkNihcKIDM/hD6b6Mt++nz/+FU3qbHC9V9af76nBqAbqrJeqOE501PiKVuimaI3VHtYP9ccT01l/bxxUeKT8VDCMUIuc4nh9aAFHQ2cd4mZpKzKy7iQILxxoH64dSChqJ5n8FFCYgjAYbhRxihb7iXN6zv0+mKy/PGF5J2zCfPwopv4RDPG7aL8yf8++VaoebVrbaDAZKMANbrHi9v8Hp/cxs8TP9e3HYvHXUfQ4KYqw/DjVwLZotnp7vUPtD/RdzH75fR3BucM9AJHk/H5v"
cEnc64 += "7/bVW1eJ3ueyIvAcQevaay4tfP7pNbD15siFvRc01VdVteLR0K8yDGOiuO2yellt2nDjG9QN8EX2D4Go8ntesczxR+N0bT+7EW+Rz2HA8If6559yXF6/LTte5vI97dwPvn4boDvejlnf3/WI143K5X87TOV5Xw1E3zS0jSPjXnS/bqrlU6ZJ56njxAQGW0s+RNj7vLxJYz3OtOj1EQD/Vkagq/zRhB3mlr4KYml+fk6ZTFCiDYKrUzSeJnifvPRfXERH3jpiW7Duv7Aoo0IsM4Yr6iplzs47EMtkf/eF9VvH9WLzxfW2MNFp1FIJjOhxSZoxkHyRaD2JuD84rHy2G0i93UIAxgH4CXKGKFY6GRbXxj/gHjADkUiPUIllHU/+Wa9+Wvazb+RjqmnO9O0mZbrqbwDnQ2gNEMd+1UPs38x8LmUm/ktQbpzXn+DzcKkq+Qnv8+KVlSeXnYDVlfifebvpa95+4Y/HvZ1wFWW5qbb+ey+xs6TXRxi8Byrm0Eyes3RmkuUc2x3urUCXrIFkrO/+WbHXZpfyOI+G8MgVcfSl4FRe8JmvffG7ssIUrxZWffO/5ke98M3gfyPbQU2SqK3"
cEnc64 += "sMbH+WtFx9EJDHPEdGZuwGKNveZim77HwqKdpZmxw15Xhi+5ynqdMspzFYe99F9Hg/a3aWn4+Hh08g/bTyeb+aOf2kVTpdmNln3/qA4/jTfsy2aMvR2VhV0VHZKKcqFR5+PBBTmtkloAirXuONAwx4tDspr/BOtE6zHTrit7gK5b8dUZeWOk5Wp9HtclfW1sZV1O8UyHG5+noMQNqvVehVJsglle4JC82l1cwGwIFVunzj62WyUM7Pum6VLdxl/PnbZDBfcaxKCj+C4I1L8ZSs7f3+BcVbzLvDIGVAfVdGxBFgBtU4JhzT+XeWuMYhZcQxcfx8MsPmk3WTdECXaEyUfdvxJezAroNxYvYezaTY4Hgmq6OzhPzakW1h3YefqfG+5l9GJpLoppF2nV+8MF35MJqLVzdl79TR/VYqvB6yRb21b9xr0vi8EBD9tExysqS60ItmjYRHk6i9UxVayDiixSmn2+CyGcpOt0Sc1Ivr3UwK4ThmKPRGRGVVx0/3GPpKRwuxVO9mvgnvgku5qWmzkK804EXDCSKvLCs9cUXAVOl8ALv6YT04lK5iMTeMUSD7ndnyCvj9SCdYEXcE24ddr"
cEnc64 += "/lR/zMW9+THQp65yWXrLv613mefuF0Gg/IKOBs1rSe0P2ohiDAkFdRKcanxdNjC3c33rbcZ3gdiKqSJyQN3xz77tit5ZkSZ8gD5xrqelxGUBkwynNgT/sdpzNWWnSo1WlE/As6O237YU7GmMWbQnsQBqrxVJkO1UBLYiPxgTdd1CNedPoxnvoSx5m+bmJEtCKiSVlfQ4W+JN50MVvzq8a2Xzxttbeeo6XnySCThpT7ZimxvWstJFsXMIOOr6P5fHdEBXruqZ8OVn1Byf7zewWOhPYlS4aNk9aBIZXH1yi4A7Dv3E9XXr4ljaMUw6n+O152gvu5XMPTL6obO7D03rgxS1Vu2nX+ry3vuF+73568+ns3tz7elyIX3HTSshTsWPIapWq503jWLTiIflQUT+2z3V6xzHey07pX4Q6zMeF1YvzQ190uN42TARdgUL7C6bDzHNFu/A4O1g5XpgMGi1MU/6+fVQofNlWuWrtSxjXrY7I5lhwNrzhKq2ch1jeQ6l/n23EdeLxxGfuWwX7d32r1yCsl0rmfWosBgJ1RPpLkftH7YxFD/vX7Nx9fRejyAGeq9oowk/2D5nLZlKLt9hmnw"
cEnc64 += "5mg7Je99TeNP1bktGAPwj6Y5Ek/8xQ6uAB0JtMRFrQZAJlpjzpL9qpJtF+t51PLad/o7eHFXJds/ZTl5t4LtJt1QJQj/VIyrZP14Lq9IibXYaY6ZrkbTPDbz6TCxbI0v1CdDTBXRaHppCyHDzEhZUUpK3f3Mmwq/YJooTG3VjHUwEpTLvOHS/TJKbBMqxGgGQO+r2mkTBkrnamEupdB0tDXQV5eKvr4t5Hy6WGp/qPd8UTtOximnZnlRfmDfQkcGVdS8NdOgReHj12qGE8clV3fr/oDVGL4wH37Fr9Ch0JC2v8zb+Xj2cbl0x4CPz2ItYOhBDF4KT9oZmtERT00d4nuY+X7f9Lh5GruHF81qdlghf9l8x4QGBEN2G1Q5jrzLbCEJm46rfDdi6UaYaMkherabx/A1Hx+pO2OS8bqbNrQ74DLaUmz22mzfMqs0d1FHRwpklayf5bf/1fpAK3yLCdGzuiG8KGsg9y6PInPsefjkNrEOP6NoDFvosfus6dNhkG/nOrC+usvefn2gt3LisjS7phQlpSx0EYccGK41G8oTu3Rvy1MJX04dQkE9ktKsaZQiFAwDrb2yE48vR6vTQoN"
cEnc64 += "+5SSSsB8kC6o0nKUSFWkSWqwQ8WrOVY0Yt+otZqJwUP4hDl2hZJ1gKn3OA4Ihobxsqj0YSjEiQsoE0jpQzkyksRSqGqWZJCVYjX7IOTqdr6a1eM+43AbsPa6f8O7ALJSltgBJ7s89lh2YbSSSSsD3PB0iFucGtqVOFwhom6T0osYVKVk6x209rl0V8b+tdVnj3W1u1lcyMjs48BoNyyQnmVfkuDksFL/s9cuknvItbTe7nq2Yw6zpwjochFPbBJieuyMv6iqW7Nhf1CD1LCxvI+v17Ak8XU4MR2ZTRVwb5Tx63nT0LCYRaaYSasGezHTVV5Q0VLryoWQyeiFeBnE+aJlpit9/3Kt/d9xVCZcLXfA9mPpcDJ5tczpUowxKltYUo2kH1fG/7vHO7tUdjF9G++Nx838c1XzllwPaz1mn6k1StqCJoZtiD8vaGR+GM7yfzyugEHsWELs5ttB9DufU8drkMDXNcO2djdX/ZONXY9njJxWdHqtUXM1vdvYrFpClBmNsQjBf7YkvV/7qcRh/jE9rIIozOwD//jR2kcddSU/OSTjofivu2Fj3GB8n+nOyyXSyKZkAZgahSeXMIVQGiT"
cEnc64 += "8LhxWJ+6+gU7yVJlrbDse1P1Qrd581pE5gfa1u9AkL2duvjkD+Fcr4hAkKvwZVWo8BBjsnaPFa/GvDnx7Bj6Vwh59/dxA0HwhUgPPT/UtPCSqYv3KNejprA/l37Oci33+TCKJ6MYlOLwQaSipCRZjScx3lGha0Hkp3BG2FBjEZTrCAoJZVBQELc/4Eperyhj/vy1mY6nCwx8erxPFTGQfQEvMyFU5/a3yeMAmklKs/h10EqFPk7g+P5rXoE9filBvtFvxG8HdALMEcwS2LTMaa0LX8nIUikmm6YFwEBBSslHOKKpiB5uP1RTsaLc4nYTP7zMVqa0u9Y6h3N57vJ+Us0uglR2te7DrfDcvPCd7yXWbUT60YL49D4Hlu/ksw2x8XO7qulgsGs+OBd3XmCRf64jpeTzGORlynSKR1J5OtD+w+748LrSSyIcKPy8XEPW9TwuFKodfoVm/SKVu+8RyX3qtM/G9nn/jeiw2GQ0hkss9lfw9PdFdvNx9s+gZzs7zdIZzTqt8rmzX1ep7FyeVH4irzJyFE+93Hp2C06mENUvK4/hWdlvTdrerK0iZt+h+u+PG83jxfUTabfjm7Rzjdb"
cEnc64 += "i91RlnpXIAnoetQRCJIznoEJywdzP/mfMzlZo1RWmqfH1dvrSAooPHzM95MS1JiuGSrcZ8QmNu4rWVU3pFOlL1hpyEomMgsz9AwOzDZEEn8gtSSoYd5EL3QZyY4iAKhKt6MIGqqawE+u2TrDBYw4WoxdB1OfRexE055OsQH17gBe7ONYOzG+yI7UPjPX0f09P2bDCw5W44DJqlJ+NxuTN4bVS9+LuM6SbMPODZ/OVshYZnpVrTVmDoKeL+utG/iqqYpU8TWud1/z2ieMwQwOPTCSadsu7fzRlv+cuD7vlw+HrY5PX/czEyLu/W/rnad+rBEy7goQOK+aXuvMXLQKdYlWLvHdztNut6mc1kj0nRs/0Vbi0FVgZMbW/wTwtLK7R1PMRN0fR64I57jyP931bKdEQ4d4o+/3jM+R5P7E7opruxG08VrlgsfLGK/QuGoiXTy9uoShnhRLzIUYnawG1iD0FKx9Pgg+8qV916OtknRj0YiaUFhJHNsqxah2EvyHGfLYaCGbi5KRRHInCLrLZzEw9kSd7ZuUwqtXrKkYZx5a7MV5/PO96e8BUvebXLG9+wyNn6Kenl44xkipJyuHDzp"
cEnc64 += "nIqjjmGmBFEVPRMmzL+0y/b8iAEJm5rbiIX8HKRGuN6fjrt4yokYU95u/B80Jkx1N2xf0YlOCFJa9I08SJgwedu9AywxuvQnWj3Rvr/pVwhSPlVYMLG7vpJQvXeGxBiZ/W+gME0BJCkrbCEsm4xAHPyajcA1aSOMrGdt8e2pGKcEKF2AmYOFvQoKUT16nPnM6xqDQmJCI1gEAfuIyxtaS5++23mZLBqaOjrGjOWfNu9vv4NbDAYFo9Gh1I8L7u/1Nayeu+EOWFNVFZEUvE0fi5VpJLxgadSPBXL1p+fhC5xqUaXG+oK/9B2XHrtBdwf5s2MnOWvNNjNjgIdqGmrangv2b3Bik+NGCw1qpK8DgJm+9IGsxO0I/+vDCP6zk7MLRKesra6pTA7UwenFipe2Mo/CGf7W17tRjlMIEat/FFsGC8vm7BwalAsQfTosqYWnyeKXpWVnZSX6sz/B5GZXx9NLj0d6c6lEnJ1b3ZD0H561ZU62lk0W6eXKNY9bBUunJ7R/EeXr9dlDsV99+XISZyJdqJjTpu/Y/vC1+vv46naXTJY2lWdJVUFDUUGDz8H0bbWTgIdS+nlSHN/tYox8e5i"
cEnc64 += "1nHI1fJaj5+uJ2HIZN9CLBBbA7vnggu+1as0OKyrNBw3wSuEtprBkWS3JhByCYJq8tzFwXQ4/FtnxfVUdMmcXshW20hQUzp6YDg2w50JrUlGSFp2iNNP1u3rFRWm04gSewpiTkowKCj4ze/j5WpIAYpH7LqFNwWxjH1g9BU4EfSYJ/ddQgtbAwvxgEsoJ4NBjjV3pWLqYSl0HBPzbOGIJusQlHfyxqgzLDNoFR4J/FrwRrxnNifGYZFjm8J7Hm2N+fPa9IfE93s8V8OL74O7UP3XdeN9Uh6EKK8BnFC0avBwfcqhXf4xp48TgfbN0u6yUvV+7We27lpAllTb3aoi/3o3oPr6dw7PCo/sioMHTeF2GqZutVB5nsBDe3gbUeH8YdHbRdht8Xgf/rUBoAi5LVXstD3y7fhW87JNHD+l9nuRRp2xhx7y0h2MQwp4eNLFvX19Gq6t5IqzkjX5YcyN5uedbKl7Jtuvqn1aXczrVVLu9FMQchCC28L0ttn98WEjSNGb8/EW90dTwSc7vjYlemqcSjaVqu2ay448KESKheP+vy+r5uP+Tqk8uN/z9t+Xk66NH3mbnjrHKvwJUEvps3M"
cEnc64 += "oxR5ai9aiZe73dndvDg8tjX59dB5d/7eXrXSLQGYT/a/UYQ2/THJUOUCVhCFOZNEH//XW2cFemXMCQ8qfr6VqZ/KCdSzpF2sA5712/IwpfeyynbnJ2HNBXa0Ya8M0wTXD6oK/w+GCo8AgXA8GPOJxrWMhAsQoYyb1kap0dnR1PAQ1o3O/EBH7+Rw4D/69lKUgM/IBGriDBPiVM4KW/kYIzlo6ZsdmRtF9iBb8MfLi37j/qY6TogP+iFw9W6wZiFhadDOWe/kcYuAH1E7vf9v/bLqjlrvv/2f5/38p5y6kfexffn6tPCQ/r/L/1//+3ewZdvn+DqHNVU9f1u7aA/HskReVEqoX0/f8PhsbAeg=="

cPastLocal := GetTempPath()
cPastLocal := Alltrim(cPastLocal)
cPastLocal += If(Right(cPastLocal,1)=="\","","\")
cPastDecod := StrTran(cPastLocal,"\","\\")

If !File(cPastLocal+cImagem)	
	Decode64(cEnc64,cPastDecod + cImagem,.F.)
	CpyT2S(cPastLocal+cImagem,"\SYSTEM")
EndIf

Return

//->> EXECUCAO DO UPD SEM AJUSTES FISICOS NAS TABELAS
User Function MadEcoUpd()

//CpyT2S("C:\bombay\logopb_010101.png","\system")
//If File("\system\logopb_010101.png")
//	msgalert("ok")
//EndIf

/*
Makedir("c:\madmais")

CpyS2T("\DATA\ZZ0010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ1010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ2010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ6010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ7010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZE010EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZG010EC.dtc","c:\madmais")

CpyS2T("\DATA\ZZ0020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ1020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ2020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ6020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZ7020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZE020EC.dtc","c:\madmais")
CpyS2T("\DATA\ZZG020EC.dtc","c:\madmais")
*/

/*
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
*/

Return



//Empty(m->C5_XIDINTG)




