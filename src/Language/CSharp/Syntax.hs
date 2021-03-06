module Language.CSharp.Syntax where

import Data.ByteString (ByteString)
import Data.Text (Text)

------------------------------------------------------------------------
-- Top level

data CompilationUnit = CompilationUnit [Namespace]
    deriving (Eq, Show)

data Namespace = Namespace Name [TypeDecl]
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Declarations

data TypeDecl = Class [ClassMod] Ident [Method]
    deriving (Eq, Show)

data Method = Method [MethodMod] (Maybe Type) Ident [FormalParam] [Stmt]
    deriving (Eq, Show)

data FormalParam = FormalParam (Maybe ParamMod) Type Ident
    deriving (Eq, Show)

data VarDecl = VarDecl Ident (Maybe VarInit)
    deriving (Eq, Show)

data VarInit = VarInitExp Exp
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Statements

data Stmt = LocalVar LocalType [VarDecl]
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Expressions

data Exp
    = Lit Literal
    | SimpleName Ident [TypeArg]
    | ParenExp Exp
    | MemberAccess Exp Ident [TypeArg]
    | Invocation Exp [Arg]
    | ElementAccess Exp [Exp]
    | ThisAccess
    | BaseMember Ident
    | BaseElement [Exp]
    | PostIncrement Exp
    | PostDecrement Exp
--    | PreIncrement Exp
--    | PreDecrement Exp
    | ObjectCreation Type [Arg] (Maybe ObjectInit)
    deriving (Eq, Show)

data Arg = Arg (Maybe Ident) (Maybe ArgMod) Exp
    deriving (Eq, Show)

data ObjectInit
    = ObjectInit [MemberInit]
    | CollectionInit [ElementInit]
    deriving (Eq, Show)

data MemberInit = MemberInit Ident InitVal
    deriving (Eq, Show)

data ElementInit = ElementInit [Exp]
    deriving (Eq, Show)

data InitVal
    = InitVal Exp
    | InitObject ObjectInit
    deriving (Eq, Show)

data Literal
    = Null
    | Bool Bool
    | Int ByteString
    | Real ByteString
    | Char Text
    | String Text
    | Verbatim Text
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Types

data LocalType = Type Type | Var
    deriving (Eq, Show)

type TypeArg = Type

data Type
    = UserType Name [TypeArg]
    | PrimType PrimType
    | ArrayType Type ArrayRank
    deriving (Eq, Show)

type ArrayRank = Int

data PrimType
    -- Value types
    = BoolT
    | SByteT
    | ByteT
    | ShortT
    | UShortT
    | IntT
    | UIntT
    | LongT
    | ULongT
    | CharT
    | FloatT
    | DoubleT
    | DecimalT
    -- Reference types
    | ObjectT
    | StringT
    | DynamicT
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Modifiers

data ClassMod
    = NewC
    | PublicC
    | ProtectedC
    | InternalC
    | PrivateC
    | AbstractC
    | SealedC
    | StaticC
    | UnsafeC
    deriving (Eq, Show)

data MethodMod
    = NewM
    | PublicM
    | ProtectedM
    | InternalM
    | PrivateM
    | StaticM
    | VirtualM
    | SealedM
    | OverrideM
    | AbstractM
    | ExternM
    | UnsafeM
    deriving (Eq, Show)

data ParamMod = RefParam | OutParam | ThisParam
    deriving (Eq, Show)

data ArgMod = RefArg | OutArg
    deriving (Eq, Show)

------------------------------------------------------------------------
-- Identifiers

data Ident = Ident Text
    deriving (Eq, Show)

data Name = Name [Ident]
    deriving (Eq, Show)
