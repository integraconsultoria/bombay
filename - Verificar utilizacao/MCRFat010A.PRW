#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"                                                                                                                     
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "ApWizard.ch"

Static cNomeArq		:= "RELATORIO_VENDEDOR_FHOM_"
Static cSintNomeArq	:= "RELATORIO_GERENCIAL_FHOM_"

// ***********************************************************************************************>> FERRAMENTA DE GERAÇÃO DE EXCEL 
  
/*/{protheus.doc} McGeraHtml
*******************************************************************************************
Classe principal do objeto de criacao de HTML.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:                   
@type function: Classe
*******************************************************************************************
/*/
Class McGeraHtml

//Propriedades  
Data aHeader							//-->> Array de Configuracao das celulas
Data aCols								//-->> Array de dados 
Data aCabec								//-->> Array com os cabecalhos
Data aRodape							//-->> Array de Rodape
Data aPlanilha							//-->> Array com os dados da planilha
Data cPasta								//-->> Pasta para gravacao do arquivo
Data cArquivo							//-->> Nome do Arquivo

//Metodos
Method New(aPlanilha,cPasta,cArquivo)	//-->> Constructor   
Method CreateHtml()						//-->> Cria o Html
Method WriteHtml()						//-->> Escreve o Arquivo Html
Method EnviaEmail()						//-->> Envia o e-Mail

EndClass                                                                                                                                          	

/*/{protheus.doc} New
*******************************************************************************************
Metodo de inicializacao do objeto McGeraHtml.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method New(aPlanilha,cPasta,cArquivo) Class McGeraHtml
::aHeader					:= {}
::aCols						:= {}
::aCabec					:= {}
::aRodape		    		:= {}
::aPlanilha					:= aPlanilha  

cPasta := Alltrim(cPasta)
cPasta += If(Right(cPasta,1)=="\","","\")

::cPasta					:= cPasta
::cArquivo					:= cArquivo

Return Self

/*/{protheus.doc} CreateHtml
*******************************************************************************************
Metodo de criacao do arquivo HTML.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method CreateHtml() Class McGeraHtml
Local cHtml			:= ""
Local aHtml			:= {}
Local nV			:= 0
Local nW			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local xText 		:= ""
Local cStyle  		:= "s02"
Local cTipo			:= ""
Local aTotais		:= {}
Local nTotLinhas	:= 0

cHtml += CabWorkBook()                         
For nW:=1 to Len(::aPlanilha)	
	For nZ:= 1 to Len(::aPlanilha[nW])		
		For nV:=1 to Len(::aPlanilha[nW,nZ,02])
			::aHeader 	:= ::aPlanilha[nW][nZ,02][nV][01]
			::aCols 	:= ::aPlanilha[nW][nZ,02][nV][02]
			::aCabec 	:= ::aPlanilha[nW][nZ,02][nV][03]
			::aRodape 	:= ::aPlanilha[nW][nZ,02][nV][04]
			
			//->> Totalizadores
			aTotais := {}
			For nX:=1 to Len(::aHeader)
				If ::aHeader[nX,08]=="S"
					aAdd(aTotais,0)
				Else
					aAdd(aTotais,"")
				EndIf	
			Next nX

			If nV==1
				cHtml += CabSheetHtml(::aPlanilha[nW][nZ,01],::aHeader,::aCabec,::aPlanilha[nW][nZ,03])
			EndIf
			cHtml += CabSheetHtml(,::aHeader,::aCabec)
			
			nTotLinhas := Len(::aCols)
			For nX:=1 to Len(::aCols)
				cHtml += '   <Row>'+CRLF
				For nY:=1 to Len(::aHeader)
					If Upper(::aHeader[nY,05])=="C"
						xText 	:= NoAcento(Alltrim(::aCols[nX,nY]))
						cTipo	:= "String"
					ElseIf Upper(::aHeader[nY,05])=="D"					
						xText 	:= dToc(::aCols[nX,nY])				
						cTipo   := "String"
					ElseIf Upper(::aHeader[nY,05])=="N"
						xText 	:= Alltrim(Str(::aCols[nX,nY]))
						cTipo   := "Number"
						
						//->> Incrementador de Totais
						If ::aHeader[nY,08]=="S"
							aTotais[nY]+=::aCols[nX,nY]
						EndIf
								
					EndIf
					
					cStyle := &(::aHeader[nY,06])					
					cHtml += '    <Cell ss:StyleID="'+cStyle+'"><Data ss:Type="'+cTipo+'">'+Alltrim(xText)+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF
				Next nY
				cHtml += '   </Row>'+CRLF
				
				//->> Garantir que nao havera erro de estouro de memoria.
				If Len(cHtml)>=10000
					aAdd(aHtml,{cHtml})
					cHtml:=""		
				EndIf		
			Next nX
			
			If nV==Len(::aPlanilha[nW,nZ,02])
				cHtml += RodSheetHtml("",aTotais,nTotLinhas,::aRodape,.T.)
			Else
				cHtml += RodSheetHtml("",aTotais,nTotLinhas,::aRodape,.F.)
			EndIf
			
		Next nV
		
	Next nZ                    
Next nW
cHtml += ' </Workbook>'+CRLF
		    
//->> Garantir que nao havera erro de estouro de memoria.
If Len(cHtml)>=1
	aAdd(aHtml,{cHtml})
	cHtml:=""		
EndIf		

Return aHtml

/*/{protheus.doc} WriteHtml
*******************************************************************************************
Metodo de gravacao do arquivo HTML.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method WriteHtml() Class McGeraHtml                 
Local aHtml 	:= {}
Local cPath 	:= ""
Local nX		:= 0                                            
Local cArquivo  := ::cArquivo                 
Local cSeq		:= "001"

cPath 	:= AllTrim(::cPasta)+cArquivo+".xml"
If File(cPath)
	Do While .T.
		cArquivo := ::cArquivo+"_"+cSeq
		cPath 	 := AllTrim(::cPasta)+cArquivo+".xml"                    
		If File(cPath)             
			cSeq := Soma1(cSeq)
		Else
			Exit		
		EndIf
	EndDo
EndIf
		                                                           
aHtml := ::CreateHtml()

Private nHdl := fCreate(cPath)

For nX:=1 to Len(aHtml)
	fWrite(nHdl,aHtml[nX,01],Len(aHtml[nX,01])) 
Next nX	

fClose(nHdl)

Return

/*/{protheus.doc} EnviaEmail
*******************************************************************************************
Metodo de envio de e-mail
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method EnviaEmail(cPasta,cArquivo,lJob) Class McGeraHtml                 
Local lEnviaVend := .F.
Local lEnviaCC	 := .F.
Local cEmail	 := ""
Local cEmailCC	 := ""
Local cHTML 	 := ""
Local cPastServ	 := "\RELGER\"
Local cHorEnv	 := Alltrim(GetNewPar("MC_HENVREL","19:00:00"))
Local cEmaiGerer := Alltrim(GetNewPar("MC_MAILGER",""))
Local dAtual	 := Date()
Local cNextEnv 	 := StrZero(Day(dAtual),2)+"/"+StrZero(Month(dAtual),2)+"/"+StrZero(Year(dAtual),4)+" "+cHorEnv

cPasta := Alltrim(cPasta)
cPasta += If(Right(cPasta,1)=="\","","\")

Makedir(cPastServ)
   
If !Empty(cArquivo) .And. File(cPasta+cArquivo)	
	If aRetParam[16] == 1
		If aRetParam[06] .And. !Empty(SA3->A3_EMAIL)
			lEnviaVend  := .T.
			cEmail		:= Alltrim(SA3->A3_EMAIL)
		EndIf
		
		If !Empty(aRetParam[07])
			lEnviaCC 	:= .T.
			cEmailCC 	:= Alltrim(aRetParam[07])
		EndIf
	                           
	    If lEnviaCC
	    	If !Empty(cEmail)
	    		cEmail += ", "
	    	EndIf
	    	cEmail += cEmailCC
	    EndIf
    Else
       	If !Empty(aRetParam[07])
	 		cEmail := Alltrim(aRetParam[07])
	 	Else
	 		cEmail := Alltrim(cEmaiGerer)
    //		If aRetParam[06]
   	//If !Empty(aRetParam[07])
	//		cEmail1 := Alltrim(cEmaiGerer) 
	//		cEmail2 := Alltrim(aRetParam[07])
	//		cEmail = cEmail1  
	//		cEmail += ", "
	//		cEmail += cEmail2
	//	Else
	//		cEmail := ""
		EndIf    	
    EndIf
    
 	If !Empty(cEmail)
 		
 		If !lJob
 			CpyT2S(Alltrim(cPasta)+Alltrim(cArquivo),cPastServ)
 		EndIf	
 			
 		//If lJob
 		//	FErase(Alltrim(cPasta)+Alltrim(cArquivo))
 		//EndIf
 		
 		If File(cPastServ+cArquivo)
			//cHTML:='<HTML><HEAD><TITLE>Relatório Gerencial de Vendedores</TITLE>'					+CRLF
			cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'		+CRLF
		  	cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'					+CRLF
			cHTML+='<BODY>'																			+CRLF
			//cHTML+='<H1><FONT color=#ff0000>Envio de informações confidenciais</FONT></H1>'			+CRLF
			cHTML+='<TABLE cellSpacing=0 cellPadding=0 width="100%" bgColor=#afeeee background=""'	+CRLF
			//cHTML+='border=1>'																	+CRLF
			cHTML+='  <TBODY>'																		+CRLF
			cHTML+='  <TR>'																			+CRLF
			If aRetParam[16] == 1
				cHTML+='    <TD>Você está Recebendo o Acompanhamento da Carteira.</TD>'		+CRLF
			Else
				cHTML+='    <TD>Você está Recebendo o Relatório Gerencial Consolidado.</TD>'		+CRLF
			EndIf
			//cHTML+='    <TD>Por favor não responder este e-mail.</TD>'								+CRLF
			cHTML+='  </TR>'																		+CRLF
			cHTML+='    <TD></TD></TR></TBODY></TABLE>'												+CRLF
			cHTML+='<P>&nbsp;</P>'																	+CRLF
			cHTML+='</BODY></HTML>'																	+CRLF
			                                               
			If EnvWF(cEmail, "", "Relatório Gerencial", cHtml, cPastServ+cArquivo)					
				If lJob
					If aRetParam[16] == 1 .And. SA3->(FieldPos("A3_XPRXENV"))>0
						Reclock("SA3",.F.)
                        SA3->A3_XPRXENV := cNextEnv
						SA3->(MsUnlock())
				    EndIf
				EndIf
			EndIf		
			FErase(cPastServ+cArquivo)
		EndIf
		
	EndIf

EndIf

Return Self
   
/*/{protheus.doc} EnvWF
*******************************************************************************************
Envia o e-mail
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/    
Static Function EnvWF(cPara, cCc, cAssunto, cMsg, cAnexo)
Local lRet		 	:= .F.
Local lResulConn 	:= .T.
Local lResulSend 	:= .T.
Local cServer  		:= Trim(GetMV("MV_RELSERV")) 
Local cEmail   		:= Trim(GetMV("MV_RELACNT")) 
Local cPass    		:= Trim(GetMV("MV_RELPSW"))  
Local lRelauth 		:= GetMv("MV_RELAUTH")
Local cDe      		:= cEmail             
Local lResult  		:= .F.

Default cCc      := ""
Default cAssunto := ""
Default cAnexo   := ""
Default cMsg     := Space(200)

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
   Return(lRet)
Endif

If lRelauth
	lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))
    
    //Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
	If !lResult
		nA := At("@",cEmail)
		cUser	:= If(nA>0,Subs(cEmail,1,nA-1),cEmail)
		lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
	Endif

Endif

If lResult 
	If Empty(cCc) .And. Empty(cAnexo)
	   SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
	Else
	   If Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend   
	   ElseIf !Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend   	   
	   ElseIf Empty(cCc) .And. Empty(cAnexo)   
			SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend   
	   Endif
	Endif
Endif

DISCONNECT SMTP SERVER

RETURN lResulSend	

/*/{protheus.doc} CabSheetHtml
*******************************************************************************************
Cria o Cabecalho do sheet.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function CabSheetHtml(cDescr,aHeader,aCabec,aTitulos)
Local cHtml := ""
Local nX	:= 1
                    
Default cDescr 	:= ""
Default aHeader	:= {}
Default aCabec 	:= {}
Default aTitulos:= {}

If !Empty(cDescr)
	cHtml += '<Worksheet ss:Name="'+Alltrim(cDescr)+'">'+CRLF
	
	cHtml += '  <Table ss:ExpandedColumnCount="250" ss:ExpandedRowCount="65536" x:FullColumns="1"'+CRLF
	cHtml += '   x:FullRows="1" ss:DefaultRowHeight="17">'+CRLF

	For nX:=1 to Len(aHeader)
		cHtml += ' <Column ss:Width="'+Alltrim(Str(aHeader[nX,04]))+'"/>'+CRLF 
	Next nX	
	
	If Len(aTitulos) > 0
	    If Len(aTitulos) >= 1
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="3" ss:StyleID="s04"><Data ss:Type="String">'+aTitulos[01]+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
			cHtml += '   </Row>'+CRLF
		EndIf		
		If Len(aTitulos) >= 2
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="3" ss:StyleID="s05"><Data ss:Type="String">'+aTitulos[02]+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
			cHtml += '   </Row>'+CRLF
		EndIf		
		If Len(aTitulos) >= 3
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="3" ss:StyleID="s05"><Data ss:Type="String">'+aTitulos[03]+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
			cHtml += '   </Row>'+CRLF
		EndIf                 
	EndIf
	
EndIf

If Empty(cDescr) .And. Len(aCabec)>0
	cHtml += '   <Row ss:AutoFitHeight="0">'+CRLF
	For nX:=1 to Len(aCabec)
		cHtml += '    <Cell ss:MergeAcross="'+Alltrim(Str(aCabec[nX,01]-1))+'" ss:StyleID="'+aCabec[nX,06]+'"><Data ss:Type="String">'+aCabec[nX,02]+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF
	Next nX         
	cHtml += '   </Row>'+CRLF
EndIf

If Empty(cDescr) .And. Len(aHeader)>0
	cHtml += '   <Row ss:AutoFitHeight="0">'+CRLF
	For nX:=1 to Len(aHeader)
		cHtml += '    <Cell ss:StyleID="'+aHeader[nX,07]+'"><Data ss:Type="String">'+NoAcento(aHeader[nX,01])+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF
	Next nX
	cHtml += '   </Row>'+CRLF
EndIf

Return cHtml                

/*/{protheus.doc} CabWorkBook
*******************************************************************************************
Cria o Cabecalho do workbook.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function CabWorkBook()
Local cHtml := ""
Local dData := Date()
Local cHora := Time()
Local cData := StrZero(Year(dData),4)+"-"+StrZero(Month(dData),2)+"-"+StrZero(Day(dData),2)+"T"+cHora+"Z"
Local cAutor:= Alltrim(SM0->M0_NOME)

cHtml += '<?xml version="1.0"?>'+CRLF
cHtml += '<?mso-application progid="Excel.Sheet"?>'+CRLF
cHtml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF
cHtml += ' xmlns:o="urn:schemas-microsoft-com:office:office"'+CRLF
cHtml += ' xmlns:x="urn:schemas-microsoft-com:office:excel"'+CRLF
cHtml += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF
cHtml += ' xmlns:html="http://www.w3.org/TR/REC-html40">'+CRLF
cHtml += ' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+CRLF
cHtml += '  <Author>'+cAutor+'</Author>'+CRLF
cHtml += '  <LastAuthor>'+cAutor+'</LastAuthor>'+CRLF
cHtml += '  <Created>'+cData+'</Created>'+CRLF
cHtml += '  <Version>12.00</Version>'+CRLF
cHtml += ' </DocumentProperties>'+CRLF
cHtml += ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
cHtml += '  <WindowHeight>6435</WindowHeight>'+CRLF
cHtml += '  <WindowWidth>14355</WindowWidth>'+CRLF
cHtml += '  <WindowTopX>360</WindowTopX>'+CRLF
cHtml += '  <WindowTopY>45</WindowTopY>'+CRLF
cHtml += '  <ProtectStructure>False</ProtectStructure>'+CRLF
cHtml += '  <ProtectWindows>False</ProtectWindows>'+CRLF
cHtml += ' </ExcelWorkbook>'+CRLF
cHtml += ' <Styles>'+CRLF

cHtml += '  <Style ss:ID="Default" ss:Name="Normal">'+CRLF
cHtml += '   <Alignment ss:Vertical="Bottom"/>'+CRLF
cHtml += '   <Borders/>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
cHtml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s01">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(255,255,255)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(196,196,196)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s02">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s03">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="0"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="0"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="0"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="0"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(255,255,255)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s04">'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="16" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s05">'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="12" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s06">'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="5" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s07">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="'+RGBToHexa(255,255,255)+'"'+CRLF
cHtml += '    ss:Bold="1"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(196,196,196)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Fixed"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s08">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(0,255,0)+'" ss:Pattern="Solid"/>'+CRLF
//cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Fixed"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s09">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,0)+'" ss:Pattern="Solid"/>'+CRLF
//cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Fixed"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s10">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,0,0)+'" ss:Pattern="Solid"/>'+CRLF
//cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Fixed"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += ' </Styles>'+CRLF
cHtml += ' <Names>'+CRLF
cHtml += '  <NamedRange ss:Name="Database" ss:RefersTo="=Nome da Pasta!R1C1:R2C6"/>'+CRLF
cHtml += ' </Names>'+CRLF

Return cHtml           

/*/{protheus.doc} RodSheetHtml
*******************************************************************************************
Cria o rodape do sheet.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function RodSheetHtml(cGuia,aTotais,nTotLinhas,aRodape,lFim)
Local cHtml := ""
Local nX	:= 1      
Local nY	:= 0 //->> Iniciar com zero
Local cTexto:= ""
Local cStylo:= ""   
Local cTipo	:= ""
Local nMerge:= 0

Default aTotais 	:= {}  
default nTotLinhas  := 0
Default aRodape 	:= {}
Default lFim		:= .F.

//->> Totalizantes
If Len(aTotais)>0	
	cHtml += '<Row ss:AutoFitHeight="0">'+CRLF
	For nX:=1 to Len(aTotais)
		If Len(aRodape) > 0
			If nMerge==0
				nY++
				
				If Len(aRodape)>= nY
					Do Case
						Case aRodape[nY,03] == "N"
							cTipo   := "Number"					
							If ValType(aRodape[nY,02])<>"U"
								cTexto 	:= Alltrim(Str(aRodape[nY,02]))
							Else
								cTexto  := NIL
							EndIf	
						
						Case aRodape[nY,03] == "D"
							cTipo	:= "String"   
							If ValType(aRodape[nY,02])<>"U"
								cTexto 	:= dToc(aRodape[nY,02])
							Else
								cTexto := NIL
							EndIf	
						
						Case aRodape[nY,03] == "C"
							cTipo	:= "String"
							If ValType(aRodape[nY,02])<>"U"
								cTexto 	:= NoAcento(Alltrim(aRodape[nY,02]))
							Else
								cTexto  := NIL
							EndIf					
					EndCase	
					cStylo := aRodape[nY,04]
					nMerge := aRodape[nY,01]
				EndIf
					
				//->> Uso dos estilos do rodape
				If Valtype(cTexto) <> "U"
					cHtml += '<Cell '+If(nMerge-1>0,' ss:MergeAcross="'+Alltrim(Str(nMerge-1))+'" ','')+' ss:StyleID="'+cStylo+'"><Data ss:Type="'+cTipo+'">'+cTexto+'</Data></Cell>'+CRLF
				Else      
					If Valtype(aTotais[nX])=="N"
						If nTotLinhas > 0						
							cHtml += '<Cell ss:Index="'+Alltrim(Str(nX))+'" '+If(nMerge-1>0,' ss:MergeAcross="'+Alltrim(Str(nMerge-1))+'" ','')+' ss:StyleID="'+cStylo+'" ss:Formula="=SUM(R[-'+Alltrim(Str(nTotLinhas))+']C:R[-1]C)"><Data'+CRLF
			      			cHtml += 'ss:Type="Number">'+Alltrim(Str(aTotais[nX]))+'</Data></Cell>'+CRLF    	      		
			      		EndIf	
		      		EndIf	
				EndIf
			
			EndIf
			
			//->> Considerar o merge
			nMerge-=1
			
		Else			
			//->> Nao tendo rodape, usar o estilo default
			If ValType(aTotais[nX])=="C"
				cHtml += '<Cell><Data ss:Type="String"> </Data></Cell>'+CRLF
			Else
				cHtml += '<Cell ss:Index="'+Alltrim(Str(nX))+'" ss:StyleID="Default" ss:Formula="=SUM(R[-'+Alltrim(Str(nTotLinhas))+']C:R[-1]C)"><Data'+CRLF
	      		cHtml += 'ss:Type="Number">'+Alltrim(Str(aTotais[nX]))+'</Data></Cell>'+CRLF    
			EndIf		
	    EndIf       	    
	Next nX	
	cHtml += '</Row>'+CRLF
EndIf

If lFim
	cHtml += '  </Table>'+CRLF
	cHtml += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
	cHtml += '   <PageSetup>'+CRLF
	cHtml += '    <Header x:Margin="0.4921259845"/>'+CRLF
	cHtml += '    <Footer x:Margin="0.4921259845"/>'+CRLF
	cHtml += '    <PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"'+CRLF
	cHtml += '     x:Right="0.78740157499999996" x:Top="0.984251969"/>'+CRLF
	cHtml += '   </PageSetup>'+CRLF
	cHtml += '   <Unsynced/>'+CRLF
	cHtml += '   <Print>'+CRLF
	cHtml += '    <ValidPrinterInfo/>'+CRLF
	cHtml += '    <HorizontalResolution>600</HorizontalResolution>'+CRLF
	cHtml += '    <VerticalResolution>600</VerticalResolution>'+CRLF
	cHtml += '   </Print>'+CRLF
	If !Empty(cGuia)
		cHtml += '  <TabColorIndex>21</TabColorIndex>'+CRLF
	EndIf
	cHtml += '   <Panes>'+CRLF
	cHtml += '    <Pane>'+CRLF
	cHtml += '     <Number>3</Number>'+CRLF
	cHtml += '     <ActiveRow>8</ActiveRow>'+CRLF
	cHtml += '     <ActiveCol>1</ActiveCol>'+CRLF
	cHtml += '    </Pane>'+CRLF
	cHtml += '   </Panes>'+CRLF
	cHtml += '   <ProtectObjects>False</ProtectObjects>'+CRLF
	cHtml += '   <ProtectScenarios>False</ProtectScenarios>'+CRLF
	cHtml += '  </WorksheetOptions>'+CRLF
	cHtml += ' </Worksheet>'+CRLF
EndIf
	
Return cHtml

/*/{protheus.doc} L010Dec2Hex
*******************************************************************************************
Converte um numero decimal ate' 255 para hexadecimal.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function L010Dec2Hex(nVal)
Local cString := "0123456789ABCDEF"
Return(Substr(cString,Int(nVal/16)+1,1)+Substr(cString,nVal-(Int(nVal/16)*16)+1,1))

/*/{protheus.doc} RGBToHexa
*******************************************************************************************
Retorna o codigo da cor em hexadecimal.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function RGBToHexa(nR,nG,nB)
Local cCor := "#"+L010Dec2Hex(nR)+L010Dec2Hex(nG)+L010Dec2Hex(nB)
Return cCor

/*/{protheus.doc} NoAcento
*******************************************************************************************
Retorna a String sem acento.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"
Local cComer := "&"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf  
		nY:= At(cChar,cComer)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("e",nY,1))
		EndIf		
	EndIf
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	EndIf
Next nX
Return cString

// ***********************************************************************************************>> FERRAMENTA DE EXPORTACAO

/*/{protheus.doc} MCRFAT010A
*******************************************************************************************

 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function MCRFAT010A()
Local oWizard
Local aParambox 	:= {} 
Local lOk		 	:= .F.

Private aRetParam 	:= {}
Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

//->> Ajuste da Consulta Padrao
AjustaSXB()
              
aRetParam := {Criavar("A3_COD",.F.),Criavar("A3_COD",.F.),Year(dDatabase),Month(dDatabase),Space(150),.F.,Space(150),.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,1}

aAdd(aParambox,{1,"Vendedor de" 				,aRetParam[01],"@!","","SA3" 	,".T.",40 ,.F.	})
aAdd(aParambox,{1,"Vendedor ate" 				,aRetParam[02],"@!","","SA3" 	,".T.",40 ,.F.	})
aAdd(aParambox,{1,"Ano" 						,aRetParam[03],"@!","","" 		,".T.",30 ,.F.	})
aAdd(aParambox,{2,"Mês" 						,aRetParam[04],aMeses,100,".T.",.T.})
aAdd(aParambox,{1,"Pasta Gravação"				,aRetParam[05],"@!","","MCPST"  ,".T.",180,.T.	})
AADD(aParambox,{5,"Envia e-Mail ao Vendedor" 	,aRetParam[06],150,".T.",.F.})
aAdd(aParambox,{1,"Email CC"					,aRetParam[07],"","",""  		,".T.",180,.F.	})
AADD(aParambox,{5,"Resumo do Cliente" 			,aRetParam[08],150,".T.",.F.})
AADD(aParambox,{5,"Pedidos em Abertos" 			,aRetParam[09],150,".T.",.F.})
AADD(aParambox,{5,"Pedidos em Saldo do Cliente" ,aRetParam[10],150,".T.",.F.})
AADD(aParambox,{5,"Devoluções" 					,aRetParam[11],150,".T.",.F.})
AADD(aParambox,{5,"Bonificação" 				,aRetParam[12],150,".T.",.F.})
AADD(aParambox,{5,"Meta Real" 					,aRetParam[13],150,".T.",.F.})
AADD(aParambox,{5,"Meta Real por Valor" 		,aRetParam[14],150,".T.",.F.})
AADD(aParambox,{5,"Meta Real por Produto" 		,aRetParam[15],150,".T.",.F.})
AADD(aParambox,{3,"Relatório",aRetParam[16],{"Analitico por Vendedor","Sintético"},150,".T.",.T.,".T."})  

DEFINE WIZARD oWizard ;
	TITLE "Relatórios Gerenciais" ;
          	HEADER "Visões por Vendedor" ;
          	MESSAGE "Avance para Continuar" 		;
          	TEXT "Este procedimento deverá gerar em Planilhas Eletrõnicas no formato Excel, os relatórios Gerenciais nas Visões por Vendedor." PANEL;
          	NEXT {|| .T. } ;
          	FINISH {|| .T. }; 
          	          	                            
   	CREATE PANEL oWizard ;				
          	HEADER "Visões por Vendedor" ;
          	MESSAGE "Informe os parametros para a Extração do Relatório" PANEL;          	          	
          	NEXT {|| 	lOK := ConfProcess() } ;
          	FINISH {|| 	lOK := ConfProcess() } ;
          	PANEL
   	
   	Parambox(aParambox,"Parametros de Geracao"	,@aRetParam,,,.T.,,,oWizard:GetPanel(2),,.F.,.F.)
ACTIVATE WIZARD oWizard CENTERED

If lOk	                 
	Processa({|x| ProcRelato(.F.) },"Processando","Aguarde, Extraindo Relatório Gerencial",.F.)			
EndIf
	
Return

/*/{protheus.doc} ConfProcess
*******************************************************************************************
Confirma a Exportação dos dados
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ConfProcess()
Local lRet 	 := .T.
Local nHdl	 := 0
Local cPasta := Alltrim(aRetParam[05])
Local cPath	 := ""
      
If Empty(cPasta)
	MsgAlert("A Pasta destino para a gravação das Planilhas Eletrônicas não é válida ou você não tem permissão para gravar nesse local."+CRLF+"Selecione uma Pasta válida para continuar.")	
    lRet := .F.
Else
	cPasta += If(Right(cPasta,1)=="\","","\")
	cPath := cPasta+"Teste_"+Criatrab(,.F.)+".Tst"
	
	nHdl := fCreate(cPath)
	If nHdl <= 0     
		MsgAlert("A Pasta destino para a gravação das Planilhas Eletrônicas não é válida ou você não tem permissão para gravar nesse local."+CRLF+"Selecione uma Pasta válida para continuar.")
	    lRet := .F.
	Else
		fClose(nHdl)
		FErase(cPath)
	EndIf
EndIf

If ValType(aRetParam[04]) <> "N"
	aRetParam[04] := Ascan(aMeses,{|x| Alltrim(x)==Alltrim(aRetParam[04]) })
EndIf

If lRet	
	If aRetParam[03] < 1997 .Or. aRetParam[03] > Year(dDatabase)
		lRet := .F.
		MsgAlert("Ano de Extração Inválido...")
	EndIf
EndIf	   
	
If lRet	
	lRet := MsgYesNo("Confirma a Geração da Planilha Eletrônica de Visões Gerenciais por Vendedor?")
EndIf

Return lRet

/*/{protheus.doc} AjustaSXB
*******************************************************************************************
Ajusta Consulta Padrao de Pasta.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustaSXB()
Local aSXB		:= {}  
Local aEstrut	:= {}
Local i, j
Local aArea		:= GetArea()     

aEstrut:= {"XB_ALIAS"	,"XB_TIPO"	,"XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"					,"XB_DESCSPA"					,"XB_DESCENG"			 		,"XB_CONTEM"		}
Aadd( aSXB,	{"MCPST"	,"1"		,"01"		,"RE"			,"Pasta Gravação da Planilha"	,"Pasta Gravação da Planilha"	,"Pasta Gravação da Planilha"	,"SA3"				})
Aadd( aSXB,	{"MCPST"	,"2"		,"01"		,"01"			,""				   				,""						   		,""						   		,".T."				})
Aadd( aSXB,	{"MCPST"	,"5"		,"01"		,""				,""								,""						   		,""						   		,"u_McGetPPSG()"	})	

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

/*/{protheus.doc} McGetPPSG
*******************************************************************************************
Retorna a Pasta.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function McGetPPSG()
Local cPasta 	:= ""

cPasta := Alltrim( cGetFile("Diretorios", "Diretorio para a Gravação da Planilha",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
aRetParam[05]  := cPasta

Return

/*/{protheus.doc} ProcRelato
*******************************************************************************************
Processamento do Relatório
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcRelato(lJob,nTipoExtr)
Local oExcel		:= NIL
Local aPlanilha 	:= {}
Local cArquivo		:= ""
Local cPasta		:= ""
Local cHRIni   		:= ""
Local cHRFim   		:= ""
Local aVendedor		:= {}
Local nX			:= 1
Local dInicio		:= Stod("")
Local dFim			:= Stod("")
Local cPastServ	 	:= "\RELGER\"

Default nTipoExtr	:= 1

cHRIni := dToc(Date()) +" "+ Time()

//->> Retorna os Vendedores
If lJob
	dInicio	:= dDatabase
	dFim	:= dInicio
	dInicio := Stod(StrZero(Year(dInicio),4)+StrZero(Month(dInicio),2)+"01")
	
	Private aRetParam 	:= {}
	aRetParam := {Replicate(" ",Tamsx3("A3_COD")[01]),Replicate("Z",Tamsx3("A3_COD")[01]),dInicio,dFim,cPastServ,.T.,"",.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,nTipoExtr}
	MakeDir(cPastServ)
	
Else
	dInicio := Stod(StrZero(aRetParam[03],4)+StrZero(aRetParam[04],2)+"01")
	dFim 	:= LastDay(Stod(StrZero(aRetParam[03],4)+StrZero(aRetParam[04],2)+"01"))
EndIf

If aRetParam[16] == 1
	aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf
		aPlanilha := {}
		aAdd(aPlanilha,GetPlanilha(aVendedor[nX,01],dInicio,dFim,lJob))	
		
		If Len(aPlanilha)>0
			cArquivo := cNomeArq+Alltrim(aVendedor[nX,01])
			cPasta	 := Alltrim(aRetParam[05])
			cPasta   += If(Right(cPasta,1)=="\","","\")
			
			oExcel := McGeraHtml():New(aPlanilha,aRetParam[05],@cArquivo)
			oExcel:WriteHtml()		
			oExcel:EnviaEmail(cPasta,cArquivo+".xml",lJob)
			FreeObj(oExcel)
			oExcel := NIL		
		EndIf			
	Next nX
Else     
	If !lJob
		ProcRegua(0)
		IncProc("Gerando o Relatório...")
	EndIf 
	
	aPlanilha := {}
	aAdd(aPlanilha,GetPlanilha(NIL,dInicio,dFim,lJob))
	
	cArquivo := cSintNomeArq
	cPasta	 := Alltrim(aRetParam[05])
	cPasta   += If(Right(cPasta,1)=="\","","\")
	
	oExcel := McGeraHtml():New(aPlanilha,aRetParam[05],@cArquivo)
	oExcel:WriteHtml()		
	oExcel:EnviaEmail(cPasta,cArquivo+".xml",lJob)
	FreeObj(oExcel)
	oExcel := NIL
EndIf	
	
cHRFim := dToc(Date()) +" "+ Time()

Return

/*/{protheus.doc} GetPlanilha
*******************************************************************************************
Retorna a planilha
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetPlanilha(cVendedor,dDataDe,dDataAte,lJob)
Local aCols		:= {}
Local aHeader   := {}
Local aCabec	:= {}
Local aRodape	:= {}
Local aDados	:= {}
Local nX		:= 1
Local aPlanilha := {}
Local nPosPlan	:= 0
Local aTitulos	:= {}
Local nValorCalc:= 0

//->> Extracao dos Dados
If aRetParam[16] == 1	
	//->> Resumo de Clientes
	If aRetParam[08]
		aAdd(aPlanilha,{"Resumo-Cliente",{},{"RESUMO POR CLIENTE","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		//->> Resumo por quantidade
		aCols  := {}
		aHeader:= GetaHeader(1,@aCabec,@aRodape)
		aDados := GetaCols(1,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
		
		//->> Pulo de Linha
		aCols  := {}
		aHeader:= GetaHeader(10,@aCabec,@aRodape,Len(aHeader))
		aDados := GetaCols(10,NIL,NIL,NIL,lJob,Len(aHeader)+1)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX           
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
		
		//->> Resumo por valor
		aCols  := {}
		aHeader:= GetaHeader(9,@aCabec,@aRodape)
		aDados := GetaCols(9,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX           
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
		                        
	//->> Pedidos em Aberto
	If aRetParam[09]
		aAdd(aPlanilha,{"PedidosAbertos",{},{"PEDIDOS EM ABERTO","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(2,@aCabec,@aRodape)
		aDados := GetaCols(2,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
		
	//->> Pedidos Saldo Cliente
	If aRetParam[10]
		aAdd(aPlanilha,{"PedidoSaldoCliente",{},{"PEDIDOS EM ABERTO POR MES/CLIENTE","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(3,@aCabec,@aRodape)
		aDados := GetaCols(3,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
	
	//->> Devoluções
	If aRetParam[11]
		aAdd(aPlanilha,{"Devolucoes",{},{"DEVOLUCOES","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(4,@aCabec,@aRodape)
		aDados := GetaCols(4,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX           
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
		
	//->> Bonificação
	If aRetParam[12]
		aAdd(aPlanilha,{"Bonificacao",{},{"INVESTIMENTOS","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(5,@aCabec,@aRodape)
		aDados := GetaCols(5,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX           
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
		
	//->> Meta Real
	If aRetParam[13]
		aAdd(aPlanilha,{"Meta Caixa",{},{"META x REALIZADO MENSAL","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(6,@aCabec,@aRodape)
		aDados := GetaCols(6,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
		
	//->> Meta Valor
	If aRetParam[14]
		aAdd(aPlanilha,{"MetaRealValor",{},{"META x REALIZADO MENSAL","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(7,@aCabec,@aRodape)
		aDados := GetaCols(7,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
	
	//->> Meta Produto
	If aRetParam[15]
		aAdd(aPlanilha,{"MetaRealProduto",{},{"META x REALIZADO MENSAL","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(8,@aCabec,@aRodape)
		aDados := GetaCols(8,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	EndIf
	
	//->> Comissao Calculada
	aAdd(aPlanilha,{"Comissao Calculada",{},{"COMISSAO CALCULADA","REPRESENTANTE: "+Alltrim(SA3->A3_NOME),"PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
	nPosPlan := Len(aPlanilha)
	aCols  := {}
	aHeader:= GetaHeader(11,@aCabec,@aRodape)
	aDados := GetaCols(11,cVendedor,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})	
	
Else
	//->> Resumo Operação
	aAdd(aPlanilha,{"Resumo Operacao",{},{"RESUMO VALOR ORCADO DIARIO DENTRO DO PERIODO (30 DIAS)","RESUMO VALOR FATURADO DIARIO DENTRO DO PERIODO (30 DIAS)",""}})
	nPosPlan := Len(aPlanilha)
	aCols  := {}
	aHeader:= GetaHeader(13,@aCabec,@aRodape)
	aDados := GetaCols(13,NIL,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})    
    	
    	
	//->> Resumo de Clientes Sintetizado
	aAdd(aPlanilha,{"Consolidado Cliente",{},{"RESUMO POR CLIENTE","SINTETIZADO","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
	nPosPlan := Len(aPlanilha)
	
	//->> Resumo por valor
	aCols  := {}
	aHeader:= GetaHeader(15,@aCabec,@aRodape)
	aDados := GetaCols(15,cVendedor,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX           
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	
	//->> Pulo de Linha
	aCols  := {}
	aHeader:= GetaHeader(10,@aCabec,@aRodape,Len(aHeader))
	aDados := GetaCols(10,NIL,NIL,NIL,lJob,Len(aHeader)+1)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX           
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	
    
	//->> Resumo por quantidade
	aCols  := {}
	aHeader:= GetaHeader(14,@aCabec,@aRodape)
	aDados := GetaCols(14,cVendedor,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX	
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	//->> Resumo de Produtos Sintetizado
	aAdd(aPlanilha,{"Consolidado Produtos",{},{"RESUMO POR PRODUTO","SINTETIZADO","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
	nPosPlan := Len(aPlanilha)
	
	//->> Resumo por valor
	aCols  := {}
	aHeader:= GetaHeader(17,@aCabec,@aRodape)
	aDados := GetaCols(17,cVendedor,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX           
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})    
	
	//->> Pulo de Linha
	aCols  := {}
	aHeader:= GetaHeader(10,@aCabec,@aRodape,Len(aHeader))
	aDados := GetaCols(10,NIL,NIL,NIL,lJob,Len(aHeader)+1)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX           
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	 
	//->> Resumo por quantidade
	aCols  := {}
	aHeader:= GetaHeader(16,@aCabec,@aRodape)
	aDados := GetaCols(16,cVendedor,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX	
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})             
	
	//->> Pedidos em Aberto sintetizado

		aAdd(aPlanilha,{"PedidosAbertos",{},{"PEDIDOS EM ABERTO","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(19,@aCabec,@aRodape)
		aDados := GetaCols(19,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})

	
	//->> Pedidos Saldo Cliente Sintetizado
		aAdd(aPlanilha,{"PedidoSaldoCliente",{},{"PEDIDOS EM ABERTO POR MES/CLIENTE","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(18,@aCabec,@aRodape)
		aDados := GetaCols(18,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX	
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	
	//->> Meta Real Valor - Sintetica
	    aAdd(aPlanilha,{"MetaRealValor",{},{"META x REALIZADO MENSAL","OPERADORE"+"S","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
		nPosPlan := Len(aPlanilha)
		
		aCols  := {}
		aHeader:= GetaHeader(20,@aCabec,@aRodape)
        aDados := GetaCols(20,dDataDe,dDataAte,lJob)
//	 aDados := GetaCols(20,cVendedor,dDataDe,dDataAte,lJob)
		For nX:=1 to Len(aDados)
			aAdd(aCols,aDados[nX])
		Next nX
		aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	

	//->> Comissao Calculada Sintetizada
	aAdd(aPlanilha,{"Comissao Calculada",{},{"COMISSAO CALCULADA","SINTETIZADO","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
	nPosPlan := Len(aPlanilha)
	aCols  := {}
	aHeader:= GetaHeader(12,@aCabec,@aRodape)
	aDados := GetaCols(12,NIL,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	
	//->> Total por vendedor - Sintetizada
	aAdd(aPlanilha,{"Total por Vendedor",{},{"TOTAL POR VENDEDOR","SINTETIZADO","PERIODO: "+Dtoc(dDataDe)+" - "+Dtoc(dDataAte)}})
	nPosPlan := Len(aPlanilha)
	aCols  := {}
	aHeader:= GetaHeader(21,@aCabec,@aRodape)
	aDados := GetaCols(21,NIL,dDataDe,dDataAte,lJob)
	For nX:=1 to Len(aDados)
		aAdd(aCols,aDados[nX])
	Next nX
	aAdd(aPlanilha[nPosPlan][02],{aHeader,aCols,aCabec,aRodape})
	

EndIf
	
Return aPlanilha

/*/{protheus.doc} GetaCols
*******************************************************************************************
Selecao dos dados.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaCols(nTipo,cVendedor,dDataDe,dDataAte,lJob,nTamanho)
Local aDados 	:= {}
Local aDadTmp	:= {}
Local nX	 	:= 1
Local dX		:= Stod("")
Local cAlias 	:= GetNextAlias()
Local cQuery 	:= ""
Local cTesBonif := Upper(Alltrim(GetNewPar("MC_TESBONI","")))
Local cTesVends := Upper(Alltrim(GetNewPar("MC_TESVNDS","")))
Local nQtde		:= 0
Local nValor	:= 0
Local nSaldo	:= 0
Local nPcAting	:= 0
Local nPcParc	:= 0
Local aDatas	:= {}
Local cAno		:= ""
Local nPos		:= 0
Local nDias		:= 0
Local nDiasMes	:= 0
Local nComiss	:= 0
Local nMetVlr	:= 0
Local nMetQtd	:= 0
Local nQtdRegs	:= 0
Local cTpVend	:= If(SA3->(FieldPos("A3_TIPOVEN"))>0,SA3->A3_TIPOVEN,"")
Local nPCComRep := 0
Local nPcAtQtde	:= 0
Local nPcAtValor:= 0
Local nPgNaQtde := 0
Local nPgNoValor:= 0
Local cPerAnter	:= ""
Local nPCA_QTDE := 0
Local nPCB_QTDE := 0
Local nPCC_QTDE := 0
Local nPCA_VALOR:= 0
Local nPCB_VALOR:= 0
Local nPCC_VALOR:= 0
Local nPcComis	:= 0
Local aVendedor := {}

Default nTamanho := 0

cTesBonif := FormatIn(cTesBonif,";")
cTesVends := FormatIn(cTesVends,";")

If nTipo==1
	// Resumo de Cliente - Quantidade
	nDias	:= dDataAte-dDataDe
	nDiasMes:= LastDay(dDataAte)-dDataDe
	
	If Month(dDataDe)==1
		cPerAnter := "12"+StrZero(Year(dDataDe)-1,4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe)-1,4)+'1201')
	Else
		cPerAnter := StrZero(Month(dDataDe)-1,2)+StrZero(Year(dDataDe),4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe),4)+StrZero(Month(dDataDe)-1,2)+'01')
	EndIf
		
	dFimAnt := LastDay(dIniAnt)		
	
		cQuery := "SELECT VENDAS.CLIENTE,"+CRLF
		cQuery += "             VENDAS.LOJA,"+CRLF
		cQuery += "             VENDAS.NOME,"+CRLF
		cQuery += "             VENDAS.QUANTIDADE,"+CRLF
		cQuery += "             VENDAS.VALOR,"+CRLF
		cQuery += "             VENDAS.VNDVLANTER,"+CRLF
		cQuery += "             VENDAS.VNDQTANTER,"+CRLF

		cQuery += "             SCT.CT_VALOR METAVALOR,"+CRLF
		cQuery += "             SCT.CT_QUANT METAQUANT,"+CRLF  

		cQuery += "             SCTANTER.CT_VALOR METVLANTER,"+CRLF
		cQuery += "             SCTANTER.CT_QUANT METQTANTER"+CRLF

		cQuery += "  FROM (SELECT"+CRLF
		cQuery += "			   SA1.A1_FILIAL   AS FILIAL,"+CRLF
		cQuery += "			   SA1.A1_VEND     AS VENDEDOR,"+CRLF
		cQuery += "			   SA1.A1_NREDUZ   AS NOME,"+CRLF
		cQuery += "			   SA1.A1_COD  	   AS CLIENTE,"+CRLF
		cQuery += "			   SA1.A1_LOJA     AS LOJA,"+CRLF

		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_TOTAL ELSE 0 END) AS VALOR,"+CRLF
		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_QUANT ELSE 0 END) AS QUANTIDADE,"+CRLF

		cQuery += "					(SELECT SUM(SD2ANT.D2_TOTAL) "+CRLF
		cQuery += "						 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"+CRLF
		cQuery += "								ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"+CRLF
		cQuery += "								AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"+CRLF
		cQuery += "								AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"+CRLF
		cQuery += "								AND SD2ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"+CRLF
		cQuery += "								 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "								 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"+CRLF
		cQuery += "								 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"+CRLF
		cQuery += "								 AND SA1ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "						WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "							AND SA1ANT.A1_COD  = SA1.A1_COD"+CRLF
		cQuery += "							AND SA1ANT.A1_LOJA = SA1.A1_LOJA"+CRLF
		cQuery += "							AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"+CRLF
		cQuery += "							  OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"+CRLF
		cQuery += "							AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		cQuery += "							AND SD2ANT.D2_TES IN "+cTesVends + CRLF
		cQuery += "							AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDVLANTER, "+CRLF

		//->> Novo		               
		cQuery += "			(SELECT SUM(SD2ANT.D2_QUANT) 
	    cQuery += "				 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"										+CRLF
	    cQuery += "					INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"								+CRLF
	    cQuery += "			 			ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"									+CRLF
		cQuery += "						AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"										+CRLF
		cQuery += "						AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"									+CRLF
		cQuery += "						AND SD2ANT.D_E_L_E_T_ = ' '"												+CRLF
		cQuery += "					INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"								+CRLF
		cQuery += "						 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
		cQuery += "						 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"									+CRLF
		cQuery += "						 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"									+CRLF
		cQuery += "						 AND SA1ANT.D_E_L_E_T_ = ' '"												+CRLF		
		cQuery += "				WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF		
		cQuery += "					AND SA1ANT.A1_COD  = SA1.A1_COD"											    +CRLF
		cQuery += "					AND SA1ANT.A1_LOJA = SA1.A1_LOJA"												+CRLF		
		cQuery += "					AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"										+CRLF
		cQuery += "					 OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"										+CRLF	
		cQuery += "		    		AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dIniAnt)+"' AND '"+dTos(dFimAnt)+"'"		+CRLF
		cQuery += "		    		AND SD2ANT.D2_TES IN "+cTesVends												+CRLF		
		cQuery += "				    AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDQTANTER"										+CRLF
		//Fim

		cQuery += "		  FROM SA1010 SA1 (NOLOCK)"+CRLF

		cQuery += "		  LEFT JOIN SF2010 SF2 (NOLOCK)"+CRLF
		cQuery += "			ON SA1.A1_COD     = SF2.F2_CLIENTE"+CRLF
		cQuery += "		   AND SA1.A1_LOJA    = SF2.F2_LOJA"+CRLF
		cQuery += "		   AND SF2.F2_FILIAL  = '"+xFilial("SA1")+"'" + CRLF
		cQuery += "		   AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF

		cQuery += "		  LEFT JOIN SD2010 SD2 (NOLOCK)"+CRLF
		cQuery += "			ON SD2.D2_FILIAL  = SF2.F2_FILIAL"+CRLF
		cQuery += "		   AND SD2.D2_DOC     = SF2.F2_DOC"+CRLF
		cQuery += "		   AND SD2.D2_SERIE   = SF2.F2_SERIE"+CRLF
		cQuery += "		   AND SD2.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "		  WHERE (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		   AND SA1.A1_FILIAL  = '"+xFilial("SF2")+"'"+CRLF
		cQuery += "        AND SA1.A1_MSBLQL  <> '1'"+CRLF
		cQuery += "		   AND SA1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "		 GROUP BY SA1.A1_COD,"+CRLF
		cQuery += "				  SF2.F2_CLIENTE,"+CRLF
		cQuery += "				  SA1.A1_LOJA,	 		"+CRLF											
		cQuery += "				  SA1.A1_NREDUZ,"+CRLF
		cQuery += "				  SA1.A1_FILIAL,"+CRLF
		cQuery += "			          SA1.A1_VEND"+CRLF
		cQuery += ") VENDAS"+CRLF
                                       
		cQuery += "   LEFT JOIN SCT010 SCT (NOLOCK)"+CRLF
		cQuery += "    ON SCT.CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCT.CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCT.CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"+CRLF
		cQuery += "   AND SCT.CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCT.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "  LEFT JOIN SCT010 SCTANTER (NOLOCK)"+CRLF
		cQuery += "    ON SCTANTER .CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCTANTER .CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCTANTER .CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCTANTER .CT_DATAMET = '"+cPerAnter+"'"+CRLF
		cQuery += "   AND SCTANTER .CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCTANTER .D_E_L_E_T_ = ' '"+CRLF

		cQuery += " ORDER BY VENDAS.NOME"+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	                                                                                                                                
		nQtde    := (cAlias)->METAQUANT
		nPcAting := Round(((cAlias)->QUANTIDADE / nQtde) * 100,2)
		nSaldo	 := (cAlias)->QUANTIDADE - (cAlias)->METAQUANT
		nPcParc  := Round(((cAlias)->QUANTIDADE / ((nQtde/nDiasMes)*nDias)) * 100,2)
		
		nSldAnter := (cAlias)->VNDQTANTER - (cAlias)->METQTANTER
		
    	aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,	;	// 01 - Cliente
    				 Alltrim((cAlias)->NOME),				; 	// 02 - Nome
    				 nSldAnter,								;	// 03 - Qtd. Un.Saldo Mês Ant.
    				 nQtde,									;	// 04 - Qtd. Meta Un. Mês
    				 (cAlias)->QUANTIDADE,					;	// 05 - Qtd. Faturado
    				 nPcAting,								;	// 06 - % Atingimento
    				 nSaldo,								;	// 07 - Qtd. Saldo
    				 0,										;	// 08 - Pedidos Total | Por Dezena
    				 0,										;	// 09 - % Valor Pedidos Por Dezena
    				 0,										;	// 10 - Atingiu     				 
    				 nPcParc}								)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
	
ElseIf nTipo==2
	// Pedidos em Aberto
	cQuery := "SELECT DISTINCT"																	+CRLF
	cQuery += "		  SC5.R_E_C_N_O_ AS RECSC5,"												+CRLF
	cQuery += "		  SC6.R_E_C_N_O_ AS RECSC6,"												+CRLF
	cQuery += "		  SB1.R_E_C_N_O_ AS RECSB1,"												+CRLF
	cQuery += "		  SA1.R_E_C_N_O_ AS RECSA1"	 												+CRLF
	cQuery += "	 FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"										+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK)"								+CRLF
	cQuery += "			 ON SC5.C5_FILIAL  = SC6.C6_FILIAL"										+CRLF
	cQuery += "			AND SC5.C5_NUM	   = SC6.C6_NUM"										+CRLF
	cQuery += "			AND SC5.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"								+CRLF
	cQuery += "			AND SB1.B1_COD	   = SC6.C6_PRODUTO"									+CRLF
	cQuery += "			AND SB1.D_E_L_E_T_ = ' '"												+CRLF		
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
	cQuery += "			AND SA1.A1_COD	   = SC5.C5_CLIENTE"									+CRLF
	cQuery += "			AND SA1.A1_LOJA	   = SC5.C5_LOJACLI"									+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		WHERE  SC6.C6_FILIAL = '"+xFilial("SC6")+"'"								+CRLF
	cQuery += "		   AND SC6.C6_QTDVEN > SC6.C6_QTDENT"										+CRLF
	cQuery += "		   AND SC5.C5_TIPO    = 'N'"												+CRLF
	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"								+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"								+CRLF	
	cQuery += "		   AND SC5.C5_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//	cQuery += "		   AND SC6.C6_TES NOT IN "+cTesBonif										+CRLF
	cQuery += "		   AND SC6.C6_TES IN "+cTesVends											+CRLF		
	cQuery += "		   AND SC6.D_E_L_E_T_ = ' '"												+CRLF	
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())
		SC5->(dbGoto((cAlias)->RECSC5))
		SC6->(dbGoto((cAlias)->RECSC6))
		SB1->(dbGoto((cAlias)->RECSB1))
		SA1->(dbGoto((cAlias)->RECSA1))
	
		aAdd(aDados,{SC5->C5_EMISSAO,									; // 01 - Data Previsão
					 SC5->C5_NUM,										; // 02 - Pedido
					 SC6->C6_ITEM,										; // 03 - Item
					 SA1->A1_COD+"-"+SA1->A1_LOJA,						; // 04 - Cliente
					 Alltrim(SA1->A1_NREDUZ),							; // 05 - Nome
					 SB1->B1_COD,										; // 06 - Produto
					 Alltrim(SB1->B1_DESC),								; // 07 - Descrição
					 SC6->C6_QTDVEN - SC6->C6_QTDENT,					; // 08 - Qtde Saldo
					 (SC6->C6_QTDVEN - SC6->C6_QTDENT)*SC6->C6_PRCVEN } ) // 09 - Valor Saldo
	     
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
		
ElseIf nTipo==3
	// Pedidos Saldo Cliente
	cQuery := "SELECT"																			+CRLF
	cQuery += "		  SC5.C5_EMISSAO										AS MES,"			+CRLF
	cQuery += "		  SC5.C5_CLIENTE										AS CLIENTE,"		+CRLF
	cQuery += "		  SC5.C5_LOJACLI										AS LOJA,"			+CRLF
	cQuery += "		  SA1.A1_NREDUZ											AS NOME,"			+CRLF	
	cQuery += "		  SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) 					AS QTD_SALDO,"		+CRLF
	cQuery += "		  SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT)*SC6.C6_PRCVEN)  	AS VLR_SALDO"		+CRLF
	cQuery += "	 FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"										+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK)"								+CRLF
	cQuery += "			 ON SC5.C5_FILIAL  = SC6.C6_FILIAL"										+CRLF
	cQuery += "			AND SC5.C5_NUM	   = SC6.C6_NUM"										+CRLF
	cQuery += "			AND SC5.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
	cQuery += "			AND SA1.A1_COD	   = SC5.C5_CLIENTE"									+CRLF
	cQuery += "			AND SA1.A1_LOJA	   = SC5.C5_LOJACLI"									+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"												+CRLF		
	cQuery += "		WHERE  SC6.C6_FILIAL = '"+xFilial("SC6")+"'"								+CRLF
	cQuery += "		   AND SC6.C6_QTDVEN > SC6.C6_QTDENT"										+CRLF
	cQuery += "		   AND SC5.C5_TIPO    = 'N'"												+CRLF
	cQuery += "		   AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"								+CRLF		
	cQuery += "		   AND SC5.C5_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//  cQuery += "		   AND SC6.C6_TES NOT IN "+cTesBonif										+CRLF
	cQuery += "		   AND SC6.C6_TES IN "+cTesVends											+CRLF	
	cQuery += "		   AND SC6.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "	GROUP BY SC5.C5_EMISSAO,"														+CRLF 
	cQuery += "			 SC5.C5_CLIENTE,"														+CRLF 
	cQuery += "			 SC5.C5_LOJACLI,"														+CRLF 
	cQuery += "			 SA1.A1_NREDUZ"															+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
		aAdd(aDados,{SubStr((cAlias)->MES,1,4)+"-"+SubStr((cAlias)->MES,5,2),	; // 01 - Mês
					 (cAlias)->CLIENTE+"-"+(cAlias)->LOJA,						; // 02 - Cliente
					 Alltrim((cAlias)->NOME),									; // 03 - Nome
					 (cAlias)->QTD_SALDO,										; // 04 - Qtde Saldo
					 (cAlias)->VLR_SALDO}										) // 05 - Valor Saldo
		
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==4
	// Devoluções
	cQuery := "SELECT "																				+CRLF
	cQuery += "		  SF1.F1_FILIAL		AS FILIAL,"													+CRLF
	cQuery += "		  SF1.F1_DOC		AS DOCUMENTO,"												+CRLF
	cQuery += "		  SF1.F1_SERIE		AS SERIE,"													+CRLF
	cQuery += "		  SF1.F1_FORNECE	AS FORNECEDOR,"												+CRLF
	cQuery += "		  SF1.F1_LOJA		AS LOJA,"													+CRLF
	cQuery += "		  SA1.A1_COD  		AS CLIENTE,"												+CRLF
	cQuery += "		  SA1.A1_LOJA 		AS LOJA,"													+CRLF
	cQuery += "		  SA1.A1_NREDUZ		AS NOME,"													+CRLF
	cQuery += "		  SD1.D1_TES		AS TES,"													+CRLF	
	cQuery += "		  SUM(SD1.D1_TOTAL) AS VALOR"													+CRLF	
	cQuery += "	 FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"											+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK)"  								+CRLF
	cQuery += "				ON  SF1.F1_FILIAL  = SD1.D1_FILIAL"										+CRLF
	cQuery += "				AND SF1.F1_DOC     = SD1.D1_DOC"										+CRLF
	cQuery += "				AND SF1.F1_SERIE   = SD1.D1_SERIE"										+CRLF
	cQuery += "				AND SF1.F1_FORNECE = SD1.D1_FORNECE"									+CRLF
	cQuery += "				AND SF1.F1_LOJA    = SD1.D1_LOJA"										+CRLF	
    cQuery += "				AND SF1.D_E_L_E_T_ = ' '"												+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"  								+CRLF
	cQuery += "				ON  SD2.D2_FILIAL  = SD1.D1_FILIAL"										+CRLF
	cQuery += "				AND SD2.D2_DOC     = SD1.D1_NFORI"										+CRLF
	cQuery += "				AND SD2.D2_SERIE   = SD1.D1_SERIORI"									+CRLF
	cQuery += "				AND SD2.D2_ITEM    = SD1.D1_ITEMORI"									+CRLF
    cQuery += "				AND SD2.D_E_L_E_T_ = ' '"												+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"  								+CRLF
	cQuery += "				ON  SF2.F2_FILIAL  = SD2.D2_FILIAL"										+CRLF
	cQuery += "				AND SF2.F2_DOC     = SD2.D2_DOC"										+CRLF
	cQuery += "				AND SF2.F2_SERIE   = SD2.D2_SERIE"										+CRLF
    cQuery += "				AND SF2.D_E_L_E_T_ = ' '"												+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"  								+CRLF
	cQuery += "				ON  SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
	cQuery += "				AND SA1.A1_COD     = SD2.D2_CLIENTE"									+CRLF
	cQuery += "				AND SA1.A1_LOJA    = SD2.D2_LOJA"										+CRLF
    cQuery += "				AND SA1.D_E_L_E_T_ = ' '"												+CRLF
    cQuery += "		WHERE   SD1.D1_FILIAL = '"+xFilial("SD1")+"'"									+CRLF
    cQuery += "		   	AND SF1.F1_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
//  cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
	cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF        
    cQuery += "			AND SD1.D_E_L_E_T_ = ' '"													+CRLF    
    cQuery += "		GROUP BY SF1.F1_FILIAL,"														+CRLF
	cQuery += "		  		 SF1.F1_DOC,"															+CRLF
	cQuery += "		  		 SF1.F1_SERIE,"															+CRLF
	cQuery += "		  		 SF1.F1_FORNECE,"														+CRLF
	cQuery += "		  		 SF1.F1_LOJA,"															+CRLF
	cQuery += "		  		 SA1.A1_COD,"															+CRLF
	cQuery += "		  		 SA1.A1_LOJA,"															+CRLF
	cQuery += "		  		 SA1.A1_NREDUZ,"														+CRLF
	cQuery += "				 SD1.D1_TES"															+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
		aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,								; // 01 - Codigo
					 Alltrim((cAlias)->NOME),											; // 02 - Nome Cliente
					 If((cAlias)->TES=="035","Mercadoria Boa","Mercadoria Avariada"),	; // 03 - Motivo Devolução 
					 (cAlias)->VALOR}													) // 04 - Valor
	
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==5
	// Bonificação
	cQuery := "SELECT DISTINCT SF2.F2_EMISSAO AS EMISSAO,"			+CRLF
	cQuery += "		  SF2.F2_DOC     AS DOCUMENTO,"					+CRLF
	cQuery += "		  SF2.F2_SERIE   AS SERIE,"						+CRLF
	cQuery += "		  SA1.A1_MUN     AS CIDADE,"					+CRLF
	cQuery += "		  SF2.F2_CLIENTE AS CLIENTE,"					+CRLF
	cQuery += "		  SF2.F2_LOJA    AS LOJA,"						+CRLF
	cQuery += "		  SA1.A1_NREDUZ  AS NOME,"						+CRLF
	cQuery += "		  SF2.F2_DESCONT AS DESCONTO,"					+CRLF
	cQuery += "		  SF2.F2_VALMERC AS FATURADO,"					+CRLF
	cQuery += "		  SF2.F2_MENNOTA AS MENSAGEM"					+CRLF
	cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"   		+CRLF	
	cQuery += "	 	INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)" 	+CRLF
	cQuery += "			 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"	+CRLF
	cQuery += "			AND SA1.A1_COD    = SF2.F2_CLIENTE"			+CRLF
	cQuery += "			AND SA1.A1_LOJA   = SF2.F2_LOJA"			+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"					+CRLF
	cQuery += "	 	INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)" 	+CRLF
	cQuery += "			 ON SD2.D2_FILIAL = SF2.F2_FILIAL"			+CRLF
	cQuery += "			AND SD2.D2_DOC    = SF2.F2_DOC"				+CRLF
	cQuery += "			AND SD2.D2_SERIE  = SF2.F2_SERIE"			+CRLF
	cQuery += "			AND SD2.D_E_L_E_T_ = ' '"					+CRLF
    cQuery += "		WHERE   SF2.F2_FILIAL = '"+xFilial("SF2")+"'"	+CRLF
    cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"	+CRLF    
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"	+CRLF	
	cQuery += "		    AND SD2.D2_TES IN "+cTesBonif				+CRLF
	cQuery += "		   	AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
	cQuery += "			AND SD2.D_E_L_E_T_ = ' '"					+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
		aAdd(aDados,{Stod((cAlias)->EMISSAO),										; // 01 - Data
					 Alltrim((cAlias)->DOCUMENTO)+"-"+Alltrim((cAlias)->SERIE),		; // 02 - NF
					 Alltrim((cAlias)->CIDADE),										; // 03 - Cidade
					 (cAlias)->CLIENTE+"-"+(cAlias)->LOJA,							; // 04 - codCliente
					 Alltrim((cAlias)->NOME),										; // 05 - nomeCliente
					 (cAlias)->DESCONTO,											; // 06 - Desconto
					 (cAlias)->FATURADO,											; // 07 - Faturado
					 ((cAlias)->DESCONTO / (cAlias)->FATURADO) * 100,				; // 08 - %
					 Alltrim((cAlias)->MENSAGEM)}									) // 09 - observaçãoSeleção

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==6
	// Meta Real
	aDatas  := {}
	cAno	:= StrZero(Year(dDataDe),4)
	For nX:=1 to 12
		aAdd(aDatas,{StrZero(nX,2),Stod(cAno+StrZero(nX,2)+"01"),LastDay(Stod(cAno+StrZero(nX,2)+"01"))})
	Next nX	
	
	cQuery := "SELECT * FROM ("																												+CRLF
	cQuery += "SELECT SA1.A1_COD 	AS CLIENTE,"																							+CRLF
	cQuery += "		  SA1.A1_LOJA 	AS LOJA,"																								+CRLF
	cQuery += "		  SA1.A1_NREDUZ	AS NOME,"																								+CRLF
    For nX:=1 to Len(aDatas)
		cQuery += "		  (SELECT SUM(SCT"+aDatas[nX,01]+".CT_QUANT)"																		+CRLF		
		cQuery += "	 		  FROM "+RetSqlName("SCT")+" SCT"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
		cQuery += "				WHERE 	SCT"+aDatas[nX,01]+".CT_FILIAL = '"+xFilial("SCT")+"'" 							 					+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_VEND   = '"+cVendedor+"'"								  	 				+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_CLIENTE= SA1.A1_COD"									  	 				+CRLF
		
		
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATAMET = '"+StrZero(Month(aDatas[nX,02]),2)+StrZero(Year(aDatas[nX,02]),4)+"'"+CRLF
		//cQuery += "				AND SCT"+aDatas[nX,01]+".CT_DATA BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"		+CRLF
		
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_MSBLQL  <> '1'"																+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS META"+aDatas[nX,01]+","									+CRLF
			
		cQuery += "		  (SELECT SUM(SD2"+aDatas[nX,01]+".D2_QUANT)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SD2")+" SD2"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
        cQuery += "				INNER JOIN "+RetSqlName("SF2")+" SF2"+aDatas[nX,01]+" (NOLOCK)"												+CRLF
        cQuery += "					 ON SF2"+aDatas[nX,01]+".F2_FILIAL  = SD2"+aDatas[nX,01]+".D2_FILIAL"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_DOC     = SD2"+aDatas[nX,01]+".D2_DOC"										+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_SERIE   = SD2"+aDatas[nX,01]+".D2_SERIE"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' '"																+CRLF
		cQuery += "				WHERE 	SD2"+aDatas[nX,01]+".D2_FILIAL  = '"+xFilial("SD2")+"'" 							 				+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_CLIENTE = SA1.A1_COD"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_LOJA 	= SA1.A1_LOJA"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_EMISSAO BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"	+CRLF
	//	cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES NOT IN "+cTesBonif														+CRLF				
		cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES IN "+cTesVends														+CRLF						
		cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS REAL"+aDatas[nX,01]+ If(nX==Len(aDatas),"",",")			+CRLF
	Next nX
	cQuery += "	 FROM "+RetSqlName("SA1")+" SA1 (NOLOCK)"																					+CRLF
	cQuery += "		WHERE   SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"																			+CRLF
	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
	cQuery += "			AND SA1.A1_MSBLQL  <> '1'"																							+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"																							+CRLF	
	cQuery += ") AS TMP"																													+CRLF
	cQuery += "  WHERE (TMP.REAL01 > 0  OR TMP.REAL02 > 0 OR TMP.REAL03 > 0 OR TMP.REAL04 > 0 OR TMP.REAL05 > 0 OR TMP.REAL06 > 0 OR TMP.REAL07 > 0 OR TMP.REAL08 > 0 OR TMP.REAL09 > 0 OR TMP.REAL10 > 0 OR TMP.REAL11 > 0 OR TMP.REAL12 > 0)"+CRLF
	cQuery += "	ORDER BY TMP.CLIENTE, TMP.LOJA"																								+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
    	aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,		; // 01 - Código
			          Alltrim((cAlias)->NOME),					; // 02 - Nome Cliente
    				  (cAlias)->META01,							; // 03 - Meta 	(JAN)
    				  (cAlias)->REAL01,							; // 04 - Real 	(JAN)
    				  ((cAlias)->REAL01/(cAlias)->META01)*100,	; // 05 - %		(JAN)    				  
    				  (cAlias)->META02,							; // 06 - Meta 	(FEV)
    				  (cAlias)->REAL02,							; // 07 - Real 	(FEV)
    				  ((cAlias)->REAL02/(cAlias)->META02)*100,	; // 08 - %		(FEV)    				  
    				  (cAlias)->META03,							; // 09 - Meta 	(MAR)
    				  (cAlias)->REAL03,							; // 10 - Real 	(MAR)
    				  ((cAlias)->REAL03/(cAlias)->META03)*100,	; // 11 - %		(MAR)    				  
    				  (cAlias)->META04,							; // 12 - Meta 	(ABR)
    				  (cAlias)->REAL04,							; // 13 - Real 	(ABR)
    				  ((cAlias)->REAL04/(cAlias)->META04)*100,	; // 14 - %		(ABR)    				  
    				  (cAlias)->META05,							; // 15 - Meta 	(MAI)
    				  (cAlias)->REAL05,							; // 16 - Real 	(MAI)
    				  ((cAlias)->REAL05/(cAlias)->META05)*100,	; // 17 - %		(MAI)    				  
    				  (cAlias)->META06,							; // 18 - Meta 	(JUN)
    				  (cAlias)->REAL06,							; // 19 - Real 	(JUN)
    				  ((cAlias)->REAL06/(cAlias)->META06)*100,	; // 20 - %		(JUN)    				  
    				  (cAlias)->META07,							; // 21 - Meta 	(JUL)
    				  (cAlias)->REAL07,							; // 22 - Real 	(JUL)
    				  ((cAlias)->REAL07/(cAlias)->META07)*100,	; // 23 - %		(JUL)    				  
    				  (cAlias)->META08,							; // 24 - Meta 	(AGO)
    				  (cAlias)->REAL08,							; // 25 - Real 	(AGO)
    				  ((cAlias)->REAL08/(cAlias)->META08)*100,	; // 26 - %		(AGO)    				  
    				  (cAlias)->META09,							; // 27 - Meta 	(SET)
    				  (cAlias)->REAL09,							; // 28 - Real 	(SET)
    				  ((cAlias)->REAL09/(cAlias)->META09)*100,	; // 29 - %		(SET)    				  
    				  (cAlias)->META10,							; // 30 - Meta 	(OUT)
    				  (cAlias)->REAL10,							; // 31 - Real 	(OUT)
    				  ((cAlias)->REAL10/(cAlias)->META10)*100,	; // 32 - %		(OUT)    				  
    				  (cAlias)->META11,							; // 33 - Meta 	(NOV)
    				  (cAlias)->REAL11,							; // 34 - Real 	(NOV)
    				  ((cAlias)->REAL11/(cAlias)->META11)*100,	; // 35 - %		(NOV)    				  
    				  (cAlias)->META12,							; // 36 - Meta 	(DEZ)
    				  (cAlias)->REAL12,							; // 37 - Real 	(DEZ)
    				  ((cAlias)->REAL12/(cAlias)->META12)*100,	; // 38 - %		(DEZ)    				  
    				  0,										; // 39 - Meta 	(SEM 1)
    				  0,										; // 40 - Real 	(SEM 1)
    				  0,										; // 41 - %		(SEM 1)    				  
    				  0,										; // 42 - Meta 	(SEM 2)
    				  0,										; // 43 - Real 	(SEM 2)
    				  0,										; // 44 - %		(SEM 2)    				  
    				  0,										; // 45 - Meta 	(TOTAL)
    				  0,										; // 46 - Real 	(TOTAL)
    				  0}										) // 47 - %		(TOTAL)

        nPos := Len(aDados)
        aDados[nPos][39] := (cAlias)->(META01+META02+META03+META04+META05+META06)
        aDados[nPos][40] := (cAlias)->(REAL01+REAL02+REAL03+REAL04+REAL05+REAL06)
        aDados[nPos][41] := (aDados[nPos][40] / aDados[nPos][39]) * 100
                                                                       
        aDados[nPos][42] := (cAlias)->(META07+META08+META09+META10+META11+META12)
        aDados[nPos][43] := (cAlias)->(REAL07+REAL08+REAL09+REAL10+REAL11+REAL12)
        aDados[nPos][44] := (aDados[nPos][43] / aDados[nPos][42]) * 100
    
    	aDados[nPos][45] := aDados[nPos][39] + aDados[nPos][42]
        aDados[nPos][46] := aDados[nPos][40] + aDados[nPos][43]
        aDados[nPos][47] := (aDados[nPos][46] / aDados[nPos][45]) * 100
    
    	(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==7
	// Meta Real Valor	
	aDatas  := {}
	cAno	:= StrZero(Year(dDataDe),4)
	For nX:=1 to 12
		aAdd(aDatas,{StrZero(nX,2),Stod(cAno+StrZero(nX,2)+"01"),LastDay(Stod(cAno+StrZero(nX,2)+"01"))})
	Next nX	
	
	cQuery := "SELECT * FROM ("																												+CRLF
	cQuery += "SELECT SA1.A1_COD 	AS CLIENTE,"																							+CRLF
	cQuery += "		  SA1.A1_LOJA 	AS LOJA,"																								+CRLF
	cQuery += "		  SA1.A1_NREDUZ	AS NOME,"																								+CRLF
    For nX:=1 to Len(aDatas)
		cQuery += "		  (SELECT SUM(SCT"+aDatas[nX,01]+".CT_VALOR)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SCT")+" SCT"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
		cQuery += "				WHERE 	SCT"+aDatas[nX,01]+".CT_FILIAL = '"+xFilial("SCT")+"'" 							 					+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_VEND   = '"+cVendedor+"'"								  	 				+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_CLIENTE= SA1.A1_COD"									  	 				+CRLF
		
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATAMET = '"+StrZero(Month(aDatas[nX,02]),2)+StrZero(Year(aDatas[nX,02]),4)+"'"+CRLF
		//cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATA BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"		+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_MSBLQL  <> '1'"																+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS META"+aDatas[nX,01]+","									+CRLF
			
		cQuery += "		  (SELECT SUM(SD2"+aDatas[nX,01]+".D2_TOTAL)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SD2")+" SD2"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
        cQuery += "				INNER JOIN "+RetSqlName("SF2")+" SF2"+aDatas[nX,01]+" (NOLOCK)"												+CRLF
        cQuery += "					 ON SF2"+aDatas[nX,01]+".F2_FILIAL  = SD2"+aDatas[nX,01]+".D2_FILIAL"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_DOC     = SD2"+aDatas[nX,01]+".D2_DOC"										+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_SERIE   = SD2"+aDatas[nX,01]+".D2_SERIE"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' '"																+CRLF
		cQuery += "				WHERE 	SD2"+aDatas[nX,01]+".D2_FILIAL  = '"+xFilial("SD2")+"'" 							 				+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_CLIENTE = SA1.A1_COD"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_LOJA 	= SA1.A1_LOJA"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_EMISSAO BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"	+CRLF
	//	cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES NOT IN "+cTesBonif														+CRLF				
		cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES IN "+cTesVends															+CRLF						
		
		cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS REAL"+aDatas[nX,01]+ If(nX==Len(aDatas),"",",")			+CRLF
	Next nX
	cQuery += "	 FROM "+RetSqlName("SA1")+" SA1 (NOLOCK)"																					+CRLF
	cQuery += "		WHERE   SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"																			+CRLF
	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"																			+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"																			+CRLF	
	cQuery += "			AND SA1.A1_MSBLQL  <> '1'"																							+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"																							+CRLF	
	cQuery += ") AS TMP"																													+CRLF
//	cQuery += "  WHERE (TMP.REAL01 > 0  OR TMP.REAL02 > 0 OR TMP.REAL03 > 0 OR TMP.REAL04 > 0 OR TMP.REAL05 > 0 OR TMP.REAL06 > 0 OR TMP.REAL07 > 0 OR TMP.REAL08 > 0 OR TMP.REAL09 > 0 OR TMP.REAL10 > 0 OR TMP.REAL11 > 0 OR TMP.REAL12 > 0)"+CRLF
	cQuery += "  WHERE (TMP.REAL01 > 0 OR TMP.META01 > 0 OR TMP.REAL02 > 0 OR TMP.META02 > 0 OR TMP.META03 > 0 OR TMP.META04 > 0 OR TMP.META05 > 0 OR TMP.META06 > 0 OR TMP.META07 > 0 OR TMP.META08 > 0 OR TMP.META09 > 0 OR TMP.META10 > 0 OR TMP.META11 > 0 OR TMP.META12 > 0  OR TMP.REAL03 > 0 OR TMP.REAL04 > 0 OR TMP.REAL05 > 0 OR TMP.REAL06 > 0 OR TMP.REAL07 > 0 OR TMP.REAL08 > 0 OR TMP.REAL09 > 0 OR TMP.REAL10 > 0 OR TMP.REAL11 > 0 OR TMP.REAL12 > 0)"+CRLF
	cQuery += "	ORDER BY TMP.CLIENTE, TMP.LOJA"																								+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
    	aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,		; // 01 - Código
			          Alltrim((cAlias)->NOME),					; // 02 - Nome Cliente
    				  (cAlias)->META01,							; // 03 - Meta 	(JAN)
    				  (cAlias)->REAL01,							; // 04 - Real 	(JAN)
    				  ((cAlias)->REAL01/(cAlias)->META01)*100,	; // 05 - %		(JAN)    				  
    				  (cAlias)->META02,							; // 06 - Meta 	(FEV)
    				  (cAlias)->REAL02,							; // 07 - Real 	(FEV)
    				  ((cAlias)->REAL02/(cAlias)->META02)*100,	; // 08 - %		(FEV)    				  
    				  (cAlias)->META03,							; // 09 - Meta 	(MAR)
    				  (cAlias)->REAL03,							; // 10 - Real 	(MAR)
    				  ((cAlias)->REAL03/(cAlias)->META03)*100,	; // 11 - %		(MAR)    				  
    				  (cAlias)->META04,							; // 12 - Meta 	(ABR)
    				  (cAlias)->REAL04,							; // 13 - Real 	(ABR)
    				  ((cAlias)->REAL04/(cAlias)->META04)*100,	; // 14 - %		(ABR)    				  
    				  (cAlias)->META05,							; // 15 - Meta 	(MAI)
    				  (cAlias)->REAL05,							; // 16 - Real 	(MAI)
    				  ((cAlias)->REAL05/(cAlias)->META05)*100,	; // 17 - %		(MAI)    				  
    				  (cAlias)->META06,							; // 18 - Meta 	(JUN)
    				  (cAlias)->REAL06,							; // 19 - Real 	(JUN)
    				  ((cAlias)->REAL06/(cAlias)->META06)*100,	; // 20 - %		(JUN)    				  
    				  (cAlias)->META07,							; // 21 - Meta 	(JUL)
    				  (cAlias)->REAL07,							; // 22 - Real 	(JUL)
    				  ((cAlias)->REAL07/(cAlias)->META07)*100,	; // 23 - %		(JUL)    				  
    				  (cAlias)->META08,							; // 24 - Meta 	(AGO)
    				  (cAlias)->REAL08,							; // 25 - Real 	(AGO)
    				  ((cAlias)->REAL08/(cAlias)->META08)*100,	; // 26 - %		(AGO)    				  
    				  (cAlias)->META09,							; // 27 - Meta 	(SET)
    				  (cAlias)->REAL09,							; // 28 - Real 	(SET)
    				  ((cAlias)->REAL09/(cAlias)->META09)*100,	; // 29 - %		(SET)    				  
    				  (cAlias)->META10,							; // 30 - Meta 	(OUT)
    				  (cAlias)->REAL10,							; // 31 - Real 	(OUT)
    				  ((cAlias)->REAL10/(cAlias)->META10)*100,	; // 32 - %		(OUT)    				  
    				  (cAlias)->META11,							; // 33 - Meta 	(NOV)
    				  (cAlias)->REAL11,							; // 34 - Real 	(NOV)
    				  ((cAlias)->REAL11/(cAlias)->META11)*100,	; // 35 - %		(NOV)    				  
    				  (cAlias)->META12,							; // 36 - Meta 	(DEZ)
    				  (cAlias)->REAL12,							; // 37 - Real 	(DEZ)
    				  ((cAlias)->REAL12/(cAlias)->META12)*100,	; // 38 - %		(DEZ)    				  
    				  0,										; // 39 - Meta 	(SEM 1)
    				  0,										; // 40 - Real 	(SEM 1)
    				  0,										; // 41 - %		(SEM 1)    				  
    				  0,										; // 42 - Meta 	(SEM 2)
    				  0,										; // 43 - Real 	(SEM 2)
    				  0,										; // 44 - %		(SEM 2)    				  
    				  0,										; // 45 - Meta 	(TOTAL)
    				  0,										; // 46 - Real 	(TOTAL)
    				  0}										) // 47 - %		(TOTAL)

        nPos := Len(aDados)
        aDados[nPos][39] := (cAlias)->(META01+META02+META03+META04+META05+META06)
        aDados[nPos][40] := (cAlias)->(REAL01+REAL02+REAL03+REAL04+REAL05+REAL06)
        aDados[nPos][41] := (aDados[nPos][40] / aDados[nPos][39]) * 100
                                                                       
        aDados[nPos][42] := (cAlias)->(META07+META08+META09+META10+META11+META12)
        aDados[nPos][43] := (cAlias)->(REAL07+REAL08+REAL09+REAL10+REAL11+REAL12)
        aDados[nPos][44] := (aDados[nPos][43] / aDados[nPos][42]) * 100
    
    	aDados[nPos][45] := aDados[nPos][39] + aDados[nPos][42]
        aDados[nPos][46] := aDados[nPos][40] + aDados[nPos][43]
        aDados[nPos][47] := (aDados[nPos][46] / aDados[nPos][45]) * 100
    
    	(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==8
	// Meta Real Produto
	aDatas  := {}
	cAno	:= StrZero(Year(dDataDe),4)
	For nX:=1 to 12
		aAdd(aDatas,{StrZero(nX,2),Stod(cAno+StrZero(nX,2)+"01"),LastDay(Stod(cAno+StrZero(nX,2)+"01"))})
	Next nX	
	
	cQuery := "SELECT * FROM ("																												+CRLF
	cQuery += "  SELECT SB1.B1_COD 	AS PRODUTO,"																							+CRLF
	cQuery += "		  SB1.B1_DESC 	AS DESCRICAO,"																							+CRLF
    For nX:=1 to Len(aDatas)
		cQuery += "		  (SELECT SUM(SCT"+aDatas[nX,01]+".CT_QUANT)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SCT")+" SCT"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
		cQuery += "				WHERE 	SCT"+aDatas[nX,01]+".CT_FILIAL = '"+xFilial("SCT")+"'" 							 					+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_VEND   = '"+cVendedor+"'"								  	 				+CRLF
		
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATAMET = '"+StrZero(Month(aDatas[nX,02]),2)+StrZero(Year(aDatas[nX,02]),4)+"'"+CRLF
		//cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATA BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"		+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_MSBLQL  <> '1'"																+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_PRODUTO = SB1.B1_COD"														+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS META"+aDatas[nX,01]+","									+CRLF
			
		cQuery += "		  (SELECT SUM(SD2"+aDatas[nX,01]+".D2_QUANT)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SD2")+" SD2"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
        cQuery += "				INNER JOIN "+RetSqlName("SF2")+" SF2"+aDatas[nX,01]+" (NOLOCK)"												+CRLF
        cQuery += "					 ON SF2"+aDatas[nX,01]+".F2_FILIAL  = SD2"+aDatas[nX,01]+".D2_FILIAL"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_DOC     = SD2"+aDatas[nX,01]+".D2_DOC"										+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_SERIE   = SD2"+aDatas[nX,01]+".D2_SERIE"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' '"																+CRLF	    
	    cQuery += "				INNER JOIN "+RetSqlName("SA1")+" SA1"+aDatas[nX,01]+" (NOLOCK)"												+CRLF
        cQuery += "					 ON SA1"+aDatas[nX,01]+".A1_FILIAL  = '"+xFilial("SA1")+"'"												+CRLF
	    cQuery += "					AND SA1"+aDatas[nX,01]+".A1_COD     = SF2"+aDatas[nX,01]+".F2_CLIENTE"									+CRLF
	    cQuery += "					AND SA1"+aDatas[nX,01]+".A1_LOJA    = SF2"+aDatas[nX,01]+".F2_LOJA"										+CRLF
	    cQuery += "					AND SA1"+aDatas[nX,01]+".D_E_L_E_T_ = ' '"																+CRLF	    
		cQuery += "				WHERE 	SD2"+aDatas[nX,01]+".D2_FILIAL  = '"+xFilial("SD2")+"'" 							 				+CRLF
		cQuery += "					AND SD2"+aDatas[nX,01]+".D2_COD 	= SB1.B1_COD"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_EMISSAO BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"	+CRLF
		//cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES NOT IN "+cTesBonif														+CRLF						
		cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES IN "+cTesVends														+CRLF						
		
		cQuery += "					AND (SA1"+aDatas[nX,01]+".A1_VEND    = '"+SA3->A3_COD+"'"												+CRLF
		cQuery += "					  OR SA1"+aDatas[nX,01]+".A1_VEND1   = '"+SA3->A3_COD+"')"												+CRLF			
		cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS REAL"+aDatas[nX,01]+ If(nX==Len(aDatas),"",",")			+CRLF
	Next nX
	cQuery += "	 FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"																					+CRLF
	cQuery += "		WHERE   SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"																			+CRLF
	cQuery += "			AND SB1.D_E_L_E_T_ = ' '"																							+CRLF	
	cQuery += ") AS TMP"																													+CRLF
	cQuery += "  WHERE (TMP.REAL01 > 0  OR TMP.REAL02 > 0 OR TMP.REAL03 > 0 OR TMP.REAL04 > 0 OR TMP.REAL05 > 0 OR TMP.REAL06 > 0 OR TMP.REAL07 > 0 OR TMP.REAL08 > 0 OR TMP.REAL09 > 0 OR TMP.REAL10 > 0 OR TMP.REAL11 > 0 OR TMP.REAL12 > 0)"+CRLF
	cQuery += "	ORDER BY TMP.PRODUTO"																										+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
    	aAdd(aDados,{(cAlias)->PRODUTO,							; // 01 - Código
			          Alltrim((cAlias)->DESCRICAO),				; // 02 - Descrição do Produto
    				  (cAlias)->META01,							; // 03 - Meta 	(JAN)
    				  (cAlias)->REAL01,							; // 04 - Real 	(JAN)
    				  ((cAlias)->REAL01/(cAlias)->META01)*100,	; // 05 - %		(JAN)    				  
    				  (cAlias)->META02,							; // 06 - Meta 	(FEV)
    				  (cAlias)->REAL02,							; // 07 - Real 	(FEV)
    				  ((cAlias)->REAL02/(cAlias)->META02)*100,	; // 08 - %		(FEV)    				  
    				  (cAlias)->META03,							; // 09 - Meta 	(MAR)
    				  (cAlias)->REAL03,							; // 10 - Real 	(MAR)
    				  ((cAlias)->REAL03/(cAlias)->META03)*100,	; // 11 - %		(MAR)    				  
    				  (cAlias)->META04,							; // 12 - Meta 	(ABR)
    				  (cAlias)->REAL04,							; // 13 - Real 	(ABR)
    				  ((cAlias)->REAL04/(cAlias)->META04)*100,	; // 14 - %		(ABR)    				  
    				  (cAlias)->META05,							; // 15 - Meta 	(MAI)
    				  (cAlias)->REAL05,							; // 16 - Real 	(MAI)
    				  ((cAlias)->REAL05/(cAlias)->META05)*100,	; // 17 - %		(MAI)    				  
    				  (cAlias)->META06,							; // 18 - Meta 	(JUN)
    				  (cAlias)->REAL06,							; // 19 - Real 	(JUN)
    				  ((cAlias)->REAL06/(cAlias)->META06)*100,	; // 20 - %		(JUN)    				  
    				  (cAlias)->META07,							; // 21 - Meta 	(JUL)
    				  (cAlias)->REAL07,							; // 22 - Real 	(JUL)
    				  ((cAlias)->REAL07/(cAlias)->META07)*100,	; // 23 - %		(JUL)    				  
    				  (cAlias)->META08,							; // 24 - Meta 	(AGO)
    				  (cAlias)->REAL08,							; // 25 - Real 	(AGO)
    				  ((cAlias)->REAL08/(cAlias)->META08)*100,	; // 26 - %		(AGO)    				  
    				  (cAlias)->META09,							; // 27 - Meta 	(SET)
    				  (cAlias)->REAL09,							; // 28 - Real 	(SET)
    				  ((cAlias)->REAL09/(cAlias)->META09)*100,	; // 29 - %		(SET)    				  
    				  (cAlias)->META10,							; // 30 - Meta 	(OUT)
    				  (cAlias)->REAL10,							; // 31 - Real 	(OUT)
    				  ((cAlias)->REAL10/(cAlias)->META10)*100,	; // 32 - %		(OUT)    				  
    				  (cAlias)->META11,							; // 33 - Meta 	(NOV)
    				  (cAlias)->REAL11,							; // 34 - Real 	(NOV)
    				  ((cAlias)->REAL11/(cAlias)->META11)*100,	; // 35 - %		(NOV)    				  
    				  (cAlias)->META12,							; // 36 - Meta 	(DEZ)
    				  (cAlias)->REAL12,							; // 37 - Real 	(DEZ)
    				  ((cAlias)->REAL12/(cAlias)->META12)*100,	; // 38 - %		(DEZ)    				  
    				  0,										; // 39 - Meta 	(SEM 1)
    				  0,										; // 40 - Real 	(SEM 1)
    				  0,										; // 41 - %		(SEM 1)    				  
    				  0,										; // 42 - Meta 	(SEM 2)
    				  0,										; // 43 - Real 	(SEM 2)
    				  0,										; // 44 - %		(SEM 2)    				  
    				  0,										; // 45 - Meta 	(TOTAL)
    				  0,										; // 46 - Real 	(TOTAL)
    				  0}										) // 47 - %		(TOTAL)

        nPos := Len(aDados)
        aDados[nPos][39] := (cAlias)->(META01+META02+META03+META04+META05+META06)
        aDados[nPos][40] := (cAlias)->(REAL01+REAL02+REAL03+REAL04+REAL05+REAL06)
        aDados[nPos][41] := (aDados[nPos][40] / aDados[nPos][39]) * 100
                                                                       
        aDados[nPos][42] := (cAlias)->(META07+META08+META09+META10+META11+META12)
        aDados[nPos][43] := (cAlias)->(REAL07+REAL08+REAL09+REAL10+REAL11+REAL12)
        aDados[nPos][44] := (aDados[nPos][43] / aDados[nPos][42]) * 100
    
    	aDados[nPos][45] := aDados[nPos][39] + aDados[nPos][42]
        aDados[nPos][46] := aDados[nPos][40] + aDados[nPos][43]
        aDados[nPos][47] := (aDados[nPos][46] / aDados[nPos][45]) * 100
    
    	(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==9
		cQuery := "SELECT VENDAS.CLIENTE,"+CRLF
		cQuery += "             VENDAS.LOJA,"+CRLF
		cQuery += "             VENDAS.NOME,"+CRLF
		cQuery += "             VENDAS.QUANTIDADE,"+CRLF
		cQuery += "             VENDAS.VALOR,"+CRLF
		cQuery += "             SCT.CT_VALOR METAVALOR,"+CRLF
		cQuery += "             VENDAS.VNDVLANTER,"+CRLF
		cQuery += "             SCTANTER.CT_VALOR METVLANTER"+CRLF

		cQuery += "  FROM (SELECT"+CRLF
		cQuery += "			   SA1.A1_FILIAL   AS FILIAL,"+CRLF
		cQuery += "			   SA1.A1_VEND     AS VENDEDOR,"+CRLF
		cQuery += "			   SA1.A1_NREDUZ   AS NOME,"+CRLF
		cQuery += "			   SA1.A1_COD  	   AS CLIENTE,"+CRLF
		cQuery += "			   SA1.A1_LOJA     AS LOJA,"+CRLF

		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_TOTAL ELSE 0 END) AS VALOR,"+CRLF
		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_QUANT ELSE 0 END) AS QUANTIDADE,"+CRLF

		cQuery += "					(SELECT SUM(SD2ANT.D2_TOTAL) "+CRLF
		cQuery += "						 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"+CRLF
		cQuery += "								ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"+CRLF
		cQuery += "								AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"+CRLF
		cQuery += "								AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"+CRLF
		cQuery += "								AND SD2ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"+CRLF
		cQuery += "								 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "								 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"+CRLF
		cQuery += "								 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"+CRLF
		cQuery += "								 AND SA1ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "						WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "							AND SA1ANT.A1_COD  = SA1.A1_COD"+CRLF
		cQuery += "							AND SA1ANT.A1_LOJA = SA1.A1_LOJA"+CRLF
		cQuery += "							AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"+CRLF
		cQuery += "							  OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"+CRLF
		cQuery += "							AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		cQuery += "							AND SD2ANT.D2_TES IN "+cTesVends + CRLF
		cQuery += "							AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDVLANTER"+CRLF

		cQuery += "		  FROM SA1010 SA1 (NOLOCK)"+CRLF

		cQuery += "		  LEFT JOIN SF2010 SF2 (NOLOCK)"+CRLF
		cQuery += "			ON SA1.A1_COD     = SF2.F2_CLIENTE"+CRLF
		cQuery += "		   AND SA1.A1_LOJA    = SF2.F2_LOJA"+CRLF
		cQuery += "		   AND SF2.F2_FILIAL  = '"+xFilial("SA1")+"'" + CRLF
		cQuery += "		   AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF

		cQuery += "		  LEFT JOIN SD2010 SD2 (NOLOCK)"+CRLF
		cQuery += "			ON SD2.D2_FILIAL  = SF2.F2_FILIAL"+CRLF
		cQuery += "		   AND SD2.D2_DOC     = SF2.F2_DOC"+CRLF
		cQuery += "		   AND SD2.D2_SERIE   = SF2.F2_SERIE"+CRLF
		cQuery += "		   AND SD2.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "		  WHERE (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		   AND SA1.A1_FILIAL  = '"+xFilial("SF2")+"'"+CRLF
		cQuery += "		   AND SA1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "		 GROUP BY SA1.A1_COD,"+CRLF
		cQuery += "				  SF2.F2_CLIENTE,"+CRLF
		cQuery += "				  SA1.A1_LOJA,	 		"+CRLF											
		cQuery += "				  SA1.A1_NREDUZ,"+CRLF
		cQuery += "				  SA1.A1_FILIAL,"+CRLF
		cQuery += "			          SA1.A1_VEND"+CRLF
		cQuery += ") VENDAS"+CRLF

		cQuery += "   LEFT JOIN SCT010 SCT (NOLOCK)"+CRLF
		cQuery += "    ON SCT.CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCT.CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCT.CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"+CRLF
		cQuery += "   AND SCT.CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCT.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "  LEFT JOIN SCT010 SCTANTER (NOLOCK)"+CRLF
		cQuery += "    ON SCTANTER .CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCTANTER .CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCTANTER .CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCTANTER .CT_DATAMET = '"+cPerAnter+"'"+CRLF
		cQuery += "   AND SCTANTER .CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCTANTER .D_E_L_E_T_ = ' '"+CRLF

		cQuery += " ORDER BY VENDAS.NOME"+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())
		nValor    := (cAlias)->METAVALOR
		nPcAting := ((cAlias)->VALOR / nValor) * 100
		nSaldo	 := (cAlias)->VALOR - (cAlias)->METAVALOR  
		nPcParc  := Round(((cAlias)->VALOR / ((nValor/nDiasMes)*nDias)) * 100,2)
		
		nSldAnter := (cAlias)->VNDVLANTER - (cAlias)->METVLANTER
		
    	aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,	;	// 01 - Cliente
    				 Alltrim((cAlias)->NOME),				; 	// 02 - Nome
    				 nSldAnter,								;	// 03 - Qtd. Un.Saldo Mês Ant.
    				 nValor,								;	// 04 - Qtd. Meta Un. Mês
    				 (cAlias)->VALOR,						;	// 05 - Qtd. Faturado
    				 nPcAting,								;	// 06 - % Atingimento
    				 nSaldo,								;	// 07 - Qtd. Saldo
    				 0,										;	// 08 - Pedidos Total | Por Dezena
    				 0,										;	// 09 - % Valor Pedidos Por Dezena
    				 0,										;	// 10 - Atingiu     				 
    				 nPcParc}								)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==10
	// Pular Linhas
	For nX:=1 to nTamanho	
		aAdd(aDadTmp,"")
	Next nX	
	aAdd(aDados,aDadTmp)

ElseIf nTipo==11
	// Comissão calculada
    nMetQtd	:= 0
	nMetVlr	:= 0   
	nPcComisV := 0
 
    cQuery := "SELECT"									 											+CRLF
	cQuery += "			SF2.F2_CLIENTE    AS CLIENTE,"	 											+CRLF
	cQuery += "			SF2.F2_LOJA    	  AS LOJA,"	 	 											+CRLF
	cQuery += "			SA1.A1_NREDUZ  	  AS NOME,"	 	 											+CRLF
	cQuery += "			SUM(SD2.D2_QUANT) AS QUANTIDADE,"											+CRLF
	cQuery += "			SUM(SD2.D2_TOTAL) AS VALOR," 	 											+CRLF	
	cQuery += "			SUM(SD2.D2_TOTAL * (SA1.A1_DESCFIN/100)) AS DESCFIN,"						+CRLF
	cQuery += "			SUM(SD2.D2_TOTAL * (SA1.A1_XFRETE/100))  AS XFRETE,"						+CRLF	
	cQuery += "			(SELECT SUM(CT_QUANT) 
    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
	cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
 //	cQuery += "				   AND SCT.CT_CLIENTE = SF2.F2_CLIENTE"		 										+CRLF
	cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
	cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
	cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
	cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAQUANT,"											+CRLF

	cQuery += "			(SELECT SUM(CT_VALOR) 
    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
	cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
 //	cQuery += "				   AND SCT.CT_CLIENTE = SF2.F2_CLIENTE"	   											+CRLF
	cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
	cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
	cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
	cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAVALOR"											+CRLF
		
	cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"											+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
	cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
	cQuery += "			AND SA1.A1_COD     = SF2.F2_CLIENTE"										+CRLF
	cQuery += "			AND SA1.A1_LOJA    = SF2.F2_LOJA"											+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
	cQuery += "			 ON SD2.D2_FILIAL  = SF2.F2_FILIAL"											+CRLF
	cQuery += "			AND SD2.D2_DOC     = SF2.F2_DOC"											+CRLF
	cQuery += "			AND SD2.D2_SERIE   = SF2.F2_SERIE"											+CRLF
	cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF
		
	cQuery += "		WHERE   SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF
	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
	cQuery += "		    AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//	cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
	cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF
	cQuery += "			AND SF2.D_E_L_E_T_ = ' '"													+CRLF		                           
	
	cQuery += "		GROUP BY SF2.F2_CLIENTE,"	 													+CRLF
	cQuery += "				 SF2.F2_LOJA,"	 	 													+CRLF
	cQuery += "				 SA1.A1_NREDUZ"	 	 													+CRLF
    
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	Do While (cAlias)->(!Eof())
	
		If cTpVend == "O"
			nPCA_QTDE := SA3->A3_XAPCQTD
			nPCB_QTDE := SA3->A3_XBPCQTD
			nPCC_QTDE := SA3->A3_XCPCQTD
			nPCA_VALOR:= SA3->A3_XAPCVLR
			nPCB_VALOR:= SA3->A3_XBPCVLR
			nPCC_VALOR:= SA3->A3_XCPCVLR
			
			nValorCalc := (cAlias)->VALOR - (cAlias)->DESCFIN - (cAlias)->XFRETE
			nPcAtQtde := Round(((cAlias)->QUANTIDADE  / (cAlias)->METAQUANT) * 100,2)
			nPcAtValor:= Round(( nValorCalc / (cAlias)->METAVALOR) * 100,2)
			
			nMetQtd	+= nPcAtQtde
			nMetVlr	+= nPcAtValor
			nQtdRegs++	
			
			Do Case
					Case (nMetQtd/nQtdRegs) >= 1
						nPgNaQtde := Round((nValorCalc*100) * nPCA_QTDE,2)

						nPcComis  = (nPCA_QTDE)*100
												
					Case (nMetQtd/nQtdRegs) >= 0.8 .And. (nMetQtd/nQtdRegs) < 1
						nPgNaQtde := Round((nValorCalc*100) * nPCB_QTDE,2)
						nPcComis  = (nPCB_QTDE)*100
						
					Case (nMetQtd/nQtdRegs) < 0.8 
				    	nPgNaQtde := Round((nValorCalc*100) * nPCC_QTDE,2)
				    	nPcComis  = (nPCC_QTDE)*100
				   
				  
				    	
				EndCase
				       
				Do Case
					Case (nMetVlr/nQtdRegs) >= 1
						nPgNoValor := Round((nValorCalc*100) * nPCA_VALOR,2)
						nPcComisV = (nPCA_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) >= 0.8 .And. (nMetVlr/nQtdRegs) < 1
						nPgNoValor := Round((nValorCalc*100) * nPCB_VALOR,2)
						nPcComisV = (nPCB_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) < 0.8 
				    	nPgNoValor := Round((nValorCalc*100) * nPCC_VALOR,2)
				    	nPcComisV = (nPCC_VALOR)*100       
				    	
				   					    	
				EndCase
		    
			nComiss += Round(nPgNaQtde + nPgNoValor,2)		
		Else
		
		        nValorCalc := (cAlias)->VALOR - (cAlias)->DESCFIN - (cAlias)->XFRETE
	  //		nPcAtQtde := Round(((cAlias)->QUANTIDADE  / (cAlias)->METAQUANT) * 100,2)
	  //		nPcAtValor:= Round(( nValorCalc / (cAlias)->METAVALOR) * 100,2)
			                                                                    
			nMetQtd	+= nPcAtQtde
			nMetVlr	+= nPcAtValor
			nQtdRegs++	
			
			nPcComis := SA3->A3_COMIS			
			nComiss += Round(nValorCalc * (nPCComRep/100),2)
			nPcComisV = 0
		EndIf
		
		nValor += nValorCalc
		nQtde  += (cAlias)->QUANTIDADE
		
		(cAlias)->(dbSkip())
    EndDo
	                         

			
    (cAlias)->(dbCloseArea())
	
	aAdd(aDados,{nValor,			;	// 01 - Valor
    			 nQtde,				; 	// 02 - Quantidade
    			 (nMetVlr/nQtdRegs)*100,	;	// 03 - Percentual Atingimento em Valor
    			 (nMetQtd/nQtdRegs)*100, 	;	// 04 - Percentual Atingimento em Quantidade   
    			  (nPcComis+nPcComisV),         ; //05 - teste			 
    			  nValor*((nPcComis+nPcComisV)/100)}			)	// 06 - Comissao a Receber

ElseIf nTipo==12
	// Comissão calculada Sintetica    
    aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf
	
	    nMetQtd		:= 0
		nMetVlr		:= 0
		cTpVend		:= If(SA3->(FieldPos("A3_TIPOVEN"))>0,SA3->A3_TIPOVEN,"")
		nValor		:= 0
	    nQtde		:= 0
	    nPcComis	:= 0
	    nQtdRegs	:= 0
	    nComiss		:= 0		
	    
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SE1.E1_CLIENTE    AS CLIENTE,"	 											+CRLF
		cQuery += "			SE1.E1_LOJA    	  AS LOJA,"	 	 											+CRLF
		cQuery += "			SA1.A1_NREDUZ  	  AS NOME,"	 	 											+CRLF
    	cQuery += "			SUM(SE1.E1_VALOR) AS QUANTIDADE,"											+CRLF
		cQuery += "			SUM(SE1.E1_VALOR) AS VALOR," 	 											+CRLF		
		cQuery += "			SUM(SE1.E1_VALOR * (SA1.A1_DESCFIN/100)) AS DESCFIN,"						+CRLF
		cQuery += "			SUM(SE1.E1_VALOR * (SA1.A1_XFRETE/100))  AS XFRETE,"						+CRLF		
		cQuery += "			(SELECT SUM(CT_QUANT) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
//		cQuery += "				   AND SCT.CT_CLIENTE = SE1.E1_CLIENTE"		 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAQUANT,"											+CRLF
	
		cQuery += "			(SELECT SUM(CT_VALOR) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
//		cQuery += "				   AND SCT.CT_CLIENTE = SE1.E1_CLIENTE"	   											+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAVALOR"											+CRLF
			
		cQuery += "	 FROM "+RetSqlName("SE1")+" SE1 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SE1.E1_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SE1.E1_LOJA"											+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
/*
		cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD2.D2_FILIAL  = SE1.E1_FILIAL"											+CRLF
		cQuery += "			AND SD2.D2_DOC     = SE1.E1_NUM"											+CRLF
		cQuery += "			AND SD2.D2_SERIE   = SE1.E1_PREFIXO"											+CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF
		
        cQuery += "		INNER JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SF2.F2_FILIAL  = SE1.E1_FILIAL"											+CRLF
		cQuery += "			AND SF2.F2_DOC     = SE1.E1_NUM"											+CRLF
		cQuery += "			AND SF2.F2_SERIE   = SE1.E1_PREFIXO"										+CRLF
		cQuery += "			AND SE1.D_E_L_E_T_ = ' '"													+CRLF
	*/		
		
		cQuery += "		WHERE   SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"									+CRLF
		cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		    AND SE1.E1_BAIXA BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
    	cQuery += "		    AND SE1.E1_SALDO = '0' "         											+CRLF
		cQuery += "		    AND SE1.E1_TIPO = 'NF' "         											+CRLF
	//	cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF				
		cQuery += "			AND SE1.D_E_L_E_T_ = ' '"													+CRLF		
		
		cQuery += "		GROUP BY SE1.E1_CLIENTE,"	 													+CRLF
		cQuery += "				 SE1.E1_LOJA,"	 	 													+CRLF
		cQuery += "				 SA1.A1_NREDUZ"	 	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())
			If cTpVend == "O"	
				nPCA_QTDE := SA3->A3_XAPCQTD
				nPCB_QTDE := SA3->A3_XBPCQTD
				nPCC_QTDE := SA3->A3_XCPCQTD
				nPCA_VALOR:= SA3->A3_XAPCVLR
				nPCB_VALOR:= SA3->A3_XBPCVLR
				nPCC_VALOR:= SA3->A3_XCPCVLR
			
				nValorCalc := (cAlias)->VALOR - (cAlias)->DESCFIN - (cAlias)->XFRETE
				nPcAtQtde := Round(((cAlias)->QUANTIDADE  / (cAlias)->METAQUANT) * 100,2)
				nPcAtValor:= Round((nValorCalc / (cAlias)->METAVALOR) * 100,2)

				nPcComis  := 0
				nMetQtd	+= nPcAtQtde
				nMetVlr	+= nPcAtValor
				nQtdRegs++	
				
					Do Case
					Case (nMetQtd/nQtdRegs) >= 1
						nPgNaQtde := Round((nValorCalc*100) * nPCA_QTDE,2)

						nPcComis  = (nPCA_QTDE)*100
						
					Case (nMetQtd/nQtdRegs) >= 0.8 .And. (nMetQtd/nQtdRegs) < 1
						nPgNaQtde := Round((nValorCalc*100) * nPCB_QTDE,2)
						nPcComis  = (nPCB_QTDE)*100
						
					Case (nMetQtd/nQtdRegs) < 0.8 
				    	nPgNaQtde := Round((nValorCalc*100) * nPCC_QTDE,2)
				    	nPcComis  = (nPCC_QTDE)*100
				   
				  
				    	
				EndCase
				       
				Do Case
					Case (nMetVlr/nQtdRegs) >= 1
						nPgNoValor := Round((nValorCalc*100) * nPCA_VALOR,2)
						nPcComisV = (nPCA_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) >= 0.8 .And. (nMetVlr/nQtdRegs) < 1
						nPgNoValor := Round((nValorCalc*100) * nPCB_VALOR,2)
						nPcComisV = (nPCB_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) < 0.8 
				    	nPgNoValor := Round((nValorCalc*100) * nPCC_VALOR,2)
				    	nPcComisV = (nPCC_VALOR)*100       
				    	
				   					    	
				EndCase
			    
				nComiss += Round(nPgNaQtde + nPgNoValor,2)
			  //  nPcComis = 100*(nPCA_VALOR + nPCC_QTDE)  
				//nPcComis /= nQtdRegs
								
			Else	
				nValorCalc := (cAlias)->VALOR - (cAlias)->DESCFIN - (cAlias)->XFRETE
				
				nPCComRep := SA3->A3_COMIS
				nComiss += Round(nValorCalc * (nPCComRep/100),2)
				nPcComis := nPCComRep
			EndIf                
			
			nValor += nValorCalc
			nQtde  += (cAlias)->QUANTIDADE
			
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())
	    
	 
				
		aAdd(aDados,{SA3->A3_COD,		;	// 01 - Vendedor
	    			 SA3->A3_NOME,		; 	// 02 - Nome
	    			 cTpVend,			;	// 03 - Tipo Vendedor
	    			 nValor,			;	// 04 - Valor
	    			 0,				; 	// 05 - Quantidade
	    			 (nPcComis+nPcComisV),			;	// 06 - Comissao	    			  
	    			 (nMetVlr/nQtdRegs)*100,	;	// 07 - Percentual Atingimento em Valor
	    			 0,	;	// 08 - Percentual Atingimento em Quantidade    			 
	    		  	 nValor*((nPcComis+nPcComisV)/100)}			)	// 09 - Comissao a Receber
	
	Next nX		

ElseIf nTipo==13
		// Previsto x Realizado - Sintetizado
	   
	   	//->> Meta Diaria
	   	For dX:=dDataDe to dDataAte
	   		     
	   		//->> Somente dias uteis
	   		If DataValida(dX)==dX
	   			aAdd(aDados,{dX,0,0,0,0,0})	   	
	   		EndIf	
	   		
	   	Next dX
	   	cQuery := "SELECT"																							+CRLF
	   	cQuery += "			SUM(SCT.CT_VALOR) AS VALOR "															+CRLF
	   	cQuery += "	 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"														+CRLF
		cQuery += "			WHERE SCT.CT_FILIAL = '"+xFilial("SCT")+"'"												+CRLF		
		cQuery += "	    	  AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"		+CRLF
		cQuery += "			  AND SCT.CT_MSBLQL  <> '1'"															+CRLF
		cQuery += "			  AND SCT.D_E_L_E_T_ = ' '"																+CRLF

	   	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
        
		Do While (cAlias)->(!Eof())
			nMetVlr += (cAlias)->VALOR
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
		nMetVlr := nMetVlr / Len(aDados)
		
		For nX:=1 to Len(aDados)
			aDados[nX,04] := nMetVlr
	    Next nX	   
	    
	    //->> Previsto
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SC5.C5_EMISSAO    AS EMISSAO,"	 											+CRLF
		cQuery += "			SUM(SC6.C6_VALOR) AS VALOR" 	 											+CRLF			
		cQuery += "	 FROM "+RetSqlName("SC5")+" SC5 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SC5.C5_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SC5.C5_LOJACLI"										+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SC6")+" SC6 (NOLOCK)"									+CRLF
		cQuery += "			 ON SC6.C6_FILIAL  = SC5.C5_FILIAL"											+CRLF
		cQuery += "			AND SC6.C6_NUM     = SC5.C5_NUM"											+CRLF
		cQuery += "			AND SC6.D_E_L_E_T_ = ' '"													+CRLF			
		cQuery += "		WHERE   SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"									+CRLF
//		cQuery += "			AND (SA1.A1_VEND    <> ' '"													+CRLF
//		cQuery += "			  OR SA1.A1_VEND1   <> ' ')"												+CRLF	
		cQuery += "		    AND SC5.C5_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//		cQuery += "		    AND SC6.C6_TES NOT IN "+cTesBonif											+CRLF
		cQuery += "		    AND SC6.C6_TES IN "+cTesVends	 											+CRLF		
		
		cQuery += "			AND SC5.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		GROUP BY SC5.C5_EMISSAO"	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
	    Do While (cAlias)->(!Eof())
	    	nPos := Ascan(aDados,{|x| x[01]==Stod((cAlias)->EMISSAO)})
	    	If nPos == 0
	    		aAdd(aDados,{Stod((cAlias)->EMISSAO),0,0,0,0,0})
	    		nPos := Len(aDados)
	    	EndIf
	    	aDados[nPos][02]+=(cAlias)->VALOR
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())	    
	    
		//->> Realizado
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SF2.F2_EMISSAO    AS EMISSAO,"	 											+CRLF
		cQuery += "			SUM(SD2.D2_TOTAL) AS VALOR" 	 											+CRLF			
		cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SF2.F2_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SF2.F2_LOJA"											+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD2.D2_FILIAL  = SF2.F2_FILIAL"											+CRLF
		cQuery += "			AND SD2.D2_DOC     = SF2.F2_DOC"											+CRLF
		cQuery += "			AND SD2.D2_SERIE   = SF2.F2_SERIE"											+CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF			
		cQuery += "		WHERE   SF2.F2_FILIAL   = '"+xFilial("SF2")+"'"									+CRLF
		cQuery += "			AND (SA1.A1_VEND    <> ' '"													+CRLF
		cQuery += "			  OR SA1.A1_VEND1   <> ' ')"												+CRLF	
		cQuery += "		    AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//		cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
		cQuery += "		    AND SD2.D2_TES IN "+cTesVends											+CRLF		
		
		cQuery += "			AND SF2.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		GROUP BY SF2.F2_EMISSAO"	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	    Do While (cAlias)->(!Eof())
	    	nPos := Ascan(aDados,{|x| x[01]==Stod((cAlias)->EMISSAO)})
	    	If nPos == 0
	    		aAdd(aDados,{Stod((cAlias)->EMISSAO),0,0,0,0,0})
	    		nPos := Len(aDados)
	    	EndIf
	    	aDados[nPos][03]+=(cAlias)->VALOR
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())
	    
	    //->> Devolução
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SF1.F1_EMISSAO    AS EMISSAO,"	 											+CRLF
		cQuery += "			SUM(SD1.D1_TOTAL) AS VALOR" 	 											+CRLF			
		cQuery += "	 FROM "+RetSqlName("SF1")+" SF1 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD1")+" SD1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD1.D1_FILIAL  = SF1.F1_FILIAL"											+CRLF
		cQuery += "			AND SD1.D1_DOC     = SF1.F1_DOC"											+CRLF
		cQuery += "			AND SD1.D1_SERIE   = SF1.F1_SERIE"											+CRLF
		cQuery += "			AND SD1.D_E_L_E_T_ = ' '"													+CRLF			
		cQuery += "		WHERE   SF1.F1_FILIAL  = '"+xFilial("SF1")+"'"									+CRLF
		cQuery += "		    AND SF1.F1_TIPO    = 'D'"													+CRLF
		cQuery += "		    AND SF1.F1_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
		cQuery += "		    AND SD1.D1_TES     =  '035'"												+CRLF
		cQuery += "			AND SF1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		GROUP BY SF1.F1_EMISSAO"	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	    Do While (cAlias)->(!Eof())
	    	nPos := Ascan(aDados,{|x| x[01]==Stod((cAlias)->EMISSAO)})
	    	If nPos == 0
	    		aAdd(aDados,{Stod((cAlias)->EMISSAO),0,0,0,0,0})
	    		nPos := Len(aDados)
	    	EndIf
	    	aDados[nPos][05]+=(cAlias)->VALOR
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())
	                             
	    //->> Descarte
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SF1.F1_EMISSAO    AS EMISSAO,"	 											+CRLF
		cQuery += "			SUM(SD1.D1_TOTAL) AS VALOR" 	 											+CRLF			
		cQuery += "	 FROM "+RetSqlName("SF1")+" SF1 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD1")+" SD1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD1.D1_FILIAL  = SF1.F1_FILIAL"											+CRLF
		cQuery += "			AND SD1.D1_DOC     = SF1.F1_DOC"											+CRLF
		cQuery += "			AND SD1.D1_SERIE   = SF1.F1_SERIE"											+CRLF
		cQuery += "			AND SD1.D_E_L_E_T_ = ' '"													+CRLF			
		cQuery += "		WHERE   SF1.F1_FILIAL  = '"+xFilial("SF1")+"'"									+CRLF
		cQuery += "		    AND SF1.F1_TIPO    = 'D'"													+CRLF
		cQuery += "		    AND SF1.F1_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
		cQuery += "		    AND SD1.D1_TES     <> '035'"												+CRLF
		cQuery += "			AND SF1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		GROUP BY SF1.F1_EMISSAO"	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	    Do While (cAlias)->(!Eof())
	    	nPos := Ascan(aDados,{|x| x[01]==Stod((cAlias)->EMISSAO)})
	    	If nPos == 0
	    		aAdd(aDados,{Stod((cAlias)->EMISSAO),0,0,0,0,0})
	    		nPos := Len(aDados)
	    	EndIf
	    	aDados[nPos][06]+=(cAlias)->VALOR
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())
	    
	   aDados := aSort(aDados,,,{|x,y| x[01]<y[01]})	    

ElseIf nTipo==14
	// Resumo de Cliente Sintetizado - Quantidade	
	nDias	:= dDataAte-dDataDe
	nDiasMes:= LastDay(dDataAte)-dDataDe
		
	If Month(dDataDe)==1
		cPerAnter := "12"+StrZero(Year(dDataDe)-1,4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe)-1,4)+'1201')
	Else
		cPerAnter := StrZero(Month(dDataDe)-1,2)+StrZero(Year(dDataDe),4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe),4)+StrZero(Month(dDataDe)-1,2)+'01')
	EndIf
		
	dFimAnt := LastDay(dIniAnt)	

	aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf			
		
		cQuery := "SELECT VENDAS.CLIENTE,"+CRLF
		cQuery += "             VENDAS.LOJA,"+CRLF
		cQuery += "             VENDAS.NOME,"+CRLF
		cQuery += "             VENDAS.QUANTIDADE,"+CRLF
		cQuery += "             VENDAS.VALOR,"+CRLF
		cQuery += "             VENDAS.VNDVLANTER,"+CRLF
		cQuery += "             VENDAS.VNDQTANTER,"+CRLF

		cQuery += "             SCT.CT_VALOR METAVALOR,"+CRLF
		cQuery += "             SCT.CT_QUANT METAQUANT,"+CRLF  

		cQuery += "             SCTANTER.CT_VALOR METVLANTER,"+CRLF
		cQuery += "             SCTANTER.CT_QUANT METQTANTER"+CRLF

		cQuery += "  FROM (SELECT"+CRLF
		cQuery += "			   SA1.A1_FILIAL   AS FILIAL,"+CRLF
		cQuery += "			   SA1.A1_VEND     AS VENDEDOR,"+CRLF
		cQuery += "			   SA1.A1_NREDUZ   AS NOME,"+CRLF
		cQuery += "			   SA1.A1_COD  	   AS CLIENTE,"+CRLF
		cQuery += "			   SA1.A1_LOJA     AS LOJA,"+CRLF

		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_TOTAL ELSE 0 END) AS VALOR,"+CRLF
		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_QUANT ELSE 0 END) AS QUANTIDADE,"+CRLF

		cQuery += "					(SELECT SUM(SD2ANT.D2_TOTAL) "+CRLF
		cQuery += "						 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"+CRLF
		cQuery += "								ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"+CRLF
		cQuery += "								AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"+CRLF
		cQuery += "								AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"+CRLF
		cQuery += "								AND SD2ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"+CRLF
		cQuery += "								 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "								 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"+CRLF
		cQuery += "								 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"+CRLF
		cQuery += "								 AND SA1ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "						WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "							AND SA1ANT.A1_COD  = SA1.A1_COD"+CRLF
		cQuery += "							AND SA1ANT.A1_LOJA = SA1.A1_LOJA"+CRLF
		cQuery += "							AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"+CRLF
		cQuery += "							  OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"+CRLF
		cQuery += "							AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
		cQuery += "							AND SD2ANT.D2_TES IN "+cTesVends + CRLF
		cQuery += "							AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDVLANTER, "+CRLF

		//->> Novo		               
		cQuery += "			(SELECT SUM(SD2ANT.D2_QUANT) 
	    cQuery += "				 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"										+CRLF
	    cQuery += "					INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"								+CRLF
	    cQuery += "			 			ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"									+CRLF
		cQuery += "						AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"										+CRLF
		cQuery += "						AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"									+CRLF
		cQuery += "						AND SD2ANT.D_E_L_E_T_ = ' '"												+CRLF
		cQuery += "					INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"								+CRLF
		cQuery += "						 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
		cQuery += "						 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"									+CRLF
		cQuery += "						 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"									+CRLF
		cQuery += "						 AND SA1ANT.D_E_L_E_T_ = ' '"												+CRLF		
		cQuery += "				WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF		
		cQuery += "					AND SA1ANT.A1_COD  = SA1.A1_COD"											    +CRLF
		cQuery += "					AND SA1ANT.A1_LOJA = SA1.A1_LOJA"												+CRLF		
		cQuery += "					AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"										+CRLF
		cQuery += "					 OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"										+CRLF	
		cQuery += "		    		AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dIniAnt)+"' AND '"+dTos(dFimAnt)+"'"		+CRLF
		cQuery += "		    		AND SD2ANT.D2_TES IN "+cTesVends												+CRLF		
		cQuery += "				    AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDQTANTER"										+CRLF
		//Fim

		cQuery += "		  FROM SA1010 SA1 (NOLOCK)"+CRLF

		cQuery += "		  LEFT JOIN SF2010 SF2 (NOLOCK)"+CRLF
		cQuery += "			ON SA1.A1_COD     = SF2.F2_CLIENTE"+CRLF
		cQuery += "		   AND SA1.A1_LOJA    = SF2.F2_LOJA"+CRLF
		cQuery += "		   AND SF2.F2_FILIAL  = '"+xFilial("SA1")+"'" + CRLF
		cQuery += "		   AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF

		cQuery += "		  LEFT JOIN SD2010 SD2 (NOLOCK)"+CRLF
		cQuery += "			ON SD2.D2_FILIAL  = SF2.F2_FILIAL"+CRLF
		cQuery += "		   AND SD2.D2_DOC     = SF2.F2_DOC"+CRLF
		cQuery += "		   AND SD2.D2_SERIE   = SF2.F2_SERIE"+CRLF
		cQuery += "		   AND SD2.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "		  WHERE (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		   AND SA1.A1_FILIAL  = '"+xFilial("SF2")+"'"+CRLF
		cQuery += "        AND SA1.A1_MSBLQL  <> '1'"+CRLF
		cQuery += "		   AND SA1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "		 GROUP BY SA1.A1_COD,"+CRLF
		cQuery += "				  SF2.F2_CLIENTE,"+CRLF
		cQuery += "				  SA1.A1_LOJA,	 		"+CRLF											
		cQuery += "				  SA1.A1_NREDUZ,"+CRLF
		cQuery += "				  SA1.A1_FILIAL,"+CRLF
		cQuery += "			          SA1.A1_VEND"+CRLF
		cQuery += ") VENDAS"+CRLF

		cQuery += "   LEFT JOIN SCT010 SCT (NOLOCK)"+CRLF
		cQuery += "    ON SCT.CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCT.CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCT.CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"+CRLF
		cQuery += "   AND SCT.CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCT.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "  LEFT JOIN SCT010 SCTANTER (NOLOCK)"+CRLF
		cQuery += "    ON SCTANTER .CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCTANTER .CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCTANTER .CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCTANTER .CT_DATAMET = '"+cPerAnter+"'"+CRLF
		cQuery += "   AND SCTANTER .CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCTANTER .D_E_L_E_T_ = ' '"+CRLF

		cQuery += " ORDER BY VENDAS.NOME"+CRLF
		
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())	
			nQtde    := (cAlias)->METAQUANT
			nPcAting := Round(((cAlias)->QUANTIDADE / nQtde) * 100,2)
			nSaldo	 := (cAlias)->QUANTIDADE - (cAlias)->METAQUANT
			nPcParc  := Round(((cAlias)->QUANTIDADE / ((nQtde/nDiasMes)*nDias)) * 100,2)
			
			nSldAnter := (cAlias)->VNDQTANTER - (cAlias)->METQTANTER
			
	    	aAdd(aDados,{Alltrim(SA3->A3_COD)+" - "+Alltrim(SA3->A3_NOME),						;	// 01 - Vendedor - Nome
	    				 (cAlias)->CLIENTE+"-"+(cAlias)->LOJA+" - "+Alltrim((cAlias)->NOME),	; 	// 02 - Cliente - Nome
	    				 nSldAnter,																;	// 03 - Qtd. Un.Saldo Mês Ant.
	    				 nQtde,																	;	// 04 - Qtd. Meta Un. Mês
	    				 (cAlias)->QUANTIDADE,													;	// 05 - Qtd. Faturado
	    				 nPcAting,																;	// 06 - % Atingimento
	    				 nSaldo,																;	// 07 - Qtd. Saldo
	    				 0,																		;	// 08 - Pedidos Total | Por Dezena
	    				 0,																		;	// 09 - % Valor Pedidos Por Dezena
	    				 0,																		;	// 10 - Atingiu     				 
	    				 nPcParc}																)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)
	
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
	Next nX

ElseIf nTipo==15
	// Resumo de Cliente Sintetizado - Valor
	nDias	:= dDataAte-dDataDe
	nDiasMes:= LastDay(dDataAte)-dDataDe
	      
	If Month(dDataDe)==1
		cPerAnter := "12"+StrZero(Year(dDataDe)-1,4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe)-1,4)+'1201')
	Else
		cPerAnter := StrZero(Month(dDataDe)-1,2)+StrZero(Year(dDataDe),4)
		dIniAnt	:= Stod(StrZero(Year(dDataDe),4)+StrZero(Month(dDataDe)-1,2)+'01')
	EndIf
		
	dFimAnt := LastDay(dIniAnt)
	      
	aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf		
	



		cQuery := "SELECT VENDAS.CLIENTE,"+CRLF
		cQuery += "             VENDAS.LOJA,"+CRLF
		cQuery += "             VENDAS.NOME,"+CRLF
		cQuery += "             VENDAS.QUANTIDADE,"+CRLF
		cQuery += "             VENDAS.VALOR,"+CRLF
		cQuery += "             SCT.CT_VALOR METAVALOR,"+CRLF
		cQuery += "             VENDAS.VNDVLANTER,"+CRLF
		cQuery += "             SCTANTER.CT_VALOR METVLANTER"+CRLF

		cQuery += "  FROM (SELECT"+CRLF
		cQuery += "			   SA1.A1_FILIAL   AS FILIAL,"+CRLF
		cQuery += "			   SA1.A1_VEND     AS VENDEDOR,"+CRLF
		cQuery += "			   SA1.A1_NREDUZ   AS NOME,"+CRLF
		cQuery += "			   SA1.A1_COD  	   AS CLIENTE,"+CRLF
		cQuery += "			   SA1.A1_LOJA     AS LOJA,"+CRLF

		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_TOTAL ELSE 0 END) AS VALOR,"+CRLF
		cQuery += "			   SUM(CASE WHEN SD2.D2_TES IN "+cTesVends+" THEN SD2.D2_QUANT ELSE 0 END) AS QUANTIDADE,"+CRLF

		cQuery += "					(SELECT SUM(SD2ANT.D2_TOTAL) "+CRLF
		cQuery += "						 FROM "+RetSqlName("SD2")+" SD2ANT (NOLOCK)"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SF2")+" SF2ANT (NOLOCK)"+CRLF
		cQuery += "								ON  SD2ANT.D2_FILIAL  = SF2ANT.F2_FILIAL"+CRLF
		cQuery += "								AND SD2ANT.D2_DOC     = SF2ANT.F2_DOC"+CRLF
		cQuery += "								AND SD2ANT.D2_SERIE   = SF2ANT.F2_SERIE"+CRLF
		cQuery += "								AND SD2ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "							INNER JOIN "+RetSqlName("SA1")+" SA1ANT (NOLOCK)"+CRLF
		cQuery += "								 ON  SA1ANT.A1_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "								 AND SA1ANT.A1_COD     = SF2ANT.F2_CLIENTE"+CRLF
		cQuery += "								 AND SA1ANT.A1_LOJA    = SF2ANT.F2_LOJA"+CRLF
		cQuery += "								 AND SA1ANT.D_E_L_E_T_ = ' '"+CRLF
		cQuery += "						WHERE   SF2ANT.F2_FILIAL  = '"+xFilial("SA1")+"'"+CRLF
		cQuery += "							AND SA1ANT.A1_COD  = SA1.A1_COD"+CRLF
		cQuery += "							AND SA1ANT.A1_LOJA = SA1.A1_LOJA"+CRLF
		cQuery += "							AND (SA1ANT.A1_VEND    = '"+SA3->A3_COD+"'"+CRLF
		cQuery += "							  OR SA1ANT.A1_VEND1   = '"+SA3->A3_COD+"')"+CRLF
	//	cQuery += "							AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF
	    cQuery += "		            		AND SF2ANT.F2_EMISSAO BETWEEN '"+dTos(dIniAnt)+"' AND '"+dTos(dFimAnt)+"'"		+CRLF
	    cQuery += "							AND SD2ANT.D2_TES IN "+cTesVends + CRLF
		cQuery += "							AND SD2ANT.D_E_L_E_T_ = ' ') AS VNDVLANTER"+CRLF

		cQuery += "		  FROM SA1010 SA1 (NOLOCK)"+CRLF

		cQuery += "		  LEFT JOIN SF2010 SF2 (NOLOCK)"+CRLF
		cQuery += "			ON SA1.A1_COD     = SF2.F2_CLIENTE"+CRLF
		cQuery += "		   AND SA1.A1_LOJA    = SF2.F2_LOJA"+CRLF
		cQuery += "		   AND SF2.F2_FILIAL  = '"+xFilial("SA1")+"'" + CRLF
		cQuery += "		   AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"+CRLF

		cQuery += "		  LEFT JOIN SD2010 SD2 (NOLOCK)"+CRLF
		cQuery += "			ON SD2.D2_FILIAL  = SF2.F2_FILIAL"+CRLF
		cQuery += "		   AND SD2.D2_DOC     = SF2.F2_DOC"+CRLF
		cQuery += "		   AND SD2.D2_SERIE   = SF2.F2_SERIE"+CRLF
		cQuery += "		   AND SD2.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "		  WHERE (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		   AND SA1.A1_FILIAL  = '"+xFilial("SF2")+"'"+CRLF
		cQuery += "        AND SA1.A1_MSBLQL  <> '1'"+CRLF
		cQuery += "		   AND SA1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "		 GROUP BY SA1.A1_COD,"+CRLF
		cQuery += "				  SF2.F2_CLIENTE,"+CRLF
		cQuery += "				  SA1.A1_LOJA,	 		"+CRLF											
		cQuery += "				  SA1.A1_NREDUZ,"+CRLF
		cQuery += "				  SA1.A1_FILIAL,"+CRLF
		cQuery += "			          SA1.A1_VEND"+CRLF
		cQuery += ") VENDAS"+CRLF

		cQuery += "   LEFT JOIN SCT010 SCT (NOLOCK)"+CRLF
		cQuery += "    ON SCT.CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCT.CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCT.CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"+CRLF
		cQuery += "   AND SCT.CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCT.D_E_L_E_T_ = ' '"+CRLF

		cQuery += "  LEFT JOIN SCT010 SCTANTER (NOLOCK)"+CRLF
		cQuery += "    ON SCTANTER .CT_FILIAL  = VENDAS.FILIAL"+CRLF
		cQuery += "   AND SCTANTER .CT_CLIENTE = VENDAS.CLIENTE"+CRLF
		cQuery += "   AND SCTANTER .CT_VEND    = VENDAS.VENDEDOR"+CRLF
		cQuery += "   AND SCTANTER .CT_DATAMET = '"+cPerAnter+"'"+CRLF
		cQuery += "   AND SCTANTER .CT_MSBLQL  <> '1'"+CRLF
		cQuery += "   AND SCTANTER .D_E_L_E_T_ = ' '"+CRLF

		cQuery += " ORDER BY VENDAS.NOME"+CRLF
		
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())
			nValor    := (cAlias)->METAVALOR
			nPcAting := ((cAlias)->VALOR / nValor) * 100
			nSaldo	 := (cAlias)->VALOR - (cAlias)->METAVALOR  
			nPcParc  := Round(((cAlias)->VALOR / ((nValor/nDiasMes)*nDias)) * 100,2)
			
			nSldAnter := (cAlias)->VNDVLANTER - (cAlias)->METVLANTER
			
	    	aAdd(aDados,{Alltrim(SA3->A3_COD)+" - "+Alltrim(SA3->A3_NOME),							;	// 01 - Vendedor - Nome
	    				 (cAlias)->CLIENTE+"-"+(cAlias)->LOJA+" - "+Alltrim((cAlias)->NOME),		; 	// 02 - Cliente - Nome
	    				 nSldAnter,																	;	// 03 - Qtd. Un.Saldo Mês Ant.
	    				 nValor,							   										;	// 04 - Qtd. Meta Un. Mês
	    				 (cAlias)->VALOR,															;	// 05 - Qtd. Faturado
	    				 nPcAting,						  											;	// 06 - % Atingimento
	    				 nSaldo,						 											;	// 07 - Qtd. Saldo
	    				 0,							   												;	// 08 - Pedidos Total | Por Dezena
	    				 0,							  												;	// 09 - % Valor Pedidos Por Dezena
	    				 0,							  												;	// 10 - Atingiu     				 
	    				 nPcParc}					   												)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)
	
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
    Next nX

ElseIf nTipo==16
	// Resumo de Produto Sintetizado
	nDias	:= dDataAte-dDataDe
	nDiasMes:= LastDay(dDataAte)-dDataDe
	
	If Month(dDataDe)==1
		cPerAnter := "12"+StrZero(Year(dDataDe)-1,4)
	Else
		cPerAnter := StrZero(Month(dDataDe)-1,2)+StrZero(Year(dDataDe),4)
	EndIf	

	aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf			
		
		cQuery := "SELECT"									 											+CRLF
		cQuery += "			SD2.D2_COD    	  AS PRODUTO,"	 											+CRLF
		cQuery += "			SB1.B1_DESC    	  AS DESCRICAO,"											+CRLF
		cQuery += "			SUM(SD2.D2_QUANT) AS QUANTIDADE,"											+CRLF
		cQuery += "			SUM(SD2.D2_TOTAL) AS VALOR," 	 											+CRLF
		cQuery += "			(SELECT SUM(CT_QUANT) AS QUANTIDADE
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
		cQuery += "				   AND SCT.CT_PRODUTO = SD2.D2_COD"			 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAQUANT,"											+CRLF
	
		cQuery += "			(SELECT SUM(CT_QUANT) AS QUANTIDADE
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
		cQuery += "				   AND SCT.CT_PRODUTO = SD2.D2_COD"			 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+cPerAnter+"'"											+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METQTANTER"											+CRLF
		
		cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SF2.F2_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SF2.F2_LOJA"											+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD2.D2_FILIAL  = SF2.F2_FILIAL"											+CRLF
		cQuery += "			AND SD2.D2_DOC     = SF2.F2_DOC"											+CRLF
		cQuery += "			AND SD2.D2_SERIE   = SF2.F2_SERIE"											+CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"									+CRLF
		cQuery += "			AND SB1.B1_COD	   = SD2.D2_COD"											+CRLF
		cQuery += "			AND SB1.D_E_L_E_T_ = ' '"													+CRLF		
		
		cQuery += "		WHERE   SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF
		cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		    AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//		cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
		cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF		
		
		cQuery += "		GROUP BY SD2.D2_COD,"		 													+CRLF
		cQuery += "				 SB1.B1_DESC"	 	 													+CRLF
		
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())	
			nQtde    := (cAlias)->METAQUANT
			nPcAting := Round(((cAlias)->QUANTIDADE / nQtde) * 100,2)
			nSaldo	 := (cAlias)->QUANTIDADE - (cAlias)->METAQUANT
			nPcParc  := Round(((cAlias)->QUANTIDADE / ((nQtde/nDiasMes)*nDias)) * 100,2)
			
	    	aAdd(aDados,{Alltrim(SA3->A3_COD)+" - "+Alltrim(SA3->A3_NOME),						;	// 01 - Vendedor - Nome
	    				 (cAlias)->PRODUTO+" - "+Alltrim((cAlias)->DESCRICAO),					; 	// 02 - Produto - Descricao
	    				 (cAlias)->METQTANTER,													;	// 03 - Qtd. Un.Saldo Mês Ant.
	    				 nQtde,																	;	// 04 - Qtd. Meta Un. Mês
	    				 (cAlias)->QUANTIDADE,													;	// 05 - Qtd. Faturado
	    				 nPcAting,																;	// 06 - % Atingimento
	    				 nSaldo,																;	// 07 - Qtd. Saldo
	    				 0,																		;	// 08 - Pedidos Total | Por Dezena
	    				 0,																		;	// 09 - % Valor Pedidos Por Dezena
	    				 0,																		;	// 10 - Atingiu     				 
	    				 nPcParc}																)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)
	
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
	Next nX

ElseIf nTipo==17
	// Resumo de Produto Sintetizado
	nDias	:= dDataAte-dDataDe
	nDiasMes:= LastDay(dDataAte)-dDataDe
	
	If Month(dDataDe)==1
		cPerAnter := "12"+StrZero(Year(dDataDe)-1,4)
	Else
		cPerAnter := StrZero(Month(dDataDe)-1,2)+StrZero(Year(dDataDe),4)
	EndIf	

	aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf			
		
		cQuery := "SELECT"									 											+CRLF
		cQuery += "			SD2.D2_COD    	  AS PRODUTO,"	 											+CRLF
		cQuery += "			SB1.B1_DESC    	  AS DESCRICAO,"											+CRLF
		cQuery += "			SUM(SD2.D2_QUANT) AS QUANTIDADE,"											+CRLF
		cQuery += "			SUM(SD2.D2_TOTAL) AS VALOR," 	 											+CRLF
		
		cQuery += "			(SELECT SUM(CT_VALOR) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
		cQuery += "				   AND SCT.CT_PRODUTO = SD2.D2_COD"			 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAVALOR,"											+CRLF
		
		cQuery += "			(SELECT SUM(CT_VALOR) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
		cQuery += "				   AND SCT.CT_PRODUTO = SD2.D2_COD"			 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+cPerAnter+"'"											+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METVLANTER"											+CRLF

		cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SF2.F2_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SF2.F2_LOJA"											+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD2.D2_FILIAL  = SF2.F2_FILIAL"											+CRLF
		cQuery += "			AND SD2.D2_DOC     = SF2.F2_DOC"											+CRLF
		cQuery += "			AND SD2.D2_SERIE   = SF2.F2_SERIE"											+CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"									+CRLF
		cQuery += "			AND SB1.B1_COD	   = SD2.D2_COD"											+CRLF
		cQuery += "			AND SB1.D_E_L_E_T_ = ' '"													+CRLF		
			
		cQuery += "		WHERE   SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF
		cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		    AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//		cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
		cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF		
		
		cQuery += "		GROUP BY SD2.D2_COD,"		 													+CRLF
		cQuery += "				 SB1.B1_DESC"	 	 													+CRLF
		
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())
			nValor    := (cAlias)->METAVALOR
			nPcAting := ((cAlias)->VALOR / nValor) * 100
			nSaldo	 := (cAlias)->VALOR - (cAlias)->METAVALOR  
			nPcParc  := Round(((cAlias)->VALOR / ((nValor/nDiasMes)*nDias)) * 100,2)
			
	    	aAdd(aDados,{Alltrim(SA3->A3_COD)+" - "+Alltrim(SA3->A3_NOME),							;	// 01 - Vendedor - Nome
	    				 (cAlias)->PRODUTO+" - "+Alltrim((cAlias)->DESCRICAO),						; 	// 02 - Produto - Descricao
	    				 (cAlias)->METVLANTER,														;	// 03 - Qtd. Un.Saldo Mês Ant.
	    				 nValor,							   										;	// 04 - Qtd. Meta Un. Mês
	    				 (cAlias)->VALOR,															;	// 05 - Qtd. Faturado
	    				 nPcAting,						  											;	// 06 - % Atingimento
	    				 nSaldo,						 											;	// 07 - Qtd. Saldo
	    				 0,							   												;	// 08 - Pedidos Total | Por Dezena
	    				 0,							  												;	// 09 - % Valor Pedidos Por Dezena
	    				 0,							  												;	// 10 - Atingiu     				 
	    				 nPcParc}					   												)	// 11 - Percentual atingido parcialmente (não impresso, somente para destacar campo)
	
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())
    Next nX
       
ElseIf nTipo==18
	// Pedidos Saldo Cliente Sintetizado
	cQuery := "SELECT"																			+CRLF
	cQuery += "		  SC5.C5_EMISSAO										AS MES,"			+CRLF
	cQuery += "		  SC5.C5_CLIENTE										AS CLIENTE,"		+CRLF
	cQuery += "		  SC5.C5_LOJACLI										AS LOJA,"			+CRLF
	cQuery += "		  SA1.A1_NREDUZ											AS NOME,"			+CRLF	
	cQuery += "		  SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) 					AS QTD_SALDO,"		+CRLF
//	cQuery += "		  SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT)*SC6.C6_PRCVEN)  	AS VLR_SALDO"		+CRLF  
    cQuery += "		  SUM(SC6.C6_VALOR)                                 	AS VLR_SALDO"		+CRLF
	cQuery += "	 FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"										+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK)"								+CRLF
	cQuery += "			 ON SC5.C5_FILIAL  = SC6.C6_FILIAL"										+CRLF
	cQuery += "			AND SC5.C5_NUM	   = SC6.C6_NUM"										+CRLF
	cQuery += "			AND SC5.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
	cQuery += "			AND SA1.A1_COD	   = SC5.C5_CLIENTE"									+CRLF
	cQuery += "			AND SA1.A1_LOJA	   = SC5.C5_LOJACLI"									+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"												+CRLF		
	cQuery += "		WHERE  SC6.C6_FILIAL = '"+xFilial("SC6")+"'"								+CRLF
//	cQuery += "		   AND SC6.C6_QTDVEN > SC6.C6_QTDENT"										+CRLF
	cQuery += "		   AND SC6.C6_SERIE    = ''"												+CRLF
	cQuery += "		   AND SC5.C5_TIPO    = 'N'"												+CRLF
//	cQuery += "		   AND SC5.C5_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//  cQuery += "		   AND SC6.C6_TES NOT IN "+cTesBonif										+CRLF
	cQuery += "		   AND SC6.C6_TES IN "+cTesVends											+CRLF	
	cQuery += "		   AND SC6.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "	GROUP BY SC5.C5_NUM,"	     													+CRLF
	cQuery += "          SC5.C5_EMISSAO,"												    	+CRLF 
	cQuery += "			 SC5.C5_CLIENTE,"														+CRLF 
	cQuery += "			 SC5.C5_LOJACLI,"														+CRLF 
	cQuery += "			 SA1.A1_NREDUZ"															+CRLF

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
		aAdd(aDados,{SubStr((cAlias)->MES,7,2)+"/"+SubStr((cAlias)->MES,5,2)+"/"+SubStr((cAlias)->MES,1,4),	; // 01 - Mês
					 (cAlias)->CLIENTE+"-"+(cAlias)->LOJA,						; // 02 - Cliente
					 Alltrim((cAlias)->NOME),									; // 03 - Nome
					 (cAlias)->QTD_SALDO,										; // 04 - Qtde Saldo
					 (cAlias)->VLR_SALDO}										) // 05 - Valor Saldo
		
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

ElseIf nTipo==19
	// Pedidos em Aberto Sintetico
	cQuery := "SELECT DISTINCT"																	+CRLF
	cQuery += "		  SC5.R_E_C_N_O_ AS RECSC5,"												+CRLF
	cQuery += "		  SC6.R_E_C_N_O_ AS RECSC6,"												+CRLF
	cQuery += "		  SB1.R_E_C_N_O_ AS RECSB1,"												+CRLF    
	cQuery += "		  SB2.R_E_C_N_O_ AS RECSB2,"												+CRLF
	cQuery += "		  SA1.R_E_C_N_O_ AS RECSA1"	 												+CRLF
	cQuery += "	 FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"										+CRLF
	cQuery += "		INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK)"								+CRLF
	cQuery += "			 ON SC5.C5_FILIAL  = SC6.C6_FILIAL"										+CRLF
	cQuery += "			AND SC5.C5_NUM	   = SC6.C6_NUM"										+CRLF
	cQuery += "			AND SC5.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"								+CRLF
	cQuery += "			AND SB1.B1_COD	   = SC6.C6_PRODUTO"									+CRLF
	cQuery += "			AND SB1.D_E_L_E_T_ = ' '"												+CRLF 
	cQuery += "		INNER JOIN "+RetSqlName("SB2")+" SB2 (NOLOCK)"								+CRLF
	cQuery += "			 ON SB2.B2_FILIAL  = '"+xFilial("SB2")+"'"								+CRLF
	cQuery += "			AND SB2.B2_COD	   = SC6.C6_PRODUTO"									+CRLF
	cQuery += "			AND SB2.D_E_L_E_T_ = ' '"												+CRLF			
	cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"								+CRLF
	cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"								+CRLF
	cQuery += "			AND SA1.A1_COD	   = SC5.C5_CLIENTE"									+CRLF
	cQuery += "			AND SA1.A1_LOJA	   = SC5.C5_LOJACLI"									+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"												+CRLF	
	cQuery += "		WHERE  SC6.C6_FILIAL = '"+xFilial("SC6")+"'"								+CRLF
	cQuery += "		   AND SB2.B2_LOCAL    = '01'"												+CRLF
//	cQuery += "		   AND SC6.C6_QTDVEN > SC6.C6_QTDENT"										+CRLF
	cQuery += "		   AND SC6.C6_SERIE    = ''"												+CRLF
	cQuery += "		   AND SC5.C5_TIPO    = 'N'"												+CRLF
 //	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"								+CRLF
 //	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"								+CRLF	
//	cQuery += "		   AND SC5.C5_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//	cQuery += "		   AND SC6.C6_TES NOT IN "+cTesBonif										+CRLF
	cQuery += "		   AND SC6.C6_TES IN "+cTesVends											+CRLF		
	cQuery += "		   AND SC6.D_E_L_E_T_ = ' '"												+CRLF	
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())
		SC5->(dbGoto((cAlias)->RECSC5))
		SC6->(dbGoto((cAlias)->RECSC6))
		SB1->(dbGoto((cAlias)->RECSB1)) 
		SB2->(dbGoto((cAlias)->RECSB2))
		SA1->(dbGoto((cAlias)->RECSA1))
	
		aAdd(aDados,{SC5->C5_EMISSAO,									; // 01 - Data Previsão
					 SC5->C5_NUM,										; // 02 - Pedido
					 SA1->A1_COD+"-"+SA1->A1_LOJA,						; // 04 - Cliente
					 Alltrim(SA1->A1_NREDUZ),							; // 05 - Nome
					 SB1->B1_COD,										; // 06 - Produto
					 Alltrim(SB1->B1_DESC),								; // 07 - Descrição
		         	 SB2->B2_QATU,	                    				; // 08 - Estoque
		         	 SC6->C6_QTDVEN - SC6->C6_QTDENT,					; // 08 - Qtde Saldo  
					 (SC6->C6_QTDVEN - SC6->C6_QTDENT)*SC6->C6_PRCVEN } ) // 09 - Valor Saldo
	     
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
  
ElseIf nTipo==20
	// Meta Real Valor	
	aDatas  := {}
	cAno	:= StrZero(Year(dDataDe),4)
	For nX:=1 to 12
		aAdd(aDatas,{StrZero(nX,2),Stod(cAno+StrZero(nX,2)+"01"),LastDay(Stod(cAno+StrZero(nX,2)+"01"))})
	Next nX	
	
	cQuery := "SELECT * FROM ("																												+CRLF
	cQuery += "SELECT SA1.A1_COD 	AS CLIENTE,"																							+CRLF
	cQuery += "		  SA1.A1_LOJA 	AS LOJA,"																								+CRLF
	cQuery += "		  SA1.A1_NREDUZ	AS NOME,"																								+CRLF
	cQuery += "		  SA1.A1_VEND	AS VEND,"																								+CRLF
    For nX:=1 to Len(aDatas)
		cQuery += "		  (SELECT SUM(SCT"+aDatas[nX,01]+".CT_VALOR)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SCT")+" SCT"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
		cQuery += "				WHERE 	SCT"+aDatas[nX,01]+".CT_FILIAL = '"+xFilial("SCT")+"'" 							 					+CRLF
	//	cQuery += "					AND SCT"+aDatas[nX,01]+".CT_VEND   = '"+cVendedor+"'"								  	 				+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_CLIENTE= SA1.A1_COD"									  	 				+CRLF
		
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATAMET = '"+StrZero(Month(aDatas[nX,02]),2)+StrZero(Year(aDatas[nX,02]),4)+"'"+CRLF
		//cQuery += "					AND SCT"+aDatas[nX,01]+".CT_DATA BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"		+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".CT_MSBLQL  <> '1'"																+CRLF
		cQuery += "					AND SCT"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS META"+aDatas[nX,01]+","									+CRLF
			
		cQuery += "		  (SELECT SUM(SD2"+aDatas[nX,01]+".D2_TOTAL)"																		+CRLF
		cQuery += "	 		  FROM "+RetSqlName("SD2")+" SD2"+aDatas[nX,01]+" (NOLOCK)"														+CRLF
        cQuery += "				INNER JOIN "+RetSqlName("SF2")+" SF2"+aDatas[nX,01]+" (NOLOCK)"												+CRLF
        cQuery += "					 ON SF2"+aDatas[nX,01]+".F2_FILIAL  = SD2"+aDatas[nX,01]+".D2_FILIAL"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_DOC     = SD2"+aDatas[nX,01]+".D2_DOC"										+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".F2_SERIE   = SD2"+aDatas[nX,01]+".D2_SERIE"									+CRLF
	    cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' '"																+CRLF
		cQuery += "				WHERE 	SD2"+aDatas[nX,01]+".D2_FILIAL  = '"+xFilial("SD2")+"'" 							 				+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_CLIENTE = SA1.A1_COD"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_LOJA 	= SA1.A1_LOJA"								  	 					+CRLF
		cQuery += "					AND SF2"+aDatas[nX,01]+".F2_EMISSAO BETWEEN '"+dTos(aDatas[nX,02])+"' AND '"+dTos(aDatas[nX,03])+"'"	+CRLF
	//	cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES NOT IN "+cTesBonif														+CRLF				
		cQuery += "		    		AND SD2"+aDatas[nX,01]+".D2_TES IN "+cTesVends															+CRLF						
		
		cQuery += "					AND SF2"+aDatas[nX,01]+".D_E_L_E_T_ = ' ') AS REAL"+aDatas[nX,01]+ If(nX==Len(aDatas),"",",")			+CRLF
	Next nX
	cQuery += "	 FROM "+RetSqlName("SA1")+" SA1 (NOLOCK)"																					+CRLF
	cQuery += "		WHERE   SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"																			+CRLF
//	cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"																			+CRLF
//	cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"																			+CRLF	
	cQuery += "			AND SA1.A1_MSBLQL  <> '1'"																							+CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' '"																							+CRLF	
	cQuery += ") AS TMP"																													+CRLF
	cQuery += "  WHERE (TMP.REAL01 > 0 OR TMP.META01 > 0 OR TMP.REAL02 > 0 OR TMP.META02 > 0 OR TMP.META03 > 0 OR TMP.META04 > 0 OR TMP.META05 > 0 OR TMP.META06 > 0 OR TMP.META07 > 0 OR TMP.META08 > 0 OR TMP.META09 > 0 OR TMP.META10 > 0 OR TMP.META11 > 0 OR TMP.META12 > 0  OR TMP.REAL03 > 0 OR TMP.REAL04 > 0 OR TMP.REAL05 > 0 OR TMP.REAL06 > 0 OR TMP.REAL07 > 0 OR TMP.REAL08 > 0 OR TMP.REAL09 > 0 OR TMP.REAL10 > 0 OR TMP.REAL11 > 0 OR TMP.REAL12 > 0)"+CRLF
	cQuery += "	ORDER BY TMP.CLIENTE, TMP.LOJA"																								+CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
	
	Do While (cAlias)->(!Eof())	
    	aAdd(aDados,{(cAlias)->CLIENTE+"-"+(cAlias)->LOJA,		; // 01 - Código
			          Alltrim((cAlias)->NOME),					; // 02 - Nome Cliente
					  (cAlias)->VEND,		                    ; // 03 - Operador
					  (cAlias)->META01,							; // 03 - Meta 	(JAN)
    				  (cAlias)->REAL01,							; // 04 - Real 	(JAN)
    				  ((cAlias)->REAL01/(cAlias)->META01)*100,	; // 05 - %		(JAN)    				  
    				  (cAlias)->META02,							; // 06 - Meta 	(FEV)
    				  (cAlias)->REAL02,							; // 07 - Real 	(FEV)
    				  ((cAlias)->REAL02/(cAlias)->META02)*100,	; // 08 - %		(FEV)    				  
    				  (cAlias)->META03,							; // 09 - Meta 	(MAR)
    				  (cAlias)->REAL03,							; // 10 - Real 	(MAR)
    				  ((cAlias)->REAL03/(cAlias)->META03)*100,	; // 11 - %		(MAR)    				  
    				  (cAlias)->META04,							; // 12 - Meta 	(ABR)
    				  (cAlias)->REAL04,							; // 13 - Real 	(ABR)
    				  ((cAlias)->REAL04/(cAlias)->META04)*100,	; // 14 - %		(ABR)    				  
    				  (cAlias)->META05,							; // 15 - Meta 	(MAI)
    				  (cAlias)->REAL05,							; // 16 - Real 	(MAI)
    				  ((cAlias)->REAL05/(cAlias)->META05)*100,	; // 17 - %		(MAI)    				  
    				  (cAlias)->META06,							; // 18 - Meta 	(JUN)
    				  (cAlias)->REAL06,							; // 19 - Real 	(JUN)
    				  ((cAlias)->REAL06/(cAlias)->META06)*100,	; // 20 - %		(JUN)    				  
    				  (cAlias)->META07,							; // 21 - Meta 	(JUL)
    				  (cAlias)->REAL07,							; // 22 - Real 	(JUL)
    				  ((cAlias)->REAL07/(cAlias)->META07)*100,	; // 23 - %		(JUL)    				  
    				  (cAlias)->META08,							; // 24 - Meta 	(AGO)
    				  (cAlias)->REAL08,							; // 25 - Real 	(AGO)
    				  ((cAlias)->REAL08/(cAlias)->META08)*100,	; // 26 - %		(AGO)    				  
    				  (cAlias)->META09,							; // 27 - Meta 	(SET)
    				  (cAlias)->REAL09,							; // 28 - Real 	(SET)
    				  ((cAlias)->REAL09/(cAlias)->META09)*100,	; // 29 - %		(SET)    				  
    				  (cAlias)->META10,							; // 30 - Meta 	(OUT)
    				  (cAlias)->REAL10,							; // 31 - Real 	(OUT)
    				  ((cAlias)->REAL10/(cAlias)->META10)*100,	; // 32 - %		(OUT)    				  
    				  (cAlias)->META11,							; // 33 - Meta 	(NOV)
    				  (cAlias)->REAL11,							; // 34 - Real 	(NOV)
    				  ((cAlias)->REAL11/(cAlias)->META11)*100,	; // 35 - %		(NOV)    				  
    				  (cAlias)->META12,							; // 36 - Meta 	(DEZ)
    				  (cAlias)->REAL12,							; // 37 - Real 	(DEZ)
    				  ((cAlias)->REAL12/(cAlias)->META12)*100,	; // 38 - %		(DEZ)    				  
    				  0,										; // 39 - Meta 	(SEM 1)
    				  0,										; // 40 - Real 	(SEM 1)
    				  0,										; // 41 - %		(SEM 1)    				  
    				  0,										; // 42 - Meta 	(SEM 2)
    				  0,										; // 43 - Real 	(SEM 2)
    				  0,										; // 44 - %		(SEM 2)    				  
    			      0,										; // 45 - Meta 	(TOTAL)
    				  0,										; // 46 - Real 	(TOTAL)
    				  0}										) // 47 - %		(TOTAL)

        nPos := Len(aDados)
        aDados[nPos][40] := (cAlias)->(META01+META02+META03+META04+META05+META06)
        aDados[nPos][41] := (cAlias)->(REAL01+REAL02+REAL03+REAL04+REAL05+REAL06)
        aDados[nPos][42] := (aDados[nPos][41] / aDados[nPos][40]) * 100
                                                                       
        aDados[nPos][43] := (cAlias)->(META07+META08+META09+META10+META11+META12)
        aDados[nPos][44] := (cAlias)->(REAL07+REAL08+REAL09+REAL10+REAL11+REAL12)
        aDados[nPos][45] := (aDados[nPos][44] / aDados[nPos][43]) * 100
    
    	aDados[nPos][46] := aDados[nPos][40] + aDados[nPos][43]
        aDados[nPos][47] := aDados[nPos][41] + aDados[nPos][44]
        aDados[nPos][48] := (aDados[nPos][47] / aDados[nPos][46]) * 100
    
    	(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
	
	
	
ElseIf nTipo==21
	// Total por Vendedor - Sintetico
	
aVendedor := GetVendedor(aRetParam[01],aRetParam[02],.F.)	
	If !lJob
		ProcRegua(Len(aVendedor))
	EndIf
	For nX:=1 to Len(aVendedor)
		SA3->(dbGoto(aVendedor[nX,03]))
		If !lJob
			IncProc("Gerando o Relatório...")
		EndIf
	
	    nMetQtd		:= 0
		nMetVlr		:= 0
		cTpVend		:= If(SA3->(FieldPos("A3_TIPOVEN"))>0,SA3->A3_TIPOVEN,"")
		nValor		:= 0
	    nQtde		:= 0
	    nPcComis	:= 0
	    nQtdRegs	:= 0
	    nComiss		:= 0		
	    
	    cQuery := "SELECT"									 											+CRLF
		cQuery += "			SF2.F2_CLIENTE    AS CLIENTE,"	 											+CRLF
		cQuery += "			SF2.F2_LOJA    	  AS LOJA,"	 	 											+CRLF
		cQuery += "			SA1.A1_NREDUZ  	  AS NOME,"	 	 											+CRLF
		cQuery += "			SUM(SD2.D2_QUANT) AS QUANTIDADE,"											+CRLF
		cQuery += "			SUM(SD2.D2_TOTAL) AS VALOR," 	 											+CRLF		
		cQuery += "			SUM(SD2.D2_TOTAL * (SA1.A1_DESCFIN/100)) AS DESCFIN,"						+CRLF
		cQuery += "			SUM(SD2.D2_TOTAL * (SA1.A1_XFRETE/100))  AS XFRETE,"						+CRLF		
		cQuery += "			(SELECT SUM(CT_QUANT) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
//		cQuery += "				   AND SCT.CT_CLIENTE = SF2.F2_CLIENTE"		 										+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAQUANT,"											+CRLF
	
		cQuery += "			(SELECT SUM(CT_VALOR) 
	    cQuery += "				 FROM "+RetSqlName("SCT")+" SCT (NOLOCK)"											+CRLF
		cQuery += "			 	 WHERE SCT.CT_FILIAL  = '"+xFilial("SCT")+"'"										+CRLF
 //		cQuery += "				   AND SCT.CT_CLIENTE = SF2.F2_CLIENTE"	   											+CRLF
		cQuery += "				   AND SCT.CT_VEND    = '"+SA3->A3_COD+"'"											+CRLF
		cQuery += "				   AND SCT.CT_DATAMET = '"+StrZero(Month(dDataDe),2)+StrZero(Year(dDataDe),4)+"'"	+CRLF
		cQuery += "				   AND SCT.CT_MSBLQL  <> '1'"														+CRLF
		cQuery += "				   AND SCT.D_E_L_E_T_ = ' ') AS METAVALOR"											+CRLF
			
		cQuery += "	 FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"											+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"									+CRLF
		cQuery += "			 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"									+CRLF
		cQuery += "			AND SA1.A1_COD     = SF2.F2_CLIENTE"										+CRLF
		cQuery += "			AND SA1.A1_LOJA    = SF2.F2_LOJA"											+CRLF
		cQuery += "			AND SA1.D_E_L_E_T_ = ' '"													+CRLF
		cQuery += "		INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"									+CRLF
		cQuery += "			 ON SD2.D2_FILIAL  = SF2.F2_FILIAL"											+CRLF
		cQuery += "			AND SD2.D2_DOC     = SF2.F2_DOC"											+CRLF
		cQuery += "			AND SD2.D2_SERIE   = SF2.F2_SERIE"											+CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '"													+CRLF
			
		cQuery += "		WHERE   SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"									+CRLF
		cQuery += "			AND (SA1.A1_VEND    = '"+SA3->A3_COD+"'"									+CRLF
		cQuery += "			  OR SA1.A1_VEND1   = '"+SA3->A3_COD+"')"									+CRLF	
		cQuery += "		    AND SF2.F2_EMISSAO BETWEEN '"+dTos(dDataDe)+"' AND '"+dTos(dDataAte)+"'"	+CRLF
//		cQuery += "		    AND SD2.D2_TES NOT IN "+cTesBonif											+CRLF
		cQuery += "		    AND SD2.D2_TES IN "+cTesVends												+CRLF				
		cQuery += "			AND SF2.D_E_L_E_T_ = ' '"													+CRLF		
		
		cQuery += "		GROUP BY SF2.F2_CLIENTE,"	 													+CRLF
		cQuery += "				 SF2.F2_LOJA,"	 	 													+CRLF
		cQuery += "				 SA1.A1_NREDUZ"	 	 													+CRLF
	    
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
		
		Do While (cAlias)->(!Eof())
			If cTpVend == "O"	
				nPCA_QTDE := SA3->A3_XAPCQTD
				nPCB_QTDE := SA3->A3_XBPCQTD
				nPCC_QTDE := SA3->A3_XCPCQTD
				nPCA_VALOR:= SA3->A3_XAPCVLR
				nPCB_VALOR:= SA3->A3_XBPCVLR
				nPCC_VALOR:= SA3->A3_XCPCVLR
			
				nValorCalc := (cAlias)->VALOR
				nPcAtQtde := Round(((cAlias)->QUANTIDADE  / (cAlias)->METAQUANT) * 100,2)
				nPcAtValor:= Round((nValorCalc / (cAlias)->METAVALOR) * 100,2)

				nPcComis  := 0
				nMetQtd	+= nPcAtQtde
				nMetVlr	+= nPcAtValor
				nQtdRegs++	
				
					Do Case
					Case (nMetQtd/nQtdRegs) >= 1
						nPgNaQtde := Round((nValorCalc*100) * nPCA_QTDE,2)

						nPcComis  = (nPCA_QTDE)*100
						
					Case (nMetQtd/nQtdRegs) >= 0.8 .And. (nMetQtd/nQtdRegs) < 1
						nPgNaQtde := Round((nValorCalc*100) * nPCB_QTDE,2)
						nPcComis  = (nPCB_QTDE)*100
						
					Case (nMetQtd/nQtdRegs) < 0.8 
				    	nPgNaQtde := Round((nValorCalc*100) * nPCC_QTDE,2)
				    	nPcComis  = (nPCC_QTDE)*100
				   
				  
				    	
				EndCase
				       
				Do Case
					Case (nMetVlr/nQtdRegs) >= 1
						nPgNoValor := Round((nValorCalc*100) * nPCA_VALOR,2)
						nPcComisV = (nPCA_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) >= 0.8 .And. (nMetVlr/nQtdRegs) < 1
						nPgNoValor := Round((nValorCalc*100) * nPCB_VALOR,2)
						nPcComisV = (nPCB_VALOR)*100
						
					Case (nMetVlr/nQtdRegs) < 0.8 
				    	nPgNoValor := Round((nValorCalc*100) * nPCC_VALOR,2)
				    	nPcComisV = (nPCC_VALOR)*100       
				    	
				   					    	
				EndCase
			    
				nComiss += Round(nPgNaQtde + nPgNoValor,2)
			  //  nPcComis = 100*(nPCA_VALOR + nPCC_QTDE)  
				//nPcComis /= nQtdRegs
								
			Else	
				nValorCalc := (cAlias)->VALOR 
				
				nPCComRep := SA3->A3_COMIS
				nComiss += Round(nValorCalc * (nPCComRep/100),2)
				nPcComis := nPCComRep
			EndIf                
			
			nValor += nValorCalc
			nQtde  += (cAlias)->QUANTIDADE
			
			(cAlias)->(dbSkip())
	    EndDo
	    (cAlias)->(dbCloseArea())
	    
	 
				
		aAdd(aDados,{SA3->A3_COD,		;	// 01 - Vendedor
	    			 SA3->A3_NOME,		; 	// 02 - Nome
	    			 cTpVend,			;	// 03 - Tipo Vendedor
	    			 nValor,			;	// 04 - Valor
	    			 nQtde}			) 	// 05 - Quantidade
	    			
		Next nX		

EndIf
        
Return aDados
   
/*/{protheus.doc} GetaHeader
*******************************************************************************************
Criacao do aHeader.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetaHeader(nTipo,aCabec,aRodape,nColunas)
Local aHeader 	:= {}
Local nX	  	:= 1
Local cRegra	:= ""

Default nColunas := 0

aCabec := {}
aRodape:= {}

If nTipo==1    
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	// Resumo de Cliente
	aAdd(aHeader,{ "Cliente"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtd. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Qtd. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
	//aAdd(aHeader,{ "Pedidos Total | Por Dezena" 	,"CPO8", "@E!",110,"N",'"s02"',"s01","N"})
	//aAdd(aHeader,{ "% Valor Pedidos Por Dezena"	,"CPO9", "@E!",110,"N",'"s02"',"s01","N"})
	//aAdd(aHeader,{ "Atingiu" 						,"CP10", "@E!",100,"N",'"s02"',"s01","N"})
	            
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	
	
ElseIf nTipo==2
	// Pedidos em Aberto
	aAdd(aHeader,{ "Data Emissão"			 		,"CPO1", "@E!",080,"D",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Pedido" 						,"CPO2", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Item" 	 						,"CPO3", "@E!",050,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO4", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO5", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Produto"					 	,"CPO6", "@E!",100,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Descrição" 						,"CPO7", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde Saldo" 					,"CPO8", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Valor Saldo"					,"CPO9", "@E!",100,"N",'"s02"',"s01","S"})

	aAdd(aRodape,{7,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==3
	// Pedidos Saldo Cliente
	aAdd(aHeader,{ "Mês"					 		,"CPO1", "@E!",050,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO2", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO3", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde Saldo" 					,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Valor Saldo"					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})

	aAdd(aRodape,{3,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==4
	// Devoluções
	aAdd(aHeader,{ "Codigo" 						,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome Cliente" 					,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Motivo Devolução" 				,"CPO3", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Valor"							,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})

	aAdd(aRodape,{3,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==5
	// Bonificação
	aAdd(aHeader,{ "Data" 							,"CPO1", "@E!",080,"D",'"s02"',"s01","N"})
	aAdd(aHeader,{ "NF" 							,"CPO2", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cidade" 						,"CPO3", "@E!",100,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "codCliente"						,"CPO4", "@E!",080,"C",'"s02"',"s01","N"})	
	aAdd(aHeader,{ "nomeCliente"					,"CPO5", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Desconto"						,"CPO6", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Faturado"						,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ ""								,"CPO8", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "observaçãoSeleção"				,"CPO9", "@E!",200,"C",'"s02"',"s01","N"})
	
	aAdd(aRodape,{5,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
ElseIf nTipo==6
	// Meta Real
	aAdd(aHeader,{ "Código" 						,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome Cliente" 					,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	
	aAdd(aCabec,{2,"","@E!",200,"C","s03"})
	For nX:=1 to 12		
		aAdd(aCabec,{3,GetMesAno(nX),"@E!",200,"C","s01"})
		
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
			
		aAdd(aHeader,{ "Meta"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "Real"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "%"			,"CPO"+Alltrim(Str(nX+2)), "@E!",080,"N",'"s02"',"s01","N"})
	Next nX
	
	aAdd(aCabec,{3,"Semestre 1","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO15", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO16", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO17", "@E!",080,"N",'"s02"',"s01","N"})
	                                    
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

	aAdd(aCabec,{3,"Semestre 2","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO18", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO19", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO20", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Total","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO21", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO22", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO23", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==7
	// Meta Real Valor
	aAdd(aHeader,{ "Código" 						,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome Cliente" 					,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	
	aAdd(aCabec,{2,"","@E!",200,"C","s03"})
	For nX:=1 to 12		
		aAdd(aCabec,{3,GetMesAno(nX),"@E!",200,"C","s01"})

		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		
		aAdd(aHeader,{ "Meta"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "Real"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "%"			,"CPO"+Alltrim(Str(nX+2)), "@E!",080,"N",'"s02"',"s01","N"})
	Next nX

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 1","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO15", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO16", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO17", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 2","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO18", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO19", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO20", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Total","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO21", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO22", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO23", "@E!",080,"N",'"s02"',"s01","N"})

ElseIf nTipo==8
	// Meta Real Produto
	aAdd(aHeader,{ "Código" 						,"CPO1", "@E!",100,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Descrição Produto" 				,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	
	aAdd(aCabec,{2,"","@E!",200,"C","s03"})
	For nX:=1 to 12		
		aAdd(aCabec,{3,GetMesAno(nX),"@E!",200,"C","s01"})

		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		
		aAdd(aHeader,{ "Meta"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "Real"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "%"			,"CPO"+Alltrim(Str(nX+2)), "@E!",080,"N",'"s02"',"s01","N"})
	Next nX

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 1","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO15", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO16", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO17", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 2","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO18", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO19", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO20", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Total","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO21", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO22", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO23", "@E!",080,"N",'"s02"',"s01","N"})

ElseIf nTipo==9
	// Resumo de Cliente
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	aAdd(aHeader,{ "Cliente"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Vlr. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Vlr. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
	//aAdd(aHeader,{ "Pedidos Total | Por Dezena" 	,"CPO8", "@E!",110,"N",'"s02"',"s01","N"})
	//aAdd(aHeader,{ "% Valor Pedidos Por Dezena"	,"CPO9", "@E!",110,"N",'"s02"',"s01","N"})
	//aAdd(aHeader,{ "Atingiu" 						,"CP10", "@E!",100,"N",'"s02"',"s01","N"})
                                   
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	

ElseIf nTipo==10
	// Pular Linha	
	For nX:=1 to nColunas
		aAdd(aHeader,{"","CPO1","@E!",080,"C",'"s06"',"s06","N"})
		aAdd(aCabec ,{1,""     ,"@E!",080,"C","s06"})
	Next nX
	aRodape:= {}
	aCabec := {}
	
ElseIf nTipo==11
	// Comissão Calculada
	
	aAdd(aCabec,{2,"Total Vendido"			,"@E!",200,"C","s01"})
	aAdd(aCabec,{3,"Percentuais Atingidos"	,"@E!",200,"C","s01"})
	aAdd(aCabec,{1,"Saldo a Receber"		,"@E!",200,"C","s01"})
	
	aAdd(aHeader,{ "Valor" 				,"CPO1", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde" 				,"CPO2", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "(%) / Valor" 		,"CPO3", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "(%) / Qtde" 		,"CPO4", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Comissao"    		,"CPO5", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Valor a receber" 	,"CPO6", "@E!",110,"N",'"s02"',"s01","N"})
		            
	aRodape := {}

ElseIf nTipo==12
	// Comissão Calculada Sintetizada
	
	aAdd(aCabec,{3,"Dados Vendedor"			,"@E!",200,"C","s01"})
	aAdd(aCabec,{2,"Total Recebido"			,"@E!",200,"C","s01"})
	aAdd(aCabec,{1,"Comissao"				,"@E!",200,"C","s01"})
	aAdd(aCabec,{2,"Percentuais Atingidos"	,"@E!",200,"C","s01"})
	aAdd(aCabec,{1,"Saldo a Receber"		,"@E!",200,"C","s01"})
	
	aAdd(aHeader,{ "Vendedor" 			,"CPO1", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 				,"CPO2", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Tipo" 				,"CPO3", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Valor" 				,"CPO4", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde" 				,"CPO5", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Comissao" 			,"CPO6", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "PC Valor" 			,"CPO7", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "PC Qtde" 			,"CPO8", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Valor Receber" 		,"CPO9", "@E!",110,"N",'"s02"',"s01","S"})
		            
	aAdd(aRodape,{8,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==13
	// Resumo Operação
	aCabec := {}
	
	aAdd(aHeader,{ "Dia" 				,"CPO1", "@E!",110,"D",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Orçado" 			,"CPO2", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vendido (fat)"		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Meta Diaria"		,"CPO4", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Devolucao/Dia" 		,"CPO5", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Descarte/Dia" 		,"CPO6", "@E!",110,"N",'"s02"',"s01","S"})
		            
	aAdd(aRodape,{1,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==14
	//->> Posicao de clientes sintetizada (Qtde)
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	// Resumo de Cliente
	aAdd(aHeader,{ "Vendedor"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtd. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Qtd. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
	            
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	

ElseIf nTipo==15
	//->> Posicao de clientes sintetizada

	// Resumo de Cliente (Valor)
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	aAdd(aHeader,{ "Vendedor"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Vlr. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Vlr. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
                                   
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	


ElseIf nTipo==16
	//->> Posicao de produtos sintetizada (Qtde)
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	// Resumo de Cliente
	aAdd(aHeader,{ "Vendedor"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Produto" 						,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtd. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtd. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Qtd. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
	            
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	

ElseIf nTipo==17
	//->> Posicao de produtos sintetizada

	// Resumo de Cliente (Valor)
	cRegra := "If(Self:aCols[nX,06] >= 100,'s08',If(Self:aCols[nX,11] >= 100,'s09','s10'))"
	
	aAdd(aHeader,{ "Vendedor"			 		 	,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Produto" 						,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Vlr. Un.Saldo Mês Ant." 		,"CPO3", "@E!",110,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Meta Un. Mês" 				,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Vlr. Faturado" 					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "% Atingimento"				 	,"CPO6", "@E!",100,"N",cRegra ,"s01","N"})
	aAdd(aHeader,{ "Vlr. Saldo" 					,"CPO7", "@E!",100,"N",'"s02"',"s01","S"})
                                   
	aAdd(aRodape,{2,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})	
	
	ElseIf nTipo==18
	// Pedidos Saldo Cliente Sintetizado
	
	aAdd(aHeader,{ "Mês"					 		,"CPO1", "@E!",050,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO2", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO3", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde Saldo" 					,"CPO4", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Valor Saldo"					,"CPO5", "@E!",100,"N",'"s02"',"s01","S"})

	aAdd(aRodape,{3,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"})   
	
	ElseIf nTipo==19
	// Pedidos em Aberto Sintetizado
	aAdd(aHeader,{ "Data Emissão"			 		,"CPO1", "@E!",080,"D",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Pedido" 						,"CPO2", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Cliente" 						,"CPO4", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 							,"CPO5", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Produto"					 	,"CPO6", "@E!",100,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Descrição" 						,"CPO7", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Estoque"    					,"CPO8", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Qtde Saldo" 					,"CPO8", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Valor Saldo"					,"CPO9", "@E!",100,"N",'"s02"',"s01","S"})

	aAdd(aRodape,{7,"Totais:","C","s01"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 

ElseIf nTipo==20
	// Meta Real Valor
	aAdd(aHeader,{ "Código" 						,"CPO1", "@E!",080,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome Cliente" 					,"CPO2", "@E!",200,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "OPERADOR" 	    				,"CPO3", "@E!",080,"C",'"s02"',"s01","N"})
	
	aAdd(aRodape,{3,"Totais:","C","s01"}) 
	
	aAdd(aCabec,{3,"","@E!",200,"C","s03"})
	For nX:=1 to 12		
		aAdd(aCabec,{3,GetMesAno(nX),"@E!",200,"C","s01"})

		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		aAdd(aRodape,{1,Nil,"N","s07"}) 
		
		aAdd(aHeader,{ "Meta"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "Real"		,"CPO"+Alltrim(Str(nX+2)), "@E!",100,"N",'"s02"',"s01","S"})
		aAdd(aHeader,{ "%"			,"CPO"+Alltrim(Str(nX+2)), "@E!",080,"N",'"s02"',"s01","N"})
	Next nX

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 1","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO15", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO16", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO17", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Semestre 2","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO18", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO19", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO20", "@E!",080,"N",'"s02"',"s01","N"})

	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	aAdd(aRodape,{1,Nil,"N","s07"}) 
	
	aAdd(aCabec,{3,"Total","@E!",200,"C","s01"})
	aAdd(aHeader,{ "Meta"			,"CPO21", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "Real"			,"CPO22", "@E!",100,"N",'"s02"',"s01","S"})
	aAdd(aHeader,{ "%"				,"CPO23", "@E!",080,"N",'"s02"',"s01","N"})

    ElseIf nTipo==21
	// Total por vendedor
	
	aAdd(aCabec,{3,"Dados Vendedor"			,"@E!",200,"C","s01"})
	aAdd(aCabec,{2,"Total Vendido"			,"@E!",200,"C","s01"})
	
	aAdd(aHeader,{ "Vendedor" 			,"CPO1", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Nome" 				,"CPO2", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Tipo" 				,"CPO3", "@E!",110,"C",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Valor" 				,"CPO4", "@E!",110,"N",'"s02"',"s01","N"})
	aAdd(aHeader,{ "Qtde" 				,"CPO5", "@E!",110,"N",'"s02"',"s01","N"})

	//aAdd(aRodape,{8,"Totais:","C","s01"}) 



	
EndIf

Return aHeader
   
/*/{protheus.doc} GetMesAno
*******************************************************************************************
Retorna o mês-ano para label do campo
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetMesAno(nMes)
Local cRet 	:= ""
Local cAno	:= Right(Alltrim(Str(Year(Date()))),2)
           
Do Case
	Case nMes == 1
		cRet := "Janeiro-"+cAno
	
	Case nMes == 2
		cRet := "Fevereiro-"+cAno
		
	Case nMes == 3
		cRet := "Marco-"+cAno
	
	Case nMes == 4
		cRet := "Abril-"+cAno
	
	Case nMes == 5
		cRet := "Maio-"+cAno
	
	Case nMes == 6
		cRet := "Junho-"+cAno
	
	Case nMes == 7
		cRet := "Julho-"+cAno
	
	Case nMes == 8
		cRet := "Agosto-"+cAno
	
	Case nMes == 9
		cRet := "Setembro-"+cAno
	
	Case nMes == 10
		cRet := "Outubro-"+cAno
	
	Case nMes == 11
		cRet := "Novembro-"+cAno
	
	Case nMes == 12
		cRet := "Dezembro-"+cAno
		
End Case

Return cRet

/*/{protheus.doc} GetVendedor
*******************************************************************************************
Retorna array com os vendedores.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetVendedor(cVendDe,cVendAte,lJob)
Local aVendedores 	:= {}
Local cQuery 		:= ""
Local cAlias		:= GetNextAlias()   
Local cHorEnv	 	:= Alltrim(GetNewPar("MC_HENVREL","19:00:00"))
Local dAtual		:= Date()
Local cNextEnv 		:= StrZero(Day(dAtual),2)+"/"+StrZero(Month(dAtual),2)+"/"+StrZero(Year(dAtual),4)+" "+cHorEnv

Default lJob		:= .F.

cQuery := "SELECT DISTINCT * FROM ("												+CRLF
cQuery += "SELECT DISTINCT 	SA3.R_E_C_N_O_ 		AS RECSA3,"							+CRLF
cQuery += "		  			SA3.A3_COD 	 		AS CODIGO,"							+CRLF
cQuery += "		  			SA3.A3_NOME 	 	AS NOME"							+CRLF
cQuery += "	 FROM "+RetSqlName("SA3")+" SA3 (NOLOCK)"								+CRLF
cQuery += "	 INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"							+CRLF
cQuery += "			ON	SA1.A1_FILIAL  =	'"+xFilial("SA1")+"'"					+CRLF
cQuery += "			AND SA1.A1_VEND    = SA3.A3_COD"								+CRLF
cQuery += "			AND SA1.D_E_L_E_T_ = ' '"										+CRLF
cQuery += "		WHERE   SA3.A3_FILIAL = '"+xFilial("SA3")+"'"						+CRLF
cQuery += "			AND SA3.A3_COD BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'"		+CRLF
cQuery += "			AND SA3.A3_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA1.A1_MSBLQL <> '1'"										+CRLF
If lJob
	If aRetParam[16] == 1 .And. SA3->(FieldPos("A3_XPRXENV"))>0
		cQuery += "	AND (SA3.A3_XPRXENV = ' ' OR SA3.A3_XPRXENV <= '"+cNextEnv+"')"	+CRLF
    EndIf
EndIf 
cQuery += "			AND SA3.D_E_L_E_T_ = ' '"										+CRLF
cQuery += "UNION ALL"																+CRLF
cQuery += "SELECT DISTINCT 	SA3.R_E_C_N_O_ 		AS RECSA3,"							+CRLF
cQuery += "		  			SA3.A3_COD 	 		AS CODIGO,"							+CRLF
cQuery += "		  			SA3.A3_NOME 	 	AS NOME"							+CRLF
cQuery += "	 FROM "+RetSqlName("SA3")+" SA3 (NOLOCK)"								+CRLF
cQuery += "	 INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK)"							+CRLF
cQuery += "			ON	SA1.A1_FILIAL  =	'"+xFilial("SA1")+"'"					+CRLF
cQuery += "			AND SA1.A1_VEND1   = SA3.A3_COD"								+CRLF
cQuery += "			AND SA1.D_E_L_E_T_ = ' '"										+CRLF
cQuery += "		WHERE   SA3.A3_FILIAL = '"+xFilial("SA3")+"'"						+CRLF
cQuery += "			AND SA3.A3_COD BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'"		+CRLF
cQuery += "			AND SA3.A3_MSBLQL <> '1'"										+CRLF
cQuery += "			AND SA1.A1_MSBLQL <> '1'"										+CRLF
If lJob
	If aRetParam[16] == 1 .And. SA3->(FieldPos("A3_XPRXENV"))>0
		cQuery += "	AND (SA3.A3_XPRXENV = ' ' OR SA3.A3_XPRXENV <= '"+cNextEnv+"')"	+CRLF
    EndIf
EndIf 
cQuery += "			AND SA3.D_E_L_E_T_ = ' '"										+CRLF
cQuery += ") AS TMP"																+CRLF
cQuery += "	 ORDER BY TMP.CODIGO"													+CRLF

If !lJob
	FwMsgRun(,{|| (	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.),;
	   				(cAlias)->(dbGotop())) },;
					"Aguarde...","Filtrando Vendedores para o processamento...")
Else
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)
EndIf	

Do While (cAlias)->(!Eof())
	aAdd(aVendedores,{	(cAlias)->CODIGO,; 	// 01 - CODIGO DO VENDEDOR
						(cAlias)->NOME,; 	// 02 - NOME DO VENDEDOR
						(cAlias)->RECSA3}) 	// 03 - RECNO DA TABELA DE VENDEDORES

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return aVendedores

/*/{protheus.doc} MCRJob010A
*******************************************************************************************
Job de Extração do relatório.
 
@author: Marcelo Celi Marques
@since: 05/07/2019
@param: 
@return:
@type function: Usuário
*******************************************************************************************
/*/
User Function MCRJob010A(_cEmp, _cFil, _cHorInic,_cHorFinal,_nMin,_cNickName)
Local nTempo  		:= 0	
Local nMin  		:= 1
Local cHorInic		:= ""
Local cHorFinal		:= ""

Default _cEmp		:= "01"
Default _cFil		:= "0101"
Default _cHorInic	:= "18"
Default _cHorFinal	:= "19"
Default _nMin		:= "58"
Default _cNickName	:= "MCRFAT010A"
    
nMin 		:= Val(_nMin)
cHorInic	:= Alltrim(_cHorInic)+":00:00"  
cHorFinal	:= Alltrim(_cHorFinal)+":00:00" 
nTempo 		:= (nMin * 60) * 1000      

If LockByName(_cNickName,.F.,.F.) 
	ExibConsole("[Agendado das: "+cHorInic+"  as: "+cHorFinal+", a cada "+Alltrim(Str(nMin))+" minutos]")
	While !KillApp()
		If (!Empty(cHorInic) .And. !Empty(cHorFinal) .And. Time() >= cHorInic .And. Time() <= cHorFinal) .Or. (Empty(cHorInic) .And. Empty(cHorFinal))
			ExibConsole("Execução do Relatório Gerencial por Vendedores")			
			StartJob( "U_MCJbRGerVd",GetEnvServer(),.T.,_cEmp,_cFil,_cNickName )
			//U_MCJbRGerVd(_cEmp,_cFil,_cNickName)
	  		Sleep(nTempo)
   		EndIf
        Sleep(1 * 60 * 1000)            
     EndDo    
     UnLockByName(_cNickName,.F.,.F.)
EndIf
      
Return

/*/{protheus.doc} MCJbRGerVd
*******************************************************************************************
Processamento do Job 
 
@author: Marcelo Celi Marques
@since: 05/06/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/   
User Function MCJbRGerVd(cEmp,cFil,cNickName)
Default cEmp 		:= ""
Default cFil 		:= ""
Default cNickName 	:= ""

If !Empty(cEmp) .And. !Empty(cFil)
	RPCSETTYPE(3)
	RPCSETENV(cEmp,cFil,,,'FAT',cNickName)
EndIf

ProcRelato(.T.,1) //->> Por/Vendedor
ProcRelato(.T.,2) //->> Por/Consolidado
   
Return

/*/{protheus.doc} ExibConsole
*******************************************************************************************
Exibição do Console
 
@author: Marcelo Celi Marques
@since: 05/06/2019
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ExibConsole(cMensagem)
Local cMsg1 	:= "< RELATORIO GERENCIAL DE VENDEDORES >"
Local cMsg2 	:= "Ambiente: "+Alltrim(getenvserver())
Local cMsg3 	:= "Execução: "+Dtoc(Date())+" - "+Time()
Local nTamMsg   := Len(cMensagem)

If nTamMsg <= 50
	nTamMsg := 50
EndIf                                     
Conout("")
Conout(Replicate("*",nTamMsg+4))
Conout("* "+cMsg1+Replicate(" ",nTamMsg - Len(cMsg1) )+" *")
Conout("* "+cMsg2+Replicate(" ",nTamMsg - Len(cMsg2) )+" *")
Conout("* "+cMsg3+Replicate(" ",nTamMsg - Len(cMsg3) )+" *")
Conout("* "+Replicate(" ",nTamMsg)+" *")
Conout("* "+cMensagem+Replicate(" ",nTamMsg - Len(cMensagem) )+" *")
Conout(Replicate("*",nTamMsg+4))
Conout("")

Return
