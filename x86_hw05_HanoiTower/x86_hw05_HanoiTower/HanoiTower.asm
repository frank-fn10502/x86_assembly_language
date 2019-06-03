TITLE 河內塔 (HanoiTower.asm)

INCLUDE Irvine32.inc

.386
;.model flat ,stdcall	;Irvine32 有設定了
.stack 4096
ExitProcess  PROTO ,dwExitCodw : DWORD
hanoiTower   PROTO ,num : DWORD ,start : DWORD ,pass : DWORD ,destination : DWORD

printProcess PROTO ,num : DWORD ,placeA : DWORD ,placeB : DWORD
composing	 PROTO ,num : DWORD

.data
	colonText BYTE ": " ,0
	toText	  BYTE " -----> " ,0
	calNumTet BYTE "搬動次數: " ,0
	inputText BYTE "請輸入圓盤數目: " ,0
.code

	main PROC
		Top:
			call clrscr

			mov esi ,0
			call inputData
			INVOKE hanoiTower ,1 ,'A' ,'B' ,'C'
			call printMoveTimes

			call waitMsg
		jmp Top
		INVOKE ExitProcess, 0
	main ENDP

	inputData PROC	;回傳eax (數目)
		mov edx ,OFFSET inputText
		call writeString

		call readDec

		ret
	inputData ENDP
;===遞迴()=================================================================
	hanoiTower PROC ,num : DWORD ,start : DWORD ,pass : DWORD ,destination : DWORD
		cmp num ,eax
		ja Done		
			inc num
			INVOKE hanoiTower ,num ,start ,destination ,pass
			dec num

			INVOKE printProcess ,num ,start ,destination

			inc num
			INVOKE hanoiTower ,num ,pass ,start ,destination
			dec num
		Done:
		ret
	hanoiTower ENDP

;===印出=================================================================
	printProcess PROC ,num : DWORD ,placeA : DWORD ,placeB : DWORD
		push eax
		push edx
			inc esi ;搬動次數
			INVOKE composing ,num

			mov EDX ,OFFSET colonText
			call writeString

			mov al ,BYTE PTR placeA
			call writeChar

			mov edx ,OFFSET toText
			call writeString

			mov al ,BYTE PTR placeB
			call writeChar

			call crlf
		pop edx
		pop eax
		ret
	printProcess ENDP
	composing PROC ,num : DWORD
		mov eax ,num
		call writeDec

		Top:
			cmp eax ,100
			jae Done
			
			push eax
				mov al ,' '
				call writeChar
			pop eax
			imul eax ,10
		jmp Top

		Done:
		ret
	composing ENDP

	printMoveTimes PROC
		mov edx ,OFFSET calNumTet
		call writeString
		mov eax ,esi
		call writeDec
		call crlf

		ret
	printMoveTimes ENDP
END main
