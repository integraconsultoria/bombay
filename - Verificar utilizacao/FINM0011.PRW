#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "vKey.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINM0011  ºAutor  ³DOUGLAS CHAGAS      º Data ³  26/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para escolha dos Titulos e envio por email do boleto em pdfeº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CLIENTE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION FINM0011()

	LOCAL cQUERY		:= ""
	Local aCpoBrw
	Local aCpoTmp
	Local cArq
	Local bLDblClick		:= { || U_FINM11A() }
	Local bBALLMARK			:= { || U_FINM11B() }

	LOCAL cPERG
	LOCAL _dDataDe
	LOCAL dDATAATE

	Private _lInverte 	:= .T.
	Private _cmarca   	:= GetMark()
	Private _oMark

	cPerg    := Padr( "DS0002",Len (SX1->X1_GRUPO))

	If !Pergunte (cPerg, .T.)
		Return
	EndIf

	cQUERY	:= " SELECT E1.E1_FILIAL, E1.E1_NUM, E1.E1_PREFIXO,E1.E1_LOJA, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_CLIENTE, E1.E1_VALOR, E1.E1_VENCREA "
	cQUERY	+= " , E1_PORTADO, E1_AGEDEP, E1_CONTA, "
	cQUERY	+= " A1.A1_COD, A1.A1_LOJA, A1.A1_NOME, A1.A1_CGC, A1.A1_EMAIL"
	cQUERY	+= " FROM " + RetSqlName("SE1") + " E1 "
	cQUERY	+= " LEFT JOIN " + RetSqlName("SA1") + " A1 ON A1.D_E_L_E_T_ <> '*' AND E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA"
	cQUERY	+= " WHERE "
	cQUERY	+= " E1.D_E_L_E_T_ <> '*' "
	cQUERY	+= " AND E1.E1_FILIAL = '" + XFILIAL("SE1") + "' "
	//	cQUERY	+= " AND E1.E1_PORTADO = '" + ALLTRIM(MV_PAR03) + "' "
	//	cQUERY	+= " AND E1.E1_AGEDEP = '" + ALLTRIM(MV_PAR04) + "' "
	//	cQUERY	+= " AND E1.E1_CONTA = '" + ALLTRIM(MV_PAR05) + "' "
	//	cQUERY	+= " AND E1.E1_TIPO in ('NF ','FT ', 'CR ') " //'NF ' "
	cQUERY	+= " AND E1.E1_VENCREA BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' "
	cQUERY	+= " AND E1.E1_BAIXA = '        ' "
	cQUERY	+= " ORDER BY E1.E1_NUM, E1.E1_VENCREA "

	MemoWrite("FINM0011.sql", cQUERY)
	DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,cQUERY),"TITULOS", .T., .T.)

	TCSETFIELD("TITULOS","E1_VENCREA","D")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Alias se estiver em Uso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") >0
		dbSelectArea("TMP")
		dbCloseArea()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo temporario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpoTmp:={}
	aAdd(aCpoTmp,{"OK"        	,"C",02,0})
	aAdd(aCpoTmp,{"PREFIXO"    	,"C",03,0})
	aAdd(aCpoTmp,{"NUMERO"    	,"C",09,0})
	aAdd(aCpoTmp,{"PARCELA"    	,"C",01,0})
	aAdd(aCpoTmp,{"TIPO"    	,"C",03,0})
	aAdd(aCpoTmp,{"VENCREA"  	,"D",08,0})
	aAdd(aCpoTmp,{"UENVBOL"    	,"C",01,0})
	aAdd(aCpoTmp,{"CODIGO"    	,"C",06,0})
	aAdd(aCpoTmp,{"LOJA"      	,"C",02,0})
	aAdd(aCpoTmp,{"NOME"      	,"C",40,0})
	aAdd(aCpoTmp,{"CNPJ"      	,"C",14,0})
	aAdd(aCpoTmp,{"EMAIL_COB" 	,"C",100,0})
	aAdd(aCpoTmp,{"EMAIL"     	,"C",100,0})
	aAdd(aCpoTmp,{"VALOR"     	,"N",14,2})
	aAdd(aCpoTmp,{"PORTADO"    	,"C",03,0})
	aAdd(aCpoTmp,{"AGEDEP"    	,"C",05,0})
	aAdd(aCpoTmp,{"CONTA"    	,"C",10,0})

	cArq:=Criatrab(aCpoTmp,.T.)
	dbUseArea(.t.,,cArq,"TMP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta arquivo temporario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("TMP")

	WHILE TITULOS->(!EOF())

		DbSelectArea("TMP")
		RecLock("TMP",.t.)
		TMP->OK           	:= _cmarca
		TMP->PREFIXO		:= TITULOS->E1_PREFIXO
		TMP->NUMERO			:= TITULOS->E1_NUM
		TMP->PARCELA		:= TITULOS->E1_PARCELA
		TMP->TIPO			:= TITULOS->E1_TIPO
		TMP->VENCREA		:= TITULOS->E1_VENCREA
		//TMP->UENVBOL		:= TITULOS->E1_UENVBOL

		TMP->CODIGO			:= TITULOS->A1_COD
		TMP->LOJA			:= TITULOS->A1_LOJA
		TMP->NOME			:= TITULOS->A1_NOME
		TMP->CNPJ			:= TITULOS->A1_CGC
		//TMP->EMAIL_COB		:= ALLTRIM(TITULOS->A1_EMAILFI)
		TMP->EMAIL			:= ALLTRIM(TITULOS->A1_EMAIL)
		TMP->VALOR			:= TITULOS->E1_VALOR
		TMP->PORTADO		:= TITULOS->E1_PORTADO
		TMP->AGEDEP			:= TITULOS->E1_AGEDEP
		TMP->CONTA			:= TITULOS->E1_CONTA

		TMP->(MsUnlock())
		DbSelectArea("TITULOS")
		TITULOS->(dbSkip())
	ENDDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com definicoes dos campos do browse ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aCpoBrw:={}
	aAdd(aCpoBrw,{"OK"           	,"",""        	,"@!"})
	aAdd(aCpoBrw,{"PREFIXO"       	,"","PREFIXO"  	,"@!"               		,"03","0"})
	aAdd(aCpoBrw,{"NUMERO"       	,"","NUMERO"  	,"@!"               		,"09","0"})
	aAdd(aCpoBrw,{"PARCELA"       	,"","PARCELA"  	,"@!"               		,"01","0"})
	aAdd(aCpoBrw,{"TIPO"       		,"","TIPO"  	,"@!"               		,"03","0"})
	aAdd(aCpoBrw,{"VENCREA"       	,"","VENCREA"  	,""               			,"08","0"})
	aAdd(aCpoBrw,{"UENVBOL"       	,"","UENVBOL"  	,"@!"               		,"01","0"})
	aAdd(aCpoBrw,{"VALOR"         	,"","VALOR"   	,""			    			,"14","2"})

	aAdd(aCpoBrw,{"PORTADO"       	,"","PORTADO"  	,"@!"               		,"03","0"})
	aAdd(aCpoBrw,{"AGEDEP"       	,"","AGEDEP"  	,"@!"               		,"05","0"})
	aAdd(aCpoBrw,{"CONTA"       	,"","CONTA"  	,"@!"               		,"10","0"})

	aAdd(aCpoBrw,{"CODIGO"       	,"","CODIGO"  	,"@!"               		,"06","0"})
	aAdd(aCpoBrw,{"LOJA"       		,"","LOJA"  	,"@!"               		,"02","0"})
	aAdd(aCpoBrw,{"NOME"         	,"","NOME"   	,"@!"			    		,"40","0"})
	aAdd(aCpoBrw,{"CNPJ"          	,"","CNPJ"    	,"@R 99.999.999/9999-99"	,"14","0"})
	aAdd(aCpoBrw,{"EMAIL_COB"     	,"","EMAIL_COB"	,""			    			,"100","0"})
	aAdd(aCpoBrw,{"EMAIL"         	,"","EMAIL"   	,""			    			,"100","0"})

	@ 000,000 TO 550,1300 DIALOG oDlgLib TITLE "Envio de Boleto PDF"
	@ 020,040 Say "Marque os Titulos que deverão ser enviados por Boleto em PDF para o e-mail de cobrança ou e-mail dos clientes."

	_oMark:=MsSelect():New("TMP","OK",,aCpoBRW,@_lInverte,@_cmarca,{005,005,250,650})
	_oMark:oBrowse:bLDblClick := bLDblClick
	_oMark:oBrowse:BALLMARK := bBALLMARK

	@ 260,530 BmpButton Type 02  Action Close(oDlgLIb) Object oBtnInv
	@ 260,575 BmpButton Type 01  Action {ENVCOB(),Close(oDlgLIb)} Object oBtnTodos

	Eval( _oMark:oBrowse:bGotop )

	ACTIVATE DIALOG oDlgLib CENTERED

	TMP->(dbCloseArea())

	FERASE(cArq+OrdBagext())
	FERASE(cArq)

	DBSELECTAREA("TITULOS")
	DBCLOSEAREA("TITULOS")

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ENVCOB    ºAutor  ³Microsiga           º Data ³  11/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ENVIA EMAIL COM OS TITULOS EM ABERTO PARA OS CLIENTES MARCA-º±±
±±º          ³DOS NA TELA.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ENVCOB()

	Processa({|| RunProc()})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunProc   ºAutor  ³Microsiga           º Data ³  11/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ENVIA EMAIL COM OS TITULOS EM ABERTO PARA OS CLIENTES MARCA-º±±
±±º          ³DOS NA TELA.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunProc()

	LOCAL cQUERY2	:= ""
	LOCAL cMENSAGEM	:= ""
	LOCAL cTIT		:= ""
	LOCAL cUSU		:= ""
	LOCAL aTITULOS	:= {}
	LOCAL cFROM		:= ""
	Local _cRepres	:= ""
	//Local _cAgeven	:= ""
	Local cCopia	:= ""

	_nQTDTIT := 0

	dbSelectArea("TMP")
	dbGoTop()
	While !EOF()

		If Marked("OK")
			IF  !EMPTY(TMP->EMAIL_COB) .OR. !EMPTY(TMP->EMAIL)
				_nQTDTIT := _nQTDTIT + 1
			ENDIF
		ENDIF
		dbSelectArea("TMP")
		dbSkip()

	ENDDO

	IF _nQTDTIT == 0 //NAO FOI SELECIONADO NENHUM TITULO
		RETURN .F.
	ENDIF

	ProcRegua(_nQTDTIT)

	_nCOUNTTIT := 1
	dbSelectArea("TMP")
	dbGoTop()
	While !EOF()

		If Marked("OK")
			IF  !EMPTY(TMP->EMAIL_COB) .OR. !EMPTY(TMP->EMAIL)

				//INCPROC("Enviando Títulos em PDF por E-mail:"+ALLTRIM(STR(_nCOUNTTIT))+"/"+ALLTRIM(STR(_nQTDTIT)))
				INCPROC("Enviando Títulos em PDF:"+ALLTRIM(STR(_nCOUNTTIT))+"/"+ALLTRIM(STR(_nQTDTIT)))

				_nCOUNTTIT := _nCOUNTTIT + 1

				cMENSAGEM :=	'<html>' +;
				'<head>' +;
				'<meta http-equiv="Content-Language" content="pt-br">'+;
				'<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'+;
				'<title>Bom dia sr</title></head>'

				cMENSAGEM += "<body> "
				//cMENSAGEM += "<p><b>Titulos Pendentes (não responder esta mensagem)</b></p>"
				cMENSAGEM += "<p><b>Prezado Cliente: " + ALLTRIM(TMP->NOME) + "</b></p>"
				cMENSAGEM += "<p>Segue neste e-mail o seu boleto de pagamento referente a nota fiscal :</p>"

				cMENSAGEM += '<table border=1>'

				cMENSAGEM += "<tr>"
				cMENSAGEM += "<td><b>Nº DUPL.</b></td>" + "<td><b>PARCELA</b></td>" + "<td><b>VENCIMENTO</b></td>" + "<td><b>VALOR</b></td>"
				cMENSAGEM += "</tr>"

				cMENSAGEM += "<tr>"
				cMENSAGEM += "<td>" + TMP->NUMERO + "</td>" + "<td>" + TMP->PARCELA + "</td>" + "<td>" + DTOC(TMP->VENCREA) + "</td>" + "<td>R$ " + ALLTRIM(CVALTOCHAR(TMP->VALOR)) + "</td>"
				cMENSAGEM += "</tr>"

				IF SE1->(DBSEEK(XFILIAL("SE1")+TMP->(PREFIXO+NUMERO+PARCELA+TIPO)))
					//					RECLOCK("SE1",.F.)
					//Replace SE1->E1_UENVBOL With "S"
					//SE1->(MSUNLOCK())
				ENDIF

				cMENSAGEM += '</table>'

				cMENSAGEM += "<p>Em caso de dúvidas, entre em contato com a Central de Atendimento - (11) 2105-7500 de segunda à sexta-feira, das 8h às 18h.</p>"

				cMENSAGEM += '</body>'
				cMENSAGEM += '</html>'

				If (cEmpAnt == "01")
					cMENSAGEM += '<html><br><font color="black" size="1"><font color="#000080" size="+0.5">'+;
					'<b></font><i><font size="1"><br>Atenciosamente</b>'+;
					'<b></font><i><font size="1"><br>Contas a Receber / Cobrança</b>'+;
					'<br>Fone: 55 11 2105.7500<br>E-mail: <a href="mailto:atendimento@dominio.com.br"'+;
					' style="text-decoration:none">atendimento@dominio.com.br</a><br><a href="http://www.dominio.com.br"'+;
					' style="text-decoration:none">www.dominio.com.br '
				EndIf

				cMENSAGEM += '<br><img src="http://suporte.dominio.com.br/MAIN_LOGO.png" width="220" height="70"></i></i></img></html>'

				MemoWrite("EmailBoleto.html", cMENSAGEM)

				IF !EMPTY(TMP->EMAIL_COB)
					cUSU := ALLTRIM(TMP->EMAIL_COB)
				ELSE
					cUSU := ALLTRIM(TMP->EMAIL)
				ENDIF

				If (cEmpAnt == "01")
					cTIT := "Boleto Pagamento - FHOM - Industria, Comercio e Embalagem de Produtos Alimenticios LTDA"
				EndIf

				// A variavel cFROM esta sendo inicializada vazia porque o servidor do exchange nao aceita endereco
				// do remetente diferente da conta que esta logada, no caso, relatorios@dominio.com.br.
				cFROM := ""

				// Incluida condicao para enviar mensagem com copia para o address do representante. Solicitado por Vanessa. Joao 13.02.13
				// Condicao para enviar mensagem com copia para o agente de vendas. Solicitado por Vanessa. Joao 08.04.13
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())

				If SA1->(DbSeek(xFilial("SA1") + TMP->CODIGO + TMP->LOJA))
					_cRepres := A1_VEND
					//_cAgeven := A1_AGEVEN
				EndIf

				DbSelectArea("SA3")
				SA3->(DbSetOrder(1))
				SA3->(DbGoTop())

				If SA3->(DbSeek(xFilial("SA3") + _cRepres))
					cCopia := ALLTRIM(A3_EMAIL)
				EndIf
				//If SA3->(DbSeek(xFilial("SA3") + _cAgeven))
				//					cCopia += ";"+ALLTRIM(A3_EMAIL)
				//EndIf

				cCopia += ";"+""

				//				IF !(ALLTRIM(TMP->PORTADO) $ "104|001|341")
				IF !(ALLTRIM(TMP->PORTADO) $ "341")
					ALERT("Permitido apenas para o Bancos 341")
					Return
				ENDIF
				/*
				aAdd(_aRegs,{cPerg,'01',"Prefixo ?"           ,"","",'mv_ch1','C',03,0,0,'C','','mv_par01','','','','','',''})
				AADD(_aRegs,{cPerg,"01","Prefixo            ?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","",""})
				AADD(_aRegs,{cPerg,"02","Do titulo          ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","",""})
				AADD(_aRegs,{cPerg,"03","Ate titulo         ?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","",""})
				AADD(_aRegs,{cPerg,"04","Da parcela         ?","","","mv_ch4","C",01,0,0,"G","","mv_par04","","","","","",""})
				AADD(_aRegs,{cPerg,"05","Ate a parcela      ?","","","mv_ch5","C",01,0,0,"G","","mv_par05",""      ,""       ,"","","",""})
				AADD(_aRegs,{cPerg,"06","Filtra por         ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Numero","Bordero","","","",""})
				AADD(_aRegs,{cPerg,"07","Bordero            ?","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","",""})
				AADD(_aRegs,{cPerg,"08","Mensagem           ?","","","mv_ch8","C",50,0,0,"G","","mv_par08","","","","","",""})
				AADD(_aRegs,{cPerg,"09","Segunda Mensagem   ?","","","mv_ch9","C",50,0,0,"G","","mv_par09","","","","","",""})
				AADD(_aRegs,{cPerg,"10","% de Juros ao Mês  ?","","","mv_cha","N",14,2,0,"G","","mv_par10"                                      ,""        ,"","","",'',"",""})
				Aadd(_aRegs,{cPerg,'11',"Banco              ?","","","mv_chb","C",3 ,0,0,"G","MV_PAR11 == '104' .And. ExistCpo('SA6',MV_PAR11)" ,"MV_PAR11","","","",'',"","SA6"})
				Aadd(_aRegs,{cPerg,'12',"Agencia            ?","","","mv_chc","C",5 ,0,0,"G","ExistCpo('SA6',MV_PAR11+MV_PAR12)"                ,"MV_PAR12","","","",'',"",""})
				Aadd(_aRegs,{cPerg,'13',"Conta              ?","","","mv_chd","C",10,0,0,"G","ExistCpo('SA6',MV_PAR11+MV_PAR12+MV_PAR13)"       ,"MV_PAR13","","","",'',"",""})

				*/

				_cLINHA1 := ""
				_cLINHA2 := ""
				_nJUROS := 2

				_aPARMS := {}
				AADD(_aPARMS,TMP->PREFIXO)
				AADD(_aPARMS,TMP->NUMERO)
				AADD(_aPARMS,TMP->NUMERO)
				AADD(_aPARMS,TMP->PARCELA)
				AADD(_aPARMS,TMP->PARCELA)
				AADD(_aPARMS,1) //NUMERO OU BORDERO
				AADD(_aPARMS,"")//NUM BORDERO
				AADD(_aPARMS,_cLINHA1)
				AADD(_aPARMS,_cLINHA2)
				AADD(_aPARMS,_nJUROS) //JUROS AO MES
				AADD(_aPARMS,TMP->PORTADO) //CARACTER DE 3
				AADD(_aPARMS,TMP->AGEDEP)// C5
				AADD(_aPARMS,TMP->CONTA) //C10

				//AADD(_aPARMS,MV_PAR03) //CARACTER DE 3
				//AADD(_aPARMS,MV_PAR04)// C5
				//AADD(_aPARMS,MV_PAR05) //C10
				_aFILES := {}
				/*
				DO CASE
				CASE TMP->PORTADO == "104"
				//					_cNOMARQ := U_BOLCAX3(_aPARMS)
				CASE TMP->PORTADO == "001"
				//					_cNOMARQ := U_BOLBB(_aPARMS)
				CASE TMP->PORTADO == "341"
				ENDCASE
				*/
				_cNOMARQ := U_BOLITAU(_aPARMS)

				IF !EMPTY(_cNOMARQ)
					AADD(_aFILES,_cNOMARQ)
				ENDIF

				If !Empty(cCopia)
					//					U_ENVIAEMAIL(cUsu,cCopia,,cTit,cMENSAGEM,_aFILES,cFROM)
				Else
					//					U_ENVIAEMAIL(cUsu,,,cTit,cMENSAGEM,_aFILES,cFROM) // Chama o fonte que envia o e-mail
				EndIf

			ELSE
				MSGALERT("CLIENTE " + TMP->CODIGO + " NÃO POSSUI NENHUM E-MAIL CADASTRADO!","ATENÇAO")
			ENDIF

		ENDIF

		dbSelectArea("TMP")
		dbSkip()

	ENDDO

	_oMark:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINM11A   ºAutor  ³Microsiga           º Data ³  11/24/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ACAO DO DUPLO CLIQUE NA CAIXA DE SELECAO. MARCA OU DESMARCA.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION FINM11A()

	RecLock("TMP",.f.)
	TMP->OK    := IIF(EMPTY(TMP->OK),_cmarca,"")
	TMP->(MsUnlock())

	_oMark:oBrowse:Refresh()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINM11B   ºAutor  ³Microsiga           º Data ³  01/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³FUNCAO DO BOTAO NA QUINA DA TELA. SELECIONA OU DESMARCA TO- º±±
±±º          ³DOS OS CLIENTES.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION FINM11B()

	WHILE TMP->(!EOF())
		RecLock("TMP",.f.)
		TMP->OK    := IIF(EMPTY(TMP->OK),_cmarca,"")
		TMP->(MsUnlock())

		DBSELECTAREA("TMP")
		DBSKIP()
	ENDDO

	TMP->(DBGOTOP())

	_oMark:oBrowse:Refresh()

RETURN