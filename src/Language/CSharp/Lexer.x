{
module Language.CSharp.Lexer
    ( L (..)
    , Token (..)
    , lexer
    ) where

import qualified Data.ByteString.Lazy.Char8 as L
import           Numeric
}

%wrapper "posn-bytestring"

-- C# actually defines a letter to be any character (or escape sequence)
-- from the Unicode classes Lu, Ll, Lt, Lm, Lo or Nl. Identifiers must
-- start with a letter or an underscore, but can then also contain
-- characters from the classes Mn, Mc, Nd, Pc or Cf.
$ident_start = [a-zA-Z_\@]
$ident_part  = [a-zA-Z_0-9]

$digit     = [0-9]
$hex_digit = [0-9a-fA-F]
$sign      = [\+\-]

@int_suffix  = [uU][lL]? | [lL][uU]?
@real_suffix = [fFdDmM]
@exponent    = [eE] $sign? $digit+

$single_character = [^\r\n\'\\]
@simple_escape    = \\ [\'\"\0\a\b\f\n\r\t\v\\]
@hex_escape       = \\x $hex_digit{1,4}
@unicode_escape   = \\u $hex_digit{4} | \\U $hex_digit{8}
@character        = $single_character | @simple_escape | @hex_escape | @unicode_escape

@newline = [\n\r] | \r\n
@any     = . | @newline
@comment = "/*" @any* "*/"
         | "//" .* @newline

tokens :-

$white+  ;
@comment ;

-- Keywords
abstract   { constTok Tok_Abstract   }
as         { constTok Tok_As         }
base       { constTok Tok_Base       }
bool       { constTok Tok_Bool       }
break      { constTok Tok_Break      }
byte       { constTok Tok_Byte       }
case       { constTok Tok_Case       }
catch      { constTok Tok_Catch      }
char       { constTok Tok_Char       }
checked    { constTok Tok_Checked    }
class      { constTok Tok_Class      }
const      { constTok Tok_Const      }
continue   { constTok Tok_Continue   }
decimal    { constTok Tok_Decimal    }
default    { constTok Tok_Default    }
delegate   { constTok Tok_Delegate   }
do         { constTok Tok_Do         }
double     { constTok Tok_Double     }
else       { constTok Tok_Else       }
enum       { constTok Tok_Enum       }
event      { constTok Tok_Event      }
explicit   { constTok Tok_Explicit   }
extern     { constTok Tok_Extern     }
false      { constTok Tok_False      }
finally    { constTok Tok_Finally    }
fixed      { constTok Tok_Fixed      }
float      { constTok Tok_Float      }
for        { constTok Tok_For        }
foreach    { constTok Tok_Foreach    }
goto       { constTok Tok_Goto       }
if         { constTok Tok_If         }
implicit   { constTok Tok_Implicit   }
in         { constTok Tok_In         }
int        { constTok Tok_Int        }
interface  { constTok Tok_Interface  }
internal   { constTok Tok_Internal   }
is         { constTok Tok_Is         }
lock       { constTok Tok_Lock       }
long       { constTok Tok_Long       }
namespace  { constTok Tok_Namespace  }
new        { constTok Tok_New        }
null       { constTok Tok_Null       }
object     { constTok Tok_Object     }
operator   { constTok Tok_Operator   }
out        { constTok Tok_Out        }
override   { constTok Tok_Override   }
params     { constTok Tok_Params     }
private    { constTok Tok_Private    }
protected  { constTok Tok_Protected  }
public     { constTok Tok_Public     }
readonly   { constTok Tok_Readonly   }
ref        { constTok Tok_Ref        }
return     { constTok Tok_Return     }
sbyte      { constTok Tok_Sbyte      }
sealed     { constTok Tok_Sealed     }
short      { constTok Tok_Short      }
sizeof     { constTok Tok_Sizeof     }
stackalloc { constTok Tok_Stackalloc }
static     { constTok Tok_Static     }
string     { constTok Tok_String     }
struct     { constTok Tok_Struct     }
switch     { constTok Tok_Switch     }
this       { constTok Tok_This       }
throw      { constTok Tok_Throw      }
true       { constTok Tok_True       }
try        { constTok Tok_Try        }
typeof     { constTok Tok_Typeof     }
uint       { constTok Tok_Uint       }
ulong      { constTok Tok_Ulong      }
unchecked  { constTok Tok_Unchecked  }
unsafe     { constTok Tok_Unsafe     }
ushort     { constTok Tok_Ushort     }
using      { constTok Tok_Using      }
virtual    { constTok Tok_Virtual    }
void       { constTok Tok_Void       }
volatile   { constTok Tok_Volatile   }
while      { constTok Tok_While      }

-- Punctuators
\( { constTok Tok_LParen   }
\) { constTok Tok_RParen   }
\[ { constTok Tok_LBracket }
\] { constTok Tok_RBracket }
\{ { constTok Tok_LBrace   }
\} { constTok Tok_RBrace   }
\; { constTok Tok_Semi     }
\, { constTok Tok_Comma    }
\. { constTok Tok_Dot      }

-- Operators
\= { constTok Tok_Assign }

-- Integer literals
      $digit+     @int_suffix? { stringTok Tok_IntLit }
0[xX] $hex_digit+ @int_suffix? { stringTok Tok_IntLit }

-- Real literals
$digit+ \. $digit+ @exponent? @real_suffix? { stringTok Tok_RealLit }
        \. $digit+ @exponent? @real_suffix? { stringTok Tok_RealLit }
           $digit+ @exponent  @real_suffix? { stringTok Tok_RealLit }
           $digit+            @real_suffix  { stringTok Tok_RealLit }

-- Character literals
\' @character \' { stringTok Tok_CharLit }

-- Identifiers
$ident_start $ident_part* { stringTok Tok_Ident }
{

wrap :: (str -> tok) -> AlexPosn -> str -> L tok
wrap f (AlexPn _ line col) s = L (line, col) (f s)

constTok = wrap . const
stringTok f = wrap (f . L.unpack)

data L a = L Pos a
  deriving (Show, Eq)

-- (line, column)
type Pos = (Int, Int)

data Token
    -- Keywords
    = Tok_Abstract
    | Tok_As
    | Tok_Base
    | Tok_Bool
    | Tok_Break
    | Tok_Byte
    | Tok_Case
    | Tok_Catch
    | Tok_Char
    | Tok_Checked
    | Tok_Class
    | Tok_Const
    | Tok_Continue
    | Tok_Decimal
    | Tok_Default
    | Tok_Delegate
    | Tok_Do
    | Tok_Double
    | Tok_Else
    | Tok_Enum
    | Tok_Event
    | Tok_Explicit
    | Tok_Extern
    | Tok_False
    | Tok_Finally
    | Tok_Fixed
    | Tok_Float
    | Tok_For
    | Tok_Foreach
    | Tok_Goto
    | Tok_If
    | Tok_Implicit
    | Tok_In
    | Tok_Int
    | Tok_Interface
    | Tok_Internal
    | Tok_Is
    | Tok_Lock
    | Tok_Long
    | Tok_Namespace
    | Tok_New
    | Tok_Null
    | Tok_Object
    | Tok_Operator
    | Tok_Out
    | Tok_Override
    | Tok_Params
    | Tok_Private
    | Tok_Protected
    | Tok_Public
    | Tok_Readonly
    | Tok_Ref
    | Tok_Return
    | Tok_Sbyte
    | Tok_Sealed
    | Tok_Short
    | Tok_Sizeof
    | Tok_Stackalloc
    | Tok_Static
    | Tok_String
    | Tok_Struct
    | Tok_Switch
    | Tok_This
    | Tok_Throw
    | Tok_True
    | Tok_Try
    | Tok_Typeof
    | Tok_Uint
    | Tok_Ulong
    | Tok_Unchecked
    | Tok_Unsafe
    | Tok_Ushort
    | Tok_Using
    | Tok_Virtual
    | Tok_Void
    | Tok_Volatile
    | Tok_While

    -- Punctuators
    | Tok_LParen
    | Tok_RParen
    | Tok_LBracket
    | Tok_RBracket
    | Tok_LBrace
    | Tok_RBrace
    | Tok_Semi
    | Tok_Comma
    | Tok_Dot

    -- Operators
    | Tok_Assign

    -- Identifiers
    | Tok_Ident String

    -- Literals
    | Tok_IntLit String
    | Tok_RealLit String
    | Tok_CharLit String

  deriving (Eq, Show)

lexer :: L.ByteString -> [L Token]
lexer = alexScanTokens
}
