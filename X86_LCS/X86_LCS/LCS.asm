INCLUDE Irvine32.inc

TITLE LongestCommonSubsequence (LCS.asm)

.386
;.model flat ,stdcall ;Irvine32 有設定了
.stack 4096
ExitProcess   PROTO ,dwExitCodw : DWORD
getInput      PROTO ,pInputText : DWORD ,pStr : DWORD ,maxNum : DWORD ,posNo : DWORD
withoutNumber PROTO ,pStr : DWORD ,strNumber : DWORD ;回傳eax (0: false ,1: true)

getThePosNum PROTO ,index1 : DWORD ,index2 : DWORD	 ;回傳 esi
getIndex	 PROTO ,index1 : DWORD ,index2 : DWORD	 ;回傳esi (最大) ,假設x,y 都加1(偏移)
getMax       PROTO ,num1 : DWORD ,num2 : DWORD		 ;回傳eax (最大)

isPrime		 PROTO ,num : DWORD
primeFactorization PROTO ,num : DWORD

StringToNum  PROTO ,pStr : DWORD ,count : DWORD
ischarNumber PROTO ,character : DWORD				;edx (0: false ,1: true)

.data
	str1  BYTE	10+1 dup(0)
	str2  BYTE	10+1 dup(0)
	array DWORD 11 * 11 dup(0)

	inputStr1Text  BYTE "輸入字串1: " ,0
	inputStr2Text  BYTE "輸入字串2: " ,0
	inputErrorText BYTE "(只能輸入正整數)" ,0
	noLcsText	   BYTE "沒有 LCS" ,0
	noGCDText	   BYTE "沒有最大公因數" ,0
	noPrimeFactorText BYTE "沒有質數因子" ,0
	LCSText		   BYTE "最長共同子序列: " ,0
	divLineText	   BYTE 13 ,10 ,"====================" ,13 ,10 ,0

	strNum DWORD 2 dup(0)

	LCS    DWORD 10 dup(0)
	LCSNum DWORD 0

	number1 DWORD 0
	number2 DWORD 0
	GCDnum	DWORD 0

	primeFactor BYTE 1000 dup(0)
.code
	main PROC
		TOP:
			call clrscr
			call input

			mov edx ,OFFSET divLineText
			call writeString
				call computeLCS
				call printLCS 

			mov edx ,OFFSET divLineText
			call writeString			
				call computeGCD
				call printGCD

			mov edx ,OFFSET divLineText
			call writeString
				call computeFactor

			call waitMsg
		jmp Top
		INVOKE ExitProcess, 0
	main ENDP

	input PROC
		invoke getInput ,OFFSET inputStr1Text ,OFFSET str1 ,SIZEOF str1 ,1
		invoke getInput ,OFFSET inputStr2Text ,OFFSET str2 ,SIZEOF str2 ,2
		ret
	input ENDP
		getInput PROC ,pInputText : DWORD ,pStr : DWORD ,maxNum : DWORD ,posNo : DWORD
			sub esp ,4
			mov DWORD PTR [ebp-4] ,0	;是否要顯示錯誤提示
			sub posNo ,1

		Top:
			cmp DWORD PTR [ebp-4] ,1
			jne NotNeed
				mov dh ,BYTE PTR posNo
				mov dl ,0
				call gotoxy

				mov edx ,OFFSET inputErrorText
				call writeString

			NotNeed:
			mov edx ,pInputText
			call writeString

			mov edx ,pStr
			mov ecx ,maxNum
			call readString

			mov esi ,posNo
			mov strNum[esi * TYPE strNum] ,eax		;輸入的長度

			invoke withoutNumber ,pStr ,strNum[esi * TYPE strNum]
			cmp eax ,0
			je Done
				mov DWORD PTR [ebp-4] ,1 ;錯誤提示
				jmp Top

			Done:
			ret
		getInput ENDP
		withoutNumber PROC ,pStr : DWORD ,strNumber : DWORD ;回傳eax (0: false ,1: true)
			push esi
			push ecx
		
			mov eax ,0
			mov esi ,pStr
			mov ecx ,strNumber
		L1:
			cmp BYTE PTR [esi] ,'0'
			jb NotNumber
			cmp BYTE PTR [esi] ,'9'
			ja NotNumber

			inc esi
		loop L1
		jmp Done

		NotNumber:
			mov eax ,1
		Done: 
			pop ecx
			pop esi
			ret
		withoutNumber ENDP

;=========計算LCS================================================
	computeLCS PROC
		enter 4 ,0
		push edx
		push ecx
		push ebx
		push eax

		mov LCSNum ,0
		mov eax ,0	
		mov ecx ,strNum[0 * TYPE strNum]
		L1:
		push ecx
			
			mov ecx ,strNum[1 * TYPE strNum]
			mov ebx ,0
			L2:
				mov dl ,str1[eax]
				mov dh ,str2[ebx]
				cmp dl ,dh
				jne NotEqual
					call getLT
					jmp Done

				NotEqual:
    				call getLorT

				Done:
				inc ebx 
			loop L2

		inc eax
		pop ecx				
		loop L1

		call getLCS

		pop eax
		pop ebx
		pop ecx
		pop edx
		leave
		ret
	computeLCS ENDP
		getLCS PROC
			enter 4*2 ,0
			mov eax ,strNum[0]			
			mov ebx ,strNum[1 * TYPE strNum]
			dec eax
			dec ebx

			invoke getThePosNum ,eax ,ebx
			mov ecx ,esi
			Top:
				mov dh ,str1[eax]
				mov dl ,str2[ebx]
				cmp dh ,dl
				jne Next
					movzx edx ,str1[eax]
					push edx
					inc LCSNum

					;刪除相應的位數(放 n)
					mov str1[eax] ,'n'
					mov str2[ebx] ,'n'	
					
					dec eax
					dec ebx
					dec ecx	
					 
					cmp ecx ,0
					je Done
					jmp NextRound
				Next:	
					push eax
						dec eax
						invoke getThePosNum ,eax ,ebx
						mov DWORD PTR [ebp-4] ,esi		;上方的數值
					pop eax

					push ebx
						dec ebx
						invoke getThePosNum ,eax ,ebx
						mov DWORD PTR [ebp-4*2] ,esi	;左方的數值
					pop ebx

					mov edx ,DWORD PTR [ebp-4]
					cmp edx ,DWORD PTR [ebp-4*2]
					jb GoLeft
						dec eax			;>= 往上
						jmp NextRound
					GoLeft:
						dec ebx			;< 往左
				NextRound:
			jmp Top
			Done:
				mov esi ,0
				mov ecx ,LCSNum
				cmp ecx ,0
				je DontDo
					L1:
						pop LCS[esi * TYPE LCS]
						inc esi
					loop L1
				DontDo:
			leave
			ret
		getLCS ENDP
		getLT PROC
			enter 4 ,0
			push eax
			push ebx
				dec eax
				dec ebx
				invoke getThePosNum ,eax ,ebx
				mov DWORD PTR [ebp-4] ,esi			;取得左上位置的數值
			pop ebx
			pop eax

			push eax
			push ebx
				invoke getIndex ,eax ,ebx 
				mov eax ,esi						;eax: 現在位置
				mov ebx ,DWORD PTR [ebp-4]			;ebx: 左上位置的數值

				mov array[eax * TYPE array] ,ebx	;現在位置 = 左上位置的數值
				add array[eax * TYPE array] ,1		;+1
			pop ebx
			pop eax	
			leave		
			ret
		getLT ENDP
		getLorT PROC
			enter 4*2 ,0
			push eax
				dec eax
				invoke getThePosNum ,eax ,ebx
				mov DWORD PTR [ebp-4] ,esi			;上方位置的數值
			pop eax

			push ebx
				dec ebx
				invoke getThePosNum ,eax ,ebx
				mov DWORD PTR [ebp-4*2] ,esi		;左方位置的數值
			pop ebx

			invoke getMax ,DWORD PTR [ebp-4] ,DWORD PTR [ebp-4*2]
			invoke getIndex ,eax ,ebx				;現在位置(esi)
			mov array[esi * TYPE array] ,edx		;max(上,左) -> edx
			
			leave
			ret
		getLorT ENDP
		getThePosNum PROC ,index1 : DWORD ,index2 : DWORD;回傳 esi
			invoke getIndex ,index1 ,index2
			mov esi ,array[esi * TYPE array]	
			ret
		getThePosNum ENDP
		getIndex PROC ,index1 : DWORD ,index2 : DWORD	 ;回傳esi (位置) ,假設x,y 都加1(偏移)
			push eax
			push ebx
				mov eax ,index1
				mov ebx ,index2
				inc eax
				inc ebx

				mov esi ,eax
				imul esi ,11
				add esi ,ebx
			pop ebx
			pop eax	
			ret
		getIndex ENDP
		getMax PROC ,num1 : DWORD ,num2 : DWORD			 ;回傳edx (最大)
			mov edx ,num1

			cmp edx ,num2
			jae Done
				mov edx ,num2
			Done:
			ret
		getMax ENDP
	printLCS PROC
		mov ecx ,LCSNum
		cmp LCSNum ,0
		je NoLCS
			mov edx ,OFFSET LCSText
			call writeString

			mov esi ,0
			L1:
				mov al ,BYTE PTR LCS[esi * TYPE LCS]
				call writeChar
				inc esi
			loop L1
			jmp Done

		NoLCS:
			mov edx ,OFFSET noLcsText
			call writeString

		Done:
		call crlf
		ret
	printLCS ENDP

;=========計算最大公因數==========================================
	computeGCD PROC
		mov number1 ,0
		mov number2 ,0

		invoke StringToNum ,OFFSET str1 ,strNum[0]
		mov number1 ,eax
		invoke StringToNum ,OFFSET str2 ,strNum[1 * TYPE strNum]
		mov number2 ,eax

		ret
	computeGCD ENDP

	printGCD PROC
		call preText
		cmp eax ,1
		jne Done
			mov edx ,0
			mov eax ,number1
			mov ebx ,number2
				Top:
					mov edx ,0
					div ebx

					cmp edx ,0 ;餘數為零
					je Print
						mov ecx ,ebx	;temp = y
						mov ebx ,edx	;y = x
						mov eax ,ecx	;x = temp
				jmp Top

			Print:
				mov GCDnum ,ebx
				mov eax ,GCDnum
				call writeDec		
		Done:
		call crlf
		ret
	printGCD ENDP
		preText PROC ;回傳eax
			cmp number1 ,0
			je NoGCD
			cmp number2 ,0
			je NoGCD
				mov al ,'('
				call writeChar

				mov eax ,number1
				call writeDec

				mov al ,','
				call writeChar

				mov eax ,number2
				call writeDec

				mov al ,')'
				call writeChar

				mov al ,':'
				call writeChar

				mov eax ,1
				jmp Done

			NoGCD:	
				mov GCDnum ,0
				mov edx ,OFFSET noGCDText
				call writeString

				mov eax ,0
			Done:
			ret
		preText ENDP

;=========計算IterativeFactor====================================
	computeFactor PROC
		mov edx ,GCDnum
		Top:
			invoke isPrime ,edx
			cmp eax ,1
			jae Prime
				invoke primeFactorization ,edx
				call printSpacialPrimeFactor
				jmp Next
			Prime:
			cmp eax ,2
			je NoAnswer
				mov eax ,edx 
				call writeDec
				call crlf
				jmp Done
			NoAnswer:
				mov edx ,OFFSET noPrimeFactorText
				call writeString
				call crlf
				jmp Done
			Next:
		jmp TOP

		Done:
		ret
	computeFactor ENDP
		isPrime PROC ,num : DWORD			 ;回傳eax (0 or 1 ,2:無)
			push edx
			push ecx

			mov eax ,2
			mov ecx ,num
			cmp ecx ,0
			je Done
				mov ecx ,2
				Top:
					cmp ecx ,num
					jae Prime

					mov edx ,0
					mov eax ,num
					div ecx
					cmp edx ,0
					je NotPrime

					inc ecx
				jmp Top

				NotPrime:
					mov eax ,0
					jmp Done	
				Prime:
					mov eax ,1
					jmp Done
			Done:
			pop ecx
			pop edx
			ret
		isPrime ENDP
		primeFactorization PROC ,num : DWORD ;回傳 esi (個數) ,放在 primeFactor
			push eax
			push ebx
			push ecx
				sub esp ,4
				mov DWORD PTR [ebp-4] ,0
				mov esi ,1		;從1開始
				mov eax ,num
				mov ebx ,2		;除數
				mov ecx ,(num - 2)		
				L1:
					jmp Top
					RecordFactor:
						push eax
							push esi
								dec esi
								movzx eax ,primeFactor[esi * TYPE primeFactor]
							pop esi
							cmp eax ,ebx
							je DontRecord
								mov primeFactor[esi * TYPE primeFactor] ,bl
								inc esi
						DontRecord:
						pop eax
					Top:
						mov DWORD PTR [ebp-4] ,eax
						mov edx ,0
						div ebx

					cmp edx ,0
					je RecordFactor
					mov eax ,DWORD PTR [ebp-4]

					cmp eax ,1
					je Done
						inc ebx
				loop L1

			Done:
			pop ecx
			pop ebx
			pop eax
			ret
		primeFactorization ENDP
		printSpacialPrimeFactor PROC ;傳入 esi ,傳出 edx(加總)
			push eax
			push ebx
			push ecx

				mov ebx ,0
				mov ecx ,esi
				dec ecx			;因為esi從1開始
				mov esi ,1
				L1:
					movzx eax ,primeFactor[esi * TYPE primeFactor]
					add   ebx ,eax
					call writeDec

					cmp ecx ,1
					je NoMutiplySign
						mov al ,'+'
						call writeChar
						jmp Next

					NoMutiplySign:
						mov al ,':'
						call writeChar
					Next:				
					inc esi
				loop L1

				mov edx ,ebx
				mov eax ,edx
				call writeDec
				call crlf

			pop ecx
			pop ebx
			pop eax
			ret
		printSpacialPrimeFactor ENDP

;=========通用===================================================
	StringToNum PROC ,pStr : DWORD ,count : DWORD
		push ecx
		mov  eax,0

		mov ecx ,count 
		mov edx ,pStr
		L1:
			movzx esi ,BYTE PTR [edx]	;edx存著"字串"
			inc edx

			push edx
				invoke ischarNumber ,esi
				cmp edx ,1
				jne Next		
					sub	 esi ,'0'
					imul eax ,10
					add  eax ,esi
				Next:
			pop edx
		loop L1

		Done: 
			pop ecx		
			ret
	StringToNum ENDP
	ischarNumber PROC ,character : DWORD ;edx (0: false ,1: true)
		push esi
		mov  edx ,1
		mov  esi ,character

		cmp esi ,'0'
		jb 	NotNumber
		cmp esi ,'9'
		ja  NotNumber
		jmp Done

		NotNumber:
			mov edx ,0
		Done:
		pop esi
		ret
	ischarNumber ENDP

END main