/*
* Copyright (C) 2016, Ulrich Wolffgang <u.wol@wwu.de>
* All rights reserved.
*
* This software may be modified and distributed under the terms
* of the BSD 3-clause license.
*/

/*
Copyright (c) 2016, Ulrich Wolffgang <u.wol@wwu.de>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
* Visual Basic 6.0 Grammar for ANTLR4
*
* This is an approximate grammar for Visual Basic 6.0, derived 
* from the Visual Basic 6.0 language reference 
* http://msdn.microsoft.com/en-us/library/aa338033%28v=vs.60%29.aspx 
* and tested against MSDN VB6 statement examples as well as several Visual 
* Basic 6.0 code repositories.
*
* Characteristics:
*
* 1. This grammar is line-based and takes into account whitespace, so that
*    member calls (e.g. "A.B") are distinguished from contextual object calls 
*    in WITH statements (e.g. "A .B").
*
* 2. Keywords can be used as identifiers depending on the context, enabling
*    e.g. "A.Type", but not "Type.B".
*
*
* Known limitations:
*
* 1. Preprocessor statements (#if, #else, ...) must not interfere with regular
*    statements.
*
* 2. Comments are skipped.
*
*
* Change log:
*
* v1.4
*	- erase statement fix
*	- explicit token definition
*
* v1.3
*	- call statement precedence
*
* v1.2
*	- refined call statements
*
* v1.1 
*	- precedence of operators and of ELSE in select statements
*	- optimized member calls
*
* v1.0 Initial revision
*/

grammar VB;

options
{
	language = Java;
}


// module ----------------------------------

startRule : module EOF;

module : 
	WS? NEWLINE*
	(moduleHeader NEWLINE+)?
	moduleConfig? NEWLINE*
	moduleAttributes? NEWLINE*
	moduleOptions? NEWLINE*
	moduleBody? NEWLINE*
	WS?
;

moduleHeader : VERSION WS DOUBLELITERAL WS CLASS;

moduleConfig :
	BEGIN NEWLINE+ 
	moduleConfigElement+
	END NEWLINE+
;

moduleConfigElement :
	ambiguousIdentifier WS? EQ WS? literal NEWLINE
;

moduleAttributes : (attributeStmt NEWLINE+)+;

moduleOptions : (moduleOption NEWLINE+)+;

moduleOption : 
	OPTION_BASE WS INTEGERLITERAL 			# optionBaseStmt
	| OPTION_COMPARE WS (BINARY | TEXT) 	# optionCompareStmt
	| OPTION_EXPLICIT 						# optionExplicitStmt
	| OPTION_PRIVATE_MODULE 				# optionPrivateModuleStmt
;

moduleBody : 
	moduleBodyElement (NEWLINE+ moduleBodyElement)*
;

moduleBodyElement : 
	moduleBlock
	| declareStmt
	| enumerationStmt 
	| eventStmt
	| functionStmt 
	| macroIfThenElseStmt
	| propertyGetStmt 
	| propertySetStmt 
	| propertyLetStmt 
	| subStmt 
	| typeStmt
;


// block ----------------------------------

moduleBlock : block;

attributeStmt : ATTRIBUTE WS implicitCallStmt_InStmt WS? EQ WS? literal (WS? COMMA WS? literal)*;

block : blockStmt (NEWLINE+ WS? blockStmt)*;

blockStmt : 
	appactivateStmt
	| attributeStmt
	| beepStmt
	| chdirStmt
	| chdriveStmt
	| closeStmt
	| constStmt
	| dateStmt
	| deleteSettingStmt
	| deftypeStmt
	| doLoopStmt
	| endStmt
	| eraseStmt
	| errorStmt
	| exitStmt
	| explicitCallStmt
	| filecopyStmt
	| forEachStmt
	| forNextStmt
	| getStmt
	| goSubStmt
	| goToStmt
	| ifThenElseStmt
	| implementsStmt
	| inputStmt
	| killStmt
	| letStmt
	| lineInputStmt
	| lineLabel
	| loadStmt
	| lockStmt
	| lsetStmt
	| macroIfThenElseStmt
	| midStmt
	| mkdirStmt
	| nameStmt
	| onErrorStmt
	| onGoToStmt
	| onGoSubStmt
	| openStmt
	| printStmt
	| putStmt
	| raiseEventStmt
	| randomizeStmt
	| redimStmt
	| resetStmt
	| resumeStmt
	| returnStmt
	| rmdirStmt
	| rsetStmt
	| savepictureStmt
	| saveSettingStmt
	| seekStmt
	| selectCaseStmt
	| sendkeysStmt
	| setattrStmt
	| setStmt
	| stopStmt
	| timeStmt
	| unloadStmt
	| unlockStmt
	| variableStmt
	| whileWendStmt
	| widthStmt
	| withStmt
	| writeStmt
	| implicitCallStmt_InBlock
;


// statements ----------------------------------

appactivateStmt : APPACTIVATE WS valueStmt (WS? COMMA WS? valueStmt)?;

beepStmt : BEEP;

chdirStmt : CHDIR WS valueStmt;

chdriveStmt : CHDRIVE WS valueStmt;

closeStmt : CLOSE (WS valueStmt (WS? COMMA WS? valueStmt)*)?;

constStmt : (visibility WS)? CONST WS constSubStmt (WS? COMMA WS? constSubStmt)*;

constSubStmt : ambiguousIdentifier typeHint? (WS asTypeClause)? WS? EQ WS? valueStmt;

dateStmt : DATE WS? EQ WS? valueStmt;

declareStmt : (visibility WS)? DECLARE WS (FUNCTION typeHint? | SUB) WS ambiguousIdentifier typeHint? WS LIB WS STRINGLITERAL (WS ALIAS WS STRINGLITERAL)? (WS? argList)? (WS asTypeClause)?;

deftypeStmt : 
	(
		DEFBOOL | DEFBYTE | DEFINT | DEFLNG | DEFCUR | 
		DEFSNG | DEFDBL | DEFDEC | DEFDATE | 
		DEFSTR | DEFOBJ | DEFVAR
	) WS
	letterrange (WS? COMMA WS? letterrange)*
;

deleteSettingStmt : DELETESETTING WS valueStmt WS? COMMA WS? valueStmt (WS? COMMA WS? valueStmt)?;

doLoopStmt :
	DO NEWLINE+ 
	(block NEWLINE+)? 
	LOOP
	|
	DO WS (WHILE | UNTIL) WS valueStmt NEWLINE+ 
	(block NEWLINE+)? 
	LOOP
	| 
	DO NEWLINE+ 
	(block NEWLINE+) 
	LOOP WS (WHILE | UNTIL) WS valueStmt
;

endStmt : END;

enumerationStmt: 
	(visibility WS)? ENUM WS ambiguousIdentifier NEWLINE+ 
	(enumerationStmt_Constant)* 
	END_ENUM
;

enumerationStmt_Constant : ambiguousIdentifier (WS? EQ WS? valueStmt)? NEWLINE+;

eraseStmt : ERASE WS valueStmt (WS? COMMA WS? valueStmt)*;

errorStmt : ERROR WS valueStmt;

eventStmt : (visibility WS)? EVENT WS ambiguousIdentifier WS? argList;

exitStmt : EXIT_DO | EXIT_FOR | EXIT_FUNCTION | EXIT_PROPERTY | EXIT_SUB;

filecopyStmt : FILECOPY WS valueStmt WS? COMMA WS? valueStmt;

forEachStmt : 
	FOR WS EACH WS ambiguousIdentifier typeHint? WS IN WS valueStmt NEWLINE+ 
	(block NEWLINE+)?
	NEXT (WS ambiguousIdentifier)?
;

forNextStmt : 
	FOR WS ambiguousIdentifier typeHint? (WS asTypeClause)? WS? EQ WS? valueStmt WS TO WS valueStmt (WS STEP WS valueStmt)? NEWLINE+ 
	(block NEWLINE+)? 
	NEXT (WS ambiguousIdentifier)?
; 

functionStmt :
	(visibility WS)? (STATIC WS)? FUNCTION WS ambiguousIdentifier (WS? argList)? (WS asTypeClause)? NEWLINE+
	(block NEWLINE+)?
	END_FUNCTION
;

getStmt : GET WS valueStmt WS? COMMA WS? valueStmt? WS? COMMA WS? valueStmt;

goSubStmt : GOSUB WS valueStmt;

goToStmt : GOTO WS valueStmt;

ifThenElseStmt : 
	IF WS ifConditionStmt WS THEN WS blockStmt (WS ELSE WS blockStmt)?	# inlineIfThenElse
	| ifBlockStmt ifElseIfBlockStmt* ifElseBlockStmt? END_IF			# blockIfThenElse
;

ifBlockStmt : 
	IF WS ifConditionStmt WS THEN NEWLINE+ 
	(block NEWLINE+)?
;

ifConditionStmt : valueStmt;

ifElseIfBlockStmt : 
	ELSEIF WS ifConditionStmt WS THEN NEWLINE+ 
	(block NEWLINE+)?
;

ifElseBlockStmt : 
	ELSE NEWLINE+ 
	(block NEWLINE+)?
;

implementsStmt : IMPLEMENTS WS ambiguousIdentifier;

inputStmt : INPUT WS valueStmt (WS? COMMA WS? valueStmt)+;

killStmt : KILL WS valueStmt;

letStmt : (LET WS)? implicitCallStmt_InStmt WS? (EQ | PLUS_EQ | MINUS_EQ) WS? valueStmt;

lineInputStmt : LINE_INPUT WS valueStmt WS? COMMA WS? valueStmt;

loadStmt : LOAD WS valueStmt;

lockStmt : LOCK WS valueStmt (WS? COMMA WS? valueStmt (WS TO WS valueStmt)?)?;

lsetStmt : LSET WS implicitCallStmt_InStmt WS? EQ WS? valueStmt;

macroIfThenElseStmt : macroIfBlockStmt macroElseIfBlockStmt* macroElseBlockStmt? MACRO_END_IF;

macroIfBlockStmt : 
	MACRO_IF WS ifConditionStmt WS THEN NEWLINE+ 
	(moduleBody NEWLINE+)?
;

macroElseIfBlockStmt : 
	MACRO_ELSEIF WS ifConditionStmt WS THEN NEWLINE+ 
	(moduleBody NEWLINE+)?
;

macroElseBlockStmt : 
	MACRO_ELSE NEWLINE+ 
	(moduleBody NEWLINE+)?
;

midStmt : MID WS? LPAREN WS? argsCall WS? RPAREN;

mkdirStmt : MKDIR WS valueStmt;

nameStmt : NAME WS valueStmt WS AS WS valueStmt;

onErrorStmt : ON_ERROR WS (GOTO WS valueStmt | RESUME WS NEXT);

onGoToStmt : ON WS valueStmt WS GOTO WS valueStmt (WS? COMMA WS? valueStmt)*;

onGoSubStmt : ON WS valueStmt WS GOSUB WS valueStmt (WS? COMMA WS? valueStmt)*;

openStmt : 
	OPEN WS valueStmt WS FOR WS (APPEND | BINARY | INPUT | OUTPUT | RANDOM) 
	(WS ACCESS WS (READ | WRITE | READ_WRITE))?
	(WS (SHARED | LOCK_READ | LOCK_WRITE | LOCK_READ_WRITE))?
	WS AS WS valueStmt
	(WS LEN WS? EQ WS? valueStmt)?
;

outputList :
	outputList_Expression (WS? (SEMICOLON | COMMA) WS? outputList_Expression?)*
	| outputList_Expression? (WS? (SEMICOLON | COMMA) WS? outputList_Expression?)+
;

outputList_Expression : 
	valueStmt
	| (SPC | TAB) (WS? LPAREN WS? argsCall WS? RPAREN)?
;

printStmt : PRINT WS valueStmt WS? COMMA (WS? outputList)?;

propertyGetStmt : 
	(visibility WS)? (STATIC WS)? PROPERTY_GET WS ambiguousIdentifier typeHint? (WS? argList)? (WS asTypeClause)? NEWLINE+ 
	(block NEWLINE+)? 
	END_PROPERTY
;

propertySetStmt : 
	(visibility WS)? (STATIC WS)? PROPERTY_SET WS ambiguousIdentifier (WS? argList)? NEWLINE+ 
	(block NEWLINE+)? 
	END_PROPERTY
;

propertyLetStmt : 
	(visibility WS)? (STATIC WS)? PROPERTY_LET WS ambiguousIdentifier (WS? argList)? NEWLINE+ 
	(block NEWLINE+)? 
	END_PROPERTY
;

putStmt : PUT WS valueStmt WS? COMMA WS? valueStmt? WS? COMMA WS? valueStmt;

raiseEventStmt : RAISEEVENT WS ambiguousIdentifier (WS? LPAREN WS? (argsCall WS?)? RPAREN)?;

randomizeStmt : RANDOMIZE (WS valueStmt)?;

redimStmt : REDIM WS (PRESERVE WS)? redimSubStmt (WS? COMMA WS? redimSubStmt)*;

redimSubStmt : implicitCallStmt_InStmt WS? LPAREN WS? subscripts WS? RPAREN (WS asTypeClause)?;

resetStmt : RESET;

resumeStmt : RESUME (WS (NEXT | ambiguousIdentifier))?;

returnStmt : RETURN;

rmdirStmt : RMDIR WS valueStmt;

rsetStmt : RSET WS implicitCallStmt_InStmt WS? EQ WS? valueStmt;

savepictureStmt : SAVEPICTURE WS valueStmt WS? COMMA WS? valueStmt;

saveSettingStmt : SAVESETTING WS valueStmt WS? COMMA WS? valueStmt WS? COMMA WS? valueStmt WS? COMMA WS? valueStmt;

seekStmt : SEEK WS valueStmt WS? COMMA WS? valueStmt;

selectCaseStmt : 
	SELECT WS CASE WS valueStmt NEWLINE+ 
	sC_Case*
	WS? END_SELECT
;

sC_Case : 
	CASE WS sC_Cond WS? (COLON? NEWLINE* | NEWLINE+)  
	(block NEWLINE+)?
;

// ELSE first, so that it is not interpreted as a variable call
sC_Cond : 
	ELSE 															# caseCondElse
	| IS WS? comparisonOperator WS? valueStmt 						# caseCondIs
	| valueStmt (WS? COMMA WS? valueStmt)* 							# caseCondValue
	| INTEGERLITERAL WS TO WS valueStmt (WS? COMMA WS? valueStmt)* 	# caseCondTo
;

sendkeysStmt : SENDKEYS WS valueStmt (WS? COMMA WS? valueStmt)?;

setattrStmt : SETATTR WS valueStmt WS? COMMA WS? valueStmt;

setStmt : SET WS implicitCallStmt_InStmt WS? EQ WS? valueStmt;

stopStmt : STOP;

subStmt : 
	(visibility WS)? (STATIC WS)? SUB WS ambiguousIdentifier (WS? argList)? NEWLINE+ 
	(block NEWLINE+)? 
	END_SUB
;

timeStmt : TIME WS? EQ WS? valueStmt;

typeStmt : 
	(visibility WS)? TYPE WS ambiguousIdentifier NEWLINE+ 
	(typeStmt_Element)*
	END_TYPE
;

typeStmt_Element : ambiguousIdentifier (WS? LPAREN (WS? subscripts)? WS? RPAREN)? (WS asTypeClause)? NEWLINE+;

typeOfStmt : TYPEOF WS valueStmt (WS IS WS type)?;

unloadStmt : UNLOAD WS valueStmt;

unlockStmt : UNLOCK WS valueStmt (WS? COMMA WS? valueStmt (WS TO WS valueStmt)?)?;

// operator precedence is represented by rule order
valueStmt : 
	literal 												# vsLiteral
	| implicitCallStmt_InStmt 								# vsICS
	| LPAREN WS? valueStmt (WS? COMMA WS? valueStmt)* RPAREN 	# vsStruct
	| NEW WS valueStmt 										# vsNew
	| typeOfStmt 											# vsTypeOf
	| midStmt 												# vsMid
	| ADDRESSOF WS valueStmt 								# vsAddressOf
	| implicitCallStmt_InStmt WS? ASSIGN WS? valueStmt 		# vsAssign

	| valueStmt WS IS WS valueStmt 							# vsIs
	| valueStmt WS LIKE WS valueStmt 						# vsLike
	| valueStmt WS? GEQ WS? valueStmt 						# vsGeq
	| valueStmt WS? LEQ WS? valueStmt 						# vsLeq
	| valueStmt WS? GT WS? valueStmt 						# vsGt
	| valueStmt WS? LT WS? valueStmt 						# vsLt
	| valueStmt WS? NEQ WS? valueStmt 						# vsNeq
	| valueStmt WS? EQ WS? valueStmt 						# vsEq

	| valueStmt WS AMPERSAND WS valueStmt 					# vsAmp
	| MINUS WS? valueStmt 									# vsNegation
	| PLUS WS? valueStmt 									# vsPlus
	| valueStmt WS? PLUS WS? valueStmt 						# vsAdd
	| valueStmt WS? MOD WS? valueStmt 						# vsMod
	| valueStmt WS? DIV WS? valueStmt 						# vsDiv
	| valueStmt WS? MULT WS? valueStmt 						# vsMult
	| valueStmt WS? MINUS WS? valueStmt 					# vsMinus
	| valueStmt WS? POW WS? valueStmt 						# vsPow

	| valueStmt WS IMP WS valueStmt 						# vsImp
	| valueStmt WS EQV WS valueStmt 						# vsEqv
	| valueStmt WS? XOR WS? valueStmt 						# vsXor
	| valueStmt WS? OR WS? valueStmt 						# vsOr
	| valueStmt WS AND WS valueStmt 						# vsAnd
	| NOT WS valueStmt 										# vsNot
;

variableStmt : (DIM | STATIC | visibility) WS (WITHEVENTS WS)? variableListStmt;

variableListStmt : variableSubStmt (WS? COMMA WS? variableSubStmt)*;

variableSubStmt : ambiguousIdentifier (WS? LPAREN WS? (subscripts WS?)? RPAREN WS?)? typeHint? (WS asTypeClause)?;

whileWendStmt : 
	WHILE WS valueStmt NEWLINE+ 
	(block NEWLINE)* 
	WEND
;

widthStmt : WIDTH WS valueStmt WS? COMMA WS? valueStmt;

withStmt : 
	WITH WS implicitCallStmt_InStmt NEWLINE+ 
	(block NEWLINE+)? 
	END_WITH
;

writeStmt : WRITE WS valueStmt WS? COMMA (WS? outputList)?;


// complex call statements ----------------------------------

explicitCallStmt : 
	eCS_ProcedureCall 
	| eCS_MemberProcedureCall 
;

// parantheses are required in case of args -> empty parantheses are removed
eCS_ProcedureCall : CALL WS ambiguousIdentifier typeHint? (WS? LPAREN WS? argsCall WS? RPAREN)?;

// parantheses are required in case of args -> empty parantheses are removed
eCS_MemberProcedureCall : CALL WS implicitCallStmt_InStmt? DOT ambiguousIdentifier typeHint? (WS? LPAREN WS? argsCall WS? RPAREN)?;


implicitCallStmt_InBlock :
	iCS_B_ProcedureCall
	| iCS_B_MemberProcedureCall
;

// parantheses are forbidden in case of args
// variables cannot be called in blocks
// certainIdentifier instead of ambiguousIdentifier for preventing ambiguity with statement keywords 
iCS_B_ProcedureCall : certainIdentifier (WS argsCall)?;

iCS_B_MemberProcedureCall : implicitCallStmt_InStmt? DOT ambiguousIdentifier typeHint? (WS argsCall)? dictionaryCallStmt?;


// iCS_S_MembersCall first, so that member calls are not resolved as separate iCS_S_VariableOrProcedureCalls
implicitCallStmt_InStmt :
	iCS_S_MembersCall
	| iCS_S_VariableOrProcedureCall
	| iCS_S_ProcedureOrArrayCall
	| iCS_S_DictionaryCall
;

iCS_S_VariableOrProcedureCall : ambiguousIdentifier typeHint? dictionaryCallStmt?;

iCS_S_ProcedureOrArrayCall : (ambiguousIdentifier | baseType) typeHint? WS? LPAREN WS? (argsCall WS?)? RPAREN dictionaryCallStmt?;

iCS_S_MembersCall : (iCS_S_VariableOrProcedureCall | iCS_S_ProcedureOrArrayCall)? iCS_S_MemberCall+ dictionaryCallStmt?;

iCS_S_MemberCall : DOT (iCS_S_VariableOrProcedureCall | iCS_S_ProcedureOrArrayCall);

iCS_S_DictionaryCall : dictionaryCallStmt;


// atomic call statements ----------------------------------

argsCall : (argCall? WS? (COMMA | SEMICOLON) WS?)* argCall (WS? (COMMA | SEMICOLON) WS? argCall?)*;

argCall : ((BYVAL | BYREF | PARAMARRAY) WS)? valueStmt;

dictionaryCallStmt : EXCLAMATIONMARK ambiguousIdentifier typeHint?;


// atomic rules for statements

argList : LPAREN (WS? arg (WS? COMMA WS? arg)*)? WS? RPAREN;

arg : (OPTIONAL WS)? ((BYVAL | BYREF) WS)? (PARAMARRAY WS)? ambiguousIdentifier (WS? LPAREN WS? RPAREN)? (WS asTypeClause)? (WS? argDefaultValue)?;

argDefaultValue : EQ WS? (literal | ambiguousIdentifier);

subscripts : subscript (WS? COMMA WS? subscript)*;

subscript : (valueStmt WS TO WS)? valueStmt;


// atomic rules ----------------------------------

ambiguousIdentifier : 
	(IDENTIFIER | ambiguousKeyword)+
	| L_SQUARE_BRACKET (IDENTIFIER | ambiguousKeyword)+ R_SQUARE_BRACKET
;

asTypeClause : AS WS (NEW WS)? type (WS fieldLength)?;

baseType : BOOLEAN | BYTE | COLLECTION | DATE | DOUBLE | INTEGER | LONG | SINGLE | STRING | VARIANT;

certainIdentifier : 
	IDENTIFIER (ambiguousKeyword | IDENTIFIER)*
	| ambiguousKeyword (ambiguousKeyword | IDENTIFIER)+
;

comparisonOperator : LT | LEQ | GT | GEQ | EQ | NEQ | IS | LIKE;

complexType : ambiguousIdentifier (DOT ambiguousIdentifier)*;

fieldLength : MULT WS? (INTEGERLITERAL | ambiguousIdentifier);

letterrange : certainIdentifier (WS? MINUS WS? certainIdentifier)?;

lineLabel : ambiguousIdentifier COLON;

literal : COLORLITERAL | DATELITERAL | DOUBLELITERAL | FILENUMBER | INTEGERLITERAL | STRINGLITERAL | TRUE | FALSE | NOTHING | NULL;

type : (baseType | complexType) (WS? LPAREN WS? RPAREN)?;

typeHint : AMPERSAND | AT | DOLLAR | EXCLAMATIONMARK | HASH | PERCENT;

visibility : PRIVATE | PUBLIC | FRIEND | GLOBAL;


// ambiguous keywords
ambiguousKeyword : 
	ACCESS | ADDRESSOF | ALIAS | AND | ATTRIBUTE | APPACTIVATE | APPEND | AS |
	BEEP | BEGIN | BINARY | BOOLEAN | BYVAL | BYREF | BYTE | 
	CALL | CASE | CLASS | CLOSE | CHDIR | CHDRIVE | COLLECTION | CONST | 
	DATE | DECLARE | DEFBOOL | DEFBYTE | DEFCUR | DEFDBL | DEFDATE | DEFDEC | DEFINT | DEFLNG | DEFOBJ | DEFSNG | DEFSTR | DEFVAR | DELETESETTING | DIM | DO | DOUBLE | 
	EACH | ELSE | ELSEIF | END | ENUM | EQV | ERASE | ERROR | EVENT | 
	FALSE | FILECOPY | FRIEND | FOR | FUNCTION | 
	GET | GLOBAL | GOSUB | GOTO | 
	IF | IMP | IMPLEMENTS | IN | INPUT | IS | INTEGER |
	KILL | 
	LOAD | LOCK | LONG | LOOP | LEN | LET | LIB | LIKE | LSET |
	ME | MID | MKDIR | MOD | 
	NAME | NEXT | NEW | NOT | NOTHING | NULL | 
	ON | OPEN | OPTIONAL | OR | OUTPUT | 
	PARAMARRAY | PRESERVE | PRINT | PRIVATE | PUBLIC | PUT |
	RANDOM | RANDOMIZE | RAISEEVENT | READ | REDIM | REM | RESET | RESUME | RETURN | RMDIR | RSET |
	SAVEPICTURE | SAVESETTING | SEEK | SELECT | SENDKEYS | SET | SETATTR | SHARED | SINGLE | SPC | STATIC | STEP | STOP | STRING | SUB | 
	TAB | TEXT | THEN | TIME | TO | TRUE | TYPE | TYPEOF | 
	UNLOAD | UNLOCK | UNTIL | 
	VARIANT | VERSION | 
	WEND | WHILE | WIDTH | WITH | WITHEVENTS | WRITE |
	XOR
;


// lexer rules --------------------------------------------------------------------------------


// keywords
ACCESS : A C C E S S;
ADDRESSOF : A D D R E S S O F;
ALIAS : A L I A S;
AND : A N D;
ATTRIBUTE : A T T R I B U T E;
APPACTIVATE : A P P A C T I V A T E;
APPEND : A P P E N D;
AS : A S;
BEGIN : B E G I N;
BEEP : B E E P;
BINARY : B I N A R Y;
BOOLEAN : B O O L E A N;
BYVAL : B Y V A L;
BYREF : B Y R E F;
BYTE : B Y T E;
CALL : C A L L;
CASE : C A S E;
CHDIR : C H D I R;
CHDRIVE : C H D R I V E;
CLASS : C L A S S;
CLOSE : C L O S E;
COLLECTION : C O L L E C T I O N;
CONST : C O N S T;
DATE : D A T E;
DECLARE : D E C L A R E;
DEFBOOL : D E F B O O L; 
DEFBYTE : D E F B Y T E;
DEFDATE : D E F D A T E;
DEFDBL : D E F D B L;
DEFDEC : D E F D E C;
DEFCUR : D E F C U R;
DEFINT : D E F I N T;
DEFLNG : D E F L N G;
DEFOBJ : D E F O B J;
DEFSNG : D E F S N G;
DEFSTR : D E F S T R;
DEFVAR : D E F V A R;
DELETESETTING : D E L E T E S E T T I N G;
DIM : D I M;
DO : D O;
DOUBLE : D O U B L E;
EACH : E A C H;
ELSE : E L S E;
ELSEIF : E L S E I F;
END_ENUM : E N D ' ' E N U M;
END_FUNCTION : E N D ' ' F U N C T I O N;
END_IF : E N D ' ' I F;
END_PROPERTY : E N D ' ' P R O P E R T Y;
END_SELECT : E N D ' ' S E L E C T;
END_SUB : E N D ' ' S U B;
END_TYPE : E N D ' ' T Y P E;
END_WITH : E N D ' ' W I T H;
END : E N D;
ENUM : E N U M;
EQV : E Q V;
ERASE : E R A S E;
ERROR : E R R O R;
EVENT : E V E N T;
EXIT_DO : E X I T ' ' D O;
EXIT_FOR : E X I T ' ' F O R;
EXIT_FUNCTION : E X I T ' ' F U N C T I O N;
EXIT_PROPERTY : E X I T ' ' P R O P E R T Y;
EXIT_SUB : E X I T ' ' S U B;
FALSE : F A L S E;
FILECOPY : F I L E C O P Y;
FRIEND : F R I E N D;
FOR : F O R;
FUNCTION : F U N C T I O N;
GET : G E T;
GLOBAL : G L O B A L;
GOSUB : G O S U B;
GOTO : G O T O;
IF : I F;
IMP : I M P;
IMPLEMENTS : I M P L E M E N T S;
IN : I N;
INPUT : I N P U T;
IS : I S;
INTEGER : I N T E G E R;
KILL: K I L L;
LOAD : L O A D;
LOCK : L O C K;
LONG : L O N G;
LOOP : L O O P;
LEN : L E N;
LET : L E T;
LIB : L I B;
LIKE : L I K E;
LINE_INPUT : L I N E ' ' I N P U T;
LOCK_READ : L O C K ' ' R E A D;
LOCK_WRITE : L O C K ' ' W R I T E;
LOCK_READ_WRITE : L O C K ' ' R E A D ' ' W R I T E;
LSET : L S E T;
MACRO_IF : HASH I F;
MACRO_ELSEIF : HASH E L S E I F;
MACRO_ELSE : HASH E L S E;
MACRO_END_IF : HASH E N D ' ' I F;
ME : M E;
MID : M I D;
MKDIR : M K D I R;
MOD : M O D;
NAME : N A M E;
NEXT : N E X T;
NEW : N E W;
NOT : N O T;
NOTHING : N O T H I N G;
NULL : N U L L;
ON : O N;
ON_ERROR : O N ' ' E R R O R;
OPEN : O P E N;
OPTIONAL : O P T I O N A L;
OPTION_BASE : O P T I O N ' ' B A S E;
OPTION_EXPLICIT : O P T I O N ' ' E X P L I C I T;
OPTION_COMPARE : O P T I O N ' ' C O M P A R E;
OPTION_PRIVATE_MODULE : O P T I O N ' ' P R I V A T E ' ' M O D U L E;
OR : O R;
OUTPUT : O U T P U T;
PARAMARRAY : P A R A M A R R A Y;
PRESERVE : P R E S E R V E;
PRINT : P R I N T;
PRIVATE : P R I V A T E;
PROPERTY_GET : P R O P E R T Y ' ' G E T;
PROPERTY_LET : P R O P E R T Y ' ' L E T;
PROPERTY_SET : P R O P E R T Y ' ' S E T;
PUBLIC : P U B L I C;
PUT : P U T;
RANDOM : R A N D O M;
RANDOMIZE : R A N D O M I Z E;
RAISEEVENT : R A I S E E V E N T;
READ : R E A D;
READ_WRITE : R E A D ' ' W R I T E;
REDIM : R E D I M;
REM : R E M;
RESET : R E S E T;
RESUME : R E S U M E;
RETURN : R E T U R N;
RMDIR : R M D I R;
RSET : R S E T;
SAVEPICTURE : S A V E P I C T U R E;
SAVESETTING : S A V E S E T T I N G;
SEEK : S E E K;
SELECT : S E L E C T;
SENDKEYS : S E N D K E Y S;
SET : S E T;
SETATTR : S E T A T T R;
SHARED : S H A R E D;
SINGLE : S I N G L E;
SPC : S P C;
STATIC : S T A T I C;
STEP : S T E P;
STOP : S T O P;
STRING : S T R I N G;
SUB : S U B;
TAB : T A B;
TEXT : T E X T;
THEN : T H E N;
TIME : T I M E;
TO : T O;
TRUE : T R U E;
TYPE : T Y P E;
TYPEOF : T Y P E O F;
UNLOAD : U N L O A D;
UNLOCK : U N L O C K;
UNTIL : U N T I L;
VARIANT : V A R I A N T;
VERSION : V E R S I O N;
WEND : W E N D;
WHILE : W H I L E;
WIDTH : W I D T H;
WITH : W I T H;
WITHEVENTS : W I T H E V E N T S;
WRITE : W R I T E;
XOR : X O R;


// symbols
AMPERSAND : '&';
ASSIGN : ':=';
AT : '@';
COLON : ':';
COMMA : ',';
DIV : '\\' | '/';
DOLLAR : '$';
DOT : '.';
EQ : '=';
EXCLAMATIONMARK : '!';
GEQ : '>=';
GT : '>';
HASH : '#';
LEQ : '<=';
LPAREN : '(';
LT : '<';
MINUS : '-';
MINUS_EQ : '-=';
MULT : '*';
NEQ : '<>';
PERCENT : '%';
PLUS : '+';
PLUS_EQ : '+=';
POW : '^';
RPAREN : ')';
SEMICOLON : ';';
L_SQUARE_BRACKET : '[';
R_SQUARE_BRACKET : ']';


// literals
STRINGLITERAL : '"' (~["\r\n] | '""')* '"';
DATELITERAL : HASH (~[#\r\n])* HASH;
COLORLITERAL : '&H' [0-9A-F]+ AMPERSAND?;
INTEGERLITERAL : (PLUS|MINUS)? ('0'..'9')+ ( ('e' | 'E') INTEGERLITERAL)* (HASH | AMPERSAND)?;
DOUBLELITERAL : (PLUS|MINUS)? ('0'..'9')* DOT ('0'..'9')+ ( ('e' | 'E') (PLUS|MINUS)? ('0'..'9')+)* (HASH | AMPERSAND)?;
FILENUMBER : HASH LETTERORDIGIT+;


// identifier
IDENTIFIER : LETTER LETTERORDIGIT*;


// whitespace, line breaks, comments, ...
LINE_CONTINUATION : ' ' '_' '\r'? '\n' -> skip;
NEWLINE : WS? ('\r'? '\n' | COLON ' ') WS?;
COMMENT : WS? ('\'' | COLON? REM ' ') (LINE_CONTINUATION | ~('\n' | '\r'))* -> skip;
WS : [ \t]+;


// letters
fragment LETTER : [a-zA-Z_������];
fragment LETTERORDIGIT : [a-zA-Z0-9_������];

// case insensitive chars
fragment A:('a'|'A');
fragment B:('b'|'B');
fragment C:('c'|'C');
fragment D:('d'|'D');
fragment E:('e'|'E');
fragment F:('f'|'F');
fragment G:('g'|'G');
fragment H:('h'|'H');
fragment I:('i'|'I');
fragment J:('j'|'J');
fragment K:('k'|'K');
fragment L:('l'|'L');
fragment M:('m'|'M');
fragment N:('n'|'N');
fragment O:('o'|'O');
fragment P:('p'|'P');
fragment Q:('q'|'Q');
fragment R:('r'|'R');
fragment S:('s'|'S');
fragment T:('t'|'T');
fragment U:('u'|'U');
fragment V:('v'|'V');
fragment W:('w'|'W');
fragment X:('x'|'X');
fragment Y:('y'|'Y');
fragment Z:('z'|'Z');