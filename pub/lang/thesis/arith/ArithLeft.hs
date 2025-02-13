-- Packrat parser for arithmetic expression language
-- supporting left-associative infix operators
module ArithLeft where


data Result v =
	  Parsed v Derivs
	| NoParse

data Derivs = Derivs {
		dvAdditive		:: Result Int,
		dvAdditiveSuffix	:: Result (Int -> Int),
		dvMultitive		:: Result Int,
		dvMultitiveSuffix	:: Result (Int -> Int),
		dvPrimary		:: Result Int,
		dvDecimal		:: Result Int,
		dvChar			:: Result Char
	}


-- Evaluate an expression and return the unpackaged result,
-- ignoring any unparsed remainder.
eval s = case dvAdditive (parse s) of
		Parsed v rem -> v
		_ -> error "Parse error"


-- Construct a (lazy) parse result structure for an input string,
-- in which any result can be computed in linear time
-- with respect to the length of the input.
parse :: String -> Derivs
parse s = d where
    d        = Derivs add addsuff mult multsuff prim dec chr
    add      = pAdditive d
    addsuff  = pAdditiveSuffix d
    mult     = pMultitive d
    multsuff = pMultitiveSuffix d
    prim     = pPrimary d
    dec      = pDecimal d
    chr      = case s of
                 (c:s') -> Parsed c (parse s')
                 [] -> NoParse


-- Parse an additive-precedence expression
-- Additive <- Multitive AdditiveSuffix
pAdditive :: Derivs -> Result Int
pAdditive d = case dvMultitive d of
		Parsed vleft d' ->
		  case dvAdditiveSuffix d' of
		    Parsed vsuff d'' ->
		      Parsed (vsuff vleft) d''
		    _ -> NoParse
		_ -> NoParse

-- Parse an additive-precedence expression suffix
pAdditiveSuffix :: Derivs -> Result (Int -> Int)
pAdditiveSuffix d = alt1 where

    -- AdditiveSuffix <- '+' Multitive AdditiveSuffix
    alt1 = case dvChar d of
	     Parsed '+' d' ->
	       case dvMultitive d' of
		 Parsed vright d'' ->
		   case dvAdditiveSuffix d'' of
		     Parsed vsuff d''' ->
		       Parsed (\vleft -> vsuff (vleft + vright)) d'''
		     _ -> alt2
		 _ -> alt2
	     _ -> alt2

    -- AdditiveSuffix <- '-' Multitive AdditiveSuffix
    alt2 = case dvChar d of
	     Parsed '-' d' ->
	       case dvMultitive d' of
		 Parsed vright d'' ->
		   case dvAdditiveSuffix d'' of
		     Parsed vsuff d''' ->
		       Parsed (\vleft -> vsuff (vleft - vright)) d'''
		     _ -> alt3
		 _ -> alt3
	     _ -> alt3

    -- AdditiveSuffix <- <empty>
    alt3 = Parsed (\v -> v) d


-- Parse a multiplicative-precedence expression
-- Multitive <- Primary MultitiveSuffix
pMultitive :: Derivs -> Result Int
pMultitive d = case dvPrimary d of
		 Parsed vleft d' ->
		   case dvMultitiveSuffix d' of
		     Parsed vsuff d'' ->
		       Parsed (vsuff vleft) d''
		     _ -> NoParse
		 _ -> NoParse

-- Parse a multiplicative-precedence expression suffix
pMultitiveSuffix :: Derivs -> Result (Int -> Int)
pMultitiveSuffix d = alt1 where

    -- MultitiveSuffix <- '*' Primary MultitiveSuffix
    alt1 = case dvChar d of
	     Parsed '*' d' ->
	       case dvPrimary d' of
		 Parsed vright d'' ->
		   case dvMultitiveSuffix d'' of
		     Parsed vsuff d''' ->
		       Parsed (\vleft -> vsuff (vleft * vright)) d'''
		     _ -> alt2
		 _ -> alt2
	     _ -> alt2

    -- MultitiveSuffix <- '/' Primary MultitiveSuffix
    alt2 = case dvChar d of
	     Parsed '/' d' ->
	       case dvPrimary d' of
		 Parsed vright d'' ->
		   case dvMultitiveSuffix d'' of
		     Parsed vsuff d''' ->
		       Parsed (\vleft -> vsuff (vleft `div` vright)) d'''
		     _ -> alt3
		 _ -> alt3
	     _ -> alt3

    -- MultitiveSuffix <- '%' Primary MultitiveSuffix
    alt3 = case dvChar d of
	     Parsed '%' d' ->
	       case dvPrimary d' of
		 Parsed vright d'' ->
		   case dvMultitiveSuffix d'' of
		     Parsed vsuff d''' ->
		       Parsed (\vleft -> vsuff (vleft `mod` vright)) d'''
		     _ -> alt4
		 _ -> alt4
	     _ -> alt4

    -- MultitiveSuffix <- <empty>
    alt4 = Parsed (\v -> v) d

-- Parse a primary expression
pPrimary :: Derivs -> Result Int
pPrimary d = alt1 where

    -- Primary <- '(' Additive ')'
    alt1 = case dvChar d of
	     Parsed '(' d' ->
	       case dvAdditive d' of
	         Parsed v d'' ->
	           case dvChar d'' of
	             Parsed ')' d''' -> Parsed v d'''
	             _ -> alt2
		 _ -> alt2
	     _ -> alt2

    -- Primary <- Decimal
    alt2 = case dvDecimal d of
	     Parsed v d' -> Parsed v d'
	     NoParse -> NoParse

-- Parse a decimal digit
pDecimal :: Derivs -> Result Int
pDecimal d = case dvChar d of
		Parsed '0' d' -> Parsed 0 d'
		Parsed '1' d' -> Parsed 1 d'
		Parsed '2' d' -> Parsed 2 d'
		Parsed '3' d' -> Parsed 3 d'
		Parsed '4' d' -> Parsed 4 d'
		Parsed '5' d' -> Parsed 5 d'
		Parsed '6' d' -> Parsed 6 d'
		Parsed '7' d' -> Parsed 7 d'
		Parsed '8' d' -> Parsed 8 d'
		Parsed '9' d' -> Parsed 9 d'
		_ -> NoParse


