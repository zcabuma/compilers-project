import java_cup.runtime.*;

%%
%class Lexer
%unicode
%cup
%line
%column

%{
  private boolean debug_mode;
  public  boolean debug()            { return debug_mode; }
  public  void    debug(boolean mode){ debug_mode = mode; }

  private void print_lexeme(int type, Object value){
    if(!debug()){ return; }

    System.out.print("<");
    switch(type){
      case sym.LET:
        System.out.print("LET"); break;
      case sym.EQUAL:
        System.out.print(":="); break;
      case sym.SEMICOL:
        System.out.print(";"); break;
      case sym.PLUS:
        System.out.print("+"); break;
      case sym.MINUS:
        System.out.print("-"); break;
      case sym.MULT:
        System.out.print("*"); break;
      case sym.DIV:
        System.out.print("/"); break;
      case sym.LPAREN:
        System.out.print("("); break;
      case sym.RPAREN:
        System.out.print(")"); break;
      case sym.INTEGER:
        System.out.printf("INT %d", value); break;
      case sym.IDENTIFIER:
        System.out.printf("IDENT %s", value); break;
      case sym.LBRACE:
        System.out.print("{"); break;
      case sym.RBRACE:
              System.out.print("}"); break;

      case sym.LCOMMENT:
            System.out.print("/#"); break;
      case sym.RCOMMENT:
            System.out.print("#/"); break;
      case sym.INLINECOMMENT:
            System.out.print("#"); break;
      case sym.EXCLAMATION:
            System.out.print("!"); break;
      case sym.AND:
            System.out.print("&&"); break;
       case sym.OR:
            System.out.print("||"); break;
       case sym.POWER:
            System.out.print("^"); break;
       case sym.IN:
            System.out.print("in"); break;
       case sym.LESS:
            System.out.print("<"); break;
       case sym.LESSEQ:
            System.out.print("<="); break;
       case sym.EQ:
            System.out.print("=="); break;
       case sym.NOTEQ:
            System.out.print("!="); break;
       case sym.MAIN:
            System.out.print("main"); break;
    }
    System.out.print(">  ");
  }

  private Symbol symbol(int type) {
    print_lexeme(type, null);
    return new Symbol(type, yyline, yycolumn);
  }
  private Symbol symbol(int type, Object value) {
    print_lexeme(type, value);
    return new Symbol(type, yyline, yycolumn, value);
  }

%}

Whitespace = \r|\n|\r\n|" "|"\t"
Letter = [a-zA-Z]
Digit = [0-9]
IdChar = {Letter} | {Digit} | "_"
Identifier = {Letter}{IdChar}*
Integer = (0|[1-9]{Digit}*)

Denominator = [1-9][0-9]*
Numerator = [0-9]*
Rational = Denominator'\'Numerator | Rational

Natural = {Digit}*
Integer = -?Natural

Boolean = "T" | "F"

Float = [0-9]+\.[0-9]+

Punctuation = "!" | "\"" | "#" | "$" | "%" | "&" | " ' " | "(" | ")" | "*" | "+" | "," | "-" | "." | "/" | ":" | ";" | "<" | "=" | ">" | "?" | "@" | "[" | "\\" | "]" | "^" | "_" | "`" | "{" | "}" | "~" | "]" | "|"
Character = "\`"({Punctuation} | {Letter})"\`"

Comments = "/#"~"#/" | "#"."\n"

SecurityTyped = "H"|"L"


ElementString = {Character} ","
String = ("[" {ElementString}* {Character} "]") | ("[" "]") | ([String])

NumberInteger = {Integer}
ElementNumber = {NumberInteger} ","
SeqInteger = ("[" {ElementNumber}* {NumberInteger} "]") | ("[""]") | ([SeqInteger])

NumberFloat = {Float}
ElementNumber = {NumberFloat} ","
SeqFloat = ("[" {ElementNumber}* {NumberFloat} "]") | ("[""]") | ([SeqFloat])

NumberRational = {Rational}
ElementNumber = {NumberRational} ","
SeqRational = ("[" {ElementNumber}* {NumberRational} "]") | ("[""]") | ([SeqRational])








%%

<YYINITIAL> {

  "main"      {return symbol(sym.MAIN);}
  "let"         { return symbol(sym.LET);                                       }
  {Integer}     { return symbol(sym.INTEGER,
                                Integer.parseInt(yytext()));                    }
  {Whitespace}  { /* do nothing */               }
  ":="          { return symbol(sym.EQUAL);      }
  ";"           { return symbol(sym.SEMICOL);    }
  "+"           { return symbol(sym.PLUS);       }
  "-"           { return symbol(sym.MINUS);      }
  "*"           { return symbol(sym.MULT);       }
  "/"           { return symbol(sym.DIV);        }
  "("           { return symbol(sym.LPAREN);     }
  ")"           { return symbol(sym.RPAREN);     }
  {Character}      { return symbol(sym.CHAR); }
  "{"           { return symbol(sym.LBRACE);     }
  "}"           { return symbol(sym.RBRACE);     }
  {Boolean}     {return symbol(sym.BOOL, Boolean.parseBoolean(yytext()));}

   "/#"         { return symbol(sym.LCOMMENT);    }
   "#/"         {return symbol(sym.RCOMMENT);}
   "#"          { return symbol(sym.INLINECOMMENT);}
    "!"         {return symbol(sym.EXCLAMATION);}
    "&&"        {return symbol(sym.AND);}
    "||"        {return symbol(sym.OR);  }
    "^"         {return symbol(sym.POWER);}
    "in"        {return symbol(sym.IN);}
    "<"         {return symbol(sym.LESS);}
    "<="        {return symbol(sym.LESSEQ);}
    "=="        { return symbol(sym.EQ);}
    "!="        {return symbol(sym.NOTEQ);}
    {Identifier}  { return symbol(sym.IDENTIFIER, yytext());                   }





}

[^]  {
  System.out.println("file:" + (yyline+1) +
    ":0: Error: Invalid input '" + yytext()+"'");
  return symbol(sym.BADCHAR);
}

