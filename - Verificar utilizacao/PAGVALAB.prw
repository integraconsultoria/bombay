/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PAGVALAB � Autor �Rafael Gama-Oficina1� Data �  01/02/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para calcular o valor dos titulos somando os titulos���
���          � com valores de abatimentos (AB-)							  ���
�������������������������������������������������������������������������͹��
���Uso       � SISPAG -  (EXECBLOCK("PAGVALAB",.F.,.F.))  	      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function PAGVALAB() 

Local nValTot	:= 0

//SomaAbat(cPrefixo,cNumero,cParcela,cCart,nMoeda,dData,cFornCli,cLoja,cFilAbat,dDataRef)

nValTot := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1)
       
nValTot := STRZERO((SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)-nValTot)*100,15) 



Return(nValTot)