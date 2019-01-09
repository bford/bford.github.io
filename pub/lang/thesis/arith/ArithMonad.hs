-- Monadic packrat parser for trivial arithmetic language
-- with left-associative operators and integrated lexical analysis.
-- Uses NO "unsafe" combinators containing hidden recursion.
module ArithMonad where

import Pos
import Parse


data ArithDerivs = ArithDerivs {
		advAdditive		:: Result ArithDerivs Int,
		advAdditiveSuffix	:: Result ArithDerivs (Int -> Int),
		advMultitive		:: Result ArithDerivs Int,
		advMultitiveSuffix	:: Result ArithDerivs (Int -> Int),
		advPrimary		:: Result ArithDerivs Int,

		advDecimal		:: Result ArithDerivs Int,
		advDigits		:: Result ArithDerivs (Int, Int),
		advDigit		:: Result ArithDerivs Int,
		advSymbol		:: Result ArithDerivs Char,
		advSpacing		:: Result ArithDerivs (),

		advChar			:: Result ArithDerivs Char,
		advPos			:: Pos
	}

instance Derivs ArithDerivs where
	dvChar d = advChar d
	dvPos d = advPos d


-- Evaluate an expression and return the unpackaged result,
-- ignoring any unparsed remainder.
eval s = case pExpression (parse (Pos "<input>" 1 1) s) of
	   Parsed v _ _ -> v
	   NoParse e -> error (show e)

	where	Parser pExpression =
			do	Parser advSpacing
				v <- Parser advAdditive
				notFollowedBy anyChar
				return v


-- Construct a (lazy) parse result structure for an input string,
-- in which any result can be computed in linear time
-- with respect to the length of the input.
parse :: Pos -> String -> ArithDerivs
parse pos s = d where
	d	= ArithDerivs add addsuf mult multsuf prim
			dec digs dig sym spc
			chr pos

	add	= pAdditive d
	addsuf	= pAdditiveSuffix d
	mult	= pMultitive d
	multsuf	= pMultitiveSuffix d
	prim	= pPrimary d

	dec	= pDecimal d
	digs	= pDigits d
	dig	= pDigit d
	sym	= pSymbol d
	spc	= pSpacing d

	chr	= case s of
			(c:s') -> Parsed c (parse (nextPos pos c) s')
					 (nullError d)
			[] -> NoParse (eofError d)


-- Parse an additive-precedence expression
pAdditive :: ArithDerivs -> Result ArithDerivs Int
Parser pAdditive =
	    (do l <- Parser advMultitive
		f <- Parser advAdditiveSuffix
		return (f l))

pAdditiveSuffix :: ArithDerivs -> Result ArithDerivs (Int -> Int)
Parser pAdditiveSuffix =
	    (do symbol '+'
		r <- Parser advMultitive
		f <- Parser advAdditiveSuffix
		return (\l -> f (l + r)))
	</> (do symbol '-'
		r <- Parser advMultitive
		f <- Parser advAdditiveSuffix
		return (\l -> f (l - r)))
	</> (do return (\v -> v))


-- Parse a multiplicative-precedence expression
pMultitive :: ArithDerivs -> Result ArithDerivs Int
Parser pMultitive =
	    (do l <- Parser advPrimary
		f <- Parser advMultitiveSuffix
		return (f l))

pMultitiveSuffix :: ArithDerivs -> Result ArithDerivs (Int -> Int)
Parser pMultitiveSuffix =
	    (do symbol '*'
		r <- Parser advMultitive
		f <- Parser advMultitiveSuffix
		return (\l -> f (l * r)))
	</> (do symbol '/'
		r <- Parser advMultitive
		f <- Parser advMultitiveSuffix
		return (\l -> f (l `div` r)))
	</> (do symbol '%'
		r <- Parser advMultitive
		f <- Parser advMultitiveSuffix
		return (\l -> f (l `mod` r)))
	</> (do return (\v -> v))


-- Parse a primary expression
pPrimary :: ArithDerivs -> Result ArithDerivs Int
Parser pPrimary =
	    (do symbol '('
		v <- Parser advAdditive
		symbol ')'
		return v)
	</> (do Parser advDecimal)


-- Parse a decimal number followed by optional whitespace
pDecimal :: ArithDerivs -> Result ArithDerivs Int
Parser pDecimal =
	    (do (v,n) <- Parser advDigits
		Parser advSpacing
		return v)
	<?> "decimal number"


-- Parse a string of consecutive decimal digits.
-- The result is (value, number of digits).
pDigits :: ArithDerivs -> Result ArithDerivs (Int, Int)
Parser pDigits =
	    (do vl <- Parser advDigit
		(vr,n) <- Parser advDigits
		return (vl*10^n + vr, n+1))
	</> (do vl <- Parser advDigit
		return (vl, 1))

-- Parse a decimal digit
pDigit :: ArithDerivs -> Result ArithDerivs Int
Parser pDigit =
	    (do c <- digit
		return (digitToInt c))

-- "Parser combinator" to look for a specific symbol.
-- Cannot be memoized directly because it takes a parameter,
-- but that does not matter because it is non-recursive.
symbol c = (do	c' <- Parser advSymbol
		if c' == c then return c
			   else fail [])
	<?> show c

-- Parse a symbol character followed by optional whitespace
pSymbol :: ArithDerivs -> Result ArithDerivs Char
Parser pSymbol =
	do	c <- oneOf "+-*/%()"
		Parser advSpacing
		return c

-- Parse zero or more whitespace characters
pSpacing :: ArithDerivs -> Result ArithDerivs ()
Parser pSpacing =
	    (do	space
		Parser advSpacing
		return ())
	</> (do return ())

