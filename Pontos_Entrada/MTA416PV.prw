#include 'totvs.ch'
#include 'rwmake.ch'
#include 'protheus.ch'

//PE na efetição do orçamento - 

User Function MTA416PV()

//->> Marcelo Celi - 20/12/2022
Local aArea         := GetArea()
Local nPC6NumOrc    := 0
Local nPC6QTDVEN    := 0

//->> Marcelo Celi - 06/01/2023
Local lUsaBkOrd := Alltrim(Upper(GetNewPar("BO_BKORDPV","S")))=="S" 
 
/*	C5_TRANSP  :=SCJ->CJ_XTRANSP
	C5_VEND1   :=SCJ->CJ_XVEND1
	C5_COMIS1  :=SCJ->CJ_XCOMIS1
	C5_VEND2   :=SCJ->CJ_XVEND2
	C5_COMIS2  :=SCJ->CJ_XCOMIS2
	C5_VEND3   :=SCJ->CJ_XVEND3
	C5_COMIS3  :=SCJ->CJ_XCOMIS3
	C5_VEND4   :=SCJ->CJ_XVEND4
	C5_COMIS4  :=SCJ->CJ_XCOMIS4
	C5_VEND5   :=SCJ->CJ_XVEND5
	C5_COMIS5  :=SCJ->CJ_XCOMIS5
	C5_NATUREZ :=SCJ->CJ_XNATUR
	C5_MENNOTA :=SCJ->CJ_XMENNF  
	C5_TIPOCLI :=SCJ->CJ_XTIPOCL
	C5_XNUMSCJ :=SCJ->CJ_NUM
	C5_XNOMCLI :=Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME") //SCJ->CJ_XNOMCLI
	C5_XNOMVEN :=SCJ->CJ_XNOMVEN
	C5_ESPECI1 :=SCJ->CJ_XESPEC1
	C5_VOLUME1 :=SCJ->CJ_XVOLUM1

	
	//Natalia
	C5_XENDENT := SCJ->CJ_XENDENT
	C5_XCOMPLE := SCJ->CJ_XCOMPLE
	C5_XBAIRRE := SCJ->CJ_XBAIRRE                                         
	C5_XESTENT := SCJ->CJ_XESTENT 
	C5_XCDMUNE := SCJ->CJ_XCDMUNE
	C5_XMUNE   := SCJ->CJ_XMUNE
	C5_XCEPE   := SCJ->CJ_XCEPE
	C5_XMETPAG  := SCJ->CJ_XMETPAG
*/
 
	 _aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_XPRCBAS')})]     := SCK->CK_XPRCBAS                    
	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_DESCONT')})]   := 0 //SCK->CK_DESCONT
	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_VALDESC')})]   := 0 //SCK->CK_VALDESC
	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_PRUNIT')})]    := SCK->CK_PRCVEN
	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_PRUNIT')})]    := SCK->CK_PRCVEN -> Ajustado Daniel 20/08/19
 	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_ITEMPC')})]    := SCK->CK_ITEMPC
 	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_NUMPCOM')})]   := SCK->CK_NUMPCOM
 	 
	 //_aCols[Len(_aCols)][AScan(aHeadC6, {|x| AllTrim(x[2]) == AllTrim('C6_QTDRESE')})]   := SCK->CK_XQTRES //desativado por apresentar error log na operação
	// SCJ->CJ_XNUMSC5 :=M->C5_NUM	       
	
	//Natalia
	//SCJ->CJ_XLEGPED := '1'
	
    //->> Marcelo Celi - 20/12/2022
	C5_XPEDCLI := SCJ->CJ_COTCLI
	C5_XDTENTR := SCJ->CJ_XDTENTR

    If lUsaBkOrd .And. SCK->(FieldPos("CK_XBKQTD"))>0
        If Type("aHeadC6")<>"U" .And. Valtype(aHeadC6)=="A"
            nPC6NUMORC := Ascan(aHeadC6,{|x| Alltrim(x[2])==Alltrim("C6_NUMORC")})
            nPC6QTDVEN := Ascan(aHeadC6,{|x| Alltrim(x[2])==Alltrim("C6_QTDVEN")})
            If nPC6NUMORC > 0 .And. nPC6QTDVEN > 0
                SCK->(dbSetOrder(1))
				If SCK->(dbSeek(xFilial("SCK")+_aCols[Len(_aCols),nPC6NUMORC]))
                    If  SCK->CK_XBKQTD > 0
                        If _aCols[Len(_aCols),nPC6QTDVEN] - SCK->CK_XBKQTD > 0
                            _aCols[Len(_aCols),nPC6QTDVEN] := _aCols[Len(_aCols),nPC6QTDVEN] - SCK->CK_XBKQTD
                        Else
                            _aCols[Len(_aCols),Len(aHeadC6)+1] := .T.
                        EndIf    
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

RestArea(aArea)

return
