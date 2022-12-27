#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  

//*****************************************************************************************************************> CLASSE/METODOS  <************************

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Class MCRadioImg

//Propriedades                                           
Data oWnd							//-->> Objeto de Tela
Data oDlg							//-->> Objeto de Tela
Data aPanels						//-->> Array de Paineis
Data nPainel						//-->> Numero do Painel Selecionado
Data nColunas						//-->> Numero de Colunas a Exibir
Data aDados							//-->> Array com os Dados
Data lSelec							//-->> Flag de Seleção     
Data oFont01						//-->> Fonte
Data oFont02						//-->> Fonte
Data oFont03						//-->> Fonte
Data nCorNotSel	
Data nCorSel	
Data nRefresh						//-->> Contador de Refresh
Data cTitulo
Data nMrkInic						//-->> Marcacao inicial

//Metodos
Method New() 						//-->> Constructor   
Method Iniciar()					//-->> Imprimir       
Method CompletaDados()				//-->> Complemento de Dados
Method Refresh()					//-->> Atualiza a Tela    
Method AjustaDados()      
Method AtuMarcacao()      
Method SetArray()

EndClass

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method New() Class MCRadioImg    
Return Self
                                   
/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Iniciar(oDlg,nColunas,aDados,cTitulo,nMrkInic) Class MCRadioImg
Local nX		:= 1    
Local nY		:= 1                    
Local aPainel	:= {}
Local oDlgTBox

Default cTitulo	:= ""
Default nMrkInic:= 0
          
If nColunas == NIL
	nColunas := Self:nColunas
EndIf                        

If oDlg == NIL
	oDlg := Self:oWnd
EndIf                        

If aDados == NIL
	aDados := Self:aDados
EndIf                        
                                                   
Self:oWnd		:= oDlg
Self:oDlg		:= TScrollBox():New(Self:oWnd,2,2,(Self:oWnd:NHEIGHT/2)-2,(Self:oWnd:NWIDTH/2)-2,.T.,.T.,.T.)
Self:aPanels	:= {}
Self:nPainel	:= 0
Self:nColunas	:= nColunas
Self:aDados		:= aDados 
Self:lSelec		:= .F.    
Self:nRefresh	:= 0 
Self:cTitulo	:= cTitulo
     
Self:oFont01	:= TFont():New('Courier new',,-23,,.F.) 
Self:oFont02	:= TFont():New('Courier new',,-18,,.T.) 
Self:oFont03	:= TFont():New('Courier new',,-12,,.F.) 

Self:nCorNotSel	:= RGB(255,255,255)
Self:nCorSel	:= RGB(233,240,246)
Self:nMrkInic	:= nMrkInic
                       
oDlgTBox 		:= TToolBox():New(01,01,Self:oWnd,Self:oWnd:NWIDTH/2,Self:oWnd:NHEIGHT/2)
oDlgTBox:AddGroup( Self:oDlg , Self:cTitulo )
        
For nX:=1 to Len(Self:aDados)
	aAdd(aPainel,TPanel():New(01,01,"",Self:oDlg,,,,,,(Self:oDlg:NWIDTH/2),45,.F.,.F.))	
	aPainel[Len(aPainel)]:Align := CONTROL_ALIGN_TOP
	For nY:=1 to Self:nColunas	
		If nX > Len(Self:aDados)
			Exit
		EndIf
		aAdd(Self:aPanels,;
				{TPanel():New(01,01,"",aPainel[Len(aPainel)],,,,,,(Self:oDlg:NWIDTH/2)/Self:nColunas,45,.F.,.F.),;	// 01 ->> Painel
				Nil,;																								// 02 ->> Objeto do CheckBox 
				Nil,;																								// 03 ->> Objeto de Imagem
				Self:aDados[nX,01],; 																				// 04 ->> Texto
				Self:aDados[nX,02],;																				// 05 ->> Texto Tool
				Self:aDados[nX,03],;																				// 06 ->> Array com dados da imagem
				Self:lSelec,;  																						// 07 ->> Seleção do Item
				Self:aDados[nX,04],;																				// 08 ->> Macro execucao do codigo de bloco
				Self:aDados[nX,05],;																				// 09 ->> Se objeto estara disponivel
				})      
				
				Self:aPanels[Len(Self:aPanels)][01]:Align := CONTROL_ALIGN_LEFT
	    nX++
    Next nY
    nX--                       
Next nX 

Self:CompletaDados(.F.)

Return Self

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method SetArray(aDados) Class MCRadioImg
Self:aDados := aDados
Self:Refresh()
Return Self

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method Refresh() Class MCRadioImg
Local nX 		:= 1       
Local aPainel	:= {}

Self:nRefresh++              
                           
For nX:=1 to Len(Self:aPanels)           
	Self:aPanels[nX,08] 		 := .F.
	Self:aPanels[nX,01]:LVisible := .F.
Next nX
                   
For nX:=1 to Len(Self:aDados)         
	If nX <= Len(Self:aPanels)	
		Self:aPanels[nX,01]:LVisible := .T.	
		Self:aPanels[nX,04] := Self:aDados[nX,01]
		Self:aPanels[nX,05] := Self:aDados[nX,02]
		Self:aPanels[nX,06] := Self:aDados[nX,03]
		Self:aPanels[nX,08] := Self:aDados[nX,04]
		Self:aPanels[nX,09] := Self:aDados[nX,05]
		
	Else                                            
		aAdd(aPainel,TPanel():New(01,01,"",Self:oDlg,,,,,,(Self:oDlg:NWIDTH/2),45,.F.,.F.))	
		aPainel[Len(aPainel)]:Align := CONTROL_ALIGN_TOP
		
		aAdd(Self:aPanels,;
				{TPanel():New(01,01,"",aPainel[Len(aPainel)],,,,,,(Self:oDlg:NWIDTH/2)/Self:nColunas,40,.T.,.T.),;			// 01 ->> Painel
				Self:aDados[nX,01],; 																						// 02 ->> Radio
				Self:aDados[nX,02],;																						// 03 ->> Imagem
				Self:aDados[nX,01],;																						// 04 ->> Texto
				Self:aDados[nX,02],;																						// 05 ->> Texto de toobox
				Self:aDados[nX,03],;																						// 06 ->> dados da imagem [resname,coor vert ini,cood horiz inic,largura,altura]
				Self:lSelec,;  																								// 07 ->> Seleção do Item
				Self:aDados[nX,04],;																						// 08 ->> Macro executa bloco de codigo
				Self:aDados[nX,05],;																						// 09 ->> Se objeto estara diponivel
				})      
				
		Self:aPanels[Len(Self:aPanels)][01]:Align := CONTROL_ALIGN_LEFT						
		self:AjustaDados(Len(Self:aPanels))
		
	EndIf	
Next nX
Self:CompletaDados(.T.)

Self:oDlg:Refresh()
Self:oWnd:Refresh()

Return Self 

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method CompletaDados(lRefresh) Class MCRadioImg
Local nX := 1              
           
For nX:=1 to Len(Self:aPanels)	
	If !lRefresh
		Self:AjustaDados(nX)
    Else                     
    	//->> Objeto de Checkbox   
    	self:APANELS[nX][2]:CCAPTION := Self:aPanels[nX,04]
    	
	    //->> Objetos de Imagem
	    Self:aPanels[nX,03]:CRESNAME := Self:aPanels[nX,06,01]
    	Self:aPanels[nX,03]:Refresh()                            
        
    EndIf
    
Next nX

Return Self          

/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method AtuMarcacao(nPos) Class MCRadioImg
Local nX 	:= 0

For nX:=1 to Len(Self:APANELS)
    If nX <> nPos       
    	self:APANELS[nX][7] := .F.
    Else                   
    	If !self:APANELS[nX][7]
    		self:APANELS[nX][7] := .T.
    	Else
    		self:APANELS[nX][7] := self:APANELS[nX][7]
    	EndIf
    EndIf
	If Valtype(self:APANELS[nX][2]) == "O"
		self:APANELS[nX][2]:CtrlRefresh()
		self:APANELS[nX][2]:LACTIVE := self:APANELS[nX][9]
	EndIf	                       
	Self:APANELS[nX][1]:Refresh()		
	
	If self:APANELS[nX][7]	
		If !Empty(Self:aPanels[nX,08])
			Eval(Self:aPanels[nX,08])
		EndIf	
	EndIf	
	
Next nX

Return Nil
           
/*/{protheus.doc} MCRadioImg
*******************************************************************************************
Classe de radio com imagem
 
@author: Marcelo Celi Marques
@since: 16/06/2020
@param: 
@return:
@type function: Classe
*******************************************************************************************
/*/
Method AjustaDados(nPos) Class MCRadioImg
Local cCmd		:= "{|| Self:aPanels["+Alltrim(Str(nPos))+",07] }"
Local cCmd2		:= "{|| Self:AtuMarcacao("+Alltrim(Str(nPos))+") }"

//->> Objetos de Imagem
If !Empty(Self:aPanels[nPos,06,01])
	Self:aPanels[nPos,03] := TBitmap():New(02,02,20,20,Self:aPanels[nPos,06,01]	,Nil						,.T.,Self:aPanels[nPos,01],,,.F.,.T.,,,.F.,,.T.,,.F.)
ElseIf !Empty(Self:aPanels[nPos,06,02])
	Self:aPanels[nPos,03] := TBitmap():New(02,02,20,20,Nil						,Self:aPanels[nPos,06,02]	,.T.,Self:aPanels[nPos,01],,,.F.,.T.,,,.F.,,.T.,,.F.)
Else
	Self:aPanels[nPos,03] := TBitmap():New(02,02,20,20,"ENABLE"					,Nil						,.T.,Self:aPanels[nPos,01],,,.F.,.T.,,,.F.,,.T.,,.F.)
EndIf
                       
//->> Objeto de Checkbox
Self:aPanels[nPos,02] := TCheckBox():New(25,05,Self:aPanels[nPos,04],&cCmd,Self:aPanels[nPos,01],(Self:APANELS[nPos][1]:NCLIENTWIDTH)/2,30,,,Self:oFont02,,CLR_RED,CLR_WHITE,,.T.,Self:aPanels[nPos,05],,)
Self:aPanels[nPos,02] :BCHANGE := &cCmd2
Self:aPanels[nPos,02] :LACTIVE := Self:aPanels[nPos][9]

If Self:nMrkInic > 0 .And. nPos == Self:nMrkInic
	self:APANELS[nPos][7] := .T.
EndIf
                                
Return Self 
      
//->> testar

User Function McTstRadio()
Local aDados	:= {}
Local oDlg        
Local oRdImagem	:= Nil

Private __cBco := ""

aAdd(aDados,{"Itau"		,"Geracao de Boletos para o Banco Itau"		,{"","341.bmp"},{|| __cBco := "341"},.T.})
aAdd(aDados,{"Bradesco"	,"Geracao de Boletos para o Banco Bradesco"	,{"","237.bmp"},{|| __cBco := "237"},.T.})
aAdd(aDados,{"Santander","Geracao de Boletos para o Banco Santander",{"","033.bmp"},{|| __cBco := "033"},.T.})
                                                                 
DEFINE MSDIALOG oDlg TITLE "teste" FROM 0,0 To 500,1000 PIXEL 

oRdImagem := MCRadioImg():New()
oRdImagem:Iniciar(oDlg,4,aDados,"Geração de boletos",2)
                 
ACTIVATE MSDIALOG oDlg Center

Return
   
   
   