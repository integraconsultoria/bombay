#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"    

Static Tb_Ferra := ""
Static Tb_Ecomm := ""
Static Tb_Conex := ""
Static Tb_Produ := ""
Static Tb_Estru := ""
Static Tb_IDS   := ""
Static Tb_Monit := ""
Static Tb_ChMon := ""
Static Tb_LgMon := ""
Static Tb_ThMon := ""
Static Tb_Depar := ""
Static Tb_Categ := ""
Static Tb_Marca := ""
Static Tb_Fabri := ""
Static Tb_Canal := ""
Static Tb_TbPrc := ""
Static Tb_TbSta := ""
Static Tb_CondP := ""
Static Tb_Transp:= ""
Static Tb_Voucher:=""
Static FilEcomm := ""
Static Armazem  := ""

/*/{protheus.doc} MaR01Ecomm
*******************************************************************************************
Relatório de Vendas do e-Commerce

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function MaR01Ecomm()
Local cTitulo := "Relatório das Vendas On-Line"
Local oReport := ""

If u_MaEcIniVar(.F.,@Tb_Ferra,@Tb_Ecomm,@Tb_Conex,@Tb_Produ,@Tb_Estru,@Tb_IDS,@Tb_Monit,@Tb_ChMon,@Tb_LgMon,@Tb_ThMon,@Tb_Depar,@Tb_Categ,@Tb_Marca,@Tb_Fabri,@Tb_Canal,@Tb_TbPrc,@Tb_TbSta,@Tb_CondP,@Tb_Transp,@Tb_Voucher,@FilEcomm,@Armazem)
    u_MaSetFilEC(Tb_Ecomm,NIL)
    oReport := ReportDef(cTitulo)
    oReport:PrintDialog()
EndIf

Return

/*/{protheus.doc} ReportDef
*******************************************************************************************
Funcao de Organizacao das sessoes e dos campos.

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ReportDef(cTitulo)
Local oReport 
Local oSection 
Local cPergunte := "MAR01ECO"

AtuSx1(cPergunte)         
Pergunte(cPergunte,.F.)

oReport  := TReport():New("MAR01ECO",cTitulo,cPergunte, {|oReport| ReportPrint(oReport)},cTitulo) 
oSection := TRSection():New(oReport,"Vendas on-line",{},{})
oSection:SetHeaderPage()    
oSection:SetTotalInLine(.F.)

TRCell():New(oSection,"FILIAL"	     	,, "Filial"	    		,"@!"	    ,  Tamsx3("CJ_FILIAL")[1]			    ,  .F.)	
TRCell():New(oSection,"PLATAFORMA"	 	,, "Plataforma"			,"@!"	    ,  Tamsx3("CJ_XORIGEM")[1]	    	    ,  .F.)	
TRCell():New(oSection,"DATA"	     	,, "Data"	    		,""	        ,  10				                    ,  .F.)	
TRCell():New(oSection,"HORA"	     	,, "Hora"	    		,"@!"	    ,  8				                    ,  .F.)	
TRCell():New(oSection,"CANAL"		 	,, "Canal"	    		,"@!"	    ,  50		                            ,  .F.)	
TRCell():New(oSection,"IDSITE"	     	,, "Id Venda"			,""         ,  Tamsx3("CJ_XIDVNDA")[1]				,  .F.)	 
TRCell():New(oSection,"ORCAMENTO"	 	,, "Orçamento"			,"@!"		,  Tamsx3("CJ_NUM")[1]				    ,  .F.)	
TRCell():New(oSection,"EMISSAO"	     	,, "Emissao"	   		,""	        ,  10				                    ,  .F.)	

oReport:NoUserFilter()
Return(oReport)

/*/{protheus.doc} ReportPrint
*******************************************************************************************
Funcao de Impressão dos Dados

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1) 
Local nX		:= 0
Local aDados    := {}

Processa( { || aDados:= GetDadosPrn() }, "Aguarde...", "Filtrando dados para impressão...")

oReport:SetMeter(Len(aDados))
For nX:=1 to Len(aDados)
	If oReport:Cancel()
		Exit			
	Else		
		oReport:IncMeter()
		oSection1:Init() 
        oSection1:Cell("FILIAL"	    ):SetValue(aDados[nX,01])
		oSection1:Cell("PLATAFORMA"	):SetValue(aDados[nX,02])			 
		oSection1:Cell("DATA"		):SetValue(aDados[nX,03])			 
		oSection1:Cell("HORA"		):SetValue(aDados[nX,04])			
		oSection1:Cell("CANAL"		):SetValue(aDados[nX,05])			
		oSection1:Cell("IDSITE"		):SetValue(aDados[nX,06])			
		oSection1:Cell("ORCAMENTO"	):SetValue(aDados[nX,07])
        oSection1:Cell("EMISSAO"	):SetValue(aDados[nX,08])
		oSection1:PrintLine()				
	EndIf
Next nX
oSection1:Finish() 		
oReport:EndPage() 					
Return NIL

/*/{protheus.doc} GetDadosPrn
*******************************************************************************************
Funcao de Extração dos Dados

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetDadosPrn()
Local aDados := {}
Local cQuery := ""
Local cAlias := GetNextAlias()
Local cCanal := ""
Local aCanal := {}
Local nPos   := 0

(Tb_Canal)->(DBSetOrder(1))
Do While (Tb_Canal)->(!Eof())
    aAdd(aCanal,{PadR(Alltrim((Tb_Canal)->&(Tb_Canal+"_ECOMME")),Tamsx3("CJ_XORIGEM")[1]),;
                 Alltrim((Tb_Canal)->&(Tb_Canal+"_CODIGO")),;
                 PadR(Alltrim((Tb_Canal)->&(Tb_Canal+"_IDECOM")),Tamsx3("CJ_XCANAL")[01]),;
                 Alltrim((Tb_Canal)->&(Tb_Canal+"_DESCRI"))})

    (Tb_Canal)->(dbSkip())
EndDo

cQuery := "SELECT SCJ.R_E_C_N_O_ AS RECSCJ"                                                 +CRLF
cQuery += " FROM "+RetSqlName("SCJ")+" SCJ (NOLOCK)"                                        +CRLF
cQuery += " INNER JOIN "+RetSqlName(Tb_Ferra)+" FERRAM (NOLOCK)"                            +CRLF
cQuery += "    ON FERRAM."+Tb_Ferra+"_FILIAL = '"+xFilial(Tb_Ferra)+"'"                     +CRLF
cQuery += "   AND FERRAM."+Tb_Ferra+"_CODIGO = SCJ.CJ_XORIGEM"                              +CRLF
cQuery += "   AND FERRAM.D_E_L_E_T_ = ' '"                                                  +CRLF
cQuery += " WHERE SCJ.CJ_XORIGEM <> ' '"                                                    +CRLF
cQuery += "   AND SCJ.CJ_XIDINTG <> ' '"                                                    +CRLF
If !Empty(MV_PAR02)
    cQuery += "   AND SCJ.CJ_EMISSAO BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"'" +CRLF
ElseIf !Empty(MV_PAR01)
    cQuery += "   AND SCJ.CJ_EMISSAO = '"+dTos(MV_PAR01)+"'"                                +CRLF
EndIf
If !Empty(MV_PAR04)
    cQuery += "   AND SCJ.CJ_XDTINTE BETWEEN '"+dTos(MV_PAR03)+"' AND '"+dTos(MV_PAR04)+"'" +CRLF
ElseIf !Empty(MV_PAR03)
    cQuery += "   AND SCJ.CJ_XDTINTE = '"+dTos(MV_PAR03)+"'"                                +CRLF
EndIf
If !Empty(MV_PAR06)
    cQuery += "   AND SCJ.CJ_XORIGEM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"             +CRLF
ElseIf !Empty(MV_PAR05)
    cQuery += "   AND SCJ.CJ_XORIGEM = '"+MV_PAR05+"'"                                      +CRLF
EndIf
cQuery += "   AND SCJ.D_E_L_E_T_ = ' '"                                                     +CRLF
cQuery += " ORDER BY CJ_FILIAL, CJ_EMISSAO, CJ_XORIGEM, CJ_XDTINTE"                         +CRLF

dbUseArea(.T.,"TOPCONN", TCGenQry(,,ChangeQuery(cQuery)),cAlias, .F., .T.)
Do While (cAlias)->(!Eof())
    SCJ->(dbGoto((cAlias)->RECSCJ))
    cCanal := "Id Canal: "+Alltrim(SCJ->CJ_XCANAL)
    nPos := Ascan(aCanal,{|x| x[1]+x[3]==SCJ->CJ_XORIGEM + SCJ->CJ_XCANAL })
    If nPos > 0
        cCanal += " - "+Alltrim(aCanal[nPos,02])+"-"+Alltrim(aCanal[nPos,04])
    EndIf
    
    aAdd(aDados,{SCJ->CJ_FILIAL,            ; // 01 - Filial
                 Alltrim(SCJ->CJ_XORIGEM),  ; // 02 - Plataforma
                 SCJ->CJ_XDTINTE,           ; // 03 - Data Integração
                 SCJ->CJ_XHRINTE,           ; // 04 - Hora Integração
                 cCanal,                    ; // 05 - Canal Integração
                 SCJ->CJ_XIDVNDA,           ; // 06 - Id da Venda
                 SCJ->CJ_NUM,               ; // 07 - Numero do Orçamento Gerado no Protheus
                 SCJ->CJ_EMISSAO}           ) // 08 - Emissao do Orçamento

    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return aDados

/*/{protheus.doc} AtuSx1
*******************************************************************************************
Funcao de Atualização das Perguntes

@author: Marcelo Celi Marques
@since: 15/01/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AtuSx1(cPerg)
u_MaPutSx1(cPerg,	"01","Emissao de?"      ,"","","mv_ch1","D",8                            ,0,1,"G","",""      ,"","S","mv_par01","","","","","","","","","","","","","","","","")
u_MaPutSx1(cPerg,	"02","Emissao até?"     ,"","","mv_ch2","D",8                            ,0,1,"G","",""      ,"","S","mv_par02","","","","","","","","","","","","","","","","")
u_MaPutSx1(cPerg,	"03","Descida de?"      ,"","","mv_ch3","D",8                            ,0,1,"G","",""      ,"","S","mv_par03","","","","","","","","","","","","","","","","")
u_MaPutSx1(cPerg,	"04","Descida até?"     ,"","","mv_ch4","D",8                            ,0,1,"G","",""      ,"","S","mv_par04","","","","","","","","","","","","","","","","")
u_MaPutSx1(cPerg,	"05","Plataforma de?"   ,"","","mv_ch5","C",Tamsx3(Tb_Ferra+"_CODIGO")[1],0,1,"G","",Tb_Ferra,"","S","mv_par05","","","","","","","","","","","","","","","","")
u_MaPutSx1(cPerg,	"06","Plataforma até?"  ,"","","mv_ch6","C",Tamsx3(Tb_Ferra+"_CODIGO")[1],0,1,"G","",Tb_Ferra,"","S","mv_par06","","","","","","","","","","","","","","","","")
Return 
