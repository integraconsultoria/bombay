#INCLUDE "Totvs.ch"
#INCLUDE "Apwizard.ch"

/*/{protheus.doc} BoDootax
*******************************************************************************************
Monitor da Integração Dootax
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Usuario
*******************************************************************************************
/*/
User Function BoDootax()
Local _cFilAnt := cFilAnt
Local cConex   := "BODOOTAX"

Private aRotina 	:= MenuDef()
Private cCadastro 	:="Monitoramento Dootax"
Private Tb_Monit    := u_MAPNGetTb("MON")
Private Tb_ChMon    := u_MAPNGetTb("CHM")
Private Tb_LgMon    := u_MAPNGetTb("LOG")
Private Tb_ThMon    := u_MAPNGetTb("THR")

AjustCfg(cConex,Tb_Monit,Tb_ChMon)

cConex := FormatIn(cConex,";")
cQuery := "R_E_C_N_O_ "														+CRLF
cQuery += "IN "																+CRLF
cQuery += "("																+CRLF
cQuery += "SELECT DISTINCT MON.R_E_C_N_O_ AS RECMON"			        	+CRLF
cQuery += "	FROM "+RetSqlName(Tb_Monit)+" MON (NOLOCK)"						+CRLF
cQuery += "		WHERE MON."+Tb_Monit+"_FILIAL = '"+xFilial(Tb_Monit)+"'"	+CRLF
cQuery += "		  AND MON."+Tb_Monit+"_CODIGO IN "+cConex 					+CRLF
cQuery += "		  AND MON."+Tb_Monit+"_MSBLQL <> 'S'"						+CRLF
cQuery += "		  AND MON.D_E_L_E_T_ = ' ' "								+CRLF
cQuery += ")"																+CRLF

mBrowse( 6, 1,22,75,Tb_Monit,,,,,,,,,,,,,,cQuery)

cFilAnt := _cFilAnt

Return

/*/{protheus.doc} MenuDef
*******************************************************************************************
Menu do configurador
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function MenuDef()
Private aRotina := { {"Pesquisar"	, "AxPesqui"  		,0,1,0	,.F.},;					 
                     {"Monitorar"	, "u_MaMIntegr"	,0,2,0	,NIL}}
Return aRotina

/*/{protheus.doc} AjustCfg
*******************************************************************************************
Ajusta as configurações do painel de integrações
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function AjustCfg(cConex,cTbMonit,cTbChMon)
Local aArea := GetArea()

(cTbMonit)->(dbSetOrder(1))
If !(cTbMonit)->(dbSeek(xFilial(cTbMonit)+cConex))
    Reclock(cTbMonit,.T.)
    (cTbMonit)->&(cTbMonit+"_FILIAL") := xFilial(cTbMonit)
    (cTbMonit)->&(cTbMonit+"_CODIGO") := cConex
    (cTbMonit)->&(cTbMonit+"_TEMPAT") := 60
    (cTbMonit)->&(cTbMonit+"_MSBLQL") := "N"
    (cTbMonit)->&(cTbMonit+"_DESCRI") := "INTEGRAÇÃO DOOTAX"
    (cTbMonit)->&(cTbMonit+"_DESRED") := "INTEGRAÇÃO DOOTAX"
	(cTbMonit)->&(cTbMonit+"_LOGOTP") := GetLogot()    
EndIf    
(cTbMonit)->(MsUnlock())

(cTbChMon)->(dbSetOrder(1))
If !(cTbChMon)->(dbSeek(xFilial(cTbChMon)+cConex))
    Reclock(cTbChMon,.T.)
    (cTbChMon)->&(cTbChMon+"_FILIAL") := xFilial(cTbChMon)
    (cTbChMon)->&(cTbChMon+"_CODIGO") := cConex
    (cTbChMon)->&(cTbChMon+"_INTEGR") := cConex
    (cTbChMon)->&(cTbChMon+"_CONEX")  := "A"
    (cTbChMon)->&(cTbChMon+"_FUNCAO") := "U_BoEscrDoot()"
    (cTbChMon)->&(cTbChMon+"_FUNREF") := "U_BoDec64Xml()"
    (cTbChMon)->&(cTbChMon+"_ORDEM")  := "1"
    (cTbChMon)->&(cTbChMon+"_ICONE")  := "ng_ico_ccusto"
    (cTbChMon)->&(cTbChMon+"_NOME")   := "ESCRITURAR NF"
    (cTbChMon)->&(cTbChMon+"_COR")    := 255
    (cTbChMon)->&(cTbChMon+"_VALIDA") := 360
    (cTbChMon)->&(cTbChMon+"_EMAIL")  := ""
    (cTbChMon)->&(cTbChMon+"_MSBLQL") := "N"    
    (cTbChMon)->(MsUnlock())
EndIf

RestArea(aArea)

Return

/*/{protheus.doc} GetLogot
*******************************************************************************************
Retorna a imagem a apresentar como logotipo
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetLogot()
Local cEnc64 	 := ""
Local cPastLocal := ""
Local cPastDecod := ""
Local cImagem	 := ""
Local cDestino   := "\system"

cPastLocal := GetTempPath()
cPastLocal := Alltrim(cPastLocal)
cPastLocal += If(Right(cPastLocal,1)=="\","","\")
cPastDecod := StrTran(cPastLocal,"\","\\")

cImagem := "dootax.jpg"
If !File(cPastLocal+cImagem)
    cEnc64 := "I3ppcEIWAADOFAAAeJy1V3k01O+//4xt7DtZYohQkS2UMKlsyVeo7CYhNCEVRpaxJEuY6BtKpaRsiaxlG/uSSraGGcvMkC1qRowPs93pd3/33nPPvX/ce8+578/zPudzzvM87+f9eq/Pw55kEwHxM9Z21gAEAgEucT6ATQBOAVwQyJ/xT+Lm5f5DfDw83LxQPij0D/MLCAnw8wvyQ6GCIoKCQsIcggqIiokIi/75/yPkz/Y/uzhDmB/KL/y/JnYHIMEPIAAyN2QfwCUB4ZaAsHsAGABAeCH/IOCfBOHi5uHl46gkKMRZ0CDOUZ+bm4ujLC8PD2c2jjMP8EjwSqrqW/JJOflC94VLGyTmvOBXO/muU8Z5hKJuePlGkoCg7B45eYX9GppaBw4eMTI2OXrM9NRpK2sbW7szLucvXHR1c/fw8w+4EhgUfPXmrYjIKFT07eQ7KXdT09Izch/8/TAvv+DR4+KXJa9el5aVV9TW1Tc0Nr3/0NzV3dPb1z8w+HF0bHziG25yCk8izy98X1xaXlmlbvze3KJtgzu7f3BBAG7Iv9F/i0uCg4uL4wMe6B9cEK6oPwskeHhV9fkkLZ2gvuF"
    cEnc64 += "S+wwS+aVP5rx41ymgZuhMkbl8Y0RQVv0IaT/1D7R/IPufAUv6PyH7d2D/gQsPCHNDOM7jlgDgAHO8OEML+D/zO5Yq6kWrCIWOwMlCbuA1HkWUaWsTTvfJ+Tjc+Z253hfeh/xtPccSNZgobbJhAylWJVmrijDK/aE+9HqKLPeWQgajlQ2k3YsI21X3cGRJG7ABasZPC2l0Z9czYVyDW1VrMFEnplvPttOD/leLwxmtOLzBu0HMdhTM769PYl+bDwmRqnvmxBj+FIsiMkLwh6wpLblC8xEyJlgDXFDiN59IJFYCHZQTVYVDA7cIB96GXrmLx+ONHwe/Dt97vTizzlBZ5gRPLgpw5jpziOSIl2IJ4SgE0uuG8NcotZMTFqrTnu+ssXa9dws+wd+vVam/ZD5PUO7BZWLAo5W9sJBB0IVUVLf0kw2EeEUX7O6gmAemEndfWsUeox9lA51R7fIMd1xIfZH8igKmu3CoVKI/Jtx0NjgAA5h9rKCK0Z4aZ68d+il3xT7N2XZGPdtKNDtT3tt2QCWbX2VB4tt90eKaeI1YR8p2ZxE3Aszvvd2bl/x8Jbh9kbZO61dGCR6vk+q4wJtO5E"
    cEnc64 += "bwMHzYQHIKQ7f4ap0nag+JVUWWU7tcia6czTI90PZtv+sD2C8Zi64EuJVW9ZCOJkv0EFXBR6yJoUXZbJxa8ETeLCmg6SgKs2S2TNbi2ABvJIige4AZuO47CPBQL640oPFRZa1c9Rz9vpfuwK/lTBnMpeCpxC1zGSKa4gQneCzRJMHjJagKQnckS+OByzepM8Z1PkbP044Y2GGvW6uzfsn13wbnWft0JrDLOcFw8NwQG+jTqoGV3XL9vsQ47VmJHtk3iqa8yGcDmRdx3QhQl1VO5SY7pt7iAy+8wh9uq/BYqTL9MXoswcHA2ks31zBrqi+6V/ZS/N8jjo91D5Lu32zIYCJ/b9PesYGk7/10c9bXWQ2KdTLRHiY9BV4hun0ut69sayq8UWG2cN6twHfv31+iDwZDtpky89ia0vVoP3oIa7jx2ZHGGoxNu+eHeqbjWXcGG6jxsrYEjgG19SGKSSfosxNr5wEnL7HearxLN5wn4h5SV1zEB9p670uS2zUPtwCAmNAxf31erWxgqxLOjw6CCzHCTSpJ9MGSQkf8mGW4wN1zVSNdzyqfGZjCyqp1Ah/F9DItXTGNrL8CPjfQ5kLij"
    cEnc64 += "ISeVvGQ7I5CrO00ATEXN6x4u+oKTCj2QHgVMgoZ7BfWF57/aPi01eqnGLEVhCjjNrPSzJVuhQx+EazvNbniWicU46AxUmf0Wyrlt1vcBrpl2wbrQQFLs/Tc1S+YPmMGx+p5Yk2mEIu7muVSjzNaLP4GX9LDQZdO065lvLCrjxFVeJR/X90oKyizNOGuj+WxtUSs4OZwqsmsyjhDFRlOvqcEP/vtyvQG3v3saH9oCSPNbeu6fsvewFfRRWuP6OpuDMjImMt4ntDcHu/+9FKYQfDq7W4x1ic20EvIoGX8IIGLE35bn76dOWx/xsnDCh29Ot0e6d0ivnh7QKs4Y9f5i/38NuM+XIkNTDaVo1fUG0AMG+ApAD1Jw5lsoLE/ufU4+bNCf4+CzHrW72E/VCHpYe7IjIC8khyXeW/8dGw8G8iFzmPpslu6TPU8rDyamI7euI/l4siDO7GB0QMH8zriK+04MoeZRf4nS0nQpBrrow2X0HoTG8MMaU0W/wciAXFndzizXWJyJkgBl7pegv3wNaV72n31nLWQraqkJPWMtORz/Yt9egJ8WKuVuv69tI2SSb3Wa7XcX8t5YGNH3kLnlxji"
    cEnc64 += "92iF7WA03R7bXf7zKcOEyjfrrpJYuNA07ps5kKuy5p/lrYgTePZwnQ1QENX4DDbQpSxKwXVl7Vu19yWXFV3EZYY0vK7Pop0KtWXtyfEuiJLQWnaIPcVRfBUewInwDIa2bPQGrrciZ54VvWjJBp67VqI7UaGlRTQwZ//Md0tSltGlYYfSL34YUOLq2+eRaIpdEbjfJ5l+BjzQrs6wtW8pEm4bwy/jjxgeESovyJ7SfIQT+Q7llZHO6nV7kABhcqFBzT0dJqPxPfHioOIAoS4LLunHag6Mj/v92BHU5Cvke0jnjlXNmIRIUD7XlyrNbB8v6n1Uia8Ihc6zAYZMNUsgppj10VSnCMOC3XvPUEKjGhXy8sMPFNH3RRtcRi2EFXQtyHTnXmjcOBW+CWeIu9KeY8FCSmAPTNSosLS5mSJ0Krxk8FAeem1lSExTs965XGi5VmuZNyaVIVP4V7Izxwq3Yp33QGyTHZPIZrScw0Qtm3b001gZNsC3Ozsktv6QfDxCc6CZ8oQVVToUEeq6pfFsWXgOPBy4bh9HtacV5XfIboe27wFvpCsSKmPzFTJzUh8HKn08pI1cSe2fNdq0YUhhWfw"
    cEnc64 += "TxHu6d5p1M+O1V3TIYRJg0pQuaeRtwK13o773+bK8xZO1e2113q87R6YQH+ww6Z6hOGwYJu1AeTitWmnmVHhLreJMKhvYW7180FZyglHW4UbeERdNtAHiT2YnoMI4nic+hgGxfsVtWcNdaH6C9ep5e99r196qbbvvO9jBMtrR5xTjw8w7Acw7FkaT+BUTHG5WkirtEPd89tNkc2PQpIBK1DlDdf8XovoPA8zEkduXsXA0kfTZdDZsaow0Q4DQyswctZ2U6cojQ5jPUhvSD7gnsJdh0igkS9CbLozyWCJHprwC+9jAidY4uDPmHOZ221bzmucTLoto1Rw3essFBIGbJbBNOdUxV4vueYq0Br1JSiYXR2NN4qICo3jLJT3P3n9n49KSJMq/65qP7mzZHh2iCJEdWqQWLMmeUZmRwt/utbABS4/dIdoPNvBAE2xiA5fzXrKBYoWsAlgOJwNswpLbZcFf9CtWz1FDlmOtdsVFYnPeioeWt3sCHA/5zY/7s65gXesRoCaio0gUaXw7K7ULw4dHBP9+9bmeitdD7bcWzi6NOtchsVn9KQxU2WYUjcNo2lcR9DPYoAM1ZjhaD/MFkZ"
    cEnc64 += "mHvlK9B9wg5by9dU9DITYUPU+muXwnlLb7B2hOeWD3cNTi1InSHnjTccZf46ofPsQMCy27rA4eW1j1ePPGR06uaGel8UbMUkicORuAcrPGuM9Tw1JYUpNe6JdB7zDiSF/PZLOMi3hjNhBp/otzI7jYnscJUmeGGWVpLZWuDN4WE//xTPlrq+v8CTOnsk50WWfI9XQ9rinBFr6urnLCL8ORWm7yMKiquW7IBgSraY9bKcov9VNtwRwge8b/qPjqOb6g92veZgPD7Z2Id0YgJ+15xSg6TWsj9KgfHkWJESGm3haLLJjMsolHyPjN/kC1wcWCbWtbvuMp4Zif62tIWhENCS750u0ZvJTq7M2ZSmi6tuSiWyIbwCATN4Yltu0u4CjSBbLtxrFKY/FHQcGl0+P60qnbjVGWN77dTNx4T1vrfq+Jx5oaodMsNJi5FkbrbqxBsjdXXG7H1Ebo5dAXGKrNvs3+MnOr+GLcxznKeTgvwxDBDwb2WhhTQ3OIcT5DTvYOpjTaMX9vp+jIxiDyxZykxFY9Z/Et0o/fb02IbGAdKjzGU5X+qqIx2+5qfgVaaCeyyVjjyXfYzE9U6fp++mkEI"
    cEnc64 += "5bqgXCUbo7PD5bzVDIvmaFdS2wryJYf/LUMVMdyLB7H+rJC+iVaiolAGVZcHXA9Y7eHZa6D4XNiTT/FcKonCtcfzKlRyfi7r0IfMMIpZwiDBtpzywqPGSkJZoXXofIL96E3ERXNXsaNuxfeRCo7Tkryfxvv6Xypz6tonNPp/b5z7+V2z0SUvUF54YUvqCQxvI7f5xD/3RV0yqH9o6sEGf6mw8FSI1Yy9OD3TlbSkMH/0pewxPSDCJagPPEcRJMOdyKK7d7IxQa1GwabWKiARvNCQlrKqzQ2cBLb2JhisTnaVp+RZj4kDv2GFW0V4fSAXeZrlvLqxeZnqRQcWSO9gmDtfLxFVnZbgs/7DXdJ4l1LFeKGiPOk2GxniCp8dY61Y/Q7nyFdSZv8ivUXSzCddijzNMmOtfTTyU55VZIwHZ1bfurGysS+TP2QfnkVrUGjnVe6azt05LC89Vj8MYOaTqhHISdP0athd+EUazRebN4xg7c/rT6NoSkylhxVAWKc3d/qT+8EDWunTs6vatWIcpygGivdDD6k3whW+Jo+Zw+i/YyrI/T3alcpWoaWsIHoZ9ZhJSErPsOcTBJkiDU3UvMT"
    cEnc64 += "LdQJJ4Z9o6+wlMb3O/W49K0btc8Tbpg9j+nPoNfR9JhZZofoEgw1ZTnKUmFMVJRK88RWzB2h8IppSNYnKH/G0dNQQYGFXLs1lhFjD2VpXYTS4kqJuqfN9/IF8vqOS5/itZyaY3Z+YcQcOb6LSvybA6/iTuzsYfGn0y8toyXZQKCDCSmO9SIMOQ/j2anx8LBXcR1/I4+3XUiDtftND3w8Bjm/abSte59OWwuZLVjEKsKDEKDqUi8nkGa1YuZSP8Mw9UH+v6+91f6ZO+Ta2O9ANdSahbdJ7d0VffgR3vWL4OMJW7vpR93Ez3/ciCdE1CkXMr4UUQ5Gvoch0J2RcORnqS42wM0GSE4rt1PaljLMHG7y7La1SkJNvf8+vJ/LKw6XZ3VC/HeDW05mIMduxFl4cr6NJ5hOFUQ90rZqVVaqvV8t+dHLy7F+Gy8rHjfbWkmL5jhiLwMBfiDbvmVEL8TCR/Y/+Nz6bOO7boRn5gZB1dqX8/a6fVFu1XIFUQXniRcEb9IiQfeXoElXJGxqV/bennyegKbBQ1L5edasY0rpV0IXaHLS195A5+EMWRdi1lLnMKGlB5/UR1mZPSYB3vvridj"
    cEnc64 += "fLQkPEtCtD9SkWLu7uFXcmjwdEYRoDOwwh3mOVV8Kk5jysAohixii6A4peC3Xy09jm9Ruw08qyg+oONKvsnp9ZJjv46UxouCdQd8yt+NeQbu9zXzvR0vVeBKuKxsD0MwnekASP0+8K+MEB5xt/MhcHSaTkxQpt4aGxeMepTV+M1Mr33HljZuffqAR85Z/+0hQB7POTan5UDgu++GOEKdmfmVWb8KzYVKM40RdoVXZ3bePiC7mfa+iw1RyBYwETpyS1CO1luF4sk1su0GH6MZ3FBPaZ7D88q0QFzvwe/nUWWPztq31nsifpr5DAxU29L62IpopRxcRMN+Tuj+vmpqN1BHrpr2pbUp9czgvZubU3p0bH4vU9YvIePe0AcXbIzUwe3SnqIWod6wuM5U08etF0OHYqEqHKus3eg41F5L4dvWynsQcrQ5jNrOBhUGWDqcrvSpjA8t3qx3H6n/EKf7VVFfXdHf0yxf1pFn+c+rXrTNkJM5fl9YCxCy9oOtokoN9P5rTq6ukrGuLnCe2wkTmPNw9TkJyFwPTk4qTE3NR0s2JO38uwcqcfrybzOrNsmcDwa5rYVmxga8ZRylXqslKly"
    cEnc64 += "MaR28pHmgQmnKb99dXjWRcP7q9D6vLCbtsNvAO3YtJ4NzH/T04rzUGhAwTCXrZvU17TaMdcbtT/f3a2buamtC9kdXlaGKNqWNPURqibq8PFESSdGJ6cD467ee/qY+9dNbR9u1JkcuD/fCf1GeO3w67Djdsh4Cu5zmm5PTNTmud199e5pCp8R80PlTpIr1NpRaP+HScftdlPuk6jm60YUgQ5k3WPen2qMp+g6tsQPR53cTh0x4Bb5rqfta+Sz8dSb1kmXBSS13UxND1FUeeFNy3WjL+i4JJZqzf/LDYLCqmV2E6vcTNfbYinViLkbTTgByVtD0fsSLWFjdv1cE4wXwJJ2YjpLEB1Um7/dlGnsP8Vz0sUr+3rZk6fBr1slFsfpGPPP28Is97mnJsHXGacwQWVt+n2Ivmb5Df/UmVvfNm7uer6UNs4P4CN6tZgbmfmnrn1q80C4mJWyKXZ0I3n9744ik06RaubfDCBuYlhYl1nXfshk260O4ys9gA8im8x0cevEnGSOBRaj5hdXPuxXJGleK9ijzvj+bxqSQd1Vm3+gldC+tBpzXrdulCrrI0qUoMD5+UF55GM+vjT9WsNpXc0"
    cEnc64 += "7sqst3TuKviReMn2QCMgeSEvwmzokqzbiyslO7dMWqmSlrOng8UMvkoFmZ8FvpwVzgCn9TOeZcklS7D9qKRjtKWJLhArDH1MeP41wXPhEWeU1UzfhbI8uux7zcuSG9P94PhywjKGV1QU5dhKJuimc0IKH2DEI8oeCyEdD9xhcIsJ5bKc0XDM5M33u5pcSp25SZiCS0sgQtk7CSG9CvV7Aw+A6w81dxwd867tSn16vLuvbgFtbYWqQZ1c9vuSw+HR2EUKxioVf1E20IANcsGFoHS5C2hVHp3+dhTTPxrybgxehLWlnGB5G3Y7yM3fsT7ahfh/KgRMqqhre6DA9WrZ14405yf0ZyNpPbTsBxgZrEOoA61EQFeaFemQjNj1W6R6batNREmj+1Ecnh6anPUQ7JqxVoBM70jodC1dRkyosa1VzcdIcGCehIYHpTIDyRHxWWraz9/6j4/f8/rhIV9GS2X+77+PurdhevdygRniJX0uf/E1kHFCYJa/8rCixlaz7n+H1mMPfUvcPUIdw=="

	Decode64(cEnc64,cPastDecod + cImagem,.F.)
	CpyT2S(cPastLocal+cImagem,cDestino)
EndIf

Return cImagem

/*/{protheus.doc} BoEscrDoot
*******************************************************************************************
Escrituração Dootax
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoEscrDoot()
Local oWizard       := NIL
Local oPanel        := NIL
Local aCoord        := {0,0,300,500}
Local cLogotipo     := "ng_ico_ccusto.png"
Local oFonte1       := TFont():New("Verdana",,013,,.T.,,,,,.F.,.F.)
Local lOk           := .F.
Local aBox01Param 	:= {}
Local aNotas        := {{.F.,"","","",Stod(""),"","",""}}
Local nX            := 1
Local aDoctos       := {}

Private aRet01Param := {}
Private oLbxNF      := NIL
Private oNo 		:= LoadBitmap( GetResources(), "LBNO" 	)
Private oOk 		:= LoadBitmap( GetResources(), "LBTIK"	)
Private lRunDblClick:= .T.
Private lChkTWiz 	:= .F.
Private _cIdent		:= ""

FwMsgRun( ,{|| _cIdent := GetIdEnt() }, , "Aguarde... Buscando Entidade do Sefaz..." )

If Empty(_cIdent)
    MsgAlert("O Serviço de Nota Fiscal do Sefaz não está no ar ou não está configurado nesse ambiente."+CRLF+"A Operação de Escrituração não pode ser Utilizada...")
Else
    aAdd( aRet01Param, Replicate(" ",Tamsx3("F2_SERIE")[01]) )
    aAdd( aRet01Param, Replicate(" ",Tamsx3("F2_DOC")[01])   )
    aAdd( aRet01Param, Replicate(" ",Tamsx3("F2_DOC")[01])   )
    aAdd( aRet01Param, sTod("")                              )
    aAdd( aRet01Param, sTod("")                              )

    aAdd( aBox01Param,{1,"Serie"	    ,aRet01Param[01] ,"@!"			,""	,""	    ,".T.",020	,.T.})
    aAdd( aBox01Param,{1,"Documento de"	,aRet01Param[02] ,"@!"			,""	,"SF2"	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Documento até",aRet01Param[03] ,"@!"			,""	,"SF2"	,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Emissão de"   ,aRet01Param[04] ,""			,""	,""	    ,".T.",070	,.F.})
    aAdd( aBox01Param,{1,"Emissão até"  ,aRet01Param[05] ,""			,""	,""	    ,".T.",070	,.F.})

    oWizard := APWizard():New("Integração Dootax",                                  									                    ;   // chTitle  - Titulo do cabecalho
                            "Informe a parametrização para a seleção de Notas Fiscais com Diferencial de Aliquota de ICMS.",              ;   // chMsg    - Mensagem do cabecalho
                            "Escrituração de Documentos Fiscais",                                                                         ;   // cTitle   - Titulo do painel de apresentacao
                            "",             													         	                                ;   // cText    - Texto do painel de apresentacao
                            {|| TudoOk(1,@aNotas) },                                                                                      ;   // bNext    - Bloco de codigo a ser executado para validar o botao "Avancar"
                            {|| TudoOk(1,@aNotas) },                                                                                      ;   // bFinish  - Bloco de codigo a ser executado para validar o botao "Finalizar"
                            .T.,             												     			                                ;   // lPanel   - Se .T. sera criado um painel, se .F. sera criado um scrollbox
                            cLogotipo,        	   												 			                            ;   // cResHead - Nome da imagem usada no cabecalho, essa tem que fazer parte do repositorio 
                            {|| },                												 			                            ;   // bExecute - Bloco de codigo contendo a acao a ser executada no clique dos botoes "Avancar" e "Voltar"
                            .F.,                  												 			                            ;   // lNoFirst - Se .T. nao exibe o painel de apresentacao
                            aCoord 		                   										 				                        )   // aCoord   - Array contendo as coordenadas da tela

    oPanel := TPanel():New(0,0,'',oWizard:GetPanel(1), oFonte1, .T., .T.,,,((oWizard:GetPanel(1):NCLIENTWIDTH)/2),((oWizard:GetPanel(1):NCLIENTHEIGHT)/2),.F.,.T. )
    oPanel:Align := CONTROL_ALIGN_BOTTOM

    Parambox(aBox01Param,"Parametrizacao",@aRet01Param,,,,,,oPanel,,.F.,.F.)

    oWizard:NewPanel(   "Integração Dootax",                   							            			     ;   // cTitle   - Tï¿½tulo do painel 
                        "Selecione os Documentos para Escriturar no Dootax", 	    	            			     ;   // cMsg     - Mensagem posicionada no cabeï¿½alho do painel
                        {|| .T. 				       },              						        			 	 ;   // bBack    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Voltar"
                        {|| lOk:= TudoOk(2,aNotas),lOk }, 														     ;   // bNext    - Bloco de cï¿½digo utilizado para validar o botï¿½o "Avanï¿½ar"
                        {|| lOk:= TudoOk(2,aNotas),lOk }, 															 ;   // bFinish  - Bloco de cï¿½digo utilizado para validar o botï¿½o "Finalizar"
                        .T.,                                              										     ;   // lPanel   - Se .T. serï¿½ criado um painel, se .F. serï¿½ criado um scrollbox
                        {||  }                                                                                       )   // bExecute - Bloco de cï¿½digo a ser executado quando o painel for selecionado

    @ 000, 000 LISTBOX oLbxNF FIELDS HEADER     	""								,;
                                                    SF2->(RetTitle("F2_FILIAL"))	,;
                                                    SF2->(RetTitle("F2_SERIE")) 	,;
                                                    SF2->(RetTitle("F2_DOC"))  		,;
                                                    SF2->(RetTitle("F2_EMISSAO"))	,;
                                                    SF2->(RetTitle("F2_CLIENTE"))	,;
                                                    SF2->(RetTitle("F2_LOJA"))	    ,;                                                
                                                    SA1->(RetTitle("A1_NOME")) 	    ;
                                        COLSIZES 	5								,;
                                                    10 								,;
                                                    15 								,;
                                                    20 								,;
                                                    20 								,;
                                                    20 								,;
                                                    15 								,;                                                
                                                    80								 ;
                            SIZE (oWizard:GetPanel(2):NWIDTH/2)-2,(oWizard:GetPanel(2):NHEIGHT/2)-2;
                            ON DBLCLICK (If(!Empty(aNotas[oLbxNF:nAt,4]),aNotas[oLbxNF:nAt,1]:=!aNotas[oLbxNF:nAt,1],aNotas[oLbxNF:nAt,1]:=oLbxNF[oLbxNF:nAt,1]),If(!aNotas[oLbxNF:nAt,1],lChkTWiz := .F., ),oLbxNF:Refresh(.f.)) OF oWizard:GetPanel(2) PIXEL

    oLbxNF:SetArray(aNotas)	
    oLbxNF:bLine        := {|| {If(aNotas[oLbxNF:nAt,1],oOK,oNO),aNotas[oLbxNF:nAt,2],aNotas[oLbxNF:nAt,3],aNotas[oLbxNF:nAt,4],aNotas[oLbxNF:nAt,5],aNotas[oLbxNF:nAt,6],aNotas[oLbxNF:nAt,7],aNotas[oLbxNF:nAt,8]}}
    oLbxNF:bRClicked 	:= { || AEVAL(aNotas,{|x|x[1]:=!x[1]}), oLbxNF:Refresh(.F.)}    	
    oLbxNF:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aNotas, {|e| IF(!Empty(e[4]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxNF:Refresh()}

    //->> Ativacao do Painel
    oWizard:Activate(   .T.,        ;   // lCenter  - Determina se o dialogo sera centralizado na tela
                        {|| .T. },  ;   // bValid   - Bloco de codigo a ser executado no encerramento do dialogo
                        {|| .T. },  ;   // bInit    - Bloco de codigo a ser executado na inicializacao do dialogo
                        {|| .T. }   )   // bWhen    - Bloco de codigo para habilitar a execucao do dialogo

    If lOk
        For nX:=1 to Len(aNotas)
            If aNotas[nX,01]
                aAdd(aDoctos,aNotas[nX])
            EndIf
        Next nX
        Processa( {|| ProcEscritur(aDoctos) },"Aguarde" ,"Escriturando Doumentos no Dootax...")
    EndIf
EndIf

Return

/*/{protheus.doc} TudoOk
*******************************************************************************************
Função de validação se os dados estão informados corretamente.
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function TudoOk(nPainel,aNotas)
Local lRet  := .F.
Local nX    := 1

Do Case
    Case nPainel == 1
        aNotas := {}
        If Empty(aRet01Param[01])
            lRet := .F.
            MsgAlert("Favor informar a Série dos Documentos a Filtrar.")
        Else
            lRet := .T.
        EndIf

        If lRet
            If Empty(aRet01Param[02]) .And. Empty(aRet01Param[03]) .And. Empty(aRet01Param[04]) .And. Empty(aRet01Param[05])
                lRet := MsgYesNo("Os Parâmetros de Filtro não foram informados."+CRLF+"A Busca pelas Notas Fiscais pode demorar consideravelmente."+CRLF+CRLF+"Deseja continuar mesmo assim ?")
            Else
                lRet := MsgYesNo("Confirma os Parâmetros para a filtragem dos Documentos Fiscais com Difal ?")
            EndIf        
        EndIf

        If lRet
            FwMsgRun(,{|| lRet := BuscaNotas(@aNotas) }, "Aguarde...","Buscando Documentos Fiscais informados no Filtro...")
            If !lRet
                MsgAlert("Nenhum Documento encontrado conforme os parâmetros informados.")                
            Else
                oLbxNF:SetArray(aNotas)	
                oLbxNF:bLine        := {|| {If(aNotas[oLbxNF:nAt,1],oOK,oNO),aNotas[oLbxNF:nAt,2],aNotas[oLbxNF:nAt,3],aNotas[oLbxNF:nAt,4],aNotas[oLbxNF:nAt,5],aNotas[oLbxNF:nAt,6],aNotas[oLbxNF:nAt,7],aNotas[oLbxNF:nAt,8]}}
                oLbxNF:bRClicked 	:= { || AEVAL(aNotas,{|x|x[1]:=!x[1]}), oLbxNF:Refresh(.F.)}    	
                oLbxNF:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, (aEval(aNotas, {|e| IF(!Empty(e[4]),e[1]:=!e[1],e[1]:=e[1])})),Nil), lRunDblClick := !lRunDblClick, oLbxNF:Refresh()}
                oLbxNF:Refresh()
            EndIf
        EndIf

    Case nPainel == 2
        For nX:=1 to Len(aNotas)
            If aNotas[nX,01]
                lRet := .T.
                Exit
            EndIf
        Next nX
        If !lRet
            MsgAlert("Nenhum Documento foi selecionado.")
        Else
            lRet := MsgYesNo("Confirma a Escrituração no Dootax, os Documentos Fiscais Selecionados ?")
        EndIf

EndCase

Return lRet

/*/{protheus.doc} BuscaNotas
*******************************************************************************************
Função de Busca de Documentos Fiscais
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function BuscaNotas(aNotas)
Local lRet   := .F.
Local cQuery := ""
Local cAlias := GetNextAlias() 
Local cSerie := GetNewPar("BO_SERMLIV","3")
Local cEstado:= GetNewPar("MV_ESTADO","")

cQuery := "SELECT DISTINCT * FROM ("                                                                        +CRLF
cQuery += "SELECT DISTINCT SF2.R_E_C_N_O_ AS RECSF2"                                                        +CRLF
cQuery += " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"                                                        +CRLF

cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"                                                  +CRLF
cQuery += "   ON SD2.D2_FILIAL  = SF2.F2_FILIAL"                                                            +CRLF
cQuery += "  AND SD2.D2_DOC     = SF2.F2_DOC"                                                               +CRLF
cQuery += "  AND SD2.D2_SERIE   = SF2.F2_SERIE"                                                             +CRLF
cQuery += "  AND SD2.D_E_L_E_T_ = ' '"                                                                      +CRLF

cQuery += " INNER JOIN "+RetSqlName("SF3")+" SF3 (NOLOCK)"                                                  +CRLF
cQuery += "   ON SF3.F3_FILIAL  = SF2.F2_FILIAL"                                                            +CRLF
cQuery += "  AND SF3.F3_NFISCAL = SF2.F2_DOC"                                                               +CRLF
cQuery += "  AND SF3.F3_SERIE   = SF2.F2_SERIE"                                                             +CRLF
cQuery += "  AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE"                                                           +CRLF
cQuery += "  AND SF3.F3_LOJA    = SF2.F2_LOJA"                                                              +CRLF
cQuery += "  AND SF3.D_E_L_E_T_ = ' '"                                                                      +CRLF
cQuery += "  AND SF3.F3_CHVNFE  = SF2.F2_CHVNFE"                                                            +CRLF
cQuery += "  AND SF3.F3_DIFAL   > 0"                                                                        +CRLF

cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"                                                     +CRLF
cQuery += "   AND SF2.F2_SERIE  = '"+aRet01Param[01]+"'"                                                    +CRLF
If !Empty(aRet01Param[03])
    cQuery += "   AND SF2.F2_DOC BETWEEN '"+aRet01Param[02]+"' AND '"+aRet01Param[03]+"'"                   +CRLF
ElseIf !Empty(aRet01Param[02])
    cQuery += "   AND SF2.F2_DOC = '"+aRet01Param[02]+"'"                                                   +CRLF
EndIf
If !Empty(aRet01Param[05])
    cQuery += "   AND SF2.F2_EMISSAO BETWEEN '"+dTos(aRet01Param[04])+"' AND '"+dTos(aRet01Param[05])+"'"   +CRLF
ElseIf !Empty(aRet01Param[04])
    cQuery += "   AND SF2.F2_EMISSAO = '"+dTos(aRet01Param[04])+"'"                                         +CRLF
EndIf
If SF2->(FieldPos("F2_XDOOTAX"))>0
    cQuery += "   AND SF2.F2_XDOOTAX = ' '"                                                                 +CRLF
EndIf
cQuery += "AND SF2.F2_CHVNFE <> ' '"                                                                        +CRLF
cQuery += "AND SF2.D_E_L_E_T_ = ' '"                                                                        +CRLF

//->> Dootax x Mercado Livre
If !Empty(cSerie)
    cQuery += "UNION "+CRLF
    cQuery += "SELECT DISTINCT SF2.R_E_C_N_O_ AS RECSF2"                                                        +CRLF
    cQuery += " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK)"                                                        +CRLF

    cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 (NOLOCK)"                                                  +CRLF
    cQuery += "   ON SD2.D2_FILIAL  = SF2.F2_FILIAL"                                                            +CRLF
    cQuery += "  AND SD2.D2_DOC     = SF2.F2_DOC"                                                               +CRLF
    cQuery += "  AND SD2.D2_SERIE   = SF2.F2_SERIE"                                                             +CRLF
    cQuery += "  AND SD2.D_E_L_E_T_ = ' '"                                                                      +CRLF

    cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"                                                     +CRLF
    cQuery += "   AND SF2.F2_SERIE  = '"+aRet01Param[01]+"'"                                                    +CRLF
    If !Empty(aRet01Param[03])
        cQuery += "   AND SF2.F2_DOC BETWEEN '"+aRet01Param[02]+"' AND '"+aRet01Param[03]+"'"                   +CRLF
    ElseIf !Empty(aRet01Param[02])
        cQuery += "   AND SF2.F2_DOC = '"+aRet01Param[02]+"'"                                                   +CRLF
    EndIf
    If !Empty(aRet01Param[05])
        cQuery += "   AND SF2.F2_EMISSAO BETWEEN '"+dTos(aRet01Param[04])+"' AND '"+dTos(aRet01Param[05])+"'"   +CRLF
    ElseIf !Empty(aRet01Param[04])
        cQuery += "   AND SF2.F2_EMISSAO = '"+dTos(aRet01Param[04])+"'"                                         +CRLF
    EndIf
    If SF2->(FieldPos("F2_XDOOTAX"))>0
        cQuery += "   AND SF2.F2_XDOOTAX = ' '"                                                                 +CRLF
    EndIf

    //->> Marcelo Celi - 10/10/2022
    cQuery += "   AND SF2.F2_EST <> '"+cEstado+"'"                                                              +CRLF

    cQuery += "AND SF2.F2_SERIE = '"+cSerie+"'"                                                                 +CRLF
    cQuery += "AND SF2.D_E_L_E_T_ = ' '"                                                                        +CRLF
EndIf
cQuery += ") AS TMP"                                                                                            +CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cAlias,.T.,.T.)

Do While (cAlias)->(!Eof())
    SF2->(dbGoto((cAlias)->RECSF2))
    SA1->(dbSetOrder(1))
    If SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
        aAdd(aNotas,{.F.,               ; // 01 - Marcação/Seleção do Registro
                     SF2->F2_FILIAL,    ; // 02 - Filial
                     SF2->F2_SERIE,     ; // 03 - Serie
                     SF2->F2_DOC,       ; // 04 - Documento                     
                     SF2->F2_EMISSAO,   ; // 05 - Data de Emissao
                     SA1->A1_COD,       ; // 06 - Codigo do Cliente
                     SA1->A1_LOJA,      ; // 07 - Loja do Cliente
                     SA1->A1_NOME}      ) // 08 - Nome do Cliente
    EndIf
    (cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

lRet := Len(aNotas)>0

Return lRet

/*/{protheus.doc} ProcEscritur
*******************************************************************************************
Escrituração no Dootax
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ProcEscritur(aDoctos)
Local nX        := 1
Local cXml      := ""
Local cConex    := "BODOOTAX"
Local cRequest  := ""
Local cResponse := ""
Local cEndPoint := "/api/v2/doodoc/pagtrib/upload/import"
Local oResponse := NIL
Local nTimeOut  := 140
Local lJob      := .F.
Local cDadConn  := ""
Local cNumPed   := ""
Local cNumVenda := ""

ProcRegua(Len(aDoctos))
For nX:=1 to Len(aDoctos)
    IncProc("Escriturando Documentos ["+Alltrim(Str(nX))+"/"+Alltrim(Str(Len(aDoctos)))+"]")
    SF2->(dbSetOrder(1))
    If SF2->(dbSeek(xFilial("SF2")+aDoctos[nX,04]+aDoctos[nX,03]))        
        cXml := GetSpedXML()

        //->> Marcelo Celi - 29/09/2022 - Uso do Mercado Livre
        If Empty(cXml)
            If SF2->(FieldPos("F2_XXMLSIT"))>0 .And. !Empty(SF2->F2_XXMLSIT)
                cXml := SF2->F2_XXMLSIT
            EndIf
        EndIf

        If Empty(cXml)
            SD2->(dbSetOrder(3))
            If SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
                cNumPed := SD2->D2_PEDIDO
                SC5->(dbSetOrder(1))
                If SC5->(dbSeek(xFilial("SC5")+cNumPed))
                    cNumVenda := PadR(SC5->C5_XIDINTG,Tamsx3("C5_XIDINTG")[01])
                    cXml := u_MaGDoc2Vtx(cNumVenda,.F.)[04]
                EndIf
            EndIf
        EndIf

        If !Empty(cXml)
            Begin Transaction
                cRequest := GetRequest(cXml)

                If ExecutConex("POST",cEndPoint,cRequest,@oResponse,nTimeOut,@cResponse,lJob,,,@cDadConn)
                    u_MAGrvLogI(cConex,,cRequest,,,"SF2",1,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO))
                    u_MAGrvLogI(cConex,"S",,cDadConn + cResponse)

                    If SF2->(FieldPos("F2_XDOOTAX"))>0
                        Reclock("SF2",.F.)
                        SF2->F2_XDOOTAX := Dtoc(Date())+" "+Time()
                        SF2->(MsUnlock())
                    EndIf
                Else
                    u_MAGrvLogI(cConex,,cDadConn+cRequest,,,"SF2",1,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO))
                    u_MAGrvLogI(cConex,"N",,cDadConn + cResponse)
                EndIf
            End Transaction
        Else
            u_MAGrvLogI(cConex,,cRequest,,,"SF2",1,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO))
            u_MAGrvLogI(cConex,"N",,"O XML da nota não foi gerado")
        EndIf
    EndIf
Next nX

Return

/*/{protheus.doc} GetIdEnt
*******************************************************************************************
Retorna o ID da Entidade do sefaz.
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetIdEnt(lUsaColab)
Local cIdEnt := ""
Local cError := ""

Default lUsaColab := .F.

If !lUsaColab
	cIdEnt := getCfgEntidade(@cError)
	If(empty(cIdEnt))
		Conout("SPED - " + cError)
	Endif
Else
	If !( ColCheckUpd() )
		Conout("SPED - UPDATE do TOTVS Colaboracao 2.0 nao aplicado. Desativado o uso do TOTVS Colaboracao 2.0")
	Else
		cIdEnt := "000000"
	Endif	 
EndIf	

Return cIdEnt

/*/{protheus.doc} GetSpedXML
*******************************************************************************************
Recupera o XML da nota.
 
@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetSpedXML()
Local oWebServ		:= NIL
Local cURLTss      	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt       	:= _cIdent
Local cTextoXML    	:= ""
Local cDocumento 	:= PadR(SF2->F2_DOC, 	TamSX3('F2_DOC')[1])
Local cSerie     	:= PadR(SF2->F2_SERIE,  TamSX3('F2_SERIE')[1])
Local dData         := SF2->F2_EMISSAO
Local lUsaPadr      := FindFunction("u_BoSpedPExp")
Local cDestino      := ""
Local nTipo         := 1
Local lMsg          := .F.

If !Empty(cDestino)
    MakeDir(cDestino)
EndIf

If lUsaPadr
    Processa({|lEnd| cTextoXML := u_BoSpedPExp(cIdEnt,cSerie,cDocumento,cDocumento,cDestino,lEnd,dData,dData,Replicate(" ",Tamsx3("A1_CGC")[01]),Replicate("Z",Tamsx3("A1_CGC")[01]),nTipo,,cSerie,,lMsg)},"Processando","Aguarde, Extraindo XML",.F.)
Else
    //Instancia a conexÃ£o com o WebService do TSS    
    oWebServ:= WSNFeSBRA():New()
    oWebServ:cUSERTOKEN        := "TOTVS"
    oWebServ:cID_ENT           := cIdEnt
    oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
    oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()

    aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())

    aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)

    oWebServ:nDIASPARAEXCLUSAO := 0
    oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
            
    //Se tiver notas
    If oWebServ:RetornaNotas()         
        If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0		
            If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                //Se tiver sido cancelada
                cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML			
            Else
                //SEnão, pega o xml normal
                cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML			
            EndIf
        EndIf
    EndIf
EndIf

Return cTextoXML

/*/{protheus.doc} ExecutConex
*******************************************************************************************
Executa a conexão com o webservice do intelipost

@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function ExecutConex(cTipo,cEndPoint,cRequest,oResponse,nTimeOut,cRetApi,lJob,cUrlAux,lDeserializ,cConexao)
Local lRet      := .F.
Local cResponse := ""
Local oWS       := NIL
Local nCodeRet  := 0
Local aHead_Api	:= {}
Local cUrl		:= GetNewPar("BO_URLDOOT","https://hom.app.dootax.com.br")
Local cToken    := GetNewPar("BO_TOKDOOT","7c8da40d-2c5b-4851-87fe-523555ff726a")
Local cTenant   := GetNewPar("BO_TENDOOT","bombay")

Default cTipo       := ""
Default cEndPoint   := ""
Default cRequest    := ""
Default nTimeOut    := 140
Default lJob        := .F.
Default cUrlAux     := ""
Default lDeserializ := .T.

aAdd(aHead_Api,'content-type: application/json')
aAdd(aHead_Api,'Accept: application/json')
aAdd(aHead_Api,'oauth-token: '+cToken)
aAdd(aHead_Api,'tenant-alias: '+cTenant)

If !Empty(cUrlAux)
	cUrl := cUrlAux	
EndIf

cUrl := AllTrim(cUrl)
If Right(cUrl,1)=="\" .Or. Right(cUrl,1)=="/"
	cUrl := Left(cUrl,Len(cUrl)-1)
EndIf

cConexao := "URL: "+cUrl+CRLF
cConexao += "EndPoint: "+cEndPoint+CRLF+CRLF
cConexao += "Header: content-type: application/json"+CRLF
cConexao += "Header: Accept: application/json"+CRLF
cConexao += "Header: oauth-token: "+cToken+CRLF
cConexao += "Header: tenant-alias: "+cTenant+CRLF+CRLF
cConexao += "Response: "+CRLF+CRLF

oWS := FWRest():New(cUrl)
oWS:nTimeout := nTimeOut
oWS:SetPath(cEndPoint)

cRetApi := ""
cTipo   := Alltrim(Upper(cTipo))
Do Case
    Case cTipo == "POST"
        oWS:SetPostParams(cRequest) 
        If oWS:Post(aHead_Api)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := oWS:GetHTTPCode()
        If Valtype(nCodeRet)=="C"
            nCodeRet := Val(nCodeRet)
        Else
            nCodeRet := 0
        EndIf
        cResponse := oWS:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse        
        If !lRet
            cRetApi += CRLF+CRLF+oWS:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Case cTipo == "GET"
        If oWS:Get(aHead_Api)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := oWS:GetHTTPCode()
        If Valtype(nCodeRet)=="C"
            nCodeRet := Val(nCodeRet)
        Else
            nCodeRet := 0
        EndIf
        cResponse := oWS:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse
        If !lRet
            cRetApi += CRLF+CRLF+oWS:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Case cTipo == "PUT"
        If oWS:Put(aHead_Api,cRequest)
            lRet := .T.
        Else
            lRet := .F.        
        EndIf
        nCodeRet := oWS:GetHTTPCode()
        If Valtype(nCodeRet)=="C"
            nCodeRet := Val(nCodeRet)
        Else
            nCodeRet := 0
        EndIf
        cResponse := oWS:GetResult()
        If Valtype(cResponse)<>"C"
            cResponse := ""
        EndIf
        cRetApi := cResponse
        If !lRet
            cRetApi += CRLF+CRLF+oWS:GetLastError() 
        EndIf
        If lDeserializ
            FWJsonDeserialize(cResponse,@oResponse)
        EndIf

    Otherwise
        lRet := .F.
        oResponse := NIL

EndCase

FreeObj(oWS)
If (nCodeRet >= 200 .And. nCodeRet <= 299) .Or. (Upper(Alltrim(cResponse)) == "TRUE")
    lRet := .T.
Else    
    If lDeserializ .And. Valtype(oResponse) <> "O"
        lRet := .F.
    EndIf
EndIf

Return lRet

/*/{protheus.doc} GetRequest
*******************************************************************************************
Retorna a request da operação de escrituração.

@author: Marcelo Celi Marques
@since: 09/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
Static Function GetRequest(cXml)
Local cRequest  := ""
Local cNomeArq  := ""
Local cConteudo := ""

cNomeArq  := Alltrim(SF2->F2_FILIAL)+"_"+Alltrim(SF2->F2_DOC)+"_"+Alltrim(SF2->F2_SERIE)+".xml"
cConteudo := Encode64(cXml)

cRequest := '{'                                 +CRLF
cRequest += '    "filename": "'+cNomeArq+'",'   +CRLF
cRequest += '    "content": "'+cConteudo+'"'    +CRLF
cRequest += '}'                                 +CRLF

Return cRequest

/*/{protheus.doc} BoDec64Xml
*******************************************************************************************
Decodifica da base64 em xml.

@author: Marcelo Celi Marques
@since: 19/04/2022
@param: 
@return:
@type function: Estatico
*******************************************************************************************
/*/
User Function BoDec64Xml()
Local cDestino  := ""
Local cResquest := (Tb_LgMon)->&(Tb_LgMon+"_REQUES")
Local cArquivo  := ""
Local cXmlEnc64 := ""
Local cPastDecod:= ""

Public _oRequest  := NIL

If MsgYesNo("Este programa deverá decodificar o arquivo xml encaminhado ao Dootax em uma pasta local, informada pelo usuário."+CRLF+"Deseja continuar com a decodificação ?")
    cDestino  := Alltrim( cGetFile("Diretorios", "Diretorio Destino da Exportação",,,.T.,nOR( GETF_LOCALHARD , GETF_RETDIRECTORY , GETF_NETWORKDRIVE ),.F. ) )
    If !Empty(cDestino)
        FWJsonDeserialize(cResquest,@_oRequest)
        If Type("_oRequest:Filename")<>"U" .And. Valtype(_oRequest:Filename)=="C" .And. !Empty(_oRequest:Filename)    
            cArquivo := _oRequest:Filename
        EndIf
        If Type("_oRequest:content")<>"U" .And. Valtype(_oRequest:content)=="C" .And. !Empty(_oRequest:content)    
            cXmlEnc64 := _oRequest:content
        EndIf
        If !Empty(cArquivo) .And. !Empty(cXmlEnc64)
            cDestino   := Alltrim(cDestino)
            cDestino   += If(Right(cDestino,1)=="\","","\")
            cPastDecod := StrTran(cDestino,"\","\\")
            Decode64(cXmlEnc64,cPastDecod + cArquivo,.F.)
            If File(cDestino + cArquivo)
                MsgAlert("Arquivo "+cArquivo+" decodificado na pasta: "+CRLF+cDestino)
            Else
                MsgAlert("Ocorreram erros na decodificação do arquivo "+cArquivo)
            EndIf
        Else
            MsgAlert("Ocorreram erros na execução da rotina.")
        EndIf
    EndIf
EndIf

Return
