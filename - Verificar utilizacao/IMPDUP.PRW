#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPDUP    บAutor  ณClistenis Batista   บ Data ณ  16/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressใo de Duplicata a pedido do Sr. Roberto            บฑฑ
ฑฑบ          ณ  MODULO: Faturamento                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENIX                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IMPDUP()

///////////////////////////////////////////////////////////////////////
///Variaveis de fontes                                             ////
///////////////////////////////////////////////////////////////////////   
Private oFont6		:= TFONT():New("ARIAL",7,6,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 6 Normal
Private oFont8		:= TFONT():New("ARIAL",9,8,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 8 Normal
Private oFont8N 	:= TFONT():New("ARIAL",9,8,,.T.,,,,.T.,.F.) ///Fonte 8 Negrito
Private oFont10 	:= TFONT():New("ARIAL",9,10,.T.,.F.,5,.T.,5,.T.,.F.) ///Fonte 10 Normal
Private oFont10S	:= TFONT():New("ARIAL",9,10,.T.,.F.,5,.T.,5,.T.,.T.) ///Fonte 10 Sublinhando
Private oFont10N 	:= TFONT():New("ARIAL",9,10,,.T.,,,,.T.,.F.) ///Fonte 10 Negrito
Private oFont10NS 	:= TFONT():New("ARIAL",9,10,,.T.,,,,.T.,.T.) ///Fonte 10 Negrito Sublinhado
Private oFont11		:= TFONT():New("ARIAL",11,11,,.F.,,,,.T.,.F.) ///Fonte 11 Normal
Private oFont11NS	:= TFONT():New("ARIAL",11,11,,.T.,,,,.T.,.T.) ///Fonte 11 Negrito e Sublinhado
Private oFont11N	:= TFONT():New("ARIAL",11,11,,.T.,,,,.T.,.F.) ///Fonte 11 Negrito
Private oFont12		:= TFONT():New("ARIAL",12,12,,.F.,,,,.T.,.F.) ///Fonte 12 Normal
Private oFont12NS	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.T.) ///Fonte 12 Negrito e Sublinhado
Private oFont12N	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.F.) ///Fonte 12 Negrito
Private oFont13 	:= TFONT():New("ARIAL",13,13,,.F.,,,,.T.,.F.) ///Fonte 13 Normal 
Private oFont13N	:= TFONT():New("ARIAL",13,13,,.T.,,,,.T.,.F.) ///Fonte 13 Negrito
Private oFont14 	:= TFONT():New("ARIAL",14,14,,.F.,,,,.T.,.F.) ///Fonte 14 Normal 
Private oFont14N	:= TFONT():New("ARIAL",14,14,,.T.,,,,.T.,.F.) ///Fonte 14 Negrito
Private oFont16 	:= TFONT():New("ARIAL",16,16,,.F.,,,,.T.,.F.) ///Fonte 16 Normal
Private oFont16N	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.F.) ///Fonte 16 Negrito
Private oFont16NS	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.T.) ///Fonte 16 Negrito e Sublinhado
Private oFont22N	:= TFONT():New("ARIAL",22,22,,.T.,,,,.T.,.F.) ///Fonte 22 Negrito
Private cStartPath
Private nLin 		:= 50
Private oPrint		:= TMSPRINTER():New("")
Private nPag		:= 1
Private oBrush1 	:= TBrush():New( , CLR_HGRAY )     //CLR_HGRAY
Private _cNFE		:= SE1->E1_NUM
Private _cFilial	:= SE1->E1_FILIAL
Private EOL  := Chr(13)+Chr(10)

//Tamanho do Papel A4
#define DMPAPER_A4 9

//Orientacao do papel (Retrato ou Paisagem)
//TMSPrinter(): SetPaperSize ()
//oPrint:SetLandscape() ///Define a orientacao da impressao como paisagem
oPrint:SetPortrait()///Define a orientacao da impressao como retrato

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ฟ
//ณMonta Query com itens para separa็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ู
cQry:=EOL+ "SELECT E1_NUM                                                                                   "
cQry+=EOL+ ",E1_PREFIXO                                                                                     "
cQry+=EOL+ ",E1_VALOR                                                                                       "
cQry+=EOL+ ",E1_CLIENTE                                                                                       "
cQry+=EOL+ ",E1_PARCELA                                                                                     "
cQry+=EOL+ ",E1_VENCREA                                                                                     "   
cQry+=EOL+ ",E1_DESCFIN                                                                                      "
cQry+=EOL+ ",E1_EMISSAO                                                                                     "
cQry+=EOL+ "FROM  "+RetSqlName("SE1")+"  SE1                                                                "
cQry+=EOL+ "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  "                                                       "
cQry+=EOL+ "AND SE1.D_E_L_E_T_ != '*'                                                                       "
cQry+=EOL+ "AND E1_NUM = '"+SE1->E1_NUM+"'				      										        "
cQry+=EOL+ "ORDER BY E1_PARCELA                                                                             "
		
cQry := ChangeQuery(cQry)

If Select("QRY") > 0 
    QRY->(dbCloseArea()) 
EndIf

TCQUERY cQry NEW ALIAS "QRY"

If Empty(QRY->E1_NUM)    
	MsgAlert("Nใo foi encontrado nenhum titulo com esse numero! ","Aten็ใo")
	oPrint:EndPage()
	Return 
EndIf 

While QRY->(!EOF()) 
	//Monta o Cabe็alho
	Cabec()         
//	nLin+=50
	//nLin+=200 
	_cNota := QRY->E1_NUM

	While QRY->(!EOF()) .and. _cNota == _cNFE
	//Salto de Pagina
		//Se nLin for maior que 1 entใo crie uma nova pagina.
//		If nLin > 1 //Valor original 2400
//		Rod() 
//		Alert (nPag)
//		nLin := 50
		Cabec()
//		nLin+=200
//		Endif    
		oPrint:Say(360, 1600,  DtoC(StoD(QRY->E1_EMISSAO)), oFont10N) //Data de Emissใo
		oPrint:Say(530, 350,  QRY->E1_NUM, oFont10N) //Numero da Nota Fiscal ou do Titulo
		oPrint:Say(530, 700,  "R$ "+Transform(QRY->E1_VALOR,"@E 9,999,999.99"), oFont10N) //Valor do titulo
		IF (QRY->E1_PARCELA = " ")                                                   
		oPrint:Say(530, 1250, AllTrim(QRY->E1_NUM)+"-ฺnica", oFont10N) //Parcela do titulo		
		ELSE
		oPrint:Say(530, 1250,  AllTrim(QRY->E1_NUM) + "-" + QRY->E1_PARCELA, oFont10N) //Parcela do titulo		
		ENDIF
		oPrint:Say(530, 1600,  DtoC(StoD(QRY->E1_VENCREA)), oFont10N) //Vencimento do titulo (nใo ้ vencimento real) alterado a pedido do Sr. Roberto dia 21/02/13.
		oPrint:Say(850, 600,  QRY->E1_CLIENTE+" - "+Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_NOME"), oFont10N) //Nome do Destinatario
		oPrint:Say(900, 600,  AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_END"))+" - "+AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_BAIRRO")), oFont10N) //Endere็o do Destinatario
		_cEST := Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_EST")
		oPrint:Say(950, 1350, Posicione("SX5",1,xFilial("SX5")+"12"+_cEST,"X5_DESCRI")) 
//		oPrint:Say(950, 1350,  AllTrim(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE,"A1_EST")), oFont10N) //Estado do Destinatario
		_cCEP := Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_CEP")
		oPrint:Say(950, 2000,  Transform(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_CEP"),"@R 99999-999"), oFont10N) //Cep do Destinatario
		oPrint:Say(950, 600,  AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_MUN")), oFont10N) //Municipio do Destinatario
		oPrint:Say(1000, 800, AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_MUN"))+" - "+AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_EST")), oFont10N) //Pra็a de Pagamento do Destinatแrio
		oPrint:Say(1050, 800,  Transform(AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_CGC")),"@R 99.999.999/9999-99"), oFont10N) //CNPJ do Destinatario
		oPrint:Say(1100, 800,  AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE,"A1_INSCR")), oFont10N) //Insc Estadual do Destinatario
		
		_COND := Posicione("SF2",1,xFilial("SF2") + QRY->E1_NUM + QRY->E1_PREFIXO + QRY->E1_CLIENTE,"F2_COND")
		oPrint:Say(1050, 1600, AllTrim(Posicione("SE4",1,xFilial("SE4")+_COND,"E4_DESCRI"))) 
	
	
	//	oPrint:Say(1050, 1600, QRY->E1_PREFIXO + QRY->E1_NUM )
		
		oPrint:Say(1280, 550,  EXTENSO(E1_VALOR), oFont10N) //Valor do titulo por extenso		
		QRY->(DBSKIP()) 
		nPag++
		Rod()

	EndDo

//	Cabec()
  
EndDo
	
//Visualiza a impressao
oPrint:Preview() 

QRY->(DbCloseArea())

Return   
		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCabec     บAutor  Clistenis Batista    บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cabec()

PRIVATE oPrn    := NIL
PRIVATE oFont1  := NIL
PRIVATE oFont2  := NIL
PRIVATE oFont3  := NIL
PRIVATE oFont4  := NIL
PRIVATE oFont5  := NIL
PRIVATE oFont6  := NIL
 		
nLin := 50
oPrint:StartPage() // Inicia uma nova pagina
cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")
oPrint:SayBitmap(200, 70, cStartPath + "logorel.bmp", 400, 200)// Impressao da Logo
//oPrint:Say(nLin+55, 50, "                                                                                                 TอTULO NUM.: "+QRY->E1_NUM, oFont10)
//oPrint:Say(nLin+10, 2100, "Pแgina: " + cValToChar(nPag), oFont10)
//oPrint:Say(nLin+50, 2100, Time(), oFont10)
//oPrint:Say(nLin+85, 2100, DTOC(dDatabase), oFont10)

//Criando o box geral
//linhainicio,colunainicio,linhafinal,colunafinal   
oPrint:Box(0100,0050,1650,2300)   // Cria BOX retangular em volta da duplicata
oPrint:Box(0100,0050,450,1250)   // Cria BOX retangular em volta do cabe็alho
oPrint:Box(0100,1250,450,2300)   // Cria BOX retangular em volta do cabe็alho
oPrint:Box(0450,0300,600,1850)   // Cria BOX retangular em volta dos campos de fatura corpo total
oPrint:FillRect( {0450,0300,500,1850}, oBrush1 )// Cria BOX retangular em volta dos campos de fatura parte cima (cinza)
oPrint:Box(0550,1900,800,2300)   // Cria BOX retangular a direira escrito DUPLICATA             
oPrint:Box(820,300,1150,2300)   // Cria BOX em volta dos dados do destinatแrio
oPrint:Box(1200,300,1400,500)   // Cria BOX em volta do cabe็alho do valor por extenso
oPrint:FillRect( {1200,0500,1400,2300}, oBrush1 )   // Cria BOX em volta do valor por extenso
oPrint:Line (450,550,600,550)  //Linha separando o numero da fatura
oPrint:Line (450,1050,600,1050)  //Linha separando o numero da fatura
oPrint:Line (450,1500,600,1500)  //Linha separando o numero da fatura

/*
//ณInicio do texto do cabe็alhoณ
*/
        
		oPrint:Say(nLin+100, 500,  "FHOM IND, COM E EMB PROD. ALIMENTอCIOS LTDA" , oFont10N)
		oPrint:Say(nLin+200, 500,  "RUA STHELA MARIA ANNA MATTOS, 24 / JD CALUX" , oFont8)
		oPrint:Say(nLin+250, 500,  "SรO BERNARDO DO CAMPO - SรO PAULO - CEP: 09.895-700" , oFont8)		
		oPrint:Say(nLin+300, 500,  "Telefone: (11) 3568-3000 " , oFont8)
		oPrint:Say(nLin+350, 500,  "E-mail: financeiro@fhom.com.br" , oFont8)	
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados do cabe็alho de duplicataณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                          
		oPrint:Say(nLin+070, 1300,  "                      D U P L I C A T A" , oFont14N)
		oPrint:Say(nLin+200, 1300,  "INSCRIวรO NO CNPJ (MF) Nบ: 74.575.804/0001-55" , oFont10)
		oPrint:Say(nLin+250, 1300,  "INSCRIวรO ESTADUAL Nบ: 799.074.470.112" , oFont10)		
		oPrint:Say(nLin+320, 1300,  "DATA DE EMISSรO: " , oFont8)		

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDizeres do cabe็alho dos quadros dos dados de titulosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:Say(0465, 0350,"FATURA Nบ " , oFont8)
		oPrint:Say(0465, 0580,"FATURA - DUPLICATA / VALOR R$ " , oFont8)
		oPrint:Say(0465, 1100,"DUPLICATA/Nบ DE ORDEM " , oFont8)
		oPrint:Say(0465, 1600,"VENCIMENTO    " , oFont8)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTexto da caixa da direitaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		oPrint:Say(0600, 1950,"       PARA USO DA " , oFont8)
		oPrint:Say(0650, 1915,"INSTITUIวรO FINANCEIRA" , oFont8)
		oPrint:Say(0700, 1950,"DUPLICATA" , oFont14N)
                           

		oPrint:Say(0650, 300,"DESCONTO DE"+Transform(QRY->E1_DESCFIN,"@E 9,999,999.99")+ "%", oFont10N)
		oPrint:Say(0650, 750,"SOBRE R$"+Transform(QRY->E1_VALOR,"@E 9,999,999.99"), oFont10N)
	   	oPrint:Say(0650, 1300,"TOTAL LIQUIDO"+Transform(QRY->E1_VALOR-((QRY->E1_VALOR/100) * QRY->E1_DESCFIN),"@E 9,999,999.99") , oFont8)
		
		oPrint:Line (600, 200, 1500, 200)

		oPrint:Say(0750, 300,"CONDIวีES ESPECIAIS" , oFont8)
		
		oPrint:Say(850, 350,"DESTINATมRIO: " , oFont8)		
		oPrint:Say(900, 350,"ENDEREวO: " , oFont8)				
		oPrint:Say(950, 350,"MUNICอPIO: " , oFont8)				
		oPrint:Say(950, 1200,"ESTADO: " , oFont8)				
		oPrint:Say(950, 1900,"CEP: " , oFont8)				
		oPrint:Say(1000, 350,"PRAวA DE PAGAMENTO: " , oFont8)						
		oPrint:Say(1050, 350,"INSCR. NO C.N.P.J. (M.F.) Nบ: " , oFont8)						
		oPrint:Say(1100, 350,"INSCR. ESTADUAL Nบ: " , oFont8)						

		oPrint:Say(1220, 350, "VALOR" , oFont8N)	
		oPrint:Say(1270, 350, "  POR" , oFont8N)	
		oPrint:Say(1320, 345, "EXTENSO" , oFont8N)	
		
		oPrint:Say(1430, 350, "RECONHEวO(EMOS)  A  EXATIDรO  DESTA  DUPLICATA  DE  VENDA  MERCANTIL,  NA  IMPORTยNCIA  ACIMA,  QUE  PAGAREI(EMOS)  ภ " , oFont8)	
		oPrint:Say(1480, 350, "FHOM IND, COM E EMB PROD. ALIMENTอCIOS LTDA, OU ภ SUA ORDEM NA PRAวA E VENCIMENTO INDICADOS." , oFont8)	
		
		oPrint:Say(1550, 350, "_______/_______/_______                                              ____________________________________________________" , oFont10)			
		oPrint:Say(1600, 450, "DATA DO ACEITE" , oFont8)			
		oPrint:Say(1600, 1600, "ASSINATURA DO SACADO" , oFont8)			

/*    
nLin += 100
nLin += 20
nLin += 20
nLin += 20

nLin += 50  
nLin += 50
oPrint:Line (nLin + 230, 50, nLin + 230, 2300)
nLin += 50

oPrint:Say(nLin+200, 50, "C๓digo", oFont10NS)
oPrint:Say(nLin+200, 250, "Produto", oFont10NS)
oPrint:Say(nLin+200, 800, "Nบ Lote", oFont10NS)
oPrint:Say(nLin+200, 1000, "Arm.", oFont10NS)
oPrint:Say(nLin+200, 1150, "Qtde Emb.", oFont10NS)  
oPrint:Say(nLin+200, 1400, "Qtde", oFont10NS)
oPrint:Say(nLin+200, 1550, "Unid", oFont10NS)
oPrint:Say(nLin+200, 1700, "Prc Unit.", oFont10NS)
oPrint:Say(nLin+200, 1900, "Vlr Total", oFont10NS)
oPrint:Say(nLin+200, 2100, "TES", oFont10NS)
oPrint:Say(nLin+200, 2200, "CFOP", oFont10NS)
*/

Return                    
        	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRod       บAutor  KAREM CAROLINE       บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function Rod()

oPrint:EndPage() // Termina a pagina

Return 

