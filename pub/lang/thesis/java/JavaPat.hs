module JavaPat where

import Char
import List

import Pos
import Parse



-------------------- Lexical Preprocessing --------------------

-- Preprocess unicode escapes and newlines
javaPrep :: String -> String
javaPrep [] = []
javaPrep ('\r':'\n':s) = '\n':javaPrep s
javaPrep ('\r':s) = '\n':javaPrep s
javaPrep ('\\':'\\':s) = '\\':'\\':javaPrep s
javaPrep ('\\':'u':s) = case s of
	h1:h2:h3:h4:s ->
		if isHexDigit h1 && isHexDigit h2 &&
		   isHexDigit h3 && isHexDigit h4
		then chr v4:javaPrep s
		else error "invalid Unicode escape sequence"
		where	v1 = digitToInt h1
			v2 = v1*16 + digitToInt h2
			v3 = v2*16 + digitToInt h3
			v4 = v3*16 + digitToInt h4
	_ -> error "incomplete Unicode escape sequence"
javaPrep (c:s) = c:javaPrep s

-------------------- Abstract Syntax Trees --------------------


type Identifier = String
type Name = [Identifier]

data Token = TokKeyword String
	   | TokIdent Identifier
	   | TokSymbol String
	   | TokInt Integer Bool
	   | TokFloat Double Bool
	   | TokChar Char
	   | TokString String
	   | TokBool Bool
	   | TokNull

instance Eq Token where
	TokKeyword s == TokKeyword s'		= s == s'
	TokIdent s == TokIdent s'		= s == s'
	TokSymbol s == TokSymbol s'		= s == s'
	TokInt i l == TokInt i' l'		= i == i' && l == l'
	TokFloat f l == TokFloat f' l'		= f == f' && l == l'
	TokChar c == TokChar c'			= c == c'
	TokString s == TokString s'		= s == s'
	_ == _					= False

instance Show Token where
	show (TokKeyword s)		= "reserved word " ++ show s
	show (TokIdent s)		= "identifier " ++ show s
	show (TokSymbol s)		= "symbol " ++ show s
	show (TokInt i l)		= show i ++ (if l then "l" else "")
	show (TokFloat f l)		= show f ++ (if l then "l" else "")
	show (TokChar c)		= show c
	show (TokString s)		= show s

data Expression = ExpLiteral Token
		| ExpIdent Identifier
		| ExpPrefix String Expression
		| ExpPostfix String Expression
		| ExpBinary String Expression Expression
		| ExpSelect Expression Expression
		| ExpInstanceof Expression DeclType
		| ExpNewClass DeclType [Expression] (Maybe [Declaration])
		| ExpNewArray DeclType [Maybe Expression] (Maybe [Initializer])
		| ExpCall Expression [Expression]
		| ExpArray Expression (Maybe Expression)
		| ExpCast DeclType Expression
		| ExpCond Expression Expression Expression
		| ExpThis
		| ExpSuper
		| ExpClass

type Modifier = String

data DeclType =   DtBasic String Int
		| DtIdent [Identifier] Int

type Declarator = (Identifier, Int, Maybe Initializer)

data Declaration =
		  DeclSimple [Modifier] DeclType [Declarator]
		| DeclMethod [Modifier] (Maybe DeclType) Identifier
				[FormalParam] Int [Name]
				(Maybe [Statement])
		| DeclConstructor [Modifier] Identifier
				[FormalParam] [Name] [Statement]
		| DeclClass [Modifier] Identifier (Maybe DeclType) [DeclType]
				[Declaration]
		| DeclInterface [Modifier] Identifier [DeclType]
				[Declaration]
		| DeclBlock Bool [Statement]

-- formal parameter: "final" flag, type, parameter name, array dimension
type FormalParam = (Bool, DeclType, Identifier, Int)

data Initializer =
		  IniExpr Expression
		| IniList [Initializer]

data SwitchGroup =
		  SwCase Expression [Statement]
		| SwDefault [Statement]

data ForInit =	  FiExpr [Expression]
		| FiDecl Bool DeclType [Declarator]
		| FiNone

data Statement =  StLabel Identifier Statement
		| StCase Expression Statement
		| StDefault Statement
		| StDecl Declaration
		| StExpr Expression
		| StBlock [Statement]
		| StIf Expression Statement (Maybe Statement)
		| StSwitch Expression [SwitchGroup]
		| StWhile Expression Statement
		| StDo Statement Expression
		| StFor ForInit (Maybe Expression)
			[Expression] Statement
		| StTry [Statement] [CatchClause] (Maybe [Statement])
		| StSynch Expression [Statement]
		| StContinue (Maybe Identifier)
		| StBreak (Maybe Identifier)
		| StReturn (Maybe Expression)
		| StThrow Expression
		| StNull

-- catch clause: 
type CatchClause = (FormalParam, [Statement])

-- import declaration: qualified name, ".*" flag
type ImportDecl = (Name, Bool)

-- compilation unit: package name, import declarations, type declarations
type CompUnit = (Maybe Name, [ImportDecl], [Declaration])

instance Show Expression where
	show expr = cprintExpr 0 0 expr

instance Show Statement where
	show stmt = cprintStmt 0 stmt

cprintExpr indent prec expr = undefined

cprintStmt indent stmt = undefined


-------------------- Packrat Parsing --------------------

data JavaDerivs = JavaDerivs {
		cdPos		:: Pos,
		cdText		:: String,
		cdChar		:: Result JavaDerivs Char,
		cdTok		:: TokDerivs,
		cdExpr		:: ExprDerivs,
		cdStmt		:: StmtDerivs,
		cdDecl		:: DeclDerivs
	}

data TokDerivs = TokDerivs {
		tdWhitespace	:: Result JavaDerivs (),
		tdWord		:: Result JavaDerivs Token,
		tdSym		:: Result JavaDerivs Token,
		tdHexLit	:: Result JavaDerivs Token,
		tdOctLit	:: Result JavaDerivs Token,
		tdDecLit	:: Result JavaDerivs Token,
		tdFloatSize	:: Result JavaDerivs Bool,
		tdFloatExp	:: Result JavaDerivs Integer,
		tdFloatLit	:: Result JavaDerivs Token,
		tdCharLit	:: Result JavaDerivs Token,
		tdStringLit	:: Result JavaDerivs Token,
		tdToken		:: Result JavaDerivs Token
	}

data ExprDerivs = ExprDerivs {
		edParExpr	:: Result JavaDerivs Expression,
		edPrimExpr	:: Result JavaDerivs Expression,
		edPostfixExpr	:: Result JavaDerivs Expression,
		edPrefixExpr	:: Result JavaDerivs Expression,
		edMultExpr	:: Result JavaDerivs Expression,
		edAddExpr	:: Result JavaDerivs Expression,
		edShiftExpr	:: Result JavaDerivs Expression,
		edRelExpr	:: Result JavaDerivs Expression,
		edEqExpr	:: Result JavaDerivs Expression,
		edAndExpr	:: Result JavaDerivs Expression,
		edXorExpr	:: Result JavaDerivs Expression,
		edOrExpr	:: Result JavaDerivs Expression,
		edCondAndExpr	:: Result JavaDerivs Expression,
		edCondOrExpr	:: Result JavaDerivs Expression,
		edCondExpr	:: Result JavaDerivs Expression,
		edAssignExpr	:: Result JavaDerivs Expression,
		edExpression	:: Result JavaDerivs Expression
	}

data StmtDerivs = StmtDerivs {
		sdCatchClause	:: Result JavaDerivs CatchClause,
		sdSwitchGroup	:: Result JavaDerivs SwitchGroup,
		sdForInit	:: Result JavaDerivs ForInit,
		sdStatement	:: Result JavaDerivs Statement,
		sdBlockStmt	:: Result JavaDerivs Statement,
		sdBlock		:: Result JavaDerivs [Statement]
	}

data DeclDerivs = DeclDerivs {
		ddModifier	:: Result JavaDerivs Modifier,
		ddDeclType	:: Result JavaDerivs DeclType,
		ddFormalParam	:: Result JavaDerivs FormalParam,
		ddFormalParams	:: Result JavaDerivs [FormalParam],
		ddDeclarator	:: Result JavaDerivs Declarator,
		ddDeclaration	:: Result JavaDerivs Declaration,
		ddInitializer	:: Result JavaDerivs Initializer,
		ddArrayInit	:: Result JavaDerivs [Initializer],
		ddImportDecl	:: Result JavaDerivs ImportDecl,
		ddCompUnit	:: Result JavaDerivs CompUnit
	}


instance Derivs JavaDerivs where
	dvPos d = cdPos d
	dvChar d = cdChar d


whitespace	= tdWhitespace	. cdTok
word		= tdWord	. cdTok
sym		= tdSym		. cdTok
hexLit		= tdHexLit	. cdTok
octLit		= tdOctLit	. cdTok
decLit		= tdDecLit	. cdTok
floatSize	= tdFloatSize	. cdTok
floatExp	= tdFloatExp	. cdTok
floatLit	= tdFloatLit	. cdTok
charLit		= tdCharLit	. cdTok
stringLit	= tdStringLit	. cdTok
token		= tdToken	. cdTok

--parExpr		= edParExpr	. cdExpr
--primExpr	= edPrimExpr	. cdExpr
--postfixExpr	= edPostfixExpr	. cdExpr
--prefixExpr	= edPrefixExpr	. cdExpr
--multExpr	= edMultExpr	. cdExpr
--addExpr		= edAddExpr	. cdExpr
--shiftExpr	= edShiftExpr	. cdExpr
--relExpr		= edRelExpr	. cdExpr
--eqExpr		= edEqExpr	. cdExpr
--andExpr		= edAndExpr	. cdExpr
--xorExpr		= edXorExpr	. cdExpr
--orExpr		= edOrExpr	. cdExpr
--condAndExpr	= edCondAndExpr	. cdExpr
--condOrExpr	= edCondOrExpr	. cdExpr
--condExpr	= edCondExpr	. cdExpr
--assignExpr	= edAssignExpr	. cdExpr
--expression	= edExpression	. cdExpr

--catchClause	= sdCatchClause	. cdStmt
--switchGroup	= sdSwitchGroup	. cdStmt
--forInit		= sdForInit	. cdStmt
--statement	= sdStatement	. cdStmt
--blockStmt	= sdBlockStmt	. cdStmt
--block		= sdBlock	. cdStmt

--modifier	= ddModifier	. cdDecl
--declType	= ddDeclType	. cdDecl
--formalParam	= ddFormalParam . cdDecl
--formalParams	= ddFormalParams. cdDecl
--declarator	= ddDeclarator	. cdDecl
--declaration	= ddDeclaration	. cdDecl
--initializer	= ddInitializer	. cdDecl
--arrayInit	= ddArrayInit	. cdDecl
--importDecl	= ddImportDecl	. cdDecl
--compUnit	= ddCompUnit	. cdDecl

parExpr		= Parser (edParExpr	. cdExpr)
primExpr	= Parser (edPrimExpr	. cdExpr)
postfixExpr	= Parser (edPostfixExpr	. cdExpr)
prefixExpr	= Parser (edPrefixExpr	. cdExpr)
multExpr	= Parser (edMultExpr	. cdExpr)
addExpr		= Parser (edAddExpr	. cdExpr)
shiftExpr	= Parser (edShiftExpr	. cdExpr)
relExpr		= Parser (edRelExpr	. cdExpr)
eqExpr		= Parser (edEqExpr	. cdExpr)
andExpr		= Parser (edAndExpr	. cdExpr)
xorExpr		= Parser (edXorExpr	. cdExpr)
orExpr		= Parser (edOrExpr	. cdExpr)
condAndExpr	= Parser (edCondAndExpr	. cdExpr)
condOrExpr	= Parser (edCondOrExpr	. cdExpr)
condExpr	= Parser (edCondExpr	. cdExpr)
assignExpr	= Parser (edAssignExpr	. cdExpr)
expression	= Parser (edExpression	. cdExpr)

catchClause	= Parser (sdCatchClause	. cdStmt)
switchGroup	= Parser (sdSwitchGroup	. cdStmt)
forInit		= Parser (sdForInit	. cdStmt)
statement	= Parser (sdStatement	. cdStmt)
blockStmt	= Parser (sdBlockStmt	. cdStmt)
block		= Parser (sdBlock	. cdStmt)

modifier	= Parser (ddModifier	. cdDecl)
declType	= Parser (ddDeclType	. cdDecl)
formalParam	= Parser (ddFormalParam . cdDecl)
formalParams	= Parser (ddFormalParams. cdDecl)
declarator	= Parser (ddDeclarator	. cdDecl)
declaration	= Parser (ddDeclaration	. cdDecl)
initializer	= Parser (ddInitializer	. cdDecl)
arrayInit	= Parser (ddArrayInit	. cdDecl)
importDecl	= Parser (ddImportDecl	. cdDecl)
compUnit	= Parser (ddCompUnit	. cdDecl)

-------------------- Lexical Structure --------------------

lineTerminator :: JavaDerivs -> Result JavaDerivs ()
lineTerminator d =
	case dvChar d of
	  Parsed '\r' d' e' ->
	    case dvChar d' of
	      Parsed '\n' d'' e'' -> Parsed () d'' e''
	      Parsed _ d'' e'' -> Parsed () d' e'
	      NoParse e'' -> NoParse e''
	  Parsed '\n' d' e' -> Parsed () d' e'
	  Parsed _ d' e' -> NoParse (nullError d)
	  NoParse e' -> NoParse e'

-- Whitespace

spaceChar :: JavaDerivs -> Result JavaDerivs ()
spaceChar d =
	case dvChar d of
	  Parsed c d' e' ->
		if isSpace c then Parsed () d' e'
		else NoParse (nullError d)
	  NoParse e' -> NoParse e'

traditionalCommentRest :: JavaDerivs -> Result JavaDerivs ()
traditionalCommentRest d =
	case dvChar d of
	  Parsed '*' d' e' ->
	    case dvChar d' of
	      Parsed '/' d'' e'' -> Parsed () d'' e''
	      _ -> traditionalCommentRest d'
	  Parsed _ d' e' -> traditionalCommentRest d'
	  NoParse e' -> NoParse e'

traditionalComment :: JavaDerivs -> Result JavaDerivs ()
traditionalComment d =
	case dvChar d of
	  Parsed '/' d' e' ->
	    case dvChar d' of
	      Parsed '*' d'' e'' -> traditionalCommentRest d''
	      _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)

endOfLineCommentRest :: JavaDerivs -> Result JavaDerivs ()
endOfLineCommentRest d =
	case lineTerminator d of
	  Parsed _ d' e' -> Parsed () d' e'
	  _ ->
	    case dvChar d of
	      Parsed _ d' e' -> endOfLineCommentRest d'
	      NoParse e' -> NoParse e'

endOfLineComment :: JavaDerivs -> Result JavaDerivs ()
endOfLineComment d =
	case dvChar d of
	  Parsed '/' d' e' ->
	    case dvChar d' of
	      Parsed '/' d'' e'' -> endOfLineCommentRest d''
	      _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)

pWhitespace :: JavaDerivs -> Result JavaDerivs ()
pWhitespace d =
	case spaceChar d of
	  Parsed _ d' e' -> whitespace d'
	  _ ->
	    case traditionalComment d of
	      Parsed _ d' e' -> whitespace d'
	      _ ->
		case endOfLineComment d of
		  Parsed _ d' e' -> whitespace d'
		  _ -> Parsed () d (nullError d)


-- Keywords and identifiers

keywords = [
	"abstract",
	"boolean", "break", "byte",
	"case", "catch", "char", "class", "const", "continue",
	"default", "do", "double",
	"else", "extends",
	"final", "finally", "float", "for",
	"goto",
	"if", "implements", "import", "instanceof", "int", "interface",
	"long",
	"native", "new",
	"package", "private", "protected", "public",
	"return",
	"short", "static", "strictfp", "super", "switch", "synchronized",
	"this", "throw", "throws", "transient", "try",
	"void", "volatile",
	"while"
    ]

isIdentStart c = isAlpha c || c == '_'
isIdentCont c = isIdentStart c || isDigit c

pWordRest :: JavaDerivs -> Result JavaDerivs String
pWordRest d =
	case dvChar d of
	  Parsed c d' e' ->
	    if isIdentCont c
	    then case pWordRest d' of
	           Parsed w d'' e'' -> Parsed (c:w) d'' e''
	    else case whitespace d of
		   Parsed _ d'' e'' -> Parsed [] d'' e''
	  _ -> Parsed [] d (nullError d)

pWord :: JavaDerivs -> Result JavaDerivs Token
pWord d =
	case dvChar d of
	  Parsed c d' e' ->
	    if isIdentStart c
	    then case pWordRest d' of
		   Parsed w d'' e'' -> Parsed (interp (c:w)) d'' e''
	    else NoParse (nullError d)
	  _ -> NoParse (nullError d)

	where interp w =
		case w of
			"null" -> TokNull
			"true" -> TokBool True
			"false" -> TokBool False
			_ -> if w `elem` keywords
				then TokKeyword w
				else TokIdent w

-- Recognize an operator or punctuation symbol.
-- There are certainly more readable alternative ways to code this,
-- but the approach here makes very simple and direct use of pattern matching
-- to produce an efficient decision tree.
-- This code simulates what an automated packrat parser generator might create
-- for rules with many alternatives matching simple constant strings.
pSym :: JavaDerivs -> Result JavaDerivs Token
pSym d =
	case dvChar d of
	  Parsed '<' d' e' ->
	    case dvChar d' of
	      Parsed '<' d'' e'' ->
		case dvChar d'' of
		  Parsed '=' d''' e''' ->
		    case whitespace d''' of
		      Parsed _ d'''' e'''' ->
			Parsed (TokSymbol "<<=") d'''' e''''
		  _ -> case whitespace d'' of 
			 Parsed _ d''' e''' ->
			   Parsed (TokSymbol "<<") d''' e'''
	      Parsed '=' d'' e'' ->
		case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "<=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "<") d'' e''

	  Parsed '>' d' e' ->
	    case dvChar d' of
	      Parsed '>' d'' e'' ->
		case dvChar d'' of
		  Parsed '>' d''' e''' ->
		    case dvChar d''' of
		      Parsed '=' d'''' e'''' ->
			case whitespace d'''' of
			  Parsed _ e''''' d''''' ->
			    Parsed (TokSymbol ">>>=") e''''' d'''''
		      _ -> case whitespace d''' of
			     Parsed _ d'''' e'''' ->
			       Parsed (TokSymbol ">>>") d'''' e''''
		  Parsed '=' d''' e''' ->
		    case whitespace d''' of
		      Parsed _ d'''' e'''' ->
			Parsed (TokSymbol ">>=") d'''' e''''
		  _ -> case whitespace d'' of 
			 Parsed _ d''' e''' ->
			   Parsed (TokSymbol ">>") d''' e'''
	      Parsed '=' d'' e'' ->
		case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol ">=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol ">") d'' e''

	  Parsed '+' d' e' ->
	    case dvChar d' of
	      Parsed '+' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "++") d''' e'''
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "+=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "+") d'' e''

	  Parsed '-' d' e' ->
	    case dvChar d' of
	      Parsed '-' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "--") d''' e'''
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "-=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "-") d'' e''

	  Parsed '*' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "*=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "*") d'' e''

	  Parsed '/' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "/=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "/") d'' e''

	  Parsed '%' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "%=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "%") d'' e''

	  Parsed '&' d' e' ->
	    case dvChar d' of
	      Parsed '&' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "&&") d''' e'''
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "&=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "&") d'' e''

	  Parsed '^' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "^=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "^") d'' e''

	  Parsed '|' d' e' ->
	    case dvChar d' of
	      Parsed '|' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "||") d''' e'''
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "|=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "|") d'' e''

	  Parsed '=' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "==") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "=") d'' e''

	  Parsed '!' d' e' ->
	    case dvChar d' of
	      Parsed '=' d'' e'' ->
	        case whitespace d'' of
		  Parsed _ d''' e''' -> Parsed (TokSymbol "!=") d''' e'''
	      _ -> case whitespace d' of
		     Parsed _ d'' e'' -> Parsed (TokSymbol "!") d'' e''

	  Parsed c d' e' ->
	    if c `elem` ";:,.{}[]()~?"
	    then case whitespace d' of
		   Parsed _ d'' e'' -> Parsed (TokSymbol [c]) d'' e''
	    else NoParse (nullError d)

	  NoParse e' -> NoParse e'



-- Integer literals

pIntTypeSuffix :: JavaDerivs -> Result JavaDerivs Bool
pIntTypeSuffix d =
	case dvChar d of
	  Parsed 'l' d' e' -> ws True d'
	  Parsed 'L' d' e' -> ws True d'
	  _ -> ws False d
	where ws islong d' =
		case whitespace d' of
		  Parsed _ d'' e'' -> Parsed islong d'' e''

pHexDigits :: JavaDerivs -> Result JavaDerivs (Integer, Integer)
pHexDigits d =
	case dvChar d of
	  Parsed c d' e' ->
	    if isHexDigit c
	    then case pHexDigits d' of
		   Parsed (v,n) d'' e'' ->
		     Parsed (v + toInteger (digitToInt c) * 16^n, n+1) d'' e''
		   _ ->
		     Parsed (toInteger (digitToInt c), 1) d' e'
	    else NoParse (nullError d)
	  _ -> NoParse (nullError d)

pHexLit :: JavaDerivs -> Result JavaDerivs Token
pHexLit d =
	case dvChar d of
	  Parsed '0' d' e' ->
	    case dvChar d' of
	      Parsed 'x' d'' e'' -> digs d''
	      Parsed 'X' d'' e'' -> digs d''
	      _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)

	where digs d'' =
		case pHexDigits d'' of
		  Parsed (v,n) d''' e''' ->
		    case pIntTypeSuffix d''' of
		      Parsed l d'''' e'''' -> Parsed (TokInt v l) d'''' e''''
		  _ -> NoParse (nullError d)

pOctDigits :: JavaDerivs -> Result JavaDerivs (Integer, Integer)
pOctDigits d =
	case dvChar d of
	  Parsed c d' e' ->
	    if isOctDigit c
	    then case pOctDigits d' of
		   Parsed (v,n) d'' e'' ->
		     Parsed (v + toInteger (digitToInt c) * 8^n, n+1) d'' e''
		   _ ->
		     Parsed (toInteger (digitToInt c), 1) d' e'
	    else NoParse (nullError d)
	  _ -> NoParse (nullError d)

pOctLit :: JavaDerivs -> Result JavaDerivs Token
pOctLit d =
	case dvChar d of
	  Parsed '0' d' e' ->
		case pOctDigits d' of
		  Parsed (v,n) d'' e'' ->
		    case pIntTypeSuffix d'' of
		      Parsed l d''' e''' -> Parsed (TokInt v l) d''' e'''
		  _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)

pDecDigits :: JavaDerivs -> Result JavaDerivs (Integer, Integer)
pDecDigits d =
	case dvChar d of
	  Parsed c d' e' ->
	    if isDigit c
	    then case pDecDigits d' of
		   Parsed (v,n) d'' e'' ->
		     Parsed (v + toInteger (digitToInt c) * 10^n, n+1) d'' e''
		   _ ->
		     Parsed (toInteger (digitToInt c), 1) d' e'
	    else NoParse (nullError d)
	  _ -> NoParse (nullError d)

pDecLit :: JavaDerivs -> Result JavaDerivs Token
pDecLit d =
	case pDecDigits d of
	  Parsed (v,n) d' e' ->
	    case pIntTypeSuffix d' of
	      Parsed l d'' e'' -> Parsed (TokInt v l) d'' e''
	  _ -> NoParse (nullError d)


-- Floating-point literals

scanDec :: String -> Integer
scanDec digits = foldl f 0 digits
	where f v c = v * 10 + toInteger (digitToInt c)

pFloatSize :: JavaDerivs -> Result JavaDerivs Bool
Parser pFloatSize = (do { s <- oneOf "dD"; return True })
		</> (do { s <- oneOf "fF"; return False })

pFloatExp :: JavaDerivs -> Result JavaDerivs Integer
Parser pFloatExp =
	do	oneOf "eE"
		neg <- plusminus
		digits <- many1 digit
		let f v c = v * 10 + toInteger (digitToInt c)
		    val = foldl f 0 digits
		return (if neg then -val else val)
	where plusminus = (do { char '+'; return False })
		      </> (do { char '-'; return True })
		      </> return False

pFloatLit :: JavaDerivs -> Result JavaDerivs Token
Parser pFloatLit =  (do i <- many1 digit
			char '.'
			f <- many digit
			e <- Parser floatExp </> return 0
			s <- Parser floatSize </> return False
			Parser whitespace
			return (mkfloat (scanDec i) f e s))
		</> (do char '.'
			f <- many1 digit
			e <- Parser floatExp </> return 0
			s <- Parser floatSize </> return False
			Parser whitespace
			return (mkfloat 0 f e s))
		</> (do i <- many1 digit
			e <- Parser floatExp
			s <- Parser floatSize </> return False
			Parser whitespace
			return (mkfloat (scanDec i) [] e s))
		</> (do i <- many1 digit
			e <- Parser floatExp </> return 0
			s <- Parser floatSize
			Parser whitespace
			return (mkfloat (scanDec i) [] e s))
	where mkfloat :: Integer -> String -> Integer -> Bool -> Token
	      mkfloat i f e s = TokFloat (scanfrac i f * 10.0**(fromInteger e))
					 s

	      scanfrac :: Integer -> String -> Double
	      scanfrac i [] = fromInteger i
	      scanfrac i (c:cs) =
			scanfrac (i * 10 + toInteger (digitToInt c)) cs / 10.0


-- Character and string literals

quotedChar quote d =
	case dvChar d of
	  Parsed '\\' d' e' ->
	    case dvChar d' of
	      Parsed c d'' e'' ->
		case c of
		  'n' -> Parsed '\n' d'' e''
		  'r' -> Parsed '\r' d'' e''
		  't' -> Parsed '\t' d'' e''
		  'v' -> Parsed '\v' d'' e''
		  'f' -> Parsed '\f' d'' e''
		  '\\' -> Parsed '\\' d'' e''
		  '\'' -> Parsed '\'' d'' e''
		  '\"' -> Parsed '\"' d'' e''
		  -- XXX octal characters, other escapes
		  _ -> NoParse (msgError (dvPos d) "invalid escape sequence")
	      _ -> NoParse (nullError d)
	  Parsed c d' e' ->
	    if c /= quote
	    then Parsed c d' e'
	    else NoParse (nullError d)
	  _ -> NoParse (nullError d)

pCharLit :: JavaDerivs -> Result JavaDerivs Token
pCharLit d =
	case dvChar d of
	  Parsed '\'' d' e' ->
	    case quotedChar '\'' d' of
	      Parsed c d'' e'' ->
		case dvChar d'' of
		  Parsed '\'' d''' e''' ->
		    case whitespace d''' of
		      Parsed _ d'''' e'''' -> Parsed (TokChar c) d'''' e''''
		  _ -> NoParse (nullError d)
	      _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)

stringLitChars :: JavaDerivs -> Result JavaDerivs String
stringLitChars d =
	case quotedChar '"' d of
	  Parsed c d' e' ->
	    case stringLitChars d' of
	      Parsed s d'' e'' -> Parsed (c:s) d'' e''
	  _ -> Parsed [] d (nullError d)

pStringLit :: JavaDerivs -> Result JavaDerivs Token
pStringLit d =
	case dvChar d of
	  Parsed '"' d' e' ->
	    case stringLitChars d' of
	      Parsed s d'' e'' ->
		case dvChar d'' of
		  Parsed '"' d''' e''' ->
		    case whitespace d''' of
		      Parsed _ d'''' e'''' -> Parsed (TokString s) d'''' e''''
		  _ -> NoParse (nullError d)
	      _ -> NoParse (nullError d)
	  _ -> NoParse (nullError d)


-- Token tie-up

pToken :: JavaDerivs -> Result JavaDerivs Token
pToken d = 
	case word d of 
	  r @ (Parsed t d' e') -> r
	  _ ->
	    case sym d of
	      r @ (Parsed t d' e') -> r
	      _ ->
		case charLit d of
		  r @ (Parsed t d' e') -> r
		  _ ->
		    case stringLit d of
		      r @ (Parsed t d' e') -> r
		      _ ->
			case floatLit d of
			  r @ (Parsed t d' e') -> r
			  _ ->
			    case hexLit d of
			      r @ (Parsed t d' e') -> r
			      _ ->
				case octLit d of
				  r @ (Parsed t d' e') -> r
				  _ ->
				    case decLit d of
				      r @ (Parsed t d' e') -> r
				      _ -> NoParse (nullError d)

keyword :: String -> Parser JavaDerivs String
keyword w = Parser parse
	where parse d = 
		case token d of
		  Parsed (TokKeyword w') d' e' ->
			if w' == w then Parsed w d' e' else none d
		  _ -> none d
	      none d = NoParse (expError (dvPos d) (show w))

symbol :: String -> Parser JavaDerivs String
symbol s = Parser parse
	where parse d =
		case token d of
		  Parsed (TokSymbol s') d' e' ->
			if s' == s then Parsed s d' e' else none d
		  _ -> none d
	      none d = NoParse (expError (dvPos d) (show s))

identifier :: Parser JavaDerivs Identifier
identifier = Parser parse
	where parse d =
		case token d of
		  Parsed (TokIdent s) d' e' -> Parsed s d' e'
		  _ -> NoParse (expError (dvPos d) "identifier")


-------------------- Expressions --------------------

arguments = do	symbol "("; eargs <- sepBy expression (symbol ","); symbol ")"
		return eargs

pParExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pParExpr =
	do symbol "("; e <- expression; symbol ")"; return e
 
pPrimExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pPrimExpr =
	    (do t <- Parser token
		case t of
			TokIdent s	-> return (ExpIdent s)
			TokInt i l	-> return (ExpLiteral t)
			TokFloat f l	-> return (ExpLiteral t)
			TokChar c	-> return (ExpLiteral t)
			TokString c	-> return (ExpLiteral t)
			TokBool b	-> return (ExpLiteral t)
			TokNull		-> return (ExpLiteral t)
			_		-> fail ("found " ++ show t))
	</> parExpr
	</> (do keyword "this"; return ExpThis)
	</> (do keyword "super"; return ExpSuper)
	</> (do keyword "class"; return ExpClass)
	</> (do keyword "new"		-- class creator
		ty <- declType
		args <- arguments
		body <- optional classBody
		return (ExpNewClass ty args body))
	</> (do keyword "new"		-- array creator
		ty <- declType
		dims <- many (do	symbol "["	-- XXX many1
					e <- optional expression
					symbol "]"
					return e)
		init <- optional arrayInit
		return (ExpNewArray ty dims init))
	<?> "primary expression"

suffix :: Parser JavaDerivs (Expression -> Expression)
suffix =
	    (do symbol "["; eidx <- optional expression; symbol "]"
		return (\ebase -> ExpArray ebase eidx))
	</> (do eargs <- arguments
		return (\efunc -> ExpCall efunc eargs))
	</> (do symbol "."; eitem <- primExpr
		return (\econtext -> ExpSelect econtext eitem))
	</> (do op <- (symbol "++" </> symbol "--")
		return (\e -> ExpPostfix op e))

pPostfixExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pPostfixExpr =
	    (do exp <- primExpr
		suffixes <- many suffix
		return (foldl (\e s -> s e) exp suffixes))
	<?> "postfix expression"

pPrefixExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pPrefixExpr =
	    (do op <- (symbol "++" </> symbol "--" </>
			symbol "+" </> symbol "-" </>
			symbol "~" </> symbol "!")
		exp <- prefixExpr
		return (ExpPostfix op exp))
	</> (do symbol "("; t <- declType; symbol ")"; e <- prefixExpr
		return (ExpCast t e))
	</> postfixExpr
	<?> "prefix expression"

pMultExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pMultExpr =
	    chainl1 prefixExpr
		(do op <- (symbol "*" </> symbol "/" </> symbol "%")
		    return (\l r -> ExpBinary op l r))

pAddExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pAddExpr =
	    chainl1 multExpr
		(do op <- (symbol "+" </> symbol "-")
		    return (\l r -> ExpBinary op l r))

pShiftExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pShiftExpr =
	    chainl1 addExpr
		(do op <- (symbol "<<" </> symbol ">>" </> symbol ">>>")
		    return (\l r -> ExpBinary op l r))

pRelExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pRelExpr =
	do l <- shiftExpr; suffix l
	where suffix l =
		    (do op <- (symbol "<=" </> symbol ">=" </>
				symbol "<" </> symbol ">")
			r <- shiftExpr
			suffix (ExpBinary op l r))
		</> (do keyword "instanceof"
			t <- declType
			suffix (ExpInstanceof l t))
		</> return l

pEqExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pEqExpr =
	    chainl1 relExpr
		(do op <- (symbol "==" </> symbol "!=")
		    return (\l r -> ExpBinary op l r))

pAndExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pAndExpr =
	    chainl1 eqExpr
		(do op <- symbol "&"
		    return (\l r -> ExpBinary op l r))

pXorExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pXorExpr =
	    chainl1 andExpr
		(do op <- symbol "^"
		    return (\l r -> ExpBinary op l r))

pOrExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pOrExpr =
	    chainl1 xorExpr
		(do op <- symbol "|"
		    return (\l r -> ExpBinary op l r))

pCondAndExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pCondAndExpr =
	    chainl1 orExpr
		(do op <- symbol "&&"
		    return (\l r -> ExpBinary op l r))

pCondOrExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pCondOrExpr =
	    chainl1 condAndExpr
		(do op <- symbol "||"
		    return (\l r -> ExpBinary op l r))

pCondExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pCondExpr =
	    (do c <- condOrExpr; symbol "?"
		t <- expression; symbol ":"
		f <- condExpr
		return (ExpCond c t f))
	</> condOrExpr
	<?> "conditional expression"

pAssignExpr :: JavaDerivs -> Result JavaDerivs Expression
Parser pAssignExpr =
	    (do l <- prefixExpr
		op <- (symbol "=" </>
			symbol "*=" </> symbol "/=" </> symbol "%=" </>
			symbol "+=" </> symbol "-=" </>
			symbol "<<=" </> symbol ">>=" </> symbol ">>>=" </>
			symbol "&=" </> symbol "^=" </> symbol "|=")
		r <- assignExpr
		return (ExpBinary op l r))
	</> condExpr
	<?> "assignment expression"

pExpression :: JavaDerivs -> Result JavaDerivs Expression
pExpression = pAssignExpr


-------------------- Statements --------------------

pCatchClause :: JavaDerivs -> Result JavaDerivs CatchClause
Parser pCatchClause =
	    (do keyword "catch"
		symbol "("
		p <- formalParam
		symbol ")"
		b <- block
		return (p,b))

pSwitchGroup :: JavaDerivs -> Result JavaDerivs SwitchGroup
Parser pSwitchGroup =
	    (do keyword "case"; e <- expression; symbol ":"
		s <- many blockStmt
		return (SwCase e s))
	</> (do keyword "default"; symbol ":"
		s <- many blockStmt
		return (SwDefault s))
	<?> "switch statement group"

pForInit :: JavaDerivs -> Result JavaDerivs ForInit
Parser pForInit =
	    (do f <- (do keyword "final"; return True) </> (return False)
		t <- declType
		d <- sepBy1 declarator (symbol ",")
		return (FiDecl f t d))
	</> (do es <- sepBy expression (symbol ",")
		return (FiExpr es))
	</> return FiNone

pStatement :: JavaDerivs -> Result JavaDerivs Statement
Parser pStatement =
	    (do b <- block
		return (StBlock b))
	</> (do keyword "if"; e <- parExpr
		t <- statement; keyword "else"; f <- statement
		return (StIf e t (Just f)))
	</> (do keyword "if"; e <- parExpr
		t <- statement
		return (StIf e t Nothing))
	</> (do keyword "for"; symbol "("
		i <- forInit; symbol ";"
		c <- optional expression; symbol ";"
		n <- sepBy expression (symbol ","); symbol ")"
		b <- statement
		return (StFor i c n b))
	</> (do keyword "while"; e <- parExpr
		b <- statement
		return (StWhile e b))
	</> (do keyword "do"; b <- statement; keyword "while"
		e <- parExpr; symbol ";"
		return (StDo b e))
	</> (do keyword "try"
		b <- block
		c <- many catchClause
		f <- optional (do keyword "finally"; block)
		return (StTry b c f))
	</> (do keyword "switch"; e <- parExpr
		symbol "{"; b <- many switchGroup; symbol "}"
		return (StSwitch e b))
	</> (do keyword "synchronized"; e <- parExpr; b <- block
		return (StSynch e b))
	</> (do keyword "return"; e <- optional expression; symbol ";"
		return (StReturn e))
	</> (do keyword "throw"; e <- expression; symbol ";"
		return (StThrow e))
	</> (do keyword "break"; i <- optional identifier; symbol ";"
		return (StBreak i))
	</> (do keyword "continue"; i <- optional identifier; symbol ";"
		return (StContinue i))
	</> (do i <- identifier; symbol ":"; s <- statement
		return (StLabel i s))
	</> (do e <- expression; symbol ";"
		return (StExpr e))
	</> (do symbol ";"
		return (StNull))
	<?> "statement"

pBlockStmt :: JavaDerivs -> Result JavaDerivs Statement
Parser pBlockStmt =
	    (do d <- declaration
		return (StDecl d))
	</> statement
	<?> "block statement"

pBlock :: JavaDerivs -> Result JavaDerivs [Statement]
Parser pBlock =
	(do symbol "{"; s <- many blockStmt; symbol "}"; return s)


-------------------- Declarations --------------------

qualName = sepBy1 identifier (symbol ".")

pModifier :: JavaDerivs -> Result JavaDerivs Modifier
Parser pModifier =
	keyword "public" </> keyword "protected" </> keyword "private" </>
	keyword "static" </> keyword "abstract" </> keyword "final" </>
	keyword "native" </> keyword "synchronized" </> keyword "transient" </>
	keyword "volatile" </> keyword "strictfp"

pDeclType :: JavaDerivs -> Result JavaDerivs DeclType
Parser pDeclType =
	    (do s <- keyword "byte" </> keyword "short" </> keyword "char" </>
		     keyword "int" </> keyword "long" </>
		     keyword "float" </> keyword "double" </> keyword "boolean"
		b <- many (do symbol "["; symbol "]")
		return (DtBasic s (length b)))
	</> (do i <- qualName
		b <- many (do symbol "["; symbol "]")
		return (DtIdent i (length b)))
	<?> "type"

pFormalParam :: JavaDerivs -> Result JavaDerivs FormalParam
Parser pFormalParam =
	do	f <- (do keyword "final"; return True) </> (return False)
		t <- declType
		i <- identifier
		a <- many (do symbol "["; symbol "]")
		return (f, t, i, length a)

pFormalParams :: JavaDerivs -> Result JavaDerivs [FormalParam]
Parser pFormalParams =
	do	symbol "("
		fs <- sepBy formalParam (symbol ",")
		symbol ")"
		return fs

pDeclarator :: JavaDerivs -> Result JavaDerivs Declarator
Parser pDeclarator =
	    (do ident <- identifier
		bkts <- many (do symbol "["; symbol "]")
		init <- optional (do symbol "="; initializer)
		return (ident, length bkts, init))
	<?> "declarator"

classBody = do symbol "{"; ds <- many declaration; symbol "}"; return ds

pDeclaration :: JavaDerivs -> Result JavaDerivs Declaration
Parser pDeclaration =
	    (do m <- many modifier		-- variable declaration
		t <- declType
		d <- sepBy declarator (symbol ",")
		symbol ";"
		return (DeclSimple m t d))
	</> (do m <- many modifier		-- method declaration
		t <- (do t <- declType; return (Just t)) </>
		     (do keyword "void"; return Nothing)
		i <- identifier
		p <- formalParams
		a <- many (do symbol "["; symbol "]")
		th <- throws
		b <- (do b <- block; return (Just b))
			</> (do symbol ";"; return Nothing)
		return (DeclMethod m t i p (length a) th b))
	</> (do m <- many modifier		-- constructor declaration
		i <- identifier
		p <- formalParams
		th <- throws
		b <- block
		return (DeclConstructor m i p th b))
	</> (do m <- many modifier		-- class declaration
		keyword "class"
		i <- identifier
		ext <- optional (do keyword "extends"; declType)
		imp <- (do keyword "implements"; sepBy1 declType (symbol ","))
			</> return []
		ds <- classBody
		return (DeclClass m i ext imp ds))
	</> (do m <- many modifier		-- interface declaration
		keyword "interface"
		i <- identifier
		ext <- (do keyword "extends"; sepBy1 declType (symbol ","))
			</> return []
		ds <- classBody
		return (DeclInterface m i ext ds))
	</> (do st <- (do keyword "static"; return True) </> (return False)
		b <- block
		return (DeclBlock st b))
	<?> "declaration"

	where throws = 
		    (do keyword "throws"; sepBy1 qualName (symbol ","))
		</> return []

pInitializer :: JavaDerivs -> Result JavaDerivs Initializer
Parser pInitializer =
	    (do inits <- arrayInit
		return (IniList inits))
	</> (do e <- expression
		return (IniExpr e))
	<?> "variable initializer"

pArrayInit :: JavaDerivs -> Result JavaDerivs [Initializer]
Parser pArrayInit =
	    (do symbol "{"
		inits <- sepEndBy initializer (symbol ",")
		symbol "}"
		return inits)
	<?> "array initializer"

pImportDecl :: JavaDerivs -> Result JavaDerivs ImportDecl
Parser pImportDecl =
	    (do keyword "import"
		name <- qualName
		all <- (do symbol "."; symbol "*"; return True)
			</> return False
		symbol ";"
		return (name, all))
	<?> "import declaration"

pCompUnit :: JavaDerivs -> Result JavaDerivs CompUnit
Parser pCompUnit =
	do	Parser whitespace
		p <- (do keyword "package"; n <- qualName; symbol ";"
			 return (Just n)) </> return Nothing
		i <- many importDecl
		t <- many declaration
		notFollowedBy anyChar
		return (p, i, t)

-------------------- Recursive Tie-Up --------------------

pTokDerivs dvs = TokDerivs whitespace word sym
			hexlit octlit declit
			floatsize floatexp floatlit
			charlit stringlit
			token
	where whitespace	= pWhitespace dvs
	      word		= pWord dvs
	      sym		= pSym dvs
	      hexlit		= pHexLit dvs
	      octlit		= pOctLit dvs
	      declit		= pDecLit dvs
	      floatsize		= pFloatSize dvs
	      floatexp		= pFloatExp dvs
	      floatlit		= pFloatLit dvs
	      charlit		= pCharLit dvs
	      stringlit		= pStringLit dvs
	      token		= pToken dvs

pExprDerivs dvs = ExprDerivs parexpr primexpr postfixexpr prefixexpr
			multexpr addexpr shiftexpr relexpr eqexpr
			andexpr xorexpr orexpr logandexpr logorexpr
			condexpr assignexpr expr
	where parexpr		= pParExpr dvs
	      primexpr		= pPrimExpr dvs
	      postfixexpr	= pPostfixExpr dvs
	      prefixexpr	= pPrefixExpr dvs
	      multexpr		= pMultExpr dvs
	      addexpr		= pAddExpr dvs
	      shiftexpr		= pShiftExpr dvs
	      relexpr		= pRelExpr dvs
	      eqexpr		= pEqExpr dvs
	      andexpr		= pAndExpr dvs
	      xorexpr		= pXorExpr dvs
	      orexpr		= pOrExpr dvs
	      logandexpr	= pCondAndExpr dvs
	      logorexpr		= pCondOrExpr dvs
	      condexpr		= pCondExpr dvs
	      assignexpr	= pAssignExpr dvs
	      expr		= pExpression dvs

pStmtDerivs dvs = StmtDerivs catch switch forinit statement blockstmt block
	where catch		= pCatchClause dvs
	      switch		= pSwitchGroup dvs
	      forinit		= pForInit dvs
	      statement		= pStatement dvs
	      blockstmt		= pBlockStmt dvs
	      block		= pBlock dvs

pDeclDerivs dvs = DeclDerivs modifier decltype formal formals
			declarator declaration initializer arrayinit
			importdecl compunit
	where modifier		= pModifier dvs
	      decltype		= pDeclType dvs
	      formal		= pFormalParam dvs
	      formals		= pFormalParams dvs
	      declarator	= pDeclarator dvs
	      declaration	= pDeclaration dvs
	      initializer	= pInitializer dvs
	      arrayinit		= pArrayInit dvs
	      importdecl	= pImportDecl dvs
	      compunit		= pCompUnit dvs

javaDerivs pos text = dvs
	where dvs = JavaDerivs pos text chr tok expr stmt decl
	      chr = case text of
			[] -> NoParse (eofError dvs)
			(c:cs) -> Parsed c (javaDerivs (nextPos pos c) cs)
					 (nullError dvs)
	      tok = pTokDerivs dvs
	      expr = pExprDerivs dvs
	      stmt = pStmtDerivs dvs
	      decl = pDeclDerivs dvs

javaParse :: String -> String -> JavaDerivs
javaParse name text = javaDerivs (Pos name 1 1) text

javaParseFile :: FilePath -> IO CompUnit
javaParseFile name =
	do	text <- readFile name
		let text' = javaPrep text
		    derivs = javaParse name text'
		case ddCompUnit (cdDecl derivs) of
			Parsed cu _ _ -> return cu
			NoParse e -> fail (show e)

