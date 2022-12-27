#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BBESTA05  �Autor  �Renato Santos       � Data �  04/10/21   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina que monta a tela para verificar SD7 aberto contra    ���
���          �SB2                                                         ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
���Data      � Alteracao                                      � Autor     ���
�������������������������������������������������������������������������ͼ��
���          �                                                �           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BBESTA05()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca 		:= 0

Private cCadastro	:= OemToAnsi("Atua��o com verifica��o de SD7 x SB2")
Private _cArq1
Private _cInd1
Private _aCampos	:= {}

Private _lOk     	:= .f.
PRIVATE lInverte 	:= .f.
Private _cOk     	:= GetMark()

Private aHead		:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Private aCol		:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols

Private lErroGer	:= .F.				//Controle geral de erro em MsExecAuto

Processa({|lEnd| Process()})

Return()

//����������������������������������������������������������������������������Ŀ
//�Funcao para cricao do MarkBrownse de selecao.                               �
//������������������������������������������������������������������������������
Static Function Process()

CriaArq()
MontaTela()
ApagaTMP()

Return()

//����������������������������������������������������������������������������Ŀ
//�Funcao para cricao do Arquivo Temporario do MarkBrowse                      �
//������������������������������������������������������������������������������
Static Function CriaArq()
Local aStrut 		:= {}
Local aStrut2 		:= {}
Local _aTam			:= {}
Local _cTitulo		:= ""
Local aCpos			:= {"B2_FILIAL", "B1_COD", "B2_LOCAL", "B1_TIPOCQ", "B2_QATU", "TTLMOV" }
Local aCpoDef		:= {	{"TTLMOV"	,"Qtd.SD7"	,TamSX3("B2_QATU")[3]	,TamSX3("B2_QATU")[1]	,TamSX3("B2_QATU")[2]	,PESQPICT("SB2","B2_QATU")		} } 
Local cQuery 		:= ""
Local _nReg			:= 0
Local _nCstRec		:= 0
Local _cUltPrd		:= ""

AADD(aStrut,{"KB_OK"     ,"C",02,0})			// Campo para Flag do MarkBrowse
AADD(_aCampos,{"KB_OK"     ,""," "         })

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For _nX := 1 To Len(aCpos)
	IF SX3->(DbSeek(aCpos[_nX]))
		_aTam 		:= TamSX3(aCpos[_nX])
		_cTitulo	:= x3titulo()
		AADD(aStrut		,{aCpos[_nX],_aTam[3],_aTam[1],_aTam[2]})
		AADD(_aCampos	,{aCpos[_nX],,_cTitulo,SX3->X3_PICTURE})
	ELSE
		nPF := aScan(aCpoDef,{|x| aCpos[_nX] == x[1]})
		if nPF > 0
			_cTitulo := aCpoDef[nPF,2]
			AADD(aStrut		,{aCpoDef[nPF,1],aCpoDef[nPF,3],aCpoDef[nPF,4],aCpoDef[nPF,5]})
			AADD(_aCampos	,{aCpoDef[nPF,1],,_cTitulo,aCpoDef[nPF,6]})
		Endif					
	ENDIF
Next

// +-------------------------------------------------------------------------------+
// | Monta Arquivo Tempor�rio para Armazenar dados a serem mostrados na MarkBrowse |
// +-------------------------------------------------------------------------------+
If Select("TMP") > 0
	DbSelectArea("TMP")
	DbCloseArea()
EndIf

_cArq1 := CriaTrab(aStrut,.t.)
DbUseArea(.t.,,_cArq1,"TMP",.t.)
_cInd1 := CriaTrab(Nil,.f.)
IndRegua("TMP",_cInd1,"B1_COD",,,"Selecionando Registros...")

cQuery := "SELECT B1_FILIAL, B2_FILIAL, B1_COD, B1_TIPOCQ, B2_LOCAL, " + CHR(13) + CHR(10)
cQuery += "B2_QATU, ISNULL(TTLMOV,0) TTLMOV " + CHR(13) + CHR(10)
cQuery += "FROM " + RETSQLNAME("SB1") + " SB1 (NOLOCK)  " + CHR(13) + CHR(10)
cQuery += "INNER JOIN " + RETSQLNAME("SB2") + " SB2 (NOLOCK) " + CHR(13) + CHR(10)
cQuery += "	ON SB2.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
cQuery += "	AND B1_FILIAL = RIGHT(B2_FILIAL,2) " + CHR(13) + CHR(10)
cQuery += "	AND B1_COD = B2_COD " + CHR(13) + CHR(10)
cQuery += "	AND B2_LOCAL = '98' " + CHR(13) + CHR(10)
cQuery += "INNER JOIN ( SELECT " + CHR(13) + CHR(10)
cQuery += "				D7_FILIAL, D7_PRODUTO, " + CHR(13) + CHR(10)
cQuery += "				( SUM(	CASE WHEN D7_TIPO = '0' THEN D7_SALDO ELSE 0 END) - " + CHR(13) + CHR(10)
cQuery += "			  	SUM(	CASE " + CHR(13) + CHR(10)
cQuery += "			  				 WHEN D7_TIPO IN('1','2') THEN D7_QTDE " + CHR(13) + CHR(10)
cQuery += "			  				 WHEN D7_TIPO IN('6','7') THEN D7_QTDE * (-1) " + CHR(13) + CHR(10)
cQuery += "			  			ELSE 0 END )  ) TTLMOV " + CHR(13) + CHR(10)
cQuery += "				FROM " + RETSQLNAME("SD7") + " TMP (NOLOCK) " + CHR(13) + CHR(10)
cQuery += "				WHERE TMP.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
cQuery += "				GROUP BY D7_FILIAL, D7_PRODUTO ) SD7" + CHR(13) + CHR(10)
cQuery += "	ON B2_FILIAL = D7_FILIAL " + CHR(13) + CHR(10)
cQuery += "	AND B2_COD = D7_PRODUTO " + CHR(13) + CHR(10)
cQuery += "WHERE SB1.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
cQuery += "AND (case when ISNULL(TTLMOV,0) < 0 then 0 else ISNULL(TTLMOV,0) end) > 0 " + CHR(13) + CHR(10) 
cQuery += "AND round(ISNULL(TTLMOV,0)," + ALLTRIM(STR(TamSX3("B2_QATU")[2])) + ") > round(B2_QATU," + ALLTRIM(STR(TamSX3("B2_QATU")[2])) + ") " + CHR(13) + CHR(10)
TcQuery cQuery Alias "TRB" New

//TcSetField("TRB","C5_EMISSAO","D",08,0)

DbSelectArea("TRB")
TRB->(DbGoTop())

DbEval({||_nReg++})

TRB->(DbGoTop())

ProcRegua(_nReg )

While TRB->(!Eof())
	IncProc("Processando: "+AllTrim(TRB->B1_COD))

	While !RecLock("TMP",.t.)
	Enddo
	TMP->B2_FILIAL  := TRB->B2_FILIAL 
	TMP->B1_COD     := TRB->B1_COD    
	TMP->B1_TIPOCQ  := TRB->B1_TIPOCQ 
	TMP->B2_LOCAL   := TRB->B2_LOCAL  
	TMP->B2_QATU    := TRB->B2_QATU   
	TMP->TTLMOV	    := TRB->TTLMOV   
    TMP->(MsUnLock())
	TRB->(DbSkip())
EndDo

TMP->(DbGoTop())

Return()


//����������������������������������������������������������������������������Ŀ
//�Funcao para montagem da Tela MarkBrowse                                     �
//������������������������������������������������������������������������������
Static Function MontaTela()
	Local lRet := .F.
	Local aButtons := {}
	
	// +--------------------------------------------------+
	// | Faz o C�lculo Autom�tico de Dimens�es de Objetos |
	// +--------------------------------------------------+
	aSize := MsAdvSize()
	
	Define MsDialog oDlg1 Title OemToAnsi("Balanceamento de Saldo SB2 -> SB8") From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd Pixel
	oDlg1:lMaximized := .T.
	
	// +------------------------------------------------------------------------------------------------+
	// | Passagem do par�metro _aStruct1 para emular tamb�m a markbrowse para o Arquivo de Trabalho TRB |
	// +------------------------------------------------------------------------------------------------+
	If FlatMode()
		aCoors := GetScreenRes()
		nHeight	:= aCoors[2]
		nWidth	:= aCoors[1]
	Else
		nHeight	:= 143
		nWidth	:= 315
	Endif
	
	TMP->(DbGoTop())
	
	oMark := MsSelect():New("TMP","KB_OK",,_aCampos,@lInverte,@_cOk,{30,1,aSize[4],aSize[6]})
	oMark:oBrowse:nwidth := aSize[5]
	oMark:oBrowse:Refresh()
	oMark:oBrowse:SetFocus()
	oMark:bMark := {|| _fMkBr(_cOk,lInverte,oDlg1)}
	
	Aadd( aButtons, {"01", {|| _Pesq()}		    , "Pesquisar..."	    , "Pesquisar" 		, {|| .T.}} )
	Aadd( aButtons, {"02", {|| _fInvMk(oDlg1)}	, "Marca/Desmarca..."	, "Marca/Desmarca"	, {|| .T.}} )
	
	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1, {||lRet := .T.,oDlg1:End()},{||oDlg1:End()},,@aButtons)
	
	If lRet
		PrcPRMk()
	EndIf
	
Return()



//����������������������������������������������������������������������������Ŀ
//�Funcao para pesquisa.                                                       �
//������������������������������������������������������������������������������
Static Function PrcPRMk()
	
    Local cCodEmp	:= FWCodEmp()
	Local aVlsAn 	:= {}
	ProcRegua(TMP->(RecCount()))
	dbSelectArea("TMP")
	TMP->(dbGoTop())
	While TMP->(!EOF())
		IncProc("Analisando Produto " + TMP->B1_COD + "...")
		If TMP->KB_OK != _cOk
			IncProc("")
			TMP->(dbSkip())
			Loop
		EndIf
		AADD(aVlsAn,{ TMP->B2_FILIAL, TMP->B1_COD, TMP->B2_LOCAL, TMP->B1_TIPOCQ, TMP->B2_QATU, TTLMOV})
		U_BBESTA06( aVlsAn )
		aVlsAn := {}
		TMP->(dbSkip())
	EndDo

Return()



//����������������������������������������������������������������������������Ŀ
//�Funcao para pesquisa.                                                       �
//������������������������������������������������������������������������������
Static Function _Pesq()
	
	Local _lConf
	Local _cChave   := Space(50)
	Local _cCombo   := ""
	Local _aCombo   := {"Produto"}
	
	@ 10,10 To 130,500 Dialog oDlg3 Title "Pesquisa"
	
	@ 010,003 ComboBox _cCombo Items _aCombo Size 180,15
	@ 025,003 Get _cChave Picture "@!"       Size 180,15
	
	@ 010,190 BmpButton Type 1 Action (_lConf := .T., Close(oDlg3))
	@ 025,190 BmpButton Type 2 Action (_lConf := .F., Close(oDlg3))
	
	Activate Dialog oDlg3 Centered
	
	If _lConf
		Set Softseek On
		dbSelectArea("TMP")
		dbSeek(_cChave)
	
		SysRefresh()
		oDlg1:Refresh()
		Set Softseek Off
	EndIf
	
Return



//����������������������������������������������������������������������������Ŀ
//�Funcao para marcacao dos itens.                                             �
//������������������������������������������������������������������������������
Static Function _fMkBr(_cOK,lInverte,oDlg1)

	If TMP->(IsMark("KB_OK",_cOk,lInverte))
	
		While !RecLock("TMP",.f.)
		Enddo
	
		If !lInverte
			TMP->KB_OK := _cOk
		Else
			TMP->KB_OK := "  "
		EndIf
	
		MsUnlock()
	
	Else
	
		While !RecLock("TMP",.f.)
		Enddo
	
		If !lInverte
			TMP->KB_OK := "  "
		Else
			TMP->KB_OK := _cOk
		EndIf
	
		MsUnlock()
	
	EndIf
	
	oDlg1:Refresh()
	
Return(.t.)

//����������������������������������������������������������������������������Ŀ
//�Funcao para marcacao dos itens.                                             �
//������������������������������������������������������������������������������
Static Function _fInvMk(oDlg1)

Local lInverte := .T.

Do While !TMP->(EOF())
	_cOK := ThisMark() //TMP->KB_OK
	If TMP->(IsMark("KB_OK"))
		RecLock("TMP",.f.)
		TMP->KB_OK := "  "
		TMP->(MsUnlock())
	
	Else
		RecLock("TMP",.f.)
		TMP->KB_OK := ThisMark()
		TMP->(MsUnlock())
	EndIf
	TMP->(DBSKIP())
EndDo
oDlg1:Refresh()

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores � Norbert/Ernani/Mansano � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//���������������������������Ŀ
	//�Tratamento para tema "Flat"�
	//�����������������������������
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


//����������������������������������������������������������������������������Ŀ
//�Fechar e apagar os arquivos tempor�rios                                     �
//������������������������������������������������������������������������������
Static Function ApagaTMP()
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	EndIf
	
	If Select("TMP") > 0
		DbSelectArea("TMP")
		TMP->(DbCloseArea())
	EndIf
	
	fErase(_cArq1+".dbf")
	fErase(_cInd1+".idx")
	
Return()
