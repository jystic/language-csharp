{-# LANGUAGE FlexibleInstances #-}

module Language.CSharp.Pretty where

import qualified Data.ByteString.Char8 as B
import           Data.List (intersperse)
import qualified Data.Text as T
import           Text.PrettyPrint
import           Language.CSharp.Syntax

------------------------------------------------------------------------
-- Pretty typeclass

class Pretty a where
    pretty :: a -> Doc
    pretty = prettyPrec 0

    prettyPrec :: Int -> a -> Doc
    prettyPrec _ = pretty

render' :: Pretty a => a -> String
render' = render . pretty

------------------------------------------------------------------------
-- Top level

instance Pretty CompilationUnit where
    pretty (CompilationUnit ns) = vsep' ns

instance Pretty Namespace where
    pretty (Namespace n ts) =
        text "namespace" <+> pp n
        $+$ block (vsep' ts)

------------------------------------------------------------------------
-- Declarations

instance Pretty TypeDecl where
    pretty (Class mds n ms) =
        hsep' mds <+> text "class" <+> pp n
        $+$ block (vsep' ms)

instance Pretty Method where
    pretty (Method ms t n ps stmts) =
        hsep' ms <+> pp t <+> pp n <> parens (params ps)
        $+$ block (vcat' stmts)

instance Pretty FormalParam where
    pretty (FormalParam Nothing  t n) =          pp t <+> pp n
    pretty (FormalParam (Just m) t n) = pp m <+> pp t <+> pp n

instance Pretty VarDecl where
    pretty (VarDecl n Nothing)  = pp n
    pretty (VarDecl n (Just d)) = pp n <+> equals <+> pp d

instance Pretty VarInit where
    pretty (VarInitExp exp) = pp exp

------------------------------------------------------------------------
-- Statements

instance Pretty Stmt where
    pretty (LocalVar t vds) = pp t <+> params vds <> semi

------------------------------------------------------------------------
-- Expressions

instance Pretty Exp where
    pretty (Lit lit)               = pp lit
    pretty (SimpleName n ts)       = pp n <> pp ts
    pretty (ParenExp exp)          = parens (pp exp)
    pretty (MemberAccess exp n ts) = pp exp <> dot <> pp n <> pp ts
    pretty (Invocation exp args)   = pp exp <> invoke args
    pretty (ElementAccess exp ixs) = pp exp <> brackets (params ixs)
    pretty (ThisAccess)            = text "this"
    pretty (BaseMember n)          = text "base" <> dot <> pp n
    pretty (BaseElement ixs)       = text "base" <> brackets (params ixs)
    pretty (PostIncrement exp)     = pp exp <> text "++"
    pretty (PostDecrement exp)     = pp exp <> text "--"
--    pretty (PreIncrement exp)      = text "++" <> pp exp
--    pretty (PreDecrement exp)      = text "--" <> pp exp

    pretty (ObjectCreation t [] (Just oi)) = new t <+> pp oi
    pretty (ObjectCreation t as (Just oi)) = new t <> invoke as <+> pp oi
    pretty (ObjectCreation t as Nothing)   = new t <> invoke as

new :: Pretty a => a -> Doc
new t = text "new" <+> pp t

instance Pretty Arg where
    pretty (Arg i m e) = name i <> mod m <> pp e
      where
        name Nothing   = empty
        name (Just i') = pp i' <> colon <> space
        mod Nothing    = empty
        mod (Just m')  = pp m' <> space

instance Pretty ObjectInit where
    pretty (ObjectInit ms) = lineBlock $ sep' comma ms
    pretty (CollectionInit es) = lineBlock $ sep' comma es

instance Pretty MemberInit where
    pretty (MemberInit n v) = pp n <+> equals <+> pp v

instance Pretty InitVal where
    pretty (InitVal exp)   = pp exp
    pretty (InitObject oi) = pp oi

instance Pretty ElementInit where
    pretty (ElementInit (x:[])) = pp x
    pretty (ElementInit xs) = lineBlock $ hcatSep' (comma <> space) xs

instance Pretty Literal where
    pretty (Null)        = text "null"
    pretty (Bool True)   = text "true"
    pretty (Bool False)  = text "false"
    pretty (Int n)       = pp n
    pretty (Real f)      = pp f
    pretty (Char c)      = quotes (pp c)
    pretty (String cs)   = doubleQuotes (pp cs)
    pretty (Verbatim cs) = char '@' <> doubleQuotes (pp cs)

------------------------------------------------------------------------
-- Types

instance Pretty (Maybe Type) where
    pretty Nothing  = text "void"
    pretty (Just t) = pp t

instance Pretty LocalType where
    pretty (Type t) = pp t
    pretty Var      = text "var"

instance Pretty [TypeArg] where
    pretty [] = empty
    pretty ts = angles (params ts)

instance Pretty Type where
    pretty (UserType t ts) = pp t <> pretty ts
    pretty (PrimType t)    = pp t
    pretty (ArrayType t r) = pp t <> prettyRank r
      where
        prettyRank r = brackets (hcatSep comma $ replicate r empty)

instance Pretty PrimType where
    pretty BoolT    = text "bool"
    pretty SByteT   = text "sbyte"
    pretty ByteT    = text "byte"
    pretty ShortT   = text "short"
    pretty UShortT  = text "ushort"
    pretty IntT     = text "int"
    pretty UIntT    = text "uint"
    pretty LongT    = text "long"
    pretty ULongT   = text "ulong"
    pretty CharT    = text "char"
    pretty FloatT   = text "float"
    pretty DoubleT  = text "double"
    pretty DecimalT = text "decimal"
    pretty ObjectT  = text "object"
    pretty StringT  = text "string"
    pretty DynamicT = text "dynamic"

instance Pretty ClassMod where
    pretty NewC       = text "new"
    pretty PublicC    = text "public"
    pretty ProtectedC = text "protected"
    pretty InternalC  = text "internal"
    pretty PrivateC   = text "private"
    pretty AbstractC  = text "abstract"
    pretty SealedC    = text "sealed"
    pretty StaticC    = text "static"
    pretty UnsafeC    = text "unsafe"

instance Pretty MethodMod where
    pretty NewM       = text "new"
    pretty PublicM    = text "public"
    pretty ProtectedM = text "protected"
    pretty InternalM  = text "internal"
    pretty PrivateM   = text "private"
    pretty AbstractM  = text "abstract"
    pretty VirtualM   = text "virtual"
    pretty OverrideM  = text "override"
    pretty SealedM    = text "sealed"
    pretty StaticM    = text "static"
    pretty ExternM    = text "extern"
    pretty UnsafeM    = text "unsafe"

instance Pretty ParamMod where
    pretty RefParam  = text "ref"
    pretty OutParam  = text "out"
    pretty ThisParam = text "this"

instance Pretty ArgMod where
    pretty RefArg = text "ref"
    pretty OutArg = text "out"

------------------------------------------------------------------------
-- Names and identifiers

instance Pretty Name where
    pretty (Name is) = hcatSep' dot is

instance Pretty Ident where
    pretty (Ident s) = pp s

------------------------------------------------------------------------
-- ByteString / Text

instance Pretty B.ByteString where
    pretty = text . B.unpack

instance Pretty T.Text where
    pretty = text . T.unpack

------------------------------------------------------------------------
-- Helpers

indent :: Int
indent = 4

block :: Doc -> Doc
block x = char '{' $+$ nest indent x $+$ char '}'

lineBlock :: Doc -> Doc
lineBlock = braces . spaces

invoke :: Pretty a => [a] -> Doc
invoke xs = parens (params xs)

params :: Pretty a => [a] -> Doc
params = hcatSep' (comma <> space)

angles :: Doc -> Doc
angles d = char '<' <> d <> char '>'

spaces :: Doc -> Doc
spaces d = space <> d <> space

dot :: Doc
dot = char '.'

------------------------------------------------------------------------

-- | Shorthand for writing pretty
pp :: Pretty a => a -> Doc
pp = pretty

blank :: Doc
blank = nest (-1000) (text "")

vsep :: [Doc] -> Doc
vsep = foldr ($+$) empty

vsep' :: Pretty a => [a] -> Doc
vsep' = vsep . intersperse blank . map pretty

vcat' :: Pretty a => [a] -> Doc
vcat' = vcat . map pretty

sep' :: Pretty a => Doc -> [a] -> Doc
sep' s = sep . punctuate s . map pretty

hsep' :: Pretty a => [a] -> Doc
hsep' = hsep . map pretty

hcatSep :: Doc -> [Doc] -> Doc
hcatSep s = hcat . intersperse s

hcatSep' :: Pretty a => Doc -> [a] -> Doc
hcatSep' s = hcatSep s . map pretty
