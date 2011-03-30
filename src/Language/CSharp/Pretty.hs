{-# LANGUAGE FlexibleInstances #-}

module Language.CSharp.Pretty where

import Data.List (intersperse)
import Text.PrettyPrint
import Language.CSharp.Syntax

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
        text "namespace" <+> pretty n
        $+$ block (vsep' ts)

------------------------------------------------------------------------
-- Declarations

instance Pretty TypeDecl where
    pretty (Class mds n ms) =
        hcat' mds <+> text "class" <+> pretty n
        $+$ block (vsep' ms)

instance Pretty Method where
    pretty (Method ms t n ps stmts) =
        hcat' ms <+> pretty t <+> pretty n <> parens (hcatComma ps)
        $+$ block (vcat' stmts)

instance Pretty FormalParam where
    pretty (FormalParam ms t n) =
        hcat' ms <+> pretty t <+> pretty n

instance Pretty VarDecl where
    pretty (VarDecl n Nothing)  = pretty n
    pretty (VarDecl n (Just d)) =
        pretty n <+> equals <+> pretty d

instance Pretty VarInit where
    pretty (InitExp exp) = pretty exp

------------------------------------------------------------------------
-- Statements

instance Pretty Stmt where
    pretty (LocalVar t vds) = pretty t <+> hcatComma vds <> semi

------------------------------------------------------------------------
-- Expressions

instance Pretty Exp where
    pretty (Lit lit) = pretty lit

instance Pretty Literal where
    pretty (Null)        = text "null"
    pretty (Bool True)   = text "true"
    pretty (Bool False)  = text "false"
    pretty (Int n)       = text n
    pretty (Real f)      = text f
    pretty (Char c)      = char '\''  <> text c  <> char '\''
    pretty (String cs)   = char '"'   <> text cs <> char '"'
    pretty (Verbatim cs) = text "@\"" <> text cs <> char '"'

------------------------------------------------------------------------
-- Types

instance Pretty (Maybe Type) where
    pretty Nothing  = text "void"
    pretty (Just t) = pretty t

instance Pretty LocalType where
    pretty (Type t) = pretty t
    pretty Var      = text "var"

instance Pretty Type where
    pretty (PrimType t) = pretty t
    pretty (UserType t) = pretty t

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

instance Pretty Modifier where
    pretty New       = text "new"
    pretty Public    = text "public"
    pretty Protected = text "protected"
    pretty Internal  = text "internal"
    pretty Private   = text "private"
    pretty Abstract  = text "abstract"
    pretty Virtual   = text "virtual"
    pretty Override  = text "override"
    pretty Sealed    = text "sealed"
    pretty Static    = text "static"
    pretty Extern    = text "extern"
    pretty Unsafe    = text "unsafe"

instance Pretty ParamModifier where
    pretty Ref  = text "ref"
    pretty Out  = text "out"
    pretty This = text "this"

------------------------------------------------------------------------
-- Names and identifiers

instance Pretty Name where
    pretty (Name is) = hcat $ punctuate (char '.') $ map pretty is

instance Pretty Ident where
    pretty (Ident s) = text s

------------------------------------------------------------------------
-- Helpers

indent :: Int
indent = 4

block :: Doc -> Doc
block x = char '{'
      $+$ nest indent x
      $+$ char '}'

blank :: Doc
blank = nest (-1000) (text "")

vsep :: [Doc] -> Doc
vsep = foldr ($+$) empty

vsep' :: Pretty a => [a] -> Doc
vsep' = vsep . intersperse blank . map pretty

vcat' :: Pretty a => [a] -> Doc
vcat' = vcat . map pretty

hcat' :: Pretty a => [a] -> Doc
hcat' = hcat . map pretty

hcatComma :: Pretty a => [a] -> Doc
hcatComma = hcatSep (comma <> space)

hcatSep :: Pretty a => Doc -> [a] -> Doc
hcatSep s xs = hcat $ intersperse s $ map pretty xs
