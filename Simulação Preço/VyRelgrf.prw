#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TBICODE.CH"                                
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"  
  
/*/{protheus.doc} VyRelgrf
*******************************************************************************************
Classe principal do objeto de criacao de HTML.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Class VyRelgrf

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

EndClass

/*/{protheus.doc} New
*******************************************************************************************
Metodo de inicializacao do objeto VyRelgrf.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method New(aPlanilha,cPasta,cArquivo) Class VyRelgrf
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
@since: 01/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method CreateHtml() Class VyRelgrf
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
Local nPosStyl		:= 0
Local nPosType		:= 0
Local nPosCelula	:= 0
Local cType			:= ""

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
					//->> Marcelo Celi - 04/06/2020
					cType := ""
					If Len(::aCols[nX]) > Len(::aHeader)
						nPosSpecial := Len(::aCols[nX])
						If Valtype(::aCols[nX][nPosSpecial]) == "A"						
							nPosType := Ascan(::aCols[nX][nPosSpecial],{|x| Upper(Alltrim(x[01])) == Upper(Alltrim("StyleType"))  })
							If nPosType > 0
								nPosCelula := Ascan(::aCols[nX][nPosSpecial][nPosType,2],{|x| x[01] == nY })
								If Valtype(nPosCelula)=="N" .And. nPosCelula > 0
									cType := Alltrim(Upper(::aCols[nX,nPosSpecial][nPosType,2][nPosCelula][02]))
								EndIf	
							EndIf						
						EndIf
					EndIf

					If Empty(cType)
						cType := Alltrim(Upper(::aHeader[nY,05]))
					EndIf
					
					If cType=="C"
						xText 	:= NoAcento(Alltrim(::aCols[nX,nY]))
						cTipo	:= "String"
					ElseIf cType=="D"					
						//xText 	:= dToc(::aCols[nX,nY])				
						//cTipo   := "String"

						//->> Marcelo Celi - DFS - 05/11/2020
						xText 	:= StrZero(Year(::aCols[nX,nY]),4)+'-'+StrZero(Month(::aCols[nX,nY]),2)+'-'+StrZero(Day(::aCols[nX,nY]),2)+'T00:00:00.000'
						cTipo   := "DateTime"

					ElseIf cType=="N"
						xText 	:= Alltrim(Str(::aCols[nX,nY]))
						cTipo   := "Number"
						
						//->> Incrementador de Totais
						If ::aHeader[nY,08]=="S"
							aTotais[nY]+=::aCols[nX,nY]
						EndIf
								
					EndIf
					
					//->> Marcelo Celi - 03/06/2020
					cStyle := ""
					If Len(::aCols[nX]) > Len(::aHeader)
						nPosSpecial := Len(::aCols[nX])
						If Valtype(::aCols[nX][nPosSpecial]) == "A"						
							nPosStyl := Ascan(::aCols[nX][nPosSpecial],{|x| Upper(Alltrim(x[01])) == Upper(Alltrim("LineStyleID"))  })
							If nPosStyl > 0
								cStyle := ::aCols[nX,nPosSpecial][nPosStyl][02]
							EndIf						
						EndIf
					EndIf
					If Empty(cStyle)
						cStyle := &(::aHeader[nY,06])					
					EndIf
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
@since: 01/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method WriteHtml() Class VyRelgrf                 
Local aHtml 	:= {}
Local cPath 	:= ""
Local nX		:= 0                                            
Local cArquivo  := ::cArquivo                 
Local cSeq		:= "001"

cPath 	:= AllTrim(::cPasta)+cArquivo+".xml"
If File(cPath)
	If MsgYesNo("Arquivo ja existe no local."+CRLF+"Deseja substitui-lo ?")
		FErase(cPath)
		If File(cPath)
			MsgAlert("Arquivo nao pode ser apagado."+CRLF+"Uma nova sequencia dele sera criada.")
		EndIf
	EndIf
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

::cArquivo := cArquivo

Return
   
/*/{protheus.doc} CabSheetHtml
*******************************************************************************************
Cria o Cabecalho do sheet.
 
@author: Marcelo Celi Marques
@since: 01/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Static Function CabSheetHtml(cDescr,aHeader,aCabec,aTitulos)
Local cHtml 		:= ""
Local nX			:= 1
Local cStyleID		:= ""
Local cTitulo		:= ""
Local nMergeAcross	:= 0

Default cDescr 		:= ""
Default aHeader		:= {}
Default aCabec 		:= {}
Default aTitulos	:= {}

If !Empty(cDescr)
	cHtml += '<Worksheet ss:Name="'+Alltrim(cDescr)+'">'+CRLF
	
	cHtml += '  <Table ss:ExpandedColumnCount="250" ss:ExpandedRowCount="65536" x:FullColumns="1"'+CRLF
	cHtml += '   x:FullRows="1" ss:DefaultRowHeight="17">'+CRLF

	For nX:=1 to Len(aHeader)
		cHtml += ' <Column ss:Width="'+Alltrim(Str(aHeader[nX,04]))+'"/>'+CRLF 
	Next nX	
	
	If Len(aTitulos) > 0
	    If Len(aTitulos) >= 1			
			nMergeAcross    := Len(aHeader)-1
			cTitulo			:= Alltrim(aTitulos[01,01])
			cStyleID		:= Alltrim(aTitulos[01,02])
			
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="'+Alltrim(Str(nMergeAcross))+'" ss:StyleID="'+cStyleID+'"><Data ss:Type="String">'+cTitulo+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
			cHtml += '   </Row>'+CRLF

		EndIf		
		If Len(aTitulos) >= 2
			nMergeAcross    := Len(aHeader)-1
			cTitulo			:= Alltrim(aTitulos[02,01])
			cStyleID		:= Alltrim(aTitulos[02,02])
			
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="'+Alltrim(Str(nMergeAcross))+'" ss:StyleID="'+cStyleID+'"><Data ss:Type="String">'+cTitulo+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
			cHtml += '   </Row>'+CRLF

		EndIf		
		If Len(aTitulos) >= 3
			nMergeAcross    := Len(aHeader)-1
			cTitulo			:= Alltrim(aTitulos[03,01])
			cStyleID		:= Alltrim(aTitulos[03,02])
			
			cHtml += '   <Row ss:AutoFitHeight="1">'+CRLF
			cHtml += '    <Cell ss:MergeAcross="'+Alltrim(Str(nMergeAcross))+'" ss:StyleID="'+cStyleID+'"><Data ss:Type="String">'+cTitulo+'</Data><NamedCell ss:Name="Database"/></Cell>'+CRLF		
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
@since: 01/06/2020
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
cHtml += '   <Interior ss:Color="'+RGBToHexa(37,132,135)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s01d">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(255,255,255)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(37,132,135)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Short Date"/>'+CRLF
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

cHtml += '  <Style ss:ID="s02d">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(255,255,255)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Short Date"/> '+CRLF
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

cHtml += '  <Style ss:ID="s11">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(255,255,255)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(103,104,107)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s12">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(0,0,0)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(191,191,191)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s13">'+CRLF
cHtml += '   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="1" ss:Size="11" ss:Color="'+RGBToHexa(255,255,255)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(46,166,169)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="0"/>'+CRLF
cHtml += '  </Style>'+CRLF

cHtml += '  <Style ss:ID="s14">'+CRLF
cHtml += '   <Borders>'+CRLF
cHtml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
cHtml += '   </Borders>'+CRLF
cHtml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Bold="0" ss:Size="10" ss:Color="'+RGBToHexa(89,89,89)+'"/>'+CRLF
cHtml += '   <Interior ss:Color="'+RGBToHexa(216,216,216)+'" ss:Pattern="Solid"/>'+CRLF
cHtml += '   <NumberFormat ss:Format="Standard"/> '+CRLF
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
@since: 01/06/2020
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
@since: 01/06/2020
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
@since: 01/06/2020
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
@since: 01/06/2020
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
Local cAgudo := "�����"+"�����"
Local cCircu := "�����"+"�����"
Local cTrema := "�����"+"�����"
Local cCrase := "�����"+"�����" 
Local cTio   := "��"
Local cCecid := "��"
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
