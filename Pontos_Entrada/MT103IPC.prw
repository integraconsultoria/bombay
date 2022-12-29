User Function MT103IPC()

_xx := Len(aCols)
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XDESCR" })]:=SC7->C7_DESCRI

Return
