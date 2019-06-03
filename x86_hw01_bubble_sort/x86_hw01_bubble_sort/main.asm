INCLUDE Irvine32.inc

TITLE Bubble Sort (main.asm)

.386
;.model flat, stdcall ;Irvine32 ���]�w�F
.stack 4096
ExitProcess PROTO, dwExitCodw:DWORD

Student STRUCT
	Id		DWORD 0
	Chinese DWORD 0
	English DWORD 0
	Math	DWORD 0
	Total   DWORD 0
	Rank	DWORD 0
Student ENDS

setOneStudent	PROTO ,SNo : DWORD
setInputNo		PROTO ,SNo : DWORD
typeSetInput	PROTO ,SNo : DWORD ,InputCharNum : DWORD ,pStudent : DWORD
exchange		PROTO ,stu1 : DWORD
printOneStudent PROTO ,pStudent : DWORD ,printItemNum : DWORD
numToString		PROTO ,detailNum : DWORD ,detailStr : DWORD
writeStr		PROTO ,pString : DWORD

count = 6

.data
	InputText   BYTE "�п�J 6 �Ӿǥ͸��" ,0
	InputTitle  BYTE "�s��  �Ǹ�      ���  �^��  �ƾ�" ,0
	TableTitle  BYTE "�Ǹ�      ���  �^��  �ƾ�  �`��  �ƦW",0

	students   Student count DUP(<222 ,22 ,23 ,24 ,25 ,1>)
	resultRank DWORD   count DUP(0)

	Buffer		BYTE 1000 dup(0)
	InputNo		BYTE 7 dup(0)
	StuDetail	BYTE LENGTH TableTitle + 1 dup(0) ;
	
.code
	main PROC
		Top:
			call clrscr
			call initReultRank
			call setStudents
			call BubbleSort
			call setRank
			call printResult
			call WaitMsg
		jmp Top

		INVOKE ExitProcess, 0
	main ENDP

	;=========�]�w��ƪ���l���ᶶ��================================
	initReultRank PROC
		mov ecx ,count
		mov eax ,OFFSET students
		mov esi ,0
		L1:
			mov resultRank[esi],eax

			add esi ,TYPE resultRank
			add eax ,TYPE Student
		loop L1

		ret
	initReultRank ENDP

	;=========�]�w�ǥ͸��=========================================
	setStudents PROC
		stuNo EQU DWORD PTR [ebp-4]

		enter 4,0
		INVOKE writeStr ,OFFSET InputText
		INVOKE writeStr ,OFFSET InputTitle

		mov ecx ,LENGTHOF students
		mov esi ,OFFSET students
		mov stuNo ,1
		KeyIn:
			INVOKE setOneStudent ,stuNo		;�ƨ禡 �B�z�r��

			add esi ,SIZEOF Student
			inc stuNo
		loop KeyIn

		call Crlf
		leave	
		ret
	setStudents ENDP

	setOneStudent PROC ,SNo : DWORD
		stuTotal EQU DWORD PTR [ebp-4]
		startPos EQU DWORD PTR [ebp-8]
		InputNum EQU DWORD PTR [ebp-12]

		sub esp ,4*3
		pushad	
		mov stuTotal ,0			;Student.Total
		mov startPos ,esi		;����Student[?]����}
			
		INVOKE setInputNo ,SNo	;�s��

		mov edx ,offset Buffer	;Ū���r��
		mov ecx ,SIZEOF Buffer	;
		call ReadString			;
		mov InputNum ,eax		;���s��J���r���ƶq
	
		mov ecx,4				;��J���|�����
		L1:
			call StringToNum	;���X�Ĥ@�ռƦr(eax)
			mov  [esi] ,eax		;�[��������ܼ�

			cmp ecx,4			;�Ĥ@��Id���Υ[
			je Next				;

			add stuTotal ,eax

			Next: add esi ,TYPE DWORD	
		loop L1		
	
		INVOKE typeSetInput	,SNo ,InputNum ,startPos
		
		mov esi ,startPos
		mov eax ,stuTotal
		mov (Student PTR [esi]).Total ,eax
		
		popad
		ret
	setOneStudent ENDP

	setInputNo PROC ,SNo : DWORD
		push esi
		push ecx

		push OFFSET InputNo
		push SNo
		call numToString

		mov ecx ,6
		sub ecx ,eax	;�Ʀr�� �X���
		mov esi ,ebx	;InputNo����}
		L2:
			mov BYTE PTR [esi] ,' '
				
			inc esi
		loop L2
		mov BYTE PTR [esi] ,0

		mov edx ,OFFSET InputNo	;
		call WriteString		;��X�s��

		pop ecx
		pop esi
		ret
	setInputNo ENDP

	;���s�ƪ�
	typeSetInput PROC ,SNo :DWORD ,InputCharNum : DWORD ,pStudent : DWORD
		printStrPos  EQU DWORD PTR [ebp-4]

		sub esp ,4

		mov dh ,1			;(2-1)
		add dh ,BYTE PTR SNo
		mov dl ,6			;(7-1)
		call Gotoxy

		INVOKE printOneStudent ,pStudent ,4
		
		cmp InputCharNum ,22
		jbe Done

		sub InputCharNum ,22
		mov ecx ,InputCharNum
		L3:
			mov al ,' '
			call writeChar
		loop L3

		Done: call Crlf
		ret
	typeSetInput ENDP

	StringToNum PROC
		push ecx
		mov eax,0

		call numberStart				;�T�O��}�l�|�O�Ʀr
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
			pop ecx		
			ret
	StringToNum ENDP

	numberStart PROC
		Top:
			movzx ecx ,BYTE PTR [edx]	;edx�s��"�r��"
			
			cmp ecx,'0'
			jb Next

			cmp ecx,'9'
			ja Next
			jbe Done

			Next:
				inc edx
		jmp Top		

		Done: ret
	numberStart ENDP

	;==========�Ƨ�===============================================
	BubbleSort PROC	 ;�]�w�`������ ���b�e��
		isChange   EQU DWORD PTR [ebp-4]
		curStudent EQU DWORD PTR [ebp-8]
		student1   EQU eax
		student2   EQU ebx
		
		mov eax ,LENGTHOF students
		cmp eax ,1							;�ǥͼƥحn�j�� 1
		je DontSort							;

		enter 4*2,0							;2�Ӱϰ��ܼ�
		mov lastTotal ,0
		mov stuRank ,1
		mov ecx ,LENGTHOF students - 1		;�}�C�Ӽ�-1
		
		L1:
			mov isChange,True				;�w�]���ƧǦn

			push ecx
			mov esi ,0
			mov curStudent ,0

			L2:
				mov eax		 ,resultRank[esi]
				mov student1 ,(Student PTR [eax]).Total

				mov ebx		 ,resultRank[esi + TYPE resultRank]
				mov student2 ,(Student PTR [ebx]).Total

				cmp student1 ,student2				;
				ja Done								;�e > �� ���Υ洫(�j->�p)

				INVOKE exchange	,curStudent			;�I�s �ƨ禡
				mov isChange ,False					;���@���洫 �N��S�ƧǦn
							
				Done: 
					add esi ,TYPE resultRank		;����U�@�Ӧ�m
					inc DWORD PTR curStudent
			loop L2

			pop ecx
			cmp isChange ,True							;�S�����L��l �N��Ƨǧ���
			je Break									;
		loop L1
		Break: leave
						
		DontSort: ret
	BubbleSort ENDP

	exchange PROC ,stu1 : DWORD
		sub esp ,4*2					;2�Ӱϰ��ܼ�
		pushad
		
		mov ecx ,stu1					;[ebp+8]
		imul ecx ,TYPE resultRank		;�Ĥ@��student

		mov edx ,ecx					;
		add edx ,TYPE resultRank		;�ĤG��

		mov eax,resultRank[ecx]
		mov ebx,resultRank[edx]

		mov resultRank[ecx],ebx
		mov resultRank[edx],eax

		popad	
		ret
	exchange ENDP

	;==========�ƦW===============================================
	setRank PROC
		lastTotal  EQU DWORD PTR [ebp-4]
		stuRank    EQU DWORD PTR [ebp-8] 

		enter 4*2 ,0	;2���ܼ�

		mov esi ,0
		mov ecx ,count

		mov lastTotal ,0
		mov stuRank ,0
		L1:
			mov	ebx ,resultRank	[esi]
			mov eax ,(Student PTR [ebx]).Total
			cmp lastTotal ,eax
			je setWithoutAdd
				
			add stuRank ,1

			setWithoutAdd:
				mov	eax ,stuRank
				mov (Student PTR [ebx]).Rank ,eax

				mov	eax ,(Student PTR [ebx]).Total
				mov lastTotal ,eax

			add esi ,TYPE resultRank		;����U�@�Ӧ�m
		loop L1

		leave
		ret
	setRank ENDP
	
	;=========�L�X================================================
	;�ƪ�
	printResult PROC
		INVOKE writeStr ,OFFSET TableTitle

		mov ecx ,LENGTHOF students
		mov esi ,0
		Print:		
			INVOKE printOneStudent ,resultRank[esi] ,6
			call Crlf

			add esi ,TYPE resultRank
		loop Print

		call Crlf
		ret
	printResult ENDP

	;�Ǹ����� < 10
	printOneStudent PROC ,pStudent : DWORD ,printItemNum : DWORD
		printStrPos  EQU DWORD PTR [ebp-4]

		sub esp ,4
		push esi
		push ecx

		mov ecx ,printItemNum ;
		mov esi ,pStudent
		mov printStrPos ,OFFSET StuDetail
		L1:
			INVOKE numToString ,DWORD PTR [esi] ,printStrPos	
			add esi ,TYPE DWORD

			push ecx
			push esi

			cmp ecx ,printItemNum	;�Ĥ@��
			jne Else_1
				mov ecx ,10
				jmp Typeset

			Else_1:
			cmp ecx ,1
			jne Else_2
				mov ecx ,4
				jmp Typeset

			Else_2: 
				mov ecx ,6
				
			Typeset:
				sub ecx ,eax	;�Ʀr�� �X���
				mov esi ,ebx	;printStrPos����}
				L2:
					mov BYTE PTR [esi] ,' '			
					inc esi
				loop L2		
				mov BYTE PTR [esi] ,0 ;		
				mov printStrPos ,esi

			pop esi
			pop ecx
		loop L1
		

		mov edx ,OFFSET StuDetail 		;�L�X�r��
		call WriteString

		pop ecx
		pop esi
		ret
	printOneStudent  ENDP

	;=========�q��================================================
	numToString PROC ,detailNum : DWORD ,detailStr : DWORD
		local_x EQU DWORD PTR [ebp-4]
		local_y EQU DWORD PTR [ebp-8]

		sub esp ,8
		push ecx
		push esi

		mov local_y ,0
		Top:

			mov edx ,0
			mov eax ,detailNum
			mov local_x ,10
			div local_x

			mov detailNum ,eax	  ;��
			add edx ,'0'		  ;�l��
			push edx			  ;�s��
			inc local_y			  ;push�h�֦�� �i�h

			cmp DWORD PTR detailNum ,0
			je  Done		
		jmp Top

		Done:
			mov ecx ,local_y
			mov eax ,[detailStr]
			L1:
				pop edx
				mov [eax] ,edx

				add eax ,TYPE BYTE
			loop L1
		mov ebx ,eax		;�r���}
		mov eax ,local_y	;�Ʀr���
		 
		pop esi
		pop ecx
		ret
	numToString ENDP

	writeStr PROC ,pString : DWORD
		mov edx ,pString
		call WriteString
		call Crlf

		ret 
	writeStr ENDP

END main
