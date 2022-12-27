#Include "TopConn.CH"
#Include "Protheus.CH"
#Include "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RELPROD
@description  Vendas Totalizadas.
@author  Ronaldo Carvalho
@type	 User Function
@since   03/05/2019
@version All versions
/*/
//-------------------------------------------------------------------
User Function RELPROD
Local oReport
Local cQuery
Private _cTitFun:= ""
Private _cChave := "" 
Private _nTotal := 0 
Private cPerg	:= "RELPRW"

ValidPerg(cPerg)

If Pergunte(cPerg,.t.)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Interface de impressao                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oReport	:= ReportDef()
   oReport:PrintDialog()
EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
@description  Definição da estrutura do relatório.
@author  Ronaldo Carvalho
@type	 Static Function
@since   03/05/2019
@version All versions
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection
Local oBreak
Local aOrdem      := {}

oReport := TReport():New(cPerg,"Valores de Produtos Totalizados",cPerg,{|oReport| PrintReport(oReport)},"Valores de Produtos Totalizado")
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)


oSection := TRSection():New(oReport,,{})		
  

TRCell():New(oSection,"ID"            ,"","ID"  ,PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1] ) 
TRCell():New(oSection,"PRODUTO"       ,"","DESC",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1] )  
TRCell():New(oSection,"Peso/Unit.KG"  ,,,"@E 999999.999",9,,,"CENTER",,"CENTER",,,,,,.F. ) 
TRCell():New(oSection,"Qtde"          ,,,"@!",11,,,"CENTER",,"CENTER",,,,,,.F. )  
TRCell():New(oSection,"Pcts"          ,,,"@E 999999.999",9,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"Kg."           ,,,"@E 999999.999",9,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"Vlr.R$"        ,,,"@E 999,999,999,999.99",18,,,"CENTER",,"CENTER",,,,,,.F. ) 
TRCell():New(oSection,"%Valor"        ,,,"@!",4,,,"CENTER",,"CENTER",,,,,,.F. ) 
TRCell():New(oSection,"%Peso"         ,,,"@!",4,,,"CENTER",,"CENTER",,,,,,.F. ) 
TRCell():New(oSection,"Qtde.Dev."     ,,,"@!",9,,,"CENTER",,"CENTER",,,,,,.F. )   
TRCell():New(oSection,"Pcts.Dev."     ,,,"@E 999999.999",9,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"Kg.Dev"        ,,,"@E 999999.999",9,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"VlDev.R$."     ,,,"@E 999,999,999,999.99",16,,,"CENTER",,"CENTER",,,,,,.F. )  
TRCell():New(oSection,"%Vl.Dev."      ,,,"@!",4,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"%Pes.Dev."     ,,,"@!",4,,,"CENTER",,"CENTER",,,,,,.F. )
TRCell():New(oSection,"Grupo"         ,,,"@!",4,,,"CENTER",,"CENTER",,,,,,.F. ) 

oBreak := TRBreak():New(oSection,oSection:Cell("Grupo"),) 

TRFunction():New(oSection:Cell("Vlr.R$"),,"SUM",oBreak,,,,.T.,.T.,.T.,oSection) 
TRFunction():New(oSection:Cell("Qtde"),,"SUM",oBreak,,,,.F.,.F.,.F.,oSection)
TRFunction():New(oSection:Cell("Pcts")  ,,"SUM",oBreak,,,,.F.,.F.,.F.,oSection)
TRFunction():New(oSection:Cell("Kg.")   ,,"SUM",oBreak,,,,.F.,.F.,.F.,oSection)
TRFunction():New(oSection:Cell("Qtde.Dev."),,"SUM",oBreak,,,,.F.,.F.,.F.,oSection)
TRFunction():New(oSection:Cell("Kg.Dev"),,"SUM",oBreak,,,,.F.,.F.,.F.,oSection) 
TRFunction():New(oSection:Cell("Pcts.Dev."),,"SUM",oBreak,,,,.F.,.F.,.F.,oSection) 
TRFunction():New(oSection:Cell("VlDev.R$."),,"SUM",oBreak,,,,.F.,.F.,.F.,oSection)  


oSection:Cell("Qtde"):SetAlign("RIGHT")
oSection:Cell("Pcts"):SetAlign("RIGHT")
oSection:Cell("Kg."):SetAlign("RIGHT")
oSection:Cell("Vlr.R$"):SetAlign("RIGHT") 
oSection:Cell("VlDev.R$."):SetAlign("RIGHT") 
oSection:Cell("Qtde.Dev."):SetAlign("RIGHT")
oSection:Cell("Pcts.Dev."):SetAlign("RIGHT")

TRFunction():New(oSection:Cell("Qtde" ), "TOT1" , "SUM", ,,,, .F., .t.)
TRFunction():New(oSection:Cell("Pcts" ), "TOT2" , "SUM", ,,,, .F., .t.)
TRFunction():New(oSection:Cell("Kg." ), "TOT3" , "SUM", ,,,, .F., .t.)
TRFunction():New(oSection:Cell("Qtde.Dev." ), "TOT4" , "SUM", ,,,, .F., .t.)	  
TRFunction():New(oSection:Cell("Kg.Dev" ), "TOT5" , "SUM", ,,,, .F., .t.)	
TRFunction():New(oSection:Cell("Pcts.Dev." ), "TOT6" , "SUM", ,,,, .F., .t.)	
TRFunction():New(oSection:Cell("VlDev.R$." ), "TOT7" , "SUM", ,,,, .F., .t.)	    
 
oSection:SetPageBreak(.F.)
oSection:SetTotalText(" ") 

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport                                          
@description  Query para gerar dados que serão impressos
@author  Ronaldo Carvalho
@type	 Static Function
@since   03/05/2019
@version All versions
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oSection := oReport:Section(1)
Local oBreak
Local cPart
Local cCase
Local cFiliais          := "' '"
Local nCont
Local nX
Local nPos := 0
Local cCodigos          := ""
Local aVerbas          := {} 
Local cQuery := ""  
Local cTotal := ""
Local aDados  := {}
Local _nTotalF := 0 
Local _nTotalD := 0
Local _nPesTotD := 0
Local _nPesTotF := 0 
Local nPesoF := 0
Local nPesoD:= 0
Private cTes := SUPERGETMV("ID_NTESDEV")
                                                                                                                        
  cQuery += " SELECT * FROM ( SELECT
  cQuery += " 'SD2' TABELA,
  cQuery += " B1_COD, "
  cQuery += " B1_DESC,"
  cQuery += " B1_XPESO2U, "
  cQuery += " B1_CONV, "
  cQuery += " B1_GRUPO, "
  cQuery += " D2_QUANT, "
  cQuery += " D2_QTSEGUM,"
  cQuery += " D2_TOTAL,"
  cQuery += " D2_PESO, "
  cQuery += " D2_TIPO, " 
  cQuery += " D2_TES, " 
  cQuery += " D2_DOC, "
  cQuery += " D2_NUMSEQ, "
  cQuery += " D2_ITEM "
  cQuery += " FROM SD2010 SD2"  
  cQuery += " INNER JOIN SF4010 SF4 ON ( D2_TES = F4_CODIGO AND  SF4.D_E_L_E_T_ <> '*'"
	If MV_PAR12 == 1
		 cQuery += " AND SF4.F4_ESTOQUE IN ('S')  "
	ElseIf MV_PAR12 == 2
		 cQuery += " AND SF4.F4_ESTOQUE IN ('N')  "
	Else
		 cQuery += " AND SF4.F4_ESTOQUE IN ('A')  "
	EndIf        
	If MV_PAR13 == 1
		 cQuery += " AND SF4.F4_DUPLIC  IN ('S')  "
	ElseIf MV_PAR13 == 2
		 cQuery += " AND SF4.F4_DUPLIC  IN ('N') "
	Else
	     cQuery += " AND SF4.F4_DUPLIC  IN ('A') "
	EndIf 		
cQuery += " )"
cQuery += " INNER JOIN SB1010 SB1 ON (B1_COD  = D2_COD AND SB1.D_E_L_E_T_ <> '*' AND "
cQuery += " SB1.B1_COD BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND SB1.B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND SB1.B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "

cQuery += " )"
cQuery += " WHERE SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SD2.D2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SD2.D_E_L_E_T_ <> '*' " 

If MV_PAR11 == 1 

	cQuery += " UNION ALL " 

	cQuery += " SELECT " 
	cQuery += " 'SD1' TABELA,
	cQuery += " B1_COD,"
	cQuery += " B1_DESC,"
	cQuery += " B1_XPESO2U,"
	cQuery += " B1_CONV,"
	cQuery += " B1_GRUPO,"
	cQuery += " D1_QUANT,"
	cQuery += " D1_QTSEGUM,"
	cQuery += " D1_TOTAL,"
	cQuery += " D1_PESO," 
	cQuery += " D1_TIPO," 
	cQuery += " D1_TES,"
	cQuery += " D1_DOC, "
    cQuery += " D1_NUMSEQ, " 
    cQuery += " D1_ITEM "
	cQuery += " FROM SD1010 SD1"   
	cQuery += " INNER JOIN SB1010 SB1 ON (B1_COD  = D1_COD AND SB1.D_E_L_E_T_ <> '*' AND "
	cQuery += " SB1.B1_COD BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND SB1.B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND SB1.B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cQuery += " )"
	cQuery += " WHERE SD1.D1_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += " AND SD1.D1_FILIAL BETWEEN '  ' AND 'ZZ' "
	cQuery += " AND D1_TIPO = ('D') "
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' " 

	cQuery += " UNION ALL " 

	cQuery += " SELECT "
	cQuery += " 'SD1' TABELA,"
	cQuery += " B1_COD,"
	cQuery += " B1_DESC,"
	cQuery += " B1_XPESO2U,"
	cQuery += " B1_CONV,"
	cQuery += " B1_GRUPO,"
	cQuery += " D2_QUANT,"                                                        
	cQuery += " D2_QTSEGUM,"
	cQuery += " D2_TOTAL,"
	cQuery += " D2_PESO,"
	cQuery += " D2_TIPO,"
	cQuery += " D2_TES, "
	cQuery += " D2_DOC, "
    cQuery += " D2_NUMSEQ, "
    cQuery += " D2_ITEM "
	cQuery += " FROM SD2010 SD2 "
	cQuery += " INNER JOIN SB1010 SB1 ON (B1_COD  = D2_COD AND SB1.D_E_L_E_T_ <> '*' AND "
	cQuery += " SB1.B1_COD BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND SB1.B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND SB1.B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cQuery += " )"
	cQuery += " WHERE SD2.D2_TES IN ("+cTes+") AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SD2.D_E_L_E_T_ <> '*' " 
EndIf	
cQuery += " ) TAB "
cQuery += " GROUP BY TABELA,B1_COD,B1_DESC,B1_XPESO2U,B1_CONV,B1_GRUPO,D2_QUANT,D2_QTSEGUM,D2_TOTAL,D2_PESO,D2_TIPO,D2_TES,D2_DOC,D2_NUMSEQ,D2_ITEM  " 
cQuery += " ORDER BY B1_GRUPO ASC "           

TcQuery cQuery New Alias T01  

T01->(DbGoTop())
nCont:= 1
While !T01->(EOF()) 
    If nCont == 1
         aAdd( aDados, {ALLTRIM(T01->B1_COD),;
         IIF(T01->TABELA $ "SD2",T01->D2_TOTAL,0),;
         IIF(T01->TABELA $ "SD1",T01->D2_TOTAL,0),;
         IIF(T01->TABELA $ "SD2",((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),0),;
         IIF(T01->TABELA $ "SD1",((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),0),;
         IIF(T01->TABELA $ "SD2",T01->D2_QUANT,0),;
         IIF(T01->TABELA $ "SD1",T01->D2_QUANT,0),;
         T01->B1_XPESO2U ,;
         IIF(T01->TABELA $ "SD2",T01->D2_QTSEGUM,0),;
         IIF(T01->TABELA $ "SD1",T01->D2_QTSEGUM,0),;
         ALLTRIM(T01->B1_DESC),;
         T01->B1_GRUPO,;
         T01->B1_CONV })   
    Else         
        For nX := 1 to Len(aDados)
            If aDados[nX][1] == ALLTRIM(T01->B1_COD)
                nPos := nX
                nX:= Len(aDados)
            EndIf    
        Next
        If nPos == 0
            aAdd( aDados, {ALLTRIM(T01->B1_COD),;
            IIF(T01->TABELA $ "SD2",T01->D2_TOTAL,0),;
            IIF(T01->TABELA $ "SD1",T01->D2_TOTAL,0),;
            IIF(T01->TABELA $ "SD2",((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),0),;
            IIF(T01->TABELA $ "SD1",((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),0),;
            IIF(T01->TABELA $ "SD2",T01->D2_QUANT,0),;
            IIF(T01->TABELA $ "SD1",T01->D2_QUANT,0),;
            T01->B1_XPESO2U ,;
            IIF(T01->TABELA $ "SD2",T01->D2_QTSEGUM,0),;
            IIF(T01->TABELA $ "SD1",T01->D2_QTSEGUM,0),;
            ALLTRIM(T01->B1_DESC),;
            T01->B1_GRUPO,;
            T01->B1_CONV })   
        Else
            aDados[nPos] := { ALLTRIM(T01->B1_COD),; 
            IIF(T01->TABELA $ "SD2" .And.!(T01->D2_TES $ cTes),aDados[nPos][2]+T01->D2_TOTAL, aDados[nPos][2]),; 
            IIF(T01->TABELA $ "SD1",aDados[nPos][3]+T01->D2_TOTAL,IIF(T01->D2_TES $ cTes,aDados[nPos][3]+T01->D2_TOTAL, aDados[nPos][3])),;  
            IIF(T01->TABELA $ "SD2",aDados[nPos][4]+((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),aDados[nPos][4]),; 
            IIF(T01->TABELA $ "SD1",aDados[nPos][5]+((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U),aDados[nPos][5]),; 
            IIF(T01->TABELA $ "SD2",aDados[nPos][6]+T01->D2_QUANT,aDados[nPos][6]),; 
            IIF(T01->TABELA $ "SD1",aDados[nPos][7]+T01->D2_QUANT,aDados[nPos][7]),;
            aDados[nPos][8],;
            IIF(T01->TABELA $ "SD2",aDados[nPos][9]+T01->D2_QTSEGUM,aDados[nPos][9]),; 
            IIF(T01->TABELA $ "SD1",aDados[nPos][10]+T01->D2_QTSEGUM,aDados[nPos][10]),;
            ALLTRIM(T01->B1_DESC),;
            T01->B1_GRUPO,;
            T01->B1_CONV }  
             

        EndIf
    EndIf
    
      If nPos > 0 .OR. nCont == 1 
     	_nTotalD  := IIF (T01->TABELA $ "SD1",(_nTotalD + T01->D2_TOTAL),_nTotalD) 
     	_nTotalF  := IIF (T01->TABELA $ "SD2",(_nTotalF + T01->D2_TOTAL),_nTotalF)
     	_nPesTotF := IIF (T01->TABELA $ "SD2",(_nPesTotF + ((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U)),_nPesTotF)
     	_nPesTotD := IIF (T01->TABELA $ "SD1",(_nPesTotD + ((T01->D2_QUANT * T01->B1_CONV)*T01->B1_XPESO2U)),_nPesTotD)
         
      EndIf
    T01->(DbSkip())
    nPos := 0
    nCont++
    
Enddo  
         

oSection:Init()     
  For nX := 1 to Len(aDados)
     oSection:Cell("ID"            ):SetBlock( { || aDados[nX][1]           })
     oSection:Cell("PRODUTO"       ):SetBlock( { || aDados[nX][11]          })
     oSection:Cell("Peso/Unit.KG"  ):SetBlock( { || aDados[nX][8]           }) 
     oSection:Cell("Qtde"          ):SetBlock( { || aDados[nX][6]           })
     oSection:Cell("Pcts"          ):SetBlock( { || aDados[nX][9]           })
     oSection:Cell("Kg."           ):SetBlock( { || aDados[nX][4]           }) 
     oSection:Cell("Vlr.R$"        ):SetBlock( { || aDados[nX][2]           })
     oSection:Cell("%Valor"        ):SetBlock( { ||  SubStr( cValtochar(((aDados[nX][2] / _nTotalF) *100)), 1, 4 ) })
     oSection:Cell("%Peso"         ):SetBlock( { ||  SubStr( cValtochar(((aDados[nX][4] / _nPesTotF) *100)), 1, 4 ) })
     oSection:Cell("Qtde.Dev."     ):SetBlock( { || aDados[nX][7]           })
     oSection:Cell("Pcts.Dev."     ):SetBlock( { || aDados[nX][10]          })  
     oSection:Cell("Kg.Dev"        ):SetBlock( { || aDados[nX][5]           }) 
     oSection:Cell("VlDev.R$."     ):SetBlock( { || aDados[nX][3]           }) 
     oSection:Cell("%Vl.Dev."      ):SetBlock( { ||  SubStr( cValtochar(((aDados[nX][3] / _nTotalD) *100)), 1, 4 ) })
     oSection:Cell("%Pes.Dev."     ):SetBlock( { ||  SubStr( cValtochar(((aDados[nX][5] /_nPesTotD) *100)), 1, 4 ) }) 
     oSection:Cell("Grupo"         ):SetBlock( { || aDados[nX][12]          })
     
   oSection:PrintLine()
  Next nX 
  

T01->(DbCloseArea())
oSection:Finish()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
@description  Cria grupo de perguntas caso não exista
@author  Ronaldo Carvalho
@type	 Static Function
@since   03/05/2019
@version All versions
/*/
//-------------------------------------------------------------------
Static Function ValidPerg(cPerg)

         
u_zPutSX1(cPerg, "01","Filial De" ,               "MV_PAR01", "MV_CH0",02,"C","G",,,"SD2",,,,,,, "Informe a Filial Inicial")
u_zPutSX1(cPerg, "02","Filial Ate",               "MV_PAR02", "MV_CH1",02,"C","G",,,"SD2",,,,,,, "Informe a Filial Final")
u_zPutSX1(cPerg, "03","Periodo De",               "MV_PAR03", "MV_CH2",08,"D","G",,,,,,,,, "Informe a data inicial a ser considerada")
u_zPutSX1(cPerg, "04","Periodo Ate",              "MV_PAR04", "MV_CH3",08,"D","G",,,,,,,,, "Informe a data final a ser considerada")
u_zPutSX1(cPerg, "05","Grupo de Produtos De",     "MV_PAR05", "MV_CH4",02,"C","G",,,"SA1",,,,,,, "Informe o grupo de produtos inicial")
u_zPutSX1(cPerg, "06","Grupo de Produtos Ate",    "MV_PAR06", "MV_CH5",02,"C","G",,,"SA1",,,,,,, "Informe o grupo de produtos final") 
u_zPutSX1(cPerg, "07","Tipo de Produtos De",      "MV_PAR07", "MV_CH6",02,"C","G",,,"SA1",,,,,,, "Informe o tipo de produto inicial")
u_zPutSX1(cPerg, "08","Tipo de Produtos Ate",      "MV_PAR08", "MV_CH7",02,"C","G",,,"SA1",,,,,,, "Informe o tipo de produto inicial")
u_zPutSX1(cPerg, "09", "Produto De?",             "MV_PAR09", "MV_CH8", TamSX3('B1_COD')[01],"C", 0, "G",, "SB1",        ,  ,        ,        ,    , "Informe o produto inicial")
u_zPutSX1(cPerg, "10", "Produto Até?",            "MV_PAR010","MV_CH9", TamSX3('B1_COD')[01],"C", 0, "G", "NaoVazio()", "SB1",        , ,        ,   ,   , "Informe o produto final")
u_zPutSX1(cPerg, "11","Considera Devolução?",     "MV_PAR011","MV_CHA",1,"N",0,"C",,"SA1",,        "Sim",  "Não",        ,        ,    , "Informe Considera Devolução") 
u_zPutSX1(cPerg, "12","Cons. Tes Mov Estoque?",   "MV_PAR012","MV_CHB",1,"N",0,"C",,"SA1",,        "Sim",  "Não",        "Ambos",        ,    , "Cons. Tes Mov Estoque")
u_zPutSX1(cPerg, "13","Cons. Tes Gera Financeiro?","MV_PAR013","MV_CHC",1,"N",0,"C",,"SA1",,       "Sim",  "Não",        "Ambos",        ,    , "Cons. Tes Gera Financeiro")
Return
 //-------------------------------------------------------------------
 /*/{Protheus.doc} zPutSX1
 Cria grupo de perguntas caso não exista
 @author  Ronaldo Carvalho
 @since   03/05/2019
 @version P11/P12
 /*/
 //-------------------------------------------------------------------
User Function zPutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel,nTamanho,cTipoCamp, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp)
    Local aArea       := GetArea()
    Local cChaveHelp  := ""
    Local nPreSel     := 0
    Local lInclui     := .F.
    Default cGrupo    := Space(10)
    Default cOrdem    := Space(02)
    Default cTexto    := Space(30)
    Default cMVPar    := Space(15)
    Default cVariavel := Space(6)
    Default cTipoCamp := Space(1)
    Default nTamanho  := 0
    Default nDecimal  := 0
    Default cTipoPar  := "G"
    Default cValid    := Space(60)
    Default cF3       := Space(6)
    Default cPicture  := Space(40)
    Default cDef01    := Space(15)
    Default cDef02    := Space(15)
    Default cDef03    := Space(15)
    Default cDef04    := Space(15)
    Default cDef05    := Space(15)
    Default cHelp     := ""
     
    //Se tiver Grupo, Ordem, Texto, Parâmetro, Variável, Tipo e Tamanho, continua para a criação do parâmetro
    If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0
         
        //Definição de variáveis
        cGrupo     := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")           //Adiciona espaços a direita para utilização no DbSeek
        cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
        cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em maiúsculo
        nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o pré-selecionado será o Primeiro
        cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definição para ser tanto Servidor quanto Local
        nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - Limitação do Protheus
        nDecimal   := Iif(Valtype(nDecimal) == "C", "9",  9)                //Se o decimal for maior que 9, volta para 9
        nDecimal   := Iif(cTipoPar == "N", nDecimal, 0)               //Se não for parâmetro do tipo numérico, será 0 o Decimal
        cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em maiúsculo
        cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo não estiver entre Caracter / Data / Numérico, será Caracter
        cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Parâmetro em maiúsculo
        cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Parâmetro estiver em branco, será um Get
        nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho será 1
     
        DbSelectArea('SX1')
        SX1->(DbSetOrder(1)) // Grupo + Ordem
     
        //Se não conseguir posicionar, a pergunta será criada
        If ! SX1->(DbSeek(cGrupo + cOrdem))
            RecLock('SX1', .T.)
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                    X1_HELP    := ""
                     
                    fPutHelp(cChaveHelp, cHelp)
                EndIf
            SX1->(MsUnlock())
        EndIf
    EndIf
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------*
 | Função: fPutHelp                                  |
 | Desc:   Função que insere o Help do Parametro     |
 *---------------------------------------------------*/
 
Static Function fPutHelp(cKey, cHelp, lUpdate)
    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
     
    //Se a Chave ou o Help estiverem em branco
    If Empty(cKey) .Or. Empty(cHelp)
        Return
    EndIf
     
    //**************************** Português
    nRet := SPF_SEEK(cFilePor, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFilePor, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Inglês
    nRet := SPF_SEEK(cFileEng, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileEng, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Espanhol
    nRet := SPF_SEEK(cFileSpa, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileSpa, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
        EndIf
    EndIf
Return