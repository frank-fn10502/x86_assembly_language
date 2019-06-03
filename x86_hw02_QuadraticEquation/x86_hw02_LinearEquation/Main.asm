INCLUDE Irvine32.inc

TITLE LinearEquation (main.asm)

.386
;.model flat ,stdcall ;Irvine32 ���]�w�F
.stack 4096
ExitProcess  PROTO ,dwExitCodw : DWORD
intToString  PROTO ,Integer : SDWORD ,printStrPos : DWORD ,sign : BYTE
concatStr    PROTO ,mainStrPos : DWORD ,secondStrPos : DWORD
calPosPart   PROTO ,SquareRootNum : DWORD
calSuareRoot PROTO ,SquareRootNum : DWORD
calDivFloat  PROTO ,num1 : DWORD ,num2 : DWORD ,pFloat : PTR DWORD

printFloatNumber PROTO ,pFloat : DWORD

Float STRUCT
	num   SDWORD 0
	floatNum SBYTE 5 dup(0)  ;�p���I�᭱���Ʀr
Float ENDS

LinearEquation STRUCT
	XA SDWORD 0
	XB SDWORD 0
	XC SDWORD 0
LinearEquation ENDS

.data
	InputText BYTE "�п�JA B C�T�ӰѼ�" ,0

	equation  LinearEquation <>

	Buffer		BYTE 1000 dup(0)
	equationStr BYTE 100  dup(0)
	resultStr   BYTE 100  dup(0)

	squared			BYTE "x^2" ,0
	linear			BYTE "x"	,0
	equationEnd		BYTE " = 0" ,0
	plusStr			BYTE " + " ,0
	minusStr		BYTE " - " ,0
	resultRoot1Str  BYTE "x1 = " ,0
	resultRoot2Str	BYTE "x2 = " ,0
	dot 		    BYTE "." ,0
	virtualRoot		BYTE "i" ,0
	noResultStr		BYTE "�L��" ,0
	unliResultStr 	BYTE "�L���h��" ,0

	prePart    Float <>
	posPart    Float <>
	resultRoot Float <>

.code
	main PROC
		Top:
		call clrscr

		call setEquation
		call printEquation
		call calEquation

		call waitMsg
		jmp Top
		
		INVOKE ExitProcess, 0
	main ENDP

	setEquation PROC
		mov edx ,offset Buffer	;Ū���r��
		mov ecx ,SIZEOF Buffer	;
		call ReadString			;

		mov esi ,OFFSET equation
		mov ecx ,3
		L1:
			call StringToInt
			mov  [esi] ,eax

			add esi ,TYPE DWORD	
		loop L1

		ret
	setEquation ENDP

	printEquation PROC
		first  EQU 3
		strPos EQU DWORD PTR [ebp-4]

		enter 4 ,0

		mov esi ,OFFSET equation
		mov strPos ,OFFSET equationStr

		mov ecx ,first
		L1:
			cmp ecx ,first
			je setNum
				cmp SDWORD PTR [esi] ,0
				jge PlusSign
					INVOKE concatStr ,strPos ,OFFSET minusStr
					mov strPos ,ebx
					jmp setNum
				PlusSign:
					INVOKE concatStr ,strPos ,OFFSET plusStr
					mov strPos ,ebx		
		setNum:
			cmp ecx ,first
			jne JustNum
				INVOKE intToString ,[esi] ,strPos ,1
				jmp PosLatter
			JustNum:
				INVOKE intToString ,[esi] ,strPos ,0
		
		PosLatter:
			call concatPosLatter

			mov strPos ,ebx
			add esi ,TYPE DWORD
		loop L1
			
		mov edx ,OFFSET equationStr		;�L�X�r��
		call WriteString
		call Crlf

		leave
		ret
	printEquation ENDP

	concatPosLatter PROC
		cmp ecx ,first
		jne ELSE1
			INVOKE concatStr ,ebx ,OFFSET squared
			jmp Done

		ELSE1:
			cmp ecx ,2
			jne ELSE2
				INVOKE concatStr ,ebx ,OFFSET linear
				jmp Done

		ELSE2:	INVOKE concatStr ,ebx ,OFFSET equationEnd

		Done: 
		ret
	concatPosLatter ENDP

	calEquation PROC
		enter 4 ,0 ;�i�ण��
		push eax
		push ebx
		
		cmp equation.XA ,0
		je Formula2
			call printFormula
			jmp Done
		Formula2:
			mov DWORD PTR [ebp-4] ,0

			mov eax ,equation.XC
			imul eax ,-1
			cmp eax ,0
			jge ELSE1
				xor DWORD PTR [ebp-4] ,1	
				imul eax ,-1
						
			ELSE1:
			mov ebx ,equation.XB
			cmp ebx ,0
			jg Compute
			je EndELSE
				xor DWORD PTR [ebp-4] ,1
				imul ebx ,-1
			Compute:
				INVOKE calDivFloat ,eax ,ebx ,OFFSET resultRoot
				cmp DWORD PTR [ebp-4] ,1
				jne Next
					mov eax ,resultRoot.num
					imul eax ,-1
					mov resultRoot.num ,eax
					mov ecx ,LENGTHOF resultRoot.floatNum
					mov esi ,OFFSET resultRoot.floatNum
					Negitive:
						mov  al ,SBYTE PTR [esi]
						imul eax ,-1
						mov SBYTE PTR [esi] ,al

						add esi ,TYPE BYTE
					loop Negitive					
			
			Next:
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot1Str
			INVOKE intToString ,resultRoot.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF resultRoot.floatNum
			mov esi ,OFFSET resultRoot.floatNum
			L1:
				INVOKE intToString ,BYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L1
			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf

			jmp Done

			EndELSE:
				cmp equation.XC ,0
				jne noResult
					mov edx ,OFFSET unliResultStr;�L�X�r��
					call WriteString
					call Crlf			
					jmp Done	
				noResult:
					mov edx ,OFFSET noResultStr     ;�L�X�r��
					call WriteString
					call Crlf
		Done:		
		pop ebx
		pop eax
		leave
		ret
	calEquation ENDP

	printFormula PROC
		mov eax ,equation.XB
		imul eax ,equation.XB
		mov ebx ,4
		imul ebx ,equation.XA
		imul ebx ,equation.XC
		sub eax ,ebx
	
		call calPrePart			;�p�� -b / 2a(�e�b��������)

		cmp eax ,0				;b^2 -4ac
		jne ELSE1
			;�]�w��Ӹ�(�L�X)	;b^2 -4ac = 0 �����o���Ӹ�
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot1Str
			INVOKE intToString ,prePart.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF prePart.floatNum
			mov esi ,OFFSET prePart.floatNum
			L1:
				INVOKE intToString ,BYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L1
			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf

			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot2Str
			INVOKE intToString ,prePart.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF prePart.floatNum
			mov esi ,OFFSET prePart.floatNum
			L2:
				INVOKE intToString ,BYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L2
			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf

			jmp Done

		ELSE1:
		jl  ELSE2			
			;b^2 -4ac > 0 ��ӹ�Ƹ� �S��i	
			INVOKE calPosPart ,eax	 ;�p�� �ڸ� / 2a 
			call addTwoFloat

			;�]�w��Ӹ�(�L�X)
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot1Str
			INVOKE intToString ,resultRoot.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF resultRoot.floatNum
			mov esi ,OFFSET resultRoot.floatNum
			L1_2:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L1_2

			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf
			;//////////////////////////////////////////////////
			call plusMinusOne
			call addTwoFloat
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot2Str
			INVOKE intToString ,resultRoot.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF resultRoot.floatNum
			mov esi ,OFFSET resultRoot.floatNum
			L2_2:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L2_2

			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf

			jmp Done

		ELSE2:
			;����t���h��(�᭱����i) ;b^2 -4ac < 0 ��ӵ�Ƹ� ��i
			imul eax ,-1
			INVOKE calPosPart ,eax	 ;�p�� �ڸ� / 2a

			;�]�w��Ӹ�(�L�X) ;INVOKE printFloatNumber ,OFFSET prePart
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot1Str		
			INVOKE intToString ,prePart.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF prePart.floatNum
			mov esi ,OFFSET prePart.floatNum
			L1_3:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L1_3

			cmp posPart.num ,0
			jge plusSign
				INVOKE concatStr ,ebx ,OFFSET plusStr
			plusSign:
				INVOKE concatStr ,ebx ,OFFSET minusStr

			INVOKE intToString ,posPart.num ,ebx ,0
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF posPart.floatNum
			mov esi ,OFFSET posPart.floatNum
			L1_3_1:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L1_3_1
			INVOKE concatStr ,ebx,OFFSET virtualRoot

			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf
			;//////////////////////////////////////////////////
			INVOKE concatStr ,OFFSET resultStr ,OFFSET resultRoot2Str		
			INVOKE intToString ,prePart.num ,ebx ,1
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF prePart.floatNum
			mov esi ,OFFSET prePart.floatNum
			L2_3:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L2_3

			call plusMinusOne
			cmp posPart.num ,0
			jge plusSign1
				INVOKE concatStr ,ebx ,OFFSET minusStr
			plusSign1:
				INVOKE concatStr ,ebx ,OFFSET plusStr

			INVOKE intToString ,posPart.num ,ebx ,0
			INVOKE concatStr ,ebx ,OFFSET dot
			mov ecx ,LENGTHOF posPart.floatNum
			mov esi ,OFFSET posPart.floatNum
			L2_3_1:
				INVOKE intToString ,SBYTE PTR [esi] ,ebx ,0
				add esi,TYPE BYTE
			loop L2_3_1
			INVOKE concatStr ,ebx,OFFSET virtualRoot

			mov edx ,OFFSET resultStr	;�L�X�r��
			call WriteString
			call Crlf
		Done:
		ret
	printFormula ENDP

	plusMinusOne PROC
		push eax
		push ecx
		push esi

		mov eax ,posPart.num
		imul eax ,-1
		mov posPart.num ,eax
		mov ecx ,LENGTHOF posPart.floatNum
		mov esi ,OFFSET posPart.floatNum
		Negitive:
			mov  al ,SBYTE PTR [esi]
			imul eax ,-1
			mov SBYTE PTR [esi] ,al

			add esi ,TYPE BYTE
		loop Negitive

		pop eax
		pop ecx
		pop esi
		ret
	plusMinusOne ENDP


	addTwoFloat PROC
		enter 4,0
		push ecx
		push esi
		push eax
		push ebx

		mov DWORD PTR [ebp-4] ,0 ;�i��

		mov ecx ,LENGTHOF prePart.FloatNum
		mov esi ,ecx
		sub esi ,1
		L1:
			cmp prePart.FloatNum[esi] ,0
			jge Positive1
				movsx ebx ,prePart.FloatNum[esi]		
				jmp ToPosPart
			Positive1:
				movzx ebx ,prePart.FloatNum[esi]	
				jmp ToPosPart
			
			ToPosPart:
			cmp posPart.FloatNum[esi] ,0
			jge Positive2	
				movsx eax ,posPart.FloatNum[esi]	
				jmp Compute
			Positive2:
				movzx eax ,posPart.FloatNum[esi]

			Compute:
			add ebx ,eax
			add ebx ,SDWORD PTR [ebp-4]						;�i��

			cmp ebx ,10
			jl ELSE1
				mov SDWORD PTR [ebp-4] ,1
				sub ebx ,10			
			ELSE1:	
			cmp ebx ,-10
			jg Next
				mov SDWORD PTR [ebp-4] ,-1
				sub ebx ,-10

			Next:
				mov resultRoot.FloatNum[esi] ,bl
				mov SDWORD PTR [ebp-4] ,0	
				dec esi
		loop L1

		mov ebx ,prePart.num
		add ebx ,posPart.num
		add ebx ,SDWORD PTR [ebp-4]

		mov resultRoot.num ,ebx

		pop ebx
		pop eax
		pop esi
		pop ecx
		leave
		ret
	addTwoFloat ENDP

	calPrePart PROC
		enter 4 ,0
		push eax
		push ecx
		push ebx

		mov DWORD PTR [ebp-4] ,1

		mov eax ,equation.XB
		cmp equation.XB ,0
		jge ELSE1
			xor DWORD PTR [ebp-4] ,1			
			imul eax ,-1

		ELSE1:
		mov ebx ,equation.XA
		cmp equation.XA ,0
		jge CalDiv
			xor DWORD PTR [ebp-4] ,1		
			imul ebx ,-1
		
		CalDiv:
			imul ebx ,2
			INVOKE calDivFloat ,eax ,ebx ,OFFSET prePart ;�p��Ĥ@�������B�I��

		cmp DWORD PTR [ebp-4] ,1		;�O�_�O �t��
		jne Done
			mov eax ,prePart.num
			imul eax ,-1
			mov prePart.num ,eax

			mov ecx ,LENGTHOF prePart.floatNum
			mov ebx ,0
			L1:
				movzx eax ,prePart.floatNum[ebx]
				imul eax ,-1
				mov prePart.floatNum[ebx] ,al

				inc ebx
			loop L1

		Done:
		pop ebx
		pop ecx
		pop eax
		leave
		ret
	calPrePart ENDP

	calPosPart PROC ,SquareRootNum : DWORD
		sub esp ,4
		push eax
		push ebx
		push ecx

		mov DWORD PTR [ebp-4] ,0

		mov ebx ,equation.XA
		cmp equation.XA ,0
		jge  ELSE1
			xor DWORD PTR [ebp-4] ,1			
			imul ebx ,-1

		ELSE1:
		INVOKE calSuareRoot ,SquareRootNum			 ;�^�� eax ���
		imul ebx ,2
		INVOKE calDivFloat ,eax ,ebx ,OFFSET posPart ;�p��ĤG�������B�I��

		cmp DWORD PTR [ebp-4] ,1					 ;�O�_�O �t��
		jne Done
			mov eax ,posPart.num
			imul eax ,-1
			mov posPart.num ,eax

			mov ecx ,LENGTHOF posPart.floatNum
			mov ebx ,0
			L1:
				movzx eax ,posPart.floatNum[ebx]
				imul eax ,-1
				mov posPart.floatNum[ebx] ,al

				inc ebx
			loop L1			
		Done:	
		pop ecx	
		pop ebx
		pop eax
		ret
	calPosPart ENDP

	calSuareRoot PROC ,SquareRootNum : DWORD
		push ebx
		push ecx
		mov eax ,1
		mov ebx ,1

		cmp SquareRootNum ,1
		mov ecx ,SquareRootNum
		je Done		
			Top:
				add ebx ,1
				mov ecx ,ebx
				imul ecx ,ecx

				cmp ecx ,SquareRootNum
				jae Done

			jmp Top

		Done:
		sub ebx ,1
		mov eax ,ebx
		pop ecx
		pop ebx
		ret
	calSuareRoot ENDP

	calDivFloat PROC ,num1 : DWORD ,num2 : DWORD ,pFloat : PTR DWORD	;mun1(���l) mun2(�������O2a)
		push eax
		push ebx
		push ecx
		push esi

		mov esi ,pFloat

		mov edx ,0
		mov eax ,num1
		mov ebx ,num2	
		;imul ebx ,2
		div ebx

		mov (Float PTR [esi]).num ,eax  ;��Ƴ���
		add esi ,TYPE SDWORD

		mov ecx ,TYPE prePart.floatNum		;�p���I��X��
		L1:									;�p��p��
			imul edx ,10
			mov eax ,edx
			mov edx ,0
			div ebx

			mov BYTE PTR [esi] ,al			;���o��
			add esi ,TYPE prePart.floatNum
		loop L1

		pop esi
		pop ecx
		pop ebx
		pop eax
		ret
	calDivFloat ENDP

;=========�q��================================================
	StringToInt PROC
		enter 4 ,0
		push ecx
		mov DWORD PTR [ebp-4] ,1
		mov eax,0

		call intStart					;�T�O��}�l�|�O������

		cmp BYTE PTR [edx] ,'-'
		jne Top
		mov DWORD PTR [ebp-4] ,-1
		inc edx

		Top:
			movzx ecx ,BYTE PTR [edx]	;edx�s��"�r��"
			inc edx

			cmp ecx ,'0'
			jb 	Done
			cmp ecx ,'9'
			ja  Done

			sub	 ecx ,'0'
			imul eax ,10
			add  eax ,ecx
		jmp Top

		Done: 
			imul eax ,DWORD PTR [ebp-4]

			pop ecx
			leave
			ret
	StringToInt ENDP

	intStart PROC
		Top:
			movzx ecx ,BYTE PTR [edx]	;edx�s��"�r��"
			
			cmp ecx ,'-'
			jne CheckNum
				cmp BYTE PTR [edx+1] ,'0'
				jb Next
				cmp BYTE PTR [edx+1] ,'9'
				ja Next
				jmp Done

		CheckNum:
			cmp ecx ,'0'
			jb Next
			cmp ecx ,'9'
			ja Next
			jbe Done

		Next:
			inc edx
		jmp Top		

		Done: 
			ret
	intStart ENDP

	intToString PROC ,Integer : SDWORD ,printStrPos : DWORD ,sign : BYTE ;�^�� ebx
		sub esp ,4*3
		push ecx
		push esi
		mov DWORD PTR [ebp-8] ,0


		cmp SDWORD PTR Integer ,0		
		jge GetNum
			cmp sign ,1
			jne JustNum
				mov  DWORD PTR [ebp-8] ,1

			JustNum:
				mov  eax ,Integer
				imul eax ,-1 
				mov  Integer ,eax

		GetNum:
			mov DWORD PTR [ebp-12] ,0
			Top:
				mov edx ,0
				mov eax ,Integer
				mov DWORD PTR [ebp-4] ,10
				div DWORD PTR [ebp-4]

				mov Integer ,eax	  ;��
				add edx ,'0'		  ;�l��
				push edx			  ;�s��
				inc DWORD PTR [ebp-12];push�h�֦�� �i�h

				cmp Integer ,0
				je  Done
			jmp Top

		Done:
			mov ecx ,DWORD PTR [ebp-12]
			mov eax ,printStrPos	;��m��eax

			cmp DWORD PTR [ebp-8] ,1
			jne L1
				mov BYTE PTR [eax] ,'-'
				add eax ,TYPE BYTE

			L1:
				pop edx
				mov [eax] ,edx

				add eax ,TYPE BYTE
			loop L1

		mov ebx ,eax		;�r���}	 
		pop esi
		pop ecx
		ret
	intToString ENDP

	concatStr PROC ,mainStrPos : DWORD ,secondStrPos : DWORD ;�^�� ebx
		push esi
		push eax
		push edx

		mov esi ,mainStrPos
		mov eax ,secondStrPos

		Top:
			mov dl ,BYTE PTR [eax]
			mov BYTE PTR [esi] ,dl

			cmp dl ,0
			je Done

			inc esi
			inc eax
		jmp Top

		Done:
			mov ebx ,esi

		pop edx
		pop eax
		pop esi
		ret
	concatStr ENDP

END main
