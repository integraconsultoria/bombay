#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

/*/{protheus.doc} BoRelRoma
*******************************************************************************************
Relatório de Romaneios
 
@author: Marcelo Celi Marques
@since: 04/02/2023
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoRelRoma()
Local aArea := GetArea()

Private oReport  := Nil
Private oSecCab1 := Nil
Private oSecCab2 := Nil
Private oSecItm	 := Nil
	
Private cTitulo    := "Romaneio de Transporte"
Private cPrograma  := "BoRelRoma"
Private cPerg	   := ""
Private cAliasRoma := ""

ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return Nil

/*/{protheus.doc} ReportDef
*******************************************************************************************
Relatório de Romaneios - Definição do Layout
 
@author: Marcelo Celi Marques
@since: 04/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ReportDef()
oReport := TReport():New( cPrograma, cTitulo, cPerg,{ |oReport| PrintReport(oReport)},"Impressão de Romaneios de Transporte")
oReport:SetLandscape(.T.)
oReport:nfontbody:=12
oReport:SetLineHeight(70)
oReport:SetColSpace(5,.T.)
oReport:SetLeftMargin(1)
oReport:oPage:SetPageNumber(1)
oReport:cFontBody := "Arial"
oReport:lBold := .F.
oReport:lUnderLine := .F.
oReport:lHeaderVisible := .T.                     
oReport:lFooterVisible := .T.
oReport:lParamPage := .F.
oReport:SetTotalInLine(.F.)
 	
oSecCab1:= TRSection():New( oReport, "ROMANEIO", {"cAliasRoma"}, NIL , .F., .T.)
TRCell():New( oSecCab1, "ZR1_ROMANE"	, "cAliasRoma", "Romaneio " 		, "@!"						, 10 )
TRCell():New( oSecCab1, "ZR1_EMISSA" 	, "cAliasRoma", "Emissão"  			, "@!"						, 10 )
TRCell():New( oSecCab1, "ZR1_PERDE"    	, "cAliasRoma", "Period De"	  		, "@!"						, 10 )
TRCell():New( oSecCab1, "ZR1_PERATE"   	, "cAliasRoma", "Period Ate"		, "@!"						, 10 )
TRCell():New( oSecCab1, "ZR1_QTDOCS"   	, "cAliasRoma", "Qtd Doctos"		, "999999"					, 10 )
TRCell():New( oSecCab1, "ZR1_VLDOCS"	, "cAliasRoma", "Vlr Doctos" 		, "@E 9,999,999,999.99"		, 20 )

oSecCab2:= TRSection():New( oReport, "FATURA", {"cAliasRoma"}, NIL , .F., .T.)
TRCell():New( oSecCab2, "ZR1_MOTOR"    	, "cAliasRoma", "Motorista"			, "@!"						, 10 )
TRCell():New( oSecCab2, "ZR1_LJMOTO"   	, "cAliasRoma", "Loja"	   			, "@!"						, 10 )
TRCell():New( oSecCab2, "ZR1_NOME"		, "cAliasRoma", "Nome"				, "@!"						, 30 )
TRCell():New( oSecCab2, "ZR1_VLFRET"	, "cAliasRoma", "Vlr Frete"			, "@E 9,999,999,999.99"		, 20 )
TRCell():New( oSecCab2, "ZR1_FATURA"   	, "cAliasRoma", "Num. Fatura"		, "@!"						, 10 )
TRCell():New( oSecCab2, "ZR1_SERIE"   	, "cAliasRoma", "Série"	   			, "@!"						, 04 )
 	
oSecItm := TRSection():New( oReport , "DOCUMENTOS", {"cAliasRoma"}, NIL, .F., .T. )
TRCell():New( oSecItm, "ZR2_TPDOC"      , "cAliasRoma", "Tp Doc"		, PesqPict("ZR2","ZR2_TPDOC" )		, TamSX3( "ZR2_TPDOC" )	[1] )
TRCell():New( oSecItm, "ZR2_FILDOC"    	, "cAliasRoma", "Filial"		, PesqPict("ZR2","ZR2_FILDOC" )		, TamSX3( "ZR2_FILDOC" )[1] )
TRCell():New( oSecItm, "ZR2_DOCTO"      , "cAliasRoma", "Documento"     , PesqPict("ZR2","ZR2_DOCTO")		, TamSX3( "ZR2_DOCTO" )	[1] )
TRCell():New( oSecItm, "ZR2_SERIE"      , "cAliasRoma", "Serie"        	, PesqPict("ZR2","ZR2_SERIE" )		, TamSX3( "ZR2_SERIE" )	[1] )
TRCell():New( oSecItm, "ZR2_CLIFOR"		, "cAliasRoma", "Cli/For"		, PesqPict("ZR2","ZR2_CLIFOR")		, TamSX3( "ZR2_CLIFOR" )[1] )
TRCell():New( oSecItm, "ZR2_LOJA"	  	, "cAliasRoma", "Loja"			, PesqPict("ZR2","ZR2_LOJA")		, TamSX3( "ZR2_LOJA" )	[1] )
TRCell():New( oSecItm, "ZR2_NOME"	  	, "cAliasRoma", "Nome"			, PesqPict("ZR2","ZR2_NOME")		, 20 						)
TRCell():New( oSecItm, "ZR2_DTDOC"      , "cAliasRoma", "Emissão"       , PesqPict("ZR2","ZR2_DTDOC")		, 10 						)
TRCell():New( oSecItm, "ZR2_VLDOC"      , "cAliasRoma", "Vlr Docto"     , PesqPict("ZR2","ZR2_VLDOC")       , TamSX3( "ZR2_VLDOC" )	[1] )
TRCell():New( oSecItm, "ZR2_VLFRET"     , "cAliasRoma", "Frete"     	, PesqPict("ZR2","ZR2_VLFRET")       , TamSX3( "ZR2_VLFRET" )	[1] )
TRCell():New( oSecItm, "ZR2_PCALFR"     , "cAliasRoma", "% Frete"       , PesqPict("ZR2","ZR2_PCALFR")       , TamSX3( "ZR2_PCALFR" )	[1] )
TRCell():New( oSecItm, "ZR2_SITUAC"     , "cAliasRoma", "Situação"      , PesqPict("ZR2","ZR2_SITUAC")       , TamSX3( "ZR2_SITUAC" )	[1] )

Return(oReport)

/*/{protheus.doc} PrintReport
*******************************************************************************************
Relatório de Romaneios - Impressão
 
@author: Marcelo Celi Marques
@since: 04/02/2023
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function PrintReport( oReport )
Local oSecCab1 := oReport:Section(1)
Local oSecCab2 := oReport:Section(2)
Local oSecItm  := oReport:Section(3)
Local cNumRoma := ""
Local cSituac  := ""
    
cAliasRoma := GetNextAlias()

BEGINSQL Alias cAliasRoma	
	SELECT
			ZR1.ZR1_ROMANE 	AS ROMANEIO,
			ZR1.ZR1_EMISSA 	AS EMISSAO,
			ZR1.ZR1_PERDE 	AS PERDE,   
			ZR1.ZR1_PERATE 	AS PERATE,
			ZR1.ZR1_QTDOCS 	AS QTDDOCS,
			ZR1.ZR1_VLDOCS 	AS VLRDOCS,
			ZR1.ZR1_MOTOR 	AS MOTORISTA, 
			ZR1.ZR1_LJMOTO 	AS LOJAMOTOR, 
			ZR1.ZR1_NOME 	AS NOMEMOTOR,
			ZR1.ZR1_VLFRET 	AS VLRFRETE,
			ZR1.ZR1_FATURA 	AS FATURA,
			ZR1.ZR1_SERIE 	AS SERFAT,
			ZR2.ZR2_TPDOC 	AS TPDOC,
			ZR2.ZR2_FILDOC 	AS FILDOC,
			ZR2.ZR2_DOCTO 	AS DOCTO,
			ZR2.ZR2_SERIE 	AS SERDOC,
			ZR2.ZR2_CLIFOR 	AS CLIFOR,
			ZR2.ZR2_LOJA 	AS LOJA,
			ZR2.ZR2_NOME	AS NOME,
			ZR2.ZR2_DTDOC 	AS DTDOC,
			ZR2.ZR2_VLDOC 	AS VLDOC,
			ZR2.ZR2_VLFRET 	AS FRETE,
			ZR2.ZR2_PCALFR 	AS PCFRETE,
			ZR2.ZR2_SITUAC 	AS SITUAC

	FROM
			%table:ZR1% ZR1
			INNER JOIN %table:ZR2% ZR2 ON ZR2.ZR2_FILIAL = %xfilial:ZR2% AND ZR2.ZR2_ROMANE = ZR1.ZR1_ROMANE AND ZR2.%notDel%			
	WHERE
			ZR1.ZR1_FILIAL = %xfilial:ZR1%
			AND ZR1.ZR1_ROMANE = %exp:ZR1->ZR1_ROMANE%
			AND ZR1.%notDel% 					

	ORDER BY ZR2.ZR2_TPDOC,ZR2.ZR2_FILIAL,ZR2.ZR2_DOCTO,ZR2.ZR2_SERIE,ZR2.ZR2_CLIFOR,ZR2.ZR2_LOJA
ENDSQL

DBSelectArea((cAliasRoma))
While (cAliasRoma)->( !EOF() )	
	oReport:IncMeter()	
	oReport:cTitle := cTitulo
	If oReport:Cancel()
		Exit
	EndIf	
	
	If (cAliasRoma)->ROMANEIO <> cNumRoma
		cNumRoma := (cAliasRoma)->ROMANEIO		
		
		oSecCab1:init()	
		oSecCab1:Cell( "ZR1_ROMANE" ):SetValue( (cAliasRoma)->ROMANEIO )
		oSecCab1:Cell( "ZR1_EMISSA" ):SetValue( Stod((cAliasRoma)->EMISSAO) )
		oSecCab1:Cell( "ZR1_PERDE" ):SetValue(  Stod((cAliasRoma)->PERDE) )
		oSecCab1:Cell( "ZR1_PERATE" ):SetValue( Stod((cAliasRoma)->PERATE) )
		oSecCab1:Cell( "ZR1_QTDOCS" ):SetValue( (cAliasRoma)->QTDDOCS )
		oSecCab1:Cell( "ZR1_VLDOCS" ):SetValue( (cAliasRoma)->VLRDOCS )		
		oSecCab1:Printline()
		
		oSecCab2:init()				
		oSecCab2:Cell( "ZR1_MOTOR" ):SetValue( (cAliasRoma)->MOTORISTA )
		oSecCab2:Cell( "ZR1_LJMOTO" ):SetValue( (cAliasRoma)->LOJAMOTOR )
		oSecCab2:Cell( "ZR1_NOME" ):SetValue( (cAliasRoma)->NOMEMOTOR )
		oSecCab2:Cell( "ZR1_VLFRET" ):SetValue( (cAliasRoma)->VLRFRETE )		
		oSecCab2:Cell( "ZR1_FATURA" ):SetValue( (cAliasRoma)->FATURA )
		oSecCab2:Cell( "ZR1_SERIE" ):SetValue( (cAliasRoma)->SERFAT )		
		oSecCab2:Printline()
		oSecCab2:Finish()		
	EndIf

	oSecItm:init()	
	oSecItm:Cell( "ZR2_TPDOC" ):SetValue( 	(cAliasRoma)->TPDOC )
	oSecItm:Cell( "ZR2_FILDOC" ):SetValue( 	(cAliasRoma)->FILDOC )
	oSecItm:Cell( "ZR2_DOCTO" ):SetValue( 	(cAliasRoma)->DOCTO )
	oSecItm:Cell( "ZR2_SERIE" ):SetValue( 	(cAliasRoma)->SERDOC )
	oSecItm:Cell( "ZR2_CLIFOR" ):SetValue( 	(cAliasRoma)->CLIFOR )
	oSecItm:Cell( "ZR2_LOJA" ):SetValue( 	(cAliasRoma)->LOJA )
	oSecItm:Cell( "ZR2_NOME" ):SetValue( 	PadR((cAliasRoma)->NOME,20) )
	oSecItm:Cell( "ZR2_DTDOC" ):SetValue( 	Stod((cAliasRoma)->DTDOC) )
	oSecItm:Cell( "ZR2_VLDOC" ):SetValue( 	(cAliasRoma)->VLDOC )
	oSecItm:Cell( "ZR2_VLFRET" ):SetValue( 	(cAliasRoma)->FRETE )	
	oSecItm:Cell( "ZR2_PCALFR" ):SetValue( 	(cAliasRoma)->PCFRETE )	
	
	If (cAliasRoma)->SITUAC == "N"
		cSituac := "Normal"
	ElseIf (cAliasRoma)->SITUAC == "R"
		cSituac := "Re-Entrega"
	ElseIf (cAliasRoma)->SITUAC == "E"
		cSituac := "Excluido"
	EndIf	
	oSecItm:Cell( "ZR2_SITUAC" ):SetValue(cSituac)

	oSecItm:Printline()
	oReport:ThinLine()	

	(cAliasRoma)->( DBSkip() )
EndDo
oSecItm:Finish()
oSecCab1:Finish()
oReport:EndPage()
(cAliasRoma)->(dbCloseArea())

Return

